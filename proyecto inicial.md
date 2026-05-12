# 📋 Plan de Implementación: Aplicación "Boutique" (Flutter + Firebase)

> ⚠️ **Nota sobre el IDE:** `Antigravity` no es un entorno de desarrollo reconocido para Flutter. El estándar industrial validado es **VS Code** (o Android Studio). Este plan está optimizado para VS Code, pero es completamente agnóstico al IDE.

---

## 🛠️ Fase 1: Preparación del Entorno y Herramientas Requeridas

| Categoría | Herramienta / Componente | Propósito |
|-----------|--------------------------|-----------|
| **SDK/Runtime** | Flutter SDK + Dart | Framework base y lenguaje |
| **IDE** | Visual Studio Code + Extensiones (`Flutter`, `Dart`, `Firebase`, `Error Lens`, `Pubspec Assist`) | Desarrollo, depuración y gestión de paquetes |
| **Control de versiones** | Git + GitHub/GitLab | Historial, colaboración y CI/CD |
| **Backend/Services** | Firebase CLI + Firebase Emulator Suite | Auth, Firestore, Storage, pruebas locales |
| **Diseño UI/UX** | Figma, Penpot o Adobe XD | Wireframes, prototipos, design system fashion/retail |
| **Testing** | Flutter `test`, `integration_test`, Firebase Test Lab | Validación multiplataforma y flujos críticos |

**Pasos de configuración:**
1. Instalar Flutter SDK y validar con `flutter doctor`.
2. Configurar VS Code con extensiones recomendadas y formateadores (`dart format`).
3. Instalar Firebase CLI y autenticar con `firebase login`.
4. Inicializar repositorio Git con estructura base de proyecto Flutter.
5. Configurar emuladores locales (Android/iOS/Web) para iteración rápida sin costos de cloud.

---

## 🎨 Fase 2: Diseño UI/UX y Arquitectura del Proyecto

### 2.1. Principios UI/UX para Boutique
- **Público objetivo:** Clientes finales (compradores), Administradores/Tienda.
- **Jerarquía visual:** Enfoque en fotografía de producto, claridad en precios/tallas, flujo de carrito/checkout sin fricción.
- **Experiencia:** Navegación intuitiva por categorías, filtros dinámicos, wishlist, historial de pedidos y seguimiento.
- **Accesibilidad:** Contraste WCAG AA, targets táctiles ≥48dp, soporte para lectores de pantalla.
- **Design System:** Paleta de marca (neutros + acento estacional), tipografía editorial, espaciado consistente, componentes reutilizables (`ProductCard`, `SizePicker`, `CartSummary`, `FilterSheet`).
- **Responsive:** Mobile-first, adaptación a tablet (grid 3-4 columnas) y web (sidebar de filtros + checkout desktop).

### 2.2. Arquitectura Propuesta
- **Patrón:** `Feature-first` + `Provider` para estado reactivo.
- **Capas:**
  - `presentation` (pantallas, widgets, rutas, temas)
  - `application` (servicios, repositorios, casos de uso)
  - `domain` (modelos: `Product`, `Order`, `User`, `CartItem`, enums de estado)
  - `core` (configuración, constantes, utilidades, validadores)
- **Navegación:** Enrutamiento declarativo (`go_router` o `auto_route`) con guardias de ruta para autenticación y roles.
- **Estado:** `Provider` con `ChangeNotifier` por feature + `StreamProvider` para sincronización en tiempo real (carrito, stock).

---

## 🔧 Fase 3: Configuración de Firebase y Dependencias

### 3.1. Consola Firebase
1. Crear proyecto: `boutique-app`.
2. Registrar apps para Android, iOS y Web.
3. Descargar y ubicar archivos de configuración en rutas nativas.
4. Habilitar **Authentication** → Método `Email/Password`.
5. Crear base de datos **Firestore** (modo prueba inicial, luego reglas por rol).
6. Activar **Cloud Storage** para imágenes de productos, banners y avatares.
7. (Opcional) Configurar índices compuestos para filtros (precio + categoría + disponibilidad).

### 3.2. Dependencias para `pubspec.yaml`
*(Listado conceptual para la sección `dependencies`)*

