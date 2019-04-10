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
import { ApAddComponent } from './ap-add/ap-add.component';
import { ApListComponent } from './ap-list/ap-list.component';
import { ApListAddComponent } from './ap-list-add/ap-list-add.component';

// my module routing
const routes: Routes = [
  { path: '', component: ZpMapListComponent },
  { path: 'post_zp', component: ZpAddComponent },
  { path: 'post_zp/:indexzp', component: ZpAddComponent },
  {
    path: 'zp/:idZP', component: ApListAddComponent,
    children: [
      { path: 'ap_list', component: ApListComponent },
      { path: 'post_ap', component: ApAddComponent },
      { path: 'post_ap/:indexap', component: ApAddComponent },
      { path: '', redirectTo: 'ap_list', pathMatch: 'full' }
    ]
  },

];

@NgModule({
  imports: [CommonModule, GN2CommonModule, RouterModule.forChild(routes)],
  declarations: [ZpMapListComponent, ZpAddComponent, ApListComponent, ApAddComponent, ApListAddComponent],

  providers: [DataService, StoreService, FormService]

})
export class GeonatureModule { }
