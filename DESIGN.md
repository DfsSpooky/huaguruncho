# Design System: Cordillera Field Instrument — Huaguruncho 360
**Project:** Huaguruncho 360 (Turismo Responsable, Conservación & Puesto de Control de Alta Montaña)  
**Target Platform:** Mobile First (Android / iOS / WebGL)  
**Design Philosophy:** *Alpine Field Instrument & Editorial Expedition Journal* (Antítesis del diseño genérico de IA)

---

## 1. Manifiesto Visual & Atmósfera (Visual Theme & Atmosphere)

El nuevo lenguaje visual de **Huaguruncho 360** abandona por completo la estética cliché generada por IA (gradientes púrpuras holográficos, curvas flotantes estériles, glassmorphism ilegible bajo el sol y tarjetas de software corporativo genéricas).

La nueva identidad se fundamenta en un **Instrumento de Campo Alpino y Cuaderno Editorial de Expedición**:
- **Ambiente:** Mineral, táctil, austero y de altísima precisión documental. Evoca el frío cortante del Nevado Huaguruncho (5,742 m s.n.m.), la roca de granito andino, las cuerdas de escalada, el cuero de montaña y las libretas de campo de los guardaparques de Huachón.
- **Densidad Visual:** *Balanced Technical* (Densidad 6/10). Espaciado amplio pero con información utilitaria densa y legible en condiciones reales de campo (luz solar directa a 4,500 m s.n.m.).
- **Varianza Estructural:** *Offset Asymmetric* (Varianza 7/10). Nada de cuadrículas predecibles ni héroes centrados. Bloques editoriales con ritmos alternados, fichas con muescas mecánicas y sellos de certificación ecológica.
- **Acabado Táctil:** Sensación física de instrumentación analógica de montaña (altímetros suizos, mosquetones anodizados, sellos de tinta de control de guardabosques).

---

## 2. Paleta de Color Calibrada (Color Palette & Roles)

Prohibidos terminantemente los degradados fluorescentes, los púrpuras neón y los fondos negros puros (`#000000`). Se adopta una paleta mineral andina de alto contraste:

| Token Semántico | Código HEX | Rol Funcional & Ubicación |
|---|---|---|
| **Basalt Ink** (Tinta Basalto) | `#14171A` | Fondo principal en Modo Noche / Color de texto principal en Modo Día. Profundidad carbón mate, nunca negro puro. |
| **Alpine Chalk** (Tiza Alpina) | `#F6F7F4` | Canvas principal de fondo en Modo Día. Tono mineral cálido y anti-fatiga visual. |
| **Pure Slate Surface** | `#FFFFFF` | Superficie sólida de tarjetas y fichas técnicas en Modo Día. En Modo Noche: `#1B2026`. |
| **Cordillera Ochre** (Ocre Cordillera) | `#D95D39` | **ÚNICO acento primario**. Inspirado en cuerdas de escalada, banderolas de cumbre y ropa de expedición de alta visibilidad. Usado exclusivamente para CTAs primarios, pines GPS activos y botón SOS. (Saturación controlada al 72%). |
| **Yareta Pine** (Verde Yareta / Musgo) | `#2A5C43` | Acento secundario para Conservación, verificación "Huella Cero", estado "Completado" y sellos ecológicos de Huachón. |
| **Glacial Frost Line** | `#E2E6E1` | Bordes estructurales ultrafinos de 1px en Modo Día. En Modo Noche: `rgba(255, 255, 255, 0.12)`. Cero sombras difusas innecesarias. |
| **Puna Muted Grey** | `#6E767D` | Metadatos secundarios, leyendas de coordenadas, unidades métricas y etiquetas de soporte. |
| **Glacier Blue Tint** | `#EDF3F5` | Fondos de etiquetas de altitud, chips de telemetría y contenedores de meteorología. |

---

## 3. Arquitectura Tipográfica (Typography Rules)

Prohibida la fuente genérica `Inter` o fuentes del sistema insípidas. La tipografía transmite peso documental, precisión técnica y carácter humano:

- **Titulares & Display:** `Cabinet Grotesk` o `Outfit` (Pesos: 700 / 800)
  - Tracking ajustado (`letter-spacing: -0.03em`), jerarquía de peso imponente pero sin gritar, mayúsculas con ritmo editorial en subtítulos (`font-feature-settings: 'cv02', 'cv03'`).
