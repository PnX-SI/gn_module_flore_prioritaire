import { Component, OnInit, ViewChild } from "@angular/core";
import { Router, ActivatedRoute } from "@angular/router";
import { Location } from "@angular/common";
import { CommonService } from "@geonature_common/service/common.service";
import { ToastrService } from "ngx-toastr";

import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";

import { DataService } from "../../services/data.service";
import { StoreService } from "../../services/store.service";
import { ModuleConfig } from "../../module.config";

@Component({
  selector: "pnx-zp-details",
  templateUrl: "zp-details.component.html",
  styleUrls: ["./zp-details.component.scss"],
})
export class ZpDetailsComponent implements OnInit {
  public currentSite = {};
  public show = true;
  private map;
  public currentAp;
  public expanded: any = {};
  @ViewChild("table") table: any;

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
  ) {}

  ngOnInit() {}

  ngAfterViewInit() {
    this.storeService.toggleLeafletDraw(true);
  }

  onAddAp(idZP) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zp`, idZP, "post_ap"]);
  }

  onEditAp(idZP, idAP) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zp`, idZP, "post_ap", idAP]);
  }

  onDeleteAp(idAp) {
    this._api.deleteAp(idAp).subscribe(
      (data) => {
        this.mapListService.tableData = this.mapListService.tableData.filter((item) => {
          return idAp !== item.id_ap;
        });
        const filterFeature = this.storeService.sites.features.filter((feature) => {
          return idAp !== feature.properties.id_ap;
        });
        this.storeService.sites["features"] = filterFeature;

        this.storeService.sites = Object.assign({}, this.storeService.sites);
        this._commonService.translateToaster("success", "Releve.DeleteSuccessfully");
      },
      (error) => {
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
      if (row.id_ap == this.storeService.sites.features[i].properties.id_ap) {
        this.currentAp = this.storeService.sites.features[i];
      }
      i++;
    }

    this.table.rowDetail.toggleExpandRow(row);
  }

  onDetailToggle(event) {
    console.log("Detail Toggled", event);
  }
}
