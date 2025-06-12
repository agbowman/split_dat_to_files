CREATE PROGRAM cpm_srv_exp_get_event_data:dba
 SET stat = alterlist(reply->orders,size(request->orders,5))
 SELECT INTO "nl:"
  epr.encntr_prsnl_r_cd, epr.prsnl_person_id
  FROM encntr_prsnl_reltn epr
  WHERE (epr.encntr_id=request->encntr_id)
   AND (epr.encntr_prsnl_r_cd=addtlphys->admitdoc)
   AND epr.active_ind=1
  DETAIL
   reply->admitdoc = epr.prsnl_person_id
  WITH nocounter
 ;end select
 IF ((g_checkeventdata->additionalcopies=1))
  DECLARE cnt = i2
  SELECT INTO "nl:"
   epr.encntr_prsnl_r_cd, epr.prsnl_person_id
   FROM encntr_prsnl_reltn epr,
    (dummyt d  WITH seq = value(size(addtlphys->physlist,5)))
   PLAN (d)
    JOIN (epr
    WHERE (epr.encntr_id=request->encntr_id)
     AND (epr.encntr_prsnl_r_cd=addtlphys->physlist[d.seq].physcd)
     AND epr.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(reply->encntrprsnl,(cnt+ 10))
    ENDIF
    reply->encntrprsnl[cnt].prsnlreltn = epr.encntr_prsnl_r_cd, reply->encntrprsnl[cnt].prsnlid = epr
    .prsnl_person_id
   FOOT REPORT
    stat = alterlist(reply->encntrprsnl,cnt)
   WITH nocounter
  ;end select
  IF ((addtlphys->consultdoc > 0))
   SELECT INTO "nl:"
    od.oe_field_meaning_id, od.oe_field_meaning, od.oe_field_value
    FROM order_detail od,
     (dummyt d  WITH seq = value(size(request->orders,5)))
    PLAN (d
     WHERE (request->orders[d.seq].order_id > 0))
     JOIN (od
     WHERE (od.order_id=request->orders[d.seq].order_id)
      AND od.oe_field_meaning_id=2
      AND od.oe_field_meaning="CONSULTDOC")
    DETAIL
     cnt = (cnt+ 1), stat = alterlist(reply->encntrprsnl,cnt), reply->encntrprsnl[cnt].prsnlreltn =
     addtlphys->consultdoc,
     reply->encntrprsnl[cnt].prsnlid = od.oe_field_value
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((g_checkeventdata->orderprovider=1))
  SELECT INTO "nl:"
   oa.order_provider_id
   FROM order_action oa,
    (dummyt d  WITH seq = value(size(request->orders,5)))
   PLAN (d)
    JOIN (oa
    WHERE (oa.order_id=request->orders[d.seq].order_id)
     AND oa.action_sequence=1)
   DETAIL
    reply->orders[d.seq].ordprovid = oa.order_provider_id
    IF ((g_checkeventdata->additionalcopies=1))
     cnt = (cnt+ 1), stat = alterlist(reply->encntrprsnl,cnt), reply->encntrprsnl[cnt].prsnlreltn =
     addtlphys->orderdoc,
     reply->encntrprsnl[cnt].prsnlid = oa.order_provider_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((g_checkeventdata->encntr=1))
  SELECT INTO "nl:"
   e.organization_id, e.loc_facility_cd, e.loc_building_cd,
   e.loc_nurse_unit_cd, e.loc_room_cd, e.loc_bed_cd,
   e.loc_temp_cd, e.disch_dt_tm
   FROM encounter e
   WHERE (e.encntr_id=request->encntr_id)
   DETAIL
    reply->orgid = e.organization_id, reply->curfacility = e.loc_facility_cd, reply->curbuilding = e
    .loc_building_cd,
    reply->curnurseunit = e.loc_nurse_unit_cd, reply->curroom = e.loc_room_cd, reply->curbed = e
    .loc_bed_cd,
    reply->curtemploc = e.loc_temp_cd
    IF (e.disch_dt_tm=null)
     reply->dischargeind = 0
    ELSE
     reply->dischargeind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((g_checkeventdata->encntrlochist=1))
  SELECT INTO "nl:"
   o.orig_order_dt_tm, elh.beg_effective_dt_tm, elh.end_effective_dt_tm,
   elh.loc_facility_cd, elh.loc_building_cd, elh.loc_nurse_unit_cd,
   elh.loc_room_cd, elh.loc_bed_cd
   FROM orders o,
    encntr_loc_hist elh,
    (dummyt d  WITH seq = value(size(request->orders,5)))
   PLAN (d)
    JOIN (o
    WHERE (o.order_id=request->orders[d.seq].order_id))
    JOIN (elh
    WHERE (elh.encntr_id=request->encntr_id)
     AND elh.active_ind=1
     AND elh.beg_effective_dt_tm <= o.orig_order_dt_tm
     AND elh.end_effective_dt_tm >= o.orig_order_dt_tm)
   DETAIL
    reply->orders[d.seq].patfacility = elh.loc_facility_cd, reply->orders[d.seq].patbuilding = elh
    .loc_building_cd, reply->orders[d.seq].patnurseunit = elh.loc_nurse_unit_cd,
    reply->orders[d.seq].patroom = elh.loc_room_cd, reply->orders[d.seq].patbed = elh.loc_bed_cd
   WITH nocounter
  ;end select
 ENDIF
 IF ((g_checkeventdata->orderlocation=1))
  SELECT INTO "nl:"
   oa.order_locn_cd
   FROM order_action oa,
    (dummyt d  WITH seq = value(size(request->orders,5)))
   PLAN (d)
    JOIN (oa
    WHERE (oa.order_id=request->orders[d.seq].order_id)
     AND oa.order_locn_cd > 0.0)
   DETAIL
    reply->orders[d.seq].ordlocation = oa.order_locn_cd
   WITH nocounter
  ;end select
 ENDIF
 RECORD manual(
   1 expedite[*]
     2 manual_id = f8
   1 event[*]
     2 em_event_id = f8
 )
 DECLARE firstorderid = f8
 IF (size(request->orders,5) > 0)
  SET firstorderid = request->orders[1].order_id
 ELSE
  SET firstorderid = 0
 ENDIF
 DECLARE manualcnt = i2
 SET manualcnt = 0
 SELECT INTO "nl:"
  em.chart_content_flag, em.chart_format_id, em.scope_flag,
  em.output_dest_cd, em.output_device_cd, em.provider_id,
  em.provider_role_cd, em.event_ind
  FROM expedite_manual em
  WHERE (((em.accession=request->accession)
   AND em.scope_flag=4) OR ((((em.encntr_id=request->encntr_id)
   AND em.scope_flag=2) OR ((em.person_id=request->person_id)
   AND em.scope_flag=1)) ))
  DETAIL
   manualcnt = (manualcnt+ 1), stat = alterlist(reply->addchartreq.qual,manualcnt)
   IF (em.chart_content_flag=0)
    reply->addchartreq.qual[manualcnt].begin_dt_tm = cnvtdatetime("01-JAN-1800")
   ELSE
    reply->addchartreq.qual[manualcnt].begin_dt_tm = request->event_dt_tm
   ENDIF
   reply->addchartreq.qual[manualcnt].end_dt_tm = request->event_dt_tm, reply->addchartreq.qual[
   manualcnt].person_id = request->person_id, reply->addchartreq.qual[manualcnt].encntr_id = request
   ->encntr_id,
   reply->addchartreq.qual[manualcnt].accession_nbr = request->accession, reply->addchartreq.qual[
   manualcnt].request_type = 2, reply->addchartreq.qual[manualcnt].order_id = firstorderid,
   reply->addchartreq.qual[manualcnt].date_range_ind = 1, reply->addchartreq.qual[manualcnt].
   chart_pending_flag = 2, reply->addchartreq.qual[manualcnt].rrd_deliver_dt_tm = cnvtdatetime(
    curdate,curtime),
   reply->addchartreq.qual[manualcnt].chart_format_id = em.chart_format_id, reply->addchartreq.qual[
   manualcnt].scope_flag = em.scope_flag, reply->addchartreq.qual[manualcnt].output_dest_cd = em
   .output_dest_cd,
   reply->addchartreq.qual[manualcnt].output_device_cd = em.output_device_cd
   IF (em.provider_id > 0)
    reply->addchartreq.qual[manualcnt].prsnl_person_id = em.provider_id, reply->addchartreq.qual[
    manualcnt].prsnl_person_r_cd = em.provider_role_cd
   ELSEIF ((reply->admitdoc > 0))
    reply->addchartreq.qual[manualcnt].prsnl_person_id = reply->admitdoc, reply->addchartreq.qual[
    manualcnt].prsnl_person_r_cd = addtlphys->admitdoc
   ENDIF
   reply->addchartreq.qual[manualcnt].event_ind = em.event_ind, stat = alterlist(manual->expedite,
    manualcnt), manual->expedite[manualcnt].manual_id = em.expedite_manual_id
  WITH nocounter
 ;end select
 IF (manualcnt > 0)
  SET reply->manualind = 1
  DECLARE eventcnt = i2
  DECLARE toteventcnt = i2
  SELECT INTO "nl:"
   eme.event_id, eme.result_status_cd, eme.em_event_id
   FROM (dummyt d  WITH seq = value(manualcnt)),
    expedite_manual_event eme
   PLAN (d
    WHERE (reply->addchartreq.qual[d.seq].event_ind=1))
    JOIN (eme
    WHERE (eme.expedite_manual_id=manual->expedite[d.seq].manual_id))
   HEAD REPORT
    toteventcnt = 0
   HEAD d.seq
    eventcnt = 0
   DETAIL
    eventcnt = (eventcnt+ 1), stat = alterlist(reply->addchartreq.qual[d.seq].event_id_list,eventcnt),
    reply->addchartreq.qual[d.seq].event_id_list[eventcnt].event_id = eme.event_id,
    reply->addchartreq.qual[d.seq].event_id_list[eventcnt].result_status_cd = eme.result_status_cd,
    toteventcnt = (toteventcnt+ 1), stat = alterlist(manual->event,toteventcnt),
    manual->event[toteventcnt].em_event_id = eme.em_event_id
   WITH nocounter
  ;end select
  IF (toteventcnt > 0)
   DELETE  FROM expedite_manual_event eme,
     (dummyt d  WITH seq = value(toteventcnt))
    SET eme.seq = 1
    PLAN (d)
     JOIN (eme
     WHERE (eme.em_event_id=manual->event[d.seq].em_event_id))
   ;end delete
  ENDIF
  DELETE  FROM expedite_manual em,
    (dummyt d  WITH seq = value(manualcnt))
   SET em.seq = 1
   PLAN (d)
    JOIN (em
    WHERE (em.expedite_manual_id=manual->expedite[d.seq].manual_id))
  ;end delete
 ENDIF
END GO
