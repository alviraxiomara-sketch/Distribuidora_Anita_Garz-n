// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';

// class BotonPrincipal extends StatelessWidget {
//   final String texto;
//   final VoidCallback onPressed;
//   final Color? color;

//   const BotonPrincipal({
//     super.key,
//     required this.texto,
//     required this.onPressed,
//     this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: onPressed,
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color ?? AppColors.accent,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//       child: Text(texto),
//     );
//   }
// }