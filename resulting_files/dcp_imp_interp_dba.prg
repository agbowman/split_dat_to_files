CREATE PROGRAM dcp_imp_interp:dba
 RECORD drequest(
   1 qual[*]
     2 dcp_interp_id = f8
     2 temp_interp_id = f8
     2 task_assay_cd = f8
     2 sex_cd = f8
     2 age_from_minutes = f8
     2 age_to_minutes = f8
     2 service_resource_cd = f8
     2 updt_cnt = i4
     2 start_state_id = f8
     2 components[*]
       3 component_assay_cd = f8
       3 description = vc
       3 component_sequence = i4
       3 flags = i4
     2 states[*]
       3 state_id = f8
       3 transition_assay_cd = f8
       3 flags = i4
       3 numeric_low = f8
       3 numeric_high = f8
       3 nomenclature_id = f8
       3 resulting_state = f8
       3 result_nomenclature_id = f8
       3 result_value = f8
 )
 RECORD code_list(
   1 code_qual[*]
     2 code_value = f8
     2 description = vc
     2 cdf_meaning = vc
     2 code_set = f8
     2 display_key = vc
 )
 RECORD task_assay_list(
   1 task_assay_qual[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 desc = vc
     2 activity_type_cd = f8
 )
 RECORD nomen_list(
   1 nomen_qual[*]
     2 nomenclature_id = f8
     2 source_vocabulary_cd = f8
     2 principle_type_cd = f8
     2 source_identifier = vc
     2 source_string = vc
 )
 DECLARE interp_id = f8 WITH public, noconstant(0.0)
 DECLARE sex_cd = f8 WITH public, noconstant(0.0)
 DECLARE sour_cd = f8 WITH public, noconstant(0.0)
 DECLARE nomen_source_cd = f8 WITH public, noconstant(0.0)
 DECLARE nomen_prin_cd = f8 WITH public, noconstant(0.0)
 DECLARE rnomen_source_cd = f8 WITH public, noconstant(0.0)
 DECLARE rnomen_prin_cd = f8 WITH public, noconstant(0.0)
 SET success_flag = 1
 SET cnt = size(requestin->list_0,5)
 SET code_value = 0.0
 SET task_assay_cki = fillstring(120," ")
 SET temp_interp_id = 0.0
 SET descrption = fillstring(120," ")
 SET qual_cnt = 0
 SET comp_cnt = 0
 SET state_cnt = 0
 SET stat = 0
 SET i = 0
 SET j = 0
 SET temp_code_meaning = fillstring(50," ")
 SET temp_code_dk = fillstring(50," ")
 SET temp_source_string = fillstring(255," ")
 SET temp_mnemonic = fillstring(80," ")
 SET temp_source_iden = fillstring(80," ")
 SET code_set1 = 0
 SET rvar = 0
 SELECT INTO "dcp_imp_interp.log"
  rvar
  HEAD REPORT
   row + 1, col 0, curdate"dd-mmm-yyyy;;d",
   "-", curtime"hh:mm;;m", col + 1,
   "Interp Adding new rows Log"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 FOR (i = 1 TO cnt)
   SET temp_interp_id = 0.0
   CALL check_for_interpid(cnvtreal(requestin->list_0[i].dcp_interp_id))
   CALL echo(build("temp_interp_id",temp_interp_id,"value:",i))
   CALL echo(build("qual_cnt:",qual_cnt))
   IF (temp_interp_id=0)
    SET qual_cnt = size(drequest->qual,5)
    SET qual_cnt = (qual_cnt+ 1)
    CALL echo(build("qual_cnt - 2:",qual_cnt))
    IF (qual_cnt > size(drequest->qual,5))
     SET stat = alterlist(drequest->qual,qual_cnt)
    ENDIF
    SET state_cnt = 0
    SET comp_cnt = 0
    SET drequest->qual[qual_cnt].temp_interp_id = cnvtreal(requestin->list_0[i].dcp_interp_id)
    SET code_value = 0.0
    SET sex_cd = cnvtreal(requestin->list_0[i].sex_cd)
    IF (sex_cd != 0)
     SET code_set1 = 57
     SET temp_code_meaning = trim(requestin->list_0[i].sex_cd_meaning)
     SET temp_code_dk = trim(requestin->list_0[i].sex_cd_dk)
     CALL get_codevalue(sex_cd,code_set1)
     IF (code_value=0)
      CALL log_of_error(1,i,trim(requestin->list_0[i].sex_cd_meaning))
      GO TO exit_script
     ENDIF
    ENDIF
    SET drequest->qual[qual_cnt].sex_cd = code_value
    CALL echo(build("code_value:",code_value))
    SET code_value = 0.0
    SET sour_cd = cnvtreal(requestin->list_0[i].sour_cd)
    IF (sour_cd != 0)
     SET code_set1 = 221
     SET temp_code_meaning = trim(requestin->list_0[i].sour_cd_meaning)
     SET temp_code_dk = trim(requestin->list_0[i].sour_cd_dk)
     CALL get_codevalue(sour_cd,code_set1)
     IF (code_value=0)
      CALL log_of_error(2,i,trim(requestin->list_0[i].sour_cd_meaning))
      GO TO exit_script
     ENDIF
    ENDIF
    SET drequest->qual[qual_cnt].service_resource_cd = code_value
    SET drequest->qual[qual_cnt].age_from_minutes = cnvtreal(requestin->list_0[i].age_from_minutes)
    SET drequest->qual[qual_cnt].age_to_minutes = cnvtreal(requestin->list_0[i].age_to_minutes)
    SET code_value = 0.0
    SET code_set = 106
    SET code_display = trim(requestin->list_0[i].task_act_type_disp)
    EXECUTE cpm_get_cd_for_disp
    SET activity_type_cd = code_value
    SET code_value = 0.0
    SET temp_mnemonic = trim(requestin->list_0[i].task_assay_mnemonic)
    CALL gettaskassaycode(cnvtreal(requestin->list_0[i].task_assay_cd),activity_type_cd)
    IF (code_value=0)
     CALL log_of_error(3,i,trim(requestin->list_0[i].task_assay_mnemonic))
     GO TO exit_script
    ENDIF
    SET drequest->qual[qual_cnt].task_assay_cd = code_value
   ELSEIF (temp_interp_id != 0)
    SET state_cnt = size(drequest->qual[qual_cnt].states,5)
    SET comp_cnt = size(drequest->qual[qual_cnt].components,5)
   ENDIF
   CASE (requestin->list_0[i].check)
    OF "ic":
     SET description = fillstring(120," ")
     SET code_value = 0.0
     SET code_set = 106
     SET code_display = trim(requestin->list_0[i].comp_act_type_disp)
     EXECUTE cpm_get_cd_for_disp
     SET activity_type_cd = code_value
     SET code_value = 0.0
     SET temp_mnemonic = trim(requestin->list_0[i].comp_cd_mnemonic)
     CALL gettaskassaycode(cnvtreal(requestin->list_0[i].comp_cd),activity_type_cd)
     IF (code_value=0)
      CALL log_of_error(4,i,trim(requestin->list_0[i].comp_cd_mnemonic))
      GO TO exit_script
     ENDIF
     SET comp_cnt = (comp_cnt+ 1)
     IF (comp_cnt > size(drequest->qual[qual_cnt].components,5))
      SET stat = alterlist(drequest->qual[qual_cnt].components,comp_cnt)
     ENDIF
     SET drequest->qual[qual_cnt].components[comp_cnt].component_assay_cd = code_value
     SET drequest->qual[qual_cnt].components[comp_cnt].description = description
     SET drequest->qual[qual_cnt].components[comp_cnt].component_sequence = cnvtreal(requestin->
      list_0[i].component_sequence)
     SET drequest->qual[qual_cnt].components[comp_cnt].flags = cnvtint(requestin->list_0[i].flags)
    OF "ist":
     SET code_value = 0.0
     SET code_set = 106
     SET code_display = trim(requestin->list_0[i].input_act_type_disp)
     EXECUTE cpm_get_cd_for_disp
     SET activity_type_cd = code_value
     SET code_value = 0.0
     SET temp_mnemonic = trim(requestin->list_0[i].input_cd_mnemonic)
     CALL gettaskassaycode(cnvtreal(requestin->list_0[i].input_cd),activity_type_cd)
     IF (code_value=0)
      CALL log_of_error(5,i,trim(requestin->list_0[i].input_cd_mnemonic))
      GO TO exit_script
     ENDIF
     SET state_cnt = (state_cnt+ 1)
     IF (state_cnt > size(drequest->qual[qual_cnt].states,5))
      SET stat = alterlist(drequest->qual[qual_cnt].states,state_cnt)
     ENDIF
     SET drequest->qual[qual_cnt].states[state_cnt].transition_assay_cd = code_value
     SET code_value = 0.0
     SET source_voc_cd = 0.0
     SET nomen_source_cd = cnvtreal(requestin->list_0[i].nomen_source_cd)
     IF (nomen_source_cd != 0)
      SET code_set1 = 400
      SET temp_code_meaning = trim(requestin->list_0[i].nomen_source_meaning)
      SET temp_code_dk = trim(trim(requestin->list_0[i].nomen_source_dk))
      CALL get_codevalue(nomen_source_cd,code_set1)
      IF (code_value=0)
       CALL log_of_error(6,i,trim(requestin->list_0[i].nomen_source_meaning))
       GO TO exit_script
      ENDIF
      SET source_voc_cd = code_value
     ENDIF
     SET code_value = 0.0
     SET prin_type_cd = 0.0
     SET nomen_prin_cd = cnvtreal(requestin->list_0[i].nomen_prin_cd)
     IF (nomen_prin_cd != 0)
      SET code_set1 = 401
      SET temp_code_meaning = trim(requestin->list_0[i].nomen_prin_meaning)
      SET temp_code_dk = trim(requestin->list_0[i].nomen_prin_dk)
      CALL get_codevalue(nomen_prin_cd,code_set1)
      IF (code_value=0)
       CALL log_of_error(7,i,trim(requestin->list_0[i].nomen_prin_meaning))
       GO TO exit_script
      ENDIF
     ENDIF
     SET prin_type_cd = code_value
     SET nomen_id = 0.0
     IF (source_voc_cd != 0)
      SET temp_source_string = trim(requestin->list_0[i].nomen_source_string)
      SET temp_source_iden = trim(requestin->list_0[i].nomen_source_iden)
      CALL get_nomenclatureid(source_voc_cd,prin_type_cd)
      IF (nomen_id=0)
       CALL log_of_error(8,i,trim(requestin->list_0[i].nomen_source_string))
       GO TO exit_script
      ENDIF
     ENDIF
     SET drequest->qual[qual_cnt].states[state_cnt].nomenclature_id = nomen_id
     SET rnomen_source_cd = cnvtreal(requestin->list_0[i].rnomen_source_cd)
     IF (rnomen_source_cd != 0)
      SET code_value = 0.0
      SET code_set1 = 400
      SET temp_code_meaning = trim(requestin->list_0[i].rnomen_source_meaning)
      SET temp_code_dk = trim(trim(requestin->list_0[i].rnomen_source_dk))
      CALL get_codevalue(rnomen_source_cd,code_set1)
      IF (code_value=0)
       CALL log_of_error(9,i,trim(requestin->list_0[i].rnomen_source_meaning))
       GO TO exit_script
      ENDIF
      SET source_voc_cd = code_value
      SET rnomen_prin_cd = cnvtreal(requestin->list_0[i].rnomen_prin_cd)
      SET code_value = 0.0
      SET code_set1 = 401
      SET temp_code_meaning = trim(requestin->list_0[i].rnomen_prin_meaning)
      SET temp_code_dk = trim(requestin->list_0[i].rnomen_prin_dk)
      CALL get_codevalue(rnomen_prin_cd,code_set1)
      IF (code_value=0)
       CALL log_of_error(10,i,trim(requestin->list_0[i].rnomen_prin_meaning))
       GO TO exit_script
      ENDIF
      SET prin_type_cd = code_value
      SET nomen_id = 0.0
      SET temp_source_string = trim(requestin->list_0[i].rnomen_source_string)
      SET temp_source_iden = trim(requestin->list_0[i].rnomen_source_iden)
      CALL get_nomenclatureid(source_voc_cd,prin_type_cd)
      IF (nomen_id=0)
       CALL log_of_error(11,i,requestin->list_0[i].rnomen_source_string)
       GO TO exit_script
      ENDIF
      SET drequest->qual[qual_cnt].states[state_cnt].result_nomenclature_id = nomen_id
     ENDIF
     SET drequest->qual[qual_cnt].states[state_cnt].state_id = cnvtreal(requestin->list_0[i].state)
     SET drequest->qual[qual_cnt].states[state_cnt].flags = cnvtint(requestin->list_0[i].state_flag)
     SET drequest->qual[qual_cnt].states[state_cnt].numeric_low = cnvtreal(requestin->list_0[i].
      numeric_low)
     SET drequest->qual[qual_cnt].states[state_cnt].numeric_high = cnvtreal(requestin->list_0[i].
      numeric_high)
     SET drequest->qual[qual_cnt].states[state_cnt].resulting_state = cnvtint(requestin->list_0[i].
      resulting_state)
     SET drequest->qual[qual_cnt].states[state_cnt].result_value = cnvtreal(requestin->list_0[i].
      result_value)
   ENDCASE
 ENDFOR
 SELECT INTO "nl:"
  di.dcp_interp_id
  FROM (dummyt d1  WITH seq = value(qual_cnt)),
   dcp_interp di
  PLAN (d1)
   JOIN (di
   WHERE (di.task_assay_cd=drequest->qual[d1.seq].task_assay_cd)
    AND (di.sex_cd=drequest->qual[d1.seq].sex_cd)
    AND (di.service_resource_cd=drequest->qual[d1.seq].service_resource_cd)
    AND (di.age_from_minutes=drequest->qual[d1.seq].age_from_minutes)
    AND (di.age_to_minutes=drequest->qual[d1.seq].age_to_minutes))
  DETAIL
   drequest->qual[d1.seq].dcp_interp_id = di.dcp_interp_id, drequest->qual[d1.seq].updt_cnt = (di
   .updt_cnt+ 1),
   CALL echo(build("dcp_interp_id:",drequest->qual[d1.seq].dcp_interp_id))
  WITH nocounter
 ;end select
 SET interp_id = 0.0
 FOR (i = 1 TO qual_cnt)
   IF ((drequest->qual[i].dcp_interp_id > 0))
    SET interp_id = drequest->qual[i].dcp_interp_id
    UPDATE  FROM dcp_interp i
     SET i.task_assay_cd = drequest->qual[i].task_assay_cd, i.sex_cd = drequest->qual[i].sex_cd, i
      .age_from_minutes = drequest->qual[i].age_from_minutes,
      i.age_to_minutes = drequest->qual[i].age_to_minutes, i.service_resource_cd = drequest->qual[i].
      service_resource_cd, i.updt_cnt = drequest->qual[i].updt_cnt,
      i.updt_dt_tm = cnvtdatetime(curdate,curtime3), i.updt_id = reqinfo->updt_id, i.updt_task =
      reqinfo->updt_task,
      i.updt_applctx = reqinfo->updt_applctx
     WHERE i.dcp_interp_id=interp_id
     WITH nocounter
    ;end update
   ELSE
    SELECT INTO "nl:"
     v = seq(dcp_interp_seq,nextval)
     FROM dual
     DETAIL
      interp_id = cnvtreal(v),
      CALL echo(build("interp_id:",interp_id))
     WITH format, nocounter
    ;end select
    CALL echo(build("interp_id:",interp_id))
    INSERT  FROM dcp_interp i
     SET i.dcp_interp_id = interp_id, i.task_assay_cd = drequest->qual[i].task_assay_cd, i.sex_cd =
      drequest->qual[i].sex_cd,
      i.age_from_minutes = drequest->qual[i].age_from_minutes, i.age_to_minutes = drequest->qual[i].
      age_to_minutes, i.service_resource_cd = drequest->qual[i].service_resource_cd,
      i.updt_cnt = 0, i.updt_dt_tm = cnvtdatetime(curdate,curtime3), i.updt_id = reqinfo->updt_id,
      i.updt_task = reqinfo->updt_task, i.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
   ENDIF
   SET cnt = size(drequest->qual[i].components,5)
   CALL echo(build("count:",cnt))
   FOR (x = 1 TO cnt)
     INSERT  FROM dcp_interp_component ic
      SET ic.dcp_interp_component_id = seq(dcp_interp_seq,nextval), ic.dcp_interp_id = interp_id, ic
       .component_assay_cd = drequest->qual[i].components[x].component_assay_cd,
       ic.component_sequence = drequest->qual[i].components[x].component_sequence, ic.description =
       drequest->qual[i].components[x].description, ic.flags = drequest->qual[i].components[x].flags,
       ic.updt_cnt = 0, ic.updt_dt_tm = cnvtdatetime(curdate,curtime3), ic.updt_id = reqinfo->updt_id,
       ic.updt_task = reqinfo->updt_task, ic.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
   ENDFOR
   SET cnt = size(drequest->qual[i].states,5)
   FOR (x = 1 TO cnt)
     INSERT  FROM dcp_interp_state dis
      SET dis.dcp_interp_state_id = seq(dcp_interp_seq,nextval), dis.dcp_interp_id = interp_id, dis
       .state = drequest->qual[i].states[x].state_id,
       dis.input_assay_cd = drequest->qual[i].states[x].transition_assay_cd, dis.flags = drequest->
       qual[i].states[x].flags, dis.numeric_low = drequest->qual[i].states[x].numeric_low,
       dis.numeric_high = drequest->qual[i].states[x].numeric_high, dis.nomenclature_id = drequest->
       qual[i].states[x].nomenclature_id, dis.result_nomenclature_id = drequest->qual[i].states[x].
       result_nomenclature_id,
       dis.resulting_state = drequest->qual[i].states[x].resulting_state, dis.result_value = drequest
       ->qual[i].states[x].result_value, dis.updt_cnt = 0,
       dis.updt_dt_tm = cnvtdatetime(curdate,curtime3), dis.updt_id = reqinfo->updt_id, dis.updt_task
        = reqinfo->updt_task,
       dis.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
   ENDFOR
 ENDFOR
#exit_script
 IF (success_flag=1)
  SET reqinfo->commit_ind = 1
  SELECT INTO "dcp_imp_inter.log"
   HEAD REPORT
    col 0
   DETAIL
    row + 1, col 0, "Successfully added all the interps "
   WITH nocounter, append, format = variable,
    noformfeed, maxcol = 132, maxrow = 1
  ;end select
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE get_nomenclatureid(source_vocabulary_cd,principle_type_cd)
   SET z = 0
   SET nomen_cnt = size(nomen_list->nomen_qual,5)
   FOR (z = 1 TO nomen_cnt)
     IF ((nomen_list->nomen_qual[z].source_vocabulary_cd=source_vocabulary_cd)
      AND (nomen_list->nomen_qual[z].principle_type_cd=principle_type_cd)
      AND (nomen_list->nomen_qual[z].source_identifier=temp_source_iden)
      AND (nomen_list->nomen_qual[z].source_string=temp_source_string))
      SET nomen_id = nomen_list->nomen_qual[z].nomenclature_id
      SET z = (nomen_cnt+ 1)
     ENDIF
   ENDFOR
   IF (source_vocabulary_cd != 0
    AND principle_type_cd != 0
    AND nomen_id=0)
    SELECT INTO "nl:"
     n.nomenclature_id
     FROM nomenclature n
     WHERE n.source_vocabulary_cd=source_vocabulary_cd
      AND n.principle_type_cd=principle_type_cd
      AND n.source_string=trim(temp_source_string)
     DETAIL
      IF (n.source_identifier=temp_source_iden)
       nomen_id = n.nomenclature_id, nomen_cnt = (nomen_cnt+ 1), stat = alterlist(nomen_list->
        nomen_qual,nomen_cnt),
       nomen_list->nomen_qual[nomen_cnt].source_vocabulary_cd = n.source_vocabulary_cd, nomen_list->
       nomen_qual[nomen_cnt].principle_type_cd = n.principle_type_cd, nomen_list->nomen_qual[
       nomen_cnt].source_string = n.source_string,
       nomen_list->nomen_qual[nomen_cnt].source_identifier = n.source_identifier
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (prin_type_cd=0)
    SET nomen_id = 0.0
   ENDIF
   IF (source_voc_cd=0)
    SET nomen_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE get_codevalue(code_value1,code_set)
   SET b = 0
   SET code_cnt = size(code_list->code_qual,5)
   IF (code_value1 != 0)
    FOR (b = 1 TO code_cnt)
      IF ((code_list->code_qual[b].cdf_meaning=temp_code_meaning)
       AND (code_list->code_qual[b].display_key=temp_code_dk)
       AND (code_list->code_qual[b].code_set=code_set))
       SET code_value = code_list->code_qual[b].code_value
       SET description = code_list->code_qual[b].description
       SET k = (code_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   IF (code_value1 != 0
    AND code_value=0)
    SELECT INTO "nl:"
     cv.code_value
     FROM code_value cv
     WHERE cv.display_key=trim(temp_code_dk)
      AND cv.code_set=code_set
     DETAIL
      code_value = cv.code_value, description = cv.description, code_cnt = (code_cnt+ 1),
      stat = alterlist(code_list->code_qual,code_cnt), code_list->code_qual[code_cnt].code_value = cv
      .code_value, code_list->code_qual[code_cnt].cdf_meaning = cv.cdf_meaning,
      code_list->code_qual[code_cnt].display_key = cv.display_key, code_list->code_qual[code_cnt].
      description = cv.description, code_list->code_qual[code_cnt].code_set = cv.code_set
     WITH nocounter
    ;end select
    CALL echo(build("code_value",code_value))
    CALL echo(build("code_set",code_set))
   ELSEIF (code_value1=0)
    SET code_value = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_for_interpid(interp_id)
   SET temp_interp_id = 0.0
   SET temp_cnt = size(drequest->qual,5)
   SET a = 0
   FOR (a = 1 TO temp_cnt)
     IF ((drequest->qual[a].temp_interp_id=cnvtreal(interp_id)))
      SET qual_cnt = a
      SET temp_interp_id = drequest->qual[a].temp_interp_id
      SET a = (temp_cnt+ 1)
     ENDIF
   ENDFOR
   IF (temp_interp_id=0)
    SET qual_cnt = temp_cnt
   ENDIF
 END ;Subroutine
 SUBROUTINE gettaskassaycode(task_assay_cd1,activity_type_cd)
   SET c = 0
   SET task_assay_cnt = size(task_assay_list->task_assay_qual,5)
   IF (task_assay_cd1 != 0)
    FOR (c = 1 TO task_assay_cnt)
      IF ((task_assay_list->task_assay_qual[c].mnemonic=temp_mnemonic)
       AND (task_assay_list->task_assay_qual[c].activity_type_cd=activity_type_cd))
       SET code_value = task_assay_list->task_assay_qual[c].task_assay_cd
       SET description = task_assay_list->task_assay_qual[c].desc
       SET k = (task_assay_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   IF (task_assay_cd1 != 0
    AND code_value=0)
    SELECT INTO "nl:"
     FROM discrete_task_assay dta
     WHERE dta.mnemonic=trim(temp_mnemonic)
      AND dta.activity_type_cd=activity_type_cd
     DETAIL
      code_value = dta.task_assay_cd, task_assay_cnt = (task_assay_cnt+ 1), stat = alterlist(
       task_assay_list->task_assay_qual,task_assay_cnt),
      task_assay_list->task_assay_qual[task_assay_cnt].task_assay_cd = dta.task_assay_cd,
      task_assay_list->task_assay_qual[task_assay_cnt].mnemonic = dta.mnemonic, task_assay_list->
      task_assay_qual[task_assay_cnt].desc = dta.description,
      task_assay_list->task_assay_qual[task_assay_cnt].activity_type_cd = dta.activity_type_cd
     WITH nocounter
    ;end select
   ELSEIF (task_assay_cd1=0)
    SET code_value = 0.0
   ENDIF
   CALL echo(build("task assaycode:",code_value))
 END ;Subroutine
 SUBROUTINE log_of_error(etype,evar,val)
  SET success_flag = 0
  SELECT INTO "dcp_imp_interp.log"
   evar
   HEAD REPORT
    resultname = concat(trim(val),"                         ")
   DETAIL
    IF (etype=1)
     row + 1, col 0, "Invalid sex Code",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=2)
     row + 1, col 0, "Invalid Service Code ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=3)
     row + 1, col 0, "Invalid Task assay Code ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=4)
     row + 1, col 0, "Invalid Comp Assay Cd",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=5)
     row + 1, col 0, "Invalid transition_assay_cd",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=6)
     row + 1, col 0, "Invalid Input source voc cd ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=7)
     row + 1, col 0, "Invalid Input Prin mean cd ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=8)
     row + 1, col 0, "Invalid Input Source String ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=9)
     row + 1, col 0, "Invalid output source cd ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=10)
     row + 1, col 0, "Invalid output prin mean cd ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
    IF (etype=11)
     row + 1, col 0, "Invalid output source string ",
     resultname, row + 1, col 0,
     "Row #: ", evar
    ENDIF
   WITH nocounter, append, format = variable,
    noformfeed, maxcol = 132, maxrow = 1
  ;end select
 END ;Subroutine
END GO
