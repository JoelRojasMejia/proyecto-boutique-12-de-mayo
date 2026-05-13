# 📘 PLAN MAESTRO DE IMPLEMENTACIÓN: Aztro Boutique (Flutter + Dart)

A continuación, presento un documento arquitectónico, de diseño y de implementación completo, estructurado para garantizar que el desarrollo de **Aztro Boutique** sea escalable, mantenible, seguro y centrado en la experiencia del usuario. Este plan cubre desde la identidad visual hasta la arquitectura de datos, dependencias, estructura de proyecto, flujos de usuario, seguridad, pruebas y despliegue. **No se incluye código fuente**, solo documentación técnica, estratégica y de diseño.

---

## 🎨 1. SISTEMA DE DISEÑO UI/UX Y PALETA DE COLORES

### 1.1 Filosofía de Diseño UX
- **Minimalismo con impacto**: La interfaz prioriza la fotografía de producto, el espacio en blanco y la jerarquía visual clara. Los elementos decorativos se usan solo para reforzar la identidad de marca.
- **Navegación intuitiva**: Máximo tres toques para llegar a cualquier producto. Checkout optimizado en máximo cuatro pasos.
- **Microinteracciones**: Feedback táctil en botones, transiciones suaves entre pantallas, estados de carga elegantes (shimmer, skeleton loaders) y animaciones de confirmación de compra.
- **Accesibilidad**: Contraste WCAG AA mínimo, tipografía escalable, soporte para lectores de pantalla, estados de error claros y recuperación de flujo.
- **Consistencia multiplataforma**: Layouts adaptativos para iOS, Android y Web. Uso de `SafeArea`, `MediaQuery` y breakpoints para tablets y escritorios.

### 1.2 Paleta de Colores y Mapeo de Componentes

| Componente UI | Color Principal | Código Hex | Uso y Propósito |
|---------------|----------------|------------|-----------------|
| Color Primario (Marca) | Rojo Borgoña Intenso | `#8B0015` | AppBar, botones principales, enlaces activos, indicadores de selección |
| Color Primario Claro | Rojo Rubí | `#C41E3A` | Hover, estados de foco, badges de descuento, acentos secundarios |
| Fondo Principal | Crema Suave | `#FAF8F5` | Pantallas generales, contenedores de listas, área de contenido |
| Fondo Secundario | Blanco Puro | `#FFFFFF` | Tarjetas de producto, modales, inputs, checkout |
| Texto Primario | Carbón Profundo | `#1A1A1A` | Títulos, descripciones, precios, etiquetas principales |
| Texto Secundario | Gris Acero | `#6B7280` | Subtítulos, placeholders, metadatos, fechas, estados secundarios |
| Acento de Lujo | Oro Muted | `#B8860B` | Iconos de wishlist, estrellas de calificación, bordes de ofertas especiales |
| Borde/Divisor | Gris Perla | `#E5E7EB` | Separadores de secciones, contornos de inputs, tablas de resumen |
| Estado Correcto | Verde Bosque | `#2E7D32` | Confirmaciones, stock disponible, pagos exitosos |
| Estado Error/Alerta | Rojo Alerta | `#D32F2F` | Validaciones fallidas, errores de red, stock agotado |
| Fondo Oscuro (Modo Nocturno) | Negro Azabache | `#121212` | Alternativa para dark mode, mantiene contraste con textos claros |
| Superposición/Overlay | Negro Semi-translúcido | `#00000040` | Backdrops, modales, galerías de imágenes en pantalla completa |

### 1.3 Tipografía Recomendada
- **Títulos**: Tipografía serif elegante (ej. Playfair Display, Cormorant Garamond) para transmitir sofisticación de boutique.
- **Cuerpo/Interfaz**: Sans-serif geométrica y legible (ej. Inter, Manrope, SF Pro) para máxima claridad en móviles.
- **Escala base**: 16px cuerpo, 1.25 ratio de incremento. Espaciado generoso entre líneas y márgenes internos.

---

## 🗃️ 2. ENTIDADES DE BASE DE DATOS Y MODELOS DE DATOS (1-20)

Cada entidad se mapeará a un Modelo en Dart con serialización/deserialización JSON, validación de tipos, inmutabilidad (preferible) y métodos de conversión. Se explican relaciones, índices recomendados y lógica de negocio.

1. **users**
   - Propósito: Perfil central del cliente o administrador.
   - Relaciones: 1:N con `addresses`, `carts`, `orders`, `reviews`, `notifications`, `wishlists`.
   - Modelo: Campos inmutables excepto `updatedAt`. `role` define acceso (customer, admin, moderator). `wishlist` y `addresses` son sub-documentos embebidos para lectura rápida, pero normalizados en Firestore para escrituras concurrentes seguras.

