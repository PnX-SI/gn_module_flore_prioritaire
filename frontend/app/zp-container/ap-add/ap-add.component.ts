import { Component, OnInit, AfterViewInit, OnDestroy, Inject, ViewChild } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';

import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { distinctUntilChanged } from 'rxjs/operators';
import { Subscription } from 'rxjs/Subscription';

import { CommonService } from '@geonature_common/service/common.service';
import { DataFormService } from '@geonature_common/form/data-form.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { NomenclatureComponent } from '@geonature_common/form/nomenclature/nomenclature.component';

import { DataService } from '../../services/data.service';
import { ApFormService } from './ap-form.service';
import { StoreService } from '../../services/store.service';
import { ModuleConfigInterface, MODULE_CONFIG_TOKEN } from '../../gnModule.config';
import { COUNTING_TYPES, FREQUENCY_METHOD } from '../../shared/nomenclatures';

@Component({
  selector: 'gn-pf-ap-add',
  templateUrl: 'ap-add.component.html',
  styleUrls: ['ap-add.component.scss'],
  providers: [MapListService],
})
export class ApAddComponent implements OnInit, AfterViewInit, OnDestroy {
  leafletDrawOptions = leafletDrawOption;
  private apForm: FormGroup;
  geojson: any;
  idAp;
  areasIntersected = new Array();
  private geojsonSubscription$: Subscription;
  myGeoJSON: GeoJSON;
  filteredData = [];
  firstFileLayerMessage: boolean = true;
  mapGpxColor: string;
  COUNTING_TYPES = COUNTING_TYPES;
  @ViewChild('countingMethod') countingMethod: NomenclatureComponent;
  FREQUENCY_METHOD = FREQUENCY_METHOD;

  constructor(
    @Inject(MODULE_CONFIG_TOKEN) private config: ModuleConfigInterface,
    public formService: ApFormService,
    public mapService: MapService,
    public router: Router,
    private toastrService: ToastrService,
    private dataFormService: DataFormService,
    public ngbModal: NgbModal,
    public api: DataService,
    public storeService: StoreService,
    public activatedRoute: ActivatedRoute,
    private commonService: CommonService,
    public mapListService: MapListService
  ) {}

  ngOnInit() {
    this.mapGpxColor = this.config.map_gpx_color;
    this.extractUrlParams();
    this.apForm = this.formService.initFormAp();
    this.storeService.setLeafletDraw();
    this.initializeLeafletDrawOptions();
    this.initializeOnLeafletDrawAddGeom();
    this.initializeTotalMaxAutocomplete();
  }

  private extractUrlParams() {
    this.idAp = this.activatedRoute.snapshot.params['idAp'];
    this.activatedRoute.parent.params.subscribe(params => {
      this.storeService.idSite = params['idZp'];
    });
  }

  private initializeLeafletDrawOptions() {
    this.leafletDrawOptions.draw.rectangle = false;
    this.leafletDrawOptions.draw.marker = true;
    this.leafletDrawOptions.draw.circle = false;
    this.leafletDrawOptions.draw.circlemarker = false;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.edit.remove = true;
  }

