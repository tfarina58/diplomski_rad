import 'package:diplomski_rad/other/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import 'package:diplomski_rad/interfaces/estate.dart';
import 'package:diplomski_rad/pages/estates/estate-details.dart';
import 'dart:math';
import 'package:diplomski_rad/services/language.dart';

class MapsWidget extends StatefulWidget {
  List<Estate> estates;
  LanguageService lang;
  // String? customerId;

  MapsWidget({Key? key, required this.lang, this.estates = const []})
      : super(key: key);

  @override
  State<MapsWidget> createState() => _MapsWidgetState();
}

class _MapsWidgetState extends State<MapsWidget> {
  @override
  Widget build(BuildContext context) {
    LatLng mapCenter = getMapCenter();
    double zoom = getMapZoom(mapCenter);

    return FlutterMap(
      options: MapOptions(
        center: mapCenter,
        zoom: zoom,
        maxZoom: 17,
        minZoom: 1.7,
      ),
      nonRotatedChildren: [
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: getMarkerLayer(),
        ),
      ],
    );
  }

  LatLng getMapCenter() {
    if (widget.estates.isEmpty) return const LatLng(0, 0);

    int k = 0;
    double lat = 0, lng = 0;

    for (int i = 0; i < widget.estates.length; ++i) {
      if (widget.estates[i].coordinates != null) {
        lat += widget.estates[i].coordinates!.latitude;
        lng += widget.estates[i].coordinates!.longitude;
        k++;
      }
    }
    return LatLng(
      lat /= (k != 0 ? k : 1),
      lng /= (k != 0 ? k : 1)
    );
  }

  double getMapZoom(LatLng center) {
    if (widget.estates.isEmpty) return 1.5;
    return 8;
  }

  double distance(double lat1, double long1, double lat2, double long2) {
    lat1 = (pi) / 180 * lat1;
    long1 = (pi) / 180 * long1;
    lat2 = (pi) / 180 * lat2;
    long2 = (pi) / 180 * long2;

    // Haversine Formula
    double dlong = long2 - long1;
    double dlat = lat2 - lat1;

    double ans = pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlong / 2), 2);

    ans = 2 * asin(sqrt(ans));

    // Radius of Earth in
    // Kilometers, R = 6371
    // Use R = 3956 for miles
    double R = 6371;

    ans = ans * R;

    return ans;
  }

  List<Marker> getMarkerLayer() {
    List<Marker> markerList = [];
    for (int i = 0; i < widget.estates.length; ++i) {
      if (widget.estates[i].coordinates == null) continue;
      markerList.add(
        Marker(
          point: LatLng(
            widget.estates[i].coordinates!.latitude,
            widget.estates[i].coordinates!.longitude,
          ),
          builder: (context) => MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EstateDetailsPage(estate: widget.estates[i]),
                ),
              ),
              child: Tooltip(
                decoration: const BoxDecoration(
                  color: PalleteCommon.backgroundColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(3),
                  ),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PalleteCommon.gradient2,
                ),
                message: widget.estates[i].name[widget.lang.language],
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: PalleteCommon.backgroundColor,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.house,
                      color: PalleteCommon.gradient3,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return markerList;
  }
}
