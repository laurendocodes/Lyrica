abstract class StreamUseCase<Type, Params> {
  Stream<Type> call({required Params params});
}
