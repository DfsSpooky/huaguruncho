"""
Puente nativo FFI hacia `libhuaguruncho_core` (Rust).
Permite a Django ejecutar el motor geoespacial GPX, compresión de paquetes offline,
lectura rápida de cabeceras EXIF y auditoría criptográfica 'Huella Cero' a velocidad nativa
sin necesidad de bloquear el GIL ni cargar imágenes completas en memoria.
"""

import ctypes
import json
import logging
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

logger = logging.getLogger(__name__)

_LIB_INSTANCE: Optional[ctypes.CDLL] = None
_LIB_LOAD_ATTEMPTED: bool = False


def _candidate_library_paths() -> List[Path]:
    # Directorio raíz del monorepo: backend/apps/common/rust_bridge.py -> ../../../
    repo_root = Path(__file__).resolve().parents[3]
    rust_target = repo_root / "rust" / "target"

    if sys.platform == "darwin":
        names = ["libhuaguruncho_core.dylib"]
    elif os.name == "nt":
        names = ["huaguruncho_core.dll", "libhuaguruncho_core.dll"]
    else:
        names = ["libhuaguruncho_core.so"]

    candidates: List[Path] = []
    env_path = os.environ.get("HUAGURUNCHO_RUST_LIB")
    if env_path:
        candidates.append(Path(env_path))

    for profile in ("release", "debug"):
        for name in names:
            candidates.append(rust_target / profile / name)

    for name in names:
        candidates.append(Path("/app") / name)

    return candidates


def get_rust_lib() -> Optional[ctypes.CDLL]:
    global _LIB_INSTANCE, _LIB_LOAD_ATTEMPTED
    if _LIB_INSTANCE is not None:
        return _LIB_INSTANCE
    if _LIB_LOAD_ATTEMPTED:
        return None

    _LIB_LOAD_ATTEMPTED = True
    for candidate in _candidate_library_paths():
        if candidate.exists():
            try:
                lib = ctypes.CDLL(str(candidate))
                _configure_signatures(lib)
                _LIB_INSTANCE = lib
                logger.info("Motor Rust cargado exitosamente desde %s", candidate)
                return _LIB_INSTANCE
            except Exception as exc:
                logger.warning("No se pudo cargar %s: %s", candidate, exc)

    return None


def _configure_signatures(lib: ctypes.CDLL) -> None:
    lib.h360_version.argtypes = []
    lib.h360_version.restype = ctypes.c_char_p

    lib.h360_free_string.argtypes = [ctypes.c_void_p]
    lib.h360_free_string.restype = None

    lib.h360_haversine_km.argtypes = [
        ctypes.c_double,
        ctypes.c_double,
        ctypes.c_double,
        ctypes.c_double,
    ]
    lib.h360_haversine_km.restype = ctypes.c_double

    lib.h360_haversine_meters.argtypes = [
        ctypes.c_double,
        ctypes.c_double,
        ctypes.c_double,
        ctypes.c_double,
    ]
    lib.h360_haversine_meters.restype = ctypes.c_double

    lib.h360_estimated_duration_minutes.argtypes = [
        ctypes.c_double,
        ctypes.c_double,
        ctypes.c_double,
        ctypes.c_double,
    ]
    lib.h360_estimated_duration_minutes.restype = ctypes.c_int32

    for fn_name in (
        "h360_parse_gpx_json",
        "h360_evaluate_telemetry_json",
        "h360_extract_exif_file_json",
        "h360_build_offline_zip_json",
        "h360_compute_file_hashes_json",
        "h360_audit_huella_cero_json",
    ):
        fn = getattr(lib, fn_name)
        fn.argtypes = [ctypes.c_char_p]
        fn.restype = ctypes.c_void_p

    lib.h360_simplify_rdp_json.argtypes = [ctypes.c_char_p, ctypes.c_double]
    lib.h360_simplify_rdp_json.restype = ctypes.c_void_p

    lib.h360_optimize_evidence_image_json.argtypes = [
        ctypes.c_char_p,
        ctypes.c_char_p,
        ctypes.c_uint32,
        ctypes.c_uint32,
    ]
    lib.h360_optimize_evidence_image_json.restype = ctypes.c_void_p

    lib.h360_sign_eco_report_json.argtypes = [
        ctypes.c_char_p,
        ctypes.c_char_p,
        ctypes.c_double,
        ctypes.c_double,
        ctypes.c_char_p,
    ]
    lib.h360_sign_eco_report_json.restype = ctypes.c_void_p


def _consume_rust_json(lib: ctypes.CDLL, ptr: Optional[int]) -> Any:
    if not ptr:
        return None
    try:
        raw_bytes = ctypes.cast(ptr, ctypes.c_char_p).value
        if not raw_bytes:
            return None
        return json.loads(raw_bytes.decode("utf-8"))
    finally:
        lib.h360_free_string(ctypes.c_void_p(ptr))


def is_rust_engine_available() -> bool:
    return get_rust_lib() is not None


def rust_engine_version() -> str:
    lib = get_rust_lib()
    if not lib:
        return "python-fallback"
    v = lib.h360_version()
    return v.decode("utf-8") if v else "huaguruncho_core"


