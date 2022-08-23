import { HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';

import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { AppConfig } from '@geonature_config/app.config';

import { ModuleConfig } from '../module.config';


@Injectable()
export class StoreService {
  public sites;
  public zp;
  public zpProperties = {};
  public idSite;
  public fpConfig = ModuleConfig;
  public leafletDrawOptions = leafletDrawOption;
  public queryString = new HttpParams();
  public urlLoad = `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/export_ap`;

  constructor() {}

  setLeafletDraw() {
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.marker = true;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.draw.polygone = true;
    this.leafletDrawOptions.edit.remove = true;
    this.leafletDrawOptions.edit.edit = true;
  }
}
