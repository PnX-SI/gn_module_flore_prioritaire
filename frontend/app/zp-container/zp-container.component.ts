import { Component, OnInit } from "@angular/core";
import { RouterModule, Router, ActivatedRoute } from "@angular/router";
import { ToastrService } from "ngx-toastr";
import * as L from "leaflet";
import { CommonService } from "@geonature_common/service/common.service";
import { FormBuilder, FormGroup } from "@angular/forms";
import { MapListService } from "@geonature_common/map-list/map-list.service";
import { MapService } from "@geonature_common/map/map.service";
import { DataService } from "../services/data.service";
import { FormService } from "../services/form.service";
import { StoreService } from "../services/store.service";

@Component({
  selector: "pnx-ap-list-add",
  templateUrl: "zp-container.component.html",
  styleUrls: ["./zp-container.component.scss"],
  providers: [MapListService],
})
export class ZpContainerComponent implements OnInit {
  public currentSite = {};
  public idAp;
  public ApFormGroup: FormGroup;
  public filteredData = [];
  public dataLoaded = false;
  public disabledForm = true;

  constructor(
    public mapService: MapService,
    public formService: FormService,
    public storeService: StoreService,
    public router: Router,
    public _api: DataService,
    private _fb: FormBuilder,
    private _commonService: CommonService,
    public activatedRoute: ActivatedRoute,
    public mapListService: MapListService,
    private toastr: ToastrService
  ) {}

  ngOnInit() {
    this.ApFormGroup = this.formService.initFormAp();
    this.storeService.setLeafletDraw();
  }

  ngAfterViewInit() {
    this.mapService.map.doubleClickZoom.disable();
    this.storeService.idSite = this.activatedRoute.snapshot.params["idZP"];
    this.mapListService.idName = "id_ap";
    this.mapListService.enableMapListConnexion(this.mapService.getMap());
    this._api.getOneZP(this.storeService.idSite).subscribe(
      (data) => {
        this.storeService.zp = data["zp"];
        this.storeService.zpProperties = data["zp"]["properties"];
        this.storeService.zpProperties["areas"] = this.storeService.zpProperties["areas"].filter(
          (area) => area.area_type.type_code == "COM"
        );

        this.storeService.sites = data["aps"];
        this.mapListService.loadTableData(data["aps"]);
        this.filteredData = this.mapListService.tableData;
        this.dataLoaded = true;
      },
      (error) => {
        if (error.status != 404) {
          this.toastr.error(
            "Une erreur est survenue lors de la récupération des informations sur le serveur",
            "",
            {
              positionClass: "toast-top-right",
            }
          );
          console.log("error: ", error);
        }
      }
    );
  }
  sendGeoInfo(geojson) {
    // declenche next sur l'observable _geojsonCoord
    this.mapService.setGeojsonCoord(geojson);
    this.disabledForm = false;
    this.ApFormGroup.patchValue({ geom_4326: geojson.geometry });
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
        const customPopup =
          '<div class="title">Altitude : ' +
          site.altitude_max +
          "m<br />Surface : " +
          site.area +
          " m\u00b2</div>";
        const customOptions = {
          className: "custom-popup",
        };
        layer.bindPopup(customPopup, customOptions);
      },
    });
  }

  onEachZp(feature, layer) {
    layer.setStyle({ color: "#F4D03F", fillOpacity: 0, weight: 4 });
  }
  formDisabled() {
    if (this.disabledForm) {
      this._commonService.translateToaster("warning", "Releve.FillGeometryFirst");
    }
  }
}
