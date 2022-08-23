import { CommonModule } from '@angular/common';
import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';

import { GN2CommonModule } from '@geonature_common/GN2Common.module';

import { DataService } from './services/data.service';
import { StoreService } from './services/store.service';
import { ApFormService } from './zp-container/ap-add/ap-form.service';
import { ZpMapListComponent } from './zp-map-list/zp-map-list.component';
import { ZpAddComponent } from './zp-add/zp-add.component';
import { ApAddComponent } from './zp-container/ap-add/ap-add.component';
import { ZpDetailsComponent } from './zp-container/zp-details/zp-details.component';
import { ZpContainerComponent } from './zp-container/zp-container.component';
import { routes } from './gnModule.routes';

@NgModule({
  imports: [CommonModule, GN2CommonModule, RouterModule.forChild(routes)],
  declarations: [
    ZpMapListComponent,
    ZpAddComponent,
    ZpDetailsComponent,
    ApAddComponent,
    ZpContainerComponent
  ],
  providers: [DataService, StoreService, ApFormService]
})
export class GeonatureModule {}
