import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/domain/message.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_shared_preferences.dart';

class MockChatRepository extends Mock implements ChatRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockChatRepository chatRepository;
  late MockCategoryRepository categoryRepository;
  late MockAuthRepository authRepository;

  const me = AsmUser(id: 'me', email: 'a@b.de', emailConfirmed: true);

  Conversation conversation() => Conversation(
    id: 'conv1',
    listingId: 'l1',
    buyerId: 'me',
    sellerId: 'seller1',
    createdAt: DateTime(2026, 8, 31, 9),
    lastMessageAt: DateTime(2026, 8, 31, 9, 5),
  );

  Message message({DateTime? readAt}) => Message(
    id: 'm1',
    conversationId: 'conv1',
    senderId: 'seller1',
    body: 'Ist das noch da?',
    createdAt: DateTime(2026, 8, 31, 9, 5),
    readAt: readAt,
  );

  setUp(() {
    chatRepository = MockChatRepository();
    categoryRepository = MockCategoryRepository();
    authRepository = MockAuthRepository();

    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(me),
    );
    when(() => categoryRepository.all()).thenAnswer((_) async => []);
  });

  Future<void> pumpBriefly(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> pumpShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(chatRepository),
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
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
    await pumpBriefly(tester);
  }

  testWidgets('kein Ungelesen-Punkt in der BottomNav ohne ungelesene Chats', (
    tester,
  ) async {
    when(() => chatRepository.conversations()).thenAnswer(
      (_) => Stream.value([conversation()]),
    );
    when(() => chatRepository.messages('conv1')).thenAnswer(
      (_) => Stream.value([message(readAt: DateTime(2026, 8, 31, 9, 6))]),
    );

    await pumpShell(tester);

    expect(find.byKey(const Key('unreadNavBadge')), findsNothing);
  });

  testWidgets(
    'Ungelesen-Punkt in der BottomNav bei einer ungelesenen Nachricht',
    (tester) async {
      when(() => chatRepository.conversations()).thenAnswer(
        (_) => Stream.value([conversation()]),
      );
      when(() => chatRepository.messages('conv1')).thenAnswer(
        (_) => Stream.value([message()]),
      );

      await pumpShell(tester);

      expect(find.byKey(const Key('unreadNavBadge')), findsOneWidget);
    },
  );
}
