import 'package:flutter/material.dart';
import 'sql_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All tasks
  List<Map<String, dynamic>> _tasks = [];

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshTasks() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _tasks = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshTasks(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingTask =
      _tasks.firstWhere((element) => element['id'] == id);
      _titleController.text = existingTask['title'];
      _descriptionController.text = existingTask['description'];
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                          labelText: 'Title', border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }else if(value.length < 3 ){
                          return "Min character required is 3";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      maxLength: 150,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Description is required';
                        }else if(value.length < 3 ){
                          return "Min character required is 3";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 7,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            // validate();
                            if (_formKey.currentState!.validate()) {
                              if (id == null) {
                                await _addItem();
                              }

                              if (id != null) {
                                await _updateItem(id);
                              }

                              // Clear the text fields
                              _titleController.text = '';
                              _descriptionController.text = '';

                              // Close the bottom sheet
                              Navigator.of(context).pop();
                            } else {
                              print('not ok');
                            }
                          },
                          child: Text(id == null ? 'Create New' : 'Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

    // confirmation delete dialog box
  _deletetaskshow(BuildContext context,index){
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text("Are you sure you want to delete this"),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              _deleteItem(_tasks[index]['id']);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }



// Insert a new task to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshTasks();
  }

  // Update an existing task
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshTasks();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a task!'),
    ));
    _refreshTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todo List'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) => Card(
          color: Colors.lime[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
              title: Text(_tasks[index]['title']),
              subtitle: Text(_tasks[index]['description']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(_tasks[index]['id']),
                    ),
                    IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _deletetaskshow(context, index)
                    ),
                  ],
                ),
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}