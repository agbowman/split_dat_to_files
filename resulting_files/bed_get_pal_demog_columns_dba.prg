CREATE PROGRAM bed_get_pal_demog_columns:dba
 FREE SET reply
 RECORD reply(
   1 columns[*]
     2 name = vc
     2 description = vc
     2 detail_code_value = f8
     2 column_type_code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SELECT INTO "nl:"
  FROM br_pal_columns b
  PLAN (b
   WHERE b.section="Demographic")
  ORDER BY b.column_name
  HEAD b.column_name
   ccnt = (ccnt+ 1), stat = alterlist(reply->columns,ccnt), reply->columns[ccnt].name = b.column_name,
   reply->columns[ccnt].description = b.column_description, reply->columns[ccnt].detail_code_value =
   b.column_cd, reply->columns[ccnt].column_type_code_value = b.column_type_cd
  WITH nocounter
 ;end select
 CALL echorecord(reply)
#exit_script
 IF (ccnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
