import 'package:flutter/material.dart';
import 'package:todo_check/database.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  Set<int> strikethroughIndexes = {};
  
  TextEditingController controller = TextEditingController();

  Future<List<Map<String, dynamic>>> dataFuture = DatabaseSqLite.getData();

  Future<void> refreshData() async {
    setState(() {
      dataFuture = DatabaseSqLite .getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 242, 253),
      body: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
             Container(
              margin: const EdgeInsets.only(top: 30,left: 10),
              child: const Text('All\nToDos', style: TextStyle(fontSize: 30),),
            ),
          ],
        ),
        Expanded(child: FutureBuilder<List<Map<String, dynamic>>>(
          future: dataFuture,
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading..');
            } 
            else if (snapshot.hasError) {
              return const Text('Error');
            } 
            else if (snapshot.hasData) {
              final List<Map<String, dynamic>> data = snapshot.data!;
              return RefreshIndicator(
                onRefresh: refreshData,
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> item = data[index];
                    final bool isStrikethrough = strikethroughIndexes.contains(index);
                    return Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.white),
                      child: ListTile(
                        onTap: (){
                          setState(() {
                            if (isStrikethrough) {
                              setState(() {
                                strikethroughIndexes.remove(index);
                              });
                            } else {
                              setState(() {
                                strikethroughIndexes.add(index);
                              });
                            }
                          });
                        },
                        leading: Icon(isStrikethrough ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                        title: Text(item['title'], 
                          style: TextStyle(decoration: isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,),),
                        trailing: IconButton(onPressed: (){
                          DatabaseSqLite.deleteData(item['id']);
                          refreshData();
                        }, 
                        icon: const Icon(Icons.delete),),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Text('No data');
            }
          },
        ))
      ]),
      floatingActionButton: FloatingActionButton(onPressed: (){
        showDialogWithAddData(context, controller, refreshData);
      },
      backgroundColor: Colors.white,
      child: const Icon(Icons.add),)
    );
  }
}

void showDialogWithAddData(BuildContext context, TextEditingController controller, Function() refreshData){
    var dialogAdd = AlertDialog(
      title: const Text('Add todo'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: 'Enter text'
        ),
        maxLines: null,
        maxLength: 50,
      ),
      actions: [
        TextButton(onPressed: (){
          DatabaseSqLite.insertData(controller.text);
          refreshData();
          controller.clear();
          Navigator.pop(context);
        }, 
        child: const Text('Add')
        ),

        TextButton(onPressed: (){
          controller.clear();
          Navigator.pop(context);
        }, 
        child: const Text('Close')
        )
      ],
    );

    showDialog(context: context, builder: (BuildContext context) {
      return dialogAdd;
    });
  } 