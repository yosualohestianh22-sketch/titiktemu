import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TravelokaDatePickerDialog extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const TravelokaDatePickerDialog({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<TravelokaDatePickerDialog> createState() => _TravelokaDatePickerDialogState();
}

class _TravelokaDatePickerDialogState extends State<TravelokaDatePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  late List<DateTime> _months;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    // Hasilkan daftar bulan: bulan ini + 11 bulan ke depan
    final now = DateTime.now();
    _months = List.generate(12, (index) {
      return DateTime(now.year, now.month + index, 1);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onDayTap(DateTime day) {
    if (day.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      return; // Tidak bisa memilih hari kemarin
    }

    setState(() {
      if (_startDate == null) {
        _startDate = day;
        _endDate = null;
      } else if (_endDate == null) {
        if (day.isBefore(_startDate!)) {
          _startDate = day;
        } else if (day.isAfter(_startDate!)) {
          _endDate = day;
        } else {
          // Klik tanggal yang sama, reset
          _startDate = null;
        }
      } else {
        // Sudah ada keduanya, mulai seleksi baru
        _startDate = day;
        _endDate = null;
      }
    });
  }

  bool _isDaySelected(DateTime day) {
    if (_startDate != null && _isSameDay(_startDate!, day)) return true;
    if (_endDate != null && _isSameDay(_endDate!, day)) return true;
    return false;
  }

  bool _isDayInRange(DateTime day) {
    if (_startDate == null || _endDate == null) return false;
    return day.isAfter(_startDate!) && day.isBefore(_endDate!);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const travelokaGreen = Color(0xFF38972E);

    final showConfirmButton = _startDate != null && _endDate != null;
    int totalNights = 0;
    if (showConfirmButton) {
      totalNights = _endDate!.difference(_startDate!).inDays;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A14) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16162A) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pilih Tanggal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [

          // 2. Row Info Berangkat & Pulang ala Traveloka
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF0F0E17) : const Color(0xFFF9FAFB),
            child: Row(
              children: [
                // Box Berangkat
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16162A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _startDate != null
                            ? travelokaGreen
                            : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                        width: _startDate != null ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Berangkat',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _startDate != null
                              ? DateFormat('EEE, d MMM yyyy', 'id_ID').format(_startDate!)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _startDate != null
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Box Pulang
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16162A) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _endDate != null
                            ? travelokaGreen
                            : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                        width: _endDate != null ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pulang',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _endDate != null
                              ? DateFormat('EEE, d MMM yyyy', 'id_ID').format(_endDate!)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _endDate != null
                                ? (isDark ? Colors.white : Colors.black87)
                                : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Grid Header Hari (Sen - Min, Minggu Merah)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: isDark ? const Color(0xFF16162A) : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDayHeader('Sen', false, isDark),
                _buildDayHeader('Sel', false, isDark),
                _buildDayHeader('Rab', false, isDark),
                _buildDayHeader('Kam', false, isDark),
                _buildDayHeader('Jum', false, isDark),
                _buildDayHeader('Sab', false, isDark),
                _buildDayHeader('Min', true, isDark), // Hari Minggu Merah
              ],
            ),
          ),

          // Divider tipis
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? Colors.grey[850]! : Colors.grey[200]!,
          ),

          // 4. List Kalender Vertikal
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _months.length,
              itemBuilder: (context, index) {
                return _buildMonthSection(_months[index], isDark);
              },
            ),
          ),

          // 5. Bottom Navigation Confirmation Bar
          if (showConfirmButton)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16162A) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalNights Malam Perjalanan',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${DateFormat('d MMM', 'id_ID').format(_startDate!)} - ${DateFormat('d MMM yyyy', 'id_ID').format(_endDate!)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,
                          DateTimeRange(start: _startDate!, end: _endDate!),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: travelokaGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Pilih Tanggal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(String label, bool isSunday, bool isDark) {
    return SizedBox(
      width: 40,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSunday
                ? Colors.red
                : (isDark ? Colors.grey[300] : Colors.grey[700]),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSection(DateTime monthDateTime, bool isDark) {
    final year = monthDateTime.year;
    final month = monthDateTime.month;
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(monthDateTime);

    // Hitung jumlah hari di bulan ini
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Hari pertama dalam seminggu (1 = Sen, ..., 7 = Min)
    final firstDayWeekday = DateTime(year, month, 1).weekday;
    // Offset untuk grid jika minggu dimulai dari hari Senin (index 0 = Sen, ..., 6 = Min)
    final offset = (firstDayWeekday - 1) % 7;

    List<Widget> dayWidgets = [];

    // Tambah slot kosong sebelum tanggal 1
    for (int i = 0; i < offset; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // Tambah tanggal
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDayDateTime = DateTime(year, month, day);
      final isPast = currentDayDateTime.isBefore(today);
      final weekdayIndex = (offset + day - 1) % 7;
      final isSunday = weekdayIndex == 6; // Kolom paling kanan adalah hari Minggu

      final isSelected = _isDaySelected(currentDayDateTime);
      final isInRange = _isDayInRange(currentDayDateTime);

      final isStartEndpoint = _startDate != null && _isSameDay(_startDate!, currentDayDateTime);
      final isEndEndpoint = _endDate != null && _isSameDay(_endDate!, currentDayDateTime);

      BoxDecoration? cellDecoration;
      TextStyle textStyle = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isPast
            ? (isDark ? Colors.grey[800] : Colors.grey[300])
            : (isSunday
                ? Colors.red
                : (isDark ? Colors.white : Colors.black87)),
      );

      const travelokaGreen = Color(0xFF38972E);
      const travelokaLightGreen = Color(0xFFE8F5E9);

      if (isSelected) {
        cellDecoration = const BoxDecoration(
          color: travelokaGreen,
          shape: BoxShape.circle,
        );
        textStyle = const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        );
      } else if (isInRange) {
        cellDecoration = BoxDecoration(
          color: isDark ? const Color(0xFF1B3B24) : travelokaLightGreen,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(day == 1 || weekdayIndex == 0 ? 20 : 0),
            bottomLeft: Radius.circular(day == 1 || weekdayIndex == 0 ? 20 : 0),
            topRight: Radius.circular(day == daysInMonth || weekdayIndex == 6 ? 20 : 0),
            bottomRight: Radius.circular(day == daysInMonth || weekdayIndex == 6 ? 20 : 0),
          ),
        );
        textStyle = TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF81C784) : travelokaGreen,
        );
      }

      Widget cellChild = Center(
        child: Text(
          '$day',
          style: textStyle,
        ),
      );

      // Tambahkan efek sambungan hijau di pinggir endpoint jika rentang terpilih
      if (isInRange || isSelected) {
        if (_startDate != null && _endDate != null) {
          double leftRadius = 0;
          double rightRadius = 0;
          
          if (isStartEndpoint) {
            rightRadius = 20;
          } else if (isEndEndpoint) {
            leftRadius = 20;
          }
          
          // Render jembatan background hijau muda di belakang endpoint bulat
          cellChild = Stack(
            alignment: Alignment.center,
            children: [
              if (isStartEndpoint || isEndEndpoint)
                Container(
                  height: 40,
                  margin: EdgeInsets.only(
                    left: isEndEndpoint ? 0 : 20,
                    right: isStartEndpoint ? 0 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1B3B24) : travelokaLightGreen,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(leftRadius),
                      bottomLeft: Radius.circular(leftRadius),
                      topRight: Radius.circular(rightRadius),
                      bottomRight: Radius.circular(rightRadius),
                    ),
                  ),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: cellDecoration,
                child: Center(
                  child: Text(
                    '$day',
                    style: textStyle,
                  ),
                ),
              ),
            ],
          );
        } else {
          cellChild = Container(
            width: 40,
            height: 40,
            decoration: cellDecoration,
            child: cellChild,
          );
        }
      } else {
        cellChild = Container(
          width: 40,
          height: 40,
          decoration: cellDecoration,
          child: cellChild,
        );
      }

      dayWidgets.add(
        GestureDetector(
          onTap: isPast ? null : () => _onDayTap(currentDayDateTime),
          behavior: HitTestBehavior.opaque,
          child: cellChild,
        ),
      );
    }

    // Hitung jumlah baris yang dibutuhkan
    final totalCells = dayWidgets.length;
    final rowCount = (totalCells / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              monthName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Column(
            children: List.generate(rowCount, (rowIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (colIndex) {
                    final cellIndex = rowIndex * 7 + colIndex;
                    if (cellIndex < totalCells) {
                      return dayWidgets[cellIndex];
                    }
                    return const SizedBox(width: 40, height: 40);
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
