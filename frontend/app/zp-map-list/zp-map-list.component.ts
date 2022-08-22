import { HttpParams } from '@angular/common/http';
import {
  Component,
  OnInit,
  AfterViewInit,
  EventEmitter,
  Output
} from '@angular/core';
import { FormGroup, FormBuilder } from '@angular/forms';
import { Router } from '@angular/router';

import * as L from 'leaflet';
import { MatDialog } from "@angular/material";

import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { CommonService } from '@geonature_common/service/common.service';
import { ConfirmationDialog } from '@geonature_common/others/modal-confirmation/confirmation.dialog';

import { DataService } from '../services/data.service';
import { StoreService } from '../services/store.service';
import { ModuleConfig } from '../module.config';

@Component({
  selector: 'pnx-zp-map-list',
  templateUrl: 'zp-map-list.component.html',
  styleUrls: ['zp-map-list.component.scss'],
  providers: [MapListService]
})
export class ZpMapListComponent implements OnInit, AfterViewInit {
  public leafletDrawOptions = leafletDrawOption;
  public sites;
  public myGeoJSON;
  public filteredData = [];
  public tabOrganism = [];
  public municipalities = [];
  public tabTaxon = [];
  public dataLoaded = false;
  public oldFilterDate;
  public filterForm: FormGroup;
  public displayColumns: Array<any>;
  private _map;
  public center;
  public zoom;
  public nbZp: number;

  @Output()
  onDeleteFiltre = new EventEmitter<any>();

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

    this.filterForm = this.formBuilder.group({
      filterYear: null,
      filterOrga: null,
      filterCom: null,
      filterTaxon: null,
      idZp: null
    });

    this.filterForm.controls.filterYear.valueChanges.subscribe(year => {
      if (year && year.toString().length === 4) {
        this.setQueryString('year', year.toString());
        this.loadData();
      }
      if (!year) {
        this.deleteParams('year');
        this.loadData();
      }
    });

    this.filterForm.controls.filterOrga.valueChanges.subscribe(org => {
      if (org) {
        this.setQueryString('id_organism', org);
        this.loadData();
      } else {
        this.deleteParams('id_organism');
        this.loadData();
      }
    });

    this.filterForm.controls.filterCom.valueChanges.subscribe(id_area => {
      if (id_area) {
        this.setQueryString('id_area', id_area);
        this.loadData();
      } else {
        this.deleteParams('id_area');
        this.loadData();
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

  loadData() {
    this.api.getZProspects(this.storeService.queryString).subscribe(data => {
      this.nbZp = data.total;
      this.myGeoJSON = data.items;
      this.mapListService.loadTableData(data.items);
      this.filteredData = this.mapListService.tableData;
      this.dataLoaded = true;
    });
  }
  onAddZp() {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/post_zp`]);
  }

  onEditZp(idZp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/post_zp`, idZp]);
  }

  onInfo(idZp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zp`, idZp, 'details']);
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
        this.api.deleteZp(idZp).subscribe(
          data => {
            this.filteredData = this.filteredData.filter(item => {
              return idZp !== item.id_zp;
            });
            const filterFeature = this.myGeoJSON.features.filter(feature => {
              return idZp !== feature.properties.id_zp;
            });
            this.myGeoJSON['features'] = filterFeature;
            this.myGeoJSON = Object.assign({}, this.myGeoJSON);
            this.commonService.translateToaster(
              'success',
              'Releve.DeleteSuccessfully'
            );
          },
          error => {
            if (error.status === 403) {
              this.commonService.translateToaster('error', 'NotAllowed');
            } else {
              this.commonService.translateToaster('error', 'ErrorMessage');
            }
          }
        );
      }
    });
  }

  ngAfterViewInit() {
    // event from the list
    this.mapListService.enableMapListConnexion(this.mapService.getMap());

    this._map = this.mapService.getMap();
    this.addCustomControl();

    this.api.getOrganisme().subscribe(orgs => {
      this.tabOrganism = orgs;
    });

    this.api.getCommune().subscribe(municipalities => {
      this.municipalities = municipalities;
    });
  }

  getGeojson(geojson) {
    alert(JSON.stringify(geojson));
  }

  deleteControlValue() {
    console.log('Suppression');
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

  addCustomControl() {
    let initzoomcontrol = new L.Control();
    initzoomcontrol.setPosition('topleft');
    initzoomcontrol.onAdd = () => {
      var container = L.DomUtil.create(
        'button',
        ' btn btn-sm btn-outline-shadow leaflet-bar leaflet-control leaflet-control-custom'
      );
      container.innerHTML =
        '<i class="material-icons" style="line-height:normal;">crop_free</i>';
      container.style.padding = '1px 4px';
      container.title = "Réinitialiser l'emprise de la carte";
      container.onclick = () => {
        this._map.setView(this.center, this.zoom);
      };
      return container;
    };
    initzoomcontrol.addTo(this._map);
  }

  setQueryString(param: string, value) {
    this.storeService.queryString = this.storeService.queryString.set(
      param,
      value
    );
  }

  deleteParams(param: string) {
    this.storeService.queryString = this.storeService.queryString.delete(param);
  }

  removeCdNom() {
    this.deleteParams('cd_nom');
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
