import { Component, OnInit, Input, AfterViewInit, EventEmitter, Output } from '@angular/core';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { CommonService } from "@geonature_common/service/common.service";
import * as L from "leaflet";
import { FormService } from '@geonature_common/form/form.service';
import { DataService } from '../services/data.service';
import { FormGroup, FormBuilder, FormControl } from "@angular/forms";
import { StoreService } from '../services/store.service';
import { Router, ActivatedRoute } from '@angular/router';
import { ModuleConfig } from "../module.config";
import { HttpParams } from '@angular/common/http';

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
  public municipalities = [];
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
    private _commonService: CommonService,
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
    this.center = this.storeService.fpConfig.zoom_center;
    this.zoom = this.storeService.fpConfig.zoom;

    this.filterForm = this._fb.group({
      filterYear: null,
      filterOrga: null,
      filterCom: null,
      filterTaxon: null,
      idZp : null
    });

    this.filterForm.controls.filterYear.valueChanges
      .subscribe(year => {
        
        if(year && year.toString().length === 4) {
          console.log(year);
          this.setQueryString("year", year.toString());
          this.loadData();
          
        }
        if(!year) {
          this.deleteParams("year");
          this.loadData(); 
        }
      });

    this.filterForm.controls.filterOrga.valueChanges
      .subscribe(org => {
        if(org) {
          this.setQueryString("id_organism", org);
          this.loadData();      
        }else {
          this.deleteParams("id_organism");
          this.loadData();      
        }
      });

      

    this.filterForm.controls.filterCom.valueChanges
      .subscribe(id_area => {
        if(id_area) {
          this.setQueryString("id_area", id_area);
          this.loadData();
        } else {
          this.deleteParams("id_area");
          this.loadData();
        }
      });

  }

  loadData() {    
    this.api.getZProspects(this.storeService.queryString).subscribe(data => {
      this.myGeoJSON = data;
      this.mapListService.loadTableData(data);
      this.filteredData = this.mapListService.tableData;
      this.dataLoaded = true;
    }
    );
  }
  onAddZp() {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/post_zp`]);
  }

  onEditZp(indexzp) {
    this.router.navigate([`${ModuleConfig.MODULE_URL}/post_zp`, indexzp]);
  }

  onInfo(indexzp) {
    this.router.navigate(
      [
        `${ModuleConfig.MODULE_URL}/zp`,
        indexzp, 'details'
      ]
    );
  }

  onDeleteZp(indexzp) {
    this.api.deleteZp(indexzp).subscribe(
      data => {
        this.filteredData = this.filteredData.filter(item => {
          return indexzp !== item.indexzp
        })
        const filterFeature = this.myGeoJSON.features.filter(feature => {
          return indexzp !== feature.properties.indexzp
        })
        this.myGeoJSON['features'] = filterFeature;
        this.myGeoJSON = Object.assign({}, this.myGeoJSON);
        this._commonService.translateToaster(
          "success",
          "Releve.DeleteSuccessfully"
        );
      },
      error => {
        if (error.status === 403) {
          this._commonService.translateToaster("error", "NotAllowed");
        } else {
          this._commonService.translateToaster("error", "ErrorMessage");
        }
      }
    );
  }

  ngAfterViewInit() {
    // event from the list
    this.mapListService.enableMapListConnexion(this.mapService.getMap());

    this._map = this.mapService.getMap();
    this.addCustomControl();

    this.api.getOrganisme().subscribe(orgs => {
      this.tabOrganism = orgs
    });

    this.api.getCommune().subscribe(municipalities => {
      this.municipalities = municipalities;
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


  setQueryString(param: string, value) {
    this.storeService.queryString = this.storeService.queryString.set(
      param,
      value
    );
  }

  deleteParams(param: string) {
    this.storeService.queryString = this.storeService.queryString.delete(param);
  }

  removeCdNom() {
    this.deleteParams("cd_nom");
    this.loadData();
  }


  onSearchTaxon(event) {
    this.setQueryString("cd_nom", event.item.cd_nom);
    this.loadData();
  }

  ngOnDestroy() {
    let filterkey = this.storeService.queryString.keys();
    filterkey.forEach(key => {
      this.storeService.queryString = this.storeService.queryString.delete(key);
    });

    //this.mysubscribe.unsubribe();
  }
}