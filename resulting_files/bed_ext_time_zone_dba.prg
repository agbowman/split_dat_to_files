CREATE PROGRAM bed_ext_time_zone:dba
 SELECT INTO "CER_INSTALL:time_zones.csv"
  FROM br_time_zone b
  ORDER BY b.region, b.sequence
  HEAD REPORT
   "description,time_zone,region,sequence"
  DETAIL
   description = concat('"',trim(b.description),'"'), time_zone = concat('"',trim(b.time_zone),'"'),
   region = concat('"',trim(b.region),'"'),
   row + 1, line = concat(trim(description),",",trim(time_zone),",",trim(region),
    ",",trim(cnvtstring(b.sequence))), line
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO
