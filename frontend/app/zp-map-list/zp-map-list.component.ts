import { HttpParams } from '@angular/common/http';
import { Component, OnInit, AfterViewInit } from '@angular/core';
import { FormGroup, FormBuilder } from '@angular/forms';
import { Router } from '@angular/router';

import * as L from 'leaflet';
import { MatDialog } from '@angular/material';

import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { CommonService } from '@geonature_common/service/common.service';
import { ConfirmationDialog } from '@geonature_common/others/modal-confirmation/confirmation.dialog';

import { DataService } from '../services/data.service';
import { StoreService } from '../services/store.service';
import { ModuleConfig } from '../module.config';

@Component({
  selector: 'gn-pf-map-list',
  templateUrl: 'zp-map-list.component.html',
  styleUrls: ['zp-map-list.component.scss'],
  providers: [MapListService]
})
export class ZpMapListComponent implements OnInit, AfterViewInit {
  public leafletDrawOptions = leafletDrawOption;
  public geojson;
  public filteredData = [];
  public organisms = [];
  public municipalities = [];
  public filtersForm: FormGroup;
  public displayColumns: Array<any>;
  private map;
  public center;
  public zoom;
  public nbZp: number;

  constructor(
    public dialog: MatDialog,
    public mapService: MapService,
    private mapListService: MapListService,
    public router: Router,
    public storeService: StoreService,
    private commonService: CommonService,
    public api: DataService,
    private formBuilder: FormBuilder
  ) {}

  ngOnInit() {
    this.displayColumns = ModuleConfig.default_zp_columns;
    this.storeService.queryString = new HttpParams();
    this.storeService.queryString = this.storeService.queryString.set(
      'limit',
      '10'
    );
    this.mapListService.idName = 'id_zp';
    this.loadData();
    this.center = this.storeService.fpConfig.zoom_center;
    this.zoom = this.storeService.fpConfig.zoom;

    this.intializeFiltersForm();
    this.setListenerOnYearFilter();
    this.setListenerOnOrganismFilter();
    this.setListenerOnMunicipalityFilter();
  }

  private intializeFiltersForm() {
    this.filtersForm = this.formBuilder.group({
      filterYear: null,
      filterOrga: null,
      filterCom: null,
      filterTaxon: null,
      idZp: null
    });
  }

  private setListenerOnYearFilter() {
    this.filtersForm.controls.filterYear.valueChanges.subscribe(year => {
      if (year && year.toString().length === 4) {
        this.setQueryString('year', year.toString());
        this.loadData();
      }
      if (!year) {
        this.deleteQueryString('year');
        this.loadData();
      }
    });
  }

  private setListenerOnOrganismFilter() {
    this.filtersForm.controls.filterOrga.valueChanges.subscribe(org => {
      if (org) {
        this.setQueryString('id_organism', org);
        this.loadData();
      } else {
        this.deleteQueryString('id_organism');
        this.loadData();
      }
    });
  }

  private setListenerOnMunicipalityFilter() {
    this.filtersForm.controls.filterCom.valueChanges.subscribe(
      id_area => {
        if (id_area) {
          this.setQueryString('id_area', id_area);
          this.loadData();
        } else {
          this.deleteQueryString('id_area');
          this.loadData();
        }
      }
    );
  }

  private loadData() {
    this.api
      .getProspectZones(this.storeService.queryString)
      .subscribe(data => {
        this.nbZp = data.total;
        this.geojson = data.items;
        this.mapListService.loadTableData(data.items);
        this.filteredData = this.mapListService.tableData;
      });
  }

  private setQueryString(param: string, value) {
    this.storeService.queryString = this.storeService.queryString.set(
      param,
      value
    );
  }

  private deleteQueryString(param: string) {
    this.storeService.queryString = this.storeService.queryString.delete(param);
  }

  ngAfterViewInit() {
    // event from the list
    this.mapListService.enableMapListConnexion(this.mapService.getMap());

    this.map = this.mapService.getMap();
    this.addCustomControl();

    this.api.getOrganisms().subscribe(orgs => {
      this.organisms = orgs;
    });

    this.api.getMunicipalities().subscribe(municipalities => {
      this.municipalities = municipalities;
    });
  }

  private addCustomControl() {
    let initzoomcontrol = new L.Control();
    initzoomcontrol.setPosition('topleft');
    initzoomcontrol.onAdd = () => {
      var container = L.DomUtil.create(
        'button',
        ' btn btn-sm btn-outline-shadow leaflet-bar leaflet-control leaflet-control-custom'
      );
      container.innerHTML =
        '<i class="material-icons" style="line-height:normal;">crop_free</i>';
      container.style.padding = '4px 4px 1px';
      container.title = "Réinitialiser l'emprise de la carte";
      container.onclick = () => {
        this.map.setView(this.center, this.zoom);
      };
      return container;
    };
    initzoomcontrol.addTo(this.map);
  }

  onEachFeature(feature, layer) {
    this.mapListService.layerDict[feature.id] = layer;
    layer.on({
      click: e => {
        this.mapListService.toggleStyle(layer);
        this.mapListService.mapSelected.next(feature.id);
      }
    });
  }

  onChangePage(event) {
    this.storeService.queryString = this.storeService.queryString.set(
      'page',
      event.offset.toString()
    );
    this.loadData();
  }

  onAddZp() {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zps`, 'add']);
  }

  onEditZp(idZp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zps`, idZp, 'edit']);
  }

  onInfo(idZp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zps`, idZp, 'details']);
  }

  onDeleteZp(idZp) {
    const msg = `Êtes vous sûr de vouloir supprimer la ZP ${idZp} ?`;
    const dialogRef = this.dialog.open(ConfirmationDialog, {
      width: '350px',
      position: { top: '5%' },
      data: { message: msg }
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.api.deleteProspectZone(idZp).subscribe(
          data => {
            this.filteredData = this.filteredData.filter(item => {
              return idZp !== item.id_zp;
            });
            const filterFeature = this.geojson.features.filter(
              feature => {
                return idZp !== feature.properties.id_zp;
              }
            );
            this.geojson['features'] = filterFeature;
            this.geojson = Object.assign({}, this.geojson);
            this.commonService.translateToaster(
              'success',
              'Releve.DeleteSuccessfully'
            );
          },
          error => {
            if (error.status === 403) {
              this.commonService.translateToaster(
                'error',
                'NotAllowed'
              );
            } else {
              this.commonService.translateToaster(
                'error',
                'ErrorMessage'
              );
            }
          }
        );
      }
    });
  }

  onRemoveTaxon() {
    this.deleteQueryString('cd_nom');
    this.loadData();
  }

  onSearchTaxon(event) {
    this.setQueryString('cd_nom', event.item.cd_nom);
    this.loadData();
  }

  ngOnDestroy() {
    let filterkey = this.storeService.queryString.keys();
    filterkey.forEach(key => {
      this.storeService.queryString = this.storeService.queryString.delete(key);
    });
  }
}
