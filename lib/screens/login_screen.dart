import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variáveis para controlar a visibilidade das senhas
  bool _isNewPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  final double tamanhoCastanha = 250.0;

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
                    // Coluna da esquerda (Logo e textos)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20), // Espaço no topo
                          Image.asset(
                            'assets/images/Logo.png',
                            height: 150, // Controla a altura da logo
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 20),
                          // Textos de boas-vindas com borda
                          _buildStrokedText(
                            'Muito bom ver você de novo!\nBem-vindo(a)!',
                            44,
                            const Color.fromARGB(255, 244, 129, 6),
                            2.0,
                            const Color(0xFF91280A),
                          ),
                          const Spacer(), // Empurra o conteúdo abaixo para o final
                          // Textos de login com borda
                          _buildStrokedText(
                            'Ainda não é um cajuicer?',
                            30,
                            const Color.fromARGB(255, 244, 117, 6),
                            1.5,
                            const Color(0xFF91280A),
                          ),
                          _buildStrokedText(
                            'Faça seu cadastro!',
                            30,
                            const Color.fromARGB(255, 255, 156, 51),
                            1.5,
                            const Color(0xFF91280A),
                          ),
                          const SizedBox(height: 20), // Espaço na base
                        ],
                      ),
                    ),
                    // Adiciona a linha divisória vertical
                    Container(
                      width: 2,
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    // Coluna da direita (Formulário de cadastro)
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Título "Cadastro"
                          Image.asset('assets/images/Login.png',
                              width: 200),
                          const SizedBox(height: 20),

                          // Campos de texto e botão
                          _buildTextField('Email'),
                          _buildPasswordTextField(
                            'Senha',
                            _isNewPasswordObscured,
                            () {
                              setState(() {
                                _isNewPasswordObscured =
                                    !_isNewPasswordObscured;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildLoginButton(),
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

  // Função para construir texto com borda (stroke)
  Widget _buildStrokedText(String text, double fontSize, Color fillColor,
      double strokeWidth, Color strokeColor) {
    return Stack(
      children: <Widget>[
        // Texto da borda (contorno)
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'VT323',
              fontWeight: FontWeight.w600,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth
                ..color = strokeColor,
            ),
          ),
        ),
        // Texto do preenchimento
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: 'VT323',
              fontWeight: FontWeight.w600,
              color: fillColor,
            ),
          ),
        ),
      ],
    );
  }

  // Função para construir os campos de texto com imagem de fundo
  Widget _buildTextField(String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // IMPORTANTE: Substitua 'assets/images/your_textfield_image.png' pelo caminho da sua imagem para o campo
          Image.asset('assets/images/fundoInput.png'),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              bottom: 5,
            ), // Ajuste o padding conforme necessário
            child: TextField(
              decoration: InputDecoration(
                hintText: labelText,
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'VT323',
                  fontSize: 20,
                ),
                // Remove a cor de preenchimento e as bordas
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'VT323',
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para construir os campos de senha com imagem de fundo e ícone de visibilidade
  Widget _buildPasswordTextField(
    String labelText,
    bool isObscured,
    VoidCallback toggleVisibility,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // IMPORTANTE: Substitua 'assets/images/your_textfield_image.png' pelo caminho da sua imagem para o campo
          Image.asset('assets/images/fundoInput.png'),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              right: 5,
              bottom: 5,
            ), // Ajuste o padding
            child: TextField(
              obscureText: isObscured,
              decoration: InputDecoration(
                hintText: labelText,
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'VT323',
                  fontSize: 20,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off : Icons.visibility,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  onPressed: toggleVisibility,
                ),
              ),
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontFamily: 'VT323',
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Função para construir o botão de cadastro com imagem de fundo
  Widget _buildLoginButton() {
    return SizedBox(
      height: 60, // Defina uma altura para o botão
      child: Stack(
        alignment: Alignment.center,
        children: [
          // IMPORTANTE: Substitua 'assets/images/your_button_image.png' pelo caminho da sua imagem para o botão
          Image.asset('assets/images/fundoInput.png'),
          SizedBox.expand(
            child: ElevatedButton(
              onPressed: () {
                // Lógica de cadastro aqui
              },
              style: ElevatedButton.styleFrom(
                // Deixa o botão completamente transparente
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Fazer Login',
                style: TextStyle(
                  color: Color.fromARGB(
                      255, 255, 255, 255), // Cor do texto mais escura, como na imagem
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
}