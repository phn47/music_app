import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/page_navigation.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BaseScaffold extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final int currentIndex;

  const BaseScaffold({
    super.key,
    required this.body,
    this.appBar,
    required this.currentIndex,
  });

  @override
  State<BaseScaffold> createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold>
    with TickerProviderStateMixin {
  late int selectedIndex;
  late AnimationController _homeAnimationController;
  late AnimationController _searchAnimationController;
  late AnimationController _artistAnimationController;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.currentIndex;

    // Khởi tạo animation controllers
    _homeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _searchAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _artistAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Chạy animation cho tab hiện tại
    if (widget.currentIndex == 0) {
      _homeAnimationController.forward();
    } else if (widget.currentIndex == 1) {
      _searchAnimationController.forward();
    } else if (widget.currentIndex == 2) {
      _artistAnimationController.forward();
    }
  }

  @override
  void dispose() {
    _homeAnimationController.dispose();
    _searchAnimationController.dispose();
    _artistAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      appBar: widget.appBar != null
          ? PreferredSize(
              preferredSize: widget.appBar!.preferredSize,
              child: AppBar(
                backgroundColor: (widget.appBar as AppBar).backgroundColor,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_outlined),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      PageNavigation.navigateWithSlide(
                        context,
                        HomePage(initialIndex: widget.currentIndex),
                        replace: true,
                      );
                    }
                  },
                ),
                title: (widget.appBar as AppBar).title,
                actions: (widget.appBar as AppBar).actions,
              ),
            )
          : null,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Pallete.backgroundColor,
            ),
          ),
          Positioned.fill(
            child: widget.body,
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MusicSlab(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
              ),
            ),
            label: 'Nghệ sĩ',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 3
                  ? 'assets/images/library-fill.png'
                  : 'assets/images/library-unfill.png',
              width: 24,
              height: 24,
              color: selectedIndex == 3
                  ? Pallete.whiteColor
                  : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Thư viện',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      // Reset tất cả các animation
      _homeAnimationController.reset();
      _searchAnimationController.reset();
      _artistAnimationController.reset();

      // Chạy animation cho tab được chọn
      if (index == 0) {
        _homeAnimationController.forward();
      } else if (index == 1) {
        _searchAnimationController.forward();
      } else if (index == 2) {
        _artistAnimationController.forward();
      }

      selectedIndex = index;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(initialIndex: index),
        ),
        (route) => false,
      );
    });
  }
}
