CREATE PROGRAM ct_rule_vte_study:dba
 FREE RECORD surgproclist
 RECORD surgproclist(
   1 proc_type = vc
   1 cnt = i4
   1 qual[*]
     2 nomenclature_id = f8
     2 nomenclature_disp = vc
 )
 FREE RECORD surgdxlist
 RECORD surgdxlist(
   1 cnt = i4
   1 qual[*]
     2 nomenclature_id = f8
     2 nomenclature_disp = vc
 )
 FREE RECORD surginetproclist
 RECORD surginetproclist(
   1 cnt = i4
   1 qual[*]
     2 proc_cd = f8
     2 proc_disp = vc
 )
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
 FREE RECORD surgical_concepts
 RECORD surgical_concepts(
   1 qual[*]
     2 concept_cki = vc
 )
 FREE RECORD encounters
 RECORD encounters(
   1 cnt = i4
   1 qual[*]
     2 encntr_id = f8
 )
 DECLARE getprocedurecodes(null) = i2
 DECLARE getdiagnosiscodes(null) = i2
 DECLARE getsuricalcodevalues(null) = i2
 DECLARE buildmessages(null) = i2
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE stemp = vc WITH protect, noconstant(" ")
 DECLARE sdtemp = vc WITH protect, noconstant(" ")
 DECLARE start_dt_tm = dq8 WITH protect, noconstant(0)
 DECLARE nsurgfoundind = i2 WITH protect, noconstant(0)
 DECLARE nsurgpxfoundind = i2 WITH protect, noconstant(0)
 DECLARE nsurgdxfoundind = i2 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE surginetind = i2 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE cur_px_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_dx_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_surg_cnt = i2 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE nstart = i2 WITH protect, noconstant(1)
 DECLARE loop_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_px_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_dx_cnt = i2 WITH protect, noconstant(0)
 DECLARE new_surg_cnt = i2 WITH protect, noconstant(0)
 DECLARE i = i2 WITH protect, noconstant(0)
 DECLARE start_dt_time = vc WITH protect, noconstant("")
 DECLARE start_dt_unit = vc WITH protect, noconstant("")
 DECLARE lookbehinddttm = vc WITH protect, noconstant("")
 DECLARE data = vc WITH protect, noconstant("")
 DECLARE tempstr = vc WITH protect, noconstant("")
 DECLARE look_back_to_dt_tm = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE enctrcnt = i2 WITH protect, noconstant(0)
 DECLARE len_of_stay = f8 WITH protect, noconstant(0)
 DECLARE batch_size = i2 WITH protect, constant(100)
 DECLARE notfound = vc WITH protect, constant("<not_found>")
 SET log_accessionid = link_accessionid
 SET log_orderid = link_orderid
 SET log_encntrid = link_encntrid
 SET log_personid = link_personid
 SET log_taskassaycd = link_taskassaycd
 SET log_clineventid = link_clineventid
 SET retval = - (1)
 SET surginetind =  $1
 CALL getpatientencounters(0)
 IF ((encounters->cnt > 0))
  CALL getprocedurecodes(0)
  IF ((surgproclist->cnt > 0))
   FOR (idx = 1 TO encounters->cnt)
     SELECT INTO "nl:"
      FROM procedure px,
       encounter e,
       (dummyt d  WITH seq = surgproclist->cnt)
      PLAN (d
       WHERE (d.seq <= surgproclist->cnt))
       JOIN (e
       WHERE e.person_id=link_personid
        AND (e.encntr_id=encounters->qual[idx].encntr_id)
        AND e.active_ind=1)
       JOIN (px
       WHERE px.encntr_id=e.encntr_id
        AND px.active_ind=1
        AND (px.nomenclature_id=surgproclist->qual[d.seq].nomenclature_id))
      ORDER BY px.updt_dt_tm DESC
      HEAD REPORT
       nsurgpxfoundind = 0
      DETAIL
       IF (nsurgpxfoundind=0)
        IF (px.proc_dt_tm != null)
         start_dt_tm = px.proc_dt_tm, stemp = surgproclist->qual[d.seq].nomenclature_disp,
         CALL echo(stemp),
         sdtemp = format(start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;d"), nsurgpxfoundind = 1
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      SET log_message = concat("SCRIPT FAILURE(Finding patient's surgical procedures:  ",errmsg)
      SET log_misc1 = ""
      GO TO exit_script
     ENDIF
     IF (nsurgpxfoundind=1)
      SET idx = (encounters->cnt+ 1)
     ENDIF
   ENDFOR
  ELSE
   SET log_message = concat("No surgical procedures were found to evaluate.")
   SET log_misc1 = ""
  ENDIF
  IF (nsurgpxfoundind=0)
   CALL getdiagnosiscodes(0)
   IF ((surgdxlist->cnt > 0))
    FOR (idx = 1 TO encounters->cnt)
      SELECT INTO "nl:"
       FROM diagnosis dx,
        encounter e,
        (dummyt d  WITH seq = surgdxlist->cnt)
       PLAN (d
        WHERE (d.seq <= surgdxlist->cnt))
        JOIN (e
        WHERE e.person_id=link_personid
         AND (e.encntr_id=encounters->qual[idx].encntr_id)
         AND e.active_ind=1)
        JOIN (dx
        WHERE dx.encntr_id=e.encntr_id
         AND dx.active_ind=1
         AND (dx.nomenclature_id=surgdxlist->qual[d.seq].nomenclature_id))
       ORDER BY dx.updt_dt_tm DESC
       HEAD REPORT
        nsurgdxfoundind = 0
       DETAIL
        IF (nsurgdxfoundind=0)
         IF (dx.diag_dt_tm != null)
          start_dt_tm = dx.diag_dt_tm, stemp = surgdxlist->qual[d.seq].nomenclature_disp,
          CALL echo(stemp),
          sdtemp = format(start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;d"), nsurgdxfoundind = 1
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
      SET error_check = error(errmsg,0)
      IF (error_check != 0)
       SET log_message = concat("SCRIPT FAILURE(Finding patient's surgical diagnoses:  ",errmsg)
       SET log_misc1 = ""
       GO TO exit_script
      ENDIF
      IF (nsurgdxfoundind=1)
       SET idx = (encounters->cnt+ 1)
      ENDIF
    ENDFOR
   ELSE
    SET log_message = concat("No surgical diagnoses were found to evaluate.")
    SET log_misc1 = ""
   ENDIF
   IF (surginetind > 0)
    IF (nsurgdxfoundind=0)
     CALL getsuricalcodevalues(0)
     IF ((surginetproclist->cnt > 0))
      FOR (idx = 1 TO encounters->cnt)
        SELECT INTO "nl:"
         FROM surgical_case sc,
          surg_case_procedure scp,
          (dummyt d  WITH seq = surginetproclist->cnt)
         PLAN (d
          WHERE (d.seq <= surginetproclist->cnt))
          JOIN (sc
          WHERE sc.person_id=link_personid
           AND (sc.encntr_id=encounters->qual[idx].encntr_id)
           AND sc.active_ind=1)
          JOIN (scp
          WHERE scp.surg_case_id=sc.surg_case_id
           AND (scp.surg_proc_cd=surginetproclist->qual[d.seq].proc_cd)
           AND scp.primary_proc_ind=1
           AND scp.active_ind=1)
         ORDER BY scp.updt_dt_tm DESC
         HEAD REPORT
          nsurgfoundind = 0
         DETAIL
          IF (nsurgfoundind=0)
           IF (sc.surg_start_dt_tm != null)
            start_dt_tm = sc.surg_start_dt_tm, stemp = surginetproclist->qual[d.seq].proc_disp,
            sdtemp = format(start_dt_tm,"DD-MMM-YYYY HH:MM:SS;;d"),
            nsurgfoundind = 1
           ENDIF
          ENDIF
         WITH nocounter
        ;end select
        SET error_check = error(errmsg,0)
        IF (error_check != 0)
         SET log_message = concat("SCRIPT FAILURE(Get 'Surgery Stop Date/Time(Surginet)'):  ",errmsg)
         SET log_misc1 = ""
         GO TO exit_script
        ENDIF
        IF (nsurgfoundind=1)
         SET idx = (encounters->cnt+ 1)
        ENDIF
      ENDFOR
     ELSE
      SET log_message = concat("No surgical procedures were found in the Order Catalog.")
      SET log_misc1 = ""
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSE
  SET log_message = concat("No encounters found longer than 3 days for this patient")
  SET log_misc1 = ""
  SET retval = 0
  GO TO exit_script
 ENDIF
 IF (nsurgpxfoundind=0
  AND nsurgfoundind=0
  AND nsurgdxfoundind=0)
  SET log_message = concat("No surgical procedures or diagnoses were found for this patient.")
  SET log_misc1 = ""
  SET retval = 0
  GO TO exit_script
 ELSE
  GO TO set_return
 ENDIF
 SUBROUTINE getpatientencounters(null)
   CALL echo("Calling GetPatientEncounters().....")
   SELECT INTO "nl:"
    FROM ct_rn_prot_config pc,
     prot_master pm
    PLAN (pm
     WHERE pm.primary_mnemonic_key="1001VTE"
      AND pm.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
     JOIN (pc
     WHERE pc.prot_master_id=pm.prot_master_id
      AND pc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    DETAIL
     start_dt_time = "", start_dt_unit = "", lookbehinddttm = "",
     num = 1, tempstr = "", data = pc.config_info,
     CALL echo(build("pc.config_info =",pc.config_info))
     WHILE (tempstr != notfound
      AND num < 1000)
       tempstr = piece(data,"|",num,notfound),
       CALL echo(build("piece",num,"=",tempstr))
       CASE (num)
        OF 4:
         start_dt_time = tempstr
        OF 5:
         start_dt_unit = tempstr
       ENDCASE
       num = (num+ 1)
     ENDWHILE
     lookbehinddttm = concat("'",start_dt_time,",",start_dt_unit,"'"), look_back_to_dt_tm =
     cnvtlookbehind(build(lookbehinddttm),cnvtdatetime(curdate,curtime3))
    WITH nocounter
   ;end select
   CALL echo(build("lookback is:",format(look_back_to_dt_tm,"@LONGDATETIME")))
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    SET log_misc1 = ""
    SET log_message = concat("SCRIPT FAILURE(Getting 1001VTE lookback range):  ",errmsg)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    e.encntr_id
    FROM encounter e
    WHERE e.person_id=log_personid
     AND e.active_ind=1
     AND e.reg_dt_tm >= cnvtdatetime(look_back_to_dt_tm)
    ORDER BY e.reg_dt_tm DESC
    HEAD REPORT
     enctrcnt = 0, len_of_stay = 0.0
    DETAIL
     IF (e.disch_dt_tm=null)
      len_of_stay = datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm,1)
     ELSE
      len_of_stay = datetimediff(e.disch_dt_tm,e.reg_dt_tm,1)
     ENDIF
     IF (len_of_stay >= 3)
      enctrcnt = (enctrcnt+ 1)
      IF (size(encounters->qual,5) < enctrcnt)
       lstat = alterlist(encounters->qual,(enctrcnt+ 4))
      ENDIF
      encounters->qual[enctrcnt].encntr_id = e.encntr_id
     ENDIF
    FOOT REPORT
     lstat = alterlist(encounters->qual,enctrcnt), encounters->cnt = enctrcnt
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    SET log_misc1 = ""
    SET log_message = concat("SCRIPT FAILURE(Getting patient's encounters):  ",errmsg)
    GO TO exit_script
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getsuricalcodevalues(null)
   CALL echo("Calling GetSuricalCodeValues().....")
   DECLARE lordercat_cs = i4 WITH protect, constant(200)
   EXECUTE ct_vte_get_surgeries
   SET num = 0
   SET nstart = 1
   SET i = 0
   SET ncnt = 0
   SET cur_surg_cnt = size(surgical_concepts->qual,5)
   IF (cur_surg_cnt > 0)
    SET loop_cnt = ceil((cnvtreal(cur_surg_cnt)/ batch_size))
    SET new_surg_cnt = (batch_size * loop_cnt)
    SET stat = alterlist(surgical_concepts->qual,new_surg_cnt)
    FOR (i = (cur_surg_cnt+ 1) TO new_surg_cnt)
      SET surgical_concepts->qual[i].concept_cki = surgical_concepts->qual[cur_surg_cnt].concept_cki
    ENDFOR
    SELECT INTO "nl:"
     FROM code_value cv,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (cv
      WHERE expand(num,nstart,((nstart+ batch_size) - 1),cv.concept_cki,surgical_concepts->qual[num].
       concept_cki)
       AND ((cv.code_set+ 0)=lordercat_cs)
       AND cv.active_ind=1)
     DETAIL
      ncnt = (ncnt+ 1)
      IF (size(surginetproclist->qual,5) < ncnt)
       lstat = alterlist(surginetproclist->qual,(ncnt+ 4))
      ENDIF
      surginetproclist->qual[ncnt].proc_cd = cv.code_value, surginetproclist->qual[ncnt].proc_disp =
      cv.display
     WITH nocounter
    ;end select
    SET surginetproclist->cnt = ncnt
    SET lstat = alterlist(surginetproclist->qual,ncnt)
    SET stat = alterlist(surginetproclist->qual,cur_surg_cnt)
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     SET log_misc1 = ""
     SET log_message = concat("SCRIPT FAILURE(Get Surgerical code values by concepts):  ",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getprocedurecodes(null)
   CALL echo("Calling GetProcedureCodes().....")
   EXECUTE ct_vte_get_px_surgeries
   SET num = 0
   SET nstart = 1
   SET i = 0
   SET ncnt = 0
   SET cur_px_cnt = size(procedure_concepts->qual,5)
   IF (cur_px_cnt > 0)
    SET loop_cnt = ceil((cnvtreal(cur_px_cnt)/ batch_size))
    SET new_px_cnt = (batch_size * loop_cnt)
    SET stat = alterlist(procedure_concepts->qual,new_px_cnt)
    FOR (i = (cur_px_cnt+ 1) TO new_px_cnt)
      SET procedure_concepts->qual[i].concept_cki = procedure_concepts->qual[cur_px_cnt].concept_cki
    ENDFOR
    SELECT INTO "nl:"
     FROM nomenclature n,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (n
      WHERE expand(num,nstart,((nstart+ batch_size) - 1),n.concept_cki,procedure_concepts->qual[num].
       concept_cki)
       AND n.active_ind=1)
     DETAIL
      ncnt = (ncnt+ 1)
      IF (size(surgproclist->qual,5) < ncnt)
       lstat = alterlist(surgproclist->qual,(ncnt+ 4))
      ENDIF
      surgproclist->qual[ncnt].nomenclature_id = n.nomenclature_id, surgproclist->qual[ncnt].
      nomenclature_disp = n.source_string
     WITH nocounter
    ;end select
    SET surgproclist->cnt = ncnt
    SET lstat = alterlist(surgproclist->qual,ncnt)
    SET stat = alterlist(procedure_concepts->qual,cur_px_cnt)
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     SET log_misc1 = ""
     SET log_message = concat(
      "SCRIPT FAILURE(Get Surgery procedure nomenclature id's by concepts):  ",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getdiagnosiscodes(null)
   CALL echo("Calling GetDiagnosisCodes().....")
   EXECUTE ct_vte_get_dx_surgeries
   SET num = 0
   SET nstart = 1
   SET i = 0
   SET ncnt = 0
   SET cur_dx_cnt = size(diagnosis_concepts->qual,5)
   IF (cur_dx_cnt > 0)
    SET loop_cnt = ceil((cnvtreal(cur_dx_cnt)/ batch_size))
    SET new_dx_cnt = (batch_size * loop_cnt)
    SET stat = alterlist(diagnosis_concepts->qual,new_dx_cnt)
    FOR (i = (cur_dx_cnt+ 1) TO new_dx_cnt)
      SET diagnosis_concepts->qual[i].concept_cki = diagnosis_concepts->qual[cur_dx_cnt].concept_cki
    ENDFOR
    SELECT INTO "nl:"
     FROM nomenclature n,
      (dummyt d  WITH seq = value(loop_cnt))
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (n
      WHERE expand(num,nstart,((nstart+ batch_size) - 1),n.concept_cki,diagnosis_concepts->qual[num].
       concept_cki)
       AND n.active_ind=1)
     DETAIL
      ncnt = (ncnt+ 1)
      IF (size(surgdxlist->qual,5) < ncnt)
       lstat = alterlist(surgdxlist->qual,(ncnt+ 4))
      ENDIF
      surgdxlist->qual[ncnt].nomenclature_id = n.nomenclature_id, surgdxlist->qual[ncnt].
      nomenclature_disp = n.source_string
     WITH nocounter
    ;end select
    SET surgdxlist->cnt = ncnt
    SET lstat = alterlist(surgdxlist->qual,ncnt)
    SET stat = alterlist(diagnosis_concepts->qual,cur_dx_cnt)
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     SET log_misc1 = ""
     SET log_message = concat(
      "SCRIPT FAILURE(Get Surgery diagnosis nomenclature id's by concepts):  ",errmsg)
     GO TO exit_script
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE buildmessages(null)
   DECLARE ecnt = i4 WITH protect, constant(size(eksdata->bldmsg,5))
   DECLARE mcnt = i4 WITH protect, constant((ecnt+ 3))
   SET lstat = alterlist(eksdata->bldmsg,mcnt)
   SET eksdata->bldmsg_cnt = mcnt
   SET eksdata->bldmsg[(ecnt+ 1)].name = "SPROCS"
   SET eksdata->bldmsg[(ecnt+ 1)].text = stemp
   SET eksdata->bldmsg[(ecnt+ 2)].name = "SSDTTM"
   SET eksdata->bldmsg[(ecnt+ 2)].text = sdtemp
   CALL echorecord(eksdata)
   RETURN(1)
 END ;Subroutine
#set_return
 CALL buildmessages(0)
 SET log_misc1 = stemp
 SET log_message = concat("The following surgical procedures/diagnoses have been found:  ",stemp,".")
 SET retval = 100
#exit_script
 CALL echo(build("log_misc1 .....",log_misc1))
 CALL echo(build("log_message ...",log_message))
 CALL echo(build("retval ........",retval))
 FREE RECORD surgproclist
 FREE RECORD surgdxlist
 FREE RECORD surginetproclist
 FREE RECORD diagnosis_concepts
 FREE RECORD procedure_concepts
 FREE RECORD surgical_concepts
 FREE RECORD encounters
 SET last_mod = "001"
 SET mod_date = "September 17, 2009"
END GO
