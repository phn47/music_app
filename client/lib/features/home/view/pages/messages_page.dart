import 'package:client/core/models/user_model.dart';
import 'package:client/features/home/view/pages/direct_message_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/home/providers/message_provider.dart';
import 'package:client/features/home/view/widgets/direct_messages_tab.dart';
import 'package:client/features/home/view/widgets/group_messages_tab.dart';

class MessagesPage extends ConsumerStatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      ref.read(userSearchProvider.notifier).searchUsers(query);
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      ref.read(userSearchProvider.notifier).clearSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(userSearchProvider);

    return Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_outlined,
                    color: Colors.white),
                onPressed: _stopSearch,
              )
            : null,
        title: _isSearching
            ? Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearch,
                  autofocus: true,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm người dùng...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: Colors.grey[400], size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Text('Tin nhắn', style: TextStyle(color: Colors.white)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: _startSearch,
                  ),
                ],
              ),
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message),
                        SizedBox(width: 8),
                        Text('Trò chuyện'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.group),
                        SizedBox(width: 8),
                        Text('Nhóm'),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      body: _isSearching
          ? Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: searchResults.when(
                data: (users) => users.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[600]),
                            SizedBox(height: 16),
                            Text(
                              'Không tìm thấy người dùng',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.imageUrl != null
                                  ? NetworkImage(user.imageUrl!)
                                  : null,
                              child: user.imageUrl == null
                                  ? Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              user.name,
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DirectMessagePage(
                                    receiverId: user.id,
                                    receiverName: user.name,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                loading: () => Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Lỗi: ${error.toString()}'),
                ),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                DirectMessagesTab(),
                GroupMessagesTab(),
              ],
            ),
    );
  }
}
