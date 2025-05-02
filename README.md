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

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo [LICENSE](LICENSE) para más detalles.