| Paquete | Función |
|---------|---------|
| `firebase_core` | Inicialización multiplataforma de Firebase |
| `firebase_auth` | Registro, login y recuperación con email+password |
| `cloud_firestore` | Lectura/escritura en tiempo real de catálogo, pedidos y usuario |
| `firebase_storage` | Carga/obtención de imágenes de productos y banners |
| `provider` | Gestión de estado, inyección de dependencias y reactividad |
| `go_router` / `auto_route` | Navegación estructurada, rutas protegidas y deep links |
| `cached_network_image` | Carga optimizada y cache de imágenes de catálogo |
| `flutter_svg` | Iconografía vectorial escalable (carrito, filtros, wishlist) |
| `intl` | Formateo de precios, fechas y localización (moneda regional) |
| `shared_preferences` | Persistencia ligera (tema, idioma, último filtro usado) |
| `flutter_staggered_grid_view` | Layouts tipo masonry para galerías de producto |
| `firebase_crashlytics` + `firebase_analytics` | Monitoreo de estabilidad y métricas de conversión |

**Pasos de integración:**
1. Agregar paquetes a `pubspec.yaml` con versiones compatibles.
2. Ejecutar `flutter pub get`.
3. Ejecutar `flutterfire configure` para generar `firebase_options.dart`.
4. Validar conflictos con `flutter pub outdated` y ajustar versiones.

---

## 🧩 Fase 4: Desarrollo por Módulos (Procedimiento Paso a Paso)

### 🔹 Módulo 1: Autenticación (Email + Password)
1. Definir rutas públicas (catálogo, detalle producto) y protegidas (carrito, perfil, pedidos).
2. Implementar servicio `AuthService` que envuelva `FirebaseAuth`.
3. Crear `AuthProvider` (`ChangeNotifier`) con estados: `user`, `isLoading`, `error`, `isAuthenticated`, `role`.
4. Construir pantallas: Login, Registro, Recuperación de contraseña, Verificación de email.
5. Validar formularios (formato email, complejidad contraseña, confirmación).
6. Manejar errores de Firebase (credenciales inválidas, email en uso, red) con feedback UI.
7. Validar persistencia de sesión y restauración de estado al abrir app.

### 🔹 Módulo 2: Base de Datos Firestore & Lógica E-commerce
1. Diseñar esquema de colecciones:
   - `users/{uid}`: perfil, direcciones, wishlist, rol (`customer`/`admin`).
   - `categories/{id}`: nombre, slug, imagen, orden de visualización.
   - `products/{id}`: nombre, descripción, precio, tallas, stock, imágenes[], categoría, activo, createdAt.
   - `carts/{uid}`: items[], total, updatedAt (sincronizado en tiempo real).
   - `orders/{id}`: userId, items[], subtotal, impuestos, total, estado (`pending`/`paid`/`shipped`/`delivered`/`cancelled`), dirección, fecha.
2. Crear capa de repositorios (`ProductRepository`, `CartRepository`, `OrderRepository`) que abstraigan Firestore.
3. Implementar métodos CRUD + streams para:
   - Catálogo con paginación y filtros.
   - Carrito sincronizado entre dispositivos.
   - Validación de stock antes de checkout.
4. Definir reglas de seguridad: lectura pública de productos/categorías, escritura protegida por `auth.uid` y rol.
5. Conectar repositorios con Providers para reflejar cambios en UI.

### 🔹 Módulo 3: Gestión de Estado con Provider
1. Crear `ChangeNotifier` por dominio: `AuthProvider`, `ProductProvider`, `CartProvider`, `OrderProvider`, `UIProvider`.
2. Inyectar en `main.dart` con `MultiProvider`.
3. Utilizar `Consumer` o `Selector` para minimizar reconstrucciones.
4. Implementar patrones de estado por feature: `Loading`, `Success`, `Error`, `Empty`, `OutOfStock`.
5. Centralizar lógica de carrito (agregar, quitar, actualizar cantidad, calcular totales, validar stock).
6. Manejar excepciones y notificaciones (snackbars, diálogos de confirmación, redirecciones post-compra).

