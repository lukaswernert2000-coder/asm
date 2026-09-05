import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/presentation/chat_detail_screen.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:asm/features/favorites/data/favorite_repository.dart';
import 'package:asm/features/favorites/presentation/favorite_providers.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/edit_listing_screen.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
import 'package:asm/features/moderation/domain/report_reason.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_shared_preferences.dart';

class MockListingRepository extends Mock implements ListingRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockModerationRepository extends Mock implements ModerationRepository {}

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReportReason.sonstiges);
  });

  late MockListingRepository listingRepository;
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late MockModerationRepository moderationRepository;
  late MockFavoriteRepository favoriteRepository;
  late MockCategoryRepository categoryRepository;
  late MockChatRepository chatRepository;

  const me = AsmUser(id: 'me', email: 'a@b.de', emailConfirmed: true);
  final seller = Profile(
    id: 'seller1',
    username: 'trader99',
    isCommercial: false,
    role: UserRole.user,
    createdAt: DateTime(2026, 2),
    lastSeenAt: DateTime(2026, 8, 29),
  );
  const category = Category(
    id: 'c1',
    slug: 'langwaffen',
    name: 'Gewehre & MPs',
    sortOrder: 0,
    requiresAge18: false,
    requiresFMarking: true,
    requiresJoule: true,
    requiresPropulsion: true,
    isActive: true,
  );

  Listing listing({String sellerId = 'seller1'}) => Listing(
    id: 'l1',
    sellerId: sellerId,
    categoryId: 'c1',
    title: 'G36 S-AEG mit Tuning-Gearbox',
    description: 'x' * 40,
    priceCents: 34900,
    negotiable: false,
    isGiveaway: false,
    acceptsSwap: false,
    condition: ListingCondition.gebraucht,
    status: ListingStatus.active,
    hasFMarking: false,
    isModified: false,
    ships: true,
    pickupOnly: false,
    postalCode: '76133',
    city: 'Karlsruhe',
    lat: 49.01,
    lng: 8.4,
    viewCount: 0,
    createdAt: DateTime(2026, 8),
    updatedAt: DateTime(2026, 8),
  );

  setUp(() {
    listingRepository = MockListingRepository();
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    moderationRepository = MockModerationRepository();
    favoriteRepository = MockFavoriteRepository();
    categoryRepository = MockCategoryRepository();
    chatRepository = MockChatRepository();

    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(),
    );
    when(() => listingRepository.imagePaths('l1')).thenAnswer(
      (_) async => <String>[],
    );
    when(() => listingRepository.incrementView('l1')).thenAnswer(
      (_) async {},
    );
    when(() => profileRepository.byId('seller1')).thenAnswer(
      (_) async => seller,
    );
    when(
      () => listingRepository.bySeller(
        'seller1',
        status: any(named: 'status'),
      ),
    ).thenAnswer((_) async => []);
    when(() => categoryRepository.all()).thenAnswer((_) async => [category]);
    when(() => favoriteRepository.isFavorited('l1')).thenAnswer(
      (_) async => false,
    );
    when(() => favoriteRepository.add('l1')).thenAnswer((_) async {});
    when(() => favoriteRepository.remove('l1')).thenAnswer((_) async {});
    when(
      () => moderationRepository.reportUser(
        any(),
        any(),
        details: any(named: 'details'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => moderationRepository.blockUser(any()),
    ).thenAnswer((_) async {});
  });

  // Der dritte, laengere Pump deckt die 250ms-Slide-up-Transition des
  // Melde-Sheets ab (Task 7.1) -- ohne ihn lag "Melden bestaetigen" beim
  // Tappen noch ausserhalb des sichtbaren Bereichs, mitten in der Animation.
  Future<void> pumpBriefly(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 250));
  }

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    required bool loggedIn,
    bool isAdult = true,
  }) async {
    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(loggedIn ? me : null),
    );
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        listingRepositoryProvider.overrideWithValue(listingRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        moderationRepositoryProvider.overrideWithValue(moderationRepository),
        favoriteRepositoryProvider.overrideWithValue(favoriteRepository),
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        chatRepositoryProvider.overrideWithValue(chatRepository),
        isAdultProvider.overrideWith((ref) async => isAdult),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    router.go(AsmRoutes.listing('l1'));
    await pumpBriefly(tester);
    return router;
  }

  testWidgets(
    'ohne Zurueck-Ziel (z. B. nach dem Veroeffentlichen) zeigt einen '
    'Schliessen-Button statt niemandem den Weg zurueck zu bieten',
    (tester) async {
      final router = await pumpScreen(tester, loggedIn: true);

      expect(find.byIcon(LucideIcons.x), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.x));
      await pumpBriefly(tester);

      expect(
        router.routeInformationProvider.value.uri.toString(),
        AsmRoutes.home,
      );
    },
  );

  testWidgets('zeigt Titel und erhoeht die Ansichtenzahl nur einmal', (
    tester,
  ) async {
    await pumpScreen(tester, loggedIn: true);

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
    await pumpBriefly(tester);
    verify(() => listingRepository.incrementView('l1')).called(1);
  });

  testWidgets('Fehler zeigt Retry, Tap laedt erneut', (tester) async {
    when(() => listingRepository.byId('l1')).thenThrow(Exception('boom'));
    await pumpScreen(tester, loggedIn: true);

    expect(find.text('Erneut versuchen'), findsOneWidget);

    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(),
    );
    await tester.tap(find.text('Erneut versuchen'));
    await pumpBriefly(tester);

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
  });

  testWidgets('eigenes Inserat zeigt Bearbeiten statt Nachricht schreiben', (
    tester,
  ) async {
    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(sellerId: 'me'),
    );
    when(() => profileRepository.byId('me')).thenAnswer((_) async => seller);
    when(
      () => listingRepository.bySeller('me', status: any(named: 'status')),
    ).thenAnswer((_) async => []);

    await pumpScreen(tester, loggedIn: true);

    expect(find.text('Bearbeiten'), findsOneWidget);
    expect(find.text('Nachricht schreiben'), findsNothing);

    await tester.tap(find.text('Bearbeiten'));
    await pumpBriefly(tester);

    // push() (anders als go()) aktualisiert routeInformationProvider.value.uri
    // im Test nicht zuverlaessig -- wie in my_listings_screen_test.dart wird
    // stattdessen direkt geprueft, dass der Ziel-Screen erscheint.
    expect(find.byType(EditListingScreen), findsOneWidget);
  });

  testWidgets('Gast-Tap auf Nachricht schreiben leitet zu /login um', (
    tester,
  ) async {
    final router = await pumpScreen(tester, loggedIn: false);

    await tester.tap(find.text('Nachricht schreiben'));
    await pumpBriefly(tester);

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/login?from=${AsmRoutes.listing('l1')}',
    );
  });

  testWidgets(
    'eingeloggt, Kategorie ohne Altersgate: Tap startet den Chat mit dem '
    'Verkaeufer',
    (tester) async {
      final conversation = Conversation(
        id: 'conv1',
        listingId: 'l1',
        buyerId: 'me',
        sellerId: 'seller1',
        createdAt: DateTime(2026, 8, 31),
      );
      when(() => chatRepository.getOrCreateConversation('l1')).thenAnswer(
        (_) async => conversation,
      );
      when(() => chatRepository.byId('conv1')).thenAnswer(
        (_) async => conversation,
      );
      when(() => chatRepository.messages('conv1')).thenAnswer(
        (_) => Stream.value(const []),
      );
      when(() => chatRepository.markRead('conv1')).thenAnswer((_) async {});

      await pumpScreen(tester, loggedIn: true);

      await tester.tap(find.text('Nachricht schreiben'));
      await pumpBriefly(tester);

      // push() (anders als go()) aktualisiert routeInformationProvider.value.uri
      // im Test nicht zuverlaessig -- wie in my_listings_screen_test.dart wird
      // stattdessen direkt geprueft, dass der Ziel-Screen erscheint.
      expect(find.byType(ChatDetailScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Altersgate blockiert Nachricht schreiben fuer nicht-volljaehrige Nutzer',
    (tester) async {
      final gatedCategory = category.copyWith(requiresAge18: true);
      when(() => categoryRepository.all()).thenAnswer(
        (_) async => [gatedCategory],
      );

      await pumpScreen(tester, loggedIn: true, isAdult: false);

      await tester.tap(find.text('Nachricht schreiben'));
      await pumpBriefly(tester);

      expect(find.textContaining('erst ab 18'), findsOneWidget);
    },
  );

  testWidgets('Melden im Overflow-Menue meldet den Verkaeufer', (
    tester,
  ) async {
    await pumpScreen(tester, loggedIn: true);

    await tester.tap(find.byIcon(LucideIcons.moreVertical));
    // PopupMenuButton hat eine eigene Oeffnen-Animation (~300ms) -- ein
    // pumpBriefly() reicht nicht, bis die Eintraege wirklich antippbar sind.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Melden'));
    await pumpBriefly(tester);
    await tester.tap(find.text('Spam'));
    await pumpBriefly(tester);
    await tester.tap(find.text('Melden bestätigen'));
    await pumpBriefly(tester);

    verify(
      () => moderationRepository.reportUser(
        'seller1',
        ReportReason.spam,
        details: any(named: 'details'),
      ),
    ).called(1);
  });

  testWidgets('Favoriten-Herz ruft add() auf', (tester) async {
    await pumpScreen(tester, loggedIn: true);

    await tester.tap(find.byIcon(LucideIcons.heart));
    await pumpBriefly(tester);

    verify(() => favoriteRepository.add('l1')).called(1);
  });
}
