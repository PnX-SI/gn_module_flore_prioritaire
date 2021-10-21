import { Component, OnInit, ViewChild } from "@angular/core";
import { Router, ActivatedRoute } from "@angular/router";
import { Location } from "@angular/common";
import { CommonService } from "@geonature_common/service/common.service";
import { ToastrService } from "ngx-toastr";
import * as L from "leaflet";

import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";

import { DataService } from "../services/data.service";
import { StoreService } from "../services/store.service";
import { ModuleConfig } from "../module.config";

@Component({
  selector: "pnx-zp-details",
  templateUrl: "zp-details.component.html",
  styleUrls: ["./zp-details.component.scss"],
})
export class ZpDetailsComponent implements OnInit {

  public currentSite = {};
  public show = true;
  private _map;
  public currentAp;
  public expanded: any = {};
  @ViewChild('table') table: any;

  constructor(
    public mapService: MapService,
    public storeService: StoreService,
    private _location: Location,
    public router: Router,
    public _api: DataService,
    private _commonService: CommonService,
    public activatedRoute: ActivatedRoute,
    public mapListService: MapListService,
    private toastr: ToastrService
  ) { }

  ngOnInit() {
    this.storeService.idSite = this.activatedRoute.snapshot.params['idSite'];

  }

  onAddAp(idZP) {
    this.router.navigate(
      [
        `${ModuleConfig.MODULE_URL}/zp`,
        idZP, 'post_ap'
      ]
    );
    this.storeService.showLeafletDraw();
  }

  onEditAp(idZP, idAP) {
    this.router.navigate(
      [
        `${ModuleConfig.MODULE_URL}/zp`,
        idZP, 'post_ap', idAP
      ]
    );
    this.storeService.showLeafletDraw();
  }

  onDeleteAp(indexap) {
    this._api.deleteAp(indexap).subscribe(
      data => {
        this.mapListService.tableData = this.mapListService.tableData.filter(item => {
          return indexap !== item.indexap
        })
        const filterFeature = this.storeService.sites.features.filter(feature => {
          return indexap !== feature.properties.indexap
        })
        this.storeService.sites['features'] = filterFeature;

        console.log(filterFeature)
        this.storeService.sites = Object.assign({}, this.storeService.sites);
        this._commonService.translateToaster(
          "success",
          "Releve.DeleteSuccessfully"
        );
      },
      error => {
        if (error.status === 403) {
          this._commonService.translateToaster("error", "NotAllowed");
        } else {
          this._commonService.translateToaster("error", "ErrorMessage");
        }
      }
    );
  }

  backToZp() {
    this.router.navigate([`${ModuleConfig.MODULE_URL}`]);
  }

  toggleExpandRow(row) {
    let i = 0;
    while (i < this.storeService.sites.features.length) {
      if (row.indexap == this.storeService.sites.features[i].properties.indexap) {
        this.currentAp = this.storeService.sites.features[i]
      }
      i++
    }
    console.log(this.currentAp);

    //this.mapListService.rowDetail.toggleExpandRow(indexap);
    this.table.rowDetail.toggleExpandRow(row);
  }

  onDetailToggle(event) {
    console.log('Detail Toggled', event);
  }

}