import 'dart:async';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:registagrodriver/screens/MainNavScreen/main_nav_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String otpCode = "";
  bool isLoading = false;

  int resendCounter = 60;
  bool canResend = false;
  Timer? _timer;

  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>.broadcast();

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _errorController.close();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      resendCounter = 60;
      canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (resendCounter <= 1) {
        timer.cancel();
        setState(() {
          canResend = true;
          resendCounter = 0;
        });
      } else {
        setState(() {
          resendCounter--;
        });
      }
    });
  }

  void validateOtp() async {
    FocusScope.of(context).unfocus();

    if (otpCode.length != 6 || isLoading) return;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => isLoading = false);

    bool otpIsCorrect = otpCode == "123456";

    if (otpIsCorrect) {
      ElegantNotification.success(
        title: const Text("Sucesso"),
        description: const Text("Operação concluída com êxito!"),
        height: 80,
      ).show(context);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
        (route) => false,
      );
    } else {
      _errorController.add(ErrorAnimationType.shake);
      setState(() => otpCode = "");

      ElegantNotification.error(
        title: const Text("Erro"),
        description: const Text("Código incorreto. Por favor, tente novamente!"),
        height: 80,
      ).show(context);
    }
  }

  void resendCode() {
    if (!canResend) return;
    setState(() => otpCode = "");

    ElegantNotification.info(
      title: const Text("Código reenviado"),
      description: const Text("Enviamos um novo código para o seu email."),
      height: 80,
    ).show(context);

    startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/icone.png",
                  height: 100.0,
                  width: 100.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.agriculture,
                    size: 100,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "RegistAgro",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Insira o código enviado para o seu email",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 30),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  errorAnimationController: _errorController,
                  cursorColor: Colors.blue,
                  backgroundColor: Colors.transparent,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  enableActiveFill: true,
                  onChanged: (value) => setState(() => otpCode = value),
                  onCompleted: (value) {
                    setState(() => otpCode = value);
                    validateOtp();
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: Colors.blue.shade100,
                    inactiveFillColor: Colors.blue.shade50,
                    selectedFillColor: Colors.blue.shade200,
                    inactiveColor: Colors.grey[700]!,
                    selectedColor: Colors.blue.shade400,
                    activeColor: Colors.blue.shade300,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : validateOtp,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Colors.grey.shade300,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Continuar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: canResend ? resendCode : null,
                  child: Text(
                    canResend
                        ? "Reenviar código"
                        : "Reenviar em ${resendCounter}s",
                    style: TextStyle(
                      color: canResend ? Colors.blue : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}