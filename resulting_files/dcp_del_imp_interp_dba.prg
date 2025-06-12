CREATE PROGRAM dcp_del_imp_interp:dba
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
 )
 RECORD code_list(
   1 code_qual[*]
     2 code_value = f8
     2 description = vc
     2 cdf_meaning = vc
     2 cki = vc
     2 display_key = vc
 )
 RECORD task_assay_list(
   1 task_assay_qual[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 desc = vc
     2 activity_type_cd = f8
 )
 DECLARE interp_id = f8 WITH public, noconstant(0.0)
 DECLARE temp_interp_id = f8 WITH public, noconstant(0.0)
 DECLARE sex_cd = f8 WITH public, noconstant(0.0)
 DECLARE sour_cd = f8 WITH public, noconstant(0.0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 SET cnt = size(requestin->list_0,5)
 IF (cnt=0)
  SET failed = 1
  GO TO exit_script
 ENDIF
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 SET task_assay_cki = fillstring(120," ")
 SET descrption = fillstring(120," ")
 SET qual_cnt = 0
 SET comp_cnt = 0
 SET state_cnt = 0
 SET stat = 0
 SET i = 0
 SET j = 0
 SET temp_code_meaning = fillstring(80," ")
 SET temp_code_dk = fillstring(50," ")
 SET temp_mnemonic = fillstring(100," ")
 SET code_display = fillstring(50," ")
 SET code_set = 0
 SET activity_type_cd = 0.0
 SET rvar = 0
 SELECT INTO "dcp_imp_interp.log"
  rvar
  HEAD REPORT
   row + 1, col 0, curdate"dd-mmm-yyyy;;d",
   "-", curtime"hh:mm;;m", col + 1,
   "Interp delete entry Import Log"
  DETAIL
   col 0
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 FOR (i = 1 TO cnt)
   SET temp_interp_id = 0
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
    SET code_value = 0
    SET sex_cd = cnvtreal(requestin->list_0[i].sex_cd)
    IF (sex_cd != 0)
     SET temp_code_meaning = trim(requestin->list_0[i].sex_cd_meaning)
     SET temp_code_dk = trim(requestin->list_0[i].sex_cd_dk)
     CALL get_codevalue(sex_cd,57)
     SET drequest->qual[qual_cnt].sex_cd = code_value
     IF (code_value=0)
      CALL log_of_error(1,i,requestin->list_0[i].sex_cd_meaning)
      GO TO exit_script
     ENDIF
    ENDIF
    SET code_value = 0
    SET sour_cd = cnvtreal(requestin->list_0[i].sour_cd)
    IF (sour_cd != 0)
     SET temp_code_meaning = trim(requestin->list_0[i].sour_cd_meaning)
     SET temp_code_dk = trim(requestin->list_0[i].sour_cd_dk)
     CALL get_codevalue(sour_cd,221)
     SET drequest->qual[qual_cnt].service_resource_cd = code_value
     IF (code_value=0)
      CALL log_of_error(2,i,requestin->list_0[i].sour_cd_meaning)
      GO TO exit_script
     ENDIF
    ENDIF
    SET drequest->qual[qual_cnt].age_from_minutes = cnvtreal(requestin->list_0[i].age_from_minutes)
    SET drequest->qual[qual_cnt].age_to_minutes = cnvtreal(requestin->list_0[i].age_to_minutes)
    SET code_value = 0
    SET code_set = 106
    SET code_display = trim(requestin->list_0[i].task_act_type_disp)
    EXECUTE cpm_get_cd_for_disp
    SET activity_type_cd = code_value
    SET code_value = 0
    SET temp_mnemonic = trim(requestin->list_0[i].task_assay_mnemonic)
    CALL gettaskassaycode(cnvtreal(requestin->list_0[i].task_assay_cd),activity_type_cd)
    CALL echo(build("code_value:",code_value))
    IF (code_value=0)
     CALL log_of_error(3,i,requestin->list_0[i].task_assay_mnemonic)
     GO TO exit_script
    ENDIF
    SET drequest->qual[qual_cnt].task_assay_cd = code_value
   ENDIF
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
   drequest->qual[d1.seq].dcp_interp_id = di.dcp_interp_id,
   CALL echo(build("dcp_interp_id:",drequest->qual[d1.seq].dcp_interp_id))
  WITH nocounter
 ;end select
 FOR (i = 1 TO qual_cnt)
   IF ((drequest->qual[i].dcp_interp_id > 0))
    SET interp_id = drequest->qual[i].dcp_interp_id
    DELETE  FROM dcp_interp_component ic
     WHERE ic.dcp_interp_id=interp_id
     WITH nocounter
    ;end delete
    DELETE  FROM dcp_interp_state s
     WHERE s.dcp_interp_id=interp_id
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
#exit_script
 IF (failed=1)
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SUBROUTINE get_codevalue(code_value1,code_set)
   SET b = 0
   SET code_cnt = size(code_list->code_qual,5)
   IF (code_value1 != 0)
    FOR (b = 1 TO code_cnt)
      IF ((code_list->code_qual[b].cki=cki)
       AND (code_list->code_qual[b].cdf_meaning=temp_code_meaning)
       AND (code_list->code_qual[b].display_key=temp_code_dk))
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
      description = cv.description, code_list->code_qual[code_cnt].cki = cv.cki
     WITH nocounter
    ;end select
   ELSEIF (code_value1=0)
    SET code_value = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE gettaskassaycode(task_assay_cd1,activity_type_cd)
   SET task_assay_cnt = size(task_assay_list->task_assay_qual,5)
   SET c = 0
   IF (task_assay_cd1 != 0)
    FOR (c = 1 TO task_assay_cnt)
      IF ((task_assay_list->task_assay_qual[c].mnemonic=mnemonic)
       AND (task_assay_list->task_assay_qual[c].activity_type_cd=activity_type_cd))
       SET code_value = task_assay_list->task_assay_qual[c].task_assay_cd
       SET description = task_assay_list->task_assay_qual[c].desc
       SET k = (task_assay_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   IF (code_value=0)
    SELECT INTO "nl:"
     dta.task_assay_cd
     FROM discrete_task_assay dta
     WHERE dta.mnemonic=trim(mnemonic)
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
   ENDIF
   IF (task_assay_cd1=0)
    SET code_value = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_for_interpid(interp_id)
   SET temp_interp_id = 0
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
 SUBROUTINE log_of_error(etype,evar,val)
   SET success_flag = 0
   SELECT INTO "dcp_imp_interp.log"
    evar
    HEAD REPORT
     resultname = concat(trim(val),"                         ")
    DETAIL
     IF (etype=1)
      row + 1, col 0, "delete - Invalid sex Code",
      resultname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=2)
      row + 1, col 0, "delete - Invalid Service Code ",
      resultname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=3)
      row + 1, col 0, "delete - Invalid Task assay Code ",
      resultname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
     IF (etype=4)
      row + 1, col 0, "delete - Invalid Comp Assay Cd",
      resultname, row + 1, col 0,
      "Row #: ", evar
     ENDIF
    WITH nocounter, append, format = variable,
     noformfeed, maxcol = 132, maxrow = 1
   ;end select
   SET failed = 1
 END ;Subroutine
END GO
