import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Servicio de datos iniciales para PChop – Tienda de Electrónica.
class SeedData {
  static const String _adminEmail = 'Admin123@gmail.com';
  static const String _adminUid   = 'admin_pchop_001';

  static Future<void> seedDatabase() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    try {
      // ── Verificar si ya están las categorías ──────────────────────────
      final categoriesSnapshot =
          await db.collection('categorias').limit(1).get();
      if (categoriesSnapshot.docs.isNotEmpty) {
        debugPrint('Base de datos ya poblada. Omitiendo seeding de productos.');
        // Aun así, garantizar que el documento del admin exista en Firestore
        await _ensureAdminUser(db);
        return;
      }

      debugPrint('Iniciando seeding de datos de electrónica en Firestore...');

      // ── Categorías de electrónica ─────────────────────────────────────
      final categories = [
        {
          'id': 'cat_tel',
          'nombre': 'Teléfonos',
          'descripcion': 'Smartphones y teléfonos inteligentes de las mejores marcas',
          'imagenUrl':
              'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&q=80&w=600',
          'orden': 1,
        },
        {
          'id': 'cat_aud',
          'nombre': 'Audífonos',
          'descripcion': 'Auriculares, earbuds y headsets con la mejor calidad de sonido',
          'imagenUrl':
              'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=600',
          'orden': 2,
        },
        {
          'id': 'cat_per',
          'nombre': 'Periféricos',
          'descripcion': 'Teclados, ratones, gamepads y accesorios para PC y consola',
          'imagenUrl':
              'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&q=80&w=600',
          'orden': 3,
        },
        {
          'id': 'cat_lap',
          'nombre': 'Laptops',
          'descripcion': 'Portátiles para trabajo, estudio y gaming de alto rendimiento',
          'imagenUrl':
              'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&q=80&w=600',
          'orden': 4,
        },
        {
          'id': 'cat_mon',
          'nombre': 'Monitores',
          'descripcion': 'Pantallas Full HD, 4K y gaming para profesionales y gamers',
          'imagenUrl':
              'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&q=80&w=600',
          'orden': 5,
        },
        {
          'id': 'cat_com',
          'nombre': 'Componentes',
          'descripcion': 'CPUs, GPUs, RAM, almacenamiento y todo para armar tu PC',
          'imagenUrl':
              'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&q=80&w=600',
          'orden': 6,
        },
      ];

      for (final cat in categories) {
        await db.collection('categorias').doc(cat['id'] as String).set({
          'nombre':      cat['nombre'],
          'descripcion': cat['descripcion'],
          'imagenUrl':   cat['imagenUrl'],
          'orden':       cat['orden'],
        });
      }

      // ── Productos de electrónica ──────────────────────────────────────
      final products = [
        // Teléfonos
        {
          'prodId':          'prod_ip15',
          'categoriaId':     'cat_tel',
          'categoriaNombre': 'Teléfonos',
          'nombre':          'iPhone 15 Pro Max',
          'descripcion':     'El smartphone más avanzado de Apple. Chip A17 Pro, sistema de cámara pro con zoom óptico 5x y pantalla Super Retina XDR de 6.7".',
          'precio':          1199.99,
          'stock':           10,
          'imagenUrl':       'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       true,
        },
        {
          'prodId':          'prod_s24',
          'categoriaId':     'cat_tel',
          'categoriaNombre': 'Teléfonos',
          'nombre':          'Samsung Galaxy S24 Ultra',
          'descripcion':     'Rendimiento extremo con Snapdragon 8 Gen 3, pantalla Dynamic AMOLED 2X de 6.8" a 120Hz y cámara de 200 MP con zoom 100x.',
          'precio':          1299.99,
          'stock':           8,
          'imagenUrl':       'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       true,
        },
        // Audífonos
        {
          'prodId':          'prod_sony_xm5',
          'categoriaId':     'cat_aud',
          'categoriaNombre': 'Audífonos',
          'nombre':          'Sony WH-1000XM5',
          'descripcion':     'Los mejores auriculares inalámbricos del mercado. Cancelación de ruido líder de la industria, 30h de batería y sonido Hi-Res Audio.',
          'precio':          349.99,
          'stock':           20,
          'imagenUrl':       'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       true,
        },
        {
          'prodId':          'prod_airpods_pro',
          'categoriaId':     'cat_aud',
          'categoriaNombre': 'Audífonos',
          'nombre':          'AirPods Pro 2da Gen',
          'descripcion':     'Cancellación activa de ruido adaptativa, audio espacial personalizado y resistencia al agua IPX4. Estuche MagSafe incluido.',
          'precio':          249.99,
          'stock':           25,
          'imagenUrl':       'https://images.unsplash.com/photo-1606741965429-02919b2ad8c4?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       false,
        },
        // Periféricos
        {
          'prodId':          'prod_kbd_mech',
          'categoriaId':     'cat_per',
          'categoriaNombre': 'Periféricos',
          'nombre':          'Teclado Mecánico Keychron Q1 Pro',
          'descripcion':     'Teclado mecánico inalámbrico 75% con switches Gateron Pro, cuerpo de aluminio CNC y retroiluminación RGB completa.',
          'precio':          199.99,
          'stock':           15,
          'imagenUrl':       'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       true,
        },
        {
          'prodId':          'prod_mouse_gaming',
          'categoriaId':     'cat_per',
          'categoriaNombre': 'Periféricos',
          'nombre':          'Logitech G Pro X Superlight 2',
          'descripcion':     'Ratón gaming ultraligero de 60g con sensor HERO 2 de 32000 DPI, tecnología LIGHTSPEED inalámbrica y 95h de batería.',
          'precio':          159.99,
          'stock':           18,
          'imagenUrl':       'https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       false,
        },
        // Laptops
        {
          'prodId':          'prod_mbp_m3',
          'categoriaId':     'cat_lap',
          'categoriaNombre': 'Laptops',
          'nombre':          'MacBook Pro 14" M3 Pro',
          'descripcion':     'Potencia profesional con chip M3 Pro de 11 núcleos, pantalla Liquid Retina XDR de 14.2", 18GB de RAM unificada y hasta 22h de batería.',
          'precio':          1999.99,
          'stock':           5,
          'imagenUrl':       'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       true,
        },
        {
          'prodId':          'prod_rog_zephyrus',
          'categoriaId':     'cat_lap',
          'categoriaNombre': 'Laptops',
          'nombre':          'ASUS ROG Zephyrus G16',
          'descripcion':     'Laptop gaming de élite con AMD Ryzen 9, RTX 4090 16GB, pantalla OLED 2.5K a 240Hz y chasis de aluminio ultradelgado.',
          'precio':          2499.99,
          'stock':           4,
          'imagenUrl':       'https://images.unsplash.com/photo-1593642702821-c8da6771f0c6?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       false,
        },
        // Monitores
        {
          'prodId':          'prod_lg_ultragear',
          'categoriaId':     'cat_mon',
          'categoriaNombre': 'Monitores',
          'nombre':          'LG UltraGear 27GP950 4K',
          'descripcion':     'Monitor gaming 4K UHD de 27" con panel Nano IPS, 144Hz (160Hz OC), 1ms, G-Sync compatible y HDR600.',
          'precio':          749.99,
          'stock':           7,
          'imagenUrl':       'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       true,
        },
        {
          'prodId':          'prod_samsung_odyssey',
          'categoriaId':     'cat_mon',
          'categoriaNombre': 'Monitores',
          'nombre':          'Samsung Odyssey Neo G9 57"',
          'descripcion':     'El monitor gaming más grande del mundo. Formato super ultrawide 32:9, resolución Dual QHD a 240Hz con retroiluminación Mini LED.',
          'precio':          1499.99,
          'stock':           3,
          'imagenUrl':       'https://images.unsplash.com/photo-1593305841991-05c297ba4575?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       false,
        },
        // Componentes
        {
          'prodId':          'prod_rtx4080',
          'categoriaId':     'cat_com',
          'categoriaNombre': 'Componentes',
          'nombre':          'NVIDIA GeForce RTX 4080 Super',
          'descripcion':     'GPU de última generación con 16GB GDDR6X, arquitectura Ada Lovelace, DLSS 3.5 y ray tracing en tiempo real. Rendimiento 4K sin compromisos.',
          'precio':          999.99,
          'stock':           6,
          'imagenUrl':       'https://images.unsplash.com/photo-1591488320449-011701bb6704?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       true,
        },
        {
          'prodId':          'prod_ryzen9',
          'categoriaId':     'cat_com',
          'categoriaNombre': 'Componentes',
          'nombre':          'AMD Ryzen 9 7950X',
          'descripcion':     'Procesador de escritorio de 16 núcleos y 32 hilos a 5.7 GHz Max Boost. El CPU de consumo más potente de AMD para trabajo pesado y gaming.',
          'precio':          699.99,
          'stock':           9,
          'imagenUrl':       'https://images.unsplash.com/photo-1555617981-dac3772e8f09?auto=format&fit=crop&q=80&w=600',
          'activo':          true,
          'destacado':       false,
        },
      ];

      for (final prod in products) {
        final id = prod['prodId'] as String;
        await db.collection('productos').doc(id).set({
          'categoriaId':     prod['categoriaId'],
          'categoriaNombre': prod['categoriaNombre'],
          'nombre':          prod['nombre'],
          'descripcion':     prod['descripcion'],
          'precio':          prod['precio'],
          'stock':           prod['stock'],
          'imagenUrl':       prod['imagenUrl'],
          'activo':          prod['activo'],
          'destacado':       prod['destacado'],
          'fechaCreacion':   FieldValue.serverTimestamp(),
        });

        // Reseñas de muestra
        await db.collection('productos').doc(id).collection('resenas').add({
          'clienteUid':             'demo_uid_1',
          'clienteNombreSnapshot':  'Carlos Pérez',
          'calificacion':           5,
          'comentario':             'Excelente producto, totalmente recomendado.',
          'fecha':                  FieldValue.serverTimestamp(),
        });
        await db.collection('productos').doc(id).collection('resenas').add({
          'clienteUid':             'demo_uid_2',
          'clienteNombreSnapshot':  'Ana Rivas',
          'calificacion':           4,
          'comentario':             'Muy buena calidad, llegó antes de lo esperado.',
          'fecha':                  FieldValue.serverTimestamp(),
        });
      }

      // ── Crear el perfil del admin en Firestore ────────────────────────
      await _ensureAdminUser(db);

      debugPrint('Base de datos de electrónica poblada exitosamente.');
    } catch (e) {
      debugPrint('Error en SeedData.seedDatabase: $e');
    }
  }

  /// Garantiza que el documento del administrador exista en la colección
  /// "usuarios" con rol = 'admin'. El UID se fija como constante para que
  /// coincida con la cuenta creada en Firebase Authentication.
  static Future<void> _ensureAdminUser(FirebaseFirestore db) async {
    try {
      final adminDoc =
          await db.collection('usuarios').doc(_adminUid).get();
      if (!adminDoc.exists) {
        await db.collection('usuarios').doc(_adminUid).set({
          'uid':           _adminUid,
          'nombre':        'Administrador',
          'email':         _adminEmail,
          'rol':           'admin',
          'fechaRegistro': FieldValue.serverTimestamp(),
        });
        debugPrint('Documento de admin creado en Firestore.');
      }
    } catch (e) {
      debugPrint('Error al crear documento de admin: $e');
    }
  }
}
