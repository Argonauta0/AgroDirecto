import 'modelos/modelo_oferta_lote.dart';
import 'modelos/modelo_pedido.dart';
import 'modelos/modelo_producto.dart';
import 'modelos/modelo_usuario.dart';

class DatosEnMemoria {
  DatosEnMemoria._();

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

  static final List<OfertaLote> ofertasLote = [
    OfertaLote(
      id: 'of1',
      productorId: 'prod1',
      productoId: 'prod_cit_1',
      precioUnitario: 700.0,
      unidadMedida: UnidadMedida.quintal,
      cantidadTotal: 20,
      cantidadDisponible: 20,
      modalidadLogistica: ModalidadLogisticaOferta.todas,
      fechaCosecha: DateTime(2026, 8, 18),
    ),
    OfertaLote(
      id: 'of2',
      productorId: 'prod2',
      productoId: 'prod_cit_2',
      precioUnitario: 900.0,
      unidadMedida: UnidadMedida.quintal,
      cantidadTotal: 15,
      cantidadDisponible: 15,
      modalidadLogistica: ModalidadLogisticaOferta.envioProductor,
      fechaCosecha: DateTime(2026, 8, 19),
    ),
    OfertaLote(
      id: 'of3',
      productorId: 'prod3',
      productoId: 'prod_cit_3',
      precioUnitario: 420.0,
      unidadMedida: UnidadMedida.cien,
      cantidadTotal: 30,
      cantidadDisponible: 30,
      modalidadLogistica: ModalidadLogisticaOferta.transportista,
      fechaCosecha: DateTime(2026, 8, 15),
    ),
    OfertaLote(
      id: 'of4',
      productorId: 'prod4',
      productoId: 'prod_cit_4',
      precioUnitario: 380.0,
      unidadMedida: UnidadMedida.cien,
      cantidadTotal: 25,
      cantidadDisponible: 25,
      modalidadLogistica: ModalidadLogisticaOferta.retiro,
      fechaCosecha: DateTime(2026, 8, 20),
    ),
    OfertaLote(
      id: 'of5',
      productorId: 'prod1',
      productoId: 'prod_cit_5',
      precioUnitario: 450.0,
      unidadMedida: UnidadMedida.cien,
      cantidadTotal: 18,
      cantidadDisponible: 18,
      modalidadLogistica: ModalidadLogisticaOferta.todas,
      fechaCosecha: DateTime(2026, 8, 21),
    ),
  ];

  static final List<Pedido> pedidos = [];

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

  static void agregarOfertaLote(OfertaLote oferta) {
    ofertasLote.insert(0, oferta);
  }

  static void eliminarOfertaLote(String id) {
    ofertasLote.removeWhere((o) => o.id == id);
  }

  static OfertaLote? obtenerOfertaLotePorId(String id) {
    try {
      return ofertasLote.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  static void actualizarOferta(OfertaLote actualizada) {
    final indice = ofertasLote.indexWhere((o) => o.id == actualizada.id);
    if (indice == -1) return;
    ofertasLote[indice] = actualizada;
  }

  static void actualizarPrecioOferta(String id, double nuevoPrecio) {
    final oferta = obtenerOfertaLotePorId(id);
    if (oferta == null) return;
    actualizarOferta(oferta.copyWith(precioUnitario: nuevoPrecio));
  }

  static void alternarPausaOferta(String id) {
    final oferta = obtenerOfertaLotePorId(id);
    if (oferta == null || oferta.estado == EstadoOferta.agotado) return;
    actualizarOferta(
      oferta.copyWith(
        estado: oferta.estado == EstadoOferta.pausada
            ? EstadoOferta.disponible
            : EstadoOferta.pausada,
      ),
    );
  }

  static List<OfertaLote> get ofertasDisponibles =>
      ofertasLote.where((o) => o.estaDisponible).toList();

  static List<OfertaLote> ofertasPorProductor(String productorId) =>
      ofertasLote.where((o) => o.productorId == productorId).toList();

  static void registrarPedido(Pedido pedido) {
    pedidos.insert(0, pedido);

    final indice = ofertasLote.indexWhere((o) => o.id == pedido.ofertaId);
    if (indice == -1) return;

    final oferta = ofertasLote[indice];
    final nuevaCantidad = oferta.cantidadDisponible - pedido.cantidadSolicitada;
    ofertasLote[indice] = oferta.copyWith(
      cantidadDisponible: nuevaCantidad < 0 ? 0 : nuevaCantidad,
      estado: nuevaCantidad <= 0 ? EstadoOferta.agotado : oferta.estado,
    );
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
