CREATE PROGRAM dms_get_media_codes:dba
 CALL echo("<==================== Entering DMS_GET_MEDIA_CODES Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 code_key = vc
      2 code_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET qualcount
 DECLARE qualcount = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF (size(trim(request->content_type)) > 0
  AND cnvtupper(trim(request->code_group))="REASON")
  SELECT INTO "nl:"
   dmc.content_type_key, dmc.dms_content_type_id, der.*,
   dmr.dms_ref_id, dmr.ref_group, dmr.ref_key,
   dmr.display
   FROM dms_event_reason_r der,
    dms_ref dmr,
    dms_content_type dmc
   PLAN (dmc
    WHERE dmc.content_type_key=cnvtupper(request->content_type))
    JOIN (der
    WHERE der.dms_content_type_id=dmc.dms_content_type_id)
    JOIN (dmr
    WHERE dmr.dms_ref_id=der.dms_reason_ref_id)
   ORDER BY dmr.display
   HEAD REPORT
    qualcount = 0
   DETAIL
    qualcount += 1
    IF (mod(qualcount,10)=1)
     stat = alterlist(reply->qual,(qualcount+ 9))
    ENDIF
    reply->qual[qualcount].code_key = dmr.ref_key, reply->qual[qualcount].code_display = dmr.display
   FOOT REPORT
    stat = alterlist(reply->qual,qualcount)
   WITH nocounter
  ;end select
 ELSEIF (size(trim(request->code_group)) > 0)
  SELECT INTO "nl:"
   dmr.*
   FROM dms_ref dmr
   WHERE dmr.ref_group=cnvtupper(trim(request->code_group))
   ORDER BY dmr.display
   HEAD REPORT
    qualcount = 0
   DETAIL
    qualcount += 1
    IF (mod(qualcount,10)=1)
     stat = alterlist(reply->qual,(qualcount+ 9))
    ENDIF
    reply->qual[qualcount].code_key = dmr.ref_key, reply->qual[qualcount].code_display = dmr.display
   FOOT REPORT
    stat = alterlist(reply->qual,qualcount)
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_MEDIA_CODES Script ====================>")
END GO
