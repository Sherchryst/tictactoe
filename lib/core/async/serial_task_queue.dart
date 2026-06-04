final class SerialTaskQueue {
  Future<void> _tail = Future<void>.value();

  Future<void> waitForIdle() => _tail;

  Future<T> enqueue<T>(Future<T> Function() operation) {
    final queued = _tail.then((_) => operation());
    _tail = queued.then<void>((_) {}, onError: (_) {});
    return queued;
  }
}
