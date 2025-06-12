CREATE PROGRAM afc_master_rpt:dba
 FREE SET events
 RECORD events(
   1 charge_event[*]
     2 master_id = f8
     2 order_id = f8
     2 event_id = f8
     2 p_ref_id = f8
     2 p_ref_cd = f8
     2 c_ref_id = f8
     2 c_ref_cd = f8
     2 accession = vc
     2 desc = vc
     2 person_name = vc
     2 acts[*]
       3 cea_type = vc
       3 charge_ind = i2
       3 service_dt_tm = dq8
       3 event_dt_tm = dq8
 )
 DECLARE cnt = i4
 SET cnt = 0
 SELECT
  IF ((diag_request->master_list[1].order_id > 0))
   PLAN (d)
    JOIN (c
    WHERE (c.ext_m_event_id=diag_request->master_list[d.seq].master_event_id)
     AND (c.order_id=diag_request->master_list[d.seq].order_id))
    JOIN (p
    WHERE p.person_id=c.person_id)
  ELSE
   PLAN (d)
    JOIN (c
    WHERE (c.ext_m_event_id=diag_request->master_list[d.seq].master_event_id))
    JOIN (p
    WHERE p.person_id=c.person_id)
  ENDIF
  INTO "nl:"
  c.charge_event_id, c.accession, c.ext_p_reference_id,
  c.ext_p_reference_cont_cd, c.ext_i_reference_id, c.ext_i_reference_cont_cd
  FROM (dummyt d  WITH seq = value(diag_request->master_qual)),
   charge_event c,
   person p
  PLAN (d)
   JOIN (c
   WHERE (c.ext_m_event_id=diag_request->master_list[d.seq].master_event_id))
   JOIN (p
   WHERE p.person_id=c.person_id)
  ORDER BY c.charge_event_id
  DETAIL
   cnt += 1, stat = alterlist(events->charge_event,cnt), events->charge_event[cnt].master_id = c
   .ext_m_event_id,
   events->charge_event[cnt].order_id = c.order_id, events->charge_event[cnt].event_id = c
   .charge_event_id, events->charge_event[cnt].accession = c.accession
   IF (c.ext_p_reference_id=0
    AND c.ext_p_reference_cont_cd=0)
    events->charge_event[cnt].p_ref_id = c.ext_i_reference_id, events->charge_event[cnt].p_ref_cd = c
    .ext_i_reference_cont_cd
   ELSE
    events->charge_event[cnt].p_ref_id = c.ext_p_reference_id, events->charge_event[cnt].p_ref_cd = c
    .ext_p_reference_cont_cd, events->charge_event[cnt].c_ref_id = c.ext_i_reference_id,
    events->charge_event[cnt].c_ref_cd = c.ext_i_reference_cont_cd
   ENDIF
   events->charge_event[cnt].person_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SET cnt = 0
 SET foud_desc = 0
 FOR (cnt = 1 TO size(events->charge_event,5))
   SET found_desc = 0
   SELECT INTO "nl:"
    b.ext_description
    FROM bill_item b
    WHERE (b.ext_parent_reference_id=events->charge_event[cnt].p_ref_id)
     AND (b.ext_parent_contributor_cd=events->charge_event[cnt].p_ref_cd)
     AND (b.ext_child_reference_id=events->charge_event[cnt].c_ref_id)
     AND (b.ext_child_contributor_cd=events->charge_event[cnt].c_ref_cd)
     AND b.active_ind=1
    DETAIL
     found_desc = 1, events->charge_event[cnt].desc = b.ext_description
    WITH nocounter
   ;end select
   IF (found_desc=0)
    SELECT INTO "nl:"
     b.ext_description
     FROM bill_item b
     WHERE b.ext_parent_reference_id=0
      AND b.ext_parent_contributor_cd=0
      AND (b.ext_child_reference_id=events->charge_event[cnt].c_ref_id)
      AND (b.ext_child_contributor_cd=events->charge_event[cnt].c_ref_cd)
      AND b.active_ind=1
     DETAIL
      found_desc = 1, events->charge_event[cnt].desc = b.ext_description
     WITH nocounter
    ;end select
    IF (found_desc=0)
     SELECT INTO "nl:"
      b.ext_description
      FROM bill_item b
      WHERE (b.ext_parent_reference_id=events->charge_event[cnt].c_ref_id)
       AND (b.ext_parent_contributor_cd=events->charge_event[cnt].c_ref_cd)
       AND b.ext_child_reference_id=0
       AND b.ext_child_contributor_cd=0
       AND b.active_ind=1
      DETAIL
       found_desc = 1, events->charge_event[cnt].desc = b.ext_description
      WITH nocounter
     ;end select
     IF (found_desc=0)
      SET events->charge_event[cnt].desc = "** No bill item found **"
     ENDIF
    ENDIF
   ENDIF
   SET actcnt = 0
   SELECT INTO "nl:"
    c.charge_event_act_id, c.cea_type_cd, c.service_dt_tm,
    c.updt_dt_tm, ch.charge_item_id
    FROM charge_event_act c,
     dummyt d1,
     charge ch
    PLAN (c
     WHERE (c.charge_event_id=events->charge_event[cnt].event_id))
     JOIN (d1)
     JOIN (ch
     WHERE ch.charge_event_act_id=c.charge_event_act_id)
    ORDER BY c.charge_event_act_id, ch.charge_item_id
    HEAD c.charge_event_act_id
     actcnt += 1, stat = alterlist(events->charge_event[cnt].acts,actcnt), events->charge_event[cnt].
     acts[actcnt].cea_type = uar_get_code_meaning(c.cea_type_cd),
     events->charge_event[cnt].acts[actcnt].service_dt_tm = c.service_dt_tm, events->charge_event[cnt
     ].acts[actcnt].event_dt_tm = c.updt_dt_tm
    HEAD ch.charge_item_id
     IF (ch.charge_item_id > 0)
      events->charge_event[cnt].acts[actcnt].charge_ind = 1
     ENDIF
    WITH nocounter, outerjoin = d1
   ;end select
 ENDFOR
 SET d_line = fillstring(130,"-")
 DECLARE loop_cnt = i2
 SELECT
  FROM (dummyt d  WITH seq = value(size(events->charge_event,5)))
  HEAD PAGE
   col 58, "Afc Master Report", row + 1,
   col 58, "-----------------", row + 2,
   col 01, "MEvent Id", col 13,
   "Order Id", col 25, "CEvent Id",
   col 37, "Accession", col 60,
   "Bill Item", row + 1, col 20,
   "Event", col 41, "Service Date",
   col 62, "Event Date", col 88,
   "Charge", col 105, "Patient",
   row + 1, col 00, d_line,
   row + 1
  DETAIL
   col 01, events->charge_event[d.seq].master_id"#########;L", col 13,
   events->charge_event[d.seq].order_id"#########;L", col 25, events->charge_event[d.seq].event_id
   "#########;L",
   col 37, events->charge_event[d.seq].accession"##################;L", col 60,
   events->charge_event[d.seq].desc"#######################################;L", col 105, events->
   charge_event[d.seq].person_name"#########################;L",
   row + 1
   FOR (loop_cnt = 1 TO size(events->charge_event[d.seq].acts,5))
     col 20, events->charge_event[d.seq].acts[loop_cnt].cea_type"##############;L", col 41,
     events->charge_event[d.seq].acts[loop_cnt].service_dt_tm"mm/dd/yyyy hh:mm;;d", col 62, events->
     charge_event[d.seq].acts[loop_cnt].event_dt_tm"mm/dd/yyyy hh:mm;;d"
     IF ((events->charge_event[d.seq].acts[loop_cnt].charge_ind=1))
      col 90, "YES"
     ENDIF
     row + 1
   ENDFOR
  WITH nocounter
 ;end select
END GO
