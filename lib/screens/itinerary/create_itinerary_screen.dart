import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:titik_temu/providers/auth_provider.dart';
import 'package:titik_temu/providers/itinerary_provider.dart';
import 'package:titik_temu/screens/itinerary/select_places_screen.dart';
import 'package:titik_temu/screens/itinerary/traveloka_date_picker.dart';
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
  int _travelersCount = 2; // Default 2 Dewasa
  int _roomsCount = 1;
  int _adultsCount = 2;
  int _childrenCount = 0;

  // Warna tema utama (Vibrant & Glowing Indigo)
  static const _gradientStart = Color(0xFF818CF8);
  static const _gradientEnd = Color(0xFF4F46E5);

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showGeneralDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'TravelokaDatePicker',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return TravelokaDatePickerDialog(
          initialStartDate: _startDate,
          initialEndDate: _endDate,
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuad)),
          child: child,
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
          roomsCount: _roomsCount,
          adultsCount: _adultsCount,
          childrenCount: _childrenCount,
        ),
      ),
    );
  }

  // Widget kotak tanggal Berangkat / Pulang (Traveloka Style)
  Widget _buildDateBox({
    required String label,
    required DateTime? date,
    required bool isStart,
  }) {
    final bool isSelected = date != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themePrimary = Theme.of(context).primaryColor;

    String dayName = isStart ? 'Berangkat' : 'Pulang';
    String formattedDate = 'Pilih Tanggal';

    if (isSelected) {
      dayName = DateFormat('EEEE', 'id_ID').format(date); // e.g. Kamis
      formattedDate = DateFormat('dd MMM yyyy', 'id_ID').format(date); // e.g. 02 Jul 2026
    }

    return Expanded(
      child: GestureDetector(
        onTap: _pickDateRange,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? themePrimary.withValues(alpha: 0.1)
                      : const Color(0xFFF0F2FF))
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? themePrimary
                  : (isDark ? Colors.grey[850]! : Colors.grey[300]!),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themePrimary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                isStart
                    ? Icons.calendar_today_rounded
                    : Icons.calendar_month_rounded,
                size: 22,
                color: isSelected ? themePrimary : Colors.grey[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSelected ? '$label: $dayName' : label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? themePrimary : Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? (isDark ? Colors.white : const Color(0xFF1E293B))
                            : Colors.grey[400],
                      ),
                    ),
                  ],
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

            // --- Tamu & Kamar (Traveloka Style) ---
            const Text(
              'Tamu & Kamar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showGuestRoomBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      color: themePrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kapasitas & Jumlah Kamar',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[500],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$_roomsCount Kamar, $_adultsCount Dewasa, $_childrenCount Anak',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ],
                ),
              ),
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
                            'Lanjut Pilih Tempat',
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

  void _showGuestRoomBottomSheet() {
    const travelokaOrange = Color(0xFFFF5E1F);

    int tempRooms = _roomsCount;
    int tempAdults = _adultsCount;
    int tempChildren = _childrenCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Blue Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF02A2E6), // Traveloka Blue
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tambahkan Tamu & Kamar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Row Kamar
                  _buildCounterRow(
                    title: 'Kamar',
                    subtitle: null,
                    icon: Icons.meeting_room_rounded,
                    value: tempRooms,
                    onMinus: tempRooms > 1
                        ? () => setModalState(() => tempRooms--)
                        : null,
                    onPlus: tempRooms < 10
                        ? () => setModalState(() => tempRooms++)
                        : null,
                  ),
                  const Divider(indent: 20, endIndent: 20, height: 24),

                  // Row Dewasa
                  _buildCounterRow(
                    title: 'Dewasa',
                    subtitle: null,
                    icon: Icons.people_alt_rounded,
                    value: tempAdults,
                    onMinus: tempAdults > 1
                        ? () => setModalState(() => tempAdults--)
                        : null,
                    onPlus: tempAdults < 30
                        ? () => setModalState(() => tempAdults++)
                        : null,
                  ),
                  const Divider(indent: 20, endIndent: 20, height: 24),

                  // Row Anak
                  _buildCounterRow(
                    title: 'Anak',
                    subtitle: 'Maksimal 17 tahun',
                    icon: Icons.child_care_rounded,
                    value: tempChildren,
                    onMinus: tempChildren > 0
                        ? () => setModalState(() => tempChildren--)
                        : null,
                    onPlus: tempChildren < 20
                        ? () => setModalState(() => tempChildren++)
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Button Terapkan
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: travelokaOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _roomsCount = tempRooms;
                            _adultsCount = tempAdults;
                            _childrenCount = tempChildren;
                            _travelersCount = _adultsCount + _childrenCount;
                            
                            // Recalculate default/recommended budget if empty or preset
                            final recommendedValue = 1000000 * _travelersCount;
                            _budgetController.text = NumberFormat('#,###', 'id_ID').format(recommendedValue);
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text(
                          'Terapkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCounterRow({
    required String title,
    required String? subtitle,
    required IconData icon,
    required int value,
    required VoidCallback? onMinus,
    required VoidCallback? onPlus,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: isDark ? Colors.grey[300] : Colors.grey[700]),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ],
          ),
          Row(
            children: [
              // Button Minus
              GestureDetector(
                onTap: onMinus,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: onMinus != null
                        ? (isDark ? const Color(0xFF1F1F35) : Colors.grey[100])
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: onMinus != null
                          ? const Color(0xFF02A2E6)
                          : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 18,
                    color: onMinus != null
                        ? const Color(0xFF02A2E6)
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 24,
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Button Plus
              GestureDetector(
                onTap: onPlus,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: onPlus != null
                        ? (isDark ? const Color(0xFF1F1F35) : Colors.grey[100])
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: onPlus != null
                          ? const Color(0xFF02A2E6)
                          : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: onPlus != null
                        ? const Color(0xFF02A2E6)
                        : (isDark ? Colors.grey[700] : Colors.grey[300]),
                  ),
                ),
              ),
            ],
          ),
        ],
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
