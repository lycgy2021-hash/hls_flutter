enum AlgoDirection { next, history }

class OffsetLimitPagination {
  const OffsetLimitPagination({required this.offset, required this.limit});

  final int offset;
  final int limit;

  Map<String, dynamic> toQuery() {
    return <String, dynamic>{'offset': offset, 'limit': limit};
  }
}

class PagePagination {
  const PagePagination({required this.pageNo, required this.pageSize});

  final int pageNo;
  final int pageSize;

  Map<String, dynamic> toQuery() {
    return <String, dynamic>{'pageNo': pageNo, 'pageSize': pageSize};
  }
}

class AlgoPagination {
  const AlgoPagination({
    required this.index,
    required this.pageSize,
    required this.direction,
  });

  final int index;
  final int pageSize;
  final AlgoDirection direction;

  Map<String, dynamic> toBody() {
    return <String, dynamic>{
      'index': index,
      'pageSize': pageSize,
      'dir': direction == AlgoDirection.next ? 'NEXT' : 'HISTORY',
      'step': index + 1,
    };
  }
}
