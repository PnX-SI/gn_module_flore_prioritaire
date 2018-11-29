import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { GeoJSON } from 'leaflet';
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
  selector: 'pnx-zp-map-list',
  templateUrl: 'zp-map-list.component.html',
  styleUrls: ['zp-map-list.component.scss'],
  providers: [MapListService]
})
export class ZpMapListComponent implements OnInit, AfterViewInit {
  public leafletDrawOptions = leafletDrawOption;
  public myGeoJSON: GeoJSON;
  public dynamicFormGroup: FormGroup;
  @ViewChild(NgbModal)
  public modalCol: NgbModal;
  constructor(
    private _ms: MapService,
    private mapListService: MapListService,
    private _fb: FormBuilder,
    public router: Router,
    public ngbModal: NgbModal,
    public api: DataService
  ) {}

  ngOnInit() {
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.circle = true;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.edit.remove = true;

    this.dynamicFormGroup = this._fb.group({
      cd_nom: null,
      date_up: null,
      date_low: null
    }); 

    this.api.getZProspects().subscribe(data => {
      this.myGeoJSON = data;
      console.log(this.myGeoJSON)

    });

    // parameters for maplist
    // columns to be default displayed
    //this.displayColumns = ModuleConfig.default_zp_columns;
    //this.mapListService.displayColumns = this.displayColumns;
  
    
  }

  

  openModalCol(event, modal) {
    this.ngbModal.open(modal);
  }

  ngAfterViewInit() {
    // event from the list
    // this.mapListService.onTableClick(this._ms.getMap());
  }

  getGeojson(geojson) {
    alert(JSON.stringify(geojson))
    
  }

  deleteControlValue() {
    console.log('Suppression')
  }
}