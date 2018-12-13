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
  postVisit(data: any) {
    console.log(data);

    return this._http.post<any>(`${AppConfig.API_ENDPOINT}/flore_prioritaire/form`, data);
  }
}


