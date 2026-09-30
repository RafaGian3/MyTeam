import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myteam_project/main.dart';

/// Mengisi form login dengan data valid lalu menekan tombol Masuk.
/// Setelah itu menunggu loading Home (simulasi 2 detik) selesai.
Future<void> loginAndWaitHome(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());

  await tester.enterText(find.byType(TextFormField).at(0), '2311522001');
  await tester.enterText(find.byType(TextFormField).at(1), 'password123');

  final loginButton = find.text('Masuk ke MyTeam  →');
  await tester.ensureVisible(loginButton);
  await tester.tap(loginButton);
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login menampilkan pesan validasi untuk isian salah', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Selamat Datang di MyTeam'), findsOneWidget);

    final loginButton = find.text('Masuk ke MyTeam  →');
    await tester.ensureVisible(loginButton);

    // 1. kosong
    await tester.tap(loginButton);
    await tester.pump();
    expect(find.text('NIM atau email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    // 2 & 3. format salah
    await tester.enterText(find.byType(TextFormField).at(0), 'abc');
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.pump();
    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Password minimal 8 karakter'), findsOneWidget);

    // masih di halaman login
    expect(find.text('Selamat Datang di MyTeam'), findsOneWidget);
  });

  testWidgets('login valid pindah ke Home dan tidak bisa kembali ke Login', (tester) async {
    await loginAndWaitHome(tester);

    expect(find.text('Rekomendasi Tim'), findsOneWidget);
    expect(find.text('Selamat Datang di MyTeam'), findsNothing);
    await tester.scrollUntilVisible(find.text('Inovasi PKM-KC Unand'), 240, scrollable: find.byType(Scrollable).first);
    expect(find.text('Inovasi PKM-KC Unand'), findsOneWidget);
  });

  testWidgets('Home menampilkan loading lalu daftar tim', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.enterText(find.byType(TextFormField).at(0), '2311522001');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    final loginButton = find.text('Masuk ke MyTeam  →');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump(); // mulai transisi
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Memuat tim...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Memuat tim...'), findsNothing);
  });

  testWidgets('search memfilter tim berdasarkan field pencarian PRD', (tester) async {
    await loginAndWaitHome(tester);

    await tester.enterText(find.byType(TextField).last, 'hackathon');
    await tester.pump();

    await tester.scrollUntilVisible(find.text('Fintech Hackathon Syariah'), 240, scrollable: find.byType(Scrollable).first);
    expect(find.text('Fintech Hackathon Syariah'), findsOneWidget);
    expect(find.text('Inovasi PKM-KC Unand'), findsNothing);
  });

  testWidgets('Home -> Detail -> Form Catatan -> Detail (catatan tampil)', (tester) async {
    await loginAndWaitHome(tester);

    // Home -> Detail (data dikirim)
    final detailButton = find.text('Detail →').first;
    await tester.scrollUntilVisible(detailButton, 240, scrollable: find.byType(Scrollable).first);
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    expect(find.text('Inovasi PKM-KC Unand'), findsWidgets);
    expect(find.text('Belum ada catatan.'), findsOneWidget);

    // Detail -> Form Catatan
    final tulisButton = find.text('Tulis Catatan');
    await tester.ensureVisible(tulisButton);
    await tester.tap(tulisButton);
    await tester.pumpAndSettle();

    // validasi form
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Catatan wajib diisi'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.pump();
    expect(find.text('Catatan minimal 5 karakter'), findsOneWidget);

    // simpan -> kembali ke Detail membawa teks
    await tester.enterText(find.byType(TextFormField), 'Catatan uji coba');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Catatan: Catatan uji coba'), findsOneWidget);
    expect(find.text('Catatan berhasil disimpan'), findsOneWidget);
  });

  testWidgets('route tidak terdaftar menampilkan halaman 404', (tester) async {
    await tester.pumpWidget(const MyApp());

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed('/tidak-ada');
    await tester.pumpAndSettle();

    expect(find.text('404'), findsOneWidget);
    expect(find.text('Halaman Tidak Ditemukan'), findsOneWidget);
  });
}
