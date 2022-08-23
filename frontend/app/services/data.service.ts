import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';

import { AppConfig } from '@geonature_config/app.config';

import { ModuleConfig } from '../module.config';

@Injectable()
export class DataService {
  constructor(private api: HttpClient) {}

  getProspectZones(params?: any) {
    return this.api.get<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/z_prospects`,
      {
        params: params
      }
    );
  }

  getPresenceAreas(params: any) {
    let urlParams = new HttpParams();
    for (let key in params) {
      urlParams = urlParams.set(key, params[key]);
    }
    return this.api.get<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/apresences`,
      {
        params: urlParams
      }
    );
  }

  getOneProspectZone(idZp) {
    return this.api.get<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/zp/${idZp}`
    );
  }

  getOnePresenceArea(idAp) {
    return this.api.get<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/ap/${idAp}`
    );
  }

  getOrganisms() {
    return this.api.get<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/organismes`
    );
  }

  getMunicipalities() {
    return this.api.get<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/communes`
    );
  }

  addProspectZone(data: any) {
    return this.api.post<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/post_zp`,
      data
    );
  }

  updateProspectZone(data: any, idZp) {
    return this.api.post<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/post_zp/${idZp}`,
      data
    );
  }

  addPresenceArea(data: any) {
    return this.api.post<any>(
      `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/post_ap`,
      data
    );
  }

  updatePresenceArea(data: any, idAp) {
    return this.api.post<any>(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/post_ap/${idAp}`,
      data
    );
  }

  deleteProspectZone(idZp) {
    return this.api.delete(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/zp/${idZp}`
    );
  }

  deletePresenceArea(idAp) {
    return this.api.delete(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/ap/${idAp}`
    );
  }

  containArea(geomA, geomB) {
    return this.api.post(
      `${AppConfig.API_ENDPOINT}${ModuleConfig.MODULE_URL}/area_contain`,
      { geom_a: geomA, geom_b: geomB }
    );
  }
}
