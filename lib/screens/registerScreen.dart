import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/woodBasic.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            width: 800,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Logo.png',
                      ),
                      const SizedBox(height: 20),
                      // Textos de boas-vindas
                      const Text(
                        'Olá novo cajuicer!\nBem-vindo(a) ao\nCajuCards!',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 244, 129, 6),
                          fontFamily: 'VT323',
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Textos de login
                      const Text(
                        'Já é um cajuicer?',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 244, 117, 6),
                          fontFamily: 'VT323',
                        ),
                      ),
                      const Text(
                        'Faça seu login!',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 255, 156, 51),
                          fontFamily: 'VT323',
                        ),
                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título "Cadastro"
                      const Text(
                        'Cadastro',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'VT323',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Campos de texto e botão (você pode criar funções auxiliares para eles)
                      _buildTextField('Nome de Usuário'),
                      _buildTextField('E-mail'),
                      _buildPasswordTextField('Nova Senha'),
                      _buildPasswordTextField('Confirme a Senha'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0953C),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cadastrar',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Funções para construir os campos de texto, para evitar repetição de código
  Widget _buildTextField(String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: labelText,
        ),
      ),
    );
  }

  Widget _buildPasswordTextField(String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: labelText,
          suffixIcon: const Icon(Icons.visibility),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class RegisterScreen extends StatelessWidget {
//   const RegisterScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container (
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/images/woodBasic.png'),
//             fit: BoxFit.cover
//           )
//         ),
//         child: Center(
//           child: Container(
//             width: 800,
//             padding: const EdgeInsets.all(40),
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/Livro.png')
//               )
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [

//                       Image.asset(
//                         'assets/images/Logo.png'
//                       ),
                      
//                       const SizedBox(height: 20),

//                       const Text(
//                         'Olá novo cajuicer! Bem-vindo(a) ao CajuCards!',
//                         style: TextStyle(
//                           fontSize: 44,
//                           fontWeight: FontWeight.w600,
//                           color: Color.fromARGB(255, 244, 129, 6),
//                           fontFamily: 'VT323'
//                         ),
//                       ),

//                       // const Text(
//                       //   'Bem-vindo(a) ao CajuCards!',
//                       //   style: TextStyle(
//                       //     fontSize: 44,
//                       //     fontWeight: FontWeight.w600,
//                       //     color: Color.fromARGB(255, 244, 129, 6),
//                       //     fontFamily: 'VT323'
//                       //   ),
//                       // ),
                      
//                       const SizedBox(height: 40),
                      
//                       const Text(
//                         'Já é um cajuicer?',
//                         style: TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w600,
//                           color: Color.fromARGB(255, 244, 117, 6),
//                           fontFamily: 'VT323'
//                         ),
//                         ),
//                       const Text(
//                         'Faça seu login!',
//                         style: TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.w600,
//                           color: Color.fromARGB(255, 255, 156, 51),
//                           fontFamily: 'VT323'
//                         ),
//                         ),
//                     ],
//                   ),
//                 )
//               ],
//             )
//           )
//           )
//         )
//       );
//   }
// }