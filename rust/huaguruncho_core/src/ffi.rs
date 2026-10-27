use crate::crypto::{audit_huella_cero, sign_eco_report, WasteAuditInput};
use crate::geo::{
    calculate_estimated_duration_minutes, evaluate_live_telemetry, haversine_distance_km,
    haversine_distance_meters, parse_gpx_content, simplify_points_rdp,
};
use crate::media::{extract_panorama_metadata_from_file, optimize_evidence_image};
use crate::packaging::{build_offline_zip, compute_file_hashes, OfflineZipRequest};
use serde::Deserialize;
use serde_json::json;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

const VERSION_CSTR: &[u8] = b"huaguruncho_core 2.0.0\0";

fn cstr_to_str<'a>(ptr: *const c_char) -> Option<&'a str> {
    if ptr.is_null() {
        return None;
    }
    unsafe { CStr::from_ptr(ptr).to_str().ok() }
}

fn to_owned_c_char(s: String) -> *mut c_char {
    match CString::new(s) {
        Ok(cs) => cs.into_raw(),
        Err(_) => CString::new("{\"success\":false,\"error\":\"null byte in string\"}")
            .unwrap()
            .into_raw(),
    }
}

#[no_mangle]
pub extern "C" fn h360_version() -> *const c_char {
    VERSION_CSTR.as_ptr() as *const c_char
}

#[no_mangle]
pub extern "C" fn h360_free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}

#[no_mangle]
pub extern "C" fn h360_haversine_km(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    haversine_distance_km(lat1, lon1, lat2, lon2)
}

#[no_mangle]
pub extern "C" fn h360_haversine_meters(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    haversine_distance_meters(lat1, lon1, lat2, lon2)
}

#[no_mangle]
pub extern "C" fn h360_estimated_duration_minutes(
    distance_km: f64,
    elevation_gain_m: f64,
    elevation_loss_m: f64,
    max_altitude_m: f64,
) -> i32 {
    calculate_estimated_duration_minutes(
        distance_km,
        elevation_gain_m,
        elevation_loss_m,
        max_altitude_m,
    )
}

#[no_mangle]
pub extern "C" fn h360_parse_gpx_json(gpx_utf8: *const c_char) -> *mut c_char {
    let Some(gpx_text) = cstr_to_str(gpx_utf8) else {
        return to_owned_c_char(
            json!({"success": false, "error": "Puntero GPX nulo o inválido"}).to_string(),
        );
    };
    let val = parse_gpx_content(gpx_text);
    to_owned_c_char(val.to_string())
}

#[no_mangle]
pub extern "C" fn h360_simplify_rdp_json(points_json: *const c_char, epsilon: f64) -> *mut c_char {
    let Some(raw) = cstr_to_str(points_json) else {
        return to_owned_c_char("[]".to_string());
    };
    let parsed: Result<Vec<Vec<f64>>, _> = serde_json::from_str(raw);
    let Ok(vec_pts) = parsed else {
        return to_owned_c_char("[]".to_string());
    };
    let pts: Vec<[f64; 3]> = vec_pts
        .into_iter()
        .filter(|p| p.len() >= 2)
        .map(|p| [p[0], p[1], if p.len() >= 3 { p[2] } else { 0.0 }])
        .collect();
    let simplified = simplify_points_rdp(&pts, epsilon);
    to_owned_c_char(serde_json::to_string(&simplified).unwrap_or_else(|_| "[]".to_string()))
}

#[derive(Deserialize)]
struct TelemetryInputPayload {
    current_lat: f64,
    current_lon: f64,
    current_alt_m: f64,
    max_alt_m: f64,
    total_distance_km: f64,
    trail_lat_lon: Vec<[f64; 2]>,
}

