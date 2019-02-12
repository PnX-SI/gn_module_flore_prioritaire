import { Injectable, Inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { AppConfig } from '@geonature_config/app.config';

@Injectable()
export class DataService {
  constructor(private _http: HttpClient) {}

  getZProspects(params?: any) {
    let myParams = new HttpParams();

    for (let key in params) {
      myParams = myParams.set(key, params[key]);
    }

    const test = this._http.get<any>(`${AppConfig.API_ENDPOINT}/flore_prioritaire/z_prospects`, {
      params: myParams
    });
    return test;
  }

  getVisits(params: any) {
    let myParams = new HttpParams();
  
    for (let key in params) {
      myParams = myParams.set(key, params[key]);
      }  
      return this._http.get<any>(`${AppConfig.API_ENDPOINT}/flore_prioritaire/apresences`, {
        params: myParams
      });
  } 

  getSites(params) {
      return this._http.get<any>(
        `${AppConfig.API_ENDPOINT}/flore_prioritaire/sites`,
        {
          params: params
        }
      );
  }

  getOrganisme() {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/flore_prioritaire/organismes`
    );
  }

  getCommune(id_module: number, params: any) {
    let myParams = new HttpParams();

    for (let key in params) {
      myParams = myParams.set(key, params[key]);
    }

    return this._http.get<any>(
      `${
        AppConfig.API_ENDPOINT
      }/flore_prioritaire/communes/${id_module}`,
      { params: myParams }
    );
  }

  postVisit(data: any) {
    console.log(data);

    return this._http.post<any>(`${AppConfig.API_ENDPOINT}/flore_prioritaire/form`, data);
  }
}


