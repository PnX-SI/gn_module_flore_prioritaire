import { Injectable, Inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';

import { ConfigService } from '@geonature/services/config.service';

@Injectable()
export class DataService {
  private moduleBaseUrl: string;

  constructor(private api: HttpClient, private cfg: ConfigService) {
    this.moduleBaseUrl = `${this.cfg.API_ENDPOINT}${this.cfg.PRIORITY_FLORA.MODULE_URL}`;
  }

  getProspectZones(params?: any) {
    return this.api.get<any>(`${this.moduleBaseUrl}/prospect-zones`, {
      params: params,
    });
  }

  // INFO: NOT USED YET !
  getPresenceAreas(params: any) {
    let urlParams = new HttpParams();
    for (let key in params) {
      urlParams = urlParams.set(key, params[key]);
    }
    return this.api.get<any>(`${this.moduleBaseUrl}/presence-areas`, {
      params: urlParams,
    });
  }

  getOneProspectZone(idZp) {
    return this.api.get<any>(
      `${this.cfg.API_ENDPOINT}${this.cfg.PRIORITY_FLORA.MODULE_URL}/prospect-zones/${idZp}`
    );
  }

  getOnePresenceArea(idAp) {
    return this.api.get<any>(`${this.moduleBaseUrl}/presence-areas/${idAp}`);
  }

  getOrganisms() {
    return this.api.get<any>(`${this.moduleBaseUrl}/organisms`);
  }

  getMunicipalities() {
    return this.api.get<any>(`${this.moduleBaseUrl}/municipalities`);
  }

  addProspectZone(data: any) {
    return this.api.post<any>(`${this.moduleBaseUrl}/prospect-zones`, data);
  }

  updateProspectZone(data: any, idZp) {
    return this.api.put<any>(`${this.moduleBaseUrl}/prospect-zones/${idZp}`, data);
  }

  addPresenceArea(data: any) {
    return this.api.post<any>(`${this.moduleBaseUrl}/presence-areas`, data);
  }

  updatePresenceArea(data: any, idAp) {
    return this.api.put<any>(`${this.moduleBaseUrl}/presence-areas/${idAp}`, data);
  }

  deleteProspectZone(idZp) {
    return this.api.delete(`${this.moduleBaseUrl}/prospect-zones/${idZp}`);
  }

  deletePresenceArea(idAp) {
    return this.api.delete(`${this.moduleBaseUrl}/presence-areas/${idAp}`);
  }

  containArea(geomA, geomB) {
    return this.api.post(`${this.moduleBaseUrl}/area-contain`, {
      geom_a: geomA,
      geom_b: geomB,
    });
  }
}
