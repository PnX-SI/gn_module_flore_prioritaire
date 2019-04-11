import { HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Layer, Map } from 'leaflet';
import * as L from "leaflet";
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { ModuleConfig } from '../module.config';
import { DataService } from "../services/data.service";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';

@Injectable()
export class StoreService {
  public currentLayer: Layer;
  public sites;
  public map_zp: Map;
  public zp;
  public idSite;
  public dataLoaded = false;
  public observateur;
  public organisme;
  public indexZp;
  public dateMin;
  public nomCommune;
  public siteDesc;
  public taxons;
  public _map;
  public nb_transects_frequency;
  public altitude_min;
  public altitude_max;
  public fpConfig = ModuleConfig;
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
    public mapListService: MapListService,
    private _modalService: NgbModal
  ) { }

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

  openModal(content) {
    this._modalService.open(content);
  }
}






