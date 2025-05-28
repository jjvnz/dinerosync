# Dinerosync

**Dinerosync** es una aplicación móvil de finanzas personales construida con Flutter. Permite a los usuarios registrar, visualizar y gestionar ingresos y gastos de forma sencilla y visualmente atractiva.

## ✨ Características

* 📥 Registro de transacciones (ingresos/gastos)
* 📅 Filtro por rango de fechas
* 📊 Resumen financiero interactivo
* 💾 Almacenamiento local con Hive
* 🎨 Modo claro y oscuro
* 🔄 Actualización en tiempo real con Provider

## 📸 Capturas de pantalla

*(Agrega aquí imágenes de tu app si lo deseas)*

## 🚀 Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/tu_usuario/dinerosync.git
   cd dinerosync
   ```

2. Instala las dependencias:

   ```bash
   flutter pub get
   ```

3. Ejecuta la app en un emulador o dispositivo físico:

   ```bash
   flutter run
   ```

## 🧰 Tecnologías usadas

* [Flutter](https://flutter.dev/)
* [Hive](https://docs.hivedb.dev/)
* [Provider](https://pub.dev/packages/provider)
* [intl](https://pub.dev/packages/intl)

## 📁 Estructura del proyecto

* `/models`: Definición de modelos como `Transaction` y `Category`.
* `/providers`: Lógica y gestión del estado de la app (`FinanceProvider`).
* `/widgets`: Componentes reutilizables como formularios y listas.
* `main.dart`: Punto de entrada y configuración principal de la app.


<h2 style="text-align: center; margin: 40px 0 30px; color: #2c3e50; font-family: 'Segoe UI', Roboto, sans-serif; font-size: 28px; font-weight: 600;">
  🎨 Modern UI Showcase - Dinerosync
</h2>

<div style="
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 24px;
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
">
  <!-- Grupo 1 -->
  <div style="grid-column: span 2; text-align: center; margin-bottom: -10px;">
    <h3 style="color: #3498db; font-family: 'Segoe UI', Roboto, sans-serif;">Main Screens</h3>
  </div>
  
  <img src="https://github.com/user-attachments/assets/30e98b3f-032d-4e93-b4f2-5364495007f0" alt="UI right" class="ui-image">
  <img src="https://github.com/user-attachments/assets/32dc92e8-081b-4ae6-836a-f844e65cf24b" alt="UI portrait" class="ui-image">
  <img src="https://github.com/user-attachments/assets/b51eb759-581f-4d30-a49e-bdbd25b80c2f" alt="UI left" class="ui-image">
  <img src="https://github.com/user-attachments/assets/b7b6e722-367f-4def-8402-f43a2e927bfd" alt="UI landscape" class="ui-image">

  <!-- Grupo 2 -->
  <div style="grid-column: span 2; text-align: center; margin: 20px 0 -10px;">
    <h3 style="color: #3498db; font-family: 'Segoe UI', Roboto, sans-serif;">Transaction Flow</h3>
  </div>
  
  <img src="https://github.com/user-attachments/assets/36eea6e6-9260-4af0-865d-32febfd75e92" alt="UI 3 right" class="ui-image">
  <img src="https://github.com/user-attachments/assets/5240fbcd-51b0-429c-a385-79946a961440" alt="UI 3 portrait" class="ui-image">
  <img src="https://github.com/user-attachments/assets/33f9c326-b5d9-470f-a578-206b819ea46e" alt="UI 3 left" class="ui-image">
  <img src="https://github.com/user-attachments/assets/21aac83b-5458-491b-a938-272cf96ef46c" alt="UI 3 landscape" class="ui-image">

  <!-- Grupo 3 -->
  <div style="grid-column: span 2; text-align: center; margin: 20px 0 -10px;">
    <h3 style="color: #3498db; font-family: 'Segoe UI', Roboto, sans-serif;">Dashboard Views</h3>
  </div>
  
  <img src="https://github.com/user-attachments/assets/1723e01c-10f3-4dec-a274-bcafdb006548" alt="UI 2 right" class="ui-image">
  <img src="https://github.com/user-attachments/assets/b8ff34fb-4966-47e0-9a80-8ef1943b24f9" alt="UI 2 portrait" class="ui-image">
  <img src="https://github.com/user-attachments/assets/b368c083-78bf-416a-9379-e65c8edca35a" alt="UI 2 left" class="ui-image">
  <img src="https://github.com/user-attachments/assets/7082becd-6550-44ba-8ea3-4e7083bccde6" alt="UI 2 landscape" class="ui-image">

  <!-- Grupo 4 -->
  <div style="grid-column: span 2; text-align: center; margin: 20px 0 -10px;">
    <h3 style="color: #3498db; font-family: 'Segoe UI', Roboto, sans-serif;">Settings & Profile</h3>
  </div>
  
  <img src="https://github.com/user-attachments/assets/48c5fc69-1eb0-48fa-aea3-57a9f4a23cfc" alt="UI 1 right" class="ui-image">
  <img src="https://github.com/user-attachments/assets/d8342822-9f01-405b-80e3-cdd73d8b68ce" alt="UI 1 portrait" class="ui-image">
  <img src="https://github.com/user-attachments/assets/e8686f65-8281-4bce-aca5-7ae8739f4fa5" alt="UI 1 left" class="ui-image">
  <img src="https://github.com/user-attachments/assets/4f3c93db-565d-48a8-a618-1067c8148c96" alt="UI 1 landscape" class="ui-image">
</div>

<style>
  .ui-image {
    width: 100%;
    height: auto;
    max-height: 520px;
    object-fit: contain;
    border-radius: 12px;
    box-shadow: 0 6px 16px rgba(0,0,0,0.1);
    transition: all 0.3s ease;
    border: 1px solid #eee;
  }
  
  .ui-image:hover {
    transform: translateY(-5px);
    box-shadow: 0 12px 24px rgba(0,0,0,0.15);
  }
  
  @media (max-width: 768px) {
    div[style*="grid-template-columns"] {
      grid-template-columns: 1fr;
    }
  }
</style>


## 📝 Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