2. **addresses**
   - Propósito: Direcciones de envío y facturación.
   - Relaciones: N:1 con `users`. Referenciado en `orders`.
   - Modelo: Validación de formato de código postal y teléfono por país. `isDefault` único por usuario. Geocodificación opcional para cálculo de envío.

3. **categories**
   - Propósito: Organización jerárquica o plana de productos.
   - Modelo: `slug` para URLs amigables y filtrado. `displayOrder` para orden en UI. Caché en cliente para evitar lecturas repetidas.

4. **products**
   - Propósito: Catálogo principal.
   - Relaciones: 1:N con `product_variants`, `product_images`, `reviews`. 1:1 con `categories`.
   - Modelo: Cálculo de `rating` promedio y `reviewCount` vía agregación o triggers de servidor. `discountPrice` opcional. Estados de activo/destacado para filtros UI.

5. **product_variants**
   - Propósito: Combinaciones de talla/color con stock y SKU independientes.
   - Modelo: Relación directa con `products`. `stock` se actualiza atómicamente. `sku` único global para inventario y facturación.

6. **product_images**
   - Propósito: Galería multimedia por producto.
   - Modelo: `displayOrder` para carrusel principal. `altText` para accesibilidad y SEO en web. Referencias a URLs de Firebase Storage.

7. **carts**
   - Propósito: Carrito persistente por usuario o sesión anónima.
   - Modelo: `total`, `subtotal`, `taxes` calculados en tiempo real o vía función serverless. Actualizado en cada cambio de item. TTL o limpieza automática tras 30 días de inactividad.

8. **cart_items**
   - Propósito: Detalle de productos en carrito.
   - Relaciones: N:1 con `carts`, `products`, `product_variants`.
   - Modelo: `totalPrice` = `unitPrice` * `quantity`. Validación de stock antes de checkout.

9. **orders**
   - Propósito: Registro de compra final.
   - Modelo: Estados: pending, confirmed, processing, shipped, delivered, cancelled. `paymentStatus`: unpaid, paid, refunded. Inmutable tras creación excepto `status` y `updatedAt`.

10. **order_items**
    - Propósito: Líneas de detalle de pedido.
    - Modelo: Denormalización intencional de `productName` y `unitPrice` para historial inalterable. Relación con `orders`.

11. **payments**
    - Propósito: Registro de transacciones financieras.
    - Modelo: `method`: card, paypal, cash_on_delivery, etc. `transactionId` único externo. `status` sincronizado con pasarela. Nunca almacena datos sensibles de tarjetas.

12. **reviews**
    - Propósito: Valoraciones y comentarios públicos.
    - Modelo: Relación con `productId` y `userId`. Moderación administrativa opcional. `rating` 1-5. Fecha de creación para orden cronológico.

13. **wishlists**
    - Propósito: Lista de deseos por usuario.
    - Modelo: `productIds` como array para consultas rápidas. Sincronización cruzada con `users.wishlist` si se desea redundancia optimizada.

14. **banners**
    - Propósito: Promociones visuales en home.
    - Modelo: `startDate`/`endDate` para activación automática. `isActive` para toggle manual. `redirectUrl` puede apuntar a categoría, producto o URL externa.

15. **coupons**
    - Propósito: Descuentos y promociones.
    - Modelo: `type`: percentage, fixed, free_shipping. Validación de `minPurchase`, `usedCount < maxUses`, `expiresAt > now`. `code` en mayúsculas, sin espacios.

16. **notifications**
    - Propósito: Alertas push e in-app.
    - Modelo: `type`: order_update, promo, system, review_reply. `isRead` para gestión de bandeja. TTL configurable para evitar sobrecarga de BD.

17. **analytics_events**
    - Propósito: Rastreo de comportamiento y funnel.
    - Modelo: `eventName` estandarizado (view_item, add_to_cart, begin_checkout, purchase). `metadata` como mapa flexible para parámetros adicionales. Integración con Firebase Analytics para agregación.

18. **inventory_movements**
    - Propósito: Auditoría de stock.
    - Modelo: `type`: sale, restock, return, adjustment, damage. Relación con `productId` y `variantId`. Base para reportes de inventario y reconciliación.

19. **roles_permissions**
    - Propósito: Control de acceso administrativo.
    - Modelo: `role` mapeado a `users.role`. `permissions` como array de strings (manage_products, view_orders, manage_coupons, etc.). Evaluado en reglas de seguridad y middleware de UI.

