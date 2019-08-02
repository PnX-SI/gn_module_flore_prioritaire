import { HttpParams } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Layer, Map } from 'leaflet';
import * as L from "leaflet";
import { NgbModal } from '@ng-bootstrap/ng-bootstrap';
import { ModuleConfig } from '../module.config';
import { DataService } from "../services/data.service";
import { MapListService } from '@geonature_common/map-list/map-list.service';
import { MapService } from "@geonature_common/map/map.service";
import { leafletDrawOption } from '@geonature_common/map/leaflet-draw.options';
import { AppConfig } from '@geonature_config/app.config';
import { CommonService } from "@geonature_common/service/common.service";
import { Router } from "@angular/router";

@Injectable()
export class StoreService {
  public currentLayer: Layer;
  public sites;
  public zp;
  public idSite;
  public dataLoaded = false;
  public observateur = [];
  public organisme;
  public indexZp;
  public dateMin;
  public nomCommune = [];
  public siteDesc;
  public taxons;
  public _map;
  public nb_transects_frequency;
  public altitude_min;
  public altitude_max;
  public fpConfig = ModuleConfig;
  public leafletDrawOptions = leafletDrawOption;
  public showLeafletDraw = false;
  public disableForm = true;
  public paramApp = new HttpParams().append(
    "id_application",
    ModuleConfig.ID_MODULE
  );
  public myStylePresent = {
    color: '#008000',
    fill: true,
    fillOpacity: 0.2,
    weight: 3
  };
  constructor(
    public _api: DataService,
    public mapListService: MapListService,
    private _commonService: CommonService,
    private _modalService: NgbModal,
    private _router: Router,
    private _mapService: MapService
  ) {

  }

  public presence = 0;

  public queryString = new HttpParams();

  public urlLoad = `${AppConfig.API_ENDPOINT}/${ModuleConfig.MODULE_URL}/export_ap`;

  openModal(content) {
    this._modalService.open(content);
  }

  formDisabled() {
    if (this.disableForm) {
      this._commonService.translateToaster(
        "warning",
        "Releve.FillGeometryFirst");
    }
  }
  booleanContains(feature1, feature2) {
    const type2 = feature2.geometry.type;
    switch (type2) {
      case "Point":
        return this.booleanPointInPolygon(feature2, feature1, { ignoreBoundary: true });
      case "Polygon":
        return this.isPolyInPoly(feature1, feature2);
      case "LineString":
        return this.isLineInPoly(feature1, feature2);
      default:
        throw new Error("feature2 " + type2 + " geometry not supported");
    }
  }


  isPolyInPoly(feature1, feature2) {
    // Handle Nulls
    if (feature1.type === "Feature" && feature1.geometry === null) { return false; }
    if (feature2.type === "Feature" && feature2.geometry === null) { return false; }

    const poly1Bbox = this.calcBbox(feature1);
    const poly2Bbox = this.calcBbox(feature2);
    if (!this.doBBoxOverlap(poly1Bbox, poly2Bbox)) {
      return false;
    }

    const coords = feature2.geometry.coordinates;
    for (const ring of coords) {
      for (const coord of ring) {
        if (!this.booleanPointInPolygon(coord, feature1)) {
          return false;
        }
      }
    }
    return true;
  }

  doBBoxOverlap(bbox1, bbox2) {
    if (bbox1[0] > bbox2[0]) { return false; }
    if (bbox1[2] < bbox2[2]) { return false; }
    if (bbox1[1] > bbox2[1]) { return false; }
    if (bbox1[3] < bbox2[3]) { return false; }
    return true;
  }

  booleanPointInPolygon(point, polygon, options: { ignoreBoundary?: boolean, } = {}, ) {
    const pt = point.geometry.coordinates;
    const geom = polygon.geometry;
    const type = geom.type;
    const bbox = polygon.bbox;

    let polys: any[] = geom.coordinates;
    // Quick elimination if point is not inside bbox
    if (bbox && this.inBBox(pt, bbox) === false) {
      return false;
    }
    // normalize to multipolygon
    if (type === "Polygon") {
      polys = [polys];
    }
    let insidePoly = false;
    for (let i = 0; i < polys.length && !insidePoly; i++) {
      // check if it is in the outer ring first
      if (this.inRing(pt, polys[i][0], options.ignoreBoundary)) {
        let inHole = false;
        let k = 1;
        // check for the point in any of the holes
        while (k < polys[i].length && !inHole) {
          if (this.inRing(pt, polys[i][k], !options.ignoreBoundary)) {
            inHole = true;
          }
          k++;
        }
        if (!inHole) {
          insidePoly = true;
        }
      }
    }
    return insidePoly;
  }

  isLineInPoly(polygon, linestring) {
    let output = false;
    let i = 0;

    const polyBbox = this.calcBbox(polygon);
    const lineBbox = this.calcBbox(linestring);
    if (!this.doBBoxOverlap(polyBbox, lineBbox)) {
      return false;
    }
    for (i; i < linestring.geometry.coordinates.length - 1; i++) {

      const midPoint = this.getMidpoint(linestring.geometry.coordinates[i], linestring.geometry.coordinates[i + 1]);
      const ptGeojson = { type: "Point", geometry: { coordinates: midPoint } };
      if (this.booleanPointInPolygon(ptGeojson, polygon, { ignoreBoundary: true })) {
        output = true;
        break;
      }
    }
    return output;
  }

