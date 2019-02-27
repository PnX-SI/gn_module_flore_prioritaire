import { Component, OnInit, Input, AfterViewInit, ViewChild } from '@angular/core';
import { GeoJSON } from 'leaflet';
import { ToastrService } from 'ngx-toastr';
import { NgbDateParserFormatter } from "@ng-bootstrap/ng-bootstrap";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from '@geonature_common/map/map.service';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { FormService } from '@geonature_common/form/form.service';
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
  providers: [MapListService]
})
export class ApAddComponent implements OnInit, AfterViewInit {
  public site;
  public zp;
  public leafletDrawOptions = leafletDrawOption;
  public myGeoJSON: GeoJSON;
  public dynamicFormGroup: FormGroup;
  public filteredData = [];
  public paramApp = this.storeService.queryString.append(
    "id_application",
    ModuleConfig.ID_MODULE
  );
  
  constructor(
    private _ms: MapService,
    private mapListService: MapListService,
    private _fb: FormBuilder,
    public router: Router,
    private toastr: ToastrService,
    public ngbModal: NgbModal,
    public api: DataService,
    private _dateParser: NgbDateParserFormatter,
    public storeService: StoreService,
  ) {}

  ngOnInit() {
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.circle = true;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.edit.remove = true;

    this.dynamicFormGroup = this._fb.group({
      date_min: null,
      date_max: null,
      geom_4326: null
    }); 

  
    
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


  onPostAp() {
  const finalForm = JSON.parse(JSON.stringify(this.dynamicFormGroup.value));
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

  ngAfterViewInit() {
    // event from the list
    // this.mapListService.onTableClick(this._ms.getMap());
  }

  getGeojson(geojson) {
    this.dynamicFormGroup.patchValue(
      {'geom_4326': geojson.geometry}
    )
  }

  getVisits() {
    this._api.getVisits({ indexzp: this.idSite }).subscribe(
      data => {
        this.site = data;
        this.mapListService.loadTableData(data);
        this.filteredData = this.mapListService.tableData;
        this.dataLoaded = true;
      },
      
      error => {
        if (error.status != 404) {
          this.toastr.error(
            "Une erreur est survenue lors de la modification de votre relevé",
            "",
            {
              positionClass: "toast-top-right"
            }
          );
        }
      }
    );
  }

  getSites() {
    this.paramApp = this.paramApp.append("indexzp", this.idSite);
    this._api.getSites(this.paramApp).subscribe(
      data => {
        this.zp = data;
        let properties = data.features[0].properties;
        this.idSite = properties.indexzp;
        this.organisme = properties.organisme;
        this.nomCommune = properties.nom_commune;
        this.observateur = properties.nom_role;
        this.taxons = properties.taxon.nom_complet;
        this.dateMin = properties.date_min;

        this.geojson.currentGeoJson$.subscribe(currentLayer => {
          this.mapService.map.fitBounds(currentLayer.getBounds());
        });

        this.getVisits();
      },
      error => {
        this.toastr.error(
          "Une erreur est survenue lors de la récupération des informations sur le serveur",
          "",
          {
            positionClass: "toast-top-right"
          }
        );
        console.log("error: ", error);
      }
    );
  }

  deleteControlValue() {
    console.log('Suppression')
  }
}