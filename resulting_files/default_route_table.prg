CREATE PROGRAM default_route_table
 FREE DEFINE def_route
 SELECT INTO TABLE "def_route.dat"
  ttime = fillstring(30," "), tkey = fillstring(30," "), activity_type_num = fillstring(15," "),
  activity_type_cdm = fillstring(100," "), activity_type_display = fillstring(100," ")
  FROM dummyt
  ORDER BY ttime
  WITH organization = i
 ;end select
 DEFINE def_route "def_route.dat"  WITH modify
 DELETE  FROM def_route
  WHERE 1=1
 ;end delete
END GO
