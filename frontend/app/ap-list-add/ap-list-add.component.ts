import { NgModule, Component, OnInit, OnDestroy, OnChanges } from "@angular/core";
import { RouterModule, Router, Routes, ActivatedRoute } from "@angular/router";
import { ToastrService } from "ngx-toastr";
import * as L from "leaflet";
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";
import { DataService } from "../services/data.service";
import { StoreService } from "../services/store.service";
import { ModuleConfig } from "../module.config";


@Component({
  selector: "pnx-ap-list-add",
  templateUrl: "ap-list-add.component.html",
  styleUrls: ["./ap-list-add.component.scss"]
})
export class ApListAddComponent implements OnInit, OnDestroy, OnChanges {
  
  public currentSite = {};
  public idAp;
  public dynamicFormGroup: FormGroup;
  );

  constructor(
    public mapService: MapService,
    public storeService: StoreService,
    public router: Router,
    public _api: DataService,
    private _fb: FormBuilder,
    public activatedRoute: ActivatedRoute,
    public mapListService: MapListService,
    private toastr: ToastrService
  ) {}

  ngOnInit() { 
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.storeService.queryString = this.storeService.queryString.set('indexzp', this.storeService.idSite);
    this.storeService.idSite = this.activatedRoute.snapshot.params['idZP'];
    this.storeService.getZp(this.storeService.idSite); 
    this.mapListService.idName = 'indexap';
    this.mapListService.enableMapListConnexion(this.mapService.getMap());
  } 

  onEachFeature(feature, layer) {
      // event from the map
      this.mapListService.layerDict[feature.id] = layer;
      layer.on({
        click : (e) => {
          // toggle style
          //this.mapListService.toggleStyle(layer);
          // observable
          this.mapListService.mapSelected.next(feature.id);
          // open popup
          layer.bindPopup(feature.properties.leaflet_popup).openPopup();
        }
    });
  }

  ngOnDestroy() {
    this.storeService.queryString = this.storeService.queryString.delete(
      "id_base_site"
    );
    console.log(
      "queryString list-visit: ",
      this.storeService.queryString.toString()
    );
  } 
}