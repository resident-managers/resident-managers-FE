const String meQuery = r'''
  query Me {
    me {
      id
      name
      email
    }
  }
''';

const String getResidentsQuery = r'''
  query GetResidents(
    $search: String
    $where: QueryResidentsWhereWhereConditions
    $orderBy: [QueryResidentsOrderByOrderByClause!]
    $first: Int
    $page: Int
  ) {
    residents(
      search: $search
      where: $where
      orderBy: $orderBy
      first: $first
      page: $page
    ) {
      paginatorInfo {
        total
        currentPage
        lastPage
      }
      data {
        id
        fullName
        gender
        dateOfBirth
        phone
        nationalId
        address
        occupation
        ethnicity
        religion
        educationLevel
        note
      }
    }
  }
''';

const String getResidentDetailQuery = r'''
  query GetResidentDetail($id: ID!) {
    resident(id: $id) {
      id
      fullName
      gender
      dateOfBirth
      phone
      nationalId
      address
      occupation
      ethnicity
      religion
      educationLevel
      note
      householdAsHead {
        id
        code
        address
      }
      household {
        id
        code
        address
        head {
          id
          fullName
          phone
          __typename
        }
        members { id relationship __typename}
        __typename
      }
      __typename
    }
  }
''';

const String getHouseholdsQuery = r'''
  query GetHouseholds($search: String, $first: Int, $page: Int) {
    houseHolds(search: $search, first: $first, page: $page) {
      paginatorInfo {
        total
        currentPage
        lastPage
      }
      data {
        id
        code
        address
        head {
          id
          fullName
          phone
          __typename
        }
        members {
          id
          fullName
          relationship
          __typename
        }
        __typename
      }
      __typename
    }
  }
''';
