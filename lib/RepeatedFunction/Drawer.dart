import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movieapp/SectionHomePageUi/FavoriateList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'repttext.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class drawerfunc extends StatefulWidget {
  const drawerfunc({
    super.key,
  });

  @override
  State<drawerfunc> createState() => _drawerfuncState();
}

class _drawerfuncState extends State<drawerfunc> with TickerProviderStateMixin {
  File? _image;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Future<void> SelectImage() async {
    final pickedfile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedfile != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: pickedfile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      );
      SharedPreferences sp = await SharedPreferences.getInstance();
      sp.setString('imagepath', cropped!.path);
      setState(() {
        _image = cropped as File?;
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    SharedPreferences.getInstance().then((sp) {
      setState(() {
        String? imagePath = sp.getString('imagepath');
        if (imagePath != null && imagePath.isNotEmpty) {
          _image = File(imagePath);
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final controllerone = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
      ),
    )
    ..loadRequest(Uri.parse('https://niranjandahal.com.np'));

  final controllertwo = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
      ),
    )
    ..loadRequest(Uri.parse('https://dahalniranjan.com.np'));

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0D0D0D),
              Color(0xFF000000),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerHeader(),
              SizedBox(height: 20),
              _buildMenuSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2D2D2D),
            Color(0xFF1A1A1A),
            Color(0xFF0D0D0D),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40),
          GestureDetector(
            onTap: () async {
              await SelectImage();
              Fluttertoast.showToast(
                msg: "✨ Profile Image Updated!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Color(0xFF333333),
                textColor: Colors.white,
                fontSize: 16.0,
              );
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFE50914), Color(0xFFB20710)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE50914).withValues(alpha:0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A1A1A),
                ),
                child: _image == null
                    ? CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2D2D2D),
                  backgroundImage: AssetImage('assets/red2.png'),
                )
                    : CircleAvatar(
                  radius: 50,
                  backgroundImage: FileImage(_image!),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Welcome Back!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFE50914).withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFFE50914).withValues(alpha:0.3)),
            ),
            child: Text(
              'Movie Box',
              style: TextStyle(
                color: Color(0xFFE50914),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          _buildMenuItem('Home', Icons.home_rounded,
              gradient: [Color(0xFFE50914), Color(0xFFB20710)],
              ontap: () {
                Navigator.pop(context);
              }
          ),
          _buildMenuItem('Favorites', Icons.favorite_rounded,
              gradient: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
              ontap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FavoriateMovies()));
              }
          ),
          // _buildMenuItem('Our Blogs', FontAwesomeIcons.blogger,
          //     gradient: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
          //     ontap: () async {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => Scaffold(
          //             backgroundColor: Color(0xFF0D0D0D),
          //             appBar: AppBar(
          //               backgroundColor: Color(0xFF1A1A1A),
          //               title: Text(
          //                 'Our Blogs',
          //                 style: TextStyle(color: Colors.white),
          //               ),
          //               iconTheme: IconThemeData(color: Colors.white),
          //               elevation: 0,
          //             ),
          //             body: WebViewWidget(controller: controllerone),
          //           ),
          //         ),
          //       );
          //     }
          // ),
          // _buildMenuItem('Our Website', FontAwesomeIcons.solidNewspaper,
          //     gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
          //     ontap: () async {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => Scaffold(
          //             backgroundColor: Color(0xFF0D0D0D),
          //             appBar: AppBar(
          //               backgroundColor: Color(0xFF1A1A1A),
          //               title: Text(
          //                 'Flutter Content',
          //                 style: TextStyle(color: Colors.white),
          //               ),
          //               iconTheme: IconThemeData(color: Colors.white),
          //               elevation: 0,
          //             ),
          //             body: WebViewWidget(controller: controllertwo),
          //           ),
          //         ),
          //       );
          //     }
          // ),
          // _buildMenuItem('Subscribe Us', FontAwesomeIcons.youtube,
          //     gradient: [Color(0xFFFF0000), Color(0xFFCC0000)],
          //     ontap: () async {
          //       var url = 'https://www.youtube.com/channel/UCeJnnsTq-Lh9E16kCEK49rQ?sub_confirmation=1';
          //       await launch(url);
          //     }
          // ),
          SizedBox(height: 20),
          Divider(color: Color(0xFF333333), thickness: 1),
          SizedBox(height: 10),
          _buildMenuItem('About', Icons.info_rounded,
              gradient: [Color(0xFF74B9FF), Color(0xFF0984E3)],
              ontap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Color(0xFF333333)),
                      ),
                      title: Text(
                        'About This App',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: overviewtext(
                        'This App is made by Harshit Ramani. User can explore and get details of latest Movies/series. TMDB API is used to fetch data.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFE50914),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
          ),
          _buildMenuItem('Quit', Icons.exit_to_app_rounded,
              gradient: [Color(0xFF636E72), Color(0xFF2D3436)],
              ontap: () {
                SystemNavigator.pop();
              }
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, {
    required List<Color> gradient,
    Function? ontap
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF2D2D2D),
            Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color(0xFF333333).withValues(alpha:0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: ontap as void Function()?,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha:0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF666666),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}