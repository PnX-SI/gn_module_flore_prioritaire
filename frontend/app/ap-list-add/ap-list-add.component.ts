import { NgModule, Component, OnInit, OnDestroy, OnChanges } from "@angular/core";
import { RouterModule, Router, Routes, ActivatedRoute } from "@angular/router";
import { ToastrService } from "ngx-toastr";
import * as L from "leaflet";
import { CommonService } from "@geonature_common/service/common.service";
import { FormBuilder, FormGroup, Validators } from "@angular/forms";
import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";
import { DataService } from "../services/data.service";
import { FormService } from "../services/form.service";
import { StoreService } from "../services/store.service";
import { ModuleConfig } from "../module.config";


@Component({
  selector: "pnx-ap-list-add",
  templateUrl: "ap-list-add.component.html",
  styleUrls: ["./ap-list-add.component.scss"],
  providers: [MapListService]
})
export class ApListAddComponent implements OnInit, OnChanges {

  public currentSite = {};
  public idAp;
  public ApFormGroup: FormGroup;
  public filteredData = [];
  public dataLoaded = false;
  public disabledForm = true;

  constructor(
    public mapService: MapService,
    public formService: FormService,
    public storeService: StoreService,
    public router: Router,
    public _api: DataService,
    private _fb: FormBuilder,
    private _commonService: CommonService,
    public activatedRoute: ActivatedRoute,
    public mapListService: MapListService,
    private toastr: ToastrService
  ) { }

  ngOnInit() {

    this.ApFormGroup = this.formService.initFormAp();
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.storeService.idSite = this.activatedRoute.snapshot.params['idZP'];
    this.mapListService.idName = 'indexap';
    this.mapListService.enableMapListConnexion(this.mapService.getMap());
    this._api.getOneZP(this.storeService.idSite).subscribe(
      data => {
        this.storeService.zp = data['zp'];
        this.storeService.sites = data['aps'];
        this.mapListService.loadTableData(data['aps']);
        this.filteredData = this.mapListService.tableData;
        this.dataLoaded = true;
        let properties = data['zp'].features[0].properties;
        this.storeService.indexZp = properties.indexzp;

        let fullNameObs;
        this.storeService.observateur = [];
        data['zp'].features[0].properties.cor_zp_observer.forEach(obs => {
          if (obs == data['zp'].features[0].properties.cor_zp_observer[data['zp'].features[0].properties.cor_zp_observer.length - 1]) {
            fullNameObs = obs.nom_complet + '. ';
          } else {
            fullNameObs = obs.nom_complet + ', ';
          }
          this.storeService.observateur.push(fullNameObs);
        });
        this.storeService.taxons = data['zp'].features[0].properties.taxonomy.nom_complet;
        this.storeService.dateMin = properties.date_min;

        // zoom on zp
        // HACK devrait être fait par pnx-geojson
        this.mapService.map.fitBounds(
          new L.FeatureGroup().addLayer(L.geoJSON(data['zp'])).getBounds()
        )
      },
      error => {
        if (error.status != 404) {
          this.toastr.error(
            "Une erreur est survenue lors de la récupération des informations sur le serveur",
            "",
            {
              positionClass: "toast-top-right"
            }
          );
          console.log("error: ", error);
        }
      });

  }
  sendGeoInfo(geojson) {
    // declenche next sur l'observable _geojsonCoord
    this.mapService.setGeojsonCoord(geojson);
    this.disabledForm = false;
    this.ApFormGroup.patchValue({ geom_4326: geojson.geometry })
  }
  onEachFeature(feature, layer) {
    // event from the map
    let site = feature.properties;
    this.mapListService.layerDict[feature.id] = layer;
    layer.on({
      click: (e) => {
        // toggle style
        this.mapListService.toggleStyle(layer);
        // observable
        this.mapListService.mapSelected.next(feature.id);
        // open popup
        const customPopup = '<div class="title">Altitude : ' + site.altitude_max + 'm<br />Surface : ' + site.area + ' m\u00b2</div>';
        const customOptions = {
          className: "custom-popup"
        };
        layer.bindPopup(customPopup, customOptions);
      }
    });
  }

  onEachZp(feature, layer) {
    layer.setStyle({ 'color': '#F4D03F', 'fillOpacity': 0, 'weight': 4 })
  }
  formDisabled() {
    if (this.disabledForm) {
      this._commonService.translateToaster(
        "warning",
        "Releve.FillGeometryFirst"
      );
    }
  }
}