CREATE PROGRAM aps_get_db_codeset:dba
 RECORD reply(
   1 code_value_counter = i4
   1 code_value_qual[10]
     2 code_value = f8
     2 display = c40
     2 description = vc
     2 cdf_meaning = c12
     2 active_ind = i2
     2 primary_ind = i2
     2 updt_cnt = i4
     2 collation_seq = i4
   1 cdf_counter = i4
   1 cdf_qual[1]
     2 cdf_meaning = c12
     2 cdf_display = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET x = 0
 SET err_cnt = 0
 SELECT INTO "nl:"
  c.code_value, c.display, c.description,
  c.updt_cnt
  FROM code_value c
  WHERE (request->code_set=c.code_set)
  HEAD REPORT
   reply->code_value_counter = 0, x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alter(reply->code_value_qual,(x+ 9))
   ENDIF
   reply->code_value_qual[x].code_value = c.code_value, reply->code_value_qual[x].display = c.display,
   reply->code_value_qual[x].description = c.description,
   reply->code_value_qual[x].cdf_meaning = c.cdf_meaning, reply->code_value_qual[x].active_ind = c
   .active_ind, reply->code_value_qual[x].updt_cnt = c.updt_cnt,
   reply->code_value_qual[x].collation_seq = c.collation_seq, reply->code_value_counter = x
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "CODE_VALUE"
 ELSE
  SET stat = alter(reply->code_value_qual,reply->code_value_counter)
 ENDIF
 IF ((request->cdf_ind != "Y"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cdf.cdf_meaning
  FROM common_data_foundation cdf
  WHERE (request->code_set=cdf.code_set)
  HEAD REPORT
   reply->cdf_counter = 0, x = 0
  DETAIL
   x = (x+ 1)
   IF (x > 1)
    stat = alter(reply->cdf_qual,x)
   ENDIF
   reply->cdf_qual[x].cdf_meaning = cdf.cdf_meaning, reply->cdf_qual[x].cdf_display = cdf.display,
   reply->cdf_counter = x
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  IF (err_cnt > 1)
   SET stat = alter(reply->status_data.subeventstatus,err_cnt)
  ENDIF
  SET reply->status_data.subeventstatus[err_cnt].operationname = "SELECT"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "Z"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = "COMMON_DATA_FOUNDATION"
 ENDIF
#exit_script
 IF (failed="F")
  IF ((reply->code_value_counter=0)
   AND (reply->cdf_counter=0))
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
