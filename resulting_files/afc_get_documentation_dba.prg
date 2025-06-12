CREATE PROGRAM afc_get_documentation:dba
 SET afc_get_documentation_version = "252701.FT.004"
 RECORD events(
   1 events[*]
     2 order_id = f8
     2 cs_order_id = f8
     2 order_mnem = c15
     2 catalog_cd = f8
     2 event_id = f8
     2 task_id = f8
     2 reference_task_id = f8
     2 parent_event_id = f8
     2 mnemonic = c15
     2 task_assay_cd = f8
     2 perform_dt_tm = dq8
     2 person_id = f8
     2 encntr_id = f8
     2 person_name = c25
     2 activity_type_cd = f8
     2 activity_type_disp = c15
     2 accession = c18
     2 result_status_cd = f8
     2 perform_result_status_cd = f8
     2 performed_flag = i2
     2 verified_flag = i2
     2 charge_event_id = f8
     2 cd_performed_flag = i2
     2 cd_verified_flag = i2
     2 bill_item_found = i2
     2 price_found = i2
     2 ce_complete_ind = i2
     2 ce_attempted_ind = i2
     2 ce_cancel_ind = i2
     2 process_ind = i2
     2 result_val = vc
     2 event_end_dt_tm = dq8
     2 location_cd = f8
     2 nomenclature[*]
       3 nomenclature_id = f8
 )
 RECORD temp_event(
   1 leventqualcnt = i4
   1 eventqual[*]
     2 parent_event_id = f8
     2 task_id = f8
 )
 DECLARE neventcnt = i2 WITH public, noconstant(0)
 DECLARE neventcnt2 = i2 WITH public, noconstant(0)
 DECLARE dtaskassay13016cd = f8 WITH public, noconstant(0.0)
 DECLARE dresultid13106cd = f8 WITH public, noconstant(0.0)
 DECLARE dordid13106cd = f8 WITH public, noconstant(0.0)
 DECLARE dordcat13106cd = f8 WITH public, noconstant(0.0)
 DECLARE dtaskcat13106cd = f8 WITH public, noconstant(0.0)
 DECLARE dtaskid13106cd = f8 WITH public, noconstant(0.0)
 DECLARE dcancelled13029cd = f8 WITH public, noconstant(0.0)
 DECLARE dattempted13029cd = f8 WITH public, noconstant(0.0)
 DECLARE dcomplete13029cd = f8 WITH public, noconstant(0.0)
 DECLARE dverified13029cd = f8 WITH public, noconstant(0.0)
 DECLARE dcredit13028cd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(13016,"TASK ASSAY",1,dtaskassay13016cd)
 IF (dtaskassay13016cd IN (0.0, null))
  CALL echo("dTaskAssay13016Cd of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13016,"RESULT ID",1,dresultid13106cd)
 IF (dresultid13106cd IN (0.0, null))
  CALL echo("dResultID13106Cd of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13016,"ORD ID",1,dordid13106cd)
 IF (dordid13106cd IN (0.0, null))
  CALL echo("dOrdID13106Cd of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13016,"ORD CAT",1,dordcat13106cd)
 IF (dordcat13106cd IN (0.0, null))
  CALL echo("dOrdCat13106Cd of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13016,"TASKCAT",1,dtaskcat13106cd)
 IF (dtaskcat13106cd IN (0.0, null))
  CALL echo("dTaskCat13106Cd of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13016,"TASK ID",1,dtaskid13106cd)
 IF (dtaskid13106cd IN (0.0, null))
  CALL echo("dTaskID13106Cd of codeset 13016 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13029,"CANCEL",1,dcancelled13029cd)
 IF (dcancelled13029cd IN (0.0, null))
  CALL echo("dCancelled13029Cd of codeset 13029 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13029,"ATTEMPTED",1,dattempted13029cd)
 IF (dattempted13029cd IN (0.0, null))
  CALL echo("dAttempted13029Cd of codeset 13029 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13029,"COMPLETE",1,dcomplete13029cd)
 IF (dcomplete13029cd IN (0.0, null))
  CALL echo("dComplete13029Cd of codeset 13029 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13029,"VERIFIED",1,dverified13029cd)
 IF (dverified13029cd IN (0.0, null))
  CALL echo("dVerified13029Cd of codeset 13029 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(13028,"CR",1,dcredit13028cd)
 IF (dcredit13028cd IN (0.0, null))
  CALL echo("dCredit13028Cd of codeset 13028 IS NULL")
  GO TO end_program
 ENDIF
 SET begdate = format(cnvtdatetime(request->beg_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 SET enddate = format(cnvtdatetime(request->end_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d")
 CALL echo("EXECUTING AFC_GET_MISSING_DOCUMENTATION NOW")
 EXECUTE afc_get_missing_documentation
 CALL echo("BACK FROM EXECUTING AFC_GET_MISSING_DOCUMENTATION")
 SET neventcnt = 0
 IF (value(size(events->events,5)) > 0)
  IF (validate(debug,- (1)) > 0)
   CALL echorecord(events)
  ENDIF
  SELECT INTO "nl:"
   d1.seq, event_id = events->events[d1.seq].event_id
   FROM (dummyt d1  WITH seq = value(size(events->events,5)))
   WHERE (events->events[d1.seq].event_id > 0.0)
    AND (events->events[d1.seq].process_ind=1)
   HEAD event_id
    IF ((events->events[d1.seq].order_id=0.0))
     neventcnt = (neventcnt+ 1), reply->charge_event_qual = neventcnt
     IF (neventcnt > size(reply->charge_event,5))
      stat = alterlist(reply->charge_event,(neventcnt+ 10))
     ENDIF
     reply->charge_event[neventcnt].ext_master_event_id = events->events[d1.seq].task_id, reply->
     charge_event[neventcnt].ext_master_event_cont_cd = dtaskid13106cd, reply->charge_event[neventcnt
     ].ext_master_reference_id = events->events[d1.seq].reference_task_id,
     reply->charge_event[neventcnt].ext_master_reference_cont_cd = dtaskcat13106cd, reply->
     charge_event[neventcnt].ext_parent_event_id = events->events[d1.seq].task_id, reply->
     charge_event[neventcnt].ext_parent_event_cont_cd = dtaskid13106cd,
     reply->charge_event[neventcnt].ext_parent_reference_id = events->events[d1.seq].
     reference_task_id, reply->charge_event[neventcnt].ext_parent_reference_cont_cd = dtaskcat13106cd,
     reply->charge_event[neventcnt].ext_item_event_id = events->events[d1.seq].event_id,
     reply->charge_event[neventcnt].ext_item_event_cont_cd = dresultid13106cd, reply->charge_event[
     neventcnt].ext_item_reference_id = events->events[d1.seq].task_assay_cd, reply->charge_event[
     neventcnt].ext_item_reference_cont_cd = dtaskassay13016cd,
     reply->charge_event[neventcnt].order_id = events->events[d1.seq].order_id, reply->charge_event[
     neventcnt].mnemonic = events->events[d1.seq].mnemonic, reply->charge_event[neventcnt].person_id
      = events->events[d1.seq].person_id,
     reply->charge_event[neventcnt].person_name = events->events[d1.seq].person_name, reply->
     charge_event[neventcnt].encntr_id = events->events[d1.seq].encntr_id
    ELSEIF ((events->events[d1.seq].task_id=0.0))
     neventcnt = (neventcnt+ 1), reply->charge_event_qual = neventcnt
     IF (neventcnt > size(reply->charge_event,5))
      stat = alterlist(reply->charge_event,(neventcnt+ 10))
     ENDIF
     reply->charge_event[neventcnt].ext_master_event_id = events->events[d1.seq].cs_order_id, reply->
     charge_event[neventcnt].ext_master_event_cont_cd = dordid13106cd, reply->charge_event[neventcnt]
     .ext_master_reference_id = events->events[d1.seq].catalog_cd,
     reply->charge_event[neventcnt].ext_master_reference_cont_cd = dordcat13106cd, reply->
     charge_event[neventcnt].ext_parent_event_id = events->events[d1.seq].order_id, reply->
     charge_event[neventcnt].ext_parent_event_cont_cd = dordid13106cd,
     reply->charge_event[neventcnt].ext_parent_reference_id = events->events[d1.seq].catalog_cd,
     reply->charge_event[neventcnt].ext_parent_reference_cont_cd = dordcat13106cd, reply->
     charge_event[neventcnt].ext_item_event_id = events->events[d1.seq].event_id,
     reply->charge_event[neventcnt].ext_item_event_cont_cd = dresultid13106cd, reply->charge_event[
     neventcnt].ext_item_reference_id = events->events[d1.seq].task_assay_cd, reply->charge_event[
     neventcnt].ext_item_reference_cont_cd = dtaskassay13016cd,
     reply->charge_event[neventcnt].order_id = events->events[d1.seq].order_id, reply->charge_event[
     neventcnt].mnemonic = events->events[d1.seq].mnemonic, reply->charge_event[neventcnt].person_id
      = events->events[d1.seq].person_id,
     reply->charge_event[neventcnt].person_name = events->events[d1.seq].person_name, reply->
     charge_event[neventcnt].encntr_id = events->events[d1.seq].encntr_id
    ELSEIF ((events->events[d1.seq].task_id > 0.0))
     neventcnt = (neventcnt+ 1), reply->charge_event_qual = neventcnt
     IF (neventcnt > size(reply->charge_event,5))
      stat = alterlist(reply->charge_event,(neventcnt+ 10))
     ENDIF
     reply->charge_event[neventcnt].ext_master_event_id = events->events[d1.seq].cs_order_id, reply->
     charge_event[neventcnt].ext_master_event_cont_cd = dordid13106cd, reply->charge_event[neventcnt]
     .ext_master_reference_id = events->events[d1.seq].catalog_cd,
     reply->charge_event[neventcnt].ext_master_reference_cont_cd = dordcat13106cd, reply->
     charge_event[neventcnt].ext_parent_event_id = events->events[d1.seq].task_id, reply->
     charge_event[neventcnt].ext_parent_event_cont_cd = dtaskid13106cd,
     reply->charge_event[neventcnt].ext_parent_reference_id = events->events[d1.seq].
     reference_task_id, reply->charge_event[neventcnt].ext_parent_reference_cont_cd = dtaskcat13106cd,
     reply->charge_event[neventcnt].ext_item_event_id = events->events[d1.seq].event_id,
     reply->charge_event[neventcnt].ext_item_event_cont_cd = dresultid13106cd, reply->charge_event[
     neventcnt].ext_item_reference_id = events->events[d1.seq].task_assay_cd, reply->charge_event[
     neventcnt].ext_item_reference_cont_cd = dtaskassay13016cd,
     reply->charge_event[neventcnt].order_id = events->events[d1.seq].order_id, reply->charge_event[
     neventcnt].mnemonic = events->events[d1.seq].mnemonic, reply->charge_event[neventcnt].person_id
      = events->events[d1.seq].person_id,
     reply->charge_event[neventcnt].person_name = events->events[d1.seq].person_name, reply->
     charge_event[neventcnt].encntr_id = events->events[d1.seq].encntr_id
    ENDIF
    reply->charge_event[neventcnt].nomen_qual = size(events->events[d1.seq].nomenclature,5)
    FOR (lloop = 1 TO size(events->events[d1.seq].nomenclature,5))
     IF (lloop > size(reply->charge_event[neventcnt].nomen,5))
      stat = alterlist(reply->charge_event[neventcnt].nomen,(lloop+ 10))
     ENDIF
     ,reply->charge_event[neventcnt].nomen[lloop].nomen_id = events->events[d1.seq].nomenclature[
     lloop].nomenclature_id
    ENDFOR
    neventcnt2 = 0
   DETAIL
    neventcnt2 = (neventcnt2+ 1)
    IF (neventcnt2 > size(reply->charge_event[neventcnt].charge_event_act,5))
     stat = alterlist(reply->charge_event[neventcnt].charge_event_act,(neventcnt2+ 10))
    ENDIF
    IF ((events->events[d1.seq].ce_complete_ind=1))
     reply->charge_event[neventcnt].charge_event_act[neventcnt2].charge_type_cd = 0.0, reply->
     charge_event[neventcnt].charge_event_act[neventcnt2].cea_type_cd = dverified13029cd, reply->
     charge_event[neventcnt].charge_event_act[neventcnt2].cea_type_disp = uar_get_code_display(
      dverified13029cd)
    ELSEIF ((events->events[d1.seq].ce_attempted_ind=1))
     reply->charge_event[neventcnt].charge_event_act[neventcnt2].charge_type_cd = 0.0, reply->
     charge_event[neventcnt].charge_event_act[neventcnt2].cea_type_cd = dattempted13029cd, reply->
     charge_event[neventcnt].charge_event_act[neventcnt2].cea_type_disp = uar_get_code_display(
      dattempted13029cd)
    ELSEIF ((events->events[d1.seq].ce_cancel_ind=1))
     reply->charge_event[neventcnt].charge_event_act[neventcnt2].charge_type_cd = dcredit13028cd,
     reply->charge_event[neventcnt].charge_event_act[neventcnt2].cea_type_cd = dcancelled13029cd,
     reply->charge_event[neventcnt].charge_event_act[neventcnt2].cea_type_disp = uar_get_code_display
     (dcancelled13029cd)
    ELSE
     reply->charge_event[neventcnt].charge_event_act[neventcnt2].charge_type_cd = 0.0, reply->
     charge_event[neventcnt].charge_event_act[neventcnt2].cea_type_cd = 0.0, reply->charge_event[
     neventcnt].charge_event_act[neventcnt2].cea_type_disp = "UNKNOWN"
    ENDIF
    reply->charge_event[neventcnt].charge_event_act[neventcnt2].charge_event_id = events->events[d1
    .seq].charge_event_id, reply->charge_event[neventcnt].charge_event_act[neventcnt2].
    service_resource_cd = 0.0, reply->charge_event[neventcnt].charge_event_act[neventcnt2].
    service_dt_tm = events->events[d1.seq].event_end_dt_tm,
    reply->charge_event[neventcnt].perf_loc_cd = events->events[d1.seq].location_cd, reply->
    charge_event[neventcnt].charge_event_act[neventcnt2].result = events->events[d1.seq].result_val,
    reply->charge_event[neventcnt].charge_event_act_qual = neventcnt2
   FOOT  event_id
    reply->charge_event_qual = neventcnt, stat = alterlist(reply->charge_event,neventcnt), stat =
    alterlist(reply->charge_event[neventcnt].nomen,reply->charge_event[neventcnt].nomen_qual),
    stat = alterlist(reply->charge_event[neventcnt].charge_event_act,neventcnt2)
   WITH nocounter
  ;end select
 ENDIF
 IF (validate(debug,- (1)) > 0)
  CALL echorecord(reply)
 ENDIF
#end_program
 FREE RECORD events
 FREE RECORD temp_event
END GO
