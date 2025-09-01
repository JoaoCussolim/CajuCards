import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container (
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/woodBasic.png'),
            fit: BoxFit.cover
          )
        ),
        child: Center(
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pixelCard1.png')
              )
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      Image.asset(
                        'assets/images/Logo.png'
                      ),
                      
                      const SizedBox(height: 20),

                      const Text(
                        'Olá novo cajuicer!',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 244, 129, 6),
                          fontFamily: 'VT323'
                        ),
                      ),

                      const Text(
                        'Bem-vindo(a) ao CajuCards!',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 244, 129, 6),
                          fontFamily: 'VT323'
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      const Text(
                        'Já é um cajuicer?',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 244, 117, 6),
                          fontFamily: 'VT323'
                        ),
                        ),
                      const Text(
                        'Faça seu login!',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 255, 156, 51),
                          fontFamily: 'VT323'
                        ),
                        ),
                    ],
                  ),
                )
              ],
            )
          )
          )
        )
      );
  }
}

//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Aqui você colocaria o "CajuCards" e os textos.
//                       Text(
//                         'CajuCards',
//                         style: TextStyle(
//                           fontSize: 40,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Text(
//                         'Olá novo cajuice!',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       Text(
//                         'Bem-vindo(a)\nao CajuCards!',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       const SizedBox(height: 40),
//                       Text('Já é um cajuicer?'),
//                       Text('Faça seu login!'),
//                     ],
//                   ),
//                 ),
//                 // 4. A linha divisória visual
//                 Container(
//                   width: 2,
//                   color: Colors.black,
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                 ),
//                 // 5. Coluna da direita (Cadastro)
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Aqui você colocaria o título "Cadastro"
//                       Text(
//                         'Cadastro',
//                         style: TextStyle(
//                           fontSize: 30,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 20),
//                       // 6. Campos de texto e o botão
//                       _buildTextField('Nome de Usuário'),
//                       _buildTextField('E-mail'),
//                       _buildPasswordTextField('Nova Senha'),
//                       _buildPasswordTextField('Confirme a Senha'),
//                       const SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () {},
//                         style: ElevatedButton.styleFrom(
//                           // Estilize o botão aqui.
//                           backgroundColor: const Color(0xFFF0953C),
//                           padding: const EdgeInsets.symmetric(vertical: 15),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: const Text(
//                           'Cadastrar',
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // 7. Funções auxiliares para criar os campos de texto
//   Widget _buildTextField(String labelText) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         decoration: InputDecoration(
//           labelText: labelText,
//           // Outras decorações como bordas, cor, etc.
//         ),
//       ),
//     );
//   }

//   Widget _buildPasswordTextField(String labelText) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         obscureText: true,
//         decoration: InputDecoration(
//           labelText: labelText,
//           suffixIcon: Icon(Icons.visibility), // O ícone do olho
//           // Outras decorações como bordas, cor, etc.
//         ),
//       ),
//     );
//   }
// }
