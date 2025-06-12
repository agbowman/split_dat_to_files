CREATE PROGRAM dms_query_media:dba
 CALL echo("<==================== Entering DMS_QUERY_MEDIA Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 end_id = vc
    1 qual[*]
      2 identifier = vc
      2 version = i4
      2 content_type = vc
      2 content_uid = vc
      2 content_size = i4
      2 media_type = vc
      2 thumbnail_uid = vc
      2 created_dt_tm = dq8
      2 created_by_id = f8
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
 FREE SET withclause
 DECLARE withclause = vc WITH noconstant("nocounter")
 IF ((0 < request->max_records))
  SET withclause = build("maxqual (dmi, ",(request->max_records+ 1),")")
 ENDIF
 CALL echo(withclause)
 FREE SET contenttypeclause
 DECLARE contenttypeclause = vc WITH noconstant("dmi.content_type != NULL")
 IF (0 < size(request->content_type))
  SET contenttypeclause = build("dmi.content_type='",request->content_type,"'")
 ENDIF
 CALL echo(contenttypeclause)
 FREE SET createdbyidclause
 DECLARE createdbyidclause = vc WITH noconstant("dmi.created_by_id != NULL")
 IF ((0 < request->created_by_id))
  SET createdbyidclause = build("dmi.created_by_id=",request->created_by_id)
 ENDIF
 CALL echo(createdbyidclause)
 FREE SET begcreateddttmclause
 DECLARE begcreateddttmclause = vc WITH noconstant("dmi.created_dt_tm != NULL")
 IF ((request->beg_created_dt_tm != null))
  SET begcreateddttmclause = "dmi.created_dt_tm >= cnvtdatetime (request->beg_created_dt_tm)"
 ENDIF
 CALL echo(begcreateddttmclause)
 FREE SET endcreateddttmclause
 DECLARE endcreateddttmclause = vc WITH noconstant("dmi.created_dt_tm != NULL")
 IF ((request->end_created_dt_tm != null))
  SET endcreateddttmclause = "dmi.created_dt_tm <= cnvtdatetime (request->end_created_dt_tm)"
 ENDIF
 CALL echo(endcreateddttmclause)
 FREE SET endid
 DECLARE endid = f8 WITH noconstant(0.0)
 FREE SET wehavesetcontinuation
 DECLARE wehavesetcontinuation = i2 WITH noconstant(0)
 SELECT INTO "nl:"
  dmi.*
  FROM dms_media_instance dmi
  WHERE parser(createdbyidclause)
   AND parser(begcreateddttmclause)
   AND parser(endcreateddttmclause)
   AND parser(contenttypeclause)
   AND ((dmi.dms_media_instance_id+ 0) > startid)
  ORDER BY dms_media_instance_id
  HEAD REPORT
   qualcount = 0
  DETAIL
   qualcount = (qualcount+ 1)
   IF ((qualcount <= request->max_records))
    IF (mod(qualcount,10)=1)
     stat = alterlist(reply->qual,(qualcount+ 9))
    ENDIF
    reply->qual[qualcount].identifier = dmi.identifier, reply->qual[qualcount].version = dmi.version,
    reply->qual[qualcount].content_type = dmi.content_type,
    reply->qual[qualcount].content_uid = dmi.content_uid, reply->qual[qualcount].content_size = dmi
    .content_size, reply->qual[qualcount].media_type = dmi.media_type,
    reply->qual[qualcount].thumbnail_uid = dmi.thumbnail_uid, reply->qual[qualcount].created_dt_tm =
    dmi.created_dt_tm, reply->qual[qualcount].created_by_id = dmi.created_by_id
    IF ((request->max_records=qualcount))
     endid = dmi.dms_media_instance_id
    ENDIF
   ELSE
    IF (wehavesetcontinuation=0)
     reply->end_id = cnvtstring(endid), wehavesetcontinuation = 1
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
 CALL echo("<==================== Exiting DMS_QUERY_MEDIA Script ====================>")
END GO
