import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite CRUD',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Item> _items = [];

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  Future<void> _refreshItems() async {
    final data = await _dbHelper.queryAllItems();
    setState(() {
      _items = data.map((item) => Item.fromMap(item)).toList();
    });
  }

  Future<void> _addItem(String name, DateTime date, int value, bool isActive) async {
    await _dbHelper.insertItem({
      'name': name,
      'date': date.toIso8601String(),
      'value': value,
      'isActive': isActive ? 1 : 0,
    });
    _refreshItems();
  }

  Future<void> _updateItem(Item item) async {
    await _dbHelper.updateItem(item.toMap());
    _refreshItems();
  }

  Future<void> _deleteItem(int id) async {
    await _dbHelper.deleteItem(id);
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter SQLite CRUD'),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item.name),
            subtitle: Text(DateFormat('yyyy-MM-dd').format(item.date)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showItemDialog(item: item),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteItem(item.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showItemDialog(),
      ),
    );
  }

  void _showItemDialog({Item? item}) {
    final _nameController = TextEditingController(text: item?.name ?? '');
    final _dateController = TextEditingController(text: item != null ? DateFormat('yyyy-MM-dd').format(item.date) : '');
    final _valueController = TextEditingController(text: item?.value.toString() ?? '');
    bool _isActive = item?.isActive ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item == null ? 'Añadir Item' : 'Editar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Fecha (yyyy-MM-dd)'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: item?.date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                  }
                },
              ),
              TextField(
                controller: _valueController,
                decoration: InputDecoration(labelText: 'Valor'),
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Text('Activar'),
                  Checkbox(
                    value: _isActive,
                    onChanged: (bool? value) {
                      setState(() {
                        _isActive = value ?? false;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(item == null ? 'Añadir' : 'Actualizar'),
              onPressed: () {
                if (item == null) {
                  _addItem(
                    _nameController.text,
                    DateTime.parse(_dateController.text),
                    int.parse(_valueController.text),
                    _isActive,
                  );
                } else {
                  _updateItem(Item(
                    id: item.id,
                    name: _nameController.text,
                    date: DateTime.parse(_dateController.text),
                    value: int.parse(_valueController.text),
                    isActive: _isActive,
                  ));
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
