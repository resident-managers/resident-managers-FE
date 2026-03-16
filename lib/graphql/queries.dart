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
      residenceType
      permanentAddress
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

const String getStatisticsQuery = r'''
  query GetStatistics {
    statistics {
      totalResidents
      totalHouseholds
      maleCount
      femaleCount
      permanentCount
      temporaryCount
      absentCount
      movedOutCount
      activeTemporaryResidences
      activeTemporaryAbsences
    }
  }
''';

const String getHealthInsurancesByResidentQuery = r'''
  query GetHealthInsurancesByResident($residentId: Mixed!) {
    healthInsurances(
      where: { column: RESIDENT_ID, operator: EQ, value: $residentId }
      first: 10
    ) {
      data {
        id
        code
        healthcareFacility
        issuedDate
        expiryDate
        createdAt
      }
    }
  }
''';

const String getSocialInsurancesByResidentQuery = r'''
  query GetSocialInsurancesByResident($residentId: Mixed!) {
    socialInsurances(
      where: { column: RESIDENT_ID, operator: EQ, value: $residentId }
      first: 10
    ) {
      data {
        id
        code
        employer
        enrolledDate
        insuranceType
        status
        createdAt
      }
    }
  }
''';

const String getTemporaryResidencesByResidentQuery = r'''
  query GetTemporaryResidencesByResident($residentId: Mixed!) {
    temporaryResidences(
      where: { column: RESIDENT_ID, operator: EQ, value: $residentId }
      first: 20
    ) {
      data {
        id
        address
        hostName
        fromDate
        toDate
        reason
        createdAt
      }
    }
  }
''';

const String getTemporaryAbsencesByResidentQuery = r'''
  query GetTemporaryAbsencesByResident($residentId: Mixed!) {
    temporaryAbsences(
      where: { column: RESIDENT_ID, operator: EQ, value: $residentId }
      first: 20
    ) {
      data {
        id
        destination
        fromDate
        toDate
        reason
        createdAt
      }
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
