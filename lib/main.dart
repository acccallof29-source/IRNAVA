import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const bg = Color(0xFF080610);
const surface = Color(0xFF171322);
const purple = Color(0xFF9B5CFF);
const muted = Color(0xFFAAA3B8);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool checking = true;
  bool authenticated = false;
  bool hasAccount = false;

  @override
  void initState() {
    super.initState();
    checkAccount();
  }

  Future<void> checkAccount() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      hasAccount = prefs.getString('irnava_account_username') != null;
      checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (authenticated) return const MusicHome();

    return AuthPage(
      hasAccount: hasAccount,
      onAuthenticated: () {
        setState(() => authenticated = true);
      },
    );
  }
}

class AuthPage extends StatefulWidget {
  final bool hasAccount;
  final VoidCallback onAuthenticated;

  const AuthPage({
    super.key,
    required this.hasAccount,
    required this.onAuthenticated,
  });

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  bool hidden = true;
  bool loading = false;

  String hashPassword(String value) {
    return sha256.convert(utf8.encode(value)).toString();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate() || loading) return;

    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final name = username.text.trim().toLowerCase();
      final passHash = hashPassword(password.text);

      final savedName = prefs.getString('irnava_account_username');
      final savedHash = prefs.getString('irnava_account_hash');

