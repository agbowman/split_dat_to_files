CREATE PROGRAM bed_imp_req_routing:dba
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
 IF (validate(build->output_routes)=0)
  FREE RECORD build
  RECORD build(
    1 output_route_cnt = i4
    1 output_routes[*]
      2 route_id = f8
      2 route_desc = vc
      2 route_type = vc
      2 route_type_flag = i2
      2 action_flag = i2
      2 error_msg = vc
      2 status_flag = i2
      2 param_cnt = i4
      2 param1_cd = f8
      2 param1_disp = vc
      2 param2_cd = f8
      2 param2_disp = vc
      2 param3_cd = f8
      2 param3_disp = vc
      2 flex_rtg_cnt = i4
      2 flex_rtgs[*]
        3 rtg_id = f8
        3 action_flag = i2
        3 error_msg = vc
        3 status_flag = i2
        3 value1_cd = f8
        3 value1_disp = vc
        3 value1_disp_orig = vc
        3 value2_cd = f8
        3 value2_disp = vc
        3 value2_disp_orig = vc
        3 value3_cd = f8
        3 value3_disp = vc
        3 value3_disp_orig = vc
        3 flex_printer_id = f8
        3 printer_name = vc
        3 num_of_copies = i4
  )
 ENDIF
 FREE RECORD id_values
 RECORD id_values(
   1 facility_cnt = i4
   1 facility[*]
     2 facility_disp = vc
     2 facility_cd = f8
   1 pattype_cnt = i4
   1 pattype[*]
     2 pattype_disp = vc
     2 pattype_cd = f8
   1 subtype_cnt = i4
   1 subtype[*]
     2 subtype_disp = vc
     2 subtype_cd = f8
   1 patloc_cnt = i4
   1 patloc[*]
     2 patloc_disp = vc
     2 patloc_cd = f8
   1 v_facility_cnt = i4
   1 v_facility[*]
     2 v_facility_disp = vc
     2 v_facility_cd = f8
   1 v_pattype_cnt = i4
   1 v_pattype[*]
     2 v_pattype_disp = vc
     2 v_pattype_cd = f8
   1 v_subtype_cnt = i4
   1 v_subtype[*]
     2 v_subtype_disp = vc
     2 v_subtype_cd = f8
   1 v_patloc_cnt = i4
   1 v_patloc[*]
     2 v_patloc_disp = vc
     2 v_patloc_cd = f8
 )
 DECLARE failrow(a_idx=i4,l_idx=i4,error_msg=vc) = null
 DECLARE generrormsg(error_msg1=vc,error_msg2=vc) = vc
 DECLARE checkstatus(check_action=i2) = null
 SUBROUTINE failrow(a_idx,l_idx,error_msg)
  DECLARE l_cnt = i4 WITH private, noconstant(0)
  IF (a_idx > 0)
   SET build->output_routes[a_idx].action_flag = fail_action
   IF (l_idx <= 0)
    SET build->output_routes[a_idx].error_msg = generrormsg(build->output_routes[a_idx].error_msg,
     error_msg)
    FOR (l_cnt = 1 TO build->output_routes[a_idx].flex_rtg_cnt)
      SET build->output_routes[a_idx].flex_rtgs[l_cnt].action_flag = fail_action
    ENDFOR
   ELSE
    SET build->output_routes[a_idx].flex_rtgs[l_idx].action_flag = fail_action
    SET build->output_routes[a_idx].flex_rtgs[l_idx].error_msg = generrormsg(build->output_routes[
     a_idx].flex_rtgs[l_idx].error_msg,error_msg)
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
    FOR (a_idx = 1 TO build->output_route_cnt)
      IF ((build->output_routes[a_idx].action_flag != fail_action))
       SET l_idx = 0
       SET l_idx = locateval(l_cnt,(l_idx+ 1),build->output_routes[a_idx].flex_rtg_cnt,0,build->
        output_routes[a_idx].flex_rtgs[l_cnt].status_flag,
        check_action,build->output_routes[a_idx].flex_rtgs[l_cnt].action_flag)
       WHILE (l_idx > 0)
        CALL failrow(a_idx,l_idx,concat("Failed ",evaluate(build->output_routes[a_idx].flex_rtgs[
           l_idx].action_flag,insert_action,"inserting",update_action,"updating"),
          " relationship in the database."))
        SET l_idx = locateval(l_cnt,(l_idx+ 1),build->output_routes[a_idx].flex_rtg_cnt,0,build->
         output_routes[a_idx].flex_rtgs[l_cnt].status_flag,
         check_action,build->output_routes[a_idx].flex_rtgs[l_cnt].action_flag)
       ENDWHILE
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
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
 DECLARE log_file = vc WITH protect, constant("ccluserdir:bed_req_routing.log")
 DECLARE insert_flag = i2 WITH protect, noconstant(0)
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE exp_start = i4 WITH protect, noconstant(1)
 DECLARE par_idx = i4 WITH protect, noconstant(0)
 DECLARE loop_cnt = i4 WITH protect, noconstant(0)
 DECLARE new_nbr = f8 WITH noconstant(0.0)
 IF (validate(tempreq) > 0)
  IF (cnvtupper(trim(tempreq->insert_ind,3))="Y")
   SET insert_flag = 1
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  route_type_disp = cnvtupper(cnvtalphanum(substring(1,100,requestin->list_0[d.seq].route_type))),
  route_name_disp = trim(substring(1,100,requestin->list_0[d.seq].route_name),3), facility_disp =
  cnvtupper(cnvtalphanum(substring(1,100,requestin->list_0[d.seq].facility))),
  patient_type_disp = cnvtupper(cnvtalphanum(substring(1,100,requestin->list_0[d.seq].patient_type))),
  sub_activity_type_disp = cnvtupper(cnvtalphanum(substring(1,100,requestin->list_0[d.seq].
     sub_activity_type))), patient_location_disp = cnvtupper(cnvtalphanum(substring(1,100,requestin->
     list_0[d.seq].patient_location))),
  printer_name_disp = cnvtupper(substring(1,100,requestin->list_0[d.seq].printer_name)),
  num_of_copies = cnvtint(requestin->list_0[d.seq].num_of_copies)
  FROM (dummyt d  WITH seq = value(input_cnt))
  ORDER BY route_name_disp
  HEAD route_name_disp
   build->output_route_cnt = (build->output_route_cnt+ 1)
   IF (mod(build->output_route_cnt,exp_size)=1)
    stat = alterlist(build->output_routes,((build->output_route_cnt+ exp_size) - 1))
   ENDIF
   build->output_routes[build->output_route_cnt].route_desc = route_name_disp, build->output_routes[
   build->output_route_cnt].route_type = route_type_disp
   IF (route_type_disp="RAD")
    build->output_routes[build->output_route_cnt].param_cnt = 3
   ELSE
    build->output_routes[build->output_route_cnt].param_cnt = 1
   ENDIF
  DETAIL
   build->output_routes[build->output_route_cnt].flex_rtg_cnt = (build->output_routes[build->
   output_route_cnt].flex_rtg_cnt+ 1)
   IF (mod(build->output_routes[build->output_route_cnt].flex_rtg_cnt,10)=1)
    stat = alterlist(build->output_routes[build->output_route_cnt].flex_rtgs,(build->output_routes[
     build->output_route_cnt].flex_rtg_cnt+ 9))
   ENDIF
   build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->
   output_route_cnt].flex_rtg_cnt].printer_name = printer_name_disp, build->output_routes[build->
   output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt].
   num_of_copies = num_of_copies
   IF (route_type_disp="RAD")
    build->output_routes[build->output_route_cnt].param1_disp = "PATIENTFACILITY", build->
    output_routes[build->output_route_cnt].param2_disp = "PATIENTTYPE", build->output_routes[build->
    output_route_cnt].param3_disp = "ACTIVITYSUBTYPE",
    build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->
    output_route_cnt].flex_rtg_cnt].value1_disp = facility_disp, build->output_routes[build->
    output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt].
    value2_disp = patient_type_disp, build->output_routes[build->output_route_cnt].flex_rtgs[build->
    output_routes[build->output_route_cnt].flex_rtg_cnt].value3_disp = sub_activity_type_disp,
    build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->
    output_route_cnt].flex_rtg_cnt].value1_disp_orig = requestin->list_0[d.seq].facility, build->
    output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].
    flex_rtg_cnt].value2_disp_orig = requestin->list_0[d.seq].patient_type, build->output_routes[
    build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt].
    value3_disp_orig = requestin->list_0[d.seq].sub_activity_type,
    par_idx = 0
    IF ((id_values->facility_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->facility_cnt,"PATIENTFACILITY",id_values->facility[
      par_idx].facility_disp)
    ENDIF
    IF (par_idx=0)
     id_values->facility_cnt = (id_values->facility_cnt+ 1)
     IF (mod(id_values->facility_cnt,exp_size)=1)
      stat = alterlist(id_values->facility,((id_values->facility_cnt+ exp_size) - 1))
     ENDIF
     id_values->facility[id_values->facility_cnt].facility_disp = "PATIENTFACILITY"
    ENDIF
    par_idx = 0
    IF ((id_values->pattype_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->pattype_cnt,"PATIENTTYPE",id_values->pattype[par_idx].
      pattype_disp)
    ENDIF
    IF (par_idx=0)
     id_values->pattype_cnt = (id_values->pattype_cnt+ 1)
     IF (mod(id_values->pattype_cnt,exp_size)=1)
      stat = alterlist(id_values->pattype,((id_values->pattype_cnt+ exp_size) - 1))
     ENDIF
     id_values->pattype[id_values->pattype_cnt].pattype_disp = "PATIENTTYPE"
    ENDIF
    par_idx = 0
    IF ((id_values->subtype_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->subtype_cnt,"ACTIVITYSUBTYPE",id_values->subtype[
      par_idx].subtype_disp)
    ENDIF
    IF (par_idx=0)
     id_values->subtype_cnt = (id_values->subtype_cnt+ 1)
     IF (mod(id_values->subtype_cnt,exp_size)=1)
      stat = alterlist(id_values->subtype,((id_values->subtype_cnt+ exp_size) - 1))
     ENDIF
     id_values->subtype[id_values->subtype_cnt].subtype_disp = "ACTIVITYSUBTYPE"
    ENDIF
    par_idx = 0
    IF ((id_values->v_facility_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->v_facility_cnt,facility_disp,id_values->v_facility[
      par_idx].v_facility_disp)
    ENDIF
    IF (par_idx=0)
     id_values->v_facility_cnt = (id_values->v_facility_cnt+ 1)
     IF (mod(id_values->v_facility_cnt,exp_size)=1)
      stat = alterlist(id_values->v_facility,((id_values->v_facility_cnt+ exp_size) - 1))
     ENDIF
     id_values->v_facility[id_values->v_facility_cnt].v_facility_disp = facility_disp
    ENDIF
    par_idx = 0
    IF ((id_values->v_pattype_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->v_pattype_cnt,patient_type_disp,id_values->v_pattype[
      par_idx].v_pattype_disp)
    ENDIF
    IF (par_idx=0)
     id_values->v_pattype_cnt = (id_values->v_pattype_cnt+ 1)
     IF (mod(id_values->v_pattype_cnt,exp_size)=1)
      stat = alterlist(id_values->v_pattype,((id_values->v_pattype_cnt+ exp_size) - 1))
     ENDIF
     id_values->v_pattype[id_values->v_pattype_cnt].v_pattype_disp = patient_type_disp
    ENDIF
    par_idx = 0
    IF ((id_values->v_subtype_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->v_subtype_cnt,sub_activity_type_disp,id_values->
      v_subtype[par_idx].v_subtype_disp)
    ENDIF
    IF (par_idx=0)
     id_values->v_subtype_cnt = (id_values->v_subtype_cnt+ 1)
     IF (mod(id_values->v_subtype_cnt,exp_size)=1)
      stat = alterlist(id_values->v_subtype,((id_values->v_subtype_cnt+ exp_size) - 1))
     ENDIF
     id_values->v_subtype[id_values->v_subtype_cnt].v_subtype_disp = sub_activity_type_disp
    ENDIF
   ELSEIF (route_type_disp="TRANSPORT")
    build->output_routes[build->output_route_cnt].param1_disp = "PATIENTFACILITY", build->
    output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].
    flex_rtg_cnt].value1_disp = facility_disp, build->output_routes[build->output_route_cnt].
    flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt].value1_disp_orig =
    requestin->list_0[d.seq].facility,
    par_idx = 0
    IF ((id_values->facility_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->facility_cnt,"PATIENTFACILITY",id_values->facility[
      par_idx].facility_disp)
    ENDIF
    IF (par_idx=0)
     id_values->facility_cnt = (id_values->facility_cnt+ 1)
     IF (mod(id_values->facility_cnt,exp_size)=1)
      stat = alterlist(id_values->facility,((id_values->facility_cnt+ exp_size) - 1))
     ENDIF
     id_values->facility[id_values->facility_cnt].facility_disp = "PATIENTFACILITY"
    ENDIF
    par_idx = 0
    IF ((id_values->v_facility_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->v_facility_cnt,facility_disp,id_values->v_facility[
      par_idx].v_facility_disp)
    ENDIF
    IF (par_idx=0)
     id_values->v_facility_cnt = (id_values->v_facility_cnt+ 1)
     IF (mod(id_values->v_facility_cnt,exp_size)=1)
      stat = alterlist(id_values->v_facility,((id_values->v_facility_cnt+ exp_size) - 1))
     ENDIF
     id_values->v_facility[id_values->v_facility_cnt].v_facility_disp = facility_disp
    ENDIF
   ELSE
    build->output_routes[build->output_route_cnt].param1_disp = "PATIENTLOCATION", build->
    output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].
    flex_rtg_cnt].value1_disp = patient_location_disp, build->output_routes[build->output_route_cnt].
    flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt].value1_disp_orig =
    requestin->list_0[d.seq].patient_location,
    par_idx = 0
    IF ((id_values->patloc_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->patloc_cnt,"PATIENTLOCATION",id_values->patloc[par_idx]
      .patloc_disp)
    ENDIF
    IF (par_idx=0)
     id_values->patloc_cnt = (id_values->patloc_cnt+ 1)
     IF (mod(id_values->patloc_cnt,exp_size)=1)
      stat = alterlist(id_values->patloc,((id_values->patloc_cnt+ exp_size) - 1))
     ENDIF
     id_values->patloc[id_values->patloc_cnt].patloc_disp = "PATIENTLOCATION"
    ENDIF
    par_idx = 0
    IF ((id_values->v_patloc_cnt > 0))
     par_idx = locateval(par_idx,1,id_values->v_patloc_cnt,patient_location_disp,id_values->v_patloc[
      par_idx].v_patloc_disp)
    ENDIF
    IF (par_idx=0)
     id_values->v_patloc_cnt = (id_values->v_patloc_cnt+ 1)
     IF (mod(id_values->v_patloc_cnt,exp_size)=1)
      stat = alterlist(id_values->v_patloc,((id_values->v_patloc_cnt+ exp_size) - 1))
     ENDIF
     id_values->v_patloc[id_values->v_patloc_cnt].v_patloc_disp = patient_location_disp
    ENDIF
   ENDIF
  FOOT  route_name_disp
   stat = alterlist(build->output_routes[build->output_route_cnt].flex_rtgs,build->output_routes[
    build->output_route_cnt].flex_rtg_cnt)
  FOOT REPORT
   FOR (loop_cnt = (build->output_route_cnt+ 1) TO size(build->output_routes,5))
     build->output_routes[loop_cnt].param1_disp = build->output_routes[build->output_route_cnt].
     param1_disp, build->output_routes[loop_cnt].param2_disp = build->output_routes[build->
     output_route_cnt].param2_disp, build->output_routes[loop_cnt].param3_disp = build->
     output_routes[build->output_route_cnt].param3_disp
   ENDFOR
   FOR (loop_cnt = (id_values->facility_cnt+ 1) TO size(id_values->facility,5))
     id_values->facility[loop_cnt].facility_disp = id_values->facility[id_values->facility_cnt].
     facility_disp
   ENDFOR
   FOR (loop_cnt = (id_values->pattype_cnt+ 1) TO size(id_values->pattype,5))
     id_values->pattype[loop_cnt].pattype_disp = id_values->pattype[id_values->pattype_cnt].
     pattype_disp
   ENDFOR
   FOR (loop_cnt = (id_values->subtype_cnt+ 1) TO size(id_values->subtype,5))
     id_values->subtype[loop_cnt].subtype_disp = id_values->subtype[id_values->subtype_cnt].
     subtype_disp
   ENDFOR
   FOR (loop_cnt = (id_values->patloc_cnt+ 1) TO size(id_values->patloc,5))
     id_values->patloc[loop_cnt].patloc_disp = id_values->patloc[id_values->patloc_cnt].patloc_disp
   ENDFOR
   FOR (loop_cnt = (id_values->v_facility_cnt+ 1) TO size(id_values->v_facility,5))
     id_values->v_facility[loop_cnt].v_facility_disp = id_values->v_facility[id_values->
     v_facility_cnt].v_facility_disp
   ENDFOR
   FOR (loop_cnt = (id_values->v_pattype_cnt+ 1) TO size(id_values->v_pattype,5))
     id_values->v_pattype[loop_cnt].v_pattype_disp = id_values->v_pattype[id_values->v_pattype_cnt].
     v_pattype_disp
   ENDFOR
   FOR (loop_cnt = (id_values->v_subtype_cnt+ 1) TO size(id_values->v_subtype,5))
     id_values->v_subtype[loop_cnt].v_subtype_disp = id_values->v_subtype[id_values->v_subtype_cnt].
     v_subtype_disp
   ENDFOR
   FOR (loop_cnt = (id_values->v_patloc_cnt+ 1) TO size(id_values->v_patloc,5))
     id_values->v_patloc[loop_cnt].v_patloc_disp = id_values->v_patloc[id_values->v_patloc_cnt].
     v_patloc_disp
   ENDFOR
  WITH nocounter
 ;end select
 IF (checkerror(failure,"SELECT",failure,"DATA LOAD") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->facility_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->facility,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->facility[exp_idx].facility_disp)"))
     AND c.code_set=6007
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->facility_cnt,c.display_key,id_values->facility[par_idx].
     facility_disp)
    IF (par_idx > 0)
     id_values->facility[par_idx].facility_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->facility,id_values->facility_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"FACILITY_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->pattype_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->pattype,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->pattype[exp_idx].pattype_disp)"))
     AND c.code_set=6007
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->pattype_cnt,c.display_key,id_values->pattype[par_idx].
     pattype_disp)
    IF (par_idx > 0)
     id_values->pattype[par_idx].pattype_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->pattype,id_values->pattype_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"PATTYPE_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->subtype_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->subtype,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->subtype[exp_idx].subtype_disp)"))
     AND c.code_set=6007
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->subtype_cnt,c.display_key,id_values->subtype[par_idx].
     subtype_disp)
    IF (par_idx > 0)
     id_values->subtype[par_idx].subtype_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->subtype,id_values->subtype_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"SUBTYPE_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->patloc_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->patloc,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->patloc[exp_idx].patloc_disp)"))
     AND c.code_set=6007
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->patloc_cnt,c.display_key,id_values->patloc[par_idx].
     patloc_disp)
    IF (par_idx > 0)
     id_values->patloc[par_idx].patloc_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->patloc,id_values->patloc_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"PATLOC_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->v_facility_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->v_facility,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->v_facility[exp_idx].v_facility_disp)"))
     AND c.code_set=220
     AND c.cdf_meaning="FACILITY"
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->v_facility_cnt,c.display_key,id_values->v_facility[
     par_idx].v_facility_disp)
    IF (par_idx > 0)
     id_values->v_facility[par_idx].v_facility_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->v_facility,id_values->v_facility_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"V_FACILITY_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->v_pattype_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->v_pattype,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->v_pattype[exp_idx].v_pattype_disp)"))
     AND c.code_set=71
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->v_pattype_cnt,c.display_key,id_values->v_pattype[par_idx
     ].v_pattype_disp)
    IF (par_idx > 0)
     id_values->v_pattype[par_idx].v_pattype_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->v_pattype,id_values->v_pattype_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"V_PATTYPE_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->v_subtype_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->v_subtype,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->v_subtype[exp_idx].v_subtype_disp)"))
     AND c.code_set=5801
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->v_subtype_cnt,c.display_key,id_values->v_subtype[par_idx
     ].v_subtype_disp)
    IF (par_idx > 0)
     id_values->v_subtype[par_idx].v_subtype_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->v_subtype,id_values->v_subtype_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"V_SUBTYPE_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 IF ((id_values->v_patloc_cnt > 0))
  SET exp_start = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value((1+ ((size(id_values->v_patloc,5) - 1)/ exp_size)))),
    code_value c
   PLAN (d
    WHERE parser(dummyt_where))
    JOIN (c
    WHERE parser(concat(exp_base,"c.display_key, id_values->v_patloc[exp_idx].v_patloc_disp)"))
     AND c.code_set=220
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    par_idx = locateval(par_idx,1,id_values->v_patloc_cnt,c.display_key,id_values->v_patloc[par_idx].
     v_patloc_disp)
    IF (par_idx > 0)
     id_values->v_patloc[par_idx].v_patloc_cd = c.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(id_values->v_patloc,id_values->v_patloc_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (checkerror(failure,"SELECT",failure,"V_PATLOC_CD LOOKUP") > 0)
  GO TO exit_script
 ENDIF
 FOR (out_idx = 1 TO build->output_route_cnt)
  IF ((build->output_routes[out_idx].route_type="RAD"))
   SET loop_cnt = locateval(loop_cnt,1,id_values->facility_cnt,build->output_routes[out_idx].
    param1_disp,id_values->facility[loop_cnt].facility_disp)
   IF (loop_cnt > 0)
    SET build->output_routes[out_idx].param1_cd = id_values->facility[loop_cnt].facility_cd
   ENDIF
   IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].param1_cd <= 0))) )
    CALL failrow(out_idx,0,"Invalid facility display value for codeset 6007.")
   ENDIF
   SET loop_cnt = locateval(loop_cnt,1,id_values->pattype_cnt,build->output_routes[out_idx].
    param2_disp,id_values->pattype[loop_cnt].pattype_disp)
   IF (loop_cnt > 0)
    SET build->output_routes[out_idx].param2_cd = id_values->pattype[loop_cnt].pattype_cd
   ENDIF
   IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].param2_cd <= 0))) )
    CALL failrow(out_idx,0,"Invalid patient type display value for codeset 6007.")
   ENDIF
   SET loop_cnt = locateval(loop_cnt,1,id_values->subtype_cnt,build->output_routes[out_idx].
    param3_disp,id_values->subtype[loop_cnt].subtype_disp)
   IF (loop_cnt > 0)
    SET build->output_routes[out_idx].param3_cd = id_values->subtype[loop_cnt].subtype_cd
   ENDIF
   IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].param3_cd <= 0))) )
    CALL failrow(out_idx,0,"Invalid activity sub type display value for codeset 6007.")
   ENDIF
  ELSEIF ((build->output_routes[out_idx].route_type="TRANSPORT"))
   SET loop_cnt = locateval(loop_cnt,1,id_values->facility_cnt,build->output_routes[out_idx].
    param1_disp,id_values->facility[loop_cnt].facility_disp)
   IF (loop_cnt > 0)
    SET build->output_routes[out_idx].param1_cd = id_values->facility[loop_cnt].facility_cd
   ENDIF
   IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].param1_cd <= 0))) )
    CALL failrow(out_idx,0,"Invalid facility display value for codeset 6007.")
   ENDIF
  ELSE
   SET loop_cnt = locateval(loop_cnt,1,id_values->patloc_cnt,build->output_routes[out_idx].
    param1_disp,id_values->patloc[loop_cnt].patloc_disp)
   IF (loop_cnt > 0)
    SET build->output_routes[out_idx].param1_cd = id_values->patloc[loop_cnt].patloc_cd
   ENDIF
   IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].param1_cd <= 0))) )
    CALL failrow(out_idx,0,"Invalid Patient Location display value for codeset 6007.")
   ENDIF
  ENDIF
  FOR (loc_idx = 1 TO build->output_routes[out_idx].flex_rtg_cnt)
    IF ((build->output_routes[out_idx].route_type="RAD"))
     SET loop_cnt = locateval(loop_cnt,1,id_values->v_facility_cnt,build->output_routes[out_idx].
      flex_rtgs[loc_idx].value1_disp,id_values->v_facility[loop_cnt].v_facility_disp)
     IF (loop_cnt > 0)
      SET build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd = id_values->v_facility[loop_cnt
      ].v_facility_cd
     ENDIF
     IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd <= 0))) )
      CALL failrow(out_idx,loc_idx,"Invalid facility display value for codeset 220.")
     ENDIF
     SET loop_cnt = locateval(loop_cnt,1,id_values->v_pattype_cnt,build->output_routes[out_idx].
      flex_rtgs[loc_idx].value2_disp,id_values->v_pattype[loop_cnt].v_pattype_disp)
     IF (loop_cnt > 0)
      SET build->output_routes[out_idx].flex_rtgs[loc_idx].value2_cd = id_values->v_pattype[loop_cnt]
      .v_pattype_cd
     ENDIF
     IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].flex_rtgs[loc_idx].value2_cd <= 0))) )
      CALL failrow(out_idx,loc_idx,"Invalid patient type display value for codeset 71.")
     ENDIF
     SET loop_cnt = locateval(loop_cnt,1,id_values->v_subtype_cnt,build->output_routes[out_idx].
      flex_rtgs[loc_idx].value3_disp,id_values->v_subtype[loop_cnt].v_subtype_disp)
     IF (loop_cnt > 0)
      SET build->output_routes[out_idx].flex_rtgs[loc_idx].value3_cd = id_values->v_subtype[loop_cnt]
      .v_subtype_cd
     ENDIF
     IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].flex_rtgs[loc_idx].value3_cd <= 0))) )
      CALL failrow(out_idx,loc_idx,"Invalid activity sub type display value for codeset 5801.")
     ENDIF
    ELSEIF ((build->output_routes[out_idx].route_type="TRANSPORT"))
     SET loop_cnt = locateval(loop_cnt,1,id_values->v_facility_cnt,build->output_routes[out_idx].
      flex_rtgs[loc_idx].value1_disp,id_values->v_facility[loop_cnt].v_facility_disp)
     IF (loop_cnt > 0)
      SET build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd = id_values->v_facility[loop_cnt
      ].v_facility_cd
     ENDIF
     IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd <= 0))) )
      CALL failrow(out_idx,loc_idx,"Invalid facility display value for codeset 220.")
     ENDIF
    ELSE
     SET loop_cnt = locateval(loop_cnt,1,id_values->v_patloc_cnt,build->output_routes[out_idx].
      flex_rtgs[loc_idx].value1_disp,id_values->v_patloc[loop_cnt].v_patloc_disp)
     IF (loop_cnt > 0)
      SET build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd = id_values->v_patloc[loop_cnt].
      v_patloc_cd
     ENDIF
     IF (((loop_cnt <= 0) OR ((build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd <= 0))) )
      CALL failrow(out_idx,loc_idx,"Invalid Patient Location display value for codeset 220.")
     ENDIF
    ENDIF
  ENDFOR
 ENDFOR
 SET exp_start = 1
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value((1+ ((size(build->output_routes,5) - 1)/ exp_size)))),
   dcp_output_route dor
  PLAN (d
   WHERE parser(dummyt_where))
   JOIN (dor
   WHERE parser(concat(exp_base,"dor.route_description, build->output_routes[exp_idx].route_desc)")))
  DETAIL
   out_idx = locateval(out_idx,1,build->output_route_cnt,dor.route_description,build->output_routes[
    out_idx].route_desc)
   IF (out_idx > 0)
    IF ((build->output_routes[out_idx].action_flag != fail_action))
     build->output_routes[out_idx].action_flag = update_action, build->output_routes[out_idx].
     route_id = dor.dcp_output_route_id
    ENDIF
   ENDIF
  FOOT REPORT
   out_idx = 0, out_idx = locateval(exp_idx,(out_idx+ 1),build->output_route_cnt,0,build->
    output_routes[exp_idx].action_flag)
   WHILE (out_idx > 0)
    build->output_routes[out_idx].action_flag = insert_action,out_idx = locateval(exp_idx,(out_idx+ 1
     ),build->output_route_cnt,0,build->output_routes[exp_idx].action_flag)
   ENDWHILE
   stat = alterlist(build->output_routes,build->output_route_cnt)
  WITH nocounter, nullreport, forupdate(dor)
 ;end select
 IF (checkerror(failure,"SELECT",failure,"EXISTING DATA CHECK") > 0)
  GO TO exit_script
 ENDIF
 IF (insert_flag > 0)
  SELECT INTO "nl:"
   dfp.dcp_output_route_id
   FROM (dummyt d  WITH seq = value(build->output_route_cnt)),
    dcp_flex_printer dfp
   PLAN (d
    WHERE (build->output_routes[d.seq].action_flag=update_action))
    JOIN (dfp
    WHERE (build->output_routes[d.seq].route_id=dfp.dcp_output_route_id))
   WITH nocounter, forupdate(dfp)
  ;end select
  IF (checkerror(failure,"SELECT",failure,"DCP_FLEX_PRINTER LOCK") > 0)
   GO TO exit_script
  ENDIF
  DELETE  FROM dcp_flex_printer dfp,
    (dummyt d  WITH seq = value(build->output_route_cnt))
   SET dfp.seq = 1
   PLAN (d
    WHERE (build->output_routes[d.seq].action_flag=update_action))
    JOIN (dfp
    WHERE (dfp.dcp_output_route_id=build->output_routes[d.seq].route_id))
   WITH nocounter
  ;end delete
  IF (checkerror(failure,"DELETE",failure,"DCP_FLEX_PRINTER") > 0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   dfr.dcp_output_route_id
   FROM (dummyt d  WITH seq = value(build->output_route_cnt)),
    dcp_flex_rtg dfr
   PLAN (d
    WHERE (build->output_routes[d.seq].action_flag=update_action))
    JOIN (dfr
    WHERE (build->output_routes[d.seq].route_id=dfr.dcp_output_route_id))
   WITH nocounter, forupdate(dfr)
  ;end select
  IF (checkerror(failure,"SELECT",failure,"DCP_FLEX_RTG LOCK") > 0)
   GO TO exit_script
  ENDIF
  DELETE  FROM dcp_flex_rtg dfr,
    (dummyt d  WITH seq = value(build->output_route_cnt))
   SET dfr.seq = 1
   PLAN (d
    WHERE (build->output_routes[d.seq].action_flag=update_action))
    JOIN (dfr
    WHERE (dfr.dcp_output_route_id=build->output_routes[d.seq].route_id))
   WITH nocounter
  ;end delete
  IF (checkerror(failure,"DELETE",failure,"DCP_FLEX_RTG") > 0)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   dor.dcp_output_route_id
   FROM (dummyt d  WITH seq = value(build->output_route_cnt)),
    dcp_output_route dor
   PLAN (d
    WHERE (build->output_routes[d.seq].action_flag=update_action))
    JOIN (dor
    WHERE (build->output_routes[d.seq].route_id=dor.dcp_output_route_id))
   WITH nocounter, forupdate(dor)
  ;end select
  IF (checkerror(failure,"SELECT",failure,"DCP_OUTPUT_ROUTE LOCK") > 0)
   GO TO exit_script
  ENDIF
  DELETE  FROM dcp_output_route dor,
    (dummyt d  WITH seq = value(build->output_route_cnt))
   SET dor.seq = 1
   PLAN (d
    WHERE (build->output_routes[d.seq].action_flag=update_action))
    JOIN (dor
    WHERE (dor.dcp_output_route_id=build->output_routes[d.seq].route_id))
   WITH nocounter
  ;end delete
  IF (checkerror(failure,"DELETE",failure,"DCP_OUTPUT_ROUTE") > 0)
   GO TO exit_script
  ENDIF
  FOR (out_cnt = 1 TO build->output_route_cnt)
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     build->output_routes[out_cnt].route_id = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (checkerror(failure,"SELECT",failure,"DUAL - REFERENCE_SEQ") > 0)
    GO TO exit_script
   ENDIF
  ENDFOR
  INSERT  FROM (dummyt d1  WITH seq = value(build->output_route_cnt)),
    dcp_output_route dor
   SET dor.dcp_output_route_id = build->output_routes[d1.seq].route_id, dor.route_description = build
    ->output_routes[d1.seq].route_desc, dor.route_type_flag = 0,
    dor.param_cnt = build->output_routes[d1.seq].param_cnt, dor.param1_cd = build->output_routes[d1
    .seq].param1_cd, dor.param2_cd = build->output_routes[d1.seq].param2_cd,
    dor.param3_cd = build->output_routes[d1.seq].param3_cd, dor.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), dor.updt_applctx = reqinfo->updt_applctx,
    dor.updt_id = reqinfo->updt_id, dor.updt_cnt = 0, dor.updt_task = reqinfo->updt_task
   PLAN (d1
    WHERE (build->output_routes[d1.seq].action_flag != fail_action))
    JOIN (dor)
   WITH nocounter, status(build->output_routes[d1.seq].status_flag)
  ;end insert
  CALL checkstatus(insert_action)
  IF (checkerror(failure,"INSERT",failure,"DCP_OUTPUT_ROUTE") > 0)
   GO TO exit_script
  ENDIF
  FOR (out_cnt = 1 TO build->output_route_cnt)
    FOR (flx_cnt = 1 TO build->output_routes[out_cnt].flex_rtg_cnt)
      SELECT INTO "nl:"
       y = seq(reference_seq,nextval)
       FROM dual
       DETAIL
        build->output_routes[out_cnt].flex_rtgs[flx_cnt].rtg_id = cnvtreal(y)
       WITH nocounter
      ;end select
    ENDFOR
  ENDFOR
  INSERT  FROM (dummyt d1  WITH seq = value(build->output_route_cnt)),
    (dummyt d2  WITH seq = value(1)),
    dcp_flex_rtg dfr
   SET dfr.dcp_flex_rtg_id = build->output_routes[d1.seq].flex_rtgs[d2.seq].rtg_id, dfr
    .dcp_output_route_id = build->output_routes[d1.seq].route_id, dfr.value1_cd = build->
    output_routes[d1.seq].flex_rtgs[d2.seq].value1_cd,
    dfr.value2_cd = build->output_routes[d1.seq].flex_rtgs[d2.seq].value2_cd, dfr.value3_cd = build->
    output_routes[d1.seq].flex_rtgs[d2.seq].value3_cd, dfr.updt_dt_tm = cnvtdatetime(curdate,curtime3
     ),
    dfr.updt_applctx = reqinfo->updt_applctx, dfr.updt_id = reqinfo->updt_id, dfr.updt_cnt = 0,
    dfr.updt_task = reqinfo->updt_task
   PLAN (d1
    WHERE (build->output_routes[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->output_routes[d1.seq].flex_rtg_cnt))
    JOIN (d2
    WHERE (build->output_routes[d1.seq].flex_rtgs[d2.seq].action_flag != fail_action))
    JOIN (dfr)
   WITH nocounter, status(build->output_routes[d1.seq].flex_rtgs[d2.seq].status_flag)
  ;end insert
  CALL checkstatus(insert_action)
  IF (checkerror(failure,"INSERT",failure,"DCP_FLEX_RTG") > 0)
   GO TO exit_script
  ENDIF
  INSERT  FROM (dummyt d1  WITH seq = value(build->output_route_cnt)),
    (dummyt d2  WITH seq = value(1)),
    (dummyt d3  WITH seq = value(1)),
    dcp_flex_printer dfp
   SET dfp.dcp_flex_printer_id = seq(reference_seq,nextval), dfp.dcp_output_route_id = build->
    output_routes[d1.seq].route_id, dfp.dcp_flex_rtg_id = build->output_routes[d1.seq].flex_rtgs[d2
    .seq].rtg_id,
    dfp.printer_name = build->output_routes[d1.seq].flex_rtgs[d2.seq].printer_name, dfp.updt_dt_tm =
    cnvtdatetime(curdate,curtime3), dfp.updt_applctx = reqinfo->updt_applctx,
    dfp.updt_id = reqinfo->updt_id, dfp.updt_cnt = 0, dfp.updt_task = reqinfo->updt_task
   PLAN (d1
    WHERE (build->output_routes[d1.seq].action_flag != fail_action)
     AND maxrec(d2,build->output_routes[d1.seq].flex_rtg_cnt))
    JOIN (d2
    WHERE (build->output_routes[d1.seq].flex_rtgs[d2.seq].action_flag != fail_action)
     AND maxrec(d3,build->output_routes[d1.seq].flex_rtgs[d2.seq].num_of_copies))
    JOIN (d3)
    JOIN (dfp)
   WITH nocounter, status(build->output_routes[d1.seq].flex_rtgs[d2.seq].status_flag)
  ;end insert
  CALL checkstatus(insert_action)
  IF (checkerror(failure,"INSERT",failure,"DCP_FLEX_PRINTER") > 0)
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 CALL checkerror(failure,"CCL ERROR",failure,"FINAL ERROR CHECK")
 SELECT INTO value(log_file)
  route_type_disp = trim(substring(1,100,build->output_routes[d1.seq].route_type),3), route_name_disp
   = trim(substring(1,100,build->output_routes[d1.seq].route_desc),3), value_disp = trim(substring(1,
    100,build->output_routes[d1.seq].flex_rtgs[d2.seq].value1_disp_orig),3),
  patient_type_disp = trim(substring(1,100,build->output_routes[d1.seq].flex_rtgs[d2.seq].
    value2_disp_orig),3), sub_activity_type_disp = trim(substring(1,100,build->output_routes[d1.seq].
    flex_rtgs[d2.seq].value3_disp_orig),3), printer_name_disp = cnvtupper(substring(1,100,build->
    output_routes[d1.seq].flex_rtgs[d2.seq].printer_name))
  FROM (dummyt d1  WITH seq = value(build->output_route_cnt)),
   (dummyt d2  WITH seq = value(1)),
   (dummyt d3  WITH seq = value(1))
  PLAN (d1
   WHERE maxrec(d2,build->output_routes[d1.seq].flex_rtg_cnt))
   JOIN (d2
   WHERE maxrec(d3,build->output_routes[d1.seq].flex_rtgs[d2.seq].num_of_copies)
    AND d2.seq > 0)
   JOIN (d3)
  ORDER BY route_type_disp DESC, route_name_disp, printer_name_disp
  HEAD REPORT
   col_count = 0, col_type_disp = (col_count+ 5), col_name_disp = (col_type_disp+ 12),
   col_action = 110, col_name_error = (col_name_disp+ 5), col_param1 = (col_name_error+ 15),
   col_param2 = (col_param1+ 15), col_param3 = (col_param2+ 15), col_param4 = (col_param3+ 15),
   col_printer_disp = (col_param4+ 15), row_cnt = 0, action_disp = fillstring(10,""),
   line = fillstring(value(120),"-"), col 0, "REQUISITION ROUTING TYPE - IMPORT",
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
   col col_count, "Row", col col_type_disp,
   "Route Type", row + 1, col col_name_disp,
   "Route Name", col col_param1, "Facility",
   col col_param2, "Patient Type", col col_param3,
   "Sub Act Type", col col_param4, "Patient Loc",
   col col_printer_disp, "Printer", col col_action,
   "Action", row + 1, col 0,
   line, row + 1
  HEAD route_type_disp
   col col_count, row_cnt"###;r;i", col col_type_disp,
   route_type_disp
  HEAD route_name_disp
   col col_count, row_cnt"###;r;i", col col_name_disp,
   route_name_disp
   IF (textlen(trim(build->output_routes[d1.seq].error_msg,3)) > 0)
    row + 1, col col_name_error, build->output_routes[d1.seq].error_msg
   ENDIF
  DETAIL
   row_cnt = (row_cnt+ 1), action_disp = evaluate(build->output_routes[d1.seq].flex_rtgs[d2.seq].
    action_flag,fail_action,"FAIL",evaluate(insert_flag,0,"VERIFIED","UPLOADED")), col col_count,
   row_cnt"###;r;i"
   IF ((build->output_routes[d1.seq].route_type="RAD"))
    col col_param1, value_disp, col col_param2,
    patient_type_disp, col col_param3, sub_activity_type_disp
   ELSEIF ((build->output_routes[d1.seq].route_type="TRANSPORT"))
    col col_param1, value_disp
   ELSE
    col col_param4, value_disp
   ENDIF
   col col_printer_disp, printer_name_disp, col col_action,
   action_disp
   IF (textlen(trim(build->output_routes[d1.seq].flex_rtgs[d2.seq].error_msg,3)) > 0)
    row + 1, col col_name_error, build->output_routes[d1.seq].flex_rtgs[d2.seq].error_msg
   ENDIF
   row + 1
  FOOT  route_type_disp
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
