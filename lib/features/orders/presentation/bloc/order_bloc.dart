
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/save_order_usecase.dart';
import '../../domain/usecases/delete_order_usecase.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final GetOrdersUseCase getOrdersUseCase;
  final SaveOrderUseCase saveOrderUseCase;
  final DeleteOrderUseCase deleteOrderUseCase;

  OrderBloc({
    required this.getOrdersUseCase,
    required this.saveOrderUseCase,
    required this.deleteOrderUseCase,
  }) : super(const OrderState()) {
    on<LoadOrdersEvent>(_onLoad);
    on<SaveOrderEvent>(_onSave);
    on<DeleteOrderEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadOrdersEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      status: OrderBlocStatus.loading,
      message: '',
    ));

    try {
      final records = await getOrdersUseCase();

      emit(state.copyWith(
        status: OrderBlocStatus.success,
        orders: records,
        message: '',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderBlocStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onSave(
    SaveOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      status: OrderBlocStatus.saving,
      message: '',
    ));

    try {
      await saveOrderUseCase(event.order);

      final records = await getOrdersUseCase();

      emit(state.copyWith(
        status: OrderBlocStatus.saved,
        orders: records,
        message: 'Order saved successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderBlocStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }

  Future<void> _onDelete(
    DeleteOrderEvent event,
    Emitter<OrderState> emit,
  ) async {
    emit(state.copyWith(
      status: OrderBlocStatus.deleting,
      message: '',
    ));

    try {
      await deleteOrderUseCase(event.orderId);

      final records = await getOrdersUseCase();

      emit(state.copyWith(
        status: OrderBlocStatus.deleted,
        orders: records,
        message: 'Order deleted successfully',
        revision: state.revision + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderBlocStatus.failure,
        message: e.toString().replaceFirst('Exception: ', ''),
        revision: state.revision + 1,
      ));
    }
  }
}
