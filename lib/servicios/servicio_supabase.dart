import 'package:supabase_flutter/supabase_flutter.dart';

import '../modelos/modelo_factura.dart';
import '../modelos/modelo_oferta_agricola.dart';
import '../modelos/modelo_producto.dart';
import '../modelos/modelo_solicitud_compra.dart';
import '../modelos/modelo_usuario.dart';

/// Servicio de acceso a datos respaldado por Supabase/PostgreSQL. Reemplaza
/// al antiguo repositorio en memoria (`DatosEnMemoria`): las vistas ya no
/// mantienen listas locales de dominio, sino que consultan y mutan las
/// tablas `usuario`, `producto`, `oferta_agricola`, `solicitud_compra` y
/// `factura` a través de estos métodos asíncronos.
class ServicioSupabase {
  ServicioSupabase._();

  static SupabaseClient get _cliente => Supabase.instance.client;

  /// Porcentaje de comisión de la plataforma aplicado a cada solicitud
  /// confirmada, consistente con `ResumenLiquidacion.tasaComision`.
  static const double porcentajeComisionPlataforma = 6.0;

  static Usuario? usuarioActual;

  // ---------------------------------------------------------------------
  // Usuarios & autenticación
  // ---------------------------------------------------------------------

  static Future<void> registrarUsuario(Usuario usuario) async {
    await _cliente.from('usuario').insert(usuario.toJson());
  }

  static Future<Usuario?> obtenerUsuarioPorId(String id) async {
    final fila = await _cliente.from('usuario').select().eq('id', id).maybeSingle();
    if (fila == null) return null;
    return Usuario.fromJson(fila);
  }

  static Future<Usuario?> login(String telefono, String password) async {
    final fila = await _cliente
        .from('usuario')
        .select()
        .eq('telefono', telefono)
        .eq('passwordHash', password)
        .maybeSingle();
    if (fila == null) return null;
    return Usuario.fromJson(fila);
  }

  static Future<List<Usuario>> obtenerUsuariosPorPerfil(TipoPerfil perfil) async {
    final filas = await _cliente.from('usuario').select().eq('tipoPerfil', perfil.toJson());
    return filas.map(Usuario.fromJson).toList();
  }

  // ---------------------------------------------------------------------
  // Catálogo de cítricos
  // ---------------------------------------------------------------------

  static Future<List<Producto>> obtenerCatalogo() async {
    final filas = await _cliente.from('producto').select();
    return filas.map(Producto.fromJson).toList();
  }

  static Future<Producto?> obtenerProductoPorId(String id) async {
    final fila = await _cliente.from('producto').select().eq('id', id).maybeSingle();
    if (fila == null) return null;
    return Producto.fromJson(fila);
  }

  // ---------------------------------------------------------------------
  // Ofertas de cosecha
  // ---------------------------------------------------------------------

  static Future<List<OfertaAgricola>> obtenerOfertasDisponibles() async {
    final filas = await _cliente
        .from('oferta_agricola')
        .select()
        .eq('estado', EstadoOferta.disponible.toJson())
        .gt('cantidadDisponible', 0)
        .order('creadoEn', ascending: false);
    return filas.map(OfertaAgricola.fromJson).toList();
  }

  static Future<List<OfertaAgricola>> obtenerOfertasPorProductor(String productorId) async {
    final filas = await _cliente
        .from('oferta_agricola')
        .select()
        .eq('productorId', productorId)
        .order('creadoEn', ascending: false);
    return filas.map(OfertaAgricola.fromJson).toList();
  }

  static Future<OfertaAgricola?> obtenerOfertaPorId(String id) async {
    final fila = await _cliente.from('oferta_agricola').select().eq('id', id).maybeSingle();
    if (fila == null) return null;
    return OfertaAgricola.fromJson(fila);
  }

  static Future<void> agregarOferta(OfertaAgricola oferta) async {
    await _cliente.from('oferta_agricola').insert(oferta.toJson());
  }

  static Future<void> actualizarPrecioOferta(String id, double nuevoPrecio) async {
    await _cliente.from('oferta_agricola').update({'precioUnitario': nuevoPrecio}).eq('id', id);
  }

  static Future<void> alternarPausaOferta(String id, EstadoOferta nuevoEstado) async {
    await _cliente.from('oferta_agricola').update({'estado': nuevoEstado.toJson()}).eq('id', id);
  }

  static Future<void> eliminarOferta(String id) async {
    await _cliente.from('oferta_agricola').delete().eq('id', id);
  }

  // ---------------------------------------------------------------------
  // Transacción de compra y facturación
  // ---------------------------------------------------------------------

  /// Confirma una solicitud de compra: inserta el registro, descuenta el
  /// inventario de la oferta (agotándola si corresponde) y emite la
  /// [Factura] con el desglose de comisión de la plataforma.
  static Future<Factura> procesarPedido(SolicitudCompra solicitud) async {
    await _cliente.from('solicitud_compra').insert(solicitud.toJson());

    final ofertaActual = await obtenerOfertaPorId(solicitud.ofertaId);
    if (ofertaActual != null) {
      final nuevaCantidad = ofertaActual.cantidadDisponible - solicitud.cantidadSolicitada;
      final cantidadFinal = nuevaCantidad < 0 ? 0 : nuevaCantidad;
      await _cliente.from('oferta_agricola').update({
        'cantidadDisponible': cantidadFinal,
        if (cantidadFinal <= 0) 'estado': EstadoOferta.agotado.toJson(),
      }).eq('id', ofertaActual.id);
    }

    final subtotal = solicitud.subtotal;
    final montoComision = subtotal * (porcentajeComisionPlataforma / 100);
    final factura = Factura(
      id: 'fac_${DateTime.now().millisecondsSinceEpoch}',
      solicitudCompraId: solicitud.id,
      numeroFactura: 'FAC-${DateTime.now().millisecondsSinceEpoch}',
      subtotal: subtotal,
      porcentajeComision: porcentajeComisionPlataforma,
      montoComision: montoComision,
      montoProductor: subtotal - montoComision,
      totalPagado: subtotal,
      metodoPago: MetodoPago.efectivo,
      estadoPago: EstadoPago.pendiente,
    );
    await _cliente.from('factura').insert(factura.toJson());
    return factura;
  }
}
