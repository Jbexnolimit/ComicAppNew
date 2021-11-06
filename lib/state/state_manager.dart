

import 'package:comic_app/model/chapters.dart';
import 'package:comic_app/model/comic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final comicSelected = StateProvider((ref) => Comic());
final chapterSelected = StateProvider((ref) => Chapters());
final isSearch = StateProvider((ref) => false);