// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';

// class Homesrcreen extends StatefulWidget {
//   const Homesrcreen({super.key});

//   @override
//   State<Homesrcreen> createState() => _HomesrcreenState();
// }

// class _HomesrcreenState extends State<Homesrcreen> {
//   CameraController? _cameraController;
//   XFile? pictureFile;
//   //final cameras=availableCameras();
//   @override
//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     _cameraController = CameraController(cameras.first, ResolutionPreset.max,
//         enableAudio: false);
//     _cameraController!.initialize().then((_) {
//       if (!mounted) {
//         return;
//       } else {
//         setState(() {
//          _cameraController!.startImageStream();
//         });
//       }
//     });
//   }

//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
