CREATE PROGRAM dcp_chck_valid_encounters:dba
 RECORD accessible_encntr_person_ids(
   1 person_ids[*]
     2 person_id = f8
 ) WITH public
 RECORD accessible_encntr_ids(
   1 accessible_encntrs_cnt = i4
   1 accessible_encntrs[*]
     2 accessible_encntr_id = f8
 ) WITH public
 RECORD accessible_encntr_ids_maps(
   1 persons_cnt = i4
   1 persons[*]
     2 person_id = f8
     2 accessible_encntrs_cnt = i4
     2 accessible_encntrs[*]
       3 accessible_encntr_id = f8
 ) WITH public
 DECLARE getaccessibleencntrerrormsg = vc WITH protect
 DECLARE getaccessibleencntrtoggleerrormsg = vc WITH protect
 DECLARE h3202611srvmsg = i4 WITH noconstant(0), protect
 DECLARE h3202611srvreq = i4 WITH noconstant(0), protect
 DECLARE h3202611srvrep = i4 WITH noconstant(0), protect
 DECLARE hsys = i4 WITH noconstant(0), protect
 DECLARE sysstat = i4 WITH noconstant(0), protect
 DECLARE slogtext = vc WITH noconstant(""), protect
 DECLARE access_encntr_req_number = i4 WITH constant(3202611), protect
 SUBROUTINE (get_accessible_encntr_ids_by_person_id(person_id=f8,concept=vc,
  disable_access_security_ind=i2(value,0)) =i4)
   SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
   IF (h3202611srvmsg=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
   IF (h3202611srvreq=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
   IF (h3202611srvrep=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   DECLARE e_count = i4 WITH noconstant(0), protect
   DECLARE encounter_count = i4 WITH noconstant(0), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hencounter = i4 WITH noconstant(0), protect
   SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",person_id)
   IF (disable_access_security_ind=0)
    SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
   ELSE
    SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
   ENDIF
   SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
   IF (stat=0)
    SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
    IF (htransactionstatus=0)
     SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",build
      (access_encntr_req_number))
     RETURN(1)
    ELSE
     IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number),
       ". Debug Msg =",uar_srvgetstringptr(htransactionstatus,"debugErrorMessage"))
      RETURN(1)
     ELSE
      SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
      SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,encounter_count)
      SET accessible_encntr_ids->accessible_encntrs_cnt = encounter_count
      FOR (e_count = 1 TO encounter_count)
       SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
       SET accessible_encntr_ids->accessible_encntrs[e_count].accessible_encntr_id = uar_srvgetdouble
       (hencounter,"encounterId")
      ENDFOR
     ENDIF
    ENDIF
    RETURN(0)
   ELSE
    SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number))
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (get_accessible_encntr_ids_by_person_ids(accessible_encntr_person_ids=vc(ref),concept=vc,
  disable_access_security_ind=i2(value,0),user_id=f8(value,0.0)) =i4)
   SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
   IF (h3202611srvmsg=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
   IF (h3202611srvreq=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
   IF (h3202611srvrep=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   DECLARE p_count = i4 WITH noconstant(0), protect
   DECLARE person_count = i4 WITH noconstant(0), protect
   DECLARE e_count = i4 WITH noconstant(0), protect
   DECLARE encounter_count = i4 WITH noconstant(0), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hencounter = i4 WITH noconstant(0), protect
   DECLARE curr_encntr_cnt = i4 WITH noconstant(0), protect
   DECLARE prev_encntr_cnt = i4 WITH noconstant(0), protect
   SET person_count = size(accessible_encntr_person_ids->person_ids,5)
   FOR (p_count = 1 TO person_count)
     SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->person_ids[
      p_count].person_id)
     IF (disable_access_security_ind=0)
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
     ELSE
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
     ENDIF
     SET stat = uar_srvsetdouble(h3202611srvreq,"userId",user_id)
     SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
     IF (stat=0)
      SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
      IF (htransactionstatus=0)
       SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
        build(access_encntr_req_number))
       RETURN(1)
      ELSE
       IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debugErrorMessage"))
        RETURN(1)
       ELSE
        SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
        SET prev_encntr_cnt = curr_encntr_cnt
        SET curr_encntr_cnt += encounter_count
        SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,curr_encntr_cnt)
        SET accessible_encntr_ids->accessible_encntrs_cnt = curr_encntr_cnt
        FOR (e_count = 1 TO encounter_count)
         SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
         SET accessible_encntr_ids->accessible_encntrs[(e_count+ prev_encntr_cnt)].
         accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
        ENDFOR
       ENDIF
      ENDIF
     ELSE
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number)
       )
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_accessible_encntr_ids_by_person_ids_map(accessible_encntr_person_ids=vc(ref),concept
  =vc,disable_access_security_ind=i2(value,0)) =i4)
   SET h3202611srvmsg = uar_srvselectmessage(access_encntr_req_number)
   IF (h3202611srvmsg=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to select message ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvreq = uar_srvcreaterequest(h3202611srvmsg)
   IF (h3202611srvreq=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create request ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   SET h3202611srvrep = uar_srvcreatereply(h3202611srvmsg)
   IF (h3202611srvrep=0)
    SET getaccessibleencntrerrormsg = build2("*** Failed to create reply ",build(
      access_encntr_req_number))
    RETURN(1)
   ENDIF
   DECLARE p_count = i4 WITH noconstant(0), protect
   DECLARE person_count = i4 WITH noconstant(0), protect
   DECLARE e_count = i4 WITH noconstant(0), protect
   DECLARE encounter_count = i4 WITH noconstant(0), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hencounter = i4 WITH noconstant(0), protect
   SET person_count = size(accessible_encntr_person_ids->person_ids,5)
   SET accessible_encntr_ids_maps->persons_cnt = person_count
   FOR (p_count = 1 TO person_count)
     SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->person_ids[
      p_count].person_id)
     IF (disable_access_security_ind=0)
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm(concept))
     ELSE
      SET stat = uar_srvsetstring(h3202611srvreq,"concept",nullterm("No_Security"))
     ENDIF
     SET accessible_encntr_ids_maps->persons[p_count].person_id = accessible_encntr_person_ids->
     person_ids[p_count].person_id
     SET stat = uar_srvexecute(h3202611srvmsg,h3202611srvreq,h3202611srvrep)
     IF (stat=0)
      SET htransactionstatus = uar_srvgetstruct(h3202611srvrep,"transactionStatus")
      IF (htransactionstatus=0)
       SET getaccessibleencntrerrormsg = build2("Failed to get transaction status from reply of ",
        build(access_encntr_req_number))
       RETURN(1)
      ELSE
       IF (uar_srvgetshort(htransactionstatus,"successIndicator") != 1)
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
          "debugErrorMessage"))
        RETURN(1)
       ELSE
        SET encounter_count = uar_srvgetitemcount(h3202611srvrep,"encounterIds")
        SET stat = alterlist(accessible_encntr_ids_maps->persons[p_count].accessible_encntrs,
         encounter_count)
        SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs_cnt = encounter_count
        FOR (e_count = 1 TO encounter_count)
         SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
         SET accessible_encntr_ids_maps->persons[p_count].accessible_encntrs[e_count].
         accessible_encntr_id = uar_srvgetdouble(hencounter,"encounterId")
        ENDFOR
       ENDIF
      ENDIF
     ELSE
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number)
       )
      RETURN(1)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (get_accessible_encntr_toggle(result=i4(ref)) =i4)
   DECLARE concept_policies_req_concept = vc WITH constant("PowerChart_Framework"), protect
   DECLARE featuretoggleflag = i2 WITH noconstant(false), protect
   DECLARE chartaccessflag = i2 WITH noconstant(false), protect
   DECLARE featuretogglestat = i2 WITH noconstant(0), protect
   DECLARE chartaccessstat = i2 WITH noconstant(0), protect
   SET featuretogglestat = isfeaturetoggleon("urn:cerner:millennium:accessible-encounters-by-concept",
    "urn:cerner:millennium",featuretoggleflag)
   CALL uar_syscreatehandle(hsys,sysstat)
   IF (hsys > 0)
    SET slogtext = build2("get_accessible_encntr_toggle - featureToggleStat is ",build(
      featuretogglestat))
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    SET slogtext = build2("get_accessible_encntr_toggle - featureToggleFlag is ",build(
      featuretoggleflag))
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    CALL uar_sysdestroyhandle(hsys)
   ENDIF
   IF (featuretogglestat=0
    AND featuretoggleflag=true)
    SET result = 1
    RETURN(0)
   ENDIF
   IF (featuretogglestat != 0)
    CALL uar_syscreatehandle(hsys,sysstat)
    IF (hsys > 0)
     SET slogtext = build("Feature toggle service returned failure status.")
     CALL uar_sysevent(hsys,1,"pm_get_access_encntr_by_person",nullterm(slogtext))
     CALL uar_sysdestroyhandle(hsys)
    ENDIF
   ENDIF
   SET chartaccessstat = ischartaccesson(concept_policies_req_concept,chartaccessflag)
   CALL uar_syscreatehandle(hsys,sysstat)
   IF (hsys > 0)
    SET slogtext = build2("get_accessible_encntr_toggle - chartAccessStat is ",build(chartaccessstat)
     )
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    SET slogtext = build2("get_accessible_encntr_toggle - chartAccessFlag is ",build(chartaccessflag)
     )
    CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
    CALL uar_sysdestroyhandle(hsys)
   ENDIF
   IF (chartaccessstat != 0)
    RETURN(1)
   ENDIF
   IF (chartaccessflag=true)
    SET result = 1
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (isfeaturetoggleon(togglename=vc,systemidentifier=vc,featuretoggleflag=i2(ref)) =i4)
   DECLARE feature_toggle_req_number = i4 WITH constant(2030001), protect
   DECLARE toggle = vc WITH noconstant(""), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hfeatureflagmsg = i4 WITH noconstant(0), protect
   DECLARE hfeatureflagreq = i4 WITH noconstant(0), protect
   DECLARE hfeatureflagrep = i4 WITH noconstant(0), protect
   DECLARE rep2030001count = i4 WITH noconstant(0), protect
   DECLARE rep2030001successind = i2 WITH noconstant(0), protect
   SET hfeatureflagmsg = uar_srvselectmessage(feature_toggle_req_number)
   IF (hfeatureflagmsg=0)
    RETURN(0)
   ENDIF
   SET hfeatureflagreq = uar_srvcreaterequest(hfeatureflagmsg)
   IF (hfeatureflagreq=0)
    RETURN(0)
   ENDIF
   SET hfeatureflagrep = uar_srvcreatereply(hfeatureflagmsg)
   IF (hfeatureflagrep=0)
    RETURN(0)
   ENDIF
   SET stat = uar_srvsetstring(hfeatureflagreq,"system_identifier",nullterm(systemidentifier))
   SET stat = uar_srvsetshort(hfeatureflagreq,"ignore_overrides_ind",1)
   IF (uar_srvexecute(hfeatureflagmsg,hfeatureflagreq,hfeatureflagrep)=0)
    SET htransactionstatus = uar_srvgetstruct(hfeatureflagrep,"transaction_status")
    IF (htransactionstatus != 0)
     SET rep2030001successind = uar_srvgetshort(htransactionstatus,"success_ind")
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2("Failed to get transaction status from reply of ",
      build(feature_toggle_req_number))
     RETURN(1)
    ENDIF
    IF (rep2030001successind=1)
     IF (uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",0) > 0)
      SET rep2030001count = uar_srvgetitemcount(hfeatureflagrep,"feature_toggle_keys")
      FOR (loop = 0 TO (rep2030001count - 1))
       SET toggle = uar_srvgetstringptr(uar_srvgetitem(hfeatureflagrep,"feature_toggle_keys",loop),
        "key")
       IF (togglename=toggle)
        SET featuretoggleflag = true
        RETURN(0)
       ENDIF
      ENDFOR
     ENDIF
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
       feature_toggle_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
       "debug_error_message"))
     RETURN(1)
    ENDIF
   ELSE
    SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
      feature_toggle_req_number))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (ischartaccesson(concept=vc,chartaccessflag=i2(ref)) =i4)
   DECLARE concept_policies_req_number = i4 WITH constant(3202590), protect
   DECLARE htransactionstatus = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesreqstruct = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesmsg = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesreq = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesrep = i4 WITH noconstant(0), protect
   DECLARE hconceptpoliciesstruct = i4 WITH noconstant(0), protect
   DECLARE rep3202590count = i4 WITH noconstant(0), protect
   DECLARE rep3202590successind = i2 WITH noconstant(0), protect
   SET hconceptpoliciesmsg = uar_srvselectmessage(concept_policies_req_number)
   IF (hconceptpoliciesmsg=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesreq = uar_srvcreaterequest(hconceptpoliciesmsg)
   IF (hconceptpoliciesreq=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesrep = uar_srvcreatereply(hconceptpoliciesmsg)
   IF (hconceptpoliciesrep=0)
    RETURN(0)
   ENDIF
   SET hconceptpoliciesreqstruct = uar_srvadditem(hconceptpoliciesreq,"concepts")
   IF (hconceptpoliciesreqstruct > 0)
    SET stat = uar_srvsetstring(hconceptpoliciesreqstruct,"concept",nullterm(concept))
    IF (uar_srvexecute(hconceptpoliciesmsg,hconceptpoliciesreq,hconceptpoliciesrep)=0)
     SET htransactionstatus = uar_srvgetstruct(hconceptpoliciesrep,"transaction_status")
     IF (htransactionstatus != 0)
      SET rep3202590successind = uar_srvgetshort(htransactionstatus,"success_ind")
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2(
       "Failed to get transaction status from reply of ",build(concept_policies_req_number))
      RETURN(1)
     ENDIF
     IF (rep3202590successind=1)
      IF (uar_srvgetitem(hconceptpoliciesrep,"concept_policies_batch",0) > 0)
       SET rep3202590count = uar_srvgetitemcount(hconceptpoliciesrep,"concept_policies_batch")
       FOR (loop = 0 TO (rep3202590count - 1))
        SET hconceptpoliciesstruct = uar_srvgetstruct(uar_srvgetitem(hconceptpoliciesrep,
          "concept_policies_batch",loop),"policies")
        IF (hconceptpoliciesstruct > 0)
         IF (uar_srvgetshort(hconceptpoliciesstruct,"chart_access_group_security_ind")=1)
          SET chartaccessflag = true
          RETURN(0)
         ENDIF
        ELSE
         SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
           concept_policies_req_number),build("Found an invalid hConceptPoliciesStruct : ",
           hconceptpoliciesstruct))
         RETURN(1)
        ENDIF
       ENDFOR
      ENDIF
     ELSE
      SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
        concept_policies_req_number),". Debug Msg =",uar_srvgetstringptr(htransactionstatus,
        "debug_error_message"))
      RETURN(1)
     ENDIF
    ELSE
     SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
       concept_policies_req_number))
     RETURN(1)
    ENDIF
   ELSE
    SET getaccessibleencntrtoggleerrormsg = build2("Failure for call to ",build(
      concept_policies_req_number),build("Found an invalid hConceptPoliciesReqStruct : ",
      hconceptpoliciesreqstruct))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 DECLARE select_error = i2 WITH public, constant(7)
 DECLARE input_error = i2 WITH public, constant(9)
 DECLARE req_size = i4 WITH public, constant(size(request->encntrs,5))
 DECLARE failed = i2 WITH public, noconstant(false)
 DECLARE table_name = c50 WITH public, noconstant(fillstring(50," "))
 DECLARE serrmsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH public, noconstant(error(serrmsg,1))
 SET ierrcode = 0
 DECLARE ex_idx = i4 WITH protect
 DECLARE encntr_idx = i4 WITH protect
 DECLARE person_idx = i4 WITH protect
 DECLARE batch_size = i4 WITH constant(50), protect
 DECLARE loop_count = i4 WITH noconstant, protect
 DECLARE padded_size = i4 WITH protect
 DECLARE confid_on = i2 WITH public, noconstant(0)
 DECLARE security_on = i2 WITH public, noconstant(0)
 DECLARE num = i4 WITH noconstant(0), public
 DECLARE unpadded_size = i4 WITH protect
 DECLARE count = i4 WITH noconstant, protect
 DECLARE checkforchartaccess = i2 WITH public, noconstant(false)
 DECLARE ischartaccesson = i2 WITH public, noconstant(false)
 DECLARE chartaccessflag = i2 WITH noconstant(false)
 DECLARE sconceptstring = vc WITH protect, noconstant(fillstring(100," "))
 DECLARE processresult(null) = null
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 security_flag = i4
    1 encntrs[*]
      2 person_id = f8
      2 encntr_id = f8
      2 org_id = f8
      2 confid_cd = f8
      2 confid_level = i4
      2 secure_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 IF (validate(request->concept_string))
  SET sconceptstring = request->concept_string
 ENDIF
 IF (sconceptstring="")
  SET checkforchartaccess = false
 ELSE
  SET checkforchartaccess = true
  SET result = ischartaccesson(sconceptstring,chartaccessflag)
 ENDIF
 IF (chartaccessflag=1)
  FOR (idx = 1 TO size(request->encntrs,5))
    IF (mod(count,10)=0)
     SET stat = alterlist(accessible_encntr_person_ids->person_ids,(count+ 10))
    ENDIF
    SET pos = locateval(num,1,size(accessible_encntr_person_ids->person_ids,5),request->encntrs[idx].
     person_id,accessible_encntr_person_ids->person_ids[num].person_id)
    IF (pos=0)
     SET count += 1
     SET accessible_encntr_person_ids->person_ids[count].person_id = request->encntrs[idx].person_id
    ENDIF
  ENDFOR
  SET stat = alterlist(accessible_encntr_person_ids->person_ids,count)
  SET stat = get_accessible_encntr_ids_by_person_ids(accessible_encntr_person_ids,sconceptstring,0)
  IF (stat=1)
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE processresult(null)
  DECLARE cnt = i4 WITH noconstant(0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_size))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt += 1
    IF (size(reply->encntrs,5) < cnt)
     stat = alterlist(reply->encntrs,(cnt+ 10))
    ENDIF
    reply->encntrs[cnt].person_id = request->encntrs[d.seq].person_id, reply->encntrs[cnt].encntr_id
     = request->encntrs[d.seq].encntr_id, reply->encntrs[cnt].org_id = request->encntrs[d.seq].org_id,
    reply->encntrs[cnt].confid_cd = request->encntrs[d.seq].confid_cd, reply->encntrs[cnt].
    confid_level = request->encntrs[d.seq].confid_level, reply->encntrs[cnt].secure_ind = 1
   FOOT REPORT
    stat = alterlist(reply->encntrs,cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 IF (chartaccessflag=1
  AND (accessible_encntr_ids->accessible_encntrs_cnt=0))
  CALL echo("domain is chart access and accessible encounters are zero- fill reply back")
  CALL processresult(null)
 ENDIF
 CALL echo("***")
 CALL echo("***   Set security variables")
 CALL echo("***")
 IF (chartaccessflag=0)
  IF ((request->security_flag IN (1, 2)))
   IF ((request->security_flag=1))
    SET security_on = true
   ENDIF
   IF ((request->security_flag=2))
    SET confid_on = true
    SET security_on = true
   ENDIF
  ELSE
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain="SECURITY"
      AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
    DETAIL
     IF (di.info_name="SEC_ORG_RELTN"
      AND di.info_number=1)
      security_on = true
     ENDIF
     IF (di.info_name="SEC_CONFID"
      AND di.info_number=1)
      confid_on = true, security_on = true
     ENDIF
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "DM_INFO"
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 IF (security_on=true)
  SET reply->security_flag = 1
 ENDIF
 IF (confid_on=true)
  SET reply->security_flag = 2
 ENDIF
 IF (req_size < 1)
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Load Request Into Reply")
 CALL echo("***")
 IF ((request->encntr_info_flag > 0))
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(req_size))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    knt = 0
   DETAIL
    knt += 1
    IF (size(reply->encntrs,5) < knt)
     stat = alterlist(reply->encntrs,(knt+ 10))
    ENDIF
    reply->encntrs[knt].person_id = request->encntrs[d.seq].person_id, reply->encntrs[knt].encntr_id
     = request->encntrs[d.seq].encntr_id, reply->encntrs[knt].org_id = request->encntrs[d.seq].org_id,
    reply->encntrs[knt].confid_cd = request->encntrs[d.seq].confid_cd, reply->encntrs[knt].
    confid_level = request->encntrs[d.seq].confid_level
    IF (chartaccessflag=1)
     pos = locateval(num,1,size(accessible_encntr_ids->accessible_encntrs,5),reply->encntrs[knt].
      encntr_id,accessible_encntr_ids->accessible_encntrs[num].accessible_encntr_id)
     IF (pos=0)
      reply->encntrs[knt].secure_ind = true
     ENDIF
    ELSEIF (security_on=true)
     reply->encntrs[knt].secure_ind = true
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->encntrs,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "LOAD_REPLY_1"
   GO TO exit_script
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SET unpadded_size = size(request->encntrs,5)
  SET loop_count = ceil((cnvtreal(unpadded_size)/ batch_size))
  SET padded_size = (loop_count * batch_size)
  SET stat = alterlist(request->encntrs,padded_size)
  FOR (idx = (unpadded_size+ 1) TO padded_size)
    SET request->encntrs[idx].encntr_id = request->encntrs[unpadded_size].encntr_id
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(loop_count)),
    encounter e
   PLAN (d
    WHERE d.seq > 0)
    JOIN (e
    WHERE expand(ex_idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),e.encntr_id,request->
     encntrs[ex_idx].encntr_id,
     batch_size))
   HEAD REPORT
    knt = 0
   DETAIL
    knt += 1
    IF (size(reply->encntrs,5) < knt)
     stat = alterlist(reply->encntrs,(knt+ 10))
    ENDIF
    reply->encntrs[knt].person_id = e.person_id, reply->encntrs[knt].encntr_id = e.encntr_id, reply->
    encntrs[knt].org_id = e.organization_id,
    reply->encntrs[knt].confid_cd = e.confid_level_cd, reply->encntrs[knt].confid_level =
    uar_get_collation_seq(e.confid_level_cd)
    IF ((reply->encntrs[knt].confid_level < 1))
     reply->encntrs[knt].confid_level = 0
    ENDIF
    IF (chartaccessflag=1)
     pos = locateval(num,1,size(accessible_encntr_ids->accessible_encntrs,5),reply->encntrs[knt].
      encntr_id,accessible_encntr_ids->accessible_encntrs[num].accessible_encntr_id)
     IF (pos=0)
      reply->encntrs[knt].secure_ind = true
     ENDIF
    ELSEIF (security_on=true)
     reply->encntrs[knt].secure_ind = true
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->encntrs,knt)
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "LOAD_REPLY_2"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("***")
 CALL echo("***   Check For Continuation")
 CALL echo("***")
 IF (((security_on=false
  AND chartaccessflag=0) OR ((((reqinfo->updt_id < 1)) OR (size(reply->encntrs,5) < 1)) )) )
  CALL echo(build2("security_on = ",security_on))
  CALL echo(build2("reqinfo->updt_id = ",reqinfo->updt_id))
  CALL echo(build2("size(reply->encntrs,5) = ",size(reply->encntrs,5)))
  CALL echo(build2("ChartAccessflag = ",chartaccessflag))
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Determines Prsnl Access")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 IF (validate(_sacrtl_org_inc_,99999)=99999)
  DECLARE _sacrtl_org_inc_ = i2 WITH constant(1)
  RECORD sac_org(
    1 organizations[*]
      2 organization_id = f8
      2 confid_cd = f8
      2 confid_level = i4
  )
  EXECUTE secrtl
  EXECUTE sacrtl
  DECLARE orgcnt = i4 WITH protected, noconstant(0)
  DECLARE secstat = i2
  DECLARE logontype = i4 WITH protect, noconstant(- (1))
  DECLARE dynamic_org_ind = i4 WITH protect, noconstant(- (1))
  DECLARE dcur_trustid = f8 WITH protect, noconstant(0.0)
  DECLARE dynorg_enabled = i4 WITH constant(1)
  DECLARE dynorg_disabled = i4 WITH constant(0)
  DECLARE logontype_nhs = i4 WITH constant(1)
  DECLARE logontype_legacy = i4 WITH constant(0)
  DECLARE confid_cnt = i4 WITH protected, noconstant(0)
  RECORD confid_codes(
    1 list[*]
      2 code_value = f8
      2 coll_seq = f8
  )
  CALL uar_secgetclientlogontype(logontype)
  CALL echo(build("logontype:",logontype))
  IF (logontype != logontype_nhs)
   SET dynamic_org_ind = dynorg_disabled
  ENDIF
  IF (logontype=logontype_nhs)
   SUBROUTINE (getdynamicorgpref(dtrustid=f8) =i4)
     DECLARE scur_trust = vc
     DECLARE pref_val = vc
     DECLARE is_enabled = i4 WITH constant(1)
     DECLARE is_disabled = i4 WITH constant(0)
     SET scur_trust = cnvtstring(dtrustid)
     SET scur_trust = concat(scur_trust,".00")
     IF ( NOT (validate(pref_req,0)))
      RECORD pref_req(
        1 write_ind = i2
        1 delete_ind = i2
        1 pref[*]
          2 contexts[*]
            3 context = vc
            3 context_id = vc
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 entry = vc
            3 values[*]
              4 value = vc
      )
     ENDIF
     IF ( NOT (validate(pref_rep,0)))
      RECORD pref_rep(
        1 pref[*]
          2 section = vc
          2 section_id = vc
          2 subgroup = vc
          2 entries[*]
            3 pref_exists_ind = i2
            3 entry = vc
            3 values[*]
              4 value = vc
        1 status_data
          2 status = c1
          2 subeventstatus[1]
            3 operationname = c25
            3 operationstatus = c1
            3 targetobjectname = c25
            3 targetobjectvalue = vc
      )
     ENDIF
     SET stat = alterlist(pref_req->pref,1)
     SET stat = alterlist(pref_req->pref[1].contexts,2)
     SET stat = alterlist(pref_req->pref[1].entries,1)
     SET pref_req->pref[1].contexts[1].context = "organization"
     SET pref_req->pref[1].contexts[1].context_id = scur_trust
     SET pref_req->pref[1].contexts[2].context = "default"
     SET pref_req->pref[1].contexts[2].context_id = "system"
     SET pref_req->pref[1].section = "workflow"
     SET pref_req->pref[1].section_id = "UK Trust Security"
     SET pref_req->pref[1].entries[1].entry = "dynamic organizations"
     EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
     IF (cnvtupper(pref_rep->pref[1].entries[1].values[1].value)="ENABLED")
      RETURN(is_enabled)
     ELSE
      RETURN(is_disabled)
     ENDIF
   END ;Subroutine
   DECLARE hprop = i4 WITH protect, noconstant(0)
   DECLARE tmpstat = i2
   DECLARE spropname = vc
   DECLARE sroleprofile = vc
   SET hprop = uar_srvcreateproperty()
   SET tmpstat = uar_secgetclientattributesext(5,hprop)
   SET spropname = uar_srvfirstproperty(hprop)
   SET sroleprofile = uar_srvgetpropertyptr(hprop,nullterm(spropname))
   SELECT INTO "nl:"
    FROM prsnl_org_reltn_type prt,
     prsnl_org_reltn por
    PLAN (prt
     WHERE prt.role_profile=sroleprofile
      AND prt.active_ind=1
      AND prt.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND prt.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (por
     WHERE (por.organization_id= Outerjoin(prt.organization_id))
      AND (por.person_id= Outerjoin(prt.prsnl_id))
      AND (por.active_ind= Outerjoin(1))
      AND (por.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (por.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    ORDER BY por.prsnl_org_reltn_id
    DETAIL
     orgcnt = 1, secstat = alterlist(sac_org->organizations,1), user_person_id = prt.prsnl_id,
     sac_org->organizations[1].organization_id = prt.organization_id, sac_org->organizations[1].
     confid_cd = por.confid_level_cd, confid_cd = uar_get_collation_seq(por.confid_level_cd),
     sac_org->organizations[1].confid_level =
     IF (confid_cd > 0) confid_cd
     ELSE 0
     ENDIF
    WITH maxrec = 1
   ;end select
   SET dcur_trustid = sac_org->organizations[1].organization_id
   SET dynamic_org_ind = getdynamicorgpref(dcur_trustid)
   CALL uar_srvdestroyhandle(hprop)
  ENDIF
  IF (dynamic_org_ind=dynorg_disabled)
   SET confid_cnt = 0
   SELECT INTO "NL:"
    c.code_value, c.collation_seq
    FROM code_value c
    WHERE c.code_set=87
    DETAIL
     confid_cnt += 1
     IF (mod(confid_cnt,10)=1)
      secstat = alterlist(confid_codes->list,(confid_cnt+ 9))
     ENDIF
     confid_codes->list[confid_cnt].code_value = c.code_value, confid_codes->list[confid_cnt].
     coll_seq = c.collation_seq
    WITH nocounter
   ;end select
   SET secstat = alterlist(confid_codes->list,confid_cnt)
   SELECT DISTINCT INTO "nl:"
    FROM prsnl_org_reltn por
    WHERE (por.person_id=reqinfo->updt_id)
     AND por.active_ind=1
     AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
     AND por.end_effective_dt_tm >= cnvtdatetime(sysdate)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,100)
     ENDIF
    DETAIL
     orgcnt += 1
     IF (mod(orgcnt,100)=1)
      secstat = alterlist(sac_org->organizations,(orgcnt+ 99))
     ENDIF
     sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->organizations[
     orgcnt].confid_cd = por.confid_level_cd
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = value(orgcnt)),
     (dummyt d2  WITH seq = value(confid_cnt))
    PLAN (d1)
     JOIN (d2
     WHERE (sac_org->organizations[d1.seq].confid_cd=confid_codes->list[d2.seq].code_value))
    DETAIL
     sac_org->organizations[d1.seq].confid_level = confid_codes->list[d2.seq].coll_seq
    WITH nocounter
   ;end select
  ELSEIF (dynamic_org_ind=dynorg_enabled)
   DECLARE nhstrustchild_org_org_reltn_cd = f8
   SET nhstrustchild_org_org_reltn_cd = uar_get_code_by("MEANING",369,"NHSTRUSTCHLD")
   SELECT INTO "nl:"
    FROM org_org_reltn oor
    PLAN (oor
     WHERE oor.organization_id=dcur_trustid
      AND oor.active_ind=1
      AND oor.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND oor.end_effective_dt_tm >= cnvtdatetime(sysdate)
      AND oor.org_org_reltn_cd=nhstrustchild_org_org_reltn_cd)
    HEAD REPORT
     IF (orgcnt > 0)
      secstat = alterlist(sac_org->organizations,10)
     ENDIF
    DETAIL
     IF (oor.related_org_id > 0)
      orgcnt += 1
      IF (mod(orgcnt,10)=1)
       secstat = alterlist(sac_org->organizations,(orgcnt+ 9))
      ENDIF
      sac_org->organizations[orgcnt].organization_id = oor.related_org_id
     ENDIF
    FOOT REPORT
     secstat = alterlist(sac_org->organizations,orgcnt)
    WITH nocounter
   ;end select
  ELSE
   CALL echo(build("Unexpected login type: ",dynamimc_org_ind))
  ENDIF
 ENDIF
 DECLARE org_cnt = i4 WITH constant(size(sac_org->organizations,5))
 IF (org_cnt > 0
  AND size(reply->encntrs,5) > 0
  AND chartaccessflag=0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->encntrs,5))),
    (dummyt d1  WITH seq = value(org_cnt))
   PLAN (d
    WHERE d.seq > 0
     AND (reply->encntrs[d.seq].secure_ind=1))
    JOIN (d1
    WHERE (sac_org->organizations[d1.seq].organization_id=reply->encntrs[d.seq].org_id))
   HEAD d.seq
    IF (confid_on=1)
     confid_level = sac_org->organizations[d1.seq].confid_level
     IF (confid_level < 1)
      confid_level = 0
     ENDIF
     IF ((confid_level >= reply->encntrs[d.seq].confid_level))
      reply->encntrs[d.seq].secure_ind = 0
     ENDIF
    ELSE
     reply->encntrs[d.seq].secure_ind = 0
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PRSNL_ORG_RELTN"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Check For Visit Reltn Override")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD encntr_temp(
   1 encntrs[*]
     2 encntr_id = f8
     2 idx = i4
 )
 SET knt = 0
 SET stat = alterlist(encntr_temp->encntrs,size(reply->encntrs,5))
 FOR (idx = 1 TO size(reply->encntrs,5))
   IF ((reply->encntrs[idx].secure_ind=true))
    SET knt += 1
    SET encntr_temp->encntrs[knt].encntr_id = reply->encntrs[idx].encntr_id
    SET encntr_temp->encntrs[knt].idx = idx
   ENDIF
 ENDFOR
 SET unpadded_size = knt
 SET loop_count = ceil((cnvtreal(unpadded_size)/ batch_size))
 SET padded_size = (loop_count * batch_size)
 SET stat = alterlist(encntr_temp->encntrs,padded_size)
 FOR (idx = (unpadded_size+ 1) TO padded_size)
  SET encntr_temp->encntrs[idx].encntr_id = encntr_temp->encntrs[unpadded_size].encntr_id
  SET encntr_temp->encntrs[idx].idx = encntr_temp->encntrs[unpadded_size].idx
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = loop_count),
   encntr_prsnl_reltn epr
  PLAN (d
   WHERE d.seq > 0)
   JOIN (epr
   WHERE expand(ex_idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),epr.encntr_id,encntr_temp
    ->encntrs[ex_idx].encntr_id,
    batch_size)
    AND (epr.prsnl_person_id=reqinfo->updt_id)
    AND epr.expiration_ind=0
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd > 0
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm > cnvtdatetime(sysdate))
  DETAIL
   encntr_idx = locateval(ex_idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),epr.encntr_id,
    encntr_temp->encntrs[ex_idx].encntr_id)
   WHILE (encntr_idx > 0)
    reply->encntrs[encntr_temp->encntrs[encntr_idx].idx].secure_ind = false,encntr_idx = locateval(
     ex_idx,(encntr_idx+ 1),(d.seq * batch_size),epr.encntr_id,encntr_temp->encntrs[ex_idx].encntr_id
     )
   ENDWHILE
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "ENCNTR_PRSNL_RELTN"
  GO TO exit_script
 ENDIF
 FREE RECORD encntr_temp
 CALL echo("***")
 CALL echo("***   Check For Life Time Reltn Override")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD person_temp(
   1 persons[*]
     2 person_id = f8
     2 idx = i4
 )
 SET knt = 0
 SET stat = alterlist(person_temp->persons,size(reply->encntrs,5))
 FOR (idx = 1 TO size(reply->encntrs,5))
   IF ((reply->encntrs[idx].secure_ind=true))
    SET knt += 1
    SET person_temp->persons[knt].person_id = reply->encntrs[idx].person_id
    SET person_temp->persons[knt].idx = idx
   ENDIF
 ENDFOR
 SET unpadded_size = knt
 SET loop_count = ceil((cnvtreal(unpadded_size)/ batch_size))
 SET padded_size = (loop_count * batch_size)
 SET stat = alterlist(person_temp->persons,padded_size)
 FOR (idx = (unpadded_size+ 1) TO padded_size)
  SET person_temp->persons[idx].person_id = person_temp->persons[unpadded_size].person_id
  SET person_temp->persons[idx].idx = person_temp->persons[unpadded_size].idx
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = loop_count),
   person_prsnl_reltn ppr,
   code_value_extension cve
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ppr
   WHERE expand(ex_idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ppr.person_id,person_temp
    ->persons[ex_idx].person_id,
    batch_size)
    AND (ppr.prsnl_person_id=reqinfo->updt_id)
    AND ppr.active_ind=1
    AND ((ppr.person_prsnl_r_cd+ 0) > 0)
    AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (cve
   WHERE cve.code_value=ppr.person_prsnl_r_cd
    AND cve.field_name="Override"
    AND cve.code_set=331
    AND cve.field_value IN ("1", "2"))
  DETAIL
   person_idx = locateval(ex_idx,(((d.seq - 1) * batch_size)+ 1),(d.seq * batch_size),ppr.person_id,
    person_temp->persons[ex_idx].person_id)
   WHILE (person_idx > 0)
    IF (((cve.field_value="2") OR (((confid_on=0) OR ((reply->encntrs[person_temp->persons[person_idx
    ].idx].confid_level=0))) )) )
     reply->encntrs[person_temp->persons[person_idx].idx].secure_ind = false
    ENDIF
    ,person_idx = locateval(ex_idx,(person_idx+ 1),(d.seq * batch_size),ppr.person_id,person_temp->
     persons[ex_idx].person_id)
   ENDWHILE
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "PERSON_PRSNL_RELTN"
  GO TO exit_script
 ENDIF
 FREE RECORD person_temp
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF (size(reply->encntrs,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET dcp_script_version = "001 09/23/08 FE2417"
 CALL echo(build2("dcp_script_version = ",dcp_script_version))
END GO
