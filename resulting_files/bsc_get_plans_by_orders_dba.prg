CREATE PROGRAM bsc_get_plans_by_orders:dba
 SET modify = predeclare
 RECORD reply(
   1 planlist[*]
     2 pw_group_nbr = f8
     2 pathway_catalog_id = f8
     2 description = vc
     2 type_mean = vc
     2 pathway_type_cd = f8
     2 plan_ref_text_ind = i2
     2 phaselist[*]
       3 pathway_id = f8
       3 pathway_catalog_id = f8
       3 description = vc
       3 type_mean = vc
       3 start_dt_tm = dq8
       3 start_tz = i4
       3 subphase_sequence = i4
       3 offset_quantity = f8
       3 offset_unit_cd = f8
       3 phase_ref_text_ind = i2
       3 orderlist[*]
         4 order_id = f8
         4 sequence = i4
         4 pathway_comp_id = f8
       3 phasereltnlist[*]
         4 pathway_s_id = f8
         4 pathway_t_id = f8
         4 type_mean = vc
   1 evidencelist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 evidence_type_mean = c12
     2 pw_evidence_reltn_id = f8
     2 evidence_locator = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 planlist[*]
     2 pw_group_nbr = f8
     2 description = vc
     2 pathway_type_cd = f8
   1 phaselist[*]
     2 pw_group_nbr = f8
     2 pw_cat_group_id = f8
     2 pathway_id = f8
     2 pathway_catalog_id = f8
     2 description = vc
     2 type_mean = vc
     2 start_dt_tm = dq8
     2 start_tz = i4
     2 subphase_sequence = i4
     2 offset_quantity = f8
     2 offset_unit_cd = f8
     2 phase_ref_text_ind = i2
     2 phasereltnlist[*]
       3 pathway_s_id = f8
       3 pathway_t_id = f8
       3 type_mean = c12
     2 orderlist[*]
       3 order_id = f8
       3 sequence = i4
       3 pathway_comp_id = f8
 )
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE debug_ind = i2 WITH protect, constant(validate(request->debug_ind))
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE totaltime = f8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE last_mod = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE l_batch_size = i4 WITH protect, noconstant(20)
 DECLARE l_size = i4 WITH protect, noconstant(0)
 DECLARE l_loop_count = i4 WITH protect, noconstant(0)
 DECLARE l_new_size = i4 WITH protect, noconstant(0)
 DECLARE l_start = i4 WITH protect, noconstant(0)
 DECLARE getplanids(null) = null
 DECLARE getphasesandreltns(null) = null
 DECLARE getorders(null) = null
 DECLARE getevidenceandrefinfo(null) = null
 DECLARE fillreply(null) = null
 IF (debug_ind=1)
  CALL echorecord(request)
 ENDIF
 IF (size(request->orderlist,5) <= 0)
  CALL echo("*** No orders in request. Exiting.")
  GO TO exit_script
 ENDIF
 CALL getplanids(null)
 IF (size(temp->planlist,5) <= 0)
  CALL echo("*** No plans found. Exiting.")
  GO TO exit_script
 ENDIF
 CALL getphasesandreltns(null)
 IF (size(temp->phaselist,5) <= 0)
  CALL echo("*** No phases found. Exiting.")
  GO TO exit_script
 ENDIF
 CALL getorders(null)
 CALL getevidenceandrefinfo(null)
 CALL fillreply(null)
