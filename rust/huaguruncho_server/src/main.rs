use axum::{
    extract::Json,
    http::StatusCode,
    response::IntoResponse,
    routing::{get, post},
    Router,
};
use huaguruncho_core::{
    crypto::{audit_huella_cero, sign_eco_report, WasteAuditInput},
    geo::{evaluate_live_telemetry, parse_gpx_content},
    packaging::compute_file_hashes,
};
use serde::Deserialize;
use serde_json::{json, Value};
use std::net::SocketAddr;
use tower_http::cors::CorsLayer;

#[derive(Deserialize)]
struct GpxAnalyzeRequest {
    gpx_content: String,
}

#[derive(Deserialize)]
struct TelemetryEvaluateRequest {
    current_lat: f64,
    current_lon: f64,
    current_alt_m: f64,
    max_alt_m: f64,
    total_distance_km: f64,
    trail_lat_lon: Vec<[f64; 2]>,
}

#[derive(Deserialize)]
struct EcoSignRequest {
    local_uuid: String,
    category: String,
    latitude: f64,
    longitude: f64,
    captured_at: String,
}

#[derive(Deserialize)]
struct PackageVerifyRequest {
    file_path: String,
}

async fn health_handler() -> Json<Value> {
    Json(json!({
        "status": "ok",
        "service": "huaguruncho_rust_engine",
        "version": "2.0.0",
        "capabilities": [
            "gpx_xml_stream_parser",
            "rdp_iterative_simplifier",
            "live_gps_telemetry",
            "huella_cero_cryptographic_audit",
            "blake3_sha256_offline_packager"
        ]
    }))
}

async fn analyze_gpx_handler(Json(payload): Json<GpxAnalyzeRequest>) -> impl IntoResponse {
    let result = parse_gpx_content(&payload.gpx_content);
    let ok = result.get("success").and_then(|v| v.as_bool()).unwrap_or(false);
    let status = if ok {
        StatusCode::OK
    } else {
        StatusCode::BAD_REQUEST
    };
    (status, Json(result))
}

async fn evaluate_telemetry_handler(Json(payload): Json<TelemetryEvaluateRequest>) -> Json<Value> {
    let res = evaluate_live_telemetry(
        payload.current_lat,
        payload.current_lon,
        payload.current_alt_m,
        payload.max_alt_m,
        payload.total_distance_km,
        &payload.trail_lat_lon,
    );
    Json(serde_json::to_value(res).unwrap_or_else(|_| json!({})))
}

async fn audit_huella_cero_handler(Json(payload): Json<WasteAuditInput>) -> Json<Value> {
    let res = audit_huella_cero(&payload);
    Json(serde_json::to_value(res).unwrap_or_else(|_| json!({})))
}

async fn sign_eco_report_handler(Json(payload): Json<EcoSignRequest>) -> Json<Value> {
    Json(sign_eco_report(
        &payload.local_uuid,
        &payload.category,
        payload.latitude,
        payload.longitude,
        &payload.captured_at,
    ))
}

async fn verify_package_handler(Json(payload): Json<PackageVerifyRequest>) -> Json<Value> {
    Json(compute_file_hashes(&payload.file_path))
}

pub fn build_router() -> Router {
    Router::new()
        .route("/health", get(health_handler))
        .route("/api/v1/rust/gpx/analyze", post(analyze_gpx_handler))
        .route(
            "/api/v1/rust/telemetry/evaluate",
            post(evaluate_telemetry_handler),
        )
        .route(
            "/api/v1/rust/huella-cero/audit",
            post(audit_huella_cero_handler),
        )
        .route(
            "/api/v1/rust/reports/sign",
            post(sign_eco_report_handler),
        )
        .route(
            "/api/v1/rust/packages/verify",
            post(verify_package_handler),
        )
        .layer(CorsLayer::permissive())
}

#[tokio::main]
async fn main() {
    let port: u16 = std::env::var("RUST_ENGINE_PORT")
        .ok()
        .and_then(|s| s.parse().ok())
        .unwrap_or(8081);

    let addr = SocketAddr::from(([0, 0, 0, 0], port));
    println!("🚀 Huaguruncho 360 Rust Engine escuchando en http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("No se pudo enlazar el puerto del motor Rust");
    axum::serve(listener, build_router())
        .await
        .expect("Error ejecutando servidor Axum");
}
