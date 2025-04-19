import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'subject.g.dart';

@HiveType(typeId: 1)
class Subject {
  @HiveField(0) final String name;
  @HiveField(1) final int colorValue;

  Subject(this.name, this.colorValue);

  Color get color => Color(colorValue);
}