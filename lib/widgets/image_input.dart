import 'dart:io';

import 'package:flutter/material.dart';
//its used to pick images from device(using native features)
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({super.key, required this.onPickImage});

  final void Function(File image) onPickImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;
  void _takePicture() async {
    //ImagePicker: helps in pickin images
    final imagePicker = ImagePicker();
    //pickImage picks an image
    //ImageSource is an enum provided by package
    //.camera means pick image from camera(we can use .gallery as  well).
    //since image picker returns a future value, so we can wither use .then or async/await
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      //if picked image is not null then it will be stored in _selectedImage
      //since Pickedimage is of type Xfile and _selectedImage is of type File, it causes an error
      //so we convert Xfile into file using File(Xfilename.path) syntax
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      onPressed: _takePicture,
      icon: const Icon(Icons.camera),
      label: const Text('Take picture'),
    );

    if (_selectedImage != null) {
      //Image.file Creates a widget that displays an [ImageStream] obtained from a [File].
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
