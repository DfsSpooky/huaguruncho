# Guía de Captura y Carga de Panoramas 360° - HUAGURUNCHO 360

Esta guía está dirigida a fotógrafos, guías de montaña y administradores de la plataforma para capturar y subir imágenes equirectangulares reales del Nevado Huaguruncho.

---

## 1. Especificaciones de Imagen Recomendadas

- **Proyección**: Equirectangular (proporción de aspecto exacta `2:1`, por ejemplo `4096 x 2048` o `6000 x 3000`).
- **Formato**: JPG optimizado (calidad 85-90%) o WebP.
- **Tamaño de archivo**: Entre 2 MB y 6 MB por escena para equilibrar nitidez y velocidad de descarga móvil.
- **Espacio de color**: sRGB.

---

## 2. Equipamiento y Técnicas de Captura

1. **Cámaras 360° dedicadas (Recomendado)**:
   - Insta360 X3 / X4, Ricoh Theta Z1 o GoPro Max.
   - Montar sobre monopié o trípode con cabezal compacto para reducir el parche del nadir (la base visible).
2. **Cámara réflex / Mirrorless con lente ojo de pez**:
   - Cabezal panorámico nodal (ej. Nodal Ninja).
   - Cosido (stitching) con software como **PTGui** o **Hugin**.
3. **Smartphones**:
   - Modo "Foto Panorámica 360 / Photo Sphere" de la cámara de Google o apps como Google Street View / GCam.

---

## 3. Procedimiento para Subir Nuevas Escenas al Sistema

### Opción A: Desde el Panel Django Admin
1. Ingresa a `http://tu-servidor:8000/admin/`.
2. Dirígete a **Tourism > Tour Scenes** y haz clic en **Añadir Escena 360°**.
3. Selecciona la **Ruta** correspondiente (ej. "Ruta piloto Huachón - Mirador").
4. Asigna un título descriptivo (ej. "Campamento Laguna Huaguruncho - Vista Este").
5. Adjunta el archivo equirectangular JPG en el campo `panorama_image`.
6. Ingresa las coordenadas GPS (latitud y longitud) del punto de toma.
7. Guarda la escena.
8. En la sección **Hotspots**, añade los puntos interactivos configurando:
   - **Yaw**: Ángulo horizontal (-180° a +180°).
   - **Pitch**: Ángulo vertical (-90° a +90°).
   - **Tipo**: `Navegación` (para saltar a otra escena), `Información` (para explicar flora, fauna o historia) o `Advertencia` (precaución por terreno resbaladizo o altitud).

### Opción B: Publicación de un Nuevo Paquete Offline
1. En Django Admin, ve a **Offline Packages > Paquetes Offline**.
2. Selecciona la ruta y haz clic en **Publicar nueva versión**.
3. El sistema generará automáticamente el manifiesto JSON con los enlaces a todas las escenas y hotspots activos para que la aplicación móvil los descargue en un solo toque.

---

## 4. Estructura de Archivos Locales en la App Móvil (Assets Demo)

Los archivos panorámicos de prueba se ubican en:
`mobile/assets/panoramas/`
- `scene_huachon_plaza.jpg`
- `scene_laguna_huaguruncho.jpg`
- `scene_mirador_glaciar.jpg`

Para reemplazar los ejemplos locales por fotos reales de alta resolución sin servidor, simplemente sustituye estos archivos respetando el formato equirectangular `2:1`.
