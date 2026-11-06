import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sprig/core/validators.dart';
import 'package:sprig/data/auth_repository.dart';
import 'package:sprig/routing/app_routes.dart';
import 'package:sprig/state/auth_view_model.dart';
import 'package:sprig/theme/app_colors.dart';
import 'package:sprig/theme/app_motion.dart';
import 'package:sprig/theme/app_text.dart';
import 'package:sprig/widgets/app_text_field.dart';
import 'package:sprig/widgets/mascot.dart';
import 'package:sprig/theme/app_shadows.dart';
import 'package:sprig/widgets/glass.dart';
import 'package:sprig/widgets/lottie_view.dart';
import 'package:sprig/widgets/pill_button.dart';
import 'package:sprig/widgets/stagger_in.dart';

/// Halaman 3: Login dengan validasi input dan penanganan error.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _passwordFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _passwordFocus.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fillDemo() {
    _email.text = AuthRepository.demoEmail;
    _password.text = AuthRepository.demoPassword;
    context.read<AuthViewModel>().clearError();
    _formKey.currentState?.validate();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final auth = context.read<AuthViewModel>();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      HapticFeedback.lightImpact();
      return;
    }
    final ok = await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (ok) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return Scaffold(
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(32),
                blur: 22,
                tint: const Color(0x99FFFFFF),
                shadow: AppShadows.soft,
                padding: const EdgeInsets.all(24),
                child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StaggerIn(
                      index: 0,
                      child: Mascot(
                        size: 112,
                        mood: auth.error != null
                            ? MascotMood.sad
                            : (_passwordFocus.hasFocus && _obscure
                                ? MascotMood.cover
                                : MascotMood.idle),
                      ),
                    ),
                    const SizedBox(height: 12),
                    StaggerIn(
                      index: 1,
                      child: Text(
                        'Selamat datang\nkembali.',
                        style: AppText.display,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StaggerIn(
                      index: 2,
                      child: Text(
                        'Masuk untuk merawat kebunmu.',
                        style: AppText.bodyMuted,
                      ),
                    ),
                    const SizedBox(height: 28),
                    StaggerIn(
                      index: 3,
                      child: AppTextField(
                        label: 'Email',
                        hint: 'nama@email.com',
                        controller: _email,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                        onChanged: (_) =>
                            context.read<AuthViewModel>().clearError(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StaggerIn(
                      index: 4,
                      child: AppTextField(
                        label: 'Kata sandi',
                        hint: 'Minimal 6 karakter',
                        controller: _password,
                        focusNode: _passwordFocus,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.password,
                        onChanged: (_) =>
                            context.read<AuthViewModel>().clearError(),
                        onFieldSubmitted: (_) => _submit(),
                        suffix: IconButton(
                          tooltip: _obscure
                              ? 'Tampilkan kata sandi'
                              : 'Sembunyikan kata sandi',
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.muted,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: AppMotion.resolve(context, AppMotion.medium),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: auth.error == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: _ErrorBanner(message: auth.error!),
                            ),
                    ),
                    const SizedBox(height: 24),
                    StaggerIn(
                      index: 5,
                      child: PillButton(
                        label: 'Masuk',
                        icon: Icons.arrow_forward_rounded,
                        loading: auth.isLoading,
                        onPressed: _submit,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StaggerIn(
                      index: 6,
                      child: _DemoHint(onFill: _fillDemo),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}

/// Latar halaman masuk: bola cahaya pastel + daun melayang (Lottie).
class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final side = size.shortestSide;
    Widget orb(Color color, double diameter) => Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withAlpha(0)],
            ),
          ),
        );
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(top: -side * 0.2, right: -side * 0.25, child: orb(AppColors.lime, side * 0.9)),
            Positioned(bottom: -side * 0.3, left: -side * 0.3, child: orb(AppColors.tint(1), side * 1.0)),
            Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.85,
                child: LottieView(
                  asset: LottieView.leaves,
                  size: size.longestSide,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 20,
              color: AppColors.danger,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppText.bodyMuted.copyWith(color: AppColors.danger),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint({required this.onFill});

  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.limeSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Akun demo', style: AppText.label),
                const SizedBox(height: 2),
                Text(
                  '${AuthRepository.demoEmail}\n'
                  'Sandi: ${AuthRepository.demoPassword}',
                  style: AppText.caption.copyWith(color: AppColors.inkSoft),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onFill,
            child: Text('Isi otomatis', style: AppText.label),
          ),
        ],
      ),
    );
  }
}
