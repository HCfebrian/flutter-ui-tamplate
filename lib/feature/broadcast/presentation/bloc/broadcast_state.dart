part of 'broadcast_bloc.dart';

abstract class BroadcastState extends Equatable {
  const BroadcastState();
}

class BroadcastInitial extends BroadcastState {
  @override
  List<Object> get props => [];
}

class BroadcastLoadingState extends BroadcastState {
  @override
  List<Object?> get props => [];
}

class BroadcastSuccessState extends BroadcastState {
  @override
  List<Object?> get props => [];
}
