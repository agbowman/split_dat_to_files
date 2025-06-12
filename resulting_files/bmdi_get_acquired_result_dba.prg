CREATE PROGRAM bmdi_get_acquired_result:dba
 RECORD reply(
   1 result_list[*]
     2 result_id = f8
     2 device_id = f8
     2 monitored_device_id = f8
     2 device_cd = f8
     2 device_disp = c40
     2 device_desc = c60
     2 device_mean = c12
     2 location_cd = f8
     2 location_disp = c40
     2 location_desc = c60
     2 location_mean = c12
     2 device_alias = vc
     2 mobile_ind = i2
     2 device_ind = i2
     2 device_parameter_id = f8
     2 result_type_cd = f8
     2 result_type_disp = c40
     2 result_type_desc = c60
     2 result_type_mean = c12
     2 parameter_cd = f8
     2 parameter_disp = c40
     2 parameter_desc = c60
     2 parameter_mean = c12
     2 units_cd = f8
     2 units_disp = c40
     2 units_desc = c60
     2 units_mean = c12
     2 event_cd = f8
     2 event_disp = c40
     2 event_desc = c60
     2 event_mean = c12
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_desc = c60
     2 task_assay_mean = c12
     2 decimal_precision = i4
     2 alarm_high = c20
     2 alarm_low = c20
     2 parameter_alias = vc
     2 nomenclature_id = f8
     2 person_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 clinical_dt_tm = dq8
     2 acquired_dt_tm = dq8
     2 result_val = vc
     2 lab_type_cd = f8
     2 lab_type_disp = c40
     2 lab_type_desc = c60
     2 lab_type_mean = c12
     2 result_format_cd = f8
     2 result_format_disp = c40
     2 result_format_desc = c60
     2 result_format_mean = c12
     2 verified_dt_tm = dq8
     2 verified_ind = i2
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE bar_where_str = vc WITH noconstant("")
 DECLARE orderby_str = vc WITH noconstant("")
 DECLARE with_str = vc WITH noconstant("")
 DECLARE event_cd_str = vc WITH public, noconstant("")
 DECLARE task_assay_cd_str = vc WITH public, noconstant("")
 DECLARE bdp_where_str = vc WITH noconstant("bdp.device_parameter_id = bar.device_parameter_id")
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET sfailed = "S"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = 0
 IF ((request->location_cd > 0.0))
  SELECT INTO "nl:"
   FROM bmdi_monitored_device bmd
   WHERE (bmd.location_cd=request->location_cd)
   DETAIL
    request->monitored_device_id = bmd.monitored_device_id
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->person_id > 0)
  AND (request->parent_entity_id=0)
  AND (request->monitored_device_id=0))
  SET bar_where_str = " bar.person_id = request->person_id"
  CALL echo(build("bar_where_str person_id: ",bar_where_str))
  CALL echo("In INET condition: ")
 ELSEIF ((request->person_id=0)
  AND (request->parent_entity_id > 0)
  AND (request->monitored_device_id=0))
  SET bar_where_str = " bar.parent_entity_id = request->parent_entity_id"
  CALL echo("In Anesthesia condition: ")
 ELSEIF ((request->person_id > 0)
  AND (request->parent_entity_id > 0)
  AND (request->monitored_device_id=0))
  SET bar_where_str =
  " bar.person_id = request->person_id and bar.parent_entity_id = request->parent_entity_id"
 ELSEIF ((request->person_id > 0)
  AND (request->parent_entity_id=0)
  AND (request->monitored_device_id > 0))
  SET bar_where_str =
  " bar.person_id = request->person_id and bar.monitored_device_id = request->monitored_device_id"
  CALL echo(build("bar_where_str : ",bar_where_str))
  CALL echo("In INET location person condition: ")
 ELSEIF ((request->person_id=0)
  AND (request->parent_entity_id=0)
  AND (request->monitored_device_id > 0))
  SET bar_where_str = " bar.monitored_device_id = request->monitored_device_id"
  CALL echo(build("bar_where_str : ",bar_where_str))
  CALL echo("In INET location condition: ")
 ELSEIF ((request->person_id=0)
  AND (request->parent_entity_id > 0)
  AND (request->monitored_device_id > 0))
  SET bar_where_str = " bar.parent_entity_id = request->parent_entity_id"
  SET bar_where_str = concat(bar_where_str,
   " and bar.monitored_device_id = request->monitored_device_id")
  CALL echo(build("bar_where_str : ",bar_where_str))
  CALL echo("In Anesthesia location condition: ")
 ELSEIF ((request->person_id > 0)
  AND (request->parent_entity_id > 0)
  AND (request->monitored_device_id > 0))
  SET bar_where_str =
  " bar.person_id = request->person_id and bar.parent_entity_id = request->parent_entity_id"
  SET bar_where_str = concat(bar_where_str,
   "and bar.monitored_device_id = request->monitored_device_id")
 ELSE
  SET sfailed = "I"
  GO TO no_valid_ids
 ENDIF
 CALL echo("Debug5: ")
 IF ((request->query_type=1))
  SET bar_where_str = concat(bar_where_str," and bar.verified_ind = 1")
  CALL echo("Query type1: ")
  CALL echo(build("bar_where_str query_type: ",bar_where_str))
 ELSEIF ((request->query_type=2))
  SET bar_where_str = concat(bar_where_str," and bar.verified_ind = 0")
  CALL echo("Query type2: ")
 ENDIF
 IF ((request->date_query=0))
  SET bar_where_str = concat(bar_where_str,
   " and bar.clinical_dt_tm >= cnvtdatetime(request->from_dt_tm) and bar.clinical_dt_tm <=  cnvtdatetime(request->to_dt_tm) "
   )
  CALL echo("Date query is 0: ")
  CALL echo(build("bar_where_str date_query: ",bar_where_str))
 ELSEIF ((request->date_query=1))
  SET bar_where_str = concat(bar_where_str,
   " and bar.clinical_dt_tm > cnvtdatetime(request->from_dt_tm) and bar.clinical_dt_tm <= cnvtdatetime(request->to_dt_tm)"
   )
  CALL echo("Date query is 1: ")
 ELSEIF ((request->date_query=2))
  SET bar_where_str = concat(bar_where_str,
   " and (bar.clinical_dt_tm) = cnvtdatetime(request->to_dt_tm)")
  CALL echo("Date query is 2: ")
 ENDIF
 FOR (cnt = 1 TO size(request->event_list,5))
  IF (cnt=1)
   SET event_cd_str = "("
   CALL echo("event_cd 1: ")
   CALL echo(build("event_cd_str 1: ",event_cd_str))
  ENDIF
  IF (cnt < size(request->event_list,5))
   SET event_cd_str = concat(event_cd_str,trim(cnvtstring(request->event_list[cnt].event_cd,20,2)),
    ",")
   CALL echo("event_cd 2: ")
   CALL echo(build("event_cd_str 2: ",event_cd_str))
  ELSEIF (cnt=size(request->event_list,5))
   SET event_cd_str = concat(event_cd_str,trim(cnvtstring(request->event_list[cnt].event_cd,20,2)),
    ")")
   CALL echo("event_cd 3: ")
   CALL echo(build("event_cd_str 3: ",event_cd_str))
  ENDIF
 ENDFOR
 CALL echo("End of event_cd: ")
 IF (event_cd_str != "")
  SET bdp_where_str = concat(bdp_where_str," and (bdp.event_cd in ",event_cd_str,")")
 ENDIF
 FOR (cnt = 1 TO size(request->task_assay_list,5))
  IF (cnt=1)
   SET task_assay_cd_str = "("
   CALL echo("task_assay_list 1: ")
   CALL echo(build("task_cd_str 1: ",task_assay_cd_str))
  ENDIF
  IF (cnt < size(request->task_assay_list,5))
   SET task_assay_cd_str = concat(task_assay_cd_str,trim(cnvtstring(request->task_assay_list[cnt].
      task_assay_cd,20,2)),",")
   CALL echo("task_assay_list 2: ")
   CALL echo(build("task_cd_str 2: ",task_assay_cd_str))
  ELSEIF (cnt=size(request->task_assay_list,5))
   SET task_assay_cd_str = concat(task_assay_cd_str,trim(cnvtstring(request->task_assay_list[cnt].
      task_assay_cd,20,2)),")")
   CALL echo("task_assay_list 3: ")
   CALL echo(build("task_cd_str 3: ",task_assay_cd_str))
  ENDIF
 ENDFOR
 CALL echo("End of task_assay_cd: ")
 IF (task_assay_cd_str != "")
  SET bdp_where_str = concat(bdp_where_str," and (bdp.task_assay_cd in ",task_assay_cd_str,")")
 ENDIF
 CALL echo("Debug6: ")
 CALL echo(build("bar_where_str: ",bar_where_str))
 CALL echo(build("bdp_where_str: ",bdp_where_str))
 CALL echo(build("orderby_str: ",orderby_str))
 SELECT
  IF ((request->retrieval_type=0)
   AND (request->max_rec > 0))
   ORDER BY bar.clinical_dt_tm, bdp.event_cd
   WITH counter, maxrec = value(request->max_rec)
  ELSEIF ((request->retrieval_type=0))
   ORDER BY bar.clinical_dt_tm, bdp.event_cd
  ELSEIF ((request->retrieval_type=1))
   ORDER BY bar.clinical_dt_tm, bdp.event_cd
   WITH nocounter, maxrec = 1
  ELSE
   ORDER BY bar.clinical_dt_tm DESC, bdp.event_cd
   WITH nocounter, maxrec = 1
  ENDIF
  INTO "nl:"
  FROM bmdi_acquired_results bar,
   bmdi_monitored_device bmd,
   bmdi_device_parameter bdp,
   strt_bmdi_model_parameter sbmp
  PLAN (bar
   WHERE parser(bar_where_str))
   JOIN (bmd
   WHERE bmd.monitored_device_id=bar.monitored_device_id)
   JOIN (bdp
   WHERE parser(bdp_where_str))
   JOIN (sbmp
   WHERE sbmp.strt_model_parameter_id=bdp.strt_model_parameter_id)
  HEAD REPORT
   count = 0, stat = alterlist(reply->result_list,10)
  DETAIL
   count = (count+ 1),
   CALL echo(build("Count: ",count))
   IF (mod(count,10)=1
    AND count != 1)
    stat = alterlist(reply->result_list,(count+ 9))
   ENDIF
   reply->result_list[count].result_id = bar.result_id, reply->result_list[count].device_id = bar
   .device_id, reply->result_list[count].monitored_device_id = bar.monitored_device_id,
   reply->result_list[count].device_cd = bmd.device_cd, reply->result_list[count].device_disp =
   uar_get_code_display(bmd.device_cd), reply->result_list[count].device_desc =
   uar_get_code_description(bmd.device_cd),
   reply->result_list[count].device_mean = uar_get_code_meaning(bmd.device_cd), reply->result_list[
   count].location_cd = bmd.location_cd, reply->result_list[count].location_disp =
   uar_get_code_display(bmd.location_cd),
   reply->result_list[count].location_desc = uar_get_code_description(bmd.location_cd), reply->
   result_list[count].location_mean = uar_get_code_meaning(bmd.location_cd), reply->result_list[count
   ].device_alias = bmd.device_alias,
   reply->result_list[count].mobile_ind = bmd.mobile_ind, reply->result_list[count].device_ind = bmd
   .device_ind, reply->result_list[count].device_parameter_id = bdp.device_parameter_id,
   reply->result_list[count].result_type_cd = bdp.result_type_cd, reply->result_list[count].
   result_type_disp = uar_get_code_display(bdp.result_type_cd), reply->result_list[count].
   result_type_desc = uar_get_code_description(bdp.result_type_cd),
   reply->result_list[count].result_type_mean = uar_get_code_meaning(bdp.result_type_cd), reply->
   result_list[count].parameter_cd = sbmp.parameter_cd, reply->result_list[count].parameter_disp =
   uar_get_code_display(sbmp.parameter_cd),
   reply->result_list[count].parameter_desc = uar_get_code_description(sbmp.parameter_cd), reply->
   result_list[count].parameter_mean = uar_get_code_meaning(sbmp.parameter_cd), reply->result_list[
   count].units_cd = bdp.units_cd,
   reply->result_list[count].units_disp = uar_get_code_display(bdp.units_cd), reply->result_list[
   count].units_desc = uar_get_code_description(bdp.units_cd), reply->result_list[count].units_mean
    = uar_get_code_meaning(bdp.units_cd),
   reply->result_list[count].event_cd = bdp.event_cd, reply->result_list[count].event_disp =
   uar_get_code_display(bdp.event_cd), reply->result_list[count].event_desc =
   uar_get_code_description(bdp.event_cd),
   reply->result_list[count].event_mean = uar_get_code_meaning(bdp.event_cd), reply->result_list[
   count].task_assay_cd = bdp.task_assay_cd, reply->result_list[count].task_assay_disp =
   uar_get_code_display(bdp.task_assay_cd),
   reply->result_list[count].task_assay_desc = uar_get_code_description(bdp.task_assay_cd), reply->
   result_list[count].task_assay_mean = uar_get_code_meaning(bdp.task_assay_cd), reply->result_list[
   count].decimal_precision = bdp.decimal_precision,
   reply->result_list[count].alarm_high = bdp.alarm_high, reply->result_list[count].alarm_low = bdp
   .alarm_low, reply->result_list[count].parameter_alias = bdp.parameter_alias,
   reply->result_list[count].nomenclature_id = bar.nomenclature_id, reply->result_list[count].
   person_id = bar.person_id, reply->result_list[count].parent_entity_id = bar.parent_entity_id,
   reply->result_list[count].parent_entity_name = bar.parent_entity_name, reply->result_list[count].
   clinical_dt_tm = bar.clinical_dt_tm, reply->result_list[count].acquired_dt_tm = bar.acquired_dt_tm,
   reply->result_list[count].result_val = bar.result_val, reply->result_list[count].lab_type_cd = bar
   .lab_type_cd, reply->result_list[count].lab_type_disp = uar_get_code_display(bar.lab_type_cd),
   reply->result_list[count].lab_type_desc = uar_get_code_description(bar.lab_type_cd), reply->
   result_list[count].lab_type_mean = uar_get_code_meaning(bar.lab_type_cd), reply->result_list[count
   ].result_format_cd = bar.result_format_cd,
   reply->result_list[count].result_format_disp = uar_get_code_display(bar.result_format_cd), reply->
   result_list[count].result_format_desc = uar_get_code_description(bar.result_format_cd), reply->
   result_list[count].result_format_mean = uar_get_code_meaning(bar.result_format_cd),
   reply->result_list[count].verified_dt_tm = bar.verified_dt_tm, reply->result_list[count].
   verified_ind = bar.verified_ind, reply->result_list[count].event_id = bar.event_id
  FOOT REPORT
   stat = alterlist(reply->result_list,count)
  WITH nocounter
 ;end select
 CALL echo("Just before curqual: ")
 IF (curqual < 1)
  SET ierrcode = error(serrmsg,1)
  SET sfailed = "T"
  IF (ierrcode > 0)
   SET stat = alter(reply->status_data.subeventstatus,2)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data Retrieval failed!"
  ELSE
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "No data matching request"
  ENDIF
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_acquired_result"
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[2].operationname = "SELECT"
   SET reply->status_data.subeventstatus[2].operationstatus = "F"
   SET reply->status_data.subeventstatus[2].targetobjectname = "bmdi_get_acquired_result"
   SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  ENDIF
  CALL echo("Debug1: ")
  GO TO exit_script
 ENDIF
 CALL echo("Debug2: ")
 GO TO exit_script
#no_valid_ids
 IF (sfailed="I")
  SET stat = alter(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationname = "Check Request"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bmdi_get_acquired_result"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No valid identifier in request"
  GO TO exit_script
 ENDIF
#exit_script
 CALL echo("exit script: ")
 IF (sfailed="T")
  IF (ierrcode > 0)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSEIF (sfailed="I")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
