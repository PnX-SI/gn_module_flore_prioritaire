import { Component } from '@angular/core';
import {
  HttpClient,
  HttpEvent,
  HttpHeaders,
  HttpEventType,
  HttpErrorResponse,
} from '@angular/common/http';
import { Observable } from 'rxjs';

import { NgbActiveModal } from '@ng-bootstrap/ng-bootstrap';

import { StoreService } from '../../services/store.service';

@Component({
  selector: 'gn-pf-modal-download',
  templateUrl: 'modal-download.component.html',
})
export class ModalDownloadComponent {
  public isDownloading: boolean = false;
  private blob: Blob;

  constructor(
    public activeModal: NgbActiveModal,
    public storeService: StoreService,
    private api: HttpClient
  ) { }

  downloadZp(format: string) {
    this.isDownloading = true;
    let queryString = this.storeService.queryString.append('export_format', format);

    let source = this.api.get(this.storeService.urlZpLoad, {
      params: queryString,
      headers: new HttpHeaders().set('Content-Type', 'application/json'),
      observe: 'events',
      responseType: 'blob',
      reportProgress: true,
    });

    this.subscribeAndDownload(source, 'zones_prospection', format);
  }

  downloadAp(format: string) {
    this.isDownloading = true;
    let queryString = this.storeService.queryString.append('export_format', format);

    let source = this.api.get(this.storeService.urlApLoad, {
      params: queryString,
      headers: new HttpHeaders().set('Content-Type', 'application/json'),
      observe: 'events',
      responseType: 'blob',
      reportProgress: true,
    });

    this.subscribeAndDownload(source, 'aires_presence', format);
  }

  subscribeAndDownload(
    source: Observable<HttpEvent<Blob>>,
    fileName: string,
    format: string,
    addDateToFilename: boolean = true
  ): void {
    const subscription = source.subscribe(
      (event) => {
        if (event.type === HttpEventType.Response) {
          this.blob = new Blob([event.body], { type: event.headers.get('Content-Type') });
        }
      },
      (e: HttpErrorResponse) => {
        this.isDownloading = false;
      },
      // response OK
      () => {
        this.isDownloading = false;
        const date = new Date();
        const extension = format === 'shapefile' ? 'zip' : format;
        this.saveBlob(
          this.blob,
          `${fileName}${addDateToFilename ? '_' + date.toISOString() : ''}.${extension}`
        );
        subscription.unsubscribe();
      }
    );
  }

  saveBlob(blob, filename) {
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.setAttribute('visibility', 'hidden');
    link.download = filename;
    link.onload = () => {
      URL.revokeObjectURL(link.href);
    };
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  }
}
