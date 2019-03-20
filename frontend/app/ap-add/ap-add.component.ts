import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { NgbDateParserFormatter } from "@ng-bootstrap/ng-bootstrap";
import { CommonService } from "@geonature_common/service/common.service";
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
  public isEstim = true;
  public isSampling = true;
  public isVisibleCountForm = false;
  public isVisibleMethodForm = false;
  public zp;
  public tabPertur = [];
  public disabledForm = true;
  public myGeoJSON: GeoJSON;
  private ApFormGroup: FormGroup;
  public filteredData = [];
  public paramApp = this.storeService.queryString.append(
    "id_application",
    ModuleConfig.ID_MODULE
  );

  constructor(
    public mapService: MapService,
    private _fb: FormBuilder,
    public router: Router,
    private toastr: ToastrService,
    public ngbModal: NgbModal,
    public api: DataService,
    private _commonService: CommonService,
    private _dateParser: NgbDateParserFormatter,
    public storeService: StoreService,
    public activatedRoute: ActivatedRoute
  ) { }

  ngOnInit() {

    this.ApFormGroup = this._fb.group({
      indexap: null,
      cor_ap_perturbation: null,
      cor_ap_physionomy: null,
      phenology: null,
      countmethod: null,
      frequencymethod: null,
      nb_contacts: null,
      nb_points: null,
      nb_transects: null,
      area_plots: null,
      nb_plots: null,
      pente: null,
      total_sterile: null,
      total_fertile: null,
      nb_sterile_plots: null,
      nb_fertile_plots: null,
      comments: null
    });
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.storeService.getZp(this.storeService.idSite);
  }
  onCancelAp(indexzp) {
    this.router.navigate(
      [
        'pr_priority_flora/zp',
        indexzp, 'ap_list'
      ]
    );
  }
  onPostAp() {
    const finalForm = JSON.parse(JSON.stringify(this.ApFormGroup.value));
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
    this.ApFormGroup.patchValue(
      { 'geom_4326': geojson.geometry }
    )
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
}