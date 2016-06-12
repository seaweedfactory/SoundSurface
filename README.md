# SoundSurface
Creates a 3D visualization of a GIS referenced sound and light readings.

Data was collected with a custom-built GPS logger which read ambient sound and light levels. This data is smoothed using linear interpolation to cover gaps in the GPS coverage. The data is also smoothed using a distance threshold which averages readings which are close together. The point data is then converted into a mesh using Delauney triangulation via the Triangulate library.

The height of each point is determined by the ambient sound level, while the position reflects GPS coordinates.The sketch gives a tour of each data point, showing the ambient light level at each point. The tour reveals the data collection process. The sound level at each point also introduces a degrading effect to the mesh depending on density. The mesh becomes noisy when there are higher levels of ambient noise present.

I tried to show how an invisible force like noise maps to the visible world of light. The mesh degradation shows how noise can be equally as disruptive as visible light.

# StaticSoundSurface
This class is used for creating large scale static images of a dataset. Rendering is done in wireframe and all light data is ignored. Several rendering parameters are available in this class.

#Processing Libraries
The sketch uses the Triangulate and peasycam libraries. As the sketch was produced in processing 1.5.1, an earlier version of the peasycam library was required. Copies of the jar for each library used have been included.

#Arduino
The somewhat messy arduino code is available for review in the arduino folder. A standalone GPS module mounted on a prototyping shield was read using the TinyGPS library:

http://arduiniana.org/libraries/tinygps/

The arduino standard SoftwareSerial and SD librraries were used for writing SD card data to the Seeed SD card shield. Another prototyping shield contained a very basic audio amplifier which was read directly using the one of the ADC pins on the Arduino.
