abstract class ReadOnlyRepository<T> {
  Stream<List<T>> getAllEntitiesStream();
  Future<List<T>> getAllEntities();
  Future<T> getEntity(int entityId);
}

abstract class Repository<T> extends ReadOnlyRepository<T> {
  Future<int> insert(T entity);
  Future update(T entity);
  Future delete(int entityId);
}
