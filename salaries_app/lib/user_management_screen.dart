import 'package:flutter/material.dart';
import 'database_helper.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  UserManagementScreenState createState() => UserManagementScreenState();
}

class UserManagementScreenState extends State<UserManagementScreen> {
  final dbHelper = DatabaseHelper.instance;
  late Future<List<Map<String, dynamic>>> _users;

  @override
  void initState() {
    super.initState();
    _refreshUserList();
  }

  void _refreshUserList() {
    setState(() {
      _users = dbHelper.queryAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user[DatabaseHelper.columnUsername]),
                  subtitle: Text(user[DatabaseHelper.columnRole]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showUserDialog(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(user[DatabaseHelper.columnUserId]),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showUserDialog({Map<String, dynamic>? user}) {
    final usernameController = TextEditingController(text: user?[DatabaseHelper.columnUsername]);
    final passwordController = TextEditingController();
    String role = user?[DatabaseHelper.columnRole] ?? 'cashier';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Add User' : 'Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: user == null ? 'Password' : 'New Password'),
                obscureText: true,
              ),
              DropdownButton<String>(
                value: role,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      role = newValue;
                    });
                  }
                },
                items: <String>['admin', 'cashier']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                final Map<String, dynamic> userData = {
                  DatabaseHelper.columnUsername: usernameController.text,
                  DatabaseHelper.columnRole: role,
                };
                if (passwordController.text.isNotEmpty) {
                  userData[DatabaseHelper.columnPassword] = passwordController.text;
                }

                if (user == null) {
                  dbHelper.insertUser(userData);
                } else {
                  userData[DatabaseHelper.columnUserId] = user[DatabaseHelper.columnUserId];
                  dbHelper.updateUser(userData);
                }
                _refreshUserList();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text('Delete'),
            onPressed: () {
              dbHelper.deleteUser(id);
              _refreshUserList();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
