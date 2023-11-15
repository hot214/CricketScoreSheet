class Stack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  bool get isEmpty => _list.isEmpty;
  bool get isNotEmpty => _list.isNotEmpty;

  E? pop() => (isEmpty) ? null : _list.removeLast();
  E? get top => (isEmpty) ? null : _list.last;
  List<E> get list => _list;

  void clear() => _list.clear();

  @override
  String toString() => _list.toString();
}
