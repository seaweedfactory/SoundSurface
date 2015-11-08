import org.processing.wiki.triangulate.*;
import peasy.*;

class GISPoint
{
  public double latitude;
  double longitude;
  String date;
  String time;
  int sound;
  int light;
  double normX;
  double normY;
  double normZ;
  int readings;

  GISPoint()
  {
    latitude = 0.0;
    longitude = 0.0;
    date = "";
    time = "";
    sound = 0;
    light = 0;
    normX = 0;
    normY = 0;
    normZ = 0;
    readings = 1;
  }
}

GISPoint[] points;
ArrayList<Triangle> surface;
int frm = 0;
float zoom = 40000;
PeasyCam cam;

void setup()
{
  size(1728,1152, P3D);
  points = readPoints("data.txt");
  spreadReadings(points);
  normAroundCenter(points);
  points = smoothData(points, 0.002);
  surface = delan(points, zoom);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(50000);
  frameRate(24);
}

void draw()
{
  if(frm % 100 == 0)
  {
    saveFrame(frm + ".png");
  }
  frm++;
  if (frm >= points.length)
  {
    frm = 0;
    exit();
  }

  background(0);
  directionalLight(0, 0, 0, 0, 0, -1);
  ambientLight(32, 32, 32);
  if (points != null)
  {
    float c = (points[frm].light / 1024.0) * 255;
    pointLight(c, c, c, (float)points[frm].normX * zoom, (float)points[frm].normY * zoom, ((float)points[frm].normZ * zoom) + 100);
    cam.lookAt((float)points[frm].normX * zoom, (float)points[frm].normY * zoom, 10, 5000, 50);
    cam.rotateX(200);

    for (int i=0; i < points.length; i++)
    {
      pushMatrix();
      float s=zoom;
      translate((float)points[i].normX * s, (float)points[i].normY * s, -(float)points[i].normZ * s);
      popMatrix();
    }

    // draw the mesh of triangles
    noStroke();
    fill(255, 255);
    pushMatrix();

    if (points[frm].sound > 100)
    {
      stroke(min(points[frm].sound, 255), 128);
    }

    beginShape(TRIANGLES);
    for (int i = 0; i < surface.size(); i++) 
    {
      float m =  random(points[frm].sound / 3);
      Triangle t = (Triangle)surface.get(i);
      vertex(t.p1.x, t.p1.y, t.p1.z + m);
      vertex(t.p2.x, t.p2.y, t.p2.z +m);
      vertex(t.p3.x, t.p3.y, t.p3.z+m);
    }
    endShape();
    popMatrix();
  }
}

public GISPoint[] smoothData(GISPoint[] data, float threshold)
{
  ArrayList<GISPoint> grid = new ArrayList<GISPoint>();
  for (int i=0; i < data.length; i++)
  {
    GISPoint p = data[i];
    int j=0;
    boolean found = false;
    while (j < grid.size () && !found)
    {
      GISPoint q = grid.get(j);
      float dt = dist((float)p.normX, (float)p.normY, (float)p.normZ, (float)q.normX, (float)q.normY, (float)q.normZ);
      if (dt < threshold)
      {
        found = true;
        q.readings++;
        q.light = q.light + p.light;
        q.sound = q.sound + p.sound;
      }
      j++;
    }

    if (!found)
    {
      grid.add(p);
    }
  }

  GISPoint[] retval = new GISPoint[grid.size()];
  for (int i=0; i< grid.size();i++)
  {
    retval[i] = grid.get(i);
    retval[i].sound = retval[i].sound / retval[i].readings;
    retval[i].light = retval[i].light / retval[i].readings;
  }
  return retval;
}

public ArrayList<Triangle> delan(GISPoint[] pointList, float magnitude)
{
  ArrayList<Triangle> triangles = new ArrayList<Triangle>();
  ArrayList<PVector> vecs = new ArrayList<PVector>();
  for (int i=0; i < pointList.length; i++)
  {
    GISPoint p = pointList[i];
    float s = magnitude;
    p.normZ = ((100 - p.sound) / (zoom /7));
    PVector pv = new PVector((float)p.normX * s, (float)p.normY * s, (float)-p.normZ * s);
    vecs.add(pv);
  }
  print("Creating mesh of " + vecs.size() + " points...");
  triangles = Triangulate.triangulate(vecs);
  println("done.");
  return triangles;
}



