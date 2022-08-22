import {
  Component,
  OnInit,
  AfterViewInit,
  ViewChild,
} from '@angular/core';
import {
  FormGroup,
  FormBuilder,
  Validators,
} from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';

import { NgbDateParserFormatter } from '@ng-bootstrap/ng-bootstrap';
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { ToastrService } from 'ngx-toastr';

import { DataFormService } from '@geonature_common/form/data-form.service';
import { GeojsonComponent } from '@geonature_common/map/geojson/geojson.component';
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { MapService } from '@geonature_common/map/map.service';
import { MapListService } from '@geonature_common/map-list/map-list.service';

import { DataService } from '../services/data.service';
import { StoreService } from '../services/store.service';
import { ModuleConfig } from '../module.config';


@Component({
  selector: 'pf-zp-add',
  templateUrl: 'zp-add.component.html',
  styleUrls: ['zp-add.component.scss'],
  providers: [MapListService, MapService]
})
export class ZpAddComponent implements OnInit, AfterViewInit {
  public leafletDrawOptions = leafletDrawOption;
  public ZpFormGroup: FormGroup;
  public idZp;

  @ViewChild('geojson')
  geojson: GeojsonComponent;

  constructor(
    public activatedRoute: ActivatedRoute,
    private formBuilder: FormBuilder,
    public router: Router,
    public dataFormService: DataFormService,
    private toastrService: ToastrService,
    public ngbModal: NgbModal,
    public api: DataService,
    public storeService: StoreService,
    private dateParser: NgbDateParserFormatter
  ) {}

  ngOnInit() {
    this.setLeafletDrawOptions();
    this.idZp = this.activatedRoute.snapshot.params['idZp'];
    this.ZpFormGroup = this.formBuilder.group({
      id_zp: null,
      cd_nom: [null, Validators.required],
      date_min: [null, Validators.required],
      cor_zp_observer: [],
      geom_4326: [null, Validators.required]
    });
  }

  private setLeafletDrawOptions() {
    this.leafletDrawOptions.draw.rectangle = true;
    this.leafletDrawOptions.draw.marker = false;
    this.leafletDrawOptions.draw.polyline = false;
    this.leafletDrawOptions.edit.remove = true;
  }

  ngAfterViewInit() {
    // Update mode
    if (this.idZp !== undefined) {
      this.api.getOneZP(this.idZp).subscribe(element => {
        const zp = element.zp.properties;
        this.ZpFormGroup.patchValue({
          id_zp: zp.id_zp,
          cd_nom: zp.taxonomy,
          date_min: this.dateParser.parse(zp.date_min),
          cor_zp_observer: zp.observers,
          geom_4326: element.zp.geometry
        });
      });
    }
  }

  onCancel() {
    this.router.navigate([`${ModuleConfig.MODULE_URL}`]);
  }

  onSubmit() {
    let finalForm = this.formateDataFormZp();

    this.api.postZp(finalForm).subscribe(data => {
      this.toastrService.success('Zone de prospection enregistrée', '', {
        positionClass: 'toast-top-center'
      });

      this.router.navigate([
        `${ModuleConfig.MODULE_URL}/zp`,
        data.id,
        'details'
      ]);
    });
  }

  private formateDataFormZp() {
    const finalForm = JSON.parse(JSON.stringify(this.ZpFormGroup.value));

    finalForm.date_min = this.dateParser.format(finalForm.date_min);

    //observers
    finalForm['cor_zp_observer'] = finalForm['cor_zp_observer'].map(obs => {
      return obs.id_role;
    });

    //taxon
    finalForm.cd_nom = finalForm.cd_nom.cd_nom;

    return finalForm;
  }

  sendGeoInfo(geojson) {
    this.ZpFormGroup.patchValue({ geom_4326: geojson.geometry });
    this.ZpFormGroup.markAsDirty();
  }

  deleteGeoInfo() {
    this.ZpFormGroup.patchValue({ geom_4326: null });
    this.ZpFormGroup.markAsDirty();
  }
}
