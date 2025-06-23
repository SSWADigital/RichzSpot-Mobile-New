import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard Menu',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        // Menentukan warna soft purple untuk digunakan kembali
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.deepPurple.shade100.withOpacity(0.5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DashboardScreen(),
    );
  }
}

// Model MenuItem tidak berubah
class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final bool isPromo;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.isPromo = false,
  });
}

// --- PERUBAHAN: DashboardScreen menjadi StatefulWidget (tanpa TabController) ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State untuk melacak tombol/halaman yang aktif
  int _selectedIndex = 0;
  final List<String> _navTitles = ['Pilihan', 'Tagihan', 'Asuransi'];

  // Daftar widget untuk setiap halaman
  static const List<Widget> _pages = <Widget>[
    MenuPilihanGrid(),
    Center(child: Text('Halaman Tagihan', style: TextStyle(fontSize: 18, color: Colors.grey))),
    Center(child: Text('Halaman Asuransi', style: TextStyle(fontSize: 18, color: Colors.grey))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Utama'),
        centerTitle: true,
        // TabBar dihilangkan dari AppBar
      ),
      // Body sekarang berisi tombol navigasi dan konten halaman
      body: Column(
        children: [
          // Baris yang berisi tombol navigasi
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _navTitles.length,
                (index) => _buildNavButton(
                  index: index,
                  title: _navTitles[index],
                ),
              ),
            ),
          ),
          // Konten halaman yang berubah sesuai tombol yang aktif
          Expanded(
            child: _pages.elementAt(_selectedIndex),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk membangun setiap tombol navigasi
  Widget _buildNavButton({required int index, required String title}) {
    bool isSelected = _selectedIndex == index;

    return InkWell(
      // Hilangkan efek splash default karena sudah ada feedback dari perubahan warna
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        // Ubah state saat tombol ditekan
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Widget Grid dan Card di bawah sini tidak ada perubahan
class MenuPilihanGrid extends StatelessWidget {
  const MenuPilihanGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MenuItem> menuItems = [
      MenuItem(title: 'Pulsa', icon: Icons.phone_android, color: Colors.blue, isPromo: true),
      MenuItem(title: 'Paket Data', icon: Icons.wifi_tethering, color: Colors.green, isPromo: true),
      MenuItem(title: 'PLN', icon: Icons.flash_on, color: Colors.orange),
      MenuItem(title: 'Pajak PBB', icon: Icons.receipt_long, color: Colors.teal),
      MenuItem(title: 'U Card', icon: Icons.credit_card, color: Colors.deepPurple),
      MenuItem(title: 'Proteksi', icon: Icons.umbrella, color: Colors.purple),
      MenuItem(title: 'Invest', icon: Icons.trending_up, color: Colors.indigo),
      MenuItem(title: 'Internet & TV Kabel', icon: Icons.tv, color: Colors.redAccent),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: GridView.builder(
        // Scroll diaktifkan kembali jika kontennya panjang
        // physics: const NeverScrollableScrollPhysics(), 
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.85,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return MenuItemCard(item: menuItems[index]);
        },
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('${item.title} diklik!');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.title} dipilih')));
      },
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              if (item.isPromo)
                Positioned(
                  top: -5,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Promo', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}