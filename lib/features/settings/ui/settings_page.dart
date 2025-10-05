import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../ui/theme/app_theme.dart';
import '../domain/app_info.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';
import 'legal_notice_page.dart';
import 'faq_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: _CenteredBody(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: context.spacing.x4),
          children: [
            // App Info Section
            _SectionHeader(title: '앱 정보'),
            _InfoTile(
              title: '버전',
              subtitle: AppInfo.fullVersion,
              icon: Icons.info_outline,
            ),
            _InfoTile(
              title: '마지막 업데이트',
              subtitle: AppInfo.lastUpdated,
              icon: Icons.update,
            ),
            _ActionTile(
              title: '라이선스',
              icon: Icons.article_outlined,
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: AppInfo.appName,
                  applicationVersion: AppInfo.fullVersion,
                );
              },
            ),
            SizedBox(height: context.spacing.x6),

            // Legal Section
            _SectionHeader(title: '법적 고지'),
            _ActionTile(
              title: '면책조항',
              icon: Icons.gavel,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LegalNoticePage(type: LegalNoticeType.disclaimer),
                  ),
                );
              },
            ),
            _ActionTile(
              title: '개인정보 처리방침',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LegalNoticePage(type: LegalNoticeType.privacy),
                  ),
                );
              },
            ),
            _ActionTile(
              title: '이용약관',
              icon: Icons.description_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LegalNoticePage(type: LegalNoticeType.terms),
                  ),
                );
              },
            ),
            SizedBox(height: context.spacing.x6),

            // Theme Settings
            _SectionHeader(title: '화면 설정'),
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return _ThemeSelectorTile(currentMode: state.mode);
              },
            ),
            SizedBox(height: context.spacing.x6),

            // Help & Support Section
            _SectionHeader(title: '도움말 및 지원'),
            _ActionTile(
              title: 'FAQ',
              icon: Icons.help_outline,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FAQPage()),
                );
              },
            ),
            _ActionTile(
              title: '사용 가이드',
              icon: Icons.menu_book_outlined,
              onTap: () {
                // TODO: Implement user guide
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('준비 중입니다')),
                );
              },
            ),
            _ActionTile(
              title: '피드백 보내기',
              icon: Icons.feedback_outlined,
              onTap: () => _sendFeedback(context),
            ),
            _ActionTile(
              title: 'HUG 공식 사이트',
              icon: Icons.open_in_new,
              onTap: () => _launchURL(AppInfo.hugWebsite),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFeedback(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: AppInfo.feedbackEmail,
      query: 'subject=전세자금대출 도우미 피드백',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 앱을 열 수 없습니다: ${AppInfo.feedbackEmail}')),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacing.x4,
        vertical: context.spacing.x2,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _ThemeSelectorTile extends StatelessWidget {
  final ThemeMode currentMode;

  const _ThemeSelectorTile({required this.currentMode});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.palette_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
      title: const Text('테마'),
      subtitle: Text(_getThemeModeLabel(currentMode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showThemeDialog(context),
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => '라이트',
      ThemeMode.dark => '다크',
      ThemeMode.system => '시스템 설정',
    };
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final result = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('테마 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('라이트'),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) => Navigator.pop(dialogContext, value),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('다크'),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) => Navigator.pop(dialogContext, value),
            ),
            RadioListTile<ThemeMode>(
              title: const Text('시스템 설정'),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) => Navigator.pop(dialogContext, value),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      context.read<ThemeBloc>().add(ThemeEvent.changed(result));
    }
  }
}

class _CenteredBody extends StatelessWidget {
  final Widget child;
  const _CenteredBody({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: child,
      ),
    );
  }
}