#exit_script
 IF (size(reply->planlist,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET error_cd = error(error_msg,1)
 IF (error_cd != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",error_msg))
  CALL echo("*********************************")
  SET reply->status_data.status = "F"
 ENDIF
 IF (debug_ind=1)
  CALL echo("*******************************************************")
  CALL echo(build("Total Time = ",datetimediff(cnvtdatetime(curdate,curtime3),totaltime,5)))
  CALL echo("*******************************************************")
  CALL echo("*******************************************************")
  CALL echorecord(temp)
  CALL echo("*******************************************************")
  CALL echo("*******************************************************")
  CALL echorecord(reply)
  CALL echo("*******************************************************")
 ENDIF
 FREE RECORD temp
 SUBROUTINE getplanids(null)
   DECLARE plancnt = i4 WITH protect, noconstant(0)
   DECLARE oidx = i4 WITH protect, noconstant(0)
   DECLARE pidx = i4 WITH protect, noconstant(0)
   SELECT DISTINCT INTO "nl:"
    pw.pw_group_nbr
    FROM act_pw_comp apc,
     pathway pw
    PLAN (apc
     WHERE expand(oidx,1,size(request->orderlist,5),apc.parent_entity_id,request->orderlist[oidx].
      order_id)
      AND apc.parent_entity_name="ORDERS"
      AND apc.active_ind=1)
     JOIN (pw
     WHERE pw.pathway_id=apc.pathway_id)
    ORDER BY pw.pw_group_nbr
    HEAD pw.pw_group_nbr
     ballowplan = 1
     IF (pw.pathway_type_cd != 0.0)
      IF (size(request->plantypeexcludelist,5) > 0)
       IF (0 < locateval(pidx,1,size(request->plantypeexcludelist,5),pw.pathway_type_cd,request->
        plantypeexcludelist[pidx].pathway_type_cd))
        ballowplan = 0
       ENDIF
      ELSEIF (size(request->plantypeincludelist,5) > 0)
       IF (0 >= locateval(pidx,1,size(request->plantypeincludelist,5),pw.pathway_type_cd,request->
        plantypeincludelist[pidx].pathway_type_cd))
        ballowplan = 0
       ENDIF
      ENDIF
     ENDIF
     IF (ballowplan=1)
      plancnt = (plancnt+ 1), stat = alterlist(temp->planlist,plancnt), temp->planlist[plancnt].
      pw_group_nbr = pw.pw_group_nbr,
      temp->planlist[plancnt].description = pw.pw_group_desc, temp->planlist[plancnt].pathway_type_cd
       = pw.pathway_type_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getphasesandreltns(null)
   DECLARE phasecnt = i4 WITH protect, noconstant(0)
   DECLARE pidx = i4 WITH protect, noconstant(0)
   DECLARE eidx = i4 WITH protect, noconstant(0)
   DECLARE planned_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16769,"PLANNED"))
   SELECT INTO "nl:"
    FROM pathway pw,
     pathway_reltn pwr,
     act_pw_comp apc,
     act_pw_comp_r apcr
    PLAN (pw
     WHERE expand(pidx,1,size(temp->planlist,5),pw.pw_group_nbr,temp->planlist[pidx].pw_group_nbr)
      AND pw.type_mean IN ("TAPERPLAN", "PATHWAY", "CAREPLAN", "SUBPHASE", "PHASE")
      AND pw.pw_status_cd != planned_cd)
     JOIN (pwr
     WHERE pwr.pathway_t_id=outerjoin(pw.pathway_id))
     JOIN (apc
     WHERE apc.parent_entity_id=outerjoin(pw.pathway_id))
     JOIN (apcr
     WHERE apcr.act_pw_comp_t_id=outerjoin(apc.act_pw_comp_id))
    ORDER BY pw.pw_group_nbr, pw.pathway_id, apc.act_pw_comp_id,
     apcr.act_pw_comp_t_id
    HEAD REPORT
     phasecnt = 0
    HEAD pw.pathway_id
     phasecnt = (phasecnt+ 1), stat = alterlist(temp->phaselist,phasecnt), temp->phaselist[phasecnt].
     pw_group_nbr = pw.pw_group_nbr,
     temp->phaselist[phasecnt].pw_cat_group_id = pw.pw_cat_group_id, temp->phaselist[phasecnt].
     pathway_id = pw.pathway_id, temp->phaselist[phasecnt].pathway_catalog_id = pw.pathway_catalog_id,
     temp->phaselist[phasecnt].description = pw.description, temp->phaselist[phasecnt].type_mean = pw
     .type_mean, temp->phaselist[phasecnt].start_dt_tm = pw.start_dt_tm,
     temp->phaselist[phasecnt].start_tz = pw.start_tz, temp->phaselist[phasecnt].subphase_sequence =
     0, phasereltncnt = 0,
     parentpathwayid = 0
    HEAD pwr.pathway_t_id
     IF (pwr.pathway_t_id > 0)
      phasereltncnt = (phasereltncnt+ 1), stat = alterlist(temp->phaselist[phasecnt].phasereltnlist,
       phasereltncnt), temp->phaselist[phasecnt].phasereltnlist[phasereltncnt].pathway_s_id = pwr
      .pathway_s_id,
      temp->phaselist[phasecnt].phasereltnlist[phasereltncnt].pathway_t_id = pwr.pathway_t_id, temp->
      phaselist[phasecnt].phasereltnlist[phasereltncnt].type_mean = pwr.type_mean
      IF (pwr.type_mean="SUBPHASE")
       parentpathwayid = pwr.pathway_s_id
      ENDIF
     ENDIF
    HEAD apc.act_pw_comp_id
     IF (apc.act_pw_comp_id > 0)
      IF (parentpathwayid > 0
       AND parentpathwayid=apc.pathway_id)
       temp->phaselist[phasecnt].subphase_sequence = apc.sequence, temp->phaselist[phasecnt].
       offset_quantity = apc.offset_quantity, temp->phaselist[phasecnt].offset_unit_cd = apc
       .offset_unit_cd
      ENDIF
     ENDIF
    HEAD apcr.act_pw_comp_t_id
     IF (apcr.act_pw_comp_t_id > 0)
      temp->phaselist[phasecnt].offset_quantity = apcr.offset_quantity, temp->phaselist[phasecnt].
      offset_unit_cd = apcr.offset_unit_cd
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getorders(null)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   DECLARE phasecnt = i4 WITH protect, noconstant(0)
   DECLARE pidx = i4 WITH protect, noconstant(0)
   DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
   SELECT INTO "nl:"
    FROM act_pw_comp apc,
     orders o
    PLAN (apc
     WHERE expand(pidx,1,size(temp->phaselist,5),apc.pathway_id,temp->phaselist[pidx].pathway_id)
      AND apc.parent_entity_name="ORDERS")
     JOIN (o
     WHERE o.order_id=apc.parent_entity_id
      AND o.catalog_type_cd=pharmacy_cd
      AND o.orig_ord_as_flag IN (0, 5))
    ORDER BY apc.pathway_id, apc.parent_entity_id
    HEAD apc.pathway_id
     phasecnt = locateval(pidx,1,size(temp->phaselist,5),apc.pathway_id,temp->phaselist[pidx].
      pathway_id), ordercnt = 0
    HEAD apc.parent_entity_id
     IF (apc.parent_entity_id > 0)
      ordercnt = (ordercnt+ 1), stat = alterlist(temp->phaselist[phasecnt].orderlist,ordercnt), temp
      ->phaselist[phasecnt].orderlist[ordercnt].order_id = apc.parent_entity_id,
      temp->phaselist[phasecnt].orderlist[ordercnt].sequence = apc.sequence, temp->phaselist[phasecnt
      ].orderlist[ordercnt].pathway_comp_id = apc.pathway_comp_id
     ENDIF
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getevidenceandrefinfo(null)
   DECLARE evidencecnt = i4 WITH protect, noconstant(0)
   DECLARE bfoundplanevidence = i2 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    pw_group_nbr = temp->phaselist[d1.seq].pw_group_nbr, pathway_id = temp->phaselist[d1.seq].
    pathway_id, per.pathway_catalog_id,
    per.type_mean, pw_group_cat_id = temp->phaselist[d1.seq].pw_cat_group_id, pw_cat_id = temp->
    phaselist[d1.seq].pathway_catalog_id
    FROM (dummyt d1  WITH seq = value(size(temp->phaselist,5))),
     pw_evidence_reltn per
    PLAN (d1)
     JOIN (per
     WHERE per.pathway_catalog_id IN (temp->phaselist[d1.seq].pathway_catalog_id, temp->phaselist[d1
     .seq].pw_cat_group_id))
    ORDER BY per.pathway_catalog_id, per.pw_evidence_reltn_id
    HEAD REPORT
     evidencecnt = 0
    HEAD per.pathway_catalog_id
     bfoundplanevidence = 0, bfoundplanreference = 0
    HEAD per.pw_evidence_reltn_id
     IF (((bfoundplanevidence=0
      AND per.pathway_catalog_id=pw_group_cat_id
      AND ((per.type_mean="ZYNX") OR (per.type_mean="URL")) ) OR (((bfoundplanreference=0
      AND per.pathway_catalog_id=pw_group_cat_id
      AND per.type_mean="REFTEXT") OR (per.pathway_catalog_id=pw_cat_id)) )) )
      evidencecnt = (evidencecnt+ 1)
      IF (evidencecnt > size(reply->evidencelist,5))
       stat = alterlist(reply->evidencelist,(evidencecnt+ 5))
      ENDIF
      reply->evidencelist[evidencecnt].pathway_comp_id = per.pathway_comp_id, reply->evidencelist[
      evidencecnt].evidence_type_mean = per.type_mean, reply->evidencelist[evidencecnt].
      pw_evidence_reltn_id = per.pw_evidence_reltn_id,
      reply->evidencelist[evidencecnt].evidence_locator = per.evidence_locator, reply->evidencelist[
      evidencecnt].pathway_catalog_id = per.pathway_catalog_id
      IF (bfoundplanevidence=0
       AND per.pathway_catalog_id=pw_group_cat_id
       AND ((per.type_mean="ZYNX") OR (per.type_mean="URL")) )
       bfoundplanevidence = 1
      ENDIF
      IF (bfoundplanreference=0
       AND per.pathway_catalog_id=pw_group_cat_id
       AND per.type_mean="REFTEXT")
       bfoundplanreference = 1
      ENDIF
     ENDIF
    FOOT  pathway_id
     stat = alterlist(reply->evidencelist,evidencecnt)
    WITH nocounter
   ;end select
   SET l_size = size(temp->phaselist,5)
   SET l_loop_count = ceil((cnvtreal(l_size)/ l_batch_size))
   SET l_new_size = (l_loop_count * l_batch_size)
   SET stat = alterlist(temp->phaselist,l_new_size)
   FOR (idx = (l_size+ 1) TO l_new_size)
     SET temp->phaselist[idx].pathway_catalog_id = temp->phaselist[l_size].pathway_catalog_id
   ENDFOR
   SET l_start = 1
   SELECT INTO "nl:"
    rtr.parent_entity_name, rtr.parent_entity_id
    FROM (dummyt d1  WITH seq = value(l_loop_count)),
     ref_text_reltn rtr
    PLAN (d1
     WHERE initarray(l_start,evaluate(d1.seq,1,1,(l_start+ l_batch_size))))
     JOIN (rtr
     WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
      AND expand(idx,l_start,(l_start+ (l_batch_size - 1)),rtr.parent_entity_id,temp->phaselist[idx].
      pathway_catalog_id)
      AND rtr.active_ind=1)
    ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
    HEAD rtr.parent_entity_id
     IF (rtr.parent_entity_id > 0.0)
      idx = locateval(idx,1,l_size,rtr.parent_entity_id,temp->phaselist[idx].pathway_catalog_id),
      CALL echo(temp->phaselist[idx].pathway_catalog_id)
      WHILE (idx > 0)
        temp->phaselist[idx].phase_ref_text_ind = 1,
        CALL echo(temp->phaselist[idx].pathway_catalog_id), idx2 = (idx+ 1),
        idx = locateval(idx,idx2,l_size,rtr.parent_entity_id,temp->phaselist[idx].pathway_catalog_id)
      ENDWHILE
     ENDIF
    WITH nocounter
   ;end select
   IF (l_size > 0
    AND l_size < l_new_size)
    SET stat = alterlist(temp->phaselist,l_size)
   ENDIF
 END ;Subroutine
 SUBROUTINE fillreply(null)
   DECLARE plancnt = i4 WITH protect, noconstant(0)
   DECLARE phasecnt = i4 WITH protect, noconstant(0)
   DECLARE phasereltncnt = i4 WITH protect, noconstant(0)
   DECLARE ordercnt = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    pw_group_nbr = temp->planlist[d1.seq].pw_group_nbr, pathway_id = temp->phaselist[d2.seq].
    pathway_id
    FROM (dummyt d1  WITH seq = value(size(temp->planlist,5))),
     (dummyt d2  WITH seq = value(size(temp->phaselist,5)))
    PLAN (d1)
     JOIN (d2
     WHERE (temp->phaselist[d2.seq].pw_group_nbr=temp->planlist[d1.seq].pw_group_nbr))
    ORDER BY pw_group_nbr, pathway_id
    HEAD REPORT
     plancnt = 0
    HEAD pw_group_nbr
     plancnt = (plancnt+ 1)
     IF (plancnt > size(reply->planlist,5))
      stat = alterlist(reply->planlist,plancnt)
     ENDIF
     reply->planlist[plancnt].pw_group_nbr = temp->planlist[d1.seq].pw_group_nbr, reply->planlist[
     plancnt].description = temp->planlist[d1.seq].description, reply->planlist[plancnt].
     pathway_type_cd = temp->planlist[d1.seq].pathway_type_cd,
     reply->planlist[plancnt].pathway_catalog_id = temp->phaselist[d2.seq].pw_cat_group_id
     IF ((temp->phaselist[d2.seq].type_mean="PHASE"))
      reply->planlist[plancnt].type_mean = "PATHWAY"
     ELSEIF ((temp->phaselist[d2.seq].type_mean="TAPERPLAN"))
      reply->planlist[plancnt].type_mean = "TAPERPLAN"
     ELSE
      reply->planlist[plancnt].type_mean = "CAREPLAN"
     ENDIF
     phasecnt = 0
    HEAD pathway_id
     phasecnt = (phasecnt+ 1)
     IF (phasecnt > size(reply->planlist[plancnt].phaselist,5))
      stat = alterlist(reply->planlist[plancnt].phaselist,phasecnt)
     ENDIF
     reply->planlist[plancnt].phaselist[phasecnt].pathway_id = temp->phaselist[d2.seq].pathway_id,
     reply->planlist[plancnt].phaselist[phasecnt].pathway_catalog_id = temp->phaselist[d2.seq].
     pathway_catalog_id, reply->planlist[plancnt].phaselist[phasecnt].description = temp->phaselist[
     d2.seq].description,
     reply->planlist[plancnt].phaselist[phasecnt].type_mean = temp->phaselist[d2.seq].type_mean,
     reply->planlist[plancnt].phaselist[phasecnt].start_dt_tm = temp->phaselist[d2.seq].start_dt_tm,
     reply->planlist[plancnt].phaselist[phasecnt].start_tz = temp->phaselist[d2.seq].start_tz,
     reply->planlist[plancnt].phaselist[phasecnt].subphase_sequence = temp->phaselist[d2.seq].
     subphase_sequence, reply->planlist[plancnt].phaselist[phasecnt].offset_quantity = temp->
     phaselist[d2.seq].offset_quantity, reply->planlist[plancnt].phaselist[phasecnt].offset_unit_cd
      = temp->phaselist[d2.seq].offset_unit_cd,
     reply->planlist[plancnt].phaselist[phasecnt].phase_ref_text_ind = temp->phaselist[d2.seq].
     phase_ref_text_ind, ordercnt = size(temp->phaselist[d2.seq].orderlist,5), stat = alterlist(reply
      ->planlist[plancnt].phaselist[phasecnt].orderlist,ordercnt)
     FOR (idx = 1 TO ordercnt)
       reply->planlist[plancnt].phaselist[phasecnt].orderlist[idx].order_id = temp->phaselist[d2.seq]
       .orderlist[idx].order_id, reply->planlist[plancnt].phaselist[phasecnt].orderlist[idx].sequence
        = temp->phaselist[d2.seq].orderlist[idx].sequence, reply->planlist[plancnt].phaselist[
       phasecnt].orderlist[idx].pathway_comp_id = temp->phaselist[d2.seq].orderlist[idx].
       pathway_comp_id
     ENDFOR
     phasereltncnt = size(temp->phaselist[d2.seq].phasereltnlist,5), stat = alterlist(reply->
      planlist[plancnt].phaselist[phasecnt].phasereltnlist,phasereltncnt)
     FOR (idx = 1 TO phasereltncnt)
       reply->planlist[plancnt].phaselist[phasecnt].phasereltnlist[idx].pathway_s_id = temp->
       phaselist[d2.seq].phasereltnlist[idx].pathway_s_id, reply->planlist[plancnt].phaselist[
       phasecnt].phasereltnlist[idx].pathway_t_id = temp->phaselist[d2.seq].phasereltnlist[idx].
       pathway_t_id, reply->planlist[plancnt].phaselist[phasecnt].phasereltnlist[idx].type_mean =
       temp->phaselist[d2.seq].phasereltnlist[idx].type_mean
     ENDFOR
    WITH nocounter
   ;end select
   SET l_size = size(reply->planlist,5)
   SET l_loop_count = ceil((cnvtreal(l_size)/ l_batch_size))
   SET l_new_size = (l_loop_count * l_batch_size)
   SET stat = alterlist(reply->planlist,l_new_size)
   FOR (idx = (l_size+ 1) TO l_new_size)
     SET reply->planlist[idx].pathway_catalog_id = reply->planlist[l_size].pathway_catalog_id
   ENDFOR
   SET l_start = 1
   SELECT INTO "nl:"
    rtr.parent_entity_name, rtr.parent_entity_id
    FROM (dummyt d1  WITH seq = value(l_loop_count)),
     ref_text_reltn rtr
    PLAN (d1
     WHERE initarray(l_start,evaluate(d1.seq,1,1,(l_start+ l_batch_size))))
     JOIN (rtr
     WHERE rtr.parent_entity_name="PATHWAY_CATALOG"
      AND expand(idx,l_start,(l_start+ (l_batch_size - 1)),rtr.parent_entity_id,reply->planlist[idx].
      pathway_catalog_id)
      AND rtr.active_ind=1)
    ORDER BY rtr.parent_entity_name, rtr.parent_entity_id
    HEAD rtr.parent_entity_id
     IF (rtr.parent_entity_id > 0.0)
      idx = locateval(idx,1,l_size,rtr.parent_entity_id,reply->planlist[idx].pathway_catalog_id),
      CALL echo(reply->planlist[idx].pathway_catalog_id)
      WHILE (idx > 0)
        reply->planlist[idx].plan_ref_text_ind = 1,
        CALL echo(reply->planlist[idx].pathway_catalog_id), idx2 = (idx+ 1),
        idx = locateval(idx,idx2,l_size,rtr.parent_entity_id,reply->planlist[idx].pathway_catalog_id)
      ENDWHILE
     ENDIF
    WITH nocounter
   ;end select
   IF (l_size > 0
    AND l_size < l_new_size)
    SET stat = alterlist(reply->planlist,l_size)
   ENDIF
 END ;Subroutine
 SET last_mod = "003 01/18/16"
 SET modify = nopredeclare
END GO
