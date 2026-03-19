import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ColorPickerPage extends StatefulWidget {
  const ColorPickerPage({super.key});

  @override
  State<ColorPickerPage> createState() => _ColorPickerPageState();
}

class _ColorPickerPageState extends State<ColorPickerPage> {
  final Map<Color, String> renkler = {
    Colors.red: "Kırmızı",
    Colors.blue: "Mavi",
    Colors.green: "Yeşil",
    Colors.yellow: "Sarı",
    Colors.orange: "Turuncu",
  };

  Color? secilenRenk;
  bool isCircular = false;
  bool isShowColorName = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Color Picker",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        backgroundColor: Colors.grey.shade200,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "a") {
                setState(() {
                  isShowColorName = !isShowColorName;
                });
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: "a",
                  child: Row(
                    children: [
                      Icon(
                        isShowColorName
                            ? Icons.visibility_off
                            : Icons.visibility_off,
                      ),
                      SizedBox(width: 10),
                      Text(
                        isShowColorName
                            ? "Renk Adını Gizle"
                            : "Renk Adını Göster",
                      ),
                    ],
                  ),
                ),
              ];
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: secilenRenk ?? Colors.red,
                borderRadius: BorderRadius.circular(isCircular ? 100 : 10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            if (isShowColorName && secilenRenk != null)
              Text(
                renkler[secilenRenk] ?? "Bilinmeyen Renk",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DropdownButton<Color>(
                    hint: Text("Renk seç"),
                    value: secilenRenk,
                    items: renkler.entries.map((entry) {
                      return DropdownMenuItem<Color>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Container(width: 20, height: 20, color: entry.key),
                            SizedBox(width: 10),
                            Text(entry.value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        secilenRenk = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: _rastgeleRenkSec,
                    child: Text('Rastgele'),
                  ),
                  IconButton(onPressed: _rgbKoduGoster, icon: Icon(Icons.info)),
                  IconButton(
                    onPressed: _containerSekliniDegistir,
                    icon: Icon(
                      isCircular
                          ? Icons.square_outlined
                          : Icons.circle_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _rastgeleRenkSec() {
    final rastgeleRenk = renkler.keys
        .toList()[DateTime.now().millisecondsSinceEpoch % renkler.length];
    setState(() {
      secilenRenk = rastgeleRenk;
    });
  }

  void _rgbKoduGoster() {
    Fluttertoast.showToast(
      msg:
          'RGB Karşılıkları: (${secilenRenk?.red}, ${secilenRenk?.green}, ${secilenRenk?.blue})',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,

      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _containerSekliniDegistir() {
    setState(() {
      isCircular = !isCircular;
    });
  }
}
