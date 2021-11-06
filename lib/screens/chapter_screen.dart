

import 'package:comic_app/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ChapterScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return Consumer(builder:(context,watch,_){
      var comic = watch(comicSelected).state;
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFF04BA6B),
          title: Center(child: Text(comic.name.toUpperCase(),
            style: const TextStyle(color: Colors.white),),),),
        body: comic.chapters != null && comic.chapters.isNotEmpty ?
        Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
              itemCount: comic.chapters.length,
              itemBuilder: (context,index){
                return GestureDetector(onTap: (){

                  context.read(chapterSelected).state = comic.chapters[index];

                  Navigator.pushNamed(context, '/read');

                },
                  child: Column(children: [
                    ListTile(title: Text(comic.chapters[index].name),),
                    const Divider(thickness: 1,)
                  ],),);
              }),
        ) : const Center(child: Text('We are translating this comic'),),
      );
    });

  }

}