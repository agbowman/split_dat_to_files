CREATE PROGRAM cp_get_document_type
 RECORD reply(
   1 event_cd = f8
   1 event_cd_disp = vc
   1 event_end_dt_tm = dq8
   1 event_end_tz = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET errmsg = fillstring(132," ")
 DECLARE mdoc_cd = f8
 DECLARE doc_cd = f8
 DECLARE proc_cd = f8
 DECLARE rad_cd = f8
 SET stat = uar_get_meaning_by_codeset(53,"MDOC",1,mdoc_cd)
 SET stat = uar_get_meaning_by_codeset(53,"DOC",1,doc_cd)
 SET stat = uar_get_meaning_by_codeset(53,"PROCEDURE",1,proc_cd)
 SET stat = uar_get_meaning_by_codeset(53,"RAD",1,rad_cd)
 SELECT INTO "nl:"
  ce.event_cd
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.event_id=request->event_id)
    AND ce.parent_event_id=ce.event_id
    AND ce.event_class_cd IN (mdoc_cd, doc_cd, proc_cd, rad_cd))
  ORDER BY ce.event_id, ce.valid_until_dt_tm DESC
  HEAD ce.event_id
   reply->event_cd = ce.event_cd, reply->event_cd_disp = uar_get_code_display(ce.event_cd), reply->
   event_end_dt_tm = ce.event_end_dt_tm,
   reply->event_end_tz = validate(ce.event_end_tz,0)
  DETAIL
   do_nothing = 0
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET errorcode = error(errmsg,0)
  IF (errorcode != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.operationname = "Select"
   SET reply->status_data.operationstatus = "F"
   SET reply->status_data.targetobjectname = "ErrorMessage"
   SET reply->status_data.targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
#exit_script
 CALL echorecord(reply)
END GO
