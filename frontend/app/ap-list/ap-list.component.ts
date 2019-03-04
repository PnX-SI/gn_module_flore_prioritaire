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
  selector: "pnx-ap-list",
  templateUrl: "ap-list.component.html",
  styleUrls: ["./ap-list.component.scss"]
})
export class ApListComponent implements OnInit, OnDestroy {
  
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

//   // onEachFeature(feature, layer) {
//   //   let site = feature.properties;
//   //   this.mapListService.layerDict[feature.id] = layer;

//   //   const customPopup = '<div class="title">' + site.date_max + "</div>";
//   //   const customOptions = {
//   //     className: "custom-popup"
//   //   };
//   //   layer.bindPopup(customPopup, customOptions);
//   //   layer.on({
//   //     click: e => {
//   //       //this.toggleStyle(layer);
//   //       //this.onMapClick(feature.id);
//   //     }
//   //   });
//   // }

//   // ngAfterViewInit() {
//   //   this.mapService.map.doubleClickZoom.disable();
//   //   const idZP = this.activatedRoute.snapshot.params['idZP'];
//   //   this.storeService.getZp(idZP);
//   // }

onAddAp(idZP) {
    this.storeService.getZp();
    this.router.navigate(
      [
        'pr_priority_flora/zp',
        idZP, 'post_ap'
      ]
    );  
  }
  
//   // onRowSelect(row) {
//   //   let id = row.selected[0]['idSite'];
//   //   let site = row.selected[0];
//   //   const selectedLayer = this.mapListService.layerDict[id];
//   //   //this.storeService.toggleStyle(selectedLayer);
//   //   this.zoomOnSelectedLayer(this._map, selectedLayer, 16);
//   // }

//   // zoomOnSelectedLayer(map, layer, zoom) {
//   //   let latlng;

//   //   if (layer instanceof L.Polygon || layer instanceof L.Polyline) {
//   //     latlng = (layer as any).getCenter();
//   //     map.setView(latlng, zoom);
//   //   } else {
//   //     latlng = layer._latlng;
//   //   }
//   // }
backToSites() {
  this._location.back();
}

//   // ngOnDestroy() {
//   //   this.storeService.queryString = this.storeService.queryString.delete(
//   //     "id_base_site"
//   //   );
//   //   console.log(
//   //     "queryString list-visit: ",
//   //     this.storeService.queryString.toString()
//   //   );
//   // } 
}