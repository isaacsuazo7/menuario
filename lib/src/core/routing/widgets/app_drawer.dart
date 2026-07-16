import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/core/routing/widgets/user_initials.dart';
import 'package:menuario/src/core/theme/spacing.dart';

/// Identity-first drawer for the authenticated shell.
///
/// Leads with a [_UserHeader] (avatar + name + email), keeps the
/// "Ingredientes" catalog and "Calendario de cocina" schedule-editor
/// entries below it, and pins "Cerrar sesión" to the bottom.
/// [AuthService.signOut] emits `null` on the underlying auth stream,
/// which `appRouterProvider`'s gate picks up to redirect back to the sign-in
/// screen.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _UserHeader(user: user),
            const SizedBox(height: MenuarioSpacing.sm),
            ListTile(
              leading: const Icon(Icons.egg_alt_outlined),
              title: const Text('Ingredientes'),
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(IngredientRoutes.list);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: const Text('Calendario de cocina'),
              onTap: () {
                Navigator.of(context).pop();
                context.pushNamed(CookScheduleRoutes.edit);
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.of(context).pop();
                ref.read(authServiceProvider).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// The drawer's single focal element: the signed-in user's avatar, name and
/// email. Degrades gracefully while [user] is `null` (auth still loading or
/// signed out) and when the display name and/or email are missing.
class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final displayName = user?.displayName?.trim();
    final email = user?.email?.trim();
    final hasName = displayName != null && displayName.isNotEmpty;
    final hasEmail = email != null && email.isNotEmpty;

    final title = hasName ? displayName : (hasEmail ? email : 'Invitado');
    // Only show the email line when it is not already the title, so it never
    // renders twice for name-less users.
    final showEmail = hasEmail && title != email;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MenuarioSpacing.lg,
        MenuarioSpacing.lg,
        MenuarioSpacing.lg,
        MenuarioSpacing.md,
      ),
      child: Row(
        children: [
          _Avatar(
            photoURL: user?.photoURL,
            initials: userInitials(displayName: displayName, email: email),
          ),
          MenuarioSpacing.gapH16,
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showEmail) ...[
                  const SizedBox(height: MenuarioSpacing.xs),
                  Text(
                    email,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A circular avatar showing the Google [photoURL] when available, otherwise
/// a brand-tinted circle with the user's [initials].
class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoURL, required this.initials});

  final String? photoURL;
  final String initials;

  static const double _radius = 28;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = photoURL;

    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: _radius,
        backgroundColor: colors.primaryContainer,
        backgroundImage: NetworkImage(url),
      );
    }

    return CircleAvatar(
      radius: _radius,
      backgroundColor: colors.primaryContainer,
      child: Text(
        initials,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
