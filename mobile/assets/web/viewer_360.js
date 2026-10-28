(function () {
  'use strict';

  let canvas, gl;
  let container, hotspotsLayer, loadingOverlay;
  let currentTexture = null;
  let shaderProgram = null;
  let vertexBuffer = null;
  let hotspots = [];

  // Camera orientation & view state
  let yaw = 0;      // Horizontal rotation in radians
  let pitch = 0;    // Vertical rotation in radians
  let fov = 75;     // Field of view in degrees (30 to 100)

  // Smooth camera target animation
  let animTargetYaw = null;
  let animTargetPitch = null;

  // Interaction tracking
  let isPointerDown = false;
  let lastPointerX = 0;
  let lastPointerY = 0;
  let velocityYaw = 0;
  let velocityPitch = 0;
  let lastPinchDistance = 0;

  const ICONS_SVG = {
    photo_camera: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"></path><circle cx="12" cy="13" r="4"></circle></svg>',
    headphones: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="M3 18v-6a9 9 0 0 1 18 0v6"></path><path d="M21 19a2 2 0 0 1-2 2h-1a2 2 0 0 1-2-2v-3a2 2 0 0 1 2-2h3zM3 19a2 2 0 0 0 2 2h1a2 2 0 0 0 2-2v-3a2 2 0 0 0-2-2H3z"></path></svg>',
    arrow_forward: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>',
    arrow_back: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>',
    info: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"></circle><line x1="12" y1="16" x2="12" y2="12"></line><line x1="12" y1="8" x2="12.01" y2="8"></line></svg>',
    warning: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>',
    eco: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2a10 10 0 0 0-10 10c0 5.52 4.48 10 10 10s10-4.48 10-10c0-2.8-1.2-5.3-3-7.1"></path><path d="M12 12c-2.8 0-5 2.2-5 5"></path><path d="M12 6c3.3 0 6 2.7 6 6"></path></svg>',
    terrain: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><path d="M8 3l4 8 5-5 5 15H2L8 3z"></path></svg>'
  };

  function sendToFlutter(data) {
    if (window.FlutterBridge && window.FlutterBridge.postMessage) {
      window.FlutterBridge.postMessage(JSON.stringify(data));
    }
  }

  function initWebGL() {
    canvas = document.getElementById('panorama-canvas');
    container = document.getElementById('viewer-container');
    hotspotsLayer = document.getElementById('hotspots-layer');
    loadingOverlay = document.getElementById('loading-overlay');

    gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
    if (!gl) {
      console.error('WebGL no disponible');
      sendToFlutter({ type: 'error', message: 'WebGL no soportado' });
      return;
    }

    const vsSource = `
      attribute vec2 aPosition;
      varying vec2 vUv;
      void main() {
        vUv = aPosition * 0.5 + 0.5;
        gl_Position = vec4(aPosition, 0.0, 1.0);
      }
    `;

    const fsSource = `
      precision highp float;
      varying vec2 vUv;
      uniform sampler2D uSampler;
      uniform vec2 uResolution;
      uniform float uYaw;
      uniform float uPitch;
      uniform float uFov;

      #define PI 3.14159265359

      void main() {
        vec2 screenPos = (gl_FragCoord.xy / uResolution.xy) * 2.0 - 1.0;
        screenPos.x *= uResolution.x / uResolution.y;

        float fovRad = uFov * PI / 180.0;
        float focalLength = 1.0 / tan(fovRad * 0.5);

        vec3 ray = normalize(vec3(screenPos.x, screenPos.y, focalLength));

        // Rotate ray by Pitch (X axis)
        float cp = cos(uPitch);
        float sp = sin(uPitch);
        mat3 pitchMat = mat3(
          1.0, 0.0, 0.0,
          0.0, cp, -sp,
          0.0, sp, cp
        );
        ray = pitchMat * ray;

        // Rotate ray by Yaw (Y axis)
        float cy = cos(uYaw);
        float sy = sin(uYaw);
        mat3 yawMat = mat3(
          cy, 0.0, -sy,
          0.0, 1.0, 0.0,
          sy, 0.0, cy
        );
        ray = yawMat * ray;

        // Convert 3D direction to spherical UV
        float phi = atan(ray.x, ray.z);
        float theta = asin(clamp(ray.y, -1.0, 1.0));

        vec2 uv = vec2(
          (phi / (2.0 * PI)) + 0.5,
          (theta / PI) + 0.5
        );

        gl_FragColor = texture2D(uSampler, uv);
      }
    `;

    const vs = createShader(gl, gl.VERTEX_SHADER, vsSource);
    const fs = createShader(gl, gl.FRAGMENT_SHADER, fsSource);
    shaderProgram = gl.createProgram();
    gl.attachShader(shaderProgram, vs);
    gl.attachShader(shaderProgram, fs);
    gl.linkProgram(shaderProgram);

    const positions = new Float32Array([
      -1, -1,
       1, -1,
      -1,  1,
      -1,  1,
       1, -1,
       1,  1,
    ]);

    vertexBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, positions, gl.STATIC_DRAW);

    setupEvents();
    resize();
    window.addEventListener('resize', resize);
    requestAnimationFrame(renderLoop);

    sendToFlutter({ type: 'ready' });
  }

  function createShader(gl, type, source) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
      console.error(gl.getShaderInfoLog(shader));
      gl.deleteShader(shader);
      return null;
    }
    return shader;
  }

  function resize() {
    const width = container.clientWidth || window.innerWidth;
    const height = container.clientHeight || window.innerHeight;
    canvas.width = width * (window.devicePixelRatio || 1);
    canvas.height = height * (window.devicePixelRatio || 1);
    if (gl) {
      gl.viewport(0, 0, canvas.width, canvas.height);
    }
  }

  function setupEvents() {
    container.addEventListener('touchstart', (e) => {
      animTargetYaw = null;
      animTargetPitch = null;
      if (e.touches.length === 1) {
        isPointerDown = true;
        lastPointerX = e.touches[0].clientX;
        lastPointerY = e.touches[0].clientY;
        velocityYaw = 0;
        velocityPitch = 0;
      } else if (e.touches.length === 2) {
        isPointerDown = false;
        lastPinchDistance = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
      }
    }, { passive: true });

    container.addEventListener('touchmove', (e) => {
      if (e.touches.length === 1 && isPointerDown) {
        const dx = e.touches[0].clientX - lastPointerX;
        const dy = e.touches[0].clientY - lastPointerY;
        lastPointerX = e.touches[0].clientX;
        lastPointerY = e.touches[0].clientY;

        const sensitivity = (fov / 75) * 0.0035;
        velocityYaw = -dx * sensitivity;
        velocityPitch = dy * sensitivity;

        yaw += velocityYaw;
        pitch += velocityPitch;
        clampPitch();
      } else if (e.touches.length === 2) {
        const dist = Math.hypot(
          e.touches[0].clientX - e.touches[1].clientX,
          e.touches[0].clientY - e.touches[1].clientY
        );
        if (lastPinchDistance > 0) {
          const delta = dist - lastPinchDistance;
          fov = Math.max(30, Math.min(100, fov - delta * 0.15));
        }
        lastPinchDistance = dist;
      }
    }, { passive: true });

    container.addEventListener('touchend', () => {
      isPointerDown = false;
      lastPinchDistance = 0;
    });

    container.addEventListener('mousedown', (e) => {
      animTargetYaw = null;
      animTargetPitch = null;
      isPointerDown = true;
      lastPointerX = e.clientX;
      lastPointerY = e.clientY;
      velocityYaw = 0;
      velocityPitch = 0;
    });

    window.addEventListener('mousemove', (e) => {
      if (!isPointerDown) return;
      const dx = e.clientX - lastPointerX;
      const dy = e.clientY - lastPointerY;
      lastPointerX = e.clientX;
      lastPointerY = e.clientY;

      const sensitivity = (fov / 75) * 0.003;
      velocityYaw = -dx * sensitivity;
      velocityPitch = dy * sensitivity;

      yaw += velocityYaw;
      pitch += velocityPitch;
      clampPitch();
    });

    window.addEventListener('mouseup', () => {
      isPointerDown = false;
    });

    container.addEventListener('wheel', (e) => {
      fov = Math.max(30, Math.min(100, fov + e.deltaY * 0.05));
      e.preventDefault();
    }, { passive: false });
  }

  function clampPitch() {
    const limit = (Math.PI / 2) - 0.05;
    pitch = Math.max(-limit, Math.min(limit, pitch));
  }

  function shortestAngleDiff(current, target) {
    let diff = (target - current) % (2 * Math.PI);
    if (diff > Math.PI) diff -= 2 * Math.PI;
    if (diff < -Math.PI) diff += 2 * Math.PI;
    return diff;
  }

  function renderLoop() {
    if (animTargetYaw !== null && animTargetPitch !== null) {
      const dyaw = shortestAngleDiff(yaw, animTargetYaw);
      const dpitch = animTargetPitch - pitch;
      yaw += dyaw * 0.14;
      pitch += dpitch * 0.14;
      clampPitch();
      if (Math.abs(dyaw) < 0.003 && Math.abs(dpitch) < 0.003) {
        yaw = animTargetYaw;
        pitch = animTargetPitch;
        animTargetYaw = null;
        animTargetPitch = null;
      }
    } else if (!isPointerDown) {
      velocityYaw *= 0.92;
      velocityPitch *= 0.92;
      if (Math.abs(velocityYaw) > 0.0001) yaw += velocityYaw;
      if (Math.abs(velocityPitch) > 0.0001) {
        pitch += velocityPitch;
        clampPitch();
      }
    }

    if (gl && shaderProgram && currentTexture) {
      gl.useProgram(shaderProgram);

      const posAttr = gl.getAttribLocation(shaderProgram, 'aPosition');
      gl.enableVertexAttribArray(posAttr);
      gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
      gl.vertexAttribPointer(posAttr, 2, gl.FLOAT, false, 0, 0);

      gl.uniform2f(gl.getUniformLocation(shaderProgram, 'uResolution'), canvas.width, canvas.height);
      gl.uniform1f(gl.getUniformLocation(shaderProgram, 'uYaw'), yaw);
      gl.uniform1f(gl.getUniformLocation(shaderProgram, 'uPitch'), pitch);
      gl.uniform1f(gl.getUniformLocation(shaderProgram, 'uFov'), fov);

      gl.activeTexture(gl.TEXTURE0);
      gl.bindTexture(gl.TEXTURE_2D, currentTexture);
      gl.uniform1i(gl.getUniformLocation(shaderProgram, 'uSampler'), 0);

      gl.drawArrays(gl.TRIANGLES, 0, 6);
    }

    updateHotspotsPosition();
    requestAnimationFrame(renderLoop);
  }

  function updateHotspotsPosition() {
    if (!hotspotsLayer || hotspots.length === 0) return;

    const width = container.clientWidth;
    const height = container.clientHeight;
    const fovRad = fov * Math.PI / 180;
    const focalLength = 1.0 / Math.tan(fovRad * 0.5);
    const aspect = width / height;

    hotspots.forEach((h) => {
      const el = h.element;
      if (!el) return;

      const hYaw = (h.data.yaw || 0) * Math.PI / 180;
      const hPitch = (h.data.pitch || 0) * Math.PI / 180;

      const wx = Math.sin(hYaw) * Math.cos(hPitch);
      const wy = Math.sin(hPitch);
      const wz = Math.cos(hYaw) * Math.cos(hPitch);

      // 1. Inverse Yaw (around Y axis)
      const cy = Math.cos(yaw);
      const sy = Math.sin(yaw);
      const x1 = cy * wx - sy * wz;
      const y1 = wy;
      const z1 = sy * wx + cy * wz;

      // 2. Inverse Pitch (around X axis)
      const cp = Math.cos(pitch);
      const sp = Math.sin(pitch);
      const camX = x1;
      const camY = cp * y1 - sp * z1;
      const camZ = sp * y1 + cp * z1;

      if (camZ <= 0.08) {
        el.style.display = 'none';
        return;
      }

      const projX = (camX / camZ) * focalLength;
      const projY = (camY / camZ) * focalLength;

      const screenX = (projX / aspect + 1.0) * 0.5 * width;
      const screenY = (-projY + 1.0) * 0.5 * height;

      if (screenX >= -100 && screenX <= width + 100 && screenY >= -100 && screenY <= height + 100) {
        el.style.display = 'flex';
        el.style.left = `${screenX}px`;
        el.style.top = `${screenY}px`;
      } else {
        el.style.display = 'none';
      }
    });
  }

  function escapeHtml(str) {
    if (!str) return '';
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // Public API methods exposed to Flutter
  window.loadPanorama = function (imageSrc, hotspotsData, startYaw, startPitch) {
    if (loadingOverlay) loadingOverlay.style.display = 'flex';

    // Apply initial camera orientation from Studio (initial_yaw / initial_pitch)
    yaw = ((typeof startYaw === 'number' && !isNaN(startYaw)) ? startYaw : 0) * Math.PI / 180;
    pitch = ((typeof startPitch === 'number' && !isNaN(startPitch)) ? startPitch : 0) * Math.PI / 180;
    clampPitch();
    velocityYaw = 0;
    velocityPitch = 0;
    animTargetYaw = null;
    animTargetPitch = null;

    const parsedHotspots = hotspotsData
      ? (typeof hotspotsData === 'string' ? JSON.parse(hotspotsData) : hotspotsData)
      : [];

    // Render hotspots immediately so they are ready as soon as the texture appears
    renderHotspots(parsedHotspots);

    const img = new Image();
    if (!imageSrc.startsWith('data:')) {
      img.crossOrigin = 'anonymous';
    }
    img.onload = function () {
      if (!gl) return;
      if (currentTexture) gl.deleteTexture(currentTexture);

      currentTexture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, currentTexture);
      gl.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, true);
      gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, img);

      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

      if (loadingOverlay) loadingOverlay.style.display = 'none';

      sendToFlutter({ type: 'scene_loaded' });
    };

    img.onerror = function () {
      if (loadingOverlay) loadingOverlay.style.display = 'none';
      console.error('Error cargando imagen panorámica');
      sendToFlutter({ type: 'error', message: 'No se pudo cargar la imagen panorámica' });
    };

    img.src = imageSrc;
  };

  function getDefaultIconForType(type, customIcon) {
    if (customIcon && ICONS_SVG[customIcon]) return ICONS_SVG[customIcon];
    switch (type) {
      case 'photo_poi':
        return ICONS_SVG.photo_camera;
      case 'audio_guide':
        return ICONS_SVG.headphones;
      case 'warning':
        return ICONS_SVG.warning;
      case 'information':
        return ICONS_SVG.info;
      case 'navigation':
      default:
        return ICONS_SVG.arrow_forward;
    }
  }

  function getCategoryBadgeText(type, hasPhoto) {
    if (type === 'photo_poi' || hasPhoto) return '📷 FOTOGRAFÍA HD';
    if (type === 'audio_guide') return '🎧 AUDIOGUÍA';
    if (type === 'warning') return '⚠️ ALERTA GLACIAR';
    if (type === 'information') return 'ℹ️ PUNTO DE INTERÉS';
    return '🔗 AVANZAR 360°';
  }

  function renderHotspots(dataList) {
    if (!hotspotsLayer) return;
    hotspotsLayer.innerHTML = '';
    hotspots = [];

    dataList.forEach((data) => {
      const el = document.createElement('div');
      const hType = data.type || 'navigation';
      const hasPhoto = Boolean(data.media_image_url && String(data.media_image_url).trim().length > 0);
      const effectiveType = (hType === 'photo_poi' || hasPhoto) ? 'photo_poi' : hType;
      el.className = `hotspot hotspot-${effectiveType}`;

      const iconSvg = getDefaultIconForType(effectiveType, data.icon);
      const badgeText = getCategoryBadgeText(effectiveType, hasPhoto);
      const safeTitle = escapeHtml(data.title || 'Punto 360°');
      const safeDesc = escapeHtml(data.content || '');

      let cardHtml = '';
      if (hasPhoto) {
        const safeImg = escapeHtml(data.media_image_url);
        cardHtml = `
          <div class="hotspot-rich-card hotspot-rich-card-photo">
            <div class="hotspot-photo-thumb-wrap">
              <img class="hotspot-photo-thumb" src="${safeImg}" alt="${safeTitle}" />
              <span class="hotspot-photo-pill">📷 FOTO</span>
            </div>
            <div class="hotspot-card-meta">
              <div class="hotspot-card-title">${safeTitle}</div>
              <div class="hotspot-card-sub">${safeDesc ? safeDesc : 'Toca para abrir foto HD'}</div>
            </div>
          </div>
        `;
      } else {
        cardHtml = `
          <div class="hotspot-rich-card">
            <div class="hotspot-card-meta">
              <div class="hotspot-card-cat">${badgeText}</div>
              <div class="hotspot-card-title">${safeTitle}</div>
              ${safeDesc ? `<div class="hotspot-card-sub">${safeDesc}</div>` : ''}
            </div>
          </div>
        `;
      }

      el.innerHTML = `
        <div class="hotspot-pin-anchor">
          <div class="hotspot-pulse"></div>
          <div class="hotspot-icon-wrapper">
            ${iconSvg}
          </div>
        </div>
        ${cardHtml}
      `;

      let lastTriggerTime = 0;
      let touchStartX = 0;
      let touchStartY = 0;

      const triggerHotspot = (e) => {
        if (e) e.stopPropagation();
        const now = Date.now();
        if (now - lastTriggerTime < 350) return;
        lastTriggerTime = now;
        sendToFlutter({
          type: 'hotspot_click',
          hotspot: data
        });
      };

      el.addEventListener('touchstart', (e) => {
        e.stopPropagation();
        if (e.touches && e.touches.length === 1) {
          touchStartX = e.touches[0].clientX;
          touchStartY = e.touches[0].clientY;
        }
      }, { passive: true });

      el.addEventListener('touchend', (e) => {
        e.stopPropagation();
        if (e.changedTouches && e.changedTouches.length === 1) {
          const dist = Math.hypot(
            e.changedTouches[0].clientX - touchStartX,
            e.changedTouches[0].clientY - touchStartY
          );
          if (dist < 15) {
            triggerHotspot(e);
          }
        }
      });

      el.addEventListener('click', triggerHotspot);

      hotspotsLayer.appendChild(el);
      hotspots.push({ data: data, element: el });
    });
  }

  window.lookAt = function (targetYaw, targetPitch) {
    animTargetYaw = (targetYaw || 0) * Math.PI / 180;
    animTargetPitch = (targetPitch || 0) * Math.PI / 180;
    const limit = (Math.PI / 2) - 0.05;
    animTargetPitch = Math.max(-limit, Math.min(limit, animTargetPitch));
  };

  document.addEventListener('DOMContentLoaded', initWebGL);
})();
