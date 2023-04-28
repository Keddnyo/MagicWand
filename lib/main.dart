import 'dart:convert';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:windows1251/windows1251.dart';

void main() {
  runApp(const MainApp());
}

class Constants {
  static String title = 'MagicWand';
  static String forumUrl = 'https://4pda.to/forum/index.php?showforum=';
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      home: MainContent(messengerKey: messengerKey),
      title: Constants.title,
      theme: FlexThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        darkIsTrueBlack: true,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
    );
  }
}

class MainContent extends StatefulWidget {
  const MainContent({super.key, required this.messengerKey});

  final GlobalKey<ScaffoldMessengerState> messengerKey;

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  var forumUrlController = TextEditingController();
  var textMatchController = TextEditingController();
  var pictureUrlController = TextEditingController();
  var outputTextController = TextEditingController();
  var outputPictureTextController = TextEditingController();

  var allowChangePicUrlRecursively = true;
  setAccess(bool condition) {
    setState(() {
      allowChangePicUrlRecursively = condition;
    });
  }

  setPictureUrl() {
    var text = textMatchController.text;
    if (allowChangePicUrlRecursively) {
      if (text.contains(' [')) {
        pictureUrlController.text = text.isEmpty
            ? ''
            : 'https://4pda.to/static/forum/style_images/f/3-${text.replaceAll(' ', '_').substring(0, text.indexOf(' ['))}.png';
      } else {
        pictureUrlController.text = text.isEmpty
            ? ''
            : 'https://4pda.to/static/forum/style_images/f/3-${text.replaceAll(' ', '_')}.png';
      }
    }
  }

  getFormattedOutput({bool usePicture = false}) {
    if (forumUrlController.text.isEmpty) return '';
    if (textMatchController.text.isEmpty) return '';
    if (usePicture && pictureUrlController.text.isEmpty) return '';

    var buffer = StringBuffer();
    buffer.write('[url="https://4pda.to/forum/index.php?act=search&query=');
    buffer.write(Uri.encodeQueryComponent(textMatchController.text,
        encoding: windows1251));
    buffer.write('&forums%5B%5D=');
    buffer.write(forumUrlController.text.substring(
        forumUrlController.text.indexOf('showforum=') + 10,
        forumUrlController.text.length));
    buffer.write(
        '&exclude_trash=1&nohl=1&source=top&sort=dd&result=topics&noform=1"]');
    if (usePicture) {
      buffer.write('[img]');
      buffer.write(pictureUrlController.text);
      buffer.write('[/img]');
    } else {
      buffer.write(textMatchController.text);
    }
    buffer.write('[/url]');
    return buffer.toString();
  }

  // getPictureOutput() {
  //   if (forumUrlController.text.isEmpty) return '';
  //   if (textMatchController.text.isEmpty) return '';
  //   if (pictureUrlController.text.isEmpty) return '';

  //   var buffer = StringBuffer();
  //   buffer.write('[url="https://4pda.to/forum/index.php?act=search&query=');
  //   buffer.write(Uri.encodeQueryComponent(textMatchController.text,
  //       encoding: windows1251));
  //   buffer.write('&forums%5B%5D=');
  //   buffer.write(forumUrlController.text.substring(
  //       forumUrlController.text.indexOf('showforum=') + 10,
  //       forumUrlController.text.length));
  //   buffer.write(
  //       '&exclude_trash=1&nohl=1&source=top&sort=dd&result=topics&noform=1');
  //   buffer.write('"][img]');
  //   buffer.write(pictureUrlController.text);
  //   buffer.write('[/img][/url]');
  //   return buffer.toString();
  // }

  snackbar(String message, {SnackBarAction? action}) =>
      SnackBar(content: Text(message), action: action);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    bool isScreenLarge() {
      return screenWidth > 1000.0;
    }

    var outputs = Column(
      children: [
        OutlineTextField(
          forumUrlController: outputTextController,
          readOnly: true,
          maxLines: null,
          labelText: 'Код текстом',
          hintText: 'Здесь будет результат',
        ),
        ElevatedFilledButton(
          onPressed: () async {
            if (outputTextController.text.isNotEmpty) {
              await Clipboard.setData(
                ClipboardData(text: outputTextController.text),
              );
              widget.messengerKey.currentState?.showSnackBar(
                snackbar(
                  'Скопировано',
                  action: SnackBarAction(
                    label: 'Открыть раздел',
                    onPressed: () {
                      launchUrl(Uri.parse(forumUrlController.text),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              );
            } else {
              widget.messengerKey.currentState?.showSnackBar(
                snackbar('Результат пуст'),
              );
            }
          },
          title: 'Скопировать',
        ),
        OutlineTextField(
          forumUrlController: outputPictureTextController,
          readOnly: true,
          maxLines: null,
          labelText: 'Код картинкой',
          hintText: 'Здесь будет результат',
        ),
        ElevatedFilledButton(
          onPressed: () async {
            if (outputPictureTextController.text.isNotEmpty) {
              await Clipboard.setData(
                ClipboardData(text: outputPictureTextController.text),
              );
              widget.messengerKey.currentState?.showSnackBar(
                snackbar(
                  'Скопировано',
                  action: SnackBarAction(
                    label: 'Открыть раздел',
                    onPressed: () {
                      launchUrl(Uri.parse(forumUrlController.text),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              );
            } else {
              widget.messengerKey.currentState?.showSnackBar(
                snackbar('Результат пуст'),
              );
            }
          },
          title: 'Скопировать',
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(Constants.title),
        actions: [
          IconButton(
            onPressed: () {
              launchUrl(
                Uri.parse('https://4pda.to/forum/index.php?autocom=fimg&f=3'),
                mode: LaunchMode.externalApplication,
              );
            },
            icon: const Icon(Icons.wallpaper),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    OutlineTextField(
                      forumUrlController: forumUrlController,
                      keyboardType: TextInputType.url,
                      onChanged: (text) {
                        if (int.tryParse(text) != null) {
                          forumUrlController.text =
                              '${Constants.forumUrl}$text';
                          forumUrlController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                                offset: forumUrlController.text.length),
                          );
                        }
                      },
                      labelText: 'URL раздела',
                      hintText: '${Constants.forumUrl}[id]',
                    ),
                    OutlineTextField(
                      forumUrlController: textMatchController,
                      onChanged: (text) {
                        setPictureUrl();
                      },
                      labelText: 'Ключевое слово',
                      hintText: 'Samsung [Умные часы]',
                    ),
                    OutlineTextField(
                      forumUrlController: pictureUrlController,
                      onChanged: (text) {
                        setAccess(text.isEmpty);
                        setPictureUrl();
                      },
                      labelText: 'URL картинки',
                      hintText:
                          'https://4pda.to/static/forum/style_images/f/3-Samsung.png',
                    ),
                    ElevatedFilledButton(
                      onPressed: () {
                        outputTextController.text = getFormattedOutput();
                        outputPictureTextController.text =
                            getFormattedOutput(usePicture: true);
                      },
                      title: 'Создать',
                    ),
                    if (!isScreenLarge()) outputs
                  ],
                ),
              ),
            ),
            if (isScreenLarge())
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: outputs,
                ),
              ),
          ],
        ),
      ),
      drawer: const Drawer(),
    );
  }
}

class Drawer extends StatelessWidget {
  const Drawer({
    super.key,
  });

