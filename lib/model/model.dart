import '../db/db.dart';
import './model_constant.dart';

class DbNote extends DbRecord {
  // final title = stringField(columnTitle);
  final content = stringField(columnContent);
  // final date = intField(columnUpdated);

  @override
  List<Field> get fields => [id,content];
}
