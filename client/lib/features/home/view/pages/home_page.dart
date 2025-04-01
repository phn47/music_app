// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/providers/theme_provider.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/artists_page.dart';
import 'package:client/features/home/view/pages/giaodientruyendulieu.dart';
import 'package:client/features/home/view/pages/library_page.dart';
import 'package:client/features/home/view/pages/messages_page.dart';
import 'package:client/features/home/view/pages/profile_page.dart';
import 'package:client/features/home/view/pages/search_page.dart';
import 'package:client/features/home/view/pages/songs_page.dart';
import 'package:client/features/home/view/pages/albums_page.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:lottie/lottie.dart';

class HomePage extends ConsumerStatefulWidget {
  final int initialIndex;

  const HomePage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late int selectedIndex;
  late ScrollController _scrollController;
  bool _showSearchBar = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final List<String> _filterOptions = [
    'Tất cả',
    'Nhạc',
    'Nghệ sĩ',
    'Album',
    'Thể loại'
  ];
  int _selectedFilterIndex = 0;
  int _selectedTabIndex = 0;
  late AnimationController _homeAnimationController;
  late AnimationController _searchAnimationController;
  late final AnimationController _artistAnimationController;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // Khởi tạo animation controllers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _homeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _artistAnimationController = AnimationController(vsync: this);

