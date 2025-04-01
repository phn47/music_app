import 'package:artist/core/constants/server_constant.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/artist_service.dart';
import '../models/artist.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthService authService;
  late final ArtistService artistService;
  Artist? artist;
  bool isLoading = true;
  TextEditingController? _bioController;
  TextEditingController? _nameController;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    artistService = Provider.of<ArtistService>(context, listen: false);
    _bioController = TextEditingController();
    _nameController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _bioController?.dispose();
    _nameController?.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Sử dụng ArtistService
      artist = await artistService.getArtistProfile();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Exception when loading profile: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      await artistService.updateProfile(
        normalizedName: artist?.normalizedName,
        bio: artist?.bio,
        imageUrl: artist?.imageUrl,
      );

      // Reload profile after update
      await _loadProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showEditDialog() {
    _bioController?.text = artist?.bio ?? '';
    _nameController?.text = artist?.normalizedName ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Tên hiển thị',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _bioController,
                style: TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Tiểu sử',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (artist != null) {
                artist!.copyWith(
                    normalizedName: _nameController?.text ?? '',
                    bio: _bioController?.text ?? '');
                await _updateProfile();
              }
              Navigator.pop(context);
            },
            child: Text(
              'Lưu',
              style: TextStyle(color: Color(0xFFFF4400)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.3, 1.0],
          colors: [
            Colors.grey[900]!,
            Colors.grey[900]!.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Avatar với shadow và border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFFF4400),
              backgroundImage:
                  artist?.imageUrl != null && artist!.imageUrl!.isNotEmpty
                      ? NetworkImage(artist!.imageUrl!)
                      : null, // Hiển thị hình ảnh từ URL nếu có
              child: artist?.imageUrl == null || artist!.imageUrl!.isEmpty
                  ? Text(
                      artist?.name.substring(0, 1).toUpperCase() ??
                          '', // Hiển thị chữ cái đầu của tên nghệ sĩ nếu không có ảnh
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : null, // Không hiển thị Text nếu có ảnh
            ),
          ),
          const SizedBox(height: 20),
          // Tên nghệ sĩ với shadow nhẹ
          Text(
            artist?.name ?? '7217_Phạm Hoài Nam',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Thông tin follower với opacity
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${artist?.followerCount ?? 0} người theo dõi',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  ' • ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                Text(
                  'Đang theo dõi 3',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Buttons với hiệu ứng
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: OutlinedButton(
                  onPressed: _showEditDialog,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: Colors.white.withOpacity(0.3),
                    ),
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Chỉnh sửa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildIconButton(Icons.share_outlined),
              _buildIconButton(Icons.more_horiz),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon),
        color: Colors.white.withOpacity(0.9),
        iconSize: 24,
        splashRadius: 24,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Không có hoạt động gần đây.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy khám phá thêm nhạc mới ngay',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildProfileHeader(),
                ),
                SliverFillRemaining(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }
}
