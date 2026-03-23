const String adminLoginMutation = r'''
  mutation AdminLogin($email: String!, $password: String!) {
    adminLogin(input: { email: $email, password: $password }) {
      access_token
    }
  }
''';

const String createUserMutation = r'''
  mutation UserCreate($input: UserCreateInput!) {
    userCreate(input: $input) {
      id
      name
      email
      roles
    }
  }
''';

const String updateUserMutation = r'''
  mutation UserUpdate($input: UserUpdateInput!) {
    userUpdate(input: $input) {
      id
      name
      email
      roles
    }
  }
''';

const String deleteUserMutation = r'''
  mutation UserDelete($id: ID!) {
    userDelete(id: $id) {
      id
    }
  }
''';
