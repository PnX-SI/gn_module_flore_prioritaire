import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { FormService } from '@geonature_common/form/form.service';
import { DataService } from '../services/data.service';
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
  public myGeoJSON;
  public filteredData = [];
  public dataLoaded = false;
  public displayColumns: Array<any>;
  
  constructor(
    public mapService: MapService,
    private mapListService: MapListService,
    public router: Router,
    public storeService: StoreService,
    public api: DataService
  ) {}

  ngOnInit() {

    
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

  
  }

  onAddZp() {
    this.router.navigate(["flore_prioritaire/form"]); 
  }
  

  ngAfterViewInit() {
    // event from the list
    this.mapListService.enableMapListConnexion(this.mapService.getMap());
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
}