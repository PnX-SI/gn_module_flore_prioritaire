import { HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';

import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { ConfigService } from '@geonature/services/config.service';

@Injectable()
export class StoreService {
  public sites;
  public zp;
  public zpProperties: any = {};
  public idSite;
  public fpConfig: any = {};
  public leafletDrawOptions = leafletDrawOption;
  public queryString = new HttpParams();
  public urlLoad: string;

  constructor(public config: ConfigService) {
    this.fpConfig = this.config['PRIORITY_FLORA'];

    this.urlLoad = `${this.config.API_ENDPOINT}/${this.fpConfig.MODULE_URL}/presence-areas/export`;
  }

  setLeafletDraw() {
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.marker = true;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.draw.polygone = true;
    this.leafletDrawOptions.edit.remove = true;
    this.leafletDrawOptions.edit.edit = {};
  }

  loadQueryString() {
    this.queryString = new HttpParams({
      fromString: localStorage.getItem('priority-flora-filters-querystring'),
    });
  }

  saveQueryString() {
    localStorage.setItem('priority-flora-filters-querystring', this.queryString.toString());
  }

  clearQueryString() {
    let filterkey = this.queryString.keys();
    filterkey.forEach((key) => {
      this.queryString = this.queryString.delete(key);
    });
  }
}
