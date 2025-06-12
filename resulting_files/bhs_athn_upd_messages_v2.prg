CREATE PROGRAM bhs_athn_upd_messages_v2
 FREE RECORD result
 RECORD result(
   1 pool_ind = i2
   1 tasks[*]
     2 task_id = f8
     2 updt_cnt = i4
     2 assign_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req967142
 RECORD req967142(
   1 task_list[*]
     2 task_id = f8
     2 event_id = f8
     2 event_cd = f8
     2 task_status_cd = f8
     2 task_status_meaning = vc
     2 task_dt_tm = dq8
     2 task_updt_cnt = i4
     2 stat_ind = i2
     2 comments = vc
     2 msg_text = gvc
     2 contributor_system_cd = f8
     2 external_reference_nbr = vc
     2 assign_prsnl_list[*]
       3 assign_prsnl_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_updt_cnt = i4
       3 msg_text = gvc
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
       3 proxy_prsnl_id = f8
     2 assign_person_list[*]
       3 assign_person_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_updt_cnt = i4
       3 msg_text = gvc
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
     2 assign_prsnl_group_list[*]
       3 assign_prsnl_group_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_updt_cnt = i4
       3 msg_text = gvc
       3 assign_prsnl_id = f8
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
     2 scheduled_dt_tm = dq8
     2 remind_dt_tm = dq8
     2 sub_activity_list[*]
     2 encntr_id = f8
 ) WITH protect
 FREE RECORD rep967142
 RECORD rep967142(
   1 task_failure_list[*]
     2 task_id = f8
     2 task_status_cd = f8
     2 task_status_meaning = vc
     2 task_dt_tm = dq8
     2 task_updt_cnt = i4
     2 task_updt_dt_tm = dq8
     2 assign_person_list[*]
       3 assign_prsnl_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_prsnl_updt_cnt = i4
       3 assign_prsnl_updt_dt_tm = dq8
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
     2 assign_person_list[*]
       3 assign_person_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_person_updt_cnt = i4
       3 assign_person_updt_dt_tm = dq8
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
     2 assign_prsnl_group_list[*]
       3 assign_prsnl_group_id = f8
       3 task_status_cd = f8
       3 task_status_meaning = vc
       3 assign_prsnl_group_updt_cnt = i4
       3 assign_prsnl_group_updt_dt_tm = dq8
       3 copy_type_flag = i2
       3 scheduled_dt_tm = dq8
       3 remind_dt_tm = dq8
   1 error_nbr = i4
   1 error_severity = i4
   1 error_description = vc
   1 status_data
     2 status = c1
     2 status_value = i4
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callupdatemessages(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (size(trim( $2,3)) <= 0)
  CALL echo("INVALID TASK ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $3 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ELSEIF (( $4 <= 0.0))
  CALL echo("INVALID STATUS CODE PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->pool_ind = evaluate( $5,0.0,0,1)
 DECLARE taskidparam = vc WITH protect, noconstant("")
 DECLARE startpos = i4 WITH protect, noconstant(0)
 DECLARE endpos = i4 WITH protect, noconstant(0)
 DECLARE param = vc WITH protect, noconstant("")
 DECLARE taskcnt = i4 WITH protect, noconstant(0)
 SET startpos = 1
 SET taskidparam = trim( $2,3)
 CALL echo(build2("TASKIDPARAM IS: ",taskidparam))
 WHILE (size(taskidparam) > 0)
   SET endpos = (findstring(":",taskidparam,1) - 1)
   IF (endpos <= 0)
    SET endpos = size(taskidparam)
   ENDIF
   CALL echo(build("ENDPOS:",endpos))
   IF (startpos < endpos)
    SET param = substring(1,endpos,taskidparam)
    CALL echo(build("PARAM:",param))
    SET taskcnt += 1
    SET stat = alterlist(result->tasks,taskcnt)
    SET result->tasks[taskcnt].task_id = cnvtreal(param)
   ENDIF
   SET taskidparam = substring((endpos+ 2),(size(taskidparam) - endpos),taskidparam)
   CALL echo(build("TASKIDPARAM:",taskidparam))
   CALL echo(build("SIZE(TASKIDPARAM):",size(taskidparam)))
 ENDWHILE
 SELECT INTO "NL:"
  FROM task_activity ta,
   task_activity_assignment taa
  PLAN (ta
   WHERE expand(idx,1,size(result->tasks,5),ta.task_id,result->tasks[idx].task_id)
    AND ta.active_ind=1)
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (((result->pool_ind=0)
    AND (taa.assign_prsnl_id= $3)) OR ((result->pool_ind=1)
    AND (taa.assign_prsnl_group_id= $5)))
    AND taa.active_ind=1)
  ORDER BY ta.task_id
  HEAD ta.task_id
   pos = locateval(locidx,1,size(result->tasks,5),ta.task_id,result->tasks[locidx].task_id)
   IF (pos > 0)
    result->tasks[pos].updt_cnt = ta.updt_cnt, result->tasks[pos].assign_updt_cnt = taa.updt_cnt
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SET stat = callupdatemessages(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM dummyt d
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v1 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v1, row + 1, col + 1,
    "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req967142
 FREE RECORD rep967142
 SUBROUTINE callupdatemessages(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(967100)
   DECLARE requestid = i4 WITH protect, constant(967142)
   FREE RECORD i_request
   RECORD i_request(
     1 prsnl_id = f8
   ) WITH protect
   FREE RECORD i_reply
   RECORD i_reply(
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   ) WITH protect
   SET i_request->prsnl_id =  $3
   CALL echorecord(i_request)
   EXECUTE bhs_athn_impersonate_user  WITH replace("REQUEST","I_REQUEST"), replace("REPLY","I_REPLY")
   IF ((i_reply->status_data.status != "S"))
    CALL echo("IMPERSONATE USER FAILED...EXITING!")
    RETURN(fail)
   ENDIF
   SET stat = alterlist(req967142->task_list,size(result->tasks,5))
   FOR (idx = 1 TO size(result->tasks,5))
     SET req967142->task_list[idx].task_id = result->tasks[idx].task_id
     SET req967142->task_list[idx].task_status_cd =  $4
     SET req967142->task_list[idx].task_updt_cnt = result->tasks[idx].updt_cnt
     IF ((result->pool_ind=0))
      SET stat = alterlist(req967142->task_list[idx].assign_prsnl_list,1)
      SET req967142->task_list[idx].assign_prsnl_list[1].assign_prsnl_id =  $3
      SET req967142->task_list[idx].assign_prsnl_list[1].task_status_cd =  $4
      SET req967142->task_list[idx].assign_prsnl_list[1].assign_updt_cnt = result->tasks[idx].
      assign_updt_cnt
     ELSE
      SET stat = alterlist(req967142->task_list[idx].assign_prsnl_group_list,1)
      SET req967142->task_list[idx].assign_prsnl_group_list[1].assign_prsnl_group_id =  $5
      SET req967142->task_list[idx].assign_prsnl_group_list[1].task_status_cd =  $4
      SET req967142->task_list[idx].assign_prsnl_group_list[1].assign_updt_cnt = result->tasks[idx].
      assign_updt_cnt
     ENDIF
   ENDFOR
   CALL echorecord(req967142)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req967142,
    "REC",rep967142,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep967142)
   IF ((rep967142->status_data.status != "F"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
