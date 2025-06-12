CREATE PROGRAM ct_run_vte_custom_ops:dba
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
 FREE RECORD persons
 RECORD persons(
   1 unsorted[*]
     2 person_id = f8
   1 sorted[*]
     2 person_id = f8
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
 FREE RECORD diagnosis_concepts
 RECORD diagnosis_concepts(
   1 qual[*]
     2 concept_cki = vc
 )
 FREE RECORD procedure_concepts
 RECORD procedure_concepts(
   1 qual[*]
     2 concept_cki = vc
 )
 DECLARE batch_size = i2 WITH protect, constant(100)
 DECLARE facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE start_dt_tm = f8 WITH protect, constant(cnvtdatetime("01-JAN-2008 00:00"))
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"PENDING"))
 DECLARE syscancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",17901,"SYSCANCEL"))
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
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
 DECLARE cur_px_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_dx_cnt = i2 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_px_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_dx_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE rn_prot_run_id = f8 WITH protect, noconstant(0.0)
 DECLARE person_cnt = i4 WITH protect, noconstant(0)
 DECLARE vte_prot_master_id = f8 WITH protect, noconstant(0.0)
 DECLARE run_group_id = f8 WITH protect, noconstant( $1)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 CALL echo("Starting")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SELECT INTO "nl:"
  FROM prot_master pm
  PLAN (pm
   WHERE pm.primary_mnemonic_key="1001VTE"
    AND pm.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  DETAIL
   vte_prot_master_id = pm.prot_master_id
  WITH nocounter
 ;end select
 IF (vte_prot_master_id <= 0.0)
  CALL echo("ERROR FINDING VTE_PROT_MASTER_ID!")
  GO TO exit_script
 ENDIF
 CALL echo("Starting to ct_rn_prot_run info")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SELECT INTO "nl:"
  FROM ct_rn_prot_run ct
  PLAN (ct
   WHERE ct.run_group_id=run_group_id
    AND ct.prot_master_id=vte_prot_master_id
    AND ct.completed_flag=0)
  DETAIL
   rn_prot_run_id = ct.ct_rn_prot_run_id,
   CALL echo(build("rn_prot_run_id: ",rn_prot_run_id))
  WITH nocounter
 ;end select
 CALL echo("Finished getting ct_rn_prot_run info")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 IF (rn_prot_run_id <= 0)
  CALL echo("ERROR FINDING ct_rn_prot_run!")
  GO TO exit_script
 ENDIF
 CALL insertrnrunactivity(rn_prot_run_id,rn_screen_start)
 CALL getprefs(0)
 CALL echo("Starting to get diagnosis data")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 CALL getdiagnosiscodes(0)
 CALL echo("Starting to get diagnosis person data")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SELECT DISTINCT INTO "NL:"
  e.person_id
  FROM (dummyt dt  WITH seq = value(loop_cnt)),
   nomenclature n,
   diagnosis d,
   encounter e,
   person p
  PLAN (dt
   WHERE initarray(nstart,evaluate(dt.seq,1,1,(nstart+ batch_size))))
   JOIN (n
   WHERE expand(i,nstart,((nstart+ batch_size) - 1),n.concept_cki,diagnosis_concepts->qual[i].
    concept_cki)
    AND n.active_ind=1)
   JOIN (d
   WHERE d.nomenclature_id=n.nomenclature_id
    AND d.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=d.encntr_id
    AND e.reg_dt_tm > cnvtdatetime(start_dt_tm)
    AND parser(enctrtypeparam)
    AND parser(facilityparam)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.person_id
  HEAD REPORT
   len_of_stay = 0.0
  HEAD e.person_id
   IF (e.disch_dt_tm=null)
    len_of_stay = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm,1)
   ELSE
    len_of_stay = datetimediff(e.disch_dt_tm,e.reg_dt_tm,1)
   ENDIF
   IF (len_of_stay >= 3
    AND p.birth_dt_tm <= cnvtlookbehind("18,Y",e.reg_dt_tm))
    person_cnt = (person_cnt+ 1)
    IF (mod(person_cnt,10000)=1)
     stat = alterlist(persons->unsorted,(person_cnt+ 9999))
    ENDIF
    persons->unsorted[person_cnt].person_id = e.person_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("So far, we have found ",person_cnt," UNSORTED persons"))
 CALL echo("Starting to get procedure data")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 CALL getprocedurecodes(0)
 CALL echo("Starting to get procedure person data")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 SELECT DISTINCT INTO "NL:"
  e.person_id
  FROM (dummyt dt  WITH seq = value(loop_cnt)),
   nomenclature n,
   procedure pr,
   encounter e,
   person p
  PLAN (dt
   WHERE initarray(nstart,evaluate(dt.seq,1,1,(nstart+ batch_size))))
   JOIN (n
   WHERE expand(i,nstart,((nstart+ batch_size) - 1),n.concept_cki,procedure_concepts->qual[i].
    concept_cki)
    AND n.active_ind=1)
   JOIN (pr
   WHERE pr.nomenclature_id=n.nomenclature_id
    AND ((pr.proc_dt_tm+ 0) != null)
    AND pr.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=pr.encntr_id
    AND e.reg_dt_tm > cnvtdatetime(start_dt_tm)
    AND parser(enctrtypeparam)
    AND parser(facilityparam)
    AND e.active_ind=1)
   JOIN (p
   WHERE p.person_id=e.person_id)
  ORDER BY e.person_id
  HEAD REPORT
   len_of_stay = 0.0
  HEAD e.person_id
   IF (e.disch_dt_tm=null)
    len_of_stay = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm,1)
   ELSE
    len_of_stay = datetimediff(e.disch_dt_tm,e.reg_dt_tm,1)
   ENDIF
   IF (len_of_stay >= 3
    AND p.birth_dt_tm <= cnvtlookbehind("18,Y",e.reg_dt_tm))
    person_cnt = (person_cnt+ 1)
    IF (mod(person_cnt,10000)=1)
     stat = alterlist(persons->unsorted,(person_cnt+ 9999))
    ENDIF
    persons->unsorted[person_cnt].person_id = e.person_id
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("So far, we have found ",person_cnt," UNSORTED persons"))
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 CALL echo("DONE SELECTING DATA!")
 SET stat = alterlist(persons->unsorted,person_cnt)
 CALL echo(build("Before dups, we have ",person_cnt," UNSORTED persons"))
 IF (person_cnt <= 0)
  CALL echo("Found 0 persons")
 ELSE
  SELECT DISTINCT INTO "nl:"
   id = persons->unsorted[d.seq].person_id
   FROM (dummyt d  WITH seq = person_cnt)
   ORDER BY id
   HEAD REPORT
    i = 0
   HEAD id
    i = (i+ 1)
    IF (mod(i,10000)=1)
     stat = alterlist(persons->sorted,(i+ 9999))
    ENDIF
    persons->sorted[i].person_id = persons->unsorted[d.seq].person_id
   FOOT REPORT
    person_cnt = i, stat = alterlist(persons->sorted,i), stat = alterlist(persons->unsorted,0)
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("******************************************************")
 CALL echo(build("Count = #",person_cnt," persons"))
 CALL echo(build("Size = #",size(persons->sorted,5)," persons"))
 CALL echo("******************************************************")
 CALL echo("WriteMatches")
 CALL echo(format(cnvtdatetime(curdate,curtime3),";;q"))
 CALL writematches(0)
 CALL insertrnrunactivity(rn_prot_run_id,rn_screen_compl)
 GO TO exit_script
 SUBROUTINE getprefs(null)
   SET stat = initrec(pref_reply)
   SET stat = initrec(pref_request)
   SET pref_request->pref_entry = "rn_facility_excl"
   EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY",
    "PREF_REPLY")
   SET orgexclcnt = size(pref_reply->pref_values,5)
   IF ((pref_reply->pref_value > 0))
    SET orgexclusionlist = build(cnvtreal(pref_reply->pref_value))
    SET orgexclusionlist = build("cv.code_value not in (",orgexclusionlist,")")
   ELSEIF (orgexclcnt > 0)
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
    SET facilityparam = build("e.loc_facility_cd in (",facilityparam,")")
   ELSE
    SET facilityparam = build("e.loc_facility_cd+0 > 0.0")
   ENDIF
   CALL echo(facilityparam)
   SET stat = initrec(pref_reply)
   SET stat = initrec(pref_request)
   SET pref_request->pref_entry = "rn_encounter_excl"
   EXECUTE ct_get_rn_pref  WITH replace("REQUEST_STRUCT","PREF_REQUEST"), replace("REPLY",
    "PREF_REPLY")
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
    SET enctrtypeparam = build("e.encntr_type_cd in (",enctrtypeparam,")")
   ELSE
    SET enctrtypeparam = build("e.encntr_type_cd+0 > 0.0")
   ENDIF
   CALL echo(build("enctrTypeParam=",enctrtypeparam))
 END ;Subroutine
 SUBROUTINE getprocedurecodes(null)
   CALL echo("Calling GetProcedureCodes().....")
   EXECUTE ct_vte_get_px_surgeries
   SET nstart = 1
   SET i = 0
   SET loop_cnt = 0
   SET cur_px_cnt = size(procedure_concepts->qual,5)
   IF (cur_px_cnt > 0)
    SET loop_cnt = ceil((cnvtreal(cur_px_cnt)/ batch_size))
    SET new_px_cnt = (batch_size * loop_cnt)
    SET stat = alterlist(procedure_concepts->qual,new_px_cnt)
    FOR (i = (cur_px_cnt+ 1) TO new_px_cnt)
      SET procedure_concepts->qual[i].concept_cki = procedure_concepts->qual[cur_px_cnt].concept_cki
    ENDFOR
   ENDIF
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    SET log_misc1 = ""
    SET log_message = concat("SCRIPT FAILURE(Get Surgery procedure nomenclature id's by concepts):",
     errmsg)
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getdiagnosiscodes(null)
   CALL echo("Calling GetDiagnosisCodes().....")
   EXECUTE ct_vte_get_dx_surgeries
   SET nstart = 1
   SET i = 0
   SET loop_cnt = 0
   SET cur_dx_cnt = size(diagnosis_concepts->qual,5)
   IF (cur_dx_cnt > 0)
    SET loop_cnt = ceil((cnvtreal(cur_dx_cnt)/ batch_size))
    SET new_dx_cnt = (batch_size * loop_cnt)
    SET stat = alterlist(diagnosis_concepts->qual,new_dx_cnt)
    FOR (i = (cur_dx_cnt+ 1) TO new_dx_cnt)
      SET diagnosis_concepts->qual[i].concept_cki = diagnosis_concepts->qual[cur_dx_cnt].concept_cki
    ENDFOR
   ENDIF
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    SET log_misc1 = ""
    SET log_message = concat("SCRIPT FAILURE(Get Surgery diagnosis nomenclature id's by concepts):",
     errmsg)
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE writematches(null)
  IF (person_cnt > 0)
   INSERT  FROM (dummyt d  WITH seq = person_cnt),
     pt_prot_prescreen ppp
    SET ppp.pt_prot_prescreen_id = cnvtreal(seq(protocol_def_seq,nextval)), ppp.prot_master_id =
     vte_prot_master_id, ppp.person_id = persons->sorted[d.seq].person_id,
     ppp.screened_dt_tm = cnvtdatetime(curdate,curtime3), ppp.screener_person_id = 0.0, ppp
     .screening_status_cd = pending_cd,
     ppp.updt_cnt = 0, ppp.updt_id = reqinfo->updt_id, ppp.updt_task = reqinfo->updt_task,
     ppp.updt_applctx = reqinfo->updt_applctx, ppp.comment_text = "VTE CUSTOM MATCH"
    PLAN (d)
     JOIN (ppp)
    WITH nocounter
   ;end insert
  ENDIF
  RETURN(1)
 END ;Subroutine
 SET reqinfo->commit_ind = 1
#exit_script
 FREE RECORD diagnosis_concepts
 FREE RECORD procedure_concepts
 FREE RECORD persons
 SET last_mod = "000"
 SET mod_date = "March 17, 2010"
END GO
