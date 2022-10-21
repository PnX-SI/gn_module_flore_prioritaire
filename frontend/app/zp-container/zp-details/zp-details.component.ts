import { Component, OnInit, ViewChild } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';

import { ToastrService } from 'ngx-toastr';
import { MatDialog } from '@angular/material';

import { CommonService } from '@geonature_common/service/common.service';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { ConfirmationDialog } from '@geonature_common/others/modal-confirmation/confirmation.dialog';

import { DataService } from '../../services/data.service';
import { StoreService } from '../../services/store.service';
import { ModuleConfig } from '../../module.config';

@Component({
  selector: 'gn-pf-zp-details',
  templateUrl: 'zp-details.component.html',
  styleUrls: ['./zp-details.component.scss'],
  providers: [MapListService],
})
export class ZpDetailsComponent implements OnInit {
  public idZp: string;
  public currentAp;
  public filteredData = [];
  @ViewChild('table') table: any;
  public displayColumns: Array<any>;

  constructor(
    public dialog: MatDialog,
    public mapService: MapService,
    public storeService: StoreService,
    public activatedRoute: ActivatedRoute,
    public router: Router,
    public api: DataService,
    private commonService: CommonService,
    public mapListService: MapListService,
    private toastrService: ToastrService
  ) {}

  ngOnInit() {
    this.displayColumns = this.storeService.fpConfig.datatable_ap_columns;
    this.activatedRoute.parent.params.subscribe(params => {
      this.idZp = params['idZp'];
      this.storeService.queryString = this.storeService.queryString.set('id_zp', this.idZp);
      this.storeService.idSite = this.idZp;
    });
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.mapListService.idName = 'id_ap';
    this.mapListService.enableMapListConnexion(this.mapService.getMap());
    this.api.getOneProspectZone(this.storeService.idSite).subscribe(
      data => {
        this.storeService.zp = data['zp'];
        this.storeService.zpProperties = data['zp']['properties'];
        this.storeService.zpProperties['areas'] = this.storeService.zpProperties['areas'].filter(
          area => area.area_type.type_code == 'COM'
        );

        this.storeService.sites = data['aps'];
        this.mapListService.loadTableData(data['aps']);
        this.filteredData = this.mapListService.tableData;
      },
      error => {
        if (error.status != 404) {
          this.toastrService.error(
            'Une erreur est survenue lors de la récupération des informations sur le serveur',
            '',
            {
              positionClass: 'toast-top-right',
            }
          );
          console.log('error: ', error);
        }
      }
    );
  }

  onAddAp(idZp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zps`, idZp, 'aps', 'add']);
  }

  onEditAp(idZp, idAp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zps`, idZp, 'aps', idAp, 'edit']);
  }

  onDeleteAp(idAp) {
    const msg = `Êtes vous sûr de vouloir supprimer l'AP ${idAp} ?`;
    const dialogRef = this.dialog.open(ConfirmationDialog, {
      width: '350px',
      position: { top: '5%' },
      data: { message: msg },
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.api.deletePresenceArea(idAp).subscribe(
          data => {
            this.mapListService.tableData = this.mapListService.tableData.filter(item => {
              return idAp !== item.id_ap;
            });
            const filterFeature = this.storeService.sites.features.filter(feature => {
              return idAp !== feature.properties.id_ap;
            });
            this.storeService.sites['features'] = filterFeature;

            this.storeService.sites = Object.assign({}, this.storeService.sites);
            this.commonService.translateToaster('success', 'Releve.DeleteSuccessfully');
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

  backToZpsList() {
    this.router.navigate([`${ModuleConfig.MODULE_URL}`]);
  }

  toggleExpandRow(row) {
    let i = 0;
    while (i < this.storeService.sites.features.length) {
      if (row.id_ap == this.storeService.sites.features[i].properties.id_ap) {
        this.currentAp = this.storeService.sites.features[i];
      }
      i++;
    }

    this.table.rowDetail.toggleExpandRow(row);
  }

  onEachFeature(feature, layer) {
    // event from the map
    let site = feature.properties;
    this.mapListService.layerDict[feature.id] = layer;

    // Bind popup
    const customPopup =
      '<div class="title">' +
      'Altitude : ' +
      site.altitude_max +
      'm <br /> ' +
      'Surface : ' +
      Math.round(site.area) +
      ' m\u00b2' +
      '</div>';
    const customOptions = {
      className: 'custom-popup',
    };
    layer.bindPopup(customPopup, customOptions);

    // Actions on layer
    layer.on({
      click: e => {
        // toggle style
        this.mapListService.toggleStyle(layer);
        // observable
        this.mapListService.mapSelected.next(feature.id);
      },
      mouseover: e => {
        layer.openPopup();
      },
      mouseout: e => {
        layer.closePopup();
      },
    });
  }

  onEachZp(feature, layer) {
    layer.setStyle({ color: '#F4D03F', fillOpacity: 0, weight: 4 });
  }
}
