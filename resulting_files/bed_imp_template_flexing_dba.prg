CREATE PROGRAM bed_imp_template_flexing:dba
 IF (validate(bed_error_subroutines) != 0)
  GO TO bed_error_subroutines_exit
 ENDIF
 DECLARE bed_error_subroutines = i2 WITH public, constant(1)
 DECLARE max_errors = i4 WITH public, constant(20)
 DECLARE failure = c1 WITH public, constant("F")
 DECLARE no_data = c1 WITH public, constant("Z")
 DECLARE warning = c1 WITH public, constant("W")
 FREE RECORD errors
 RECORD errors(
   1 error_ind = i2
   1 error_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE checkerror(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc) = i2
 DECLARE adderrormsg(s_status=c1,s_op_name=vc,s_op_status=c1,s_target_obj_name=vc,s_target_obj_value=
  vc) = null
 DECLARE showerrors(s_output=vc) = null
 DECLARE ms_err_msg = vc WITH private, noconstant("")
 SET stat = error(ms_err_msg,1)
 FREE SET ms_err_msg
 SUBROUTINE checkerror(s_status,s_op_name,s_op_status,s_target_obj_name)
   DECLARE s_err_msg = vc WITH private, noconstant("")
   DECLARE l_err_code = i4 WITH private, noconstant(0)
   DECLARE l_err_cnt = i4 WITH private, noconstant(0)
   SET l_err_code = error(s_err_msg,0)
   WHILE (l_err_code > 0
    AND l_err_cnt < max_errors)
     SET errors->error_ind = 1
     SET l_err_cnt = (l_err_cnt+ 1)
     CALL adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_err_msg)
     SET l_err_code = error(s_err_msg,0)
   ENDWHILE
   RETURN(errors->error_ind)
 END ;Subroutine
 SUBROUTINE adderrormsg(s_status,s_op_name,s_op_status,s_target_obj_name,s_target_obj_value)
   SET errors->error_cnt = (errors->error_cnt+ 1)
   SET s_status = cnvtupper(trim(substring(1,1,s_status),3))
   SET s_op_status = cnvtupper(trim(substring(1,1,s_op_status),3))
   IF (textlen(s_status) > 0
    AND (errors->status_data.status != failure))
    SET errors->status_data.status = s_status
   ENDIF
   IF ((errors->status_data.status=failure))
    SET errors->error_ind = 1
   ENDIF
   IF (((s_status=failure) OR (s_op_status=failure)) )
    CALL echo(concat("SCRIPT FAILURE - ",trim(s_target_obj_value,3)))
   ENDIF
   IF (size(errors->status_data.subeventstatus,5) < max_errors)
    SET stat = alter(errors->status_data.subeventstatus,max_errors)
   ENDIF
   SET errors->status_data.subeventstatus[errors->error_cnt].operationname = trim(substring(1,25,
     s_op_name),3)
   SET errors->status_data.subeventstatus[errors->error_cnt].operationstatus = s_op_status
   SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectname = trim(substring(1,25,
     s_target_obj_name),3)
   SET errors->status_data.subeventstatus[errors->error_cnt].targetobjectvalue = trim(
    s_target_obj_value,3)
 END ;Subroutine
 SUBROUTINE showerrors(s_output)
  DECLARE s_output_dest = vc WITH protect, noconstant(cnvtupper(trim(s_output,3)))
  IF ((errors->error_cnt > 0))
   SET stat = alter(errors->status_data.subeventstatus,errors->error_cnt)
   IF (((textlen(s_output_dest)=0) OR (s_output_dest="MINE")) )
    SET s_output_dest = "NOFORMS"
   ENDIF
   IF (s_output_dest="NOFORMS")
    CALL echo("")
   ENDIF
   SELECT INTO value(s_output_dest)
    operation_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.subeventstatus[(d.seq - 1)].
     operationname), target_object_name = evaluate(d.seq,1,"ERROR LOG",errors->status_data.
     subeventstatus[(d.seq - 1)].targetobjectname), status = evaluate(d.seq,1,errors->status_data.
     status,errors->status_data.subeventstatus[(d.seq - 1)].operationstatus),
    error_message = trim(substring(1,100,evaluate(d.seq,1,concat("SCRIPT ERROR LOG FOR: ",trim(
         curprog,3)),errors->status_data.subeventstatus[(d.seq - 1)].targetobjectvalue)))
    FROM (dummyt d  WITH seq = value((errors->error_cnt+ 1)))
    PLAN (d)
    WITH nocounter, format, separator = " "
   ;end select
  ENDIF
 END ;Subroutine
