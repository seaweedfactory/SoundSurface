public GISPoint[] readPoints(String filename)
{
  String[] lines = loadStrings(filename);
  GISPoint[] gps = new GISPoint[lines.length];
  for (int i=0; i < lines.length; i++) 
  {
    String[] tokens=split(lines[i], ',');
    GISPoint gp = new GISPoint();
    String lat = tokens[0];
    String lon = tokens[1];
    gp.date = tokens[2];
    gp.time = tokens[3];
    gp.sound = Integer.parseInt(tokens[4]);
    gp.light = Integer.parseInt(tokens[5]);

    //Add decimal
    if (lat.length() == 8)
    {
      lat = lat.substring(0, 2) + "." + lat.substring(2, 8);
    }
    else if (lat.length() == 9)
    {
      lat = lat.substring(0, 3) + "." + lat.substring(3, 8);
    }

    if (lon.length() == 8)
    {
      lon = lon.substring(0, 2) + "." + lon.substring(2, 9);
    }
    else if (lon.length() == 9)
    {
      lon = lon.substring(0, 3) + "." + lon.substring(3, 9);
    }

    gp.latitude = Double.parseDouble(lat);
    gp.longitude = Double.parseDouble(lon);

    gps[i] = gp;
  }

  return gps;
}


public void spreadReadings(GISPoint[] data)
{
  Double lastLat = data[0].latitude;
  Double lastLon = data[0].longitude;
  int lastIndex = 0;
  for (int i=0; i < data.length; i++)
  {
    Double newLat = data[i].latitude;
    Double newLon = data[i].longitude;
    if (newLat.toString().compareTo(lastLat.toString()) != 0 || newLon.toString().compareTo(lastLon.toString()) != 0)
    {
      Double diffLat = (newLat - lastLat);
      Double diffLon = (newLon - lastLon);
      int pointsToSpread = i - lastIndex;
      Double deltaLat = diffLat / pointsToSpread;
      Double deltaLon = diffLon / pointsToSpread;
      for (int j = 0; j < pointsToSpread; j++)
      {
        data[j + lastIndex].latitude += (deltaLat * j);
        data[j + lastIndex].longitude += (deltaLon * j);
      } 
      lastIndex = i;
      lastLat = newLat;
      lastLon = newLon;
    }
  }
}

public void normAroundCenter(GISPoint[] data)
{
  double maxLat, minLat, maxLon, minLon;
  maxLat = -99999999;
  minLat = 99999999;
  maxLon = -99999999;
  minLon = 99999999;

  //find max and min in each direction
  for (int i=0; i < points.length; i++)
  {
    GISPoint tmpP = points[i];
    maxLat = maxD(tmpP.latitude, maxLat);
    minLat = minD(tmpP.latitude, minLat);
    maxLon = maxD(tmpP.longitude, maxLon);
    minLon = minD(tmpP.longitude, minLon);
  }

  //get center of data
  double centerX = minLat + ((maxLat - minLat) / 2.0);
  double centerY = minLon + ((maxLon - minLon) / 2.0);
  double windowX = Math.abs(maxLat - minLat);
  double windowY = Math.abs(maxLon - minLon);
  
  for (int i=0; i < points.length; i++)
  {
    GISPoint tmpP = points[i];
    tmpP.normX = (tmpP.latitude - centerX) / windowX; 
    tmpP.normY = (tmpP.longitude - centerY) / windowY;
  }
}
