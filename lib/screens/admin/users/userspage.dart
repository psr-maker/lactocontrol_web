import 'package:flutter/material.dart';
import 'package:lactosure_control/constant/global/loadingflw.dart';
import 'package:lactosure_control/services/authen_service.dart';
import 'package:lactosure_control/widgets/custom_button.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> allUsers = [];

  List<dynamic> filteredUsers = [];

  bool isLoading = true;
  bool isSearching = false;
  String selectedFilter = "All";
  late TabController tabController;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final users = await AuthService.getAllUsers();

      setState(() {
        allUsers = users;
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      CustomSnackbar.show(
        context: context,
        message: e.toString(),
        isError: true,
      );
    }
  }

  void filterSearch(String value) {
    setState(() {
      filteredUsers = allUsers
          .where(
            (u) =>
                u["name"].toString().toLowerCase().contains(
                  value.toLowerCase(),
                ) ||
                u["email"].toString().toLowerCase().contains(
                  value.toLowerCase(),
                ),
          )
          .toList();
    });
  }

  List<dynamic> getPending() =>
      filteredUsers.where((u) => u["status"] == false).toList();

  List<dynamic> getApproved() =>
      filteredUsers.where((u) => u["status"] == true).toList();

  Future<void> approveUser(int id) async {
    bool success = await AuthService.approveUser(id);
    if (success) {
      CustomSnackbar.show(
        context: context,
        message: "User Approved",
        isError: false,
      );
      loadUsers();
    }
  }

  Future<void> rejectUser(int id) async {
    bool success = await AuthService.rejectUser(id);
    if (success) {
      CustomSnackbar.show(
        context: context,
        message: "User Rejected",
        isError: false,
      );
    }
  }

  Future<void> deleteUser(int id) async {
    bool success = await AuthService.deleteUser(id);

    if (success) {
      CustomSnackbar.show(
        context: context,
        message: "User deleted successfully",
        isError: false,
      );

      loadUsers();
    } else {
      CustomSnackbar.show(
        context: context,
        message: "Failed to delete user",
        isError: true,
      );
    }
  }

  List<dynamic> getFilteredUsers() {
    List<dynamic> users = List.from(allUsers);

    // Search
    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();

      users = users.where((user) {
        return (user["name"] ?? "").toString().toLowerCase().contains(query) ||
            (user["email"] ?? "").toString().toLowerCase().contains(query);
      }).toList();
    }

    // Status Filter
    if (selectedFilter == "Active") {
      users = users.where((u) => u["status"] == true).toList();
    } else if (selectedFilter == "Pending") {
      users = users.where((u) => u["status"] == false).toList();
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                style: Theme.of(context).textTheme.titleMedium,
                onChanged: filterSearch,
                decoration: InputDecoration(
                  hintText: "Search users...",
                  hintStyle: Theme.of(context).textTheme.titleMedium,
                  border: InputBorder.none,
                ),
              )
            : const Text("Users"),
      ),

      body: isLoading
          ? const Center(child: RotatingFlower())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// Top Bar
                  Row(
                    children: [
                      Text(
                        "All Users",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),

                      const Spacer(),

                      SizedBox(
                        width: 250,
                        child: TextField(
                          controller: searchController,
                          style: Theme.of(context).textTheme.titleMedium,
                          decoration: InputDecoration(
                            hintText: "Search users",
                            hintStyle: Theme.of(context).textTheme.titleMedium,
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),

                      const SizedBox(width: 20),

                      DropdownButton<String>(
                        value: selectedFilter,
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: const [
                          DropdownMenuItem(value: "All", child: Text("All")),
                          DropdownMenuItem(
                            value: "Active",
                            child: Text("Active"),
                          ),
                          DropdownMenuItem(
                            value: "Pending",
                            child: Text("Pending"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedFilter = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Name",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Text(
                            "Email",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),

                        Expanded(
                          flex: 1,
                          child: Text(
                            "Status",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            "Action",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final users = getFilteredUsers();

                        if (users.isEmpty) {
                          return const Center(child: Text("No users found"));
                        }

                        return ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            return desktopRow(users[index]);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget desktopRow(dynamic user) {
    final bool approved = user["status"] == true;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: Text(user["name"] ?? "")),

          Expanded(
            flex: 2,
            child: Text(user["email"] ?? "", overflow: TextOverflow.ellipsis),
          ),

          Expanded(
            child: Text(
              approved ? "Active" : "Pending",
              style: TextStyle(
                color: approved ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  deleteUser(user["uId"]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
