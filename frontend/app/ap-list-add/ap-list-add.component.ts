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
  styleUrls: ["./ap-list-add.component.scss"],
  providers: [MapListService]
})
export class ApListAddComponent implements OnInit, OnChanges {

  public currentSite = {};
  public idAp;
  public dynamicFormGroup: FormGroup;
  public filteredData = [];
  public dataLoaded = false;

  constructor(
    public mapService: MapService,
    public storeService: StoreService,
    public router: Router,
    public _api: DataService,
    private _fb: FormBuilder,
    public activatedRoute: ActivatedRoute,
    public mapListService: MapListService,
    private toastr: ToastrService
  ) { }

  ngOnInit() { }


  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.storeService.idSite = this.activatedRoute.snapshot.params['idZP'];
    this.mapListService.idName = 'indexap';
    this.mapListService.enableMapListConnexion(this.mapService.getMap());
    console.log(this.storeService.idSite);
    //this.paramApp = this.paramApp.append("indexzp", idZP);
    this._api.getOneZP(this.storeService.idSite).subscribe(
      data => {
        this.storeService.zp = data['zp'];
        this.storeService.sites = data['aps'];
        this.mapListService.loadTableData(data['aps']);
        this.filteredData = this.mapListService.tableData;
        this.dataLoaded = true;
        let properties = data['zp'].features.properties;

        this.storeService.organisme = properties.organisme;
        this.storeService.nomCommune = properties.nom_commune;
        this.storeService.observateur = properties.nom_role;
        this.storeService.taxons = data['zp'].features.properties.taxonomy.nom_complet;
        this.storeService.dateMin = properties.date_min;

        //this.geojson.currentGeoJson$.subscribe(currentLayer => {
        //  this.mapService.map.fitBounds(currentLayer.getBounds());
        //});
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



  onEachFeature(feature, layer) {
    // event from the map
    let site = feature.properties;
    this.mapListService.layerDict[feature.id] = layer;
    layer.on({
      click: (e) => {
        // toggle style
        //this.mapListService.toggleStyle(layer);
        // observable
        this.mapListService.mapSelected.next(feature.id);
        // open popup
        const customPopup = '<div class="title">' + site.altitude_max + "</div>";
        const customOptions = {
          className: "custom-popup"
        };
        layer.bindPopup(customPopup, customOptions);
      }
    });
  }
}