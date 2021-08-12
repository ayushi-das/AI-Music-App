import 'dart:core';
import 'package:AI_music/models/radio.dart';
import 'package:AI_music/utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:AI_music/models/radio.dart';
import 'package:alan_voice/alan_voice.dart';

List<MyRadio> radio;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //List<MyRadio> radio;
  MyRadio selectedRadio;
  Color selectedColor;
  bool isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
    fetchRadios();
    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == AudioPlayerState.PLAYING) {
        isPlaying = true;
      } else {
        isPlaying = false;
      }
      setState(() {});
    });
  }

  setupAlan() {
    AlanVoice.addButton(
        "218ad5e2037e28b5da8153584503063c2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => handleCommand(command.data));
  }

  handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        _playmusic(selectedRadio.url);
        break;
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = selectedRadio.id;
        MyRadio newRadio;
        if (index + 1 > radio.length) {
          newRadio = radio.firstWhere((element) => element.id == 1);
          radio.remove(newRadio);
          radio.insert(0, newRadio);
        } else {
          newRadio = radio.firstWhere((element) => element.id == index + 1);
          radio.remove(newRadio);
          radio.insert(0, newRadio);
        }
        _playmusic(newRadio.url);
        break;

      case "prev":
        final index = selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio = radio.firstWhere((element) => element.id == 1);
          radio.remove(newRadio);
          radio.insert(0, newRadio);
        } else {
          newRadio = radio.firstWhere((element) => element.id == index - 1);
          radio.remove(newRadio);
          radio.insert(0, newRadio);
        }
        _playmusic(newRadio.url);
        break;
      default:
        print("hi");
        break;
    }
  }

  fetchRadios() async {
    final radiojson = await rootBundle.loadString("assets/AI.json");
    radio = MyRadioList.fromJson(radiojson).radios;
    selectedRadio = radio[0];
    selectedColor = Color(int.tryParse(selectedRadio.color));
    print(radio);
    setState(() {});
  }

  _playmusic(String url) {
    _audioPlayer.play(url);
    selectedRadio = radio.firstWhere((element) => element.url == url);
    print(selectedRadio.name);
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: selectedColor ?? AIcolors.primaryColor2,
          child: radio != null
              ? [
                  100.heightBox,
                  "All Channels".text.xl.white.semiBold.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: radio
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: "${e.name} FM".text.white.make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  ).expand()
                ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIcolors.primaryColor2,
                    selectedColor ?? AIcolors.primaryColor1,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          AppBar(
            title: "Radio"
                .text
                .xl4
                .make()
                .shimmer(
                    primaryColor: Vx.purple300, secondaryColor: Colors.white30)
                .h(50.0)
                .p16(),
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
          ),
          radio != null
              ? VxSwiper.builder(
                  itemCount: radio.length,
                  aspectRatio: 1.0,
                  onPageChanged: (index) {
                    final colorhex = radio[index].color;
                    selectedColor = Color(int.tryParse(colorhex));
                    selectedRadio = radio[index];
                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final rad = radio[index];
                    return VxBox(
                            child: ZStack([
                      Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: VxBox(
                                  child: rad.category.text.white.uppercase
                                      .make()
                                      .p12())
                              .alignTopRight
                              .black
                              .height(40)
                              .px16
                              .withRounded(value: 10)
                              .make()),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: VStack([
                          rad.name.text.xl3.white.bold.make(),
                          HeightBox(2),
                          rad.tagline.text.sm.white.semiBold.make()
                        ]),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: VStack([
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                          ),
                          HeightBox(10),
                          "PLAY".text.sm.bold.white.make()
                        ]),
                      )
                    ]))
                        .clip(Clip.antiAlias)
                        .bgImage(DecorationImage(
                            image: NetworkImage(rad.image), fit: BoxFit.cover))
                        .withRounded(value: 50)
                        .border(color: Colors.black)
                        .make()
                        .onInkDoubleTap(() {
                      _playmusic(rad.url);
                    }).p16();
                  }).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                ),
          Align(
              alignment: Alignment.bottomCenter,
              child: [
                if (isPlaying)
                  "Playing Now - ${selectedRadio.name}"
                      .text
                      .white
                      .makeCentered(),
                Icon(
                  isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline,
                  color: Colors.white,
                ).onInkTap(() {
                  if (isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    _playmusic(selectedRadio.url);
                  }
                })
              ].vStack().pOnly(bottom: context.percentHeight * 12))
        ],
        fit: StackFit.expand,
      ),
    );
  }
}
