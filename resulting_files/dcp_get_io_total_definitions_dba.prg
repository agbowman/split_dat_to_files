CREATE PROGRAM dcp_get_io_total_definitions:dba
 DECLARE exec_dt_tm = q8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 IF (validate(debug_ind,0) != 1)
  SET debug_ind = 0
 ENDIF
 SET modify = predeclare
 RECORD reply(
   1 io_def_cnt = i4
   1 io_total_definitions[*]
     2 io_total_definition_id = f8
     2 total_definition_name = vc
     2 total_duration_type_cd = f8
     2 total_duration_type_disp = c40
     2 total_duration_type_desc = vc
     2 total_duration_type_mean = c12
     2 total_duration = f8
     2 total_operation_type_cd = f8
     2 total_operation_type_disp = c40
     2 total_operation_type_desc = vc
     2 total_operation_type_mean = c12
     2 total_type_cd = f8
     2 total_type_disp = c40
     2 total_type_desc = vc
     2 total_type_mean = c12
     2 discrete_task_assay_cd = f8
     2 io_elem_cnt = i4
     2 io_total_elements[*]
       3 event_cd = f8
       3 event_disp = c40
       3 event_desc = vc
       3 event_mean = c12
       3 route_cd = f8
       3 route_disp = c40
       3 route_desc = vc
       3 route_mean = c12
       3 iv_event_cd = f8
       3 iv_event_disp = c40
       3 iv_event_desc = vc
       3 iv_event_mean = c12
       3 io_definition_element_id = f8
       3 prev_io_definition_element_id = f8
       3 beg_effective_dt_tm = q8
       3 end_effective_dt_tm = q8
     2 prev_io_total_definition_id = f8
     2 beg_effective_dt_tm = q8
     2 end_effective_dt_tm = q8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE all_intake = f8 WITH public, constant(uar_get_code_by("MEANING",200008,"ALLINTAKE"))
 DECLARE all_output = f8 WITH public, constant(uar_get_code_by("MEANING",200008,"ALLOUTPUT"))
 DECLARE all_balance = f8 WITH public, constant(uar_get_code_by("MEANING",200008,"ALLBALANCE"))
 DECLARE intake = f8 WITH public, constant(uar_get_code_by("MEANING",200008,"INTAKE"))
 DECLARE output = f8 WITH public, constant(uar_get_code_by("MEANING",200008,"OUTPUT"))
 DECLARE balance = f8 WITH public, constant(uar_get_code_by("MEANING",200008,"BALANCE"))
 IF (((all_intake <= 0.0) OR (((all_output <= 0.0) OR (((all_balance <= 0.0) OR (((intake <= 0.0) OR
 (((output <= 0.0) OR (balance <= 0.0)) )) )) )) )) )
  GO TO exit_program
 ENDIF
 DECLARE getbasictotaldefinitions(null) = null WITH public
 DECLARE gettotaldefinitions(null) = null WITH public
 IF ((request->basic_ind=1))
  CALL getbasictotaldefinitions(null)
 ELSE
  CALL gettotaldefinitions(null)
 ENDIF
 IF ((reply->io_def_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SUBROUTINE getbasictotaldefinitions(null)
   DECLARE def_cnt = i4 WITH protect, noconstant(0)
   SET reply->status_data.subeventstatus[1].operationname = "GetBasicTotalDefinitions"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SELECT
    IF ((request->io_total_definition_id > 0.0))
     WHERE (itd.io_total_definition_id=request->io_total_definition_id)
      AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    ELSE
    ENDIF
    INTO "nl:"
    itd.io_total_definition_id, itd.prev_io_total_definition_id, itd.total_definition_name,
    itd.task_assay_cd, itd.total_duration, itd.total_duration_type_cd,
    itd.total_operation_type_cd, itd.total_type_cd, itd.beg_effective_dt_tm,
    itd.end_effective_dt_tm
    FROM io_total_definition itd
    WHERE itd.io_total_definition_id > 0.0
     AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
    ORDER BY itd.io_total_definition_id
    HEAD REPORT
     def_cnt = 0
    HEAD itd.io_total_definition_id
     def_cnt = (def_cnt+ 1)
     IF (mod(def_cnt,10)=1)
      stat = alterlist(reply->io_total_definitions,(def_cnt+ 9))
     ENDIF
     reply->io_total_definitions[def_cnt].io_total_definition_id = itd.io_total_definition_id, reply
     ->io_total_definitions[def_cnt].prev_io_total_definition_id = itd.prev_io_total_definition_id,
     reply->io_total_definitions[def_cnt].total_definition_name = itd.total_definition_name,
     reply->io_total_definitions[def_cnt].total_duration = itd.total_duration, reply->
     io_total_definitions[def_cnt].total_duration_type_cd = itd.total_duration_type_cd, reply->
     io_total_definitions[def_cnt].total_operation_type_cd = itd.total_operation_type_cd,
     reply->io_total_definitions[def_cnt].total_type_cd = itd.total_type_cd, reply->
     io_total_definitions[def_cnt].discrete_task_assay_cd = itd.task_assay_cd, reply->
     io_total_definitions[def_cnt].beg_effective_dt_tm = cnvtdatetime(itd.beg_effective_dt_tm),
     reply->io_total_definitions[def_cnt].end_effective_dt_tm = cnvtdatetime(itd.end_effective_dt_tm)
    FOOT REPORT
     reply->io_def_cnt = def_cnt, stat = alterlist(reply->io_total_definitions,reply->io_def_cnt)
    WITH nocounter
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "Q1 FAILED"
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE gettotaldefinitions(null)
   DECLARE cnt = i4 WITH protect, noconstant(0)
   DECLARE def_cnt = i4 WITH protect, noconstant(0)
   DECLARE def_elem_cnt = i4 WITH protect, noconstant(0)
   SET reply->status_data.subeventstatus[1].operationname = "GetTotalDefinitions"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SELECT
    IF ((request->io_total_definition_id > 0.0))
     PLAN (itd
      WHERE (itd.io_total_definition_id=request->io_total_definition_id)
       AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
       AND itd.total_type_cd IN (intake, output, balance))
      JOIN (idr
      WHERE idr.io_total_group_id=itd.io_total_group_id
       AND ((idr.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100")))
      JOIN (ide
      WHERE ide.io_definition_element_id=idr.io_definition_element_id
       AND ((ide.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100")))
    ELSE
    ENDIF
    INTO "nl:"
    itd.io_total_definition_id, itd.prev_io_total_definition_id, itd.total_definition_name,
    itd.task_assay_cd, itd.total_duration, itd.total_duration_type_cd,
    itd.total_operation_type_cd, itd.total_type_cd, itd.beg_effective_dt_tm,
    itd.end_effective_dt_tm
    FROM io_total_definition itd,
     io_def_element_reltn idr,
     io_definition_element ide
    PLAN (itd
     WHERE itd.io_total_definition_id > 0.0
      AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
      AND itd.total_type_cd IN (intake, output, balance))
     JOIN (idr
     WHERE idr.io_total_group_id=itd.io_total_group_id
      AND ((idr.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100")))
     JOIN (ide
     WHERE ide.io_definition_element_id=idr.io_definition_element_id
      AND ((ide.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100")))
    ORDER BY itd.io_total_definition_id, ide.io_definition_element_id
    HEAD REPORT
     def_cnt = 0
    HEAD itd.io_total_definition_id
     def_elem_cnt = 0, def_cnt = (def_cnt+ 1)
     IF (mod(def_cnt,10)=1)
      stat = alterlist(reply->io_total_definitions,(def_cnt+ 9))
     ENDIF
     reply->io_total_definitions[def_cnt].io_total_definition_id = itd.io_total_definition_id, reply
     ->io_total_definitions[def_cnt].prev_io_total_definition_id = itd.prev_io_total_definition_id,
     reply->io_total_definitions[def_cnt].total_definition_name = itd.total_definition_name,
     reply->io_total_definitions[def_cnt].total_duration = itd.total_duration, reply->
     io_total_definitions[def_cnt].total_duration_type_cd = itd.total_duration_type_cd, reply->
     io_total_definitions[def_cnt].total_operation_type_cd = itd.total_operation_type_cd,
     reply->io_total_definitions[def_cnt].total_type_cd = itd.total_type_cd, reply->
     io_total_definitions[def_cnt].discrete_task_assay_cd = itd.task_assay_cd, reply->
     io_total_definitions[def_cnt].beg_effective_dt_tm = cnvtdatetime(itd.beg_effective_dt_tm),
     reply->io_total_definitions[def_cnt].end_effective_dt_tm = cnvtdatetime(itd.end_effective_dt_tm)
    HEAD ide.io_definition_element_id
     def_elem_cnt = (def_elem_cnt+ 1)
     IF (mod(def_elem_cnt,10)=1)
      stat = alterlist(reply->io_total_definitions[def_cnt].io_total_elements,(def_elem_cnt+ 9))
     ENDIF
     reply->io_total_definitions[def_cnt].io_total_elements[def_elem_cnt].io_definition_element_id =
     ide.io_definition_element_id, reply->io_total_definitions[def_cnt].io_total_elements[
     def_elem_cnt].prev_io_definition_element_id = ide.prev_io_definition_element_id, reply->
     io_total_definitions[def_cnt].io_total_elements[def_elem_cnt].event_cd = ide.event_cd,
     reply->io_total_definitions[def_cnt].io_total_elements[def_elem_cnt].route_cd = ide.route_cd,
     reply->io_total_definitions[def_cnt].io_total_elements[def_elem_cnt].iv_event_cd = ide
     .iv_event_cd, reply->io_total_definitions[def_cnt].io_total_elements[def_elem_cnt].
     beg_effective_dt_tm = cnvtdatetime(ide.beg_effective_dt_tm),
     reply->io_total_definitions[def_cnt].io_total_elements[def_elem_cnt].end_effective_dt_tm =
     cnvtdatetime(ide.end_effective_dt_tm)
    FOOT  itd.io_total_definition_id
     reply->io_total_definitions[def_cnt].io_elem_cnt = def_elem_cnt, stat = alterlist(reply->
      io_total_definitions[def_cnt].io_total_elements,reply->io_total_definitions[def_cnt].
      io_elem_cnt)
    FOOT REPORT
     reply->io_def_cnt = def_cnt, stat = alterlist(reply->io_total_definitions,reply->io_def_cnt)
    WITH nocounter
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "Q1 FAILED"
    GO TO exit_program
   ENDIF
   SELECT
    IF ((request->io_total_definition_id > 0.0))
     WHERE (itd.io_total_definition_id=request->io_total_definition_id)
      AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
      AND itd.total_type_cd IN (all_intake, all_output, all_balance)
    ELSE
    ENDIF
    INTO "nl:"
    itd.io_total_definition_id, itd.prev_io_total_definition_id, itd.total_definition_name,
    itd.task_assay_cd, itd.total_duration, itd.total_duration_type_cd,
    itd.total_operation_type_cd, itd.total_type_cd, itd.beg_effective_dt_tm,
    itd.end_effective_dt_tm
    FROM io_total_definition itd
    WHERE itd.io_total_definition_id > 0.0
     AND ((itd.end_effective_dt_tm+ 0)=cnvtdatetime("31-DEC-2100"))
     AND itd.total_type_cd IN (all_intake, all_output, all_balance)
    ORDER BY itd.io_total_definition_id
    HEAD REPORT
     cnt = reply->io_def_cnt, def_cnt = 0
    HEAD itd.io_total_definition_id
     cnt = (cnt+ 1), def_cnt = (def_cnt+ 1)
     IF (mod(def_cnt,10)=1)
      stat = alterlist(reply->io_total_definitions,(cnt+ 9))
     ENDIF
     reply->io_total_definitions[cnt].io_total_definition_id = itd.io_total_definition_id, reply->
     io_total_definitions[cnt].prev_io_total_definition_id = itd.prev_io_total_definition_id, reply->
     io_total_definitions[cnt].total_definition_name = itd.total_definition_name,
     reply->io_total_definitions[cnt].total_duration = itd.total_duration, reply->
     io_total_definitions[cnt].total_duration_type_cd = itd.total_duration_type_cd, reply->
     io_total_definitions[cnt].total_operation_type_cd = itd.total_operation_type_cd,
     reply->io_total_definitions[cnt].total_type_cd = itd.total_type_cd, reply->io_total_definitions[
     cnt].discrete_task_assay_cd = itd.task_assay_cd, reply->io_total_definitions[cnt].
     beg_effective_dt_tm = cnvtdatetime(itd.beg_effective_dt_tm),
     reply->io_total_definitions[cnt].end_effective_dt_tm = cnvtdatetime(itd.end_effective_dt_tm)
    FOOT REPORT
     reply->io_def_cnt = cnt, stat = alterlist(reply->io_total_definitions,reply->io_def_cnt)
    WITH nocounter
   ;end select
   IF (error(reply->status_data.subeventstatus[1].targetobjectvalue,0) != 0)
    SET reply->status_data.subeventstatus[1].targetobjectname = "Q2 FAILED"
    GO TO exit_program
   ENDIF
 END ;Subroutine
#exit_program
 IF (debug_ind=1)
  CALL echo("*********************")
  CALL echo("*	 CODE VALUES    *")
  CALL echo("*********************")
  CALL echo(build("ALLINTAKE=",all_intake))
  CALL echo(build("ALLOUTPUT= ",all_output))
  CALL echo(build("ALLBALANCE=",all_balance))
  CALL echo(build("INTAKE= ",intake))
  CALL echo(build("OUTPUT= ",output))
  CALL echo(build("BALANCE= ",balance))
  CALL echo("*********************")
  CALL echo("*	 THE REQUEST    *")
  CALL echo("*********************")
  CALL echorecord(request)
  CALL echo("*********************")
  CALL echo("*	  THE REPLY     *")
  CALL echo("*********************")
  CALL echorecord(reply)
  CALL echo("*********************")
  CALL echo("*	  EXEC TIME     *")
  CALL echo("*********************")
  CALL echo(build("TOTAL EXECUTION TIME IN SECONDS: ",datetimediff(cnvtdatetime(curdate,curtime3),
     exec_dt_tm,5)))
 ENDIF
END GO