- **Cuerpo de Texto & UI:** `Satoshi` o `Plus Jakarta Sans` (Pesos: 400 / 500)
  - Interlineado relajado (`line-height: 1.55`), longitud de línea máxima de 65 caracteres, legibilidad cristalina.
- **Telemetría & Datos Técnicos:** `JetBrains Mono` o `Geist Mono` (Pesos: 500 / 600)
  - Obligatorio para: altitudes (`5,742 m s.n.m.`), coordenadas GPS (`10°31'52"S 75°55'26"W`), temporizadores de trekking, barómetros, pesos de residuos en kg y cola de sincronización offline (`UUID: 8f4c-12b`).

---

## 4. Principios de Composición y Layout (Layout Principles)

1. **Fin a la simetría de plantilla:**
   - Prohibido el típico patrón de "3 tarjetas idénticas horizontales". En su lugar: cuadrículas asimétricas 60/40, tarjetas horizontales tipo ficha de inventario y listados de senderos con perfil altimétrico incrustado.
2. **Hero Editorial Asimétrico:**
   - La cabecera nunca va centrada. Título alineado a la izquierda con micro-fotografías o etiquetas documentales incrustadas en línea (ej. `[ Nevado ] Huaguruncho · 5,742 m`).
   - Una sola acción principal clara (CTA de expedición o puesto de control). Nada de enlaces secundarios dispersos.
3. **Visibilidad en Entornos Extremos:**
   - Bordes nítidos de 1px con contraste garantizado contra nieve o sol andino. Nada de fondos translúcidos borrosos donde no se leen los datos.
4. **Offline First Transparente:**
   - Banner de estado sutil en la parte superior del layout: "MODO CORDILLERA (OFFLINE)" con indicador discreto de almacenamiento local.

---

## 5. Anatomía de Componentes (Component Stylings)

### Botones (Action Elements)
- **Botón Primario:** Color sólido *Cordillera Ochre* (`#D95D39`), esquinas suavemente curvadas (radio de 12px), texto en alto contraste blanco.
- **Respuesta Mecánica:** Al presionarse realiza una micro-traslación física de `-1px` vertical, simulando un pulsador táctil real. **Sin halos ni resplandores neón exteriores**.
- **Botón Secundario / Instrumento:** Fondo blanco/gris tiza con borde de 1px `Glacial Frost Line`, tipografía mono o semi-bold.

### Fichas y Tarjetas de Expedición (Cards & Containers)
- **Ficha de Ruta:** Esquinas con radio de 14px a 16px. En lugar de sombras flotantes pesadas, utiliza un sutil borde estructural de 1px (`#E2E6E1`) y una ligera sombra de elevación física (`0 2px 4px rgba(20,23,26,0.04)`).
- **Muesca de Estado:** Pequeñas pestañas o sellos de esquina que indican "Descargado Offline", "Sendero Abierto" o "Nivel Técnico".

### Puesto de Control "Huella Cero" (Waste Inventory Sheet)
- Inspirado en las hojas de control físico de los guardaparques: filas tabulares limpias, contadores táctiles grandes tipo `[ - ]  04  [ + ]` para botellas de plástico, latas y gas.
- Sello de certificación de retorno: Insignia en *Yareta Pine* (`#2A5C43`) con tipografía mono que dice `RETORNO VERIFICADO 100%`.

### Visor 360° e Interfaz HUD (Heads-Up Display)
- Controles flotantes mínimos tipo brújula de senderismo: fondo sólido semitransparente oscuro (`rgba(20,23,26,0.85)`), iconografía de trazo limpio de 1.5px, botones de 48px de área táctil.
- Hotspots en 360: Pines circulares con aro de precisión y etiqueta de datos en fuente mono (`LAGUNA TAURICOCHA · 4,150M`), sin animaciones estridentes.

### Formularios y Eco-Reportes
- Campos de texto con etiqueta estricta arriba (no floating labels que se pierden).
- Estado de captura GPS: cuadro de telemetría con coordenadas satelitales en tiempo real y precisión en metros (`±3.2m`).

---

## 6. Filosofía de Movimiento e Interacción (Motion Philosophy)

