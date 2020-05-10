import 'package:great_circle_distance2/great_circle_distance2.dart';

class LocationService {

  bool getDistance(lat1, long1, lat2, long2, radius) {
     var distance = GreatCircleDistance.fromDegrees(latitude1: lat1, latitude2: lat2, longitude1: long1, longitude2: long2);
     if(distance.haversineDistance() > radius) {
       return true;
     } 
     return false;
  }

}