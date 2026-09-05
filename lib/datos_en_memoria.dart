import 'modelos/modelo_factura.dart';
import 'modelos/modelo_oferta_agricola.dart';
import 'modelos/modelo_producto.dart';
import 'modelos/modelo_solicitud_compra.dart';
import 'modelos/modelo_usuario.dart';

class DatosEnMemoria {
  DatosEnMemoria._();

  /// Porcentaje de comisión de la plataforma aplicado a cada solicitud
  /// confirmada, consistente con [ResumenLiquidacion.tasaComision].
  static const double porcentajeComisionPlataforma = 6.0;

  static final List<Usuario> usuarios = [
    Usuario(
      id: 'prod1',
      nombreCompleto: 'Don José García',
      telefono: '8888-1111',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Masaya',
      municipio: 'Ticuantepe',
      direccionExacta: 'Finca El Roble, Ticuantepe',
    ),
    Usuario(
      id: 'prod2',
      nombreCompleto: 'Doña Reyna Blandón',
      telefono: '8888-2222',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Rivas',
      municipio: 'Nandaime',
      direccionExacta: 'Comunidad El Limonal, Nandaime',
    ),
    Usuario(
      id: 'prod3',
      nombreCompleto: 'Carlos Membreño',
      telefono: '8888-3333',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Rivas',
      municipio: 'Belén',
      direccionExacta: 'Finca Santa Rosa, Belén',
    ),
    Usuario(
      id: 'prod4',
      nombreCompleto: 'Doña Marta Suárez',
      telefono: '8888-4444',
      tipoPerfil: TipoPerfil.productor,
      departamento: 'Masaya',
      municipio: 'Masatepe',
      direccionExacta: 'Comunidad San Juan, Masatepe',
    ),
    Usuario(
      id: 'comp1',
      nombreCompleto: 'Supermercado La Colonia',
      telefono: '2222-5555',
      tipoPerfil: TipoPerfil.comprador,
      departamento: 'Managua',
      municipio: 'Managua',
      direccionExacta: 'Bodega Central, Km 7 Carretera Masaya',
    ),
  ];

  static List<Usuario> get productores =>
      usuarios.where((u) => u.tipoPerfil == TipoPerfil.productor).toList();

  static List<Usuario> get compradores =>
      usuarios.where((u) => u.tipoPerfil == TipoPerfil.comprador).toList();

  static final List<Producto> catalogoProductos = [
    Producto(id: 'prod_cit_1', nombre: 'Limón Criollo', categoria: 'Cítricos'),
    Producto(id: 'prod_cit_2', nombre: 'Limón Tahití', categoria: 'Cítricos'),
    Producto(id: 'prod_cit_3', nombre: 'Naranja Dulce', categoria: 'Cítricos'),
    Producto(id: 'prod_cit_4', nombre: 'Naranja Agria', categoria: 'Cítricos'),
    Producto(id: 'prod_cit_5', nombre: 'Mandarina', categoria: 'Cítricos'),
  ];

  static final List<OfertaAgricola> ofertas = [
    OfertaAgricola(
      id: 'of1',
      productorId: 'prod1',
      productoId: 'prod_cit_1',
      precioUnitario: 700.0,
      unidadMedida: UnidadMedida.quintal,
      cantidadTotal: 20,
      cantidadDisponible: 20,
      modalidadLogistica: ModalidadLogistica.todas,
      fechaCosecha: DateTime(2026, 8, 18),
    ),
    OfertaAgricola(
      id: 'of2',
      productorId: 'prod2',
      productoId: 'prod_cit_2',
      precioUnitario: 900.0,
      unidadMedida: UnidadMedida.quintal,
      cantidadTotal: 15,
      cantidadDisponible: 15,
      modalidadLogistica: ModalidadLogistica.envioProductor,
      fechaCosecha: DateTime(2026, 8, 19),
    ),
    OfertaAgricola(
      id: 'of3',
      productorId: 'prod3',
      productoId: 'prod_cit_3',
      precioUnitario: 420.0,
      unidadMedida: UnidadMedida.cien,
      cantidadTotal: 30,
      cantidadDisponible: 30,
      modalidadLogistica: ModalidadLogistica.transportista,
      fechaCosecha: DateTime(2026, 8, 15),
    ),
    OfertaAgricola(
      id: 'of4',
      productorId: 'prod4',
      productoId: 'prod_cit_4',
      precioUnitario: 380.0,
      unidadMedida: UnidadMedida.cien,
      cantidadTotal: 25,
      cantidadDisponible: 25,
      modalidadLogistica: ModalidadLogistica.retiro,
      fechaCosecha: DateTime(2026, 8, 20),
    ),
    OfertaAgricola(
      id: 'of5',
      productorId: 'prod1',
      productoId: 'prod_cit_5',
      precioUnitario: 450.0,
      unidadMedida: UnidadMedida.cien,
      cantidadTotal: 18,
      cantidadDisponible: 18,
      modalidadLogistica: ModalidadLogistica.todas,
      fechaCosecha: DateTime(2026, 8, 21),
    ),
  ];