- **Física de Resortes Pesados (Spring Physics):** Transiciones con amortiguación natural (`stiffness: 120, damping: 22`). Se sienten mecánicas, firmes y deliberadas, sin rebotes caricaturescos ni animaciones lentas.
- **Micro-interacciones funcionales:**
  - Pulso suave de radar únicamente en la búsqueda satelital GPS activa.
  - El perfil de elevación se dibuja con una línea continua limpia al abrir la ficha técnica.
  - Cero efectos de brillo "shimmer" holográfico o chispitas mágicas de IA.

---

## 7. Catálogo Estricto de Anti-Patrones (Reglas Anti-IA para Stitch)

Cualquier pantalla generada para **Huaguruncho 360** debe cumplir con la siguiente lista de **PROHIBICIONES ESTRICTAS**:

1. ❌ **PROHIBIDO el degradado púrpura/violeta neón ("AI Purple")**: Ningún botón, fondo o borde puede usar colores violetas, rosas fluorescentes ni brillos cósmicos.
2. ❌ **PROHIBIDA la fuente `Inter` o fuentes genéricas de sistema**: Emplear siempre `Cabinet Grotesk` / `Outfit` para títulos y `JetBrains Mono` / `Geist Mono` para métricas.
3. ❌ **PROHIBIDO el negro puro (`#000000`)**: Usar siempre *Basalt Ink* (`#14171A`).
4. ❌ **PROHIBIDO el "Glassmorphism" exagerado**: Las tarjetas deben ser sólidas y legibles. El texto debe poder leerse sin esfuerzo bajo la luz del sol andino.
5. ❌ **PROHIBIDAS las 3 columnas horizontales idénticas**: Estructuras asimétricas, listas verticales ricas o cuadrículas dinámicas 2-columnas con jerarquía.
6. ❌ **PROHIBIDO el texto centrado en pantallas principales**: Encabezados y datos técnicos firmemente anclados a la izquierda.
7. ❌ **PROHIBIDOS los clichés de redacción IA**: Prohibido usar palabras como *"Unleash", "Elevate your experience", "Seamless journey", "Next-gen adventure"*. Usar lenguaje real, sobrio y de montaña: *"Puesto de Control Huachón", "Registro de Ascenso", "Desnivel +1,240m", "Cero Residuos"*.
8. ❌ **PROHIBIDOS los datos inventados absurdos**: Prohibido colocar *"99.9% de satisfacción"* o *"10k+ montañistas felices"*. Si se muestran números, deben ser cotas reales de altitud, kilómetros del sendero o conteo de botellas retornadas.
9. ❌ **PROHIBIDOS los emojis en la interfaz formal**: Usar íconos SVG vectoriales limpios (estilo Lucide / Phosphor: compás, bota de trekking, hoja de reciclaje, advertencia topográfica).

---

## 8. Master Prompt para Google Stitch (Copiar y Pegar en Stitch)

Usa este bloque de directivas como prompt de diseño en **Google Stitch**:

```text
Design a modern, authentic mobile application screen for "Huaguruncho 360", a high-altitude mountaineering, 360 virtual tour, and sustainable eco-conservation platform set in the Andes of Pasco, Peru (Nevado Huaguruncho, 5,742 m).

Aesthetic Directive:
- Theme: "Alpine Field Instrument & Editorial Expedition Journal". Real mountaineering utility meets documentary editorial design.
- Colors: Canvas is Alpine Chalk (#F6F7F4) with Pure White (#FFFFFF) solid cards and Basalt Ink (#14171A) deep charcoal typography. Singular high-contrast expedition accent is Cordillera Ochre (#D95D39) for main CTAs and active pins, complemented by Yareta Pine Green (#2A5C43) for eco-conservation badges.
- Absolutely NO neon purples, NO glowing blue gradients, NO generic glassmorphism blobs, and NO pure pitch black.
- Typography: Bold characterful grotesque sans for titles (Cabinet Grotesk / Outfit), crisp body text (Satoshi), and precision monospace (JetBrains Mono) for altitudes (e.g. 5,742 m s.n.m.), GPS coordinates, and offline status.
- Layout: Asymmetric, left-aligned, spacious, and field-tested for high sunlight outdoors readability. Avoid generic 3-card equal grids or centered heroes.
- Components: Tactile mechanical buttons with crisp 1px borders (#E2E6E1), elevation profile charts, physical checklist counters for the "Huella Cero" solid waste audit (plastic bottles, gas canisters), and a clean, floating outdoor HUD for the 360 panoramic views.
- Tone: Technical, respectful of local culture (Huachón, Pasco), rugged, and authoritative. No AI marketing buzzwords.
```
