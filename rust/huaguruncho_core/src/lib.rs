pub mod crypto;
pub mod ffi;
pub mod geo;
pub mod media;
pub mod packaging;

#[cfg(test)]
mod tests {
    use super::crypto::{audit_huella_cero, sign_eco_report, WasteAuditInput};
    use super::geo::{
        calculate_difficulty_level, calculate_estimated_duration_minutes, evaluate_live_telemetry,
        haversine_distance_km, parse_gpx_content, simplify_points_rdp,
    };
    use super::packaging::compute_bytes_hashes;

    #[test]
    fn test_haversine_and_naismith() {
        let d = haversine_distance_km(-10.55159, -75.930389, -10.52180, -75.91890);
        assert!(d > 3.0 && d < 4.0);

        let mins = calculate_estimated_duration_minutes(12.0, 650.0, 120.0, 4650.0);
        assert!(mins >= 300);

        assert_eq!(calculate_difficulty_level(5.0, 200.0, 3500.0), "FACIL");
        assert_eq!(calculate_difficulty_level(18.0, 1100.0, 4800.0), "EXPERTO");
    }

    #[test]
    fn test_iterative_rdp_simplification() {
        let mut pts = Vec::new();
        for i in 0..500 {
            let x = -75.93 + (i as f64) * 0.0001;
            let y = -10.55 + (i as f64) * 0.0001;
            pts.push([x, y, 4200.0]);
        }
        let simplified = simplify_points_rdp(&pts, 0.00008);
        assert_eq!(simplified.len(), 2);
    }

    #[test]
    fn test_parse_gpx_xml_streaming() {
        let gpx = r#"<?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1" creator="Huaguruncho360">
          <trk>
            <name>Ascenso Laguna Huaguruncho</name>
            <desc>Ruta glaciar oficial</desc>
            <trkseg>
              <trkpt lat="-10.551590" lon="-75.930389"><ele>4120.0</ele></trkpt>
              <trkpt lat="-10.548910" lon="-75.954120"><ele>4350.0</ele></trkpt>
              <trkpt lat="-10.539800" lon="-75.942000"><ele>4620.0</ele></trkpt>
            </trkseg>
          </trk>
          <wpt lat="-10.548910" lon="-75.954120">
            <ele>4350.0</ele>
            <name>Mirador Glaciar</name>
            <desc>Vista panorámica</desc>
          </wpt>
        </gpx>"#;

        let res = parse_gpx_content(gpx);
        assert_eq!(res["success"], true);
        assert_eq!(res["track_name"], "Ascenso Laguna Huaguruncho");
        assert_eq!(res["point_count"], 3);
        assert_eq!(res["min_altitude_m"], 4120.0);
        assert_eq!(res["max_altitude_m"], 4620.0);
        assert_eq!(res["waypoints"].as_array().unwrap().len(), 1);
    }

    #[test]
    fn test_live_telemetry_evaluation() {
        let trail = vec![
            [-10.551590, -75.930389],
            [-10.548910, -75.954120],
            [-10.539800, -75.942000],
        ];
        let tel = evaluate_live_telemetry(-10.548910, -75.954120, 4350.0, 4796.0, 10.0, &trail);
        assert!(!tel.is_off_trail_alert);
        assert_eq!(tel.nearest_point_index, 1);
        assert!((tel.distance_covered_km - 5.0).abs() < 0.01);
    }

    #[test]
    fn test_huella_cero_cryptographic_audit() {
        let audit_ok = audit_huella_cero(&WasteAuditInput {
            local_uuid: "uuid-test-001".to_string(),
            document_number: "71234567".to_string(),
            plastic_bottles_in: 3,
            cans_in: 2,
            plastic_wrappers_in: 4,
            plastic_bags_in: 1,
            batteries_in: 2,
            gas_canisters_in: 1,
            plastic_bottles_out: 4,
            cans_out: 2,
            plastic_wrappers_out: 4,
            plastic_bags_out: 1,
            batteries_out: 2,
            gas_canisters_out: 1,
        });
        assert_eq!(audit_ok.total_items_in, 13);
        assert_eq!(audit_ok.total_items_out, 14);
        assert_eq!(audit_ok.waste_compliance_status, "extra_collected");
        assert!(audit_ok.cryptographic_seal.starts_with("H360-"));

        let sig = sign_eco_report(
            "eco-123",
            "RESIDUOS_SOLIDOS",
            -10.5412,
            -75.9311,
            "2026-10-18T12:00:00Z",
        );
        assert!(sig["verification_code"]
            .as_str()
            .unwrap()
            .starts_with("ECO360-"));

        let (sha, b3) = compute_bytes_hashes(b"Huaguruncho 360");
        assert_eq!(sha.len(), 64);
        assert_eq!(b3.len(), 64);
    }
}
