import 'package:hive/hive.dart';

part 'document_model.g.dart';

@HiveType(typeId: 0)
class Document {
  @HiveField(0)
  String name;

  @HiveField(1)
  String filePath;

  Document({required this.name, required this.filePath});
}