  openForumUrl(int id) {
    launchUrl(
      Uri.parse('${Constants.forumUrl}$id'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      selectedIndex: null,
      onDestinationSelected: (value) {
        switch (value) {
          case 0:
            openForumUrl(659);
            break;
          case 1:
            openForumUrl(1119);
            break;
          case 2:
            openForumUrl(862);
            break;
          case 3:
            openForumUrl(1120);
            break;
          case 4:
            openForumUrl(1107);
            break;
          case 5:
            openForumUrl(1108);
            break;
          case 6:
            openForumUrl(810);
            break;
          case 7:
            openForumUrl(1123);
            break;
          case 8:
            openForumUrl(1121);
            break;
          case 9:
            openForumUrl(1122);
            break;
          case 10:
            openForumUrl(1124);
            break;
          case 11:
            launchUrl(
              Uri.parse('https://4pda.to/forum/index.php?showuser=8096247'),
              mode: LaunchMode.externalApplication,
            );
            break;
          default:
        }
      },
      children: [
        DrawerHeader(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Constants.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
                const Text(
                  'Created by Keddnyo',
                  style: TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),
        ),
        const NavigationDrawerDestination(
            icon: Icon(Icons.watch), label: Text('Умные часы')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.child_care), label: Text('Детские умные часы')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.watch), label: Text('Фитнес-браслеты')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.headset), label: Text('Наушники и гарнитуры')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.speaker), label: Text('Портативные колонки')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.cell_tower), label: Text('Другие устройства')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.apps), label: Text('Программы')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.brush), label: Text('Очумелые ручки')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.shopping_cart), label: Text('Покупка')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.extension), label: Text('Аксессуары')),
        const NavigationDrawerDestination(
            icon: Icon(Icons.archive), label: Text('Архив')),
        const Divider(),
        const NavigationDrawerDestination(
            icon: Icon(Icons.account_circle_rounded), label: Text('Keddnyo')),
      ],
    );
  }
}

class ElevatedFilledButton extends StatelessWidget {
  const ElevatedFilledButton({
    super.key,
    required this.onPressed,
    required this.title,
  });

  final Function()? onPressed;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FilledButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}

class OutlineTextField extends StatelessWidget {
  const OutlineTextField({
    super.key,
    required this.forumUrlController,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
    this.readOnly = false,
    required this.labelText,
    required this.hintText,
  });

  final TextEditingController forumUrlController;
  final TextInputType keyboardType;
  final int? maxLines;
  final Function(String)? onChanged;
  final bool readOnly;
  final String? labelText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: forumUrlController,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          hintText: hintText,
        ),
      ),
    );
  }
}
