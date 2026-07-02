import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/auth_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  bool _hasError = false;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPress(String number, AuthState authState) {
    if (_hasError) {
      setState(() => _hasError = false);
    }
    
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == 4) {
        _handlePinComplete(authState);
      }
    }
  }

  void _onBackspace() {
    if (_hasError) {
      setState(() => _hasError = false);
    }
    
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _handlePinComplete(AuthState authState) async {
    final notifier = ref.read(authStateProvider.notifier);

    if (authState == AuthState.needsPinCreation) {
      if (!_isConfirming) {
        // Step 1 of creation complete, move to confirm
        setState(() {
          _confirmPin = _pin;
          _pin = '';
          _isConfirming = true;
        });
      } else {
        // Step 2 of creation complete, verify match
        if (_pin == _confirmPin) {
          await notifier.createPin(_pin);
          if (mounted) context.go('/dashboard');
        } else {
          _triggerError();
          setState(() {
            _pin = '';
            _confirmPin = '';
            _isConfirming = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PINs do not match. Try again.')),
            );
          }
        }
      }
    } else if (authState == AuthState.needsPinEntry) {
      // Authenticate
      final success = await notifier.authenticate(_pin);
      if (success) {
        if (mounted) context.go('/dashboard');
      } else {
        _triggerError();
        setState(() {
          _pin = '';
        });
      }
    }
  }

  void _triggerError() {
    setState(() => _hasError = true);
    _shakeController.forward(from: 0);
  }

  void _showForgotPinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset PIN?'),
          content: const Text(
            'Because this is an offline app, resetting your PIN will clear your secure credentials.\n\n'
            'Are you sure you want to continue?',
          ),
          icon: const Icon(Icons.warning_amber_rounded, size: 48),
          iconColor: Theme.of(context).colorScheme.error,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                ref.read(authStateProvider.notifier).resetPin();
                setState(() {
                  _pin = '';
                  _confirmPin = '';
                  _isConfirming = false;
                });
                Navigator.pop(context);
              },
              child: const Text('Reset PIN'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Auto navigation if somehow landed here authenticated
    ref.listen(authStateProvider, (previous, next) {
      if (next == AuthState.authenticated) {
        context.go('/dashboard');
      }
    });

    if (authState == AuthState.initial) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String titleText = '';
    String subtitleText = '';
    
    if (authState == AuthState.needsPinCreation) {
      titleText = _isConfirming ? 'Confirm PIN' : 'Create PIN';
      subtitleText = _isConfirming
          ? 'Re-enter your 4-digit PIN'
          : 'Set a 4-digit PIN to secure your data';
    } else if (authState == AuthState.needsPinEntry) {
      titleText = 'Welcome Back';
      subtitleText = 'Enter your 4-digit PIN';
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Header
            Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              titleText,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitleText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(flex: 1),

            // PIN Dots
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isFilled = index < _pin.length;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFilled
                              ? (_hasError
                                  ? colorScheme.error
                                  : colorScheme.primary)
                              : colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: isFilled
                                ? Colors.transparent
                                : colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
            const Spacer(flex: 1),
            
            if (_hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Incorrect PIN',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // Numpad
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          for (var j = 1; j <= 3; j++)
                            _NumpadButton(
                              number: '${i * 3 + j}',
                              onTap: () => _onNumberPress('${i * 3 + j}', authState),
                            ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Empty space for layout balance or a biometric button
                      const SizedBox(width: 72, height: 72),
                      _NumpadButton(
                        number: '0',
                        onTap: () => _onNumberPress('0', authState),
                      ),
                      _NumpadButton(
                        icon: Icons.backspace_outlined,
                        onTap: _onBackspace,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 1),

            // Forgot PIN (Only show if PIN exists)
            if (authState == AuthState.needsPinEntry)
              TextButton(
                onPressed: _showForgotPinDialog,
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurfaceVariant,
                ),
                child: const Text('Forgot PIN?'),
              ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class _NumpadButton extends StatelessWidget {
  final String? number;
  final IconData? icon;
  final VoidCallback onTap;

  const _NumpadButton({
    this.number,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surfaceContainer,
          ),
          child: number != null
              ? Text(
                  number!,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                )
              : Icon(
                  icon,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
        ),
      ),
    );
  }
}
