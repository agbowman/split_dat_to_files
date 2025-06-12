CREATE PROGRAM cv_drop_charges:dba
 FREE RECORD pref_request
 RECORD pref_request(
   1 context = vc
   1 context_id = vc
   1 section = vc
   1 section_id = vc
   1 groups[*]
     2 name = vc
   1 debug = vc
 )
 FREE RECORD pref_reply
 RECORD pref_reply(
   1 entries[*]
     2 name = vc
     2 values[*]
       3 value = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE step_type_procedure_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "PROCEDURE"))
 DECLARE step_type_final_report_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4001923,
   "FINALREPORT"))
 DECLARE step_status_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4000440,
   "COMPLETED"))
 DECLARE batch_size = i4 WITH protect, constant(20)
 DECLARE drop_charge_ind = i2 WITH protect, constant(1)
 DECLARE reverse_charge_ind = i2 WITH protect, constant(2)
 DECLARE institution_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"INSTITUTION"))
 DECLARE department_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"DEPARTMENT"))
 DECLARE section_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SECTION"))
 DECLARE subsection_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",223,"SUBSECTION"))
 DECLARE encntr_prsnl_reltn_referdoc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,
   "REFERDOC"))
 DECLARE cur_list_size = i4 WITH protect
 DECLARE loop_cnt = i4 WITH protect
 DECLARE new_list_size = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE nstart = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE charge_event_cnt = i4 WITH protect
 RECORD charges(
   1 charge_list[*]
     2 fin_class_cd = f8
     2 encntr_org_id = f8
     2 ord_loc_cd = f8
     2 loc_nurse_unit_cd = f8
     2 perf_loc_cd = f8
     2 health_plan_id = f8
     2 encntr_type_cd = f8
     2 order_id = f8
     2 perf_phys_id = f8
     2 service_dt_tm = f8
     2 person_id = f8
     2 encntr_id = f8
     2 cv_proc_id = f8
     2 verify_phys_id = f8
     2 ref_phys_id = f8
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 step_id = f8
     2 new_step_status_cd = f8
     2 step_type_cd = f8
     2 charge_ind = i2
     2 cs_order_id = f8
     2 cs_catalog_cd = f8
     2 institution_cd = f8
     2 department_cd = f8
     2 section_cd = f8
     2 subsection_cd = f8
     2 service_resource_cd = f8
     2 level5_cd = f8
     2 schedule_ind = i2
 )
 RECORD cd(
   1 ext_contrib_ord_id_cd = f8
   1 ext_contrib_ord_cat_cd = f8
   1 ext_contrib_task_assay_cd = f8
   1 ext_contrib_rad_result = f8
   1 charge_type_bill_only_cd = f8
   1 charge_type_cr_cd = f8
   1 charge_type_dr_cd = f8
   1 cea_type_performed_cd = f8
   1 cea_type_verified_cd = f8
   1 cea_type_reverse_cd = f8
   1 mins_unit_type_cd = f8
 )
 SUBROUTINE (fetchcvchargescodevalues(unusedargument=i1) =null WITH protect)
   IF (validate(cd->ext_contrib_ord_id_cd,0.0)=0.0)
    SET cd->ext_contrib_ord_id_cd = uar_get_code_by("MEANING",13016,"ORD ID")
    SET cd->ext_contrib_ord_cat_cd = uar_get_code_by("MEANING",13016,"ORD CAT")
    SET cd->ext_contrib_task_assay_cd = uar_get_code_by("MEANING",13016,"TASK ASSAY")
    SET cd->ext_contrib_rad_result = uar_get_code_by("MEANING",13016,"RAD RESULT")
    SET cd->charge_type_bill_only_cd = uar_get_code_by("MEANING",13028,"BILL ONLY")
    SET cd->charge_type_cr_cd = uar_get_code_by("MEANING",13028,"CR")
    SET cd->charge_type_dr_cd = uar_get_code_by("MEANING",13028,"DR")
    SET cd->cea_type_performed_cd = uar_get_code_by("MEANING",13029,"PERFORMED")
    SET cd->cea_type_verified_cd = uar_get_code_by("MEANING",13029,"VERIFIED")
    SET cd->cea_type_reverse_cd = uar_get_code_by("MEANING",13029,"REVERSE")
    SET cd->mins_unit_type_cd = uar_get_code_by("MEANING",14276,"MINUTES")
   ENDIF
 END ;Subroutine
 SUBROUTINE (filterstepsforcharges(unusedargument=i1) =null WITH protect)
   SET cur_list_size = size(charges->charge_list,5)
   IF (cur_list_size > 1)
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET stat = alterlist(charges->charge_list,new_list_size)
    SET nstart = 1
    FOR (idx = (cur_list_size+ 1) TO new_list_size)
      SET charges->charge_list[idx].step_id = charges->charge_list[cur_list_size].step_id
    ENDFOR
   ENDIF
   SELECT
    IF (cur_list_size > 1)
     FROM (dummyt d1  WITH seq = value(loop_cnt)),
      cv_step cs,
      cv_step_ref csr
     PLAN (d1
      WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
      JOIN (cs
      WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cs.cv_step_id,charges->charge_list[idx].
       step_id))
      JOIN (csr
      WHERE csr.task_assay_cd=cs.task_assay_cd
       AND csr.step_type_cd IN (step_type_procedure_cd, step_type_final_report_cd))
    ELSE
     FROM cv_step cs,
      cv_step_ref csr
     PLAN (cs
      WHERE (cs.cv_step_id=charges->charge_list[1].step_id))
      JOIN (csr
      WHERE csr.task_assay_cd=cs.task_assay_cd
       AND csr.step_type_cd IN (step_type_procedure_cd, step_type_final_report_cd))
    ENDIF
    INTO "nl:"
    FROM cv_step cs,
     cv_step_ref csr
    PLAN (cs
     WHERE (cs.cv_step_id=- (1.0)))
     JOIN (csr
     WHERE csr.task_assay_cd=cs.task_assay_cd)
    HEAD REPORT
     num1 = 0, charge_event_cnt = 0
    DETAIL
     index = locateval(num1,1,cur_list_size,cs.cv_step_id,charges->charge_list[num1].step_id)
     IF (cs.step_status_cd=step_status_completed_cd
      AND (charges->charge_list[index].new_step_status_cd != step_status_completed_cd))
      charges->charge_list[index].charge_ind = reverse_charge_ind, charges->charge_list[index].
      step_type_cd = csr.step_type_cd, charge_event_cnt += 1
     ELSEIF (cs.step_status_cd != step_status_completed_cd
      AND (charges->charge_list[index].new_step_status_cd=step_status_completed_cd))
      charges->charge_list[index].charge_ind = drop_charge_ind, charges->charge_list[index].
      step_type_cd = csr.step_type_cd, charge_event_cnt += 1
     ENDIF
     charges->charge_list[index].schedule_ind = csr.schedule_ind
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (validate(stat)=0)
  DECLARE stat = i4 WITH protect
 ENDIF
 IF (validate(cv_log_stat_cnt)=0)
  DECLARE cv_log_stat_cnt = i4
  DECLARE cv_log_msg_cnt = i4
  DECLARE cv_debug = i2 WITH constant(4)
  DECLARE cv_info = i2 WITH constant(3)
  DECLARE cv_audit = i2 WITH constant(2)
  DECLARE cv_warning = i2 WITH constant(1)
  DECLARE cv_error = i2 WITH constant(0)
  DECLARE cv_log_levels[5] = c8
  SET cv_log_levels[1] = "ERROR  :"
  SET cv_log_levels[2] = "WARNING:"
  SET cv_log_levels[3] = "AUDIT  :"
  SET cv_log_levels[4] = "INFO   :"
  SET cv_log_levels[5] = "DEBUG  :"
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime("31-DEC-2100 00:00:00"))
  DECLARE null_f8 = f8 WITH protect, noconstant(0.000001)
  DECLARE cv_log_error_file = i4 WITH noconstant(0)
  IF (currdbname IN ("PROV", "SOLT", "SURD"))
   SET cv_log_error_file = 1
  ENDIF
  DECLARE cv_err_msg = vc WITH noconstant(fillstring(128," "))
  DECLARE cv_log_file_name = vc WITH noconstant(build("cer_temp:CV_DEFAULT",cnvtstring(curtime2),
    ".dat"))
  DECLARE cv_log_error_string = vc WITH noconstant(fillstring(32000," "))
  DECLARE cv_log_error_string_cnt = i4
  CALL cv_log_msg(cv_info,"CV_LOG_MSG version: 002 10/16/08 AR012547")
 ENDIF
 CALL cv_log_msg(cv_info,concat("*** Entering ",curprog," at ",format(cnvtdatetime(sysdate),
    "@SHORTDATETIME")))
 IF (validate(request)=1
  AND (reqdata->loglevel >= cv_info))
  IF (cv_log_error_file=1)
   CALL echorecord(request,cv_log_file_name,1)
  ENDIF
  CALL echorecord(request)
 ENDIF
 SUBROUTINE (cv_log_stat(log_lev=i2,op_name=vc,op_stat=c1,obj_name=vc,obj_value=vc) =null)
   SET cv_log_stat_cnt = (size(reply->status_data.subeventstatus,5)+ 1)
   SET stat = alterlist(reply->status_data.subeventstatus,cv_log_stat_cnt)
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].operationstatus = op_stat
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectname = obj_name
   SET reply->status_data.subeventstatus[cv_log_stat_cnt].targetobjectvalue = obj_value
   IF ((reqdata->loglevel >= log_lev))
    CALL cv_log_msg(log_lev,build("Subevent:",nullterm(op_name),"=",nullterm(op_stat),"::",
      nullterm(obj_name),"::",obj_value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg(log_lev=i2,the_message=vc(byval)) =null)
   IF ((reqdata->loglevel >= log_lev))
    SET cv_err_msg = fillstring(128," ")
    SET cv_err_msg = concat("**",nullterm(cv_log_levels[(log_lev+ 1)]),trim(the_message)," at :",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME"))
    CALL echo(cv_err_msg)
    IF (cv_log_error_file=1)
     SET cv_log_error_string_cnt += 1
     SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (cv_log_msg_post(script_vrsn=vc) =null)
  IF ((reqdata->loglevel >= cv_info))
   IF (validate(reply))
    IF (cv_log_error_file=1
     AND validate(request)=1)
     CALL echorecord(request,cv_log_file_name,1)
    ENDIF
    CALL echorecord(reply)
   ENDIF
   CALL cv_log_msg(cv_info,concat("*** Leaving ",curprog," version:",script_vrsn," at ",
     format(cnvtdatetime(sysdate),"@SHORTDATETIME")))
  ENDIF
  IF (cv_log_error_string_cnt > 0)
   CALL cv_log_msg(cv_info,concat("*** The Error Log File is: ",cv_log_file_name))
   EXECUTE cv_log_flush_message
   SET cv_log_msg_cnt = 0
  ENDIF
 END ;Subroutine
 DECLARE app = i4 WITH protect, constant(4100700)
 DECLARE task = i4 WITH protect, constant(4100700)
 DECLARE req = i4 WITH protect, constant(951060)
 DECLARE ecrmok = i4 WITH protect, constant(0)
 DECLARE happ = i4
 DECLARE htask = i4
 DECLARE hreq = i4
 DECLARE hrequest = i4
 DECLARE hreply = i4
 DECLARE hchargeevent = i4
 DECLARE hchargeeventact = i4
 DECLARE crmstatus = i4
 DECLARE endapp = i2
 DECLARE endtask = i2
 DECLARE endreq = i2
 DECLARE charge_flg = i2
 DECLARE examroomlevelindex = i4 WITH protect
 DECLARE chargelistindex = i4 WITH protect
 DECLARE objcnt = i4 WITH protect, constant(size(request->objarray,5))
 DECLARE chg_service_dt_tm = dq8
 DECLARE cs13029_verified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",13029,"VERIFIED"))
 DECLARE chg_service_resource_cd = f8
 DECLARE chg_sched_loc_cd = f8
 DECLARE chg_perf_loc_cd = f8
 DECLARE parent_resource_cd = f8
 DECLARE res_group_type_cd = f8
 DECLARE child_resource_cd = f8
 IF (validate(reply->status_data.status,"0")="0")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 CALL fetchcvchargescodevalues(0)
 IF (objcnt=0)
  SET reply->status_data.status = "S"
  CALL cv_log_msg(cv_info,"No steps found in request")
  GO TO exit_script
 ENDIF
 SET stat = checkchargeconfig(charge_flg)
 IF (charge_flg <= 0)
  CALL cv_log_msg(cv_debug,"Professional Charge using Service Date is not set")
 ENDIF
 SET stat = alterlist(charges->charge_list,objcnt)
 FOR (i = 1 TO objcnt)
   SET charges->charge_list[i].step_id = request->objarray[i].cv_step_id
   SET charges->charge_list[i].new_step_status_cd = request->objarray[i].step_status_cd
   SET charges->charge_list[i].perf_loc_cd = request->objarray[i].perf_loc_cd
   SET charges->charge_list[i].service_dt_tm = request->objarray[i].perf_stop_dt_tm
   SET charges->charge_list[i].task_assay_cd = request->objarray[i].task_assay_cd
   SET charges->charge_list[i].cv_proc_id = request->objarray[i].cv_proc_id
 ENDFOR
 CALL filterstepsforcharges(0)
 IF (charge_event_cnt=0)
  SET reply->status_data.status = "S"
  CALL cv_log_msg(cv_info,"No charges to be dropped or reversed")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO objcnt)
   IF (charge_flg > 0
    AND (charges->charge_list[i].step_type_cd=step_type_final_report_cd))
    SELECT INTO "nl:"
     FROM cv_step cs,
      cv_step_ref csr
     PLAN (cs)
      JOIN (csr
      WHERE csr.task_assay_cd=cs.task_assay_cd
       AND csr.step_type_cd=step_type_procedure_cd
       AND (cs.cv_proc_id=request->objarray[i].cv_proc_id))
     DETAIL
      chg_service_dt_tm = cs.perf_stop_dt_tm
     WITH nocounter
    ;end select
    SET charges->charge_list[i].service_dt_tm = chg_service_dt_tm
   ENDIF
 ENDFOR
 IF (institution_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=INSTITUTION;CODE_SET=223")
  GO TO exit_script
 ENDIF
 IF (department_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=DEPARTMENT;CODE_SET=223")
  GO TO exit_script
 ENDIF
 IF (section_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=SECTION;CODE_SET=223")
  GO TO exit_script
 ENDIF
 IF (subsection_cd <= 0.0)
  CALL cv_log_stat(cv_error,"SELECT","F","CODE_VALUE","CDF_MEANING=SUBSECTION;CODE_SET=223")
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO objcnt)
   SET chg_sched_loc_cd = 0.0
   SET chg_perf_loc_cd = 0.0
   IF ((charges->charge_list[i].schedule_ind=1))
    SELECT INTO "nl:"
     FROM cv_step cs,
      cv_step_sched css
     PLAN (cs
      WHERE (cs.cv_proc_id=request->objarray[i].cv_proc_id))
      JOIN (css
      WHERE css.cv_step_id=cs.cv_step_id)
     DETAIL
      chg_sched_loc_cd = css.sched_loc_cd
     WITH nocounter
    ;end select
   ENDIF
   SET chg_perf_loc_cd = charges->charge_list[i].perf_loc_cd
   IF (chg_perf_loc_cd=0)
    SET charges->charge_list[i].service_resource_cd = chg_sched_loc_cd
    SET charges->charge_list[i].level5_cd = chg_sched_loc_cd
   ELSE
    SET charges->charge_list[i].service_resource_cd = chg_perf_loc_cd
    SET charges->charge_list[i].level5_cd = chg_perf_loc_cd
   ENDIF
   CALL echo(build("SERVICE RESOURCE Level5_cd = ",charges->charge_list[i].level5_cd))
   SET child_resource_cd = charges->charge_list[i].level5_cd
   IF ((charges->charge_list[i].level5_cd != 0))
    FOR (examroomlevelindex = 1 TO 4)
      SELECT INTO "nl:"
       FROM resource_group r
       WHERE r.child_service_resource_cd=child_resource_cd
       DETAIL
        parent_resource_cd = r.parent_service_resource_cd, res_group_type_cd = r
        .resource_group_type_cd
       WITH nocounter
      ;end select
      CASE (res_group_type_cd)
       OF institution_cd:
        SET charges->charge_list[i].institution_cd = parent_resource_cd
       OF department_cd:
        SET charges->charge_list[i].department_cd = parent_resource_cd
       OF section_cd:
        SET charges->charge_list[i].section_cd = parent_resource_cd
       OF subsection_cd:
        SET charges->charge_list[i].subsection_cd = parent_resource_cd
      ENDCASE
      SET child_resource_cd = parent_resource_cd
    ENDFOR
   ENDIF
 ENDFOR
 SET nstart = 1
 SELECT
  IF (cur_list_size > 1)
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    encounter e,
    cv_proc cp
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (cp
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),cp.cv_proc_id,charges->charge_list[idx].
     cv_proc_id))
    JOIN (e
    WHERE e.encntr_id=cp.encntr_id)
  ELSE
   FROM encounter e,
    cv_proc cp
   PLAN (cp
    WHERE (cp.cv_proc_id=charges->charge_list[1].cv_proc_id))
    JOIN (e
    WHERE e.encntr_id=cp.encntr_id)
  ENDIF
  INTO "nl:"
  FROM cv_proc cp,
   encounter e
  PLAN (cp
   WHERE (cp.cv_proc_id=- (1.0)))
   JOIN (e
   WHERE e.encntr_id=cp.encntr_id)
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,cp.cv_proc_id,charges->charge_list[num1].cv_proc_id)
   WHILE (index != 0)
    IF ((charges->charge_list[index].charge_ind > 0))
     charges->charge_list[index].fin_class_cd = e.financial_class_cd, charges->charge_list[index].
     encntr_org_id = e.organization_id, charges->charge_list[index].loc_nurse_unit_cd = e
     .loc_nurse_unit_cd,
     charges->charge_list[index].encntr_type_cd = e.encntr_type_cd, charges->charge_list[index].
     encntr_id = e.encntr_id, charges->charge_list[index].order_id = cp.order_id,
     charges->charge_list[index].person_id = cp.person_id, charges->charge_list[index].catalog_cd =
     cp.catalog_cd
    ENDIF
    ,index = locateval(num1,(index+ 1),cur_list_size,cp.cv_proc_id,charges->charge_list[num1].
     cv_proc_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET nstart = 1
 SELECT
  IF (cur_list_size > 1)
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    encntr_prsnl_reltn epr
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (epr
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),epr.encntr_id,charges->charge_list[idx].
     encntr_id)
     AND epr.encntr_prsnl_r_cd=encntr_prsnl_reltn_referdoc_cd
     AND epr.active_ind=1
     AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
  ELSE
   FROM encntr_prsnl_reltn epr
   WHERE (epr.encntr_id=charges->charge_list[1].encntr_id)
    AND epr.encntr_prsnl_r_cd=encntr_prsnl_reltn_referdoc_cd
    AND epr.active_ind=1
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate)
  ENDIF
  INTO "nl:"
  FROM encntr_prsnl_reltn epr
  WHERE (epr.encntr_id=- (1.0))
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,epr.encntr_id,charges->charge_list[num1].encntr_id)
   IF (index > 0
    AND (charges->charge_list[index].charge_ind > 0))
    charges->charge_list[index].ref_phys_id = epr.prsnl_person_id
   ENDIF
  WITH nocounter, maxqual(epr,1)
 ;end select
 SET nstart = 1
 SELECT
  IF (cur_list_size > 1)
   FROM (dummyt d1  WITH seq = value(loop_cnt)),
    oe_field_meaning ofm,
    order_detail od
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ batch_size))))
    JOIN (od
    WHERE expand(idx,nstart,(nstart+ (batch_size - 1)),od.order_id,charges->charge_list[idx].order_id
     ))
    JOIN (ofm
    WHERE ofm.oe_field_meaning="ORDERLOC"
     AND ofm.oe_field_meaning_id=od.oe_field_meaning_id)
  ELSE
   FROM oe_field_meaning ofm,
    order_detail od
   PLAN (od
    WHERE (od.order_id=charges->charge_list[1].order_id))
    JOIN (ofm
    WHERE ofm.oe_field_meaning="ORDERLOC"
     AND ofm.oe_field_meaning_id=od.oe_field_meaning_id)
  ENDIF
  INTO "nl:"
  FROM order_detail od
  WHERE (od.order_id=- (1.0))
  HEAD REPORT
   num1 = 0
  DETAIL
   index = locateval(num1,1,cur_list_size,od.order_id,charges->charge_list[num1].order_id)
   IF (index > 0
    AND (charges->charge_list[index].charge_ind > 0))
    charges->charge_list[index].ord_loc_cd = od.oe_field_value
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(charges->charge_list,cur_list_size)
 DECLARE cs_order_id = f8 WITH protect
 DECLARE order_id = f8 WITH protect
 DECLARE catalog_cd = f8 WITH protect
 IF (((validate(charges->charge_list[1].cs_order_id)=0) OR (validate(charges->charge_list[1].
  cs_catalog_cd)=0)) )
  CALL echo(
   "Error! Old cv_charges.inc used when compiling script. Please recompile with newest version.")
  CALL cv_log_stat(cv_error,"VALIDATE","F","CS_ORDER_ID",
   "Error! Old cv_charges.inc used when compiling script. Please recompile with newest version.")
  GO TO exit_script
 ENDIF
 FOR (chargelistindex = 1 TO value(size(charges->charge_list,5)))
   IF ((charges->charge_list[chargelistindex].charge_ind > 0))
    SET cs_order_id = charges->charge_list[chargelistindex].order_id
    WHILE (cs_order_id > 0.0)
     SELECT INTO "nl:"
      FROM orders o
      WHERE o.order_id=cs_order_id
      DETAIL
       order_id = o.order_id, catalog_cd = o.catalog_cd, cs_order_id = o.cs_order_id
      WITH nocounter
     ;end select
     IF (curqual=0)
      SET cs_order_id = 0.0
     ENDIF
    ENDWHILE
    SET charges->charge_list[chargelistindex].cs_order_id = order_id
    SET charges->charge_list[chargelistindex].cs_catalog_cd = catalog_cd
   ENDIF
 ENDFOR
 CALL echorecord(charges)
 SET crmstatus = uar_crmbeginapp(app,happ)
 IF (crmstatus != ecrmok)
  CALL echo(concat("Error! uar_CrmBeginApp failed with status: ",cnvtstring(crmstatus)))
  CALL cv_log_stat(cv_error,"uar_CrmBeginApp","F","App 4100700",concat("Failed with status: ",
    cnvtstring(crmstatus)))
  GO TO exit_script
 ELSE
  SET endapp = 1
 ENDIF
 SET crmstatus = uar_crmbegintask(happ,task,htask)
 IF (crmstatus != ecrmok)
  CALL echo(concat("Error! uar_CrmBeginTask failed with status: ",cnvtstring(crmstatus)))
  CALL cv_log_stat(cv_error,"uar_CrmBeginTask","F","Task 4100700",concat("Failed with status: ",
    cnvtstring(crmstatus)))
  GO TO exit_script
 ELSE
  SET endtask = 1
 ENDIF
 SET crmstatus = uar_crmbeginreq(htask,0,req,hreq)
 IF (crmstatus != ecrmok)
  CALL echo(concat("Error! uar_CrmBeginReq failed with status: ",cnvtstring(crmstatus)))
  CALL cv_log_stat(cv_error,"uar_CrmBeginReq","F","Req 951060",concat("Failed with status: ",
    cnvtstring(crmstatus)))
  GO TO exit_script
 ELSE
  SET endreq = 1
 ENDIF
 SET hrequest = uar_crmgetrequest(hreq)
 IF (hrequest=0)
  CALL echo("Invalid hRequest handle returned from CrmGetRequest")
  GO TO exit_script
 ENDIF
 CALL echo("sending fields to server")
 SET stat = uar_srvsetshort(hrequest,"charge_event_qual",charge_event_cnt)
 FOR (cur_charge_event = 1 TO cur_list_size)
   IF ((charges->charge_list[cur_charge_event].charge_ind > 0))
    SET hchargeevent = uar_srvadditem(hrequest,"charge_event")
    IF (hchargeevent=0)
     CALL echo("Invalid hChargeEvent handle returned from uar_SrvAddItem")
    ELSE
     SET stat = uar_srvsetdouble(hchargeevent,"ext_master_event_id",charges->charge_list[
      cur_charge_event].cs_order_id)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_master_event_cont_cd",cd->ext_contrib_ord_id_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_master_reference_id",charges->charge_list[
      cur_charge_event].cs_catalog_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_master_reference_cont_cd",cd->
      ext_contrib_ord_cat_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_parent_event_id",charges->charge_list[
      cur_charge_event].order_id)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_parent_event_cont_cd",cd->ext_contrib_ord_id_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_parent_reference_id",charges->charge_list[
      cur_charge_event].catalog_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_parent_reference_cont_cd",cd->
      ext_contrib_ord_cat_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_item_event_id",charges->charge_list[
      cur_charge_event].step_id)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_item_event_cont_cd",cd->ext_contrib_ord_id_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_item_reference_id",charges->charge_list[
      cur_charge_event].task_assay_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ext_item_reference_cont_cd",cd->
      ext_contrib_task_assay_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"order_id",charges->charge_list[cur_charge_event].
      order_id)
     SET stat = uar_srvsetdouble(hchargeevent,"person_id",charges->charge_list[cur_charge_event].
      person_id)
     SET stat = uar_srvsetdouble(hchargeevent,"encntr_id",charges->charge_list[cur_charge_event].
      encntr_id)
     SET stat = uar_srvsetdouble(hchargeevent,"encntr_org_id",charges->charge_list[cur_charge_event].
      encntr_org_id)
     SET stat = uar_srvsetdouble(hchargeevent,"fin_class_cd",charges->charge_list[cur_charge_event].
      fin_class_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ord_loc_cd",charges->charge_list[cur_charge_event].
      ord_loc_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"loc_nurse_unit_cd",charges->charge_list[
      cur_charge_event].loc_nurse_unit_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"encntr_type_cd",charges->charge_list[cur_charge_event]
      .encntr_type_cd)
     SET stat = uar_srvsetdouble(hchargeevent,"ref_phys_id",charges->charge_list[cur_charge_event].
      ref_phys_id)
     SET stat = uar_srvsetshort(hchargeevent,"charge_event_act_qual",1)
     SET stat = uar_srvsetdouble(hchargeevent,"perf_loc_cd",charges->charge_list[cur_charge_event].
      perf_loc_cd)
     SET hcharges = uar_srvadditem(hchargeevent,"charges")
     SET stat = uar_srvsetdouble(hcharges,"level5_cd",charges->charge_list[cur_charge_event].
      level5_cd)
     SET stat = uar_srvsetdouble(hcharges,"institution_cd",charges->charge_list[cur_charge_event].
      institution_cd)
     SET stat = uar_srvsetdouble(hcharges,"department_cd",charges->charge_list[cur_charge_event].
      department_cd)
     SET stat = uar_srvsetdouble(hcharges,"section_cd",charges->charge_list[cur_charge_event].
      section_cd)
     SET stat = uar_srvsetdouble(hcharges,"subsection_cd",charges->charge_list[cur_charge_event].
      subsection_cd)
     SET hchargeeventact = uar_srvadditem(hchargeevent,"charge_event_act")
     IF (hchargeeventact=0)
      CALL echo("Invalid hChargeEventAct handle returned from uar_SrvAddItem")
     ELSE
      IF ((charges->charge_list[cur_charge_event].charge_ind=drop_charge_ind)
       AND (charges->charge_list[cur_charge_event].step_type_cd=step_type_procedure_cd))
       SET stat = uar_srvsetdouble(hchargeeventact,"charge_type_cd",cd->charge_type_dr_cd)
       SET stat = uar_srvsetdouble(hchargeeventact,"cea_type_cd",cd->cea_type_performed_cd)
      ELSEIF ((charges->charge_list[cur_charge_event].charge_ind=drop_charge_ind)
       AND (charges->charge_list[cur_charge_event].step_type_cd=step_type_final_report_cd))
       SET stat = uar_srvsetdouble(hchargeeventact,"charge_type_cd",cd->charge_type_dr_cd)
       SET stat = uar_srvsetdouble(hchargeeventact,"cea_type_cd",cd->cea_type_verified_cd)
       SET hprsnl = uar_srvadditem(hchargeeventact,"prsnl")
       SET stat = uar_srvsetdouble(hprsnl,"prsnl_id",cnvtreal(request->objarray[cur_charge_event].
         perf_provider_id))
       SET stat = uar_srvsetdouble(hprsnl,"prsnl_type_cd",cs13029_verified_cd)
      ELSEIF ((charges->charge_list[cur_charge_event].charge_ind=reverse_charge_ind))
       SET stat = uar_srvsetdouble(hchargeeventact,"charge_type_cd",cd->charge_type_cr_cd)
       SET stat = uar_srvsetdouble(hchargeeventact,"cea_type_cd",cd->cea_type_reverse_cd)
      ENDIF
      SET stat = uar_srvsetlong(hchargeeventact,"quantity",1)
      SET stat = uar_srvsetdate(hchargeeventact,"service_dt_tm",charges->charge_list[cur_charge_event
       ].service_dt_tm)
      SET stat = uar_srvsetdouble(hchargeeventact,"service_resource_cd",charges->charge_list[
       cur_charge_event].service_resource_cd)
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET crmstatus = uar_crmperform(hreq)
 IF (crmstatus != ecrmok)
  CALL echo(concat("Error! uar_CrmPerform failed with status: ",cnvtstring(crmstatus)))
  CALL cv_log_stat(cv_error,"uar_CrmPerform","F","Req 951060",concat("Failed with status: ",
    cnvtstring(crmstatus)))
  GO TO exit_script
 ENDIF
 SUBROUTINE (checkchargeconfig(p_charge_flag=i2(ref)) =i4)
   DECLARE curvalue = i4 WITH private, noconstant(0)
   DECLARE curpref = i4 WITH private, noconstant(1)
   DECLARE prefcnt = i4 WITH private, noconstant(0)
   SET pref_request->context = "default"
   SET pref_request->context_id = "system"
   SET pref_request->section = "module"
   SET pref_request->section_id = "cvnet"
   SET pref_request->debug = "0"
   SET p_charge_flag = 0
   EXECUTE cv_get_preferences  WITH replace("REQUEST",pref_request), replace("REPLY",pref_reply)
   IF ((pref_reply->status_data.status="F"))
    SET p_charge_flag = - (1)
    CALL cv_log_stat(cv_audit,"CALL","Z","FindPreference","charge_service_date")
   ENDIF
   SET prefcnt = size(pref_reply->entries,5)
   FOR (curpref = 1 TO prefcnt)
     IF (p_charge_flag=0.0
      AND (pref_reply->entries[curpref].name="charge_service_date"))
      FOR (curvalue = 1 TO size(pref_reply->entries[curpref].values,5))
        IF (cnvtreal(pref_reply->entries[curpref].values[curvalue].value) > 0.0)
         SET p_charge_flag = cnvtreal(pref_reply->entries[curpref].values[curvalue].value)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 IF (endreq)
  CALL uar_crmendreq(hreq)
 ENDIF
 IF (endtask)
  CALL uar_crmendtask(htask)
 ENDIF
 IF (endapp)
  CALL uar_crmendapp(happ)
 ENDIF
 CALL cv_log_msg_post("MOD 010 SS028138 02/12/2021")
END GO
