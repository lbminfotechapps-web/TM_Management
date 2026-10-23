
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/invoice_model.dart';
import '../../domain/entities/invoice_entity.dart';

abstract class InvoiceLocalDataSource {
  Future<void> saveInvoice(InvoiceEntity invoice);

  Future<InvoiceEntity?> getInvoice(String id);
}

class InvoiceLocalDataSourceImpl
    implements InvoiceLocalDataSource {
  static const String _prefix = 'invoice_';

  @override
  Future<void> saveInvoice(InvoiceEntity invoice) async {
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(
      InvoiceModel.toJson(invoice),
    );

    final saved = await prefs.setString(
      '$_prefix${invoice.id}',
      json,
    );

    if (!saved) {
      throw Exception('Unable to store invoice locally.');
    }
  }

  @override
  Future<InvoiceEntity?> getInvoice(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString('$_prefix$id');

    if (raw == null) return null;

    final decoded = jsonDecode(raw);

    if (decoded is! Map) {
      throw const FormatException('Invalid stored invoice.');
    }

    return InvoiceModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }
}
