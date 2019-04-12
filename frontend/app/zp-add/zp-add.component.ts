import { Component, OnInit, Input, AfterViewInit, ViewChild, EventEmitter } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { NgbDateParserFormatter } from "@ng-bootstrap/ng-bootstrap";
import { CommonService } from "@geonature_common/service/common.service";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { FormService } from '@geonature_common/form/form.service';
import { FormGroup, FormBuilder, Validators, FormControl } from "@angular/forms";
import { DataFormService } from '@geonature_common/form/data-form.service';
import { DataService } from '../services/data.service';
import { Router, ActivatedRoute } from '@angular/router';
import { NgbModal } from "@ng-bootstrap/ng-bootstrap";
import { StoreService } from '../services/store.service';
import { ModuleConfig } from "../module.config";
import { GeojsonComponent } from '@geonature_common/map/geojson/geojson.component';

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
  public idZp;
  public nomTaxon;
  public date;
  public tabObserver = [];

  @ViewChild('geojson')
  geojson: GeojsonComponent;

  constructor(
    private _ms: MapService,
    public activatedRoute: ActivatedRoute,
    private _fb: FormBuilder,
    public router: Router,
    public dataFormService: DataFormService,
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

    this.idZp = this.activatedRoute.snapshot.params['indexzp'];


    this.ZpFormGroup = this._fb.group({
      indexzp: null,
      cd_nom: null,
      date_min: null,
      cor_zp_observer: [],
      geom_4326: null

    });

  }

  ngAfterViewInit() {

    // vérifie s'il existe idZp --> c' une modif

    if (this.idZp !== undefined) {
      this.api.getOneZP(this.idZp).subscribe(element => {

        let fullNameObserver;

        element.zp.features[0].properties.cor_zp_observer.forEach(name => {
          if (name === element.zp.features[0].properties.cor_zp_observer[element.zp.features[0].properties.cor_zp_observer.length - 1]) {
            fullNameObserver = name.nom_complet + '. ';
          } else {
            fullNameObserver = name.nom_complet + ', ';
          }
          this.tabObserver.push(fullNameObserver);
        });
        console.log(element.zp.features[0]);

        this.ZpFormGroup.patchValue({
          indexzp: this.idZp,
          cd_nom: element.zp.features[0].properties.taxonomy,
          date_min: this._dateParser.parse(element.zp.features[0].properties.date_min),
          cor_zp_observer: element.zp.features[0].properties.cor_zp_observer,
          geom_4326: element.zp.features[0].geometry
        });
      });
    });
  }

  onCancelAddZp() {
    this.router.navigate([`${ModuleConfig.MODULE_URL}`]);
  }

  onSave() {
    let finalForm = this.formateDataFormZp();
    console.log(finalForm);

    this.api.postZp(finalForm).subscribe(
      (data) => {
        this.toastr.success('Zone de prospection enregistrée', '', {
          positionClass: 'toast-top-center'
        });
        console.log(data);

        this.router.navigate(
          [`${ModuleConfig.MODULE_URL}/zp`, data.id, 'ap_list'
          ]
        );
      });

  }

  formateDataFormZp() {
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

    return finalForm;
  }

  postZp(finalForm) {

    this.api.postZp(finalForm).subscribe(
      () => {
        this.toastr.success('Zone de prospection enregistrée', '', {
          positionClass: 'toast-top-center'
        });
      });
  }

  patchZp(finalForm) {

    this.api.patchZp(finalForm, this.idZp).subscribe(
      () => {
        this.toastr.success('Zone de prospection modifiée', '', {
          positionClass: 'toast-top-center'
        });
      });
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

