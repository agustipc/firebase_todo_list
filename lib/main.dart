import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/db.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }

}
Future<String> delayed(String message) async{
  await Future.delayed(Duration(seconds: 3));
  return message;
}

Stream<int> coountdown(int from) async*{
  await Future.delayed(Duration(seconds: 3));
  for(int i = from; i >= 0; i--){
    yield i;
    // yield es como un return pero sigue la funcion
    await Future.delayed(Duration(seconds: 1));
  }
}

class TestPage extends StatelessWidget{
  @override
  Widget build(BuildContext contex){
    return Scaffold(
      body: StreamBuilder<int>(
        stream: coountdown(10),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot){
          if(snapshot.hasError){
            return Center(child: Text('ERROR:: ${snapshot.toString()}'),);
          }
          switch(snapshot.connectionState){
            case ConnectionState.waiting:
              return Center(child: Text('Waiting...'),);
            case ConnectionState.active:
              return Center(child: Text('${snapshot.data}', style: TextStyle(fontSize: 40),));
            case ConnectionState.done:
              return Center(child: Text('Done!'),);
            case ConnectionState.none:
            default: 
              return(Placeholder());
          }
        },
      ),
    );
  }
}

//DocumentSnapshot: "Foto" de un documento en un momento de timepo
//QuerySnapshot: "Foto" de una consulta a una coleccion

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController _controller = TextEditingController();

  _addTodo(String text){
    if(text.isNotEmpty){
      addTodo(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true ,title: Text('Firestore Todo List')),
      body: StreamBuilder<List<Todo>>(
        stream: todoListSnapshots(),
        builder: (context, AsyncSnapshot<List<Todo>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('ERROR: ${snapshot.error.toString()}'));
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.active:
              return _buildBody(snapshot.data);
            case ConnectionState.done:
              return Center(child: Text("done??"));
            case ConnectionState.none:
            default:
              return Center(child: Text("no hi ha stream??"));
          }
        }
      ),
    );
  }

  Widget _buildBody(List<Todo> todos){
    return Column(
      children: <Widget>[
        Expanded(
          child: TodoList(todos: todos)
        ),
        Material(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                  )
                ),
                IconButton(
                  onPressed: () {
                    _addTodo(_controller.text);
                    _controller.clear();
                  },
                  icon: Icon(
                    Icons.add
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  TodoList({ @required this.todos });

  _toggleDone(Todo todo){
     Firestore.instance.collection('todos').document(todo.id).updateData({
              'done': !todo.done
            });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, int index) {
        return ListTile(
          onTap: () => _toggleDone(todos[index]),
          onLongPress: () => deleteTodo(todos[index]),
          title: Text(todos[index].what),
          leading: Checkbox(
            value: todos[index].done,
            onChanged: (_) => _toggleDone(todos[index]),
          ),
        );
      },
    );
  }
}