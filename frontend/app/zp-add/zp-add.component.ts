import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { NgbDateParserFormatter } from "@ng-bootstrap/ng-bootstrap";
import { CommonService } from "@geonature_common/service/common.service";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { FormService } from '@geonature_common/form/form.service';
import { FormGroup, FormBuilder, Validators, FormControl } from "@angular/forms";
import { DataService } from '../services/data.service';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal } from "@ng-bootstrap/ng-bootstrap";
import { StoreService } from '../services/store.service';

@Component({
  selector: 'pnx-zp-add',
  templateUrl: 'zp-add.component.html',
  styleUrls: ['zp-add.component.scss'],
  providers: [MapListService, MapService]
})
export class ZpAddComponent implements OnInit, AfterViewInit {
  public leafletDrawOptions = leafletDrawOption;
  public myGeoJSON: GeoJSON;
  public ZpFormGroup: FormGroup;
  public taxonForm = new FormControl();
  public disabledForm = true;

  constructor(
    private _ms: MapService,
    private mapListService: MapListService,
    private _fb: FormBuilder,
    public router: Router,
    private _commonService: CommonService,
    private toastr: ToastrService,
    public ngbModal: NgbModal,
    public api: DataService,
    public storeService: StoreService,
    private _dateParser: NgbDateParserFormatter
  ) { }

  ngOnInit() {
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.circle = true;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.edit.remove = true;

    this.ZpFormGroup = this._fb.group({
      cd_nom: null,
      date_min: null,
      cor_zp_observer: [],
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

    const finalForm = JSON.parse(JSON.stringify(this.ZpFormGroup.value));

    finalForm.date_min = this._dateParser.format(
      finalForm.date_min
    );

    //observers
    finalForm["cor_zp_observer"] = finalForm["cor_zp_observer"].map(
      obs => {
        return obs.id_role;
      }
    );

    //taxon
    finalForm.cd_nom = finalForm.cd_nom.cd_nom;


    this.api.postZp(finalForm).subscribe(
      data => {
        this.toastr.success('Zone de prospection enregistrée', '', {
          positionClass: 'toast-top-center'
        });
      });
  }


  ngAfterViewInit() {
    // event from the list
    // this.mapListService.onTableClick(this._ms.getMap());
  }

  sendGeoInfo(geojson) {
    // renvoie le
    // this._ms.setGeojsonCoord(geojson);
    console.log(geojson.geometry);
    this.disabledForm = false;
    this.ZpFormGroup.patchValue({ geom_4326: geojson.geometry })
  }

  deleteControlValue() {
    console.log('Suppression')
  }

  formDisabled() {
    if (this.disabledForm) {
      this._commonService.translateToaster(
        "warning",
        "Releve.FillGeometryFirst"
      );
    }
  }