      if (savedName == null) {
        await prefs.setString('irnava_account_username', name);
        await prefs.setString('irnava_account_hash', passHash);
      } else {
        if (savedName != name || savedHash != passHash) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('نام کاربری یا رمز عبور اشتباه است'),
              ),
            );
          }
          return;
        }
      }

      widget.onAuthenticated();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ذخیره حساب انجام نشد')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.graphic_eq,
                        color: purple,
                        size: 76,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'IRNAVA',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: purple,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.hasAccount
                            ? 'خوش برگشتی! وارد حساب خودت شو'
                            : 'حساب کاربری ایرنوا را بساز',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 35),
                      TextFormField(
                        controller: username,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        decoration: const InputDecoration(
                          labelText: 'نام کاربری',
                          prefixIcon: Icon(Icons.person_outline),
                          filled: true,
                        ),
                        validator: (v) {
                          final value = v?.trim() ?? '';
                          if (value.length < 3 ||
                              !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                            return 'حداقل ۳ حرف؛ فقط انگلیسی، عدد و _';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: password,
                        obscureText: hidden,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          labelText: 'رمز عبور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => hidden = !hidden),
                            icon: Icon(
                              hidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: (v) => (v ?? '').length < 8
                            ? 'رمز عبور باید حداقل ۸ کاراکتر باشد'
                            : null,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton(
                          onPressed: loading ? null : submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: purple,
                          ),
                          child: loading
                              ? const CircularProgressIndicator()
                              : Text(
                                  widget.hasAccount
                                      ? 'ورود به ایرنوا'
                                      : 'ساخت حساب',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class Song {
  final String path;
  final String name;

  Song(this.path) : name = path.split('/').last;

  Map<String, String> toMap() => {'path': path, 'name': name};

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(map['path'] as String);
  }
}

class MusicHome extends StatefulWidget {
  const MusicHome({super.key});

  @override
  State<MusicHome> createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final AudioPlayer player = AudioPlayer();
  final TextEditingController searchController = TextEditingController();

  List<Song> songs = [];
  Set<String> favorites = {};
  int currentIndex = -1;
  int tab = 0;
  bool loading = false;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  String search = '';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadLibrary();

    player.positionStream.listen((value) {
      if (mounted) setState(() => position = value);
    });

    player.durationStream.listen((value) {
      if (mounted) setState(() => duration = value ?? Duration.zero);
    });

    player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => isPlaying = state.playing);
      if (state.processingState == ProcessingState.completed) {
        nextSong();
      }
    });
  }

  Future<void> loadLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('irnava_songs') ?? [];
    final savedFavorites = prefs.getStringList('irnava_favorites') ?? [];

    if (!mounted) return;
    setState(() {
      songs = saved
          .where((path) => File(path).existsSync())
          .map((path) => Song(path))
          .toList();
      favorites = savedFavorites.toSet();
    });
    saveLibrary();
  }

  Future<void> saveLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'irnava_songs',
      songs.map((song) => song.path).toList(),
    );
    await prefs.setStringList('irnava_favorites', favorites.toList());
  }

  Future<void> importSongs() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result == null) return;

      int added = 0;
      for (final file in result.files) {
        final path = file.path;
        if (path == null || !File(path).existsSync()) continue;
        if (songs.any((song) => song.path == path)) continue;
        songs.add(Song(path));
        added++;
      }

      await saveLibrary();
      if (!mounted) return;
      setState(() {});
      showMessage('$added آهنگ به کتابخانه اضافه شد');
    } catch (e) {
      showMessage('خطا در انتخاب فایل: $e');
    }
  }

  Future<void> playSong(int index) async {
    if (index < 0 || index >= songs.length || loading) return;

    setState(() {
      loading = true;
      errorMessage = null;
      currentIndex = index;
      position = Duration.zero;
      duration = Duration.zero;
    });

    try {
      await player.setFilePath(songs[index].path);
      await player.play();
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'این فایل قابل پخش نیست';
          isPlaying = false;
        });
        showMessage('پخش آهنگ ناموفق بود. فایل دیگری انتخاب کن.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> togglePlayback() async {
    if (currentIndex == -1) {
      if (songs.isNotEmpty) await playSong(0);
      return;
    }

    try {
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    } catch (_) {
      showMessage('پخش آهنگ انجام نشد');
    }
  }

  Future<void> nextSong() async {
    if (songs.isEmpty) return;
    final next = currentIndex < 0 ? 0 : (currentIndex + 1) % songs.length;
    await playSong(next);
  }

  Future<void> previousSong() async {
    if (songs.isEmpty) return;
    final previous = currentIndex <= 0 ? songs.length - 1 : currentIndex - 1;
    await playSong(previous);
  }

  Future<void> toggleFavorite(Song song) async {
    setState(() {
      if (favorites.contains(song.path)) {
        favorites.remove(song.path);
      } else {
        favorites.add(song.path);
      }
    });
    await saveLibrary();
  }

  Future<void> removeSong(Song song) async {
    if (currentIndex >= 0 && songs[currentIndex].path == song.path) {
      await player.stop();
      currentIndex = -1;
      isPlaying = false;
    }
    setState(() {
      songs.removeWhere((item) => item.path == song.path);
      favorites.remove(song.path);
    });
    await saveLibrary();
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: surface,
      ),
    );
  }

  String formatTime(Duration value) {
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  List<Song> get visibleSongs {
    final source = tab == 1
        ? songs.where((song) => favorites.contains(song.path)).toList()
        : songs;
    if (search.trim().isEmpty) return source;
    return source
        .where((song) => song.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    player.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: bg,
          title: const Text(
            'IRNAVA',
            style: TextStyle(
              color: purple,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          actions: [
            IconButton(
              onPressed: importSongs,
              icon: const Icon(Icons.add_circle_outline, color: purple),
              tooltip: 'افزودن آهنگ',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _buildPage()),
            if (currentIndex >= 0) _miniPlayer(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: surface,
          indicatorColor: purple.withValues(alpha: 0.2),
          selectedIndex: tab,
          onDestinationSelected: (value) {
            setState(() => tab = value);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'خانه',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'علاقه‌مندی',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music),
              label: 'کتابخانه',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage() {
    if (tab == 2) return _libraryPage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() => search = value),
              decoration: const InputDecoration(
                hintText: 'جست‌وجوی آهنگ در کتابخانه',
                prefixIcon: Icon(Icons.search, color: purple),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                colors: [Color(0xFF442078), Color(0xFF171322)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'موسیقی، همیشه همراه تو',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'آهنگ‌های گوشی‌ات را وارد کن و در ایرنوا گوش بده.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: importSongs,
                  icon: const Icon(Icons.library_add),
                  label: const Text('انتخاب آهنگ از گوشی'),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          child: Text(
            tab == 1 ? 'آهنگ‌های مورد علاقه' : 'کتابخانه موسیقی',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: _songList()),
      ],
    );
  }

  Widget _songList() {
    final list = visibleSongs;

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_off, size: 58, color: muted),
              const SizedBox(height: 14),
              Text(
                tab == 1
                    ? 'هنوز آهنگ مورد علاقه‌ای نداری'
                    : 'هنوز آهنگی اضافه نکرده‌ای',
                style: const TextStyle(color: muted, fontSize: 16),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: importSongs,
                icon: const Icon(Icons.add),
                label: const Text('انتخاب فایل صوتی'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final song = list[index];
        final actualIndex = songs.indexWhere((s) => s.path == song.path);
        final selected = actualIndex == currentIndex;
        final favorite = favorites.contains(song.path);

        return ListTile(
          onTap: () => playSong(actualIndex),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: purple.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              selected && isPlaying ? Icons.graphic_eq : Icons.music_note,
              color: purple,
            ),
          ),
          title: Text(
            song.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? purple : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            selected ? 'در حال پخش' : 'فایل صوتی دستگاه',
            style: const TextStyle(color: muted, fontSize: 12),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'favorite') toggleFavorite(song);
              if (value == 'remove') removeSong(song);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'favorite',
                child: Text(favorite
                    ? 'حذف از علاقه‌مندی‌ها'
                    : 'افزودن به علاقه‌مندی‌ها'),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Text('حذف از کتابخانه'),
              ),
            ],
            child: Icon(
              favorite ? Icons.favorite : Icons.more_vert,
              color: favorite ? Colors.pinkAccent : muted,
            ),
          ),
        );
      },
    );
  }

  Widget _libraryPage() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'کتابخانه من',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _libraryTile(
            Icons.music_note,
            'تمام آهنگ‌ها',
            '${songs.length} آهنگ',
            () => setState(() => tab = 0),
          ),
          _libraryTile(
            Icons.favorite,
            'علاقه‌مندی‌ها',
            '${favorites.length} آهنگ',
            () => setState(() => tab = 1),
          ),
          _libraryTile(
            Icons.add_circle_outline,
            'افزودن آهنگ جدید',
            'انتخاب از حافظه گوشی',
            importSongs,
          ),
        ],
      ),
    );
  }

  Widget _libraryTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) {
    return Card(
      color: surface,
      child: ListTile(
        onTap: action,
        leading: Icon(icon, color: purple),
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(color: muted)),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }

  Widget _miniPlayer() {
    final song = currentIndex >= 0 && currentIndex < songs.length
        ? songs[currentIndex]
        : null;

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note, color: purple, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  song?.name ?? 'آهنگی انتخاب نشده',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                onPressed: previousSong,
                icon: const Icon(Icons.skip_previous),
              ),
              IconButton(
                onPressed: loading ? null : togglePlayback,
                icon: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isPlaying ? Icons.pause_circle : Icons.play_circle,
                        color: purple,
                        size: 34,
                      ),
              ),
              IconButton(
                onPressed: nextSong,
                icon: const Icon(Icons.skip_next),
              ),
            ],
          ),
          Row(
            children: [
              Text(formatTime(position),
                  style: const TextStyle(fontSize: 11, color: muted)),
              Expanded(
                child: Slider(
                  value: duration.inMilliseconds == 0
                      ? 0
                      : position.inMilliseconds
                          .clamp(0, duration.inMilliseconds)
                          .toDouble(),
                  max: duration.inMilliseconds > 0
                      ? duration.inMilliseconds.toDouble()
                      : 1,
                  onChanged: duration.inMilliseconds == 0
                      ? null
                      : (value) {
                          player.seek(Duration(milliseconds: value.round()));
                        },
                ),
              ),
              Text(formatTime(duration),
                  style: const TextStyle(fontSize: 11, color: muted)),
            ],
          ),
        ],
      ),
    );
  }
}
