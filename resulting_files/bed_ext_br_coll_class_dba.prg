CREATE PROGRAM bed_ext_br_coll_class:dba
 SELECT INTO "CER_INSTALL:br_coll_class.csv"
  FROM br_coll_class b
  ORDER BY b.activity_type, b.collection_class
  HEAD REPORT
   "activity_type,collection_class,proposed_name_suffix"
  DETAIL
   act_type = concat('"',trim(b.activity_type),'",'), coll_class = concat('"',trim(b.collection_class
     ),'",'), suffix = concat('"',trim(b.proposed_name_suffix),'"'),
   line = concat(trim(act_type),trim(coll_class),trim(suffix)), row + 1, line
  WITH maxcol = 500, noformfeed, format = variable,
   nocounter
 ;end select
END GO
