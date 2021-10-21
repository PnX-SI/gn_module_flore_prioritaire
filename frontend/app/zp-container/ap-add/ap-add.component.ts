import { Component, OnInit, Input, AfterViewInit, OnDestroy } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { Subscription } from "rxjs/Subscription";
import { ToastrService } from 'ngx-toastr';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { DataFormService } from "@geonature_common/form/data-form.service";
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { GeojsonComponent } from "@geonature_common/map/geojson/geojson.component";
import { FormGroup } from "@angular/forms";
import { DataService } from '../../services/data.service';
import { StoreService } from "../../services/store.service";
import { FormService } from "../../services/form.service";
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal } from "@ng-bootstrap/ng-bootstrap";
import { ModuleConfig } from "../../module.config";
import { CommonService } from "@geonature_common/service/common.service";


@Component({
  selector: 'pnx-ap-add',
  templateUrl: 'ap-add.component.html',
  styleUrls: ['ap-add.component.scss'],
  providers: []
})
export class ApAddComponent implements OnInit, AfterViewInit, OnDestroy {

  private ApFormGroup: FormGroup;
  public site;
  public geojson: any;
  public isEstim = true;
  public isSampling = true;
  public isVisibleCountForm = false;
  public isVisibleMethodForm = false;
  public zp;
  public idAp;
  public areasIntersected = new Array();
  public tabPertur = [];
  private geojsonSubscription$: Subscription;
  public myGeoJSON: GeoJSON;
  public filteredData = [];
  constructor(
    public formService: FormService,
    public mapService: MapService,
    public router: Router,
    private toastr: ToastrService,
    private _dfs: DataFormService,
    public ngbModal: NgbModal,
    public api: DataService,
    public storeService: StoreService,
    public activatedRoute: ActivatedRoute,
    private _commonService: CommonService,
    public mapListService : MapListService,

  ) { }

  ngOnInit() {
    this.storeService.toggleLeafletDraw(false);
    this.idAp = this.activatedRoute.snapshot.params['indexap'];
    this.ApFormGroup = this.formService.initFormAp();
    
    // subscription to the geojson observable
    this.geojsonSubscription$ = this.mapService.gettingGeojson$.subscribe(geojson => {
      this.ApFormGroup.patchValue({ geom_4326: geojson.geometry });
      this.geojson = geojson;

      // get to geo info from API
      this._dfs.getGeoInfo(geojson).subscribe(res => {
        this.ApFormGroup.patchValue({
          altitude_min: res.altitude.altitude_min,
          altitude_max: res.altitude.altitude_max
        });
      });
      this._dfs.getFormatedGeoIntersection(geojson).subscribe(res => {
        this.areasIntersected = res;
      });
    });
    // autocomplete total_max
    this.ApFormGroup.controls.total_min.valueChanges
      //.debounceTime(500)
      .distinctUntilChanged()
      .subscribe(value => {
        if (
          this.ApFormGroup.controls.total_max ===
          null ||
          this.ApFormGroup.controls.total_max.pristine
        ) {
          this.ApFormGroup.patchValue({
            total_max: value
          });
        }
      })
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();

    // vérifie s'il existe idAp --> c' une modif

    if (this.idAp !== undefined) {
      this.api.getOneAP(this.idAp).subscribe(element => {

        let typePer;
        let tabApPerturb = element.properties.cor_ap_perturbation;

        if (tabApPerturb !== undefined) {
          tabApPerturb.forEach(per => {
            if (per === tabApPerturb[tabApPerturb.length - 1]) {
              typePer = per.label_fr + '. ';
            } else {
              typePer = per.label_fr + ', ';
            }
            this.tabPertur.push(typePer);
          });
        }
        console.log(element);
        
        this.ApFormGroup.patchValue({
          indexap: this.idAp,
          indexzp: element.properties.indexzp,
          altitude_min: element.properties.altitude_min,
          altitude_max: element.properties.altitude_max,
          comment: element.properties.comment,
          frequency: element.properties.frequency,
          total_min: element.properties.total_min,
          total_max: element.properties.total_max,
          id_nomenclatures_phenology: element.properties.pheno.id_nomenclature,
          id_nomenclatures_habitat: element.properties.habitat ? element.properties.habitat.id_nomenclature : null,
          id_nomenclatures_pente: element.properties.pente.id_nomenclature,
          id_nomenclatures_counting: element.properties.counting.id_nomenclature,
          geom_4326: element.geometry,
          cor_ap_perturbation: element.properties.cor_ap_perturbation === null ? [] : element.properties.cor_ap_perturbation
        });
      });
    }
  }

  formDisabled() {
      this._commonService.translateToaster(
        "warning",
        "Releve.FillGeometryFirst"
      );
  }

  onCancelAp(indexzp) {
    this.router.navigate(
      [
        `${ModuleConfig.MODULE_URL}/zp`,
        indexzp, 'details'
      ]
    );
  }
  onPostAp() {
    const apForm = JSON.parse(JSON.stringify(this.ApFormGroup.value));
    // set indexZP
    apForm["indexzp"] = this.storeService.zp.id;
    this.api.postAp(apForm).subscribe(
      data => {
        this.toastr.success('Aire de présence enregistrée', '', {
          positionClass: 'toast-top-center'
        });
        this.router.navigate([
            `${ModuleConfig.MODULE_URL}/zp`, this.storeService.zp.id, 'details'
        ]);
      // push ap maplist data       
      this.mapListService.tableData.push(data.properties);
      this.storeService.sites.features.push(data);
      const savedGeojsn = Object.assign({}, this.storeService.sites);
      this.storeService.sites = null;
      this.storeService.sites = savedGeojsn;
      });

  }

  deleteControlValue() {
    console.log('Suppression')
  }

  ngOnDestroy() {
    this.geojsonSubscription$.unsubscribe();
  }
}