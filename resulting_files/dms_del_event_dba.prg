CREATE PROGRAM dms_del_event:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD longtext(
   1 qual[*]
     2 long_text_id = f8
 )
 FREE SET qualcount
 DECLARE qualcount = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  dme.long_text_id
  FROM dms_event dme,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  PLAN (d)
   JOIN (dme
   WHERE (dme.dms_media_instance_id=request->qual[d.seq].dms_media_instance_id)
    AND dme.long_text_id > 0)
  HEAD REPORT
   qualcount = 0
  DETAIL
   qualcount += 1
   IF (mod(qualcount,10)=1)
    stat = alterlist(longtext->qual,(qualcount+ 9))
   ENDIF
   longtext->qual[qualcount].long_text_id = dme.long_text_id
  FOOT REPORT
   stat = alterlist(longtext->qual,qualcount)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("dms_del_event: ",errmsg)
  GO TO end_script
 ENDIF
 DELETE  FROM dms_event dme,
   (dummyt d  WITH seq = value(size(request->qual,5)))
  SET dme.seq = 1
  PLAN (d)
   JOIN (dme
   WHERE (dme.dms_media_instance_id=request->qual[d.seq].dms_media_instance_id))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) > 0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("dms_del_event: ",errmsg)
  GO TO end_script
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 IF (value(size(longtext->qual,5)) > 0)
  DELETE  FROM long_text lt,
    (dummyt d  WITH seq = value(size(longtext->qual,5)))
   SET lt.seq = 1
   PLAN (d)
    JOIN (lt
    WHERE (lt.long_text_id=longtext->qual[d.seq].long_text_id))
   WITH nocounter
  ;end delete
  IF (error(errmsg,0) > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat("dms_del_event: ",errmsg)
   GO TO end_script
  ENDIF
  IF (curqual=0)
   SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "LONG_TEXT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Error deleting row from LONG_TEXT table."
   GO TO end_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#end_script
END GO
