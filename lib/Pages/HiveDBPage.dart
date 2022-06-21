import 'package:flutter/material.dart';
import 'package:hive_crud/Boxes.dart';
import 'package:hive_crud/Comm/getTextFormField.dart';
import 'package:hive_crud/Model/userModel.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveDBPage extends StatefulWidget {
  const HiveDBPage({Key? key}) : super(key: key);

  @override
  State<HiveDBPage> createState() => _HiveDBPageState();
}

class _HiveDBPageState extends State<HiveDBPage> {
  final _formKey = GlobalKey<FormState>();

  final conId = TextEditingController();
  final conName = TextEditingController();
  final conEmail = TextEditingController();

  @override
  void dispose() {
    Hive.close();
    conId.dispose();
    conName.dispose();
    conEmail.dispose();
    super.dispose();
  }

  Future<void> addUser(String uId, String uName, String uEmail) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final user = UserModel()
        ..user_id = uId
        ..user_name = uName
        ..email = uEmail;

      final box = Boxes.getUsers();
      box.add(user).then((value) => clearPage());
    }
  }

  Future<void> editUser(UserModel userModel) async {
    conId.text = userModel.user_id;
    conName.text = userModel.user_name;
    conEmail.text = userModel.email;

    deleteUser(userModel);
  }

  Future<void> deleteUser(UserModel userModel) async {
    userModel.delete();
  }

  clearPage() {
    conId.text = '';
    conName.text = '';
    conEmail.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hive DB CRUD'),
          backgroundColor: Colors.red.shade600,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                genTextFormField(
                    controller: conId,
                    hintName: "User ID",
                    iconData: Icons.person_add),
                const SizedBox(height: 10),
                genTextFormField(
                    controller: conName,
                    hintName: "User Name",
                    iconData: Icons.person_outline),
                const SizedBox(height: 10),
                genTextFormField(
                    controller: conEmail,
                    textInputType: TextInputType.emailAddress,
                    hintName: "Email",
                    iconData: Icons.email),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 15.0),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          onPressed: () =>
                              addUser(conId.text, conName.text, conEmail.text),
                          child: const Text(
                            "Add",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: FlatButton(
                          onPressed: clearPage,
                          child: const Text(
                            "Clear",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          color: Colors.red.shade600,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                    height: 500,
                    child: ValueListenableBuilder(
                      valueListenable: Boxes.getUsers().listenable(),
                      builder: (BuildContext context, Box box, Widget? child) {
                        final users = box.values.toList().cast<UserModel>();

                        return genContent(users);
                      },
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget genContent(List<UserModel> user) {
    if (user.isEmpty) {
      return const Center(
        child: Text(
          "No Users Found",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      return ListView.builder(
          itemCount: user.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.white,
              child: ExpansionTile(
                title: Text(
                  "${user[index].user_id} (${user[index].email})",
                  maxLines: 2,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(user[index].user_name),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () => editUser(user[index]),
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.amber,
                        ),
                        label: const Text(
                          "Edit",
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => deleteUser(user[index]),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        label: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          });
    }
  }
}
