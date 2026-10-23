
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tailorpro_clean/core/theme/invoice_colors.dart';

import '../../domain/entities/invoice_entity.dart';
import '../bloc/invoice_bloc.dart';

import '../widgets/invoice_receipt.dart';

class InvoicePreviewPage extends StatefulWidget {
  final String invoiceId;
  final InvoiceEntity? initialInvoice;

  const InvoicePreviewPage({
    super.key,
    required this.invoiceId,
    this.initialInvoice,
  });

  @override
  State<InvoicePreviewPage> createState() =>
      _InvoicePreviewPageState();
}

class _InvoicePreviewPageState
    extends State<InvoicePreviewPage> {
  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    final bloc = context.read<InvoiceBloc>();

    if (widget.initialInvoice != null) {
      bloc.add(
        SaveInvoiceRequested(
          widget.initialInvoice!,
        ),
      );
    } else {
      bloc.add(
        GetInvoiceRequested(
          widget.invoiceId,
        ),
      );
    }
  }

  // ============================================================
  // DOWNLOAD INVOICE PDF
  // ============================================================

  void _download() {
    context.read<InvoiceBloc>().add(
      const DownloadInvoiceRequested(),
    );
  }

  // ============================================================
  // SHARE INVOICE PDF
  // ============================================================

  void _share() {
    context.read<InvoiceBloc>().add(
      const ShareInvoiceRequested(),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    if (message.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: InvoiceColors.primary,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM ACTION BUTTONS
  // ============================================================

  Widget _bottomActions(InvoiceState state) {
    final busy =
        state.status == InvoiceStatus.loading ||
        state.status == InvoiceStatus.saving ||
        state.status == InvoiceStatus.downloading ||
        state.status == InvoiceStatus.sharing;

    final downloading =
        state.status == InvoiceStatus.downloading;

    final sharing =
        state.status == InvoiceStatus.sharing;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          14,
          9,
          14,
          12,
        ),
        decoration: const BoxDecoration(
          color: InvoiceColors.card,
          border: Border(
            top: BorderSide(
              color: InvoiceColors.border,
            ),
          ),
        ),
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: Row(
              children: [
                // ==================================================
                // SAVE PDF BUTTON
                // ==================================================

                Expanded(
                  flex: 5,
                  child: SizedBox(
                    height: 47,
                    child: ElevatedButton.icon(
                      onPressed: busy || state.invoice == null
                          ? null
                          : _download,

                      icon: downloading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: InvoiceColors.onPrimary,
                              ),
                            )
                          : const Icon(
                              Icons.download_rounded,
                              size: 19,
                            ),

                      label: Text(
                        downloading
                            ? 'Saving...'
                            : 'Save PDF',
                      ),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: InvoiceColors.gold,
                        foregroundColor: InvoiceColors.onPrimary,
                        disabledBackgroundColor:
                            InvoiceColors.gold.withValues(
                          alpha: 0.5,
                        ),
                        disabledForegroundColor:
                            InvoiceColors.onPrimary,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // ==================================================
                // SHARE BUTTON
                // ==================================================

                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 47,
                    child: OutlinedButton.icon(
                      onPressed: busy || state.invoice == null
                          ? null
                          : _share,

                      icon: sharing
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: InvoiceColors.primary,
                              ),
                            )
                          : const Icon(
                              Icons.share_outlined,
                              size: 18,
                            ),

                      label: const Text('Share'),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: InvoiceColors.primary,
                        side: const BorderSide(
                          color: InvoiceColors.border,
                        ),
                        backgroundColor: InvoiceColors.card,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY / ERROR STATE
  // ============================================================

  Widget _buildEmptyState(
    InvoiceState state,
  ) {
    final loading =
        state.status == InvoiceStatus.initial ||
        state.status == InvoiceStatus.loading ||
        state.status == InvoiceStatus.saving;

    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: InvoiceColors.gold,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: InvoiceColors.softGold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 31,
                color: InvoiceColors.gold,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'Invoice Not Available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InvoiceColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              state.message.isNotEmpty
                  ? state.message
                  : 'Unable to load invoice details.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: InvoiceColors.subText,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: () {
                context.read<InvoiceBloc>().add(
                  GetInvoiceRequested(
                    widget.invoiceId,
                  ),
                );
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(
                foregroundColor: InvoiceColors.primary,
                side: const BorderSide(
                  color: InvoiceColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar(
    InvoiceState state,
  ) {
    final ready =
        state.invoice != null &&
        state.status == InvoiceStatus.ready;

    return AppBar(
      backgroundColor: InvoiceColors.background,
      foregroundColor: InvoiceColors.primary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      titleSpacing: 0,

      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 19,
          color: InvoiceColors.primary,
        ),
      ),

      title: const Text(
        'Invoice Preview',
        style: TextStyle(
          color: InvoiceColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),

      actions: [
        TextButton(
          onPressed: ready ? _share : null,
          child: const Text(
            'Share',
            style: TextStyle(
              color: InvoiceColors.darkGold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert_rounded,
            color: InvoiceColors.primary,
          ),
          onSelected: (value) {
            if (value == 'download' && ready) {
              _download();
            }

            if (value == 'share' && ready) {
              _share();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'download',
              enabled: ready,
              child: const Row(
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: 18,
                    color: InvoiceColors.primary,
                  ),
                  SizedBox(width: 9),
                  Text('Save PDF'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              enabled: ready,
              child: const Row(
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: InvoiceColors.primary,
                  ),
                  SizedBox(width: 9),
                  Text('Share Invoice'),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(width: 4),
      ],
    );
  }

  // ============================================================
  // MAIN PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvoiceBloc, InvoiceState>(
      listenWhen: (previous, current) =>
          current.message.isNotEmpty &&
          (previous.message != current.message ||
              previous.status != current.status),

      listener: (context, state) {
        _showMessage(
          context,
          state.message,
        );

        context.read<InvoiceBloc>().add(
          const InvoiceMessageCleared(),
        );
      },

      builder: (context, state) {
        final invoice = state.invoice;

        return Scaffold(
          backgroundColor: InvoiceColors.background,

          appBar: _buildAppBar(state),

          body: invoice == null
              ? _buildEmptyState(state)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 650,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        12,
                        10,
                        12,
                        24,
                      ),
                      child: InvoiceReceipt(
                        invoice: invoice,
                      ),
                    ),
                  ),
                ),

          bottomNavigationBar: invoice == null
              ? null
              : _bottomActions(state),
        );
      },
    );
  }
}
