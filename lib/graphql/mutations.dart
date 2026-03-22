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

const String logoutMutation = r'''
  mutation Logout {
    logout
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
  mutation houseHoldCreate($input: HouseholdCreateInput!) {
    householdCreate(input: $input) {
      id
      code
      address
      head {
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
      members {
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

const String createHealthInsuranceMutation = r'''
  mutation CreateHealthInsurance($input: HealthInsuranceCreateInput!) {
    healthInsuranceCreate(input: $input) {
      id
      code
      healthcareFacility
      issuedDate
      expiryDate
    }
  }
''';

const String updateHealthInsuranceMutation = r'''
  mutation UpdateHealthInsurance($input: HealthInsuranceUpdateInput!) {
    healthInsuranceUpdate(input: $input) {
      id
      code
      healthcareFacility
      issuedDate
      expiryDate
    }
  }
''';

const String deleteHealthInsuranceMutation = r'''
  mutation DeleteHealthInsurance($id: ID!) {
    healthInsuranceDelete(id: $id) {
      id
    }
  }
''';

const String createSocialInsuranceMutation = r'''
  mutation CreateSocialInsurance($input: SocialInsuranceCreateInput!) {
    socialInsuranceCreate(input: $input) {
      id
      code
      employer
      enrolledDate
      insuranceType
      status
    }
  }
''';

const String updateSocialInsuranceMutation = r'''
  mutation UpdateSocialInsurance($input: SocialInsuranceUpdateInput!) {
    socialInsuranceUpdate(input: $input) {
      id
      code
      employer
      enrolledDate
      insuranceType
      status
    }
  }
''';

const String deleteSocialInsuranceMutation = r'''
  mutation DeleteSocialInsurance($id: ID!) {
    socialInsuranceDelete(id: $id) {
      id
    }
  }
''';

const String createTemporaryResidenceMutation = r'''
  mutation CreateTemporaryResidence($input: TemporaryResidenceCreateInput!) {
    temporaryResidenceCreate(input: $input) {
      id
      address
      hostName
      fromDate
      toDate
      reason
    }
  }
''';

const String updateTemporaryResidenceMutation = r'''
  mutation UpdateTemporaryResidence($input: TemporaryResidenceUpdateInput!) {
    temporaryResidenceUpdate(input: $input) {
      id
      address
      hostName
      fromDate
      toDate
      reason
    }
  }
''';

const String deleteTemporaryResidenceMutation = r'''
  mutation DeleteTemporaryResidence($id: ID!) {
    temporaryResidenceDelete(id: $id) {
      id
    }
  }
''';

const String createTemporaryAbsenceMutation = r'''
  mutation CreateTemporaryAbsence($input: TemporaryAbsenceCreateInput!) {
    temporaryAbsenceCreate(input: $input) {
      id
      destination
      fromDate
      toDate
      reason
    }
  }
''';

const String updateTemporaryAbsenceMutation = r'''
  mutation UpdateTemporaryAbsence($input: TemporaryAbsenceUpdateInput!) {
    temporaryAbsenceUpdate(input: $input) {
      id
      destination
      fromDate
      toDate
      reason
    }
  }
''';

const String deleteTemporaryAbsenceMutation = r'''
  mutation DeleteTemporaryAbsence($id: ID!) {
    temporaryAbsenceDelete(id: $id) {
      id
    }
  }
''';

const String forgotPasswordMutation = r'''
  mutation ForgotPassword($email: String!) {
    forgotPassword(email: $email) {
      message
    }
  }
''';

const String resetPasswordMutation = r'''
  mutation ResetPassword(
    $token: String!
    $email: String!
    $password: String!
    $password_confirmation: String!
  ) {
    resetPassword(
      token: $token
      email: $email
      password: $password
      password_confirmation: $password_confirmation
    ) {
      message
    }
  }
''';
