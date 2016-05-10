/*
 2015/May/25
 Supporting for my poor memory
 Display Marker from GPS data
 Draw relationship between places
 Search GPS data from address input
 */

import de.fhpotsdam.unfolding.*;
import de.fhpotsdam.unfolding.geo.*;
import de.fhpotsdam.unfolding.utils.*;
import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.marker.*;

import http.requests.*;

UnfoldingMap map;
AbstractMapProvider provider1;
AbstractMapProvider provider2;
AbstractMapProvider provider3;
DebugDisplay debugDisplay;

//definition of location
Location yagamiLocation = new Location(35.555622f, 139.65392f);
float templat = 35.555622, templon = 139.65392;

//location and relation data
int NUMplaces = 100;
Table locationtable; //table for loading lat & lon from table
Table relationtable;
int relationarray[][] = new int[NUMplaces][NUMplaces];

//Place class for address
Place places[] = new Place[NUMplaces];
int stepin = 0;
int tempstepin = 0;

//keyboard input
String input_str = "";
String input_str1 = "";
String input_str2 = "";
boolean inputmode = false;
int input_strflag = 0;

void setup() {
  size(1200, 900);

  provider1 = new Google.GoogleMapProvider();
  provider2 = new Microsoft.AerialProvider();
  provider3 = new StamenMapProvider.Toner();

  map = new UnfoldingMap(this, "myLocationMemory", provider1);
  map.zoomAndPanTo(yagamiLocation, 11);
  MapUtils.createDefaultEventDispatcher(this, map);

  //create debug display
  debugDisplay = new DebugDisplay(this, map);

  loadLocationTable();
  loadRelationTable();
  getRelation();
}

void draw() {
  map.draw();
  debugDisplay.draw();

  //Draw marker
  SimplePointMarker yagamiMarker = new SimplePointMarker(yagamiLocation);
  ScreenPosition yagamiPos = yagamiMarker.getScreenPosition(map); //Get x and y from Latitude and longitude
  strokeWeight(12);
  stroke(200, 0, 0, 200);
  strokeCap(SQUARE);
  noFill();
  float s = 30;
  arc(yagamiPos.x, yagamiPos.y, s, s, -PI *0.9, -PI *0.1);
  arc(yagamiPos.x, yagamiPos.y, s, s, PI *0.1, PI *0.9);
  fill(0);
  text("Yagami", yagamiPos.x - textWidth("Yagami") /2, yagamiPos.y + 4); 

  //draw marker of locationtable
  for (int i = 0; i < locationtable.getRowCount (); i++) {
    places[i].drawMarker();
  }

  //draw relation line from rrelationtable
  drawRelation();

  //Get Latitude and longitude from mouseX, mouseY
  Location location = map.getLocation(mouseX, mouseY);
  fill(255);
  text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);

  //if inputmode = true, overlay the inputmode layer
  if (inputmode) {
    drawInputmode();
  }
}  

void keyPressed() {
  if (inputmode) {//input mode
    switch(key) {
    case 8: //backspace
    case 127: //delete
      input_str = "";
      break;
    case '\n': //input_str end
      int foundflag = 0;
      if (input_str.length() > 0) {
        print(input_str);
        for (int i = 0; i < locationtable.getRowCount (); i++) {
          if (input_str.equals(places[i].address)) foundflag++;
        }
        if (foundflag == 0) {
          getDatafromWeb(input_str); //if input_str is not found in location table, get location by Web
          loadLocationTable();
        }
      }
      if (input_strflag == 0) {
        input_str1 = input_str;
        input_str = "";
        input_strflag = 1;
        break;
      } else if (input_strflag ==1) {
        input_str2 = input_str;

        //if multi input come, save the relation between input_str
        if (input_str1.length() >0 &&input_str2.length() >0) {
          saveNewRelation(input_str1, input_str2);
          loadRelationTable();
          getRelation();
        }

        input_str = "";
        input_str1 = "";
        input_str2 = "";
        input_strflag = 0;
        inputmode = false; 
        break;
      }
    default:     
      input_str += key;
      break;
    }
  } else { //inputmode = false : normal mode
    switch(key) {
    case '1':
      map.mapDisplay.setProvider(provider1);
      break;
    case '2':
      map.mapDisplay.setProvider(provider2);
      break;
    case '3':
      map.mapDisplay.setProvider(provider3);
      break;
    case 'r':
      map.zoomAndPanTo(yagamiLocation, 11);
      loadLocationTable();
      loadRelationTable();
      getRelation();
      break;
    case 's':
      putNewMarker("MouseSpot", mouseX, mouseY);
      loadLocationTable();
      break;
    case 'i':
      inputmode = true;
      break;
    case 'k':
      println("canvas_" + year() + "_" + month() + "_" + day() + "_" +hour() + ":" +minute() + ":" +second() + ".jpg");
      save("canvas_" + year() + "_" + month() + "_" + day() + "_" +hour() + "_" +minute() + "_" +second() + ".jpg"); //save image for offline
      break;
    default: 
      break;
    }
  }
}