  private initializeOnLeafletDrawAddGeom() {
    // Subscription to the geojson observable. Used when new geom add on map by Leaflet Draw
    this.geojsonSubscription$ = this.mapService.gettingGeojson$
      .pipe(distinctUntilChanged())
      .subscribe(geojson => {
        // check if ap is in zp
        this.api.containArea(this.storeService.zp.geometry, geojson.geometry).subscribe(contain => {
          if (contain) {
            // Update geom control in form
            this.apForm.patchValue({
              geom_4326: geojson.geometry,
            });

            // Get area size
            if (geojson.geometry.type == 'Point') {
              this.apForm.controls['area'].enable();
              if (this.apForm.controls.area.value == null) {
                this.apForm.patchValue({ area: 1 });
                this.commonService.regularToaster(
                  'info',
                  "Veuillez saisir la surface en m² de l'aire de présence."
                );
              }
            } else {
              this.apForm.controls['area'].disable();
              this.dataFormService.getAreaSize(geojson).subscribe(areaSize => {
                this.apForm.patchValue({
                  area: Math.round(areaSize),
                });
              });
            }

            // Get to geo info from API
            this.dataFormService.getGeoInfo(geojson).subscribe(res => {
              if (res.altitude.altitude_min && res.altitude.altitude_max) {
                this.apForm.patchValue({
                  altitude_min: res.altitude.altitude_min,
                  altitude_max: res.altitude.altitude_max,
                });
              } else {
                this.commonService.regularToaster(
                  'warning',
                  'Les altitudes minimum et maximum de la nouvelle aire de présence ' +
                    "n'ont pu être mis à jour automatiquement. Vérifier votre DEM !"
                );
              }
            });

            // Get intersected geometry
            this.dataFormService.getFormatedGeoIntersection(geojson).subscribe(res => {
              this.areasIntersected = res;
            });
          } else {
            this.geojson = null;
            this.apForm.patchValue({
              geom_4326: null,
            });
            this.commonService.regularToaster(
              'warning',
              "L'aire de présence n'est pas inclue dans la zone de prospection."
            );
          }
          // WARNING: markAsDirty() must be call after controls update.
          this.apForm.markAsDirty();
        });
      });
  }

  private initializeTotalMaxAutocomplete() {
    this.apForm.controls.total_min.valueChanges.distinctUntilChanged().subscribe(value => {
      if (this.apForm.controls.total_max === null || this.apForm.controls.total_max.pristine) {
        this.apForm.patchValue({
          total_max: value,
        });
      }
    });
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    if (this.isUpdateMode()) {
      this.loadApData();
    }
    this.loadZpData();
  }

  private loadApData() {
    this.api.getOnePresenceArea(this.idAp).subscribe(
      element => {
        const ap = element.properties;

        // Manage area field activation
        if (element.geometry.type == 'Point') {
          this.apForm.controls['area'].enable();
        } else {
          this.apForm.controls['area'].disable();
        }

        // Manage form fields values initialiazation
        this.apForm.patchValue({
          id_ap: this.idAp,
          id_zp: ap.id_zp,
          geom_4326: element.geometry,
          altitude_min: ap.altitude_min,
          altitude_max: ap.altitude_max,
          area: Math.round(ap.area),
          id_nomenclature_incline: ap.incline ? ap.incline.id_nomenclature : null,
          physiognomies: ap.physiognomies === null ? [] : ap.physiognomies,
          id_nomenclature_habitat: ap.habitat ? ap.habitat.id_nomenclature : null,
          favorable_status_percent: ap.favorable_status_percent,
          id_nomenclature_threat_level: ap.threat_level ? ap.threat_level.id_nomenclature : null,
          perturbations: ap.perturbations === null ? [] : ap.perturbations,
          id_nomenclature_phenology: ap.pheno ? ap.pheno.id_nomenclature : null,
          id_nomenclature_frequency_method: ap.frequency_method
            ? ap.frequency_method.id_nomenclature
            : null,
          frequency: ap.frequency,
          id_nomenclature_counting: ap.counting ? ap.counting.id_nomenclature : null,
          total:
            ap.counting && ap.counting.cd_nomenclature == COUNTING_TYPES.census ? ap.total_min : 0,
          total_min: ap.total_min,
          total_max: ap.total_max,
          comment: ap.comment,
        });
        this.geojson = element.geometry;
      },
      error => {
        if (error.status != 404) {
          this.toastrService.error(
            "Une erreur est survenue lors de la récupération des informations de l'AP sur le serveur",
            '',
            {
              positionClass: 'toast-top-right',
            }
          );
          console.log('error: ', error);
        }
      }
    );
  }

  private loadZpData() {
    this.api.getOneProspectZone(this.storeService.idSite).subscribe(
      data => {
        this.storeService.zp = data['zp'];
        this.storeService.zpProperties = data['zp']['properties'];
        this.storeService.zpProperties['areas'] = this.storeService.zpProperties['areas'].filter(
          area => area.area_type.type_code == 'COM'
        );

        //this.storeService.sites = data['aps'];
      },
      error => {
        if (error.status != 404) {
          this.toastrService.error(
            'Une erreur est survenue lors de la récupération des informations sur le serveur',
            '',
            {
              positionClass: 'toast-top-right',
            }
          );
          console.log('error: ', error);
        }
      }
    );
  }

