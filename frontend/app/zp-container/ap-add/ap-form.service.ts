import { Injectable } from '@angular/core';
import {
  FormGroup,
  FormBuilder,
  Validators,
  AbstractControl,
  ValidationErrors
} from '@angular/forms';

@Injectable()
export class ApFormService {
  public disabled = true;

  constructor(private formBuilder: FormBuilder) {}

  initFormAp(): FormGroup {
    return this.formBuilder.group(
      {
        id_ap: null,
        id_zp: null,
        altitude_min: null,
        altitude_max: null,
        area: [{ value: null, disabled: true }, [Validators.required, Validators.min(1)]],
        id_nomenclature_incline: null,
        physiognomies: new Array(),
        id_nomenclature_habitat: null,
        favorable_status_percent: [
          null,
          [Validators.min(0), Validators.max(100)]
        ],
        id_nomenclature_threat_level: null,
        perturbations: new Array(),
        id_nomenclature_phenology: null,
        id_nomenclature_frequency_method: null,
        frequency: [null, [Validators.min(0), Validators.max(100)]],
        id_nomenclature_counting: null,
        total: [null, Validators.min(0)],
        total_min: [null, Validators.min(0)],
        total_max: [null, Validators.min(0)],
        comment: null,
        geom_4326: [null, Validators.required]
      },
      {
        validators: [this.countingValidator, this.invalidAltitudeValidator]
      }
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

  invalidAltitudeValidator(ApFormGroup: AbstractControl): ValidationErrors | null {
    const altitudeMin = ApFormGroup.get('altitude_min').value;
    const altitudeMax = ApFormGroup.get('altitude_max').value;
    if (altitudeMin && altitudeMax) {
      return altitudeMin > altitudeMax ? { invalidAltitude: true } : null;
    }
    return null;
  }
}
