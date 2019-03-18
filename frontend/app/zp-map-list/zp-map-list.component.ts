import { Component, OnInit, Input, AfterViewInit, EventEmitter, Output } from '@angular/core';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import * as L from "leaflet";
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
  public tabTaxon = [];
  public dataLoaded = false;
  public oldFilterDate;
  public filterForm: FormGroup;
  public displayColumns: Array<any>;
  private _map;
  public center;
  public zoom;

  @Output()
  onDeleteFiltre = new EventEmitter<any>();

  constructor(
    public mapService: MapService,
    private mapListService: MapListService,
    public router: Router,
    public storeService: StoreService,
    public api: DataService,
    private _fb: FormBuilder
  ) { }

  ngOnInit() {
    this.displayColumns = ModuleConfig.default_zp_columns;
    this.mapListService.idName = 'indexzp';
    this.api.getZProspects().subscribe(data => {
      this.myGeoJSON = data;
      this.mapListService.loadTableData(data);
      this.filteredData = this.mapListService.tableData;
      this.dataLoaded = true;
    }
    );
    this.center = this.storeService.shtConfig.zoom_center;
    this.zoom = this.storeService.shtConfig.zoom;

    this.filterForm = this._fb.group({
      filterYear: null,
      filterOrga: null,
      filterCom: null,
      filterTaxon: null
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

    this.filterForm.controls.filterTaxon.valueChanges
      .filter(select => {
        return select !== null;
      })
      .subscribe(tax => {
        this.onSearchTaxon(tax);
      });

    this.filterForm.controls.filterTaxon.valueChanges
      .filter(input => {
        return input === null;
      })
      .subscribe(tax => {
        this.onDeleteParams("taxon", tax);
        this.onDeleteFiltre.emit();
      });
  }

  test($event) {
    console.log($event.item);
  }

  onChargeList(param?) {
    this.api.getZProspects(param).subscribe(data => {
      this.myGeoJSON = data;
      this.mapListService.loadTableData(data);
      this.filteredData = this.mapListService.tableData;
      console.log(this.filteredData);
      this.dataLoaded = true;
    }
    );
  }
  onAddZp() {
    this.router.navigate(["pr_priority_flora/post_zp"]);
  }

  onInfo(indexzp) {
    this.router.navigate(
      [
        'pr_priority_flora/zp',
        indexzp, 'ap_list'
      ]
    );

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

    this.api.getCommune().subscribe(info => {
      info.forEach(com => {
        this.tabCom.push(com.nom_commune);
        this.tabCom.sort((a, b) => {
          return a.localeCompare(b);
        });
      });
    });

    this.api.getTaxon().subscribe(info => {
      info.forEach(tax => {
        this.tabTaxon.push(tax.nom_complet);
        this.tabTaxon.sort((a, b) => {
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

  addCustomControl() {
    let initzoomcontrol = new L.Control();
    initzoomcontrol.setPosition("topleft");
    initzoomcontrol.onAdd = () => {
      var container = L.DomUtil.create(
        "button",
        " btn btn-sm btn-outline-shadow leaflet-bar leaflet-control leaflet-control-custom"
      );
      container.innerHTML =
        '<i class="material-icons" style="line-height:normal;">crop_free</i>';
      container.style.padding = "1px 4px";
      container.title = "Réinitialiser l'emprise de la carte";
      container.onclick = () => {
        this._map.setView(this.center, this.zoom);
      };
      return container;
    };
    initzoomcontrol.addTo(this._map);
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

  onSearchTaxon(event) {
    this.onSetParams("taxon", event);
    this.onChargeList(this.storeService.queryString.toString());
  }

  ngOnDestroy() {
    let filterkey = this.storeService.queryString.keys();
    filterkey.forEach(key => {
      this.storeService.queryString = this.storeService.queryString.delete(key);
    });

    //this.mysubscribe.unsubribe();
  }
}