20. **settings**
    - Propósito: Configuración global del negocio.
    - Modelo: Documento singleton. `currency`, `taxRate`, `shippingBaseCost` usados en cálculo de checkout. `supportEmail` para contacto y recuperación. `maintenanceMode` bloquea acceso temporalmente con mensaje UI.

---

## 📁 3. ESTRUCTURA DE CARPETAS Y ARCHIVOS DEL PROYECTO

```
aztro_boutique/
├── assets/
│   ├── images/
│   ├── fonts/
│   ├── icons/
│   └── lottie/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   ├── utils/
│   │   ├── network/
│   │   ├── security/
│   │   └── storage/
│   ├── models/
│   ├── services/
│   ├── repositories/
│   ├── state/
│   ├── features/
│   │   ├── auth/
│   │   ├── onboarding/
│   │   ├── home/
│   │   ├── catalog/
│   │   ├── product/
│   │   ├── cart/
│   │   ├── checkout/
│   │   ├── orders/
│   │   ├── profile/
│   │   ├── wishlist/
│   │   ├── reviews/
│   │   ├── notifications/
│   │   ├── coupons/
│   │   ├── admin/
│   │   └── settings/
│   ├── shared/
│   │   ├── widgets/
│   │   ├── layouts/
│   │   ├── dialogs/
│   │   ├── templates/
│   │   └── animations/
│   ├── routes/
│   └── di/
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
├── docs/
└── pubspec.yaml
```

**Notas de arquitectura:**
- `features/` sigue el enfoque Feature-First. Cada característica contiene su propio árbol: `presentation/`, `domain/`, `data/`.
- `state/` aloja la gestión de estado global (Riverpod/Provider/Bloc según elección).
- `shared/templates/` contiene scaffolds reutilizables (skeletons, empty states, error banners, list shells).
- `di/` maneja inyección de dependencias para servicios y repositorios.
- `test/` separado por capas para cobertura completa.

---

## 📦 4. DEPENDENCIAS REQUERIDAS (pubspec.yaml)

Lista numerada con propósito y categoría. Las versiones se manejarán mediante semver actualizado al momento de la creación del proyecto.

**Núcleo y Estado**
1. flutter_riverpod (o flutter_bloc) – Gestión de estado reactivo y inyección.
2. freezed_annotation + build_runner + freezed – Generación de modelos inmutables y serialización.
3. json_annotation + json_serializable – Mapeo JSON bidireccional seguro.
4. flutter_hooks / provider – Alternativas según arquitectura elegida.

**Firebase y Backend (Antigravity + Console)**
5. firebase_core – Inicialización de SDK.
6. firebase_auth – Autenticación por email/password y sesión.
7. cloud_firestore – Base de datos en tiempo real y consultas.
8. firebase_storage – Gestión de imágenes y multimedia.
9. firebase_messaging – Notificaciones push.
10. firebase_analytics – Rastreo de eventos y funnel.
11. firebase_crashlytics – Reporte de errores en producción.

**Navegación y Routing**
12. go_router – Enrutamiento declarativo, deeplinks y autenticación guards.

**UI y Experiencia**
13. cached_network_image – Caché y optimización de imágenes remotas.
14. flutter_svg – Renderizado de iconos y vectores escalables.
15. carousel_slider / flutter_swiper – Carruseles de banners y productos.
16. flutter_staggered_grid_view – Grids responsivos para catálogo.
17. flutter_rating_bar – Calificación de productos.
18. lottie_flutter – Animaciones de carga, éxito y microinteracciones.
19. shimmer – Skeleton loaders para estados de carga.
20. google_fonts / flutter_localized_fonts – Tipografías externas.

**Formularios y Validación**
21. formz / flutter_form_builder – Validación reactiva y tipos seguros.
22. input_mask / intl_phone_number_input – Formato de teléfonos y códigos postales.

**Utilidades y Almacenamiento Local**
23. shared_preferences / hive – Persistencia ligera de configuraciones y sesión.
24. intl – Formato de fechas, monedas y localización.
25. url_launcher – Apertura de enlaces externos y redes sociales.
26. uuid – Generación de identificadores locales antes de sync con BD.
27. envied / flutter_dotenv – Variables de entorno seguras.

**Seguridad y Red**
28. crypto – Hashing para firmas locales y checksums.
29. http / dio – Cliente HTTP para APIs externas (pasarelas, geocodificación).
30. flutter_secure_storage – Almacenamiento cifrado de tokens sensibles.

