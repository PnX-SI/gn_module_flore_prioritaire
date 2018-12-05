import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { HttpClientXsrfModule } from '@angular/common/http';
import { Routes, RouterModule } from '@angular/router';
import { HttpClient } from '@angular/common/http';

import { GN2CommonModule } from '@geonature_common/GN2Common.module';

import { DataService } from './services/data.service';
import { StoreService } from './services/store.service';
import { ZpMapListComponent } from './zp-map-list/zp-map-list.component';
import { ZpAddComponent } from './zp-add/zp-add.component';
import { FormService } from './services/form.service';


// my module routing
const routes: Routes = [
  { path: "", component: ZpMapListComponent },
  { path: "form", component: ZpAddComponent },

];

@NgModule({
  imports: [CommonModule, GN2CommonModule, RouterModule.forChild(routes)],
  declarations: [ZpMapListComponent, ZpAddComponent],
  
  providers: [DataService] 
  
})
export class GeonatureModule {}
