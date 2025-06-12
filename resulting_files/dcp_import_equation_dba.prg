CREATE PROGRAM dcp_import_equation:dba
 RECORD internal(
   1 equation_list[*]
     2 task_assay_cd = f8
     2 equation_id = f8
     2 service_resource_cd = f8
     2 unknown_age_ind = i2
     2 age_from_units_cd = f8
     2 age_from_minutes = f8
     2 age_to_minutes = f8
     2 age_to_units_cd = f8
     2 sex_cd = f8
     2 species_cd = f8
     2 equation_description = vc
     2 equation_postfix = vc
     2 default_ind = i4
     2 active_ind = i4
     2 components[*]
       3 result_status_cd = f8
       3 included_assay_cd = f8
       3 name = vc
       3 default_value = f8
       3 cross_drawn_dt_tm_ind = i2
       3 time_window_minutes = i4
       3 time_window_back_minutes = i4
       3 result_req_flag = i2
       3 variable_prompt = vc
       3 constant_value = f8
       3 component_flag = i2
       3 units_cd = f8
 )
 DECLARE equation_id = f8 WITH public, noconstant(0.0)
 SET numrows = size(requestin->list_0,5)
 SET tmp_dta_mnemonic = fillstring(255," ")
 SET tmp_dta_desc = fillstring(255," ")
 DECLARE tmp_task_assay_cd = f8 WITH protect, noconstant(0.0)
 DECLARE tmp_equation_id = f8 WITH protect, noconstant(0.0)
 SET code_display = fillstring(255," ")
 DECLARE code_value = f8 WITH protect, noconstant(0.0)
 SET comp_cnt = 0
 DECLARE serv_resource_cd = f8 WITH protect, noconstant(0.0)
 DECLARE species_cd = f8 WITH protect, noconstant(0.0)
 DECLARE age_from_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE age_to_unit_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sex_cd = f8 WITH protect, noconstant(0.0)
 SET eqn_cnt = 0
 SET status_ind = 1
 IF (numrows=0)
  SET status_ind = 0
  GO TO endprogram
 ENDIF
 SET rvar = 0
 SELECT INTO "dcp_import_equation.log"
  rvar
  HEAD REPORT
   curdate"dd-mmm-yyyy;;d", "-", curtime"hh:mm;;m",
   col + 1, "**equation Import Log", row + 1,
   col 0, "Equation ForTask_assay_cd  Being Imported: ", row + 1,
   col 0, requestin->list_0[1].dta_desc
  DETAIL
   col 0
  WITH nocounter, format = variable, noformfeed,
   maxcol = 132, maxrow = 1
 ;end select
 SET lvar = 1
 DECLARE prev_eqn_id = f8 WITH protect, noconstant(0.0)
 DECLARE activity_type_cd = f8 WITH protect, noconstant(0.0)
 SET cdf_meaning = fillstring(50," ")
 SET code_value = 0
 WHILE (lvar <= numrows)
   IF (lvar=1)
    SET code_value = 0
    SET code_set = 106
    SET code_display = cnvtalphanum(requestin->list_0[lvar].act_type_display)
    EXECUTE cpm_get_cd_for_disp
    SET activity_type_cd = code_value
    CALL echo(build("activity_type_cd:",activity_type_cd))
    SET tmp_task_assay_cd = 0
    SET tmp_dta_mnemonic = requestin->list_0[lvar].dta_mnemonic
    SET tmp_dta_desc = requestin->list_0[lvar].dta_desc
    CALL gettaskassaycd(lvar)
    SET eqn_cnt = 0
   ELSEIF (cnvtreal(requestin->list_0[lvar].task_assay_cd) != cnvtreal(requestin->list_0[(lvar - 1)].
    task_assay_cd))
    SET code_value = 0
    SET code_set = 106
    SET code_display = cnvtalphanum(requestin->list_0[lvar].act_type_display)
    EXECUTE cpm_get_cd_for_disp
    SET activity_type_cd = code_value
    SET tmp_task_assay_cd = 0
    SET tmp_dta_mnemonic = requestin->list_0[lvar].dta_mnemonic
    SET tmp_dta_desc = requestin->list_0[lvar].dta_desc
    CALL gettaskassaycd(lvar)
    SET eqn_cnt = 0
   ENDIF
   IF (tmp_task_assay_cd=0)
    CALL logoferror(5,lvar)
    SET status_ind = 0
    GO TO endprogram
   ENDIF
   IF (((lvar=1) OR (cnvtreal(requestin->list_0[lvar].equation_id) != prev_eqn_id)) )
    SET prev_eqn_id = cnvtreal(requestin->list_0[lvar].equation_id)
    SET tmp_equation_id = 0
    SET eqn_cnt = (eqn_cnt+ 1)
    SET code_value = 0
    SET code_display = cnvtalphanum(trim(requestin->list_0[lvar].serv_cd_disp))
    SET code_set = cnvtint(requestin->list_0[lvar].serv_code_set)
    EXECUTE cpm_get_cd_for_disp
    SET serv_resource_cd = code_value
    SET code_value = 0
    SET code_display = cnvtalphanum(trim(requestin->list_0[lvar].species_cd_disp))
    SET code_set = cnvtint(requestin->list_0[lvar].species_code_set)
    EXECUTE cpm_get_cd_for_disp
    SET species_cd = code_value
    SET code_value = 0
    SET code_display = cnvtalphanum(trim(requestin->list_0[lvar].age_from_units_disp))
    SET code_set = cnvtint(requestin->list_0[lvar].age_units_codeset)
    EXECUTE cpm_get_cd_for_disp
    SET age_from_unit_cd = code_value
    SET code_value = 0
    SET code_display = cnvtalphanum(trim(requestin->list_0[lvar].age_to_units_disp))
    EXECUTE cpm_get_cd_for_disp
    SET age_to_unit_cd = code_value
    SET code_value = 0
    SET code_display = cnvtalphanum(trim(requestin->list_0[lvar].sex_code_disp))
    SET code_set = cnvtint(requestin->list_0[lvar].sex_code_set)
    EXECUTE cpm_get_cd_for_disp
    SET sex_cd = code_value
    CALL getequationid(lvar)
    CALL createnewequation(lvar,tmp_equation_id,tmp_task_assay_cd)
   ENDIF
   SET code_value = 0
   SET code_set = 106
   SET code_display = cnvtalphanum(requestin->list_0[lvar].comp_act_type_display)
   EXECUTE cpm_get_cd_for_disp
   SET activity_type_cd = code_value
   CALL echo(build("activity_type_cd:",activity_type_cd))
   SET tmp_task_assay_cd = 0
   SET tmp_dta_mnemonic = requestin->list_0[lvar].comp_mnemonic
   SET tmp_dta_desc = requestin->list_0[lvar].comp_desc
   CALL gettaskassaycd(lvar)
   IF (tmp_task_assay_cd=0)
    CALL logoferror(6,lvar)
    SET status_ind = 0
    GO TO endprogram
   ENDIF
   SET comp_cnt = (comp_cnt+ 1)
   IF (comp_cnt > size(internal->equation_list[eqn_cnt].components,5))
    SET stat = alterlist(internal->equation_list[eqn_cnt].components,comp_cnt)
   ENDIF
   SET internal->equation_list[eqn_cnt].components[comp_cnt].included_assay_cd = tmp_task_assay_cd
   SET code_value = 0
   SET code_display = trim(requestin->list_0[lvar].result_status_disp)
   SET code_set = cnvtint(requestin->list_0[lvar].result_status_cs)
   EXECUTE cpm_get_cd_for_disp
   SET internal->equation_list[eqn_cnt].components[comp_cnt].result_status_cd = code_value
   SET internal->equation_list[eqn_cnt].components[comp_cnt].name = requestin->list_0[lvar].name
   SET internal->equation_list[eqn_cnt].components[comp_cnt].default_value = cnvtreal(requestin->
    list_0[lvar].default_ind)
   SET internal->equation_list[eqn_cnt].components[comp_cnt].cross_drawn_dt_tm_ind = cnvtint(
    requestin->list_0[lvar].cross_drawn_dt_tm_ind)
   SET internal->equation_list[eqn_cnt].components[comp_cnt].time_window_minutes = cnvtint(requestin
    ->list_0[lvar].time_window_minutes)
   SET internal->equation_list[eqn_cnt].components[comp_cnt].time_window_back_minutes = cnvtint(
    requestin->list_0[lvar].time_window_back_minutes)
   SET internal->equation_list[eqn_cnt].components[comp_cnt].result_req_flag = cnvtint(requestin->
    list_0[lvar].result_req_flag)
   SET internal->equation_list[eqn_cnt].components[comp_cnt].variable_prompt = trim(requestin->
    list_0[lvar].variable_prompt)
   SET internal->equation_list[eqn_cnt].components[comp_cnt].constant_value = cnvtreal(requestin->
    list_0[lvar].constant_value)
   SET internal->equation_list[eqn_cnt].components[comp_cnt].component_flag = cnvtint(requestin->
    list_0[lvar].component_flag)
   SET code_value = 0
   SET code_display = trim(requestin->list_0[lvar].units_cd_cs)
   SET code_set = cnvtint(requestin->list_0[lvar].units_cd_disp)
   EXECUTE cpm_get_cd_for_disp
   SET internal->equation_list[eqn_cnt].components[comp_cnt].units_cd = code_value
   SET lvar = (lvar+ 1)
 ENDWHILE
 SET equation_id = 0
 CALL echo(build("status_ind:",status_ind))
 IF (status_ind=1)
  FOR (i = 1 TO eqn_cnt)
    IF ((internal->equation_list[i].default_ind > 0))
     UPDATE  FROM equation e
      SET e.default_ind = 0, e.updt_id = reqinfo->updt_id, e.updt_task = reqinfo->updt_task,
       e.updt_applctx = reqinfo->updt_applctx, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
       .updt_cnt = (e.updt_cnt+ 1)
      WHERE (e.task_assay_cd=internal->equation_list[i].task_assay_cd)
       AND e.default_ind=1
      WITH nocounter
     ;end update
    ENDIF
    IF ((internal->equation_list[i].equation_id > 0))
     SET equation_id = internal->equation_list[i].equation_id
     UPDATE  FROM equation e
      SET e.unknown_age_ind = internal->equation_list[i].unknown_age_ind, e.age_from_units_cd =
       internal->equation_list[i].age_from_units_cd, e.age_from_minutes = internal->equation_list[i].
       age_from_minutes,
       e.age_to_units_cd = internal->equation_list[i].age_to_units_cd, e.age_to_minutes = internal->
       equation_list[i].age_to_minutes, e.sex_cd = internal->equation_list[i].sex_cd,
       e.species_cd = internal->equation_list[i].species_cd, e.equation_description = internal->
       equation_list[i].equation_desc, e.equation_postfix = internal->equation_list[i].
       equation_postfix,
       e.active_dt_tm = cnvtdatetime(curdate,curtime3), e.inactive_dt_tm = cnvtdatetime(
        "31-DEC-2100 00:00"), e.default_ind = internal->equation_list[i].default_ind,
       e.active_ind = internal->equation_list[i].active_ind, e.updt_dt_tm = cnvtdatetime(curdate,
        curtime3), e.updt_id = reqinfo->updt_id,
       e.updt_task = reqinfo->updt_task, e.updt_applctx = reqinfo->updt_applctx, e.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       e.updt_cnt = (e.updt_cnt+ 1)
      WHERE e.equation_id=equation_id
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL logoferror(1,equation_id)
      SET status_ind = 0
      GO TO endprogram
     ENDIF
     DELETE  FROM equation_component ec
      WHERE ec.equation_id=equation_id
      WITH nocounter
     ;end delete
     IF (curqual=0)
      CALL logoferror(2,equation_id)
      SET status_ind = 0
      GO TO endprogram
     ENDIF
    ELSEIF ((internal->equation_list[i].equation_id=0))
     SELECT INTO "nl:"
      y = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       equation_id = cnvtreal(y)
      WITH format, counter
     ;end select
     INSERT  FROM equation e
      SET e.equation_id = equation_id, e.task_assay_cd = internal->equation_list[i].task_assay_cd, e
       .unknown_age_ind = internal->equation_list[i].unknown_age_ind,
       e.age_from_units_cd = internal->equation_list[i].age_from_units_cd, e.age_from_minutes =
       internal->equation_list[i].age_from_minutes, e.age_to_units_cd = internal->equation_list[i].
       age_to_units_cd,
       e.age_to_minutes = internal->equation_list[i].age_to_minutes, e.sex_cd = internal->
       equation_list[i].sex_cd, e.species_cd = internal->equation_list[i].species_cd,
       e.equation_description = internal->equation_list[i].equation_description, e.equation_postfix
        = internal->equation_list[i].equation_postfix, e.active_dt_tm = cnvtdatetime(curdate,curtime3
        ),
       e.inactive_dt_tm = cnvtdatetime("31-DEC-2100 00:00"), e.default_ind = internal->equation_list[
       i].default_ind, e.active_ind = internal->equation_list[i].active_ind,
       e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e.updt_id = reqinfo->updt_id, e.updt_task =
       reqinfo->updt_task,
       e.updt_applctx = reqinfo->updt_applctx, e.updt_dt_tm = cnvtdatetime(curdate,curtime3), e
       .updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual=0)
      CALL logoferror(3,internal->equation_list[i].task_assay_cd)
      SET status_ind = 0
      GO TO endprogram
     ENDIF
    ENDIF
    CALL echo(build("equation_id:",equation_id))
    SET tmpseq = 0
    SET comp_cnt = size(internal->equation_list[i].components,5)
    INSERT  FROM equation_component ec,
      (dummyt d1  WITH seq = value(comp_cnt))
     SET tmpseq = (tmpseq+ 1), ec.equation_id = equation_id, ec.sequence = tmpseq,
      ec.result_status_cd = internal->equation_list[i].components[d1.seq].result_status_cd, ec
      .included_assay_cd = internal->equation_list[i].components[d1.seq].included_assay_cd, ec.name
       = internal->equation_list[i].components[d1.seq].name,
      ec.default_value = internal->equation_list[i].components[d1.seq].default_value, ec
      .cross_drawn_dt_tm_ind = internal->equation_list[i].components[d1.seq].cross_drawn_dt_tm_ind,
      ec.time_window_minutes = internal->equation_list[i].components[d1.seq].time_window_minutes,
      ec.time_window_back_minutes = internal->equation_list[i].components[d1.seq].
      time_window_back_minutes, ec.result_req_flag = internal->equation_list[i].components[d1.seq].
      result_req_flag, ec.variable_prompt = internal->equation_list[i].components[d1.seq].
      variable_prompt,
      ec.constant_value = internal->equation_list[i].components[d1.seq].constant_value, ec
      .component_flag = internal->equation_list[i].components[d1.seq].component_flag, ec.units_cd =
      internal->equation_list[i].components[d1.seq].units_cd,
      ec.updt_id = reqinfo->updt_id, ec.updt_task = reqinfo->updt_task, ec.updt_applctx = reqinfo->
      updt_applctx,
      ec.updt_dt_tm = cnvtdatetime(curdate,curtime3), ec.updt_cnt = 0
     PLAN (d1)
      JOIN (ec
      WHERE ec.equation_id=equation_id
       AND ec.sequence=d1.seq)
     WITH nocounter, outerjoin = d1, dontexist
    ;end insert
    IF (curqual=0)
     CALL logoferror(4,equation_id)
     SET status_ind = 0
     GO TO endprogram
    ENDIF
  ENDFOR
 ENDIF
