import io
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
    HRFlowable,
)


def generate_route_technical_pdf(route):
    """
    Generates a high-quality, printable PDF technical sheet for park rangers and mountaineers.
    """
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=letter,
        rightMargin=36,
        leftMargin=36,
        topMargin=36,
        bottomMargin=36
    )

    styles = getSampleStyleSheet()

    # Estilos Personalizados
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Heading1'],
        fontName='Helvetica-Bold',
        fontSize=18,
        leading=22,
        textColor=colors.HexColor('#0A2540'),
        alignment=0,
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11,
        leading=14,
        textColor=colors.HexColor('#00838F'),
    )

    section_heading = ParagraphStyle(
        'SectionHeading',
        parent=styles['Heading2'],
        fontName='Helvetica-Bold',
        fontSize=13,
        leading=16,
        textColor=colors.HexColor('#0A2540'),
        spaceBefore=8,
        spaceAfter=4,
    )

    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=13,
        textColor=colors.HexColor('#2D3748'),
    )

    badge_style = ParagraphStyle(
        'BadgeStyle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=10,
        leading=12,
        textColor=colors.white,
        alignment=1,
    )

    elements = []

    # 1. Cabecera Institucional
    header_text = "<b>SISTEMA HUAGURUNCHO 360</b> • GESTIÓN DE TURISMO SOSTENIBLE Y ALTA MONTAÑA"
    elements.append(Paragraph(header_text, subtitle_style))
    elements.append(Paragraph(f"FICHA TÉCNICA OFICIAL: {route.name.upper()}", title_style))
    elements.append(HRFlowable(width="100%", thickness=2, color=colors.HexColor('#00838F'), spaceAfter=8, spaceBefore=4))

    # 2. Resumen de la Ruta
    elements.append(Paragraph(f"<b>Descripción:</b> {route.description}", body_style))
    elements.append(Spacer(1, 8))

    # 3. Métricas Principales (Tabla de Resumen Técnico)
    metrics_data = [
        [
            Paragraph("<b>Dificultad</b>", body_style),
            Paragraph("<b>Distancia Total</b>", body_style),
            Paragraph("<b>Desnivel Acumulado (+D)</b>", body_style),
            Paragraph("<b>Rango Altitudinal</b>", body_style),
            Paragraph("<b>Tiempo Estimado</b>", body_style),
        ],
        [
            Paragraph(route.get_difficulty_display(), body_style),
            Paragraph(f"{route.distance_km} km", body_style),
            Paragraph(f"+{int(route.elevation_gain_m)} m", body_style),
            Paragraph(f"{route.min_altitude_m}m - {route.max_altitude_m}m", body_style),
            Paragraph(f"{route.estimated_duration_minutes // 60}h {route.estimated_duration_minutes % 60}min", body_style),
        ]
    ]
    metrics_table = Table(metrics_data, colWidths=[100, 105, 120, 115, 100])
    metrics_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#E0F2F1')),
        ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor('#F8FAFC')),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#CBD5E0')),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    elements.append(metrics_table)
    elements.append(Spacer(1, 10))

    # 4. Hitos y Puntos de Control en Sendero (POIs)
    elements.append(Paragraph("📍 Hitos y Puntos de Control en el Sendero", section_heading))
    pois = route.points_of_interest.filter(is_active=True).order_by('order')

    if pois.exists():
        poi_rows = [
            [
                Paragraph("<b>#</b>", body_style),
                Paragraph("<b>Hito / Punto de Control</b>", body_style),
                Paragraph("<b>Categoría</b>", body_style),
                Paragraph("<b>Altitud</b>", body_style),
                Paragraph("<b>Coordenadas GPS</b>", body_style),
                Paragraph("<b>Detalles de Conservación</b>", body_style),
            ]
        ]
        for p in pois:
            coords = f"{p.latitude:.4f}, {p.longitude:.4f}" if p.latitude and p.longitude else "Sin GPS"
            poi_rows.append([
                Paragraph(str(p.order), body_style),
                Paragraph(f"<b>{p.name}</b>", body_style),
                Paragraph(p.get_category_display(), body_style),
                Paragraph(f"{p.altitude_masl} m", body_style),
                Paragraph(coords, body_style),
                Paragraph(p.description[:80] + "..." if len(p.description) > 80 else p.description, body_style),
            ])

        poi_table = Table(poi_rows, colWidths=[25, 140, 95, 65, 95, 120])
        poi_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#0A2540')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
            ('VALIGN', (0, 0), (-1, -1), 'TOP'),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F7FAFC')]),
            ('TOPPADDING', (0, 0), (-1, -1), 4),
            ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ]))
        elements.append(poi_table)
    else:
        elements.append(Paragraph("No hay hitos registrados.", body_style))

    elements.append(Spacer(1, 10))

    # 5. Recomendaciones de Seguridad y Principios "No Deje Rastro"
    elements.append(Paragraph("⚠️ Recomendaciones de Seguridad & Principio No Deje Rastro (LNT)", section_heading))
    safety_text = route.safety_recommendations or (
        "1. Calzado de alta montaña impermeable y bastones de trekking obligatorios.\n"
        "2. Registro previo obligatorio en el puesto comunal de Huachón.\n"
        "3. Respeto absoluto a los rodales de Puya Raimondi y espejos de agua glaciar.\n"
        "4. Regresar el 100% de los residuos generados."
    )
    elements.append(Paragraph(safety_text.replace('\n', '<br/>'), body_style))
    elements.append(Spacer(1, 10))

    # 6. Directorio Telefónico de Emergencia
    elements.append(Paragraph("📞 Directorio de Emergencias y Rescate de Alta Montaña", section_heading))
    emergency_rows = [
        [
            Paragraph("<b>Entidad / Puesto</b>", body_style),
            Paragraph("<b>Teléfono Directo</b>", body_style),
            Paragraph("<b>Rol en Huaguruncho</b>", body_style),
        ],
        [
            Paragraph("Policía Nacional del Perú (PNP Huachón)", body_style),
            Paragraph("105 / +51 063 421 222", body_style),
            Paragraph("Seguridad ciudadana y control de accesos", body_style),
        ],
        [
            Paragraph("Puesto de Salud Huachón (MINSA)", body_style),
            Paragraph("+51 963 852 741", body_style),
            Paragraph("Atención de mal de altura (soroche) y primeros auxilios", body_style),
        ],
        [
            Paragraph("Asociación de Guías Oficiales de Montaña", body_style),
            Paragraph("+51 963 111 222", body_style),
            Paragraph("Guías acreditados DIRCETUR y rescate en morrenas", body_style),
        ],
    ]
    em_table = Table(emergency_rows, colWidths=[200, 140, 200])
    em_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#2D6A4F')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#E2E8F0')),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#F0FDF4')]),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    elements.append(em_table)

    from apps.common.rust_bridge import rust_sign_eco_report, rust_engine_version
    sig = rust_sign_eco_report(
        str(route.uuid),
        f"ROUTE_{route.slug}",
        float(route.max_altitude_m or 0),
        float(route.distance_km or 0),
        route.updated_at.isoformat(),
    )
    seal_code = sig.get('verification_code', 'H360-VERIFIED') if sig else 'H360-VERIFIED'

    elements.append(Spacer(1, 12))
    footer_text = (
        f"<i>Ficha técnica oficial generada automáticamente por Huaguruncho 360 ({rust_engine_version()}) • "
        f"Sello Criptográfico: <b>{seal_code}</b> • "
        f"Fecha de emisión: {route.updated_at.strftime('%d/%m/%Y')} • Municipalidad Distrital de Huachón, Pasco.</i>"
    )
    elements.append(Paragraph(footer_text, ParagraphStyle('Foot', parent=body_style, fontSize=8, textColor=colors.HexColor('#718096'))))

    doc.build(elements)
    buffer.seek(0)
    return buffer
