import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final url =
      'https://scontent-sof1-1.cdninstagram.com/v/t51.82787-19/640810978_17951403000094411_781324874961463526_n.jpg?stp=cp0_dst-jpg_s110x80_tt6&_nc_cat=106&ccb=7-5&_nc_sid=bf7eb4&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLnd3dy4xMDgwLkMzIn0%3D&_nc_ohc=8vHOzH-OPZkQ7kNvwECNIPG&_nc_oc=AdmnWqJjbWLiRokK5RVy7-JtiqAhVzltQNYGAa21LZVSYVfLf228bT_usXvM6YifGFw&_nc_zt=24&_nc_ht=scontent-sof1-1.cdninstagram.com&_nc_gid=35UqWE-KXm-JkxWU_z4F5Q&_nc_ss=8&oh=00_AfssCPa2C2walJGk5-iwLjM5zuBRt579PIlNBAfGuJgyCg&oe=69A88E3A';

  Widget _buildItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      ),
    );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(centerTitle: true, title: const Text('Profil Sayfası')),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(url),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Oray Yılmaz',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Full-Stack Developer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          _buildItem('47', 'Takipçi'),
                          _buildItem('84', 'Takip'),
                          _buildItem('0', 'Gönderi'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hakkımda',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Merhaba, ben Oray Yılmaz. Full-Stack Developer\'ım. Flutter ve Node.js ile uygulamalar geliştiriyorum.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
