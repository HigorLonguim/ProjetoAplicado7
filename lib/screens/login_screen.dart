import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _auth = AuthService();
  LocalUser? _user;
  bool _hasAccount = false;
  bool _loggedIn = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final hasAccount = await _auth.hasAccount;
      final loggedIn = await _auth.isLoggedIn;
      final user = await _auth.currentUser;
      if (!mounted) return;
      setState(() {
        _hasAccount = hasAccount;
        _loggedIn = loggedIn;
        _user = user;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasAccount = false;
        _loggedIn = false;
        _user = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha conta')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: _loggedIn && _user != null
                      ? _ProfileCard(user: _user!, onLogout: () async { await _auth.logout(); await _load(); })
                      : _AuthForm(
                          registerMode: !_hasAccount,
                          onSuccess: _load,
                          auth: _auth,
                        ),
                ),
              ),
            ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.onLogout});
  final LocalUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.navyLight, AppColors.navy]),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.peach,
            child: Text(user.name.characters.first.toUpperCase(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.navy)),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.olive),
            const SizedBox(width: 14),
            const Expanded(child: Text('Conta local protegida por senha. Seus dados ficam neste dispositivo.')),
          ]),
        ),
      ),
      const SizedBox(height: 22),
      OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout_rounded), label: const Text('Sair da conta')),
    ]);
  }
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.registerMode, required this.onSuccess, required this.auth});
  final bool registerMode;
  final VoidCallback onSuccess;
  final AuthService auth;
  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _key = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose(); _email.dispose(); _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_key.currentState?.validate() ?? false)) return;
    setState(() { _busy = true; _error = null; });
    try {
      if (widget.registerMode) {
        await widget.auth.register(name: _name.text, email: _email.text, password: _password.text);
        widget.onSuccess();
        return;
      }
      final valid = await widget.auth.login(email: _email.text, password: _password.text);
      if (!mounted) return;
      if (valid) widget.onSuccess();
      setState(() { _busy = false; _error = valid ? null : 'E-mail ou senha incorretos.'; });
    } catch (_) {
      if (mounted) setState(() { _busy = false; _error = 'Não foi possível salvar os dados neste dispositivo.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Center(child: OrigemMark(size: 72)),
            const SizedBox(height: 22),
            Text(widget.registerMode ? 'Criar conta' : 'Entrar', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 6),
            Text(widget.registerMode ? 'Salve seu perfil neste dispositivo.' : 'Acesse seu perfil local.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            if (widget.registerMode) ...[
              TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline)), validator: (value) => (value?.trim().length ?? 0) < 2 ? 'Informe seu nome.' : null),
              const SizedBox(height: 14),
            ],
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)), validator: (value) => !RegExp(r'^.+@.+\..+$').hasMatch(value?.trim() ?? '') ? 'Informe um e-mail válido.' : null),
            const SizedBox(height: 14),
            TextFormField(
              controller: _password,
              obscureText: _hidden,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _hidden = !_hidden), icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined))),
              validator: (value) => (value?.length ?? 0) < 6 ? 'Use pelo menos 6 caracteres.' : null,
            ),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error))),
            const SizedBox(height: 22),
            GradientButton(label: widget.registerMode ? 'Criar minha conta' : 'Entrar', icon: widget.registerMode ? Icons.person_add_alt_1 : Icons.login_rounded, onPressed: _busy ? null : _submit),
          ]),
        ),
      ),
    );
  }
}

class LoginScreen extends AccountScreen {
  const LoginScreen({super.key});
}