**Pruebas y Calidad**
31. mocktail / mockito – Simulación de dependencias.
32. flutter_test – Framework nativo de pruebas.
33. integration_test – Pruebas E2E multiplataforma.
34. very_good_analysis / custom_lint – Linting y estándares de código.

---

## 🛠️ 5. PROCEDIMIENTO PASO A PASO PARA LA IMPLEMENTACIÓN

### FASE 1: Configuración Inicial y Entorno
1. Instalar SDK de Flutter estable y configurar PATH.
2. Verificar compatibilidad multiplataforma (Android, iOS, Web).
3. Inicializar proyecto con nombre `aztro_boutique` y organización corporativa.
4. Configurar linter, formateador y convenciones de nomenclatura.
5. Crear repositorio Git con ramas: `main`, `develop`, `feature/*`, `hotfix/*`.

### FASE 2: Integración Antigravity + Firebase Console
1. Crear proyecto en Firebase Console (desarrollo y producción).
2. Registrar apps iOS, Android y Web. Descargar configuraciones oficiales.
3. Vincular Antigravity como entorno de desarrollo/backend sync.
4. Configurar Firebase Auth con método Email/Password. Habilitar verificación de email.
5. Crear colecciones Firestore según las 20 entidades. Definir índices compuestos para consultas frecuentes.
6. Configurar Firebase Storage con rutas `/products/`, `/banners/`, `/users/`.
7. Establecer reglas de seguridad iniciales (solo lectura pública, escritura autenticada, validación de roles).

### FASE 3: Arquitectura y Estructura
1. Implementar árbol de carpetas definido.
2. Configurar inyección de dependencias y módulos por capa.
3. Definir router principal con protección de rutas (auth guard, admin guard).
4. Crear sistema de temas (claro/oscuro) y tokens de diseño.

### FASE 4: Capa de Datos y Modelos
1. Generar clases modelo para las 20 entidades con serialización segura.
2. Implementar repositorios por entidad (interfaz + implementación Firestore).
3. Configurar streams y listeners para datos en tiempo real (carrito, stock, notificaciones).
4. Establecer caché local para categorías, configuración y banners.

### FASE 5: Autenticación y Perfil
1. Implementar registro, inicio de sesión, recuperación de contraseña y verificación.
2. Crear flujo de onboarding opcional (permisos, preferencias).
3. Desarrollar pantalla de perfil con edición de datos, gestión de direcciones y cambio de contraseña.
4. Implementar logout seguro y limpieza de estado.

### FASE 6: Catálogo y Productos
1. Construir pantalla Home con banners, categorías destacadas y productos recomendados.
2. Implementar listado de productos con filtros (categoría, precio, talla, color, disponibilidad).
3. Desarrollar detalle de producto: galería, selector de variantes, calculadora de precio, reseñas.
4. Optimizar carga de imágenes con lazy loading, precarga y compresión en storage.

### FASE 7: Carrito y Checkout
1. Implementar carrito persistente con sync en tiempo real.
2. Validar stock y aplicar cupones antes de checkout.
3. Diseñar flujo de checkout: dirección → método de pago → resumen → confirmación.
4. Integrar pasarela de pago (Stripe, MercadoPago, etc.) mediante SDK oficial o API server-side.
5. Generar orden y registrar movimiento de inventario.

### FASE 8: Órdenes, Reseñas y Notificaciones
1. Historial de órdenes con estados y tracking.
2. Sistema de reseñas con moderación y cálculo de promedio.
3. Notificaciones push e in-app para cambios de estado y promociones.
4. Wishlists con sync cruzado y notificaciones de baja de stock.

### FASE 9: Administración y Configuración
1. Panel interno o ruta protegida para gestión de productos, pedidos y cupones.
2. Dashboard con métricas clave (ventas, conversión, stock crítico).
3. Edición de `settings` globales y modo mantenimiento.
4. Exportación de reportes CSV/PDF.

### FASE 10: Optimización, Pruebas y Despliegue
1. Auditoría de rendimiento: profiling, reducción de rebuilds, lazy imports.
2. Pruebas unitarias (modelos, utilidades), widget (UI states), integración (flujos completos).
3. Configuración de CI/CD para builds automáticos y distribución.
4. Despliegue a Play Store, App Store y Web. Verificación de políticas y accesibilidad.
5. Monitoreo post-lanzamiento con Crashlytics y Analytics. Iteración basada en datos.

---

## 🧭 6. FLUJOS DE USUARIO Y ARQUITECTURA DE PANTALLAS

