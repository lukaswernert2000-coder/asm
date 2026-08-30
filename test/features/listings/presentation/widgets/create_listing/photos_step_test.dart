import 'dart:io';
import 'dart:ui' as ui;

import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/data/image_service.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/photos_step.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../helpers/fake_shared_preferences.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockImageService extends Mock implements ImageService {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

final _profile = Profile(
  id: 'u1',
  username: 'gear_hunter_42',
  isCommercial: false,
  role: UserRole.user,
  createdAt: DateTime(2026),
  lastSeenAt: DateTime(2026),
);

Future<String> _tempImagePath(String name) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    const ui.Rect.fromLTWH(0, 0, 10, 10),
    ui.Paint()..color = const ui.Color(0xFF224422),
  );
  final image = await recorder.endRecording().toImage(10, 10);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  final dir = await Directory.systemTemp.createTemp('photos_step_test_');
  final file = File('${dir.path}/$name.png')
    ..writeAsBytesSync(byteData!.buffer.asUint8List());
  return file.path;
}

void main() {
  late MockCategoryRepository categoryRepository;
  late MockImageService imageService;
  late String testImagePath;

  setUpAll(() async {
    testImagePath = await _tempImagePath('fixture');
    registerFallbackValue(File('fallback'));
  });

  setUp(() {
    categoryRepository = MockCategoryRepository();
    imageService = MockImageService();
  });

  tearDownAll(() {
    File(testImagePath).parent.deleteSync(recursive: true);
  });

  const pistolen = Category(
    id: 'c1',
    slug: 'pistolen-revolver',
    name: 'Revolver',
    sortOrder: 1,
    requiresAge18: true,
    requiresFMarking: true,
    requiresJoule: true,
    requiresPropulsion: true,
    isActive: true,
    parentId: 'p1',
  );
  const accessory = Category(
    id: 'c2',
    slug: 'zubehoer-magazine',
    name: 'Magazine',
    sortOrder: 1,
    requiresAge18: false,
    requiresFMarking: false,
    requiresJoule: false,
    requiresPropulsion: false,
    isActive: true,
    parentId: 'p2',
  );

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    required CreateListingDraft draft,
    VoidCallback? onNext,
  }) async {
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        imageServiceProvider.overrideWithValue(imageService),
        supabaseProvider.overrideWithValue(MockSupabaseClient()),
        currentProfileProvider.overrideWith((ref) async => _profile),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(createListingDraft: draft),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: PhotosStep(onNext: onNext ?? () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('zeigt F-Kennzeichen-Slot nur wenn die Kategorie es verlangt', (
    tester,
  ) async {
    when(
      () => categoryRepository.all(),
    ).thenAnswer((_) async => [pistolen, accessory]);

    await pumpScreen(
      tester,
      draft: const CreateListingDraft(categoryId: 'c2'),
    );
    expect(find.text('F-Kennzeichen'), findsNothing);
    expect(find.text('Besitznachweis'), findsOneWidget);
    expect(find.textContaining('gear_hunter_42'), findsOneWidget);
  });

  testWidgets('zeigt F-Kennzeichen-Slot wenn die Kategorie es verlangt', (
    tester,
  ) async {
    when(
      () => categoryRepository.all(),
    ).thenAnswer((_) async => [pistolen, accessory]);

    await pumpScreen(
      tester,
      draft: const CreateListingDraft(categoryId: 'c1'),
    );
    expect(find.text('F-Kennzeichen'), findsOneWidget);
  });

  testWidgets(
    'Weiter ist erst aktiv wenn Foto, F-Kennzeichen und Besitznachweis gesetzt sind',
    (tester) async {
      when(
        () => categoryRepository.all(),
      ).thenAnswer((_) async => [pistolen, accessory]);

      bool nextEnabled() =>
          tester
              .widget<InkWell>(
                find.descendant(
                  of: find.byKey(const Key('photosStepNext')),
                  matching: find.byType(InkWell),
                ),
              )
              .onTap !=
          null;

      // Nur ein Foto, requiresFMarking-Kategorie -- noch nicht genug.
      await pumpScreen(
        tester,
        draft: CreateListingDraft(
          categoryId: 'c1',
          images: [
            DraftImage(localPath: testImagePath, kind: ImageKind.photo),
          ],
        ),
      );
      expect(nextEnabled(), isFalse);

      // Foto + F-Kennzeichen + Besitznachweis -- jetzt vollstaendig.
      await pumpScreen(
        tester,
        draft: CreateListingDraft(
          categoryId: 'c1',
          images: [
            DraftImage(localPath: testImagePath, kind: ImageKind.photo),
            DraftImage(localPath: testImagePath, kind: ImageKind.fMarking),
            DraftImage(
              localPath: testImagePath,
              kind: ImageKind.ownershipProof,
            ),
          ],
        ),
      );
      expect(nextEnabled(), isTrue);
    },
  );

  testWidgets('entfernt ein Bild ueber den X-Button', (tester) async {
    when(
      () => categoryRepository.all(),
    ).thenAnswer((_) async => [pistolen, accessory]);

    final container = await pumpScreen(
      tester,
      draft: CreateListingDraft(
        categoryId: 'c2',
        images: [DraftImage(localPath: testImagePath, kind: ImageKind.photo)],
      ),
    );

    expect(
      container
          .read(createListingDraftProvider)
          .images
          .where((i) => i.kind == ImageKind.photo),
      hasLength(1),
    );

    await tester.tap(find.byKey(Key('removeImage_$testImagePath')));
    await tester.pumpAndSettle();

    expect(
      container
          .read(createListingDraftProvider)
          .images
          .where((i) => i.kind == ImageKind.photo),
      isEmpty,
    );
  });

  testWidgets('Galerie-Auswahl fuegt ein komprimiertes Foto hinzu', (
    tester,
  ) async {
    when(
      () => categoryRepository.all(),
    ).thenAnswer((_) async => [pistolen, accessory]);
    when(
      () => imageService.pickFromGallery(max: any(named: 'max')),
    ).thenAnswer((_) async => [XFile(testImagePath)]);
    when(
      () => imageService.compress(any()),
    ).thenAnswer(
      (invocation) async => invocation.positionalArguments[0] as File,
    );

    final container = await pumpScreen(
      tester,
      draft: const CreateListingDraft(categoryId: 'c2'),
    );

    await tester.tap(find.byKey(const Key('photosStepAdd')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aus der Galerie'));
    await tester.pumpAndSettle();

    final images = container
        .read(createListingDraftProvider)
        .images
        .where((i) => i.kind == ImageKind.photo);
    expect(images, hasLength(1));
    expect(images.first.localPath, testImagePath);
  });
}
