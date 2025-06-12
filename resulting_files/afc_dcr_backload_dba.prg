CREATE PROGRAM afc_dcr_backload:dba
 CALL echo("")
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo(concat(curprog," : ","VERSION : ","CHARGSRV-15843.001"))
 CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
 CALL echo("")
 DECLARE backload_file_name = vc WITH protect, noconstant("")
 IF (reflect(parameter(1,0)) != " ")
  SET backload_file_name = parameter(1,0)
 ENDIF
 FREE RECORD chargestruct
 RECORD chargestruct(
   1 enclist[*]
     2 person_id = f8
     2 encntr_id = f8
     2 dcrdate = dq8
     2 chargelist[*]
       3 charge_item_id = f8
       3 charge_description = vc
       3 offset_charge_item_id = f8
       3 new_charge_item_id = f8
       3 new_credit_charge_item_id = f8
 )
 FREE RECORD amicrequest
 RECORD amicrequest(
   1 charge_item_id = f8
   1 charge_type_cd = f8
   1 process_flg = i4
   1 ord_phys_id = f8
   1 research_acct_id = f8
   1 abn_status_cd = f8
   1 verify_phys_id = f8
   1 perf_loc_cd = f8
   1 service_dt_tm = dq8
   1 suspense_rsn_cd = f8
   1 reason_comment = vc
   1 charge_description = vc
   1 item_price = f8
   1 item_extended_price = f8
   1 item_quantity = f8
   1 late_charge_processing_ind = i2
   1 item_copay = f8
   1 item_deductible_amt = f8
   1 patient_responsibility_flag = i2
   1 modified_copy = i2
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 nomen_entity_reltn_id = f8
     2 nomen_id = f8
     2 field6 = vc
     2 field7 = vc
 )
 FREE RECORD amicreply
 RECORD amicreply(
   1 charge_qual = i2
   1 dequeued_ind = i2
   1 charge[*]
     2 charge_item_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 FREE RECORD aacmrequest
 RECORD aacmrequest(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 action_type = c3
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1 = c200
     2 field2 = c200
     2 field3 = c200
     2 field4 = c200
     2 field5 = c200
     2 field6 = c200
     2 field7 = c200
     2 field8 = c200
     2 field9 = c200
     2 field10 = c200
     2 activity_dt_tm = dq8
     2 active_ind_ind = i2
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 active_status_prsnl_id = f8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field4_id = f8
     2 field5_id = f8
     2 nomen_id = f8
     2 cm1_nbr = f8
     2 code1_cd = f8
     2 charge_mod_source_cd = f8
   1 skip_charge_event_mod_ind = i2
 )
 FREE RECORD aacmreply
 RECORD aacmreply(
   1 charge_mod_qual = i2
   1 charge_mod[*]
     2 charge_mod_id = f8
     2 charge_item_id = f8
     2 charge_mod_type_cd = f8
     2 field1_id = f8
     2 field2_id = f8
     2 field3_id = f8
     2 field6 = vc
     2 field7 = vc
     2 nomen_id = f8
     2 action_type = c3
     2 nomen_entity_reltn_id = f8
     2 cm1_nbr = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE c_charge_mod_field_6 = c34 WITH constant("Charge is a result of DCR Backload")
 DECLARE c_line = c130 WITH protect, constant(fillstring(130,":"))
 IF ( NOT (validate(encounter_id_limit)))
  DECLARE encounter_id_limit = i4 WITH protect, constant(2000)
 ENDIF
 DECLARE request_mode = i2 WITH protect, constant(1)
 DECLARE csv_mode = i2 WITH protect, constant(2)
 DECLARE cs13028_dr_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",13028,"DR")))
 DECLARE cs13028_cr_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",13028,"CR")))
 DECLARE cs13019_other_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",13019,"OTHER"))
  )
 DECLARE cs48_active_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",48,"ACTIVE")))
 DECLARE cs355_revelate_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",355,"REVELATE"
    )))
 DECLARE cs356_dcrrevelate_cd = f8 WITH protect, constant(value(uar_get_code_by("MEANING",356,
    "REVELATEDCR")))
 DECLARE charge_parser = vc WITH protect, noconstant("")
 DECLARE load_all = i2 WITH protect, noconstant(0)
 DECLARE encidx = i4 WITH protect, noconstant(0)
 DECLARE encpos = i4 WITH protect, noconstant(0)
 DECLARE chgidx = i4 WITH protect, noconstant(0)
 DECLARE csv_or_request_mode = i2 WITH protect, noconstant(0)
 DECLARE checkforproductiondomain(null) = i2
 DECLARE loadencounters(null) = i2
 DECLARE loadcharges(null) = i2
 DECLARE createchargecopy(null) = i2
 DECLARE releasecharges(null) = i2
 IF (validate(request))
  SET csv_or_request_mode = request_mode
 ELSE
  SET csv_or_request_mode = csv_mode
 ENDIF
 IF (checkforproductiondomain(null))
  CALL logmessage(
   "ERROR: Make sure you are securely logged in, and you are not executing in a production domain.")
  GO TO end_program
 ENDIF
 IF (csv_or_request_mode=csv_mode)
  IF (validatefile(backload_file_name))
   CALL logmessage("ERROR: CSV file is not valid.")
   GO TO end_program
  ENDIF
 ELSE
  IF (validate(request->encntrids))
   IF (size(request->encntrids,5)=0)
    CALL logmessage("ERROR: Request does not contain encounter ids.")
    GO TO end_program
   ENDIF
  ELSE
   CALL logmessage("ERROR: Request is not configured correctly.")
   GO TO end_program
  ENDIF
 ENDIF
 IF ( NOT (loadencounters(null)))
  CALL logmessage("ERROR: Failed to load encounters.")
  GO TO end_program
 ENDIF
 IF ( NOT (loadcharges(null)))
  CALL logmessage("ERROR: Failed to load charges.")
  GO TO end_program
 ENDIF
 IF ( NOT (createchargecopy(null)))
  CALL logmessage("ERROR: Failed to create new charges.")
  GO TO end_program
 ENDIF
 IF ( NOT (releasecharges(null)))
  CALL logmessage("ERROR: Failure encountered releasing charges.")
  GO TO end_program
 ENDIF
 SUBROUTINE (logmessage(msg=vc) =null)
   CALL echo(c_line)
   CALL echo(msg)
   CALL echo(c_line)
 END ;Subroutine
 SUBROUTINE checkforproductiondomain(null)
  IF (validate(debug,- (1)) > 0)
   CALL logmessage(build("Domain Name: ",trim(curdomain,3)))
  ENDIF
  IF (((cnvtupper(substring(1,1,curdomain))="P") OR (textlen(trim(curdomain,3))=0)) )
   RETURN(true)
  ELSE
   RETURN(false)
  ENDIF
 END ;Subroutine
 SUBROUTINE (validatefile(filename=vc) =i2)
  IF ( NOT (textlen(trim(filename,3)) > 0))
   CALL logmessage("Filename must be passed as a prompt.")
   RETURN(true)
  ELSE
   IF ( NOT (findfile(filename)))
    CALL logmessage(build(filename," was not found in the CCLUSERDIR directory."))
    RETURN(true)
   ENDIF
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE loadencounters(null)
   DECLARE delim = vc WITH protect, constant(",")
   DECLARE encntr_id_column = i2 WITH protect, constant(1)
   DECLARE parent_entity_name_column = i2 WITH protect, constant(2)
   DECLARE encntr_id_str = vc WITH protect
   DECLARE parent_entity_name_str = vc WITH protect
   DECLARE encidcnt = i4 WITH protect, noconstant(0)
   RECORD csvencids(
     1 encidcnt = i4
     1 ids[*]
       2 encntr_id = f8
   ) WITH protect
   FREE DEFINE rtl2
   DEFINE rtl2 backload_file_name
   IF (csv_or_request_mode=csv_mode)
    SELECT INTO "nl:"
     r.line
     FROM rtl2t r
     HEAD REPORT
      encidcnt = 0
     DETAIL
      encntr_id_str = trim(piece(r.line,delim,encntr_id_column,"",3)), parent_entity_name_str = trim(
       piece(r.line,delim,parent_entity_name_column,"",3))
      IF (encntr_id_str != ""
       AND  NOT (cnvtupper(encntr_id_str) IN ("PARENT_ENTITY_ID", "ENCNTR_ID"))
       AND cnvtupper(parent_entity_name_str)="ENCOUNTER")
       encidcnt += 1
       IF (mod(encidcnt,100)=1)
        stat = alterlist(csvencids->ids,(encidcnt+ 99))
       ENDIF
       csvencids->ids[encidcnt].encntr_id = cnvtreal(encntr_id_str)
      ENDIF
     FOOT REPORT
      csvencids->encidcnt = encidcnt, stat = alterlist(csvencids->ids,encidcnt)
     WITH nocounter
    ;end select
    IF (encidcnt > encounter_id_limit)
     CALL logmessage(build("CSV file contains more encounters than ",encounter_id_limit))
     RETURN(false)
    ELSEIF (encidcnt < 1)
     CALL logmessage(build("No encntr_ids were identified from the CSV"))
     RETURN(false)
    ENDIF
    SET stat = alterlist(chargestruct->enclist,encidcnt)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = csvencids->encidcnt),
      encounter e,
      org_info oi
     PLAN (d)
      JOIN (e
      WHERE (e.encntr_id=csvencids->ids[d.seq].encntr_id)
       AND e.active_ind=1)
      JOIN (oi
      WHERE oi.organization_id=e.organization_id
       AND oi.active_ind=1
       AND oi.info_sub_type_cd=cs356_dcrrevelate_cd
       AND oi.info_type_cd=cs355_revelate_cd)
     ORDER BY e.encntr_id
     HEAD REPORT
      encidcnt = 0
     DETAIL
      encidcnt += 1, chargestruct->enclist[encidcnt].person_id = e.person_id, chargestruct->enclist[
      encidcnt].encntr_id = e.encntr_id
     FOOT REPORT
      stat = alterlist(chargestruct->enclist,encidcnt)
     WITH nocounter
    ;end select
   ELSE
    SET stat = alterlist(chargestruct->enclist,size(request->encntrids,5))
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = size(request->encntrids,5)),
      encounter e,
      org_info oi
     PLAN (d)
      JOIN (e
      WHERE (e.encntr_id=request->encntrids[d.seq].encntr_id)
       AND e.active_ind=1)
      JOIN (oi
      WHERE oi.organization_id=e.organization_id
       AND oi.active_ind=1
       AND oi.info_sub_type_cd=cs356_dcrrevelate_cd
       AND oi.info_type_cd=cs355_revelate_cd)
     ORDER BY e.encntr_id
     HEAD REPORT
      encidcnt = 0
     DETAIL
      encidcnt += 1, chargestruct->enclist[encidcnt].person_id = e.person_id, chargestruct->enclist[
      encidcnt].encntr_id = e.encntr_id
     FOOT REPORT
      stat = alterlist(chargestruct->enclist,encidcnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (encidcnt < 1)
    CALL logmessage(build("No valid encntr_ids were identified from the CSV"))
    RETURN(false)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE loadcharges(null)
   DECLARE chargesfound = i2 WITH protect, noconstant(0)
   DECLARE chgcnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM charge c
    PLAN (c
     WHERE expand(encidx,1,size(chargestruct->enclist,5),c.encntr_id,chargestruct->enclist[encidx].
      encntr_id)
      AND c.process_flg=100
      AND c.active_ind=1
      AND c.charge_type_cd=cs13028_dr_cd
      AND c.offset_charge_item_id=0
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM charge c2,
       charge_mod cm
      WHERE c2.parent_charge_item_id=c.charge_item_id
       AND c2.active_ind=1
       AND cm.charge_item_id=c2.charge_item_id
       AND cm.charge_mod_type_cd=cs13019_other_cd
       AND cm.field6=c_charge_mod_field_6)))
      AND  NOT ( EXISTS (
     (SELECT
      1
      FROM charge_mod cm
      WHERE cm.charge_item_id=c.charge_item_id
       AND cm.charge_mod_type_cd=cs13019_other_cd
       AND cm.field6=c_charge_mod_field_6))))
    ORDER BY c.encntr_id, c.charge_event_id
    HEAD c.encntr_id
     encpos = locatevalsort(encidx,1,size(chargestruct->enclist,5),c.encntr_id,chargestruct->enclist[
      encidx].encntr_id), chgcnt = 0
    DETAIL
     chargesfound = true, chgcnt += 1
     IF (mod(chgcnt,100)=1)
      stat = alterlist(chargestruct->enclist[encidx].chargelist,(chgcnt+ 99))
     ENDIF
     chargestruct->enclist[encidx].chargelist[chgcnt].charge_item_id = c.charge_item_id, chargestruct
     ->enclist[encidx].chargelist[chgcnt].charge_description = c.charge_description, chargestruct->
     enclist[encidx].chargelist[chgcnt].offset_charge_item_id = c.offset_charge_item_id
    FOOT  c.encntr_id
     stat = alterlist(chargestruct->enclist[encidx].chargelist,chgcnt)
    WITH nocounter, expand = 2
   ;end select
   RETURN(chargesfound)
 END ;Subroutine
 SUBROUTINE createchargecopy(null)
   DECLARE amicencidx = i4 WITH protect, noconstant(0)
   DECLARE amicchgidx = i4 WITH protect, noconstant(0)
   FOR (amicencidx = 1 TO size(chargestruct->enclist,5))
    IF (validate(debug,- (1)) > 0)
     CALL logmessage(build2("Creating charge copies for encntr ",trim(cnvtstring(amicencidx,10),3),
       " of ",trim(cnvtstring(size(chargestruct->enclist,5),10),3),". encntr_id: ",
       trim(cnvtstring(chargestruct->enclist[amicencidx].encntr_id,10),3)))
    ENDIF
    FOR (amicchgidx = 1 TO size(chargestruct->enclist[amicencidx].chargelist,5))
      SET stat = initrec(amicrequest)
      SET stat = initrec(amicreply)
      SET amicrequest->charge_item_id = chargestruct->enclist[amicencidx].chargelist[amicchgidx].
      charge_item_id
      SET amicrequest->charge_description = chargestruct->enclist[amicencidx].chargelist[amicchgidx].
      charge_description
      SET amicrequest->process_flg = 1
      SET amicrequest->charge_type_cd = cs13028_dr_cd
      EXECUTE afc_modify_interfaced_charge  WITH replace("REQUEST",amicrequest), replace("REPLY",
       amicreply)
      IF ((((amicreply->status_data.status != "S")) OR (size(amicreply->charge,5) < 1)) )
       IF (validate(debug,- (1)) > 0)
        CALL echorecord(amicrequest)
        CALL echorecord(amicreply)
        CALL logmessage("Failure in afc_modify_interfaced_charge")
       ENDIF
       RETURN(false)
      ELSE
       SET chargestruct->enclist[amicencidx].chargelist[amicchgidx].new_charge_item_id = amicreply->
       charge[1].charge_item_id
       SET stat = initrec(aacmrequest)
       SET stat = initrec(aacmreply)
       SET aacmrequest->charge_mod_qual = 1
       SET aacmrequest->skip_charge_event_mod_ind = 1
       SET stat = alterlist(aacmrequest->charge_mod,1)
       SET aacmrequest->charge_mod[1].action_type = "ADD"
       SET aacmrequest->charge_mod[1].charge_item_id = amicreply->charge[1].charge_item_id
       SET aacmrequest->charge_mod[1].charge_mod_type_cd = cs13019_other_cd
       SET aacmrequest->charge_mod[1].field6 = c_charge_mod_field_6
       SET aacmrequest->charge_mod[1].active_ind = true
       SET aacmrequest->charge_mod[1].active_status_cd = cs48_active_cd
       EXECUTE afc_add_charge_mod  WITH replace("REQUEST",aacmrequest), replace("REPLY",aacmreply)
       IF ((aacmreply->status_data.status != "S"))
        IF (validate(debug,- (1)) > 0)
         CALL echorecord(aacmrequest)
         CALL echorecord(aacmreply)
         CALL logmessage("Failure in afc_add_charge_mod")
        ENDIF
        RETURN(false)
       ENDIF
      ENDIF
    ENDFOR
   ENDFOR
   IF (validate(debug,- (1)) > 0)
    CALL logmessage("Committing new charges")
   ENDIF
   COMMIT
 END ;Subroutine
 SUBROUTINE releasecharges(null)
   DECLARE rcencidx = i4 WITH protect, noconstant(0)
   DECLARE rcchgidx = i4 WITH protect, noconstant(0)
   DECLARE maxbatch = i4 WITH protect, constant(100)
   DECLARE remainingcharges = i4 WITH protect, noconstant(0)
   DECLARE endchargeidx = i4 WITH protect, noconstant(0)
   DECLARE batchcnt = i4 WITH protect, noconstant(0)
   DECLARE cecnt = i4 WITH protect, noconstant(0)
   DECLARE chgcnt = i4 WITH protect, noconstant(0)
   RECORD 951021request(
     1 charge_event_qual = i2
     1 process_event[*]
       2 charge_event_id = f8
       2 charge_item_qual = i2
       2 charge_item[*]
         3 charge_item_id = f8
   )
   RECORD 951021reply(
     1 status = c1
   )
   FOR (rcencidx = 1 TO size(chargestruct->enclist,5))
     IF (validate(debug,- (1)) > 0)
      CALL logmessage(build2("Releasing charges for encntr ",trim(cnvtstring(rcencidx,10),3)," of ",
        trim(cnvtstring(size(chargestruct->enclist,5),10),3),". encntr_id: ",
        trim(cnvtstring(chargestruct->enclist[rcencidx].encntr_id,10),3)))
     ENDIF
     SET remainingcharges = size(chargestruct->enclist[rcencidx].chargelist,5)
     IF (remainingcharges > maxbatch)
      SET endchargeidx = maxbatch
     ELSE
      SET endchargeidx = remainingcharges
     ENDIF
     SET batchcnt = 0
     WHILE (remainingcharges > 0)
       SET stat = initrec(951021request)
       SET stat = initrec(951021reply)
       SELECT INTO "nl:"
        FROM (dummyt d  WITH seq = endchargeidx),
         charge c
        PLAN (d)
         JOIN (c
         WHERE (c.charge_item_id=chargestruct->enclist[rcencidx].chargelist[(d.seq+ (batchcnt *
         maxbatch))].new_charge_item_id)
          AND c.charge_item_id != 0)
        ORDER BY c.charge_event_id
        HEAD REPORT
         cecnt = 0
        HEAD c.charge_event_id
         cecnt += 1
         IF (mod(cecnt,100)=1)
          stat = alterlist(951021request->process_event,(cecnt+ 99))
         ENDIF
         951021request->process_event[cecnt].charge_event_id = c.charge_event_id, chgcnt = 0
        DETAIL
         chgcnt += 1
         IF (mod(chgcnt,10)=1)
          stat = alterlist(951021request->process_event[cecnt].charge_item,(chgcnt+ 9))
         ENDIF
         951021request->process_event[cecnt].charge_item[chgcnt].charge_item_id = c.charge_item_id
        FOOT  c.charge_event_id
         stat = alterlist(951021request->process_event[cecnt].charge_item,chgcnt), 951021request->
         process_event[cecnt].charge_item_qual = chgcnt
        FOOT REPORT
         stat = alterlist(951021request->process_event,cecnt), 951021request->charge_event_qual =
         cecnt
        WITH nocounter
       ;end select
       IF (validate(debug,- (1)) > 0)
        CALL logmessage("Release charge request:")
        CALL echorecord(951021request)
       ENDIF
       SET stat = tdbexecute(951020,951020,951021,"REC",951021request,
        "REC",951021reply)
       IF (stat != 0)
        CALL logmessage(build("Server call to release charges failed: ",stat))
        RETURN(false)
       ENDIF
       SET batchcnt += 1
       SET remainingcharges = (size(chargestruct->enclist[rcencidx].chargelist,5) - (batchcnt *
       maxbatch))
       IF (remainingcharges > maxbatch)
        SET endchargeidx = maxbatch
       ELSEIF (remainingcharges < 0)
        SET endchargeidx = 0
       ELSE
        SET endchargeidx = remainingcharges
       ENDIF
     ENDWHILE
   ENDFOR
   RETURN(true)
 END ;Subroutine
#end_program
#exit_script
END GO
