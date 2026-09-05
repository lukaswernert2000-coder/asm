import 'dart:async';

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/domain/message.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
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

class MockChatRepository extends Mock implements ChatRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockModerationRepository extends Mock implements ModerationRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockChatRepository chatRepository;
  late MockListingRepository listingRepository;
  late MockProfileRepository profileRepository;
  late MockModerationRepository moderationRepository;
  late MockAuthRepository authRepository;

  const me = AsmUser(id: 'me', email: 'a@b.de', emailConfirmed: true);

  final other = Profile(
    id: 'seller1',
    username: 'trader99',
    isCommercial: false,
    role: UserRole.user,
    createdAt: DateTime(2026, 2),
    lastSeenAt: DateTime(2026, 8, 29),
  );

  Listing listing() => Listing(
    id: 'l1',
    sellerId: 'seller1',
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

  Conversation conversation() => Conversation(
    id: 'conv1',
    listingId: 'l1',
    buyerId: 'me',
    sellerId: 'seller1',
    createdAt: DateTime(2026, 8, 31, 9),
    lastMessageAt: DateTime(2026, 8, 31, 9, 5),
  );

  Message message({
    required String id,
    required String senderId,
    required String body,
    DateTime? readAt,
  }) => Message(
    id: id,
    conversationId: 'conv1',
    senderId: senderId,
    body: body,
    createdAt: DateTime(2026, 8, 31, 9, 5),
    readAt: readAt,
  );

  setUp(() {
    chatRepository = MockChatRepository();
    listingRepository = MockListingRepository();
    profileRepository = MockProfileRepository();
    moderationRepository = MockModerationRepository();
    authRepository = MockAuthRepository();

    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(me),
    );
    when(() => chatRepository.byId('conv1')).thenAnswer(
      (_) async => conversation(),
    );
    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(),
    );
    when(() => listingRepository.imagePaths('l1')).thenAnswer(
      (_) async => <String>[],
    );
    when(() => profileRepository.byId('seller1')).thenAnswer(
      (_) async => other,
    );
    when(() => chatRepository.markRead('conv1')).thenAnswer((_) async {});
  });

  Future<void> pumpBriefly(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<GoRouter> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(chatRepository),
        listingRepositoryProvider.overrideWithValue(listingRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        moderationRepositoryProvider.overrideWithValue(moderationRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
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
    router.go(AsmRoutes.chat('conv1'));
    await pumpBriefly(tester);
    return router;
  }

  testWidgets('ruft markRead beim Oeffnen auf', (tester) async {
    when(() => chatRepository.messages('conv1')).thenAnswer(
      (_) => Stream.value([message(id: 'm1', senderId: 'seller1', body: 'Hi')]),
    );

    await pumpScreen(tester);

    verify(() => chatRepository.markRead('conv1')).called(1);
  });

  testWidgets('leerer Chat zeigt Leerzustand und die ListingChip-Karte', (
    tester,
  ) async {
    when(() => chatRepository.messages('conv1')).thenAnswer(
      (_) => Stream.value(<Message>[]),
    );

    await pumpScreen(tester);

    expect(find.text('Noch keine Nachrichten'), findsOneWidget);
    expect(
      find.textContaining('Frag den Verkäufer'),
      findsOneWidget,
    );
    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
  });

  testWidgets('zeigt Nachrichten beider Seiten', (tester) async {
    when(() => chatRepository.messages('conv1')).thenAnswer(
      (_) => Stream.value([
        message(id: 'm1', senderId: 'me', body: 'Ist es noch da?'),
        message(id: 'm2', senderId: 'seller1', body: 'Ja klar'),
      ]),
    );

    await pumpScreen(tester);

    expect(find.text('Ist es noch da?'), findsOneWidget);
    expect(find.text('Ja klar'), findsOneWidget);
  });

  testWidgets(
    'zeigt einen Hinweis statt des Eingabefelds, wenn ich blockiert habe',
    (tester) async {
      when(() => chatRepository.messages('conv1')).thenAnswer(
        (_) => Stream.value(<Message>[]),
      );
      when(() => moderationRepository.isBlockedByMe('seller1')).thenAnswer(
        (_) async => true,
      );

      await pumpScreen(tester);

      expect(find.text('Ihr könnt euch nicht mehr schreiben.'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(LucideIcons.send), findsNothing);
    },
  );

  testWidgets(
    'Senden zeigt die Nachricht optimistisch an und ruft send() auf',
    (tester) async {
      when(() => chatRepository.messages('conv1')).thenAnswer(
        (_) => Stream.value(<Message>[]),
      );
      final sendCompleter = Completer<void>();
      when(() => chatRepository.send('conv1', 'Hallo!')).thenAnswer(
        (_) => sendCompleter.future,
      );

      await pumpScreen(tester);
      await tester.enterText(find.byType(TextField), 'Hallo!');
      await tester.tap(find.byIcon(LucideIcons.send));
      await tester.pump();

      expect(find.text('Hallo!'), findsOneWidget);
      verify(() => chatRepository.send('conv1', 'Hallo!')).called(1);

      sendCompleter.complete();
      await pumpBriefly(tester);
    },
  );

  testWidgets(
    'fehlgeschlagenes Senden zeigt ein Wiederholen-Symbol, Retry sendet erneut',
    (tester) async {
      when(() => chatRepository.messages('conv1')).thenAnswer(
        (_) => Stream.value(<Message>[]),
      );
      when(() => chatRepository.send('conv1', 'Hallo!')).thenThrow(
        const NetworkException(),
      );

      await pumpScreen(tester);
      await tester.enterText(find.byType(TextField), 'Hallo!');
      await tester.tap(find.byIcon(LucideIcons.send));
      await pumpBriefly(tester);

      expect(find.byIcon(LucideIcons.refreshCw), findsOneWidget);

      when(() => chatRepository.send('conv1', 'Hallo!')).thenAnswer(
        (_) async {},
      );
      await tester.tap(find.byIcon(LucideIcons.refreshCw));
      await pumpBriefly(tester);

      verify(() => chatRepository.send('conv1', 'Hallo!')).called(2);
    },
  );

  testWidgets('Chat loeschen fragt nach Bestaetigung und ruft hide() aus', (
    tester,
  ) async {
    when(() => chatRepository.messages('conv1')).thenAnswer(
      (_) => Stream.value(<Message>[]),
    );

    await pumpScreen(tester);

    await tester.tap(find.byIcon(LucideIcons.moreVertical));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Chat löschen'));
    await pumpBriefly(tester);

    expect(find.text('Löschen bestätigen'), findsOneWidget);
    await tester.tap(find.text('Löschen bestätigen'));
    await pumpBriefly(tester);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    expect(
      container.read(hiddenConversationIdsProvider).containsKey('conv1'),
      isTrue,
    );
  });
}
