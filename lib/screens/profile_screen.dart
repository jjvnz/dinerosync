import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileHeader(theme),
            const SizedBox(height: 32),
            _buildSettingsSection(theme, 'Cuenta', [
              _SettingsItem(
                icon: Icons.person,
                title: 'Información Personal',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.notifications,
                title: 'Notificaciones',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsSection(theme, 'Preferencias', [
              _SettingsItem(
                icon: Icons.brightness_6,
                title: 'Tema',
                onTap: () => _showThemeSelector(context),
              ),
              _SettingsItem(
                icon: Icons.attach_money,
                title: 'Moneda',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            _buildSettingsSection(theme, 'Soporte', [
              _SettingsItem(
                icon: Icons.info,
                title: 'Acerca de',
                onTap: () => _showAboutDialog(context),
              ),
              _SettingsItem(
                icon: Icons.star,
                title: 'Calificar App',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showSignOutDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cerrar Sesión',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
        ),
        const SizedBox(height: 16),
        Text(
          'Jair',
          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          'jair@example.com',
          style: GoogleFonts.inter(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    ThemeData theme,
    String title,
    List<_SettingsItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: items
                .map((item) => _buildSettingsItemTile(item, theme))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItemTile(_SettingsItem item, ThemeData theme) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(item.title, style: GoogleFonts.inter()),
      trailing: const Icon(Icons.chevron_right),
      onTap: item.onTap,
    );
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seleccionar Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Claro'),
              leading: Icon(
                Theme.of(context).brightness == Brightness.light
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                // Implement theme change here
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Oscuro'),
              leading: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              onTap: () {
                // Implement theme change here
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Dinerosync',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 48),
      children: [
        Text(
          'Una app moderna para gestionar tus finanzas personales.',
          style: GoogleFonts.inter(),
        ),
      ],
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Implement sign out logic here
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
            },
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _SettingsItem({required this.icon, required this.title, required this.onTap});
}


