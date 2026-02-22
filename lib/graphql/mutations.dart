const String loginMutation = r'''
  mutation Login($email: String!, $password: String!) {
    login(input: { email: $email, password: $password }) {
      access_token
      user {
        id
        name
        email
      }
    }
  }
''';

const String createResidentMutation = r'''
  mutation CreateResident($input: ResidentCreateInput!) {
    residentCreate(input: $input) {
      id
      fullName
    }
  }
''';

const String updateResidentMutation = r'''
  mutation UpdateResident($id: ID!, $input: ResidentUpdateInput!) {
    residentUpdate(id: $id, input: $input) {
      id
      fullName
    }
  }
''';

const String deleteResidentMutation = r'''
  mutation DeleteResident($id: ID!) {
    residentDelete(id: $id) {
      id
    }
  }
''';

const String createHouseholdMutation = r'''
  mutation CreateHousehold($input: HouseholdCreateInput!) {
    householdCreate(input: $input) {
      id
      code
      address
    }
  }
''';

const String updateHouseholdMutation = r'''
  mutation UpdateHousehold($input: HouseholdUpdateInput!) {
    householdUpdate(input: $input) {
      id
      code
      address
    }
  }
''';

const String deleteHouseholdMutation = r'''
  mutation DeleteHousehold($id: ID!) {
    householdDelete(id: $id) {
      id
    }
  }
''';
