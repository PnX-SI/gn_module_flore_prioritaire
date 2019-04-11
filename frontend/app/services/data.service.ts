import { Injectable, Inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { AppConfig } from '@geonature_config/app.config';
import { ModuleConfig } from '../module.config';

@Injectable()
export class DataService {
  constructor(private _http: HttpClient) { }

  getZProspects(params?: any) {
    /*  let myParams = new HttpParams();
 
     for (let key in params) {
       myParams = myParams.set(key, params[key]);
     }
 
     const test = */
    return this._http.get<any>(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/z_prospects`, {
      params: params
    });
  }

  getApresences(params: any) {
    let myParams = new HttpParams();

    for (let key in params) {
      myParams = myParams.set(key, params[key]);
    }
    return this._http.get<any>(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/apresences`, {
      params: myParams
    });
  }

  getOneZP(idZp) {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/zp/${idZp}`
    );
  }

  getOneAP(idAp) {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/ap/${idAp}`
    );
  }

  getOrganisme() {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/organismes`
    );
  }

  getCommune() {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/communes`
    );
  }

  postZp(data: any) {
    return this._http.post<any>(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/post_zp`, data);
  }

  patchZp(data: any, idZp) {
    return this._http.post<any>(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/post_zp/${idZp}`, data);
  }

  postAp(data: any) {
    return this._http.post<any>(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/post_ap`, data);
  }

  patchAp(data: any, idAp) {
    return this._http.post<any>(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/post_ap/${idAp}`, data);
  }

  deleteZp(idZp) {
    return this._http.delete(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/zp/${idZp}`);
  }

  deleteAp(idAp) {
    return this._http.delete(`${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/ap/${idAp}`);
  }
}


