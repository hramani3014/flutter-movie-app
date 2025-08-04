import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:movieapp/HomePage.dart';
import 'package:movieapp/RepeatedFunction/TrailerUI.dart';
import 'package:movieapp/RepeatedFunction/favoriateandshare.dart';
import 'package:movieapp/RepeatedFunction/reviewui.dart';
import 'package:movieapp/RepeatedFunction/sliderlist.dart';
import 'package:movieapp/apikey/apikey.dart';

class TvSeriesDetails extends StatefulWidget {
  var id;
  TvSeriesDetails({super.key, this.id});

  @override
  State<TvSeriesDetails> createState() => _TvSeriesDetailsState();
}

class _TvSeriesDetailsState extends State<TvSeriesDetails> with TickerProviderStateMixin {
  var tvseriesdetaildata;
  List<Map<String, dynamic>> TvSeriesDetails = [];
  List<Map<String, dynamic>> TvSeriesREview = [];
  List<Map<String, dynamic>> similarserieslist = [];
  List<Map<String, dynamic>> recommendserieslist = [];
  List<Map<String, dynamic>> seriestrailerslist = [];
  List SeriesGenres = [];

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

  Future<void> tvseriesdetailfunc() async {
    var tvseriesdetailurl =
        'https://api.themoviedb.org/3/tv/${widget.id}?api_key=$apikey';
    var tvseriesreviewurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/reviews?api_key=$apikey';
    var similarseriesurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/similar?api_key=$apikey';
    var recommendseriesurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/recommendations?api_key=$apikey';
    var seriestrailersurl =
        'https://api.themoviedb.org/3/tv/${widget.id}/videos?api_key=$apikey';

    var tvseriesdetailresponse = await http.get(Uri.parse(tvseriesdetailurl));
    if (tvseriesdetailresponse.statusCode == 200) {
      tvseriesdetaildata = jsonDecode(tvseriesdetailresponse.body);
      for (var i = 0; i < 1; i++) {
        TvSeriesDetails.add({
          'backdrop_path': tvseriesdetaildata['backdrop_path'],
          'title': tvseriesdetaildata['original_name'],
          'vote_average': tvseriesdetaildata['vote_average'],
          'overview': tvseriesdetaildata['overview'],
          'status': tvseriesdetaildata['status'],
          'releasedate': tvseriesdetaildata['first_air_date'],
          'total_episodes': tvseriesdetaildata['number_of_episodes']?.toInt() ?? 0,
          'total_seasons': tvseriesdetaildata['number_of_seasons']?.toInt() ?? 0,
        });
      }

      // Store genres separately for easier access
      for (var i = 0; i < tvseriesdetaildata['genres'].length; i++) {
        SeriesGenres.add(tvseriesdetaildata['genres'][i]['name']);
        TvSeriesDetails.add({
          'genre': tvseriesdetaildata['genres'][i]['name'],
        });
      }

      for (var i = 0; i < tvseriesdetaildata['created_by'].length; i++) {
        TvSeriesDetails.add({
          'creator': tvseriesdetaildata['created_by'][i]['name'],
          'creatorprofile': tvseriesdetaildata['created_by'][i]['profile_path'],
        });
      }
      for (var i = 0; i < tvseriesdetaildata['seasons'].length; i++) {
        TvSeriesDetails.add({
          'season': tvseriesdetaildata['seasons'][i]['name'],
          'episode_count': tvseriesdetaildata['seasons'][i]['episode_count']?.toInt() ?? 0,
        });
      }
    }

    // TV Series Review
    var tvseriesreviewresponse = await http.get(Uri.parse(tvseriesreviewurl));
    if (tvseriesreviewresponse.statusCode == 200) {
      var tvseriesreviewdata = jsonDecode(tvseriesreviewresponse.body);
      for (var i = 0; i < tvseriesreviewdata['results'].length; i++) {
        TvSeriesREview.add({
          'name': tvseriesreviewdata['results'][i]['author'],
          'review': tvseriesreviewdata['results'][i]['content'],
          "rating": tvseriesreviewdata['results'][i]['author_details']['rating'] == null
              ? "Not Rated"
              : tvseriesreviewdata['results'][i]['author_details']['rating'].toString(),
          "avatarphoto": tvseriesreviewdata['results'][i]['author_details']['avatar_path'] == null
              ? "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png"
              : "https://image.tmdb.org/t/p/w500" + tvseriesreviewdata['results'][i]['author_details']['avatar_path'],
          "creationdate": tvseriesreviewdata['results'][i]['created_at'].substring(0, 10),
          "fullreviewurl": tvseriesreviewdata['results'][i]['url'],
        });
      }
    }

    // Similar Series
    var similarseriesresponse = await http.get(Uri.parse(similarseriesurl));
    if (similarseriesresponse.statusCode == 200) {
      var similarseriesdata = jsonDecode(similarseriesresponse.body);
      for (var i = 0; i < similarseriesdata['results'].length; i++) {
        similarserieslist.add({
          'poster_path': similarseriesdata['results'][i]['poster_path'],
          'name': similarseriesdata['results'][i]['original_name'],
          'vote_average': similarseriesdata['results'][i]['vote_average'],
          'id': similarseriesdata['results'][i]['id'],
          'Date': similarseriesdata['results'][i]['first_air_date'],
        });
      }
    }

    // Recommended Series
    var recommendseriesresponse = await http.get(Uri.parse(recommendseriesurl));
    if (recommendseriesresponse.statusCode == 200) {
      var recommendseriesdata = jsonDecode(recommendseriesresponse.body);
      for (var i = 0; i < recommendseriesdata['results'].length; i++) {
        recommendserieslist.add({
          'poster_path': recommendseriesdata['results'][i]['poster_path'],
          'name': recommendseriesdata['results'][i]['original_name'],
          'vote_average': recommendseriesdata['results'][i]['vote_average'],
          'id': recommendseriesdata['results'][i]['id'],
          'Date': recommendseriesdata['results'][i]['first_air_date'],
        });
      }
    }

    // TV Series Trailer
    var tvseriestrailerresponse = await http.get(Uri.parse(seriestrailersurl));
    if (tvseriestrailerresponse.statusCode == 200) {
      var tvseriestrailerdata = jsonDecode(tvseriestrailerresponse.body);
      for (var i = 0; i < tvseriestrailerdata['results'].length; i++) {
        if (tvseriestrailerdata['results'][i]['type'] == "Trailer") {
          seriestrailerslist.add({
            'key': tvseriestrailerdata['results'][i]['key'],
          });
        }
      }
      if (seriestrailerslist.isEmpty) {
        seriestrailerslist.add({'key': 'aJ0cZTcTh90'});
      }
    } else {
      seriestrailerslist.add({'key': 'aJ0cZTcTh90'});
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
        future: tvseriesdetailfunc(),
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
                            _buildSeriesInfo(),
                            _buildStorySection(),
                            _buildReviewSection(),
                            _buildCreatorsSection(),
                            _buildSeriesDetails(),
                            // _buildSeasonsSection(),
                            _buildSimilarSeries(),
                            _buildRecommendedSeries(),
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
          color: Colors.black.withValues(alpha: 0.7),
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
            color: Colors.black.withValues(alpha: 0.7),
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
                    Color(0xFF0D0D0D).withValues(alpha: 0.3),
                    Color(0xFF0D0D0D).withValues(alpha: 0.8),
                    Color(0xFF0D0D0D),
                  ],
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.cover,
              child: trailerwatch(
                trailerytid: seriestrailerslist.isNotEmpty
                    ? seriestrailerslist[0]['key']
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
                    Color(0xFF0D0D0D).withValues(alpha: 0.7),
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
        type: 'tv',
        Details: TvSeriesDetails,
      ),
    );
  }

  Widget _buildSeriesInfo() {
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
              itemCount: SeriesGenres.length,
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
                              color: _getGenreGradient(index)[0].withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          SeriesGenres[index],
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
          // Status
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
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(TvSeriesDetails[0]['status']),
                    color: _getStatusColor(TvSeriesDetails[0]['status']),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    TvSeriesDetails[0]['status'],
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
            color: Colors.black.withValues(alpha: 0.3),
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
                'Series Overview',
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
            TvSeriesDetails[0]['overview'].toString(),
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
      child: ReviewUI(revdeatils: TvSeriesREview),
    );
  }

  Widget _buildCreatorsSection() {
    if (tvseriesdetaildata['created_by'].isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Color(0xFF333333)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
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
                          colors: [Color(0xFFE17055), Color(0xFFFDCB6E)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Created By',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 120,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: tvseriesdetaildata['created_by'].length,
                    itemBuilder: (context, index) {
                      final creatorIndex = SeriesGenres.length + 1 + index;
                      return Container(
                        margin: EdgeInsets.only(right: 15),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Color(0xFF444444)),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                TvSeriesDetails[creatorIndex]['creatorprofile'] != null
                                    ? 'https://image.tmdb.org/t/p/w500${TvSeriesDetails[creatorIndex]['creatorprofile']}'
                                    : "https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png",
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 80,
                              child: Text(
                                TvSeriesDetails[creatorIndex]['creator'].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeriesDetails() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _buildDetailCard(
            'First Air Date',
            TvSeriesDetails[0]['releasedate'] ?? 'N/A',
            Icons.calendar_today_rounded,
            [Color(0xFF74B9FF), Color(0xFF0984E3)],
          ),
          SizedBox(height: 15),
          _buildDetailCard(
            'Total Seasons',
            (TvSeriesDetails[0]['total_seasons'] as int?)?.toString() ?? 'N/A',
            Icons.video_library_rounded,
            [Color(0xFF00B894), Color(0xFF00CEC9)],
          ),
          SizedBox(height: 15),
          _buildDetailCard(
            'Total Episodes',
            (TvSeriesDetails[0]['total_episodes'] as int?)?.toString() ?? 'N/A',
            Icons.play_circle_outline_rounded,
            [Color(0xFFE17055), Color(0xFFFDCB6E)],
          ),
        ],
      ),
    );
  }

  // Widget _buildSeasonsSection() {
  //   if (tvseriesdetaildata['seasons'].isEmpty) return SizedBox.shrink();
  //
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //     padding: EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
  //       ),
  //       borderRadius: BorderRadius.circular(20),
  //       border: Border.all(color: Color(0xFF333333)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withValues(alpha: 0.3),
  //           blurRadius: 15,
  //           offset: Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Container(
  //               padding: EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
  //                 ),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Icon(
  //                 Icons.list_rounded,
  //                 color: Colors.white,
  //                 size: 20,
  //               ),
  //             ),
  //             SizedBox(width: 12),
  //             Text(
  //               'Seasons',
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //                 letterSpacing: 0.5,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 15),
  //         Container(
  //           height: 100,
  //           child: ListView.builder(
  //             physics: BouncingScrollPhysics(),
  //             scrollDirection: Axis.horizontal,
  //             itemCount: tvseriesdetaildata['seasons'].length,
  //             itemBuilder: (context, index) {
  //               final seasonIndex = SeriesGenres.length + 1 + tvseriesdetaildata['created_by'].length + index;
  //               return Container(
  //                 margin: EdgeInsets.only(right: 12),
  //                 padding: EdgeInsets.all(15),
  //                 decoration: BoxDecoration(
  //                   gradient: LinearGradient(
  //                     colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
  //                   ),
  //                   borderRadius: BorderRadius.circular(15),
  //                   border: Border.all(color: Color(0xFF444444)),
  //                 ),
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text(
  //                       TvSeriesDetails[seasonIndex]['season'].toString(),
  //                       style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                     SizedBox(height: 5),
  //                     Text(
  //                       '${(TvSeriesDetails[seasonIndex]['episode_count'] as int?) ?? 0} Episodes',
  //                       style: TextStyle(
  //                         color: Colors.white70,
  //                         fontSize: 12,
  //                       ),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
            color: Colors.black.withValues(alpha: 0.2),
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
                  color: gradient[0].withValues(alpha: 0.3),
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

  Widget _buildSimilarSeries() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: sliderlist(
        similarserieslist,
        "Similar Series",
        "tv",
        similarserieslist.length,
      ),
    );
  }

  Widget _buildRecommendedSeries() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: sliderlist(
        recommendserieslist,
        "Recommended Series",
        "tv",
        recommendserieslist.length,
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
                    color: Color(0xFFE50914).withValues(alpha: 0.3),
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
              'Loading Series Details...',
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'ended':
        return Icons.stop_circle_rounded;
      case 'returning series':
        return Icons.replay_circle_filled_rounded;
      case 'in production':
        return Icons.video_camera_front_rounded;
      case 'canceled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ended':
        return Color(0xFFE17055);
      case 'returning series':
        return Color(0xFF00B894);
      case 'in production':
        return Color(0xFF74B9FF);
      case 'canceled':
        return Color(0xFFE50914);
      default:
        return Color(0xFFFDCB6E);
    }
  }
}