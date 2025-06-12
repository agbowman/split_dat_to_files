CREATE PROGRAM afc_get_tasks:dba
 SET afc_reprocess_charge_version = "44398.FT.002"
 RECORD tasks(
   1 tasks[*]
     2 cs_order_id = f8
     2 cs_catalog_cd = f8
     2 order_id = f8
     2 catalog_cd = f8
     2 task_id = f8
     2 reference_task_id = f8
     2 person_id = f8
     2 name_full_formatted = c100
     2 encntr_id = f8
     2 task_status_cd = f8
     2 task_status_reason_cd = f8
     2 task_dt_tm = dq8
     2 location_cd = f8
     2 updt_id = f8
     2 complete_ind = i2
     2 attempted_ind = i2
     2 ce_id = f8
     2 ce_complete_ind = i2
     2 ce_attempted_ind = i2
     2 process_ind = i2
     2 task_description = vc
 )
 DECLARE 13016_ord_id = f8
 DECLARE 13016_ord_cat = f8
 DECLARE 13016_taskcat = f8
 DECLARE 13016_task_id = f8
 DECLARE 13029_complete = f8
 DECLARE 13029_attempted = f8
 DECLARE 13029_cancel = f8
 DECLARE 13028_cr = f8
 DECLARE 13029_complete_disp = c40
 DECLARE 13029_attempted_disp = c40
 DECLARE 13029_cancel_disp = c40
 DECLARE 13028_cr_disp = c40
 SET 13029_complete_disp = uar_get_code_display(13029_complete)
 SET 13029_attempted_disp = uar_get_code_display(13029_attempted)
 SET 13029_cancel_disp = uar_get_code_display(13029_cancel)
 SET 13028_cr_disp = uar_get_code_display(13028_cr)
 DECLARE code_value = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 SET code_set = 13016
 SET cdf_meaning = "ORD ID"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13016_ord_id)
 IF (13016_ord_id IN (0.0, null))
  CALL echo("13016_ORD_ID of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET cdf_meaning = "ORD CAT"
 SET code_set = 13016
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13016_ord_cat)
 IF (13016_ord_cat IN (0.0, null))
  CALL echo("13016_ORD_CAT of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET cdf_meaning = "TASKCAT"
 SET code_set = 13016
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13016_taskcat)
 IF (13016_taskcat IN (0.0, null))
  CALL echo("13016_TASKCAT of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET cdf_meaning = "TASK ID"
 SET code_set = 13016
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13016_task_id)
 IF (13016_task_id IN (0.0, null))
  CALL echo("13016_TASK_ID of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET code_set = 13028
 SET cdf_meaning = "CR"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13028_cr)
 IF (13028_cr IN (0.0, null))
  CALL echo("13028_CR of codeset 13028 IS NULL")
  GO TO end_program
 ENDIF
 SET code_set = 13029
 SET cdf_meaning = "CANCEL"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13029_cancel)
 IF (13029_cancel IN (0.0, null))
  CALL echo("13029_CANCEL of codeset 13029 IS NULL")
  GO TO end_program
 ENDIF
 SET code_set = 13029
 SET cdf_meaning = "ATTEMPTED"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13029_attempted)
 IF (13029_attempted IN (0.0, null))
  CALL echo("13029_ATTEMPTED of codeset 13029 IS NULL")
  GO TO end_program
 ENDIF
 SET code_set = 13029
 SET cdf_meaning = "COMPLETE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(code_set,nullterm(cdf_meaning),cnt,13029_complete)
 IF (13029_complete IN (0.0, null))
  CALL echo("13029_COMPLETE of codeset 13029 IS NULL")
  GO TO end_program
 ENDIF
 SET begdate = format(cnvtdatetime(request->beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 SET enddate = format(cnvtdatetime(request->end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 CALL echo("=====================GOING TO AFC_GET_MISSING_TASKS=====================")
 EXECUTE afc_get_missing_tasks
 CALL echo("=====================BACK FROM AFC_GET_MISSING_TASKS=====================")
 SET count = 0
 SELECT INTO "nl:"
  d1.seq, task_id = tasks->tasks[d1.seq].task_id
  FROM (dummyt d1  WITH seq = value(size(tasks->tasks,5)))
  WHERE (tasks->tasks[d1.seq].process_ind=1)
  ORDER BY tasks->tasks[d1.seq].task_id, tasks->tasks[d1.seq].person_id, tasks->tasks[d1.seq].
   task_dt_tm
  HEAD task_id
   IF ((tasks->tasks[d1.seq].order_id > 0.0))
    count = (count+ 1), count2 = 0, reply->charge_event_qual = count
    IF (count > size(reply->charge_event,5))
     stat = alterlist(reply->charge_event,(count+ 10))
    ENDIF
    reply->charge_event[count].ext_master_event_id = tasks->tasks[d1.seq].cs_order_id, reply->
    charge_event[count].ext_master_event_cont_cd = 13016_ord_id, reply->charge_event[count].
    ext_master_reference_id = tasks->tasks[d1.seq].cs_catalog_cd,
    reply->charge_event[count].ext_master_reference_cont_cd = 13016_ord_cat, reply->charge_event[
    count].ext_parent_event_id = tasks->tasks[d1.seq].order_id, reply->charge_event[count].
    ext_parent_event_cont_cd = 13016_ord_id,
    reply->charge_event[count].ext_parent_reference_id = tasks->tasks[d1.seq].catalog_cd, reply->
    charge_event[count].ext_parent_reference_cont_cd = 13016_ord_cat, reply->charge_event[count].
    ext_item_event_id = tasks->tasks[d1.seq].task_id,
    reply->charge_event[count].ext_item_event_cont_cd = 13016_task_id, reply->charge_event[count].
    ext_item_reference_id = tasks->tasks[d1.seq].reference_task_id, reply->charge_event[count].
    ext_item_reference_cont_cd = 13016_taskcat,
    reply->charge_event[count].order_id = tasks->tasks[d1.seq].order_id, reply->charge_event[count].
    mnemonic = tasks->tasks[d1.seq].task_description, reply->charge_event[count].person_id = tasks->
    tasks[d1.seq].person_id,
    reply->charge_event[count].person_name = tasks->tasks[d1.seq].name_full_formatted, reply->
    charge_event[count].encntr_id = tasks->tasks[d1.seq].encntr_id
   ELSE
    count = (count+ 1), count2 = 0, reply->charge_event_qual = count
    IF (count > size(reply->charge_event,5))
     stat = alterlist(reply->charge_event,(count+ 10))
    ENDIF
    reply->charge_event[count].ext_master_event_id = tasks->tasks[d1.seq].task_id, reply->
    charge_event[count].ext_master_event_cont_cd = 13016_task_id, reply->charge_event[count].
    ext_master_reference_id = tasks->tasks[d1.seq].reference_task_id,
    reply->charge_event[count].ext_master_reference_cont_cd = 13016_taskcat, reply->charge_event[
    count].ext_parent_event_id = 0.0, reply->charge_event[count].ext_parent_event_cont_cd = 0.0,
    reply->charge_event[count].ext_parent_reference_id = 0.0, reply->charge_event[count].
    ext_parent_reference_cont_cd = 0.0, reply->charge_event[count].ext_item_event_id = tasks->tasks[
    d1.seq].task_id,
    reply->charge_event[count].ext_item_event_cont_cd = 13016_task_id, reply->charge_event[count].
    ext_item_reference_id = tasks->tasks[d1.seq].reference_task_id, reply->charge_event[count].
    ext_item_reference_cont_cd = 13016_taskcat,
    reply->charge_event[count].order_id = tasks->tasks[d1.seq].order_id, reply->charge_event[count].
    mnemonic = tasks->tasks[d1.seq].task_description, reply->charge_event[count].person_id = tasks->
    tasks[d1.seq].person_id,
    reply->charge_event[count].person_name = tasks->tasks[d1.seq].name_full_formatted, reply->
    charge_event[count].encntr_id = tasks->tasks[d1.seq].encntr_id
   ENDIF
  DETAIL
   count2 = (count2+ 1)
   IF (count2 > size(reply->charge_event[count].charge_event_act,5))
    stat = alterlist(reply->charge_event[count].charge_event_act,(count2+ 10))
   ENDIF
   IF ((tasks->tasks[d1.seq].complete_ind=1))
    reply->charge_event[count].charge_event_act[count2].charge_type_cd = 0, reply->charge_event[count
    ].charge_event_act[count2].cea_type_cd = 13029_complete, reply->charge_event[count].
    charge_event_act[count2].cea_type_disp = 13029_complete_disp
   ELSEIF ((tasks->tasks[d1.seq].attempted_ind=1))
    reply->charge_event[count].charge_event_act[count2].charge_type_cd = 0, reply->charge_event[count
    ].charge_event_act[count2].cea_type_cd = 13029_attempted, reply->charge_event[count].
    charge_event_act[count2].cea_type_disp = 13029_attempted_disp
   ELSE
    reply->charge_event[count].charge_event_act[count2].charge_type_cd = 0, reply->charge_event[count
    ].charge_event_act[count2].cea_type_cd = 0, reply->charge_event[count].charge_event_act[count2].
    cea_type_disp = "UNKNOWN"
   ENDIF
   reply->charge_event[count].charge_event_act[count2].service_resource_cd = 0, reply->charge_event[
   count].charge_event_act[count2].service_dt_tm = tasks->tasks[d1.seq].task_dt_tm, reply->
   charge_event[count].charge_event_act_qual = count2
  FOOT  task_id
   stat = alterlist(reply->charge_event,count), stat = alterlist(reply->charge_event[count].
    charge_event_act,count2)
  WITH nocounter
 ;end select
 SET reply->charge_event_qual = count
 FREE SET tasks
END GO
