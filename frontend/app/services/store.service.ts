import { HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Layer, Map } from 'leaflet';
import * as L from "leaflet";
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { ModuleConfig } from '../module.config';
import { DataService } from "../services/data.service";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { AppConfig } from '@geonature_config/app.config';

@Injectable()
export class StoreService {
  public currentLayer: Layer;
  public sites;
  public map_zp: Map;
  public zp;
  public zpProperties = {};
  public idSite;
  public dataLoaded = false;
  public observateur = [];
  public organisme;
  public indexZp;
  public dateMin;
  public nomCommune = [];
  public siteDesc;
  public taxons;
  public _map;
  public nb_transects_frequency;
  public altitude_min;
  public altitude_max;
  public fpConfig = ModuleConfig;
  public leafletDrawOptions = leafletDrawOption;
  public presence = 0;
  public queryString = new HttpParams();
  public urlLoad = `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/export_ap`;
  public myStylePresent = {
    color: "#008000",
    fill: true,
    fillOpacity: 0.2,
    weight: 3,
  };

  constructor(
    public _api: DataService,
    public mapListService: MapListService,
    private _modalService: NgbModal
  ) {}

  setLeafletDraw() {
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.marker = true;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.draw.polygone = true;
    this.leafletDrawOptions.edit.remove = true;
    this.leafletDrawOptions.edit.edit = true;
  }

  toggleLeafletDraw(hidden) {
    const drawElements = document.getElementsByClassName("leaflet-draw");
    if (drawElements.length > 0) {
      const e: any = drawElements[0];
      e.hidden = hidden;
    }
  }

  openModal(content) {
    this._modalService.open(content);
  }
}
