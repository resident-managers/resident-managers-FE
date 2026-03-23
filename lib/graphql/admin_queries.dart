const String usersQuery = r'''
  query Users {
    users(orderBy: [{column: CREATED_AT, order: DESC}]) {
      data {
        id
        name
        email
        roles
      }
      paginatorInfo {
        total
        currentPage
        lastPage
        hasMorePages
      }
    }
  }
''';
