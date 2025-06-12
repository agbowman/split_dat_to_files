CREATE PROGRAM bed_imp_query_list_template
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
 FREE RECORD querylist
 RECORD querylist(
   1 cnt = i4
   1 qual[*]
     2 name = vc
     2 query_type = vc
     2 query_type_cd = f8
     2 stat = i4
     2 templateid = f8
     2 provider_group_add_all_ind = i2
     2 provider_group[*] = vc
       3 disp = vc
       3 value = f8
       3 stat = i4
     2 treatment_add_all_ind = i2
     2 treatment[*]
       3 disp = vc
       3 value = f8
       3 stat = i4
     2 care_add_all_ind = i2
     2 care[*]
       3 disp = vc
       3 value = f8
       3 stat = i4
     2 enc_add_all_ind = i2
     2 enc[*]
       3 disp = vc
       3 value = f8
       3 stat = i4
     2 fac_add_all_ind = i2
     2 fac[*]
       3 disp = vc
       3 value = f8
       3 stat = i4
     2 ref_add_all_ind = i2
     2 ref[*]
       3 disp = vc
       3 value = f8
       3 stat = i4
     2 pos_add_all_ind = i2
     2 pos[*]
       3 disp = vc
       3 value = f8
       3 stat = i4
     2 msgcnt = i4
     2 logmsg[*]
       3 level = vc
       3 msg = vc
 ) WITH public
 SET querylist->cnt = 0
 FREE RECORD msglog
 RECORD msglog(
   1 cnt = i4
   1 qual[*]
     2 level = vc
     2 msg = vc
 ) WITH public
 SET msglog->cnt = 0
 DECLARE logstart(xtitle=vc,xname=vc) = null
 DECLARE logmsg(level=vc,msg=vc) = null
 DECLARE loglistmsg(qidx=i4,level=vc,msg=vc) = null
 DECLARE add_param_values(paramtype=i4,paramval=vc,qidx=i4) = null
 DECLARE get_provider_group_code_values(i4_listidx=i4) = null
 DECLARE get_treatment_code_values(i4_listidx=i4) = null
 DECLARE get_care_team_code_values(i4_listidx=i4) = null
 DECLARE get_encounter_code_values(i4_listidx=i4) = null
 DECLARE get_facilities_code_values(i4_listidx=i4) = null
 DECLARE get_referral_order_code_values(i4_listidx=i4,inpatientind=i2) = null
 DECLARE get_positions_code_values(i4_listidx=i4) = null
 DECLARE populate_param(add_request=vc(ref),listidx=i4) = null
 DECLARE add_update_query_template(reqrec=vc(ref),qidx=i4,templateid=f8(ref)) = i2
 DECLARE upd_query_template_access(request=vc(ref),qidx=i4) = i2
 DECLARE insertflag = vc WITH protect, noconstant(validate(tempreq->insert_ind,"N"))
 DECLARE numrows = i4 WITH protect, noconstant(size(requestin->list_0,5))
 IF (numrows=0)
  CALL logmsg("ERROR","Spreadsheet is empty. No rows to process.")
  GO TO exit_script
 ENDIF
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 DECLARE divider_1 = vc WITH protect, constant(concat(
   "======================================================================",
   "======================================================================",
   "======================================================================",
   "======================================================================",
   "====================================================================="))
 DECLARE divider_2 = vc WITH protect, constant(concat(
   "----------------------------------------------------------------------",
   "----------------------------------------------------------------------",
   "----------------------------------------------------------------------",
   "----------------------------------------------------------------------",
   "---------------------------------------------------------------------"))
 SET title = validate(log_title_set,"Query List Upload Log")
 SET name = validate(log_name_set,"bed_query_list_template.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 DECLARE stat_insert_ok = i4 WITH protect, constant(1)
 DECLARE stat_update_ok = i4 WITH protect, constant(2)
 DECLARE stat_audit_insert_ok = i4 WITH protect, constant(3)
 DECLARE stat_audit_update_ok = i4 WITH protect, constant(4)
 DECLARE stat_insert_error = i4 WITH protect, constant(- (1))
 DECLARE stat_update_error = i4 WITH protect, constant(- (2))
 DECLARE stat_audit_insert_error = i4 WITH protect, constant(- (3))
 DECLARE stat_audit_update_error = i4 WITH protect, constant(- (4))
 DECLARE code_set_query_type = i4 WITH protect, constant(29802)
 DECLARE code_set_provider_group = i4 WITH protect, constant(19189)
 DECLARE code_set_treatment_specialities = i4 WITH protect, constant(34)
 DECLARE code_set_careteam = i4 WITH protect, constant(100006)
 DECLARE code_set_encounters = i4 WITH protect, constant(71)
 DECLARE code_set_facilities = i4 WITH protect, constant(222)
 DECLARE code_set_ahp = i4 WITH protect, constant(100641)
 DECLARE code_set_ahp_inpatient = i4 WITH protect, constant(100642)
 DECLARE code_set_positions = i4 WITH protect, constant(88)
 DECLARE cdf_meaning_provider_group = vc WITH protect, constant("DCPTEAM")
 DECLARE cdf_meaning_facility = vc WITH protect, constant("FACILITY")
 DECLARE value_ok = i4 WITH protect, constant(1)
 DECLARE param_provider_type = i4 WITH protect, constant(101)
 DECLARE param_treatment_type = i4 WITH protect, constant(102)
 DECLARE param_care_type = i4 WITH protect, constant(103)
 DECLARE param_facilities_type = i4 WITH protect, constant(104)
 DECLARE param_encounter_type = i4 WITH protect, constant(105)
 DECLARE param_referral_type = i4 WITH protect, constant(106)
 DECLARE param_positions_type = i4 WITH protect, constant(107)
 DECLARE listidx = i4 WITH public, noconstant(0)
 DECLARE param_cnt = i4 WITH protect, noconstant(0)
 FOR (listidx = 1 TO numrows)
   SET param_cnt = 0
   IF (textlen(trim(validate(requestin->list_0[listidx].name,""),3)) > 0)
    SET querylist->cnt = (querylist->cnt+ 1)
    SET stat = alterlist(querylist->qual,querylist->cnt)
    SET querylist->qual[querylist->cnt].query_type = trim(requestin->list_0[listidx].query_type,3)
    SET querylist->qual[querylist->cnt].name = trim(requestin->list_0[listidx].name,3)
    SET querylist->qual[querylist->cnt].provider_group_add_all_ind = 0
    SET querylist->qual[querylist->cnt].treatment_add_all_ind = 0
    SET querylist->qual[querylist->cnt].care_add_all_ind = 0
    SET querylist->qual[querylist->cnt].enc_add_all_ind = 0
    SET querylist->qual[querylist->cnt].fac_add_all_ind = 0
    SET querylist->qual[querylist->cnt].ref_add_all_ind = 0
    SET querylist->qual[querylist->cnt].pos_add_all_ind = 0
    SET querylist->qual[querylist->cnt].templateid = 0.0
    SET param_cnt = 1
   ENDIF
   CALL add_param_values(param_provider_type,trim(validate(requestin->list_0[listidx].providers,""),3
     ),querylist->cnt)
   CALL add_param_values(param_treatment_type,trim(validate(requestin->list_0[listidx].
      treatment_speciality,""),3),querylist->cnt)
   CALL add_param_values(param_care_type,trim(validate(requestin->list_0[listidx].care_team,""),3),
    querylist->cnt)
   CALL add_param_values(param_encounter_type,trim(validate(requestin->list_0[listidx].encounter_type,
      ""),3),querylist->cnt)
   CALL add_param_values(param_facilities_type,trim(validate(requestin->list_0[listidx].facilities,""
      ),3),querylist->cnt)
   CALL add_param_values(param_referral_type,trim(validate(requestin->list_0[listidx].referral_order,
      ""),3),querylist->cnt)
   CALL add_param_values(param_positions_type,trim(validate(requestin->list_0[listidx].positions,""),
     3),querylist->cnt)
 ENDFOR
 DECLARE idx = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dcp_pl_query_template d
  PLAN (d
   WHERE expand(idx,1,querylist->cnt,d.template_name,querylist->qual[idx].name))
  DETAIL
   pos = locateval(idx,1,querylist->cnt,d.template_name,querylist->qual[idx].name)
   IF (pos != 0)
    querylist->qual[pos].templateid = d.template_id
   ENDIF
  WITH nocounter
 ;end select
 DECLARE tmp_cv = f8 WITH protect, noconstant(0.0)
 DECLARE process_result = i2 WITH protect, noconstant(0)
 DECLARE poscnt = i4 WITH protect, noconstant(0)
 DECLARE templateid = f8 WITH protect, noconstant(0.0)
 FOR (listidx = 1 TO querylist->cnt)
   SET tmp_cv = 0.0
   SET process_result = 0
   SET poscnt = 0
   SET templateid = 0.0
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=code_set_query_type
     AND cv.active_ind=1
     AND cv.display_key=cnvtupper(cnvtalphanum(querylist->qual[listidx].query_type))
    DETAIL
     tmp_cv = cv.code_value
    WITH nocounter, maxqual(cv,1)
   ;end select
   IF (tmp_cv > 0.0)
    SET querylist->qual[listidx].query_type_cd = tmp_cv
    SET process_result = 1
   ELSE
    SET querylist->qual[listidx].query_type_cd = 0.0
    CALL loglistmsg(listidx,"ERROR",concat('Unable to determine query type code value for type "',
      querylist->qual[listidx].query_type,'"'))
   ENDIF
   IF (process_result=1)
    SET process_result = 0
    CALL get_provider_group_code_values(listidx)
    CALL get_treatment_code_values(listidx)
    CALL get_care_team_code_values(listidx)
    CALL get_encounter_code_values(listidx)
    CALL get_facilities_code_values(listidx)
    IF ((querylist->qual[listidx].query_type="AHP Inpatient Service Type"))
     CALL get_referral_order_code_values(listidx,1)
    ELSE
     CALL get_referral_order_code_values(listidx,0)
    ENDIF
    CALL get_positions_code_values(listidx)
    FREE RECORD add_request
    RECORD add_request(
      1 query_type_cd = f8
      1 name = vc
      1 parameters[*]
        2 param_id = f8
        2 parameter_name = vc
        2 parameter_seq = i4
        2 values[*]
          3 name = vc
          3 value_seq = i4
          3 value_string = vc
          3 value_dt = dq8
          3 value_id = f8
          3 value_entity = vc
    )
    CALL populate_param(add_request,listidx)
    SET process_result = add_update_query_template(add_request,listidx,templateid)
   ENDIF
   IF (process_result=1
    AND templateid != 0.0)
    FREE RECORD accessreq
    RECORD accessreq(
      1 template_id = f8
      1 positions[*]
        2 position_cd = f8
      1 provider_groups[*]
        2 provider_group_id = f8
      1 providers[*]
        2 provider_id = f8
    ) WITH public
    SET poscnt = size(querylist->qual[listidx].pos,5)
    SET stat = alterlist(accessreq->positions,poscnt)
    SET accessreq->template_id = templateid
    FOR (valueidx = 1 TO poscnt)
      SET accessreq->positions[valueidx].position_cd = querylist->qual[listidx].pos[valueidx].value
    ENDFOR
    SET process_result = upd_query_template_access(accessreq,listidx)
    IF (process_result=0)
     IF ((querylist->qual[listidx].stat=stat_update_ok))
      SET querylist->qual[listidx].stat = stat_update_error
     ENDIF
     IF ((querylist->qual[listidx].stat=stat_insert_ok))
      SET querylist->qual[listidx].stat = stat_insert_error
     ENDIF
    ENDIF
    CALL loglistmsg(listidx,"VERIFY",concat("select * from dcp_pl_query_value where template_id = ",
      build(templateid)," go"))
    CALL loglistmsg(listidx,"VERIFY",concat(
      "select * from dcp_pl_query_temp_access where template_id = ",build(templateid)," go"))
   ENDIF
 ENDFOR
 DECLARE msglogidx = i4 WITH protect, noconstant(0)
 FOR (msglogidx = 1 TO msglog->cnt)
   CALL echo(concat("[",msglog->qual[msglogidx].level,"] ",msglog->qual[msglogidx].msg))
 ENDFOR
 FOR (listidx = 1 TO querylist->cnt)
   DECLARE paramidx = i4 WITH protect, noconstant(0)
   DECLARE error_occur = i2 WITH protect, noconstant(0)
   FOR (paramidx = 1 TO size(querylist->qual[listidx].provider_group,5))
     IF ((querylist->qual[listidx].provider_group[paramidx].stat=0))
      CALL loglistmsg(listidx,"ERROR",concat('Parameter "',querylist->qual[listidx].provider_group[
        paramidx].disp,'" has code value "',build(querylist->qual[listidx].provider_group[paramidx].
         value),'"'))
      SET error_occur = 1
     ENDIF
   ENDFOR
   FOR (paramidx = 1 TO size(querylist->qual[listidx].treatment,5))
     IF ((querylist->qual[listidx].treatment[paramidx].stat=0))
      CALL loglistmsg(listidx,"ERROR",concat('Parameter "',querylist->qual[listidx].treatment[
        paramidx].disp,'" has code value "',build(querylist->qual[listidx].treatment[paramidx].value),
        '"'))
      SET error_occur = 1
     ENDIF
   ENDFOR
   FOR (paramidx = 1 TO size(querylist->qual[listidx].care,5))
     IF ((querylist->qual[listidx].care[paramidx].stat=0))
      CALL loglistmsg(listidx,"ERROR",concat('Parameter "',querylist->qual[listidx].care[paramidx].
        disp,'" has code value "',build(querylist->qual[listidx].care[paramidx].value),'"'))
      SET error_occur = 1
     ENDIF
   ENDFOR
   FOR (paramidx = 1 TO size(querylist->qual[listidx].enc,5))
     IF ((querylist->qual[listidx].enc[paramidx].stat=0))
      CALL loglistmsg(listidx,"ERROR",concat('Parameter "',querylist->qual[listidx].enc[paramidx].
        disp,'" has code value "',build(querylist->qual[listidx].enc[paramidx].value),'"'))
      SET error_occur = 1
     ENDIF
   ENDFOR
   FOR (paramidx = 1 TO size(querylist->qual[listidx].fac,5))
     IF ((querylist->qual[listidx].fac[paramidx].stat=0))
      CALL loglistmsg(listidx,"ERROR",concat('Parameter "',querylist->qual[listidx].fac[paramidx].
        disp,'" has code value "',build(querylist->qual[listidx].fac[paramidx].value),'"'))
      SET error_occur = 1
     ENDIF
   ENDFOR
   FOR (paramidx = 1 TO size(querylist->qual[listidx].ref,5))
     IF ((querylist->qual[listidx].ref[paramidx].stat=0))
      CALL loglistmsg(listidx,"ERROR",concat('Parameter "',querylist->qual[listidx].ref[paramidx].
        disp,'" has code value "',build(querylist->qual[listidx].ref[paramidx].value),'"'))
      SET error_occur = 1
     ENDIF
   ENDFOR
   FOR (paramidx = 1 TO size(querylist->qual[listidx].pos,5))
     IF ((querylist->qual[listidx].pos[paramidx].stat=0))
      CALL loglistmsg(listidx,"ERROR",concat('Parameter "',querylist->qual[listidx].pos[paramidx].
        disp,'" has code value "',build(querylist->qual[listidx].pos[paramidx].value),'"'))
      SET error_occur = 1
     ENDIF
   ENDFOR
   IF (error_occur=1)
    CASE (querylist->qual[listidx].stat)
     OF stat_insert_ok:
      SET querylist->qual[listidx].stat = stat_insert_error
     OF stat_update_ok:
      SET querylist->qual[listidx].stat = stat_updaet_error
     OF stat_audit_insert_ok:
      SET querylist->qual[listidx].stat = stat_audit_insert_error
     OF stat_audit_update_ok:
      SET querylist->qual[listidx].stat = stat_audit_update_error
    ENDCASE
   ENDIF
 ENDFOR
 DECLARE status_ok = vc WITH protect, constant("[ OK]")
 DECLARE status_err = vc WITH protect, constant("[ERR]")
 DECLARE paramidx = i4 WITH protect, noconstant(0)
 DECLARE logidx = i4 WITH protect, noconstant(0)
 DECLARE outtxt = vc WITH protect, noconstant("")
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = querylist->cnt)
  HEAD REPORT
   col_status = 0, col_name = (col_status+ 25), col_query_type = (col_name+ 40),
   col_providers = (col_query_type+ 35), col_treatment = (col_providers+ 30), col_careteam = (
   col_treatment+ 35),
   col_encounter_type = (col_careteam+ 45), col_facilities = (col_encounter_type+ 30),
   col_referral_order = (col_facilities+ 35),
   col_positions = (col_referral_order+ 35), col_logmsg = (col_status+ 5)
  DETAIL
   CASE (querylist->qual[d.seq].stat)
    OF stat_insert_ok:
     outtxt = "INSERT OK"
    OF stat_update_ok:
     outtxt = "UPDATE OK"
    OF stat_audit_insert_ok:
     outtxt = "AUDIT INSERT OK"
    OF stat_audit_update_ok:
     outtxt = "AUDIT UPDATE OK"
    OF stat_insert_error:
     outtxt = "INSERT ERROR"
    OF stat_update_error:
     outtxt = "UPDATE ERROR"
    OF stat_audit_insert_error:
     outtxt = "AUDIT INSERT ERROR"
    OF stat_audit_update_error:
     outtxt = "AUDIT UPDATE ERROR"
    ELSE
     outtxt = "UNKNOWN"
   ENDCASE
   outtxt = concat("[",outtxt,"]"), col col_status, outtxt
   IF (textlen(trim(querylist->qual[d.seq].name,3)) > 38)
    outtxt = concat(substring(1,35,querylist->qual[d.seq].name),"...")
   ELSE
    outtxt = querylist->qual[d.seq].name
   ENDIF
   col col_name, outtxt
   IF ((querylist->qual[d.seq].query_type_cd != 0.0))
    outtxt = status_ok
   ELSE
    outtxt = status_err
   ENDIF
   outtxt = concat(outtxt," ",querylist->qual[d.seq].query_type), col col_query_type, outtxt,
   size_provider = size(querylist->qual[d.seq].provider_group,5), size_treatment = size(querylist->
    qual[d.seq].treatment,5), size_careteam = size(querylist->qual[d.seq].care,5),
   size_encounter = size(querylist->qual[d.seq].enc,5), size_facilities = size(querylist->qual[d.seq]
    .fac,5), size_referral = size(querylist->qual[d.seq].ref,5),
   size_positions = size(querylist->qual[d.seq].pos,5), max_size = maxval(size_provider,
    size_treatment,size_careteam,size_encounter,size_facilities,
    size_referral,size_positions)
   FOR (paramidx = 1 TO max_size)
     IF (paramidx <= size_provider)
      IF ((querylist->qual[d.seq].provider_group[paramidx].stat=1))
       outtxt = status_ok
      ELSE
       outtxt = status_err
      ENDIF
      IF (textlen(trim(querylist->qual[d.seq].provider_group[paramidx].disp,3)) > 23)
       outtxt = concat(outtxt," ",substring(1,20,querylist->qual[d.seq].provider_group[paramidx].disp
         ),"...")
      ELSE
       outtxt = concat(outtxt," ",querylist->qual[d.seq].provider_group[paramidx].disp)
      ENDIF
      col col_providers, outtxt
     ELSEIF (paramidx=1
      AND (querylist->qual[d.seq].provider_group_add_all_ind=1))
      outtxt = concat(status_ok," all"), col col_providers, outtxt
     ENDIF
     IF (paramidx <= size_treatment)
      IF ((querylist->qual[d.seq].treatment[paramidx].stat=1))
       outtxt = status_ok
      ELSE
       outtxt = status_err
      ENDIF
      IF (textlen(trim(querylist->qual[d.seq].treatment[paramidx].disp,3)) > 28)
       outtxt = concat(outtxt," ",substring(1,25,querylist->qual[d.seq].treatment[paramidx].disp),
        "...")
      ELSE
       outtxt = concat(outtxt," ",querylist->qual[d.seq].treatment[paramidx].disp)
      ENDIF
      col col_treatment, outtxt
     ELSEIF (paramidx=1
      AND (querylist->qual[d.seq].treatment_add_all_ind=1))
      outtxt = concat(status_ok," all"), col col_treatment, outtxt
     ENDIF
     IF (paramidx <= size_careteam)
      IF ((querylist->qual[d.seq].care[paramidx].stat=1))
       outtxt = status_ok
      ELSE
       outtxt = status_err
      ENDIF
      IF (textlen(trim(querylist->qual[d.seq].care[paramidx].disp,3)) > 36)
       outtxt = concat(outtxt," ",substring(1,33,querylist->qual[d.seq].care[paramidx].disp),"...")
      ELSE
       outtxt = concat(outtxt," ",querylist->qual[d.seq].care[paramidx].disp)
      ENDIF
      col col_careteam, outtxt
     ELSEIF (paramidx=1
      AND (querylist->qual[d.seq].care_add_all_ind=1))
      outtxt = concat(status_ok," all"), col col_careteam, outtxt
     ENDIF
     IF (paramidx <= size_encounter)
      IF ((querylist->qual[d.seq].enc[paramidx].stat=1))
       outtxt = status_ok
      ELSE
       outtxt = status_err
      ENDIF
      IF (textlen(trim(querylist->qual[d.seq].enc[paramidx].disp,3)) > 22)
       outtxt = concat(outtxt," ",substring(1,20,querylist->qual[d.seq].enc[paramidx].disp),"...")
      ELSE
       outtxt = concat(outtxt," ",querylist->qual[d.seq].enc[paramidx].disp)
      ENDIF
      col col_encounter_type, outtxt
     ELSEIF (paramidx=1
      AND (querylist->qual[d.seq].enc_add_all_ind=1))
      outtxt = concat(status_ok," all"), col col_encounter_type, outtxt
     ENDIF
     IF (paramidx <= size_facilities)
      IF ((querylist->qual[d.seq].fac[paramidx].stat=1))
       outtxt = status_ok
      ELSE
       outtxt = status_err
      ENDIF
      IF (textlen(trim(querylist->qual[d.seq].fac[paramidx].disp,3)) > 28)
       outtxt = concat(outtxt," ",substring(1,25,querylist->qual[d.seq].fac[paramidx].disp),"...")
      ELSE
       outtxt = concat(outtxt," ",querylist->qual[d.seq].fac[paramidx].disp)
      ENDIF
      col col_facilities, outtxt
     ELSEIF (paramidx=1
      AND (querylist->qual[d.seq].fac_add_all_ind=1))
      outtxt = concat(status_ok," all"), col col_facilities, outtxt
     ENDIF
     IF (paramidx <= size_referral)
      IF ((querylist->qual[d.seq].ref[paramidx].stat=1))
       outtxt = status_ok
      ELSE
       outtxt = status_err
      ENDIF
      IF (textlen(trim(querylist->qual[d.seq].ref[paramidx].disp,3)) > 28)
       outtxt = concat(outtxt," ",substring(1,25,querylist->qual[d.seq].ref[paramidx].disp),"...")
      ELSE
       outtxt = concat(outtxt," ",querylist->qual[d.seq].ref[paramidx].disp)
      ENDIF
      col col_referral_order, outtxt
     ELSEIF (paramidx=1
      AND (querylist->qual[d.seq].ref_add_all_ind=1))
      outtxt = concat(status_ok," all"), col col_referral_order, outtxt
     ENDIF
     IF (paramidx <= size_positions)
      IF ((querylist->qual[d.seq].pos[paramidx].stat=1))
       outtxt = status_ok
      ELSE
       outtxt = status_err
      ENDIF
      IF (textlen(trim(querylist->qual[d.seq].pos[paramidx].disp,3)) > 34)
       outtxt = concat(outtxt," ",substring(1,29,querylist->qual[d.seq].pos[paramidx].disp),"...")
      ELSE
       outtxt = concat(outtxt," ",querylist->qual[d.seq].pos[paramidx].disp)
      ENDIF
      col col_positions, outtxt
     ELSEIF (paramidx=1
      AND (querylist->qual[d.seq].pos_add_all_ind=1))
      outtxt = concat(status_ok," all"), col col_positions, outtxt
     ENDIF
     row + 1
   ENDFOR
   row + 1
   FOR (logidx = 1 TO querylist->qual[d.seq].msgcnt)
     outtxt = concat("[",querylist->qual[d.seq].logmsg[logidx].level,"] ",querylist->qual[d.seq].
      logmsg[logidx].msg)
     IF (textlen(outtxt) > 340)
      outtxt = concat(substring(1,340,outtxt),"...")
     ENDIF
     col col_logmsg, outtxt, row + 1
   ENDFOR
   row + 1, col 0, divider_2,
   row + 1
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 350, maxrow = 1
 ;end select
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1,
     col_status = 0, col_name = (col_status+ 25), col_query_type = (col_name+ 40),
     col_providers = (col_query_type+ 35), col_treatment = (col_providers+ 30), col_careteam = (
     col_treatment+ 35),
     col_encounter_type = (col_careteam+ 45), col_facilities = (col_encounter_type+ 30),
     col_referral_order = (col_facilities+ 35),
     col_positions = (col_referral_order+ 35)
    DETAIL
     row + 2, col col_status, "STATUS.",
     col col_name, "NAME", col col_query_type,
     "TYPE", col col_providers, "PROVIDERS",
     col col_treatment, "TREATMENT SPECIALITY", col col_careteam,
     "CARE TEAM", col col_encounter_type, "ENCOUNTER TYPE",
     col col_facilities, "FACILITIES", col col_referral_order,
     "REFERRAL ORDER", col col_positions, "POSITIONS",
     row + 1, col 0, divider_1
    WITH nocounter, format = variable, noformfeed,
     maxcol = 350, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE logmsg(level,msg)
   SET msglog->cnt = (msglog->cnt+ 1)
   SET stat = alterlist(msglog->qual,msglog->cnt)
   SET msglog->qual[msglog->cnt].level = level
   SET msglog->qual[msglog->cnt].msg = msg
 END ;Subroutine
 SUBROUTINE loglistmsg(qidx,level,msg)
   SET querylist->qual[qidx].msgcnt = (querylist->qual[qidx].msgcnt+ 1)
   SET stat = alterlist(querylist->qual[qidx].logmsg,querylist->qual[qidx].msgcnt)
   SET querylist->qual[qidx].logmsg[querylist->qual[qidx].msgcnt].level = level
   SET querylist->qual[qidx].logmsg[querylist->qual[qidx].msgcnt].msg = msg
 END ;Subroutine
 SUBROUTINE add_param_values(paramtype,paramval,qidx)
   IF (textlen(trim(paramval,3)) > 0)
    DECLARE new_size = i4 WITH protect, noconstant(0)
    SET paramvaltmp = cnvtupper(cnvtalphanum(paramval))
    CASE (paramtype)
     OF param_provider_type:
      IF (cnvtupper(paramval)="ALL")
       SET querylist->qual[qidx].provider_group_add_all_ind = 1
      ELSE
       SET new_size = (size(querylist->qual[qidx].provider_group,5)+ 1)
       SET stat = alterlist(querylist->qual[qidx].provider_group,new_size)
       SET querylist->qual[qidx].provider_group[new_size].disp = paramvaltmp
      ENDIF
     OF param_treatment_type:
      IF (cnvtupper(paramval)="ALL")
       SET querylist->qual[qidx].treatment_add_all_ind = 1
      ELSE
       SET new_size = (size(querylist->qual[qidx].treatment,5)+ 1)
       SET stat = alterlist(querylist->qual[qidx].treatment,new_size)
       SET querylist->qual[qidx].treatment[new_size].disp = paramvaltmp
      ENDIF
     OF param_care_type:
      IF (cnvtupper(paramval)="ALL")
       SET querylist->qual[qidx].care_add_all_ind = 1
      ELSE
       SET new_size = (size(querylist->qual[qidx].care,5)+ 1)
       SET stat = alterlist(querylist->qual[qidx].care,new_size)
       SET querylist->qual[qidx].care[new_size].disp = paramvaltmp
      ENDIF
     OF param_facilities_type:
      IF (cnvtupper(paramval)="ALL")
       SET querylist->qual[qidx].fac_add_all_ind = 1
      ELSE
       SET new_size = (size(querylist->qual[qidx].fac,5)+ 1)
       SET stat = alterlist(querylist->qual[qidx].fac,new_size)
       SET querylist->qual[qidx].fac[new_size].disp = paramvaltmp
      ENDIF
     OF param_encounter_type:
      IF (cnvtupper(paramval)="ALL")
       SET querylist->qual[qidx].enc_add_all_ind = 1
      ELSE
       SET new_size = (size(querylist->qual[qidx].enc,5)+ 1)
       SET stat = alterlist(querylist->qual[qidx].enc,new_size)
       SET querylist->qual[qidx].enc[new_size].disp = paramvaltmp
      ENDIF
     OF param_referral_type:
      IF (cnvtupper(paramval)="ALL")
       SET querylist->qual[qidx].ref_add_all_ind = 1
      ELSE
       SET new_size = (size(querylist->qual[qidx].ref,5)+ 1)
       SET stat = alterlist(querylist->qual[qidx].ref,new_size)
       SET querylist->qual[qidx].ref[new_size].disp = paramvaltmp
      ENDIF
     OF param_positions_type:
      IF (cnvtupper(paramval)="ALL")
       SET querylist->qual[qidx].pos_add_all_ind = 1
      ELSE
       SET new_size = (size(querylist->qual[qidx].pos,5)+ 1)
       SET stat = alterlist(querylist->qual[qidx].pos,new_size)
       SET querylist->qual[qidx].pos[new_size].disp = paramvaltmp
      ENDIF
    ENDCASE
   ENDIF
 END ;Subroutine
 SUBROUTINE get_provider_group_code_values(i4_listidx)
   DECLARE pro_size = i4 WITH protect, noconstant(size(querylist->qual[i4_listidx].provider_group,5))
   IF ((((querylist->qual[i4_listidx].provider_group_add_all_ind=1)) OR (pro_size <= 0)) )
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    p.prsnl_group_id
    FROM prsnl_group p,
     code_value cv
    PLAN (p
     WHERE p.active_ind=1
      AND expand(idx,1,pro_size,p.prsnl_group_name_key,querylist->qual[i4_listidx].provider_group[idx
      ].disp)
      AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (cv
     WHERE cv.cdf_meaning="DCPTEAM"
      AND cv.code_set=code_set_provider_group
      AND cv.code_value=p.prsnl_group_class_cd)
    ORDER BY p.prsnl_group_name
    DETAIL
     pos = locateval(idx,1,pro_size,p.prsnl_group_name_key,querylist->qual[i4_listidx].
      provider_group[idx].disp)
     IF (pos != 0)
      querylist->qual[i4_listidx].provider_group[pos].disp = p.prsnl_group_name_key, querylist->qual[
      i4_listidx].provider_group[pos].value = p.prsnl_group_id, querylist->qual[i4_listidx].
      provider_group[pos].stat = value_ok
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_treatment_code_values(i4_listidx)
   DECLARE treatment_size = i4 WITH protect, noconstant(size(querylist->qual[i4_listidx].treatment,5)
    )
   IF ((((querylist->qual[i4_listidx].treatment_add_all_ind=1)) OR (treatment_size <= 0)) )
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=code_set_treatment_specialities
     AND cv.active_ind=1
     AND expand(idx,1,treatment_size,cv.display_key,querylist->qual[i4_listidx].treatment[idx].disp)
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    ORDER BY cv.display_key
    DETAIL
     pos = locateval(idx,1,treatment_size,cv.display_key,querylist->qual[i4_listidx].treatment[idx].
      disp)
     IF (pos != 0)
      querylist->qual[i4_listidx].treatment[pos].disp = cv.display, querylist->qual[i4_listidx].
      treatment[pos].value = cv.code_value, querylist->qual[i4_listidx].treatment[pos].stat =
      value_ok
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_care_team_code_values(i4_listidx)
   DECLARE care_size = i4 WITH protect, noconstant(size(querylist->qual[i4_listidx].care,5))
   IF ((((querylist->qual[i4_listidx].care_add_all_ind=1)) OR (care_size <= 0)) )
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.active_ind=1
      AND cv.code_set=code_set_careteam
      AND expand(idx,1,care_size,cv.display_key,querylist->qual[i4_listidx].care[idx].disp)
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    ORDER BY cv.display_key
    DETAIL
     pos = locateval(idx,1,care_size,cv.display_key,querylist->qual[i4_listidx].care[idx].disp)
     IF (pos != 0)
      querylist->qual[i4_listidx].care[pos].disp = cv.display, querylist->qual[i4_listidx].care[pos].
      value = cv.code_value, querylist->qual[i4_listidx].care[pos].stat = value_ok
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_encounter_code_values(i4_listidx)
   DECLARE enc_size = i4 WITH protect, noconstant(size(querylist->qual[i4_listidx].enc,5))
   IF ((((querylist->qual[i4_listidx].enc_add_all_ind=1)) OR (enc_size <= 0)) )
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=code_set_encounters
     AND cv.active_ind=1
     AND expand(idx,1,enc_size,cv.display_key,querylist->qual[i4_listidx].enc[idx].disp)
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    ORDER BY cv.display_key
    DETAIL
     pos = locateval(idx,1,enc_size,cv.display_key,querylist->qual[i4_listidx].enc[idx].disp)
     IF (pos != 0)
      querylist->qual[i4_listidx].enc[pos].disp = cv.display, querylist->qual[i4_listidx].enc[pos].
      value = cv.code_value, querylist->qual[i4_listidx].enc[pos].stat = value_ok
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_facilities_code_values(i4_listidx)
   DECLARE facilities_size = i4 WITH protect, noconstant(size(querylist->qual[i4_listidx].fac,5))
   IF (facilities_size <= 0)
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE qualifier_clause = vc WITH protect, noconstant(" cv.active_ind = 1")
   IF ((querylist->qual[i4_listidx].fac_add_all_ind != 1))
    SET qualifier_clause = concat(qualifier_clause,
     " and expand (idx, 1, facilities_size, cv.display_key, queryList->qual[i4_listIdx].fac[idx].disp)"
     )
   ENDIF
   SELECT INTO "nl:"
    FROM location l,
     code_value cv,
     code_value cv2
    PLAN (l
     WHERE l.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=l.location_cd
      AND parser(qualifier_clause)
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
      AND (cv.active_type_cd != reqdata->deleted_cd))
     JOIN (cv2
     WHERE cv2.active_ind=1
      AND cv2.cdf_meaning=cdf_meaning_facility
      AND cv2.code_set=code_set_facilities
      AND cv2.code_value=l.location_type_cd)
    ORDER BY cv.collation_seq, cv.display, l.location_cd
    HEAD l.location_cd
     pos = locateval(idx,1,facilities_size,cv.display_key,querylist->qual[i4_listidx].fac[idx].disp)
     IF (pos != 0)
      querylist->qual[i4_listidx].fac[pos].disp = cv.display, querylist->qual[i4_listidx].fac[pos].
      value = cv.code_value, querylist->qual[i4_listidx].fac[pos].stat = value_ok
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_referral_order_code_values(i4_listidx,inpatientind)
   DECLARE ref_size = i4 WITH protect, noconstant(size(querylist->qual[i4_listidx].ref,5))
   IF (ref_size <= 0)
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE refcodeset = i4 WITH protect, noconstant(0)
   DECLARE qualifier_clause = vc WITH protect, noconstant(" cv.active_ind = 1")
   IF ((querylist->qual[i4_listidx].fac_add_all_ind != 1))
    SET qualifier_clause = concat(qualifier_clause,
     " and expand (idx, 1, ref_size, cv.display_key, queryList->qual[i4_listIdx].ref[idx].disp)")
   ENDIF
   IF (inpatientind=1)
    SET refcodeset = code_set_ahp_inpatient
   ELSE
    SET refcodeset = code_set_ahp
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=refcodeset
     AND parser(qualifier_clause)
    ORDER BY cv.display_key
    DETAIL
     pos = locateval(idx,1,ref_size,cv.display_key,querylist->qual[i4_listidx].ref[idx].disp)
     IF (pos != 0)
      querylist->qual[i4_listidx].ref[pos].disp = cv.display, querylist->qual[i4_listidx].ref[pos].
      value = cv.code_value, querylist->qual[i4_listidx].ref[pos].stat = value_ok
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_positions_code_values(i4_listidx)
   DECLARE position_size = i4 WITH protect, noconstant(size(querylist->qual[i4_listidx].pos,5))
   IF (position_size <= 0)
    RETURN
   ENDIF
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE skip = i2 WITH protect, noconstant(0)
   DECLARE qualifier_clause = vc WITH protect, noconstant(" cv.active_ind = 1")
   IF ((querylist->qual[i4_listidx].pos_add_all_ind != 1))
    SET qualifier_clause = concat(qualifier_clause,
     " and expand (idx, 1, position_size, cv.display_key, queryList->qual[i4_listIdx].pos[idx].disp)"
     )
   ENDIF
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=code_set_positions
     AND parser(qualifier_clause)
    ORDER BY cv.display_key
    DETAIL
     pos = locateval(idx,1,position_size,cv.display_key,querylist->qual[i4_listidx].pos[idx].disp)
     IF (pos != 0)
      querylist->qual[i4_listidx].pos[pos].disp = cv.display, querylist->qual[i4_listidx].pos[pos].
      value = cv.code_value, querylist->qual[i4_listidx].pos[pos].stat = value_ok
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE populate_param(add_request,listidx)
   DECLARE paramname = vc WITH protect, noconstant("")
   DECLARE paramidx = i4 WITH protect, noconstant(1)
   DECLARE paramstart = i4 WITH protect, noconstant(1)
   DECLARE paramvaluesize = i4 WITH protect, noconstant(0)
   DECLARE valueidx = i4 WITH protect, noconstant(0)
   SET add_request->query_type_cd = querylist->qual[listidx].query_type_cd
   SET add_request->name = querylist->qual[listidx].name
   SELECT INTO "nl:"
    FROM dcp_pl_query_parameter d
    WHERE (d.query_type_cd=querylist->qual[listidx].query_type_cd)
    DETAIL
     stat = alterlist(add_request->parameters,(size(add_request->parameters,5)+ 1)), paramname =
     cnvtupper(d.parameter_name)
     IF (paramname="PROVIDERS")
      add_request->parameters[paramidx].param_id = d.parameter_id, add_request->parameters[paramidx].
      parameter_name = "Providers", add_request->parameters[paramidx].parameter_seq = d.parameter_seq,
      paramvaluesize = size(querylist->qual[listidx].provider_group,5), stat = alterlist(add_request
       ->parameters[paramidx].values,paramvaluesize)
      FOR (valueidx = 1 TO paramvaluesize)
        add_request->parameters[paramidx].values[valueidx].name = "R_GROUP_ID", add_request->
        parameters[paramidx].values[valueidx].value_seq = 0, add_request->parameters[paramidx].
        values[valueidx].value_entity = "PRSNL_GROUP",
        add_request->parameters[paramidx].values[valueidx].value_id = querylist->qual[listidx].
        provider_group[valueidx].value
      ENDFOR
      paramidx = (paramidx+ 1)
     ELSEIF (((paramname="TREATMENT FUNCTION") OR (((paramname="TREATMENT SPECIALTY") OR (((paramname
     ="CARE TEAM") OR (((paramname="ENCOUNTER TYPE") OR (((paramname="FACILITY LOCATION") OR (
     paramname="REFERRAL ORDER")) )) )) )) )) )
      add_request->parameters[paramidx].param_id = d.parameter_id, add_request->parameters[paramidx].
      parameter_seq = d.parameter_seq
      CASE (paramname)
       OF "TREATMENT FUNCTION":
        add_request->parameters[paramidx].parameter_name = "Treatment Function",paramvaluesize = size
        (querylist->qual[listidx].treatment,5)
       OF "TREATMENT SPECIALTY":
        add_request->parameters[paramidx].parameter_name = "Treatment Specialty",paramvaluesize =
        size(querylist->qual[listidx].treatment,5)
       OF "CARE TEAM":
        add_request->parameters[paramidx].parameter_name = "Care Team",paramvaluesize = size(
         querylist->qual[listidx].care,5)
       OF "ENCOUNTER TYPE":
        add_request->parameters[paramidx].parameter_name = "Encounter Type",paramvaluesize = size(
         querylist->qual[listidx].enc,5)
       OF "FACILITY LOCATION":
        add_request->parameters[paramidx].parameter_name = "Facility Location",paramvaluesize = size(
         querylist->qual[listidx].fac,5)
       OF "REFERRAL ORDER":
        add_request->parameters[paramidx].parameter_name = "Referral Order",paramvaluesize = size(
         querylist->qual[listidx].ref,5)
      ENDCASE
      stat = alterlist(add_request->parameters[paramidx].values,paramvaluesize)
      FOR (valueidx = 1 TO paramvaluesize)
        add_request->parameters[paramidx].values[valueidx].name = "R_ENTITY_ID", add_request->
        parameters[paramidx].values[valueidx].value_seq = valueidx, add_request->parameters[paramidx]
        .values[valueidx].value_entity = "CODE_VALUE"
        CASE (paramname)
         OF "TREATMENT FUNCTION":
          add_request->parameters[paramidx].values[valueidx].value_id = querylist->qual[listidx].
          treatment[valueidx].value
         OF "TREATMENT SPECIALTY":
          add_request->parameters[paramidx].values[valueidx].value_id = querylist->qual[listidx].
          treatment[valueidx].value
         OF "CARE TEAM":
          add_request->parameters[paramidx].values[valueidx].value_id = querylist->qual[listidx].
          care[valueidx].value
         OF "ENCOUNTER TYPE":
          add_request->parameters[paramidx].values[valueidx].value_id = querylist->qual[listidx].enc[
          valueidx].value
         OF "FACILITY LOCATION":
          add_request->parameters[paramidx].values[valueidx].value_id = querylist->qual[listidx].fac[
          valueidx].value
         OF "REFERRAL ORDER":
          add_request->parameters[paramidx].values[valueidx].value_id = querylist->qual[listidx].ref[
          valueidx].value
        ENDCASE
      ENDFOR
      paramidx = (paramidx+ 1)
     ELSE
      CALL logmsg("ERROR",concat("'",paramname,
       "' is a required parameter, but we don't know how to process it"))
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE add_update_query_template(reqrec,qidx,templateid)
   DECLARE x = i4 WITH protect, noconstant(0)
   DECLARE y = i4 WITH protect, noconstant(0)
   DECLARE _templateid = f8 WITH protect, noconstant(0.0)
   DECLARE error_occur = i2 WITH protect, noconstant(0)
   DECLARE paramcnt = i4 WITH noconstant(size(reqrec->parameters,5))
   DECLARE paramid = f8 WITH protect, noconstant(0.0)
   DECLARE returnresult = i2 WITH protect, noconstant(1)
   IF ((querylist->qual[qidx].templateid > 0.0))
    SET _templateid = querylist->qual[qidx].templateid
    CALL loglistmsg(qidx,"DEBUG",concat('Found "',reqrec->name,'" with template_id = ',build(
       _templateid),"."))
   ELSE
    CALL loglistmsg(qidx,"DEBUG",concat('Cannot find template with name "',reqrec->name,
      '". New template will be created.'))
   ENDIF
   IF (insertflag="Y")
    IF (_templateid=0.0)
     SELECT INTO "nl:"
      num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       _templateid = cnvtreal(num)
      WITH format, counter
     ;end select
     INSERT  FROM dcp_pl_query_template dpqt
      SET dpqt.template_id = _templateid, dpqt.query_type_cd = reqrec->query_type_cd, dpqt
       .template_name = reqrec->name,
       dpqt.updt_cnt = 0, dpqt.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqt.updt_id = reqinfo->
       updt_id,
       dpqt.updt_applctx = reqinfo->updt_applctx, dpqt.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (checkerror(failure,"INSERT",failure,concat("Insert new template ",reqrec->name))=0)
      SET querylist->qual[qidx].stat = stat_insert_ok
     ELSE
      SET error_occur = 1
      SET querylist->qual[qidx].stat = stat_insert_error
      CALL loglistmsg(qidx,"ERROR",concat('Failed to insert new template "',reqrec->name,'" (id=',
        build(_templateid),")"))
     ENDIF
    ELSE
     DELETE  FROM dcp_pl_query_value d
      WHERE d.template_id=_templateid
      WITH nocounter
     ;end delete
     IF (checkerror(failure,"DELETE",failure,concat("Delete children param value for '",reqrec->name,
       "'"))=0)
      SET querylist->qual[qidx].stat = stat_update_ok
     ELSE
      SET error_occur = 1
      SET querylist->qual[qidx].stat = stat_update_error
      CALL loglistmsg(qidx,"ERROR",concat('Failed to delete children param values for template "',
        reqrec->name,'" (id=',build(_templateid),")"))
     ENDIF
    ENDIF
   ELSE
    IF (_templateid=0.0)
     SET querylist->qual[qidx].stat = stat_audit_insert_ok
    ELSE
     SET querylist->qual[qidx].stat = stat_audit_update_ok
    ENDIF
   ENDIF
   IF (insertflag="Y"
    AND error_occur != 1)
    FOR (x = 1 TO paramcnt)
     DECLARE valuecnt = i4 WITH protect, noconstant(size(reqrec->parameters[x].values,5))
     FOR (y = 1 TO valuecnt)
      IF ((reqrec->parameters[x].values[y].value_id=0.0))
       SET error_occur = 1
       CALL loglistmsg(qidx,"ERROR","Cannot add parameter with value_id = 0.0")
      ENDIF
      IF (error_occur != 1)
       IF ((reqrec->parameters[x].values[y].value_id=0.0))
        SET entityname = trim("")
       ELSE
        SET entityname = reqrec->parameters[x].values[y].value_entity
       ENDIF
       INSERT  FROM dcp_pl_query_value dpqv
        SET dpqv.parameter_id = reqrec->parameters[x].param_id, dpqv.parameter_seq = reqrec->
         parameters[x].parameter_seq, dpqv.parent_entity_id = reqrec->parameters[x].values[y].
         value_id,
         dpqv.parent_entity_name = trim(entityname), dpqv.patient_list_id = 0, dpqv.query_value_id =
         seq(dcp_patient_list_seq,nextval),
         dpqv.template_id = _templateid, dpqv.value_dt = cnvtdatetime(reqrec->parameters[x].values[y]
          .value_dt), dpqv.value_name = reqrec->parameters[x].values[y].name,
         dpqv.value_seq = reqrec->parameters[x].values[y].value_seq, dpqv.value_string = reqrec->
         parameters[x].values[y].value_string, dpqv.updt_cnt = 0,
         dpqv.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqv.updt_id = reqinfo->updt_id, dpqv
         .updt_applctx = reqinfo->updt_applctx,
         dpqv.updt_task = reqinfo->updt_task
        WITH nocounter
       ;end insert
       IF (checkerror(failure,"INSERT",failure,concat("Insert new param value ",build(reqrec->
          parameters[x].values[y].value_id))) != 0)
        SET error_occur = 1
        CALL loglistmsg(qidx,"ERROR",concat("Failed to insert new param value ",build(reqrec->
           parameters[x].values[y].value_id),' for template "',reqrec->name,'" (id=',
          build(_templateid),")"))
       ENDIF
      ENDIF
     ENDFOR
    ENDFOR
   ENDIF
   IF (error_occur=1)
    ROLLBACK
    CALL loglistmsg(qidx,"ERROR",'Perform ROLLBACK inside subroutine "add_update_query_template"')
    IF ((querylist->qual[qidx].templateid > 0.0))
     IF (insertflag="Y")
      SET querylist->qual[qidx].stat = stat_update_error
     ELSE
      SET querylist->qual[qidx].stat = stat_audit_update_error
     ENDIF
    ELSE
     IF (insertflag="Y")
      SET querylist->qual[qidx].stat = stat_insert_error
     ELSE
      SET querylist->qual[qidx].stat = stat_audit_insert_error
     ENDIF
    ENDIF
    SET templateid = 0.0
    SET returnresult = 0
   ELSE
    SET templateid = _templateid
   ENDIF
   RETURN(returnresult)
 END ;Subroutine
 SUBROUTINE upd_query_template_access(request,qidx)
   FREE RECORD patient_list
   RECORD patient_list(
     1 qual[*]
       2 patient_list_id = f8
       2 keep_flag = i2
       2 owner_id = f8
   ) WITH public
   DECLARE positioncnt = i4 WITH noconstant(size(request->positions,5))
   DECLARE x = i4 WITH noconstant(0)
   DECLARE pl_cnt = i4 WITH noconstant(0)
   DECLARE tempaccess_seq = f8 WITH noconstant(0.0)
   DECLARE error_occur = i2 WITH noconstant(0)
   DECLARE returnresult = i2 WITH protect, noconstant(1)
   IF (insertflag="Y")
    DELETE  FROM dcp_pl_query_temp_access d
     WHERE (d.template_id=request->template_id)
     WITH nocounter
    ;end delete
    IF (checkerror(failure,"DELETE",failure,concat(
      "Delete entries from dcp_pl_query_temp_access with template_id = ",build(request->template_id))
     ) != 0)
     SET error_occur = 1
     CALL loglistmsg(qidx,"ERROR",concat(
       "Failed to delete template access rows that match with template id ",build(request->
        template_id)))
    ENDIF
   ENDIF
   IF (error_occur != 1)
    SELECT INTO "nl:"
     FROM dcp_pl_query_list ql,
      dcp_patient_list dpl
     PLAN (ql
      WHERE (ql.template_id=request->template_id))
      JOIN (dpl
      WHERE dpl.patient_list_id=ql.patient_list_id)
     HEAD REPORT
      pl_cnt = 0
     DETAIL
      IF (mod(pl_cnt,10)=0)
       stat = alterlist(patient_list->qual,(pl_cnt+ 10))
      ENDIF
      pl_cnt = (pl_cnt+ 1), patient_list->qual[pl_cnt].patient_list_id = ql.patient_list_id,
      patient_list->qual[pl_cnt].keep_flag = 0,
      patient_list->qual[pl_cnt].owner_id = dpl.owner_prsnl_id
     FOOT REPORT
      stat = alterlist(patient_list->qual,pl_cnt)
     WITH nocounter
    ;end select
    CALL loglistmsg(qidx,"DEBUG",concat("There are ",build(pl_cnt),
      " patient lists that tie to template id ",build(request->template_id)))
    FOR (x = 1 TO positioncnt)
     IF ((request->positions[x].position_cd=0.0))
      SET error_occur = 1
      CALL loglistmsg(qidx,"ERROR","Cannot add position with position_cd = 0.0")
     ENDIF
     IF (error_occur != 1
      AND insertflag="Y")
      SELECT INTO "nl:"
       num = seq(dcp_patient_list_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        tempaccess_seq = cnvtreal(num)
       WITH format, counter
      ;end select
      INSERT  FROM dcp_pl_query_temp_access dpqta
       SET dpqta.position_cd = request->positions[x].position_cd, dpqta.template_access_id =
        tempaccess_seq, dpqta.template_id = request->template_id,
        dpqta.updt_cnt = 0, dpqta.updt_dt_tm = cnvtdatetime(curdate,curtime3), dpqta.updt_id =
        reqinfo->updt_id,
        dpqta.updt_applctx = reqinfo->updt_applctx, dpqta.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (checkerror(failure,"INSERT",failure,concat("Insert new row for the position ",build(request
         ->positions[x].position_cd))) != 0)
       SET error_occur = 1
       CALL loglistmsg(qidx,"ERROR",concat("Failed to insert new row for position ",build(request->
          positions[x].position_cd)))
      ENDIF
     ENDIF
    ENDFOR
   ENDIF
   IF (error_occur != 1
    AND insertflag="Y")
    IF (positioncnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = pl_cnt),
       prsnl p
      PLAN (d
       WHERE (patient_list->qual[d.seq].keep_flag=0))
       JOIN (p
       WHERE (p.person_id=patient_list->qual[d.seq].owner_id)
        AND expand(x,1,positioncnt,p.position_cd,request->positions[x].position_cd))
      DETAIL
       patient_list->qual[d.seq].keep_flag = 1
      WITH nocounter
     ;end select
    ENDIF
    FOR (i = 1 TO size(patient_list->qual,5))
      IF ((patient_list->qual[i].keep_flag=0))
       IF ((patient_list->qual[i].patient_list_id > 0))
        EXECUTE dcp_del_patient_list value(patient_list->qual[i].patient_list_id)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
   IF (error_occur)
    ROLLBACK
    CALL loglistmsg(qidx,"ERROR",'Perform ROLLBACK inside subroutine "upd_query_template_access"')
    SET returnresult = 0
    IF ((querylist->qual[qidx].templateid > 0.0))
     IF (insertflag="Y")
      SET querylist->qual[qidx].stat = stat_update_error
     ELSE
      SET querylist->qual[qidx].stat = stat_audit_update_error
     ENDIF
    ELSE
     IF (insertflag="Y")
      SET querylist->qual[qidx].stat = stat_insert_error
     ELSE
      SET querylist->qual[qidx].stat = stat_audit_insert_error
     ENDIF
    ENDIF
   ENDIF
   RETURN(returnresult)
 END ;Subroutine
#exit_script
 CALL showerrors("MINE")
END GO