#[no_mangle]
pub extern "C" fn h360_evaluate_telemetry_json(request_json: *const c_char) -> *mut c_char {
    let Some(raw) = cstr_to_str(request_json) else {
        return to_owned_c_char(
            json!({"success": false, "error": "JSON de telemetría inválido"}).to_string(),
        );
    };
    let Ok(req) = serde_json::from_str::<TelemetryInputPayload>(raw) else {
        return to_owned_c_char(
            json!({"success": false, "error": "Estructura de telemetría inválida"}).to_string(),
        );
    };
    let res = evaluate_live_telemetry(
        req.current_lat,
        req.current_lon,
        req.current_alt_m,
        req.max_alt_m,
        req.total_distance_km,
        &req.trail_lat_lon,
    );
    to_owned_c_char(serde_json::to_string(&res).unwrap_or_else(|_| "{}".to_string()))
}

#[no_mangle]
pub extern "C" fn h360_extract_exif_file_json(file_path: *const c_char) -> *mut c_char {
    let Some(path) = cstr_to_str(file_path) else {
        return to_owned_c_char(
            json!({"latitude": null, "longitude": null, "altitude_masl": null, "heading": null})
                .to_string(),
        );
    };
    to_owned_c_char(extract_panorama_metadata_from_file(path).to_string())
}

#[no_mangle]
pub extern "C" fn h360_optimize_evidence_image_json(
    input_path: *const c_char,
    output_path: *const c_char,
    max_dim: u32,
    quality: u32,
) -> *mut c_char {
    let (Some(in_p), Some(out_p)) = (cstr_to_str(input_path), cstr_to_str(output_path)) else {
        return to_owned_c_char(
            json!({"success": false, "error": "Ruta de imagen inválida"}).to_string(),
        );
    };
    let q = quality.clamp(40, 95) as u8;
    to_owned_c_char(optimize_evidence_image(in_p, out_p, max_dim, q).to_string())
}

#[no_mangle]
pub extern "C" fn h360_build_offline_zip_json(request_json: *const c_char) -> *mut c_char {
    let Some(raw) = cstr_to_str(request_json) else {
        return to_owned_c_char(
            json!({"success": false, "error": "Solicitud ZIP nula"}).to_string(),
        );
    };
    let Ok(req) = serde_json::from_str::<OfflineZipRequest>(raw) else {
        return to_owned_c_char(
            json!({"success": false, "error": "JSON de OfflineZipRequest inválido"}).to_string(),
        );
    };
    to_owned_c_char(build_offline_zip(&req).to_string())
}

#[no_mangle]
pub extern "C" fn h360_compute_file_hashes_json(file_path: *const c_char) -> *mut c_char {
    let Some(path) = cstr_to_str(file_path) else {
        return to_owned_c_char(
            json!({"success": false, "error": "Ruta de archivo nula"}).to_string(),
        );
    };
    to_owned_c_char(compute_file_hashes(path).to_string())
}

#[no_mangle]
pub extern "C" fn h360_audit_huella_cero_json(request_json: *const c_char) -> *mut c_char {
    let Some(raw) = cstr_to_str(request_json) else {
        return to_owned_c_char(
            json!({"success": false, "error": "JSON de auditoría nulo"}).to_string(),
        );
    };
    let Ok(req) = serde_json::from_str::<WasteAuditInput>(raw) else {
        return to_owned_c_char(
            json!({"success": false, "error": "Estructura WasteAuditInput inválida"}).to_string(),
        );
    };
    let res = audit_huella_cero(&req);
    to_owned_c_char(serde_json::to_string(&res).unwrap_or_else(|_| "{}".to_string()))
}

#[no_mangle]
pub extern "C" fn h360_sign_eco_report_json(
    local_uuid: *const c_char,
    category: *const c_char,
    lat: f64,
    lon: f64,
    captured_at: *const c_char,
) -> *mut c_char {
    let uuid = cstr_to_str(local_uuid).unwrap_or("");
    let cat = cstr_to_str(category).unwrap_or("");
    let cap = cstr_to_str(captured_at).unwrap_or("");
    to_owned_c_char(sign_eco_report(uuid, cat, lat, lon, cap).to_string())
}
