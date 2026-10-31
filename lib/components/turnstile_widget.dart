import 'package:flutter/material.dart';
import 'package:registagrodriver/config/api_config.dart';
import 'package:flutter_turnstile/flutter_turnstile.dart';

/// Cloudflare Turnstile CAPTCHA using flutter_turnstile package.
class TurnstileWidget extends StatefulWidget {
  final void Function(String token) onVerify;
  final String action;
  final String? siteKey;
  final void Function()? onTokenExpired;

  const TurnstileWidget({
    super.key,
    required this.onVerify,
    this.action = 'login',
    this.siteKey,
    this.onTokenExpired,
  });

  @override
  State<TurnstileWidget> createState() => TurnstileWidgetState();
}

class TurnstileWidgetState extends State<TurnstileWidget> {
  String? _baseUrl;
  late final TurnstileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TurnstileController();
    _baseUrl = _getBaseUrl();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Reseta o widget Turnstile para forçar novo desafio CAPTCHA
  Future<void> reset() async {
    await _controller.refreshToken();
  }

  String _getBaseUrl() {
    final apiBase = ApiConfig.baseUrl;
    if (apiBase.startsWith('http://') || apiBase.startsWith('https://')) {
      final uri = Uri.parse(apiBase);
      return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
    }
    return 'http://localhost';
  }

  @override
  Widget build(BuildContext context) {
    final siteKey = widget.siteKey ?? ApiConfig.turnstileSiteKey;

    if (siteKey.isEmpty) {
      return SizedBox(
        height: 70,
        child: Center(
          child: Text(
            'Turnstile Site Key não configurado',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      );
    }

    return SizedBox(
      height: 70,
      child: CloudFlareTurnstile(
        siteKey: siteKey,
        baseUrl: _baseUrl!,
        action: widget.action,
        controller: _controller,
        onTokenReceived: widget.onVerify,
        onTokenExpired: widget.onTokenExpired,
        options: TurnstileOptions(
          theme: TurnstileTheme.light,
          language: 'pt',
        ),
      ),
    );
  }
}
