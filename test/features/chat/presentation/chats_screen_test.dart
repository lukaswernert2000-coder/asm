import 'dart:async';

import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/domain/message.dart';
import 'package:asm/features/chat/presentation/chat_detail_screen.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_shared_preferences.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockChatRepository chatRepository;
  late MockListingRepository listingRepository;
  late MockProfileRepository profileRepository;
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
    lastMessageBody: 'Ist das noch da?',
    lastMessageSenderId: 'seller1',
  );

  Message message({required String senderId, DateTime? readAt}) => Message(
    id: 'm1',
    conversationId: 'conv1',
    senderId: senderId,
    body: 'Ist das noch da?',
    createdAt: DateTime(2026, 8, 31, 9, 5),
    readAt: readAt,
  );

  setUp(() {
    chatRepository = MockChatRepository();
    listingRepository = MockListingRepository();
    profileRepository = MockProfileRepository();
    authRepository = MockAuthRepository();

    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(me),
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
    router.go(AsmRoutes.chats);
    await pumpBriefly(tester);
    return router;
  }

  testWidgets('zeigt einen leeren Zustand ohne Konversationen', (
    tester,
  ) async {
    when(() => chatRepository.conversations())
        .thenAnswer((_) => Stream.value(<Conversation>[]));

    await pumpScreen(tester);

    expect(find.text('Noch keine Chats'), findsOneWidget);
  });

  testWidgets(
    'zeigt eine Zeile mit Titel, Gegenueber, letzter Nachricht und Zeit',
    (tester) async {
      when(() => chatRepository.conversations()).thenAnswer(
        (_) => Stream.value([conversation()]),
      );
      when(() => chatRepository.messages('conv1')).thenAnswer(
        (_) => Stream.value([message(senderId: 'seller1')]),
      );

      await pumpScreen(tester);

      expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
      expect(find.text('trader99'), findsOneWidget);
      expect(find.text('Ist das noch da?'), findsOneWidget);
    },
  );

  testWidgets(
    'zeigt einen Ungelesen-Punkt bei einer ungelesenen fremden Nachricht',
    (tester) async {
      when(() => chatRepository.conversations()).thenAnswer(
        (_) => Stream.value([conversation()]),
      );
      when(() => chatRepository.messages('conv1')).thenAnswer(
        (_) => Stream.value([message(senderId: 'seller1')]),
      );

      await pumpScreen(tester);

      expect(find.byKey(const Key('unreadDot_conv1')), findsOneWidget);
    },
  );

  testWidgets('kein Ungelesen-Punkt, wenn die letzte Nachricht gelesen ist', (
    tester,
  ) async {
    when(() => chatRepository.conversations()).thenAnswer(
      (_) => Stream.value([conversation()]),
    );
    when(() => chatRepository.messages('conv1')).thenAnswer(
      (_) => Stream.value([
        message(senderId: 'seller1', readAt: DateTime(2026, 8, 31, 9, 6)),
      ]),
    );

    await pumpScreen(tester);

    expect(find.byKey(const Key('unreadDot_conv1')), findsNothing);
  });

  testWidgets('Tap auf eine Zeile navigiert zur Chat-Detailseite', (
    tester,
  ) async {
    when(() => chatRepository.conversations()).thenAnswer(
      (_) => Stream.value([conversation()]),
    );
    when(() => chatRepository.messages('conv1')).thenAnswer(
      (_) => Stream.value([message(senderId: 'seller1')]),
    );
    when(() => chatRepository.byId('conv1')).thenAnswer(
      (_) async => conversation(),
    );
    when(() => chatRepository.markRead('conv1')).thenAnswer((_) async {});

    await pumpScreen(tester);
    await tester.tap(find.text('G36 S-AEG mit Tuning-Gearbox'));
    await pumpBriefly(tester);

    expect(find.byType(ChatDetailScreen), findsOneWidget);
  });
}
