import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { CommonService } from "@geonature_common/service/common.service";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { GeojsonComponent } from "@geonature_common/map/geojson/geojson.component";
import { FormGroup } from "@angular/forms";
import { DataService } from '../services/data.service';
import { StoreService } from "../services/store.service";
import { FormService } from "../services/form.service";
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
  private ap = {
    indexap: "",
    indexzp: "",
    altitude_min: "",
    altitude_max: "",
    area: "",
    total_min: "",
    total_max: "",
    frequency: "",
    id_nomenclatures_counting: "",
    id_nomenclatures_habitat: "",
    id_nomenclatures_phenology: "",
    id_nomenclatures_pente: "",
    cor_ap_perturbation: [],
    comment: ""
  };
  public myGeoJSON: GeoJSON;
  private ApFormGroup: FormGroup;
  public filteredData = [];
  public paramApp = this.storeService.queryString.append(
    "id_application",
    ModuleConfig.ID_MODULE
  );

  constructor(
    public formService: FormService,
    public mapService: MapService,
    public router: Router,
    private toastr: ToastrService,
    public ngbModal: NgbModal,
    public api: DataService,
    private _commonService: CommonService,
    public storeService: StoreService,
    public activatedRoute: ActivatedRoute
  ) { }

  ngOnInit() {

    this.ApFormGroup = this.formService.initFormAp();
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
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
    const apForm = JSON.parse(JSON.stringify(this.ApFormGroup.value));

    //perturbation
    /* apForm["cor_ap_perturbation"] = apForm["cor_ap_perturbation"].map(
      pertu => {
        return pertu.id_nomenclatures;
      }
    ); */

    this.api.postAp(apForm).subscribe(
      data => {
        this.toastr.success('Aire de présence enregistrée', '', {
          positionClass: 'toast-top-center'
        });
      });
  }

  deleteControlValue() {
    console.log('Suppression')
  }

  pachForm() {
    this.ApFormGroup.patchValue({
      indexap: this.ap.indexap,
      indexzp: this.ap.indexzp,
      altitude_min: this.ap.altitude_min,
      altitude_max: this.ap.altitude_max,
      area: this.ap.area,
      frequency: this.ap.frequency,
      total_min: this.ap.total_min,
      total_max: this.ap.total_max,
      id_nomenclatures_counting: this.ap.id_nomenclatures_counting,
      id_nomenclatures_habitat: this.ap.id_nomenclatures_habitat,
      id_nomenclatures_phenology: this.ap.id_nomenclatures_phenology,
      id_nomenclatures_pente: this.ap.id_nomenclatures_pente,
      cor_ap_perturbation: this.ap.cor_ap_perturbation,
      comment: this.ap.comment
    });
  }
}