import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { NgbDateParserFormatter } from "@ng-bootstrap/ng-bootstrap";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { FormService } from '@geonature_common/form/form.service';
import { FormGroup, FormBuilder } from "@angular/forms";
import { DataService } from '../services/data.service';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal } from "@ng-bootstrap/ng-bootstrap";
import { ModuleConfig } from "../module.config";

@Component({
  selector: 'pnx-zp-add',
  templateUrl: 'zp-add.component.html',
  styleUrls: ['zp-add.component.scss'],
  providers: [MapListService]
})
export class ZpAddComponent implements OnInit, AfterViewInit {
  public leafletDrawOptions = leafletDrawOption;
  public myGeoJSON: GeoJSON;
  public dynamicFormGroup: FormGroup;
  
  constructor(
    private _ms: MapService,
    private mapListService: MapListService,
    private _fb: FormBuilder,
    public router: Router,
    private toastr: ToastrService,
    public ngbModal: NgbModal,
    public api: DataService,
    private _dateParser: NgbDateParserFormatter
  ) {}

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

    // parameters for maplist
    // columns to be default displayed
    //this.displayColumns = ModuleConfig.default_zp_columns;
    //this.mapListService.displayColumns = this.displayColumns;
  
    
  }

  onCancelAddZp() {
    this.router.navigate(["pr_priority_flora"]); 
  }

  onPostZp() {
  
  const finalForm = JSON.parse(JSON.stringify(this.dynamicFormGroup.value));
  finalForm.date_min = this._dateParser.format(
    finalForm.date_min
  );
  
  finalForm.date_max = this._dateParser.format(
    finalForm.date_max
  );

  this.api.postVisit(finalForm).subscribe(
    data => {
      this.toastr.success('Zone de prospection enregistrée', '', {
        positionClass: 'toast-top-center'
      });
    } 
  } 
  
 
  ngAfterViewInit() {
    // event from the list
    // this.mapListService.onTableClick(this._ms.getMap());
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