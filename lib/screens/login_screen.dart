import 'package:flutter/material.dart';
import '../providers/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await AuthService.login(_userCtrl.text.trim(), _passCtrl.text);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = 'Login falhou. Verifique usuário e senha ou registre-se.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(labelText: 'Usuário'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe usuário' : null,
              ),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (v) => (v == null || v.isEmpty) ? 'Informe senha' : null,
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton(onPressed: _submit, child: const Text('Entrar')),
                  const SizedBox(width: 12),
                  TextButton(
                      onPressed: () => Navigator.of(context).pushNamed('/register'),
                      child: const Text('Registrar'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
