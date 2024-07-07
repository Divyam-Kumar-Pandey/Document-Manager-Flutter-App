import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'document_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DocumentAdapter());
  await Hive.openBox<Document>('documents');

  runApp(const MaterialApp(
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final Box<Document> _documentBox = Hive.box<Document>('documents');
  int _docCounter = 1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {});
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      String filePath = result.files.single.path!;
      String fileName = 'doc$_docCounter';
      _docCounter++;

      Document document = Document(name: fileName, filePath: filePath);
      _documentBox.add(document);

      setState(() {});
    }
  }

  void _viewFile(String path) {
    OpenFile.open(path);
  }

  void _editFile(int key, Document document) {
    TextEditingController _editController = TextEditingController(text: document.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit File Name'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(
              hintText: 'Enter new file name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                document.name = _editController.text;
                _documentBox.put(key, document);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(int key) {
    _documentBox.delete(key);
    setState(() {});
  }

  Icon _getFileIcon(String filePath) {
    if (filePath.endsWith('.pdf')) {
      return Icon(Icons.picture_as_pdf);
    } else if (filePath.endsWith('.jpg') || filePath.endsWith('.png')) {
      return Icon(Icons.image);
    } else {
      return Icon(Icons.insert_drive_file);
    }
  }

  @override
  Widget build(BuildContext context) {
    var documents = _documentBox.keys.map((key) {
      var doc = _documentBox.get(key);
      return MapEntry(key, doc);
    }).where((entry) => entry.value!.name.toLowerCase().contains(_searchController.text.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Manager'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                var entry = documents.elementAt(index);
                int key = entry.key;
                Document document = entry.value!;

                return GestureDetector(
                  onTap: () => _viewFile(document.filePath),
                  onLongPress: () => _showOptions(context, key, document),
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getFileIcon(document.filePath),
                        SizedBox(height: 8.0),
                        Text(document.name, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showOptions(BuildContext context, int key, Document document) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _editFile(key, document);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(key);
              },
            ),
          ],
        );
      },
    );
  }
}
