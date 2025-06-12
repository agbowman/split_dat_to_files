CREATE PROGRAM bsc_get_orders_for_protocol:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 protocol_order_list[*]
     2 protocol_order_id = f8
     2 protocol_start_dt_tm = dq8
     2 protocol_start_tz = i4
     2 protocol_stop_dt_tm = dq8
     2 protocol_stop_tz = i4
     2 template_order_list[*]
       3 template_order_id = f8
       3 template_start_dt_tm = dq8
       3 template_start_tz = i4
       3 template_stop_dt_tm = dq8
       3 template_stop_tz = i4
       3 template_encntr_id = f8
       3 template_order_status_cd = f8
       3 template_seq = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE initialize(null) = null
 DECLARE loadfromprotocol(null) = null
 DECLARE loadfromtemplate(null) = null
 DECLARE checksecurity(null) = null
 DECLARE checkorgsecurity(null) = null
 DECLARE protocol_cnt = i4 WITH noconstant(0)
 DECLARE template_cnt = i4 WITH noconstant(0)
 DECLARE debug_ind = i2 WITH noconstant(0)
 DECLARE temp_order_cnt = i4 WITH noconstant(0)
 DECLARE proto_order_cnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE person_id = f8 WITH protect, noconstant(0)
 DECLARE has_access_ind = i2 WITH protect, noconstant(1)
 DECLARE encntrs_api_stat = i2 WITH protect, noconstant(0)
 DECLARE starttime = f8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE protocol_flag = i4 WITH constant(7)
 FREE RECORD internal_encntrs
 RECORD internal_encntrs(
   1 encntr_list[*]
     2 encntr_id = f8
 )
 CALL initialize(null)
 IF ((request->skip_org_sec_check != 1))
  CALL checksecurity(null)
 ELSE
  SET stat = alterlist(internal_encntrs->encntr_list,size(request->encntr_list,5))
  FOR (inencntridx = 1 TO size(request->encntr_list,5))
    SET internal_encntrs->encntr_list[inencntridx].encntr_id = request->encntr_list[inencntridx].
    encntr_id
  ENDFOR
 ENDIF
 IF (encntrs_api_stat != 2
  AND has_access_ind=1)
  IF (protocol_cnt > 0)
   CALL loadfromprotocol(null)
  ELSEIF (template_cnt > 0)
   CALL loadfromtemplate(null)
  ENDIF
 ENDIF
 IF (encntrs_api_stat=2)
  SET reply->status_data.status = "F"
 ELSEIF (proto_order_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL printdebug("*********************************")
  CALL printdebug(build("ERROR MESSAGE : ",error_msg))
  CALL printdebug("*********************************")
  SET reply->status_data.status = "F"
 ENDIF
 CALL printdebug(build("********bsc_get_orders_for_protocol Time = ",datetimediff(cnvtdatetime(
     sysdate),starttime,5)))
 SUBROUTINE initialize(null)
   SET debug_ind = request->debug_ind
   CALL printdebug("Subroutine: Initialize")
   SET protocol_cnt = size(request->protocol_order_list,5)
   SET template_cnt = size(request->template_order_list,5)
 END ;Subroutine
 SUBROUTINE loadfromprotocol(null)
   IF (debug_ind > 0)
    DECLARE initializetime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   ENDIF
   DECLARE iord = i4 WITH protect, noconstant(0)
   DECLARE oidx = i4 WITH protect, noconstant(0)
   DECLARE ienc = i4 WITH protect, noconstant(0)
   DECLARE iencsize = i4 WITH protect, noconstant(size(internal_encntrs->encntr_list,5))
   CALL printdebug("Subroutine: LoadFromProtocol")
   SELECT
    IF (iencsize > 0)
     PLAN (o
      WHERE expand(iord,1,protocol_cnt,o.order_id,request->protocol_order_list[iord].
       protocol_order_id)
       AND o.template_order_flag=protocol_flag)
      JOIN (o2
      WHERE o2.protocol_order_id=o.order_id
       AND o2.template_order_id=0
       AND expand(ienc,1,iencsize,o2.encntr_id,internal_encntrs->encntr_list[ienc].encntr_id))
      JOIN (apc
      WHERE apc.parent_entity_id=o2.order_id
       AND apc.parent_entity_name="ORDERS")
      JOIN (pw
      WHERE pw.pathway_id=apc.pathway_id)
    ELSE
     PLAN (o
      WHERE expand(iord,1,protocol_cnt,o.order_id,request->protocol_order_list[iord].
       protocol_order_id)
       AND o.template_order_flag=protocol_flag)
      JOIN (o2
      WHERE o2.protocol_order_id=o.order_id
       AND o2.template_order_id=0)
      JOIN (apc
      WHERE apc.parent_entity_id=o2.order_id
       AND apc.parent_entity_name="ORDERS")
      JOIN (pw
      WHERE pw.pathway_id=apc.pathway_id)
    ENDIF
    INTO "nl:"
    FROM orders o,
     orders o2,
     act_pw_comp apc,
     pathway pw
    ORDER BY o2.protocol_order_id, o2.order_id
    HEAD REPORT
     temp_order_cnt = 0, proto_order_cnt = 0
    HEAD o2.protocol_order_id
     temp_order_cnt = 0, proto_order_cnt += 1
     IF (size(reply->protocol_order_list,5) < proto_order_cnt)
      stat = alterlist(reply->protocol_order_list,(proto_order_cnt+ 19))
     ENDIF
     reply->protocol_order_list[proto_order_cnt].protocol_order_id = o.order_id, reply->
     protocol_order_list[proto_order_cnt].protocol_start_dt_tm = o.current_start_dt_tm, reply->
     protocol_order_list[proto_order_cnt].protocol_start_tz = o.current_start_tz,
     reply->protocol_order_list[proto_order_cnt].protocol_stop_dt_tm = o.projected_stop_dt_tm, reply
     ->protocol_order_list[proto_order_cnt].protocol_stop_tz = o.projected_stop_tz
    DETAIL
     IF (o2.template_order_flag != 7)
      CALL printdebug(build("order id",o2.order_id)), temp_order_cnt += 1
      IF (size(reply->protocol_order_list[proto_order_cnt].template_order_list,5) < temp_order_cnt)
       stat = alterlist(reply->protocol_order_list[proto_order_cnt].template_order_list,(
        temp_order_cnt+ 19))
      ENDIF
      reply->protocol_order_list[proto_order_cnt].template_order_list[temp_order_cnt].
      template_order_id = o2.order_id, reply->protocol_order_list[proto_order_cnt].
      template_order_list[temp_order_cnt].template_start_dt_tm = o2.current_start_dt_tm, reply->
      protocol_order_list[proto_order_cnt].template_order_list[temp_order_cnt].template_start_tz = o2
      .current_start_tz,
      reply->protocol_order_list[proto_order_cnt].template_order_list[temp_order_cnt].
      template_stop_dt_tm = pw.calc_end_dt_tm, reply->protocol_order_list[proto_order_cnt].
      template_order_list[temp_order_cnt].template_stop_tz = o2.projected_stop_tz, reply->
      protocol_order_list[proto_order_cnt].template_order_list[temp_order_cnt].template_encntr_id =
      o2.encntr_id,
      reply->protocol_order_list[proto_order_cnt].template_order_list[temp_order_cnt].
      template_order_status_cd = o2.order_status_cd, reply->protocol_order_list[proto_order_cnt].
      template_order_list[temp_order_cnt].template_seq = o2.day_of_treatment_sequence
     ENDIF
    FOOT  o2.protocol_order_id
     stat = alterlist(reply->protocol_order_list[proto_order_cnt].template_order_list,temp_order_cnt),
     temp_order_cnt = 0
    FOOT REPORT
     stat = alterlist(reply->protocol_order_list,proto_order_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE loadfromtemplate(null)
   IF (debug_ind > 0)
    DECLARE initializetime = f8 WITH protect, noconstant(cnvtdatetime(sysdate))
   ENDIF
   DECLARE iord = i4 WITH protect, noconstant(0)
   DECLARE ienc = i4 WITH protect, noconstant(0)
   DECLARE iencsize = i4 WITH protect, noconstant(size(internal_encntrs->encntr_list,5))
   CALL printdebug("Subroutine: LoadFromTemplate")
   SELECT DISTINCT INTO "nl:"
    FROM orders o
    WHERE expand(iord,1,template_cnt,o.order_id,request->template_order_list[iord].template_order_id)
    ORDER BY o.protocol_order_id
    HEAD REPORT
     proto_order_cnt = 0
    DETAIL
     IF (o.protocol_order_id > 0)
      proto_order_cnt += 1
      IF (size(request->protocol_order_list,5) < proto_order_cnt)
       stat = alterlist(request->protocol_order_list,(proto_order_cnt+ 19))
      ENDIF
      request->protocol_order_list[proto_order_cnt].protocol_order_id = o.protocol_order_id
     ENDIF
    FOOT REPORT
     stat = alterlist(request->protocol_order_list,proto_order_cnt)
    WITH nocounter
   ;end select
   SET protocol_cnt = size(request->protocol_order_list,5)
   IF (protocol_cnt > 0)
    CALL loadfromprotocol(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE (printdebug(msg=vc) =null)
   IF (debug_ind > 0)
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SUBROUTINE checksecurity(null)
   IF (debug_ind)
    CALL echo("*** Checking Security ***")
   ENDIF
   DECLARE lencntrcnt = i4 WITH protect, noconstant(0)
   DECLARE lencntridx = i4 WITH protect, noconstant(0)
   DECLARE inencntridx = i4 WITH protect, noconstant(0)
   DECLARE curlistsize = i4 WITH protect, noconstant(0)
   SET modify = nopredeclare
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
        SET stat = alterlist(accessible_encntr_ids->accessible_encntrs,encounter_count)
        SET accessible_encntr_ids->accessible_encntrs_cnt = encounter_count
        FOR (e_count = 1 TO encounter_count)
         SET hencounter = uar_srvgetitem(h3202611srvrep,"encounterIds",(e_count - 1))
         SET accessible_encntr_ids->accessible_encntrs[e_count].accessible_encntr_id =
         uar_srvgetdouble(hencounter,"encounterId")
        ENDFOR
       ENDIF
      ENDIF
      RETURN(0)
     ELSE
      SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(access_encntr_req_number)
       )
      RETURN(1)
     ENDIF
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_ids_by_person_ids(accessible_encntr_person_ids=vc(ref),concept=
    vc,disable_access_security_ind=i2(value,0),user_id=f8(value,0.0)) =i4)
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
       SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->
        person_ids[p_count].person_id)
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
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number))
        RETURN(1)
       ENDIF
     ENDFOR
     RETURN(0)
   END ;Subroutine
   SUBROUTINE (get_accessible_encntr_ids_by_person_ids_map(accessible_encntr_person_ids=vc(ref),
    concept=vc,disable_access_security_ind=i2(value,0)) =i4)
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
       SET stat = uar_srvsetdouble(h3202611srvreq,"patientId",accessible_encntr_person_ids->
        person_ids[p_count].person_id)
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
        SET getaccessibleencntrerrormsg = build2("Failure for call to ",build(
          access_encntr_req_number))
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
     SET featuretogglestat = isfeaturetoggleon(
      "urn:cerner:millennium:accessible-encounters-by-concept","urn:cerner:millennium",
      featuretoggleflag)
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
      SET slogtext = build2("get_accessible_encntr_toggle - chartAccessStat is ",build(
        chartaccessstat))
      CALL uar_sysevent(hsys,4,"pm_get_access_encntr_by_person",nullterm(slogtext))
      SET slogtext = build2("get_accessible_encntr_toggle - chartAccessFlag is ",build(
        chartaccessflag))
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
       SET getaccessibleencntrtoggleerrormsg = build2(
        "Failed to get transaction status from reply of ",build(feature_toggle_req_number))
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
   SUBROUTINE (getaccessibleencounters(person_id=f8,debug_ind=i2) =i4)
     DECLARE accessible_encntrs_stat = i4 WITH protect, noconstant(0)
     DECLARE chart_access_stat = i2 WITH protect, noconstant(0)
     DECLARE chart_access_flag = i2 WITH protect, noconstant(false)
     DECLARE mrd_concept_string = vc WITH protect, constant("MEDICATION_RECORD")
     SET accessible_encntrs_stat = get_accessible_encntr_ids_by_person_id(person_id,
      mrd_concept_string)
     IF (accessible_encntrs_stat=0)
      IF (debug_ind)
       CALL echo("User's Accessible Encounters: ")
       CALL echorecord(accessible_encntr_ids)
      ENDIF
      RETURN(0)
     ELSE
      IF (debug_ind)
       CALL echo(build("Encounter Retrieval Failed because:",getaccessibleencntrerrormsg))
      ENDIF
      SET chart_access_stat = ischartaccesson(mrd_concept_string,chart_access_flag)
      IF (chart_access_stat=0
       AND chart_access_flag=false)
       IF (debug_ind)
        CALL echo("Chart Access is disabled, so legacy implementation can be used")
       ENDIF
       RETURN(1)
      ELSE
       IF (debug_ind)
        CALL echo("Chart Access is enabled, so legacy implementation can't be used")
       ENDIF
       RETURN(2)
      ENDIF
     ENDIF
   END ;Subroutine
   SET modify = predeclare
   IF (protocol_cnt > 0)
    SELECT INTO "nl:"
     FROM orders o
     WHERE (o.order_id=request->protocol_order_list[1].protocol_order_id)
     DETAIL
      person_id = o.person_id
     WITH nocounter
    ;end select
   ELSEIF (template_cnt > 0)
    SELECT INTO "nl:"
     FROM orders o
     WHERE (o.order_id=request->template_order_list[1].template_order_id)
     DETAIL
      person_id = o.person_id
     WITH nocounter
    ;end select
   ELSE
    IF (debug_ind)
     CALL echo(
      "person_id is 0 as there is no protocol_order_id or template_order_id present in the request")
    ENDIF
   ENDIF
   SET encntrs_api_stat = getaccessibleencounters(person_id,debug_ind)
   IF (encntrs_api_stat=0)
    SET lencntrcnt = accessible_encntr_ids->accessible_encntrs_cnt
    IF (lencntrcnt > 0)
     IF (size(request->encntr_list,5) > 0)
      FOR (inencntridx = 1 TO size(request->encntr_list,5))
        FOR (lencntridx = 1 TO lencntrcnt)
          IF ((request->encntr_list[inencntridx].encntr_id=accessible_encntr_ids->accessible_encntrs[
          lencntridx].accessible_encntr_id))
           SET curlistsize = (size(internal_encntrs->encntr_list,5)+ 1)
           SET stat = alterlist(internal_encntrs->encntr_list,curlistsize)
           SET internal_encntrs->encntr_list[curlistsize].encntr_id = request->encntr_list[
           inencntridx].encntr_id
           SET lencntridx = lencntrcnt
          ENDIF
        ENDFOR
      ENDFOR
     ELSE
      SET stat = alterlist(internal_encntrs->encntr_list,lencntrcnt)
      FOR (lencntridx = 1 TO lencntrcnt)
        SET internal_encntrs->encntr_list[lencntridx].encntr_id = accessible_encntr_ids->
        accessible_encntrs[lencntridx].accessible_encntr_id
      ENDFOR
     ENDIF
    ENDIF
    IF (size(internal_encntrs->encntr_list,5)=0)
     SET has_access_ind = 0
    ENDIF
   ELSEIF (encntrs_api_stat=1)
    CALL checkorgsecurity(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE checkorgsecurity(null)
   IF (debug_ind)
    CALL echo("*** Checking Org Security ***")
   ENDIF
   DECLARE inencntridx = i4 WITH noconstant(0)
   DECLARE orgsecidx = i4 WITH noconstant(0)
   DECLARE curlistsize = i4 WITH noconstant(0)
   FREE RECORD valid_req
   RECORD valid_req(
     1 prsnl_id = f8
     1 person_id = f8
   )
   IF (protocol_cnt > 0)
    SELECT INTO "nl:"
     FROM orders o
     WHERE (o.order_id=request->protocol_order_list[1].protocol_order_id)
     DETAIL
      person_id = o.person_id
     WITH nocounter
    ;end select
   ELSEIF (template_cnt > 0)
    SELECT INTO "nl:"
     FROM orders o
     WHERE (o.order_id=request->template_order_list[1].template_order_id)
     DETAIL
      person_id = o.person_id
     WITH nocounter
    ;end select
   ELSE
    IF (debug_ind)
     CALL echo(
      "person_id is 0 as there is no protocol_order_id or template_order_id present in the request")
    ENDIF
   ENDIF
   SET valid_req->person_id = person_id
   SET valid_req->prsnl_id = reqinfo->updt_id
   FREE RECORD pts_encntr
   RECORD pts_encntr(
     1 restrict_ind = i2
     1 encntrs
       2 data_cnt = i2
       2 data[1]
         3 encntr_id = f8
     1 lookup_status = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c8
         3 operationstatus = c1
         3 targetobjectname = c15
         3 targetobjectvalue = vc
   )
   SET modify = nopredeclare
   EXECUTE pts_get_valid_encntrs  WITH replace(request,valid_req), replace(reply,pts_encntr)
   SET modify = predeclare
   IF ((pts_encntr->restrict_ind=1))
    IF (size(request->encntr_list,5) > 0)
     FOR (inencntridx = 1 TO size(request->encntr_list,5))
       FOR (orgsecidx = 1 TO pts_encntr->encntrs.data_cnt)
         IF ((request->encntr_list[inencntridx].encntr_id=pts_encntr->encntrs.data[orgsecidx].
         encntr_id))
          SET curlistsize = (size(internal_encntrs->encntr_list,5)+ 1)
          SET stat = alterlist(internal_encntrs->encntr_list,curlistsize)
          SET internal_encntrs->encntr_list[curlistsize].encntr_id = request->encntr_list[inencntridx
          ].encntr_id
          SET orgsecidx = pts_encntr->encntrs.data_cnt
         ENDIF
       ENDFOR
     ENDFOR
    ELSE
     SET stat = alterlist(internal_encntrs->encntr_list,pts_encntr->encntrs.data_cnt)
     FOR (orgsecidx = 1 TO pts_encntr->encntrs.data_cnt)
       SET internal_encntrs->encntr_list[orgsecidx].encntr_id = pts_encntr->encntrs.data[orgsecidx].
       encntr_id
     ENDFOR
    ENDIF
    IF (size(internal_encntrs->encntr_list,5)=0)
     SET has_access_ind = 0
    ENDIF
   ELSE
    IF (size(request->encntr_list,5) > 0)
     SET stat = alterlist(internal_encntrs->encntr_list,size(request->encntr_list,5))
     FOR (inencntridx = 1 TO size(request->encntr_list,5))
       SET internal_encntrs->encntr_list[size(internal_encntrs->encntr_list,5)].encntr_id = request->
       encntr_list[inencntridx].encntr_id
     ENDFOR
    ENDIF
   ENDIF
 END ;Subroutine
 SET last_mod = "001 11/25/20"
 SET modify = nopredeclare
END GO
