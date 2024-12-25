import 'package:flutter/material.dart';
import 'package:parent_link/builder/child_state_tile.dart';
import 'package:parent_link/model/control/control_child_state.dart';
import 'package:parent_link/model/control/control_main_user.dart';
import 'package:parent_link/theme/app.theme.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await Provider.of<ControlChildState>(context, listen: false)
          .fetchChildrenData();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final childStateList = context.watch<ControlChildState>().getlistChild;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<ControlMainUser>(builder: (context, user, child) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: $_error'),
                          ElevatedButton(
                            onPressed: _fetchData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // ... rest of your existing widget tree ...
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/children_qr_2');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 8),
                                    backgroundColor: Apptheme.colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      side: BorderSide(
                                        color: Apptheme.colors.black,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    "Add a child",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.notifications),
                                  onPressed: () {},
                                  iconSize: 36.0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25.0),
                              child: Text(
                                "Hello ${user.username}",
                                style: TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Text(
                                "There are current new alert",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Apptheme.colors.gray,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              SingleChildScrollView(
                                child: Container(
                                  height: childStateList.length * 150,
                                ),
                              ),
                              ...List.generate(childStateList.length, (index) {
                                final childState = childStateList[index];
                                return ChildStateTile(
                                    childState: childState, index: index);
                              }),
                            ],
                          ),
                        ],
                      ),
                    );
        }));
  }
}
