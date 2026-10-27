use serde::{Deserialize, Serialize};
use serde_json::{json, Value};
use sha2::{Digest, Sha256};
use std::fs::File;
use std::io::{BufReader, Read, Write};
use std::path::Path;
use zip::write::SimpleFileOptions;
use zip::{CompressionMethod, ZipWriter};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PanoramaEntryInput {
    pub file_path: String,
    pub arcname: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OfflineZipRequest {
    pub output_zip_path: String,
    pub manifest_json: String,
    pub readme_text: String,
    pub track_geojson: Option<String>,
    pub panoramas: Vec<PanoramaEntryInput>,
}

/// Calcula hashes SHA-256 y BLAKE3 de un slice de bytes en memoria.
pub fn compute_bytes_hashes(data: &[u8]) -> (String, String) {
    let mut sha = Sha256::new();
    sha.update(data);
    let sha256_hex = hex::encode(sha.finalize());
    let blake3_hex = blake3::hash(data).to_hex().to_string();
    (sha256_hex, blake3_hex)
}

/// Calcula hashes SHA-256 y BLAKE3 haciendo streaming de un archivo en disco.
pub fn compute_file_hashes(file_path: &str) -> Value {
    let path = Path::new(file_path);
    if !path.exists() {
        return json!({
            "success": false,
            "error": "Archivo no encontrado"
        });
    }

    let Ok(file) = File::open(path) else {
        return json!({
            "success": false,
            "error": "No se pudo abrir el archivo"
        });
    };

    let mut reader = BufReader::with_capacity(64 * 1024, file);
    let mut sha = Sha256::new();
    let mut b3 = blake3::Hasher::new();
    let mut buf = [0u8; 64 * 1024];
    let mut total_bytes: u64 = 0;

    loop {
        match reader.read(&mut buf) {
            Ok(0) => break,
            Ok(n) => {
                sha.update(&buf[..n]);
                b3.update(&buf[..n]);
                total_bytes += n as u64;
            }
            Err(e) => {
                return json!({
                    "success": false,
                    "error": format!("Error leyendo archivo: {}", e)
                });
            }
        }
    }

    json!({
        "success": true,
        "size_bytes": total_bytes,
        "sha256": hex::encode(sha.finalize()),
        "blake3": b3.finalize().to_hex().to_string(),
    })
}

/// Construye un archivo ZIP de paquete offline para alta montaña transmitiendo los panoramas
/// directamente desde disco y generando sumas criptográficas SHA-256 y BLAKE3.
pub fn build_offline_zip(req: &OfflineZipRequest) -> Value {
    let manifest_bytes = req.manifest_json.as_bytes();
    let (manifest_sha256, manifest_blake3) = compute_bytes_hashes(manifest_bytes);

    let out_path = Path::new(&req.output_zip_path);
    if let Some(parent) = out_path.parent() {
        let _ = std::fs::create_dir_all(parent);
    }

    let temp_path = out_path.with_extension("zip.tmp");
    let file = match File::create(&temp_path) {
        Ok(f) => f,
        Err(e) => {
            return json!({
                "success": false,
                "error": format!("No se pudo crear el archivo temporal ZIP: {}", e)
            })
        }
    };

    let mut zip = ZipWriter::new(file);
    let deflate_opts = SimpleFileOptions::default()
        .compression_method(CompressionMethod::Deflated)
        .unix_permissions(0o644);
    let store_opts = SimpleFileOptions::default()
        .compression_method(CompressionMethod::Stored)
        .unix_permissions(0o644);

    // 1. manifest.json
    if let Err(e) = zip.start_file("manifest.json", deflate_opts) {
        return json!({ "success": false, "error": format!("Error creando manifest.json: {}", e) });
    }
    if let Err(e) = zip.write_all(manifest_bytes) {
        return json!({ "success": false, "error": format!("Error escribiendo manifest.json: {}", e) });
    }

    // 2. README_OFFLINE.txt
    if let Err(e) = zip.start_file("README_OFFLINE.txt", deflate_opts) {
        return json!({ "success": false, "error": format!("Error creando README_OFFLINE.txt: {}", e) });
    }
    if let Err(e) = zip.write_all(req.readme_text.as_bytes()) {
        return json!({ "success": false, "error": format!("Error escribiendo README_OFFLINE.txt: {}", e) });
    }

    // 3. checksum.sha256 y checksum.blake3
    let sha_line = format!("{}  manifest.json\n", manifest_sha256);
    if zip.start_file("checksum.sha256", deflate_opts).is_ok() {
        let _ = zip.write_all(sha_line.as_bytes());
    }

    let b3_line = format!("{}  manifest.json\n", manifest_blake3);
    if zip.start_file("checksum.blake3", deflate_opts).is_ok() {
        let _ = zip.write_all(b3_line.as_bytes());
    }

    // 4. track.geojson si existe
    if let Some(ref geojson) = req.track_geojson {
        if !geojson.is_empty() && zip.start_file("track.geojson", deflate_opts).is_ok() {
            let _ = zip.write_all(geojson.as_bytes());
        }
    }

    // 5. Imágenes panorámicas 360 (transmitidas por bloques de 64KB, sin re-comprimir JPG ya comprimido)
    let mut packed_panoramas = 0usize;
    let mut copy_buf = [0u8; 64 * 1024];

    for p in &req.panoramas {
        let p_path = Path::new(&p.file_path);
        if p_path.exists() {
            if let Ok(mut src_file) = File::open(p_path) {
                if zip.start_file(&p.arcname, store_opts).is_ok() {
                    loop {
                        match src_file.read(&mut copy_buf) {
                            Ok(0) => break,
                            Ok(n) => {
                                if zip.write_all(&copy_buf[..n]).is_err() {
                                    break;
                                }
                            }
                            Err(_) => break,
                        }
                    }
                    packed_panoramas += 1;
                }
            }
        }
    }

    if let Err(e) = zip.finish() {
        return json!({
            "success": false,
            "error": format!("Error cerrando archivo ZIP: {}", e)
        });
    }

    if let Err(e) = std::fs::rename(&temp_path, out_path) {
        return json!({
            "success": false,
            "error": format!("Error renombrando paquete ZIP final: {}", e)
        });
    }

    let zip_size = std::fs::metadata(out_path).map(|m| m.len()).unwrap_or(0);

    json!({
        "success": true,
        "engine": "rust_huaguruncho_core",
        "zip_path": req.output_zip_path,
        "zip_size_bytes": zip_size,
        "manifest_sha256": manifest_sha256,
        "manifest_blake3": manifest_blake3,
        "panoramas_packed": packed_panoramas,
    })
}
