import { Injectable } from '@angular/core';
import { FormGroup, FormBuilder, Validators } from '@angular/forms';

@Injectable()
export class FormService {
  public disabled = true;

  constructor(private _fb: FormBuilder) {}

  initFormAp(): FormGroup {
    const formSuivi = this._fb.group({
      indexap: null,
      frequency: null,
      altitude_min: [null, Validators.required],
      altitude_max: null,
      cor_ap_observer: [null, Validators.required],
      cor_ap_perturbation: new Array(),
      cor_ap_physionomie: new Array(),
      id_nomenclatures_pente: null,
      id_nomenclatures_count_method: null,
      id_nomenclatures_freq_method: null,
      id_nomenclatures_phenology: null,
      nb_transects_frequency: null,
      nb_points_frequency: null,
      nb_contacts_frequency: null,
      nb_plots_count: null,
      area_plots_count: null,
      nb_sterile_plots: null,
      nb_fertile_plots: null,
      total_fertile: null,
      total_sterile: null,
      step_length: null,
      comments: null
    });
    return formSuivi;
  }
}
