import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ok11/app/theme/app_colors.dart';
import 'package:ok11/app/theme/app_text_styles.dart';

class TeamAvatarWidget extends StatelessWidget {
  static Color _getTeamColor(String teamName) {
    final hash = teamName.hashCode;
    final random = Random(hash);
    return Color.fromRGBO(
      random.nextInt(200) + 50,
      random.nextInt(200) + 50,
      random.nextInt(200) + 50,
      1.0,
    );
  }

  final String teamName;
  final String? imageUrl;
  final double size;
  final double fontSize;

  const TeamAvatarWidget({
    super.key,
    required this.teamName,
    this.imageUrl,
    this.size = 64,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedTeamName = teamName.trim();
    final teamColor = _getTeamColor(normalizedTeamName);

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                teamColor.withValues(alpha: 0.1),
                teamColor.withValues(alpha: 0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            border: Border.all(
              color: teamColor.withValues(alpha: 0.3),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: teamColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return Text(
                          normalizedTeamName.isNotEmpty
                              ? normalizedTeamName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.headline2.copyWith(
                            fontSize: fontSize,
                            color: teamColor,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                      placeholder: (context, url) {
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              teamColor,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    normalizedTeamName.isNotEmpty
                        ? normalizedTeamName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.headline2.copyWith(
                      fontSize: fontSize,
                      color: teamColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          normalizedTeamName.isNotEmpty ? normalizedTeamName : 'Team',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
