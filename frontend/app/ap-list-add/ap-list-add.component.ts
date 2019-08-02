import { Component, OnInit, OnChanges, ViewChild, AfterViewInit } from "@angular/core";
import { Router, ActivatedRoute } from "@angular/router";
import { ToastrService } from "ngx-toastr";
import * as L from "leaflet";
import { FormGroup } from "@angular/forms";
import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";
import { DataService } from "../services/data.service";
import { FormService } from "../services/form.service";
import { StoreService } from "../services/store.service";
import { LeafletDrawComponent } from '@geonature_common/map/leaflet-draw/leaflet-draw.component';



@Component({
  selector: "pnx-ap-list-add",
  templateUrl: "ap-list-add.component.html",
  styleUrls: ["./ap-list-add.component.scss"],
  providers: [MapListService]
})
export class ApListAddComponent implements OnInit, OnChanges, AfterViewInit {

  public currentSite = {};
  public idAp;
  public ApFormGroup: FormGroup;
  public filteredData = [];
  public dataLoaded = false;
  public geojsonZp;
  public geojsonAp;
  public leafletAlreadyEnable;
  public currentAp;
  public currentApProvisoire;
  @ViewChild("drawComponent") public drawComponent: LeafletDrawComponent;


  constructor(
    public mapService: MapService,
    public formService: FormService,
    public storeService: StoreService,
    public router: Router,
    public _api: DataService,
    public activatedRoute: ActivatedRoute,
    public mapListService: MapListService,
    private toastr: ToastrService,

  ) { }

  ngOnInit() {

    this.ApFormGroup = this.formService.initFormAp();

    this.mapListService.onMapClik$.subscribe(currentId => {
      this.currentApProvisoire = this.storeService.sites.features.filter(ap => {
        return ap.id == currentId
      });
      if (this.currentApProvisoire.length > 0) {
        this.currentApProvisoire = this.currentApProvisoire[0].geometry
      }
    });

    this.mapListService.onTableClick$.subscribe(currentId => {
      this.currentApProvisoire = this.storeService.sites.features.filter(ap => {
        return ap.id == currentId
      });
      if (this.currentApProvisoire.length > 0) {
        this.currentApProvisoire = this.currentApProvisoire[0].geometry
      }
    })
  }

  ngAfterViewInit() {
    const url = this.router.url.split('/');

    if (url[url.length - 1] == 'info_zp') {
      this.leafletAlreadyEnable = false;
      this.drawComponent.disableLeafletDraw();
    }


    this.router.events.subscribe(data => {
      const url = (data as any).url.split('/');
      if (url[url.length - 1] == 'form_ap' || url[url.length - 2] == 'form_ap') {
        if (!this.leafletAlreadyEnable) {
          this.currentAp = this.currentApProvisoire;
          this.drawComponent.enableLeafletDraw();
          this.leafletAlreadyEnable = true;
        }
      } else if (url[url.length - 1] == 'info_zp') {
        this.leafletAlreadyEnable = false;
        this.drawComponent.disableLeafletDraw();
      }
    })

    this.mapService.map.doubleClickZoom.disable();
    this.storeService.idSite = this.activatedRoute.snapshot.params['idZP'];
    this.mapListService.idName = 'indexap';
    this.mapListService.enableMapListConnexion(this.mapService.getMap());
    this._api.getOneZP(this.storeService.idSite).subscribe(
      data => {
        this.storeService.zp = data['zp'];
        this.storeService.sites = data['aps'];

        this.mapListService.loadTableData(data['aps']);
        this.filteredData = this.mapListService.tableData;
        this.dataLoaded = true;
        let properties = data['zp'].features[0].properties;
        this.storeService.indexZp = properties.indexzp;
        console.log(data['zp']);

        let fullNameObs;
        this.storeService.observateur = [];
        data['zp'].features[0].properties.cor_zp_observer.forEach(obs => {
          if (obs == data['zp'].features[0].properties.cor_zp_observer[data['zp'].features[0].properties.cor_zp_observer.length - 1]) {
            fullNameObs = obs.nom_complet + '. ';
          } else {
            fullNameObs = obs.nom_complet + ', ';
          }
          this.storeService.observateur.push(fullNameObs);
        });

        let fullNameCom;
        this.storeService.nomCommune = [];
        data['zp'].features[0].properties.cor_zp_area.forEach(com => {
          if (com == data['zp'].features[0].properties.cor_zp_area[data['zp'].features[0].properties.cor_zp_area.length - 1]) {
            fullNameCom = com.area_name + '. ';
          } else {
            fullNameCom = com.area_name + ', ';
          }
          this.storeService.nomCommune.push(fullNameCom);
        });

        this.storeService.taxons = data['zp'].features[0].properties.taxonomy.nom_complet;
        this.storeService.dateMin = properties.date_min;

        // zoom on zp
        // HACK devrait être fait par pnx-geojson
        this.mapService.map.fitBounds(
          new L.FeatureGroup().addLayer(L.geoJSON(data['zp'])).getBounds()
        )
      },
      error => {
        if (error.status != 404) {
          this.toastr.error(
            "Une erreur est survenue lors de la récupération des informations sur le serveur",
            "",
            {
              positionClass: "toast-top-right"
            }
          );
          console.log("error: ", error);
        }
      });
  }

  sendGeoInfo(geojson) {
    // declenche next sur l'observable _geojsonCoord
    this.mapService._geojsonCoord.next(geojson);
    //this.mapService.setGeojsonCoord(geojson);
    this.geojsonZp = this.storeService.zp.features[0];
    this.geojsonAp = geojson;
    if (this.storeService.booleanContains(this.geojsonZp, this.geojsonAp)) {
      this.storeService.disableForm = false;
      this.ApFormGroup.patchValue({ geom_4326: geojson.geometry });
    } else {
      this.mapService.removeAllLayers(this.mapService.map, this.mapService.leafletDrawFeatureGroup);

      this.toastr.error(
        "L'aire de présence n'est pas située dans la zone de prospection",
        "",
        {
          positionClass: "toast-top-center"
        }
      );
    }
  }

  onEachFeature(feature, layer) {
    // event from the map
    let site = feature.properties;
    this.mapListService.layerDict[feature.id] = layer;
    layer.on({
      click: (e) => {
        // toggle style
        this.mapListService.toggleStyle(layer);
        // observable
        this.mapListService.mapSelected.next(feature.id);
        // open popup
        const customPopup = '<div class="title">Altitude : ' + site.altitude_max + 'm<br />Surface : ' + site.area + ' m\u00b2</div>';
        const customOptions = {
          className: "custom-popup"
        };
        layer.bindPopup(customPopup, customOptions);
      }
    });
  }

  onEachZp(feature, layer) {
    layer.setStyle({ 'color': '#F4D03F', 'fillOpacity': 0, 'weight': 4 })
  }


}