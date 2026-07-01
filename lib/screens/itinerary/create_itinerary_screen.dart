import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:titik_temu/providers/auth_provider.dart';
import 'package:titik_temu/providers/itinerary_provider.dart';
import 'package:titik_temu/screens/itinerary/select_places_screen.dart';
import 'package:intl/intl.dart';

// Formatter untuk menambahkan titik pemisah ribuan secara otomatis
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Hapus semua karakter selain angka
    final cleanText = newValue.text.replaceAll('.', '');
    if (cleanText.isEmpty) return newValue.copyWith(text: '');

    // Format dengan titik ribuan
    final formatted = NumberFormat(
      '#,###',
      'id_ID',
    ).format(int.parse(cleanText));
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CreateItineraryScreen extends StatefulWidget {
  const CreateItineraryScreen({super.key});

  @override
  State<CreateItineraryScreen> createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final _titleController = TextEditingController();
  final _cityController = TextEditingController();
  final _budgetController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  int _travelersCount = 1;

  // Warna tema utama
  static const _gradientStart = Color(0xFF8E2DE2);
  static const _gradientEnd = Color(0xFF4A00E0);

  Future<void> _pickDateRange() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;
    final themeCardColor = Theme.of(context).cardColor;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: themePrimary,
                    onPrimary: Colors.deepPurple[900]!,
                    secondary: themePrimary.withValues(alpha: 0.15),
                    onSecondary: themePrimary,
                    surface: themeCardColor,
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: themePrimary,
                    onPrimary: Colors.white,
                    secondary: const Color(0xFFF3E5F5),
                    onSecondary: themePrimary,
                    surface: themeCardColor,
                    onSurface: const Color(0xFF1E1E2C),
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: themePrimary),
            ),
            dialogTheme: const DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _continueToSelectPlaces() async {
    final title = _titleController.text.trim();
    final city = _cityController.text.trim();
    // Hapus titik ribuan sebelum parsing
    final budgetStr = _budgetController.text.trim().replaceAll('.', '');

    if (title.isEmpty ||
        city.isEmpty ||
        budgetStr.isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tolong lengkapi semua data!')),
      );
      return;
    }

    final double? budget = double.tryParse(budgetStr);
    if (budget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anggaran harus berupa angka!')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login terlebih dahulu.')),
      );
      return;
    }

    // Arahkan ke halaman pemilihan tempat manual
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectPlacesScreen(
          title: title,
          city: city,
          startDate: _startDate!,
          endDate: _endDate!,
          budget: budget,
          travelersCount: _travelersCount,
        ),
      ),
    );
  }

  // Widget kotak tanggal Berangkat / Pulang
  Widget _buildDateBox({
    required String label,
    required DateTime? date,
    required bool isStart,
  }) {
    final bool isSelected = date != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    return Expanded(
      child: GestureDetector(
        onTap: _pickDateRange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? themePrimary.withValues(alpha: 0.15)
                      : const Color(0xFFF3E5F5))
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? themePrimary
                  : (isDark ? Colors.grey[850]! : Colors.grey[300]!),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themePrimary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isStart
                        ? Icons.flight_takeoff_rounded
                        : Icons.flight_land_rounded,
                    size: 14,
                    color: isSelected ? themePrimary : Colors.grey[500],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? themePrimary : Colors.grey[500],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isSelected
                    ? DateFormat('EEE, dd MMM yyyy').format(date)
                    : 'Pilih Tanggal',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget input field elegan
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    String? prefix,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: themePrimary, size: 22),
        prefixText: prefix,
        prefixStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: themePrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hitung durasi perjalanan
    int tripDays = 0;
    if (_startDate != null && _endDate != null) {
      tripDays = _endDate!.difference(_startDate!).inDays + 1;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[850]! : Colors.transparent,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Rencana',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Header Banner ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_gradientStart, _gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rencanakan Liburanmu',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Isi detail perjalanan dan biarkan AI menyusun rutenya!',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --- Detail Perjalanan ---
            const Text(
              'Detail Perjalanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _titleController,
              label: 'Nama Perjalanan',
              icon: Icons.luggage_rounded,
              capitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _cityController,
              label: 'Kota Tujuan',
              icon: Icons.location_city_rounded,
              capitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            // --- Chip Kota Populer ---
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    '🏔️ Yogyakarta',
                    '🌊 Bali',
                    '🌆 Jakarta',
                    '⛰️ Bandung',
                    '🏝️ Lombok',
                    '🌿 Labuan Bajo',
                    '🦧 Borneo',
                    '🌺 Makassar',
                    '🏕️ Raja Ampat',
                  ].map((kota) {
                    final namaKota = kota.substring(kota.indexOf(' ') + 1);
                    final isSelected = _cityController.text == namaKota;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _cityController.text = namaKota;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? themePrimary
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? themePrimary
                                : (isDark
                                      ? Colors.grey[850]!
                                      : Colors.grey[300]!),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: themePrimary.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          kota,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? (isDark
                                      ? Colors.deepPurple[900]
                                      : Colors.white)
                                : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[700]),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 28),

            // --- Tanggal Perjalanan ---
            const Text(
              'Tanggal Perjalanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            // Dua Kotak Berangkat & Pulang
            Row(
              children: [
                _buildDateBox(
                  label: 'Berangkat',
                  date: _startDate,
                  isStart: true,
                ),
                const SizedBox(width: 12),
                _buildDateBox(label: 'Pulang', date: _endDate, isStart: false),
              ],
            ),
            const SizedBox(height: 12),

            // Badge durasi perjalanan (muncul setelah tanggal dipilih)
            if (tripDays > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? themePrimary.withValues(alpha: 0.15)
                      : const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timelapse_rounded,
                      color: themePrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Durasi perjalanan: $tripDays hari',
                      style: TextStyle(
                        color: themePrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),

            // --- Jumlah Anggota Perjalanan ---
            const Text(
              'Jumlah Anggota Perjalanan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final count = index + 1;
                final isSelected = _travelersCount == count;
                final label = count == 5 ? '5+ Orang' : '$count Orang';
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _travelersCount = count;
                        // Recalculate default/recommended budget if empty or preset
                        final multiplier = _travelersCount;
                        final recommendedValue = 1000000 * multiplier;
                        _budgetController.text = NumberFormat('#,###', 'id_ID').format(recommendedValue);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 4,
                        right: index == 4 ? 0 : 4,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? themePrimary : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? themePrimary : (isDark ? Colors.grey[850]! : Colors.grey[300]!),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? (isDark ? Colors.deepPurple[900] : Colors.white)
                                : (isDark ? Colors.grey[400] : Colors.grey[700]),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),

            // --- Anggaran ---
            const Text(
              'Anggaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),

            _buildInputField(
              controller: _budgetController,
              label: 'Anggaran Maksimal',
              icon: Icons.account_balance_wallet_rounded,
              keyboardType: TextInputType.number,
              prefix: 'Rp ',
              inputFormatters: [_ThousandsSeparatorFormatter()],
            ),
            
            // Info Rekomendasi Budget Dinamis
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: themePrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Rekomendasi Anggaran ($_travelersCount orang): Rp ${NumberFormat('#,###', 'id_ID').format(500000 * _travelersCount)} - Rp ${NumberFormat('#,###', 'id_ID').format(1500000 * _travelersCount)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: themePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- Pilihan Anggaran Preset ---
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                500000,
                1000000,
                2000000,
                5000000,
                10000000,
                20000000
              ].map((baseValue) {
                final val = baseValue * _travelersCount;
                final formattedVal = NumberFormat('#,###', 'id_ID').format(val);
                final isSelected = _budgetController.text == formattedVal;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _budgetController.text = formattedVal;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _gradientEnd
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? _gradientEnd
                            : (isDark
                                  ? Colors.grey[850]!
                                  : Colors.grey[300]!),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _gradientEnd.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      'Rp $formattedVal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700]),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            // Tombol Simpan
            Consumer<ItineraryProvider>(
              builder: (context, provider, child) {
                return InkWell(
                  onTap: _continueToSelectPlaces,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_gradientStart, _gradientEnd],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _gradientEnd.withValues(
                            alpha: isDark ? 0.5 : 0.35,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LANJUT PILIH TEMPAT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _cityController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}