#bed_error_subroutines_exit
 FREE RECORD request
 RECORD request(
   1 code_set = i4
   1 qual[1]
     2 code_value = f8
     2 cdf_meaning = c12
     2 display = c40
     2 display_key = c40
     2 description = vc
     2 definition = vc
     2 collation_seq = i4
     2 active_ind = i2
     2 authentic_ind = i2
     2 updt_cnt = i4
     2 cki = vc
 )
 DECLARE fail_action = i2 WITH protect, constant(- (1))
 DECLARE no_action = i2 WITH protect, constant(0)
 DECLARE insert_action = i2 WITH protect, constant(1)
 DECLARE update_action = i2 WITH protect, constant(2)
 DECLARE audit_action = i2 WITH protect, constant(3)
 IF (validate(g_corr_rec->entry_cnt)=0)
  RECORD g_corr_rec(
    1 entry_cnt = i4
    1 entries[*]
      2 flexing_name = vc
      2 flexing_name_cv = f8
      2 flexing_name_updt_cnt = i4
      2 trust = vc
      2 trust_id = f8
      2 facility = vc
      2 facility_id = f8
      2 enc_type = vc
      2 med_service = vc
      2 med_service_cv = f8
      2 tel = vc
      2 time = vc
      2 app_type_cnt = i4
      2 app_types[*]
        3 app_type = vc
        3 code_value = f8
      2 action_flag = i2
      2 error_msg = vc
  )
 ENDIF
 FREE RECORD g_corr_cvg_op
 RECORD g_corr_cvg_op(
   1 entry_cnt = i4
   1 entries[*]
     2 code_value = f8
 )
 FREE RECORD g_corr_cvg_ip
 RECORD g_corr_cvg_ip(
   1 entry_cnt = i4
   1 entries[*]
     2 code_value = f8
 )
 FREE RECORD g_corr_cvg_dc
 RECORD g_corr_cvg_dc(
   1 entry_cnt = i4
   1 entries[*]
     2 code_value = f8
 )
 FREE RECORD g_corr_cvg_apptypes
 RECORD g_corr_cvg_apptypes(
   1 entry_cnt = i4
   1 entries[*]
     2 code_value = f8
 )
 DECLARE begin_date = q8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE gc_log = vc WITH protect, constant("ccluserdir:bed_template_flexing.log")
 DECLARE gc_code_set = i4 WITH protect, constant(4001991)
 DECLARE gc_enctype_code_set = i4 WITH protect, constant(71)
 DECLARE gc_medservice_code_set = i4 WITH protect, constant(34)
 DECLARE gc_apptype_code_set = i4 WITH protect, constant(14230)
 DECLARE gc_org_alias_type_code_set = i4 WITH protect, constant(334)
 DECLARE gc_org_alias_type_cdf_meaning = vc WITH protect, constant("NHSORGALIAS")
 DECLARE gc_cse_med_service = vc WITH protect, constant("1_treatment_function")
 DECLARE gc_cse_telephone = vc WITH protect, constant("2_telephone_no")
 DECLARE gc_cse_hours = vc WITH protect, constant("3_opening_hours")
 DECLARE gc_skip = i2 WITH protect, constant(1)
 DECLARE gc_continue = i2 WITH protect, constant(0)
 DECLARE g_numrows = i4 WITH protect, noconstant(size(requestin->list_0,5))
 DECLARE g_insert_flag = i2 WITH protect, noconstant(0)
 DECLARE g_query_counter = i4 WITH protect, noconstant(0)
 DECLARE g_row_counter = i4 WITH protect, noconstant(0)
 DECLARE g_app_type_counter = i4 WITH protect, noconstant(1)
 DECLARE g_app_type_empty_flag = i2 WITH protect, noconstant(0)
 DECLARE corr_update_codevalue(in_codevalue=f8,in_codevaluedisplay=vc,in_desc=vc,in_def=vc,
  in_updt_cnt=i4) = i2
 DECLARE corr_insert_codevalue(out_codevalue=f8(ref),in_codevaluedisplay=vc,in_desc=vc,in_def=vc) =
 i2
 DECLARE corr_delete_cvg_cve(in_parentcodevalue=f8) = i2
 DECLARE corr_insert_cvg_children(in_parentcodevalue=f8,in_recordstruc=vc(ref),in_childrencodeset=i4)
  = i2
 DECLARE corr_insert_cve(in_codevalue=f8,in_fieldname=vc,in_fieldvalue=vc) = i2
 DECLARE corr_verify_cse(cse_field_name=vc) = null
 IF (g_numrows=0)
  GO TO exit_script
 ENDIF
 IF (validate(tempreq) > 0)
  IF (cnvtupper(trim(tempreq->insert_ind,3))="Y")
   SET g_insert_flag = 1
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  flexing_name = trim(substring(1,100,requestin->list_0[d.seq].flexing_name),3), app_type = trim(
   substring(1,100,requestin->list_0[d.seq].appointment_type),3)
  FROM (dummyt d  WITH seq = value(g_numrows))
  ORDER BY flexing_name, app_type DESC
  HEAD flexing_name
   g_query_counter = (g_query_counter+ 1)
   IF (mod(g_query_counter,50)=1)
    stat = alterlist(g_corr_rec->entries,(g_query_counter+ 49))
   ENDIF
   g_corr_rec->entries[g_query_counter].flexing_name = flexing_name, g_corr_rec->entries[
   g_query_counter].trust = trim(substring(1,100,requestin->list_0[d.seq].encounter_trust),3),
   g_corr_rec->entries[g_query_counter].facility = trim(substring(1,100,requestin->list_0[d.seq].
     encounter_facility),3),
   g_corr_rec->entries[g_query_counter].enc_type = trim(substring(1,100,requestin->list_0[d.seq].
     encounter_type),3), g_corr_rec->entries[g_query_counter].med_service = trim(substring(1,100,
     requestin->list_0[d.seq].treatment_function),3), g_corr_rec->entries[g_query_counter].tel = trim
   (substring(1,100,requestin->list_0[d.seq].telephone_no),3),
   g_corr_rec->entries[g_query_counter].time = trim(substring(1,100,requestin->list_0[d.seq].
     operating_hours),3), g_corr_rec->entries[g_query_counter].action_flag = no_action, g_corr_rec->
   entries[g_query_counter].error_msg = "",
   g_app_type_counter = 0
  HEAD app_type
   g_app_type_counter = (g_app_type_counter+ 1)
   IF (mod(g_app_type_counter,10)=1)
    stat = alterlist(g_corr_rec->entries[g_query_counter].app_types,(g_app_type_counter+ 9))
   ENDIF
   g_corr_rec->entries[g_query_counter].app_types[g_app_type_counter].app_type = app_type, g_corr_rec
   ->entries[g_query_counter].app_types[g_app_type_counter].code_value = 0.0
  FOOT  flexing_name
   g_corr_rec->entries[g_query_counter].app_type_cnt = g_app_type_counter, stat = alterlist(
    g_corr_rec->entries[g_query_counter].app_types,g_corr_rec->entries[g_query_counter].app_type_cnt)
  FOOT REPORT
   g_corr_rec->entry_cnt = g_query_counter, stat = alterlist(g_corr_rec->entries,g_corr_rec->
    entry_cnt)
  WITH nocounter
 ;end select
 DECLARE g_org_alias_type_code = f8
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=gc_org_alias_type_code_set
   AND cv.cdf_meaning=gc_org_alias_type_cdf_meaning
  DETAIL
   g_org_alias_type_code = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(g_corr_rec->entry_cnt)),
   organization_alias oa
  PLAN (d)
   JOIN (oa
   WHERE oa.org_alias_type_cd=g_org_alias_type_code
    AND oa.alias=cnvtalphanum(cnvtupper(g_corr_rec->entries[d.seq].trust))
    AND oa.active_ind=1
    AND oa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND oa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   g_corr_rec->entries[d.seq].trust_id = oa.organization_alias_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(g_corr_rec->entry_cnt)),
   organization_alias oa
  PLAN (d)
   JOIN (oa
   WHERE oa.org_alias_type_cd=g_org_alias_type_code
    AND oa.alias=cnvtalphanum(cnvtupper(g_corr_rec->entries[d.seq].facility))
    AND oa.active_ind=1
    AND oa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND oa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   g_corr_rec->entries[d.seq].facility_id = oa.organization_alias_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(g_corr_rec->entry_cnt)),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=gc_medservice_code_set
    AND cv.display_key=cnvtalphanum(cnvtupper(g_corr_rec->entries[d.seq].med_service))
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   g_corr_rec->entries[d.seq].med_service_cv = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(g_corr_rec->entry_cnt)),
   (dummyt d2  WITH seq = value(1)),
   code_value cv
  PLAN (d1
   WHERE maxrec(d2,g_corr_rec->entries[d1.seq].app_type_cnt))
   JOIN (d2
   WHERE d2.seq > 0)
   JOIN (cv
   WHERE cv.code_set=gc_apptype_code_set
    AND cv.display_key=cnvtalphanum(cnvtupper(g_corr_rec->entries[d1.seq].app_types[d2.seq].app_type)
    )
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   g_corr_rec->entries[d1.seq].app_types[d2.seq].code_value = cv.code_value
  WITH nocounter
 ;end select
 DECLARE exit_script_flag = i2 WITH protect, noconstant(0)
 FOR (g_row_counter = 1 TO g_corr_rec->entry_cnt)
   DECLARE error_msg = vc WITH protect, noconstant("")
   SET g_skip = gc_continue
   IF ((g_corr_rec->entries[g_row_counter].trust_id=0.0))
    SET error_msg = concat("trust [",g_corr_rec->entries[g_row_counter].trust,"]")
    SET g_skip = gc_skip
   ELSE
    CALL echo(build("[VERIFIED] trust [",g_corr_rec->entries[g_row_counter].trust,"/",g_corr_rec->
      entries[g_row_counter].trust_id,"]"))
   ENDIF
   IF (g_skip=gc_continue)
    IF ((g_corr_rec->entries[g_row_counter].facility_id=0.0))
     SET error_msg = concat("facility [",g_corr_rec->entries[g_row_counter].facility,"]")
     SET g_skip = gc_skip
    ELSE
     CALL echo(build("[VERIFIED] facility [",g_corr_rec->entries[g_row_counter].facility,"/",
       g_corr_rec->entries[g_row_counter].facility_id,"]"))
    ENDIF
   ENDIF
   IF (g_skip=gc_continue)
    IF (textlen(trim(g_corr_rec->entries[g_row_counter].med_service)) > 0
     AND (g_corr_rec->entries[g_row_counter].med_service_cv=0.0))
     SET error_msg = concat("treatment function [",g_corr_rec->entries[g_row_counter].med_service,"]"
      )
     SET g_skip = gc_skip
    ELSE
     CALL echo(build("[VERIFIED] treatment function [",g_corr_rec->entries[g_row_counter].med_service,
       "/",g_corr_rec->entries[g_row_counter].med_service_cv,"]"))
    ENDIF
   ENDIF
   IF (g_skip=gc_continue)
    FOR (g_app_type_counter = 1 TO g_corr_rec->entries[g_row_counter].app_type_cnt)
      IF (textlen(trim(g_corr_rec->entries[g_row_counter].app_types[g_app_type_counter].app_type)) >
      0
       AND (g_corr_rec->entries[g_row_counter].app_types[g_app_type_counter].code_value=0.0))
       SET error_msg = concat("appointment type [",g_corr_rec->entries[g_row_counter].app_types[
        g_app_type_counter].app_type,"]")
       SET g_skip = gc_skip
      ELSE
       CALL echo(build("[VERIFIED] app_type [",g_corr_rec->entries[g_row_counter].app_types[
         g_app_type_counter].app_type,"/",g_corr_rec->entries[g_row_counter].app_types[
         g_app_type_counter].code_value,"]"))
      ENDIF
    ENDFOR
   ENDIF
   IF (g_skip=gc_continue)
    IF ( NOT (cnvtalphanum(cnvtupper(g_corr_rec->entries[g_row_counter].enc_type)) IN ("",
    "INPATIENTS", "INPATIENT", "OUTPATIENTS", "OUTPATIENT",
    "DAYCASE", "DAYCASES")))
     SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
     SET g_corr_rec->entries[g_row_counter].error_msg = build2(
      "Error when verifying encounter type [",g_corr_rec->entries[g_row_counter].enc_type,"]")
     SET g_skip = gc_skip
    ELSE
     CALL echo(build("[VERIFIED] encounter type [",g_corr_rec->entries[g_row_counter].enc_type,"]"))
    ENDIF
   ENDIF
   IF (g_skip=gc_skip)
    CALL echo(concat("error_msg = ",error_msg))
    IF (textlen(trim(error_msg)) > 0)
     SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
     SET g_corr_rec->entries[g_row_counter].error_msg = build2("Error when verifying ",error_msg)
     SET exit_script_flag = 1
    ENDIF
   ENDIF
 ENDFOR
 IF (exit_script_flag=1)
  GO TO exit_script
 ENDIF
 IF (g_insert_flag=0)
  GO TO exit_script
 ENDIF
 DECLARE ip_counter = i4 WITH protect, noconstant(0)
 DECLARE op_counter = i4 WITH protect, noconstant(0)
 DECLARE dc_counter = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  cv.code_value, cv.display_key
  FROM code_value cv
  WHERE cv.code_set=gc_enctype_code_set
   AND cv.display_key IN ("INPATIENT", "INPATIENTWAITINGLIST", "INPATIENTPREADMISSION", "OUTPATIENT",
  "OUTPATIENTPREREGISTRATION",
  "OUTPATIENTREFERRAL", "DAYCASE", "DAYCASEWAITINGLIST")
   AND cv.active_ind=1
   AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   IF (cv.display_key IN ("INPATIENT", "INPATIENTWAITINGLIST", "INPATIENTPREADMISSION"))
    ip_counter = (ip_counter+ 1)
    IF (mod(ip_counter,5)=1)
     stat = alterlist(g_corr_cvg_ip->entries,(ip_counter+ 4))
    ENDIF
    g_corr_cvg_ip->entries[ip_counter].code_value = cv.code_value
   ELSEIF (cv.display_key IN ("OUTPATIENT", "OUTPATIENTPREREGISTRATION", "OUTPATIENTREFERRAL"))
    op_counter = (op_counter+ 1)
    IF (mod(op_counter,5)=1)
     stat = alterlist(g_corr_cvg_op->entries,(op_counter+ 4))
    ENDIF
    g_corr_cvg_op->entries[op_counter].code_value = cv.code_value
   ELSE
    dc_counter = (dc_counter+ 1)
    IF (mod(dc_counter,5)=1)
     stat = alterlist(g_corr_cvg_dc->entries,(dc_counter+ 4))
    ENDIF
    g_corr_cvg_dc->entries[dc_counter].code_value = cv.code_value
   ENDIF
  FOOT REPORT
   g_corr_cvg_ip->entry_cnt = ip_counter, stat = alterlist(g_corr_cvg_ip->entries,g_corr_cvg_ip->
    entry_cnt), g_corr_cvg_op->entry_cnt = op_counter,
   stat = alterlist(g_corr_cvg_op->entries,g_corr_cvg_op->entry_cnt), g_corr_cvg_dc->entry_cnt =
   dc_counter, stat = alterlist(g_corr_cvg_dc->entries,g_corr_cvg_dc->entry_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(g_corr_rec->entry_cnt)),
   code_value cv
  PLAN (d)
   JOIN (cv
   WHERE cv.code_set=gc_code_set
    AND cv.display_key=cnvtalphanum(cnvtupper(g_corr_rec->entries[d.seq].flexing_name))
    AND cv.active_ind=1
    AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   g_corr_rec->entries[d.seq].flexing_name_cv = cv.code_value, g_corr_rec->entries[d.seq].
   flexing_name_updt_cnt = cv.updt_cnt, g_corr_rec->entries[d.seq].action_flag = update_action
  WITH nocounter
 ;end select
 CALL corr_verify_cse(gc_cse_med_service)
 CALL corr_verify_cse(gc_cse_telephone)
 CALL corr_verify_cse(gc_cse_hours)
 DECLARE g_stat = i2 WITH protect, noconstant(0)
 DECLARE g_skip = i2 WITH protect, noconstant(gc_continue)
 FOR (g_row_counter = 1 TO g_corr_rec->entry_cnt)
   SET g_skip = gc_continue
   DECLARE loop_cv_code_value = f8 WITH protect, noconstant(g_corr_rec->entries[g_row_counter].
    flexing_name_cv)
   DECLARE loop_cv_updt_cnt = i4 WITH protect, noconstant(g_corr_rec->entries[g_row_counter].
    flexing_name_updt_cnt)
   DECLARE loop_flexing_name = vc WITH protect, noconstant(g_corr_rec->entries[g_row_counter].
    flexing_name)
   DECLARE loop_trust = vc WITH protect, noconstant(g_corr_rec->entries[g_row_counter].trust)
   DECLARE loop_facility = vc WITH protect, noconstant(g_corr_rec->entries[g_row_counter].facility)
   IF ((g_corr_rec->entries[g_row_counter].action_flag=update_action))
    SET g_skip = corr_update_codevalue(loop_cv_code_value,loop_flexing_name,loop_trust,loop_facility,
     loop_cv_updt_cnt)
    IF (g_skip=gc_continue)
     SET g_skip = corr_delete_cvg_cve(loop_cv_code_value)
     IF (g_skip=gc_skip)
      SET g_corr_rec->entries[g_row_counter].error_msg = build(
       "Failed to delete cvg children of code value [",loop_cv_code_value,"]")
      SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
     ENDIF
    ENDIF
   ELSE
    SET g_corr_rec->entries[g_row_counter].action_flag = insert_action
    SET g_skip = corr_insert_codevalue(loop_cv_code_value,loop_flexing_name,loop_trust,loop_facility)
    IF (loop_cv_code_value=0.0
     AND textlen(trim(g_corr_rec->entries[g_row_counter].error_msg))=0)
     SET g_corr_rec->entries[g_row_counter].error_msg = build(
      "Code value is empty after inserting code value")
     SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
    ENDIF
   ENDIF
   IF (g_skip=gc_continue)
    DECLARE loop_enc_type = vc WITH protect, noconstant(cnvtalphanum(cnvtupper(g_corr_rec->entries[
       g_row_counter].enc_type)))
    IF (loop_enc_type IN ("INPATIENTS", "INPATIENT"))
     SET g_skip = corr_insert_cvg_children(loop_cv_code_value,g_corr_cvg_ip,gc_enctype_code_set)
    ELSEIF (loop_enc_type IN ("OUTPATIENTS", "OUTPATIENT"))
     SET g_skip = corr_insert_cvg_children(loop_cv_code_value,g_corr_cvg_op,gc_enctype_code_set)
    ELSEIF (loop_enc_type IN ("DAYCASES", "DAYCASE"))
     SET g_skip = corr_insert_cvg_children(loop_cv_code_value,g_corr_cvg_dc,gc_enctype_code_set)
    ENDIF
   ENDIF
   IF (g_skip=gc_continue)
    DECLARE loop_app_type_cnt = i4 WITH protect, noconstant(g_corr_rec->entries[g_row_counter].
     app_type_cnt)
    SET g_stat = alterlist(g_corr_cvg_apptypes->entries,loop_app_type_cnt)
    FOR (g_app_type_counter = 1 TO loop_app_type_cnt)
      SET g_corr_cvg_apptypes->entries[g_app_type_counter].code_value = g_corr_rec->entries[
      g_row_counter].app_types[g_app_type_counter].code_value
    ENDFOR
    SET g_corr_cvg_apptypes->entry_cnt = loop_app_type_cnt
    SET g_skip = corr_insert_cvg_children(loop_cv_code_value,g_corr_cvg_apptypes,gc_apptype_code_set)
   ENDIF
   IF (g_skip=gc_continue
    AND textlen(trim(g_corr_rec->entries[g_row_counter].tel)) > 0)
    SET g_skip = corr_insert_cve(loop_cv_code_value,gc_cse_telephone,g_corr_rec->entries[
     g_row_counter].tel)
   ENDIF
   IF (g_skip=gc_continue
    AND textlen(trim(g_corr_rec->entries[g_row_counter].med_service)) > 0)
    SET g_skip = corr_insert_cve(loop_cv_code_value,gc_cse_med_service,g_corr_rec->entries[
     g_row_counter].med_service)
   ENDIF
   IF (g_skip=gc_continue
    AND textlen(trim(g_corr_rec->entries[g_row_counter].time)) > 0)
    SET g_skip = corr_insert_cve(loop_cv_code_value,gc_cse_hours,g_corr_rec->entries[g_row_counter].
     time)
   ENDIF
 ENDFOR
 SUBROUTINE corr_update_codevalue(in_codevalue,in_codevaluedisplay,in_desc,in_def,in_updt_cnt)
   SET request->code_set = gc_code_set
   SET request->qual[1].code_value = in_codevalue
   SET request->qual[1].cdf_meaning = ""
   SET request->qual[1].display = in_codevaluedisplay
   SET request->qual[1].display_key = cnvtalphanum(cnvtupper(in_codevaluedisplay))
   SET request->qual[1].description = in_desc
   SET request->qual[1].definition = in_def
   SET request->qual[1].collation_seq = 0
   SET request->qual[1].active_ind = 1
   SET request->qual[1].authentic_ind = 1
   SET request->qual[1].updt_cnt = in_updt_cnt
   SET request->qual[1].cki = ""
   RECORD reply(
     1 qual[*]
       2 code_value = f8
       2 status = c1
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
   EXECUTE dm_ins_upd_code_value
   IF ((reply->qual[1].status="Z"))
    SET g_corr_rec->entries[g_row_counter].error_msg = build("Failed to update code value [",
     in_codevalue,
     "]. Code value already exists which matches the duplicate indicators for this code set.")
    SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
    RETURN(gc_skip)
   ELSEIF ((reply->qual[1].status="X"))
    SET g_corr_rec->entries[g_row_counter].error_msg = build("Failed to update code value [",
     in_codevalue,"]. An error occurred during the insert.")
    SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
    RETURN(gc_skip)
   ELSEIF ((reply->qual[1].status="T"))
    SET g_corr_rec->entries[g_row_counter].error_msg = build("Failed to update code value [",
     in_codevalue,"]. UPDT_CNT doesn't match.")
    SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
    RETURN(gc_skip)
   ENDIF
   RETURN(gc_continue)
 END ;Subroutine
 SUBROUTINE corr_insert_codevalue(out_codevalue,in_codevaluedisplay,in_desc,in_def)
   SET request->code_set = gc_code_set
   SET request->qual[1].code_value = 0.0
   SET request->qual[1].cdf_meaning = ""
   SET request->qual[1].display = in_codevaluedisplay
   SET request->qual[1].display_key = cnvtalphanum(cnvtupper(in_codevaluedisplay))
   SET request->qual[1].description = in_desc
   SET request->qual[1].definition = in_def
   SET request->qual[1].collation_seq = 0
   SET request->qual[1].active_ind = 1
   SET request->qual[1].cki = ""
   SET request->qual[1].authentic_ind = 1
   SET request->qual[1].updt_cnt = 0
   RECORD reply(
     1 qual[*]
       2 code_value = f8
       2 status = c1
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c15
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = c100
   )
   EXECUTE dm_ins_upd_code_value
   IF ((reply->qual[1].status="Z"))
    SET g_corr_rec->entries[g_row_counter].error_msg =
    "Failed to insert code value. Code value already exists which matches the duplicate indicators for this code set."
    SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
    RETURN(gc_skip)
   ELSEIF ((reply->qual[1].status="Y"))
    SET g_corr_rec->entries[g_row_counter].error_msg =
    "Failed to insert code value. An error occurred during the insert."
    SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
    RETURN(gc_skip)
   ENDIF
   SET out_codevalue = reply->qual[1].code_value
   RETURN(gc_continue)
 END ;Subroutine
 SUBROUTINE corr_delete_cvg_cve(in_parentcodevalue)
   DECLARE local_entry_exist = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    cvg.child_code_value
    FROM code_value_group cvg
    WHERE cvg.parent_code_value=in_parentcodevalue
    DETAIL
     local_entry_exist = 1
    WITH nocounter
   ;end select
   IF (local_entry_exist=1)
    DELETE  FROM code_value_group cvg
     WHERE cvg.parent_code_value=in_parentcodevalue
     WITH nocounter
    ;end delete
    IF (checkerror(failure,"DELETE",failure,build(in_parentcodevalue," CVG CHILDREN")) > 0)
     RETURN(gc_skip)
    ENDIF
   ENDIF
   SET local_entry_exist = 0
   SELECT INTO "nl:"
    cve.field_value
    FROM code_value_extension cve
    WHERE cve.code_set=gc_code_set
     AND cve.code_value=in_parentcodevalue
    DETAIL
     local_entry_exist = 1
    WITH nocounter
   ;end select
   IF (local_entry_exist=1)
    DELETE  FROM code_value_extension cve
     WHERE cve.code_set=gc_code_set
      AND cve.code_value=in_parentcodevalue
     WITH nocounter
    ;end delete
    IF (checkerror(failure,"DELETE",failure,build("CVE [",in_parentcodevalue,"]")) > 0)
     RETURN(gc_skip)
    ENDIF
   ENDIF
   RETURN(gc_continue)
 END ;Subroutine
 SUBROUTINE corr_insert_cvg_children(in_parentcodevalue,in_recordstruc,in_childrencodeset)
   DECLARE local_cvg_rowcounter = i4
   FOR (local_cvg_rowcounter = 1 TO in_recordstruc->entry_cnt)
     IF ((in_recordstruc->entries[local_cvg_rowcounter].code_value != 0.0))
      INSERT  FROM code_value_group cvg
       SET cvg.parent_code_value = in_parentcodevalue, cvg.child_code_value = in_recordstruc->
        entries[local_cvg_rowcounter].code_value, cvg.updt_applctx = reqinfo->updt_applctx,
        cvg.updt_dt_tm = cnvtdatetime(curdate,curtime), cvg.updt_id = reqinfo->updt_id, cvg.updt_cnt
         = 0,
        cvg.updt_task = reqinfo->updt_task, cvg.collation_seq = 0, cvg.code_set = in_childrencodeset
       WITH nocounter
      ;end insert
      IF (checkerror(failure,"INSERT",failure,build("CVG [",in_recordstruc->entries[
        local_cvg_rowcounter].code_value,"]")) > 0)
       SET g_corr_rec->entries[g_row_counter].error_msg = build("Failed to insert CVG child [",
        in_recordstruc->entries[local_cvg_rowcounter].code_value,"] to parent [",in_parentcodevalue,
        "]")
       SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
       RETURN(gc_skip)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(gc_continue)
 END ;Subroutine
 SUBROUTINE corr_insert_cve(in_codevalue,in_fieldname,in_fieldvalue)
   INSERT  FROM code_value_extension cve
    SET cve.code_value = in_codevalue, cve.code_set = gc_code_set, cve.field_name = in_fieldname,
     cve.field_type = 2, cve.field_value = in_fieldvalue, cve.updt_applctx = reqinfo->updt_applctx,
     cve.updt_cnt = 0, cve.updt_id = reqinfo->updt_id, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3
      ),
     cve.updt_task = reqinfo->updt_task
    WITH nocounter
   ;end insert
   IF (checkerror(failure,"INSERT",failure,"INSERT NEW CODE VALUE EXTENSION") > 0)
    SET g_corr_rec->entries[g_row_counter].error_msg = build("Failed to insert CVE entry [",
     in_fieldname,"/",in_fieldvalue,"] to code value [",
     in_codevalue,"]")
    SET g_corr_rec->entries[g_row_counter].action_flag = fail_action
    RETURN(gc_skip)
   ENDIF
   COMMIT
   RETURN(gc_continue)
 END ;Subroutine
 SUBROUTINE corr_verify_cse(cse_field_name)
   DECLARE local_status = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    cse.field_name
    FROM code_set_extension cse
    WHERE cse.code_set=gc_code_set
     AND cse.field_name=cse_field_name
     AND cse.field_type=2
    DETAIL
     local_status = 1
    WITH nocounter
   ;end select
   IF (local_status=0)
    INSERT  FROM code_set_extension cse
     SET cse.code_set = gc_code_set, cse.field_name = cse_field_name, cse.field_seq = 0,
      cse.field_type = 2, cse.field_len = 0, cse.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WITH nocounter
    ;end insert
   ENDIF
   CALL checkerror(failure,"INSERT",failure,build("new cse [",cse_field_name,"]"))
 END ;Subroutine
#exit_script
 DECLARE app_type_line = vc WITH protect, noconstant("")
 SELECT INTO value(gc_log)
  flexing_name = trim(substring(1,100,g_corr_rec->entries[d.seq].flexing_name),3), trust = trim(
   substring(1,100,g_corr_rec->entries[d.seq].trust),3), facility = trim(substring(1,100,g_corr_rec->
    entries[d.seq].facility),3),
  enc_type = trim(substring(1,100,g_corr_rec->entries[d.seq].enc_type),3), med_service = trim(
   substring(1,100,g_corr_rec->entries[d.seq].med_service),3), tel = trim(substring(1,100,g_corr_rec
    ->entries[d.seq].tel),3),
  time = trim(substring(1,100,g_corr_rec->entries[d.seq].time),3), action_flag = g_corr_rec->entries[
  d.seq].action_flag
  FROM (dummyt d  WITH seq = value(g_corr_rec->entry_cnt))
  PLAN (d)
  HEAD REPORT
   col_count = 0, col_action = (col_count+ 5), col_flexing_name = (col_action+ 15),
   col_enc_type = (col_flexing_name+ 35), col_trust = (col_enc_type+ 16), col_facility = (col_trust+
   10),
   col_med_service = (col_facility+ 13), col_app_type = (col_med_service+ 40), col_tel = (
   col_app_type+ 40),
   col_time = (col_tel+ 35), row_cnt = 0, action_disp = fillstring(10,""),
   line = fillstring(value(250),"-"), row + 1, col 0,
   "CORRESPONDENCE TEMPLATE FLEXING IMPORT", row + 1, col 0,
   "LAST RUN: ", col 11, begin_date"@MEDIUMDATETIME",
   row + 1, row + 1
   IF ((errors->error_ind > 0))
    col 0, "CCL ERRORS ENCOUNTERED!:", row + 1
    FOR (loop_cnt = 1 TO errors->error_cnt)
      col 0, errors->status_data.subeventstatus[loop_cnt].operationname, col 20,
      errors->status_data.subeventstatus[loop_cnt].targetobjectname, row + 1, col 0,
      errors->status_data.subeventstatus[loop_cnt].targetobjectvalue, row + 1
    ENDFOR
    row + 1
   ENDIF
   col col_count, "Row", col col_action,
   "Action", col col_flexing_name, "Flexing Name",
   col col_enc_type, "Encounter Type", col col_trust,
   "Trust", col col_facility, "Facility",
   col col_med_service, "Treatment Function", col col_app_type,
   "Appointment Type", col col_tel, "Telephone No",
   col col_time, "Opening Hours", row + 1,
   col 0, line, row + 1
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF ((g_corr_rec->entries[d.seq].action_flag=fail_action))
    action_disp = "FAIL"
   ELSEIF ((g_corr_rec->entries[d.seq].action_flag=insert_action))
    action_disp = "INSERTED"
   ELSEIF ((g_corr_rec->entries[d.seq].action_flag=update_action))
    action_disp = "UPDATED"
   ELSE
    action_disp = "VERIFIED"
   ENDIF
   col col_count, row_cnt"###;r;i", col col_action,
   action_disp, col col_flexing_name, flexing_name,
   col col_enc_type, enc_type, col col_trust,
   trust, col col_facility, facility,
   col col_med_service, med_service, col col_tel,
   tel, col col_time, time
   FOR (g_app_type_counter = 1 TO g_corr_rec->entries[d.seq].app_type_cnt)
     IF (textlen(trim(g_corr_rec->entries[d.seq].app_types[g_app_type_counter].app_type)) > 0)
      app_type_line = concat(build(g_app_type_counter),") ",g_corr_rec->entries[d.seq].app_types[
       g_app_type_counter].app_type), col col_app_type, app_type_line,
      row + 1
     ENDIF
   ENDFOR
   IF (textlen(trim(g_corr_rec->entries[d.seq].error_msg,3)) > 0)
    row + 1, call reportmove('COL',(col_action+ 5),0), "ERRORS:",
    call reportmove('COL',(col_enc_type+ 5),0), g_corr_rec->entries[d.seq].error_msg
   ENDIF
   row + 1, row + 1
  FOOT REPORT
   row + 1,
   CALL center("---------- END OF LOG ----------",0,250)
  WITH nocounter, format = variable, noformfeed,
   maxcol = 350, maxrow = 1, nullreport
 ;end select
 CALL echo("")
 CALL echo(
  "******************************************************************************************")
 CALL echo(concat("*  Upload complete, check ",gc_log," for more information.  *"))
 CALL echo(
  "******************************************************************************************")
 CALL echo("")
END GO
