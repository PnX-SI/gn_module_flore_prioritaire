import { Injectable } from '@angular/core';
import { FormGroup, FormBuilder, Validators, AbstractControl } from '@angular/forms';

@Injectable()
export class FormService {
  public disabled = true;

  constructor(private _fb: FormBuilder) { }

  initFormAp(): FormGroup {
    const ApFormGroup = this._fb.group({
      indexap: null,
      indexzp: null,
      cor_ap_perturbation: new Array(),
      area: [{value: null, disabled: true}],
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
      geom_4326: [null, Validators.required]
    });
    ApFormGroup.setValidators([this.countingValidator]);

    return ApFormGroup;
  }

  countingValidator(ApFormGroup: AbstractControl): { [key: string]: boolean } {
    const countMin = ApFormGroup.get("total_min").value;
    const countMax = ApFormGroup.get("total_max").value;
    if (countMin && countMax) {
      return countMin > countMax ? { invalidCount: true } : null;
    }
    return null;
  }
}
