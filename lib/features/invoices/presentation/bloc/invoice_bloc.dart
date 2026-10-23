
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/invoice_entity.dart';
import '../../domain/usecases/save_invoice_usecase.dart';
import '../../domain/usecases/get_invoice_usecase.dart';
import '../../domain/usecases/export_invoice_usecase.dart';

// ============================================================
// EVENTS
// ============================================================

abstract class InvoiceEvent {
  const InvoiceEvent();
}

class SaveInvoiceRequested extends InvoiceEvent {
  final InvoiceEntity invoice;

  const SaveInvoiceRequested(this.invoice);
}

class GetInvoiceRequested extends InvoiceEvent {
  final String invoiceId;

  const GetInvoiceRequested(this.invoiceId);
}

class DownloadInvoiceRequested extends InvoiceEvent {
  const DownloadInvoiceRequested();
}

class ShareInvoiceRequested extends InvoiceEvent {
  const ShareInvoiceRequested();
}

class InvoiceMessageCleared extends InvoiceEvent {
  const InvoiceMessageCleared();
}

// ============================================================
// STATE
// ============================================================

enum InvoiceStatus {
  initial,
  loading,
  ready,
  saving,
  downloading,
  sharing,
  failure,
}

class InvoiceState {
  final InvoiceStatus status;
  final InvoiceEntity? invoice;
  final String message;
  final String? savedFilePath;

  const InvoiceState({
    this.status = InvoiceStatus.initial,
    this.invoice,
    this.message = '',
    this.savedFilePath,
  });

  InvoiceState copyWith({
    InvoiceStatus? status,
    InvoiceEntity? invoice,
    String? message,
    String? savedFilePath,
  }) {
    return InvoiceState(
      status: status ?? this.status,
      invoice: invoice ?? this.invoice,
      message: message ?? this.message,
      savedFilePath: savedFilePath ?? this.savedFilePath,
    );
  }
}

// ============================================================
// BLOC
// ============================================================

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final SaveInvoiceUseCase saveInvoice;
  final GetInvoiceUseCase getInvoice;
  final ExportInvoiceUseCase exportInvoice;

  bool _busy = false;

  InvoiceBloc({
    required this.saveInvoice,
    required this.getInvoice,
    required this.exportInvoice,
  }) : super(const InvoiceState()) {
    on<SaveInvoiceRequested>(_onSave);
    on<GetInvoiceRequested>(_onGet);
    on<DownloadInvoiceRequested>(_onDownload);
    on<ShareInvoiceRequested>(_onShare);
    on<InvoiceMessageCleared>((event, emit) {
      emit(state.copyWith(message: ''));
    });
  }

  Future<void> _onSave(
    SaveInvoiceRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    if (_busy) return;
    _busy = true;

    emit(state.copyWith(
      status: InvoiceStatus.saving,
      invoice: event.invoice,
      message: '',
    ));

    try {
      await saveInvoice(event.invoice);

      emit(state.copyWith(
        status: InvoiceStatus.ready,
        message: 'Invoice saved successfully.',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: InvoiceStatus.failure,
        message: _error(error),
      ));
    } finally {
      _busy = false;
    }
  }

  Future<void> _onGet(
    GetInvoiceRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    if (_busy) return;
    _busy = true;

    emit(state.copyWith(
      status: InvoiceStatus.loading,
      message: '',
    ));

    try {
      final invoice = await getInvoice(event.invoiceId);

      if (invoice == null) {
        throw Exception('Invoice not found.');
      }

      emit(state.copyWith(
        status: InvoiceStatus.ready,
        invoice: invoice,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: InvoiceStatus.failure,
        message: _error(error),
      ));
    } finally {
      _busy = false;
    }
  }

  Future<void> _onDownload(
    DownloadInvoiceRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    if (_busy || state.invoice == null) return;
    _busy = true;

    emit(state.copyWith(
      status: InvoiceStatus.downloading,
      message: '',
    ));

    try {
      final path = await exportInvoice.savePdf(
        state.invoice!,
      );

      emit(state.copyWith(
        status: InvoiceStatus.ready,
        savedFilePath: path,
        message: 'PDF saved to $path',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: InvoiceStatus.ready,
        message: 'PDF error: ${_error(error)}',
      ));
    } finally {
      _busy = false;
    }
  }

  Future<void> _onShare(
    ShareInvoiceRequested event,
    Emitter<InvoiceState> emit,
  ) async {
    if (_busy || state.invoice == null) return;
    _busy = true;

    emit(state.copyWith(
      status: InvoiceStatus.sharing,
      message: '',
    ));

    try {
      await exportInvoice.sharePdf(state.invoice!);

      emit(state.copyWith(
        status: InvoiceStatus.ready,
        message: '',
      ));
    } catch (error) {
      emit(state.copyWith(
        status: InvoiceStatus.ready,
        message: 'Share error: ${_error(error)}',
      ));
    } finally {
      _busy = false;
    }
  }

  String _error(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
