import 'package:find_my_stuff/models/category_model.dart';
import 'package:find_my_stuff/models/lost_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<CategoryModel> categories = [];
  List<LostItemModel> lostItems = [];

  void _getInitializationInfo() {
    categories = CategoryModel.getCategories();
    lostItems = LostItemModel.getLostItems();
  }

  @override
  Widget build(BuildContext context) {
    _getInitializationInfo();
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _searchField(),
          SizedBox(height: 40),
          _categoriesSection(),
          SizedBox(height: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20), 
                child: Text('Lost Items', 
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.black,
                  fontWeight: FontWeight.w600)
                )
              ),
              SizedBox(height: 15,),
              Container(
                height: 315,
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    return Container(
                      width: 210,
                      decoration: BoxDecoration(
                        color: lostItems[index].isFound ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 210,
                            height: 150,
                            child: Image.asset(lostItems[index].iconPath,
                            fit: BoxFit.cover)
                          ),
                          SizedBox(height: 15),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: 
                                  Text(
                                  lostItems[index].name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500
                                  ),
                                  ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child:
                                  Text(
                                  lostItems[index].description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child:
                                  Text(
                                  lostItems[index].locationLost,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Text(
                                'Date Lost: ' + lostItems[index].dateLost,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 15),
                              Container(
                                height: 35,
                                width: 150,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff9DCEFF), 
                                      Color(0xff92A3FD)
                                    ]
                                ),
                              )
                              )
                            ],
                          ),
                        ]
                      )
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  separatorBuilder: (context, index) => SizedBox(width: 25),
                  itemCount: lostItems.length,
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20
                  ),
              ),
              )
            ],
            )
        ],
      )
    );
  }

  Column _categoriesSection() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text('Category',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600
              )),
            ),
            SizedBox(height: 20),
            Container(
              height: 140,
              child: ListView.separated(
                itemCount: categories.length,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20
                ),
                separatorBuilder: (context, index) => SizedBox(width: 20),
                itemBuilder: (context, index) {
                  return Container(
                    width: 130,
                    decoration: BoxDecoration(
                      color: categories[index].boxColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8),
                          child: SvgPicture.asset(categories[index].iconPath,)
                          ),
                          Text(
                            categories[index].name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400
                            ),
                          )
                      ],
                    )
                  );
                },
              )
            )
          ],);
  }

  Container _searchField() {
    return Container(
          margin: EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0xff1D1617).withOpacity(0.11),
                blurRadius: 40,
                spreadRadius: 0.0,
              )
            ]
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search Item',
              hintStyle: TextStyle(
                color: Color(0xffDDDADA),
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset('assets/icons/Search.svg'),
              ),
              suffixIcon: Container(
                width: 100,
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      VerticalDivider(
                        color: Colors.black,
                        indent: 10,
                        endIndent: 10,
                        thickness: 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SvgPicture.asset('assets/icons/Filter.svg'),
                      ),
                    ],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none
              )
            )
          ),
        );
  }

  AppBar appBar() {
    return AppBar(
      title: Text('Find My Stuff', 
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: GestureDetector(
        onTap: () {

        },
        child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: SvgPicture.asset(
          'assets/icons/Arrows - Left 2.svg',
          height: 20,
          width: 20
        ),
        decoration: BoxDecoration(
          color: Color(0xffF7F8f8),
          borderRadius: BorderRadius.circular(10)
        )
      ),
      ),
      actions: [
        GestureDetector(
          onTap: () {

          },
          child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          width: 37,
          child: SvgPicture.asset(
            'assets/icons/dots.svg',
            height: 20,
            width: 20
          ),
          decoration: BoxDecoration(
            color: Color(0xffF7F8f8),
            borderRadius: BorderRadius.circular(10)
          )
        ),
        )
      ]
    );
  }
}