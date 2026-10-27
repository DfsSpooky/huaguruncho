use quick_xml::events::Event;
use quick_xml::reader::Reader;
use serde::{Deserialize, Serialize};
use serde_json::{json, Value};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ElevationPoint {
    pub distance_km: f64,
    pub altitude_m: f64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WaypointData {
    pub name: String,
    pub latitude: f64,
    pub longitude: f64,
    pub altitude_m: f64,
    pub description: String,
    pub symbol: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LiveTelemetryResult {
    pub distance_to_trail_m: f64,
    pub is_off_trail_alert: bool,
    pub nearest_point_index: usize,
    pub distance_covered_km: f64,
    pub distance_remaining_km: f64,
    pub progress_percent: f64,
    pub estimated_remaining_minutes: i32,
}

#[inline]
pub fn haversine_distance_km(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    const R: f64 = 6371.0;
    let dlat = (lat2 - lat1).to_radians();
    let dlon = (lon2 - lon1).to_radians();
    let a = (dlat / 2.0).sin().powi(2)
        + lat1.to_radians().cos() * lat2.to_radians().cos() * (dlon / 2.0).sin().powi(2);
    let c = 2.0 * a.sqrt().atan2((1.0 - a).max(0.0).sqrt());
    R * c
}

#[inline]
pub fn haversine_distance_meters(lat1: f64, lon1: f64, lat2: f64, lon2: f64) -> f64 {
    haversine_distance_km(lat1, lon1, lat2, lon2) * 1000.0
}

#[inline]
pub fn calculate_estimated_duration_minutes(
    distance_km: f64,
    elevation_gain_m: f64,
    elevation_loss_m: f64,
    max_altitude_m: f64,
) -> i32 {
    if distance_km <= 0.0 {
        return 30;
    }

    let flat_minutes = (distance_km / 4.0) * 60.0;
    let ascent_minutes = (elevation_gain_m / 100.0) * 10.0;
    let descent_minutes = (elevation_loss_m / 100.0) * 4.0;

    let altitude_factor = if max_altitude_m >= 4500.0 {
        1.25
    } else if max_altitude_m >= 3800.0 {
        1.15
    } else {
        1.0
    };

    let total = (flat_minutes + ascent_minutes + descent_minutes) * altitude_factor;
    (total.round() as i32).max(15)
}

#[inline]
pub fn calculate_difficulty_level(
    distance_km: f64,
    elevation_gain_m: f64,
    max_altitude_m: f64,
) -> &'static str {
    if distance_km < 7.0 && elevation_gain_m < 350.0 && max_altitude_m < 3800.0 {
        "FACIL"
    } else if distance_km <= 14.0 && elevation_gain_m <= 750.0 && max_altitude_m < 4200.0 {
        "MODERADA"
    } else if distance_km <= 22.0 && elevation_gain_m <= 1300.0 && max_altitude_m < 4600.0 {
        "DIFICIL"
    } else {
        "EXPERTO"
    }
}

#[inline]
fn perpendicular_distance(pt: &[f64; 3], start: &[f64; 3], end: &[f64; 3]) -> f64 {
    let dx = end[0] - start[0];
    let dy = end[1] - start[1];
    if dx == 0.0 && dy == 0.0 {
        return ((pt[0] - start[0]).powi(2) + (pt[1] - start[1]).powi(2)).sqrt();
    }
    let num = (dy * pt[0] - dx * pt[1] + end[0] * start[1] - end[1] * start[0]).abs();
    let den = (dy * dy + dx * dx).sqrt();
    if den > 0.0 {
        num / den
    } else {
        0.0
    }
}

/// Simplificación Ramer-Douglas-Peucker iterativa (sin recursión en pila)
/// para evitar stack overflow con tracks masivos de Garmin/Wikiloc.
pub fn simplify_points_rdp(points: &[[f64; 3]], epsilon: f64) -> Vec<[f64; 3]> {
    let n = points.len();
    if n <= 2 {
        return points.to_vec();
    }

    let mut keep = vec![false; n];
    keep[0] = true;
    keep[n - 1] = true;

    let mut stack: Vec<(usize, usize)> = Vec::with_capacity(64);
    stack.push((0, n - 1));

    while let Some((start, end)) = stack.pop() {
        if end <= start + 1 {
            continue;
        }
        let mut dmax = 0.0;
        let mut index = start;

        for i in (start + 1)..end {
            let d = perpendicular_distance(&points[i], &points[start], &points[end]);
            if d > dmax {
                index = i;
                dmax = d;
            }
        }

        if dmax > epsilon {
            keep[index] = true;
            stack.push((start, index));
            stack.push((index, end));
        }
    }

    let mut result = Vec::with_capacity(n.min(512));
    for (i, pt) in points.iter().enumerate() {
        if keep[i] {
            result.push(*pt);
        }
    }
    result
}

fn sample_profile(profile: &[ElevationPoint], max_points: usize) -> Vec<ElevationPoint> {
    if profile.len() <= max_points || max_points == 0 {
        return profile.to_vec();
    }
    let step = profile.len() as f64 / max_points as f64;
    let mut sampled: Vec<ElevationPoint> = (0..max_points)
        .map(|i| profile[(i as f64 * step) as usize].clone())
        .collect();

    if let (Some(last_orig), Some(last_samp)) = (profile.last(), sampled.last()) {
        if (last_orig.distance_km - last_samp.distance_km).abs() > 1e-6
            || (last_orig.altitude_m - last_samp.altitude_m).abs() > 1e-6
        {
            sampled.push(last_orig.clone());
        }
    }
    sampled
}

#[inline]
fn round_to(val: f64, decimals: i32) -> f64 {
    let factor = 10_f64.powi(decimals);
    (val * factor).round() / factor
}

fn local_tag_name(raw: &[u8]) -> &[u8] {
    if let Some(pos) = raw.iter().rposition(|&b| b == b':') {
        &raw[pos + 1..]
    } else {
        raw
    }
}

/// Parsea un archivo GPX de forma ultra-rápida con streaming XML (quick-xml).
pub fn parse_gpx_content(gpx_text: &str) -> Value {
    let mut reader = Reader::from_str(gpx_text);
    reader.config_mut().trim_text(true);

    let mut buf = Vec::new();

    let mut track_name = String::new();
    let mut track_desc = String::new();

    let mut trk_points: Vec<[f64; 3]> = Vec::new();
    let mut trk_profile: Vec<ElevationPoint> = Vec::new();
    let mut trk_dist_km = 0.0;
    let mut trk_uphill = 0.0;
    let mut trk_downhill = 0.0;
    let mut trk_prev: Option<(f64, f64, f64)> = None;
    let mut trk_min_elev = 99999.0_f64;
    let mut trk_max_elev = -99999.0_f64;

    let mut rte_points: Vec<[f64; 3]> = Vec::new();
    let mut rte_profile: Vec<ElevationPoint> = Vec::new();
    let mut rte_dist_km = 0.0;
    let mut rte_uphill = 0.0;
    let mut rte_downhill = 0.0;
    let mut rte_prev: Option<(f64, f64, f64)> = None;
    let mut rte_min_elev = 99999.0_f64;
    let mut rte_max_elev = -99999.0_f64;

    let mut waypoints: Vec<WaypointData> = Vec::new();

    // Contexto de lectura XML
    #[derive(Clone, Copy, PartialEq, Eq)]
    enum Section {
        Root,
        Trk,
        TrkPt,
        Rte,
        RtePt,
        Wpt,
    }

    let mut section = Section::Root;
    let mut current_tag: Vec<u8> = Vec::new();

    let mut cur_lat: Option<f64> = None;
    let mut cur_lon: Option<f64> = None;
    let mut cur_ele: f64 = 0.0;
    let mut cur_name = String::new();
    let mut cur_desc = String::new();
    let mut cur_cmt = String::new();
    let mut cur_sym = String::new();

    let mut saw_gpx_root = false;

    loop {
        match reader.read_event_into(&mut buf) {
            Ok(Event::Start(e)) => {
                let tag = local_tag_name(e.name().as_ref()).to_vec();
                match tag.as_slice() {
                    b"gpx" => {
                        saw_gpx_root = true;
                    }
                    b"trk" => {
                        section = Section::Trk;
                    }
                    b"rte" => {
                        section = Section::Rte;
                    }
                    b"trkpt" | b"rtept" | b"wpt" => {
                        let mut lat = None;
                        let mut lon = None;
                        for attr in e.attributes().flatten() {
                            let k = local_tag_name(attr.key.as_ref());
                            if k == b"lat" {
                                if let Ok(s) = std::str::from_utf8(&attr.value) {
                                    lat = s.trim().parse::<f64>().ok();
                                }
                            } else if k == b"lon" {
                                if let Ok(s) = std::str::from_utf8(&attr.value) {
                                    lon = s.trim().parse::<f64>().ok();
                                }
                            }
                        }
                        if lat.is_none() || lon.is_none() {
                            return json!({
                                "success": false,
                                "error": "Formato GPX inválido: punto sin coordenadas lat/lon válidas"
                            });
                        }
                        cur_lat = lat;
                        cur_lon = lon;
                        cur_ele = 0.0;
                        cur_name.clear();
                        cur_desc.clear();
                        cur_cmt.clear();
                        cur_sym.clear();

                        section = match tag.as_slice() {
                            b"trkpt" => Section::TrkPt,
                            b"rtept" => Section::RtePt,
                            _ => Section::Wpt,
                        };
                    }
                    _ => {}
                }
                current_tag = tag;
            }
            Ok(Event::Empty(e)) => {
                let tag = local_tag_name(e.name().as_ref()).to_vec();
                if tag == b"gpx" {
                    saw_gpx_root = true;
                } else if tag == b"trkpt" || tag == b"rtept" || tag == b"wpt" {
                    let mut lat = None;
                    let mut lon = None;
                    for attr in e.attributes().flatten() {
                        let k = local_tag_name(attr.key.as_ref());
                        if k == b"lat" {
                            if let Ok(s) = std::str::from_utf8(&attr.value) {
                                lat = s.trim().parse::<f64>().ok();
                            }
                        } else if k == b"lon" {
                            if let Ok(s) = std::str::from_utf8(&attr.value) {
                                lon = s.trim().parse::<f64>().ok();
                            }
                        }
                    }
                    if let (Some(lt), Some(ln)) = (lat, lon) {
                        if tag == b"trkpt" {
                            if let Some((plat, plon, pele)) = trk_prev {
                                let d = haversine_distance_km(plat, plon, lt, ln);
                                trk_dist_km += d;
                                let diff = 0.0 - pele;
                                if diff > 0.0 {
                                    trk_uphill += diff;
                                } else {
                                    trk_downhill += diff.abs();
                                }
                            }
                            trk_min_elev = trk_min_elev.min(0.0);
                            trk_max_elev = trk_max_elev.max(0.0);
                            trk_points.push([ln, lt, 0.0]);
                            trk_profile.push(ElevationPoint {
                                distance_km: round_to(trk_dist_km, 3),
                                altitude_m: 0.0,
                            });
                            trk_prev = Some((lt, ln, 0.0));
                        } else if tag == b"rtept" {
                            if let Some((plat, plon, pele)) = rte_prev {
                                let d = haversine_distance_km(plat, plon, lt, ln);
                                rte_dist_km += d;
                                let diff = 0.0 - pele;
                                if diff > 0.0 {
                                    rte_uphill += diff;
                                } else {
                                    rte_downhill += diff.abs();
                                }
                            }
                            rte_min_elev = rte_min_elev.min(0.0);
                            rte_max_elev = rte_max_elev.max(0.0);
                            rte_points.push([ln, lt, 0.0]);
                            rte_profile.push(ElevationPoint {
                                distance_km: round_to(rte_dist_km, 3),
                                altitude_m: 0.0,
                            });
                            rte_prev = Some((lt, ln, 0.0));
                        } else {
                            waypoints.push(WaypointData {
                                name: "Punto de Control".to_string(),
                                latitude: lt,
                                longitude: ln,
                                altitude_m: 0.0,
                                description: String::new(),
                                symbol: String::new(),
                            });
                        }
                    } else {
                        return json!({
                            "success": false,
                            "error": "Formato GPX inválido: punto sin coordenadas lat/lon"
                        });
                    }
                }
            }
            Ok(Event::Text(e)) => {
                if let Ok(txt) = e.unescape() {
                    let s = txt.trim();
                    if !s.is_empty() {
                        match section {
                            Section::Root | Section::Trk | Section::Rte => {
                                if current_tag == b"name" && track_name.is_empty() {
                                    track_name = s.to_string();
                                } else if current_tag == b"desc" && track_desc.is_empty() {
                                    track_desc = s.to_string();
                                }
                            }
                            Section::TrkPt | Section::RtePt | Section::Wpt => {
                                match current_tag.as_slice() {
                                    b"ele" => {
                                        if let Ok(v) = s.parse::<f64>() {
                                            cur_ele = v;
                                        }
                                    }
                                    b"name" => cur_name = s.to_string(),
                                    b"desc" => cur_desc = s.to_string(),
                                    b"cmt" => cur_cmt = s.to_string(),
                                    b"sym" => cur_sym = s.to_string(),
                                    _ => {}
                                }
                            }
                        }
                    }
                }
            }
            Ok(Event::End(e)) => {
                let qname = e.name();
                let tag = local_tag_name(qname.as_ref());
                match tag {
                    b"trkpt" => {
                        if let (Some(lt), Some(ln)) = (cur_lat, cur_lon) {
                            let ele = cur_ele;
                            if let Some((plat, plon, pele)) = trk_prev {
                                let d = haversine_distance_km(plat, plon, lt, ln);
                                trk_dist_km += d;
                                let diff = ele - pele;
                                if diff > 0.0 {
                                    trk_uphill += diff;
                                } else {
                                    trk_downhill += diff.abs();
                                }
                            }
                            trk_min_elev = trk_min_elev.min(ele);
                            trk_max_elev = trk_max_elev.max(ele);
                            let rounded_ele = round_to(ele, 1);
                            trk_points.push([ln, lt, rounded_ele]);
                            trk_profile.push(ElevationPoint {
                                distance_km: round_to(trk_dist_km, 3),
                                altitude_m: rounded_ele,
                            });
                            trk_prev = Some((lt, ln, ele));
                        }
                        section = Section::Trk;
                    }
                    b"rtept" => {
                        if let (Some(lt), Some(ln)) = (cur_lat, cur_lon) {
                            let ele = cur_ele;
                            if let Some((plat, plon, pele)) = rte_prev {
                                let d = haversine_distance_km(plat, plon, lt, ln);
                                rte_dist_km += d;
                                let diff = ele - pele;
                                if diff > 0.0 {
                                    rte_uphill += diff;
                                } else {
                                    rte_downhill += diff.abs();
                                }
                            }
                            rte_min_elev = rte_min_elev.min(ele);
                            rte_max_elev = rte_max_elev.max(ele);
                            let rounded_ele = round_to(ele, 1);
                            rte_points.push([ln, lt, rounded_ele]);
                            rte_profile.push(ElevationPoint {
                                distance_km: round_to(rte_dist_km, 3),
                                altitude_m: rounded_ele,
                            });
                            rte_prev = Some((lt, ln, ele));
                        }
                        section = Section::Rte;
                    }
                    b"wpt" => {
                        if let (Some(lt), Some(ln)) = (cur_lat, cur_lon) {
                            waypoints.push(WaypointData {
                                name: if cur_name.is_empty() {
                                    "Punto de Control".to_string()
                                } else {
                                    cur_name.clone()
                                },
                                latitude: lt,
                                longitude: ln,
                                altitude_m: round_to(cur_ele, 1),
                                description: if !cur_desc.is_empty() {
                                    cur_desc.clone()
                                } else {
                                    cur_cmt.clone()
                                },
                                symbol: cur_sym.clone(),
                            });
                        }
                        section = Section::Root;
                    }
                    b"trk" | b"rte" => {
                        section = Section::Root;
                    }
                    _ => {}
                }
                current_tag.clear();
            }
            Ok(Event::Eof) => break,
            Err(err) => {
                return json!({
                    "success": false,
                    "error": format!("Formato GPX inválido: {}", err)
                });
            }
            _ => {}
        }
        buf.clear();
    }

    if !saw_gpx_root {
        return json!({
            "success": false,
            "error": "Formato GPX inválido: no se encontró el nodo raíz <gpx>"
        });
    }

    let (track_points, elevation_profile, total_dist_km, uphill, downhill, min_elev, max_elev) =
        if !trk_points.is_empty() {
            (
                trk_points,
                trk_profile,
                trk_dist_km,
                trk_uphill,
                trk_downhill,
                trk_min_elev,
                trk_max_elev,
            )
        } else {
            (
                rte_points,
                rte_profile,
                rte_dist_km,
                rte_uphill,
                rte_downhill,
                rte_min_elev,
                rte_max_elev,
            )
        };

    let start_alt = track_points.first().map(|p| p[2]).unwrap_or(0.0);
    let min_altitude = round_to(if min_elev != 99999.0 { min_elev } else { start_alt }, 1);
    let max_altitude = round_to(if max_elev != -99999.0 { max_elev } else { start_alt }, 1);
    let dist_km = round_to(total_dist_km, 2);
    let gain_m = round_to(uphill, 1);
    let loss_m = round_to(downhill, 1);

    let duration_min =
        calculate_estimated_duration_minutes(dist_km, gain_m, loss_m, max_altitude);
    let diff_level = calculate_difficulty_level(dist_km, gain_m, max_altitude);

    let simplified_coords = if track_points.len() > 300 {
        simplify_points_rdp(&track_points, 0.00008)
    } else {
        track_points.clone()
    };

    let sampled_profile = sample_profile(&elevation_profile, 120);

    json!({
        "success": true,
        "engine": "rust_huaguruncho_core",
        "track_name": track_name.trim(),
        "track_description": track_desc.trim(),
        "total_distance_km": dist_km,
        "elevation_gain_m": gain_m,
        "elevation_loss_m": loss_m,
        "min_altitude_m": min_altitude,
        "max_altitude_m": max_altitude,
        "start_altitude_m": round_to(start_alt, 1),
        "estimated_duration_minutes": duration_min,
        "difficulty": diff_level,
        "point_count": track_points.len(),
        "simplified_point_count": simplified_coords.len(),
        "geojson_track": {
            "type": "Feature",
            "geometry": {
                "type": "LineString",
                "coordinates": simplified_coords,
            },
            "properties": {
                "distance_km": dist_km,
                "elevation_gain_m": gain_m,
                "elevation_loss_m": loss_m,
                "max_altitude_m": max_altitude,
                "min_altitude_m": min_altitude,
                "estimated_duration_minutes": duration_min,
                "difficulty": diff_level,
            }
        },
        "elevation_profile": sampled_profile,
        "waypoints": waypoints,
    })
}

/// Calcula telemetría en tiempo real para Live Trekking GPS:
/// desvío respecto al eje del sendero en metros, alerta >50m, avance en km y tiempo restante Naismith.
pub fn evaluate_live_telemetry(
    current_lat: f64,
    current_lon: f64,
    current_alt_m: f64,
    max_alt_m: f64,
    total_distance_km: f64,
    trail_lat_lon: &[[f64; 2]],
) -> LiveTelemetryResult {
    if trail_lat_lon.is_empty() {
        return LiveTelemetryResult {
            distance_to_trail_m: 0.0,
            is_off_trail_alert: false,
            nearest_point_index: 0,
            distance_covered_km: 0.0,
            distance_remaining_km: total_distance_km.max(0.0),
            progress_percent: 0.0,
            estimated_remaining_minutes: calculate_estimated_duration_minutes(
                total_distance_km,
                (max_alt_m - current_alt_m).max(0.0),
                0.0,
                max_alt_m,
            ),
        };
    }

    let mut min_dist_m = f64::MAX;
    let mut nearest_idx = 0usize;

    for (i, pt) in trail_lat_lon.iter().enumerate() {
        let d = haversine_distance_meters(current_lat, current_lon, pt[0], pt[1]);
        if d < min_dist_m {
            min_dist_m = d;
            nearest_idx = i;
        }
    }

    let is_off_trail = min_dist_m > 50.0;
    let n = trail_lat_lon.len();
    let ratio = if n > 1 {
        nearest_idx as f64 / (n - 1) as f64
    } else {
        0.0
    };

    let covered_km = round_to((ratio * total_distance_km).clamp(0.0, total_distance_km), 2);
    let remaining_km = round_to((total_distance_km - covered_km).max(0.0), 2);
    let progress = if total_distance_km > 0.0 {
        round_to((covered_km / total_distance_km).clamp(0.0, 1.0), 4)
    } else {
        0.0
    };

    let remaining_gain = (max_alt_m - current_alt_m).max(0.0);
    let eta_min = calculate_estimated_duration_minutes(
        remaining_km,
        remaining_gain,
        0.0,
        max_alt_m,
    );

    LiveTelemetryResult {
        distance_to_trail_m: round_to(min_dist_m, 1),
        is_off_trail_alert: is_off_trail,
        nearest_point_index: nearest_idx,
        distance_covered_km: covered_km,
        distance_remaining_km: remaining_km,
        progress_percent: progress,
        estimated_remaining_minutes: eta_min,
    }
}
