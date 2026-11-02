import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whatsapp_stickers_injector/exceptions.dart';
import 'package:whatsapp_stickers_injector/whatsapp_stickers.dart';

const _channel = MethodChannel('whatsapp_stickers_injector');

WhatsappStickers _pack({bool? animated}) {
  final pack = WhatsappStickers(
    identifier: 'test_pack',
    name: 'Test',
    publisher: 'Me',
    trayImageFileName: WhatsappStickerImage.fromAsset('assets/tray.png'),
    animatedStickerPack: animated,
  );
  for (var i = 0; i < 3; i++) {
    pack.addSticker(WhatsappStickerImage.fromAsset('assets/$i.webp'), ['😀']);
  }
  return pack;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<dynamic, dynamic>? sent;

  void mockChannel(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, handler);
  }

  setUp(() {
    sent = null;
    mockChannel((call) async {
      sent = call.arguments as Map<dynamic, dynamic>;
      return 'success';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  test('payload carries the animated flag as null by default (auto-detect)',
      () async {
    await _pack().sendToWhatsApp();
    expect(sent, contains('animatedStickerPack'));
    expect(sent!['animatedStickerPack'], isNull);
    expect(sent!['identifier'], 'test_pack');
    expect((sent!['stickers'] as Map).length, 3);
  });

  test('payload carries an explicit animated flag', () async {
    await _pack(animated: true).sendToWhatsApp();
    expect(sent!['animatedStickerPack'], true);
    await _pack(animated: false).sendToWhatsApp();
    expect(sent!['animatedStickerPack'], false);
  });

  group('maps animation error codes to typed exceptions', () {
    Future<void> expectCode<T extends Exception>(String code) async {
      mockChannel(
          (call) async => throw PlatformException(code: code, message: 'm'));
      expect(_pack().sendToWhatsApp(), throwsA(isA<T>()));
    }

    test(
        'STATIC_STICKER_IN_ANIMATED_PACK',
        () => expectCode<WhatsappStickersStaticStickerInAnimatedPackException>(
            'STATIC_STICKER_IN_ANIMATED_PACK'));
    test(
        'INVALID_ANIMATION',
        () => expectCode<WhatsappStickersInvalidAnimationException>(
            'INVALID_ANIMATION'));
    test(
        'ANIMATED_IMAGES_NOT_SUPPORTED',
        () => expectCode<WhatsappStickersAnimatedImagesNotSupportedException>(
            'ANIMATED_IMAGES_NOT_SUPPORTED'));
  });
}
