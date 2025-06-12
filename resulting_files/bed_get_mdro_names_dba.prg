CREATE PROGRAM bed_get_mdro_names:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 name[*]
      2 id = f8
      2 name = vc
      2 name_key = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 DECLARE mdro_name_cnt = i4
 DECLARE temp_cnt = i4
 SELECT INTO "nl:"
  FROM br_mdro mn
  PLAN (mn
   WHERE mn.br_mdro_id > 0)
  HEAD REPORT
   mdro_name_cnt = 0, temp_cnt = 0, stat = alterlist(reply->name,10)
  DETAIL
   mdro_name_cnt = (mdro_name_cnt+ 1), temp_cnt = (temp_cnt+ 1)
   IF (temp_cnt > 10)
    temp_cnt = 1, stat = alterlist(reply->name,(mdro_name_cnt+ 10))
   ENDIF
   reply->name[mdro_name_cnt].id = mn.br_mdro_id, reply->name[mdro_name_cnt].name = mn.mdro_name,
   reply->name[mdro_name_cnt].name_key = mn.mdro_name_key
  FOOT REPORT
   stat = alterlist(reply->name,mdro_name_cnt), temp_cnt = 0
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Error on selecting mdro names"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
