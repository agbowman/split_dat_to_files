CREATE PROGRAM dcp_get_pw_processing_status:dba
 SET modify = predeclare
 RECORD reply(
   1 processing_status_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE n_processing_status_unknown = i2 WITH protect, constant(0)
 DECLARE n_processing_status_processing = i2 WITH protect, constant(1)
 DECLARE n_processing_status_failed_in_processing = i2 WITH protect, constant(2)
 DECLARE n_processing_status_not_processing = i2 WITH protect, constant(3)
 DECLARE getpwprocessingstatus(updatecount=i4,processingupdatecount=i4,processingdttm=dq8,
  staleinminutes=i4) = i2
 SUBROUTINE getpwprocessingstatus(updatecount,processingupdatecount,processingdttm,staleinminutes)
   DECLARE expiredttm = dq8 WITH private
   SET expiredttm = cnvtlookahead(build('"',staleinminutes,',MIN"'),cnvtdatetime(processingdttm))
   IF (expiredttm > cnvtdatetime(curdate,curtime3))
    IF (updatecount < processingupdatecount)
     RETURN(n_processing_status_processing)
    ELSE
     RETURN(n_processing_status_not_processing)
    ENDIF
   ELSE
    IF (updatecount >= processingupdatecount)
     RETURN(n_processing_status_not_processing)
    ELSE
     RETURN(n_processing_status_failed_in_processing)
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE s_script_name = vc WITH protect, constant("dcp_get_pw_processing_status")
 DECLARE d_pathway_id = f8 WITH protect, constant(request->pathway_id)
 DECLARE l_update_count = i4 WITH protect, constant(request->update_count)
 DECLARE lupdatecount = i4 WITH protect, noconstant(l_update_count)
 DECLARE l_stale_in_minutes = i4 WITH protect, constant(evaluate(request->stale_in_minutes,0,10,
   request->stale_in_minutes))
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE isubeventstatuscount = i4 WITH protect, noconstant(0)
 DECLARE isubeventstatussize = i4 WITH protect, noconstant(value(size(reply->status_data.
    subeventstatus,5)))
 DECLARE set_script_status(cstatus=c1,soperationname=vc,coperationstatus=c1,stargetobjectname=vc,
  stargetobjectvalue=vc) = null
 SET reply->status_data.status = "S"
 SET reply->processing_status_flag = n_processing_status_unknown
 IF (d_pathway_id <= 0.0)
  CALL set_script_status("Z","BEGIN","Z",s_script_name,"The pathway_id was not valid.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM pathway pw
  PLAN (pw
   WHERE pw.pathway_id=d_pathway_id)
  DETAIL
   lupdatecount = pw.updt_cnt
  WITH nocounter
 ;end select
 IF (curqual > 0
  AND l_update_count < lupdatecount)
  SET reply->processing_status_flag = n_processing_status_processing
 ELSE
  SELECT INTO "nl:"
   FROM pw_processing_action ppa
   PLAN (ppa
    WHERE ppa.pathway_id=d_pathway_id)
   DETAIL
    reply->processing_status_flag = getpwprocessingstatus(lupdatecount,ppa.processing_updt_cnt,
     cnvtdatetime(ppa.processing_start_dt_tm),l_stale_in_minutes)
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->processing_status_flag = n_processing_status_not_processing
  ENDIF
 ENDIF
 SUBROUTINE set_script_status(cstatus,soperationname,coperationstatus,stargetobjectname,
  stargetobjectvalue)
   SET reply->status_data.status = cstatus
   SET isubeventstatuscount = (isubeventstatuscount+ 1)
   IF (isubeventstatuscount > isubeventstatussize)
    SET isubeventstatussize = (isubeventstatussize+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,isubeventstatussize)
   ENDIF
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationname = substring(1,25,trim(
     soperationname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].operationstatus = trim(
    coperationstatus)
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectname = substring(1,25,trim
    (stargetobjectname))
   SET reply->status_data.subeventstatus[isubeventstatuscount].targetobjectvalue = trim(
    stargetobjectvalue)
 END ;Subroutine
#exit_script
END GO