  static final List<SolicitudCompra> solicitudes = [];
  static final List<Factura> facturas = [];

  static void agregarUsuario(Usuario usuario) {
    usuarios.insert(0, usuario);
  }

  static Usuario? obtenerUsuarioPorId(String id) {
    try {
      return usuarios.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  static Producto? obtenerProductoPorId(String id) {
    try {
      return catalogoProductos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Producto> obtenerProductosPorCategoria(String categoria) {
    return catalogoProductos.where((p) => p.categoria == categoria).toList();
  }

  static void agregarOferta(OfertaAgricola oferta) {
    ofertas.insert(0, oferta);
  }

  static void eliminarOferta(String id) {
    ofertas.removeWhere((o) => o.id == id);
  }

  static OfertaAgricola? obtenerOfertaPorId(String id) {
    try {
      return ofertas.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  static void actualizarOferta(OfertaAgricola actualizada) {
    final indice = ofertas.indexWhere((o) => o.id == actualizada.id);
    if (indice == -1) return;
    ofertas[indice] = actualizada;
  }

  static void actualizarPrecioOferta(String id, double nuevoPrecio) {
    final oferta = obtenerOfertaPorId(id);
    if (oferta == null) return;
    actualizarOferta(oferta.copyWith(precioUnitario: nuevoPrecio));
  }

  static void alternarPausaOferta(String id) {
    final oferta = obtenerOfertaPorId(id);
    if (oferta == null || oferta.estado == EstadoOferta.agotado) return;
    actualizarOferta(
      oferta.copyWith(
        estado: oferta.estado == EstadoOferta.pausada
            ? EstadoOferta.disponible
            : EstadoOferta.pausada,
      ),
    );
  }

  static List<OfertaAgricola> get ofertasDisponibles =>
      ofertas.where((o) => o.estaDisponible).toList();

  static List<OfertaAgricola> ofertasPorProductor(String productorId) =>
      ofertas.where((o) => o.productorId == productorId).toList();

  /// Confirma una solicitud de compra: descuenta el inventario de la oferta,
  /// agota la oferta si corresponde, y emite la [Factura] con el desglose de
  /// comisión de la plataforma.
  static Factura registrarSolicitud(SolicitudCompra solicitud) {
    solicitudes.insert(0, solicitud);

    final indice = ofertas.indexWhere((o) => o.id == solicitud.ofertaId);
    if (indice != -1) {
      final oferta = ofertas[indice];
      final nuevaCantidad = oferta.cantidadDisponible - solicitud.cantidadSolicitada;
      ofertas[indice] = oferta.copyWith(
        cantidadDisponible: nuevaCantidad < 0 ? 0 : nuevaCantidad,
        estado: nuevaCantidad <= 0 ? EstadoOferta.agotado : oferta.estado,
      );
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
    facturas.insert(0, factura);
    return factura;
  }

  static Factura? obtenerFacturaPorSolicitudId(String solicitudCompraId) {
    try {
      return facturas.firstWhere((f) => f.solicitudCompraId == solicitudCompraId);
    } catch (_) {
      return null;
    }
  }

  static Usuario? usuarioActual;

  static void iniciarSesion(String id) {
    final usuario = obtenerUsuarioPorId(id);
    if (usuario == null) return;
    usuarioActual = usuario;
  }

  static void cerrarSesion() {
    usuarioActual = null;
  }
}
