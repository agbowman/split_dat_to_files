CREATE PROGRAM dms_query_event:dba
 CALL echo("<==================== Entering DMS_QUERY_MEDIA Script ====================>")
 SET modify = predeclare
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 end_id = f8
    1 qual[*]
      2 dms_media_instance_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF ((request->max_records <= 0))
  GO TO end_script
 ENDIF
 FREE SET qualcount
 DECLARE qualcount = i4 WITH noconstant(0)
 FREE SET startid
 DECLARE startid = f8 WITH constant(cnvtreal(request->start_id))
 FREE SET contenttypeclause
 DECLARE contenttypeclause = vc WITH noconstant("ct.content_type_key != NULL")
 IF ((request->content_type != null))
  SET contenttypeclause = build("ct.content_type_key=",request->content_type)
 ENDIF
 CALL echo(build("Content Type Clause->",contenttypeclause))
 FREE SET createdbyidclause
 DECLARE createdbyidclause = vc WITH noconstant("dme.created_by_id != NULL")
 IF ((0 < request->created_by_id))
  SET createdbyidclause = build("dme.created_by_id=",request->created_by_id)
 ENDIF
 CALL echo(build("CreatedById Clause->",createdbyidclause))
 FREE SET eventidclause
 DECLARE eventidclause = vc WITH noconstant("dme.dms_event_ref_id != NULL")
 IF (size(trim(request->event_key)) > 0)
  SELECT INTO "nl:"
   dmr.dms_ref_id
   FROM dms_ref dmr
   WHERE dmr.ref_group="MEDIAEVENT"
    AND (dmr.ref_key=request->event_key)
   DETAIL
    eventidclause = build("dme.dms_event_ref_id=",dmr.dms_ref_id)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("EventId Clause->",eventidclause))
 IF ((request->beg_event_dt_tm=null))
  GO TO end_script
 ENDIF
 IF ((request->end_event_dt_tm=null))
  GO TO end_script
 ENDIF
 FREE SET withclause
 DECLARE withclause = vc WITH noconstant("nocounter")
 IF ((0 < request->max_records))
  SET withclause = build("maxqual (dme, ",(request->max_records+ 1),")")
 ENDIF
 CALL echo(build("With Clause->",withclause))
 FREE SET wehavesetcontinuation
 DECLARE wehavesetcontinuation = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  dme.*
  FROM dms_event dme,
   dms_media_instance dmi,
   dms_content_type ct
  PLAN (dme
   WHERE parser(createdbyidclause)
    AND dme.event_dt_tm >= cnvtdatetime(request->beg_event_dt_tm)
    AND dme.event_dt_tm <= cnvtdatetime(request->end_event_dt_tm)
    AND parser(eventidclause)
    AND ((dme.dms_event_id+ 0) > startid))
   JOIN (dmi
   WHERE dmi.dms_media_instance_id=dme.dms_media_instance_id)
   JOIN (ct
   WHERE ct.dms_content_type_id=dmi.dms_content_type_id
    AND parser(contenttypeclause))
  ORDER BY dme.dms_media_instance_id
  HEAD REPORT
   qualcount = 0
  HEAD dme.dms_media_instance_id
   qualcount += 1
   IF ((qualcount <= request->max_records))
    IF (mod(qualcount,10)=1)
     stat = alterlist(reply->qual,(qualcount+ 9))
    ENDIF
    reply->qual[qualcount].dms_media_instance_id = dmi.dms_media_instance_id
    IF ((request->max_records=qualcount))
     reply->end_id = dme.dms_event_id
    ENDIF
   ELSE
    IF (wehavesetcontinuation=0)
     wehavesetcontinuation = 1
    ENDIF
   ENDIF
  FOOT REPORT
   IF ((qualcount < request->max_records))
    stat = alterlist(reply->qual,qualcount)
   ELSE
    stat = alterlist(reply->qual,request->max_records)
   ENDIF
  WITH parser(withclause)
 ;end select
 IF (qualcount <= 0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_QUERY_EVENT Script ====================>")
END GO
