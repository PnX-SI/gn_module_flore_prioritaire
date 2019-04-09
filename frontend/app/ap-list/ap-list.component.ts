import { Component, OnInit, OnDestroy, ViewChild } from "@angular/core";
import { Router, ActivatedRoute } from "@angular/router";
import { Location } from "@angular/common";
import { ToastrService } from "ngx-toastr";
import * as L from "leaflet";

import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";

import { DataService } from "../services/data.service";
import { StoreService } from "../services/store.service";
import { ModuleConfig } from "../module.config";

@Component({
  selector: "pnx-ap-list",
  templateUrl: "ap-list.component.html",
  styleUrls: ["./ap-list.component.scss"],
})
export class ApListComponent implements OnInit, OnDestroy {

  public currentSite = {};
  public show = true;
  public idAp;
  private _map;
  public currentAp;
  public expanded: any = {};
  @ViewChild('table') table: any;
  );

  constructor(
    public mapService: MapService,
    public storeService: StoreService,
    private _location: Location,
    public router: Router,
    public _api: DataService,
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
        'pr_priority_flora/zp',
        idZP, 'post_ap'
      ]
    );
    this.storeService.showLeafletDraw();
  }

  onEditAp(idZP) {
    this.router.navigate(
      [
        'pr_priority_flora/zp',
        idZP, 'post_ap'
      ]
    );
    this.storeService.showLeafletDraw();
  }

  backToZp() {
    this.router.navigate(["pr_priority_flora"]);
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