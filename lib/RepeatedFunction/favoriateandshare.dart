import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movieapp/SqfLitelocalstorage/NoteDbHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class addtofavoriate extends StatefulWidget {
  var id, type, Details;
  addtofavoriate({
    super.key,
    this.id,
    this.type,
    this.Details,
  });

  @override
  State<addtofavoriate> createState() => _addtofavoriateState();
}

class _addtofavoriateState extends State<addtofavoriate>
    with TickerProviderStateMixin {
  Color? favoriatecolor;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    checkfavoriate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Future checkfavoriate() async {
    FavMovielist()
        .search(widget.id.toString(), widget.Details[0]['title'].toString(),
        widget.type)
        .then((value) {
      setState(() {
        if (value == 0) {
          print('notanythingfound');
          favoriatecolor = Colors.white;
        } else {
          print('surelyfound');
          favoriatecolor = Colors.red;
        }
        _isLoading = false;
      });
    });
    await Future.delayed(Duration(milliseconds: 100));
  }

  addatatbase(
      id,
      name,
      type,
      rating,
      customcolor,
      ) async {
    // Trigger bounce animation
    _bounceController.forward().then((_) => _bounceController.reverse());

    if (customcolor == Colors.white) {
      FavMovielist().insert({
        'tmdbid': id,
        'tmdbtype': type,
        'tmdbname': name,
        'tmdbrating': rating,
      });
      favoriatecolor = Colors.red;
      Fluttertoast.showToast(
        msg: "❤️ Added to Favorites!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        // backgroundColor: Color(0xFF333333),
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else if (customcolor == Colors.red) {
      FavMovielist().deletespecific(id, type);
      favoriatecolor = Colors.white;
      Fluttertoast.showToast(
        msg: "💔 Removed from Favorites",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        // backgroundColor: Color(0xFF333333),
        backgroundColor: Colors.blueGrey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFavoriteButton(),
          _buildShareButton(context),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        child: _isLoading
            ? _buildLoadingFavorite()
            : _buildAnimatedFavorite(),
      ),
    );
  }

  Widget _buildLoadingFavorite() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF333333)),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFavorite() {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: GestureDetector(
            onTap: () {
              setState(() {
                addatatbase(
                  widget.id.toString(),
                  widget.Details[0]['title'].toString(),
                  widget.type,
                  widget.Details[0]['vote_average'].toString(),
                  favoriatecolor,
                );
              });
            },
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: favoriatecolor == Colors.red
                      ? [Color(0xFFE50914), Color(0xFFB20710)]
                      : [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: favoriatecolor == Colors.red
                      ? Color(0xFFE50914)
                      : Color(0xFF333333),
                ),
                boxShadow: [
                  BoxShadow(
                    color: favoriatecolor == Colors.red
                        ? Color(0xFFE50914).withValues(alpha:0.3)
                        : Colors.black.withValues(alpha:0.2),
                    blurRadius: favoriatecolor == Colors.red ? 15 : 8,
                    offset: Offset(0, favoriatecolor == Colors.red ? 5 : 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: favoriatecolor == Colors.red ? _pulseAnimation.value : 1.0,
                        child: Icon(
                          favoriatecolor == Colors.red
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  Text(
                    favoriatecolor == Colors.red ? 'Favorited' : 'Add to Favorites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: () => _showShareDialog(context),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFF667EEA).withValues(alpha:0.5)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667EEA).withValues(alpha:0.3),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  'Share',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
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
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Color(0xFF333333)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.5),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogHeader(),
                  SizedBox(height: 25),
                  _buildShareOptions(),
                  SizedBox(height: 20),
                  _buildCopyLinkButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE50914), Color(0xFFB20710)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0xFFE50914).withValues(alpha:0.3),
                blurRadius: 15,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.share_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        SizedBox(height: 15),
        Text(
          'Share Movie',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Choose your platform',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildShareOptions() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF333333).withValues(alpha:0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF555555).withValues(alpha:0.5)),
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildSocialButton(
                FontAwesomeIcons.facebookF,
                Color(0xFF1877F2),
                'Facebook',
                    () async {
                  var url =
                      "https://www.facebook.com/sharer/sharer.php?u=https://www.themoviedb.org/${widget.type}/${widget.id}";
                  await launch(url);
                  Navigator.pop(context);
                },
              ),
              _buildSocialButton(
                FontAwesomeIcons.whatsapp,
                Color(0xFF25D366),
                'WhatsApp',
                    () async {
                  var url =
                      "https://wa.me/?text=Check%20out%20this%20link:%20https://www.themoviedb.org/${widget.type}/${widget.id}";
                  await launch(url);
                  Navigator.pop(context);
                },
              ),
              _buildSocialButton(
                FontAwesomeIcons.linkedinIn,
                Color(0xFF0A66C2),
                'LinkedIn',
                    () async {
                  var url =
                      "https://www.linkedin.com/shareArticle?mini=true&url=https://www.themoviedb.org/${widget.type}/${widget.id}&title=Movie Hunt&summary=Check%20out%20this%20link:%20https://www.themoviedb.org/${widget.type}/${widget.id}&source=Movie%20Hunt";
                  await launch(url);
                  Navigator.pop(context);
                },
              ),
              _buildSocialButton(
                FontAwesomeIcons.twitter,
                Color(0xFF1DA1F2),
                'Twitter',
                    () async {
                  var url =
                      "https://twitter.com/intent/tweet?text=Check%20out%20this%20link:%20https://www.themoviedb.org/${widget.type}/${widget.id}";
                  await launch(url);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha:0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyLinkButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(
            text: "https://www.themoviedb.org/${widget.type}/${widget.id}"));
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "🔗 Link Copied to Clipboard!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Color(0xFF333333),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDCB6E), Color(0xFFE17055)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFFDCB6E).withValues(alpha:0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.content_copy_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Copy Link',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}