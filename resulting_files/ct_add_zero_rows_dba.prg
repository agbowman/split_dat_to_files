CREATE PROGRAM ct_add_zero_rows:dba
 RECORD reply(
   1 debug[*]
     2 str = vc
 )
 SET false = 0
 SET true = 1
 SELECT INTO "nl:"
  FROM person p
  WHERE p.person_id=0
  WITH counter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM organization org
   WHERE org.organization_id=0
   WITH counter
  ;end select
  IF (curqual > 0)
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE n.nomenclature_id=0
    WITH counter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     FROM prot_master pm
     WHERE pm.prot_master_id=0
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL echo("Prot_master - Zero row already exists")
    ELSE
     CALL echo("Prot_master - Zero row does not exists - attempting creation")
     INSERT  FROM prot_master pm
      SET pm.prot_master_id = 0.0, pm.initiating_service_cd = 0, pm.initiating_service_desc = " ",
       pm.peer_review_indicator_cd = 0, pm.program_cd = 0, pm.prot_phase_cd = 0,
       pm.prot_purpose_cd = 0, pm.prot_status_cd = 0, pm.prot_type_cd = 0,
       pm.participation_type_cd = 0, pm.primary_mnemonic = " ", pm.primary_mnemonic_key = " ",
       pm.accession_nbr_last = 0, pm.accession_nbr_prefix = " ", pm.accession_nbr_sig_dig = 0,
       pm.updt_dt_tm = cnvtdatetime(curdate,curtime3), pm.updt_id = 0.0, pm.updt_applctx = 0,
       pm.updt_task = 0, pm.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      CALL echo("prot_master - zero row successfully created")
     ELSE
      CALL echo("prot_master - FAILURE TO CREATE zero row ")
      GO TO exitfailure
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM prot_amendment pa
     WHERE pa.prot_amendment_id=0
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL echo("prot_amendment - Zero row already exists")
    ELSE
     CALL echo("prot_amendment - Zero row does not exists - attempting creation")
     INSERT  FROM prot_amendment pa
      SET pa.prot_title = " ", pa.prot_amendment_id = 0, pa.enroll_stratification_cd = 0.0,
       pa.accrual_required_indc_cd = 0.0, pa.amendment_description = " ", pa.amendment_dt_tm =
       cnvtdatetime("31-DEC-2100 00:00:00"),
       pa.amendment_nbr = 0, pa.anticipated_prot_duration = 0, pa.anticipated_prot_dur_uom_cd = 0.0,
       pa.groupwide_targeted_accrual = 0, pa.prot_master_id = 0.0, pa.prot_title = " ",
       pa.targeted_accrual = 0, pa.amendment_status_cd = 0.0, pa.other_applicable_prot_ind = 0,
       pa.safety_monitor_committee_ind = 0, pa.compensation_description = " ", pa.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       pa.updt_id = 0.0, pa.updt_applctx = 0, pa.updt_task = 0,
       pa.updt_cnt = 0
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      CALL echo("prot_amendment - zero row successfully created")
     ELSE
      CALL echo("prot_amendment - FAILURE TO CREATE zero row ")
      GO TO exitfailure
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM prot_arm arm
     WHERE arm.prot_arm_id=0
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL echo("Prot_arm - Zero row already exists")
    ELSE
     CALL echo("Prot_arm - Zero row does not exists - attempting creation")
     INSERT  FROM prot_arm arm
      SET arm.arm_cd = 0.0, arm.arm_description = " ", arm.arm_status_cd = 0.0,
       arm.groupwide_targeted_accrual = 0, arm.most_recent_closure_susp_dt_tm = cnvtdatetime(curdate,
        curtime3), arm.primary_reason_closure_susp_cd = 0.0,
       arm.prot_amendment_id = 0.0, arm.prot_arm_id = 0.0, arm.targeted_accrual = 0,
       arm.updt_applctx = 0, arm.updt_cnt = 0, arm.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       arm.updt_id = 0, arm.updt_task = 0
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      CALL echo("prot_arm - zero row successfully created")
     ELSE
      CALL echo("prot_arm - FAILURE TO CREATE zero row ")
      GO TO exitfailure
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM prot_stratum strat
     WHERE strat.prot_stratum_id=0
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL echo("Prot_stratum - Zero row already exists")
    ELSE
     CALL echo("Prot_stratum - Zero row does not exists - attempting creation")
     INSERT  FROM prot_stratum strat
      SET strat.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), strat.end_effective_dt_tm =
       cnvtdatetime(curdate,curtime3), strat.length_evaluation = 0,
       strat.length_evaluation_uom_cd = 0.0, strat.organization_id = 0.0, strat.prot_amendment_id =
       0.0,
       strat.prot_stratum_id = 0.0, strat.status_chg_reason_cd = 0.0, strat.stratum_cd = 0.0,
       strat.stratum_cohort_type_cd = 0.0, strat.stratum_description = " ", strat.stratum_id = 0.0,
       strat.stratum_label = " ", strat.stratum_status_cd = 0.0, strat.updt_applctx = 0,
       strat.updt_cnt = 0, strat.updt_dt_tm = cnvtdatetime(curdate,curtime3), strat.updt_id = 0.0,
       strat.updt_task = 0
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      CALL echo("prot_stratum - zero row successfully created")
     ELSE
      CALL echo("prot_stratum - FAILURE TO CREATE zero row ")
      GO TO exitfailure
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM revision
     WHERE revision.revision_id=0
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL echo("Revision - Zero row already exists")
    ELSE
     CALL echo("Revision - Zero row does not exist - attempting creation")
     INSERT  FROM revision
      SET revision_nbr = 0, revision_description = " ", prot_amendment_id = 0.0,
       revision_dt_tm = cnvtdatetime(curdate,curtime3), revision_id = 0.0, updt_applctx = 0,
       updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 0,
       updt_task = 0
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      CALL echo("Revision - zero row successfully created")
     ELSE
      CALL echo("Revision - FAILURE TO CREATE zero row ")
      GO TO exitfailure
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM prot_objective po
     WHERE po.prot_objective_id=0
     WITH nocounter
    ;end select
    IF (curqual > 0)
     CALL echo("Prot_Objective - Zero row already exists")
    ELSE
     CALL echo("Prot_Objective - Zero row does not exist - attempting creation")
     INSERT  FROM prot_objective
      SET objective_nbr = 0, sequence_nbr = 0, objective_type_cd = 0,
       objective = " ", prot_amendment_id = 0.0, beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
       end_effective_dt_tm = cnvtdatetime(curdate,curtime3), prot_objective_id = 0.0,
       parent_prot_objective_id = 0.0,
       updt_applctx = 0, updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3),
       updt_id = 0, updt_task = 0
      WITH nocounter
     ;end insert
     IF (curqual > 0)
      CALL echo("Revision - zero row successfully created")
     ELSE
      CALL echo("Revision - FAILURE TO CREATE zero row ")
      GO TO exitfailure
     ENDIF
    ENDIF
   ELSE
    CALL echo("no nomencalture ZERO row exists !!! unable to proceed")
   ENDIF
  ELSE
   CALL echo("no person ZERO row exists !!! unable to proceed")
  ENDIF
  SELECT INTO "nl:"
   FROM committee
   WHERE committee_id=0
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("Committee - Zero row already exists")
  ELSE
   CALL echo("Committee - Zero row does not exist - attempting creation")
   INSERT  FROM committee
    SET committee_type_cd = 0, committee_name = " ", email_address = " ",
     beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), end_effective_dt_tm = cnvtdatetime(curdate,
      curtime3), sponsoring_org_id = 0.0,
     committee_id = 0.0, updt_applctx = 0, updt_cnt = 0,
     updt_dt_tm = cnvtdatetime(curdate,curtime3), updt_id = 0, updt_task = 0
    WITH nocounter
   ;end insert
   IF (curqual > 0)
    CALL echo("Committee - zero row successfully created")
   ELSE
    CALL echo("Committee - FAILURE TO CREATE zero row ")
    GO TO exitfailure
   ENDIF
  ENDIF
 ELSE
  CALL echo("no organization ZERO row exists !!! unable to proceed")
 ENDIF
#exitfailure
 SET debug_code_stemp = fillstring(999," ")
 SET debug_code_ecode = 1
 SET debug_code_cntd = size(reply->debug,5)
 WHILE (debug_code_ecode != 0)
  SET debug_code_ecode = error(debug_code_stemp,0)
  IF (debug_code_ecode != 0)
   SET debug_code_cntd = (debug_code_cntd+ 1)
   SET stat = alterlist(reply->debug,debug_code_cntd)
   SET reply->debug[debug_code_cntd].str = debug_code_stemp
  ENDIF
 ENDWHILE
 SET debug_code_cntd = size(reply->debug,5)
 SET debug_echo_i = 0
 FOR (debug_echo_i = 1 TO debug_code_cntd)
   CALL echo(build("Error#",debug_echo_i,"[",reply->debug[debug_echo_i].str,"]"))
 ENDFOR
END GO
