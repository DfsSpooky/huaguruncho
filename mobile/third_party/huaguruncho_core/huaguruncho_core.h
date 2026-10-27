// Copyright (c) 2026 Proyecto Huaguruncho 360 - Municipalidad Distrital de Huachón, Pasco, Perú.
// Licensed under the MIT License.

#ifndef HUAGURUNCHO_CORE_H_
#define HUAGURUNCHO_CORE_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

const char *h360_version(void);
void h360_free_string(char *ptr);

double h360_haversine_km(double lat1, double lon1, double lat2, double lon2);
double h360_haversine_meters(double lat1, double lon1, double lat2, double lon2);
int32_t h360_estimated_duration_minutes(
    double distance_km,
    double elevation_gain_m,
    double elevation_loss_m,
    double max_altitude_m
);

char *h360_parse_gpx_json(const char *gpx_utf8);
char *h360_simplify_rdp_json(const char *points_json, double epsilon);
char *h360_evaluate_telemetry_json(const char *request_json);
char *h360_extract_exif_file_json(const char *file_path);
char *h360_optimize_evidence_image_json(
    const char *input_path,
    const char *output_path,
    uint32_t max_dim,
    uint32_t quality
);
char *h360_build_offline_zip_json(const char *request_json);
char *h360_compute_file_hashes_json(const char *file_path);
char *h360_audit_huella_cero_json(const char *request_json);
char *h360_sign_eco_report_json(
    const char *local_uuid,
    const char *category,
    double lat,
    double lon,
    const char *captured_at
);

#ifdef __cplusplus
}
#endif

#endif // HUAGURUNCHO_CORE_H_
