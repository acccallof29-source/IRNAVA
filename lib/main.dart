import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const Color bg = Color(0xFF080610);
const Color surface = Color(0xFF171322);
const Color purple = Color(0xFF9B5CFF);
const Color muted = Color(0xFFAAA3B8);

void main() {
  runApp(const IrnavaApp());
}

class IrnavaApp extends StatelessWidget {
  const IrnavaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IRNAVA',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: AuthPage(),
      ),
    );
  }
}



String currentUsername = '';
String currentNumericId = '';
bool currentIsPremium = false;

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  late final AnimationController animation;
  bool isLogin = true;
  bool hidden = true;
  bool hiddenConfirm = true;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    animation.dispose();
    username.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;

    currentUsername = username.text.trim();

    if (!isLogin || currentNumericId.isEmpty) {
      currentNumericId =
          (Random.secure().nextInt(90000000) + 10000000).toString();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  InputDecoration decoration(String label, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: purple),
      suffixIcon: suffix,
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: purple.withValues(alpha: .2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: purple),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: purple.withValues(alpha: .13),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: animation,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB77AFF), Color(0xFF5723A8)],
                            ),
                          ),
                          child: const Icon(
                            Icons.graphic_eq,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'IRNAVA',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 5,
                            color: Color(0xFFC69AFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'موسیقی، نزدیک‌تر از همیشه',
                          style: TextStyle(color: muted),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: const Color(0xFF100D19),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: purple.withValues(alpha: .2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                isLogin ? 'خوش برگشتی!' : 'ساخت حساب ایرنوا',
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isLogin
                                    ? 'با شناسه و رمز عبورت وارد شو'
                                    : 'شناسه دلخواهت را انتخاب کن',
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: _mode('ورود', true),
                                  ),
                                  Expanded(
                                    child: _mode('ثبت‌نام', false),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: username,
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: decoration(
                                        'شناسه کاربری دلخواه',
                                        Icons.person_outline,
                                      ),
                                      validator: (v) {
                                        final value = v?.trim() ?? '';
                                        if (value.length < 3) {
                                          return 'شناسه باید حداقل ۳ کاراکتر باشد';
                                        }
                                        if (!RegExp(r'^[a-zA-Z0-9_]+$')
                                            .hasMatch(value)) {
                                          return 'فقط حروف انگلیسی، عدد و _ مجاز است';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 15),
                                    TextFormField(
                                      controller: password,
                                      obscureText: hidden,
                                      textDirection: TextDirection.ltr,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: decoration(
                                        'رمز عبور',
                                        Icons.lock_outline,
                                        suffix: IconButton(
                                          onPressed: () =>
                                              setState(() => hidden = !hidden),
                                          icon: Icon(
                                            hidden
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: muted,
                                          ),
                                        ),
                                      ),
                                      validator: (v) =>
                                          (v ?? '').length < 8
                                              ? 'رمز عبور حداقل ۸ کاراکتر باشد'
                                              : null,
                                    ),
                                    if (!isLogin) ...[
                                      const SizedBox(height: 15),
                                      TextFormField(
                                        controller: confirm,
                                        obscureText: hiddenConfirm,
                                        textDirection: TextDirection.ltr,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: decoration(
                                          'تکرار رمز عبور',
                                          Icons.lock_reset,
                                          suffix: IconButton(
                                            onPressed: () => setState(
                                              () => hiddenConfirm = !hiddenConfirm,
                                            ),
                                            icon: Icon(
                                              hiddenConfirm
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: muted,
                                            ),
                                          ),
                                        ),
                                        validator: (v) => v != password.text
                                            ? 'رمزها یکسان نیستند'
                                            : null,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                height: 53,
                                child: ElevatedButton(
                                  onPressed: submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: purple,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Text(
                                    isLogin ? 'ورود به ایرنوا' : 'ساخت حساب',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextButton(
                                onPressed: () => setState(() {
                                  isLogin = !isLogin;
                                  confirm.clear();
                                }),
                                child: Text(
                                  isLogin
                                      ? 'حساب نداری؟ ثبت‌نام کن'
                                      : 'قبلاً حساب ساخته‌ای؟ وارد شو',
                                  style: const TextStyle(color: purple),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'نسخه آزمایشی حساب کاربری IRNAVA',
                          style: TextStyle(color: muted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mode(String label, bool login) {
    final selected = isLogin == login;
    return GestureDetector(
      onTap: () => setState(() {
        isLogin = login;
        confirm.clear();
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? purple : surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class Song {
  final String title;
  final String artist;
  final List<Color> colors;

  const Song(this.title, this.artist, this.colors);
}

const songs = [
  Song('آسمان من', 'خواننده ایرانی', [Color(0xFF7139B8), Color(0xFF25143F)]),
  Song('شب‌های تهران', 'موسیقی فارسی', [Color(0xFFB34C83), Color(0xFF421B4D)]),
  Song('Dreams', 'International Artist', [Color(0xFF286D85), Color(0xFF172C4C)]),
  Song('Golden Hour', 'Music Collection', [Color(0xFFB77B35), Color(0xFF49301C)]),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  int selectedCategory = 0;
  int playingIndex = 0;
  bool isPlaying = false;
  String searchText = '';

  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void playSong(int index) {
    setState(() {
      playingIndex = index;
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _buildPage()),
          ],
        ),
      ),
      bottomNavigationBar: _bottomArea(),
    );
  }

  Widget _buildPage() {
    if (selectedTab == 1) return _searchPage();
    if (selectedTab == 2) return _libraryPage();
    if (selectedTab == 3) return _profilePage();
    return _homePage();
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: .18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.graphic_eq, color: purple, size: 29),
          ),
          const SizedBox(width: 11),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'IRNAVA',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'موسیقی، همیشه همراه تو',
                style: TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          CircleAvatar(
            radius: 19,
            backgroundColor: surface,
            child: const Icon(Icons.person_outline, color: purple),
          ),
        ],
      ),
    );
  }

  Widget _homePage() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _header(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _searchBox(),
        ),
        const SizedBox(height: 24),
        _sectionTitle('برای تو', 'پیشنهادهای ویژه'),
        _heroCard(),
        const SizedBox(height: 25),
        _sectionTitle('دسته‌بندی‌ها', 'انتخاب سبک موسیقی'),
        _categories(),
        const SizedBox(height: 25),
        _sectionTitle('محبوب‌ترین‌ها', 'آهنگ‌های منتخب'),
        _songList(),
        const SizedBox(height: 25),
        _sectionTitle('مجموعه‌ها', 'آلبوم‌های پیشنهادی'),
        _albums(),
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      height: 53,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .05)),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() => searchText = value);
        },
        onTap: () {
          setState(() => selectedTab = 1);
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'نام آهنگ، خواننده یا آلبوم...',
          hintStyle: TextStyle(color: muted, fontSize: 13),
          prefixIcon: Icon(Icons.search, color: purple),
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(color: muted, fontSize: 11)),
            ],
          ),
          const Spacer(),
          const Text('مشاهده همه',
              style: TextStyle(color: purple, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 178,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF572B91), Color(0xFF211333)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 10,
              top: 10,
              child: Icon(Icons.graphic_eq,
                  size: 125, color: Colors.white.withValues(alpha: .09)),
            ),
            Padding(
              padding: const EdgeInsets.all(19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('PLAYLIST OF THE WEEK',
                        style: TextStyle(fontSize: 9, letterSpacing: 1)),
                  ),
                  const Spacer(),
                  const Text('دنیای موسیقی',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900)),
                  const Text('مجموعه‌ای برای لحظه‌های خاص تو',
                      style: TextStyle(fontSize: 11, color: Colors.white70)),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: () => playSong(0),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF512B83),
                      minimumSize: const Size(110, 34),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('پخش مجموعه'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categories() {
    const labels = ['همه', 'ایرانی', 'خارجی', 'پاپ', 'سنتی', 'بی‌کلام'];
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final selected = selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? purple : surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _songList() {
    return Column(
      children: List.generate(songs.length, (index) {
        final song = songs[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          leading: _cover(song.colors, 49),
          title: Text(song.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(song.artist,
              style: const TextStyle(color: muted, fontSize: 11)),
          trailing: IconButton(
            onPressed: () => playSong(index),
            icon: Icon(
              playingIndex == index && isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_outline,
              color: purple,
              size: 29,
            ),
          ),
          onTap: () => playSong(index),
        );
      }),
    );
  }

  Widget _albums() {
    return SizedBox(
      height: 145,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _albumCard('شب‌های بنفش', const [Color(0xFF7D4CC2), Color(0xFF30204B)]),
          _albumCard('آرامش', const [Color(0xFF267D8D), Color(0xFF16313D)]),
          _albumCard('لحظه‌ها', const [Color(0xFFB16A49), Color(0xFF512C38)]),
        ],
      ),
    );
  }

  Widget _albumCard(String title, List<Color> colors) {
    return Container(
      width: 112,
      margin: const EdgeInsets.only(left: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cover(colors, 105),
          const SizedBox(height: 7),
          Text(title, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _cover(List<Color> colors, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: const Icon(Icons.music_note_rounded,
          color: Colors.white70, size: 32),
    );
  }

  Widget _searchPage() {
    final filtered = songs.where((song) {
      return song.title.toLowerCase().contains(searchText.toLowerCase()) ||
          song.artist.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 18),
      children: [
        _header(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _searchBox(),
        ),
        const SizedBox(height: 25),
        _sectionTitle('جست‌وجو', 'نتایج موسیقی'),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Text('موردی پیدا نشد',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted)),
          )
        else
          ...filtered.map((song) {
            final index = songs.indexOf(song);
            return ListTile(
              leading: _cover(song.colors, 48),
              title: Text(song.title),
              subtitle: Text(song.artist),
              trailing: const Icon(Icons.play_circle_outline, color: purple),
              onTap: () => playSong(index),
            );
          }),
      ],
    );
  }

  Widget _libraryPage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _header(),
        const Text('کتابخانه من',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('موسیقی‌های مورد علاقه و مجموعه‌های تو',
            style: TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 25),
        _libraryItem(Icons.favorite_border, 'آهنگ‌های مورد علاقه'),
        _libraryItem(Icons.download_outlined, 'دانلودهای من'),
        _libraryItem(Icons.queue_music, 'لیست‌های پخش'),
        _libraryItem(Icons.history, 'اخیراً پخش‌شده'),
      ],
    );
  }

  Widget _libraryItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: purple),
        title: Text(title, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_left, color: muted),
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget _profilePage() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _header(),
        const SizedBox(height: 20),
        const CircleAvatar(
          radius: 42,
          backgroundColor: surface,
          child: Icon(Icons.person, size: 42, color: purple),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                currentUsername.isEmpty ? 'کاربر ایرنوا' : currentUsername,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (currentIsPremium) ...[
              const SizedBox(width: 7),
              const Icon(Icons.workspace_premium,
                  color: Color(0xFFFFD166), size: 25),
            ],
          ],
        ),
        const SizedBox(height: 7),
        Center(
          child: Text(
            'شناسه عددی: ${currentNumericId.isEmpty ? '---' : currentNumericId}',
            textDirection: TextDirection.ltr,
            style: const TextStyle(color: muted, fontSize: 13),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            currentIsPremium ? 'عضو IRNAVA PREMIUM' : 'عضو رایگان IRNAVA',
            style: TextStyle(
              color: currentIsPremium ? const Color(0xFFFFD166) : muted,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 25),
        _libraryItem(Icons.account_circle_outlined, 'حساب کاربری'),
        _libraryItem(Icons.workspace_premium_outlined, 'اشتراک Premium'),
        _libraryItem(Icons.language, 'زبان برنامه'),
        _libraryItem(Icons.settings_outlined, 'تنظیمات'),
        _libraryItem(Icons.help_outline, 'پشتیبانی', onTap: _openSupportPage),
      ],
    );
  }

  void _openSupportPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SupportPage()),
    );
  }

  Widget _bottomArea() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF100C19),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: .06))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _miniPlayer(),
          NavigationBar(
            height: 65,
            backgroundColor: const Color(0xFF100C19),
            selectedIndex: selectedTab,
            onDestinationSelected: (index) {
              setState(() => selectedTab = index);
            },
            indicatorColor: purple.withValues(alpha: .18),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: purple),
                  label: 'خانه'),
              NavigationDestination(
                  icon: Icon(Icons.search), label: 'جست‌وجو'),
              NavigationDestination(
                  icon: Icon(Icons.library_music_outlined),
                  label: 'کتابخانه'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline), label: 'پروفایل'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniPlayer() {
    final song = songs[playingIndex];
    return Container(
      height: 67,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          _cover(song.colors, 43),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
                Text(song.artist,
                    maxLines: 1,
                    style: const TextStyle(color: muted, fontSize: 10)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() => isPlaying = !isPlaying);
            },
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: purple,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () => playSong((playingIndex + 1) % songs.length),
            icon: const Icon(Icons.skip_next_rounded, size: 27),
          ),
        ],
      ),
    );
  }
}