    // Tạo fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Nếu tab ban đầu là home hoặc search, chạy animation tương ứng
    if (widget.initialIndex == 0) {
      _homeAnimationController.forward();
    } else if (widget.initialIndex == 1) {
      _searchAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    _homeAnimationController.dispose();
    _searchAnimationController.dispose();
    _artistAnimationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!_showSearchBar) {
        setState(() {
          _showSearchBar = true;
        });
      }
    }
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (_showSearchBar) {
        setState(() {
          _showSearchBar = false;
        });
      }
    }
  }

  final pages = const [
    SongsPage(),
    SearchPage(),
    ArtistsPage(),
    LibraryPage(),
    ProfilePage(),
  ];

  String _getAppBarTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Trang chủ';
      case 1:
        return 'Tìm kiếm';
      case 2:
        return 'Nghệ sĩ';
      case 3:
        return 'Thư viện';
      case 4:
        return 'Hồ sơ';
      default:
        return 'Trang chủ';
    }
  }

  Widget _buildFilterButton(int index) {
    bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Pallete.gradient2 : Pallete.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Pallete.gradient2) : null,
        ),
        child: Text(
          _filterOptions[index],
          style: TextStyle(
            color: isSelected ? Pallete.whiteColor : Pallete.greyColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // Nếu không phải trang chủ (selectedIndex != 0), trả về AppBar thông thường
    if (selectedIndex != 0) {
      return AppBar(
        backgroundColor: Pallete.backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer(
            builder: (context, ref, child) {
              final currentUser = ref.watch(currentUserNotifierProvider);
              return GestureDetector(
                onTap: _showProfileDrawer,
                child: _buildSmallProfileAvatar(
                  currentUser?.imageUrl,
                  currentUser?.name,
                ),
              );
            },
          ),
        ),
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: Pallete.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MessagesPage(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Pallete.cardColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.message_rounded,
                  color: Pallete.whiteColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Trả về AppBar với ScrollableTabBar cho trang chủ
    return AppBar(
      backgroundColor: Pallete.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer(
          builder: (context, ref, child) {
            final currentUser = ref.watch(currentUserNotifierProvider);
            return GestureDetector(
              onTap: _showProfileDrawer,
              child: _buildSmallProfileAvatar(
                currentUser?.imageUrl,
                currentUser?.name,
              ),
            );
          },
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildTabButton('Tất cả', 0),
              const SizedBox(width: 10),
              _buildTabButton('Nhạc', 1),
              const SizedBox(width: 10),
              _buildTabButton('Nghệ sĩ', 2),
              const SizedBox(width: 10),
              _buildTabButton('Album', 3),
              const SizedBox(width: 10),
              _buildTabButton('Thể loại', 4),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessagesPage(),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Pallete.cardColor,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.message_rounded,
                color: Pallete.whiteColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = index == _selectedTabIndex;
    return GestureDetector(
      onTap: () => _updateSelectedTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Pallete.gradient2
              : Pallete.cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Pallete.gradient2
                : Pallete.greyColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Pallete.gradient2.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Pallete.backgroundColor : Pallete.whiteColor,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  void _updateSelectedTab(int index) {
    switch (index) {
      case 0: // Tất cả
        setState(() {
          selectedIndex = 0;
          _selectedTabIndex = 0;
        });
        break;
      case 1: // Nhạc - toggle giữa nhạc và tất cả
        if (_selectedTabIndex == 1) {
          // Nếu đang ở tab nhạc, chuyển về tất cả
          setState(() {
            selectedIndex = 0;
            _selectedTabIndex = 0;
          });
        } else {
          setState(() {
            selectedIndex = 0;
            _selectedTabIndex = 1;
          });
          // Overlay widget cho phần content
          OverlayEntry overlayEntry = OverlayEntry(
            builder: (context) => Positioned(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              bottom: kBottomNavigationBarHeight,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: Loader(),
                  ),
                ),
              ),
            ),
          );

          // Hiển thị overlay
          Overlay.of(context).insert(overlayEntry);

          // Xóa overlay sau 1 giây và cập nhật state
          Future.delayed(const Duration(seconds: 1), () {
            overlayEntry.remove();
            setState(() {
              _selectedTabIndex = 1; // Đảm bảo tab vẫn được chọn sau khi load
            });
          });
        }
        break;
      case 2: // Nghệ sĩ
        setState(() {
          selectedIndex = 2;
          _selectedTabIndex = 2;
        });
        break;
      case 3: // Album
        setState(() {
          selectedIndex = 3;
          _selectedTabIndex = 3;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AlbumsPage(),
          ),
        );
        break;
      case 4: // Thể loại
        setState(() {
          selectedIndex = 1;
          _selectedTabIndex = 4;
        });
        break;
    }
  }

  void _showProfileDrawer() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation1,
            curve: Curves.easeInOut,
          )),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              color: Pallete.backgroundColor,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Consumer(
                              builder: (context, ref, child) {
                                final currentUser =
                                    ref.watch(currentUserNotifierProvider);
                                return _buildLargeProfileAvatar(
                                  currentUser?.imageUrl,
                                  currentUser?.name,
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final currentUser = ref
                                          .watch(currentUserNotifierProvider);
                                      return Text(
                                        currentUser?.name ?? 'Tên người dùng',
                                        style: const TextStyle(
                                          color: Pallete.whiteColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                  const Text(
                                    'Xem hồ sơ',
                                    style: TextStyle(
                                      color: Pallete.greyColor,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(color: Pallete.greyColor),
                    // _buildDrawerItem(
                    //   icon: Icons.person_add_outlined,
                    //   title: 'Thêm tài khoản',
                    //   onTap: () {
                    //     // Xử lý thêm tài khoản
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   icon: Icons.bolt_outlined,
                    //   title: 'Nội dung mới',
                    //   onTap: () {
                    //     // Xử lý nội dung mới
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   icon: Icons.history,
                    //   title: 'Gần đây',
                    //   onTap: () {
                    //     // Xử lý gần đây
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   icon: Icons.settings,
                    //   title: 'Cài đặt và quyền riêng tư',
                    //   onTap: () {
                    //     // Xử lý cài đặt
                    //   },
                    // ),
                    // _buildDrawerItem(
                    //   icon: ref.watch(themeNotifierProvider)
                    //       ? Icons.light_mode
                    //       : Icons.dark_mode,
                    //   title: 'Chuyển đổi chế độ',
                    //   onTap: () {
                    //     ref.read(themeNotifierProvider.notifier).toggleTheme();
                    //     Navigator.pop(
                    //         context); // Đóng drawer sau khi chuyển đổi
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withOpacity(
                  animation1.value * 0.5,
                ),
              ),
            ),
            child!,
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Pallete.whiteColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                color: Pallete.whiteColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallProfileAvatar(String? imageUrl, String? name) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      String initial = (name ?? '').isNotEmpty
          ? name!.trim().split(' ').last.substring(0, 1).toUpperCase()
          : 'U';
      return CircleAvatar(
        radius: 16,
        backgroundColor: Pallete.gradient2,
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              color: Pallete.whiteColor,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Widget _buildLargeProfileAvatar(String? imageUrl, String? name) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(imageUrl),
      );
    } else {
      String initial = (name ?? '').isNotEmpty
          ? name!.trim().split(' ').last.substring(0, 1).toUpperCase()
          : 'U';
      return CircleAvatar(
        radius: 30,
        backgroundColor: Pallete.gradient2,
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              color: Pallete.whiteColor,
              fontSize: 32,
              fontWeight: FontWeight.w600,
              height: 1,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Thay đổi Container background thành màu đen
          Container(
            decoration: const BoxDecoration(
              color:
                  Pallete.backgroundColor, // Thay đổi background thành màu đen
            ),
          ),
          // Bọc pages trong Positioned để nó có thể tương tác được
          Positioned.fill(
            child: pages[selectedIndex],
          ),
          // Music Slab luôn nằm trên cùng
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MusicSlab(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: Lottie.asset(
                'assets/images/home.json',
                height: 24,
                width: 24,
                fit: BoxFit.fill,
                controller: _homeAnimationController,
                repeat: false,
                onLoaded: (composition) {
                  _homeAnimationController.duration = composition.duration;
                  // Nếu đang ở tab home, chạy animation ngay
                  if (selectedIndex == 0) {
                    _homeAnimationController.forward();
                  }
                },
              ),
            ),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: Lottie.asset(
                'assets/images/search.json',
                height: 24,
                width: 24,
                fit: BoxFit.fill,
                controller: _searchAnimationController,
                repeat: false,
                onLoaded: (composition) {
                  _searchAnimationController.duration = composition.duration;
                  // Nếu đang ở tab search, chạy animation ngay
                  if (selectedIndex == 1) {
                    _searchAnimationController.forward();
                  }
                },
              ),
            ),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              child: Lottie.asset(
                'assets/images/itunes.json',
                height: 24,
                width: 24,
                fit: BoxFit.fill,
                controller: _artistAnimationController,
                repeat: false,
                onLoaded: (composition) {
                  _artistAnimationController.duration = composition.duration;
                  // Nếu đang ở tab artist, chạy animation ngay
                  if (selectedIndex == 2) {
                    _artistAnimationController.forward();
                  }
                },
              ),
            ),
            label: 'Nghệ sĩ',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 3
                  ? 'assets/images/library-fill.png' // Hình fill khi được chọn
                  : 'assets/images/library-unfill.png', // Hình unfill khi không được chọn
              width: 24,
              height: 24,
              color: selectedIndex == 3
                  ? Pallete.whiteColor
                  : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Thư viện',
          ),
          // BottomNavigationBarItem(
          //   icon: Image.asset(
          //     'assets/images/profile.png',
          //     color: selectedIndex == 4
          //         ? Pallete.whiteColor
          //         : Pallete.inactiveBottomBarItemColor,
          //   ),
          //   label: 'Hồ sơ',
          // ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Pallete.whiteColor,
        unselectedItemColor: Pallete.inactiveBottomBarItemColor,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          color: Pallete.whiteColor,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Pallete.inactiveBottomBarItemColor,
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Pallete.backgroundColor,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      // Reset tất cả các animation về trạng thái ban đầu
      _homeAnimationController.reset();
      _searchAnimationController.reset();
      _artistAnimationController.reset();

      // Chỉ chạy animation của tab được chọn
      if (index == 0) {
        _homeAnimationController.forward();
      } else if (index == 1) {
        _searchAnimationController.forward();
      } else if (index == 2) {
        _artistAnimationController.forward();
      }

      selectedIndex = index;
      if (index == 0) {
        _selectedTabIndex = 0;
      }
    });
  }
}
