CREATE PROGRAM bed_imp_sn_report_privs:dba
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
 IF (validate(build->rpts)=0)
  RECORD build(
    1 rpt_cnt = i4
    1 rpts[*]
      2 rpt_disp = vc
      2 rpt_id = f8
      2 action_flag = i2
      2 error_msg = vc
      2 rpt_priv_flag = i2
      2 priv_cnt = i4
      2 privs[*]
        3 parent_entity_disp = vc
        3 parent_entity_name = vc
        3 parent_entity_id = f8
        3 priv_disp = vc
        3 priv_disp_orig = vc
        3 person_id = f8
        3 position_cd = f8
        3 application_disp = vc
        3 application_number = f8
        3 access_flag_disp = vc
        3 access_flag = i2
        3 action_flag = i2
        3 status_flag = i2
        3 error_msg = vc
  )
 ENDIF
 FREE RECORD id_values
 RECORD id_values(
   1 filter_group_cnt = i4
   1 filter_groups[*]
     2 rpt_disp = vc
     2 rpt_id = f8
     2 type_flag = i2
     2 filter_group_disp = vc
     2 filter_group_id = f8
   1 priv_cnt = i4
   1 privs[*]
     2 priv_disp = vc
     2 priv_id = f8
     2 surgeon_ind = i2
   1 app_cnt = i4
   1 apps[*]
     2 app_disp = vc
     2 app_number = f8
 )
 FREE RECORD del_privs
 RECORD del_privs(
   1 cnt = i4
   1 qual[*]
     2 priv_id = f8
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
 DECLARE log_file = vc WITH protect, constant("ccluserdir:bed_sn_report_privs.log")
 DECLARE fg_type_flag = i2 WITH protect, constant(3)
 DECLARE no_access = i2 WITH protect, constant(0)
 DECLARE view_only = i2 WITH protect, constant(1)
 DECLARE run_only = i2 WITH protect, constant(2)
 DECLARE view_run = i2 WITH protect, constant(3)
 DECLARE view_run_copy = i2 WITH protect, constant(7)
 DECLARE view_modify = i2 WITH protect, constant(9)
 DECLARE view_run_modify = i2 WITH protect, constant(11)
 DECLARE view_run_copy_mod = i2 WITH protect, constant(15)
 DECLARE parent_filter_grp = vc WITH protect, constant("SN_RPT_FILTER_GRP")
 DECLARE parent_report = vc WITH protect, constant("SN_RPT")
 DECLARE insert_flag = i2 WITH protect, noconstant(0)
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE exp_start = i4 WITH protect, noconstant(1)
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 DECLARE rpt_idx = i4 WITH protect, noconstant(0)
 DECLARE priv_idx = i4 WITH protect, noconstant(0)
 DECLARE report_type_schedule = f8 WITH protect, noconstant(0.0)
 DECLARE failrow(r_idx=i4,p_idx=i4,error_msg=vc) = null
 DECLARE generrormsg(error_msg1=vc,error_msg2=vc) = vc
 DECLARE checkstatus(check_action=i2,check_filters=i2) = null
 SUBROUTINE failrow(r_idx,p_idx,error_msg)
   SET curalias err_struct_alias off
   IF (p_idx > 0)
    CALL failrow(r_idx,0,"")
    SET curalias err_struct_alias build->rpts[r_idx].privs[p_idx]
   ELSEIF (r_idx > 0)
    SET curalias err_struct_alias build->rpts[r_idx]
   ENDIF
   SET err_struct_alias->action_flag = fail_action
   SET err_struct_alias->error_msg = generrormsg(err_struct_alias->error_msg,error_msg)
   SET curalias err_struct_alias off
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
   DECLARE r_idx = i4 WITH private, noconstant(0)
   DECLARE p_idx = i4 WITH private, noconstant(0)
   DECLARE l_cnt = i4 WITH private, noconstant(0)
   IF (check_action IN (insert_action, update_action))
    FOR (r_idx = 1 TO build->rpt_cnt)
      IF ((build->rpts[r_idx].action_flag != fail_action))
       SET p_idx = 0
       SET p_idx = locateval(l_cnt,(p_idx+ 1),build->rpts[r_idx].priv_cnt,0,build->rpts[r_idx].privs[
        l_cnt].status_flag,
        check_action,build->rpts[r_idx].privs[l_cnt].action_flag)
       WHILE (p_idx > 0)
        CALL failrow(r_idx,p_idx,concat("Failed ",evaluate(build->rpts[r_idx].privs[p_idx].
           action_flag,insert_action,"inserting",update_action,"updating"),
          " relationship in the database."))
        SET p_idx = locateval(l_cnt,(p_idx+ 1),build->rpts[r_idx].priv_cnt,0,build->rpts[r_idx].
         privs[l_cnt].status_flag,
         check_action,build->rpts[r_idx].privs[l_cnt].action_flag)
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
  FROM code_value c
  WHERE c.code_set=25069
   AND c.cdf_meaning="SCHEDULE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   report_type_schedule = c.code_value
  WITH nocounter
 ;end select
 IF (((checkerror(failure,"SELECT",failure,"SCHEDULE REPORT TYPE") > 0) OR (report_type_schedule <=
 0.0)) )
  CALL adderrormsg(failure,"SELECT",failure,"SCHEDULE REPORT TYPE",
   "Could not retrieve code_value for 'SCHEDULE' report type")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  report_name_disp = trim(substring(1,100,requestin->list_0[d.seq].report_name),3)
  FROM (dummyt d  WITH seq = value(input_cnt))
  ORDER BY report_name_disp
  HEAD report_name_disp
   build->rpt_cnt = (build->rpt_cnt+ 1)
   IF (mod(build->rpt_cnt,exp_size)=1)
    stat = alterlist(build->rpts,((build->rpt_cnt+ exp_size) - 1))
   ENDIF
   build->rpts[build->rpt_cnt].rpt_disp = report_name_disp, priv_idx = 0
  DETAIL
   priv_idx = (priv_idx+ 1)
   IF (mod(priv_idx,50)=1)
    stat = alterlist(build->rpts[build->rpt_cnt].privs,(priv_idx+ 49))
   ENDIF
   build->rpts[build->rpt_cnt].privs[priv_idx].parent_entity_disp = trim(requestin->list_0[d.seq].
    filter_group,3), build->rpts[build->rpt_cnt].privs[priv_idx].priv_disp_orig = trim(requestin->
    list_0[d.seq].position_username,3), build->rpts[build->rpt_cnt].privs[priv_idx].priv_disp =
   cnvtupper(build->rpts[build->rpt_cnt].privs[priv_idx].priv_disp_orig),
   build->rpts[build->rpt_cnt].privs[priv_idx].application_disp = trim(requestin->list_0[d.seq].
    application,3), build->rpts[build->rpt_cnt].privs[priv_idx].access_flag_disp = trim(requestin->
    list_0[d.seq].privilege_type,3)
   IF (textlen(trim(build->rpts[build->rpt_cnt].privs[priv_idx].parent_entity_disp,3))=0)
    build->rpts[build->rpt_cnt].rpt_priv_flag = 1, build->rpts[build->rpt_cnt].privs[priv_idx].
    parent_entity_name = parent_report
   ELSE
    build->rpts[build->rpt_cnt].privs[priv_idx].parent_entity_name = parent_filter_grp
   ENDIF
   CASE (cnvtupper(cnvtalphanum(build->rpts[build->rpt_cnt].privs[priv_idx].access_flag_disp)))
    OF "NOACCESS":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = no_access
    OF "VIEWONLY":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = view_only
    OF "RUNONLY":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = run_only
    OF "VIEWRUN":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = view_run
    OF "VIEWRUNCOPY":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = view_run_copy
    OF "VIEWMODIFY":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = view_modify
    OF "VIEWRUNMODIFY":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = view_run_modify
    OF "VIEWRUNCOPYMODIFY":
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = view_run_copy_mod
    ELSE
     build->rpts[build->rpt_cnt].privs[priv_idx].access_flag = - (1)
   ENDCASE
   loc_idx = 0
   IF ((id_values->priv_cnt > 0))
    loc_idx = locateval(loc_idx,1,id_values->priv_cnt,build->rpts[build->rpt_cnt].privs[priv_idx].
     priv_disp,id_values->privs[loc_idx].priv_disp)
   ENDIF
   IF (loc_idx=0)
    id_values->priv_cnt = (id_values->priv_cnt+ 1)
    IF (mod(id_values->priv_cnt,exp_size)=1)
     stat = alterlist(id_values->privs,((id_values->priv_cnt+ exp_size) - 1))
    ENDIF
    id_values->privs[id_values->priv_cnt].priv_disp = build->rpts[build->rpt_cnt].privs[priv_idx].
    priv_disp
   ENDIF
   IF (textlen(trim(build->rpts[build->rpt_cnt].privs[priv_idx].parent_entity_disp,3)) > 0)
    loc_idx = 0
    IF ((id_values->filter_group_cnt > 0))
     loc_idx = locateval(loc_idx,1,id_values->filter_group_cnt,build->rpts[build->rpt_cnt].rpt_disp,
      id_values->filter_groups[loc_idx].rpt_disp,
      build->rpts[build->rpt_cnt].privs[priv_idx].parent_entity_disp,id_values->filter_groups[loc_idx
      ].filter_group_disp)
    ENDIF
    IF (loc_idx=0)
     id_values->filter_group_cnt = (id_values->filter_group_cnt+ 1)
     IF (mod(id_values->filter_group_cnt,exp_size)=1)
      stat = alterlist(id_values->filter_groups,((id_values->filter_group_cnt+ exp_size) - 1))
     ENDIF
     id_values->filter_groups[id_values->filter_group_cnt].rpt_disp = build->rpts[build->rpt_cnt].
     rpt_disp, id_values->filter_groups[id_values->filter_group_cnt].type_flag = fg_type_flag,
     id_values->filter_groups[id_values->filter_group_cnt].filter_group_disp = build->rpts[build->
     rpt_cnt].privs[priv_idx].parent_entity_disp
    ENDIF
   ENDIF
   loc_idx = 0
   IF ((id_values->app_cnt > 0))
    loc_idx = locateval(loc_idx,1,id_values->app_cnt,build->rpts[build->rpt_cnt].privs[priv_idx].
     application_disp,id_values->apps[loc_idx].app_disp)
   ENDIF
   IF (loc_idx=0)
    id_values->app_cnt = (id_values->app_cnt+ 1)
    IF (mod(id_values->app_cnt,exp_size)=1)
     stat = alterlist(id_values->apps,((id_values->app_cnt+ exp_size) - 1))
    ENDIF
    id_values->apps[id_values->app_cnt].app_disp = build->rpts[build->rpt_cnt].privs[priv_idx].
    application_disp
   ENDIF
  FOOT  report_name_disp
   build->rpts[build->rpt_cnt].priv_cnt = priv_idx, stat = alterlist(build->rpts[build->rpt_cnt].
    privs,priv_idx)
  FOOT REPORT
   FOR (rpt_idx = (build->rpt_cnt+ 1) TO size(build->rpts,5))
     build->rpts[rpt_idx].rpt_disp = build->rpts[build->rpt_cnt].rpt_disp
   ENDFOR
   FOR (priv_idx = (id_values->priv_cnt+ 1) TO size(id_values->privs,5))
     id_values->privs[priv_idx].priv_disp = id_values->privs[id_values->priv_cnt].priv_disp
   ENDFOR
   FOR (priv_idx = (id_values->app_cnt+ 1) TO size(id_values->apps,5))
     id_values->apps[priv_idx].app_disp = id_values->apps[id_values->app_cnt].app_disp
   ENDFOR
  WITH nocounter, nullreport
 ;end select
 IF (checkerror(failure,"SELECT",failure,"DATA LOAD") > 0)
  GO TO exit_script
 ENDIF
 SET exp_start = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((build->rpt_cnt - 1)/ exp_size)))),
   sn_rpt r
  PLAN (d
   WHERE parser(dummyt_where))
   JOIN (r
   WHERE parser(concat(exp_base,"r.display, build->rpts[exp_idx].rpt_disp)")))
  DETAIL
   rpt_idx = locateval(rpt_idx,1,build->rpt_cnt,r.display,build->rpts[rpt_idx].rpt_disp)
   IF (rpt_idx > 0)
    build->rpts[rpt_idx].rpt_id = r.rpt_id, rpt_idx = 0, rpt_idx = locateval(loc_idx,(rpt_idx+ 1),
     id_values->filter_group_cnt,r.display,id_values->filter_groups[loc_idx].rpt_disp)
    WHILE (rpt_idx > 0)
     id_values->filter_groups[rpt_idx].rpt_id = r.rpt_id,rpt_idx = locateval(loc_idx,(rpt_idx+ 1),
      id_values->filter_group_cnt,r.display,id_values->filter_groups[loc_idx].rpt_disp)
    ENDWHILE
   ENDIF
  WITH nocounter
 ;end select
 IF (checkerror(failure,"SELECT",failure,"REPORT VALIDATE") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->filter_group_cnt > 0))
  FOR (loc_idx = (id_values->filter_group_cnt+ 1) TO size(id_values->filter_groups,5))
    SET id_values->filter_groups[loc_idx].rpt_id = id_values->filter_groups[id_values->
    filter_group_cnt].rpt_id
    SET id_values->filter_groups[loc_idx].type_flag = id_values->filter_groups[id_values->
    filter_group_cnt].type_flag
    SET id_values->filter_groups[loc_idx].filter_group_disp = id_values->filter_groups[id_values->
    filter_group_cnt].filter_group_disp
  ENDFOR
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((id_values->filter_group_cnt - 1)/ exp_size)))),
    sn_rpt_filter_grp fg
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (fg
    WHERE parser(concat(exp_base,"fg.rpt_id, id_values->filter_groups[exp_idx].rpt_id,",
      "fg.type_flag, id_values->filter_groups[exp_idx].type_flag,",
      "fg.display, id_values->filter_groups[exp_idx].filter_group_disp)")))
   ORDER BY fg.rpt_id
   HEAD fg.rpt_id
    rpt_idx = 0, rpt_idx = locateval(rpt_idx,1,build->rpt_cnt,fg.rpt_id,build->rpts[rpt_idx].rpt_id)
   DETAIL
    IF (rpt_idx > 0)
     priv_idx = 0, priv_idx = locateval(loc_idx,(priv_idx+ 1),build->rpts[rpt_idx].priv_cnt,fg
      .display,build->rpts[rpt_idx].privs[loc_idx].parent_entity_disp)
     WHILE (priv_idx > 0)
      build->rpts[rpt_idx].privs[priv_idx].parent_entity_id = fg.rpt_filter_grp_id,priv_idx =
      locateval(loc_idx,(priv_idx+ 1),build->rpts[rpt_idx].priv_cnt,fg.display,build->rpts[rpt_idx].
       privs[loc_idx].parent_entity_disp)
     ENDWHILE
     loc_idx = locateval(loc_idx,1,id_values->filter_group_cnt,fg.rpt_id,id_values->filter_groups[
      loc_idx].rpt_id,
      fg.display,id_values->filter_groups[loc_idx].filter_group_disp)
     IF (loc_idx > 0)
      id_values->filter_groups[loc_idx].filter_group_id = fg.rpt_filter_grp_id
     ENDIF
    ENDIF
   FOOT REPORT
    FOR (loc_idx = (id_values->filter_group_cnt+ 1) TO size(id_values->filter_groups,5))
      id_values->filter_groups[loc_idx].filter_group_id = id_values->filter_groups[id_values->
      filter_group_cnt].filter_group_id
    ENDFOR
   WITH nocounter, nullreport
  ;end select
  IF (checkerror(failure,"SELECT",failure,"FILTER GROUP VALIDATE") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((id_values->priv_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(id_values->priv_cnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE c.display_key=cnvtalphanum(id_values->privs[d.seq].priv_disp)
     AND ((c.code_set+ 0)=88)
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    id_values->privs[d.seq].priv_id = c.code_value
   WITH nocounter
  ;end select
  IF (checkerror(failure,"SELECT",failure,"POSITION VALIDATE") > 0)
   GO TO exit_script
  ENDIF
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((id_values->priv_cnt - 1)/ exp_size)))),
    prsnl p
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (p
    WHERE parser(concat(exp_base,"p.username, id_values->privs[exp_idx].priv_disp)"))
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    priv_idx = locateval(priv_idx,1,id_values->priv_cnt,p.username,id_values->privs[priv_idx].
     priv_disp)
    IF (priv_idx > 0)
     IF ((id_values->privs[priv_idx].priv_id=0))
      id_values->privs[priv_idx].priv_id = p.person_id, id_values->privs[priv_idx].surgeon_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  IF (checkerror(failure,"SELECT",failure,"SURGEON VALIDATE") > 0)
   GO TO exit_script
  ENDIF
  SET stat = alterlist(id_values->privs,id_values->priv_cnt)
 ENDIF
 IF ((id_values->app_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((id_values->app_cnt - 1)/ exp_size)))),
    application a
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (a
    WHERE parser(concat(exp_base,"a.description, id_values->apps[exp_idx].app_disp)"))
     AND a.active_ind=1)
   DETAIL
    priv_idx = locateval(priv_idx,1,id_values->priv_cnt,a.description,id_values->apps[exp_idx].
     app_disp)
    IF (priv_idx > 0)
     id_values->apps[priv_idx].app_number = a.application_number
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->apps,id_values->app_cnt)
   WITH nocounter, nullreport
  ;end select
  IF (checkerror(failure,"SELECT",failure,"APPLICATION VALIDATE") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (rpt_idx = 1 TO build->rpt_cnt)
   IF ((build->rpts[rpt_idx].rpt_id <= 0))
    CALL failrow(rpt_idx,0,"Invalid display value from sn_rpt.")
   ENDIF
   FOR (priv_idx = 1 TO build->rpts[rpt_idx].priv_cnt)
     IF ((build->rpts[rpt_idx].privs[priv_idx].parent_entity_name=parent_report))
      SET build->rpts[rpt_idx].privs[priv_idx].parent_entity_id = build->rpts[rpt_idx].rpt_id
     ELSEIF ((build->rpts[rpt_idx].privs[priv_idx].parent_entity_id=0.0))
      CALL failrow(rpt_idx,priv_idx,"Invalid filter group display from sn_rpt_filter_grp")
     ENDIF
     SET loc_idx = locateval(loc_idx,1,id_values->priv_cnt,build->rpts[rpt_idx].privs[priv_idx].
      priv_disp,id_values->privs[loc_idx].priv_disp)
     IF (loc_idx > 0)
      IF ((id_values->privs[loc_idx].surgeon_ind=1))
       SET build->rpts[rpt_idx].privs[priv_idx].person_id = id_values->privs[loc_idx].priv_id
      ELSE
       SET build->rpts[rpt_idx].privs[priv_idx].position_cd = id_values->privs[loc_idx].priv_id
      ENDIF
     ENDIF
     IF (((loc_idx <= 0) OR ((build->rpts[rpt_idx].privs[priv_idx].person_id <= 0)
      AND (build->rpts[rpt_idx].privs[priv_idx].position_cd <= 0))) )
      CALL failrow(rpt_idx,priv_idx,evaluate(id_values->privs[loc_idx].surgeon_ind,1,
        "Invalid surgeon username from prsnl","Invalid position display value from codeset 88"))
     ELSE
      SET build->rpts[rpt_idx].privs[priv_idx].action_flag = insert_action
     ENDIF
     SET loc_idx = locateval(loc_idx,1,id_values->app_cnt,build->rpts[rpt_idx].privs[priv_idx].
      application_disp,id_values->apps[loc_idx].app_disp)
     IF (loc_idx > 0)
      SET build->rpts[rpt_idx].privs[priv_idx].application_number = id_values->apps[loc_idx].
      app_number
     ENDIF
     IF (((loc_idx <= 0) OR ((build->rpts[rpt_idx].privs[priv_idx].application_number <= 0))) )
      CALL failrow(rpt_idx,priv_idx,"Invalid application description")
     ELSE
      SET build->rpts[rpt_idx].privs[priv_idx].action_flag = insert_action
     ENDIF
     IF ((build->rpts[rpt_idx].privs[priv_idx].access_flag < 0))
      CALL failrow(rpt_idx,priv_idx,"Invalid privilege type")
     ENDIF
     SET loc_idx = locateval(loc_idx,1,build->rpts[rpt_idx].priv_cnt,build->rpts[rpt_idx].privs[
      priv_idx].parent_entity_name,build->rpts[rpt_idx].privs[loc_idx].parent_entity_name,
      build->rpts[rpt_idx].privs[priv_idx].parent_entity_id,build->rpts[rpt_idx].privs[loc_idx].
      parent_entity_id,build->rpts[rpt_idx].privs[priv_idx].person_id,build->rpts[rpt_idx].privs[
      loc_idx].person_id,build->rpts[rpt_idx].privs[priv_idx].position_cd,
      build->rpts[rpt_idx].privs[loc_idx].position_cd,build->rpts[rpt_idx].privs[priv_idx].
      application_number,build->rpts[rpt_idx].privs[loc_idx].application_number)
     IF (loc_idx > 0
      AND loc_idx != priv_idx)
      CALL failrow(rpt_idx,priv_idx,"Duplicate privilege")
     ENDIF
   ENDFOR
   IF ((build->rpts[rpt_idx].action_flag != fail_action))
    SET build->rpts[rpt_idx].action_flag = update_action
   ENDIF
 ENDFOR
 IF (insert_flag > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(build->rpt_cnt)),
    sn_priv p
   PLAN (d
    WHERE (build->rpts[d.seq].rpt_priv_flag > 0))
    JOIN (p
    WHERE (p.parent_entity_id=build->rpts[d.seq].rpt_id)
     AND p.parent_entity_name=parent_report)
   DETAIL
    del_privs->cnt = (del_privs->cnt+ 1)
    IF (mod(del_privs->cnt,exp_size)=1)
     stat = alterlist(del_privs->qual,((del_privs->cnt+ exp_size) - 1))
    ENDIF
    del_privs->qual[del_privs->cnt].priv_id = p.priv_id
   FOOT REPORT
    stat = alterlist(build->rpts,build->rpt_cnt)
   WITH nocounter, nullreport, forupdate(p)
  ;end select
  IF (checkerror(failure,"SELECT",failure,"REPORT LEVEL PRIVS") > 0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((build->rpt_cnt - 1)/ exp_size)))),
    sn_priv p
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (p
    WHERE parser(concat(exp_base,
      "p.parent_entity_id, id_values->filter_groups[exp_idx].filter_group_id)"))
     AND p.parent_entity_name=parent_filter_grp)
   DETAIL
    del_privs->cnt = (del_privs->cnt+ 1)
    IF (mod(del_privs->cnt,exp_size)=1)
     stat = alterlist(del_privs->qual,((del_privs->cnt+ exp_size) - 1))
    ENDIF
    del_privs->qual[del_privs->cnt].priv_id = p.priv_id
   FOOT REPORT
    FOR (loc_idx = (del_privs->cnt+ 1) TO size(del_privs->qual,5))
      del_privs->qual[loc_idx].priv_id = del_privs->qual[del_privs->cnt].priv_id
    ENDFOR
    stat = alterlist(id_values->filter_groups,id_values->filter_group_cnt)
   WITH nocounter, nullreport, forupdate(p)
  ;end select
  IF (checkerror(failure,"SELECT",failure,"FILTER GROUP LEVEL PRIVS") > 0)
   GO TO exit_script
  ENDIF
  IF ((del_privs->cnt > 0))
   DELETE  FROM (dummyt d  WITH seq = value((1+ ((del_privs->cnt - 1)/ exp_size)))),
     sn_priv p
    SET p.seq = 1
    PLAN (d
     WHERE parser(dummyt_where))
     JOIN (p
     WHERE parser(concat(exp_base,"p.priv_id, del_privs->qual[exp_idx].priv_id)")))
    WITH nocounter
   ;end delete
   IF ((curqual != del_privs->cnt))
    CALL adderrormsg(failure,"DELETE",failure,"SN_PRIV",
     "Could not delete all existing rows from sn_priv")
   ENDIF
   IF (checkerror(failure,"DELETE",failure,"SN_PRIV") > 0)
    GO TO exit_script
   ENDIF
  ENDIF
  INSERT  FROM (dummyt d1  WITH seq = value(build->rpt_cnt)),
    (dummyt d2  WITH seq = value(1)),
    sn_priv p
   SET p.priv_id = seq(surgery_seq,nextval), p.parent_entity_id = build->rpts[d1.seq].privs[d2.seq].
    parent_entity_id, p.parent_entity_name = build->rpts[d1.seq].privs[d2.seq].parent_entity_name,
    p.person_id = build->rpts[d1.seq].privs[d2.seq].person_id, p.position_cd = build->rpts[d1.seq].
    privs[d2.seq].position_cd, p.application_number = build->rpts[d1.seq].privs[d2.seq].
    application_number,
    p.access_flag = build->rpts[d1.seq].privs[d2.seq].access_flag, p.create_applctx = reqinfo->
    updt_applctx, p.create_dt_tm = cnvtdatetime(curdate,curtime3),
    p.create_prsnl_id = reqinfo->updt_id, p.create_task = reqinfo->updt_task, p.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    p.updt_cnt = 0, p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->updt_task,
    p.updt_applctx = reqinfo->updt_applctx
   PLAN (d1
    WHERE (build->rpts[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->rpts[d1.seq].priv_cnt))
    JOIN (d2
    WHERE (build->rpts[d1.seq].privs[d2.seq].action_flag=insert_action))
    JOIN (p)
   WITH nocounter, status(build->rpts[d1.seq].privs[d2.seq].status_flag)
  ;end insert
  CALL checkstatus(insert_action)
  IF (checkerror(failure,"INSERT",failure,"SN_PRIV") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 IF (checkerror(failure,"CCL ERROR",failure,"FINAL ERROR CHECK") > 0)
  IF (insert_flag > 0)
   ROLLBACK
  ENDIF
 ENDIF
 SELECT INTO value(log_file)
  rpt_disp = trim(substring(1,100,build->rpts[d1.seq].rpt_disp),3), filter_group_disp = trim(
   substring(1,100,build->rpts[d1.seq].privs[d2.seq].parent_entity_disp),3), position_username_disp
   = trim(substring(1,100,build->rpts[d1.seq].privs[d2.seq].priv_disp_orig),3),
  application_disp = trim(substring(1,100,build->rpts[d1.seq].privs[d2.seq].application_disp),3),
  privilege_disp = trim(substring(1,100,build->rpts[d1.seq].privs[d2.seq].access_flag_disp),3)
  FROM (dummyt d1  WITH seq = value(build->rpt_cnt)),
   (dummyt d2  WITH seq = value(1))
  PLAN (d1
   WHERE maxrec(d2,build->rpts[d1.seq].priv_cnt))
   JOIN (d2
   WHERE d2.seq > 0)
  ORDER BY rpt_disp, filter_group_disp
  HEAD REPORT
   col_count = 0, col_rpt_disp = (col_count+ 5), col_rpt_error = (col_rpt_disp+ 5),
   col_fg_disp = (col_rpt_disp+ 5), col_pos_user_disp = (col_fg_disp+ 40), col_app_disp = (
   col_pos_user_disp+ 40),
   col_priv_type_disp = (col_app_disp+ 30), col_action = (col_priv_type_disp+ 25), col_error = (
   col_action+ 10),
   row_cnt = 0, loop_cnt = 0, action_disp = fillstring(10,""),
   line = fillstring(value(200),"-"), col 0, "SURGINET REPORT PRIVILEGES IMPORT",
   row + 1, col 0, "RUN DATE: ",
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
   col col_count, "Row", col col_rpt_disp,
   "Report Name", row + 1, col col_fg_disp,
   "Filter Group", col col_pos_user_disp, "Position / Username",
   col col_app_disp, "Application", col col_priv_type_disp,
   "Privilege Type", col col_action, "Action",
   row + 1, col 0, line,
   row + 1
  HEAD rpt_disp
   row_cnt = (row_cnt+ 1), action_disp = evaluate(build->rpts[d1.seq].action_flag,fail_action,"FAIL",
    evaluate(insert_flag,0,"VERIFIED","UPLOADED")), col col_count,
   row_cnt"###;r;i", col col_rpt_disp, rpt_disp,
   col col_action, action_disp
   IF (textlen(trim(build->rpts[d1.seq].error_msg,3)) > 0)
    col col_error, build->rpts[d1.seq].error_msg
   ENDIF
   row + 1
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF ((build->rpts[d1.seq].privs[d2.seq].status_flag=0)
    AND insert_flag > 0)
    action_disp = "FAIL"
   ELSE
    action_disp = evaluate(build->rpts[d1.seq].privs[d2.seq].action_flag,fail_action,"FAIL",evaluate(
      insert_flag,0,"VERIFIED","UPLOADED"))
   ENDIF
   col col_count, row_cnt"###;r;i", col col_fg_disp,
   filter_group_disp, col col_pos_user_disp, position_username_disp,
   col col_app_disp, application_disp, col col_priv_type_disp,
   privilege_disp, col col_action, action_disp
   IF (textlen(trim(build->rpts[d1.seq].privs[d2.seq].error_msg,3)) > 0)
    col col_error, build->rpts[d1.seq].privs[d2.seq].error_msg
   ENDIF
   row + 1
   IF ((d2.seq != build->rpts[d1.seq].priv_cnt))
    IF (textlen(trim(build->rpts[d1.seq].privs[d2.seq].parent_entity_disp,3))=0
     AND textlen(trim(build->rpts[d1.seq].privs[(d2.seq+ 1)].parent_entity_disp,3)) > 0)
     row + 1
    ENDIF
   ENDIF
  FOOT  rpt_disp
   col 0, line, row + 1
  FOOT REPORT
   CALL center("---------- END OF LOG ----------",0,200)
  WITH nocounter, format = variable, noformfeed,
   maxcol = 300, maxrow = 1, nullreport
 ;end select
 CALL echo("")
 CALL echo(
  "******************************************************************************************")
 CALL echo(concat("*   Upload complete, check ",log_file," for more information.   *"))
 CALL echo(
  "******************************************************************************************")
 CALL echo("")
END GO
