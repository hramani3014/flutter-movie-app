import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movieapp/HomePage.dart';
import 'package:movieapp/RepeatedFunction/TrailerUI.dart';
import 'package:movieapp/RepeatedFunction/favoriateandshare.dart';
import 'package:movieapp/RepeatedFunction/reviewui.dart';
import 'package:movieapp/RepeatedFunction/sliderlist.dart';
import 'package:movieapp/apikey/apikey.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class MovieDetails extends StatefulWidget {
  var id;
  MovieDetails({super.key, this.id});
  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> with TickerProviderStateMixin {
  List<Map<String, dynamic>> MovieDetails = [];
  List<Map<String, dynamic>> UserREviews = [];
  List<Map<String, dynamic>> similarmovieslist = [];
  List<Map<String, dynamic>> recommendedmovieslist = [];
  List<Map<String, dynamic>> movietrailerslist = [];
  List MoviesGeneres = [];

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize animations
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future Moviedetails() async {
    var moviedetailurl =
        'https://api.themoviedb.org/3/movie/${widget.id}?api_key=$apikey';
    var UserReviewurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/reviews?api_key=$apikey';
    var similarmoviesurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/similar?api_key=$apikey';
    var recommendedmoviesurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/recommendations?api_key=$apikey';
    var movietrailersurl =
        'https://api.themoviedb.org/3/movie/${widget.id}/videos?api_key=$apikey';

    var moviedetailresponse = await http.get(Uri.parse(moviedetailurl));
    if (moviedetailresponse.statusCode == 200) {
      var moviedetailjson = jsonDecode(moviedetailresponse.body);
      for (var i = 0; i < 1; i++) {
        MovieDetails.add({
          "backdrop_path": moviedetailjson['backdrop_path'],
          "title": moviedetailjson['title'],
          "vote_average": moviedetailjson['vote_average'],
          "overview": moviedetailjson['overview'],
          "release_date": moviedetailjson['release_date'],
          "runtime": moviedetailjson['runtime'],
          "budget": moviedetailjson['budget'],
          "revenue": moviedetailjson['revenue'],
        });
      }
      for (var i = 0; i < moviedetailjson['genres'].length; i++) {
        MoviesGeneres.add(moviedetailjson['genres'][i]['name']);
      }
    }

    var UserReviewresponse = await http.get(Uri.parse(UserReviewurl));
    if (UserReviewresponse.statusCode == 200) {
      var UserReviewjson = jsonDecode(UserReviewresponse.body);
      for (var i = 0; i < UserReviewjson['results'].length; i++) {
        UserREviews.add({
          "name": UserReviewjson['results'][i]['author'],
          "review": UserReviewjson['results'][i]['content'],
          "rating":
          UserReviewjson['results'][i]['author_details']['rating'] == null
              ? "Not Rated"
              : UserReviewjson['results'][i]['author_details']['rating']
              .toString(),
          "avatarphoto": UserReviewjson['results'][i]['author_details']
          ['avatar_path'] ==
              null
              ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
              : "https://image.tmdb.org/t/p/w500" +
              UserReviewjson['results'][i]['author_details']['avatar_path'],
          "creationdate":
          UserReviewjson['results'][i]['created_at'].substring(0, 10),
          "fullreviewurl": UserReviewjson['results'][i]['url'],
        });
      }
    }

    var similarmoviesresponse = await http.get(Uri.parse(similarmoviesurl));
    if (similarmoviesresponse.statusCode == 200) {
      var similarmoviesjson = jsonDecode(similarmoviesresponse.body);
      for (var i = 0; i < similarmoviesjson['results'].length; i++) {
        similarmovieslist.add({
          "poster_path": similarmoviesjson['results'][i]['poster_path'],
          "name": similarmoviesjson['results'][i]['title'],
          "vote_average": similarmoviesjson['results'][i]['vote_average'],
          "Date": similarmoviesjson['results'][i]['release_date'],
          "id": similarmoviesjson['results'][i]['id'],
        });
      }
    }

    var recommendedmoviesresponse =
    await http.get(Uri.parse(recommendedmoviesurl));
    if (recommendedmoviesresponse.statusCode == 200) {
      var recommendedmoviesjson = jsonDecode(recommendedmoviesresponse.body);
      for (var i = 0; i < recommendedmoviesjson['results'].length; i++) {
        recommendedmovieslist.add({
          "poster_path": recommendedmoviesjson['results'][i]['poster_path'],
          "name": recommendedmoviesjson['results'][i]['title'],
          "vote_average": recommendedmoviesjson['results'][i]['vote_average'],
          "Date": recommendedmoviesjson['results'][i]['release_date'],
          "id": recommendedmoviesjson['results'][i]['id'],
        });
      }
    }

    var movietrailersresponse = await http.get(Uri.parse(movietrailersurl));
    if (movietrailersresponse.statusCode == 200) {
      var movietrailersjson = jsonDecode(movietrailersresponse.body);
      for (var i = 0; i < movietrailersjson['results'].length; i++) {
        if (movietrailersjson['results'][i]['type'] == "Trailer") {
          movietrailerslist.add({
            "key": movietrailersjson['results'][i]['key'],
          });
        }
      }
      movietrailerslist.add({'key': 'aJ0cZTcTh90'});
    }

    // Start animations after data is loaded
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: FutureBuilder(
        future: Moviedetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CustomScrollView(
              physics: BouncingScrollPhysics(),
              slivers: [
                _buildSliverAppBar(),
                SliverList(
                  delegate: SliverChildListDelegate([
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            _buildFavoriteSection(),
                            _buildMovieInfo(),
                            _buildStorySection(),
                            _buildReviewSection(),
                            _buildMovieDetails(),
                            _buildSimilarMovies(),
                            _buildRecommendedMovies(),
                            // _buildFooter(),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ],
            );
          } else {
            return _buildLoadingState();
          }
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: MediaQuery.of(context).size.height * 0.45,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF333333)),
        ),
        child: IconButton(
          onPressed: () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: [SystemUiOverlay.bottom]);
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
            Navigator.pop(context);
          },
          icon: Icon(FontAwesomeIcons.circleArrowLeft),
          iconSize: 24,
          color: Colors.white,
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha:0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF333333)),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false,
              );
            },
            icon: Icon(FontAwesomeIcons.houseUser),
            iconSize: 20,
            color: Colors.white,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0xFF0D0D0D).withValues(alpha:0.3),
                    Color(0xFF0D0D0D).withValues(alpha:0.8),
                    Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.cover,
              child: trailerwatch(
                trailerytid: movietrailerslist.isNotEmpty
                    ? movietrailerslist[0]['key']
                    : 'aJ0cZTcTh90',
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF0D0D0D).withValues(alpha:0.7),
                    Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: addtofavoriate(
        id: widget.id,
        type: 'movie',
        Details: MovieDetails,
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Genres
          Container(
            height: 50,
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: MoviesGeneres.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  duration: Duration(milliseconds: 600 + (index * 100)),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getGenreGradient(index),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _getGenreGradient(index)[0].withValues(alpha:0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          MoviesGeneres[index],
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 15),
          // Runtime
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Color(0xFF333333)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.3),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: Color(0xFFE50914),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${MovieDetails[0]['runtime']} min',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFF333333)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Movie Story',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            MovieDetails[0]['overview'].toString(),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ReviewUI(revdeatils: UserREviews),
    );
  }

  Widget _buildMovieDetails() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _buildDetailCard(
            'Release Date',
            MovieDetails[0]['release_date'],
            Icons.calendar_today_rounded,
            [Color(0xFF74B9FF), Color(0xFF0984E3)],
          ),
          SizedBox(height: 15),
          _buildDetailCard(
            'Budget',
            '\$${_formatCurrency(MovieDetails[0]['budget'])}',
            Icons.attach_money_rounded,
            [Color(0xFF00B894), Color(0xFF00CEC9)],
          ),
          SizedBox(height: 15),
          _buildDetailCard(
            'Revenue',
            '\$${_formatCurrency(MovieDetails[0]['revenue'])}',
            Icons.trending_up_rounded,
            [Color(0xFFE17055), Color(0xFFFDCB6E)],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon, List<Color> gradient) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFF333333)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.2),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
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
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarMovies() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: sliderlist(
        similarmovieslist,
        "Similar Movies",
        "movie",
        similarmovieslist.length,
      ),
    );
  }

  Widget _buildRecommendedMovies() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: sliderlist(
        recommendedmovieslist,
        "Recommended Movies",
        "movie",
        recommendedmovieslist.length,
      ),
    );
  }

  // Widget _buildFooter() {
  //   return Container(
  //     height: 80,
  //     margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
  //       ),
  //       borderRadius: BorderRadius.circular(15),
  //       border: Border.all(color: Color(0xFF333333)),
  //     ),
  //     child: Center(
  //       child: Text(
  //         "Crafted with ❤️ by Harshit Ramani",
  //         style: TextStyle(
  //           color: Colors.white70,
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //           letterSpacing: 0.5,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF0D0D0D),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE50914), Color(0xFFB20710)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE50914).withValues(alpha:0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Loading Movie Details...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGenreGradient(int index) {
    List<List<Color>> gradients = [
      [Color(0xFFE50914), Color(0xFFB20710)],
      [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
      [Color(0xFF00B894), Color(0xFF00CEC9)],
      [Color(0xFF74B9FF), Color(0xFF0984E3)],
      [Color(0xFFFDCB6E), Color(0xFFE17055)],
      [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    ];
    return gradients[index % gradients.length];
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null || amount == 0) return 'N/A';

    double value = amount.toDouble();
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}