### 🔹 Módulo 4: Implementación UI/UX Boutique
1. Traducir wireframes a widgets: Home con banners, grid de productos, detalle con galería/swipe, selección de talla/color.
2. Aplicar `ThemeData` global (paleta fashion, tipografía, radios de borde, elevaciones).
3. Construir componentes reutilizables: `ProductCard`, `PriceTag`, `SizeSelector`, `CartTile`, `CheckoutSummary`, `FilterBottomSheet`.
4. Implementar listas virtuales y paginación (`ListView.builder` + `PaginationController` o `StreamBuilder` con `limit`/`startAfter`).
5. Navegación fluida: transiciones, manejo de backstack, deep links para compartir productos.
6. Validar responsividad y modo claro/oscuro (imágenes adaptables, contrastes de texto).
7. Feedback visual: skeletons de carga, pull-to-refresh, badges de carrito, confirmaciones de acción.

---

## 🧪 Fase 5: Pruebas, Optimización y Despliegue

### 5.1. Estrategia de Testing
- **Unitarias:** Lógica de carrito, cálculo de totales, validación de stock, parsers de modelos.
- **Widget:** Formularios de login, grids de producto, comportamiento de UI ante estados vacíos/error.
- **Integración:** Flujos completos con Firebase Emulator Suite (Auth → Firestore → Storage).
- **E2E:** Navegación crítica, agregar al carrito → checkout simulado → creación de orden → historial.

### 5.2. Optimización
- Índices compuestos en Firestore para filtros frecuentes.
- Compresión y conversión a WebP/AVIF de imágenes de catálogo.
- Sincronización diferencial del carrito (evitar sobreescribir, usar `FieldValue.increment` o merge).
- Minimizar `setState`/reconstrucciones con `Selector` y `context.watch`/`context.read` adecuados.
- Perfilado con DevTools (CPU, memoria, red, layout shifts).

### 5.3. Preparación para Despliegue
1. Configurar íconos, splash screen y metadatos por plataforma.
2. Generar builds:
   - Android: `flutter build appbundle`
   - iOS: `flutter build ipa` (requiere macOS + Xcode)
   - Web: `flutter build web --release`
3. Configurar CI/CD (GitHub Actions, Codemagic o Fastlane).
4. Subir a tiendas (Play Console, App Store Connect) y Firebase Hosting (web).
5. Monitorear con Crashlytics y Analytics post-lanzamiento (eventos: `view_item`, `add_to_cart`, `begin_checkout`, `purchase`).

---

## 📌 Checklist de Validación Pre-Código

- [ ] Entorno Flutter + VS Code operativo y verificado con `flutter doctor`.
- [ ] Proyecto Firebase creado con Auth, Firestore y Storage activos.
- [ ] Dependencias definidas, versiones compatibles y `flutterfire configure` ejecutado.
- [ ] Wireframes y design system de boutique aprobados (catálogo, detalle, carrito, checkout).
- [ ] Estructura de carpetas `feature-first` + capas definidas.
- [ ] Esquema de colecciones Firestore documentado y reglas de seguridad iniciales redactadas.
- [ ] Flujos de navegación, estados de pantalla y protección de rutas mapeados.
- [ ] Estrategia de testing y plan de optimización de rendimiento validados.

---

✅ **Siguiente paso recomendado:** Una vez valides este plan, puedo generar el código inicial estructurado (configuración de `main.dart`, `firebase_options.dart`, esqueleto de carpetas, `pubspec.yaml` listo, providers base, rutas protegidas y repositorios Firestore). Indícame si deseas priorizar algún módulo (ej. carrito en tiempo real, filtros avanzados o panel de administración) o ajustar el nivel de complejidad antes de continuar.
<img width="824" height="329" alt="image" src="https://github.com/user-attachments/assets/7b6c66d3-3dc3-4f25-90fe-b52a0d5857df" />
<img width="805" height="339" alt="image" src="https://github.com/user-attachments/assets/f8f5dc56-72ce-4a87-9f64-3e29b87217be" />
<img width="801" height="304" alt="image" src="https://github.com/user-attachments/assets/85c59fa0-94a9-46f2-b368-1cad70c835af" />

