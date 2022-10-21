import { Routes } from '@angular/router';

import { ZpMapListComponent } from './zp-map-list/zp-map-list.component';
import { ZpAddComponent } from './zp-add/zp-add.component';
import { ApAddComponent } from './zp-container/ap-add/ap-add.component';
import { ZpDetailsComponent } from './zp-container/zp-details/zp-details.component';
import { ZpContainerComponent } from './zp-container/zp-container.component';

export const routes: Routes = [
  {
    path: '',
    component: ZpMapListComponent,
  },
  {
    path: 'zps/add',
    component: ZpAddComponent,
  },
  {
    path: 'zps/:idZp/edit',
    component: ZpAddComponent,
  },
  {
    path: 'zps/:idZp',
    component: ZpContainerComponent,
    children: [
      {
        path: 'details',
        component: ZpDetailsComponent,
      },
      {
        path: 'aps/add',
        component: ApAddComponent,
      },
      {
        path: 'aps/:idAp/edit',
        component: ApAddComponent,
      },
      {
        path: '',
        redirectTo: 'details',
        pathMatch: 'full',
      },
    ],
  },
];
