CREATE PROGRAM ct_enroll_loader:dba
 RECORD reply(
   1 status = c1
   1 debug[*]
     2 str = vc
   1 regid = f8
   1 conid = f8
   1 reltnid = f8
   1 personid = f8
   1 protid = f8
   1 amendid = f8
   1 aliaspoolcd = f8
   1 isduplicate = i2
   1 isnoperson = i2
   1 isnoprotocol = i2
   1 isnoamendment = i2
   1 isdeceasedproblem = i2
 )
 RECORD pt_amd_assignment(
   1 reg_id = f8
   1 prot_amendment_id = f8
   1 transfer_checked_amendment_id = f8
   1 assign_start_dt_tm = dq8
   1 assign_end_dt_tm = dq8
 )
 RECORD ptdead(
   1 date = dq8
   1 cd = dq8
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status = "F"
 SET accessionnbrnext = 0
 SET accessionnbrprefix = fillstring(255," ")
 SET accessionnbrsigdig = 0
 SET newaccessionnbr = fillstring(276," ")
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 SET false = 0
 SET true = 1
 SET commitrow = false
 SET doinsert = false
 SET conid = 0.0
 SET regid = 0.0
 SET reltnid = 0.0
 SET protid = 0.0
 SET cntd = 0
 SET u_applctx = reqinfo->updt_applctx
 SET u_task = reqinfo->updt_task
 SET u_id = reqinfo->updt_id
 SET stjudeid = 61.0
 SET amdid = 0.0
 SET cnt = 0
 SET typecd = 0.0
 SELECT INTO "nl:"
  ct.prot_amendment_id
  FROM ct_document ct
  WHERE ct_document_id=0
  DETAIL
   amdid = ct.prot_amendment_id, cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SELECT INTO "nl:"
   pa.prot_amendment_id
   FROM prot_amendment pa
   DETAIL
    amdid = pa.prot_amendment_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv
   WHERE cv.code_set=17304
    AND cv.display_key="MEMOS"
   DETAIL
    typecd = cv.code_value
   WITH nocounter
  ;end select
  INSERT  FROM ct_document
   SET ct_document_id = 0, description = "nothing", prot_amendment_id = amdid,
    title = "nothing", document_type_cd = typecd, begin_effective_dt_tm = cnvtdatetime(curdate,
     curtime3),
    end_effective_dt_tm = cnvtdatetime("21-DEC-2100 00:00:00.00"), updt_cnt = 0, updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    updt_id = 1, updt_task = 1, updt_applctx = 1
  ;end insert
  INSERT  FROM ct_document_version
   SET ct_document_version_id = 0, version_description = "nothing", ct_document_id = 0,
    file_name = "nothing", begin_effective_dt_tm = cnvtdatetime(curdate,curtime3),
    end_effective_dt_tm = cnvtdatetime("21-DEC-2100 00:00:00.00"),
    version_nbr = 0, updt_cnt = 0, updt_dt_tm = cnvtdatetime(curdate,curtime3),
    updt_id = 1, updt_task = 1, updt_applctx = 1
  ;end insert
 ENDIF
 SET cset = 17270
 SET cmean = "UNKNOWN"
 EXECUTE ct_get_cv
 SET unknown = cval
 SET cset = 17349
 SET cmean = "ENROLLING"
 EXECUTE ct_get_cv
 SET enrolling = cval
 SELECT INTO "nl:"
  alias_pool_cd
  FROM esi_alias_trans e
  WHERE (e.esi_assign_auth=request->clientnbr)
   AND e.alias_entity_name="PERSON"
   AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND e.active_ind=1
  DETAIL
   reply->aliaspoolcd = e.alias_pool_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET doinsert = false
  SET cntd = (cntd+ 1)
  SET stat = alterlist(reply->debug,cntd)
  SET reply->debug[cntd].str = build("NO  alias_pool_cd ; ClientNbr = '",request->clientnbr,"'")
  SET cntd = (cntd+ 1)
  SET stat = alterlist(reply->debug,cntd)
  SET reply->debug[cntd].str = build("    curqual = ",curqual)
  SET reply->isnoperson = true
 ELSE
  SET doinsert = true
  SET cntd = (cntd+ 1)
  SET stat = alterlist(reply->debug,cntd)
  SET reply->debug[cntd].str = build("YES alias_pool_cd ; ClientNbr = '",request->clientnbr,"'")
  SET cntd = (cntd+ 1)
  SET stat = alterlist(reply->debug,cntd)
  SET reply->debug[cntd].str = build("    Reply->AliasPoolCD = ",reply->aliaspoolcd,"  ;  curqual = ",
   curqual)
 ENDIF
 IF (doinsert=true)
  SELECT INTO "nl:"
   person_id
   FROM person_alias pa
   WHERE (pa.alias_pool_cd=reply->aliaspoolcd)
    AND (trim(cnvtalias(pa.alias,pa.alias_pool_cd))=request->mrn)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   DETAIL
    reply->personid = pa.person_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET doinsert = false
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("NO  PersonID ; AliasPoolCD = ",reply->aliaspoolcd,
    "  ; curqual = ",curqual)
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("    MRN = '",request->mrn,"'")
   SET reply->isnoperson = true
  ELSE
   SET doinsert = true
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("YES PersonID ; AliasPoolCD = ",reply->aliaspoolcd)
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("    PersonID = ",reply->personid,"  ;  curqual = ",curqual)
  ENDIF
 ENDIF
 SET reply->isdeceasedproblem = false
 IF (doinsert=true)
  SELECT INTO "nl:"
   FROM prot_master pr_m
   WHERE pr_m.primary_mnemonic_key=cnvtupper(request->protmnemonic)
   DETAIL
    reply->protid = pr_m.prot_master_id, accessionnbrnext = (pr_m.accession_nbr_last+ 1),
    accessionnbrprefix = pr_m.accession_nbr_prefix,
    accessionnbrsigdig = pr_m.accession_nbr_sig_dig
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET doinsert = false
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("NO  ProtMnemonic = '",request->protmnemonic,"'")
   SET reply->isnoprotocol = true
  ELSE
   SET doinsert = true
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("YES Protocol ; ProtMnemonic = '",request->protmnemonic,
    "' ; curqual = ",curqual)
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("    ProtID = ",reply->protid)
  ENDIF
 ENDIF
 IF (doinsert=true)
  SELECT INTO "nl:"
   pr_a.*
   FROM prot_amendment pr_a
   WHERE (pr_a.prot_master_id=reply->protid)
    AND ((pr_a.amendment_dt_tm < cnvtdatetime(request->dateonstudy)) OR (pr_a.amendment_dt_tm=
   cnvtdatetime(request->dateonstudy)))
    AND pr_a.amendment_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")
   ORDER BY pr_a.amendment_dt_tm DESC, pr_a.amendment_nbr DESC
   HEAD REPORT
    reply->amendid = pr_a.prot_amendment_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET doinsert = false
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("NO  Amendment activated prior to  '",cnvtdatetime(request->
     dateonstudy),"'")
   SET reply->isnoamendment = true
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("The Date on study = '",cnvtdatetime(request->dateonstudy),"'")
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("The Amendments that exist are as follows:")
   SELECT INTO "nl:"
    pr_a.*
    FROM prot_amendment pr_a
    WHERE (pr_a.prot_master_id=reply->protid)
     AND ((pr_a.amendment_dt_tm < cnvtdatetime(request->dateonstudy)) OR (pr_a.amendment_dt_tm=
    cnvtdatetime(request->dateonstudy)))
     AND pr_a.amendment_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00.00")
    ORDER BY pr_a.amendment_dt_tm DESC
    DETAIL
     cntd = (cntd+ 1), stat = alterlist(reply->debug,cntd), reply->debug[cntd].str = build(
      "Amendment # [",pr_a.amendment_nbr,"]  activated on '",pr_a.amendment_dt_tm,"'")
    WITH counter
   ;end select
  ELSE
   SET doinsert = true
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("YES Amendment found before = '",cnvtdatetime(request->
     dateonstudy),"' ; curqual = ",curqual)
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build(" ; AmendID = ",reply->amendid)
  ENDIF
 ENDIF
 IF (doinsert=true)
  UPDATE  FROM prot_master pr_m
   SET pr_m.accession_nbr_last = (pr_m.accession_nbr_last+ 1), pr_m.updt_cnt = (pr_m.updt_cnt+ 1),
    pr_m.updt_applctx = u_applctx,
    pr_m.updt_task = u_task, pr_m.updt_id = u_id, pr_m.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WHERE (pr_m.prot_master_id=reply->protid)
   WITH nocounter
  ;end update
  IF (curqual=1)
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build(
    "YES Successfully incremented accession info on protocol table ")
  ELSE
   SET doinsert = false
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build(
    "NO  Failed to incremented accession info on protocol table  ; curqual = ",curqual)
  ENDIF
  SET newaccessionnbr = build(accessionnbrnext)
  IF (doinsert=true)
   SET len = size(build(newaccessionnbr),1)
   CALL echo(build("len = ",len))
   CALL echo(build("AccessionNbrSigDig - len = ",(accessionnbrsigdig - len)))
   FOR (k = 1 TO (accessionnbrsigdig - len))
     SET newaccessionnbr = build("0",build(newaccessionnbr))
   ENDFOR
   SET newaccessionnbr = build(accessionnbrprefix,newaccessionnbr)
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("    New Accession Nbr = '",newaccessionnbr,"'")
  ENDIF
 ENDIF
 IF (doinsert=true)
  SELECT INTO "nl:"
   reg.*
   FROM pt_prot_reg reg
   WHERE (reg.prot_master_id=reply->protid)
    AND reg.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    AND reg.on_study_dt_tm=cnvtdatetime(request->dateonstudy)
    AND (reg.person_id=reply->personid)
   DETAIL
    reply->regid = reg.reg_id
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET doinsert = true
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build(
    "YES Okay to proceed as this will NOT create a duplicate enollment")
  ELSE
   SET doinsert = false
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build(
    "NO  Not Okay to proceed as this WILL create a duplicate enollment!")
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build(
    "    The RegID of the already existing enrollment is - RegID = ",reply->regid)
   SET reply->isduplicate = true
   GO TO duplicate
  ENDIF
 ENDIF
 IF (doinsert=true)
  CALL echo("Get Unique ID for Reg - TEST")
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    regid = cnvtreal(num)
   WITH format, counter
  ;end select
  CALL echo("Insert pt_prot_reg")
  CALL echo(build("regid = ",regid))
  INSERT  FROM pt_prot_reg p_pr_r
   SET p_pr_r.off_study_dt_tm =
    IF ((request->dateoffstudy != 0)) cnvtdatetime(request->dateoffstudy)
    ELSE cnvtdatetime("31-DEC-2100 00:00:00.00")
    ENDIF
    , p_pr_r.tx_start_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.tx_completion_dt_tm =
    cnvtdatetime("31-DEC-2100 00:00:00.00"),
    p_pr_r.first_pd_failure_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.first_pd_dt_tm =
    cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.first_cr_dt_tm = cnvtdatetime(
     "31-DEC-2100 00:00:00.00"),
    p_pr_r.nomenclature_id = 0, p_pr_r.removal_organization_id = 0, p_pr_r.removal_person_id = 0,
    p_pr_r.enrolling_organization_id = stjudeid, p_pr_r.best_response_cd = 0, p_pr_r
    .first_dis_rel_event_death_cd = 0,
    p_pr_r.diagnosis_type_cd = unknown, p_pr_r.prot_arm_id = 0, p_pr_r.prot_master_id = reply->protid,
    p_pr_r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), p_pr_r.end_effective_dt_tm =
    cnvtdatetime("31-DEC-2100 00:00:00.00"), p_pr_r.pt_prot_reg_id = regid,
    p_pr_r.reg_id = regid, p_pr_r.person_id = reply->personid, p_pr_r.prot_accession_nbr =
    newaccessionnbr,
    p_pr_r.on_study_dt_tm = cnvtdatetime(request->dateonstudy), p_pr_r.updt_cnt = 0, p_pr_r
    .updt_applctx = u_applctx,
    p_pr_r.updt_task = u_task, p_pr_r.updt_id = u_id, p_pr_r.updt_dt_tm = cnvtdatetime(curdate,
     curtime3)
   WITH nocounter
  ;end insert
  IF (curqual=1)
   SET doinsert = true
   SET reply->regid = regid
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("YES created row in pt_prot_reg table ; RegID =",regid)
   IF ((request->dateoffstudy > 0))
    SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime(request->dateoffstudy)
   ELSE
    SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
   ENDIF
   SET caaa_status = "F"
   SET pt_amd_assignment->reg_id = regid
   SET pt_amd_assignment->prot_amendment_id = reply->amendid
   SET pt_amd_assignment->transfer_checked_amendment_id = reply->amendid
   SET pt_amd_assignment->assign_start_dt_tm = cnvtdatetime(request->dateonstudy)
   SET pt_amd_assignment->assign_end_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
   EXECUTE ct_add_a_a_func
   IF (caaa_status != "S")
    SET doinsert = false
    SET cntd = (cntd+ 1)
    SET stat = alterlist(reply->debug,cntd)
    SET reply->debug[cntd].str = build("NO  execute ct_add_a_a_func returned  CAAA_STATUS =",
     caaa_status)
   ENDIF
  ELSE
   SET doinsert = false
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("NO  did not create row in pt_prot_reg table  ;  curqual = ",
    curqual)
  ENDIF
 ENDIF
 IF (doinsert=true)
  CALL echo("Get a unique key to the pt_consent table")
  SELECT INTO "nl:"
   num = seq(protocol_def_seq,nextval)"########################;rpO"
   FROM dual
   DETAIL
    conid = cnvtreal(num)
   WITH format, counter
  ;end select
  CALL echo("insert into the pt_consent table")
  INSERT  FROM pt_consent pc
   SET pc.pt_consent_id = conid, pc.consent_id = conid, pc.ct_document_version_id = 0,
    pc.consenting_organization_id = stjudeid, pc.consenting_person_id = 0, pc.consent_nbr = 1,
    pc.consent_received_dt_tm = cnvtdatetime(request->dateonstudy), pc.consent_signed_dt_tm =
    cnvtdatetime(request->dateonstudy), pc.consent_released_dt_tm = cnvtdatetime(request->dateonstudy
     ),
    pc.not_returned_dt_tm = cnvtdatetime("31-Dec-2100 00:00:00.00"), pc.reason_for_consent_cd =
    enrolling, pc.person_id = reply->personid,
    pc.prot_amendment_id = reply->amendid, pc.not_returned_reason_cd = 0, pc.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    pc.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), pc.end_effective_dt_tm = cnvtdatetime(
     "31-Dec-2100 00:00:00.00"), pc.updt_id = u_id,
    pc.updt_task = u_task, pc.updt_applctx = u_applctx, pc.updt_cnt = 0
   WITH nocounter
  ;end insert
  IF (curqual=1)
   SET doinsert = true
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("YES created row in pt_consent table ; ConID = ",conid)
   SET reply->conid = conid
  ELSE
   SET doinsert = false
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = build("NO  did not create row in pt_consent table  ;  curqual = ",
    curqual)
  ENDIF
  IF (doinsert=true)
   CALL echo("Get Unique ID for pt_reg_consent_reltn")
   SELECT INTO "nl:"
    num = seq(protocol_def_seq,nextval)"########################;rpO"
    FROM dual
    DETAIL
     reltnid = cnvtreal(num)
    WITH format, counter
   ;end select
   CALL echo("BEFORE - Insert pt_reg_consent_reltn")
   INSERT  FROM pt_reg_consent_reltn rltn
    SET rltn.pt_reg_consent_reltn_id = reltnid, rltn.reg_id = reply->regid, rltn.consent_id = reply->
     conid,
     rltn.updt_cnt = 0, rltn.updt_applctx = u_applctx, rltn.updt_task = u_task,
     rltn.updt_id = u_id, rltn.updt_dt_tm = cnvtdatetime(curdate,curtime3)
    WITH nocounter
   ;end insert
   CALL echo(build("ReltnID = ",reltnid))
   CALL echo(build("RegID = ",reply->regid))
   CALL echo(build("ConID = ",reply->conid))
   IF (curqual=1)
    SET doinsert = true
    SET reply->reltnid = reltnid
    SET cntd = (cntd+ 1)
    SET stat = alterlist(reply->debug,cntd)
    SET reply->debug[cntd].str = build("YES created row in pt_reg_consent_reltn table ; ReltnID = ",
     reltnid)
   ELSE
    SET doinsert = false
    SET cntd = (cntd+ 1)
    SET stat = alterlist(reply->debug,cntd)
    SET reply->debug[cntd].str = build(
     "NO  did not create row in pt_reg_consent_reltn table  ;  curqual = ",curqual)
   ENDIF
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = doinsert
 IF (doinsert=true)
  SET reply->status = "S"
 ELSE
  SET reply->status = "F"
 ENDIF
 SET stemp = fillstring(999," ")
 SET ecode = 1
 WHILE (ecode != 0)
  SET ecode = error(stemp,0)
  IF (ecode != 0)
   SET cntd = (cntd+ 1)
   SET stat = alterlist(reply->debug,cntd)
   SET reply->debug[cntd].str = stemp
  ENDIF
 ENDWHILE
 GO TO startecho
