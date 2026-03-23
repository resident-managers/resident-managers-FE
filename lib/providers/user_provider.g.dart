// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserManagement)
final userManagementProvider = UserManagementProvider._();

final class UserManagementProvider
    extends $NotifierProvider<UserManagement, UserManagementState> {
  UserManagementProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userManagementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userManagementHash();

  @$internal
  @override
  UserManagement create() => UserManagement();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserManagementState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserManagementState>(value),
    );
  }
}

String _$userManagementHash() => r'd9214916dd8dca6577a7ba2ac91d153fa311b017';

abstract class _$UserManagement extends $Notifier<UserManagementState> {
  UserManagementState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserManagementState, UserManagementState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserManagementState, UserManagementState>,
              UserManagementState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
