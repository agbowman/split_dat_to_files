CREATE PROGRAM bed_ext_name_value:dba
 SELECT INTO "CER_INSTALL:name_value.csv"
  FROM br_name_value b
  ORDER BY b.br_name_value_id
  HEAD REPORT
   "display,mean,key1"
  DETAIL
   display = concat('"',trim(b.br_value),'"'), mean = concat('"',trim(b.br_name),'"'), nv_key =
   concat('"',trim(b.br_nv_key1),'"'),
   row + 1, line = concat(trim(display),",",trim(mean),",",trim(nv_key)), line
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO
