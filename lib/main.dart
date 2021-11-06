// ignore_for_file: use_key_in_widget_constructors

import 'dart:convert';
import 'dart:io';


import 'package:carousel_slider/carousel_slider.dart';
import 'package:comic_app/screens/chapter_screen.dart';
import 'package:comic_app/screens/read_screen.dart';
import 'package:comic_app/state/state_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';


import 'model/comic.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await Firebase.initializeApp(
      name: 'ComicReaderApp',
      options: Platform.isMacOS || Platform.isIOS ?
      const FirebaseOptions(
          appId: 'IOS KEY',
          apiKey: 'AIzaSyDgA2LNMwUkdOO-vKSGtEnk9PnXt0mcZ7g',
          projectId: 'comicreaderapp-5dcda',
          messagingSenderId: '153291530719',
          databaseURL: 'https://comicreaderapp-5dcda-default-rtdb.firebaseio.com/'
      )
          :

      const FirebaseOptions(
          appId: '1:153291530719:android:38ae70af20cf304954646a',
          apiKey: 'AIzaSyDgA2LNMwUkdOO-vKSGtEnk9PnXt0mcZ7g',
          projectId: 'comicreaderapp-5dcda',
          messagingSenderId: '153291530719',
          databaseURL: 'https://comicreaderapp-5dcda-default-rtdb.firebaseio.com/'
      )

  );

  bool kisweb;
  try{
    if(Platform.isAndroid||Platform.isIOS) {
      kisweb=false;
    } else {
      kisweb=true;
    }
  } catch(e){
    kisweb=true;
  }

  runApp(ProviderScope(child: MyApp(app : app)));
}

class MyApp extends StatelessWidget {
    FirebaseApp app;
     MyApp({this.app});

  // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Flutter Demo',
        routes: {
          '/chapters' : (context) => ChapterScreen(),
          '/read' : (context) => ReadScreen()
        },
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Comic Reader',app: app),
      );
    }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key,  this.title, this.app}) : super(key: key);

  final FirebaseApp app;
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DatabaseReference _bannerRef,_comicRef;
  List<Comic> listComicFromFirebase = <Comic>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase _database = FirebaseDatabase(app:widget.app);
    _bannerRef = _database.reference().child('Banners');
    _comicRef = _database.reference().child('Comic');

  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context,watch,_){
      var searchEnable = watch(isSearch).state;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF02727B),
          title: searchEnable ?
          TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: const InputDecoration(hintText:  'Comic name or category',
                    hintStyle: TextStyle(color:Colors.white60)
                ),
                autofocus: false,
                style: DefaultTextStyle.of(context).style
                    .copyWith(fontStyle: FontStyle.italic,
                    fontSize: 18,
                    color: Colors.white),
              ),
              suggestionsCallback: (searchString) async{
                return await searchComic(searchString);
              },
              itemBuilder: (context,comic){
                return ListTile(leading: Image.network(comic.image),
                  title: Text('${comic.name}'),
                  subtitle: Text('${comic.category ?? ''}'),
                );
              },
              onSuggestionSelected: (comic){
                context.read(comicSelected).state = comic;
                Navigator.pushNamed(context, '/chapters');
              })
              : Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.search),
              onPressed: () =>
              context.read(isSearch).state = !context.read(isSearch).state,
            )
          ],
        ),
        body: FutureBuilder<List<String>>(
          future: getBanners(_bannerRef),
          builder: (context, snapshot){
            if(snapshot.hasData){
              return Column(mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CarouselSlider(
                      items: snapshot.data.map((e) =>
                      Builder(builder: (context){
                        return Image.network(e, fit: BoxFit.cover);
                      },
                      ))?.toList(),
                      options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          initialPage: 0,
                          height: MediaQuery.of(context).size.height/3
                      )),
                  Row(
                    children: [
                      Expanded(flex: 4,
                        child: Container(color: const Color(0xFF58B397),child:
                        const Padding(padding: EdgeInsets.all(8),
                          child: Text('NEW COMIC',style: TextStyle(color: Colors.white),),)),),
                      Expanded(flex: 1,
                        child: Container(color: Colors.black,child: const Padding(padding: EdgeInsets.all(8),
                          child: Text(''),),),)
                    ],
                  ),
                  FutureBuilder(
                    future: getComic(_comicRef),
                    builder: (context, snapshot){
                      if(snapshot.hasError) {
                        return Center(child: Text('${snapshot.error}'),);
                      }else if(snapshot.hasData)
                      {
                        listComicFromFirebase = <Comic>[];
                        snapshot.data.forEach((item){
                          var comic = Comic.fromJson(json.decode(json.encode(item)));
                          listComicFromFirebase.add(comic);
                        });

                        return Expanded(child: GridView.count(crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          padding: const EdgeInsets.all(4.0),
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0,
                          children: listComicFromFirebase.map((comic){
                            return GestureDetector(onTap: (){

                            context.read(comicSelected).state = comic;
                              Navigator.pushNamed(context, "/chapters");

                            },child:
                            Card(elevation: 12,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [Image.network(comic.image,fit:BoxFit.cover),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        color: const Color(0xAA434343),
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Expanded(child:
                                            Text(comic.name,
                                              style: const TextStyle(color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,)
                                              ,)
                                          ],
                                        ),

                                      )
                                    ],
                                  )
                                ],
                              ),),);
                          }).toList(),
                        ),);
                      }
                      return const Center(child: CircularProgressIndicator(),);
                    },),
                ],
              );
            }else if(snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'),);
            }
            return const Center(child: CircularProgressIndicator(),);
          },
        ),

      );
    });
  }

  Future<List<dynamic>>getComic(DatabaseReference comicRef) {
    return comicRef.once().then((snapshot) => snapshot.value);
  }

  Future<List<String>>getBanners(DatabaseReference bannerRef) {
    return bannerRef.once().then((snapshot) => snapshot.value.cast<String>().toList());

  }

  Future<List<Comic>> searchComic(String searchString) async{
    return listComicFromFirebase.where((comic) =>
    comic.name.toLowerCase().contains(searchString.toLowerCase())
        ||
        (comic.category != null && comic.category.toLowerCase().contains(searchString.toLowerCase()))

    ).toList();
  }
}