class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  Future<void> _openTelegram(BuildContext context, String username) async {
    final uri = Uri.parse('https://t.me/$username');
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('باز کردن لینک تلگرام ممکن نشد')),
      );
    }
  }

  Widget _telegramCard(
    BuildContext context, {
    required String title,
    required String username,
    required String description,
  }) {
    return Card(
      color: surface,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        leading: const FaIcon(
          FontAwesomeIcons.telegram,
          color: Color(0xFF229ED9),
          size: 34,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: purple, fontSize: 14),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.open_in_new, color: muted, size: 19),
        onTap: () => _openTelegram(context, username.substring(1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پشتیبانی ایرنوا'),
        backgroundColor: bg,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 15),
          const Center(
            child: FaIcon(
              FontAwesomeIcons.telegram,
              color: Color(0xFF229ED9),
              size: 65,
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'ارتباط با IRNAVA',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 9),
          const Center(
            child: Text(
              'برای دریافت اخبار و ارتباط با پشتیبانی از راه‌های زیر استفاده کنید.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 30),
          _telegramCard(
            context,
            title: 'کانال رسمی ایرنوا',
            username: '@irnavaia',
            description: 'اخبار و اطلاعیه‌های IRNAVA',
          ),
          _telegramCard(
            context,
            title: 'ادمین پشتیبانی',
            username: '@Irnavai',
            description: 'ارتباط مستقیم با پشتیبانی',
          ),
        ],
      ),
    );
  }
}
