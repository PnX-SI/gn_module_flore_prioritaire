import { InjectionToken } from '@angular/core';

export const MODULE_CONFIG_TOKEN = new InjectionToken<ModuleConfigInterface>('PriorityFloraConfig');

export interface ModuleConfigInterface {
  FRONTEND_PATH: string;
  MODULE_CODE: string;
  MODULE_URL: string;
  datatable_ap_columns: { name: string; prop: string }[];
  datatable_ap_messages: { emptyMessage: string; totalMessage: string };
  datatable_zp_columns: { name: string; prop: string; width: number }[];
  datatable_zp_messages: { emptyMessage: string; totalMessage: string };
  export_available_format: ['csv', 'geojson'];
  observers_list_code: string;
  taxons_list_code: string;
  zoom: number;
  zoom_center: number[];
  map_gpx_color: string;
}
