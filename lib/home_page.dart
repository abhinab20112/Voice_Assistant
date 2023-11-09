import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:voice_assistant/feature_box.dart';
import 'package:voice_assistant/openai_service.dart';
import 'package:voice_assistant/pallete.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageURL;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text("Aditi"),
        ),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(children: [
              ZoomIn(
                child: Stack(children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: AssetImage(
                                "assets/images/virtualAssistant.png"))),
                  )
                ]),
              ),
              FadeInRight(
                child: Visibility(
                  visible: generatedImageURL == null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 30).copyWith(
                      top: 24,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Pallete.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(20).copyWith(
                          topLeft: Radius.zero,
                        )),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        generatedContent ??
                            "Good Morning , what task can i do for you?",
                        style: TextStyle(
                          fontFamily: 'Cera Pro',
                          fontSize: generatedContent == null ? 25 : 18,
                          color: Pallete.mainFontColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (generatedImageURL != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageURL!),
                  ),
                ),
              SlideInLeft(
                child: Visibility(
                  visible:
                      generatedContent == null && generatedImageURL == null,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                    ),
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Here are a few features",
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: generatedContent == null && generatedImageURL == null,
                child: Column(
                  children: [
                    SlideInLeft(
                      delay: Duration(milliseconds: start),
                      child: const FunctionBox(
                        color: Pallete.firstSuggestionBoxColor,
                        headerText: 'ChatGPT',
                        descriptionText:
                            'A smarter way to stay organized and informed with ChatGPT',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + delay),
                      child: const FunctionBox(
                        color: Pallete.secondSuggestionBoxColor,
                        headerText: 'Dall-E',
                        descriptionText:
                            'Get inspired and stay creative with your personal assistant powered by Dall-E',
                      ),
                    ),
                    SlideInLeft(
                      delay: Duration(milliseconds: start + 2 * delay),
                      child: const FunctionBox(
                        color: Pallete.thirdSuggestionBoxColor,
                        headerText: 'Smart Voice Assistant',
                        descriptionText:
                            'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, bottom: 20),
            child: Align(
              alignment: Alignment.bottomRight,
              child: ZoomIn(
                delay: Duration(milliseconds: start + 3 * delay),
                child: FloatingActionButton(
                  backgroundColor: Pallete.firstSuggestionBoxColor,
                  onPressed: () async {
                    if (await speechToText.hasPermission &&
                        speechToText.isNotListening) {
                      await startListening();
                    } else if (speechToText.isListening) {
                      final speech =
                          await openAIService.isArtPromptAPI(lastWords);
                      if (speech.contains('https')) {
                        generatedImageURL = speech;
                        generatedContent = null;
                        setState(() {});
                      } else {
                        generatedImageURL = null;
                        generatedContent = speech;
                        await systemSpeak(speech);
                        setState(() {});
                      }

                      await stopListening();
                    } else {
                      initSpeechToText();
                    }
                  },
                  child:
                      Icon(speechToText.isListening ? Icons.stop : Icons.mic),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