1. **Onboarding → Auth**: Splash animado → Slides de valor → Registro/Login → Verificación → Home.
2. **Exploración**: Home (banners + destacados) → Categorías → Listado filtrado → Detalle producto.
3. **Conversión**: Agregar al carrito → Revisar carrito → Aplicar cupón → Checkout (dirección + pago) → Confirmación → Notificación.
4. **Post-Venta**: Historial de órdenes → Tracking → Reseña → Soporte.
5. **Perfil**: Datos personales → Direcciones → Wishlist → Notificaciones → Configuración → Logout.

**Microestados manejados en UI:**
- Empty states ilustrados (carrito vacío, sin órdenes, sin reseñas).
- Loading states con shimmer y skeleton adaptativos.
- Error states con retry, fallback offline y mensajes claros.
- Success states con confetti sutil y redirección automática.

---

## 🔒 7. ESTRATEGIAS DE SEGURIDAD, RENDIMIENTO Y BUENAS PRÁCTICAS

### Seguridad
- Reglas de Firestore estrictas: validación de tipo, tamaño y permisos por rol.
- Nunca almacenar secretos de pago en cliente. Usar Cloud Functions para crear intents de pago.
- Sanitización de inputs y validación de esquemas en modelo y capa de repositorio.
- Tokens de sesión gestionados por Firebase Auth. Revocación en logout.
- Cumplimiento de GDPR/LOPD: consentimiento de cookies, exportación/eliminación de datos, política de privacidad integrada.

### Rendimiento
- Uso de `ListView.builder` y `GridView.builder` con `cacheExtent`.
- Paginación virtual (Firestore `limit` + `startAfterDocument`).
- Imágenes en WebP/AVIF, tamaños responsivos (`?width=`, `?quality=` en Storage).
- Debounce en búsquedas y filtros.
- Estado global optimizado: solo escuchar cambios relevantes, evitar rebuilds innecesarios.
- Offline first: caché de catálogo y carrito, sincronización diferida.

### Mantenibilidad
- Principio de responsabilidad única por archivo/clase.
- Documentación de API interna y flujos de datos.
- Versionado semántico y changelog estructurado.
- Linters y formatters automáticos en pre-commit hooks.

---

## 🧪 8. PLAN DE PRUEBAS, QA Y DESPLIEGUE

### Estrategia de Pruebas
- **Unitarias**: Modelos, validaciones, cálculos de precios, impuestos, descuentos.
- **Widget**: Botones, formularios, listas, estados de carga/error, temas.
- **Integración**: Flujo auth → añadir al carrito → checkout → orden creada.
- **E2E**: Simulación de pasarela en sandbox, notificaciones push, deep links.

### QA y Certificación
- Matriz de dispositivos mínimos (Android 10+, iOS 15+, Chrome/Safari modernos).
- Validación de accesibilidad (lectores de pantalla, contraste, navegación por teclado).
- Pruebas de carga con múltiples usuarios simultáneos en Firestore.
- Revisión de políticas de Apple/Google (compras in-app, privacidad, metadatos).

### Despliegue
- Entornos: `dev` → `staging` → `production` con proyectos Firebase separados.
- CI/CD con GitHub Actions/GitLab CI: build, test, analyze, generate APK/IPA/Web deploy.
- Distribución interna vía TestFlight/Firebase App Distribution.
- Lanzamiento escalonado: 10% → 50% → 100% con monitoreo de crash rate y métricas de conversión.
- Rollback automático si tasa de errores > 2%.

---

## 🏁 9. CONCLUSIÓN Y PRÓXIMOS PASOS

Este plan establece los cimientos técnicos, visuales y operativos para **Aztro Boutique**. La arquitectura propuesta prioriza la escalabilidad, la seguridad y la experiencia de usuario, aprovechando la sinergia entre Flutter/Dart y Firebase gestionado desde Antigravity. 

**Próximos pasos recomendados:**
1. Validar la paleta de colores y tipografía con stakeholders de marca.
2. Definir pasarela de pago y configuración fiscal local.
3. Establecer cronograma por sprints (2 semanas) con entregables medibles.
4. Configurar entorno de staging y pipeline de CI/CD antes del primer commit de producción.
5. Realizar sesión de UX testing con usuarios reales en prototipo navegable.

Con esta guía, el equipo de desarrollo tendrá una ruta clara, sin ambigüedades, optimizada para entregas de alta calidad y mantenimiento a largo plazo. Si deseas profundizar en alguna fase específica (reglas de seguridad, flujo de checkout, estrategia de estado, o plan de métricas), puedo expandir cada sección con mayor detalle operativo.
