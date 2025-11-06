import 'package:cajucards/screens/playground.dart';
import 'package:flutter/material.dart';
import 'package:cajucards/api/services/auth_service.dart';
import 'initial_screen.dart';
import 'register_screen.dart';
import 'package:provider/provider.dart';
import 'package:cajucards/providers/player_provider.dart';
// import 'package:cajucards/screens/battle_screen.dart'; // Removido (não é chamado daqui)
import 'package:cajucards/api/services/socket_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para pegar o texto dos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instância do nosso serviço de autenticação
  final _authService = AuthService();

  // Variáveis de estado para controlar a UI
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  bool _isPasswordObscured = true;
  final double tamanhoCastanha = 250.0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função principal para lidar com o login
  Future<void> _handleSignIn() async {
    // 1. Limpa os erros anteriores e ativa o loading
    setState(() {
      _emailError = null;
      _passwordError = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    bool isValid = true;

    // 2. Validação básica dos campos
    if (email.isEmpty) {
      setState(() => _emailError = 'Campo obrigatório');
      isValid = false;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Campo obrigatório');
      isValid = false;
    }

    if (!isValid) {
      setState(() => _isLoading = false);
      _showErrorToast('Ops! Preencha todos os campos.');
      return;
    }

    // 3. Chama o serviço de autenticação
    final result = await _authService.signIn(email: email, password: password);

    final currentContext = context;
    if (!currentContext.mounted) return;

    // 4. Trata o resultado
    if (result.success) {
      final playerProvider = Provider.of<PlayerProvider>(
        currentContext,
        listen: false,
      );
      final success = await playerProvider.fetchAndSetPlayer();

      if (!mounted) return;

      if (success) {
        _showSuccessToast('Login efetuado! Bem-vindo(a) de volta.');

        // --- INÍCIO DA ALTERAÇÃO PRINCIPAL ---
        bool socketConnected = false;
        try {
          // 1. ADICIONADO 'await': Agora esperamos a função terminar.
          // 2. ADICIONADO 'socketConnected': Salvamos o resultado (true/false)
          socketConnected =
              await context.read<SocketService>().connectAndListen();
        } catch (e) {
          debugPrint("Erro ao iniciar SocketService: $e");
          _showErrorToast("Erro ao conectar ao servidor de jogo.");
        }

        if (!mounted) return;

        // 3. ADICIONADO 'if/else': Só navegamos se a conexão do socket
        //    foi bem-sucedida (retornou true).
        if (socketConnected) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const InitialScreen()),
          );
        } else {
          // A conexão do socket falhou (provavelmente token nulo ou timeout)
          setState(() => _isLoading = false); // Para o loading
          _showErrorToast(context.read<SocketService>().errorMessage ??
              "Falha ao conectar ao servidor de jogo. Tente novamente.");
        }
        // --- FIM DA ALTERAÇÃO ---
      } else {
        setState(() => _isLoading = false);
        _showErrorToast(
          playerProvider.error ?? 'Não foi possível carregar seus dados.',
        );
      }
    } else {
      setState(() => _isLoading = false);
      _showErrorToast(result.errorMessage ?? 'E-mail ou senha inválidos.');
    }
  }

  // Função para navegar para a tela de registro
  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/woodBasic.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Container(
                width: 800,
                height: 600,
                padding: const EdgeInsets.all(40),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Livro.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Row(
                  children: [
                    // Coluna da esquerda
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          Image.asset(
                            'assets/images/Logo.png',
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          _buildStrokedText(
                            'Bem-vindo(a)\nde volta,\ncajuicer!',
                            44,
                            const Color.fromARGB(255, 244, 129, 6),
                            2.0,
                            const Color(0xFF91280A),
                          ),
                          const Spacer(),
                          _buildStrokedText(
                            'Não tem uma conta?',
                            30,
                            const Color.fromARGB(255, 244, 117, 6),
                            1.5,
                            const Color(0xFF91280A),
                          ),
                          // Botão para ir para a tela de registro
                          GestureDetector(
                            onTap: _navigateToRegister,
                            child: _buildStrokedText(
                              'Cadastre-se!',
                              30,
                              const Color.fromARGB(255, 255, 156, 51),
                              1.5,
                              const Color(0xFF91280A),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    // Coluna da direita
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Login.png',
                            width: 200,
                          ),
                          const SizedBox(height: 20),
                          _buildTextField(
                            labelText: 'E-mail',
                            controller: _emailController,
                            errorText: _emailError,
                          ),
                          _buildPasswordTextField(
                            'Senha',
                            _passwordController,
                            _isPasswordObscured,
                            _passwordError,
                            () => setState(
                              () => _isPasswordObscured = !_isPasswordObscured,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildLoginButton(_handleSignIn),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Image.asset(
              'assets/images/Castanha1Cima.png',
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Image.asset(
              'assets/images/Castanha2Cima.png',
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Image.asset(
              'assets/images/Castanha1Baixo.png',
              width: tamanhoCastanha,
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Image.asset(
              'assets/images/Castanha2Baixo.png',
              width: tamanhoCastanha,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrokedText(
    String text,
    double fontSize,
    Color fillColor,
    double strokeWidth,
    Color strokeColor,
  ) {
    return Stack(
      children: [
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'VT3323',
              fontWeight: FontWeight.w600,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
            ),
          ),
        ),
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'VT3323',
              fontWeight: FontWeight.w600,
              color: fillColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: errorText != null
                ? const Color(0xFFc72c41)
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Image.asset('assets/images/fundoInput.png'),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.emailAddress,
                cursorColor: Colors.white,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'VT323',
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  hintText: labelText,
                  hintStyle: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'VT323',
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(
    String labelText,
    TextEditingController controller,
    bool isObscured,
    String? errorText,
    VoidCallback toggleVisibility,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: errorText != null
                ? const Color(0xFFc72c41)
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Image.asset('assets/images/fundoInput.png'),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 5, bottom: 5),
              child: TextFormField(
                controller: controller,
                obscureText: isObscured,
                cursorColor: Colors.white,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'VT323',
                  fontSize: 20,
                ),
                decoration: InputDecoration(
                  hintText: labelText,
                  hintStyle: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'VT323',
                    fontSize: 20,
                  ),
                  border: InputBorder.none,
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isObscured ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: toggleVisibility,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(VoidCallback onPressed) {
    return SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/fundoInput.png'),
          SizedBox.expand(
            child: ElevatedButton(
              onPressed: _isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Fazer Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 22,
                        fontFamily: 'VT323',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFc72c41),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF801336), width: 3),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 32),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'VT323',
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2D6A4F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF1B4332), width: 3),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'VT323',
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}