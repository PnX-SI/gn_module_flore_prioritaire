import { Component, OnInit, AfterViewInit, OnDestroy } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';

import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { distinctUntilChanged } from 'rxjs/operators';
import { Subscription } from 'rxjs/Subscription';

import { DataFormService } from '@geonature_common/form/data-form.service';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { CommonService } from '@geonature_common/service/common.service';

import { ModuleConfig } from '../../module.config';
import { DataService } from '../../services/data.service';
import { FormService } from '../../services/form.service';
import { StoreService } from '../../services/store.service';

@Component({
  selector: 'pnx-ap-add',
  templateUrl: 'ap-add.component.html',
  styleUrls: ['ap-add.component.scss'],
  providers: [MapListService]
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
    this.extractUrlParams();
    this.ApFormGroup = this.formService.initFormAp();
    this.storeService.setLeafletDraw();
    this.initializeOnLeafletDrawAddGeom();
    this.initializeTotalMaxAutocomplete();
  }

  private extractUrlParams() {
    this.idAp = this.activatedRoute.snapshot.params['idAp'];
    this.activatedRoute.parent.params.subscribe(params => {
      this.storeService.idSite = params['idZP'];
    });
  }

  private initializeOnLeafletDrawAddGeom() {
    // Subscription to the geojson observable. Used when new geom add on map by Leaflet Draw
    this.geojsonSubscription$ = this.mapService.gettingGeojson$
      .pipe(distinctUntilChanged())
      .subscribe(geojson => {
        // check if ap is in zp
        this.api
          .areaContain(this.storeService.zp.geometry, geojson.geometry)
          .subscribe(contain => {
            if (contain) {
              // Update geom control in form
              this.ApFormGroup.patchValue({
                geom_4326: geojson.geometry
              });
              this.ApFormGroup.markAsDirty();

              // Get area size
              this.dataFormService.getAreaSize(geojson).subscribe(areaSize => {
                this.ApFormGroup.patchValue({
                  area: Math.round(areaSize)
                });
              });

              // Get to geo info from API
              this.dataFormService.getGeoInfo(geojson).subscribe(res => {
                if (res.altitude.altitude_min && res.altitude.altitude_max) {
                  this.ApFormGroup.patchValue({
                    altitude_min: res.altitude.altitude_min,
                    altitude_max: res.altitude.altitude_max
                  });
                } else {
                  this.commonService.regularToaster(
                    'warning',
                    "Les altitudes minimum et maximum de la nouvelle aire de présence " +
                    "n'ont pu être mis à jour automatiquement. Vérifier votre DEM !"
                  );
                }
              });

              // Get intersected geometry
              this.dataFormService
                .getFormatedGeoIntersection(geojson)
                .subscribe(res => {
                  this.areasIntersected = res;
                });
            } else {
              this.geojson = null;
              this.ApFormGroup.patchValue({
                geom_4326: null
              });
              this.commonService.regularToaster(
                'warning',
                "L'aire de présence n'est pas inclue dans la zone de prospection."
              );
            }
          });
      });
  }

  private initializeTotalMaxAutocomplete() {
    this.ApFormGroup.controls.total_min.valueChanges
      .distinctUntilChanged()
      .subscribe(value => {
        if (
          this.ApFormGroup.controls.total_max === null ||
          this.ApFormGroup.controls.total_max.pristine
        ) {
          this.ApFormGroup.patchValue({
            total_max: value
          });
        }
      });
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();

    // Update mode
    if (this.idAp !== undefined) {
      this.api.getOneAP(this.idAp).subscribe(
        element => {
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

          const ap = element.properties;
          this.ApFormGroup.patchValue({
            id_ap: this.idAp,
            id_zp: ap.id_zp,
            altitude_min: ap.altitude_min,
            altitude_max: ap.altitude_max,
            comment: ap.comment,
            frequency: ap.frequency,
            total_min: ap.total_min,
            total_max: ap.total_max,
            id_nomenclature_phenology: ap.pheno
              ? ap.pheno.id_nomenclature
              : null,
            id_nomenclature_habitat: ap.habitat
              ? ap.habitat.id_nomenclature
              : null,
            id_nomenclature_incline: ap.incline
              ? ap.incline.id_nomenclature
              : null,
            id_nomenclature_counting: ap.counting
              ? ap.counting.id_nomenclature
              : null,
            geom_4326: element.geometry,
            area: Math.round(ap.area),
            cor_ap_perturbation:
              ap.cor_ap_perturbation === null ? [] : ap.cor_ap_perturbation
          });
          this.geojson = element.geometry;
        },
        error => {
          if (error.status != 404) {
            this.toastrService.error(
              "Une erreur est survenue lors de la récupération des informations de l'AP sur le serveur",
              '',
              {
                positionClass: 'toast-top-right'
              }
            );
            console.log('error: ', error);
          }
        }
      );
    }

    this.api.getOneZP(this.storeService.idSite).subscribe(
      data => {
        this.storeService.zp = data['zp'];
        this.storeService.zpProperties = data['zp']['properties'];
        this.storeService.zpProperties[
          'areas'
        ] = this.storeService.zpProperties['areas'].filter(
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
              positionClass: 'toast-top-right'
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

  onCancelAp(idZp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/zp`, idZp, 'details']);
  }

  onPostAp() {
    if (this.ApFormGroup.valid) {
      const apForm = JSON.parse(JSON.stringify(this.ApFormGroup.value));
      // set indexZP
      apForm['id_zp'] = this.storeService.zp.id;
      this.api.postAp(apForm).subscribe(data => {
        this.toastrService.success('Aire de présence enregistrée', '', {
          positionClass: 'toast-top-center'
        });
        this.router.navigate([
          `${ModuleConfig.MODULE_URL}/zp`,
          this.storeService.zp.id,
          'details'
        ]);
        // push ap maplist data
        if (apForm['id_ap']) {
          // remove from list
          this.mapListService.tableData = this.mapListService.tableData.filter(
            ap => ap.id_ap != apForm['id_ap']
          );
          // remove from map
          this.storeService.sites.features = this.storeService.sites.features.filter(
            ap => ap.id != apForm['id_ap']
          );
        }

        this.mapListService.tableData.push(data.properties);
        this.storeService.sites.features.push(data);
        // TODO: see if the code below is really necessary
        const savedGeojsn = Object.assign({}, this.storeService.sites);
        this.storeService.sites = null;
        this.storeService.sites = savedGeojsn;
      });
    } else {
      console.log('Form invalid !');
    }
  }

  sendGeoInfo(geojson) {
    //this.ApFormGroup.patchValue({ geom_4326: geojson.geometry });
    //this.geojson = geojson.geometry;
    console.log("In sendGeoInfo")
  }

  deleteApGeom() {
    this.ApFormGroup.patchValue({
      geom_4326: null,
      area: null
    });
    this.ApFormGroup.markAsDirty();
    this.geojson = null;
  }

  ngOnDestroy() {
    this.geojsonSubscription$.unsubscribe();
  }
}
