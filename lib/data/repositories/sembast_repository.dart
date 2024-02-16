abstract class Repository<T> {
  Future<int> insert(T entity);
  Future update(T entity);
  Future delete(int entityId);
  Stream<List<T>> getAllEntitiesStream();
}