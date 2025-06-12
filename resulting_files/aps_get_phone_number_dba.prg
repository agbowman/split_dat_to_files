CREATE PROGRAM aps_get_phone_number:dba
 RECORD reply(
   1 qual[*]
     2 phone_num = vc
     2 extension = vc
     2 type_cd = f8
     2 type_disp = c40
     2 typef_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM phone p
  PLAN (p
   WHERE (p.parent_entity_name=request->entity_name)
    AND (p.parent_entity_id=request->person_id)
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].phone_num = cnvtphone(p.phone_num,p.phone_format_cd), reply->qual[cnt].extension
    = p.extension, reply->qual[cnt].type_cd = p.phone_type_cd,
   CALL echo(build("phone num =",reply->qual[cnt].phone_num)),
   CALL echo(build("extension =",reply->qual[cnt].extension)),
   CALL echo(build("type cd =",reply->qual[cnt].type_cd))
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PHONE"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