#endprogram
 IF (status_ind=1)
  CALL logoferror(7,0)
  CALL echo("Success")
  COMMIT
 ELSE
  CALL logoferror(8,0)
  CALL echo("Failure")
  ROLLBACK
 ENDIF
 SUBROUTINE gettaskassaycd(val)
   CALL echo(build("dta_desc:",tmp_dta_desc))
   CALL echo(build("dta_mnemonic:",tmp_dta_mnemonic))
   SELECT INTO "nl:"
    FROM discrete_task_assay dta
    WHERE dta.activity_type_cd=activity_type_cd
     AND dta.mnemonic=tmp_dta_mnemonic
    DETAIL
     tmp_task_assay_cd = dta.task_assay_cd,
     CALL echo(build("tmp_task_assay_cd:",tmp_task_assay_cd))
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getequationid(val1)
   SELECT INTO "nl:"
    FROM equation eqn
    WHERE eqn.task_assay_cd=tmp_task_assay_cd
     AND eqn.service_resource_cd=serv_resource_cd
     AND eqn.species_cd=species_cd
     AND eqn.age_from_minutes=cnvtint(requestin->list_0[val1].age_from_minutes)
     AND eqn.age_to_minutes=cnvtint(requestin->list_0[val1].age_from_minutes)
     AND eqn.sex_cd=sex_cd
    DETAIL
     tmp_equation_id = eqn.equation_id
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE createnewequation(val2,eqnid,taskassaycd)
   IF (eqn_cnt > size(internal->equation_list,5))
    SET stat = alterlist(internal->equation_list,eqn_cnt)
   ENDIF
   SET internal->equation_list[eqn_cnt].task_assay_cd = taskassaycd
   SET internal->equation_list[eqn_cnt].equation_id = eqnid
   SET internal->equation_list[eqn_cnt].service_resource_cd = serv_resource_cd
   SET internal->equation_list[eqn_cnt].unknown_age_ind = cnvtint(requestin->list_0[val2].
    unknown_age_ind)
   SET internal->equation_list[eqn_cnt].age_from_minutes = cnvtint(requestin->list_0[val2].
    age_from_minutes)
   SET internal->equation_list[eqn_cnt].age_to_minutes = cnvtint(requestin->list_0[val2].
    age_to_minutes)
   SET internal->equation_list[eqn_cnt].age_from_units_cd = age_from_unit_cd
   SET internal->equation_list[eqn_cnt].age_to_units_cd = age_to_unit_cd
   SET internal->equation_list[eqn_cnt].species_cd = species_cd
   SET internal->equation_list[eqn_cnt].sex_cd = sex_cd
   SET internal->equation_list[eqn_cnt].equation_description = trim(requestin->list_0[val2].
    equation_desc)
   SET internal->equation_list[eqn_cnt].equation_postfix = requestin->list_0[val2].equation_postfix
   SET internal->equation_list[eqn_cnt].default_ind = cnvtint(requestin->list_0[val2].default_ind)
   SET internal->equation_list[eqn_cnt].active_ind = 1
 END ;Subroutine
 SUBROUTINE logoferror(etype,val1)
   SELECT INTO "dcp_import_equation.log"
    val1
    DETAIL
     IF (etype=1)
      row + 1, col 0, "Update Equation Failed"
     ENDIF
     IF (etype=2)
      row + 1, col 0, "Delete Equation Failed"
     ENDIF
     IF (etype=3)
      row + 1, col 0, "New Equation Failed create"
     ENDIF
     IF (etype=4)
      row + 1, col 0, " Equation Components is not created"
     ENDIF
     IF (etype=5)
      row + 1, col 0, "Could not find the task_assay_cd",
      row + 1, col 0, "Row #:",
      val1
     ENDIF
     IF (etype=6)
      row + 1, col 0, "Could not find the component task_assay_cd",
      row + 1, col 0, "Row #:",
      val1
     ENDIF
     IF (etype=7)
      row + 1, col 0, "Equation Uploaded Successfully"
     ENDIF
     IF (etype=8)
      row + 1, col 0, "Equation Upload Failed"
     ENDIF
   ;end select
 END ;Subroutine
END GO
