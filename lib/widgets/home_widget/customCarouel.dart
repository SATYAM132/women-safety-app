import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/quates.dart';
import 'package:flutter_application_1/widgets/home_widget/safewebview.dart';

class CustomCarouel  extends StatelessWidget {
  const CustomCarouel ({super.key});

void navigateToRoute(BuildContext context, Widget route){
   Navigator.push(context, CupertinoPageRoute(builder: (context) => route));
}


  @override
  Widget build(BuildContext context) {
    return Container(
      child: CarouselSlider(items:List.generate(imageSliders.length,
       (index) => Card(
        elevation: 5.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: (){
            if(index == 0){
              navigateToRoute(context, 
              SafeWebView(url: "https://amritmahotsav.nic.in/blogdetail.htm?75",));
            } else if(index == 1){
              navigateToRoute(context, 
              SafeWebView(url: "https://www.unwomen.org/en/news/stories/2020/11/compilation-take-action-to-help-end-violence-against-women",));
            } else if(index == 2){
              navigateToRoute(context, 
              SafeWebView(url: "https://blog.hubspot.com/sales/quotes-about-change",));
            } else {
              navigateToRoute(context, 
              SafeWebView(url: "https://www.positivityblog.com/you-are-stronger-than-you-think-quotes/",));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
             
              
                image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageSliders[index]))
            ),
            
            child: Align(
              
              alignment: Alignment.bottomLeft, 
              child:Padding(padding: const EdgeInsets.only(bottom: 8, left: 8),
            child :
            Text(articleTitle[index], 
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.05,),
            
            ),
            )
            )
          ),
        ),
      )
      ) ,
       options: CarouselOptions(
        aspectRatio: 2.0,
        autoPlay: true,
        enlargeCenterPage: true,
      )),
    );
     
  }
}