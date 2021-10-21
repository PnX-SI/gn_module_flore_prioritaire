import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClientXsrfModule } from '@angular/common/http';
import { Routes, RouterModule } from '@angular/router';
import { HttpClient } from '@angular/common/http';

import { GN2CommonModule } from '@geonature_common/GN2Common.module';

import { DataService } from './services/data.service';
import { StoreService } from './services/store.service';
import { FormService } from './services/form.service';

import { ZpMapListComponent } from './zp-map-list/zp-map-list.component';
import { ZpAddComponent } from './zp-add/zp-add.component';
import { ApAddComponent } from './zp-container/ap-add/ap-add.component';
import { ZpDetailsComponent } from './zp-container/zp-details/zp-details.component';
import { ZpContainerComponent } from "./zp-container/zp-container.component";

// my module routing
const routes: Routes = [
  { path: '', component: ZpMapListComponent },
  { path: 'post_zp', component: ZpAddComponent },
  { path: 'post_zp/:indexzp', component: ZpAddComponent },
  {
    path: 'zp/:idZP', component: ZpContainerComponent,
    children: [
      { path: 'details', component: ZpDetailsComponent },
      { path: 'post_ap', component: ApAddComponent },
      { path: 'post_ap/:indexap', component: ApAddComponent },
      { path: '', redirectTo: 'details', pathMatch: 'full' }
    ]
  },

];

@NgModule({
  imports: [CommonModule, GN2CommonModule, RouterModule.forChild(routes)],
  declarations: [
    ZpMapListComponent, 
    ZpAddComponent, 
    ZpDetailsComponent, 
    ApAddComponent, 
    ZpContainerComponent
  ],

  providers: [DataService, StoreService, FormService]

})
export class GeonatureModule { }
