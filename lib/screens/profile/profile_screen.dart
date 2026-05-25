import 'package:flutter/material.dart';
import 'package:registagrodriver/repositories/profile.dart';
import 'package:registagrodriver/screens/profile/profile_class.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final String? name;
  final String? email;
  final String? phone;
  final String? photo;
  final String? province;
  final String? adress;
  final String? balance;
  final String? totalTrip;

  const ProfileScreen({
    super.key,
    this.name,
    this.email,
    this.phone,
    this.photo,
    this.province,
    this.adress,
    this.balance,
    this.totalTrip
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel user = UserModel(
    name: "Cadete Express",
    email: "myemailtemp2@gmail.com",
    phone: "941877294",
    bio: "Seu pedido nosso objectivo",
    province: "Luanda",
    adress: "Golf 2",
    balance: "0Kz",
  );

  @override
  Widget build(BuildContext context) {
    user = UserModel(
      name: widget.name ?? user.name,
      email: widget.email ?? user.email,
      phone: widget.phone ?? user.phone,
      bio: user.bio,
      province: widget.province ?? user.province,
      adress: widget.adress ?? user.adress,
      profile: widget.photo,
      balance: widget.balance ?? user.balance,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: REGISTheme.surface,
                border: Border(bottom: BorderSide(color: REGISTheme.divider)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: REGISTheme.accent,
                            width: 3,
                          ),
                          // ignore: deprecated_member_use
                          color: REGISTheme.accent.withOpacity(0.2),
                        ),
                        child: Center(
                          child: CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white,
                            backgroundImage: user.profile != ""
                                ? NetworkImage(user.profile ?? "")
                                : null,
                            child: user.profile == ""
                                ? const Icon(
                                    Icons.person,
                                    size: 52,
                                    color: REGISTheme.accentLight,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: REGISTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(value: "${widget.totalTrip ?? 0}", label: 'Viagens'),
                      _divider(),
                      _StatItem(
                        value: user.balance,
                        label: 'Ganhos',
                        icon: Icons.attach_money_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações Pessoais',
                    style: TextStyle(
                      color: REGISTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoCard(
                    children: [
                      _ProfileRow(
                        icon: Icons.person_outline,
                        label: 'Nome',
                        value: user.name,
                      ),
                      _ProfileRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user.email,
                      ),
                      _ProfileRow(
                        icon: Icons.phone_outlined,
                        label: 'Telefone',
                        value: user.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 210),
                  _InfoCard(
                    children: [
                      _SettingRow(
                        icon: Icons.logout_rounded,
                        label: 'Sair',
                        color: REGISTheme.danger,
                        onTap: () => _confirmLogout(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'RegistAgro v1.0.0 • Transport Information System',
                      style: TextStyle(
                        // ignore: deprecated_member_use
                        color: REGISTheme.textSecondary.withOpacity(0.5),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() =>
      Container(height: 32, width: 1, color: REGISTheme.divider);

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: REGISTheme.surface,
        title: const Text(
          'Sair',
          style: TextStyle(color: REGISTheme.textPrimary),
        ),
        content: const Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(color: REGISTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: REGISTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final profile = Profile();
              await profile.logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: REGISTheme.danger),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const _StatItem({required this.value, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: REGISTheme.warning, size: 16),
              const SizedBox(width: 2),
            ],
            Text(
              value,
              style: TextStyle(
                color: REGISTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(color: REGISTheme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: REGISTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: REGISTheme.divider),
      ),
      child: Column(
        children: children.asMap().entries.map((e) {
          return Column(
            children: [
              e.value,
              if (e.key < children.length - 1)
                const Divider(color: REGISTheme.divider, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: REGISTheme.textSecondary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: REGISTheme.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: REGISTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? REGISTheme.textPrimary;
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? REGISTheme.textSecondary),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: c)),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: color ?? REGISTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
