import { NgModule, Component, OnInit, OnDestroy } from "@angular/core";
import { RouterModule, Router, Routes, ActivatedRoute } from "@angular/router";
import { Location } from "@angular/common";
import { ToastrService } from "ngx-toastr";
import * as L from "leaflet";
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";
import { ApAddComponent } from '../ap-add/ap-add.component';
import { ApListComponent } from '../ap-list/ap-list.component';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { DataService } from "../services/data.service";
import { StoreService } from "../services/store.service";
import { ModuleConfig } from "../module.config";

@Component({
  selector: "pnx-ap-list-add",
  templateUrl: "ap-list-add.component.html",
  styleUrls: ["./ap-list-add.component.scss"]
})
export class ApListAddComponent implements OnInit, OnDestroy {
  
  public currentSite = {};
  public show = true;
  public idAp;
  private _map;
  public leafletDrawOptions = leafletDrawOption;
  public dynamicFormGroup: FormGroup;
  );

  constructor(
    public mapService: MapService,
    public storeService: StoreService,
    private _location: Location,
    public router: Router,
    public _api: DataService,
    private _fb: FormBuilder,
    public activatedRoute: ActivatedRoute,
    public mapListService: MapListService,
    private toastr: ToastrService
  ) {}

  ngOnInit() {

    this.dynamicFormGroup = this._fb.group({
      cd_nom: null,
      date_min: null,
      date_max: null,
      cor_zp_observer: [new Array(), Validators.required],
      geom_4326: null
    });
  }
  onEachFeature(feature, layer) {
    let site = feature.properties;
    this.mapListService.layerDict[feature.id] = layer;

    const customPopup = '<div class="title">' + site.date_max + "</div>";
    const customOptions = {
      className: "custom-popup"
    };
    layer.bindPopup(customPopup, customOptions);
    layer.on({
      click: e => {
        //this.toggleStyle(layer);
        //this.onMapClick(feature.id);
      }
    });
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.storeService.queryString = this.storeService.queryString.set('indexzp', this.storeService.idSite);
    this.storeService.idSite = this.activatedRoute.snapshot.params['idZP'];
    this.storeService.getZp(this.storeService.idSite);
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