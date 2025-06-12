CREATE PROGRAM bed_imp_res_list_appt_type_rel:dba
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
 IF (validate(build->appt_types)=0)
  RECORD build(
    1 appt_type_cnt = i4
    1 appt_types[*]
      2 appt_type_cd = f8
      2 appt_type_disp = vc
      2 appt_type_disp_orig = vc
      2 appt_type_flag = i2
      2 action_flag = i2
      2 error_msg = vc
      2 location_cnt = i4
      2 locations[*]
        3 location_cd = f8
        3 location_disp = vc
        3 location_disp_orig = vc
        3 res_list_id = f8
        3 res_list_disp = vc
        3 res_list_disp_orig = vc
        3 existing_ind = i2
        3 action_flag = i2
        3 status_flag = i2
        3 error_msg = vc
  )
 ENDIF
 FREE RECORD id_values
 RECORD id_values(
   1 res_list_cnt = i4
   1 res_lists[*]
     2 res_list_disp = vc
     2 res_list_id = f8
   1 location_cnt = i4
   1 locations[*]
     2 location_disp = vc
     2 location_cd = f8
 )
 DECLARE input_cnt = i4 WITH protect, constant(size(requestin->list_0,5))
 DECLARE dummyt_where = vc WITH protect, constant(
  "initarray(exp_start, evaluate(d.seq, 1, 1, exp_start + EXP_SIZE))")
 DECLARE exp_base = vc WITH protect, constant(
  "expand(exp_idx, exp_start, exp_start + (EXP_SIZE - 1),")
 DECLARE exp_size = i4 WITH protect, constant(25)
 DECLARE fail_action = i2 WITH protect, constant(- (1))
 DECLARE insert_action = i2 WITH protect, constant(1)
 DECLARE update_action = i2 WITH protect, constant(2)
 DECLARE begin_date = q8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE log_file = vc WITH protect, constant("ccluserdir:bed_res_list_appt_type.log")
 DECLARE insert_flag = i2 WITH protect, noconstant(0)
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE exp_start = i4 WITH protect, noconstant(1)
 DECLARE appt_idx = i4 WITH protect, noconstant(0)
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE failrow(a_idx=i4,l_idx=i4,error_msg=vc) = null
 DECLARE generrormsg(error_msg1=vc,error_msg2=vc) = vc
 DECLARE checkstatus(check_action=i2) = null
 SUBROUTINE failrow(a_idx,l_idx,error_msg)
  DECLARE l_cnt = i4 WITH private, noconstant(0)
  IF (a_idx > 0)
   SET build->appt_types[a_idx].action_flag = fail_action
   IF (l_idx <= 0)
    SET build->appt_types[a_idx].error_msg = generrormsg(build->appt_types[a_idx].error_msg,error_msg
     )
    FOR (l_cnt = 1 TO build->appt_types[a_idx].location_cnt)
      SET build->appt_types[a_idx].locations[l_cnt].action_flag = fail_action
    ENDFOR
   ELSE
    SET build->appt_types[a_idx].locations[l_idx].action_flag = fail_action
    SET build->appt_types[a_idx].locations[l_idx].error_msg = generrormsg(build->appt_types[a_idx].
     locations[l_idx].error_msg,error_msg)
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE generrormsg(error_msg1,error_msg2)
   DECLARE cat_error_msg = vc WITH private, noconstant("")
   IF (textlen(trim(error_msg2,3)) > 0)
    IF (textlen(trim(error_msg1,3)) > 0)
     SET cat_error_msg = concat(error_msg1," | ",error_msg2)
    ELSE
     SET cat_error_msg = error_msg2
    ENDIF
   ENDIF
   RETURN(cat_error_msg)
 END ;Subroutine
 SUBROUTINE checkstatus(check_action)
   DECLARE a_idx = i4 WITH private, noconstant(0)
   DECLARE l_idx = i4 WITH private, noconstant(0)
   DECLARE l_cnt = i4 WITH private, noconstant(0)
   IF (check_action IN (insert_action, update_action))
    FOR (a_idx = 1 TO build->appt_type_cnt)
      IF ((build->appt_types[a_idx].action_flag != fail_action))
       SET l_idx = 0
       SET l_idx = locateval(l_cnt,(l_idx+ 1),build->appt_types[a_idx].location_cnt,0,build->
        appt_types[a_idx].locations[l_cnt].status_flag,
        check_action,build->appt_types[a_idx].locations[l_cnt].action_flag)
       WHILE (l_idx > 0)
        CALL failrow(a_idx,l_idx,concat("Failed ",evaluate(build->appt_types[a_idx].locations[l_idx].
           action_flag,insert_action,"inserting",update_action,"updating"),
          " relationship in the database."))
        SET l_idx = locateval(l_cnt,(l_idx+ 1),build->appt_types[a_idx].location_cnt,0,build->
         appt_types[a_idx].locations[l_cnt].status_flag,
         check_action,build->appt_types[a_idx].locations[l_cnt].action_flag)
       ENDWHILE
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 IF (input_cnt <= 0)
  GO TO exit_script
 ENDIF
 IF (validate(tempreq) > 0)
  IF (cnvtupper(trim(tempreq->insert_ind,3))="Y")
   SET insert_flag = 1
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  appt_type_disp = cnvtupper(cnvtalphanum(substring(1,100,requestin->list_0[d.seq].appointment_type))
   ), location_disp = cnvtupper(cnvtalphanum(substring(1,100,requestin->list_0[d.seq].location))),
  res_list_disp = cnvtupper(trim(substring(1,100,requestin->list_0[d.seq].resource_list),3)),
  loc_res_list_disp = concat(cnvtupper(cnvtalphanum(substring(1,100,requestin->list_0[d.seq].location
      ))),cnvtupper(trim(substring(1,100,requestin->list_0[d.seq].resource_list),3)))
  FROM (dummyt d  WITH seq = value(input_cnt))
  ORDER BY appt_type_disp, loc_res_list_disp
  HEAD appt_type_disp
   build->appt_type_cnt = (build->appt_type_cnt+ 1)
   IF (mod(build->appt_type_cnt,exp_size)=1)
    stat = alterlist(build->appt_types,((build->appt_type_cnt+ exp_size) - 1))
   ENDIF
   build->appt_types[build->appt_type_cnt].appt_type_disp = appt_type_disp, build->appt_types[build->
   appt_type_cnt].appt_type_disp_orig = requestin->list_0[d.seq].appointment_type
  HEAD loc_res_list_disp
   build->appt_types[build->appt_type_cnt].location_cnt = (build->appt_types[build->appt_type_cnt].
   location_cnt+ 1)
   IF (mod(build->appt_types[build->appt_type_cnt].location_cnt,10)=1)
    stat = alterlist(build->appt_types[build->appt_type_cnt].locations,(build->appt_types[build->
     appt_type_cnt].location_cnt+ 9))
   ENDIF
   build->appt_types[build->appt_type_cnt].locations[build->appt_types[build->appt_type_cnt].
   location_cnt].location_disp = location_disp, build->appt_types[build->appt_type_cnt].locations[
   build->appt_types[build->appt_type_cnt].location_cnt].res_list_disp = res_list_disp, build->
   appt_types[build->appt_type_cnt].locations[build->appt_types[build->appt_type_cnt].location_cnt].
   location_disp_orig = requestin->list_0[d.seq].location,
   build->appt_types[build->appt_type_cnt].locations[build->appt_types[build->appt_type_cnt].
   location_cnt].res_list_disp_orig = requestin->list_0[d.seq].resource_list, loc_idx = 0
   IF ((id_values->location_cnt > 0))
    loc_idx = locateval(loc_idx,1,id_values->location_cnt,location_disp,id_values->locations[loc_idx]
     .location_disp)
   ENDIF
   IF (loc_idx=0)
    id_values->location_cnt = (id_values->location_cnt+ 1)
    IF (mod(id_values->location_cnt,exp_size)=1)
     stat = alterlist(id_values->locations,((id_values->location_cnt+ exp_size) - 1))
    ENDIF
    id_values->locations[id_values->location_cnt].location_disp = location_disp
   ENDIF
   loc_idx = 0
   IF ((id_values->res_list_cnt > 0))
    loc_idx = locateval(loc_idx,1,id_values->res_list_cnt,res_list_disp,id_values->res_lists[loc_idx]
     .res_list_disp)
   ENDIF
   IF (loc_idx=0)
    id_values->res_list_cnt = (id_values->res_list_cnt+ 1)
    IF (mod(id_values->res_list_cnt,exp_size)=1)
     stat = alterlist(id_values->res_lists,((id_values->res_list_cnt+ exp_size) - 1))
    ENDIF
    id_values->res_lists[id_values->res_list_cnt].res_list_disp = res_list_disp
   ENDIF
  FOOT  appt_type_disp
   stat = alterlist(build->appt_types[build->appt_type_cnt].locations,build->appt_types[build->
    appt_type_cnt].location_cnt)
  FOOT REPORT
   FOR (loop_cnt = (build->appt_type_cnt+ 1) TO size(build->appt_types,5))
     build->appt_types[loop_cnt].appt_type_disp = build->appt_types[build->appt_type_cnt].
     appt_type_disp
   ENDFOR
   FOR (loop_cnt = (id_values->location_cnt+ 1) TO size(id_values->locations,5))
     id_values->locations[loop_cnt].location_disp = id_values->locations[id_values->location_cnt].
     location_disp
   ENDFOR
   FOR (loop_cnt = (id_values->res_list_cnt+ 1) TO size(id_values->res_lists,5))
     id_values->res_lists[loop_cnt].res_list_disp = id_values->res_lists[id_values->res_list_cnt].
     res_list_disp
   ENDFOR
  WITH nocounter
 ;end select
 IF (checkerror(failure,"SELECT",failure,"DATA LOAD") > 0)
  GO TO exit_script
 ENDIF
 SET exp_start = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((size(id_values->locations,5) - 1)/ exp_size)))),
   code_value c
  PLAN (d
   WHERE parser(dummyt_where))
   JOIN (c
   WHERE parser(concat(exp_base,"c.display_key, id_values->locations[exp_idx].location_disp)"))
    AND c.code_set=220
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   loc_idx = locateval(loc_idx,1,id_values->location_cnt,c.display_key,id_values->locations[loc_idx].
    location_disp)
   IF (loc_idx > 0)
    id_values->locations[loc_idx].location_cd = c.code_value
   ENDIF
  FOOT REPORT
   stat = alterlist(id_values->locations,id_values->location_cnt)
  WITH nocounter
 ;end select
 IF (checkerror(failure,"SELECT",failure,"LOCATION VALIDATE") > 0)
  GO TO exit_script
 ENDIF
 SET exp_start = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((size(id_values->res_lists,5) - 1)/ exp_size)))),
   sch_resource_list srl
  PLAN (d
   WHERE parser(dummyt_where))
   JOIN (srl
   WHERE parser(concat(exp_base,"srl.mnemonic_key, id_values->res_lists[exp_idx].res_list_disp)"))
    AND srl.active_ind=1)
  DETAIL
   loc_idx = locateval(loc_idx,1,id_values->res_list_cnt,srl.mnemonic_key,id_values->res_lists[
    loc_idx].res_list_disp)
   IF (loc_idx > 0)
    id_values->res_lists[loc_idx].res_list_id = srl.res_list_id
   ENDIF
  FOOT REPORT
   stat = alterlist(id_values->res_lists,id_values->res_list_cnt)
  WITH nocounter
 ;end select
 IF (checkerror(failure,"SELECT",failure,"RESOURCE LIST VALIDATE") > 0)
  GO TO exit_script
 ENDIF
 SET exp_start = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((size(build->appt_types,5) - 1)/ exp_size)))),
   code_value c,
   sch_appt_type sat
  PLAN (d
   WHERE parser(dummyt_where))
   JOIN (c
   WHERE parser(concat(exp_base,"c.display_key, build->appt_types[exp_idx].appt_type_disp)"))
    AND c.code_set=14230
    AND c.active_ind=1
    AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (sat
   WHERE sat.appt_type_cd=c.code_value
    AND sat.active_ind=1
    AND sat.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND sat.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  DETAIL
   appt_idx = locateval(appt_idx,1,build->appt_type_cnt,c.display_key,build->appt_types[appt_idx].
    appt_type_disp)
   IF (appt_idx > 0)
    build->appt_types[appt_idx].appt_type_cd = c.code_value, build->appt_types[appt_idx].
    appt_type_flag = sat.appt_type_flag
   ENDIF
  FOOT REPORT
   FOR (loop_cnt = (build->appt_type_cnt+ 1) TO size(build->appt_types,5))
     build->appt_types[loop_cnt].appt_type_cd = build->appt_types[build->appt_type_cnt].appt_type_cd
   ENDFOR
  WITH nocounter
 ;end select
 IF (checkerror(failure,"SELECT",failure,"APPT TYPE VALIDATE") > 0)
  GO TO exit_script
 ENDIF
 FOR (appt_idx = 1 TO build->appt_type_cnt)
   IF ((build->appt_types[appt_idx].appt_type_cd <= 0))
    CALL failrow(appt_idx,0,"Invalid display value for codeset 14230.")
   ENDIF
   IF ((build->appt_types[appt_idx].appt_type_flag > 0))
    CALL failrow(appt_idx,0,"Only single appointment types are currently supported.")
   ENDIF
   IF ((build->appt_types[appt_idx].location_cnt <= 0))
    CALL failrow(appt_idx,0,"No resource lists to associate to this appointment type.")
   ENDIF
   FOR (loc_idx = 1 TO build->appt_types[appt_idx].location_cnt)
     SET loop_cnt = locateval(loop_cnt,1,id_values->location_cnt,build->appt_types[appt_idx].
      locations[loc_idx].location_disp,id_values->locations[loop_cnt].location_disp)
     IF (loop_cnt > 0)
      SET build->appt_types[appt_idx].locations[loc_idx].location_cd = id_values->locations[loop_cnt]
      .location_cd
     ENDIF
     IF (((loop_cnt <= 0) OR ((build->appt_types[appt_idx].locations[loc_idx].location_cd <= 0))) )
      CALL failrow(appt_idx,loc_idx,"Invalid location display value for codeset 220.")
     ENDIF
     SET loop_cnt = locateval(loop_cnt,1,id_values->res_list_cnt,build->appt_types[appt_idx].
      locations[loc_idx].res_list_disp,id_values->res_lists[loop_cnt].res_list_disp)
     IF (loop_cnt > 0)
      SET build->appt_types[appt_idx].locations[loc_idx].res_list_id = id_values->res_lists[loop_cnt]
      .res_list_id
     ENDIF
     IF (((loop_cnt <= 0) OR ((build->appt_types[appt_idx].locations[loc_idx].res_list_id <= 0))) )
      CALL failrow(appt_idx,loc_idx,"Invalid resource list name from sch_resource_list.")
     ENDIF
     SET loop_cnt = locateval(loop_cnt,1,loc_idx,build->appt_types[appt_idx].locations[loc_idx].
      location_disp,build->appt_types[appt_idx].locations[loop_cnt].location_disp)
     IF (loop_cnt > 0
      AND loop_cnt != loc_idx)
      CALL failrow(appt_idx,loc_idx,"Duplicate location.")
     ENDIF
   ENDFOR
 ENDFOR
 SET exp_start = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((size(build->appt_types,5) - 1)/ exp_size)))),
   sch_appt_loc sal
  PLAN (d
   WHERE parser(dummyt_where))
   JOIN (sal
   WHERE parser(concat(exp_base,"sal.appt_type_cd, build->appt_types[exp_idx].appt_type_cd)"))
    AND sal.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND sal.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND sal.active_ind=1)
  ORDER BY sal.appt_type_cd
  HEAD sal.appt_type_cd
   appt_idx = locateval(appt_idx,1,build->appt_type_cnt,sal.appt_type_cd,build->appt_types[appt_idx].
    appt_type_cd)
  DETAIL
   IF (appt_idx > 0)
    loc_idx = locateval(loc_idx,1,build->appt_types[appt_idx].location_cnt,sal.location_cd,build->
     appt_types[appt_idx].locations[loc_idx].location_cd)
    IF (loc_idx > 0)
     IF ((build->appt_types[appt_idx].locations[loc_idx].action_flag != fail_action))
      build->appt_types[appt_idx].locations[loc_idx].action_flag = update_action
     ENDIF
    ELSE
     IF (sal.res_list_id > 0)
      build->appt_types[appt_idx].location_cnt = (build->appt_types[appt_idx].location_cnt+ 1), stat
       = alterlist(build->appt_types[appt_idx].locations,build->appt_types[appt_idx].location_cnt),
      build->appt_types[appt_idx].locations[build->appt_types[appt_idx].location_cnt].action_flag =
      update_action,
      build->appt_types[appt_idx].locations[build->appt_types[appt_idx].location_cnt].location_cd =
      sal.location_cd, build->appt_types[appt_idx].locations[build->appt_types[appt_idx].location_cnt
      ].res_list_id = 0.0, build->appt_types[appt_idx].locations[build->appt_types[appt_idx].
      location_cnt].existing_ind = 1
     ENDIF
    ENDIF
   ENDIF
  FOOT  sal.appt_type_cd
   IF (appt_idx > 0)
    loc_idx = 0, loc_idx = locateval(loop_cnt,(loc_idx+ 1),build->appt_types[appt_idx].location_cnt,0,
     build->appt_types[appt_idx].locations[loop_cnt].action_flag)
    WHILE (loc_idx > 0)
     build->appt_types[appt_idx].locations[loc_idx].action_flag = insert_action,loc_idx = locateval(
      loop_cnt,(loc_idx+ 1),build->appt_types[appt_idx].location_cnt,0,build->appt_types[appt_idx].
      locations[loop_cnt].action_flag)
    ENDWHILE
   ENDIF
  FOOT REPORT
   stat = alterlist(build->appt_types,build->appt_type_cnt)
  WITH nocounter, forupdate(sal)
 ;end select
 IF (checkerror(failure,"SELECT",failure,"EXISTING DATA CHECK") > 0)
  GO TO exit_script
 ENDIF
 IF (insert_flag > 0)
  UPDATE  FROM (dummyt d1  WITH seq = value(build->appt_type_cnt)),
    (dummyt d2  WITH seq = value(1)),
    sch_appt_loc sal
   SET sal.updt_dt_tm = cnvtdatetime(curdate,curtime3), sal.updt_applctx = reqinfo->updt_applctx, sal
    .updt_id = reqinfo->updt_id,
    sal.updt_cnt = (sal.updt_cnt+ 1), sal.updt_task = reqinfo->updt_task, sal.res_list_id = build->
    appt_types[d1.seq].locations[d2.seq].res_list_id
   PLAN (d1
    WHERE (build->appt_types[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->appt_types[d1.seq].location_cnt))
    JOIN (d2
    WHERE (build->appt_types[d1.seq].locations[d2.seq].action_flag=update_action))
    JOIN (sal
    WHERE (sal.appt_type_cd=build->appt_types[d1.seq].appt_type_cd)
     AND (sal.location_cd=build->appt_types[d1.seq].locations[d2.seq].location_cd))
   WITH nocounter, status(build->appt_types[d1.seq].locations[d2.seq].status_flag)
  ;end update
  CALL checkstatus(update_action)
  IF (checkerror(failure,"UPDATE",failure,"SCH_APPT_LOC") > 0)
   GO TO exit_script
  ENDIF
  INSERT  FROM (dummyt d1  WITH seq = value(build->appt_type_cnt)),
    (dummyt d2  WITH seq = value(1)),
    sch_appt_loc sal
   SET sal.appt_type_cd = build->appt_types[d1.seq].appt_type_cd, sal.location_cd = build->
    appt_types[d1.seq].locations[d2.seq].location_cd, sal.res_list_id = build->appt_types[d1.seq].
    locations[d2.seq].res_list_id,
    sal.candidate_id = seq(sch_candidate_seq,nextval), sal.version_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), sal.null_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
    sal.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sal.end_effective_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"), sal.active_ind = 1,
    sal.active_status_cd = reqdata->active_status_cd, sal.active_status_dt_tm = cnvtdatetime(curdate,
     curtime3), sal.active_status_prsnl_id = reqinfo->updt_id,
    sal.updt_dt_tm = cnvtdatetime(curdate,curtime3), sal.updt_applctx = reqinfo->updt_applctx, sal
    .updt_id = reqinfo->updt_id,
    sal.updt_cnt = 0, sal.updt_task = reqinfo->updt_task
   PLAN (d1
    WHERE (build->appt_types[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->appt_types[d1.seq].location_cnt))
    JOIN (d2
    WHERE (build->appt_types[d1.seq].locations[d2.seq].action_flag=insert_action))
    JOIN (sal)
   WITH nocounter, status(build->appt_types[d1.seq].locations[d2.seq].status_flag)
  ;end insert
  CALL checkstatus(insert_action)
  IF (checkerror(failure,"INSERT",failure,"SCH_APPT_LOC") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 CALL checkerror(failure,"CCL ERROR",failure,"FINAL ERROR CHECK")
 SELECT INTO value(log_file)
  appt_type_disp = trim(substring(1,100,build->appt_types[d1.seq].appt_type_disp_orig),3),
  location_disp = trim(substring(1,100,build->appt_types[d1.seq].locations[d2.seq].location_disp_orig
    ),3), res_list_disp = trim(substring(1,100,build->appt_types[d1.seq].locations[d2.seq].
    res_list_disp_orig),3)
  FROM (dummyt d1  WITH seq = value(build->appt_type_cnt)),
   (dummyt d2  WITH seq = value(1))
  PLAN (d1
   WHERE maxrec(d2,build->appt_types[d1.seq].location_cnt))
   JOIN (d2
   WHERE (build->appt_types[d1.seq].locations[d2.seq].existing_ind=0)
    AND d2.seq > 0)
  ORDER BY appt_type_disp, location_disp, res_list_disp
  HEAD REPORT
   col_count = 0, col_appt_disp = (col_count+ 5), col_appt_error = (col_appt_disp+ 5),
   col_loc_disp = (col_appt_disp+ 10), col_res_disp = (col_loc_disp+ 40), col_action = 110,
   col_loc_error = (col_loc_disp+ 5), row_cnt = 0, action_disp = fillstring(10,""),
   line = fillstring(value(120),"-"), col 0, "APPOINTMENT TYPE - RESOURCE LIST ASSOCIATION IMPORT",
   row + 1, col 0, "LAST RUN: ",
   col 11, begin_date"@MEDIUMDATETIME", row + 1,
   row + 1
   IF ((errors->error_ind > 0))
    col 0, "CCL ERRORS ENCOUNTERED!:", row + 1
    FOR (loop_cnt = 1 TO errors->error_cnt)
      col 0, errors->status_data.subeventstatus[loop_cnt].operationname, col 20,
      errors->status_data.subeventstatus[loop_cnt].targetobjectname, row + 1, col 0,
      errors->status_data.subeventstatus[loop_cnt].targetobjectvalue, row + 1
    ENDFOR
    row + 1
   ENDIF
   col col_count, "Row", col col_appt_disp,
   "Appointment Type", row + 1, col col_loc_disp,
   "Location", col col_res_disp, "Resource List",
   col col_action, "Action", row + 1,
   col 0, line, row + 1
  HEAD appt_type_disp
   row_cnt = (row_cnt+ 1), action_disp = evaluate(build->appt_types[d1.seq].action_flag,fail_action,
    "FAIL",evaluate(insert_flag,0,"VERIFIED","UPLOADED")), col col_count,
   row_cnt"###;r;i", col col_appt_disp, appt_type_disp,
   col col_action, action_disp
   IF (textlen(trim(build->appt_types[d1.seq].error_msg,3)) > 0)
    row + 1, col col_appt_error, build->appt_types[d1.seq].error_msg
   ENDIF
   row + 1
  DETAIL
   row_cnt = (row_cnt+ 1), action_disp = evaluate(build->appt_types[d1.seq].locations[d2.seq].
    action_flag,fail_action,"FAIL",evaluate(build->appt_types[d1.seq].action_flag,fail_action,
     "NO ACTION",evaluate(insert_flag,0,"VERIFIED",evaluate(build->appt_types[d1.seq].locations[d2
       .seq].action_flag,insert_action,"INSERTED",update_action,"UPDATED")))), col col_count,
   row_cnt"###;r;i", col col_loc_disp, location_disp,
   col col_res_disp, res_list_disp, col col_action,
   action_disp
   IF (textlen(trim(build->appt_types[d1.seq].locations[d2.seq].error_msg,3)) > 0)
    row + 1, col col_loc_error, build->appt_types[d1.seq].locations[d2.seq].error_msg
   ENDIF
   row + 1
  FOOT  appt_type_disp
   col 0, line, row + 1
  FOOT REPORT
   CALL center("---------- END OF LOG ----------",0,120)
  WITH nocounter, format = variable, noformfeed,
   maxcol = 200, maxrow = 1, nullreport
 ;end select
 CALL echo("")
 CALL echo(
  "******************************************************************************************")
 CALL echo(concat("*   Upload complete, check ",log_file," for more information.   *"))
 CALL echo(
  "******************************************************************************************")
 CALL echo("")
END GO
