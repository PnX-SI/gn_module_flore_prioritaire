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

    const test = this._http.get<any>(`${AppConfig.API_ENDPOINT}/pr_priority_flora/z_prospects`, {
      params: myParams
    });
    return test;
  }

  getVisits(params: any) {
    let myParams = new HttpParams();
  
    for (let key in params) {
      myParams = myParams.set(key, params[key]);
      }  
      return this._http.get<any>(`${AppConfig.API_ENDPOINT}/pr_priority_flora/apresences`, {
        params: myParams
      });
  } 

  getSites(params) {
      return this._http.get<any>(
        `${AppConfig.API_ENDPOINT}/pr_priority_flora/sites`,
        {
          params: params
        }
      );
  }

  getOrganisme() {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/pr_priority_flora/organismes`
    );
  }

  getCommune() {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/pr_priority_flora/communes`
    );
  }

  getTaxon() {
    return this._http.get<any>(
      `${AppConfig.API_ENDPOINT}/pr_priority_flora/taxs`
    );
  }

  postVisit(data: any) {
    console.log(data);

    return this._http.post<any>(`${AppConfig.API_ENDPOINT}/pr_priority_flora/post_zp`, data);
  }
}


