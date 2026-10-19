import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/reviews_social_sharing_entity.dart';
import '../../domain/usecases/reviews_social_sharing_usecase.dart';

// Events
abstract class ReviewsSocialSharingEvent extends Equatable {
  const ReviewsSocialSharingEvent();
  @override
  List<Object?> get props => [];
}

class LoadReviewsSocialSharingEvent extends ReviewsSocialSharingEvent {}

// States
abstract class ReviewsSocialSharingState extends Equatable {
  const ReviewsSocialSharingState();
  @override
  List<Object?> get props => [];
}

class ReviewsSocialSharingInitial extends ReviewsSocialSharingState {}
class ReviewsSocialSharingLoading extends ReviewsSocialSharingState {}
class ReviewsSocialSharingLoaded extends ReviewsSocialSharingState {
  final List<ReviewEntity> items;
  const ReviewsSocialSharingLoaded(this.items);
  @override
  List<Object?> get props => [items];
}
class ReviewsSocialSharingError extends ReviewsSocialSharingState {
  final String message;
  const ReviewsSocialSharingError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ReviewsSocialSharingBloc extends Bloc<ReviewsSocialSharingEvent, ReviewsSocialSharingState> {
  final GetReviewsSocialSharingUseCase getItemsUseCase;

  ReviewsSocialSharingBloc({required this.getItemsUseCase}) : super(ReviewsSocialSharingInitial()) {
    on<LoadReviewsSocialSharingEvent>((event, emit) async {
      emit(ReviewsSocialSharingLoading());
      try {
        final items = await getItemsUseCase.execute();
        emit(ReviewsSocialSharingLoaded(items));
      } catch (e) {
        emit(ReviewsSocialSharingError(e.toString()));
      }
    });
  }
}
