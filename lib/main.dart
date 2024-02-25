import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo/common/colors.dart';
import 'package:todo/databasehelper.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

Color getRandomColor() {
  final Random random = Random();
  return Color.fromARGB(
    100,
    random.nextInt(256), // red
    random.nextInt(256), // green
    random.nextInt(256), // blue
  );
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late TabController controller;
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<Task> _tasks = [];
  late DatabaseHelper dbHelper;

  // Define different bodies for each tab
  //final List<Widget> _bodies = [Center(child: Text('Home Body')), Tasks(_tasks)];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dbHelper = DatabaseHelper();
    fetchAndUpdateTasks();
    controller = new TabController(length: 2, vsync: this);
  }

  Future<void> fetchAndUpdateTasks() async {
    _tasks = await dbHelper.getTasks();
    print(_tasks.length);
    print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&");
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        appBar: buildAppBar(),
        drawer: buildDrawer(),
        /*body: TabBarView(
              controller: controller,
              children: [Text("This is active screen"), Tasks()],
            ),*/
        body: IndexedStack(
          index: _currentIndex,
          children: [
            buildListTasksView(false),
            buildListTasksView(true),
          ],
        ),
        floatingActionButton: buildFloatingActionButton(context),
        bottomNavigationBar: buildBottomNavigationBar(),
      );
    });
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: primaryColor,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      // Change selected tab label color
      fixedColor: Colors.white,
      // Change selected tab icon and background color
      unselectedItemColor: Colors.grey,
      // Change unselected tab icon and label color
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.play_arrow_outlined),
          label: 'Active',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.done_outline_outlined),
          label: 'Completed',
        ),
      ],
    );
  }

  Widget buildListTasksView(bool isCompleted) {
    List<Task> tasks =
        _tasks.where((task) => task.isCompleted == isCompleted).toList();

    return tasks.isEmpty
        ? Center(
            child: Text("No Tasks"),
          )
        : ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: getRandomColor(),
                  borderRadius:
                      BorderRadius.circular(20), // Set the radius value here
                ),
                margin: EdgeInsets.all(5),
                child: ListTile(
                  leading: Checkbox(
                    checkColor: Colors.black,
                    fillColor: MaterialStateColor.resolveWith((states) {
                      return Colors.white;
                    }),
                    value: tasks[index].isCompleted,
                    onChanged: (bool? value) {
                      value = !tasks[index].isCompleted;
                      tasks[index].isCompleted = value!;
                      dbHelper.updateTask(tasks[index]);
                      fetchAndUpdateTasks();
                      setState(() {});
                    },
                  ),
                  title: Text(tasks[index].title),
                  subtitle: Text(tasks[index].subtitle),
                  onTap: () {
                    // Handle tap for the corresponding item
                    // print('Tapped on ${items[index]}');
                  },
                  trailing: Container(
                    color: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.delete_outlined),
                      onPressed: () async {
                        await dbHelper.deleteTask(tasks[index].id!);
                        await fetchAndUpdateTasks();
                        setState(() {
                          print("In delete state");
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          );
  }

  Drawer buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: Image.asset("assets/logo.png"),
            accountName: Text(
              "TODO MANAGER",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            accountEmail: null,
            decoration: BoxDecoration(
              color: primaryColor,
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              createNewTask(context);
            },
            hoverColor: secondaryColor,
            title: Text(
              "Create New",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            ),
            trailing: Icon(Icons.add),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _currentIndex = 0;
              setState(() {});
            },
            hoverColor: secondaryColor,
            title: Text(
              "Active Tasks",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            ),
            trailing: Icon(Icons.play_arrow_outlined),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _currentIndex = 1;
              setState(() {});
            },
            hoverColor: secondaryColor,
            title: Text(
              "Completed Tasks",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontSize: 20),
            ),
            trailing: Icon(Icons.done_outline),
          )
        ],
      ),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        createNewTask(context);
      },
      backgroundColor: primaryColor,
      child: Icon(
        Icons.add_task,
        color: Colors.white,
      ),
    );
  }

  void createNewTask(BuildContext context) {
    TextEditingController titleController =
        TextEditingController(); // Controller for the task title
    TextEditingController subtitleController = TextEditingController();
    // context = _scaffoldKey.currentState!.context;
    if (context != null) {
      showDialog(
          builder: (BuildContext context) {
            return AlertDialog(
              title: Container(
                  padding: EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width,
                  color: primaryColor,
                  child: Text(
                    'Create New Task',
                    style: TextStyle(color: Colors.white),
                  )),
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height *
                      0.3, // Set the maximum or fixed height
                ),
                child: Column(
                  children: [
                    // Task title input field
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: titleController,
                      decoration: InputDecoration(labelText: 'Task Title'),
                    ),
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      controller: subtitleController,
                      decoration: InputDecoration(labelText: 'Sub Title'),
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog without saving
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 20, color: primaryColor),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    // Handle the logic to save the task
                    String taskTitle = titleController.text;
                    String subTitle = subtitleController.text;
                    if (taskTitle.isNotEmpty) {
                      // Replace this with your logic to save the task
                      print('Task Title: $taskTitle');
                      DatabaseHelper dbHelper = DatabaseHelper();
                      await dbHelper.insertTask(
                          Task(title: taskTitle, subtitle: subTitle));
                      await fetchAndUpdateTasks();

                      setState(() {}); // Cl
                    } else {
                      // Handle empty task title
                      print('Task title cannot be empty');
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 20, color: primaryColor),
                  ),
                ),
              ],
            );
          },
          context: context);
    }
  }

  AppBar buildAppBar() {
    return AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(
          color: Colors.white, // Change the color of the drawer icon here
        ),
        title: Text(
          "TODO MANAGER",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ));
  }
}
