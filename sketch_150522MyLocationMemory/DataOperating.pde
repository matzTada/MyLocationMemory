class Place {
  String address;
  float lat, lon;
  float x, y;
  int numberOfLine;

  //constructa
  Place(String _address, float _lat, float _lon) {
    address = _address;
    lat = _lat;
    lon = _lon;
    numberOfLine = 0;
  }

  void drawMarker() {
    SimplePointMarker marker = new SimplePointMarker(new Location(lat, lon));
    ScreenPosition pos = marker.getScreenPosition(map);
    x = pos.x;
    y = pos.y;
    float s = 20 + numberOfLine * 5;
    noFill();
    strokeWeight(12);
    strokeCap(SQUARE);
    stroke(0, 0, 255, 100);
    arc(x, y, s, s, -PI * 0.9, -PI * 0.1);
    arc(x, y, s, s, PI * 0.1, PI * 0.9);
    strokeWeight(9);
    strokeCap(SQUARE);
    stroke(255, 255, 255, 200);
    arc(x, y, s, s, -PI * 0.9, -PI * 0.1);
    arc(x, y, s, s, PI * 0.1, PI * 0.9);
    fill(0, 0, 255);
    textSize(15);
    text(address + " #" + numberOfLine, x - textWidth(address+ " #" + numberOfLine) / 2, y + 4);
  }
}

void putNewMarker(String address, float x, float y) {
  Location templocation = map.getLocation(x, y);
  TableRow newRow = locationtable.addRow();
  newRow.setString("address", address);
  newRow.setFloat("latitude", templocation.getLat());
  newRow.setFloat("longitude", templocation.getLon());
  newRow.setString("date", year() + "/" + month() + "/" + day() + "_" +hour() + ":" +minute() + ":" +second());
  saveTable(locationtable, "data/location.csv");
}

void loadLocationTable() {
  locationtable = loadTable("location.csv", "header");
  println("---Location Table--- #rows=" + locationtable.getRowCount());
  for (TableRow row : locationtable.rows ()) {
    print(row.getString("address") + " ") ;
    print(row.getFloat("latitude") + " ");
    print(row.getFloat("longitude") + " ");
    println(row.getString("date"));
  }

  //redefinition of Places
  int i = 0;
  for (TableRow row : locationtable.rows ()) {
    places[i] = new Place(row.getString("address"), row.getFloat("latitude"), row.getFloat("longitude"));
    i++;
  }
}

void saveNewRelation(String address1, String address2) {
  TableRow newRow = relationtable.addRow();
  newRow.setString("address1", address1);
  newRow.setString("address2", address2);
  newRow.setString("date", year() + "/" + month() + "/" + day() + "_" +hour() + ":" +minute() + ":" +second());
  saveTable(relationtable, "data/relation.csv");
}

void loadRelationTable() {
  relationtable = loadTable("relation.csv", "header");
  println("---Relation Table--- #rows=" + relationtable.getRowCount());
  for (TableRow row : relationtable.rows ()) {
    print(row.getString("address1") + " ");
    print(row.getString("address2") + " ");
    println(row.getString("date"));
  }
}

void getRelation() {//make or remake relation array
  //initialization
  for (int i = 0; i < locationtable.getRowCount (); i++)
    for (int j = 0; j < locationtable.getRowCount (); j++) 
      relationarray[i][j] = 0;
  //(re)load relation array
  for (TableRow rel_row : relationtable.rows ()) {
    int m = 0, n = 0;
    String str_a1, str_a2;
    boolean flag_a1 = false, flag_a2 = false;

    str_a1 = rel_row.getString("address1");
    str_a2 = rel_row.getString("address2");

    for (int i = 0; i < locationtable.getRowCount (); i++) {//even in the worst case, loop once. 
      if (str_a1.equals(places[i].address)) {
        m = i;        
        flag_a1 = true;
      }
      if (str_a2.equals(places[i].address) ) {
        n = i;        
        flag_a2 = true;
      }
      if (flag_a1 && flag_a2) break;
    }
    if (flag_a1 && flag_a2) {
      relationarray[m][n]++;
      places[m].numberOfLine++;
      places[n].numberOfLine++;
    }
  }
  //visualize
  println("---Relation array---");
  for (int i = 0; i < locationtable.getRowCount (); i++) {
    for (int j = 0; j < locationtable.getRowCount (); j++) {
      if (relationarray[i][j] == 0) print(". ");
      else print(relationarray[i][j] + " ");
    }
    println("");
  }
}

void drawRelation() {//draw relation line
  for (int i = 0; i < locationtable.getRowCount (); i++) {
    for (int j = i + 1; j < locationtable.getRowCount (); j++) {
      float linewidth = 0;
      linewidth = relationarray[i][j] + relationarray[j][i];
      if (linewidth > 0) {
        stroke(0, 0, 200, 150);
        strokeWeight(linewidth*2);
        line(places[i].x, places[i].y, places[j].x, places[j].y);
        noStroke();
      }
    }
  }
}

void drawInputmode() {
  fill(255, 0, 0, 150);
  rect(0, 0, width, height);
  fill(255);
  textFont(loadFont("ComicSansMS-Bold-32.vlw"));
  text("Input Mode", 10, 30);
  noFill();
  text("Input place: " + input_str, width/2 - textWidth("Input place: " + input_str) / 2, height/2);
  text("input_str1: " + input_str1, width/2 - textWidth("input_str1: " + input_str1) / 2, height/2+32);
  text("input_str2: " + input_str2, width/2 - textWidth("input_str2: " + input_str2) / 2, height/2+32+32);
}

