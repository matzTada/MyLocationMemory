/*
http://www.geocoding.jp/api/
 so nice!!!
 you can use google map -like api on the website by Aoha
 "GET" request to the site and... that's all
 you can get XML format data
 */

import http.requests.*;

Table locationtable;
String search_word = "Seatle";

void setup() { 
  //GET XML format data from www.geocoding.jp/api
  GetRequest get = new GetRequest("http://www.geocoding.jp/api/?v=1.1&q=" + search_word);
  get.send();
  String str_responce = get.getContent();
  println("Reponse Content: " + str_responce);

  //extract values of latitude and longitude. string analysis directry... oops
  String address = str_responce.substring(str_responce.indexOf("<address>") + 9, str_responce.indexOf("</address>"));
  float latitude = Float.parseFloat(str_responce.substring(str_responce.indexOf("<lat>") + 5, str_responce.indexOf("</lat>")));
  float longitude = Float.parseFloat(str_responce.substring(str_responce.indexOf("<lng>") + 5, str_responce.indexOf("</lng>")));
  println("---new data from GET HTTP request---");
  println("addreess : " + address);
  println("latitude : " + latitude + " longitude : " + longitude);

  //write new data to location.csv
  locationtable = loadTable("location.csv", "header");
  TableRow newRow = locationtable.addRow();
  newRow.setString("address", address);
  newRow.setFloat("latitude", latitude);
  newRow.setFloat("longitude", longitude);
  newRow.setString("date", year() + "/" + month() + "/" + day() + "_" +hour() + ":" +minute() + ":" +second());
  saveTable(locationtable, "data/location.csv");

  //display current table
  println("---Location Table---");
  for (TableRow row : locationtable.rows ()) {
    print(row.getString("address") + " ") ;
    print(row.getFloat("latitude") + " ");
    print(row.getFloat("longitude") + " ");
    println(row.getString("date"));
  }
}

