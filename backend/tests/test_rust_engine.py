from django.test import TestCase
from apps.common.rust_bridge import (
    is_rust_engine_available,
    rust_engine_version,
    rust_haversine_km,
    rust_estimated_duration_minutes,
    rust_simplify_points_rdp,
    rust_parse_gpx_content,
    rust_audit_huella_cero,
    rust_sign_eco_report,
)
from apps.tourism.utils.gpx_parser import parse_gpx_content, simplify_points_rdp


class RustEngineIntegrationTests(TestCase):
    def test_rust_shared_library_loaded(self):
        self.assertTrue(is_rust_engine_available())
        self.assertIn("huaguruncho_core", rust_engine_version())

    def test_rust_geospatial_and_gpx_parser(self):
        dist = rust_haversine_km(-10.55159, -75.930389, -10.52180, -75.91890)
        self.assertIsNotNone(dist)
        self.assertGreater(dist, 3.0)

        mins = rust_estimated_duration_minutes(10.0, 500.0, 100.0, 4600.0)
        self.assertIsNotNone(mins)
        self.assertGreaterEqual(mins, 200)

        pts = [[-75.93 + i * 0.0001, -10.55 + i * 0.0001, 4100.0] for i in range(400)]
        simplified = simplify_points_rdp(pts, 0.00008)
        self.assertEqual(len(simplified), 2)

        sample_gpx = """<?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Wikiloc">
          <trk>
            <name>Nevado Huaguruncho Sur</name>
            <desc>Ascenso glaciar</desc>
            <trkseg>
              <trkpt lat="-10.551590" lon="-75.930389"><ele>4100</ele></trkpt>
              <trkpt lat="-10.541590" lon="-75.920389"><ele>4450</ele></trkpt>
              <trkpt lat="-10.531590" lon="-75.910389"><ele>4820</ele></trkpt>
            </trkseg>
          </trk>
          <wpt lat="-10.541590" lon="-75.920389">
            <ele>4450</ele>
            <name>Campamento Base</name>
          </wpt>
        </gpx>
        """
        res = parse_gpx_content(sample_gpx)
        self.assertTrue(res["success"])
        self.assertEqual(res.get("engine"), "rust_huaguruncho_core")
        self.assertEqual(res["track_name"], "Nevado Huaguruncho Sur")
        self.assertEqual(res["point_count"], 3)
        self.assertEqual(len(res["waypoints"]), 1)

    def test_rust_huella_cero_and_eco_report_seal(self):
        audit = rust_audit_huella_cero({
            "local_uuid": "chk-001",
            "document_number": "45678912",
            "plastic_bottles_in": 2,
            "cans_in": 1,
            "plastic_wrappers_in": 3,
            "plastic_bags_in": 1,
            "batteries_in": 2,
            "gas_canisters_in": 1,
            "plastic_bottles_out": 2,
            "cans_out": 1,
            "plastic_wrappers_out": 3,
            "plastic_bags_out": 1,
            "batteries_out": 2,
            "gas_canisters_out": 1,
        })
        self.assertIsNotNone(audit)
        self.assertEqual(audit["waste_compliance_status"], "compliant")
        self.assertTrue(audit["cryptographic_seal"].startswith("H360-"))

        sig = rust_sign_eco_report(
            "rep-001",
            "RESIDUOS_SOLIDOS",
            -10.5512,
            -75.9301,
            "2026-10-18T15:00:00Z",
        )
        self.assertIsNotNone(sig)
        self.assertTrue(sig["verification_code"].startswith("ECO360-"))
