import { Component, OnInit, OnDestroy } from "@angular/core";
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
  selector: "pnx-ap-detail",
  templateUrl: "ap-detail.component.html",
  styleUrls: ["./ap-detail.component.scss"],
})
export class ApDetailComponent implements OnInit, OnDestroy {
  
  public currentSite = {};
  public show = true;
  public idAp;
  private _map;
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
  ) {}

  ngOnInit() {
  this.storeService.idSite = this.activatedRoute.snapshot.params['idSite'];
  this.storeService.queryString = this.storeService.queryString.set('indexzp', this.storeService.idSite);
  }

onAddAp(idZP) {
    
    this.storeService.getZp(idZP);
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
}