import 'package:flutter/material.dart';

class PresentationScreen extends StatelessWidget {
  const PresentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3), // Fundo cinza claro como na imagem
      body: SafeArea(
        child: Column(
          children: [
            // Imagem 3D no topo (ocupando aproximadamente 65% da tela)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // Sem padding para a imagem cobrir a largura total
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ), // Arredondamento apenas na parte inferior
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: Image.asset(
                    'assets/img/presentation.png', // Sua imagem da ilustração 3D
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Conteúdo de texto (ocupando o restante da tela)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Reinventamos o\ngerenciamento de\ngrandes frotas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0066CC), // Azul como na imagem
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tenha acesso rápido a\ndiversas funcionalidades',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Botão "Acessar" com estilo similar ao da imagem
                    SizedBox(
                      width: 200, // Largura fixa para o botão como na imagem
                      height: 50, // Altura para o botão
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF116AD5), // Azul do botão
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Bordas levemente arredondadas
                          ),
                        ),
                        child: const Text(
                          'Acessar',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
