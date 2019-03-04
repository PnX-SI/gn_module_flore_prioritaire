import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { NgbDateParserFormatter } from "@ng-bootstrap/ng-bootstrap";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { GeojsonComponent } from "@geonature_common/map/geojson/geojson.component";
import { FormGroup, FormBuilder } from "@angular/forms";
import { DataService } from '../services/data.service';
import { StoreService } from "../services/store.service";
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal } from "@ng-bootstrap/ng-bootstrap";
import { ModuleConfig } from "../module.config";

@Component({
  selector: 'pnx-ap-add',
  templateUrl: 'ap-add.component.html',
  styleUrls: ['ap-add.component.scss'],
  providers: []
})
export class ApAddComponent implements OnInit, AfterViewInit {
  public site;
  public zp;
  public tabPertur = [];
  public leafletDrawOptions = leafletDrawOption;
  public myGeoJSON: GeoJSON;
  private dynamicFormGroup: FormGroup;
  public filteredData = [];
  public paramApp = this.storeService.queryString.append(
    "id_application",
    ModuleConfig.ID_MODULE
  );

  // @ViewChild("geojson")
  // geojson: GeojsonComponent;

  constructor(
    public mapService: MapService,
    private _fb: FormBuilder,
    public router: Router,
    private toastr: ToastrService,
    public ngbModal: NgbModal,
    public api: DataService,
    private _dateParser: NgbDateParserFormatter,
    public storeService: StoreService,
    public activatedRoute: ActivatedRoute
  ) { }

  ngOnInit() {
  
     this.leafletDrawOptions.draw.rectangle = true;
     this.leafletDrawOptions.draw.circle = true;
     this.leafletDrawOptions.draw.polyline = false;
     this.leafletDrawOptions.edit.remove = true;

     this.dynamicFormGroup = this._fb.group({
       date_min: null,
       date_max: null,
       geom_4326: null
     });  
  }

   ngAfterViewInit() {
     this.mapService.map.doubleClickZoom.disable();
     this.storeService.getZp(this.storeService.idSite);
   }

   onPostAp() {
   const finalForm = JSON.parse(JSON.stringify(this.dynamicFormGroup.value));
   finalForm.date_min = this._dateParser.format(
     finalForm.date_min
   );

   finalForm.date_max = this._dateParser.format(
     finalForm.date_max
   );

   this.api.postAp(finalForm).subscribe(
     data => {
       this.toastr.success('Aire de présence enregistrée', '', {
         positionClass: 'toast-top-center'
       });
     } 
   } 

   getGeojson(geojson) {
     this.dynamicFormGroup.patchValue(
       {'geom_4326': geojson.geometry}
     )
   } 

   deleteControlValue() {
     console.log('Suppression')
   }
}