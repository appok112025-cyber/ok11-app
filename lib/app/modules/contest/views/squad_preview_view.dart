import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:ok11/app/data/models/match_data.dart';
import 'package:ok11/app/utils/player_utils.dart';
import 'package:ok11/app/utils/status_theme.dart';
import 'package:ok11/app/theme/app_colors.dart';

class SquadPreviewView extends StatelessWidget {
  final String userName;
  final String teamLabel; // e.g. "T1"
  final double totalPoints;
  final MatchData match;
  final List<PlayerInfo> players;
  final String? captainId;
  final String? viceCaptainId;

  SquadPreviewView({
    Key? key,
    required this.userName,
    this.teamLabel = 'T1',
    required this.totalPoints,
    required this.match,
    required this.players,
    this.captainId,
    this.viceCaptainId,
  }) : super(key: key);

  final GlobalKey _repaintKey = GlobalKey();

  Future<void> _captureAndDownloadImage() async {
    try {
      // 1. Capture the repaint boundary
      final RenderRepaintBoundary? boundary =
          _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar(
          'Capture Error',
          'Could not capture the preview layout.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
        );
        return;
      }

      // Convert to ui.Image at high resolution
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // 2. Save the image to the device's storage
      String? path;
      if (Platform.isAndroid) {
        final dir = Directory('/storage/emulated/0/Download');
        if (await dir.exists()) {
          path = '${dir.path}/ok11_squad_${DateTime.now().millisecondsSinceEpoch}.png';
        } else {
          path = '/sdcard/Download/ok11_squad_${DateTime.now().millisecondsSinceEpoch}.png';
        }
      } else {
        path = 'ok11_squad_${DateTime.now().millisecondsSinceEpoch}.png';
      }

      final file = File(path);
      await file.writeAsBytes(pngBytes);

      // 3. Show gorgeous success dialog
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Download Complete',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F1923),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The squad layout image has been successfully downloaded and saved directly to your device\'s downloads folder.',
                style: TextStyle(fontSize: 14, color: Color(0xFF0F1923), height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved Path:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      path,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('AWESOME'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('❌ Error saving squad image: $e');
      Get.snackbar(
        'Download Failed',
        'Unable to save image to storage: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group players by role
    final wks = players.where((p) => p.role == PlayerRole.wk).toList();
    final bats = players.where((p) => p.role == PlayerRole.bat).toList();
    final ars = players.where((p) => p.role == PlayerRole.ar).toList();
    final bowls = players.where((p) => p.role == PlayerRole.bowl).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF143F23), // Premium dark green stadium color
      body: Stack(
        children: [
          // ── REPAINT BOUNDARY (Full Screen capturing both background & players) ──
          RepaintBoundary(
            key: _repaintKey,
            child: Stack(
              children: [
                // Solid background color inside the RepaintBoundary so it gets captured in downloads
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFF143F23),
                  ),
                ),

                // 1. Cricket Field Ground Grass Background (Perfect Square in the Center)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Image.asset(
                        'assets/images/ground.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

                // Subdued field overlay to make player names pop
                Container(
                  color: Colors.black.withValues(alpha: 0.15),
                ),

                // 2. Main Layout Tree (Takes up the entire full screen height!)
                SafeArea(
                  child: Column(
                    children: [
                      // Translucent header
                      _buildFieldHeader(),

                      // Cricket Grid Spacers
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: _buildSquadGrid(players),
                        ),
                      ),

                      // Translucent footer showing Teams
                      _buildFieldFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── FLOATING DOWNLOAD BUTTON ──
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: _captureAndDownloadImage,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F1923),
              elevation: 4,
              icon: const Icon(Icons.download_rounded, color: Colors.green),
              label: const Text(
                'DOWNLOAD SQUAD',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
              ),
            ),
          ),

          // ── APPBAR CLOSE BUTTON ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(68, 16, 24, 16),
      color: Colors.black38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      userName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        teamLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${totalPoints.toStringAsFixed(1)} Pts',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white10,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Text(
              'PTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.black38,
      child: Center(
        child: Text(
          '${match.team1.toUpperCase()}  vs  ${match.team2.toUpperCase()}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSquadGrid(List<PlayerInfo> players) {
    final capInfo = players.firstWhereOrNull((p) => p.id == captainId);
    final vcInfo = players.firstWhereOrNull((p) => p.id == viceCaptainId);

    // Row 1: Captain & Vice-Captain
    final List<PlayerInfo> row1 = [];
    if (capInfo != null) row1.add(capInfo);
    if (vcInfo != null) row1.add(vcInfo);

    // Get all remaining players
    final allRemaining = players.where((p) => p.id != captainId && p.id != viceCaptainId).toList();
    
    // Fallback: If row1 doesn't have 2 players (e.g. invalid selection data), pull from list
    while (row1.length < 2 && allRemaining.isNotEmpty) {
      row1.add(allRemaining.removeAt(0));
    }

    // Rows 2, 3, 4: Divide remaining 9 players into 3 rows of 3 players each
    final List<PlayerInfo> row2 = [];
    final List<PlayerInfo> row3 = [];
    final List<PlayerInfo> row4 = [];

    for (int i = 0; i < allRemaining.length; i++) {
      if (i < 3) {
        row2.add(allRemaining[i]);
      } else if (i < 6) {
        row3.add(allRemaining[i]);
      } else {
        row4.add(allRemaining[i]);
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildRowWrapper(row1),
        _buildRowWrapper(row2),
        _buildRowWrapper(row3),
        _buildRowWrapper(row4),
      ],
    );
  }

  Widget _buildRowWrapper(List<PlayerInfo> list) {
    if (list.isEmpty) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list.map((p) {
        final isCap = captainId == p.id;
        final isVc = viceCaptainId == p.id;
        final pPoints = match.playerPoints[p.id] ?? 0.0;
        final isDt = match.status != MatchStatus.upcoming && pPoints >= 80;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildPlayerItem(p, isCap, isVc, isDt, pPoints),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerItem(PlayerInfo pInfo, bool isCap, bool isVc, bool isDt, double pPoints) {
    final isTeam1 = pInfo.teamName == match.team1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Headshot or team color jersey avatar circle
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isTeam1 
                    ? const Color(0xFF1E3A8A) // Team A: Premium Dark Blue
                    : const Color(0xFFC2410C), // Team B: Premium Dark Orange
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: pInfo.imageUrl != null && pInfo.imageUrl!.isNotEmpty
                    ? Image.network(
                        pInfo.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Center(
                          child: Icon(Icons.person, color: Colors.white70, size: 28),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.person, color: Colors.white70, size: 28),
                      ),
              ),
            ),

            // Captain / Vice-Captain badge on Top-Left
            if (isCap || isVc)
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    isCap ? 'C' : 'VC',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

            // DT Gold Shield Badge on Bottom-Right
            if (isDt)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    'DT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 6),

        // Name Pill (White container with dark text)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            pInfo.name,
            style: const TextStyle(
              color: Color(0xFF0F1923),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 4),

        // Points Pill (Solid dark contrast container for 100% readability)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            match.status != MatchStatus.upcoming
                ? '${pPoints.toStringAsFixed(1)} Pts'
                : '${pInfo.credits} Cr',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
