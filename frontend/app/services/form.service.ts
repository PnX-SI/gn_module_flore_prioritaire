import { Injectable } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';

@Injectable()
export class FormService {
  public disabled = true;

  constructor(private _fb: FormBuilder) { }

  initFormAp(): FormGroup {
    const ApFormGroup = this._fb.group({
      indexzp: null,
      cor_ap_perturbation: new Array(),
      area: null,
      id_nomenclatures_pente: null,
      altitude_min: null,
      altitude_max: null,
      id_nomenclatures_phenology: null,
      id_nomenclatures_habitat: null,
      frequency: null,
      total_min: null,
      total_max: null,
      id_nomenclatures_counting: null,
      comment: null,
      geom_4326: null
    });
    return ApFormGroup;
  }
}
