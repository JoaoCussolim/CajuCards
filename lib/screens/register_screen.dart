import 'package:flutter/material.dart';
import 'package:cajucards/api/services/auth_service.dart';
import 'package:cajucards/screens/login_screen.dart'; // NOVO: Importa a tela de login

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  final double tamanhoCastanha = 250.0;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _usernameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    bool isValid = true;

    if (username.isEmpty) {
      setState(() => _usernameError = 'Campo obrigatório');
      isValid = false;
    }
    if (email.isEmpty) {
      setState(() => _emailError = 'Campo obrigatório');
      isValid = false;
    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _emailError = 'E-mail inválido');
      isValid = false;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Campo obrigatório');
      isValid = false;
    } else if (password.length < 6) {
      setState(() => _passwordError = 'Mínimo 6 caracteres');
      isValid = false;
    }
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = 'Campo obrigatório');
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() => _confirmPasswordError = 'As senhas não coincidem');
      isValid = false;
    }
    
    if (!isValid) {
      _showErrorToast('Ops! Verifique os campos em vermelho.');
      return;
    }

    setState(() => _isLoading = true);
    final result = await _authService.signUp(email: email, password: password, username: username);

    // Salva o context localmente ANTES do await
    final currentContext = context;

    if (!currentContext.mounted) return; // Verifica se o widget ainda está na tela

    setState(() => _isLoading = false);
    
    if (result.success) {
      _showSuccessToast('Cadastro realizado! Entrando...');
      // NAVEGAÇÃO CORRIGIDA: Usa o context salvo para garantir a navegação
      Navigator.of(currentContext).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      _showErrorToast(result.errorMessage ?? 'Ocorreu um erro desconhecido.');
    }
  }
  
  // NOVO: Função para navegar para a tela de login
  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/woodBasic.png'), fit: BoxFit.cover),
            ),
            child: Center(
              child: Container(
                width: 800,
                height: 600,
                padding: const EdgeInsets.all(40),
                decoration: const BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/images/Livro.png'), fit: BoxFit.fill),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Image.asset('assets/images/Logo.png', height: 150, fit: BoxFit.contain),
                          const SizedBox(height: 20),
                          _buildStrokedText('Olá novo cajuicer!\nBem-vindo(a) ao\nCajuCards!', 44, const Color.fromARGB(255, 244, 129, 6), 2.0, const Color(0xFF91280A)),
                          const Spacer(),
                          _buildStrokedText('Já é um cajuicer?', 30, const Color.fromARGB(255, 244, 117, 6), 1.5, const Color(0xFF91280A)),
                          // WIDGET CLICÁVEL: Adicionado GestureDetector
                          GestureDetector(
                            onTap: _navigateToLogin,
                            child: _buildStrokedText('Faça seu login!', 30, const Color.fromARGB(255, 255, 156, 51), 1.5, const Color(0xFF91280A)),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Container(width: 2, color: Colors.black, margin: const EdgeInsets.symmetric(horizontal: 20)),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/Cadastro.png', width: 200),
                            const SizedBox(height: 20),
                            _buildTextField(labelText: 'Nome de Usuário', controller: _usernameController, errorText: _usernameError),
                            _buildTextField(labelText: 'E-mail', controller: _emailController, errorText: _emailError),
                            _buildPasswordTextField('Nova Senha', _passwordController, _isNewPasswordObscured, _passwordError, () => setState(() => _isNewPasswordObscured = !_isNewPasswordObscured)),
                            _buildPasswordTextField('Confirme a Senha', _confirmPasswordController, _isConfirmPasswordObscured, _confirmPasswordError, () => setState(() => _isConfirmPasswordObscured = !_isConfirmPasswordObscured)),
                            const SizedBox(height: 20),
                            _buildRegisterButton(_handleSignUp),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(top: 10, left: 10, child: Image.asset('assets/images/Castanha1Cima.png', width: tamanhoCastanha)),
          Positioned(top: 10, right: 10, child: Image.asset('assets/images/Castanha2Cima.png', width: tamanhoCastanha)),
          Positioned(bottom: 10, left: 10, child: Image.asset('assets/images/Castanha1Baixo.png', width: tamanhoCastanha)),
          Positioned(bottom: 10, right: 10, child: Image.asset('assets/images/Castanha2Baixo.png', width: tamanhoCastanha)),
        ],
      ),
    );
  }

  // Funções de build e toasts (sem alterações, apenas para manter o código completo)
  Widget _buildStrokedText(String text, double fontSize, Color fillColor, double strokeWidth, Color strokeColor) {
    return Stack(children: [
      Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize, fontFamily: 'VT323', fontWeight: FontWeight.w600, foreground: Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..color = strokeColor))),
      Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize, fontFamily: 'VT323', fontWeight: FontWeight.w600, color: fillColor)))
    ]);
  }

  Widget _buildTextField({required String labelText, required TextEditingController controller, String? errorText}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5.0), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: errorText != null ? const Color(0xFFc72c41) : Colors.transparent, width: 3)), child: Stack(alignment: Alignment.centerLeft, children: [Image.asset('assets/images/fundoInput.png'), Padding(padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5), child: TextFormField(controller: controller, cursorColor: Colors.white, decoration: InputDecoration(hintText: labelText, hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontFamily: 'VT323', fontSize: 20), border: InputBorder.none, errorStyle: const TextStyle(height: 0, fontSize: 0)), style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontFamily: 'VT323', fontSize: 20)))])));
  }

  Widget _buildPasswordTextField(String labelText, TextEditingController controller, bool isObscured, String? errorText, VoidCallback toggleVisibility) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5.0), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: errorText != null ? const Color(0xFFc72c41) : Colors.transparent, width: 3)), child: Stack(alignment: Alignment.centerLeft, children: [Image.asset('assets/images/fundoInput.png'), Padding(padding: const EdgeInsets.only(left: 15, right: 5, bottom: 5), child: TextFormField(controller: controller, cursorColor: Colors.white, obscureText: isObscured, decoration: InputDecoration(hintText: labelText, hintStyle: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontFamily: 'VT323', fontSize: 20), border: InputBorder.none, errorStyle: const TextStyle(height: 0, fontSize: 0), suffixIcon: IconButton(icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: const Color.fromARGB(255, 255, 255, 255)), onPressed: toggleVisibility)), style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontFamily: 'VT323', fontSize: 20)))])));
  }

  Widget _buildRegisterButton(VoidCallback onPressed) {
    return SizedBox(height: 60, child: Stack(alignment: Alignment.center, children: [Image.asset('assets/images/fundoInput.png'), SizedBox.expand(child: ElevatedButton(onPressed: _isLoading ? null : onPressed, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: _isLoading ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)) : const Text('Cadastrar', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 22, fontFamily: 'VT323', fontWeight: FontWeight.bold))))]));
  }
  
  void _showErrorToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.transparent, elevation: 0, content: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: const Color(0xFFc72c41), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF801336), width: 3)), child: Row(children: [const Icon(Icons.error_outline, color: Colors.white, size: 32), const SizedBox(width: 15), Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontFamily: 'VT323', fontSize: 20)))]))));
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.transparent, elevation: 0, content: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: const Color(0xFF2D6A4F), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF1B4332), width: 3)), child: Row(children: [const Icon(Icons.check_circle_outline, color: Colors.white, size: 32), const SizedBox(width: 15), Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontFamily: 'VT323', fontSize: 20)))]))));
  }
}