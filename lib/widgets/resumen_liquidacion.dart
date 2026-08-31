import 'package:flutter/material.dart';
import '../tema_app.dart';

/// Vista previa de liquidación: calcula en tiempo real el valor bruto de un
/// lote, descuenta la comisión de la plataforma y muestra el ingreso neto
/// estimado que recibirá el productor.
class ResumenLiquidacion extends StatelessWidget {
  static const double tasaComision = 0.06;

  final int cantidad;
  final double precioUnitario;
  final String unidadEtiqueta;
  final String titulo;

  const ResumenLiquidacion({
    super.key,
    required this.cantidad,
    required this.precioUnitario,
    required this.unidadEtiqueta,
    this.titulo = 'Liquidación estimada',
  });

  double get valorBruto => cantidad * precioUnitario;
  double get comision => valorBruto * tasaComision;
  double get ingresoNeto => valorBruto - comision;

  String _formatear(double valor) => 'C\$${valor.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColoresApp.verdeClaro.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColoresApp.verdeClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long, color: ColoresApp.verdeOscuro, size: 20),
              const SizedBox(width: 8),
              Text(titulo, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$cantidad $unidadEtiqueta${cantidad == 1 ? '' : 's'} × ${_formatear(precioUnitario)}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          _filaMonto('Valor bruto total', valorBruto),
          const SizedBox(height: 6),
          _filaMonto(
            'Comisión de la plataforma (${(tasaComision * 100).toStringAsFixed(0)}%)',
            -comision,
          ),
          const Divider(height: 20),
          _filaMonto('Ingreso neto estimado', ingresoNeto, destacado: true),
        ],
      ),
    );
  }

  Widget _filaMonto(String etiqueta, double monto, {bool destacado = false}) {
    final String signo = monto < 0 ? '- ' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          etiqueta,
          style: TextStyle(
            fontSize: destacado ? 15 : 13,
            fontWeight: destacado ? FontWeight.bold : FontWeight.w500,
            color: destacado ? ColoresApp.verdeOscuro : Colors.black54,
          ),
        ),
        Text(
          '$signo${_formatear(monto.abs())}',
          style: TextStyle(
            fontSize: destacado ? 18 : 14,
            fontWeight: destacado ? FontWeight.bold : FontWeight.w600,
            color: destacado ? ColoresApp.verdeOscuro : Colors.black87,
          ),
        ),
      ],
    );
  }
}
