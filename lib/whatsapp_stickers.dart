/// Adds sticker packs to WhatsApp from a Flutter app.
///
/// Build a [WhatsappStickers] pack, add its stickers with
/// [WhatsappStickers.addSticker], then hand it to WhatsApp with
/// [WhatsappStickers.sendToWhatsApp]:
///
/// ```dart
/// final pack = WhatsappStickers(
///   identifier: 'cuppyFlutterWhatsAppStickers',
///   name: 'Cuppy Flutter WhatsApp Stickers',
///   publisher: 'John Doe',
///   trayImageFileName: WhatsappStickerImage.fromAsset('assets/tray_Cuppy.png'),
/// );
///
/// pack.addSticker(
///   WhatsappStickerImage.fromAsset('assets/01_Cuppy_smile.webp'),
///   ['☕', '🙂'],
/// );
/// // ...at least three stickers in total.
///
/// try {
///   await pack.sendToWhatsApp();
/// } on WhatsappStickersException catch (e) {
///   debugPrint('${e.cause}');
/// }
/// ```
///
/// Stickers are WebP images and the tray image is a PNG. See the README for the
/// per-platform setup each side needs — `noCompress "webp"` on Android, and the
/// `LSApplicationQueriesSchemes` entry on iOS.
library;

import 'package:flutter/services.dart';
import 'exceptions.dart';

/// A sticker pack to be handed to WhatsApp.
///
/// Create one, add between 3 and 30 stickers with [addSticker], then call
/// [sendToWhatsApp]. An instance is reusable: the stickers you add accumulate
/// until the object is discarded.
class WhatsappStickers {
  static const MethodChannel _channel =
      MethodChannel('whatsapp_stickers_injector');

  final Map<String, List<String>> _stickers = {};

  /// Uniquely identifies this pack to WhatsApp.
  ///
  /// WhatsApp keys installed packs on this value, so reusing an identifier for
  /// a pack the user already has results in a
  /// [WhatsappStickersAlreadyAddedException]. At most 128 characters.
  final String identifier;

  /// The pack name WhatsApp shows to the user. At most 128 characters.
  final String name;

  /// The publisher name WhatsApp shows to the user. At most 128 characters.
  final String publisher;

  /// The small PNG icon representing the pack in WhatsApp's sticker tray.
  ///
  /// Unlike the stickers themselves, which are WebP, this one is PNG.
  final WhatsappStickerImage trayImageFileName;

  /// An optional website for the publisher.
  String? publisherWebsite;

  /// An optional link to the privacy policy covering the pack.
  String? privacyPolicyWebsite;

  /// An optional link to the pack's license agreement.
  String? licenseAgreementWebsite;

  /// Creates a sticker pack description.
  ///
  /// This only describes the pack; nothing reaches WhatsApp until
  /// [sendToWhatsApp] is called. The optional website arguments must be full
  /// URLs including the scheme when provided.
  WhatsappStickers({
    required this.identifier,
    required this.name,
    required this.publisher,
    required this.trayImageFileName,
    this.publisherWebsite,
    this.privacyPolicyWebsite,
    this.licenseAgreementWebsite,
  });

  /// Adds one sticker to the pack.
  ///
  /// [image] is the 512x512 WebP sticker, and [emojis] the 1 to 3 emoji that
  /// WhatsApp uses to suggest it. Adding two images with the same path replaces
  /// the earlier entry's emoji rather than adding a second sticker.
  ///
  /// Nothing is validated here — an invalid pack is reported by
  /// [sendToWhatsApp].
  void addSticker(WhatsappStickerImage image, List<String> emojis) {
    _stickers[image.path] = emojis;
  }

  /// Sends the pack to WhatsApp and asks it to install it.
  ///
  /// WhatsApp shows its own confirmation prompt, so the returned future
  /// completes only once the user has answered it.
  ///
  /// Throws a [WhatsappStickersException] subclass if the pack is rejected or
  /// not added. Two of those are ordinary outcomes rather than bugs:
  /// [WhatsappStickersCancelledException] when the user dismisses the prompt,
  /// and [WhatsappStickersAlreadyAddedException] when the pack is already
  /// installed. Anything the native side reports that does not map to a
  /// specific subclass surfaces as a plain [WhatsappStickersException].
  Future<void> sendToWhatsApp() async {
    try {
      final payload = <String, dynamic>{};
      payload['identifier'] = identifier;
      payload['name'] = name;
      payload['publisher'] = publisher;
      payload['trayImageFileName'] = trayImageFileName.path;
      payload['publisherWebsite'] = publisherWebsite;
      payload['privacyPolicyWebsite'] = privacyPolicyWebsite;
      payload['licenseAgreementWebsite'] = licenseAgreementWebsite;
      payload['stickers'] = _stickers;
      await _channel.invokeMethod('sendToWhatsApp', payload);
    } on PlatformException catch (e) {
      switch (e.code.toUpperCase()) {
        case WhatsappStickersFileNotFoundException.code:
          throw WhatsappStickersFileNotFoundException(e.message);
        case WhatsappStickersNumOutsideAllowableRangeException.code:
          throw WhatsappStickersNumOutsideAllowableRangeException(e.message);
        case WhatsappStickersUnsupportedImageFormatException.code:
          throw WhatsappStickersUnsupportedImageFormatException(e.message);
        case WhatsappStickersImageTooBigException.code:
          throw WhatsappStickersImageTooBigException(e.message);
        case WhatsappStickersIncorrectImageSizeException.code:
          throw WhatsappStickersIncorrectImageSizeException(e.message);
        case WhatsappStickersAnimatedImagesNotSupportedException.code:
          throw WhatsappStickersAnimatedImagesNotSupportedException(e.message);
        case WhatsappStickersTooManyEmojisException.code:
          throw WhatsappStickersTooManyEmojisException(e.message);
        case WhatsappStickersEmptyStringException.code:
          throw WhatsappStickersEmptyStringException(e.message);
        case WhatsappStickersStringTooLongException.code:
          throw WhatsappStickersStringTooLongException(e.message);
        case WhatsappStickersAlreadyAddedException.code:
          throw WhatsappStickersAlreadyAddedException(e.message);
        case WhatsappStickersCancelledException.code:
          throw WhatsappStickersCancelledException(e.message);
        default:
          throw WhatsappStickersException(e.message);
      }
    }
  }
}

/// Points at an image to use as a sticker or as a pack's tray icon.
///
/// Use [WhatsappStickerImage.fromAsset] for images bundled with the app and
/// [WhatsappStickerImage.fromFile] for ones on disk, such as downloads.
class WhatsappStickerImage {
  /// The scheme-prefixed location the native side resolves.
  ///
  /// Either `assets://` followed by the asset key, or `file://` followed by an
  /// absolute path, depending on which constructor was used.
  final String path;

  WhatsappStickerImage._internal(this.path);

  /// Refers to an image bundled with the app.
  ///
  /// [asset] is the asset key as written in `pubspec.yaml`, for example
  /// `assets/01_Cuppy_smile.webp`. The asset must be declared there or it will
  /// not be found at runtime.
  factory WhatsappStickerImage.fromAsset(String asset) {
    return WhatsappStickerImage._internal('assets://$asset');
  }

  /// Refers to an image on the device's file system.
  ///
  /// [file] is an absolute path, typically somewhere your app can read such as
  /// the documents directory. Use this for stickers downloaded at runtime.
  factory WhatsappStickerImage.fromFile(String file) {
    return WhatsappStickerImage._internal('file://$file');
  }
}
