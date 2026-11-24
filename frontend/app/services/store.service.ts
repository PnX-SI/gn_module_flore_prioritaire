import { HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';

import { ConfigService } from '@geonature/services/config.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';

@Injectable()
export class StoreService {
  public sites;
  public zp;
  public zpProperties: any = {};
  public idSite;
  public fpConfig: any = {};
  public leafletDrawOptions = leafletDrawOption;
  public queryString = new HttpParams();
  public urlApLoad: string;
  public urlZpLoad: string;
  private readonly taxonNameStorageKey = 'priority-flora-filters-taxon-name';
  private readonly queryStringStorageKey = 'priority-flora-filters-querystring';

  constructor(public config: ConfigService) {
    this.fpConfig = this.config['PRIORITY_FLORA'];
    this.urlApLoad = `${this.config.API_ENDPOINT}${this.fpConfig.MODULE_URL}/presence-areas/export`;
    this.urlZpLoad = `${this.config.API_ENDPOINT}${this.fpConfig.MODULE_URL}/prospect-zones/export`;
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
      fromString: localStorage.getItem(this.queryStringStorageKey) ?? '',
    });
  }

  saveQueryString() {
    localStorage.setItem(this.queryStringStorageKey, this.queryString.toString());
  }

  clearQueryString() {
    this.queryString = new HttpParams();
  }

  loadTaxonName(): string {
    return localStorage.getItem(this.taxonNameStorageKey) ?? '';
  }

  saveTaxonName(name: string | null): void {
    if (name) {
      localStorage.setItem(this.taxonNameStorageKey, name);
    } else {
      localStorage.removeItem(this.taxonNameStorageKey);
    }
  }
}
