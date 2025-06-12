CREATE PROGRAM aps_solcap_nicelabel:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.1.00090.2"
 SET reply->solcap[1].degree_of_use_num = 0
 SET reply->solcap[1].degree_of_use_str = "NO"
 SET stat = alterlist(reply->solcap[1].other,1)
 SET reply->solcap[1].other[1].category_name =
 "Number of inventory items distributed in a flat file with NiceLabel, grouped by inventory type"
 SET stat = alterlist(reply->solcap[1].other[1].value,3)
 SET reply->solcap[1].other[1].value[1].display = "Specimens"
 SET reply->solcap[1].other[1].value[1].value_num = 0
 SET reply->solcap[1].other[1].value[1].value_str = "NO"
 SET reply->solcap[1].other[1].value[2].display = "Cassettes"
 SET reply->solcap[1].other[1].value[2].value_num = 0
 SET reply->solcap[1].other[1].value[2].value_str = "NO"
 SET reply->solcap[1].other[1].value[3].display = "Slides"
 SET reply->solcap[1].other[1].value[3].value_num = 0
 SET reply->solcap[1].other[1].value[3].value_str = "NO"
 SELECT INTO "nl:"
  specimencnt = count(cs.case_specimen_id), cs.label_create_type_flag
  FROM case_specimen cs
  WHERE cs.label_create_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
   AND cs.label_create_type_flag=3
  GROUP BY cs.label_create_type_flag
  DETAIL
   reply->solcap[1].other[1].value[1].value_num = specimencnt, reply->solcap[1].other[1].value[1].
   value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
   specimencnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cassettecnt = count(c.cassette_id), c.label_create_type_flag
  FROM cassette c
  WHERE c.label_create_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
   AND c.label_create_type_flag=3
  GROUP BY c.label_create_type_flag
  DETAIL
   reply->solcap[1].other[1].value[2].value_num = cassettecnt, reply->solcap[1].other[1].value[2].
   value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
   cassettecnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  slidecnt = count(s.slide_id), s.label_create_type_flag
  FROM slide s
  WHERE s.label_create_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   end_dt_tm)
   AND s.label_create_type_flag=3
  GROUP BY s.label_create_type_flag
  DETAIL
   reply->solcap[1].other[1].value[3].value_num = slidecnt, reply->solcap[1].other[1].value[3].
   value_str = "YES", reply->solcap[1].degree_of_use_num = (reply->solcap[1].degree_of_use_num+
   slidecnt)
  WITH nocounter
 ;end select
 IF ((reply->solcap[1].degree_of_use_num > 0))
  SET reply->solcap[1].degree_of_use_str = "YES"
 ENDIF
END GO
