import 'package:flutter/material.dart';
import 'core.dart';

Widget _logo({double r = 34}) => CircleAvatar(
    radius: r, backgroundColor: Colors.white, child: Icon(Icons.local_bar, size: r, color: kBar));

Widget _cameraCircle({double r = 34}) => CircleAvatar(
    radius: r, backgroundColor: Colors.white, child: Icon(Icons.photo_camera, size: r, color: Colors.black));

/// Inicio de sesión
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 24),
              _logo(),
              BorderPanel(title: 'Iniciar Sesión', child: Column(children: [
                const GrayField('Nombre'),
                const GrayField('Contraseña', obscure: true),
                const GrayField('Correo', type: TextInputType.emailAddress),
                BlueButton('Iniciar sesión',
                    onTap: () => Navigator.pushReplacementNamed(context, '/home')),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/recuperar'),
                    child: const Text('¿Olvidaste tu Contraseña?',
                        style: TextStyle(fontSize: 11, color: Colors.white))),
              ])),
              const Divider(color: Colors.white54, indent: 16, endIndent: 16),
              const Text('Iniciar Sesión con', style: TextStyle(fontSize: 11)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _social(Icons.facebook, 'Facebook', Colors.blue),
                const SizedBox(width: 16),
                _social(Icons.g_mobiledata, 'Google', Colors.red),
              ]),
              const SizedBox(height: 40),
              const Text('¿No tienes cuenta aún?', style: TextStyle(fontSize: 11)),
              BlueButton('Crea una cuenta',
                  onTap: () => Navigator.pushNamed(context, '/registro')),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      );

  Widget _social(IconData i, String t, Color c) => ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(i, color: c, size: 18),
        label: Text(t, style: const TextStyle(color: Colors.black, fontSize: 11)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
      );
}

/// Registro
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 24),
              _cameraCircle(),
              BorderPanel(title: 'Registrarse', child: Column(children: [
                const GrayField('Nombre'),
                const GrayField('Correo', type: TextInputType.emailAddress),
                const GrayField('Dirección de residencia'),
                const GrayField('Teléfono', type: TextInputType.phone),
                const GrayField('Contraseña', obscure: true),
                const GrayField('Confirmar contraseña', obscure: true),
                BlueButton('Crear Cuenta', onTap: () {}),
                const SizedBox(height: 10),
                const Text('¿Ya tienes una cuenta?', style: TextStyle(fontSize: 11)),
                BlueButton('Inicia sesión',
                    onTap: () => Navigator.pushNamed(context, '/login')),
              ])),
            ]),
          ),
        ),
      );
}

/// Recuperar contraseña
class RecoverScreen extends StatelessWidget {
  const RecoverScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(children: [
            const SizedBox(height: 40),
            _logo(),
            BorderPanel(title: 'Recuperar Contraseña', child: Column(children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Correo', style: TextStyle(fontSize: 11))),
              const SizedBox(height: 4),
              const GrayField('', type: TextInputType.emailAddress),
              BlueButton('Enviar Correo',
                  onTap: () => Navigator.pushNamed(context, '/cambiar-clave')),
            ])),
          ]),
        ),
      );
}

/// Cambiar contraseña
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              const SizedBox(height: 40),
              _logo(),
              const SizedBox(height: 8),
              const Text('Cambiar Contraseña',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              BorderPanel(child: Column(children: [
                const GrayField('Código'),
                const GrayField('Contraseña', obscure: true),
                const GrayField('Confirmar contraseña', obscure: true),
                BlueButton('Cambiar contraseña',
                    onTap: () => Navigator.pushNamed(context, '/login')),
              ])),
            ]),
          ),
        ),
      );
}

/// Perfil
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => AppScaffold(
        left: [navHome(context), navBell(context)],
        right: [navCart(context)],
        fab: const AiAvatar(),
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(height: 30),
            _cameraCircle(r: 36),
            const SizedBox(height: 8),
            const Text('Perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            BorderPanel(child: const Column(children: [
              GrayField('Nombre'),
              GrayField('Correo'),
              GrayField('Teléfono'),
              GrayField('Dirección'),
            ])),
            BlueButton('Cerrar sesión',
                onTap: () => Navigator.pushReplacementNamed(context, '/login')),
          ]),
        ),
      );
}