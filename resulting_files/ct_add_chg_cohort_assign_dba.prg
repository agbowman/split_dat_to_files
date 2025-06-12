CREATE PROGRAM ct_add_chg_cohort_assign:dba
 RECORD reply(
   1 reg_status = c1
   1 assign_reg_reltn_id = f8
   1 elig_status = c1
   1 assign_elig_reltn_id = f8
   1 coh_status = c1
   1 strat_status = c1
   1 scs_funcstatus = c1
   1 statusfunc = c1
   1 a_c_results[*]
     2 a_key = vc
     2 stratumstatus = c1
     2 prot_stratum_id = f8
     2 stratum_id = f8
     2 suspsummary = c1
     2 cohortsummary = c1
     2 susps[*]
       3 a_key = vc
       3 suspstatus = c1
       3 prot_stratum_susp_id = f8
       3 susp_id = f8
     2 cohorts[*]
       3 a_key = vc
       3 cohortstatus = c1
       3 prot_cohort_id = f8
       3 cohort_id = f8
   1 probdesc[*]
     2 str = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 debug[*]
     2 str = vc
 )
 RECORD old(
   1 curdatetime = dq8
   1 cohort_id = f8
   1 assign_id = f8
   1 stratum_id = f8
   1 cohort_label = vc
   1 stratum_cohort_type_cd = f8
 )
 RECORD audit(
   1 list[*]
     2 eventname = vc
     2 eventtype = vc
 )
 DECLARE audit_mode = i2 WITH protect, constant(0)
 DECLARE lst_updt_dt_tm = vc WITH protect, noconstant("")
 DECLARE field_name = vc WITH protect, noconstant("")
 DECLARE assgn_id = f8 WITH protect, noconstant(0.0)
 DECLARE assgn_id_audit = vc WITH protect, noconstant("")
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE cohort_label_new = vc WITH protect, noconstant("")
 DECLARE list_ind = i2 WITH protect, noconstant(0)
 DECLARE current_date = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
 DECLARE stratum_cohort_type_cd = f8 WITH protect, noconstant(0.0)
 SET false = 0
 SET true = 1
 SET continue = false
 SET reply->status_data.status = "F"
 SET reply->reg_status = "Z"
 SET reply->elig_status = "Z"
 SET reply->coh_status = "F"
 SET reply->strat_status = "F"
 SET assignregreltnid = 0.0
 SET assigneligreltnid = 0.0
 SET cohort_open = 0.0
 SET stratum_open = 0.0
 SET parentstratumid = 0.0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET cset = 18778
 SET cmean = "OPEN"
 EXECUTE ct_get_cv
 SET cohort_open = cval
 SET stat = alterlist(audit->list,0)
 CALL echo(build("COHORT_OPEN  = ",cohort_open))
 IF ((request->cohort_id > 0))
  CALL echo("1")
  SELECT INTO "NL:"
   FROM prot_cohort coh
   WHERE (coh.cohort_id=request->cohort_id)
    AND coh.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND coh.cohort_status_cd=cohort_open
   DETAIL
    request->stratum_id = coh.stratum_id, cohort_label_new = coh.cohort_label
   WITH counter
  ;end select
  IF (curqual=1)
   SET reply->coh_status = "O"
   SET cset = 18775
   SET cmean = "OPEN"
   EXECUTE ct_get_cv
   SET stratum_open = cval
   CALL echo("2")
   SELECT INTO "NL:"
    FROM prot_stratum strat
    WHERE (strat.stratum_id=request->stratum_id)
     AND strat.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND strat.stratum_status_cd=stratum_open
    WITH counter
   ;end select
   IF (curqual=1)
    SET reply->strat_status = "O"
    SET continue = true
    CALL echo("3")
   ELSE
    IF ((request->pt_elig_tracking_id > 0))
     SET continue = false
     SET assigncount = 0
     SELECT INTO "nl:"
      FROM assign_elig_reltn a_e
      WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
       AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      DETAIL
       assigncount += 1
      WITH counter
     ;end select
     IF (curqual=1)
      SET continue = true
      SET reply->strat_status = "O"
     ELSE
      SET reply->strat_status = "C"
      SET continue = false
     ENDIF
    ELSE
     CALL echo("4")
     SET reply->strat_status = "C"
     SET continue = false
    ENDIF
   ENDIF
  ELSE
   CALL echo("5")
   IF ((request->pt_elig_tracking_id > 0))
    SET continue = false
    SET assigncount = 0
    SELECT INTO "nl:"
     FROM assign_elig_reltn a_e
     WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
      AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      assigncount += 1
     WITH counter
    ;end select
    IF (curqual=1)
     SET continue = true
     SET reply->coh_status = "O"
     SET reply->strat_status = "Z"
    ELSE
     SET reply->coh_status = "C"
     SET reply->strat_status = "Z"
     SET continue = false
    ENDIF
   ELSE
    SET reply->coh_status = "C"
    SET reply->strat_status = "Z"
    SET continue = false
   ENDIF
  ENDIF
  IF (continue=true)
   CALL echo("6")
   IF ((request->reg_id > 0))
    SET continue = false
    CALL echo("7")
    SELECT INTO "nl:"
     a_r.*
     FROM assign_reg_reltn a_r
     WHERE (a_r.reg_id=request->reg_id)
      AND a_r.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      old->curdatetime = cnvtdatetime(sysdate), old->cohort_id = a_r.cohort_id, old->assign_id = a_r
      .assign_reg_reltn_id
     WITH counter, forupdate(a_r)
    ;end select
    IF (curqual=1)
     IF ((old->cohort_id != request->cohort_id))
      CALL echo("8")
      UPDATE  FROM assign_reg_reltn a_r
       SET a_r.end_effective_dt_tm = cnvtdatetime(old->curdatetime), a_r.updt_cnt = (a_r.updt_cnt+ 1),
        a_r.updt_applctx = reqinfo->updt_applctx,
        a_r.updt_task = reqinfo->updt_task, a_r.updt_id = reqinfo->updt_id, a_r.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE (a_r.assign_reg_reltn_id=old->assign_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET reply->reg_status = "F"
      ELSE
       CALL echo("9")
       SELECT INTO "nl:"
        num = seq(protocol_def_seq,nextval)"########################;rpO"
        FROM dual
        DETAIL
         assignregreltnid = cnvtreal(num)
        WITH format, counter
       ;end select
       SET continue = true
       CALL echo("10")
      ENDIF
     ENDIF
    ELSE
     CALL echo("11")
     SET old->curdatetime = cnvtdatetime(sysdate)
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)"########################;rpO"
      FROM dual
      DETAIL
       assignregreltnid = cnvtreal(num)
      WITH format, counter
     ;end select
     SET continue = true
     CALL echo("12")
    ENDIF
    IF (continue=true)
     CALL echo("13")
     SET current_date = cnvtdatetime(sysdate)
     INSERT  FROM assign_reg_reltn a_r
      SET a_r.assign_reg_reltn_id = assignregreltnid, a_r.cohort_id = request->cohort_id, a_r.reg_id
        = request->reg_id,
       a_r.beg_effective_dt_tm = cnvtdatetime(old->curdatetime), a_r.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00.00"), a_r.updt_cnt = 0,
       a_r.updt_applctx = reqinfo->updt_applctx, a_r.updt_task = reqinfo->updt_task, a_r.updt_id =
       reqinfo->updt_id,
       a_r.updt_dt_tm = cnvtdatetime(current_date)
      WITH nocounter
     ;end insert
     IF (curqual=1)
      SET reply->reg_status = "S"
      SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(cnvtdatetime(current_date),0,
        "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
      SET field_name = "ASSIGN_REG_RELTN_ID : "
      SET assgn_id = assignregreltnid
      SET reply->assign_elig_reltn_id = assignregreltnid
      CALL echo("14")
     ELSE
      SET reply->reg_status = "F"
      CALL echo("15")
     ENDIF
    ENDIF
   ENDIF
   IF ((request->pt_elig_tracking_id > 0))
    CALL echo("16")
    SET continue = false
    SELECT INTO "nl:"
     a_e.*
     FROM assign_elig_reltn a_e
     WHERE (a_e.pt_elig_tracking_id=request->pt_elig_tracking_id)
      AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     DETAIL
      old->curdatetime = cnvtdatetime(sysdate), old->cohort_id = a_e.cohort_id, old->assign_id = a_e
      .assign_elig_reltn_id
     WITH counter, forupdate(a_e)
    ;end select
    CALL echo("17")
    IF (curqual=1)
     CALL echo("18")
     IF ((old->cohort_id != request->cohort_id))
      CALL echo("19")
      UPDATE  FROM assign_elig_reltn a_e
       SET a_e.end_effective_dt_tm = cnvtdatetime(old->curdatetime), a_e.updt_cnt = (a_e.updt_cnt+ 1),
        a_e.updt_applctx = reqinfo->updt_applctx,
        a_e.updt_task = reqinfo->updt_task, a_e.updt_id = reqinfo->updt_id, a_e.updt_dt_tm =
        cnvtdatetime(sysdate)
       WHERE (a_e.assign_elig_reltn_id=old->assign_id)
       WITH nocounter
      ;end update
      IF (curqual=0)
       SET reply->elig_status = "F"
      ELSE
       CALL echo("201")
       SELECT INTO "nl:"
        num = seq(protocol_def_seq,nextval)"########################;rpO"
        FROM dual
        DETAIL
         assigneligreltnid = cnvtreal(num)
        WITH format, counter
       ;end select
       SET continue = true
      ENDIF
     ENDIF
     CALL echo("test")
    ELSE
     CALL echo("21")
     SET old->curdatetime = cnvtdatetime(sysdate)
     SELECT INTO "nl:"
      num = seq(protocol_def_seq,nextval)"########################;rpO"
      FROM dual
      DETAIL
       assigneligreltnid = cnvtreal(num)
      WITH format, counter
     ;end select
     SET continue = true
     CALL echo("23")
    ENDIF
    IF (continue=true)
     CALL echo("24")
     SET current_date = cnvtdatetime(sysdate)
     INSERT  FROM assign_elig_reltn a_e
      SET a_e.cohort_id = request->cohort_id, a_e.assign_elig_reltn_id = assigneligreltnid, a_e
       .pt_elig_tracking_id = request->pt_elig_tracking_id,
       a_e.beg_effective_dt_tm = cnvtdatetime(old->curdatetime), a_e.end_effective_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00.00"), a_e.updt_cnt = 0,
       a_e.updt_applctx = reqinfo->updt_applctx, a_e.updt_task = reqinfo->updt_task, a_e.updt_id =
       reqinfo->updt_id,
       a_e.updt_dt_tm = cnvtdatetime(current_date)
      WITH nocounter
     ;end insert
     IF (curqual=1)
      SET reply->elig_status = "S"
      IF (((lst_updt_dt_tm="") OR (field_name="")) )
       SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(cnvtdatetime(current_date),0,
         "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
       SET field_name = "ASSIGN_ELIG_RELTN_ID : "
       SET assgn_id = assigneligreltnid
      ENDIF
     ELSE
      SET reply->elig_status = "F"
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSE
  CALL echo("26")
  SELECT INTO "nl:"
   a_e.*
   FROM assign_reg_reltn a_e
   WHERE (a_e.reg_id=request->reg_id)
    AND a_e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
   DETAIL
    old->curdatetime = cnvtdatetime(sysdate), old->cohort_id = a_e.cohort_id, old->assign_id = a_e
    .assign_reg_reltn_id
   WITH counter, forupdate(a_e)
  ;end select
  IF (curqual=1)
   CALL echo("27")
   IF ((old->cohort_id != request->cohort_id))
    SET current_date = cnvtdatetime(sysdate)
    UPDATE  FROM assign_reg_reltn a_e
     SET a_e.end_effective_dt_tm = cnvtdatetime(old->curdatetime), a_e.updt_cnt = (a_e.updt_cnt+ 1),
      a_e.updt_applctx = reqinfo->updt_applctx,
      a_e.updt_task = reqinfo->updt_task, a_e.updt_id = reqinfo->updt_id, a_e.updt_dt_tm =
      cnvtdatetime(sysdate)
     WHERE (a_e.assign_reg_reltn_id=old->assign_id)
     WITH nocounter
    ;end update
    IF (curqual=1)
     CALL echo("28")
     SET reply->reg_status = "S"
     SET reply->status_data.status = "S"
     SET lst_updt_dt_tm = build("LST_UPDT_DT_TM: ",datetimezoneformat(cnvtdatetime(current_date),0,
       "MM/dd/yyyy  hh:mm:ss ZZZ",curtimezonedef))
     SET field_name = "ASSIGN_REG_RELTN_ID : "
     SET assgn_id = old->assign_id
    ELSE
     SET reply->reg_status = "F"
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 CALL echo("test1")
 SET reqinfo->commit_ind = false
 IF (((continue=true) OR (continue=false
  AND (request->cohort_id <= 0))) )
  IF ((reply->reg_status != "F"))
   IF ((reply->elig_status != "F"))
    IF (continue=true)
     EXECUTE strat_coh_status_update_func
    ENDIF
    IF ((reply->scs_funcstatus != "F"))
     SET reply->status_data.status = "S"
     IF ((old->cohort_id != 0)
      AND (old->cohort_id != request->cohort_id)
      AND (request->cohort_id > 0))
      SELECT INTO "NL:"
       FROM prot_cohort coh
       WHERE (coh.cohort_id=old->cohort_id)
       DETAIL
        old->stratum_id = coh.stratum_id
       WITH counter
      ;end select
      IF (curqual=1)
       SET list_ind += 1
       SET stat = alterlist(audit->list,list_ind)
       IF ((old->stratum_id=request->stratum_id))
        SET audit->list[list_ind].eventname = "Cohort_Modify"
        SET audit->list[list_ind].eventtype = "Modify"
       ELSE
        SET audit->list[list_ind].eventname = "Stratum_Modify"
        SET audit->list[list_ind].eventtype = "Modify"
        SELECT INTO "NL:"
         FROM prot_stratum ps
         WHERE ps.stratum_id IN (old->stratum_id, request->stratum_id)
         DETAIL
          IF ((ps.stratum_id=old->stratum_id))
           old->stratum_cohort_type_cd = ps.stratum_cohort_type_cd
          ELSE
           stratum_cohort_type_cd = ps.stratum_cohort_type_cd
          ENDIF
         WITH counter
        ;end select
        IF (curqual != 0)
         IF (uar_get_code_meaning(old->stratum_cohort_type_cd) != "DEFAULT"
          AND uar_get_code_meaning(stratum_cohort_type_cd) != "DEFAULT")
          SET list_ind += 1
          SET stat = alterlist(audit->list,list_ind)
          SET audit->list[list_ind].eventname = "Cohort_Modify"
          SET audit->list[list_ind].eventtype = "Modify"
         ELSEIF (uar_get_code_meaning(old->stratum_cohort_type_cd) != "DEFAULT"
          AND uar_get_code_meaning(stratum_cohort_type_cd)="DEFAULT")
          SET list_ind += 1
          SET stat = alterlist(audit->list,list_ind)
          SET audit->list[list_ind].eventname = "Cohort_Delete"
          SET audit->list[list_ind].eventtype = "Delete"
         ELSEIF (uar_get_code_meaning(old->stratum_cohort_type_cd)="DEFAULT"
          AND uar_get_code_meaning(stratum_cohort_type_cd) != "DEFAULT")
          SET list_ind += 1
          SET stat = alterlist(audit->list,list_ind)
          SET audit->list[list_ind].eventname = "Cohort_Add"
          SET audit->list[list_ind].eventtype = "Add"
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((old->cohort_id != 0)
      AND (old->cohort_id != request->cohort_id)
      AND (request->cohort_id <= 0))
      SELECT INTO "NL:"
       FROM prot_cohort coh
       WHERE (coh.cohort_id=old->cohort_id)
       DETAIL
        old->stratum_id = coh.stratum_id
       WITH counter
      ;end select
      IF (curqual=1)
       SELECT INTO "NL:"
        FROM prot_stratum ps
        WHERE (ps.stratum_id=old->stratum_id)
        DETAIL
         old->stratum_cohort_type_cd = ps.stratum_cohort_type_cd
        WITH counter
       ;end select
       IF (curqual != 0)
        SET list_ind += 1
        SET stat = alterlist(audit->list,list_ind)
        SET audit->list[list_ind].eventname = "Stratum_Delete"
        SET audit->list[list_ind].eventtype = "Delete"
        IF ( NOT (uar_get_code_meaning(old->stratum_cohort_type_cd)="DEFAULT"))
         SET list_ind += 1
         SET stat = alterlist(audit->list,list_ind)
         SET audit->list[list_ind].eventname = "Cohort_Delete"
         SET audit->list[list_ind].eventtype = "Delete"
        ENDIF
       ENDIF
      ENDIF
     ELSEIF ((old->cohort_id=0)
      AND (old->cohort_id != request->cohort_id)
      AND (request->cohort_id > 0))
      SELECT INTO "NL:"
       FROM prot_stratum ps
       WHERE (ps.stratum_id=request->stratum_id)
       DETAIL
        stratum_cohort_type_cd = ps.stratum_cohort_type_cd
       WITH counter
      ;end select
      IF (curqual != 0)
       SET list_ind += 1
       SET stat = alterlist(audit->list,list_ind)
       SET audit->list[list_ind].eventname = "Stratum_Add"
       SET audit->list[list_ind].eventtype = "Add"
       IF ( NOT (uar_get_code_meaning(stratum_cohort_type_cd)="DEFAULT"))
        SET list_ind += 1
        SET stat = alterlist(audit->list,list_ind)
        SET audit->list[list_ind].eventname = "Cohort_Add"
        SET audit->list[list_ind].eventtype = "Add"
       ENDIF
      ENDIF
     ENDIF
     SELECT INTO "NL:"
      FROM pt_prot_reg preg
      WHERE (preg.reg_id=request->reg_id)
      DETAIL
       person_id = preg.person_id
      WITH counter
     ;end select
     SET reqinfo->commit_ind = true
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF ((reply->reg_status="S"))
  SET reqinfo->commit_ind = true
 ENDIF
 CALL echo(build("commit: ",reqinfo->commit_ind))
 IF ((reply->status_data.status="S"))
  SET assgn_id_audit = build3(3,field_name,assgn_id)
  SET participantname = concat(assgn_id_audit," ",lst_updt_dt_tm," (UPDT_DT_TM)")
  FOR (x = 1 TO list_ind)
    CASE (audit->list[x].eventtype)
     OF "Add":
      EXECUTE cclaudit audit_mode, audit->list[x].eventname, audit->list[x].eventtype,
      "Person", "Patient", "Patient",
      "Origination", person_id, ""
     OF "Modify":
      EXECUTE cclaudit audit_mode, audit->list[x].eventname, audit->list[x].eventtype,
      "Person", "Patient", "Patient",
      "Amendment", person_id, participantname
     OF "Delete":
      EXECUTE cclaudit audit_mode, audit->list[x].eventname, audit->list[x].eventtype,
      "Person", "Patient", "Patient",
      "Destruction", person_id, participantname
    ENDCASE
  ENDFOR
 ENDIF
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd += 1
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
 SET last_mod = "005"
 SET mod_date = "Feb 01, 2021"
END GO
