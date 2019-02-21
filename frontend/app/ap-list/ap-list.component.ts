import { Component, OnInit, ViewChild, OnDestroy } from "@angular/core";
import { ActivatedRoute } from "@angular/router";
import { Location } from "@angular/common";
import { ToastrService } from "ngx-toastr";

import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";
import { GeojsonComponent } from "@geonature_common/map/geojson/geojson.component";

import { DataService } from "../services/data.service";
import { StoreService } from "../services/store.service";
import { ModuleConfig } from "../module.config";

@Component({
  selector: "pnx-ap-list",
  templateUrl: "ap-list.component.html",
  styleUrls: ["./ap-list.component.scss"]
})
export class ApListComponent implements OnInit, OnDestroy {
  public site;
  public currentSite = {};
  public show = true;
  public idSite;
  public dataLoaded = false;
  public idAp;
  public observateur;
  public organisme;
  public dateMin;
  public nomCommune;
  public siteDesc;
  public taxons;
  public nb_transects_frequency;
  public altitude_min;
  public altitude_max;
  public filteredData = [];
  public paramApp = this.storeService.queryString.append(
    "id_application",
    ModuleConfig.ID_MODULE
  );

  @ViewChild("geojson")
  geojson: GeojsonComponent;

  constructor(
    public mapService: MapService,
    public mapListService: MapListService,
    public storeService: StoreService,
    private _location: Location,
    public _api: DataService,
    public activatedRoute: ActivatedRoute,
    private toastr: ToastrService
  ) {}

  ngOnInit() {
    this.idSite = this.activatedRoute.snapshot.params['idSite'];
    this.storeService.queryString = this.storeService.queryString.set('indexzp', this.idSite);
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.getSites();
  }

  onEachFeature(feature, layer) {
    layer.setStyle(this.storeService.getLayerStyle(this.site));
  }

  getVisits() {
    this._api.getVisits({ indexzp: this.idSite }).subscribe(
      data => {
        this.site = data;
        this.mapListService.loadTableData(data);
        this.filteredData = this.mapListService.tableData;
        this.dataLoaded = true;
      },
      
      error => {
        if (error.status != 404) {
          this.toastr.error(
            "Une erreur est survenue lors de la modification de votre relevé",
            "",
            {
              positionClass: "toast-top-right"
            }
          );
        }
      }
    );
  }

  getSites() {
    this.paramApp = this.paramApp.append("indexzp", this.idSite);
    this._api.getSites(this.paramApp).subscribe(
      data => {
        this.site = data;
        let properties = data.features[0].properties;
        this.idSite = properties.indexzp;
        this.organisme = properties.organisme;
        this.nomCommune = properties.nom_commune;
        this.observateur = properties.nom_role;
        this.taxons = properties.taxon.nom_complet;
        this.dateMin = properties.date_min;

        this.geojson.currentGeoJson$.subscribe(currentLayer => {
          this.mapService.map.fitBounds(currentLayer.getBounds());
        });

        this.getVisits();
      },
      error => {
        this.toastr.error(
          "Une erreur est survenue lors de la récupération des informations sur le serveur",
          "",
          {
            positionClass: "toast-top-right"
          }
        );
        console.log("error: ", error);
      }
    );
  }

  backToSites() {
    this._location.back();
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