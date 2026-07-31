import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/photo_service.dart';

import 'features/auth/data/datasources/auth_data_source.dart';
import 'features/auth/data/datasources/firebase_auth_data_source.dart';
import 'features/auth/data/datasources/mock_auth_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/change_password.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/send_email_verification.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/update_profile.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/send_password_reset.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/booking/data/datasources/booking_data_source.dart';
import 'features/booking/data/datasources/firestore_booking_data_source.dart';
import 'features/booking/data/datasources/mock_booking_data_source.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/domain/usecases/cancel_booking.dart';
import 'features/booking/domain/usecases/create_booking.dart';
import 'features/booking/domain/usecases/get_bookings.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/lifestyle/data/datasources/lifestyle_local_data_source.dart';
import 'features/lifestyle/data/repositories/lifestyle_repository_impl.dart';
import 'features/lifestyle/domain/repositories/lifestyle_repository.dart';
import 'features/lifestyle/domain/usecases/get_lifestyle_profile.dart';
import 'features/lifestyle/domain/usecases/save_lifestyle_profile.dart';
import 'features/lifestyle/presentation/cubit/lifestyle_cubit.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/property/data/datasources/firestore_property_data_source.dart';
import 'features/property/data/datasources/mock_property_data_source.dart';
import 'features/property/data/datasources/property_data_source.dart';
import 'features/property/data/repositories/property_repository_impl.dart';
import 'features/property/domain/repositories/property_repository.dart';
import 'features/property/domain/usecases/create_listing.dart';
import 'features/property/domain/usecases/delete_listing.dart';
import 'features/property/domain/usecases/update_listing.dart';
import 'features/property/domain/usecases/get_properties.dart';
import 'features/property/domain/usecases/search_properties.dart';
import 'features/property/domain/usecases/toggle_favorite.dart';
import 'features/property/presentation/bloc/property_bloc.dart';
import 'features/property/presentation/cubit/search_cubit.dart';
import 'features/settings/data/datasources/preferences_local_data_source.dart';
import 'features/settings/data/repositories/preferences_repository_impl.dart';
import 'features/settings/domain/repositories/preferences_repository.dart';
import 'features/settings/domain/usecases/get_preferences.dart';
import 'features/settings/domain/usecases/save_preferences.dart';
import 'features/settings/presentation/cubit/preferences_cubit.dart';

final sl = GetIt.instance;

/// Wires every layer together (data sources -> repositories -> use cases ->
/// blocs). When [useFirebase] is false — i.e. `flutterfire configure` has
/// not been run yet — in-memory mock data sources are registered instead so
/// the app remains fully functional in demo mode.
Future<void> init({required bool useFirebase}) async {
  // ---------- External ----------
  // SharedPreferences is resolved once here so the rest of the graph can
  // depend on it synchronously.
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Cloud Storage needs the Blaze billing plan, which this project is not on,
  // so photos are compressed and embedded in the Firestore document instead.
  // Swap this for FirebasePhotoService the moment Storage is available.
  sl.registerLazySingleton<PhotoService>(
    () => useFirebase ? InlinePhotoService() : LocalPhotoService(),
  );

  // ---------- Data sources ----------
  sl.registerLazySingleton<PreferencesLocalDataSource>(
    () => SharedPrefsPreferencesDataSource(sl()),
  );
  sl.registerLazySingleton<LifestyleLocalDataSource>(
    () => SharedPrefsLifestyleDataSource(sl()),
  );

  if (useFirebase) {
    sl.registerLazySingleton<AuthDataSource>(
      () => FirebaseAuthDataSource(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
    );
    sl.registerLazySingleton<PropertyDataSource>(
      () => FirestorePropertyDataSource(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      ),
    );
    sl.registerLazySingleton<BookingDataSource>(
      () => FirestoreBookingDataSource(
        firestore: FirebaseFirestore.instance,
        auth: FirebaseAuth.instance,
      ),
    );
  } else {
    sl.registerLazySingleton<AuthDataSource>(() => MockAuthDataSource());
    sl.registerLazySingleton<PropertyDataSource>(
      () => MockPropertyDataSource(),
    );
    sl.registerLazySingleton<BookingDataSource>(() => MockBookingDataSource());
  }

  // ---------- Repositories ----------
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<PropertyRepository>(
    () => PropertyRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PreferencesRepository>(
    () => PreferencesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LifestyleRepository>(
    () => LifestyleRepositoryImpl(sl()),
  );

  // ---------- Use cases ----------
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => ChangePassword(sl()));
  sl.registerLazySingleton(() => SendPasswordReset(sl()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => SendEmailVerification(sl()));
  sl.registerLazySingleton(() => GetProperties(sl()));
  sl.registerLazySingleton(() => SearchProperties(sl()));
  sl.registerLazySingleton(() => ToggleFavorite(sl()));
  sl.registerLazySingleton(() => CreateListing(sl()));
  sl.registerLazySingleton(() => UpdateListing(sl()));
  sl.registerLazySingleton(() => DeleteListing(sl()));
  sl.registerLazySingleton(() => GetBookings(sl()));
  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => CancelBooking(sl()));
  sl.registerLazySingleton(() => GetPreferences(sl()));
  sl.registerLazySingleton(() => SavePreferences(sl()));
  sl.registerLazySingleton(() => GetLifestyleProfile(sl()));
  sl.registerLazySingleton(() => SaveLifestyleProfile(sl()));

  // ---------- Blocs / cubits ----------
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signInWithGoogle: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      changePassword: sl(),
      updateProfile: sl(),
      sendEmailVerification: sl(),
    ),
  );
  sl.registerFactory(
    () => PropertyBloc(
      getProperties: sl(),
      toggleFavorite: sl(),
      deleteListing: sl(),
    ),
  );
  sl.registerFactory(
    () => BookingBloc(
      getBookings: sl(),
      createBooking: sl(),
      cancelBooking: sl(),
    ),
  );
  sl.registerFactory(() => SearchCubit(searchProperties: sl()));
  sl.registerFactory(() => NotificationsCubit());

  // A singleton, not a factory: the chosen theme has to be the same instance
  // everywhere so MaterialApp and the settings page never disagree.
  sl.registerLazySingleton(
    () => PreferencesCubit(getPreferences: sl(), savePreferences: sl()),
  );

  // Also a singleton: every listing screen must score against the same
  // lifestyle answers.
  sl.registerLazySingleton(
    () => LifestyleCubit(getLifestyleProfile: sl(), saveLifestyleProfile: sl()),
  );
}
