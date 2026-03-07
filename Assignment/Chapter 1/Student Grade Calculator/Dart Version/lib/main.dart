import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/providers/grade_calculator_controller.dart';
import 'features/import/ui/import_panel.dart';
import 'features/results/ui/results_dashboard.dart';

void main() {
  runApp(const ProviderScope(child: GradeCalcApp()));
}

class GradeCalcApp extends StatelessWidget {
  const GradeCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.light(useMaterial3: true);
    final bodyText = GoogleFonts.manropeTextTheme(base.textTheme);

    return MaterialApp(
      title: 'Student Grade Calculator (Dart)',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFFF7F1E7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF18314F),
          secondary: Color(0xFFB8743C),
          tertiary: Color(0xFF24706A),
          surface: Color(0xFFFFFCF6),
          onSurface: Color(0xFF16212E),
          onPrimary: Colors.white,
        ),
        textTheme: bodyText.copyWith(
          displaySmall: GoogleFonts.cormorantGaramond(
            fontSize: 54,
            fontWeight: FontWeight.w700,
            height: 0.95,
            letterSpacing: -1.2,
          ),
          headlineLarge: GoogleFonts.cormorantGaramond(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
          headlineMedium: GoogleFonts.cormorantGaramond(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          headlineSmall: GoogleFonts.cormorantGaramond(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
          titleLarge: bodyText.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          bodyLarge: bodyText.bodyLarge?.copyWith(
            color: const Color(0xFF374151),
            height: 1.55,
          ),
          bodyMedium: bodyText.bodyMedium?.copyWith(
            color: const Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            backgroundColor: const Color(0xFF18314F),
            foregroundColor: Colors.white,
            textStyle: bodyText.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            foregroundColor: const Color(0xFF18314F),
            side: const BorderSide(color: Color(0xFF18314F), width: 1.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFFFFFCF6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          shadowColor: const Color(0x1E1A2742),
          margin: EdgeInsets.zero,
        ),
      ),
      home: const GradeCalcHomePage(),
    );
  }
}

class GradeCalcHomePage extends ConsumerWidget {
  const GradeCalcHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gradeCalculatorProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5EFE3), Color(0xFFF8F4EC), Color(0xFFECE9E3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _Backdrop(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1220),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _RevealIn(
                          verticalOffset: 28,
                          child: _HeroHeader(),
                        ),
                        const SizedBox(height: 20),
                        const _RevealIn(
                          verticalOffset: 20,
                          child: ImportPanel(),
                        ),
                        const SizedBox(height: 18),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 650),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInOut,
                          child: ResultsDashboard(
                            key: ValueKey(
                              state.report?.summary.totalRows ?? -1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state.loading)
                Container(
                  color: const Color(0xCCF7F1E7),
                  child: const Center(
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Color(0xFF18314F),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -60,
          child: _orb(
            size: 260,
            colors: [const Color(0x4CB8743C), const Color(0x00B8743C)],
          ),
        ),
        Positioned(
          top: 120,
          right: -70,
          child: _orb(
            size: 280,
            colors: [const Color(0x5524706A), const Color(0x0024706A)],
          ),
        ),
        Positioned(
          bottom: -70,
          left: 140,
          child: _orb(
            size: 220,
            colors: [const Color(0x5518314F), const Color(0x0018314F)],
          ),
        ),
        Positioned(
          top: 90,
          left: 40,
          child: Transform.rotate(
            angle: -0.14,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(42),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _orb({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [Color(0xFF10233A), Color(0xFF1A3550), Color(0xFF29556D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29132435),
            blurRadius: 40,
            offset: Offset(0, 24),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 880;
          final textColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroChip(
                icon: Icons.auto_awesome_rounded,
                label: 'Student Grade Calculator',
              ),
              const SizedBox(height: 18),
              Text(
                'Student Grade\nCalculator',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'Import CSV or XLSX files, calculate grades, review the results, and export the final report.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFE7EEF7),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _HeroPill(title: 'Input', value: 'CSV and XLSX files'),
                  _HeroPill(title: 'Output', value: 'Summary and Excel report'),
                  _HeroPill(title: 'Pass Mark', value: '65 and above'),
                ],
              ),
            ],
          );

          final spotlight = Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Notes',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The app checks each row, calculates the final mark, and lists any missing or invalid data before export.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE3ECF6),
                  ),
                ),
                const SizedBox(height: 16),
                const _HeroMetric(
                  label: 'Main Sheets',
                  value: 'Grades, summary, issues, chart',
                ),
                const SizedBox(height: 10),
                const _HeroMetric(
                  label: 'Rule Used',
                  value: 'Invalid rows are marked X',
                ),
              ],
            ),
          );

          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [textColumn, const SizedBox(height: 18), spotlight],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: textColumn),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: spotlight),
            ],
          );
        },
      ),
    );
  }

  Widget _heroChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFB8743C).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x40FFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFF6D0A7), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 176),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD5E4F2),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.keyboard_double_arrow_right_rounded,
            color: Color(0xFFF6D0A7),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color(0xFFD7E3EF), fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RevealIn extends StatelessWidget {
  const _RevealIn({required this.child, this.verticalOffset = 18});

  final Widget child;
  final double verticalOffset;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 820),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * verticalOffset),
            child: child,
          ),
        );
      },
    );
  }
}
