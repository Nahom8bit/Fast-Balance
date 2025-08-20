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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add a new user',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          } else {
            final users = snapshot.data!;
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 600;
                
                if (isWideScreen) {
                  // Grid layout for wide screens
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth > 1200 ? 4 : 
                                     constraints.maxWidth > 900 ? 3 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserCard(user);
                    },
                  );
                } else {
                  // List layout for mobile
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildUserCard(user),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String username = user[DatabaseHelper.columnUsername];
    final String role = user[DatabaseHelper.columnRole];
    final bool isAdmin = role.toLowerCase() == 'admin';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showUserDialog(user: user),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isAdmin 
                        ? Colors.purple.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                      color: isAdmin ? Colors.purple[600] : Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showUserDialog(user: user);
                      } else if (value == 'delete') {
                        _confirmDeleteUser(user);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                username,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin 
                    ? Colors.purple.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    color: isAdmin ? Colors.purple[700] : Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last login: Recent',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete user "${user[DatabaseHelper.columnUsername]}"?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () {
                _deleteUser(user[DatabaseHelper.columnUserId]);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
