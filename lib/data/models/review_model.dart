import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String resenaId;
  final String clienteUid;
  final String clienteNombreSnapshot;
  final int calificacion;
  final String comentario;
  final DateTime fecha;

  ReviewModel({
    required this.resenaId,
    required this.clienteUid,
    required this.clienteNombreSnapshot,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
  });

  // Convertir de Map (Firestore) a Modelo
  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      resenaId: id,
      clienteUid: map['clienteUid'] ?? '',
      clienteNombreSnapshot: map['clienteNombreSnapshot'] ?? '',
      calificacion: map['calificacion'] ?? 5,
      comentario: map['comentario'] ?? '',
      fecha: map['fecha'] != null 
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convertir de Modelo a Map (Firestore)
  Map<String, dynamic> toMap() {
    return {
      'clienteUid': clienteUid,
      'clienteNombreSnapshot': clienteNombreSnapshot,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}
