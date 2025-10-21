import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_stickers_injector/exceptions.dart';
import 'package:whatsapp_stickers_injector/whatsapp_stickers.dart';

void main() {
  runApp(AppRoot());
}

class AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('WhatsApp Stickers Flutter Demo'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: ElevatedButton(
                    child: Text('Install from assets'),
                    onPressed: installFromAssets,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    child: Text('Install from remote'),
                    onPressed: installFromRemote,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: ElevatedButton(
                    child: Text('Install Animated Stickers'),
                    onPressed: installAnimatedStickers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
          ),
        ),
      ),
    );
  }
}

const stickers = {
  '01_Cuppy_smile.webp': ['☕', '🙂'],
  '02_Cuppy_lol.webp': ['😄', '😀'],
  '03_Cuppy_rofl.webp': ['😆', '😂'],
  '04_Cuppy_sad.webp': ['😃', '😍'],
  '05_Cuppy_cry.webp': ['😭', '💧'],
  '06_Cuppy_love.webp': ['😍', '♥'],
  '07_Cuppy_hate.webp': ['💔', '👎'],
  '08_Cuppy_lovewithmug.webp': ['😍', '💑'],
  '09_Cuppy_lovewithcookie.webp': ['😘', '🍪'],
  '10_Cuppy_hmm.webp': ['🤔', '😐'],
  '11_Cuppy_upset.webp': ['😱', '😵'],
  '12_Cuppy_angry.webp': ['😡', '😠'],
  '13_Cuppy_curious.webp': ['❓', '🤔'],
  '14_Cuppy_weird.webp': ['🌈', '😜'],
  '15_Cuppy_bluescreen.webp': ['💻', '😩'],
  '16_Cuppy_angry.webp': ['😡', '😤'],
  '17_Cuppy_tired.webp': ['😩', '😨'],
  '18_Cuppy_workhard.webp': ['😔', '😨'],
  '19_Cuppy_shine.webp': ['🎉', '✨'],
  '20_Cuppy_disgusting.webp': ['🤮', '👎'],
  '21_Cuppy_hi.webp': ['🖐', '🙋'],
  '22_Cuppy_bye.webp': ['🖐', '👋'],
};

// Stickers animados de exemplo (baseados no pacote "Together While Apart" do WhatsApp)
const animatedStickers = {
  '01_SendingLove.webp': ['💕', '😘', '❤️'],
  '02_WellDoThisTogether.webp': ['✊', '💪', '🙏'],
  '03_Heart.webp': ['❤️', '😘', '💕'],
  '04_AirHighFive.webp': ['🖐', '🙌', '✋'],
  '05_GroupVideoCalling.webp': ['📱', '👯', '👋'],
  '06_StayConnected.webp': ['📱', '🙋‍♀', '🙋‍♂'],
  '07_OK.webp': ['👍', '👌', '🙂'],
  '08_AreYouOK.webp': ['👋', '❓', '📱'],
  '09_StayingHomeMug.webp': ['☕', '🍵', '🏠'],
  '10_WorkingFromBed.webp': ['👩‍💻', '👨‍💻', '🛏'],
  '11_StayCalm.webp': ['☕', '🍵', '🤙'],
  '12_Gymnastics.webp': ['🤸', '🐩', '💪'],
  '13_DoubleChecking.webp': ['📰', '🔎', '🔍'],
  '14_CatOnTheLaptop.webp': ['🐈', '🐱', '💻'],
  '15_WorkingFromHomeF.webp': ['👩‍💻', '🏠', '💻'],
  '16_WorkingFromHomeM.webp': ['👨‍💻', '🏠', '💻'],
  '17_WashingHands.webp': ['✋', '💦', '🤧'],
  '18_DontTouchYourFace.webp': ['😷', '🤒', '🤧'],
  '19_SocialDistancing.webp': ['😷', '🤒', '🏠'],
  '20_SuperheroNurse.webp': ['👩‍⚕', '👨‍⚕️', '🤒'],
  '21_YouAreMyHero.webp': ['🙏', '🎉', '✨'],
};

Future installFromAssets() async {
  var stickerPack = WhatsappStickers(
    identifier: 'cuppyFlutterWhatsAppStickers',
    name: 'Cuppy Flutter WhatsApp Stickers',
    publisher: 'John Doe',
    trayImageFileName: WhatsappStickerImage.fromAsset('assets/tray_Cuppy.png'),
    publisherWebsite: '',
    privacyPolicyWebsite: '',
    licenseAgreementWebsite: '',
  );

  stickers.forEach((sticker, emojis) {
    stickerPack.addSticker(WhatsappStickerImage.fromAsset('assets/$sticker'), emojis);
  });

  try {
    await stickerPack.sendToWhatsApp();
  } on WhatsappStickersException catch (e) {
    print(e.cause);
  }
}

Future installFromRemote() async {
  var applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
  var stickersDirectory = Directory('${applicationDocumentsDirectory.path}/stickers');
  await stickersDirectory.create(recursive: true);

  final dio = Dio();
  final downloads = <Future>[];

  stickers.forEach((sticker, emojis) {
    downloads.add(
      dio.download(
        'https://github.com/applicazza/whatsapp_stickers_plus/raw/master/example/assets/$sticker',
        '${stickersDirectory.path}/$sticker',
      ),
    );
  });

  await Future.wait(downloads);

  var stickerPack = WhatsappStickers(
    identifier: 'cuppyFlutterWhatsAppStickers',
    name: 'Cuppy Flutter WhatsApp Stickers',
    publisher: 'John Doe',
    trayImageFileName: WhatsappStickerImage.fromAsset('assets/tray_Cuppy.png'),
    publisherWebsite: '',
    privacyPolicyWebsite: '',
    licenseAgreementWebsite: '',
  );

  stickers.forEach((sticker, emojis) {
    stickerPack.addSticker(WhatsappStickerImage.fromFile('${stickersDirectory.path}/$sticker'), emojis);
  });

  try {
    await stickerPack.sendToWhatsApp();
  } on WhatsappStickersException catch (e) {
    print(e.cause);
  }
}

Future installAnimatedStickers() async {
  // Criar um pacote de stickers animados
  var animatedStickerPack = WhatsappStickers(
    identifier: 'animatedFlutterWhatsAppStickers',
    name: 'Animated Flutter WhatsApp Stickers',
    publisher: 'Flutter Developer',
    trayImageFileName: WhatsappStickerImage.fromAsset('assets/tray_Cuppy.png'), // Usando o mesmo tray icon
    publisherWebsite: 'https://flutter.dev',
    privacyPolicyWebsite: '',
    licenseAgreementWebsite: '',
    isAnimatedPack: true, // Flag importante para stickers animados
  );

  // Adicionar stickers animados (WebP animados)
  animatedStickers.forEach((sticker, emojis) {
    animatedStickerPack.addSticker(WhatsappStickerImage.fromAsset('assets/$sticker'), emojis);
  });

  try {
    await animatedStickerPack.sendToWhatsApp();
    print('Pacote de stickers animados enviado com sucesso!');
  } on WhatsappStickersException catch (e) {
    print('Erro ao enviar stickers animados: ${e.cause}');
  }
}