def rust_haversine_km(lat1: float, lon1: float, lat2: float, lon2: float) -> Optional[float]:
    lib = get_rust_lib()
    if not lib:
        return None
    return float(lib.h360_haversine_km(lat1, lon1, lat2, lon2))


def rust_estimated_duration_minutes(
    distance_km: float,
    elevation_gain_m: float,
    elevation_loss_m: float = 0.0,
    max_altitude_m: float = 0.0,
) -> Optional[int]:
    lib = get_rust_lib()
    if not lib:
        return None
    return int(
        lib.h360_estimated_duration_minutes(
            float(distance_km),
            float(elevation_gain_m),
            float(elevation_loss_m),
            float(max_altitude_m),
        )
    )


def rust_simplify_points_rdp(
    points: List[List[float]], epsilon: float = 0.00008
) -> Optional[List[List[float]]]:
    lib = get_rust_lib()
    if not lib:
        return None
    payload = json.dumps(points).encode("utf-8")
    ptr = lib.h360_simplify_rdp_json(payload, float(epsilon))
    return _consume_rust_json(lib, ptr)


def rust_parse_gpx_content(gpx_text: str) -> Optional[Dict[str, Any]]:
    lib = get_rust_lib()
    if not lib:
        return None
    ptr = lib.h360_parse_gpx_json(gpx_text.encode("utf-8"))
    return _consume_rust_json(lib, ptr)


def rust_extract_exif_file(file_path: str) -> Optional[Dict[str, Any]]:
    lib = get_rust_lib()
    if not lib:
        return None
    ptr = lib.h360_extract_exif_file_json(str(file_path).encode("utf-8"))
    return _consume_rust_json(lib, ptr)


def rust_build_offline_zip(
    output_zip_path: str,
    manifest_json: str,
    readme_text: str,
    track_geojson: Optional[str],
    panoramas: List[Dict[str, str]],
) -> Optional[Dict[str, Any]]:
    lib = get_rust_lib()
    if not lib:
        return None
    req = {
        "output_zip_path": str(output_zip_path),
        "manifest_json": manifest_json,
        "readme_text": readme_text,
        "track_geojson": track_geojson,
        "panoramas": panoramas,
    }
    ptr = lib.h360_build_offline_zip_json(json.dumps(req).encode("utf-8"))
    return _consume_rust_json(lib, ptr)


def rust_compute_file_hashes(file_path: str) -> Optional[Dict[str, Any]]:
    lib = get_rust_lib()
    if not lib:
        return None
    ptr = lib.h360_compute_file_hashes_json(str(file_path).encode("utf-8"))
    return _consume_rust_json(lib, ptr)


def rust_audit_huella_cero(payload: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    lib = get_rust_lib()
    if not lib:
        return None
    req = {
        "local_uuid": str(payload.get("local_uuid", "")),
        "document_number": str(payload.get("document_number", "")),
        "plastic_bottles_in": int(payload.get("plastic_bottles_in", 0) or 0),
        "cans_in": int(payload.get("cans_in", 0) or 0),
        "plastic_wrappers_in": int(payload.get("plastic_wrappers_in", 0) or 0),
        "plastic_bags_in": int(payload.get("plastic_bags_in", 0) or 0),
        "batteries_in": int(payload.get("batteries_in", 0) or 0),
        "gas_canisters_in": int(payload.get("gas_canisters_in", 0) or 0),
        "plastic_bottles_out": int(payload.get("plastic_bottles_out", 0) or 0),
        "cans_out": int(payload.get("cans_out", 0) or 0),
        "plastic_wrappers_out": int(payload.get("plastic_wrappers_out", 0) or 0),
        "plastic_bags_out": int(payload.get("plastic_bags_out", 0) or 0),
        "batteries_out": int(payload.get("batteries_out", 0) or 0),
        "gas_canisters_out": int(payload.get("gas_canisters_out", 0) or 0),
    }
    ptr = lib.h360_audit_huella_cero_json(json.dumps(req).encode("utf-8"))
    return _consume_rust_json(lib, ptr)


def rust_sign_eco_report(
    local_uuid: str,
    category: str,
    latitude: float,
    longitude: float,
    captured_at_iso: str,
) -> Optional[Dict[str, Any]]:
    lib = get_rust_lib()
    if not lib:
        return None
    ptr = lib.h360_sign_eco_report_json(
        str(local_uuid).encode("utf-8"),
        str(category).encode("utf-8"),
        float(latitude),
        float(longitude),
        str(captured_at_iso).encode("utf-8"),
    )
    return _consume_rust_json(lib, ptr)


def rust_evaluate_telemetry(
    current_lat: float,
    current_lon: float,
    current_alt_m: float,
    max_alt_m: float,
    total_distance_km: float,
    trail_lat_lon: List[List[float]],
) -> Optional[Dict[str, Any]]:
    lib = get_rust_lib()
    if not lib:
        return None
    req = {
        "current_lat": float(current_lat),
        "current_lon": float(current_lon),
        "current_alt_m": float(current_alt_m),
        "max_alt_m": float(max_alt_m),
        "total_distance_km": float(total_distance_km),
        "trail_lat_lon": trail_lat_lon,
    }
    ptr = lib.h360_evaluate_telemetry_json(json.dumps(req).encode("utf-8"))
    return _consume_rust_json(lib, ptr)
