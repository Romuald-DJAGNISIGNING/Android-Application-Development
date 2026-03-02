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

    return MaterialApp(
      title: 'Student Grade Calculator (Dart)',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0E5A8A),
          secondary: Color(0xFF1C8D74),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF0F172A),
          onPrimary: Colors.white,
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
            colors: [Color(0xFF091B34), Color(0xFF2E5C87), Color(0xFF65A5D3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -50,
                left: -60,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                right: -40,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9CE7D4).withValues(alpha: 0.22),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroHeader(),
                      const SizedBox(height: 20),
                      const ImportPanel(),
                      const SizedBox(height: 16),
                      const ResultsDashboard(),
                    ],
                  ),
                ),
              ),
              if (state.loading)
                Container(
                  color: Colors.black.withValues(alpha: 0.22),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Grade Calculator',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Built for class demos: fast processing, strict validation, and clean report export.',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFB8F0E3).withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Offline | CSV + XLSX | Issue Log + Charts',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
