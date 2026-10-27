use exif::{In, Reader, Tag, Value as ExifValue};
use image::imageops::FilterType;
use image::ImageReader;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use std::fs::File;
use std::io::{BufReader, BufWriter, Cursor};
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PanoramaMetadata {
    pub latitude: Option<f64>,
    pub longitude: Option<f64>,
    pub altitude_masl: Option<i32>,
    pub heading: Option<f64>,
}

fn rational_to_f64(r: &exif::Rational) -> Option<f64> {
    if r.denom == 0 {
        None
    } else {
        Some(r.num as f64 / r.denom as f64)
    }
}

fn dms_to_decimal(val: &ExifValue, ref_str: &str) -> Option<f64> {
    if let ExifValue::Rational(ref list) = *val {
        if list.len() >= 3 {
            let deg = rational_to_f64(&list[0])?;
            let min = rational_to_f64(&list[1])?;
            let sec = rational_to_f64(&list[2])?;
            let mut dec = deg + (min / 60.0) + (sec / 3600.0);
            let r = ref_str.trim().to_uppercase();
            if r == "S" || r == "W" {
                dec = -dec;
            }
            let factor = 1_000_000.0;
            return Some((dec * factor).round() / factor);
        }
    }
    None
}

fn parse_exif_from_reader<R: std::io::BufRead + std::io::Seek>(reader: &mut R) -> PanoramaMetadata {
    let mut meta = PanoramaMetadata {
        latitude: None,
        longitude: None,
        altitude_masl: None,
        heading: None,
    };

    let exif_reader = Reader::new();
    let Ok(exif_data) = exif_reader.read_from_container(reader) else {
        return meta;
    };

    let lat_ref = exif_data
        .get_field(Tag::GPSLatitudeRef, In::PRIMARY)
        .map(|f| f.display_value().to_string())
        .unwrap_or_default();

    let lon_ref = exif_data
        .get_field(Tag::GPSLongitudeRef, In::PRIMARY)
        .map(|f| f.display_value().to_string())
        .unwrap_or_default();

    if let Some(lat_field) = exif_data.get_field(Tag::GPSLatitude, In::PRIMARY) {
        if !lat_ref.is_empty() {
            meta.latitude = dms_to_decimal(&lat_field.value, &lat_ref);
        }
    }

    if let Some(lon_field) = exif_data.get_field(Tag::GPSLongitude, In::PRIMARY) {
        if !lon_ref.is_empty() {
            meta.longitude = dms_to_decimal(&lon_field.value, &lon_ref);
        }
    }

    if let Some(alt_field) = exif_data.get_field(Tag::GPSAltitude, In::PRIMARY) {
        if let ExifValue::Rational(ref list) = alt_field.value {
            if let Some(first) = list.first() {
                if let Some(v) = rational_to_f64(first) {
                    meta.altitude_masl = Some(v as i32);
                }
            }
        }
    }

    if let Some(dir_field) = exif_data.get_field(Tag::GPSImgDirection, In::PRIMARY) {
        if let ExifValue::Rational(ref list) = dir_field.value {
            if let Some(first) = list.first() {
                if let Some(v) = rational_to_f64(first) {
                    meta.heading = Some((v * 10.0).round() / 10.0);
                }
            }
        }
    }

    meta
}

/// Extrae metadatos EXIF GPS directamente de la cabecera del archivo sin decodificar los píxeles.
pub fn extract_panorama_metadata_from_file(path: &str) -> Value {
    let Ok(file) = File::open(path) else {
        return json!({
            "latitude": null,
            "longitude": null,
            "altitude_masl": null,
            "heading": null,
        });
    };
    let mut buf_reader = BufReader::new(file);
    let meta = parse_exif_from_reader(&mut buf_reader);
    json!({
        "latitude": meta.latitude,
        "longitude": meta.longitude,
        "altitude_masl": meta.altitude_masl,
        "heading": meta.heading,
    })
}

/// Extrae metadatos EXIF GPS desde un slice de bytes en memoria.
pub fn extract_panorama_metadata_from_bytes(bytes: &[u8]) -> Value {
    let mut cursor = Cursor::new(bytes);
    let meta = parse_exif_from_reader(&mut cursor);
    json!({
        "latitude": meta.latitude,
        "longitude": meta.longitude,
        "altitude_masl": meta.altitude_masl,
        "heading": meta.heading,
    })
}

/// Optimiza y redimensiona una fotografía de evidencia de Eco-Reporte para sincronización
/// rápida en redes rurales de baja cobertura (3G/Edge en Huachón).
pub fn optimize_evidence_image(
    input_path: &str,
    output_path: &str,
    max_dimension: u32,
    jpeg_quality: u8,
) -> Value {
    let in_path = Path::new(input_path);
    if !in_path.exists() {
        return json!({
            "success": false,
            "error": "Archivo de entrada no encontrado"
        });
    }

    let original_size = std::fs::metadata(in_path).map(|m| m.len()).unwrap_or(0);

    let reader = match ImageReader::open(in_path) {
        Ok(r) => match r.with_guessed_format() {
            Ok(rf) => rf,
            Err(e) => {
                return json!({
                    "success": false,
                    "error": format!("Error detectando formato de imagen: {}", e)
                })
            }
        },
        Err(e) => {
            return json!({
                "success": false,
                "error": format!("Error abriendo imagen: {}", e)
            })
        }
    };

    let img = match reader.decode() {
        Ok(i) => i,
        Err(e) => {
            return json!({
                "success": false,
                "error": format!("Error decodificando imagen: {}", e)
            })
        }
    };

    let width = img.width();
    let height = img.height();
    let max_dim = max_dimension.max(320);

    let processed = if width > max_dim || height > max_dim {
        img.resize(max_dim, max_dim, FilterType::Lanczos3)
    } else {
        img
    };

    let out_file = match File::create(output_path) {
        Ok(f) => f,
        Err(e) => {
            return json!({
                "success": false,
                "error": format!("Error creando archivo de salida: {}", e)
            })
        }
    };

    let mut writer = BufWriter::new(out_file);
    let quality = jpeg_quality.clamp(40, 95);
    let mut encoder = image::codecs::jpeg::JpegEncoder::new_with_quality(&mut writer, quality);

    if let Err(e) = encoder.encode_image(&processed) {
        return json!({
            "success": false,
            "error": format!("Error codificando JPEG optimizado: {}", e)
        });
    }
    drop(encoder);

    let optimized_size = std::fs::metadata(output_path).map(|m| m.len()).unwrap_or(0);

    json!({
        "success": true,
        "original_bytes": original_size,
        "optimized_bytes": optimized_size,
        "width": processed.width(),
        "height": processed.height(),
        "output_path": output_path,
    })
}
