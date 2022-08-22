import { Injectable } from '@angular/core';
import {
  FormGroup,
  FormBuilder,
  Validators,
  AbstractControl,
  ValidationErrors
} from '@angular/forms';

@Injectable()
export class FormService {
  public disabled = true;

  constructor(private formBuilder: FormBuilder) {}

  initFormAp(): FormGroup {
    return this.formBuilder.group(
      {
        id_ap: null,
        id_zp: null,
        cor_ap_perturbation: new Array(),
        altitude_min: null,
        altitude_max: null,
        area: [{ value: null, disabled: true }],
        frequency: null,
        id_nomenclature_counting: null,
        id_nomenclature_habitat: null,
        id_nomenclature_incline: null,
        id_nomenclature_phenology: null,
        total_min: null,
        total_max: null,
        comment: null,
        geom_4326: [null, Validators.required]
      },
      { validators: [this.countingValidator, this.invalidAltitude] }
    );
  }

  countingValidator(ApFormGroup: AbstractControl): ValidationErrors | null {
    const countMin = ApFormGroup.get('total_min').value;
    const countMax = ApFormGroup.get('total_max').value;
    if (countMin && countMax) {
      return countMin > countMax ? { invalidCount: true } : null;
    }
    return null;
  }

  invalidAltitude(ApFormGroup: AbstractControl): ValidationErrors | null {
    const altitudeMin = ApFormGroup.get('altitude_min').value;
    const altitudeMax = ApFormGroup.get('altitude_max').value;
    if (altitudeMin && altitudeMax) {
      return altitudeMin > altitudeMax ? { invalidAltitude: true } : null;
    }
    return null;
  }
}
