
import 'chapters.dart';

class Comic {
  String category, name, image;
  List<Chapters> chapters;

  Comic(
      { this.category,  this.chapters,  this.image,  this.name});

  Comic.fromJson(Map<String, dynamic> json)
  {
    category = json['Category'];
    if (json['Chapters'] != null) {
      chapters = <Chapters>[];

      json['Chapters'].forEach((v) {
        chapters.add(Chapters.fromJson(v));
      });
    }

    image = json['Image'];
    name = json['Name'];
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['Category'] = category;
    if(chapters!=null){
      data['Chapters'] = chapters.map((v) => v.toJson()).toList();
    }
    data['Image'] = image;
    data['Name'] = name;
    return data;
  }

}