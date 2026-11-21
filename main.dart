import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: Dashboard()));

class Dashboard extends StatefulWidget { const Dashboard({super.key}); @override State<Dashboard> createState() => _S(); }

class _S extends State<Dashboard> with WidgetsBindingObserver {
  static const ch = MethodChannel('reelmonster');
  Map s = {'ig': 0, 'yt': 0, 'sec': 0, 'level': 1, 'a11y': false, 'overlay': false};
  Timer? t;
  @override void initState() { super.initState(); WidgetsBinding.instance.addObserver(this); poll(); t = Timer.periodic(const Duration(seconds: 2), (_) => poll()); }
  @override void dispose() { t?.cancel(); super.dispose(); }
  Future<void> poll() async { final r = await ch.invokeMethod('stats'); if (mounted) setState(() => s = r as Map); }
  static const names = ['Tiny Baby', 'Curious', 'Excited', 'Big', 'Huge', 'Giant'];
  Widget card(String title, String val, {Color c = Colors.white}) => Expanded(child: Container(
    margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(24)),
    child: Column(children: [Text(val, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF6B46C1))), Text(title, style: const TextStyle(color: Colors.black54))])));
  Widget btn(String l, String m, {bool done = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: SizedBox(width: double.infinity,
    child: FilledButton(style: FilledButton.styleFrom(backgroundColor: done ? Colors.green.shade300 : const Color(0xFF9F7AEA), padding: const EdgeInsets.all(14)),
      onPressed: () async { await ch.invokeMethod(m); poll(); }, child: Text(done ? '✓ $l' : l))));
  @override Widget build(BuildContext c) {
    final total = (s['ig'] as int) + (s['yt'] as int); final mins = ((s['sec'] as int) / 60).round(); final lv = s['level'] as int;
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE9D8FD), Color(0xFFFBCFE8), Color(0xFFFFF7ED)])),
      child: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        const Center(child: Text('👾 Reel Monster', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF553C9A)))),
        const SizedBox(height: 16),
        Row(children: [card('Reels today', '$total', c: const Color(0xFFFFFFFF)), card('Level $lv', names[lv - 1])]),
        Row(children: [card('Instagram', '${s['ig']}'), card('YouTube', '${s['yt']}'), card('Minutes', '$mins')]),
        const SizedBox(height: 12),
        btn('Enable Accessibility Service', 'openAccessibility', done: s['a11y'] == true),
        btn('Allow floating overlay', 'requestOverlay', done: s['overlay'] == true),
        btn('Show monster', 'startOverlay'), btn('Hide monster', 'stopOverlay'),
        const Padding(padding: EdgeInsets.all(12), child: Text('Detection is best-effort: it relies on Instagram/YouTube screen IDs and may miscount or stop working after app updates.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black45, fontSize: 12))),
      ]))));
  }
}
