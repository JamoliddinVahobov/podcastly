// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:podcast_app/logic/bloc/auth_bloc.dart';
// import 'package:podcast_app/logic/bloc/auth_event.dart';
// import 'package:podcast_app/logic/bloc/auth_state.dart';
// import 'package:podcast_app/presentation/auth%20pages/initial_page.dart';

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});

//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   void _showLogoutConfirmationDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Logout'),
//           content: const Text(
//             "Are you sure you want to log out?",
//             style: TextStyle(fontSize: 17),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('No'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 context.read<AuthBloc>().add(AuthLogoutRequested());
//               },
//               child: const Text('Yes'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthBloc, AuthState>(
//       listener: (context, state) {
//         if (state is AuthUnauthenticated) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => const AuthPages()),
//           );
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           actions: [
//             Padding(
//               padding: const EdgeInsets.only(right: 10, top: 10),
//               child: PopupMenuButton<String>(
//                 onSelected: (value) {
//                   if (value == 'logout') {
//                     _showLogoutConfirmationDialog();
//                   }
//                 },
//                 itemBuilder: (context) {
//                   return [
//                     const PopupMenuItem(
//                       value: 'logout',
//                       child: Text('Log out'),
//                     ),
//                   ];
//                 },
//               ),
//             )
//           ],
//         ),
//         body: const Center(
//           child: Text(
//             "Hello World",
//             style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
//           ),
//         ),
//       ),
//     );
//   }
// }
