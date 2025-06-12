CREATE PROGRAM bbt_get_modify_desc:dba
 RECORD reply(
   1 qual[*]
     2 option_id = f8
     2 description = c40
     2 active_ind = i2
     2 division_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET modify_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  m.option_id, m.description, m.active_ind,
  m.division_type_flag
  FROM modify_option m
  WHERE option_id > 0
  HEAD REPORT
   err_cnt = 0, modify_cnt = 0
  DETAIL
   modify_cnt = (modify_cnt+ 1), stat = alterlist(reply->qual,modify_cnt), reply->qual[modify_cnt].
   option_id = m.option_id,
   reply->qual[modify_cnt].description = m.description, reply->qual[modify_cnt].active_ind = m
   .active_ind, reply->qual[modify_cnt].division_type_flag = m.division_type_flag
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "modify option"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return modify options"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
