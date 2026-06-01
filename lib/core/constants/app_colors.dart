import 'package:flutter/material.dart';

abstract class AppColors {

  // ── PRIMARIOS ──────────────────────────────────────────────
  /// Borgoña Intenso — botones principales, AppBar, acentos de marca
  static const Color primary       = Color(0xFF8B0015);
  /// Rojo Rubí — hover, focus states, badges de alerta
  static const Color primaryLight  = Color(0xFFC41E3A);
  /// Borgoña Oscuro — pressed states, sombras de botón
  static const Color primaryDark   = Color(0xFF5C0010);

  // ── FONDOS ────────────────────────────────────────────────
  /// Crema Suave — fondo general de la app
  static const Color background    = Color(0xFFFAF8F5);
  /// Blanco Puro — tarjetas, modales, inputs
  static const Color surface       = Color(0xFFFFFFFF);
  /// Crema Muted — inputs deshabilitados, chips sin seleccionar
  static const Color surfaceVariant = Color(0xFFF5F0EC);

  // ── TEXTO ─────────────────────────────────────────────────
  /// Carbón — títulos principales, precios, nombres de producto
  static const Color textPrimary   = Color(0xFF1A1A1A);
  /// Gris Acero — subtítulos, descripcion corta, metadatos
  static const Color textSecondary = Color(0xFF6B7280);
  /// Gris Claro — placeholders, texto deshabilitado
  static const Color textDisabled  = Color(0xFFB0B7C3);
  /// Blanco — texto sobre fondos oscuros/borgoña
  static const Color textOnDark    = Color(0xFFFFFFFF);

  // ── ACENTO LUJO ───────────────────────────────────────────
  /// Oro Muted — wishlist hearts, rating stars, badges premium
  static const Color accentGold    = Color(0xFFB8860B);
  /// Oro Brillante — hover sobre elementos dorados
  static const Color accentGoldLight = Color(0xFFD4A017);
  /// Oro Oscuro — pressed sobre elementos dorados
  static const Color accentGoldDark  = Color(0xFF8B6508);

  // ── SEMÁNTICOS ────────────────────────────────────────────
  /// Verde Bosque — stock disponible, confirmaciones, pedido entregado
  static const Color success       = Color(0xFF2E7D32);
  static const Color successLight  = Color(0xFFE8F5E9);
  /// Rojo Alerta — validaciones de formulario, errores
  static const Color error         = Color(0xFFD32F2F);
  static const Color errorLight    = Color(0xFFFFEBEE);
  /// Naranja — advertencias, pedido procesando
  static const Color warning       = Color(0xFFF57C00);
  static const Color warningLight  = Color(0xFFFFF3E0);
  /// Azul — pedido enviado, información
  static const Color info          = Color(0xFF0288D1);
  static const Color infoLight     = Color(0xFFE1F5FE);

  // ── PREMIUM (Colección Exclusiva) ─────────────────────────
  /// Negro Cálido — fondo de pantalla premium
  static const Color premiumBg     = Color(0xFF1A1008);
  /// Marrón Oscuro Elegante — tarjetas en pantalla premium
  static const Color premiumSurface = Color(0xFF2D2318);
  /// Borde Dorado — contorno de tarjetas premium
  static const Color premiumBorder = Color(0xFFB8860B);
  /// Crema Dorada — texto principal en pantalla premium
  static const Color premiumText   = Color(0xFFF5E6C8);
  /// Blanco Cálido — texto secundario en pantalla premium
  static const Color premiumTextSecondary = Color(0xFFD4C5A9);

  // ── SISTEMA ───────────────────────────────────────────────
  /// Gris Suave — líneas divisorias, separadores
  static const Color divider       = Color(0xFFE5E7EB);
  /// Negro 10% — sombra estándar de tarjetas
  static const Color shadow        = Color(0x1A000000);
  /// Negro 15% — sombra elevada de modales
  static const Color shadowElevated = Color(0x26000000);
  /// Negro 50% — overlay de modales y bottom sheets
  static const Color overlay       = Color(0x80000000);
  /// Dorado 25% — glow de tarjetas premium
  static const Color goldGlow      = Color(0x40B8860B);
}
