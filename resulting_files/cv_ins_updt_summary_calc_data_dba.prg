CREATE PROGRAM cv_ins_updt_summary_calc_data:dba
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  SET null_date = "31-DEC-2100 00:00:00"
  SET cv_log_debug = 5
  SET cv_log_info = 4
  SET cv_log_audit = 3
  SET cv_log_warning = 2
  SET cv_log_error = 1
  SET cv_log_handle_cnt = 1
  SET cv_log_handle = 0
  SET cv_log_status = 0
  SET cv_log_level = 0
  SET cv_log_echo_level = 0
  SET cv_log_error_time = 0
  SET cv_log_error_file = 1
  SET cv_log_error_string = fillstring(32000," ")
  SET cv_err_msg = fillstring(100," ")
  SET cv_log_err_num = 0
  SET cv_log_file_name = build("cer_temp:CV_DEFAULT",format(cnvtdatetime(curdate,curtime3),
    "HHMMSS;;q"),".dat")
  SET cv_log_struct_file_name = build("cer_temp:",curprog)
  SET cv_log_struct_file_nbr = 0
  SET cv_log_event = "CV_DEFAULT_LOG"
  SET cv_log_level = cv_log_debug
  SET cv_def_log_level = cv_log_debug
  SET cv_log_echo_level = cv_log_debug
  SET cv_log_chg_to_default = 1
  SET cv_log_error_time = 1
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 SUBROUTINE cv_log_message(log_message_param)
   SET cv_log_err_num = (cv_log_err_num+ 1)
   SET cv_err_msg = fillstring(100," ")
   IF (cv_log_error_time=0)
    SET cv_err_msg = log_message_param
   ELSE
    SET cv_err_msg = build(log_message_param," at :",format(cnvtdatetime(curdate,curtime3),
      "@SHORTDATETIME"))
   ENDIF
   IF (cv_log_chg_to_default=1)
    SET cv_log_level = cv_def_log_level
   ENDIF
   IF (cv_log_echo_level > cv_log_audit)
    CALL echo(cv_err_msg)
   ENDIF
   IF (cv_log_error_file=1)
    SET cv_log_error_string = build(cv_log_error_string,char(10),cv_err_msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
   ENDIF
   SET reply->status_data.subeventstatus[num_event].targetobjectname = object_name_param
   SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
   SET reply->status_data.subeventstatus[num_event].operationname = operation_name_param
   SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 IF ( NOT (validate(calc_reply,0)))
  RECORD calc_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF ( NOT (validate(ec_list,0)))
  RECORD ec_list(
    1 list[*]
      2 event_cd = f8
      2 cdf_meaning = c12
      2 dta = f8
  )
 ENDIF
 SET stat = alterlist(ec_list->list,8)
 SET clac_failed = "F"
 SET ec_list->list[1].cdf_meaning = cdf_accv2_num_pci
 SET ec_list->list[2].cdf_meaning = cdf_accv2_mult_pci
 SET ec_list->list[3].cdf_meaning = cdf_accv2_proc_num
 SET ec_list->list[4].cdf_meaning = cdf_accv2_cathpci
 SET ec_list->list[5].cdf_meaning = cdf_accv2_les_attemped
 SET ec_list->list[6].cdf_meaning = cdf_accv2_les_dilated
 SET ec_list->list[7].cdf_meaning = cdf_accv2_proc_resulst
 SET ec_list->list[8].cdf_meaning = cdf_lesion_id_num
 SET ec_cnt = size(ec_list->list,5)
 FOR (ecnt = 1 TO ec_cnt)
   DECLARE iret = i2
   SET iret = uar_get_meaning_by_codeset(14003,ec_list->list[ecnt].cdf_meaning,1,ec_list->list[ecnt].
    dta)
   SELECT INTO "nl:"
    *
    FROM discrete_task_assay dta
    WHERE (dta.task_assay_cd=ec_list->list[ecnt].dta)
    DETAIL
     ec_list->list[ecnt].event_cd = dta.event_cd
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("No event_cd found! Exit Program")
    SET clac_failed = "T"
    GO TO exit_script
   ENDIF
 ENDFOR
 IF ( NOT (validate(all_case,0)))
  RECORD all_case(
    1 cases[*]
      2 case_id = f8
      2 encntr_id = f8
      2 all_case_ins_ind = i2
      2 del_ind = i2
  )
 ENDIF
 SET case_cnt = 0
 SELECT INTO "nl:"
  *
  FROM cv_case cc
  WHERE (cc.encntr_id=cv_calc_rec->encntr_id)
  DETAIL
   case_cnt = (case_cnt+ 1), stat = alterlist(all_case->cases,case_cnt), all_case->cases[case_cnt].
   case_id = cc.cv_case_id,
   all_case->cases[case_cnt].encntr_id = cv_calc_rec->encntr_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No cases associated with this encounter!")
 ENDIF
 FOR (ecnt = 1 TO ec_cnt)
   DELETE  FROM cv_les_abstr_data clad,
     (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
     (dummyt d2  WITH seq = value(cv_calc_rec->max_les)),
     (dummyt d3  WITH seq = value(cv_calc_rec->max_les_abs))
    SET clad.seq = 1
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5))
     JOIN (d3
     WHERE d3.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data,5))
     JOIN (clad
     WHERE (ec_list->list[ecnt].event_cd=clad.event_cd)
      AND (cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].lesion_id=clad
     .lesion_id))
    WITH nocounter
   ;end delete
 ENDFOR
 IF (curqual=0)
  CALL cv_log_message("No records deleted in cv_les_abstr_data table!")
 ENDIF
 FOR (ecnt = 1 TO ec_cnt)
   DELETE  FROM cv_proc_abstr_data cpad,
     (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
     (dummyt d2  WITH seq = value(cv_calc_rec->max_pro_abs))
    SET cpad.seq = 1
    PLAN (d1)
     JOIN (d2
     WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].proc_abstr_data,5))
     JOIN (cpad
     WHERE (ec_list->list[ecnt].event_cd=cpad.event_cd)
      AND (cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].procedure_id=cpad.procedure_id))
    WITH nocounter
   ;end delete
 ENDFOR
 IF (curqual=0)
  CALL cv_log_message("No records deleted in cv_proc_abstr_data table!")
 ENDIF
 FOR (idx = 1 TO size(all_case->cases,5))
   DELETE  FROM cv_case_abstr_data ccad,
     (dummyt d  WITH seq = value(ec_cnt))
    SET ccad.seq = 1
    PLAN (d
     WHERE (ec_list->list[d.seq].cdf_meaning IN (cdf_accv2_num_pci, cdf_accv2_mult_pci,
     cdf_accv2_proc_num)))
     JOIN (ccad
     WHERE (ec_list->list[d.seq].event_cd=ccad.event_cd)
      AND (ccad.cv_case_id=all_case->cases[idx].case_id))
    WITH nocounter
   ;end delete
 ENDFOR
 IF (curqual=0)
  CALL cv_log_message("No encounter level records deleted in cv_case_abstr_data table!")
 ELSE
  CALL cv_log_message("Encouter level records deleted in cv_case_abstr_data table!")
 ENDIF
 DELETE  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(ec_cnt))
  SET ccad.seq = 1
  PLAN (d
   WHERE (ec_list->list[d.seq].cdf_meaning=cdf_accv2_cathpci))
   JOIN (ccad
   WHERE (ec_list->list[d.seq].event_cd=ccad.event_cd)
    AND (ccad.cv_case_id=cv_calc_rec->case_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No case level records deleted in cv_case_abstr_data table!")
 ENDIF
 SET les_abs_cnt = 0
 SELECT INTO "nl:"
  *
  FROM cv_les_abstr_data clad,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_les))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5))
   JOIN (clad
   WHERE (cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].lesion_id=clad.lesion_id))
  DETAIL
   les_abs_cnt = (les_abs_cnt+ 1), cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].del_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in selecting cv_les_abstr_data for deleting lesions!")
 ENDIF
 DELETE  FROM cv_lesion cl,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_les))
  SET cl.seq = 1
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5)
    AND (cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].del_ind=0))
   JOIN (cl
   WHERE (cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].lesion_id=cl.lesion_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No lesion records were deleted with this case or procedure!")
 ENDIF
 SELECT INTO "nl:"
  *
  FROM cv_proc_abstr_data cpad,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_pro_abs))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].proc_abstr_data,5))
   JOIN (cpad
   WHERE (cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].procedure_id=cpad.procedure_id))
  DETAIL
   stat = alterlist(cv_calc_rec->proc_data,d1.seq), cv_calc_rec->proc_data[d1.seq].del_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in selecting cv_proc_abstr_data for deleting procedure!")
 ENDIF
 SELECT INTO "nl:"
  *
  FROM cv_lesion cl,
   (dummyt d  WITH seq = value(cv_calc_rec->max_pro))
  PLAN (d)
   JOIN (cl
   WHERE (cv_calc_rec->proc_data[d.seq].procedure_id=cl.procedure_id))
  DETAIL
   stat = alterlist(cv_calc_rec->proc_data,d.seq), cv_calc_rec->proc_data[d.seq].del_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in selecting cv_lesion for deleting procedure!")
 ENDIF
 DELETE  FROM cv_procedure cp,
   (dummyt d  WITH seq = value(size(cv_calc_rec->proc_data,5)))
  SET cp.seq = 1
  PLAN (d
   WHERE (cv_calc_rec->proc_data[d.seq].del_ind=0))
   JOIN (cp
   WHERE (cv_calc_rec->proc_data[d.seq].procedure_id=cp.procedure_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No procedure was deleted for this case!")
 ENDIF
 FOR (idx = 1 TO size(all_case->cases,5))
   SELECT INTO "nl:"
    *
    FROM cv_case_abstr_data ccad
    WHERE (all_case->cases[idx].case_id=ccad.cv_case_id)
    DETAIL
     all_case->cases[idx].del_ind = 1
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("Failed in selecting cv_case_abstr_data for deleting case!")
   ENDIF
   SELECT INTO "nl:"
    *
    FROM cv_procedure cp
    WHERE (all_case->cases[idx].case_id=cp.cv_case_id)
    DETAIL
     all_case->cases[idx].del_ind = 1
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL cv_log_message("Failed in selecting cv_lesion for deleting procedure!")
   ENDIF
   DELETE  FROM cv_case cc
    WHERE (cc.cv_case_id=all_case->cases[idx].case_id)
     AND (all_case->cases[idx].del_ind=0)
   ;end delete
   IF (curqual=0)
    SET cv_log_level = cv_log_audit
    CALL cv_log_current_default(0)
    CALL cv_log_message("No case field was deleted with this case!")
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  *
  FROM cv_case_abstr_data ccad,
   (dummyt d  WITH seq = value(size(all_case->cases,5)))
  PLAN (d)
   JOIN (ccad
   WHERE (all_case->cases[d.seq].case_id=ccad.cv_case_id))
  DETAIL
   all_case->cases[d.seq].all_case_ins_ind = 1
   IF ((all_case->cases[d.seq].case_id=cv_calc_rec->case_id))
    cv_calc_rec->case_ins_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM cv_proc_abstr_data cpad,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_pro_abs))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].proc_abstr_data,5))
   JOIN (cpad
   WHERE (cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].procedure_id=cpad.procedure_id))
  DETAIL
   cv_calc_rec->proc_ins_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in selecting cv_proc_abstr_data for inserting proc abstr data!")
 ENDIF
 SELECT INTO "nl:"
  *
  FROM cv_les_abstr_data clad,
   (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
   (dummyt d2  WITH seq = value(cv_calc_rec->max_les))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5))
   JOIN (clad
   WHERE (cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].lesion_id=clad.lesion_id))
  DETAIL
   cv_calc_rec->les_ins_ind = 1
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("Failed in selecting cv_les_abstr_data for inserting lesions!")
 ENDIF
 FOR (idx = 1 TO size(all_case->cases,5))
   IF ((all_case->cases[idx].all_case_ins_ind=1))
    INSERT  FROM cv_case_abstr_data ccad,
      (dummyt d  WITH seq = value(cv_calc_rec->max_case_abs))
     SET ccad.case_abstr_data_id = cnvtint(seq(card_vas_seq,nextval)), ccad.cv_case_id = all_case->
      cases[idx].case_id, ccad.event_cd = cv_calc_rec->case_abstr_data[d.seq].event_cd,
      ccad.nomenclature_id = cv_calc_rec->case_abstr_data[d.seq].nomenclature_id, ccad.result_val =
      cv_calc_rec->case_abstr_data[d.seq].result_val, ccad.active_ind = 1,
      ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd = reqdata->
      active_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = reqdata->
      data_status_cd, ccad.data_status_prsnl_id = reqinfo->updt_id,
      ccad.active_status_prsnl_id = reqinfo->updt_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,
       curtime3), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      ccad.updt_task = reqinfo->updt_task, ccad.updt_app = reqinfo->updt_app, ccad.updt_applctx =
      reqinfo->updt_applctx,
      ccad.updt_cnt = 0, ccad.updt_req = reqinfo->updt_req, ccad.updt_id = reqinfo->updt_id
     PLAN (d
      WHERE cnvtupper(trim(cv_calc_rec->case_abstr_data[d.seq].task_assay_meaning)) IN (
      cdf_accv2_num_pci, cdf_accv2_mult_pci))
      JOIN (ccad)
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET cv_log_level = cv_log_audit
     CALL cv_log_current_default(0)
     CALL echo("Failed in insert cv_case_abstr_data for encounter level calc data!")
    ELSE
     CALL cv_log_message("Success in insert cv_case_abstr_data for encntr calc data!")
    ENDIF
   ENDIF
 ENDFOR
 IF ((cv_calc_rec->case_ins_ind=1))
  INSERT  FROM cv_case_abstr_data ccad,
    (dummyt d  WITH seq = value(cv_calc_rec->max_case_abs))
   SET ccad.case_abstr_data_id = cnvtint(seq(card_vas_seq,nextval)), ccad.cv_case_id = cv_calc_rec->
    case_abstr_data[d.seq].case_id, ccad.event_cd = cv_calc_rec->case_abstr_data[d.seq].event_cd,
    ccad.nomenclature_id = cv_calc_rec->case_abstr_data[d.seq].nomenclature_id, ccad.result_val =
    cv_calc_rec->case_abstr_data[d.seq].result_val, ccad.active_ind = 1,
    ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd = reqdata->
    active_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = reqdata->data_status_cd,
    ccad.data_status_prsnl_id = reqinfo->updt_id,
    ccad.active_status_prsnl_id = reqinfo->updt_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,
     curtime3), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ccad.updt_task = reqinfo->updt_task, ccad.updt_app = reqinfo->updt_app, ccad.updt_applctx =
    reqinfo->updt_applctx,
    ccad.updt_cnt = 0, ccad.updt_req = reqinfo->updt_req, ccad.updt_id = reqinfo->updt_id
   PLAN (d
    WHERE trim(cv_calc_rec->case_abstr_data[d.seq].task_assay_meaning)=cdf_accv2_proc_num)
    JOIN (ccad)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("Failed in insert cv_case_abstr_data for case level calc data!")
  ELSE
   CALL cv_log_message("Success in insert cv_case_abstr_data for case level proc num data!")
  ENDIF
  INSERT  FROM cv_case_abstr_data ccad,
    (dummyt d  WITH seq = value(cv_calc_rec->max_case_abs))
   SET ccad.case_abstr_data_id = cnvtint(seq(card_vas_seq,nextval)), ccad.cv_case_id = cv_calc_rec->
    case_id, ccad.event_cd = cv_calc_rec->case_abstr_data[d.seq].event_cd,
    ccad.nomenclature_id = cv_calc_rec->case_abstr_data[d.seq].nomenclature_id, ccad.result_val =
    cv_calc_rec->case_abstr_data[d.seq].result_val, ccad.active_ind = 1,
    ccad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ccad.active_status_cd = reqdata->
    active_status_cd, ccad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    ccad.end_effective_dt_tm = cnvtdatetime(null_date), ccad.data_status_cd = reqdata->data_status_cd,
    ccad.data_status_prsnl_id = reqinfo->updt_id,
    ccad.active_status_prsnl_id = reqinfo->updt_id, ccad.data_status_dt_tm = cnvtdatetime(curdate,
     curtime3), ccad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    ccad.updt_task = reqinfo->updt_task, ccad.updt_app = reqinfo->updt_app, ccad.updt_applctx =
    reqinfo->updt_applctx,
    ccad.updt_cnt = 0, ccad.updt_req = reqinfo->updt_req, ccad.updt_id = reqinfo->updt_id
   PLAN (d
    WHERE trim(cv_calc_rec->case_abstr_data[d.seq].task_assay_meaning)=cdf_accv2_cathpci)
    JOIN (ccad)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("Failed in insert cv_case_abstr_data for case level cath/pci data!")
  ELSE
   CALL cv_log_message("Success in insert cv_case_abstr_data for case level cath/pci data!")
  ENDIF
 ENDIF
 IF ((cv_calc_rec->proc_ins_ind=1))
  INSERT  FROM cv_proc_abstr_data cpad,
    (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
    (dummyt d2  WITH seq = value(cv_calc_rec->max_pro_abs))
   SET cpad.proc_abstr_data_id = cnvtint(seq(card_vas_seq,nextval)), cpad.procedure_id = cv_calc_rec
    ->proc_data[d1.seq].proc_abstr_data[d2.seq].procedure_id, cpad.event_cd = cv_calc_rec->proc_data[
    d1.seq].proc_abstr_data[d2.seq].event_cd,
    cpad.nomenclature_id = cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].nomenclature_id,
    cpad.result_val = cv_calc_rec->proc_data[d1.seq].proc_abstr_data[d2.seq].result_val, cpad
    .active_ind = 1,
    cpad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), cpad.active_status_cd = reqdata->
    active_status_cd, cpad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    cpad.end_effective_dt_tm = cnvtdatetime(null_date), cpad.data_status_cd = reqdata->data_status_cd,
    cpad.data_status_prsnl_id = reqinfo->updt_id,
    cpad.active_status_prsnl_id = reqinfo->updt_id, cpad.data_status_dt_tm = cnvtdatetime(curdate,
     curtime3), cpad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cpad.updt_task = reqinfo->updt_task, cpad.updt_app = reqinfo->updt_app, cpad.updt_applctx =
    reqinfo->updt_applctx,
    cpad.updt_cnt = 0, cpad.updt_req = reqinfo->updt_req, cpad.updt_id = reqinfo->updt_id
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].proc_abstr_data,5))
    JOIN (cpad)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("Failed in insert cv_proc_abstr_data for calc data!")
  ELSE
   CALL cv_log_message("Success in insert cv_proc_abstr_data for calc data!")
  ENDIF
 ENDIF
 IF ((cv_calc_rec->les_ins_ind=1))
  INSERT  FROM cv_les_abstr_data clad,
    (dummyt d1  WITH seq = value(cv_calc_rec->max_pro)),
    (dummyt d2  WITH seq = value(cv_calc_rec->max_les)),
    (dummyt d3  WITH seq = value(cv_calc_rec->max_les_abs))
   SET clad.les_abstr_data_id = cnvtint(seq(card_vas_seq,nextval)), clad.lesion_id = cv_calc_rec->
    proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].lesion_id, clad.event_cd = cv_calc_rec->
    proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].event_cd,
    clad.nomenclature_id = cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[d3.seq].
    nomenclature_id, clad.result_val = cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data[
    d3.seq].result_val, clad.active_ind = 1,
    clad.active_status_dt_tm = cnvtdatetime(curdate,curtime3), clad.active_status_cd = reqdata->
    active_status_cd, clad.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    clad.end_effective_dt_tm = cnvtdatetime(null_date), clad.data_status_cd = reqdata->data_status_cd,
    clad.data_status_prsnl_id = reqinfo->updt_id,
    clad.active_status_prsnl_id = reqinfo->updt_id, clad.data_status_dt_tm = cnvtdatetime(curdate,
     curtime3), clad.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    clad.updt_task = reqinfo->updt_task, clad.updt_app = reqinfo->updt_app, clad.updt_applctx =
    reqinfo->updt_applctx,
    clad.updt_cnt = 0, clad.updt_req = reqinfo->updt_req, clad.updt_id = reqinfo->updt_id
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion,5))
    JOIN (d3
    WHERE d3.seq <= size(cv_calc_rec->proc_data[d1.seq].lesion[d2.seq].les_abstr_data,5))
    JOIN (clad)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET cv_log_level = cv_log_audit
   CALL cv_log_current_default(0)
   CALL cv_log_message("Failed in insert cv_les_abstr_data for calc data!")
  ELSE
   CALL cv_log_message("Success in insert cv_les_abstr_data for calc data!")
  ENDIF
 ENDIF
 CALL echorecord(cv_calc_rec,"cer_temp:cv_calc_rec_af.dat")
 CALL echo("cv_calc_rec_af is saved in cer_temp:cv_calc_rec_af.dat")
#exit_script
 IF (clac_failed="T")
  SET calc_reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  ROLLBACK
 ELSE
  SET calc_reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
 CALL cv_log_destroyhandle(0)
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message(build("Leaving ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
  CALL cv_log_message(build("****************","The Error Log File is :",cv_log_file_name))
  EXECUTE cv_log_flush_message
 ENDIF
 SUBROUTINE cv_log_destroyhandle(dummy)
   IF ( NOT (validate(cv_log_handle_cnt,0)))
    CALL echo("Error Handle not created!!!")
   ELSE
    SET cv_log_handle_cnt = (cv_log_handle_cnt - 1)
   ENDIF
 END ;Subroutine
END GO
