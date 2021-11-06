

import 'package:carousel_slider/carousel_slider.dart';
import 'package:comic_app/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    return Consumer(builder:(context,watch,_){
      var comic = watch(comicSelected).state;
      return Scaffold(
        appBar: AppBar(backgroundColor: const Color(0xFF04BA6B),
          title: Center(child: Text(comic.name.toUpperCase(),
            style: const TextStyle(color: Colors.white),),),),
        body: Center(
          child: (context.read(chapterSelected).state.links == null ||
              context.read(chapterSelected).state.links.isEmpty) ?
          const Text('This chapter is translating...') :
          CarouselSlider(items: context.read(chapterSelected).state.links
              .map((e) => Builder(
            builder: (context){
              return Image.network(e,fit: BoxFit.cover,);
            },
          )).toList(), options: CarouselOptions(
              autoPlay: false,
              height: MediaQuery.of(context).size.height,
              enlargeCenterPage: false,
              viewportFraction: 1,
              initialPage: 0
          ))
          ,
        ),
      );
    });

  }

}