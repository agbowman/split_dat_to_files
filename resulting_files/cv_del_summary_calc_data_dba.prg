CREATE PROGRAM cv_del_summary_calc_data:dba
 IF ( NOT (validate(cv_log_handle_cnt,0)))
  RECORD temp_text(
    1 qual[*]
      2 text = vc
  )
  DECLARE null_date = vc WITH protect, constant("31-DEC-2100 00:00:00")
  DECLARE cv_log_debug = i4 WITH protect, constant(4)
  DECLARE cv_log_info = i4 WITH protect, constant(3)
  DECLARE cv_log_audit = i4 WITH protect, constant(2)
  DECLARE cv_log_warning = i4 WITH protect, constant(1)
  DECLARE cv_log_error = i4 WITH protect, constant(0)
  DECLARE cv_log_handle_cnt = i4 WITH protect, noconstant(1)
  DECLARE cv_log_handle = i4 WITH protect
  DECLARE cv_log_status = i4 WITH protect
  DECLARE cv_log_error_file = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_string = c32000 WITH protect, noconstant(fillstring(32000," "))
  DECLARE cv_err_msg = c100 WITH protect, noconstant(fillstring(100," "))
  DECLARE cv_log_err_num = i4 WITH protect
  DECLARE cv_log_file_name = vc WITH protect, noconstant(build("cer_temp:CV_DEFAULT",format(
     cnvtdatetime(curdate,curtime3),"HHMMSS;;q"),".dat"))
  DECLARE cv_log_struct_file_name = vc WITH protect, noconstant(build("cer_temp:",curprog))
  DECLARE cv_log_struct_file_nbr = i4 WITH protect
  DECLARE cv_log_event = vc WITH protect, noconstant("CV_DEFAULT_LOG")
  DECLARE cv_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_def_log_level = i4 WITH protect, noconstant(cv_log_debug)
  DECLARE cv_log_echo_level = i4 WITH protect, noconstant(cv_log_debug)
  SET cv_log_level = reqdata->loglevel
  SET cv_def_log_level = reqdata->loglevel
  SET cv_log_echo_level = reqdata->loglevel
  IF (cv_log_level >= cv_log_info)
   SET cv_log_error_file = 1
  ELSE
   SET cv_log_error_file = 0
  ENDIF
  DECLARE cv_log_chg_to_default = i4 WITH protect, noconstant(1)
  DECLARE cv_log_error_time = i4 WITH protect, noconstant(1)
  DECLARE serrmsg = c132 WITH protect, noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH protect
  DECLARE cv_chk_err_label = vc WITH protect, noconstant("EXIT_SCRIPT")
  DECLARE num_event = i4 WITH protect
  IF ( NOT (validate(cv_hide_prog_sep,0)))
   CALL cv_log_message(build("The Error Log File is :",cv_log_file_name))
  ENDIF
 ELSE
  SET cv_log_handle_cnt = (cv_log_handle_cnt+ 1)
 ENDIF
 DECLARE cv_log_createhandle(dummy=i2) = null
 SUBROUTINE cv_log_createhandle(dummy)
   CALL uar_syscreatehandle(cv_log_handle,cv_log_status)
 END ;Subroutine
 DECLARE cv_log_current_default(dummy=i2) = null
 SUBROUTINE cv_log_current_default(dummy)
   SET cv_def_log_level = cv_log_level
 END ;Subroutine
 DECLARE cv_echo(string=vc) = null
 SUBROUTINE cv_echo(string)
   IF (cv_log_echo_level >= cv_log_audit)
    CALL echo(string)
   ENDIF
 END ;Subroutine
 DECLARE cv_log_message(log_message_param=vc) = null
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
 DECLARE cv_log_message_status(object_name_param=vc,operation_status_param=c1,operation_name_param=vc,
  target_object_value_param=vc) = null
 SUBROUTINE cv_log_message_status(object_name_param,operation_status_param,operation_name_param,
  target_object_value_param)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET num_event = size(reply->status_data.subeventstatus,5)
   IF (num_event=1)
    IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
     SET num_event = (num_event+ 1)
     SET stat = alterlist(reply->status_data.subeventstatus,num_event)
     SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
      object_name_param)
     SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
     SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
      operation_name_param)
     SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
    ENDIF
   ELSE
    SET num_event = (num_event+ 1)
    SET stat = alterlist(reply->status_data.subeventstatus,num_event)
    SET reply->status_data.subeventstatus[num_event].targetobjectname = substring(1,25,
     object_name_param)
    SET reply->status_data.subeventstatus[num_event].operationstatus = operation_status_param
    SET reply->status_data.subeventstatus[num_event].operationname = substring(1,25,
     operation_name_param)
    SET reply->status_data.subeventstatus[num_event].targetobjectvalue = target_object_value_param
   ENDIF
 END ;Subroutine
 DECLARE cv_check_err(opname=vc,opstatus=c1,targetname=vc) = null
 SUBROUTINE cv_check_err(opname,opstatus,targetname)
   IF ( NOT (validate(reply,0)))
    RETURN
   ENDIF
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode=0)
    RETURN
   ENDIF
   WHILE (ierrcode != 0)
     CALL cv_log_message_status(targetname,opstatus,opname,serrmsg)
     CALL cv_log_message(serrmsg)
     SET ierrcode = error(serrmsg,0)
     SET reply->status_data.status = "F"
   ENDWHILE
   IF (trim(reply->status_data.subeventstatus[1].targetobjectname) > "")
    GO TO cv_chk_err_label
   ENDIF
 END ;Subroutine
 IF ( NOT (validate(cv_hide_prog_sep,0)))
  CALL cv_log_message("*****************************************************")
  CALL cv_log_message(build("Entering ::",curprog," at ::",format(cnvtdatetime(curdate,curtime3),
     "@SHORTDATETIME")))
 ENDIF
 DECLARE cv_log_message_pre_vrsn = vc WITH private, constant("MOD 003 10/12/04 MH9140")
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
 IF ( NOT (validate(cv_omf_rec,0)))
  RECORD cv_omf_rec(
    1 max_lesion = i4
    1 max_lesion_abstr = i4
    1 max_proc_abstr = i4
    1 max_icdev = i4
    1 max_icdev_abstr = i4
    1 max_closdev = i4
    1 max_closdev_abstr = i4
    1 called_by_import = i2
    1 dataset[*]
      2 dataset_id = f8
      2 alias_pool_cd = f8
      2 alias_pool_mean = vc
      2 participant_nbr = vc
      2 organization_id = f8
      2 participant_prsnl_id = f8
      2 participant_prsnl_group_id = f8
      2 status_ind = i2
      2 case_dataset_r_id = f8
    1 admit_dt_tm = dq8
    1 admit_ind = i2
    1 age_group_cd = f8
    1 age_year = i4
    1 case_id = f8
    1 cv_case_nbr = f8
    1 form_event_id = f8
    1 death_ind = i2
    1 disch_dt_tm = dq8
    1 disch_ind = i2
    1 encntr_id = f8
    1 hospital_cd = f8
    1 los_adm_disch = i4
    1 los_adm_proc = i4
    1 los_proc_disch = i4
    1 admt_dt_num = i4
    1 disch_dt_num = i4
    1 proc_dt_num = i4
    1 proc_start_dt_tm = dq8
    1 num_proc = i4
    1 patient_type_cd = f8
    1 person_id = f8
    1 sex_cd = f8
    1 source_cd = f8
    1 organization_id = f8
    1 status_ind = i2
    1 updt_cnt = i2
    1 updt_id = f8
    1 top_parent_event_id = f8
    1 form_id = f8
    1 chart_dt_tm = dq8
    1 reference_nbr = c50
    1 case_abstr_data[*]
      2 case_abstr_id = f8
      2 case_id = f8
      2 event_cd = f8
      2 event_id = f8
      2 event_type_cd = f8
      2 field_type_cd = f8
      2 field_type_meaning = c12
      2 nomenclature_id = f8
      2 result_dt_tm = dq8
      2 result_id = f8
      2 result_status_cd = f8
      2 result_status_meaning = c12
      2 updt_cnt = i2
      2 result_val = vc
      2 task_assay_cd = f8
      2 task_assay_meaning = c12
      2 ins_upd_ind = i2
    1 proc_data[*]
      2 procedure_id = f8
      2 case_id = f8
      2 event_type_cd = f8
      2 proc_physician_id = f8
      2 proc_start_dt_tm = dq8
      2 proc_end_dt_tm = dq8
      2 proc_dur_min = i4
      2 proc_start_month = i4
      2 proc_start_day = i4
      2 proc_start_hour = i4
      2 proc_complete_ind = i2
      2 los_adm_proc = i4
      2 los_proc_disch = i4
      2 num_lesion = i4
      2 status_ind = i2
      2 updt_cnt = i2
      2 proc_abstr_data[*]
        3 procedure_id = f8
        3 event_cd = f8
        3 event_id = f8
        3 event_type_cd = f8
        3 field_type_cd = f8
        3 field_type_meaning = c12
        3 nomenclature_id = f8
        3 proc_abstr_id = f8
        3 result_dt_tm = dq8
        3 result_id = f8
        3 result_status_cd = f8
        3 result_status_meaning = c12
        3 updt_cnt = i2
        3 result_val = vc
        3 task_assay_cd = f8
        3 task_assay_meaning = c12
        3 ins_upd_ind = i2
      2 lesion[*]
        3 lesion_id = f8
        3 procedure_id = f8
        3 parent_event_id = f8
        3 status_ind = i2
        3 updt_cnt = i2
        3 les_abstr_data[*]
          4 event_cd = f8
          4 event_id = f8
          4 event_type_cd = f8
          4 field_type_cd = f8
          4 field_type_meaning = c12
          4 lesion_abstr_id = f8
          4 lesion_id = f8
          4 nomenclature_id = f8
          4 result_dt_tm = dq8
          4 result_id = f8
          4 result_status_cd = f8
          4 result_status_meaning = c12
          4 updt_cnt = i2
          4 result_val = vc
          4 task_assay_cd = f8
          4 task_assay_meaning = c12
          4 ins_upd_ind = i2
        3 icdevice[*]
          4 device_id = f8
          4 procedure_id = f8
          4 parent_event_id = f8
          4 status_ind = i2
          4 updt_cnt = i2
          4 icd_abstr_data[*]
            5 event_cd = f8
            5 event_id = f8
            5 event_type_cd = f8
            5 field_type_cd = f8
            5 field_type_meaning = c12
            5 device_abstr_id = f8
            5 device_id = f8
            5 nomenclature_id = f8
            5 result_dt_tm = dq8
            5 result_id = f8
            5 result_status_cd = f8
            5 result_status_meaning = c12
            5 updt_cnt = i2
            5 result_val = vc
            5 task_assay_cd = f8
            5 task_assay_meaning = c12
            5 ins_upd_ind = i2
    1 closuredevice[*]
      2 device_id = f8
      2 case_id = f8
      2 parent_event_id = f8
      2 status_ind = i2
      2 updt_cnt = i2
      2 cd_abstr_data[*]
        3 event_cd = f8
        3 event_id = f8
        3 event_type_cd = f8
        3 field_type_cd = f8
        3 field_type_meaning = c12
        3 device_abstr_id = f8
        3 device_id = f8
        3 nomenclature_id = f8
        3 result_dt_tm = dq8
        3 result_id = f8
        3 result_status_cd = f8
        3 result_status_meaning = c12
        3 updt_cnt = i2
        3 result_val = vc
        3 task_assay_cd = f8
        3 task_assay_meaning = c12
        3 ins_upd_ind = i2
    1 form_type_cd = f8
    1 form_type_mean = vc
    1 case_dt_tm = dq8
  )
  IF (validate(cv_status_add) != 1)
   DECLARE cv_status_add = i4 WITH protect, constant(0)
  ENDIF
  IF (validate(cv_status_chg) != 1)
   DECLARE cv_status_chg = i4 WITH protect, constant(1)
  ENDIF
  IF (validate(cv_status_del) != 1)
   DECLARE cv_status_del = i4 WITH protect, constant(2)
  ENDIF
 ENDIF
 IF ( NOT (validate(cv_calc_rec,0)))
  RECORD cv_calc_rec(
    1 case_id = f8
    1 encntr_id = f8
    1 max_case_abs = i4
    1 max_pro = i4
    1 max_pro_abs = i4
    1 max_les = i4
    1 max_les_abs = i4
    1 case_ins_ind = i2
    1 proc_ins_ind = i2
    1 les_ins_ind = i2
    1 case_ab_cnt = i2
    1 case_abstr_data[*]
      2 case_abstr_id = f8
      2 case_id = f8
      2 event_cd = f8
      2 nomenclature_id = f8
      2 result_val = vc
      2 task_assay_cd = f8
      2 task_assay_meaning = c12
    1 proc_data[*]
      2 procedure_id = f8
      2 case_id = f8
      2 les_attempted = i2
      2 les_dilated = i2
      2 del_ind = i2
      2 proc_abstr_data[*]
        3 procedure_id = f8
        3 cpad_cnt = i2
        3 event_cd = f8
        3 nomenclature_id = f8
        3 proc_abstr_id = f8
        3 result_val = vc
        3 task_assay_cd = f8
        3 task_assay_meaning = c12
      2 lesion[*]
        3 lesion_id = f8
        3 procedure_id = f8
        3 dev_cnt = i2
        3 del_ind = i2
        3 les_abstr_data[*]
          4 lesion_abstr_id = f8
          4 event_cd = f8
          4 lesion_id = f8
          4 nomenclature_id = f8
          4 result_val = vc
          4 task_assay_cd = f8
          4 task_assay_meaning = c12
  )
  DECLARE cdf_accv2_num_pci = c12 WITH protect, constant("AC02ANOPCI")
  DECLARE cdf_accv2_mult_pci = c12 WITH protect, constant("AC02AMULT")
  DECLARE cdf_accv2_proc_num = c12 WITH protect, constant("AC02VPROCNUM")
  DECLARE cdf_accv2_cathpci = c12 WITH protect, constant("AC02VCATHPCI")
  DECLARE cdf_accv2_proc_type = c12 WITH protect, constant("AC02VPROCTYP")
  DECLARE cdf_accv2_les_attemped = c12 WITH protect, constant("AC02PATT")
  DECLARE cdf_accv2_les_dilated = c12 WITH protect, constant("AC02PSUCC")
  DECLARE cdf_accv2_proc_results = c12 WITH protect, constant("AC02PREST")
  DECLARE cdf_accv2_les_segment = c12 WITH protect, constant("AC02LSEGT")
  DECLARE cdf_accv2_gw_mean = c12 WITH protect, constant("AC02LGUIDE")
  DECLARE cdf_accv2_pre_stn = c12 WITH protect, constant("AC02LPRSTN")
  DECLARE cdf_accv2_pos_stn = c12 WITH protect, constant("AC02LPSSTN")
  DECLARE cdf_accv2_timi_fl = c12 WITH protect, constant("AC02LPSTIMI")
  DECLARE cdf_lesion_id_num = c12 WITH protect, constant("AC02LLSNO")
  DECLARE xref_internal_name = vc WITH protect, constant("ACC02_LSEGT")
  DECLARE response_int_blank_name = vc WITH protect, constant("ACC02_LSEGT_<BLANK>")
  DECLARE response_proc_resu_suc = vc WITH protect, constant("ACC02_PREST_SUCCESSFUL")
  DECLARE response_proc_resu_psuc = vc WITH protect, constant("ACC02_PREST_PARTIALLY_SUCCESSFUL")
  DECLARE response_proc_resu_usuc = vc WITH protect, constant("ACC02_PREST_UNSUCCESSFUL")
  DECLARE response_post_suc_timi = vc WITH protect, constant(
   "ACC02_LPSTIMI_COMPLETE_AND_BRISK_FLOW_COMPLETE_PERFUSION")
  DECLARE response_gw_suc_pass = vc WITH protect, constant("ACC02_LGUIDE_SUCCESSFUL")
  DECLARE sub_cdf_meaning = c12
 ENDIF
 IF ( NOT (validate(calc_del_rec,0)))
  RECORD calc_del_rec(
    1 del_proc[*]
      2 procedure_id = f8
    1 del_les[*]
      2 lesion_id = f8
  )
 ENDIF
 IF ( NOT (validate(ec_list,0)))
  RECORD ec_list(
    1 list[*]
      2 cdf_meaning = c12
      2 dta = f8
  )
 ENDIF
 IF ( NOT (validate(all_case,0)))
  RECORD all_case(
    1 cases[*]
      2 case_id = f8
      2 encntr_id = f8
  )
 ENDIF
 DECLARE stat = i4 WITH protect
 SET stat = alterlist(ec_list->list,8)
 SET ec_list->list[1].cdf_meaning = cdf_accv2_num_pci
 SET ec_list->list[2].cdf_meaning = cdf_accv2_mult_pci
 SET ec_list->list[3].cdf_meaning = cdf_accv2_proc_num
 SET ec_list->list[4].cdf_meaning = cdf_accv2_cathpci
 SET ec_list->list[5].cdf_meaning = cdf_accv2_les_attemped
 SET ec_list->list[6].cdf_meaning = cdf_accv2_les_dilated
 SET ec_list->list[7].cdf_meaning = cdf_accv2_proc_results
 SET ec_list->list[8].cdf_meaning = cdf_lesion_id_num
 DECLARE num_pci_ec = f8 WITH protect, noconstant(0.0)
 DECLARE mult_pci_ec = f8 WITH protect, noconstant(0.0)
 DECLARE proc_num_ec = f8 WITH protect, noconstant(0.0)
 DECLARE cathpci_ec = f8 WITH protect, noconstant(0.0)
 DECLARE attemped_ec = f8 WITH protect, noconstant(0.0)
 DECLARE dilated_ec = f8 WITH protect, noconstant(0.0)
 DECLARE resulst_ec = f8 WITH protect, noconstant(0.0)
 DECLARE id_num_ec = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect
 DECLARE num = i4 WITH protect
 DECLARE index = i4 WITH protect
 DECLARE ec_cnt = i4 WITH protect, noconstant(size(ec_list->list,5))
 FOR (ecnt = 1 TO ec_cnt)
   SET stat = uar_get_meaning_by_codeset(14003,ec_list->list[ecnt].cdf_meaning,1,ec_list->list[ecnt].
    dta)
 ENDFOR
 SELECT INTO "nl:"
  FROM discrete_task_assay dta
  WHERE expand(idx,1,ec_cnt,dta.task_assay_cd,ec_list->list[idx].dta)
  DETAIL
   index = locateval(num,1,ec_cnt,dta.task_assay_cd,ec_list->list[num].dta)
   CASE (ec_list->list[index].cdf_meaning)
    OF cdf_accv2_num_pci:
     num_pci_ec = dta.event_cd
    OF cdf_accv2_mult_pci:
     mult_pci_ec = dta.event_cd
    OF cdf_accv2_proc_num:
     proc_num_ec = dta.event_cd
    OF cdf_accv2_cathpci:
     cathpci_ec = dta.event_cd
    OF cdf_accv2_les_attemped:
     attemped_ec = dta.event_cd
    OF cdf_accv2_les_dilated:
     dilated_ec = dta.event_cd
    OF cdf_accv2_proc_results:
     resulst_ec = dta.event_cd
    OF cdf_lesion_id_num:
     id_num_ec = dta.event_cd
   ENDCASE
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No calc event_cd found! Exit Program")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM cv_case cc
  WHERE (cc.encntr_id=cv_omf_rec->encntr_id)
  ORDER BY cc.chart_dt_tm, cc.form_event_id
  HEAD REPORT
   case_cnt = 0
  DETAIL
   case_cnt = (case_cnt+ 1), stat = alterlist(all_case->cases,case_cnt), all_case->cases[case_cnt].
   case_id = cc.cv_case_id,
   all_case->cases[case_cnt].encntr_id = cv_omf_rec->encntr_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL cv_log_message("No calc cases associated with this encounter!")
 ELSE
  DELETE  FROM cv_case_abstr_data ccad,
    (dummyt d  WITH seq = value(size(all_case->cases,5)))
   SET ccad.seq = 1
   PLAN (d)
    JOIN (ccad
    WHERE (ccad.cv_case_id=all_case->cases[d.seq].case_id)
     AND ccad.event_cd IN (num_pci_ec, mult_pci_ec, proc_num_ec))
   WITH nocounter
  ;end delete
  IF (curqual=0)
   CALL cv_log_message(concat("No encounter level calc records deleted in ",
     "cv_case_abstr_data table!"))
  ENDIF
 ENDIF
 DELETE  FROM cv_case_abstr_data ccad
  SET ccad.seq = 1
  WHERE ccad.event_cd=cathpci_ec
   AND (ccad.cv_case_id=cv_omf_rec->case_id)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message(concat("No case level calc records deleted in ","cv_case_abstr_data table!"))
 ENDIF
 SELECT INTO "nl:"
  proc_id = cp.procedure_id
  FROM cv_procedure cp
  WHERE (cp.cv_case_id=cv_omf_rec->case_id)
   AND cp.cv_case_id != 0.0
  HEAD REPORT
   del_pro_cnt = 0
  DETAIL
   del_pro_cnt = (del_pro_cnt+ 1), stat = alterlist(calc_del_rec->del_proc,del_pro_cnt), calc_del_rec
   ->del_proc[del_pro_cnt].procedure_id = proc_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No procedure associates with this case!")
 ENDIF
 DELETE  FROM cv_proc_abstr_data cpad,
   (dummyt d  WITH seq = value(size(calc_del_rec->del_proc,5)))
  SET cpad.seq = 1
  PLAN (d)
   JOIN (cpad
   WHERE (cpad.procedure_id=calc_del_rec->del_proc[d.seq].procedure_id)
    AND cpad.event_cd IN (attemped_ec, dilated_ec, resulst_ec))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No calc records deleted in cv_proc_abstr_data table!")
 ENDIF
 SELECT INTO "nl:"
  cl.lesion_id
  FROM cv_lesion cl,
   (dummyt d2  WITH seq = value(size(calc_del_rec->del_proc,5)))
  PLAN (d2)
   JOIN (cl
   WHERE (cl.procedure_id=calc_del_rec->del_proc[d2.seq].procedure_id)
    AND cl.lesion_id != 0.0)
  HEAD REPORT
   del_les_cnt = 0
  DETAIL
   del_les_cnt = (del_les_cnt+ 1), stat = alterlist(calc_del_rec->del_les,del_les_cnt), calc_del_rec
   ->del_les[del_les_cnt].lesion_id = cl.lesion_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET cv_log_level = cv_log_audit
  CALL cv_log_current_default(0)
  CALL cv_log_message("No calc lesion records associates with the procedure!")
 ENDIF
 DELETE  FROM cv_les_abstr_data clad,
   (dummyt d  WITH seq = value(size(calc_del_rec->del_les,5)))
  SET clad.seq = 1
  PLAN (d)
   JOIN (clad
   WHERE (clad.lesion_id=calc_del_rec->del_les[d.seq].lesion_id)
    AND clad.lesion_id != 0.0
    AND clad.event_cd=id_num_ec)
  WITH nocounter
 ;end delete
 IF (curqual=0)
  CALL cv_log_message("No Calc Records Deleted In Cv_les_abstr_data Table!")
 ENDIF
#exit_script
 SET calc_reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 DECLARE cv_log_destroyhandle(dummy=i2) = null
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
 DECLARE cv_del_summary_calc_data = vc WITH private, constant("MOD 002 03/23/06 BM9013")
END GO
