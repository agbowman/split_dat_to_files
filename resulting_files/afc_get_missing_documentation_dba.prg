CREATE PROGRAM afc_get_missing_documentation:dba
 SET afc_get_missing_documentation_version = "303270.FT.003"
 DECLARE ntopflag = i2 WITH public, noconstant(0)
 DECLARE neventcnt1 = i2 WITH public, noconstant(0)
 DECLARE leventqualcnt = i2 WITH public, noconstant(0)
 DECLARE dcomplete79cd = f8 WITH public, noconstant(0.0)
 DECLARE dpending79cd = f8 WITH public, noconstant(0.0)
 DECLARE ddcpchart14024cd = f8 WITH public, noconstant(0.0)
 DECLARE ddcpdone14024cd = f8 WITH public, noconstant(0.0)
 DECLARE ddcpnotdone14024cd = f8 WITH public, noconstant(0.0)
 DECLARE applicationid = i4 WITH constant(1000011)
 DECLARE taskid = i4 WITH constant(1000011)
 DECLARE requestid = i4 WITH constant(1000011)
 DECLARE happ = i4 WITH noconstant(0)
 DECLARE htask = i4 WITH noconstant(0)
 DECLARE hstep = i4 WITH noconstant(0)
 DECLARE hrblist = i4 WITH noconstant(0)
 DECLARE query_mode = i4 WITH constant(3)
 DECLARE iret = i2 WITH noconstant(0)
 DECLARE calleventserver(deventid=f8) = i2
 DECLARE retrieveresults(hhandle=i4) = f8
 SET stat = uar_get_meaning_by_codeset(79,"COMPLETE",1,dcomplete79cd)
 IF (dcomplete79cd IN (0.0, null))
  CALL echo("dComplete79Cd of codeset 79 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(79,"PENDING",1,dpending79cd)
 IF (dpending79cd IN (0.0, null))
  CALL echo("dPending79Cd of codeset 79 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(14024,"DCP_CHART",1,ddcpchart14024cd)
 IF (ddcpchart14024cd IN (0.0, null))
  CALL echo("dDCPChart14024Cd of codeset 14024 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(14024,"DCP_DONE",1,ddcpdone14024cd)
 IF (ddcpdone14024cd IN (0.0, null))
  CALL echo("dDCPDone14024Cd of codeset 14024 IS NULL")
  GO TO end_program
 ENDIF
 SET stat = uar_get_meaning_by_codeset(14024,"DCP_NOTDONE",1,ddcpnotdone14024cd)
 IF (ddcpnotdone14024cd IN (0.0, null))
  CALL echo("dDCPNotDone14024Cd of codeset 14024 IS NULL")
  GO TO end_program
 ENDIF
 SET leventqualcnt = 0
 SELECT DISTINCT INTO "nl:"
  ce.parent_event_id, ta.task_id
  FROM clinical_event ce,
   task_activity ta
  PLAN (ce
   WHERE ce.updt_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND ce.parent_event_id > 0.0
    AND ce.parent_event_id=ce.event_id)
   JOIN (ta
   WHERE ta.event_id=ce.parent_event_id
    AND ta.updt_dt_tm BETWEEN cnvtdatetime(begdate) AND cnvtdatetime(enddate)
    AND ta.task_id > 0.0
    AND ta.active_ind=1)
  DETAIL
   leventqualcnt = (leventqualcnt+ 1)
   IF (leventqualcnt > size(temp_event->eventqual,5))
    stat = alterlist(temp_event->eventqual,(leventqualcnt+ 10))
   ENDIF
   temp_event->leventqualcnt = leventqualcnt, temp_event->eventqual[leventqualcnt].parent_event_id =
   ce.parent_event_id, temp_event->eventqual[leventqualcnt].task_id = ta.task_id
  WITH nocounter
 ;end select
 SET stat = alterlist(temp_event->eventqual,leventqualcnt)
 SET neventcnt1 = 0
 IF (value(size(temp_event->eventqual,5)) > 0)
  FOR (leventloop = 1 TO value(size(temp_event->eventqual,5)))
   SET iret = calleventserver(temp_event->eventqual[leventloop].parent_event_id)
   IF (iret=0)
    CALL echo(build("iRet: ",iret))
    CALL echo(build("Server call failed for: ",temp_event->eventqual[leventloop].parent_event_id))
   ENDIF
  ENDFOR
  SET stat = alterlist(events->events,neventcnt1)
 ENDIF
 IF (value(size(events->events,5)) > 0)
  SELECT INTO "nl:"
   o_null = nullind(o.order_id)
   FROM (dummyt d1  WITH seq = value(size(events->events,5))),
    clinical_event ce,
    task_activity ta,
    orders o,
    discrete_task_assay dta,
    order_task oa,
    encounter e,
    person p
   PLAN (d1
    WHERE (events->events[d1.seq].event_id > 0.0)
     AND (events->events[d1.seq].parent_event_id > 0.0))
    JOIN (ce
    WHERE (ce.event_id=events->events[d1.seq].event_id))
    JOIN (ta
    WHERE (ta.event_id=events->events[d1.seq].parent_event_id)
     AND ta.active_ind=1)
    JOIN (dta
    WHERE dta.task_assay_cd=ce.task_assay_cd
     AND dta.active_ind=1)
    JOIN (oa
    WHERE oa.reference_task_id=ta.reference_task_id
     AND oa.active_ind=1)
    JOIN (e
    WHERE e.encntr_id=ta.encntr_id
     AND e.active_ind=1)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND p.active_ind=1)
    JOIN (o
    WHERE o.order_id=outerjoin(ta.order_id)
     AND o.order_id > outerjoin(0.0)
     AND o.active_ind=outerjoin(1))
   DETAIL
    IF (o_null=0)
     events->events[d1.seq].cs_order_id = o.order_id, events->events[d1.seq].catalog_cd = o
     .catalog_cd, events->events[d1.seq].order_id = o.order_id
    ELSE
     events->events[d1.seq].cs_order_id = 0.0, events->events[d1.seq].catalog_cd = 0.0, events->
     events[d1.seq].order_id = 0.0
    ENDIF
    events->events[d1.seq].mnemonic = dta.mnemonic, events->events[d1.seq].perform_dt_tm = ta
    .updt_dt_tm, events->events[d1.seq].event_end_dt_tm = ce.event_end_dt_tm,
    events->events[d1.seq].location_cd = ta.location_cd, events->events[d1.seq].reference_task_id =
    ta.reference_task_id, events->events[d1.seq].task_assay_cd = dta.task_assay_cd,
    events->events[d1.seq].encntr_id = e.encntr_id, events->events[d1.seq].person_id = p.person_id,
    events->events[d1.seq].person_name = p.name_full_formatted
    IF (ta.task_status_cd=dcomplete79cd
     AND ta.task_status_reason_cd IN (ddcpdone14024cd, ddcpchart14024cd))
     events->events[d1.seq].ce_complete_ind = 1, events->events[d1.seq].process_ind = 1
    ELSEIF (ta.task_status_cd=dcomplete79cd
     AND ta.task_status_reason_cd=ddcpnotdone14024cd)
     events->events[d1.seq].ce_attempted_ind = 1, events->events[d1.seq].process_ind = 1
    ELSEIF (ta.task_status_cd=dpending79cd)
     events->events[d1.seq].ce_cancel_ind = 1, events->events[d1.seq].process_ind = 1
    ENDIF
   WITH nocounter
  ;end select
  SET ntopflag = 0
  WHILE (ntopflag=0)
   SET ntopflag = 1
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(events->events,5))),
     orders o
    PLAN (d1
     WHERE (events->events[d1.seq].process_ind=1)
      AND (events->events[d1.seq].cs_order_id > 0.0))
     JOIN (o
     WHERE (o.order_id=events->events[d1.seq].cs_order_id))
    DETAIL
     IF (o.cs_order_id != 0)
      ntopflag = 0, events->events[d1.seq].cs_order_id = o.cs_order_id
     ELSE
      events->events[d1.seq].catalog_cd = o.catalog_cd
     ENDIF
    WITH nocounter
   ;end select
  ENDWHILE
  SELECT INTO "nl:"
   ce.charge_event_id
   FROM charge_event ce,
    (dummyt d1  WITH seq = value(size(events->events,5)))
   PLAN (d1
    WHERE (events->events[d1.seq].process_ind=1))
    JOIN (ce
    WHERE (((ce.ext_m_event_id=events->events[d1.seq].cs_order_id)
     AND (ce.ext_m_reference_id=events->events[d1.seq].catalog_cd)
     AND (ce.ext_p_event_id=events->events[d1.seq].task_id)
     AND (ce.ext_p_reference_id=events->events[d1.seq].reference_task_id)
     AND (ce.ext_i_event_id=events->events[d1.seq].event_id)
     AND (ce.ext_i_reference_id=events->events[d1.seq].task_assay_cd)) OR ((ce.ext_m_event_id=events
    ->events[d1.seq].task_id)
     AND (ce.ext_m_reference_id=events->events[d1.seq].reference_task_id)
     AND (ce.ext_p_event_id=events->events[d1.seq].task_id)
     AND (ce.ext_p_reference_id=events->events[d1.seq].reference_task_id)
     AND (ce.ext_i_event_id=events->events[d1.seq].event_id)
     AND (ce.ext_i_reference_id=events->events[d1.seq].task_assay_cd))) )
   DETAIL
    events->events[d1.seq].charge_event_id = ce.charge_event_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event_act cea,
    (dummyt d1  WITH seq = value(size(events->events,5)))
   PLAN (d1
    WHERE (events->events[d1.seq].ce_complete_ind=1)
     AND (events->events[d1.seq].process_ind=1)
     AND (events->events[d1.seq].charge_event_id != 0))
    JOIN (cea
    WHERE (cea.charge_event_id=events->events[d1.seq].charge_event_id)
     AND cea.cea_type_cd IN (dcomplete13029cd, dverified13029cd)
     AND cea.active_ind=1)
   DETAIL
    events->events[d1.seq].process_ind = 0, events->events[d1.seq].ce_complete_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event_act cea,
    (dummyt d1  WITH seq = value(size(events->events,5)))
   PLAN (d1
    WHERE (events->events[d1.seq].ce_attempted_ind=1)
     AND (events->events[d1.seq].process_ind=1)
     AND (events->events[d1.seq].charge_event_id != 0))
    JOIN (cea
    WHERE (cea.charge_event_id=events->events[d1.seq].charge_event_id)
     AND cea.cea_type_cd=dattempted13029cd
     AND cea.active_ind=1)
   DETAIL
    events->events[d1.seq].process_ind = 0, events->events[d1.seq].ce_attempted_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM charge_event_act cea,
    (dummyt d1  WITH seq = value(size(events->events,5)))
   PLAN (d1
    WHERE (events->events[d1.seq].ce_cancel_ind=1)
     AND (events->events[d1.seq].process_ind=1)
     AND (events->events[d1.seq].charge_event_id != 0))
    JOIN (cea
    WHERE (cea.charge_event_id=events->events[d1.seq].charge_event_id)
     AND cea.cea_type_cd=dcancelled13029cd
     AND cea.active_ind=1)
   DETAIL
    events->events[d1.seq].process_ind = 0, events->events[d1.seq].ce_cancel_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE calleventserver(deventid)
   SET iret = uar_crmbeginapp(applicationid,happ)
   IF (iret != 0)
    CALL echo("uar_crm_begin_app failed in post_to_clinical_event")
    GO TO end_program
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    CALL echo("uar_crm_begin_task failed in post_to_clinical_event")
    GO TO end_program
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
   IF (iret != 0)
    CALL echo("uar_crm_begin_Request failed in post_to_clinical_event")
    GO TO end_program
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   IF (hreq)
    SET srvstat = uar_srvsetulong(hreq,"query_mode",query_mode)
    SET srvstat = uar_srvsetdouble(hreq,"event_id",deventid)
    SET srvstat = uar_srvsetlong(hreq,"subtable_bit_map",0)
    SET srvstat = uar_srvsetshort(hreq,"subtable_bit_map_ind",1)
    SET srvstat = uar_srvsetshort(hreq,"decode_flag",false)
    SET srvstat = uar_srvsetshort(hreq,"valid_from_dt_tm_ind",1)
   ENDIF
   SET iret = uar_crmperform(hstep)
   SET hrep = uar_crmgetreply(hstep)
   IF (hrep=0)
    RETURN(false)
   ENDIF
   SET hrblist = uar_srvgetitem(hrep,"rb_list",0)
   IF (hrblist=0)
    RETURN(false)
   ENDIF
   CALL retrieveresults(hrblist)
   IF (hstep)
    CALL uar_crmendreq(hstep)
   ENDIF
   IF (htask)
    CALL uar_crmendtask(htask)
   ENDIF
   IF (happ)
    CALL uar_crmendapp(happ)
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE retrieveresults(hlist)
   DECLARE nidx = i4 WITH noconstant(0), private
   DECLARE ncnt = i4 WITH noconstant(0), private
   DECLARE hitem = i4 WITH noconstant(0), private
   DECLARE dvalue = f8 WITH noconstant(0.0), private
   DECLARE hitem2 = i4 WITH noconstant(0), private
   DECLARE nnomencnt = i4 WITH noconstant(0), private
   IF (hlist=0)
    RETURN
   ENDIF
   SET ncnt = uar_srvgetitemcount(hlist,"child_event_list")
   FOR (nidx = 0 TO (ncnt - 1))
    SET hitem = uar_srvgetitem(hlist,"child_event_list",nidx)
    IF (hitem > 0)
     SET dvalue = uar_srvgetdouble(hitem,"task_assay_cd")
     IF (dvalue > 0.0)
      SET neventcnt1 = (neventcnt1+ 1)
      IF (neventcnt1 > size(events->events,5))
       SET stat = alterlist(events->events,(neventcnt1+ 10))
      ENDIF
      SET events->events[neventcnt1].event_id = uar_srvgetdouble(hitem,"event_id")
      SET events->events[neventcnt1].parent_event_id = temp_event->eventqual[leventloop].
      parent_event_id
      SET events->events[neventcnt1].task_id = temp_event->eventqual[leventloop].task_id
      SET nnomencnt = uar_srvgetitemcount(hitem,"coded_result_list")
      IF (nnomencnt > 0)
       FOR (lloop1 = 1 TO nnomencnt)
        SET hitem2 = uar_srvgetitem(hitem,"coded_result_list",(lloop1 - 1))
        IF (hitem2 > 0)
         IF (lloop1 > size(events->events[neventcnt1].nomenclature,5))
          SET stat = alterlist(events->events[neventcnt1].nomenclature,(lloop1+ 10))
         ENDIF
         SET events->events[neventcnt1].nomenclature[lloop1].nomenclature_id = uar_srvgetdouble(
          hitem2,"nomenclature_id")
        ENDIF
       ENDFOR
       SET stat = alterlist(events->events[neventcnt1].nomenclature,nnomencnt)
      ELSE
       SET events->events[neventcnt1].result_val = uar_srvgetstringptr(hitem,"result_val")
      ENDIF
     ENDIF
     CALL retrieveresults(hitem)
    ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
