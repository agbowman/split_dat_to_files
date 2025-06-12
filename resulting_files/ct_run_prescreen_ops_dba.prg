CREATE PROGRAM ct_run_prescreen_ops:dba
 DECLARE rn_start = i4 WITH protect, constant(200)
 DECLARE rn_screen_start = i4 WITH protect, constant(200)
 DECLARE rn_screen_compl = i4 WITH protect, constant(300)
 DECLARE rn_data_ext_success = i4 WITH protect, constant(350)
 DECLARE rn_data_ext_fail = i4 WITH protect, constant(355)
 DECLARE rn_gather_start = i4 WITH protect, constant(400)
 DECLARE rn_gather_compl = i4 WITH protect, constant(500)
 DECLARE rn_send_start = i4 WITH protect, constant(600)
 DECLARE rn_send_compl = i4 WITH protect, constant(700)
 DECLARE rn_forced_compl = i4 WITH protect, constant(900)
 DECLARE rn_completed = i4 WITH protect, constant(1000)
 DECLARE hmsg = i4 WITH protect, constant(0)
 DECLARE insertrnrunactivity(ct_rn_prot_run_id=f8,rn_status=i4) = i2
 SUBROUTINE insertrnrunactivity(ct_rn_prot_run_id,rn_status)
   DECLARE _stat = i4 WITH private, noconstant(0)
   IF (hmsg=0)
    CALL uar_syscreatehandle(hmsg,_stat)
   ENDIF
   INSERT  FROM ct_rn_run_activity ra
    SET ra.ct_rn_run_activity_id = seq(protocol_def_seq,nextval), ra.ct_rn_prot_run_id =
     ct_rn_prot_run_id, ra.status_flag = rn_status,
     ra.updt_dt_tm = cnvtdatetime(curdate,curtime3), ra.updt_id = reqinfo->updt_id, ra.updt_applctx
      = reqinfo->updt_applctx,
     ra.updt_task = reqinfo->updt_task, ra.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET stat = msgwrite(hmsg,"INSERT ACTIVTY ERROR",emsglvl_warn,"Unable to insert Run Activity")
    CALL echo(concat("Unable to insert run activity (",trim(cnvtstring(rn_status)),
      ") for ct_rn_prot_run_id = ",trim(cnvtstring(ct_rn_prot_run_id))))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE paramstatement = vc WITH protect, noconstant("")
 DECLARE facilityparam = vc WITH protect, noconstant("'*'")
 DECLARE enctrtypeparam = vc WITH protect, noconstant("'*'")
 DECLARE enctrexclcnt = i2 WITH protect, noconstant(0)
 DECLARE enctridx = i2 WITH protect, noconstant(0)
 DECLARE enctrexclusionlist = vc WITH protect, noconstant("")
 DECLARE enctrinclcnt = i2 WITH protect, noconstant(0)
 DECLARE orgexclcnt = i2 WITH protect, noconstant(0)
 DECLARE orgidx = i2 WITH protect, noconstant(0)
 DECLARE orgexclusionlist = vc WITH protect, noconstant("")
 DECLARE orginclcnt = i2 WITH protect, noconstant(0)
 DECLARE protcnt = i2 WITH protect, noconstant(0)
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE notfound = vc WITH protect, constant("<not_found>")
 DECLARE num = i4 WITH protect, noconstant(1)
 DECLARE data = vc WITH protect, noconstant("")
 DECLARE protidx = i2 WITH protect, noconstant(0)
 DECLARE facility_cd = f8 WITH protect, noconstant(0.0)
 DECLARE run_group_id = f8 WITH protect, noconstant( $1)
 DECLARE runstr = vc WITH protect, noconstant("")
 DECLARE retval = i2 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, noconstant(0)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_list_size = i2 WITH protect, noconstant(0)
 DECLARE new_list_size = i2 WITH protect, noconstant(0)
 DECLARE buildrunstatement(protidx=i2) = vc
 DECLARE executerunstatement(exestatement=vc) = null
 IF ( NOT (validate(status_reply,0)))
  RECORD status_reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD protocols
 RECORD protocols(
   1 cnt = i4
   1 prots[*]
     2 prot_master_id = f8
     2 ct_rn_prot_run_id = f8
     2 config_info = vc
     2 new_run = i2
     2 run_num = f8
     2 primary_mnemonic = vc
     2 title = vc
     2 start_dt_time = vc
     2 start_dt_unit = vc
     2 gender = vc
     2 age_qual = vc
     2 age1 = vc
     2 age1_unit = vc
     2 age2 = vc
     2 age2_unit = vc
 )
 IF ( NOT (validate(pref_request,0)))
  RECORD pref_request(
    1 pref_entry = vc
  )
 ENDIF
 IF ( NOT (validate(pref_reply,0)))
  RECORD pref_reply(
    1 pref_value = i4
    1 pref_values[*]
      2 values = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET stat = initrec(pref_reply)
 SET stat = initrec(pref_request)
 SET stat = initrec(protocols)
 SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,facility_cd)
 CALL echo("Starting ct_rn_prescreen_ops")
 SET pref_request->pref_entry = "rn_facility_excl"
 EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 SET orgexclcnt = size(pref_reply->pref_values,5)
 IF ((pref_reply->pref_value > 0))
  SET orgexclusionlist = build(cnvtreal(pref_reply->pref_value))
  SET orgexclusionlist = build("cv.code_value not in (",orgexclusionlist,")")
 ELSEIF (orgexclcnt > 0)
  SET stat = alterlist(code_values->qual,orgexclcnt)
  FOR (orgidx = 1 TO orgexclcnt)
    IF (orgidx=1)
     SET orgexclusionlist = build(cnvtreal(pref_reply->pref_values[orgidx].values))
    ELSE
     SET orgexclusionlist = build(orgexclusionlist,", ",cnvtreal(pref_reply->pref_values[orgidx].
       values))
    ENDIF
  ENDFOR
  SET orgexclusionlist = build("cv.code_value not in (",orgexclusionlist,")")
 ENDIF
 CALL echo(build("org exclusion list:",orgexclusionlist))
 IF (((orgexclcnt > 0) OR ((pref_reply->pref_value > 0))) )
  SELECT DISTINCT INTO "NL:"
   cv.code_value
   FROM code_value cv,
    location_group lg
   PLAN (lg
    WHERE lg.location_group_type_cd=facility_cd
     AND lg.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=lg.parent_loc_cd
     AND parser(orgexclusionlist)
     AND cv.cdf_meaning=trim("FACILITY")
     AND ((cv.active_ind+ 0)=1))
   ORDER BY cnvtupper(cv.display)
   HEAD REPORT
    orginclcnt = 0
   DETAIL
    orginclcnt = (orginclcnt+ 1)
    IF (orginclcnt=1)
     facilityparam = build(cv.code_value)
    ELSE
     facilityparam = build(facilityparam,", ",cv.code_value)
    ENDIF
   WITH nocounter
  ;end select
  SET facilityparam = build("VALUE (",facilityparam,")")
 ENDIF
 CALL echo(facilityparam)
 SET stat = initrec(pref_reply)
 SET stat = initrec(pref_request)
 SET pref_request->pref_entry = "rn_encounter_excl"
 EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY","PREF_REPLY")
 SET enctrexclcnt = size(pref_reply->pref_values,5)
 IF ((pref_reply->pref_value > 0))
  SET enctrexclusionlist = build(cnvtreal(pref_reply->pref_value))
  SET enctrexclusionlist = build("cv.code_value not in (",enctrexclusionlist,")")
 ELSEIF (enctrexclcnt > 0)
  FOR (enctridx = 1 TO enctrexclcnt)
    IF (enctridx=1)
     SET enctrexclusionlist = build(cnvtreal(trim(pref_reply->pref_values[enctridx].values)))
    ELSE
     SET enctrexclusionlist = build(enctrexclusionlist,", ",cnvtreal(trim(pref_reply->pref_values[
        enctridx].values)))
    ENDIF
  ENDFOR
  SET enctrexclusionlist = build("cv.code_value not in (",enctrexclusionlist,")")
 ENDIF
 CALL echo(build("enctrExclusionList=",enctrexclusionlist))
 IF (((enctrexclcnt > 0) OR ((pref_reply->pref_value > 0))) )
  SELECT INTO "nl:"
   FROM code_value cv
   PLAN (cv
    WHERE cv.code_set=71
     AND cv.active_ind=1
     AND parser(enctrexclusionlist))
   HEAD REPORT
    enctrinclcnt = 0
   DETAIL
    enctrinclcnt = (enctrinclcnt+ 1)
    IF (enctrinclcnt=1)
     enctrtypeparam = build(cv.code_value)
    ELSE
     enctrtypeparam = build(enctrtypeparam,",",cv.code_value)
    ENDIF
   WITH nocounter
  ;end select
  SET enctrtypeparam = build("VALUE (",enctrtypeparam,")")
 ENDIF
 CALL echo(build("enctrTypeParam=",enctrtypeparam))
 SELECT INTO "nl:"
  FROM ct_rn_prot_run pr,
   ct_rn_prot_config pc,
   prot_master pm
  PLAN (pr
   WHERE pr.run_group_id=run_group_id)
   JOIN (pc
   WHERE pc.prot_master_id=pr.prot_master_id
    AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (pm
   WHERE pm.prot_master_id=pr.prot_master_id)
  HEAD REPORT
   protcnt = 0
  DETAIL
   protcnt = (protcnt+ 1)
   IF (mod(protcnt,10)=1)
    stat = alterlist(protocols->prots,(protcnt+ 9))
   ENDIF
   protocols->prots[protcnt].prot_master_id = pr.prot_master_id, protocols->prots[protcnt].
   ct_rn_prot_run_id = pr.ct_rn_prot_run_id, protocols->prots[protcnt].config_info = pc.config_info,
   protocols->prots[protcnt].primary_mnemonic = pm.primary_mnemonic
  FOOT REPORT
   stat = alterlist(protocols->prots,protcnt), protocols->cnt = protcnt
  WITH nocounter
 ;end select
 CALL echorecord(protocols)
 IF ((protocols->cnt > 0))
  FOR (protidx = 1 TO protocols->cnt)
    SET num = 1
    SET tempstr = ""
    SET data = protocols->prots[protidx].config_info
    CALL echo(build("protocols->prots[protidx].config_info=",protocols->prots[protidx].config_info))
    WHILE (tempstr != notfound
     AND num < 1000)
      SET tempstr = piece(data,"|",num,notfound)
      CALL echo(build("piece",num,"=",tempstr))
      CASE (num)
       OF 4:
        SET protocols->prots[protidx].start_dt_time = tempstr
       OF 5:
        SET protocols->prots[protidx].start_dt_unit = tempstr
       OF 6:
        SET protocols->prots[protidx].gender = tempstr
       OF 7:
        SET protocols->prots[protidx].age_qual = tempstr
       OF 8:
        SET protocols->prots[protidx].age1 = tempstr
       OF 9:
        SET protocols->prots[protidx].age2 = tempstr
      ENDCASE
      SET num = (num+ 1)
    ENDWHILE
    SET paramstatement = buildrunstatement(protidx)
    SET retval = insertrnrunactivity(protocols->prots[protidx].ct_rn_prot_run_id,rn_screen_start)
    IF (retval=0)
     CALL echo("Failed to insert a new CT_RN_RUN_ACTIVITY record")
    ENDIF
    CALL executerunstatement(paramstatement)
    SET retval = insertrnrunactivity(protocols->prots[protidx].ct_rn_prot_run_id,rn_screen_compl)
    IF (retval=0)
     CALL echo("Failed to insert a new CT_RN_RUN_ACTIVITY record")
    ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE buildrunstatement(protidx)
   CALL echo("In BuildRunStatement")
   DECLARE returnstatement = vc WITH protect, noconstant("")
   DECLARE outputparam = vc WITH protect, constant("'MINE'")
   DECLARE execmodeparam = i2 WITH protect, constant(1)
   DECLARE orderbyparam = i2 WITH protect, constant(0)
   DECLARE startdtparam = dq8 WITH protect
   DECLARE gender_cd = f8 WITH protect, noconstant(0.0)
   DECLARE startdtlookbehind = vc WITH protect, noconstant("")
   DECLARE startdt = vc WITH protect, noconstant("")
   DECLARE enddtparam = dq8 WITH protect
   DECLARE enddt = vc WITH protect, noconstant("")
   DECLARE protocolsparam = vc WITH protect, noconstant("")
   DECLARE genderparam = vc WITH protect, noconstant("")
   DECLARE agequalparam = f8 WITH protect, noconstant(0.0)
   DECLARE age1param = vc WITH protect, noconstant("")
   DECLARE age2param = vc WITH protect, noconstant("")
   SET startdtlookbehind = concat("'",protocols->prots[protidx].start_dt_time,",",protocols->prots[
    protidx].start_dt_unit,"'")
   SET startdtparam = cnvtlookbehind(build(startdtlookbehind),cnvtdatetime(curdate,curtime3))
   SET startdt = format(startdtparam,"MMDDYYYY;;D")
   SET enddtparam = cnvtdatetime(curdate,curtime3)
   SET enddt = format(enddtparam,"MMDDYYYY;;D")
   SET protocolsparam = concat("'",protocols->prots[protidx].primary_mnemonic,"'")
   CALL echo(build("gender in prot list:",protocols->prots[protidx].gender))
   IF (trim(protocols->prots[protidx].gender)="")
    SET genderparam = concat("'*'")
   ELSE
    SET gender_cd = uar_get_code_by("MEANING",57,protocols->prots[protidx].gender)
    SET genderparam = build(gender_cd)
   ENDIF
   IF ((protocols->prots[protidx].age_qual=""))
    SET agequalparam = 0
   ELSE
    SET agequalparam = uar_get_code_by("MEANING",17913,protocols->prots[protidx].age_qual)
   ENDIF
   IF ((protocols->prots[protidx].age1=""))
    SET age1param = "''"
   ELSE
    SET age1param = concat("'",protocols->prots[protidx].age1,"'")
   ENDIF
   IF ((protocols->prots[protidx].age2=""))
    SET age2param = "''"
   ELSE
    SET age2param = concat("'",protocols->prots[protidx].age2,"'")
   ENDIF
   SET returnstatement = build(outputparam,", ",execmodeparam,", ",startdt,
    ", ",enddt,", ",enctrtypeparam,", ",
    facilityparam,", VALUE(",protocolsparam,"), ",orderbyparam,
    ", ",genderparam,", ",agequalparam,", ",
    age1param,", ",age2param)
   RETURN(returnstatement)
 END ;Subroutine
 SUBROUTINE executerunstatement(paramstatement)
   DECLARE exestatement = vc WITH protect, noconstant("")
   SET exestatement = concat("execute ct_trial_prescreen ",paramstatement," go")
   CALL echo(build("exeStatement=",exestatement))
   CALL parser(exestatement)
 END ;Subroutine
 COMMIT
#exit_script
 CALL echo("Ending ct_rn_prescreen_ops")
 SET last_mod = "001"
 SET mod_date = "April 10, 2009"
END GO