#duplicate
 ROLLBACK
 SET reply->status = "S"
 SET cntd = (cntd+ 1)
 SET stat = alterlist(reply->debug,cntd)
 SET reply->debug[cntd].str = "This information would have created a DUPLICATE enrollment!!"
 SET reqinfo->commit_ind = false
 SET reply->isduplicate = true
#startecho
 CALL echo(build("AliasPoolCD = ",reply->aliaspoolcd))
 CALL echo(build("PersonID = ",reply->personid))
 CALL echo(build("NewAccessionNbr = ",newaccessionnbr))
 CALL echo(build("AccessionNbrSigDig = ",accessionnbrsigdig))
 CALL echo(build("ProtID = ",reply->protid))
 CALL echo(build("AmendID = ",reply->amendid))
 CALL echo(build("RegID = ",reply->regid))
 CALL echo(build("ConID = ",reply->conid))
 CALL echo(build("ReltnID = ",reply->reltnid))
 CALL echo(build("Status = ",reply->status))
 CALL echo("-------------------------------------------------------------")
 CALL echo("DEBUG INFORMATION")
 FOR (i = 1 TO cntd)
   CALL echo(build(reply->debug[i].str))
 ENDFOR
 CALL echo("-------------------------------------------------------------")
 SET last_mod = "001"
 SET mod_date = "Feb 22, 2018"
#endofscript
END GO
