import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/finance_provider.dart';
import '../utils/number_formatter.dart';
import '../models/insight.dart'; // <-- Importar el nuevo modelo

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final financeProvider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme),
              const SizedBox(height: 24),
              _buildBalanceCard(financeProvider, theme),
              const SizedBox(height: 24),
              _buildSpendingFlows(
                financeProvider,
                theme,
              ), // <-- Pasa el provider
              const SizedBox(height: 24),
              _buildSmartInsights(
                financeProvider,
                theme,
              ), // <-- Pasa el provider
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person, color: theme.colorScheme.primary),
        ),
        Text(
          'Buenos días, Jair', // Esto puede volverse dinámico más adelante
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Próximamente: Notificaciones')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceCard(FinanceProvider provider, ThemeData theme) {
    final todayChange = provider.todayChange;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance Total',
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormatter.formatCurrency(provider.balance),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                todayChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                color: todayChange >= 0
                    ? Colors.lightGreenAccent
                    : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${todayChange >= 0 ? '+' : ''}${NumberFormatter.formatCurrency(todayChange)} hoy',
                style: GoogleFonts.inter(
                  color: todayChange >= 0
                      ? Colors.lightGreenAccent
                      : Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- MÉTODO COMPLETAMENTE DINÁMICO ---
  Widget _buildSpendingFlows(FinanceProvider provider, ThemeData theme) {
    final expensesByCategory = provider.expensesByCategory;
    final totalExpenses = provider.totalExpenses;

    if (expensesByCategory.isEmpty) {
      return _buildEmptySection(
        'Tus Flujos de Gasto',
        'No hay gastos para mostrar en el período actual.',
        theme,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tus Flujos de Gasto',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: expensesByCategory.entries.map((entry) {
              final category = entry.key;
              final amount = entry.value;
              final percent = totalExpenses > 0 ? amount / totalExpenses : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.category,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          category.toString().split('.').last,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          NumberFormatter.formatCurrency(amount),
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 60,
                          height: 8,
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // --- MÉTODO QUE CONSUME LOS INSIGHTS GENERADOS ---
  Widget _buildSmartInsights(FinanceProvider provider, ThemeData theme) {
    final insights = provider.insights;

    if (insights.isEmpty) {
      return _buildEmptySection(
        'Insights Inteligentes',
        'Sigue usando la app para recibir consejos personalizados sobre tus finanzas.',
        theme,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights Inteligentes',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...insights.map(
          (insight) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _InsightCard(
              icon: insight.icon,
              iconColor: insight.iconColor,
              title: insight.title,
              description: insight.description,
              theme: theme,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySection(String title, String message, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 48,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: GoogleFonts.inter(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final ThemeData theme;

  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
