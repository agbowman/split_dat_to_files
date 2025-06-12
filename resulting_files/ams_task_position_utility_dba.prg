CREATE PROGRAM ams_task_position_utility:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Task Description" = "",
  "Task" = 0,
  "Task Type" = 0.000000,
  "Task Activity" = 2695.000000,
  "Position To Chart" = 0,
  "Chart" = "C",
  "Indicator" = "",
  "Over Due" = "1",
  "Units" = "2",
  "Retention" = "7",
  "Retention Units" = "3",
  "Reschedule (Hours)" = "72",
  "Grace Period" = "30",
  "Units" = "M"
  WITH outdev, taskdescription, task,
  tasktype, taskactivity, position,
  chart, indicator, overdue,
  overdueselect, retention, retentionselect,
  reschedule, graceperiod, graceperiodselect
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed_mess = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 DECLARE smessage = vc WITH protect, noconstant("")
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed_mess = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD request
 RECORD request(
   1 reference_task_id = f8
   1 task_description = vc
   1 active_ind = i2
   1 chart_not_cmplt_ind = i2
   1 task_type_cd = f8
   1 quick_chart_done_ind = i2
   1 quick_chart_notdone_ind = i2
   1 quick_chart_ind = i2
   1 allpositionchart_ind = i2
   1 task_activity_cd = f8
   1 overdue_min = i4
   1 overdue_units = i4
   1 reschedule_time = i4
   1 retain_time = i4
   1 retain_units = i4
   1 event_cd = f8
   1 capture_bill_info_ind = i2
   1 ignore_req_ind = i2
   1 grace_period_mins = i4
   1 position_cnt = i4
   1 updt_cnt = i4
   1 buildeventcd_ind = i4
 )
 IF (( $TASKDESCRIPTION != ""))
  SET request->task_description =  $TASKDESCRIPTION
  SET request->chart_not_cmplt_ind = 0
  SET request->buildeventcd_ind = 0
  SET request->task_type_cd =  $TASKTYPE
  IF (( $CHART="C"))
   SET request->quick_chart_done_ind = 1
   SET request->buildeventcd_ind = 1
  ELSEIF (( $CHART="Q"))
   SET request->quick_chart_ind = 1
  ELSEIF (( $CHART="N"))
   SET request->quick_chart_notdone_ind = 1
  ENDIF
  IF (( $POSITION=0))
   SET request->allpositionchart_ind = 1
  ENDIF
  SET request->updt_cnt = 0
  SET request->task_activity_cd =  $TASKACTIVITY
  SET request->overdue_min = cnvtint( $OVERDUE)
  SET request->overdue_units = cnvtint( $OVERDUESELECT)
  SET request->reschedule_time = cnvtint( $RESCHEDULE)
  SET request->retain_time = cnvtint( $RETENTION)
  SET request->retain_units = cnvtint( $RETENTIONSELECT)
  SET request->event_cd = 0.00
  IF (( $INDICATOR="A"))
   SET request->active_ind = 1
  ELSE
   SET request->active_ind = 0
  ENDIF
  IF (( $INDICATOR="C"))
   SET request->capture_bill_info_ind = 1
  ELSE
   SET request->capture_bill_info_ind = 0
  ENDIF
  IF (( $INDICATOR="I"))
   SET request->ignore_req_ind = 1
  ELSE
   SET request->ignore_req_ind = 0
  ENDIF
  IF (( $GRACEPERIODSELECT="H"))
   SET request->grace_period_mins = (cnvtint( $GRACEPERIOD) * 60)
  ELSE
   SET request->grace_period_mins = cnvtint( $GRACEPERIOD)
  ENDIF
  FREE RECORD reply
  RECORD reply(
    1 reference_task_id = f8
    1 event_cd = f8
    1 bill_item_qual = i4
    1 bill_item[*]
      2 bill_item_id = f8
    1 qual[*]
      2 bill_item_id = f8
    1 actioncnt = i2
    1 actionlist[*]
      2 action1 = vc
      2 action2 = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  DECLARE reference_task_id = f8 WITH protect, noconstant(0.0)
  DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
  DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
  DECLARE count1 = i4 WITH protect, noconstant(0)
  DECLARE failed = c1 WITH noconstant("F")
  DECLARE temp_task_description = vc WITH noconstant(fillstring(40," "))
  DECLARE extdesc = vc WITH noconstant(fillstring(100," "))
  DECLARE extshort = vc WITH noconstant(fillstring(50," "))
  DECLARE var1 = i4 WITH noconstant(1)
  DECLARE active = i2 WITH noconstant(0)
  DECLARE code_value = f8 WITH protect, noconstant(0.0)
  DECLARE code_set = f8 WITH protect, noconstant(0.0)
  DECLARE cdf_meaning = vc WITH protect, noconstant(fillstring(12," "))
  DECLARE taskcat_cd = f8 WITH protect, noconstant(0.0)
  DECLARE task_cd = f8 WITH protect, noconstant(0.0)
  DECLARE temp_event_cd = f8 WITH protect, noconstant(0.0)
  SET reply->status_data.status = "F"
  SET extdesc = request->task_description
  SET extshort = cnvtupper(request->task_description)
  SET code_value = 0.0
  SET code_set = 13016
  SET cdf_meaning = "TASKCAT"
  EXECUTE cpm_get_cd_for_cdf
  SET taskcat_cd = code_value
  SET code_value = 0.0
  SET code_set = 106
  SET cdf_meaning = "TASK"
  EXECUTE cpm_get_cd_for_cdf
  SET task_cd = code_value
  IF ((request->buildeventcd_ind=1))
   SET temp_task_description = request->task_description
   SET temp_event_cd = 0
   EXECUTE tsk_post_event_code
   SET request->event_cd = temp_event_cd
  ELSE
   SET temp_event_cd = request->event_cd
  ENDIF
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    reference_task_id = cnvtreal(y)
   WITH counter
  ;end select
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  INSERT  FROM order_task ot
   SET ot.reference_task_id = reference_task_id, ot.active_ind = request->active_ind, ot
    .task_description = request->task_description,
    ot.task_description_key = cnvtupper(request->task_description), ot.chart_not_cmplt_ind = request
    ->chart_not_cmplt_ind, ot.task_type_cd = request->task_type_cd,
    ot.quick_chart_done_ind = request->quick_chart_done_ind, ot.quick_chart_notdone_ind = request->
    quick_chart_notdone_ind, ot.allpositionchart_ind = request->allpositionchart_ind,
    ot.overdue_min = request->overdue_min, ot.reschedule_time = request->reschedule_time, ot
    .retain_time = request->retain_time,
    ot.retain_units = request->retain_units, ot.task_activity_cd = request->task_activity_cd, ot
    .cernertask_flag = 0,
    ot.event_cd = request->event_cd, ot.quick_chart_ind = request->quick_chart_ind, ot.overdue_units
     = request->overdue_units,
    ot.capture_bill_info_ind = request->capture_bill_info_ind, ot.ignore_req_ind = request->
    ignore_req_ind, ot.grace_period_mins = request->grace_period_mins,
    ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot.updt_task =
    reqinfo->updt_task,
    ot.updt_cnt = 0, ot.updt_applctx = reqinfo->updt_applctx
   WITH counter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO exit_script
  ENDIF
  IF ((request->active_ind=1))
   CALL createbill(var1)
  ENDIF
  SUBROUTINE createbill(var)
    FREE SET request
    RECORD request(
      1 nbr_of_recs = i2
      1 qual[1]
        2 action = i2
        2 ext_id = f8
        2 ext_contributor_cd = f8
        2 parent_qual_ind = f8
        2 ext_owner_cd = f8
        2 ext_description = c100
        2 ext_short_desc = c50
        2 build_ind = i2
        2 careset_ind = i2
        2 workload_only_ind = i2
        2 child_qual = i2
        2 price_qual = i2
        2 prices[*]
          3 price_sched_id = f8
          3 price = f8
        2 billcode_qual = i2
        2 billcodes[*]
          3 billcode_sched_cd = f8
          3 billcode = c25
        2 children[*]
          3 ext_id = f8
          3 ext_contributor_cd = f8
          3 ext_description = c100
          3 ext_short_desc = c50
          3 build_ind = i2
          3 ext_owner_cd = f8
    )
    SET request->nbr_of_recs = 1
    SET request->qual[1].action = 1
    SET request->qual[1].ext_id = reference_task_id
    SET request->qual[1].ext_contributor_cd = taskcat_cd
    SET request->qual[1].parent_qual_ind = 1
    SET request->qual[1].careset_ind = 0
    SET request->qual[1].ext_owner_cd = task_cd
    SET request->qual[1].ext_description = extdesc
    SET request->qual[1].ext_short_desc = extshort
    SET request->qual[1].price_qual = 0
    SET request->qual[1].billcode_qual = 0
    SET request->qual[1].child_qual = 0
    EXECUTE afc_add_reference_api
  END ;Subroutine
  IF (failed="T")
   SET reqinfo->commit_ind = 0
  ELSE
   SET reqinfo->commit_ind = 1
   SET reply->status_data.status = "S"
   SET reply->reference_task_id = reference_task_id
   SET reply->event_cd = temp_event_cd
  ENDIF
  FREE RECORD request_add
  RECORD request_add(
    1 reference_task_id = f8
    1 position_cnt = i4
    1 addqual[*]
      2 position_cd = f8
  )
  SELECT INTO "nl:"
   FROM order_task ot
   WHERE (ot.reference_task_id=reply->reference_task_id)
   HEAD REPORT
    r = 0
   HEAD ot.reference_task_id
    r = 0, request_add->reference_task_id = ot.reference_task_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=88
    AND (cv.code_value= $POSITION)
   HEAD REPORT
    r = 0
   DETAIL
    IF (mod(r,10)=0)
     stat = alterlist(request_add->addqual,(r+ 10))
    ENDIF
    r = (r+ 1), request_add->addqual[r].position_cd = cv.code_value
   FOOT REPORT
    stat = alterlist(request_add->addqual,r)
   WITH nocounter
  ;end select
  EXECUTE orm_add_pos_order_task  WITH replace(request,request_add)
 ENDIF
 SET failed_mess = true
 SET serrmsg = "Successfully Updated"
 FREE RECORD task
 RECORD task(
   1 list[*]
     2 reference_task_id = f8
 )
 SELECT INTO "nl:"
  *
  FROM order_task ot
  WHERE (ot.reference_task_id= $TASK)
  HEAD REPORT
   r = 0
  DETAIL
   IF (mod(r,10)=0)
    stat = alterlist(task->list,(r+ 10))
   ENDIF
   r = (r+ 1), task->list[r].reference_task_id = ot.reference_task_id
  FOOT REPORT
   stat = alterlist(task->list,r)
  WITH nocounter
 ;end select
 FOR (x = 1 TO size(task->list,5))
   SELECT INTO "nl:"
    FROM order_task ot
    WHERE (ot.reference_task_id=task->list[x].reference_task_id)
    DETAIL
     request->reference_task_id = ot.reference_task_id, request->task_description = ot
     .task_description, request->active_ind = ot.active_ind,
     request->chart_not_cmplt_ind = 0, request->buildeventcd_ind = 0, request->task_type_cd =
      $TASKTYPE
     IF (( $CHART="C"))
      request->quick_chart_done_ind = 1, request->buildeventcd_ind = 1
     ELSEIF (( $CHART="Q"))
      request->quick_chart_ind = 1
     ELSEIF (( $CHART="N"))
      request->quick_chart_notdone_ind = 1
     ENDIF
     IF (( $POSITION=0))
      request->allpositionchart_ind = 1
     ENDIF
     request->updt_cnt = ot.updt_cnt, request->task_activity_cd =  $TASKACTIVITY, request->
     overdue_min = cnvtint( $OVERDUE),
     request->overdue_units = cnvtint( $OVERDUESELECT), request->reschedule_time = cnvtint(
       $RESCHEDULE), request->retain_time = cnvtint( $RETENTION),
     request->retain_units = cnvtint( $RETENTIONSELECT), request->event_cd = ot.event_cd
     IF (( $INDICATOR="A"))
      request->active_ind = 1
     ELSE
      request->active_ind = 0
     ENDIF
     IF (( $INDICATOR="C"))
      request->capture_bill_info_ind = 1
     ELSE
      request->capture_bill_info_ind = 0
     ENDIF
     IF (( $INDICATOR="I"))
      request->ignore_req_ind = 1
     ELSE
      request->ignore_req_ind = 0
     ENDIF
     IF (( $GRACEPERIODSELECT="H"))
      request->grace_period_mins = (cnvtint( $GRACEPERIOD) * 60)
     ELSE
      request->grace_period_mins = cnvtint( $GRACEPERIOD)
     ENDIF
    WITH nocounter
   ;end select
   SET reply->status_data.status = "F"
   SET cur_updt_cnt = 0
   SET failed = "F"
   SET count1 = 0
   SET tvar1 = 1
   SET var1 = 1
   SET temp_task_description = fillstring(40," ")
   SET reference_task_id = 0.0
   SET extdesc = fillstring(100," ")
   SET extshort = fillstring(50," ")
   SET reference_task_id = request->reference_task_id
   SET extdesc = request->task_description
   SET extshort = cnvtupper(request->task_description)
   SET addbillitem = 0
   SET deletebillitem = 0
   SET code_value = 0.0
   SET code_set = 13016
   SET cdf_meaning = "TASKCAT"
   EXECUTE cpm_get_cd_for_cdf
   SET taskcat_cd = code_value
   SET code_value = 0.0
   SET code_set = 106
   SET cdf_meaning = "TASK"
   EXECUTE cpm_get_cd_for_cdf
   SET task_cd = code_value
   IF ((request->buildeventcd_ind=1))
    SET temp_task_description = request->task_description
    SET temp_event_cd = 0.0
    EXECUTE tsk_post_event_code
    SET request->event_cd = temp_event_cd
   ELSE
    SET temp_event_cd = request->event_cd
   ENDIF
   SELECT INTO "nl:"
    ot.*
    FROM order_task ot
    WHERE (request->reference_task_id=ot.reference_task_id)
    DETAIL
     cur_updt_cnt = ot.updt_cnt
     IF ((ot.active_ind != request->active_ind))
      IF ((request->active_ind=0))
       deletebillitem = 1
      ELSE
       addbillitem = 1
      ENDIF
     ENDIF
     IF (trim(ot.task_description) != trim(request->task_description))
      addbillitem = 1
     ENDIF
    WITH nocounter, forupdate(ot)
   ;end select
   IF (curqual=0)
    SET failed = "T"
    GO TO exit_script
   ENDIF
   IF ((request->updt_cnt != cur_updt_cnt))
    SET failed = "T"
    GO TO exit_script
   ENDIF
   UPDATE  FROM order_task ot
    SET ot.active_ind = request->active_ind, ot.task_description = request->task_description, ot
     .task_description_key = cnvtupper(request->task_description),
     ot.chart_not_cmplt_ind = request->chart_not_cmplt_ind, ot.task_type_cd = request->task_type_cd,
     ot.quick_chart_done_ind = request->quick_chart_done_ind,
     ot.quick_chart_notdone_ind = request->quick_chart_notdone_ind, ot.allpositionchart_ind = request
     ->allpositionchart_ind, ot.task_activity_cd = request->task_activity_cd,
     ot.overdue_min = request->overdue_min, ot.reschedule_time = request->reschedule_time, ot
     .retain_time = request->retain_time,
     ot.retain_units = request->retain_units, ot.cernertask_flag = 0, ot.event_cd = request->event_cd,
     ot.quick_chart_ind = request->quick_chart_ind, ot.overdue_units = request->overdue_units, ot
     .capture_bill_info_ind = request->capture_bill_info_ind,
     ot.ignore_req_ind = request->ignore_req_ind, ot.grace_period_mins = request->grace_period_mins,
     ot.updt_cnt = (ot.updt_cnt+ 1),
     ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo->updt_id, ot.updt_task =
     reqinfo->updt_task,
     ot.updt_applctx = reqinfo->updt_applctx
    WHERE (request->reference_task_id=ot.reference_task_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
   ELSE
    IF (((addbillitem=1) OR (deletebillitem=1)) )
     CALL updatebill(var1)
    ENDIF
   ENDIF
   SUBROUTINE updatebill(var)
     FREE SET request
     RECORD request(
       1 nbr_of_recs = i2
       1 qual[1]
         2 action = i2
         2 ext_id = f8
         2 ext_contributor_cd = f8
         2 parent_qual_ind = f8
         2 ext_owner_cd = f8
         2 ext_description = c100
         2 ext_short_desc = c50
         2 build_ind = i2
         2 careset_ind = i2
         2 workload_only_ind = i2
         2 child_qual = i2
         2 price_qual = i2
         2 prices[*]
           3 price_sched_id = f8
           3 price = f8
         2 billcode_qual = i2
         2 billcodes[*]
           3 billcode_sched_cd = f8
           3 billcode = c25
         2 children[*]
           3 ext_id = f8
           3 ext_contributor_cd = f8
           3 ext_description = c100
           3 ext_short_desc = c50
           3 build_ind = i2
           3 ext_owner_cd = f8
     )
     SET request->nbr_of_recs = 1
     IF (deletebillitem=1)
      SET request->qual[1].action = 3
     ELSE
      SET request->qual[1].action = 1
     ENDIF
     SET request->qual[1].ext_id = reference_task_id
     SET request->qual[1].ext_contributor_cd = taskcat_cd
     SET request->qual[1].parent_qual_ind = 1
     SET request->qual[1].careset_ind = 0
     SET request->qual[1].ext_owner_cd = task_cd
     SET request->qual[1].ext_description = extdesc
     SET request->qual[1].ext_short_desc = extshort
     SET request->qual[1].price_qual = 0
     SET request->qual[1].billcode_qual = 0
     SET request->qual[1].child_qual = 0
     EXECUTE afc_add_reference_api
   END ;Subroutine
   IF (failed="T")
    SET reqinfo->commit_ind = 0
   ELSE
    SET reqinfo->commit_ind = 1
    SET reply->status_data.status = "S"
    SET reply->event_cd = temp_event_cd
   ENDIF
 ENDFOR
 FOR (x = 1 TO size(task->list,5))
   FREE RECORD request_del
   RECORD request_del(
     1 reference_task_id = f8
     1 position_cnt = i4
     1 delqual[*]
       2 position_cd = f8
   )
   SELECT INTO "nl:"
    FROM order_task_position_xref ot
    WHERE (ot.reference_task_id=task->list[x].reference_task_id)
    HEAD REPORT
     null
    HEAD ot.reference_task_id
     r = 0, request_del->reference_task_id = ot.reference_task_id
    DETAIL
     IF (mod(r,10)=0)
      stat = alterlist(request_del->delqual,(r+ 10))
     ENDIF
     r = (r+ 1), request_del->delqual[r].position_cd = ot.position_cd
    FOOT REPORT
     stat = alterlist(request_del->delqual,r)
    WITH nocounter
   ;end select
   EXECUTE orm_del_pos_order_task  WITH replace(request,request_del)
 ENDFOR
 FOR (x = 1 TO size(task->list,5))
   FREE RECORD request_add
   RECORD request_add(
     1 reference_task_id = f8
     1 position_cnt = i4
     1 addqual[*]
       2 position_cd = f8
   )
   SELECT INTO "nl:"
    FROM order_task ot
    WHERE (ot.reference_task_id=task->list[x].reference_task_id)
    HEAD REPORT
     r = 0
    HEAD ot.reference_task_id
     r = 0, request_add->reference_task_id = ot.reference_task_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=88
     AND (cv.code_value= $POSITION)
    HEAD REPORT
     r = 0
    DETAIL
     IF (mod(r,10)=0)
      stat = alterlist(request_add->addqual,(r+ 10))
     ENDIF
     r = (r+ 1), request_add->addqual[r].position_cd = cv.code_value
    FOOT REPORT
     stat = alterlist(request_add->addqual,r)
    WITH nocounter
   ;end select
   EXECUTE orm_add_pos_order_task  WITH replace(request,request_add)
 ENDFOR
 SET failed_mess = true
 SET serrmsg = "Successfully Updated"
#exit_script
 IF (failed_mess != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (failed_mess != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
 SET script_ver = "000 11/12/14 SD030379 Initial Release"
END GO
