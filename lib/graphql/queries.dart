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
    $first: Int
    $page: Int
  ) {
    residents(
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
  query GetHouseholds($first: Int, $page: Int) {
    houseHolds(first: $first, page: $page) {
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
