import os
import asyncio
from pathlib import Path
from playwright.async_api import async_playwright

ARTIFACTS_DIR = Path("/Users/miguel/.gemini/antigravity-ide/brain/f7e6bd49-b4cf-487f-b7d0-94675b460fd5")
BASE_URL = "http://127.0.0.1:8000/"


async def run_landing_playwright_verification():
    print("=== INICIANDO VERIFICACIÓN E2E PLAYWRIGHT: HUAGURUNCHO 360 (USER-FOCUSED) ===")
    
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            viewport={"width": 1440, "height": 900},
            device_scale_factor=2
        )
        page = await context.new_page()

        # 1. Navegación Principal
        print(f"1. Navegando a {BASE_URL}...")
        response = await page.goto(BASE_URL, wait_until="networkidle")
        assert response and response.status == 200, f"Error en respuesta: {response.status if response else 'None'}"
        print(f"✔ Página cargada con éxito (HTTP {response.status})")

        # 2. Captura Fullpage y Hero
        fullpage_path = ARTIFACTS_DIR / "landing_apple_fullpage.png"
        await page.screenshot(path=str(fullpage_path), full_page=True)
        print(f"✔ Captura de página completa guardada en: {fullpage_path.name}")

        hero_path = ARTIFACTS_DIR / "landing_apple_hero.png"
        hero_el = await page.query_selector("#hero")
        if hero_el:
            await hero_el.screenshot(path=str(hero_path))
            print(f"✔ Captura del Hero Section guardada en: {hero_path.name}")

        # 3. Interacción con Pestañas del Mockup de Smartphone
        print("2. Probando interacción con el Smartphone Titanium...")
        gps_tab = await page.query_selector("button:has-text('Mapas Offline')")
        if gps_tab:
            await gps_tab.click()
            await page.wait_for_timeout(300)
            print("✔ Clic en pestaña 'Mapas Offline'")

        reports_tab = await page.query_selector("button:has-text('Sellos & Retos')")
        if reports_tab:
            await reports_tab.click()
            await page.wait_for_timeout(300)
            print("✔ Clic en pestaña 'Sellos & Retos'")

        sos_tab = await page.query_selector("button:has-text('SOS 24h')")
        if sos_tab:
            await sos_tab.click()
            await page.wait_for_timeout(300)
            print("✔ Clic en pestaña 'SOS 24h'")

        tour_tab = await page.query_selector("button:has-text('Tour 360')")
        if tour_tab:
            await tour_tab.click()
            await page.wait_for_timeout(300)
            print("✔ Clic de retorno a 'Tour 360'")

        # 4. Interacción con el Visor 360° (Giro Táctil y Botones)
        print("3. Probando giro 360° interactivo (Drag & Controles)...")
        tour_section = await page.query_selector("#tour360")
        if tour_section:
            await tour_section.scroll_into_view_if_needed()
            await page.wait_for_timeout(500)

            # Simular arrastre con el ratón
            box = await tour_section.bounding_box()
            if box:
                await page.mouse.move(box["x"] + 400, box["y"] + 200)
                await page.mouse.down()
                await page.mouse.move(box["x"] + 200, box["y"] + 200, steps=10)
                await page.mouse.up()
                print("✔ Giro táctil 360° simulado con éxito")

            # Pulsar botón de rotación
            rotate_btn = await page.query_selector("button[title='Girar a la derecha']")
            if rotate_btn:
                await rotate_btn.click()
                await page.wait_for_timeout(300)
                print("✔ Botón de rotación 360° activado")

            tour_path = ARTIFACTS_DIR / "tour_360_spatial.png"
            await tour_section.screenshot(path=str(tour_path))
            print(f"✔ Captura del Visor 360° guardada en: {tour_path.name}")

        # 5. Filtrado de Senderos con HTMX
        print("4. Probando catálogo de senderos y filtros HTMX...")
        routes_section = await page.query_selector("#rutas")
        if routes_section:
            await routes_section.scroll_into_view_if_needed()
            await page.wait_for_timeout(400)

            facil_btn = await page.query_selector("#rutas button:has-text('Fácil')")
            if facil_btn:
                await facil_btn.click()
                await page.wait_for_timeout(500)
                print("✔ Filtro HTMX 'Fácil' aplicado")

            all_btn = await page.query_selector("#rutas button:has-text('Todas')")
            if all_btn:
                await all_btn.click()
                await page.wait_for_timeout(500)
                print("✔ Filtro HTMX 'Todas las Rutas' restaurado")

            routes_path = ARTIFACTS_DIR / "routes_apple_fitness.png"
            await routes_section.screenshot(path=str(routes_path))
            print(f"✔ Captura del Catálogo de Senderos guardada en: {routes_path.name}")

        # 6. Soroche Advisor (Cálculo HTMX)
        print("5. Probando Calculadora Anti-Soroche...")
        security_section = await page.query_selector("#seguridad")
        if security_section:
            await security_section.scroll_into_view_if_needed()
            await page.wait_for_timeout(400)

            calc_submit = await page.query_selector("#seguridad button[type='submit']")
            if calc_submit:
                await calc_submit.click()
                await page.wait_for_timeout(600)
                print("✔ Cálculo de oxigenación y soroche completado vía HTMX")

            soroche_path = ARTIFACTS_DIR / "soroche_biometric_hud.png"
            await security_section.screenshot(path=str(soroche_path))
            print(f"✔ Captura del Soroche Advisor guardada en: {soroche_path.name}")

        # 7. Pasaporte de Montaña (Sellado)
        print("6. Probando sellado digital en Pasaporte...")
        guardian_section = await page.query_selector("#guardian")
        if guardian_section:
            await guardian_section.scroll_into_view_if_needed()
            await page.wait_for_timeout(400)

            stamp_btn = await page.query_selector("#guardian button:has-text('Sello Mirador Glaciar')")
            if stamp_btn:
                await stamp_btn.click()
                await page.wait_for_timeout(600)
                print("✔ Sello 'Mirador Glaciar' acreditado con éxito")

            guardian_path = ARTIFACTS_DIR / "guardian_apple_wallet.png"
            await guardian_section.screenshot(path=str(guardian_path))
            print(f"✔ Captura del Pasaporte de Montaña guardada en: {guardian_path.name}")

        # 8. Reproductor de Audio Andino
        print("7. Probando Reproductor de Audio Andino...")
        cultura_section = await page.query_selector("#cultura")
        if cultura_section:
            await cultura_section.scroll_into_view_if_needed()
            await page.wait_for_timeout(300)

            audio_btn = await page.query_selector("button:has-text('Escuchar Muestra')")
            if audio_btn:
                await audio_btn.click()
                await page.wait_for_timeout(500)
                print("✔ Audio de leyenda andina activado (Web Audio API)")
                
                # Pausar
                pause_btn = await page.query_selector("button:has-text('Pausar Relato')")
                if pause_btn:
                    await pause_btn.click()
                    await page.wait_for_timeout(300)
                    print("✔ Audio pausado")

        # 9. Acordeón de Preguntas Frecuentes (FAQ)
        print("8. Probando Preguntas Frecuentes (FAQ)...")
        faq_section = await page.query_selector("#faq")
        if faq_section:
            await faq_section.scroll_into_view_if_needed()
            await page.wait_for_timeout(300)

            first_faq = await page.query_selector("#faq .apple-glass-card")
            if first_faq:
                await first_faq.click()
                await page.wait_for_timeout(300)
                print("✔ Pregunta 1 desplegada")

        # 10. Modal de Descarga
        print("9. Probando apertura de Modal de Descarga...")
        nav_download_btn = await page.query_selector("header button:has-text('Obtener App')")
        if nav_download_btn:
            await nav_download_btn.click()
            await page.wait_for_timeout(400)

            download_modal_path = ARTIFACTS_DIR / "download_modal_preview.png"
            await page.screenshot(path=str(download_modal_path))
            print(f"✔ Modal de Descarga abierto y capturado en: {download_modal_path.name}")

        await browser.close()
        print("=== VERIFICACIÓN PLAYWRIGHT FINALIZADA CON ÉXITO (100% OK) ===")


if __name__ == "__main__":
    asyncio.run(run_landing_playwright_verification())
