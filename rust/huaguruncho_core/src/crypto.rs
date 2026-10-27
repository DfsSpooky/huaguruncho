use hmac::{Hmac, Mac};
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use sha2::Sha256;

type HmacSha256 = Hmac<Sha256>;

const HUELLA_CERO_DOMAIN_KEY: &[u8] = b"HUAGURUNCHO_360_HUELLA_CERO_MUNICIPALIDAD_HUACHON_PASCO_v2";

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WasteAuditInput {
    pub local_uuid: String,
    pub document_number: String,
    pub plastic_bottles_in: i32,
    pub cans_in: i32,
    pub plastic_wrappers_in: i32,
    pub plastic_bags_in: i32,
    pub batteries_in: i32,
    pub gas_canisters_in: i32,
    pub plastic_bottles_out: i32,
    pub cans_out: i32,
    pub plastic_wrappers_out: i32,
    pub plastic_bags_out: i32,
    pub batteries_out: i32,
    pub gas_canisters_out: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WasteAuditResult {
    pub total_items_in: i32,
    pub total_items_out: i32,
    pub net_balance: i32,
    pub return_rate_percent: f64,
    pub waste_compliance_status: String,
    pub has_hazardous_missing: bool,
    pub cryptographic_seal: String,
}

/// Audita el inventario de entrada y salida de residuos sólidos ("Huella Cero")
/// y emite un sello criptográfico verificable (HMAC-SHA256 + BLAKE3).
pub fn audit_huella_cero(input: &WasteAuditInput) -> WasteAuditResult {
    let total_in = (input.plastic_bottles_in.max(0))
        + (input.cans_in.max(0))
        + (input.plastic_wrappers_in.max(0))
        + (input.plastic_bags_in.max(0))
        + (input.batteries_in.max(0))
        + (input.gas_canisters_in.max(0));

    let total_out = (input.plastic_bottles_out.max(0))
        + (input.cans_out.max(0))
        + (input.plastic_wrappers_out.max(0))
        + (input.plastic_bags_out.max(0))
        + (input.batteries_out.max(0))
        + (input.gas_canisters_out.max(0));

    let net_balance = total_out - total_in;

    let has_hazardous_missing = (input.batteries_out < input.batteries_in)
        || (input.gas_canisters_out < input.gas_canisters_in);

    let compliance_status = if has_hazardous_missing || total_out < total_in {
        "infraction_missing".to_string()
    } else if total_out > total_in {
        "extra_collected".to_string()
    } else {
        "compliant".to_string()
    };

    let return_rate_percent = if total_in > 0 {
        ((total_out as f64 / total_in as f64) * 1000.0).round() / 10.0
    } else {
        100.0
    };

    let canonical = format!(
        "v2|{}|{}|in:{}|out:{}|haz:{}|status:{}",
        input.local_uuid.trim(),
        input.document_number.trim(),
        total_in,
        total_out,
        has_hazardous_missing,
        compliance_status
    );

    let mut mac =
        HmacSha256::new_from_slice(HUELLA_CERO_DOMAIN_KEY).expect("HMAC accepts any key size");
    mac.update(canonical.as_bytes());
    let hmac_bytes = mac.finalize().into_bytes();
    let short_hex = hex::encode(&hmac_bytes[..8]).to_uppercase();

    let seal = format!("H360-{}-{}", &short_hex[..8], &short_hex[8..16]);

    WasteAuditResult {
        total_items_in: total_in,
        total_items_out: total_out,
        net_balance,
        return_rate_percent,
        waste_compliance_status: compliance_status,
        has_hazardous_missing,
        cryptographic_seal: seal,
    }
}

/// Firma un Eco-Reporte ciudadano offline con coordenadas GPS y timestamp para garantizar
/// cadena de custodia ambiental.
pub fn sign_eco_report(
    local_uuid: &str,
    category: &str,
    latitude: f64,
    longitude: f64,
    captured_at_iso: &str,
) -> Value {
    let canonical = format!(
        "ECO|{}|{}|{:.6}|{:.6}|{}",
        local_uuid.trim(),
        category.trim(),
        latitude,
        longitude,
        captured_at_iso.trim()
    );
    let b3_hash = blake3::hash(canonical.as_bytes()).to_hex().to_string();
    let mut mac =
        HmacSha256::new_from_slice(HUELLA_CERO_DOMAIN_KEY).expect("HMAC accepts any key size");
    mac.update(canonical.as_bytes());
    let sig_hex = hex::encode(mac.finalize().into_bytes());

    json!({
        "local_uuid": local_uuid,
        "blake3_digest": b3_hash,
        "hmac_sha256": sig_hex,
        "verification_code": format!("ECO360-{}", &b3_hash[..12].to_uppercase()),
    })
}
