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

//Rendering paramaters
int weight = 1; //Width of lines
int squareSize = 9000; //Size of image as a square
float zoom = 40000; //Zoom factor
int zoom2 = 48000; //Corrective zoom factor
int Zintensity = 5; //Exaggeration factor for Z-axis
float smoothFactor= 0.002; //Point smoothing strength
float cameraX = -1.0; //Camera X rotation
float cameraZ = 0.4; //Camera Z rotation
float cameraY = -0.29; //Camera Y rotation
float dataCenterMidFactor = 0.55; //Used to decide where in data should be considered middle
int lightLevel = 100; //Ambient lighting strength

PeasyCam cam;

void setup()
{
  size(squareSize,squareSize, P3D);
  points = readPoints("data.txt");
  spreadReadings(points);
  normAroundCenter(points);
  points = smoothData(points,smoothFactor);
  surface = delan(points, zoom);
  cam = new PeasyCam(this, 100);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(50000);
  frameRate(12);
}

void draw()
{
  //Throw out a few empty frames, then exit after saving
  if(frm % 5 == 0 && frm > 3)
  {
    saveFrame("render.png");
    exit();
  }
  frm++;
  if (frm >= points.length)
  {
    frm = 0;
    exit();
  }

  background(0);
  directionalLight(0, 0, 0, 0, 0, -1);
  ambientLight(lightLevel, lightLevel, lightLevel);
  if (points != null)
  {
    
    //Setup camera
    int displayIndex = (int)(points.length * dataCenterMidFactor);
    cam.lookAt((float)points[displayIndex].normX * zoom, (float)points[displayIndex].normY * zoom, 10, zoom2, 50);
    cam.rotateX(cameraX);
    cam.rotateZ(cameraZ);
    cam.rotateY(cameraY);

    for (int i=0; i < points.length; i++)
    {
      pushMatrix();
      float s=zoom;
      translate((float)points[i].normX * s, (float)points[i].normY * s, -(float)points[i].normZ * s);
      popMatrix();
    }

    //Draw the mesh of triangles
    strokeWeight(weight);
    stroke(255,255);
    fill(0,0);
    
    pushMatrix();

    beginShape(TRIANGLES);
    for (int i = 0; i < surface.size(); i++) 
    {
      Triangle t = (Triangle)surface.get(i);
      vertex(t.p1.x, t.p1.y, t.p1.z);
      vertex(t.p2.x, t.p2.y, t.p2.z);
      vertex(t.p3.x, t.p3.y, t.p3.z);
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
    p.normZ = ((p.sound) / (zoom /5)) * -Zintensity;
    PVector pv = new PVector((float)p.normX * s, (float)p.normY * s, (float)-p.normZ * s);
    vecs.add(pv);
  }
  triangles = Triangulate.triangulate(vecs);
  return triangles;
}