  getMidpoint(pair1: number[], pair2: number[]) {
    return [(pair1[0] + pair2[0]) / 2, (pair1[1] + pair2[1]) / 2];
  }


  inRing(pt: number[], ring: number[][], ignoreBoundary?: boolean) {
    let isInside = false;
    if (ring[0][0] === ring[ring.length - 1][0] && ring[0][1] === ring[ring.length - 1][1]) {
      ring = ring.slice(0, ring.length - 1);
    }
    for (let i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      const xi = ring[i][0];
      const yi = ring[i][1];
      const xj = ring[j][0];
      const yj = ring[j][1];
      const onBoundary = (pt[1] * (xi - xj) + yi * (xj - pt[0]) + yj * (pt[0] - xi) === 0) &&
        ((xi - pt[0]) * (xj - pt[0]) <= 0) && ((yi - pt[1]) * (yj - pt[1]) <= 0);
      if (onBoundary) {
        return !ignoreBoundary;
      }
      const intersect = ((yi > pt[1]) !== (yj > pt[1])) &&
        (pt[0] < (xj - xi) * (pt[1] - yi) / (yj - yi) + xi);
      if (intersect) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  inBBox(pt, bbox) {
    return bbox[0] <= pt[0] &&
      bbox[1] <= pt[1] &&
      bbox[2] >= pt[0] &&
      bbox[3] >= pt[1];
  }

  calcBbox(geojson: any) {
    const result = [Infinity, Infinity, -Infinity, -Infinity];
    this.coordEach(geojson, (coord) => {
      if (result[0] > coord[0]) { result[0] = coord[0]; }
      if (result[1] > coord[1]) { result[1] = coord[1]; }
      if (result[2] < coord[0]) { result[2] = coord[0]; }
      if (result[3] < coord[1]) { result[3] = coord[1]; }
    });
    return result;
  }

  coordEach(geojson, callback, excludeWrapCoord?) {
    // Handles null Geometry -- Skips this GeoJSON
    if (geojson === null) return;
    var j, k, l, geometry, stopG, coords,
      geometryMaybeCollection,
      wrapShrink = 0,
      coordIndex = 0,
      isGeometryCollection,
      type = geojson.type,
      isFeatureCollection = type === 'FeatureCollection',
      isFeature = type === 'Feature',
      stop = isFeatureCollection ? geojson.features.length : 1;


    for (var featureIndex = 0; featureIndex < stop; featureIndex++) {
      geometryMaybeCollection = (isFeatureCollection ? geojson.features[featureIndex].geometry :
        (isFeature ? geojson.geometry : geojson));
      isGeometryCollection = (geometryMaybeCollection) ? geometryMaybeCollection.type === 'GeometryCollection' : false;
      stopG = isGeometryCollection ? geometryMaybeCollection.geometries.length : 1;

      for (var geomIndex = 0; geomIndex < stopG; geomIndex++) {
        var multiFeatureIndex = 0;
        var geometryIndex = 0;
        geometry = isGeometryCollection ?
          geometryMaybeCollection.geometries[geomIndex] : geometryMaybeCollection;

        // Handles null Geometry -- Skips this geometry
        if (geometry === null) continue;
        coords = geometry.coordinates;
        var geomType = geometry.type;

        wrapShrink = (excludeWrapCoord && (geomType === 'Polygon' || geomType === 'MultiPolygon')) ? 1 : 0;

        switch (geomType) {
          case null:
            break;
          case 'Point':
            if (callback(coords, coordIndex, featureIndex, multiFeatureIndex, geometryIndex) === false) return false;
            coordIndex++;
            multiFeatureIndex++;
            break;
          case 'LineString':
          case 'MultiPoint':
            for (j = 0; j < coords.length; j++) {
              if (callback(coords[j], coordIndex, featureIndex, multiFeatureIndex, geometryIndex) === false) return false;
              coordIndex++;
              if (geomType === 'MultiPoint') multiFeatureIndex++;
            }
            if (geomType === 'LineString') multiFeatureIndex++;
            break;
          case 'Polygon':
          case 'MultiLineString':
            for (j = 0; j < coords.length; j++) {
              for (k = 0; k < coords[j].length - wrapShrink; k++) {
                if (callback(coords[j][k], coordIndex, featureIndex, multiFeatureIndex, geometryIndex) === false) return false;
                coordIndex++;
              }
              if (geomType === 'MultiLineString') multiFeatureIndex++;
              if (geomType === 'Polygon') geometryIndex++;
            }
            if (geomType === 'Polygon') multiFeatureIndex++;
            break;
          case 'MultiPolygon':
            for (j = 0; j < coords.length; j++) {
              geometryIndex = 0;
              for (k = 0; k < coords[j].length; k++) {
                for (l = 0; l < coords[j][k].length - wrapShrink; l++) {
                  if (callback(coords[j][k][l], coordIndex, featureIndex, multiFeatureIndex, geometryIndex) === false) return false;
                  coordIndex++;
                }
                geometryIndex++;
              }
              multiFeatureIndex++;
            }
            break;
          case 'GeometryCollection':
            for (j = 0; j < geometry.geometries.length; j++)
              if (this.coordEach(geometry.geometries[j], callback, excludeWrapCoord) === false) return false;
            break;
          default:
            throw new Error('Unknown Geometry Type');
        }
      }
    }
  }
}






