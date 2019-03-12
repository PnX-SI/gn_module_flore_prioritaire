import { HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { ToastrService } from "ngx-toastr";
import { Layer } from 'leaflet';
import * as L from "leaflet";
import { ModuleConfig } from '../module.config';
import { DataService } from "../services/data.service";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';

@Injectable()
export class StoreService {
  public currentLayer: Layer;
  public sites;
  public zp;
  public idSite;
  public dataLoaded = false;
  public observateur;
  public organisme;
  public dateMin;
  public nomCommune;
  public siteDesc;
  public taxons;
  public _map;
  public nb_transects_frequency;
  public altitude_min;
  public altitude_max;
  public shtConfig = ModuleConfig;
  public leafletDrawOptions = leafletDrawOption;
  public showDraw = false;
  public paramApp = new HttpParams().append(
    "id_application",
    ModuleConfig.ID_MODULE
    );
  public myStylePresent = {
    color: '#008000',
    fill: true,
    fillOpacity: 0.2,
    weight: 3
  };
  
  constructor(
    public _api: DataService,
    private toastr: ToastrService,
    public mapListService: MapListService
    
    ) {}

  public presence = 0;

  public queryString = new HttpParams();
  
  showLeafletDraw() {
    this.showDraw = true;
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.circle = true;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.draw.polygone = true;
    this.leafletDrawOptions.edit.remove = true;
    this.leafletDrawOptions.edit.edit = true;
    }

  getAps() {
    this._api.getApresences({ indexzp: this.idSite }).subscribe(
      data => {
        this.sites = data;
        this.mapListService.loadTableData(data);
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

  onRowSelect(row) {
    let id = row.selected[0]["indexzp"];
    let site = row.selected[0];
    const selectedLayer = this.mapListService.layerDict[id];
    this.zoomOnSelectedLayer(this._map, selectedLayer, 16);
  }

  zoomOnSelectedLayer(map, layer, zoom) {
    let latlng;
    if (layer instanceof L.Polygon || layer instanceof L.Polyline) {
      latlng = (layer as any).getCenter();
      map.setView(latlng, zoom);
    } else {
      latlng = layer._latlng;
    }
  }
  
  getZp(idZP) { 
    this.paramApp = this.paramApp.append("indexzp", idZP);
    this._api.getZprosps(this.paramApp).subscribe(
      data => {
        this.zp = data;
        let properties = data.features[0].properties;
        console.log(data.features[0].properties);
        this.idSite = properties.indexzp;
        this.organisme = properties.organisme;
        this.nomCommune = properties.nom_commune;
        this.observateur = properties.nom_role;
        this.taxons = properties.taxon.nom_complet;
        this.dateMin = properties.date_min;

        //this.geojson.currentGeoJson$.subscribe(currentLayer => {
        //  this.mapService.map.fitBounds(currentLayer.getBounds());
        //});

        this.getAps();
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
      );
    }   
  }
  
  




