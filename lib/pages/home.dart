import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:myapp/components/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart';
import '';

var box;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List docList = box.get('documents') ?? [];

  // int _docCounter = 1;
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    _requestPermissions();
    log(docList.toString());
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
      String fileName = result.files.single.name;

      // Copy the file to the app's storage directory
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      File originalFile = File(filePath);
      File copiedFile = await originalFile.copy('$appDocPath/$fileName');

      docList.add(
          {'fileName': fileName, 'filePath': copiedFile.path, 'appPath': '/'});
      box.put('documents', docList);
      setState(() {});
    }
  }

  void _viewFile(String filePath) {
    log('Hello from _viewfile');
    OpenFile.open(filePath);
  }

  bool checkForDuplicate(String fileName) {
    for (var doc in docList) {
      if (doc['fileName'] == fileName) {
        return true;
      }
    }
    return false;
  }

  //
  void _editFile(String fileName) {
    TextEditingController _editController =
        TextEditingController(text: fileName);
    String originalName = fileName;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit File Name'),
          content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
              hintText: 'Enter new file name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                fileName = _editController.text;
                late String _filePath;
                late String _appPath;
                if (fileName == originalName) {
                  Navigator.of(context).pop();
                  return;
                }
                if (checkForDuplicate(fileName) && fileName != originalName) {
                  showSnackBar(context, 'File name already exists');
                  return;
                }
                if (fileName.isEmpty) {
                  showSnackBar(context, 'File name cannot be empty');
                  return;
                }
                for (var doc in docList) {
                  if (doc['fileName'] == originalName) {
                    _filePath = doc['filePath'];
                    _appPath = doc['appPath'] ?? '/';
                    break;
                  }
                }
                docList.removeWhere((doc) => doc['fileName'] == originalName);
                docList.add({
                  'fileName': fileName,
                  'filePath': _filePath,
                  'appPath': _appPath
                });
                setState(() {});
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteFile(String fileName) {
    docList.removeWhere((doc) => doc['fileName'] == fileName);
    box.put('documents', docList);
    setState(() {});
  }

  Icon _getFileIcon(String filePath) {
    log('filepath from getFileIcon: $filePath');
    if (filePath.endsWith('.pdf')) {
      return const Icon(Icons.picture_as_pdf, size: 100);
    } else if (filePath.endsWith('.jpg') ||
        filePath.endsWith('.png') ||
        filePath.endsWith('.jpeg')) {
      return const Icon(Icons.image, size: 100);
    } else {
      return const Icon(Icons.insert_drive_file, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    var docsAfterFilter = docList.where((entry) => entry['fileName']!
        .toLowerCase()
        .contains(_searchController.text.toLowerCase()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Manager'),
      ),
      body: Stack(
        children: [
          Column(
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
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: docsAfterFilter.length,
                  itemBuilder: (context, index) {
                    var doc = docsAfterFilter.elementAt(index);

                    return GestureDetector(
                      onTap: () => _viewFile(doc['filePath']!),
                      onLongPress: () =>
                          _showOptions(context, doc['fileName']!),
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _getFileIcon(doc['filePath']!),
                            const SizedBox(height: 8.0),
                            Text(doc['fileName']!, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // if (_isLoading)
          //   const Center(
          //     child: CircularProgressIndicator(),
          //   ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickFile,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showOptions(BuildContext context, String fileName) {
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
                _editFile(fileName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(fileName);
              },
            ),
          ],
        );
      },
    );
  }
}
