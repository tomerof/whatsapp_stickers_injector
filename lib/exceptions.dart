/// The typed exceptions `WhatsappStickers.sendToWhatsApp` can throw.
///
/// Every failure reported by the native side arrives as a subclass of
/// [WhatsappStickersException], so a single `on WhatsappStickersException`
/// clause is enough to handle them all. Catch a specific subclass only when you
/// want to react to that one condition — most usefully
/// [WhatsappStickersCancelledException] and
/// [WhatsappStickersAlreadyAddedException], which are ordinary user outcomes
/// rather than programming errors.
library;

/// The base class for every error raised while adding a sticker pack.
///
/// Thrown directly when the native side reports a failure that does not map to
/// one of the more specific subclasses below.
class WhatsappStickersException implements Exception {
  /// The message from the underlying platform error, if it provided one.
  ///
  /// Intended for logging and debugging; it is not localized and is not
  /// suitable for display to users.
  final String? cause;

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersException(this.cause);

  @override
  String toString() => 'Unknown error: $cause';
}

/// Thrown when a sticker image or the tray image could not be read.
///
/// Usually means the path passed to `WhatsappStickerImage.fromAsset` or
/// `WhatsappStickerImage.fromFile` does not exist — for an asset, check that it
/// is declared in the `flutter:` section of your `pubspec.yaml`.
class WhatsappStickersFileNotFoundException extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'FILE_NOT_FOUND';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersFileNotFoundException(super.cause);

  @override
  String toString() => 'File not found';
}

/// Thrown when the pack does not hold between 3 and 30 stickers, inclusive.
///
/// WhatsApp rejects packs outside that range, so add at least three stickers
/// with `WhatsappStickers.addSticker` before calling
/// `WhatsappStickers.sendToWhatsApp`.
class WhatsappStickersNumOutsideAllowableRangeException
    extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'OUTSIDE_ALLOWABLE_RANGE';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersNumOutsideAllowableRangeException(super.cause);

  @override
  String toString() => 'Outside allowable range';
}

/// Thrown when an image could not be decoded as a usable sticker.
///
/// Stickers must be WebP; the tray image must be PNG.
class WhatsappStickersUnsupportedImageFormatException
    extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'UNSUPPORTED_IMAGE_FORMAT';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersUnsupportedImageFormatException(super.cause);

  @override
  String toString() => 'Unsupported image format';
}

/// Thrown when a sticker file exceeds the size WhatsApp accepts.
///
/// The budget is per file, so shrink the offending sticker rather than the pack.
class WhatsappStickersImageTooBigException extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'IMAGE_TOO_BIG';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersImageTooBigException(super.cause);

  @override
  String toString() => 'Image too big';
}

/// Thrown when an image's pixel dimensions are not what WhatsApp expects.
///
/// Stickers are 512x512. The accepted tray image size differs by platform, so
/// check the message in [cause] for what the native side actually rejected.
class WhatsappStickersIncorrectImageSizeException
    extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'INCORRECT_IMAGE_SIZE';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersIncorrectImageSizeException(super.cause);

  @override
  String toString() => 'Incorrect image size';
}

/// Thrown when a sticker is an animated image and the platform requires a
/// static one.
class WhatsappStickersAnimatedImagesNotSupportedException
    extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'ANIMATED_IMAGES_NOT_SUPPORTED';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersAnimatedImagesNotSupportedException(super.cause);

  @override
  String toString() => 'Animated images not supported';
}

/// Thrown when a sticker is not associated with 1 to 3 emoji.
///
/// Despite the name, Android also raises this when a sticker has *no* emoji at
/// all, so treat it as "wrong number of emoji" rather than strictly "too many".
class WhatsappStickersTooManyEmojisException extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'TOO_MANY_EMOJIS';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersTooManyEmojisException(super.cause);

  @override
  String toString() => 'Too many emojis';
}

/// Thrown when a required field was left empty.
///
/// `WhatsappStickers.identifier`, `WhatsappStickers.name` and
/// `WhatsappStickers.publisher` must all be non-empty, as must each sticker's
/// file path.
class WhatsappStickersEmptyStringException extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'EMPTY_STRING';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersEmptyStringException(super.cause);

  @override
  String toString() => 'Contain empty string';
}

/// Thrown when `WhatsappStickers.identifier`, `WhatsappStickers.name` or
/// `WhatsappStickers.publisher` is longer than 128 characters.
class WhatsappStickersStringTooLongException extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'STRING_TOO_LONG';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersStringTooLongException(super.cause);

  @override
  String toString() => 'String too long';
}

/// Thrown when WhatsApp already has a pack installed with this
/// `WhatsappStickers.identifier`.
///
/// This is a normal outcome rather than a failure of your code: the pack is
/// present and there is nothing to add. Catch it separately if you want to say
/// so instead of reporting an error.
class WhatsappStickersAlreadyAddedException extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'ALREADY_ADDED';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersAlreadyAddedException(super.cause);

  @override
  String toString() => 'Stickers already added';
}

/// Thrown when the user dismissed WhatsApp's "add sticker pack" prompt.
///
/// Nothing went wrong — the user simply declined — so this is usually worth
/// catching separately and handling silently.
class WhatsappStickersCancelledException extends WhatsappStickersException {
  /// The platform error code that maps to this exception.
  static const String code = 'CANCELLED';

  /// Creates an exception carrying the platform's error message.
  WhatsappStickersCancelledException(super.cause);

  @override
  String toString() => 'Cancelled';
}
