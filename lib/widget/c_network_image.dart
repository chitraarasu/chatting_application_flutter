import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget getNetworkImage(
    BuildContext context, String image, double width, double height,
    {Color? color, BoxFit boxFit = BoxFit.contain}) {
  return CachedNetworkImage(
    imageUrl: image,
    imageBuilder: (context, imageProvider) => Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.fill,
        ),
      ),
    ),
    placeholder: (context, url) => Container(
      color: Colors.grey,
      width: double.infinity,
      height: double.infinity,
    ),
    errorWidget: (context, url, error) => Container(
      color: Colors.grey,
      width: double.infinity,
      height: double.infinity,
      child: Center(
          child: Icon(
        Icons.error,
        color: Colors.white,
      )),
    ),
    color: color,
    width: width,
    height: height,
    fit: boxFit,
    // scale: FetchPixels.getScale(),
  );
}