  onEachZp(feature, layer) {
    layer.setStyle({ color: '#F4D03F', fillOpacity: 0, weight: 4 });
  }

  onCancel(idZp) {
    this.router.navigate([`${this.config.MODULE_URL}/zps`, idZp, 'details']);
  }

  onSubmit() {
    if (this.apForm.valid) {
      // WARNING: use getRawValue() to get values from disabled controls !
      const apForm = JSON.parse(JSON.stringify(this.apForm.getRawValue()));

      // Set indexZP
      apForm['id_zp'] = this.storeService.zp.id;

      // Store total input form value in total_min and total_max DB fields.
      if (apForm['total'] != null) {
        apForm['total_min'] = apForm['total'];
        apForm['total_max'] = apForm['total'];
      }
      delete apForm['total'];

      // Send presence area data
      if (this.isUpdateMode()) {
        this.api.updatePresenceArea(apForm, this.idAp).subscribe(
          data => {
            this.onPresenceAreaSavedSuccess(data);
          },
          error => {
            this.onPresenceAreaSavedError(error);
          }
        );
      } else {
        this.api.addPresenceArea(apForm).subscribe(
          data => {
            this.onPresenceAreaSavedSuccess(data);
          },
          error => {
            this.onPresenceAreaSavedError(error);
          }
        );
      }
    }
  }

  private onPresenceAreaSavedSuccess(apData) {
    this.toastrService.success('Aire de présence enregistrée', '', {
      positionClass: 'toast-top-center',
    });

    this.router.navigate([`${this.config.MODULE_URL}/zps`, this.storeService.zp.id, 'details']);

    // TODO: try to simplify the code below
    // Push ap maplist data
    if (this.isUpdateMode()) {
      // remove from list
      this.mapListService.tableData = this.mapListService.tableData.filter(
        ap => ap.id_ap != apData.id
      );
      // remove from map
      this.storeService.sites.features = this.storeService.sites.features.filter(
        ap => ap.id != apData.id
      );
    }

    this.mapListService.tableData.push(apData.properties);
    this.storeService.sites.features.push(apData);
    // TODO: see if the code below is really necessary
    const savedGeojsn = Object.assign({}, this.storeService.sites);
    this.storeService.sites = null;
    this.storeService.sites = savedGeojsn;
  }

  private onPresenceAreaSavedError(error) {
    const title = this.isUpdateMode() ? 'Problème de mise à jour' : "Problème d'ajout";
    const genericMsg = this.isUpdateMode()
      ? `Une erreur ${error.status} est survenue lors de la mise à jour des informations sur le serveur.`
      : `Une erreur ${error.status} est survenue lors de l'ajout des informations sur le serveur.`;
    const msg =
      error.error && error.error.description
        ? `${error.status} ${error.statusText} - ${error.error.description}`
        : genericMsg;
    const options = {
      positionClass: 'toast-top-right',
    };
    this.toastrService.error(msg, title, options);
    console.log(`Error ${error.status} ${error.statusText}:`, error);
  }

  private isUpdateMode() {
    return this.idAp !== undefined;
  }

  onCountingChange(nomenclatureId) {
    let countingCode = this.countingMethod.getCdNomenclature();
    if (countingCode == COUNTING_TYPES.census) {
      this.apForm.patchValue({
        total_min: null,
        total_max: null,
      });
    } else if (countingCode == COUNTING_TYPES.sampling) {
      this.apForm.patchValue({
        total: null,
      });
    } else {
      this.apForm.patchValue({
        total_min: null,
        total_max: null,
        total: null,
      });
    }
  }

  deleteApGeom() {
    this.apForm.controls['area'].disable();

    this.apForm.patchValue({
      geom_4326: null,
      area: null,
    });
    this.apForm.markAsDirty();
    this.geojson = null;
  }

  displayFileLayerInfoMessage() {
    if (this.firstFileLayerMessage) {
      this.commonService.translateToaster('info', 'Map.FileLayerInfoSynthese');
    }
    this.firstFileLayerMessage = false;
  }

  ngOnDestroy() {
    this.geojsonSubscription$.unsubscribe();
  }
}
