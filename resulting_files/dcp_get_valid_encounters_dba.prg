CREATE PROGRAM dcp_get_valid_encounters:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 restrict_ind = i2
    1 persons[*]
      2 person_id = f8
      2 restrict_ind = i2
      2 encntrs[*]
        3 encntr_id = f8
        3 encntr_type_cd = f8
        3 encntr_type_disp = vc
        3 encntr_type_class_cd = f8
        3 encntr_type_class_disp = vc
        3 encntr_status_cd = f8
        3 encntr_status_disp = vc
        3 reg_dt_tm = dq8
        3 pre_reg_dt_tm = dq8
        3 location_cd = f8
        3 loc_facility_cd = f8
        3 loc_facility_disp = vc
        3 loc_building_cd = f8
        3 loc_building_disp = vc
        3 loc_nurse_unit_cd = f8
        3 loc_nurse_unit_disp = vc
        3 loc_room_cd = f8
        3 loc_room_disp = vc
        3 loc_bed_cd = f8
        3 loc_bed_disp = vc
        3 reason_for_visit = vc
        3 financial_class_cd = f8
        3 financial_class_disp = vc
        3 beg_effective_dt_tm = dq8
        3 disch_dt_tm = dq8
        3 med_service_cd = f8
        3 diet_type_cd = f8
        3 isolation_cd = f8
        3 encntr_financial_id = f8
        3 arrive_dt_tm = dq8
        3 provider_list[*]
          4 provider_id = f8
          4 provider_name = vc
          4 relationship_cd = f8
          4 relationship_disp = vc
          4 relationship_mean = c12
        3 organization_id = f8
        3 time_zone_indx = i4
        3 est_arrive_dt_tm = dq8
        3 est_disch_dt_tm = dq8
        3 contributor_system_cd = f8
        3 contributor_system_disp = vc
        3 contributor_system_mean = vc
        3 loc_temp_cd = f8
        3 loc_temp_disp = vc
        3 alias_list[*]
          4 alias = vc
          4 alias_type_cd = f8
          4 alias_type_disp = vc
          4 alias_type_mean = vc
          4 alias_status_cd = f8
          4 alias_status_disp = vc
          4 alias_status_mean = vc
          4 contributor_system_cd = f8
          4 contributor_system_disp = vc
          4 contributor_system_mean = vc
        3 encntr_type_class_mean = c12
        3 encntr_status_mean = c12
        3 med_service_disp = vc
        3 isolation_disp = vc
        3 location_disp = vc
        3 diet_type_disp = vc
        3 diet_type_mean = vc
        3 inpatient_admit_dt_tm = dq8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD gve_temp(
   1 org_list[*]
     2 organization_id = f8
     2 confid_level = i4
   1 encntr_list[*]
     2 restrict_ind = i4
     2 encntr_id = f8
     2 person_id = f8
     2 encntr_type_cd = f8
     2 encntr_type_class_cd = f8
     2 encntr_status_cd = f8
     2 reg_dt_tm = dq8
     2 pre_reg_dt_tm = dq8
     2 est_arrive_dt_tm = dq8
     2 location_cd = f8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
     2 loc_temp_cd = f8
     2 reason_for_visit = vc
     2 financial_class_cd = f8
     2 beg_effective_dt_tm = dq8
     2 disch_dt_tm = dq8
     2 med_service_cd = f8
     2 diet_type_cd = f8
     2 isolation_cd = f8
     2 encntr_financial_id = f8
     2 arrive_dt_tm = dq8
     2 provider_list[*]
     2 organization_id = f8
     2 confid_level = i4
     2 time_zone_indx = i4
     2 est_disch_dt_tm = dq8
     2 contributor_system_cd = f8
     2 inpatient_admit_dt_tm = dq8
   1 valid_encntr_cnt = i4
   1 valid_encntrs[*]
     2 encntr_id = f8
     2 facility_cd = f8
     2 person_index = i4
     2 encntr_index = i4
 )
 RECORD gve_confid_codes(
   1 list[*]
     2 code_value = f8
     2 coll_seq = f8
 )
 SET modify = predeclare
 SET reply->status_data.status = "F"
 DECLARE gve_encntr_org_sec_ind = i2 WITH noconstant(0)
 DECLARE gve_confid_ind = i2 WITH noconstant(0)
 DECLARE gve_sz = i4 WITH constant(size(request->persons,5))
 DECLARE gve_encntr_cnt = i4 WITH noconstant(0)
 DECLARE gve_org_cnt = i4 WITH noconstant(0)
 DECLARE gve_secure_cnt = i4 WITH noconstant(0)
 DECLARE gve_person_cnt = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE request_prsnl_id = f8
 DECLARE retval = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE pidx = i4 WITH noconstant(0)
 DECLARE eidx = i4 WITH noconstant(0)
 DECLARE sfailed = vc WITH noconstant("F")
 DECLARE mlreqcount = i4 WITH protected, noconstant(0)
 DECLARE mlcagind = i4 WITH protected, noconstant(0)
 DECLARE mnskipsecind = i2 WITH protected, noconstant(0)
 DECLARE sconceptstring = vc WITH protected
 DECLARE mncaflag = i2 WITH protected, noconstant(false)
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
 SET mlcagind = 0
 SET sconceptstring = "POWERCHART_FRAMEWORK"
 SET mnskipsecind = 0
 DECLARE new_list_size = i4
 DECLARE cur_list_size = i4
 DECLARE batch_size = i4 WITH constant(20)
 DECLARE nstart = i4
 DECLARE loop_cnt = i4
 DECLARE bincexternalind = i2 WITH protect, noconstant(0)
 DECLARE bincinternalind = i2 WITH protect, noconstant(0)
 DECLARE evaluateorgsecurity(null) = null
 DECLARE loadencounters(null) = null
 DECLARE loadencounterswithinrange(null) = null
 DECLARE loadencountersbydaterange(null) = null
 DECLARE performorgsecurity(null) = null
 DECLARE loadorganizations(null) = null
 DECLARE peformvisitreltnoverride(null) = null
 DECLARE performlifereltnoverride(null) = null
 DECLARE loadtimezones(null) = null
 DECLARE loadproviders(null) = null
 DECLARE populatereply(null) = null
 DECLARE loadencounteraliases(null) = null
 DECLARE loadconfidcodelevels(null) = null
 IF ((validate(request->bincexternalind,- (1)) != - (1)))
  SET bincexternalind = request->bincexternalind
 ENDIF
 SET reply->restrict_ind = 0
 SET chartaccessstat = ischartaccesson(sconceptstring,mncaflag)
 IF (mncaflag=true)
  SET mlcagind = 1
  SET mlreqcount = size(request->persons,5)
  IF (mlreqcount=0)
   GO TO exit_script
  ENDIF
  SET stat = alterlist(accessible_encntr_person_ids->person_ids,mlreqcount)
  SET stat = moverec(request->persons,accessible_encntr_person_ids->person_ids)
  SET stat = get_accessible_encntr_ids_by_person_ids(accessible_encntr_person_ids,sconceptstring,
   mnskipsecind)
  IF (stat=1)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "get_accessible_encntr_ids_by_person_ids"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "getAccessibleEncntrErrorMsg"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = getaccessibleencntrerrormsg
   SET sfailed = "T"
   GO TO exit_script
  ELSE
   IF ((accessible_encntr_ids->accessible_encntrs_cnt=0))
    GO TO exit_script
   ENDIF
  ENDIF
  SET reply->restrict_ind = 1
 ELSE
  IF (chartaccessstat=1)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "isChartAccessOn"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "getAccessibleEncntrToggleErrorMsg"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = getaccessibleencntrtoggleerrormsg
   SET sfailed = "T"
   GO TO exit_script
  ENDIF
 ENDIF
 SET request_prsnl_id = request->prsnl_id
 IF (mlcagind=0)
  CALL loadconfidcodelevels(null)
  CALL evaluateorgsecurity(null)
 ENDIF
 IF (((mlcagind=1) OR (((gve_confid_ind=1) OR (((gve_encntr_org_sec_ind=1) OR ((request->
 force_encntrs_ind=1))) )) )) )
  IF (validate(request->encntr_lookback_days,0) > 0)
   CALL loadencounterswithinrange(null)
  ELSEIF (validate(request->encntr_from_dt_tm,0) > 0
   AND validate(request->encntr_to_dt_tm,0) > 0)
   CALL loadencountersbydaterange(null)
  ELSE
   CALL loadencounters(null)
  ENDIF
  SET gve_secure_cnt = gve_encntr_cnt
  IF (((gve_confid_ind=1) OR (gve_encntr_org_sec_ind=1)) )
   CALL performorgsecurity(null)
  ENDIF
  IF (gve_secure_cnt > 0)
   CALL performlifereltnoverride(null)
  ENDIF
  IF (gve_secure_cnt > 0)
   CALL peformvisitreltnoverride(null)
  ENDIF
  CALL populatereply(null)
  CALL loadtimezones(null)
  IF ((request->provider_ind=1))
   CALL loadproviders(null)
  ENDIF
  IF (validate(request->retrieve_aliases_ind,0)=1)
   CALL loadencounteraliases(null)
  ENDIF
 ENDIF
 FREE RECORD gve_temp
 FREE RECORD gve_confid_codes
 SUBROUTINE loadconfidcodelevels(null)
   DECLARE confid_cnt = i4 WITH noconstant(0)
   SELECT INTO "NL:"
    c.code_value, c.collation_seq
    FROM code_value c
    WHERE c.code_set=87
    DETAIL
     confid_cnt += 1
     IF (mod(confid_cnt,10)=1)
      stat = alterlist(gve_confid_codes->list,(confid_cnt+ 9))
     ENDIF
     gve_confid_codes->list[confid_cnt].code_value = c.code_value, gve_confid_codes->list[confid_cnt]
     .coll_seq = c.collation_seq
    WITH nocounter
   ;end select
   SET stat = alterlist(gve_confid_codes->list,confid_cnt)
 END ;Subroutine
 SUBROUTINE evaluateorgsecurity(null)
   DECLARE dminfo_ok = i2 WITH noconstant(0), private
   IF ((request->force_org_security_ind != - (1)))
    SET dminfo_ok = validate(ccldminfo->mode,0)
    IF (dminfo_ok=1)
     SET gve_encntr_org_sec_ind = ccldminfo->sec_org_reltn
     SET gve_confid_ind = ccldminfo->sec_confid
    ELSE
     SELECT INTO "nl:"
      FROM dm_info di
      PLAN (di
       WHERE di.info_domain="SECURITY"
        AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID")
        AND di.info_number=1)
      DETAIL
       IF (di.info_name="SEC_ORG_RELTN")
        gve_encntr_org_sec_ind = 1
       ELSEIF (di.info_name="SEC_CONFID")
        gve_confid_ind = 1
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   IF ((request->force_org_security_ind > 0))
    SET gve_encntr_org_sec_ind = 1
   ENDIF
   IF (((gve_encntr_org_sec_ind=1) OR (gve_confid_ind=1)) )
    SET reply->restrict_ind = 1
   ENDIF
 END ;Subroutine
 SUBROUTINE loadorganizations(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE x = i4 WITH noconstant(0)
   DECLARE org_cnt = i4 WITH noconstant(0)
   DECLARE found = i4 WITH noconstant(0)
   DECLARE org_list_cnt = i4 WITH noconstant(0)
   DECLARE sac_org_cnt = i4 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0)
   RECORD exist_org_list(
     1 orgs[*]
       2 org_id = f8
   )
   RECORD gve_org_temp(
     1 orgs[*]
       2 org_id = f8
   )
   FOR (i = 1 TO gve_encntr_cnt)
     IF ((gve_temp->encntr_list[i].restrict_ind=1))
      SET found = 0
      FOR (j = 1 TO org_cnt)
        IF ((gve_org_temp->orgs[j].org_id=gve_temp->encntr_list[i].organization_id))
         SET found = 1
         SET j = (org_cnt+ 1)
        ENDIF
      ENDFOR
      IF (found=0)
       SET org_cnt += 1
       IF (mod(org_cnt,10)=1)
        SET stat = alterlist(gve_org_temp->orgs,(org_cnt+ 9))
       ENDIF
       SET gve_org_temp->orgs[org_cnt].org_id = gve_temp->encntr_list[i].organization_id
      ENDIF
     ENDIF
   ENDFOR
   IF ((reqinfo->updt_id=request_prsnl_id))
    IF (validate(sac_org)=0)
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
         sac_org->organizations[orgcnt].organization_id = por.organization_id, sac_org->
         organizations[orgcnt].confid_cd = por.confid_level_cd
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
    ENDIF
    SET gve_org_cnt = 0
    SET sac_org_cnt = size(sac_org->organizations,5)
    FOR (i = 1 TO sac_org_cnt)
     SET org_list_cnt = size(exist_org_list->orgs,5)
     IF (locateval(num,1,org_list_cnt,sac_org->organizations[i].organization_id,exist_org_list->orgs[
      num].org_id)=0)
      SET stat = alterlist(exist_org_list->orgs,(org_list_cnt+ 1))
      SET exist_org_list->orgs[num].org_id = sac_org->organizations[i].organization_id
      FOR (x = 1 TO org_cnt)
        IF ((gve_org_temp->orgs[x].org_id=sac_org->organizations[i].organization_id))
         SET gve_org_cnt = (size(gve_temp->org_list,5)+ 1)
         SET stat = alterlist(gve_temp->org_list,gve_org_cnt)
         SET gve_temp->org_list[gve_org_cnt].confid_level = sac_org->organizations[i].confid_level
         SET gve_temp->org_list[gve_org_cnt].organization_id = sac_org->organizations[i].
         organization_id
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
    SET stat = alterlist(gve_temp->org_list,gve_org_cnt)
   ELSE
    SET cur_list_size = org_cnt
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET nstart = 1
    SET stat = alterlist(gve_org_temp->orgs,new_list_size)
    FOR (x = (cur_list_size+ 1) TO new_list_size)
      SET gve_org_temp->orgs[x].org_id = gve_org_temp->orgs[cur_list_size].org_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(loop_cnt)),
      prsnl_org_reltn por
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (por
      WHERE por.person_id=request_prsnl_id
       AND expand(i,nstart,(nstart+ (batch_size - 1)),por.organization_id,gve_org_temp->orgs[i].
       org_id)
       AND por.active_ind=1
       AND por.beg_effective_dt_tm < cnvtdatetime(sysdate)
       AND por.end_effective_dt_tm > cnvtdatetime(sysdate))
     HEAD REPORT
      gve_org_cnt = 0
     DETAIL
      gve_org_cnt = (size(gve_temp->org_list,5)+ 1), stat = alterlist(gve_temp->org_list,gve_org_cnt),
      gve_temp->org_list[gve_org_cnt].organization_id = por.organization_id,
      gve_temp->org_list[gve_org_cnt].confid_level = determineconfidlevel(por.confid_level_cd)
     FOOT REPORT
      stat = alterlist(gve_temp->org_list,gve_org_cnt)
     WITH nocounter
    ;end select
   ENDIF
   FREE RECORD gve_org_temp
 END ;Subroutine
 SUBROUTINE performorgsecurity(null)
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   CALL loadorganizations(null)
   FOR (i = 1 TO gve_encntr_cnt)
     IF ((gve_temp->encntr_list[i].restrict_ind=1))
      FOR (j = 1 TO gve_org_cnt)
        IF ((gve_temp->encntr_list[i].organization_id=gve_temp->org_list[j].organization_id))
         IF (((gve_confid_ind=0) OR ((gve_temp->encntr_list[i].confid_level <= gve_temp->org_list[j].
         confid_level))) )
          SET gve_temp->encntr_list[i].restrict_ind = 0
          SET gve_secure_cnt -= 1
         ENDIF
         SET j = (gve_org_cnt+ 1)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE loadencounters(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE restrict = i4 WITH noconstant(0)
   DECLARE nstart = i2 WITH protected, noconstant(1)
   IF (((mlcagind=1) OR (((gve_confid_ind=1) OR (gve_encntr_org_sec_ind=1)) )) )
    SET restrict = 1
   ENDIF
   SELECT
    IF (mlcagind=0)
     WHERE expand(i,nstart,size(request->persons,5),e.person_id,request->persons[i].person_id)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND e.active_ind=1
      AND e.external_ind IN (bincinternalind, bincexternalind)
     ORDER BY e.person_id
    ELSE
     WHERE expand(i,nstart,accessible_encntr_ids->accessible_encntrs_cnt,e.encntr_id,
      accessible_encntr_ids->accessible_encntrs[i].accessible_encntr_id)
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND e.active_ind=1
      AND e.external_ind IN (bincinternalind, bincexternalind)
     ORDER BY e.person_id
    ENDIF
    INTO "nl:"
    FROM encounter e
    HEAD REPORT
     gve_encntr_cnt = 0, gve_timezone_cnt = 0
    DETAIL
     gve_encntr_cnt += 1
     IF (mod(gve_encntr_cnt,100)=1)
      stat = alterlist(gve_temp->encntr_list,(gve_encntr_cnt+ 99))
     ENDIF
     gve_temp->encntr_list[gve_encntr_cnt].restrict_ind = restrict, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_id = e.encntr_id, gve_temp->encntr_list[gve_encntr_cnt].person_id = e
     .person_id,
     gve_temp->encntr_list[gve_encntr_cnt].encntr_type_cd = e.encntr_type_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_type_class_cd = e.encntr_type_class_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_status_cd = e.encntr_status_cd,
     gve_temp->encntr_list[gve_encntr_cnt].reg_dt_tm = e.reg_dt_tm, gve_temp->encntr_list[
     gve_encntr_cnt].pre_reg_dt_tm = e.pre_reg_dt_tm, gve_temp->encntr_list[gve_encntr_cnt].
     location_cd = e.location_cd,
     gve_temp->encntr_list[gve_encntr_cnt].loc_facility_cd = e.loc_facility_cd, gve_temp->
     encntr_list[gve_encntr_cnt].loc_building_cd = e.loc_building_cd, gve_temp->encntr_list[
     gve_encntr_cnt].loc_nurse_unit_cd = e.loc_nurse_unit_cd,
     gve_temp->encntr_list[gve_encntr_cnt].loc_room_cd = e.loc_room_cd, gve_temp->encntr_list[
     gve_encntr_cnt].loc_bed_cd = e.loc_bed_cd, gve_temp->encntr_list[gve_encntr_cnt].loc_temp_cd = e
     .loc_temp_cd,
     gve_temp->encntr_list[gve_encntr_cnt].reason_for_visit = e.reason_for_visit, gve_temp->
     encntr_list[gve_encntr_cnt].financial_class_cd = e.financial_class_cd, gve_temp->encntr_list[
     gve_encntr_cnt].beg_effective_dt_tm = e.beg_effective_dt_tm,
     gve_temp->encntr_list[gve_encntr_cnt].disch_dt_tm = e.disch_dt_tm, gve_temp->encntr_list[
     gve_encntr_cnt].med_service_cd = e.med_service_cd, gve_temp->encntr_list[gve_encntr_cnt].
     diet_type_cd = e.diet_type_cd,
     gve_temp->encntr_list[gve_encntr_cnt].isolation_cd = e.isolation_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_financial_id = e.encntr_financial_id, gve_temp->encntr_list[
     gve_encntr_cnt].arrive_dt_tm = e.arrive_dt_tm,
     gve_temp->encntr_list[gve_encntr_cnt].est_arrive_dt_tm = e.est_arrive_dt_tm, gve_temp->
     encntr_list[gve_encntr_cnt].organization_id = e.organization_id, gve_temp->encntr_list[
     gve_encntr_cnt].confid_level = determineconfidlevel(e.confid_level_cd),
     gve_temp->encntr_list[gve_encntr_cnt].est_disch_dt_tm = e.est_depart_dt_tm, gve_temp->
     encntr_list[gve_encntr_cnt].contributor_system_cd = e.contributor_system_cd, gve_temp->
     encntr_list[gve_encntr_cnt].inpatient_admit_dt_tm = e.inpatient_admit_dt_tm
    FOOT REPORT
     stat = alterlist(gve_temp->encntr_list,gve_encntr_cnt)
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE loadencounterswithinrange(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE restrict = i4 WITH noconstant(0)
   DECLARE nstart = i2 WITH protected, noconstant(1)
   IF (((mlcagind=1) OR (((gve_confid_ind=1) OR (gve_encntr_org_sec_ind=1)) )) )
    SET restrict = 1
   ENDIF
   SELECT
    IF (mlcagind=0)
     WHERE expand(i,nstart,size(request->persons,5),e.person_id,request->persons[i].person_id)
      AND ((e.disch_dt_tm > cnvtdatetime((curdate - request->encntr_lookback_days),curtime)) OR (e
     .disch_dt_tm = null))
      AND e.active_ind=1
      AND e.external_ind IN (bincinternalind, bincexternalind)
     ORDER BY e.person_id
    ELSE
     WHERE expand(i,nstart,accessible_encntr_ids->accessible_encntrs_cnt,e.encntr_id,
      accessible_encntr_ids->accessible_encntrs[i].accessible_encntr_id)
      AND ((e.disch_dt_tm > cnvtdatetime((curdate - request->encntr_lookback_days),curtime)) OR (e
     .disch_dt_tm = null))
      AND e.active_ind=1
      AND e.external_ind IN (bincinternalind, bincexternalind)
     ORDER BY e.person_id
    ENDIF
    INTO "nl:"
    FROM encounter e
    HEAD REPORT
     gve_encntr_cnt = 0, gve_timezone_cnt = 0
    DETAIL
     gve_encntr_cnt += 1
     IF (mod(gve_encntr_cnt,100)=1)
      stat = alterlist(gve_temp->encntr_list,(gve_encntr_cnt+ 99))
     ENDIF
     gve_temp->encntr_list[gve_encntr_cnt].restrict_ind = restrict, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_id = e.encntr_id, gve_temp->encntr_list[gve_encntr_cnt].person_id = e
     .person_id,
     gve_temp->encntr_list[gve_encntr_cnt].encntr_type_cd = e.encntr_type_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_type_class_cd = e.encntr_type_class_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_status_cd = e.encntr_status_cd,
     gve_temp->encntr_list[gve_encntr_cnt].reg_dt_tm = e.reg_dt_tm, gve_temp->encntr_list[
     gve_encntr_cnt].pre_reg_dt_tm = e.pre_reg_dt_tm, gve_temp->encntr_list[gve_encntr_cnt].
     location_cd = e.location_cd,
     gve_temp->encntr_list[gve_encntr_cnt].loc_facility_cd = e.loc_facility_cd, gve_temp->
     encntr_list[gve_encntr_cnt].loc_building_cd = e.loc_building_cd, gve_temp->encntr_list[
     gve_encntr_cnt].loc_nurse_unit_cd = e.loc_nurse_unit_cd,
     gve_temp->encntr_list[gve_encntr_cnt].loc_room_cd = e.loc_room_cd, gve_temp->encntr_list[
     gve_encntr_cnt].loc_bed_cd = e.loc_bed_cd, gve_temp->encntr_list[gve_encntr_cnt].loc_temp_cd = e
     .loc_temp_cd,
     gve_temp->encntr_list[gve_encntr_cnt].reason_for_visit = e.reason_for_visit, gve_temp->
     encntr_list[gve_encntr_cnt].financial_class_cd = e.financial_class_cd, gve_temp->encntr_list[
     gve_encntr_cnt].beg_effective_dt_tm = e.beg_effective_dt_tm,
     gve_temp->encntr_list[gve_encntr_cnt].disch_dt_tm = e.disch_dt_tm, gve_temp->encntr_list[
     gve_encntr_cnt].med_service_cd = e.med_service_cd, gve_temp->encntr_list[gve_encntr_cnt].
     diet_type_cd = e.diet_type_cd,
     gve_temp->encntr_list[gve_encntr_cnt].isolation_cd = e.isolation_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_financial_id = e.encntr_financial_id, gve_temp->encntr_list[
     gve_encntr_cnt].arrive_dt_tm = e.arrive_dt_tm,
     gve_temp->encntr_list[gve_encntr_cnt].est_arrive_dt_tm = e.est_arrive_dt_tm, gve_temp->
     encntr_list[gve_encntr_cnt].organization_id = e.organization_id, gve_temp->encntr_list[
     gve_encntr_cnt].confid_level = determineconfidlevel(e.confid_level_cd),
     gve_temp->encntr_list[gve_encntr_cnt].est_disch_dt_tm = e.est_depart_dt_tm, gve_temp->
     encntr_list[gve_encntr_cnt].contributor_system_cd = e.contributor_system_cd, gve_temp->
     encntr_list[gve_encntr_cnt].inpatient_admit_dt_tm = e.inpatient_admit_dt_tm
    FOOT REPORT
     stat = alterlist(gve_temp->encntr_list,gve_encntr_cnt)
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE loadencountersbydaterange(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE restrict = i4 WITH noconstant(0)
   DECLARE nstart = i2 WITH protected, noconstant(1)
   IF (((mlcagind=1) OR (((gve_confid_ind=1) OR (gve_encntr_org_sec_ind=1)) )) )
    SET restrict = 1
   ENDIF
   SELECT
    IF (mlcagind=0)
     WHERE expand(i,nstart,size(request->persons,5),e.person_id,request->persons[i].person_id)
      AND e.reg_dt_tm != null
      AND e.reg_dt_tm <= cnvtdatetime(request->encntr_to_dt_tm)
      AND ((e.disch_dt_tm != null
      AND e.disch_dt_tm >= cnvtdatetime(request->encntr_from_dt_tm)) OR (e.disch_dt_tm=null))
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND e.active_ind=1
      AND e.external_ind IN (bincinternalind, bincexternalind)
     ORDER BY e.reg_dt_tm DESC
    ELSE
     WHERE expand(i,nstart,accessible_encntr_ids->accessible_encntrs_cnt,e.encntr_id,
      accessible_encntr_ids->accessible_encntrs[i].accessible_encntr_id)
      AND e.reg_dt_tm != null
      AND e.reg_dt_tm <= cnvtdatetime(request->encntr_to_dt_tm)
      AND ((e.disch_dt_tm != null
      AND e.disch_dt_tm >= cnvtdatetime(request->encntr_from_dt_tm)) OR (e.disch_dt_tm=null))
      AND e.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND e.end_effective_dt_tm > cnvtdatetime(sysdate)
      AND e.active_ind=1
      AND e.external_ind IN (bincinternalind, bincexternalind)
     ORDER BY e.reg_dt_tm DESC
    ENDIF
    INTO "nl:"
    FROM encounter e
    HEAD REPORT
     gve_encntr_cnt = 0, gve_timezone_cnt = 0
    DETAIL
     gve_encntr_cnt += 1
     IF (mod(gve_encntr_cnt,100)=1)
      stat = alterlist(gve_temp->encntr_list,(gve_encntr_cnt+ 99))
     ENDIF
     gve_temp->encntr_list[gve_encntr_cnt].restrict_ind = restrict, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_id = e.encntr_id, gve_temp->encntr_list[gve_encntr_cnt].person_id = e
     .person_id,
     gve_temp->encntr_list[gve_encntr_cnt].encntr_type_cd = e.encntr_type_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_type_class_cd = e.encntr_type_class_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_status_cd = e.encntr_status_cd,
     gve_temp->encntr_list[gve_encntr_cnt].reg_dt_tm = e.reg_dt_tm, gve_temp->encntr_list[
     gve_encntr_cnt].pre_reg_dt_tm = e.pre_reg_dt_tm, gve_temp->encntr_list[gve_encntr_cnt].
     location_cd = e.location_cd,
     gve_temp->encntr_list[gve_encntr_cnt].loc_facility_cd = e.loc_facility_cd, gve_temp->
     encntr_list[gve_encntr_cnt].loc_building_cd = e.loc_building_cd, gve_temp->encntr_list[
     gve_encntr_cnt].loc_nurse_unit_cd = e.loc_nurse_unit_cd,
     gve_temp->encntr_list[gve_encntr_cnt].loc_room_cd = e.loc_room_cd, gve_temp->encntr_list[
     gve_encntr_cnt].loc_bed_cd = e.loc_bed_cd, gve_temp->encntr_list[gve_encntr_cnt].loc_temp_cd = e
     .loc_temp_cd,
     gve_temp->encntr_list[gve_encntr_cnt].reason_for_visit = e.reason_for_visit, gve_temp->
     encntr_list[gve_encntr_cnt].financial_class_cd = e.financial_class_cd, gve_temp->encntr_list[
     gve_encntr_cnt].beg_effective_dt_tm = e.beg_effective_dt_tm,
     gve_temp->encntr_list[gve_encntr_cnt].disch_dt_tm = e.disch_dt_tm, gve_temp->encntr_list[
     gve_encntr_cnt].med_service_cd = e.med_service_cd, gve_temp->encntr_list[gve_encntr_cnt].
     diet_type_cd = e.diet_type_cd,
     gve_temp->encntr_list[gve_encntr_cnt].isolation_cd = e.isolation_cd, gve_temp->encntr_list[
     gve_encntr_cnt].encntr_financial_id = e.encntr_financial_id, gve_temp->encntr_list[
     gve_encntr_cnt].arrive_dt_tm = e.arrive_dt_tm,
     gve_temp->encntr_list[gve_encntr_cnt].est_arrive_dt_tm = e.est_arrive_dt_tm, gve_temp->
     encntr_list[gve_encntr_cnt].organization_id = e.organization_id, gve_temp->encntr_list[
     gve_encntr_cnt].confid_level = determineconfidlevel(e.confid_level_cd),
     gve_temp->encntr_list[gve_encntr_cnt].est_disch_dt_tm = e.est_depart_dt_tm, gve_temp->
     encntr_list[gve_encntr_cnt].contributor_system_cd = e.contributor_system_cd, gve_temp->
     encntr_list[gve_encntr_cnt].inpatient_admit_dt_tm = e.inpatient_admit_dt_tm
    FOOT REPORT
     stat = alterlist(gve_temp->encntr_list,gve_encntr_cnt)
    WITH nocounter, expand = 1
   ;end select
 END ;Subroutine
 SUBROUTINE loadproviders(null)
   IF ((gve_temp->valid_encntr_cnt > 0))
    DECLARE attending = f8 WITH constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
    DECLARE admitting = f8 WITH constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
    DECLARE ordering = f8 WITH constant(uar_get_code_by("MEANING",333,"ORDERDOC"))
    DECLARE referring = f8 WITH constant(uar_get_code_by("MEANING",333,"REFERDOC"))
    DECLARE i = i4 WITH noconstant(0)
    DECLARE j = i4 WITH noconstant(0)
    SET cur_list_size = gve_temp->valid_encntr_cnt
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET nstart = 1
    SET stat = alterlist(gve_temp->valid_encntrs,new_list_size)
    FOR (i = (cur_list_size+ 1) TO new_list_size)
      SET gve_temp->valid_encntrs[i].encntr_id = gve_temp->valid_encntrs[cur_list_size].encntr_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(loop_cnt)),
      encntr_prsnl_reltn epr,
      prsnl p
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (epr
      WHERE expand(i,nstart,(nstart+ (batch_size - 1)),epr.encntr_id,gve_temp->valid_encntrs[i].
       encntr_id)
       AND epr.encntr_prsnl_r_cd IN (referring, ordering, admitting, attending)
       AND epr.active_ind=1
       AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
      JOIN (p
      WHERE p.person_id=epr.prsnl_person_id)
     ORDER BY epr.encntr_id, epr.encntr_prsnl_r_cd, epr.beg_effective_dt_tm DESC
     HEAD epr.encntr_id
      idx = locateval(j,1,gve_temp->valid_encntr_cnt,epr.encntr_id,gve_temp->valid_encntrs[j].
       encntr_id), pidx = gve_temp->valid_encntrs[idx].person_index, eidx = gve_temp->valid_encntrs[
      idx].encntr_index,
      providercnt = 0
     DETAIL
      providercnt += 1
      IF (mod(providercnt,4)=1)
       stat = alterlist(reply->persons[pidx].encntrs[eidx].provider_list,(providercnt+ 3))
      ENDIF
      reply->persons[pidx].encntrs[eidx].provider_list[providercnt].provider_id = p.person_id, reply
      ->persons[pidx].encntrs[eidx].provider_list[providercnt].provider_name = p.name_full_formatted,
      reply->persons[pidx].encntrs[eidx].provider_list[providercnt].relationship_cd = epr
      .encntr_prsnl_r_cd
     FOOT  epr.encntr_id
      stat = alterlist(reply->persons[pidx].encntrs[eidx].provider_list,providercnt), stat =
      alterlist(gve_temp->valid_encntrs,cur_list_size)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE peformvisitreltnoverride(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE k = i4 WITH noconstant(0)
   DECLARE excludecnt = i4 WITH constant(size(request->exclude_visit_reltns,5))
   DECLARE encntrcnt = i4 WITH noconstant(0)
   DECLARE reltncnt = i4 WITH noconstant(0)
   RECORD gve_temp2(
     1 encntr_list[*]
       2 encntr_id = f8
     1 reltn_list[*]
       2 reltn_id = f8
       2 encntr_id = f8
       2 epr_cd = f8
   )
   SET stat = alterlist(gve_temp2->encntr_list,gve_encntr_cnt)
   FOR (i = 1 TO gve_encntr_cnt)
     IF ((gve_temp->encntr_list[i].restrict_ind=1))
      SET encntrcnt += 1
      SET gve_temp2->encntr_list[encntrcnt].encntr_id = gve_temp->encntr_list[i].encntr_id
     ENDIF
   ENDFOR
   SET loop_cnt = ceil((cnvtreal(encntrcnt)/ batch_size))
   SET new_list_size = (loop_cnt * batch_size)
   SET nstart = 1
   SET stat = alterlist(gve_temp2->encntr_list,new_list_size)
   FOR (i = (encntrcnt+ 1) TO new_list_size)
     SET gve_temp2->encntr_list[i].encntr_id = gve_temp2->encntr_list[encntrcnt].encntr_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(loop_cnt)),
     encntr_prsnl_reltn epr
    PLAN (d
     WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
     JOIN (epr
     WHERE expand(i,nstart,(nstart+ (batch_size - 1)),epr.encntr_id,gve_temp2->encntr_list[i].
      encntr_id)
      AND epr.prsnl_person_id=request_prsnl_id
      AND ((epr.expiration_ind+ 0)=0)
      AND epr.active_ind=1
      AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     reltncnt += 1
     IF (mod(reltncnt,50)=1)
      stat = alterlist(gve_temp2->reltn_list,(reltncnt+ 49))
     ENDIF
     gve_temp2->reltn_list[reltncnt].encntr_id = epr.encntr_id, gve_temp2->reltn_list[reltncnt].
     reltn_id = epr.encntr_prsnl_reltn_id, gve_temp2->reltn_list[reltncnt].epr_cd = epr
     .encntr_prsnl_r_cd
    WITH nocounter
   ;end select
   FOR (i = 1 TO reltncnt)
     FOR (j = 1 TO excludecnt)
       IF ((gve_temp2->reltn_list[i].reltn_id=request->exclude_visit_reltns[j].encntr_prsnl_reltn_id)
       )
        SET gve_temp2->reltn_list[i].encntr_id = - (1)
       ENDIF
     ENDFOR
   ENDFOR
   FOR (i = 1 TO reltncnt)
     IF ((gve_temp2->reltn_list[i].encntr_id > 0))
      FOR (j = 1 TO gve_encntr_cnt)
        IF ((gve_temp->encntr_list[j].encntr_id=gve_temp2->reltn_list[i].encntr_id))
         SET gve_temp->encntr_list[j].restrict_ind = 0
         SET gve_secure_cnt -= 1
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FREE RECORD gve_temp2
 END ;Subroutine
 SUBROUTINE performlifereltnoverride(null)
   DECLARE exclude_cnt = i4 WITH noconstant(size(request->exclude_life_reltns,5)), private
   DECLARE begin = i4 WITH noconstant(1), private
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   DECLARE found = i4 WITH noconstant(0)
   DECLARE personcnt = i4 WITH noconstant(0)
   DECLARE pprfound = i4 WITH noconstant(0)
   DECLARE reltncnt = i4 WITH noconstant(0)
   DECLARE pprtype = i4 WITH noconstant(0), private
   RECORD gve_temp2(
     1 person_list[*]
       2 person_id = f8
     1 reltn_list[*]
       2 reltn_id = f8
       2 person_id = f8
       2 ppr_cd = f8
       2 type = i4
   )
   SELECT INTO "nl:"
    FROM code_value_extension cve
    PLAN (cve
     WHERE cve.code_set=331
      AND cve.field_name="Override"
      AND cve.field_value IN ("1", "2"))
    HEAD REPORT
     pprfound = 1
    WITH nocounter, maxqual = 1
   ;end select
   IF (pprfound=1)
    SET stat = alterlist(gve_temp2->person_list,gve_sz)
    FOR (i = 1 TO gve_encntr_cnt)
      IF ((gve_temp->encntr_list[i].restrict_ind=1))
       SET found = 0
       FOR (j = 1 TO personcnt)
         IF ((gve_temp->encntr_list[i].person_id=gve_temp2->person_list[j].person_id))
          SET found = 1
          SET j = (personcnt+ 1)
         ENDIF
       ENDFOR
       IF (found=0)
        SET personcnt += 1
        SET gve_temp2->person_list[personcnt].person_id = gve_temp->encntr_list[i].person_id
       ENDIF
      ENDIF
    ENDFOR
    SET cur_list_size = personcnt
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET nstart = 1
    SET stat = alterlist(gve_temp2->person_list,new_list_size)
    FOR (i = (personcnt+ 1) TO new_list_size)
      SET gve_temp2->person_list[i].person_id = gve_temp2->person_list[personcnt].person_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(loop_cnt)),
      person_prsnl_reltn ppr,
      code_value_extension cve
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (ppr
      WHERE ppr.prsnl_person_id=request_prsnl_id
       AND ppr.active_ind=1
       AND expand(i,nstart,(nstart+ (batch_size - 1)),ppr.person_id,gve_temp2->person_list[i].
       person_id)
       AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
      JOIN (cve
      WHERE cve.code_value=ppr.person_prsnl_r_cd
       AND cve.code_set=331
       AND cve.field_name="Override"
       AND cve.field_value IN ("1", "2"))
     DETAIL
      reltncnt += 1
      IF (mod(reltncnt,10)=1)
       stat = alterlist(gve_temp2->reltn_list,(reltncnt+ 9))
      ENDIF
      gve_temp2->reltn_list[reltncnt].reltn_id = ppr.person_prsnl_reltn_id, gve_temp2->reltn_list[
      reltncnt].person_id = ppr.person_id, gve_temp2->reltn_list[reltncnt].ppr_cd = ppr
      .person_prsnl_r_cd,
      gve_temp2->reltn_list[reltncnt].type = cnvtint(cve.field_value)
     WITH nocounter
    ;end select
    FOR (i = 1 TO reltncnt)
     FOR (j = 1 TO exclude_cnt)
       IF ((gve_temp2->reltn_list[i].reltn_id=request->exclude_life_reltns[j].person_prsnl_reltn_id))
        SET gve_temp2->reltn_list[i].type = 0
        SET j = (exclude_cnt+ 1)
       ENDIF
     ENDFOR
     IF ((gve_temp2->reltn_list[i].type > 0))
      FOR (j = 1 TO gve_encntr_cnt)
        IF ((gve_temp->encntr_list[j].restrict_ind=1)
         AND (gve_temp->encntr_list[j].person_id=gve_temp2->reltn_list[i].person_id)
         AND ((gve_confid_ind=0) OR ((((gve_temp->encntr_list[j].confid_level=0)) OR ((gve_temp2->
        reltn_list[i].type=2))) )) )
         SET gve_temp->encntr_list[j].restrict_ind = 0
         SET gve_secure_cnt -= 1
        ENDIF
      ENDFOR
     ENDIF
    ENDFOR
   ENDIF
   FREE RECORD gve_temp2
 END ;Subroutine
 SUBROUTINE (determineconfidlevel(confid_cd=f8) =i4)
   IF (confid_cd <= 0)
    RETURN(0)
   ENDIF
   DECLARE confidcdloc = i4 WITH noconstant(0)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE confidcdsize = i4 WITH constant(size(gve_confid_codes->list,5))
   SET confidcdloc = locateval(num,1,confidcdsize,confid_cd,gve_confid_codes->list[num].code_value)
   IF (confidcdloc=0)
    RETURN(0)
   ENDIF
   SET retval = gve_confid_codes->list[confidcdloc].coll_seq
   IF (retval < 0)
    SET retval = 0
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SUBROUTINE loadtimezones(null)
   DECLARE facilitycnt = i4 WITH noconstant(0)
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE found = i4 WITH noconstant(0), private
   IF (curutc > 0
    AND (gve_temp->valid_encntr_cnt > 0))
    RECORD encntrloctzreq(
      1 encntrs[*]
        2 encntr_id = f8
        2 transaction_dt_tm = dq8
      1 facilities[*]
        2 loc_facility_cd = f8
    )
    RECORD encntrloctzrep(
      1 encntrs_qual_cnt = i4
      1 encntrs[*]
        2 encntr_id = f8
        2 time_zone_indx = i4
        2 time_zone = vc
        2 transaction_dt_tm = dq8
        2 check = i2
        2 status = i2
        2 loc_fac_cd = f8
      1 facilities_qual_cnt = i4
      1 facilities[*]
        2 loc_facility_cd = f8
        2 time_zone_indx = i4
        2 time_zone = vc
        2 status = i2
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET stat = alterlist(encntrloctzreq->facilities,gve_temp->valid_encntr_cnt)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = gve_temp->valid_encntr_cnt)
     PLAN (d
      WHERE (gve_temp->valid_encntrs[d.seq].facility_cd > 0.0))
     ORDER BY gve_temp->valid_encntrs[d.seq].facility_cd
     DETAIL
      IF (((facilitycnt=0) OR ((encntrloctzreq->facilities[facilitycnt].loc_facility_cd != gve_temp->
      valid_encntrs[d.seq].facility_cd))) )
       facilitycnt += 1, encntrloctzreq->facilities[facilitycnt].loc_facility_cd = gve_temp->
       valid_encntrs[d.seq].facility_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(encntrloctzreq->facilities,facilitycnt)
     WITH nocounter
    ;end select
    IF (facilitycnt > 0)
     EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST",encntrloctzreq), replace("REPLY",
      encntrloctzrep)
     IF ((encntrloctzrep->status_data.status="F"))
      CALL echo("Failed Timezone")
      CALL echorecord(encntrloctzreq)
      CALL echorecord(encntrloctzrep)
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = encntrloctzrep->status_data.
      subeventstatus[1].targetobjectvalue
     ELSE
      SET facilitycnt = size(encntrloctzrep->facilities,5)
      SELECT INTO "nl:"
       FROM (dummyt d1  WITH seq = facilitycnt),
        (dummyt d2  WITH seq = gve_temp->valid_encntr_cnt)
       PLAN (d1)
        JOIN (d2
        WHERE (gve_temp->valid_encntrs[d2.seq].facility_cd=encntrloctzrep->facilities[d1.seq].
        loc_facility_cd))
       DETAIL
        pidx = gve_temp->valid_encntrs[d2.seq].person_index, eidx = gve_temp->valid_encntrs[d2.seq].
        encntr_index, reply->persons[pidx].encntrs[eidx].time_zone_indx = encntrloctzrep->facilities[
        d1.seq].time_zone_indx
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    FREE RECORD encntrloctzrep
    FREE RECORD encntrloctzreq
   ENDIF
 END ;Subroutine
 SUBROUTINE populatereply(null)
   DECLARE i = i4 WITH noconstant(0), private
   DECLARE j = i4 WITH noconstant(0), private
   DECLARE personcnt = i4 WITH noconstant(0), private
   DECLARE encntrcnt = i4 WITH noconstant(0), private
   DECLARE providercnt = i4 WITH noconstant(0), private
   DECLARE lastpersonid = f8 WITH noconstant(- (1.0)), private
   DECLARE restrict = i4 WITH noconstant(0), private
   IF (((mlcagind=1) OR (((gve_confid_ind=1) OR (gve_encntr_org_sec_ind=1)) )) )
    SET restrict = 1
   ENDIF
   SET gve_temp->valid_encntr_cnt = 0
   SET stat = alterlist(gve_temp->valid_encntrs,gve_encntr_cnt)
   SET stat = alterlist(reply->persons,gve_sz)
   FOR (i = 1 TO gve_encntr_cnt)
     IF ((((gve_temp->encntr_list[i].restrict_ind=0)) OR (mlcagind=1)) )
      IF ((gve_temp->encntr_list[i].person_id > lastpersonid))
       IF (personcnt >= 0)
        SET stat = alterlist(reply->persons[personcnt].encntrs,encntrcnt)
       ENDIF
       SET lastpersonid = gve_temp->encntr_list[i].person_id
       SET personcnt += 1
       SET encntrcnt = 0
       SET reply->persons[personcnt].person_id = gve_temp->encntr_list[i].person_id
       SET reply->persons[personcnt].restrict_ind = restrict
      ENDIF
      SET encntrcnt += 1
      IF (mod(encntrcnt,10)=1)
       SET stat = alterlist(reply->persons[personcnt].encntrs,(encntrcnt+ 9))
      ENDIF
      SET gve_temp->valid_encntr_cnt += 1
      SET gve_temp->valid_encntrs[gve_temp->valid_encntr_cnt].encntr_id = gve_temp->encntr_list[i].
      encntr_id
      SET gve_temp->valid_encntrs[gve_temp->valid_encntr_cnt].facility_cd = gve_temp->encntr_list[i].
      loc_facility_cd
      SET gve_temp->valid_encntrs[gve_temp->valid_encntr_cnt].person_index = personcnt
      SET gve_temp->valid_encntrs[gve_temp->valid_encntr_cnt].encntr_index = encntrcnt
      SET reply->persons[personcnt].encntrs[encntrcnt].encntr_id = gve_temp->encntr_list[i].encntr_id
      SET reply->persons[personcnt].encntrs[encntrcnt].encntr_type_cd = gve_temp->encntr_list[i].
      encntr_type_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].encntr_type_class_cd = gve_temp->encntr_list[i
      ].encntr_type_class_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].encntr_status_cd = gve_temp->encntr_list[i].
      encntr_status_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].contributor_system_cd = gve_temp->encntr_list[
      i].contributor_system_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].reg_dt_tm = gve_temp->encntr_list[i].reg_dt_tm
      SET reply->persons[personcnt].encntrs[encntrcnt].pre_reg_dt_tm = gve_temp->encntr_list[i].
      pre_reg_dt_tm
      SET reply->persons[personcnt].encntrs[encntrcnt].est_arrive_dt_tm = gve_temp->encntr_list[i].
      est_arrive_dt_tm
      SET reply->persons[personcnt].encntrs[encntrcnt].est_disch_dt_tm = gve_temp->encntr_list[i].
      est_disch_dt_tm
      SET reply->persons[personcnt].encntrs[encntrcnt].location_cd = gve_temp->encntr_list[i].
      location_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].loc_facility_cd = gve_temp->encntr_list[i].
      loc_facility_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].loc_building_cd = gve_temp->encntr_list[i].
      loc_building_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].loc_nurse_unit_cd = gve_temp->encntr_list[i].
      loc_nurse_unit_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].loc_room_cd = gve_temp->encntr_list[i].
      loc_room_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].loc_bed_cd = gve_temp->encntr_list[i].
      loc_bed_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].loc_temp_cd = gve_temp->encntr_list[i].
      loc_temp_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].reason_for_visit = gve_temp->encntr_list[i].
      reason_for_visit
      SET reply->persons[personcnt].encntrs[encntrcnt].financial_class_cd = gve_temp->encntr_list[i].
      financial_class_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].beg_effective_dt_tm = gve_temp->encntr_list[i]
      .beg_effective_dt_tm
      SET reply->persons[personcnt].encntrs[encntrcnt].disch_dt_tm = gve_temp->encntr_list[i].
      disch_dt_tm
      SET reply->persons[personcnt].encntrs[encntrcnt].med_service_cd = gve_temp->encntr_list[i].
      med_service_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].diet_type_cd = gve_temp->encntr_list[i].
      diet_type_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].isolation_cd = gve_temp->encntr_list[i].
      isolation_cd
      SET reply->persons[personcnt].encntrs[encntrcnt].encntr_financial_id = gve_temp->encntr_list[i]
      .encntr_financial_id
      SET reply->persons[personcnt].encntrs[encntrcnt].arrive_dt_tm = gve_temp->encntr_list[i].
      arrive_dt_tm
      SET reply->persons[personcnt].encntrs[encntrcnt].organization_id = gve_temp->encntr_list[i].
      organization_id
      SET reply->persons[personcnt].encntrs[encntrcnt].time_zone_indx = gve_temp->encntr_list[i].
      time_zone_indx
      IF (validate(reply->persons[personcnt].encntrs[encntrcnt].inpatient_admit_dt_tm) > 0)
       SET reply->persons[personcnt].encntrs[encntrcnt].inpatient_admit_dt_tm = gve_temp->
       encntr_list[i].inpatient_admit_dt_tm
      ENDIF
      SET reply->persons[personcnt].encntrs[encntrcnt].encntr_type_class_mean = uar_get_code_meaning(
       reply->persons[personcnt].encntrs[encntrcnt].encntr_type_class_cd)
      SET reply->persons[personcnt].encntrs[encntrcnt].encntr_status_mean = uar_get_code_meaning(
       reply->persons[personcnt].encntrs[encntrcnt].encntr_status_cd)
      SET reply->persons[personcnt].encntrs[encntrcnt].med_service_disp = uar_get_code_display(reply
       ->persons[personcnt].encntrs[encntrcnt].med_service_cd)
      SET reply->persons[personcnt].encntrs[encntrcnt].isolation_disp = uar_get_code_display(reply->
       persons[personcnt].encntrs[encntrcnt].isolation_cd)
      SET reply->persons[personcnt].encntrs[encntrcnt].diet_type_disp = uar_get_code_display(reply->
       persons[personcnt].encntrs[encntrcnt].diet_type_cd)
      SET reply->persons[personcnt].encntrs[encntrcnt].diet_type_mean = uar_get_code_meaning(reply->
       persons[personcnt].encntrs[encntrcnt].diet_type_cd)
      SET reply->persons[personcnt].encntrs[encntrcnt].location_disp = uar_get_code_display(reply->
       persons[personcnt].encntrs[encntrcnt].location_cd)
     ENDIF
   ENDFOR
   IF (personcnt > 0)
    SET stat = alterlist(reply->persons[personcnt].encntrs,encntrcnt)
   ENDIF
   SET stat = alterlist(reply->persons,personcnt)
 END ;Subroutine
 SUBROUTINE loadencounteraliases(null)
   DECLARE i = i4 WITH noconstant(0)
   DECLARE j = i4 WITH noconstant(0)
   IF ((gve_temp->valid_encntr_cnt > 0))
    SET cur_list_size = gve_temp->valid_encntr_cnt
    SET loop_cnt = ceil((cnvtreal(cur_list_size)/ batch_size))
    SET new_list_size = (loop_cnt * batch_size)
    SET nstart = 1
    SET stat = alterlist(gve_temp->valid_encntrs,new_list_size)
    FOR (i = (cur_list_size+ 1) TO new_list_size)
      SET gve_temp->valid_encntrs[i].encntr_id = gve_temp->valid_encntrs[cur_list_size].encntr_id
    ENDFOR
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value(loop_cnt)),
      encntr_alias ea
     PLAN (d
      WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
      JOIN (ea
      WHERE expand(i,nstart,(nstart+ (batch_size - 1)),ea.encntr_id,gve_temp->valid_encntrs[i].
       encntr_id)
       AND ea.active_ind=1
       AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
       AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
     ORDER BY ea.encntr_id
     HEAD ea.encntr_id
      idx = locateval(j,1,gve_temp->valid_encntr_cnt,ea.encntr_id,gve_temp->valid_encntrs[j].
       encntr_id), pidx = gve_temp->valid_encntrs[idx].person_index, eidx = gve_temp->valid_encntrs[
      idx].encntr_index,
      aliascnt = 0
     DETAIL
      IF (pidx > 0
       AND eidx > 0)
       aliascnt += 1
       IF (mod(aliascnt,3)=1)
        stat = alterlist(reply->persons[pidx].encntrs[eidx].alias_list,(aliascnt+ 2))
       ENDIF
       reply->persons[pidx].encntrs[eidx].alias_list[aliascnt].alias = cnvtalias(ea.alias,ea
        .alias_pool_cd), reply->persons[pidx].encntrs[eidx].alias_list[aliascnt].alias_type_cd = ea
       .encntr_alias_type_cd, reply->persons[pidx].encntrs[eidx].alias_list[aliascnt].alias_status_cd
        = ea.data_status_cd,
       reply->persons[pidx].encntrs[eidx].alias_list[aliascnt].contributor_system_cd = ea
       .contributor_system_cd
      ENDIF
     FOOT  ea.encntr_id
      stat = alterlist(reply->persons[pidx].encntrs[eidx].alias_list,aliascnt)
     WITH nocounter
    ;end select
   ENDIF
 END ;Subroutine
 SET modify = nopredeclare
#exit_script
 IF (sfailed="F")
  IF (size(reply->persons,5) > 0)
   SET reply->status_data.status = "S"
  ELSEIF (size(reply->persons,5)=0)
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
END GO
