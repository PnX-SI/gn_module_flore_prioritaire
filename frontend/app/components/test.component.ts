import { Component, OnInit } from "@angular/core";
import { FormGroup, FormBuilder } from "@angular/forms";
import { FILTERSLIST } from "./filters-list";

@Component({
  selector: "test",
  templateUrl: "test.component.html"
})
export class TestComponent implements OnInit {
    public idName: string;
    public formsDefinition = FILTERSLIST;
    public dynamicFormGroup: FormGroup;
  constructor(

    private _fb: FormBuilder
  ) {}

  ngOnInit() {
    this.dynamicFormGroup = this._fb.group({
    cd_nom: null,
    observers: null,
    dataset: null,
    observers_txt: null,
    id_dataset: null,
    date_up: null,
    date_low: null,
    municipality: null
  });
}
