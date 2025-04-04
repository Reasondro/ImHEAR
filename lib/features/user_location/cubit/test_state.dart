part of 'test_cubit.dart';

sealed class TestState extends Equatable {
  const TestState();

  @override
  List<Object> get props => [];
}

final class TestInitial extends TestState {}
