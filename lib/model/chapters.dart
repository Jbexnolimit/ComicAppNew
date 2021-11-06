

class Chapters{

  List<String> links;
  String name;

  Chapters({ this.links, this.name});

  Chapters.fromJson(Map<String,dynamic> json){
    if(json['Links'] != null) {
      links = json['Links'].cast<String>();
    }
    name = json['Name'];
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['Links'] = links;
    data['Name'] = name;
    return data;
  }
}