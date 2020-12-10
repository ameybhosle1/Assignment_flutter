import 'dart:async';
import 'dart:convert';
import 'dart:io';
// import 'dart:js';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(new MaterialApp(
      home: new HomePage(),
    ));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _connectionStatus = 'Unknown';
  Connectivity connectivity;
  StreamSubscription<ConnectivityResult> subscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result.toString();
      print(_connectionStatus);
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        // getData();
        setState(() {});
      }
    });
  }

  Future getData() async {
    http.Response response = await http.get(
        "https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7");
    if (response.statusCode == 200) {
      var result = jsonDecode(response.body)['message']['body']['track_list'];
      print(result);
      // setState(() {});
      return result;
    }
  }

  // Future getsonglyrics(String val) async {}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("Connectivy")),
      body: new FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var mydata = snapshot.data;
            return new ListView.builder(
              itemBuilder: (context, i) => new ListTile(
                title: Text(mydata[i]['track']['track_name']),
                onTap: () async {
                  String url =
                      'https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=${mydata[i]['track']['track_id']}&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7';
                  http.Response response = await http.get(url);
                  if (response.statusCode == 200) {
                    var result = jsonDecode(response.body)['message']['body']
                        ['lyrics']['lyrics_body'];
                    print(result);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Second(
                          text: mydata[i]['track']['track_id'],
                        ),
                      ),
                    );
                  }
                },
              ),
              itemCount: mydata.length,
            );
          } else {
            return Center(
              child: Text("Not Connected"),
            );
          }
        },
      ),
    );
  }
}

// ignore: must_be_immutable
class Second extends StatelessWidget {
  final String text;
  var name, album, lyrics, artist;
  var rating;
  Second({Key key, @required this.text}) : super(key: key);

  // ignore: non_constant_identifier_names
  void get_name_artist() async {
    String url =
        // ignore: unnecessary_brace_in_string_interps
        'https:api.musixmatch.com/ws/1.1/track.get?track_id=${text}&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7';
    String url2 =
        'https:api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=$text&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7';
    http.Response response = await http.get(url);
    http.Response response2 = await http.get(url2);
    if (response.statusCode == 200 && response2.statusCode == 200) {
      rating =
          jsonDecode(response.body)['message']['body']['track']['track_rating'];
      name =
          jsonDecode(response.body)['message']['body']['track']['track_name'];
      artist =
          jsonDecode(response.body)['message']['body']['track']['artist_name'];
      album =
          jsonDecode(response.body)['message']['body']['track']['album_name'];
      lyrics = jsonDecode(response2.body)['message']['body']['lyrics']
          ['lyrics_body'];
    }
  }

  @override
  Widget build(BuildContext context) {
    get_name_artist();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('ssdds'),
        ),
        body: Column(
          children: [
            Text('Name'),
            Text('$name'),
            SizedBox(
              height: 20.0,
            ),
            Text('Rating'),
            Text('$rating'),
            SizedBox(
              height: 20.0,
            ),
            Text('$artist'),
            SizedBox(
              height: 20.0,
            ),
            Text('$lyrics'),
          ],
        ),
      ),
    );
  }
}
