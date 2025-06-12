CREATE PROGRAM cdi_get_all_work_queues:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 codesetlist[*]
      2 code = f8
      2 display = c40
      2 description = c60
      2 meaning = c12
      2 active_ind = i2
    1 logical_domain_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE sline = vc WITH protect, constant(fillstring(70,"-"))
 DECLARE dstarttime = f8 WITH private, noconstant(curtime3)
 DECLARE delapsedtime = f8 WITH private, noconstant(0.0)
 DECLARE dstat = f8 WITH protect, noconstant(0.0)
 DECLARE lqueuecount = i4 WITH protect, noconstant(0)
 DECLARE sscriptstatus = c1 WITH protect, noconstant("F")
 DECLARE sscriptmsg = vc WITH protect, noconstant("Script Error")
 DECLARE iunknownqueueind = i2 WITH protect, noconstant(0)
 CALL echorecord(reqinfo)
 RECORD add_work_queue_request(
   1 queue_qual[*]
     2 display = c40
     2 description = c60
     2 active_ind = i2
     2 code_value_qual[*]
       3 code_set = i4
       3 code_value = f8
       3 collation_seq = i4
     2 prsnl_qual[*]
       3 person_id = f8
       3 exception_ind = i2
     2 time_qual[*]
       3 open_days_bitmap = i4
       3 open_time = i4
       3 close_time = i4
     2 rule_qual[*]
       3 criteria_qual[*]
         4 variable_cd = f8
         4 comparison_flag = i2
         4 value_cd = f8
         4 value_nbr = i4
         4 value_dt_tm = dq8
         4 value_txt = vc
         4 value_entity_id = f8
         4 value_entity_name = vc
         4 value_entity_dbl_id = f8
     2 attr_cnfg_qual[*]
       3 attr_code_value = f8
       3 req_ind = i2
       3 warn_ind = i2
       3 multi_select_enable_ind = i2
     2 error_queue_ind = i2
     2 default_authenticated_ind = i2
     2 pagination_ind = i2
     2 reg_action_keys_txt = vc
 )
 RECORD add_work_queue_reply(
   1 queue_qual[*]
     2 status = c1
     2 status_reason = vc
     2 work_queue_cd = f8
     2 work_queue_id = f8
     2 display = vc
   1 elapsed_time = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SELECT INTO "nl:"
  FROM prsnl p,
   cdi_work_queue wq,
   code_value cv
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
   JOIN (wq
   WHERE wq.logical_domain_id=p.logical_domain_id)
   JOIN (cv
   WHERE cv.code_value=wq.work_queue_cd)
  HEAD REPORT
   lqueuecount = 0, reply->logical_domain_id = wq.logical_domain_id
  DETAIL
   lqueuecount += 1
   IF (mod(lqueuecount,10)=1)
    dstat = alterlist(reply->codesetlist,(lqueuecount+ 9))
   ENDIF
   reply->codesetlist[lqueuecount].code = wq.work_queue_cd, reply->codesetlist[lqueuecount].display
    = cv.display, reply->codesetlist[lqueuecount].description = cv.description,
   reply->codesetlist[lqueuecount].meaning = cv.cdf_meaning, reply->codesetlist[lqueuecount].
   active_ind = cv.active_ind
   IF ((reply->codesetlist[lqueuecount].meaning="ERROR_QUEUE"))
    iunknownqueueind = 1
   ENDIF
  FOOT REPORT
   dstat = alterlist(reply->codesetlist,lqueuecount)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET sscriptstatus = "Z"
 ELSE
  SET sscriptstatus = "S"
 ENDIF
 IF (iunknownqueueind=0)
  CALL alterlist(add_work_queue_request->queue_qual,1)
  SET add_work_queue_request->queue_qual[1].display = "Unknown Queue"
  SET add_work_queue_request->queue_qual[1].description = "Unknown Queue"
  SET add_work_queue_request->queue_qual[1].active_ind = 1
  SET add_work_queue_request->queue_qual[1].error_queue_ind = 1
  EXECUTE cdi_add_work_queue  WITH replace("REQUEST",add_work_queue_request), replace("REPLY",
   add_work_queue_reply)
  IF ((add_work_queue_reply->status="F"))
   SET sscriptstatus = "F"
  ELSEIF ((add_work_queue_reply->status="S"))
   SET sscriptstatus = "S"
   SET lqueuecount += 1
   SET dstat = alterlist(reply->codesetlist,lqueuecount)
   SET reply->codesetlist[lqueuecount].code = add_work_queue_reply->queue_qual[1].work_queue_cd
   SET reply->codesetlist[lqueuecount].display = add_work_queue_reply->queue_qual[1].display
   SET reply->codesetlist[lqueuecount].description = "Unknown Queue"
   SET reply->codesetlist[lqueuecount].meaning = "ERROR_QUEUE"
   SET reply->codesetlist[lqueuecount].active_ind = 1
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = sscriptstatus
 IF (sscriptstatus="F")
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "FAILURE"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_all_work_queues"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSEIF (sscriptstatus="Z")
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_all_work_queues"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = sscriptmsg
 ELSE
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "cdi_get_all_work_queues"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Work Items Found"
 ENDIF
END GO
