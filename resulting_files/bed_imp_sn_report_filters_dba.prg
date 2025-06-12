CREATE PROGRAM bed_imp_sn_report_filters:dba
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
      2 owner_id = f8
      2 action_flag = i2
      2 error_msg = vc
      2 filter_group_cnt = i4
      2 filter_groups[*]
        3 filter_group_disp = vc
        3 filter_group_id = f8
        3 action_flag = i2
        3 status_flag = i2
        3 error_msg = vc
        3 filter_cnt = i4
        3 filters[*]
          4 filter_disp = vc
          4 filter_disp_orig = vc
          4 parent_entity_id = f8
          4 filter_ref_id = f8
          4 filter_string = vc
          4 action_flag = i2
          4 status_flag = i2
          4 error_msg = vc
  )
 ENDIF
 FREE RECORD id_values
 RECORD id_values(
   1 filter_group_cnt = i4
   1 filter_groups[*]
     2 rpt_id = f8
     2 type_flag = i2
     2 filter_group_disp = vc
     2 filter_group_id = f8
   1 surgeon_cnt = i4
   1 surgeons[*]
     2 surgeon_username = vc
     2 person_id = f8
   1 room_cnt = i4
   1 rooms[*]
     2 room_disp = vc
     2 service_resource_cd = f8
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
 DECLARE log_file = vc WITH protect, constant("ccluserdir:bed_sn_report_filters.log")
 DECLARE fg_type_flag = i2 WITH protect, constant(3)
 DECLARE insert_flag = i2 WITH protect, noconstant(0)
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE exp_start = i4 WITH protect, noconstant(1)
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 DECLARE rpt_idx = i4 WITH protect, noconstant(0)
 DECLARE group_idx = i4 WITH protect, noconstant(0)
 DECLARE filter_idx = i4 WITH protect, noconstant(0)
 DECLARE filter_ref_or_room = f8 WITH protect, noconstant(0.0)
 DECLARE filter_ref_surgeon = f8 WITH protect, noconstant(0.0)
 DECLARE filter_ref_noncancel = f8 WITH protect, noconstant(0.0)
 DECLARE report_type_schedule = f8 WITH protect, noconstant(0.0)
 DECLARE failrow(r_idx=i4,g_idx=i4,f_idx=i4,error_msg=vc) = null
 DECLARE generrormsg(error_msg1=vc,error_msg2=vc) = vc
 DECLARE checkstatus(check_action=i2,check_filters=i2) = null
 SUBROUTINE failrow(r_idx,g_idx,f_idx,error_msg)
   SET curalias err_struct_alias off
   IF (f_idx > 0)
    CALL failrow(r_idx,g_idx,0,"")
    SET curalias err_struct_alias build->rpts[r_idx].filter_groups[g_idx].filters[f_idx]
   ELSEIF (g_idx > 0)
    CALL failrow(r_idx,0,0,"")
    SET curalias err_struct_alias build->rpts[r_idx].filter_groups[g_idx]
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
 SUBROUTINE checkstatus(check_action,check_filters)
   DECLARE r_idx = i4 WITH private, noconstant(0)
   DECLARE g_idx = i4 WITH private, noconstant(0)
   DECLARE f_idx = i4 WITH private, noconstant(0)
   IF (check_action IN (insert_action, update_action))
    FOR (r_idx = 1 TO build->rpt_cnt)
      IF ((build->rpts[r_idx].action_flag != fail_action))
       SET g_idx = 0
       SET g_idx = locateval(loc_idx,(g_idx+ 1),build->rpts[r_idx].filter_group_cnt,0,build->rpts[
        r_idx].filter_groups[loc_idx].status_flag,
        check_action,build->rpts[r_idx].filter_groups[loc_idx].action_flag)
       WHILE (g_idx > 0)
        CALL failrow(r_idx,g_idx,0,concat("Failed ",evaluate(build->rpts[r_idx].filter_groups[g_idx].
           action_flag,insert_action,"inserting",update_action,"updating"),
          " relationship in the database."))
        SET g_idx = locateval(loc_idx,(g_idx+ 1),build->rpts[r_idx].filter_group_cnt,0,build->rpts[
         r_idx].filter_groups[loc_idx].status_flag,
         check_action,build->rpts[r_idx].filter_groups[loc_idx].action_flag)
       ENDWHILE
       IF (check_filters > 0)
        FOR (g_idx = 1 TO build->rpts[r_idx].filter_group_cnt)
          SET f_idx = 0
          SET f_idx = locateval(loc_idx,(f_idx+ 1),build->rpts[r_idx].filter_groups[g_idx].filter_cnt,
           0,build->rpts[r_idx].filter_groups[g_idx].filters[loc_idx].status_flag,
           check_action,build->rpts[r_idx].filter_groups[g_idx].filters[loc_idx].action_flag)
          WHILE (f_idx > 0)
           CALL failrow(r_idx,g_idx,f_idx,concat("Failed ",evaluate(build->rpts[r_idx].filter_groups[
              g_idx].filters[f_idx].action_flag,insert_action,"inserting",update_action,"updating"),
             " relationship in the database."))
           SET f_idx = locateval(loc_idx,(f_idx+ 1),build->rpts[r_idx].filter_groups[g_idx].
            filter_cnt,0,build->rpts[r_idx].filter_groups[g_idx].filters[loc_idx].status_flag,
            check_action,build->rpts[r_idx].filter_groups[g_idx].filters[loc_idx].action_flag)
          ENDWHILE
        ENDFOR
       ENDIF
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
  FROM sn_rpt_filter_ref rfr
  WHERE rfr.rpt_type_cd=report_type_schedule
   AND rfr.filter_key IN ("SCH_OR", "SCH_SURGEON", "NONCANCELED")
  DETAIL
   CASE (rfr.filter_key)
    OF "SCH_OR":
     filter_ref_or_room = rfr.rpt_filter_ref_id
    OF "SCH_SURGEON":
     filter_ref_surgeon = rfr.rpt_filter_ref_id
    OF "NONCANCELED":
     filter_ref_noncancel = rfr.rpt_filter_ref_id
   ENDCASE
  WITH nocounter
 ;end select
 IF (((checkerror(failure,"SELECT",failure,"FILTER REF") > 0) OR (((filter_ref_or_room <= 0.0) OR (((
 filter_ref_surgeon <= 0.0) OR (filter_ref_noncancel <= 0.0)) )) )) )
  CALL adderrormsg(failure,"SELECT",failure,"FILTER REF",
   "Could not retrieve sn_rpt_filter_ref_id for 'SCH_OR', 'SCH_SURGEON', or 'NONCANCELED' filter types"
   )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  report_name_disp = trim(substring(1,100,requestin->list_0[d.seq].report_name),3), filter_group_disp
   = trim(substring(1,100,requestin->list_0[d.seq].filter_group),3), surgeon_disp = trim(substring(1,
    100,requestin->list_0[d.seq].surgeon_username),3),
  room_disp = trim(substring(1,100,requestin->list_0[d.seq].room),3)
  FROM (dummyt d  WITH seq = value(input_cnt))
  ORDER BY report_name_disp, filter_group_disp
  HEAD report_name_disp
   build->rpt_cnt = (build->rpt_cnt+ 1)
   IF (mod(build->rpt_cnt,exp_size)=1)
    stat = alterlist(build->rpts,((build->rpt_cnt+ exp_size) - 1))
   ENDIF
   build->rpts[build->rpt_cnt].rpt_disp = report_name_disp, group_idx = 0
  HEAD filter_group_disp
   group_idx = (group_idx+ 1)
   IF (mod(group_idx,10)=1)
    stat = alterlist(build->rpts[build->rpt_cnt].filter_groups,(group_idx+ 9))
   ENDIF
   build->rpts[build->rpt_cnt].filter_groups[group_idx].filter_group_disp = filter_group_disp,
   filter_idx = 0
  DETAIL
   IF (textlen(trim(surgeon_disp,3)) > 0)
    filter_idx = (filter_idx+ 1)
    IF (mod(filter_idx,10)=1)
     stat = alterlist(build->rpts[build->rpt_cnt].filter_groups[group_idx].filters,(filter_idx+ 9))
    ENDIF
    build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[filter_idx].filter_disp = cnvtupper(
     surgeon_disp), build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[filter_idx].
    filter_disp_orig = surgeon_disp, build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[
    filter_idx].filter_ref_id = filter_ref_surgeon,
    loc_idx = 0
    IF ((id_values->surgeon_cnt > 0))
     loc_idx = locateval(loc_idx,1,id_values->surgeon_cnt,cnvtupper(surgeon_disp),id_values->
      surgeons[loc_idx].surgeon_username)
    ENDIF
    IF (loc_idx=0)
     id_values->surgeon_cnt = (id_values->surgeon_cnt+ 1)
     IF (mod(id_values->surgeon_cnt,exp_size)=1)
      stat = alterlist(id_values->surgeons,((id_values->surgeon_cnt+ exp_size) - 1))
     ENDIF
     id_values->surgeons[id_values->surgeon_cnt].surgeon_username = build->rpts[build->rpt_cnt].
     filter_groups[group_idx].filters[filter_idx].filter_disp
    ENDIF
   ENDIF
   IF (textlen(trim(room_disp,3)) > 0)
    filter_idx = (filter_idx+ 1)
    IF (mod(filter_idx,10)=1)
     stat = alterlist(build->rpts[build->rpt_cnt].filter_groups[group_idx].filters,(filter_idx+ 9))
    ENDIF
    build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[filter_idx].filter_disp = cnvtupper(
     cnvtalphanum(room_disp)), build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[
    filter_idx].filter_disp_orig = room_disp, build->rpts[build->rpt_cnt].filter_groups[group_idx].
    filters[filter_idx].filter_ref_id = filter_ref_or_room,
    loc_idx = 0
    IF ((id_values->room_cnt > 0))
     loc_idx = locateval(loc_idx,1,id_values->room_cnt,room_disp,id_values->rooms[loc_idx].room_disp)
    ENDIF
    IF (loc_idx=0)
     id_values->room_cnt = (id_values->room_cnt+ 1)
     IF (mod(id_values->room_cnt,exp_size)=1)
      stat = alterlist(id_values->rooms,((id_values->room_cnt+ exp_size) - 1))
     ENDIF
     id_values->rooms[id_values->room_cnt].room_disp = build->rpts[build->rpt_cnt].filter_groups[
     group_idx].filters[filter_idx].filter_disp
    ENDIF
   ENDIF
  FOOT  filter_group_disp
   filter_idx = (filter_idx+ 1)
   IF (mod(filter_idx,10)=1)
    stat = alterlist(build->rpts[build->rpt_cnt].filter_groups[group_idx].filters,(filter_idx+ 9))
   ENDIF
   build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[filter_idx].filter_disp_orig =
   "Non-Canceled Cases", build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[filter_idx].
   filter_ref_id = filter_ref_noncancel, build->rpts[build->rpt_cnt].filter_groups[group_idx].
   filters[filter_idx].filter_string = "1",
   build->rpts[build->rpt_cnt].filter_groups[group_idx].filters[filter_idx].action_flag = insert_flag,
   stat = alterlist(build->rpts[build->rpt_cnt].filter_groups[group_idx].filters,filter_idx), build->
   rpts[build->rpt_cnt].filter_groups[group_idx].filter_cnt = filter_idx
  FOOT  report_name_disp
   build->rpts[build->rpt_cnt].filter_group_cnt = group_idx, stat = alterlist(build->rpts[build->
    rpt_cnt].filter_groups,group_idx)
  FOOT REPORT
   FOR (rpt_idx = (build->rpt_cnt+ 1) TO size(build->rpts,5))
     build->rpts[rpt_idx].rpt_disp = build->rpts[build->rpt_cnt].rpt_disp
   ENDFOR
   FOR (filter_idx = (id_values->surgeon_cnt+ 1) TO size(id_values->surgeons,5))
     id_values->surgeons[filter_idx].surgeon_username = id_values->surgeons[id_values->surgeon_cnt].
     surgeon_username
   ENDFOR
   FOR (filter_idx = (id_values->room_cnt+ 1) TO size(id_values->rooms,5))
     id_values->rooms[filter_idx].room_disp = id_values->rooms[id_values->room_cnt].room_disp
   ENDFOR
  WITH nocounter
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
    build->rpts[rpt_idx].rpt_id = r.rpt_id
    IF ((reqinfo->updt_id > 0))
     build->rpts[rpt_idx].owner_id = reqinfo->updt_id
    ELSE
     build->rpts[rpt_idx].owner_id = r.owner_id
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(build->rpts,build->rpt_cnt)
  WITH nocounter, nullreport
 ;end select
 IF (checkerror(failure,"SELECT",failure,"REPORT VALIDATE") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->surgeon_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((id_values->surgeon_cnt - 1)/ exp_size)))),
    prsnl p
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (p
    WHERE parser(concat(exp_base,"p.username, id_values->surgeons[exp_idx].surgeon_username)"))
     AND p.active_ind=1
     AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    filter_idx = locateval(filter_idx,1,id_values->surgeon_cnt,p.username,id_values->surgeons[
     filter_idx].surgeon_username)
    IF (filter_idx > 0)
     id_values->surgeons[filter_idx].person_id = p.person_id
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->surgeons,id_values->surgeon_cnt)
   WITH nocounter, nullreport
  ;end select
  IF (checkerror(failure,"SELECT",failure,"SURGEON VALIDATE") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((id_values->room_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((id_values->room_cnt - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->rooms[exp_idx].room_disp)"))
     AND ((c.code_set+ 0)=221)
     AND c.cdf_meaning="SURGOP"
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    filter_idx = locateval(filter_idx,1,id_values->room_cnt,c.display_key,id_values->rooms[filter_idx
     ].room_disp)
    IF (filter_idx > 0)
     id_values->rooms[filter_idx].service_resource_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->rooms,id_values->room_cnt)
   WITH nocounter, nullreport
  ;end select
  IF (checkerror(failure,"SELECT",failure,"ROOM VALIDATE") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (rpt_idx = 1 TO build->rpt_cnt)
   IF ((build->rpts[rpt_idx].rpt_id <= 0))
    CALL failrow(rpt_idx,0,0,"Invalid display value from sn_rpt.")
   ENDIF
   IF ((build->rpts[rpt_idx].owner_id <= 0))
    CALL failrow(rpt_idx,0,0,"Report has no owner assigned.")
   ENDIF
   FOR (group_idx = 1 TO build->rpts[rpt_idx].filter_group_cnt)
    IF (textlen(trim(build->rpts[rpt_idx].filter_groups[group_idx].filter_group_disp,3))=0)
     CALL failrow(rpt_idx,group_idx,0,"Filter Group name is required.")
    ELSEIF ((build->rpts[rpt_idx].action_flag != fail_action))
     SET loc_idx = 0
     IF ((id_values->filter_group_cnt > 0))
      SET loc_idx = locateval(loc_idx,1,id_values->filter_group_cnt,build->rpts[rpt_idx].rpt_id,
       id_values->filter_groups[loc_idx].rpt_id,
       build->rpts[rpt_idx].filter_groups[group_idx].filter_group_disp,id_values->filter_groups[
       loc_idx].filter_group_disp)
     ENDIF
     IF (loc_idx=0)
      SET id_values->filter_group_cnt = (id_values->filter_group_cnt+ 1)
      IF (mod(id_values->filter_group_cnt,exp_size)=1)
       SET stat = alterlist(id_values->filter_groups,((id_values->filter_group_cnt+ exp_size) - 1))
      ENDIF
      SET id_values->filter_groups[id_values->filter_group_cnt].rpt_id = build->rpts[rpt_idx].rpt_id
      SET id_values->filter_groups[id_values->filter_group_cnt].type_flag = fg_type_flag
      SET id_values->filter_groups[id_values->filter_group_cnt].filter_group_disp = build->rpts[
      rpt_idx].filter_groups[group_idx].filter_group_disp
     ENDIF
    ENDIF
    FOR (filter_idx = 1 TO build->rpts[rpt_idx].filter_groups[group_idx].filter_cnt)
      IF ((build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].filter_ref_id=
      filter_ref_surgeon))
       SET loc_idx = locateval(loc_idx,1,id_values->surgeon_cnt,build->rpts[rpt_idx].filter_groups[
        group_idx].filters[filter_idx].filter_disp,id_values->surgeons[loc_idx].surgeon_username)
       IF (loc_idx > 0)
        SET build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].parent_entity_id =
        id_values->surgeons[loc_idx].person_id
       ENDIF
       IF (((loc_idx <= 0) OR ((build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].
       parent_entity_id <= 0))) )
        CALL failrow(rpt_idx,group_idx,filter_idx,"Invalid surgeon username for prsnl.")
       ELSE
        SET build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].action_flag =
        insert_action
       ENDIF
      ELSEIF ((build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].filter_ref_id=
      filter_ref_or_room))
       SET loc_idx = locateval(loc_idx,1,id_values->room_cnt,build->rpts[rpt_idx].filter_groups[
        group_idx].filters[filter_idx].filter_disp,id_values->rooms[loc_idx].room_disp)
       IF (loc_idx > 0)
        SET build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].parent_entity_id =
        id_values->rooms[loc_idx].service_resource_cd
       ENDIF
       IF (((loc_idx <= 0) OR ((build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].
       parent_entity_id <= 0))) )
        CALL failrow(rpt_idx,group_idx,filter_idx,"Invalid room display value for codeset 220.")
       ELSE
        SET build->rpts[rpt_idx].filter_groups[group_idx].filters[filter_idx].action_flag =
        insert_action
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
   IF ((build->rpts[rpt_idx].action_flag != fail_action))
    SET build->rpts[rpt_idx].action_flag = update_action
   ENDIF
 ENDFOR
 IF ((id_values->filter_group_cnt > 0))
  FOR (group_idx = (id_values->filter_group_cnt+ 1) TO size(id_values->filter_groups,5))
    SET id_values->filter_groups[group_idx].rpt_id = id_values->filter_groups[id_values->
    filter_group_cnt].rpt_id
    SET id_values->filter_groups[group_idx].type_flag = id_values->filter_groups[id_values->
    filter_group_cnt].type_flag
    SET id_values->filter_groups[group_idx].filter_group_disp = id_values->filter_groups[id_values->
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
     group_idx = locateval(group_idx,1,build->rpts[rpt_idx].filter_group_cnt,fg.display,build->rpts[
      rpt_idx].filter_groups[group_idx].filter_group_disp)
     IF (group_idx > 0)
      build->rpts[rpt_idx].filter_groups[group_idx].filter_group_id = fg.rpt_filter_grp_id
      IF ((build->rpts[rpt_idx].filter_groups[group_idx].action_flag != fail_action))
       build->rpts[rpt_idx].filter_groups[group_idx].action_flag = update_action
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    FOR (rpt_idx = 1 TO build->rpt_cnt)
      group_idx = 0, group_idx = locateval(loc_idx,(group_idx+ 1),build->rpts[rpt_idx].
       filter_group_cnt,0,build->rpts[rpt_idx].filter_groups[loc_idx].action_flag)
      WHILE (group_idx > 0)
       build->rpts[rpt_idx].filter_groups[group_idx].action_flag = insert_action,group_idx =
       locateval(loc_idx,(group_idx+ 1),build->rpts[rpt_idx].filter_group_cnt,0,build->rpts[rpt_idx].
        filter_groups[loc_idx].action_flag)
      ENDWHILE
    ENDFOR
    stat = alterlist(id_values->filter_groups,id_values->filter_group_cnt)
   WITH nocounter, nullreport
  ;end select
  IF (checkerror(failure,"SELECT",failure,"FILTER GROUP VALIDATE") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (insert_flag > 0)
  FOR (rpt_idx = 1 TO build->rpt_cnt)
    FOR (group_idx = 1 TO build->rpts[rpt_idx].filter_group_cnt)
      IF ((build->rpts[rpt_idx].filter_groups[group_idx].action_flag=insert_action))
       SELECT INTO "nl:"
        new_id = seq(surgery_seq,nextval)
        FROM dual
        DETAIL
         build->rpts[rpt_idx].filter_groups[group_idx].filter_group_id = new_id
        WITH nocounter
       ;end select
       IF (checkerror(failure,"SELECT",failure,"FILTER GROUP SEQUENCE") > 0)
        GO TO exit_script
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  INSERT  FROM (dummyt d1  WITH seq = value(build->rpt_cnt)),
    (dummyt d2  WITH seq = value(1)),
    sn_rpt_filter_grp fg
   SET fg.rpt_filter_grp_id = build->rpts[d1.seq].filter_groups[d2.seq].filter_group_id, fg.rpt_id =
    build->rpts[d1.seq].rpt_id, fg.display = build->rpts[d1.seq].filter_groups[d2.seq].
    filter_group_disp,
    fg.type_flag = fg_type_flag, fg.owner_id = build->rpts[d1.seq].owner_id, fg.dir_name = "cer_temp",
    fg.file_name = "", fg.file_format = 0, fg.append_ind = 0,
    fg.page_break_ind = 1, fg.updt_cnt = 0, fg.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    fg.updt_id = reqinfo->updt_id, fg.updt_task = reqinfo->updt_task, fg.updt_applctx = reqinfo->
    updt_applctx,
    fg.create_dt_tm = cnvtdatetime(curdate,curtime3), fg.create_prsnl_id = reqinfo->updt_id, fg
    .create_task = reqinfo->updt_task,
    fg.create_applctx = reqinfo->updt_applctx
   PLAN (d1
    WHERE (build->rpts[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->rpts[d1.seq].filter_group_cnt))
    JOIN (d2
    WHERE (build->rpts[d1.seq].filter_groups[d2.seq].action_flag=insert_action))
    JOIN (fg)
   WITH nocounter, status(build->rpts[d1.seq].filter_groups[d2.seq].status_flag)
  ;end insert
  CALL checkstatus(insert_action,0)
  IF (checkerror(failure,"INSERT",failure,"SN_RPT_FILTER_GRP") > 0)
   GO TO exit_script
  ENDIF
  UPDATE  FROM (dummyt d1  WITH seq = value(build->rpt_cnt)),
    (dummyt d2  WITH seq = value(1)),
    sn_rpt_filter_grp fg
   SET fg.updt_cnt = (fg.updt_cnt+ 1), fg.updt_dt_tm = cnvtdatetime(curdate,curtime3), fg.updt_id =
    reqinfo->updt_id,
    fg.updt_task = reqinfo->updt_task, fg.updt_applctx = reqinfo->updt_applctx
   PLAN (d1
    WHERE (build->rpts[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->rpts[d1.seq].filter_group_cnt))
    JOIN (d2
    WHERE (build->rpts[d1.seq].filter_groups[d2.seq].action_flag=update_action))
    JOIN (fg
    WHERE (fg.rpt_filter_grp_id=build->rpts[d1.seq].filter_groups[d2.seq].filter_group_id))
   WITH nocounter, status(build->rpts[d1.seq].filter_groups[d2.seq].status_flag)
  ;end update
  CALL checkstatus(update_action,0)
  IF (checkerror(failure,"UPDATE",failure,"SN_RPT_FILTER_GRP") > 0)
   GO TO exit_script
  ENDIF
  DELETE  FROM (dummyt d1  WITH seq = value(build->rpt_cnt)),
    (dummyt d2  WITH seq = value(1)),
    sn_rpt_filter f
   SET f.seq = 1
   PLAN (d1
    WHERE (build->rpts[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->rpts[d1.seq].filter_group_cnt))
    JOIN (d2
    WHERE (build->rpts[d1.seq].filter_groups[d2.seq].action_flag=update_action))
    JOIN (f
    WHERE (f.rpt_filter_grp_id=build->rpts[d1.seq].filter_groups[d2.seq].filter_group_id))
   WITH nocounter, status(build->rpts[d1.seq].filter_groups[d2.seq].status_flag)
  ;end delete
  CALL checkstatus(update_action,0)
  IF (checkerror(failure,"DELETE",failure,"SN_RPT_FILTER") > 0)
   GO TO exit_script
  ENDIF
  INSERT  FROM (dummyt d1  WITH seq = value(build->rpt_cnt)),
    (dummyt d2  WITH seq = value(1)),
    (dummyt d3  WITH seq = value(1)),
    sn_rpt_filter f
   SET f.rpt_filter_grp_id = build->rpts[d1.seq].filter_groups[d2.seq].filter_group_id, f
    .rpt_filter_id = seq(surgery_seq,nextval), f.rpt_filter_ref_id = build->rpts[d1.seq].
    filter_groups[d2.seq].filters[d3.seq].filter_ref_id,
    f.filter_string = build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_string, f
    .parent_entity_id = build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].parent_entity_id, f
    .parent_entity_name =
    IF ((build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_ref_id=filter_ref_surgeon))
      "PRSNL"
    ELSEIF ((build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_ref_id=
    filter_ref_or_room)) "SERVICE_RESOURCE"
    ENDIF
    ,
    f.create_dt_tm = cnvtdatetime(curdate,curtime3), f.create_prsnl_id = reqinfo->updt_id, f
    .create_task = reqinfo->updt_task,
    f.create_applctx = reqinfo->updt_applctx, f.updt_cnt = 0, f.updt_dt_tm = cnvtdatetime(curdate,
     curtime3),
    f.updt_id = reqinfo->updt_id, f.updt_task = reqinfo->updt_task, f.updt_applctx = reqinfo->
    updt_applctx
   PLAN (d1
    WHERE (build->rpts[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->rpts[d1.seq].filter_group_cnt))
    JOIN (d2
    WHERE (build->rpts[d1.seq].filter_groups[d2.seq].action_flag != fail_action)
     AND maxrec(d3,build->rpts[d1.seq].filter_groups[d2.seq].filter_cnt))
    JOIN (d3
    WHERE (build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].action_flag=insert_action))
    JOIN (f)
   WITH nocounter, status(build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].status_flag)
  ;end insert
  CALL checkstatus(insert_action,1)
  IF (checkerror(failure,"INSERT",failure,"SN_RPT_FILTER") > 0)
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
   substring(1,100,build->rpts[d1.seq].filter_groups[d2.seq].filter_group_disp),3), surgeon_disp =
  IF ((build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_ref_id=filter_ref_surgeon))
   trim(substring(1,100,build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_disp_orig),3
    )
  ELSE ""
  ENDIF
  ,
  room_disp =
  IF ((build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_ref_id=filter_ref_or_room))
   trim(substring(1,100,build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_disp_orig),3
    )
  ELSE ""
  ENDIF
  FROM (dummyt d1  WITH seq = value(build->rpt_cnt)),
   (dummyt d2  WITH seq = value(1)),
   (dummyt d3  WITH seq = value(1))
  PLAN (d1
   WHERE maxrec(d2,build->rpts[d1.seq].filter_group_cnt))
   JOIN (d2
   WHERE maxrec(d3,build->rpts[d1.seq].filter_groups[d2.seq].filter_cnt)
    AND d2.seq > 0)
   JOIN (d3
   WHERE (build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].filter_ref_id !=
   filter_ref_noncancel)
    AND d3.seq > 0)
  ORDER BY rpt_disp, filter_group_disp
  HEAD REPORT
   col_count = 0, col_rpt_disp = (col_count+ 5), col_rpt_error = (col_rpt_disp+ 5),
   col_fg_disp = (col_rpt_disp+ 5), col_surg_disp = (col_fg_disp+ 5), col_room_disp = (col_surg_disp
   + 40),
   col_action = (col_room_disp+ 40), col_error = (col_action+ 10), row_cnt = 0,
   loop_cnt = 0, action_disp = fillstring(10,""), line = fillstring(value(120),"-"),
   col 0, "SURGINET REPORT FILTERS IMPORT", row + 1,
   col 0, "RUN DATE: ", col 11,
   begin_date"@MEDIUMDATETIME", row + 1, row + 1
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
   "Filter Group", row + 1, col col_surg_disp,
   "Surgeon", col col_room_disp, "Room",
   col col_action, "Action", row + 1,
   col 0, line, row + 1
  HEAD rpt_disp
   row_cnt = (row_cnt+ 1), action_disp = evaluate(build->rpts[d1.seq].action_flag,fail_action,"FAIL",
    evaluate(insert_flag,0,"VERIFIED","UPLOADED")), col col_count,
   row_cnt"###;r;i", col col_rpt_disp, rpt_disp,
   col col_action, action_disp
   IF (textlen(trim(build->rpts[d1.seq].error_msg,3)) > 0)
    col col_error, build->rpts[d1.seq].error_msg
   ENDIF
   row + 1
  HEAD filter_group_disp
   row_cnt = (row_cnt+ 1), action_disp = evaluate(build->rpts[d1.seq].filter_groups[d2.seq].
    action_flag,fail_action,"FAIL",evaluate(build->rpts[d1.seq].action_flag,fail_action,"NO ACTION",
     evaluate(insert_flag,0,"VERIFIED",evaluate(build->rpts[d1.seq].filter_groups[d2.seq].action_flag,
       insert_action,"INSERTED",update_action,"UPDATED")))), col col_count,
   row_cnt"###;r;i", col col_fg_disp, filter_group_disp,
   col col_action, action_disp
   IF (textlen(trim(build->rpts[d1.seq].filter_groups[d2.seq].error_msg,3)) > 0)
    col col_error, build->rpts[d1.seq].filter_groups[d2.seq].error_msg
   ENDIF
   row + 1
  DETAIL
   row_cnt = (row_cnt+ 1), action_disp = evaluate(build->rpts[d1.seq].filter_groups[d2.seq].filters[
    d3.seq].action_flag,fail_action,"FAIL",evaluate(build->rpts[d1.seq].filter_groups[d2.seq].
     action_flag,fail_action,"NO ACTION",evaluate(insert_flag,0,"VERIFIED",evaluate(build->rpts[d1
       .seq].filter_groups[d2.seq].filters[d3.seq].action_flag,insert_action,"INSERTED",update_action,
       "UPDATED")))), col col_count,
   row_cnt"###;r;i", col col_surg_disp, surgeon_disp,
   col col_room_disp, room_disp, col col_action,
   action_disp
   IF (textlen(trim(build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].error_msg,3)) > 0)
    col col_error, build->rpts[d1.seq].filter_groups[d2.seq].filters[d3.seq].error_msg
   ENDIF
   row + 1
  FOOT  rpt_disp
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
