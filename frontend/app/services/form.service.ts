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
      area: null,
      id_nomenclatures_pente: null,
      altitude_min: null,
      altitude_max: null,
      id_nomenclatures_phenology: null,
      id_nomenclatures_habitat: null,
      frequency: null,
      total_min: [
        1,
        Validators.compose([
          Validators.required,
          Validators.pattern("[0-9]+[0-9]*")
        ])
      ],
      total_max: [
        1,
        Validators.compose([
          Validators.required,
          Validators.pattern("[0-9]+[0-9]*")
        ])
      ],
      id_nomenclatures_counting: null,
      comment: null,
      geom_4326: null
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
