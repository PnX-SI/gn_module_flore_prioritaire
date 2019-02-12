import { Component, OnInit, Input, AfterViewInit, ViewChild, OnDestroy } from '@angular/core';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { FormService } from '@geonature_common/form/form.service';
import { DataService } from '../services/data.service';
import { FormGroup, FormBuilder, FormControl } from "@angular/forms";
import { StoreService } from '../services/store.service';
import { Router, ActivatedRoute } from '@angular/router';
import { ModuleConfig } from "../module.config";

@Component({
  selector: 'pnx-zp-map-list',
  templateUrl: 'zp-map-list.component.html',
  styleUrls: ['zp-map-list.component.scss'],
  providers: [MapListService]
})
export class ZpMapListComponent implements OnInit, AfterViewInit {
  public leafletDrawOptions = leafletDrawOption;
  public sites;
  public myGeoJSON;
  public filteredData = [];
  public tabOrganism = [];
  public tabCom = [];
  public dataLoaded = false;
  public oldFilterDate;
  public filterForm: FormGroup;
  public displayColumns: Array<any>;
  
  constructor(
    public mapService: MapService,
    private mapListService: MapListService,
    public router: Router,
    public storeService: StoreService,
    public api: DataService
  ) {}

  ngOnInit() {
    this.onChargeList();
    this.displayColumns = ModuleConfig.default_zp_columns;
    this.mapListService.displayColumns = this.displayColumns;
    
    this.mapListService.idName = 'indexzp';

    this.api.getZProspects().subscribe(data => {
      console.log(data)
      this.myGeoJSON = data;
      this.mapListService.loadTableData(data);
      this.filteredData = this.mapListService.tableData;

      this.dataLoaded = true;
      console.log(this.myGeoJSON)
    });

    this.filterForm = this._fb.group({
      filterYear: null,
      filterOrga: null,
      filterCom: null,
      filterHab: null
    });

    this.filterForm.controls.filterYear.valueChanges
      .filter(input => {
        return input != null && input.toString().length === 4;
      })
      .subscribe(year => {
        this.onSearchDate(year);
      });

    this.filterForm.controls.filterYear.valueChanges
      .filter(input => {
        return input === null;
      })
      .subscribe(year => {
        this.onDeleteParams("year", year);
        this.onDeleteFiltre.emit();
      });

    this.filterForm.controls.filterOrga.valueChanges
      .filter(select => {
        return select !== null;
      })
      .subscribe(org => {
        this.onSearchOrganisme(org);
      });

    this.filterForm.controls.filterOrga.valueChanges
      .filter(input => {
        return input === null;
      })
      .subscribe(org => {
        this.onDeleteParams("organisme", org);
        this.onDeleteFiltre.emit();
      });

    this.filterForm.controls.filterCom.valueChanges
      .filter(select => {
        return select !== null;
      })
      .subscribe(com => {
        this.onSearchCom(com);
      });

    this.filterForm.controls.filterCom.valueChanges
      .filter(input => {
        return input === null;
      })
      .subscribe(com => {
        this.onDeleteParams("commune", com);
        this.onDeleteFiltre.emit();
      });

    this.filterForm.controls.filterHab.valueChanges
      .filter(select => {
        return select !== null;
      })
      .subscribe(hab => {
        this.onSearchHab(hab);
      });

    this.filterForm.controls.filterHab.valueChanges
      .filter(input => {
        return input === null;
      })
      .subscribe(hab => {
        this.onDeleteParams("cd_hab", hab);
        this.onDeleteFiltre.emit();
      });
  }
  
  onChargeList(param?) {
    this.api.getZProspects().subscribe(data => {
      console.log(data)
      this.myGeoJSON = data;
      this.mapListService.loadTableData(data);
      this.filteredData = this.mapListService.tableData;

      this.dataLoaded = true;
      },
      error => {
        if (error.status == 404) {
          this.page.totalElements = 0;
          this.page.size = 0;
          this.filteredData = [];
        } else {
          this.toastr.error(
            "Une erreur est survenue lors de la récupération des données",
            "",
            {
              positionClass: "toast-top-right"
            }
          );
          console.log("error getsites: ", error);
        }
        this.dataLoaded = true;
      }
    );
  }
  onAddZp() {
    this.router.navigate(["flore_prioritaire/form"]); 
  }
  
  onInfo(indexzp) {
    this.router.navigate([
      `${ModuleConfig.api_url}/APlist`,
      indexzp
    ]);
  }

  ngAfterViewInit() {
    // event from the list
    this.mapListService.enableMapListConnexion(this.mapService.getMap());

    this._map = this.mapService.getMap();
    this.addCustomControl();
  
    this.api.getOrganisme().subscribe(elem => {
      elem.forEach(orga => {
          this.tabOrganism.push(orga.nom_organisme);
          this.tabOrganism.sort((a, b) => {
            return a.localeCompare(b);
          });
      });
    });
  
    this.api.getCommune(ModuleConfig.id_application, {
        id_area_type: this.storeService.shtConfig.id_type_commune
      })
      .subscribe(info => {
          info.forEach(com => {
          this.tabCom.push(com.nom_commune);
          this.tabCom.sort((a, b) => {
            return a.localeCompare(b);
          });
        });
      });
  }

  getGeojson(geojson) {
    alert(JSON.stringify(geojson)) 
  }

  deleteControlValue() {
    console.log('Suppression')
  }

  onEachFeature(feature, layer) {
    this.mapListService.layerDict[feature.id] = layer;
    layer.on({
      click: e => {
        this.mapListService.toggleStyle(layer);
        this.mapListService.mapSelected.next(feature.id);
      }
    });
  }

  // Filters
  onDelete() {
    console.log("ondelete");
    this.onChargeList();
  }

  onSetParams(param: string, value) {
    //  ajouter le queryString pour télécharger les données
    this.storeService.queryString = this.storeService.queryString.set(
      param,
      value
    );
  }

  onDeleteParams(param: string, value) {
    // effacer le queryString
    console.log("ondelete params", param + " value: " + value);
    this.storeService.queryString = this.storeService.queryString.delete(param);
    this.onChargeList(this.storeService.queryString.toString());
  }

  onSearchDate(event) {
    // fonction de recherche de date
    this.onSetParams("year", event);
    this.oldFilterDate = event;
    this.onChargeList(this.storeService.queryString.toString());
  }

  onSearchOrganisme(event) {
    // fonction de recherche d'organisme
    this.onSetParams("organisme", event);
    this.onChargeList(this.storeService.queryString.toString());
  }

  onSearchCom(event) {
    // fonction de recherche de commune
    this.onSetParams("commune", event);
    this.onChargeList(this.storeService.queryString.toString());
  }

  onSearchHab(event) {
    this.onSetParams("cd_hab", event);
    this.onChargeList(this.storeService.queryString.toString());
  }

  ngOnDestroy() {
    let filterkey = this.storeService.queryString.keys();
    filterkey.forEach(key => {
      this.storeService.queryString= this.storeService.queryString.delete(key);
    });
  }
}