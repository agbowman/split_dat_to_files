CREATE PROGRAM bed_imp_sla:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET sla
 RECORD sla(
   1 sla_cnt = i4
   1 sla[*]
     2 sla_id = f8
     2 mnemonic = vc
     2 description = vc
     2 beg_dt = dq8
     2 end_dt = dq8
     2 encounter_type_cnt = i4
     2 medical_service_cnt = i4
     2 service_category_cnt = i4
     2 new_followup_cnt = i4
     2 admit_type_cnt = i4
     2 qual_cnt = i4
     2 row_num = i4
     2 action_flag = i2
     2 error_string = vc
     2 qual[*]
       3 qual = vc
       3 qual_cd = f8
       3 qual_type = vc
       3 qual_type_cd = f8
       3 row_num = i4
       3 action_flag = i2
       3 error_string = vc
       3 admit_type_cnt = i4
 )
 FREE SET str_data
 RECORD str_data(
   1 str_qual = c1
 )
#1000_initialize
 SET write_mode = 0
 IF ((tempreq->insert_ind="Y"))
  SET write_mode = 1
 ENDIF
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 DECLARE error_msg = vc
 DECLARE begin_dt_tm = dq8 WITH constant(cnvtdatetime(curdate,curtime3))
 DECLARE end_dt_tm = dq8 WITH constant(cnvtdatetime("31-dec-2100 00:00:00"))
 SET active_cd = get_code_value(48,"ACTIVE")
 SET auth_cd = get_code_value(8,"AUTH")
 SET encounter_type_qual = get_code_value(27118,"ENCNTRTYPE")
 SET medical_service_qual = get_code_value(27118,"MEDSERVICE")
 SET service_category_qual = get_code_value(27118,"SERVCAT")
 SET admit_type_qual = get_code_value(27118,"ADMITTYPE")
 SET new_followup_qual = get_code_value(27118,"APPTTYPECLSS")
 SET sla_benefit_type = get_code_value(26307,"SLA")
 SET double_data_type = get_code_value(27103,"DOUBLE")
 SET parent_table_data_type = get_code_value(27103,"PARENT")
 SET numrows = size(requestin->list_0,5)
 SET stat = alterlist(sla->sla,0)
 SET sla->sla_cnt = 0
 IF (numrows=0)
  SET error_msg = "No rows to process"
  GO TO exit_script
 ENDIF
 SET title = validate(log_title_set,"SLA Load Log File")
 SET name = validate(log_name_set,"bed_sla.log")
 SET status = validate(log_col_set,"STATUS")
 SET alt_mode = validate(alt_mode_set,0)
 SET alt_detail = validate(alt_detail_set,0)
 CALL logstart(title,name)
 FOR (i = 1 TO numrows)
   SET exists_id = 0
   FOR (ii = 1 TO sla->sla_cnt)
     IF (cnvtupper(sla->sla[ii].mnemonic)=cnvtupper(requestin->list_0[i].sla_mnemonic))
      SET exists_id = ii
     ENDIF
   ENDFOR
   IF (exists_id=0)
    SET sla->sla_cnt = (sla->sla_cnt+ 1)
    SET stat = alterlist(sla->sla,sla->sla_cnt)
    SET exists_id = sla->sla_cnt
    SET sla->sla[exists_id].row_num = i
    SET sla->sla[exists_id].mnemonic = requestin->list_0[i].sla_mnemonic
    SET sla->sla[exists_id].description = requestin->list_0[i].sla_description
    IF ((requestin->list_0[i].beg_dt != ""))
     SET tempdate = format_date(requestin->list_0[i].beg_dt)
     SET sla->sla[exists_id].beg_dt = cnvtdate2(tempdate,"DD/MM/YYYY")
    ELSE
     SET sla->sla[exists_id].beg_dt = cnvtdate(curdate)
    ENDIF
    IF ((requestin->list_0[i].end_dt != ""))
     SET tempdate = format_date(requestin->list_0[i].end_dt)
     SET sla->sla[exists_id].end_dt = cnvtdate2(tempdate,"DD/MM/YYYY")
    ELSE
     SET sla->sla[exists_id].end_dt = cnvtdate2("12/31/2100","MM/DD/YYYY")
    ENDIF
    SELECT INTO "NL:"
     FROM eem_benefit eb
     PLAN (eb
      WHERE cnvtupper(eb.mnemonic)=cnvtupper(sla->sla[exists_id].mnemonic)
       AND eb.active_ind=1)
     DETAIL
      sla->sla[exists_id].sla_id = eb.eem_benefit_id, sla->sla[exists_id].action_flag = 2
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET sla->sla[exists_id].action_flag = 1
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].encounter_type != ""))
    IF ((sla->sla[exists_id].encounter_type_cnt < 1))
     SET sla->sla[exists_id].encounter_type_cnt = (sla->sla[exists_id].encounter_type_cnt+ 1)
     SET sla->sla[exists_id].qual_cnt = (sla->sla[exists_id].qual_cnt+ 1)
     SET stat = alterlist(sla->sla[exists_id].qual,sla->sla[exists_id].qual_cnt)
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type = "ENCOUNTER TYPE"
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd = encounter_type_qual
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual = requestin->list_0[i].
     encounter_type
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].row_num = i
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd = get_cv_by_disp(71,sla->sla[
      exists_id].qual[sla->sla[exists_id].qual_cnt].qual)
     IF ((sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd=0))
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Invalid"
     ELSEIF ((sla->sla[exists_id].sla_id > 0))
      SELECT INTO "NL:"
       FROM eem_benefit_qual ebq
       PLAN (ebq
        WHERE (ebq.benefit_id=sla->sla[exists_id].sla_id)
         AND (ebq.qualifier_cd=sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd)
         AND ebq.active_ind=1)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
      ELSE
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Already Exists"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].medical_service != ""))
    IF ((sla->sla[exists_id].medical_service_cnt < 1))
     SET sla->sla[exists_id].medical_service_cnt = (sla->sla[exists_id].medical_service_cnt+ 1)
     SET sla->sla[exists_id].qual_cnt = (sla->sla[exists_id].qual_cnt+ 1)
     SET stat = alterlist(sla->sla[exists_id].qual,sla->sla[exists_id].qual_cnt)
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual = requestin->list_0[i].
     medical_service
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].row_num = i
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type = "MEDICAL SERVICE"
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd = medical_service_qual
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd = get_cv_by_disp(34,sla->sla[
      exists_id].qual[sla->sla[exists_id].qual_cnt].qual)
     IF ((sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd=0))
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Invalid"
     ELSEIF ((sla->sla[exists_id].sla_id > 0))
      SELECT INTO "NL:"
       FROM eem_benefit_qual ebq
       PLAN (ebq
        WHERE (ebq.benefit_id=sla->sla[exists_id].sla_id)
         AND (ebq.qualifier_cd=sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd)
         AND ebq.active_ind=1)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
      ELSE
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Already Exists"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].service_category != ""))
    IF ((sla->sla[exists_id].service_category_cnt < 1))
     SET sla->sla[exists_id].service_category_cnt = (sla->sla[exists_id].service_category_cnt+ 1)
     SET sla->sla[exists_id].qual_cnt = (sla->sla[exists_id].qual_cnt+ 1)
     SET stat = alterlist(sla->sla[exists_id].qual,sla->sla[exists_id].qual_cnt)
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type = "SERVICE CATEGORY"
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd = service_category_qual
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual = requestin->list_0[i].
     service_category
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].row_num = i
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd = get_cv_by_disp(3394,sla->
      sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual)
     IF ((sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd=0))
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Invalid"
     ELSEIF ((sla->sla[exists_id].sla_id > 0))
      SELECT INTO "NL:"
       FROM eem_benefit_qual ebq
       PLAN (ebq
        WHERE (ebq.benefit_id=sla->sla[exists_id].sla_id)
         AND (ebq.qualifier_cd=sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd)
         AND ebq.active_ind=1)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
      ELSE
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Already Exists"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].admit_type != ""))
    SET sla->sla[exists_id].qual_cnt = (sla->sla[exists_id].qual_cnt+ 1)
    SET stat = alterlist(sla->sla[exists_id].qual,sla->sla[exists_id].qual_cnt)
    SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
    SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].admit_type_cnt = sla->sla[exists_id].
    admit_type_cnt
    SET sla->sla[exists_id].admit_type_cnt = (sla->sla[exists_id].admit_type_cnt+ 1)
    FOR (ii = 1 TO (sla->sla[exists_id].qual_cnt - 1))
      IF (cnvtupper(sla->sla[exists_id].qual[ii].qual)=cnvtupper(requestin->list_0[i].admit_type))
       IF ((sla->sla[exists_id].qual[ii].qual_type_cd=admit_type_qual))
        SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
        SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string =
        "Previously Defined"
       ENDIF
      ENDIF
    ENDFOR
    SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type = "ADMIT TYPE"
    SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd = admit_type_qual
    SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual = requestin->list_0[i].admit_type
    SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].row_num = i
    IF ((sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag != - (1)))
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd = get_cv_by_disp(3,sla->sla[
      exists_id].qual[sla->sla[exists_id].qual_cnt].qual)
     IF ((sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd=0))
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Invalid"
     ELSEIF ((sla->sla[exists_id].sla_id > 0))
      SELECT INTO "NL:"
       FROM eem_benefit_qual ebq
       PLAN (ebq
        WHERE (ebq.benefit_id=sla->sla[exists_id].sla_id)
         AND (ebq.qualifier_cd=sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd)
         AND (ebq.double_value=sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd)
         AND ebq.active_ind=1)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
      ELSE
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Already Exists"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF ((requestin->list_0[i].new_followup != ""))
    IF ((sla->sla[exists_id].new_followup_cnt < 1))
     SET sla->sla[exists_id].new_followup_cnt = (sla->sla[exists_id].new_followup_cnt+ 1)
     SET sla->sla[exists_id].qual_cnt = (sla->sla[exists_id].qual_cnt+ 1)
     SET stat = alterlist(sla->sla[exists_id].qual,sla->sla[exists_id].qual_cnt)
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type = "NEW/FU"
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd = new_followup_qual
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual = requestin->list_0[i].
     new_followup
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].row_num = i
     SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd = get_cv_by_disp(23058,sla->
      sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual)
     IF ((sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_cd=0))
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
      SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Invalid"
     ELSEIF ((sla->sla[exists_id].sla_id > 0))
      SELECT INTO "NL:"
       FROM eem_benefit_qual ebq
       PLAN (ebq
        WHERE (ebq.benefit_id=sla->sla[exists_id].sla_id)
         AND (ebq.qualifier_cd=sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].qual_type_cd)
         AND ebq.active_ind=1)
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = 1
      ELSE
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].action_flag = - (1)
       SET sla->sla[exists_id].qual[sla->sla[exists_id].qual_cnt].error_string = "Already Exists"
      ENDIF
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (write_mode=1)
  FOR (i = 1 TO sla->sla_cnt)
   IF ((sla->sla[i].action_flag=1))
    SELECT INTO "NL:"
     nextseqnum = seq(eem_seq,nextval)"##################;RP0"
     FROM dual
     DETAIL
      sla->sla[i].sla_id = nextseqnum
     WITH nocounter, format
    ;end select
    INSERT  FROM eem_benefit eb
     SET eb.eem_benefit_id = sla->sla[i].sla_id, eb.mnemonic = sla->sla[i].mnemonic, eb.mnemonic_key
       = trim(cnvtupper(sla->sla[i].mnemonic)),
      eb.description = sla->sla[i].description, eb.info_text_id = 0.00, eb.benefit_type_cd =
      sla_benefit_type,
      eb.double_value = 0.00, eb.units_cd = 0.00, eb.long_text_id = 0.00,
      eb.data_type_cd = double_data_type, eb.cost_per_case = 0.00, eb.cost_per_bed_day = 0.00,
      eb.nbr_pat_agreed = 0.00, eb.rvu_amnt = 0.00, eb.local_rvu = 0.00,
      eb.national_rvu = 0.00, eb.variance_level = 0.00, eb.active_ind = 1,
      eb.active_status_cd = active_cd, eb.active_status_dt_tm = cnvtdatetime(curdate,curtime3), eb
      .active_status_prsnl_id = reqinfo->updt_id,
      eb.beg_effective_dt_tm = cnvtdate(sla->sla[i].beg_dt), eb.end_effective_dt_tm = cnvtdate(sla->
       sla[i].end_dt), eb.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      eb.updt_id = reqinfo->updt_id, eb.updt_task = reqinfo->updt_task, eb.updt_applctx = reqinfo->
      updt_applctx,
      eb.updt_cnt = 0
     WITH nocounter
    ;end insert
   ENDIF
   FOR (ii = 1 TO sla->sla[i].qual_cnt)
     IF ((sla->sla[i].qual[ii].action_flag=1))
      INSERT  FROM eem_benefit_qual ebq
       SET ebq.benefit_qual_id = seq(eem_seq,nextval), ebq.benefit_id = sla->sla[i].sla_id, ebq
        .qualifier_cd = sla->sla[i].qual[ii].qual_type_cd,
        ebq.seq_nbr = sla->sla[i].qual[ii].admit_type_cnt, ebq.data_type_cd = parent_table_data_type,
        ebq.double_value = sla->sla[i].qual[ii].qual_cd,
        ebq.parent_entity_name = "CODE_VALUE", ebq.parent_entity_id = sla->sla[i].qual[ii].qual_cd,
        ebq.from_units = 0.00,
        ebq.from_units_cd = 0.00, ebq.to_units = 0.00, ebq.to_units_cd = 0.00,
        ebq.inc_exc_cd = 0.00, ebq.vocabulary_cd = 0.00, ebq.beg_nomen_id = 0.00,
        ebq.end_nomen_id = 0.00, ebq.long_text_id = 0.00, ebq.active_ind = 1,
        ebq.active_status_cd = active_cd, ebq.active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        ebq.active_status_prsnl_id = reqinfo->updt_id,
        ebq.beg_effective_dt_tm = cnvtdate(sla->sla[i].beg_dt), ebq.end_effective_dt_tm = cnvtdate(
         sla->sla[i].end_dt), ebq.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ebq.updt_id = reqinfo->updt_id, ebq.updt_task = reqinfo->updt_task, ebq.updt_applctx =
        reqinfo->updt_applctx,
        ebq.updt_cnt = 0
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 SELECT INTO value(name)
  FROM (dummyt d  WITH seq = sla->sla_cnt)
  DETAIL
   col 1, sla->sla[d.seq].row_num"#####", col 10,
   sla->sla[d.seq].mnemonic
   IF ((sla->sla[d.seq].action_flag=1))
    col 90, "ADDED"
   ELSEIF ((sla->sla[d.seq].action_flag=- (1)))
    col 90, "ERROR"
   ENDIF
   col 100, sla->sla[d.seq].error_string, row + 1
   FOR (i = 1 TO sla->sla[d.seq].qual_cnt)
     col 1, sla->sla[d.seq].qual[i].row_num"#####", col 20,
     sla->sla[d.seq].qual[i].qual_type, col 50, sla->sla[d.seq].qual[i].qual
     IF ((sla->sla[d.seq].qual[i].action_flag=1))
      col 90, "ADDED"
     ELSEIF ((sla->sla[d.seq].qual[i].action_flag=- (1)))
      col 90, "ERROR"
     ENDIF
     col 100, sla->sla[d.seq].qual[i].error_string, row + 1
   ENDFOR
  WITH nocounter, append, format = variable,
   noformfeed, maxcol = 132, maxrow = 1
 ;end select
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 RETURN
 SUBROUTINE logstart(xtitle,xname)
   DECLARE dir_name = vc
   SET dir_name = "ccluserdir:"
   SET log_name = concat(trim(dir_name),xname)
   SET logvar = 0
   SELECT INTO value(log_name)
    logvar
    HEAD REPORT
     begin_dt_tm"dd-mmm-yyyy;;d", "-", begin_dt_tm"hh:mm:ss;;m",
     col + 1, xtitle, row + 1
     IF (write_mode=0)
      col 30, "AUDIT MODE: NO CHANGES HAVE BEEN MADE TO THE DATABASE"
     ELSE
      col 30, "COMMIT MODE: CHANGES HAVE BEEN MADE TO THE DATABASE"
     ENDIF
    DETAIL
     row + 2, col 2, "ROW",
     col 10, "SLA", col 20,
     "QUALIFIER TYPE", col 50, "DETAIL",
     col 90, "STATUS", col 100,
     "ERROR"
    WITH nocounter, format = variable, noformfeed,
     maxcol = 132, maxrow = 1
   ;end select
   RETURN
 END ;Subroutine
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE get_cv_by_disp(xcodeset,xdisp)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND cnvtupper(c.display)=trim(cnvtupper(xdisp)))
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
 SUBROUTINE format_date(x)
   SET fdate = "00/00/0000"
   IF (substring(2,1,x)="/")
    SET fdate = build("0",x)
   ENDIF
   IF (substring(5,1,fdate)="/")
    SET fdate = build(substring(1,3,fdate),"0",substring(4,6,fdate))
   ENDIF
   IF (fdate="00/00/0000")
    SET fdate = x
   ENDIF
   RETURN(fdate)
 END ;Subroutine
END GO
