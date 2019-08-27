import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:xiecheng_flutter/dao/home_dao.dart';
import 'package:xiecheng_flutter/model/common_model.dart';
import 'package:xiecheng_flutter/model/grid_nav_model.dart';
import 'package:xiecheng_flutter/model/home_model.dart';
import 'package:xiecheng_flutter/widget/local_nav.dart';
import 'dart:convert';
import '../widget/grid_nav.dart';

const APPBAR_SEROLL_OFFSET = 100;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List _imageUrls = [
    'http://pic39.nipic.com/20140320/12795880_110914420143_2.jpg',
    'http://pic39.nipic.com/20140327/17556992_134152074389_2.jpg',
    'http://pic29.nipic.com/20130516/3895313_131038325107_2.jpg'
  ];

  double appBarAlpha = 0;
  List<CommonModel> localNavList = [];
  GridNavModel gridNavModel;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  _onScroll(offset) {
    double alpha = offset/APPBAR_SEROLL_OFFSET;
    if (alpha < 0) {
      alpha = 0;
    } else if (alpha > 1) {
      alpha = 1;
    }
    setState(() {
      appBarAlpha = alpha;
    });
  }

  loadData() async {
    try {
      HomeModel model = await HomeDao.fetch();
      setState(() {
        localNavList = model.localNavList;
        gridNavModel = model.gridNav;
      });
    } catch (e) {
      setState(() {
        print(e);
      });
    }
  }

//  loadData() {
//    HomeDao.fetch().then((result) {
//      setState(() {
//        resultString = json.encode(result);
//      })
//    }).catchError((e) {
//      setState(() {
//        resultString = e.toString();
//      });
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( //自定义appbar堆在ListView上边
        children: <Widget>[
          MediaQuery.removePadding( //移除状态栏间距
            removeTop: true,
            context: context,
            child: NotificationListener( //监听
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification && scrollNotification.depth == 0) { //排除banner的滚动
                  //滚动且是列表滚动
                  _onScroll(scrollNotification.metrics.pixels);
                }
              },
              child: ListView(
                children: <Widget>[
                  Container(
                    height: 160.0,
                    child: Swiper(
                      itemCount: _imageUrls.length,
                      autoplay: true,
                      itemBuilder: (BuildContext context, int index) {
                        return Image.network(
                          _imageUrls[index],
                          fit: BoxFit.fill,
                        );
                      },
                      pagination: SwiperPagination(), //指示器
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
                    child: LocalNav(localNavList: localNavList,),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
                    child: GridNav(gridNavModel: gridNavModel),
                  ),
                  Container(
                    height: 800,
                    child: ListTile(
                      title: Text('aaa'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Opacity(
            opacity: appBarAlpha,
            child: Container(
              height: 80,
              decoration: BoxDecoration(color: Colors.white),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text('首页'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
