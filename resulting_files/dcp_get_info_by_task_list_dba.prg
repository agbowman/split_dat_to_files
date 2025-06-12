CREATE PROGRAM dcp_get_info_by_task_list:dba
 DECLARE program_version = vc WITH private, constant("013")
 FREE RECORD order_ids_associated_to_tasks
 RECORD order_ids_associated_to_tasks(
   1 order_list[*]
     2 order_id = f8
 )
 DECLARE task_status_overdue = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"OVERDUE"))
 DECLARE task_status_inprocess = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"INPROCESS"))
 DECLARE task_status_pending = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"PENDING"))
 DECLARE task_status_validation = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"VALIDATION"
   ))
 DECLARE task_class_prn = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"PRN"))
 DECLARE task_class_continuous = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"CONT"))
 DECLARE task_class_nonscheduled = f8 WITH protect, constant(uar_get_code_by("MEANING",6025,"NSCH"))
 DECLARE task_status_complete = f8 WITH protect, constant(uar_get_code_by("MEANING",79,"COMPLETE"))
 DECLARE task_status_reason_notdone = f8 WITH protect, constant(uar_get_code_by("MEANING",14024,
   "DCP_NOTDONE"))
 DECLARE pharmacy = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE response = f8 WITH protect, constant(uar_get_code_by("MEANING",6026,"RESPONSE"))
 DECLARE grp_event_class = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"GRP"))
 DECLARE result_status_inerror = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE result_status_inerrnomut = f8 WITH protect, constant(uar_get_code_by("MEANING",8,
   "INERRNOMUT"))
 DECLARE result_status_inerrnoview = f8 WITH protect, constant(uar_get_code_by("MEANING",8,
   "INERRNOVIEW"))
 DECLARE record_status_deleted = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"DELETED"))
 DECLARE event_class_placeholder = f8 WITH protect, constant(uar_get_code_by("MEANING",53,
   "PLACEHOLDER"))
 DECLARE list_size = i4 WITH protect, constant(10)
 DECLARE nbroftasks = i4 WITH protect, constant(size(reply->task_list,5))
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE ntotal2 = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(60)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE num1 = i4 WITH protect, noconstant(0)
 DECLARE get_floating_dosage_info_by_event_ids(null) = null
 DECLARE get_floating_dosage_info_by_result_set_ids(null) = null
 DECLARE get_floating_dosage_info_by_template_order_id_and_event_ids(null) = null
 DECLARE get_floating_dosage_info_by_template_order_id_and_result_set_ids(null) = null
 DECLARE populate_task_info(null) = null
 SET ntotal2 = size(reply->task_list,5)
 SET ntotal = (ceil((cnvtreal(ntotal2)/ nsize)) * nsize)
 SET actual_size = size(reply->task_list,5)
 SET stat = alterlist(reply->task_list,ntotal)
 IF (nbroftasks > 0)
  IF ((request->get_order_info=1))
   DECLARE order_action_new = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
   DECLARE admin_note_mask = i4 WITH constant(128)
   DECLARE mar_note_mask = i4 WITH constant(2)
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].order_id = reply->task_list[ntotal2].order_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     orders o,
     order_action oa,
     orders o1
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (o
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),o.order_id,reply->task_list[idx].order_id)
      AND o.active_ind=1)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_type_cd=order_action_new)
     JOIN (o1
     WHERE o1.order_id=o.template_order_id)
    ORDER BY o.order_id
    DETAIL
     index = locateval(num1,1,ntotal2,o.order_id,reply->task_list[num1].order_id)
     WHILE (index != 0)
       reply->task_list[index].order_comment_ind = o.order_comment_ind, reply->task_list[index].
       order_status_cd = o.order_status_cd, reply->task_list[index].template_order_id = o
       .template_order_id,
       reply->task_list[index].stop_type_cd = o.stop_type_cd, reply->task_list[index].
       projected_stop_dt_tm = o.projected_stop_dt_tm, reply->task_list[index].projected_stop_tz = o
       .projected_stop_tz,
       reply->task_list[index].hna_mnemonic = o.hna_order_mnemonic, reply->task_list[index].
       order_mnemonic = o.order_mnemonic, reply->task_list[index].ordered_as_mnemonic = o
       .ordered_as_mnemonic,
       reply->task_list[index].activity_type_cd = o.activity_type_cd, reply->task_list[index].
       ref_text_mask = o.ref_text_mask, reply->task_list[index].cki = o.cki,
       reply->task_list[index].need_rx_verify_ind = o.need_rx_verify_ind, reply->task_list[index].
       orderable_type_flag = o.orderable_type_flag, reply->task_list[index].need_nurse_review_ind = o
       .need_nurse_review_ind,
       reply->task_list[index].freq_type_flag = o.freq_type_flag, reply->task_list[index].
       current_start_dt_tm = o.current_start_dt_tm, reply->task_list[index].current_start_tz = o
       .current_start_tz,
       reply->task_list[index].template_order_flag = o.template_order_flag, reply->task_list[index].
       template_core_action_sequence = o.template_core_action_sequence, reply->task_list[index].
       need_rx_clin_review_flag = o.need_rx_clin_review_flag,
       reply->task_list[index].last_action_sequence = o.last_action_sequence
       IF (trim(o.clinical_display_line) > " ")
        reply->task_list[index].order_detail_display_line = o.clinical_display_line
       ELSE
        reply->task_list[index].order_detail_display_line = o.order_detail_display_line
       ENDIF
       reply->task_list[index].order_provider_id = oa.order_provider_id, reply->task_list[index].
       order_dt_tm = oa.order_dt_tm, reply->task_list[index].order_tz = oa.order_tz
       IF (o.template_order_id > 0)
        reply->task_list[index].parent_order_status_cd = o1.order_status_cd, reply->task_list[index].
        parent_need_rx_verify_ind = o1.need_rx_verify_ind, reply->task_list[index].
        parent_need_nurse_review_ind = o1.need_nurse_review_ind,
        reply->task_list[index].parent_freq_type_flag = o1.freq_type_flag, reply->task_list[index].
        parent_stop_type_cd = o1.stop_type_cd, reply->task_list[index].parent_current_start_dt_tm =
        o1.current_start_dt_tm,
        reply->task_list[index].parent_current_start_tz = o1.current_start_tz, reply->task_list[index
        ].parent_projected_stop_dt_tm = o1.projected_stop_dt_tm, reply->task_list[index].
        parent_projected_stop_tz = o1.projected_stop_tz,
        comment_type_mask_temp = o.comment_type_mask, comment_type_mask_temp = bor(
         comment_type_mask_temp,band(o1.comment_type_mask,admin_note_mask)), comment_type_mask_temp
         = bor(comment_type_mask_temp,band(o1.comment_type_mask,mar_note_mask)),
        reply->task_list[index].comment_type_mask = comment_type_mask_temp, reply->task_list[index].
        link_nbr = o1.link_nbr, reply->task_list[index].link_type_flag = o1.link_type_flag
       ELSE
        reply->task_list[index].comment_type_mask = o.comment_type_mask, reply->task_list[index].
        link_nbr = o.link_nbr, reply->task_list[index].link_type_flag = o.link_type_flag
       ENDIF
       index = locateval(num1,(index+ 1),ntotal2,o.order_id,reply->task_list[num1].order_id)
     ENDWHILE
    WITH check
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(nbroftasks)),
     order_detail od
    PLAN (d)
     JOIN (od
     WHERE (((od.order_id=reply->task_list[d.seq].order_id)
      AND (reply->task_list[d.seq].template_order_id=0)) OR ((od.order_id=reply->task_list[d.seq].
     template_order_id)))
      AND od.oe_field_meaning IN ("FREQ", "RSN", "RXROUTE")
      AND (od.action_sequence=
     (SELECT
      max(od2.action_sequence)
      FROM order_detail od2
      WHERE od2.order_id=od.order_id
       AND od2.oe_field_id=od.oe_field_id)))
    ORDER BY od.order_id
    DETAIL
     CASE (od.oe_field_meaning)
      OF "FREQ":
       reply->task_list[d.seq].frequency_cd = od.oe_field_value,reply->task_list[d.seq].
       freq_detail_display = od.oe_field_display_value
      OF "RSN":
       reply->task_list[d.seq].rsn_detail_display = od.oe_field_display_value
      OF "RXROUTE":
       reply->task_list[d.seq].route_detail_display = od.oe_field_display_value
     ENDCASE
    WITH check
   ;end select
   DECLARE order_comment_mask = i4 WITH constant(1)
   DECLARE order_comment_cd = f8 WITH noconstant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(nbroftasks)),
     order_comment oc,
     long_text lt
    PLAN (d
     WHERE band(reply->task_list[d.seq].comment_type_mask,order_comment_mask)=order_comment_mask)
     JOIN (oc
     WHERE (oc.order_id=reply->task_list[d.seq].order_id)
      AND oc.comment_type_cd=order_comment_cd
      AND (oc.action_sequence=
     (SELECT
      max(oc2.action_sequence)
      FROM order_comment oc2
      WHERE oc2.order_id=oc.order_id
       AND oc2.comment_type_cd=order_comment_cd)))
     JOIN (lt
     WHERE lt.long_text_id=oc.long_text_id)
    DETAIL
     reply->task_list[d.seq].order_comment_text = lt.long_text
    WITH check
   ;end select
   DECLARE additive_ing_type_flag = i4 WITH constant(3)
   DECLARE ivpb_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(nbroftasks)),
     order_ingredient oi
    PLAN (d
     WHERE (reply->task_list[d.seq].med_order_type_cd=ivpb_type_cd))
     JOIN (oi
     WHERE (oi.order_id=reply->task_list[d.seq].order_id)
      AND (oi.action_sequence=
     (SELECT
      max(oi2.action_sequence)
      FROM order_ingredient oi2
      WHERE oi2.order_id=oi.order_id))
      AND oi.ingredient_type_flag=additive_ing_type_flag)
    DETAIL
     reply->task_list[d.seq].additive_cnt += 1
    WITH check
   ;end select
   IF ((request->get_protocol_order_info=1))
    DECLARE patient_mismatch_ind = i4 WITH protect, constant(8)
    SET nstart = 1
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
      orders o,
      orders o2
     PLAN (d
      WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
      JOIN (o
      WHERE expand(idx,nstart,(nstart+ (nsize - 1)),o.order_id,reply->task_list[idx].order_id)
       AND ((o.order_id+ 0) > 0.0)
       AND ((o.protocol_order_id+ 0) > 0.0))
      JOIN (o2
      WHERE o2.order_id=o.protocol_order_id)
     DETAIL
      index = locateval(num1,1,ntotal2,o.order_id,reply->task_list[num1].order_id)
      WHILE (index != 0)
        stat = alterlist(reply->task_list[index].protocol_order_info,1)
        IF (band(o2.warning_level_bit,patient_mismatch_ind)=patient_mismatch_ind)
         stat = alterlist(reply->task_list[index].protocol_order_info[1].warning_type_list,1), reply
         ->task_list[index].protocol_order_info[1].warning_type_list[1].protocol_patient_mismatch_ind
          = 1
        ENDIF
        index = locateval(num1,(index+ 1),ntotal2,o.order_id,reply->task_list[num1].order_id)
      ENDWHILE
     WITH check
    ;end select
   ENDIF
  ENDIF
  IF ((request->get_pathway_info=1))
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].order_id = reply->task_list[ntotal2].order_id
   ENDFOR
   DECLARE order_ids_associated_to_tasks_size = i4 WITH protect, noconstant(0)
   SET stat = alterlist(order_ids_associated_to_tasks->order_list,ntotal2)
   FOR (idx = 1 TO ntotal2)
     IF ((reply->task_list[idx].order_id > 0.0))
      SET order_ids_associated_to_tasks_size += 1
      SET order_ids_associated_to_tasks->order_list[order_ids_associated_to_tasks_size].order_id =
      reply->task_list[idx].order_id
     ENDIF
   ENDFOR
   SET stat = alterlist(order_ids_associated_to_tasks->order_list,order_ids_associated_to_tasks_size)
   SET nstart = 1
   IF (order_ids_associated_to_tasks_size > 0)
    SELECT INTO "nl:"
     FROM orders o,
      (left JOIN act_pw_comp a ON a.parent_entity_name="ORDERS"
       AND a.parent_entity_id=o.order_id),
      (left JOIN pathway p ON p.pathway_id=a.pathway_id)
     PLAN (o
      WHERE expand(idx,nstart,order_ids_associated_to_tasks_size,o.order_id,
       order_ids_associated_to_tasks->order_list[idx].order_id))
      JOIN (a)
      JOIN (p)
     DETAIL
      index = locateval(num1,1,ntotal2,o.order_id,reply->task_list[num1].order_id)
      WHILE (index > 0)
        reply->task_list[index].pathway_catalog_id = o.pathway_catalog_id
        IF (p.pathway_type_cd > 0)
         stat = alterlist(reply->task_list[index].pathway_info,1), reply->task_list[index].
         pathway_info.pathway_type_cd = p.pathway_type_cd
        ENDIF
        index = locateval(num1,(index+ 1),ntotal2,o.order_id,reply->task_list[num1].order_id)
      ENDWHILE
     WITH check, expand = 2
    ;end select
   ENDIF
   SET stat = alterlist(order_ids_associated_to_tasks->order_list,0)
  ENDIF
  IF ((request->get_encounter_info=1))
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].encntr_id = reply->task_list[ntotal2].encntr_id
   ENDFOR
   DECLARE finnbr_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR"))
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     encounter enc
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (enc
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),enc.encntr_id,reply->task_list[idx].encntr_id)
      AND enc.active_ind=1
      AND enc.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND enc.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     index = locateval(num1,1,ntotal2,enc.encntr_id,reply->task_list[num1].encntr_id)
     WHILE (index != 0)
       IF (enc.loc_nurse_unit_cd > 0)
        reply->task_list[index].location_cd = enc.loc_nurse_unit_cd, reply->task_list[index].
        location_mean = uar_get_code_meaning(enc.loc_nurse_unit_cd), reply->task_list[index].
        location_disp = uar_get_code_display(enc.loc_nurse_unit_cd)
       ENDIF
       IF (enc.loc_room_cd > 0)
        reply->task_list[index].loc_room_cd = enc.loc_room_cd, reply->task_list[index].loc_room_mean
         = uar_get_code_meaning(enc.loc_room_cd), reply->task_list[index].loc_room_disp =
        uar_get_code_display(enc.loc_room_cd)
       ENDIF
       IF (enc.loc_bed_cd > 0)
        reply->task_list[index].loc_bed_cd = enc.loc_bed_cd, reply->task_list[index].loc_bed_mean =
        uar_get_code_meaning(enc.loc_bed_cd), reply->task_list[index].loc_bed_disp =
        uar_get_code_display(enc.loc_bed_cd)
       ENDIF
       IF (enc.isolation_cd > 0)
        reply->task_list[index].isolation_cd = enc.isolation_cd, reply->task_list[index].
        isolation_mean = uar_get_code_meaning(enc.isolation_cd), reply->task_list[index].
        isolation_disp = uar_get_code_display(enc.isolation_cd)
       ENDIF
       index = locateval(num1,(index+ 1),ntotal2,enc.encntr_id,reply->task_list[num1].encntr_id)
     ENDWHILE
    WITH check
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     encntr_alias ea
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (ea
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ea.encntr_id,reply->task_list[idx].encntr_id)
      AND ea.encntr_alias_type_cd=finnbr_cd
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     index = locateval(num1,1,ntotal2,ea.encntr_id,reply->task_list[num1].encntr_id)
     WHILE (index != 0)
      IF (ea.encntr_alias_type_cd=finnbr_cd)
       reply->task_list[index].finnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
      ENDIF
      ,index = locateval(num1,(index+ 1),ntotal2,ea.encntr_id,reply->task_list[num1].encntr_id)
     ENDWHILE
    WITH check
   ;end select
  ENDIF
  IF ((request->get_person_info=1))
   DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN"))
   SET nstart = 1
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].person_id = reply->task_list[ntotal2].person_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     person p
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (p
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),p.person_id,reply->task_list[idx].person_id))
    DETAIL
     index = locateval(num1,1,ntotal2,p.person_id,reply->task_list[num1].person_id)
     WHILE (index != 0)
      reply->task_list[index].person_name = p.name_full_formatted,index = locateval(num1,(index+ 1),
       ntotal2,p.person_id,reply->task_list[num1].person_id)
     ENDWHILE
    WITH check
   ;end select
   SET nstart = 1
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].msg_sender_id = reply->task_list[ntotal2].msg_sender_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     person msg_p
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (msg_p
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),msg_p.person_id,reply->task_list[idx].
      msg_sender_id))
    DETAIL
     index = locateval(num1,1,ntotal2,msg_p.person_id,reply->task_list[num1].msg_sender_id)
     WHILE (index != 0)
      reply->task_list[index].msg_sender_name = msg_p.name_full_formatted,index = locateval(num1,(
       index+ 1),ntotal2,msg_p.person_id,reply->task_list[num1].msg_sender_id)
     ENDWHILE
    WITH check
   ;end select
   SET nstart = 1
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].performed_prsnl_id = reply->task_list[ntotal2].performed_prsnl_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     prsnl p
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (p
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),p.person_id,reply->task_list[idx].
      performed_prsnl_id))
    DETAIL
     index = locateval(num1,1,ntotal2,p.person_id,reply->task_list[num1].performed_prsnl_id)
     WHILE (index != 0)
      reply->task_list[index].performed_prsnl_name = p.name_full_formatted,index = locateval(num1,(
       index+ 1),ntotal2,p.person_id,reply->task_list[num1].performed_prsnl_id)
     ENDWHILE
    WITH check
   ;end select
   SET nstart = 1
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].updt_id = reply->task_list[ntotal2].updt_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     prsnl updt_p
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (updt_p
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),updt_p.person_id,reply->task_list[idx].updt_id))
    DETAIL
     index = locateval(num1,1,ntotal2,updt_p.person_id,reply->task_list[num1].updt_id)
     WHILE (index != 0)
      reply->task_list[index].updt_person_name = updt_p.name_full_formatted,index = locateval(num1,(
       index+ 1),ntotal2,updt_p.person_id,reply->task_list[num1].updt_id)
     ENDWHILE
    WITH check
   ;end select
   SET nstart = 1
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     encntr_alias ea
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (ea
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ea.encntr_id,reply->task_list[idx].encntr_id)
      AND ea.encntr_alias_type_cd=mrn_cd
      AND ea.active_ind=1
      AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     index = locateval(num1,1,ntotal2,ea.encntr_id,reply->task_list[num1].encntr_id)
     WHILE (index != 0)
      reply->task_list[index].mrn = cnvtalias(ea.alias,ea.alias_pool_cd),index = locateval(num1,(
       index+ 1),ntotal2,ea.encntr_id,reply->task_list[num1].encntr_id)
     ENDWHILE
    WITH check
   ;end select
  ENDIF
  IF ((request->get_container_info=1))
   SET nstart = 1
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].container_id = reply->task_list[ntotal2].container_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     container c,
     container_accession ca
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (c
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),c.container_id,reply->task_list[idx].container_id)
      AND c.container_id > 0)
     JOIN (ca
     WHERE ca.container_id=c.container_id)
    DETAIL
     index = locateval(num1,1,ntotal2,c.container_id,reply->task_list[num1].container_id)
     WHILE (index != 0)
       reply->task_list[index].spec_cntnr_cd = c.spec_cntnr_cd, reply->task_list[index].volume = c
       .volume, reply->task_list[index].units_cd = c.units_cd,
       reply->task_list[index].parent_container_id = c.parent_container_id, reply->task_list[index].
       accession_container_nbr = ca.accession_container_nbr, reply->task_list[index].accession =
       uar_fmt_accession(ca.accession,size(ca.accession,1)),
       reply->task_list[index].specimen_type_cd = c.specimen_type_cd, index = locateval(num1,(index+
        1),ntotal2,c.container_id,reply->task_list[num1].container_id)
     ENDWHILE
    WITH check
   ;end select
  ENDIF
  IF ((request->get_ce_med_result_info=1))
   SET nstart = 1
   FOR (idx = (ntotal2+ 1) TO ntotal)
     SET reply->task_list[idx].event_id = reply->task_list[ntotal2].event_id
   ENDFOR
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
     clinical_event ce,
     ce_med_result cmr
    PLAN (d
     WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
     JOIN (ce
     WHERE expand(idx,nstart,(nstart+ (nsize - 1)),ce.parent_event_id,reply->task_list[idx].event_id)
      AND ce.event_class_cd != grp_event_class)
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id)
    DETAIL
     index = locateval(num1,1,ntotal2,ce.parent_event_id,reply->task_list[num1].event_id)
     WHILE (index != 0)
      reply->task_list[index].response_required_flag = cmr.response_required_flag,index = locateval(
       num1,(index+ 1),ntotal2,ce.parent_event_id,reply->task_list[num1].event_id)
     ENDWHILE
    WITH check
   ;end select
  ENDIF
  FREE SET order_group
  RECORD order_group(
    1 order_task_info[*]
      2 order_id = f8
      2 last_done_dt_tm = dq8
      2 last_done_tz = i4
      2 initial_volume = f8
      2 initial_dosage = f8
      2 admin_dosage = f8
      2 dosage_unit_cd = f8
      2 admin_site_cd = f8
      2 infusion_rate = f8
      2 infusion_unit_cd = f8
      2 iv_event_cd = f8
  )
  SET stat = alterlist(reply->task_list,actual_size)
  IF ((request->get_floating_dosage_info=1))
   CALL echo("Begin retrieval of floating dosage information.")
   DECLARE cust_loopcount = i4 WITH protect, noconstant(0)
   DECLARE order_task_info_idx = i4 WITH protect, noconstant(0)
   DECLARE order_task_info_count = i4 WITH protect, noconstant(0)
   FOR (cust_loopcount = 1 TO size(reply->task_list,5))
     IF (is_task_active_and_floating(cust_loopcount)
      AND (reply->task_list[cust_loopcount].order_id > 0.0))
      SET order_task_info_idx = locateval(index,1,order_task_info_count,reply->task_list[
       cust_loopcount].order_id,order_group->order_task_info[index].order_id)
      IF (order_task_info_idx=0)
       SET order_task_info_count += 1
       IF (order_task_info_count > size(order_group->order_task_info,5))
        SET stat = alterlist(order_group->order_task_info,(order_task_info_count+ list_size))
       ENDIF
       SET order_group->order_task_info[order_task_info_count].order_id = reply->task_list[
       cust_loopcount].order_id
      ENDIF
     ENDIF
   ENDFOR
   SET stat = alterlist(order_group->order_task_info,order_task_info_count)
   IF (size(order_group->order_task_info,5) > 0)
    CALL get_floating_dosage_info_by_event_ids(null)
    CALL get_floating_dosage_info_by_result_set_ids(null)
    CALL get_floating_dosage_info_by_template_order_id_and_event_ids(null)
    CALL get_floating_dosage_info_by_template_order_id_and_result_set_ids(null)
    CALL populate_task_info(null)
   ENDIF
  ENDIF
 ENDIF
 SET stat = alterlist(reply->task_list,actual_size)
 SUBROUTINE get_floating_dosage_info_by_event_ids(null)
  CALL echo("Starting retrieval of floating dosage info by event_ids.")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(order_group->order_task_info,5))),
    task_activity ta,
    clinical_event ce,
    ce_med_result cmr
   PLAN (d)
    JOIN (ta
    WHERE (ta.order_id=order_group->order_task_info[d.seq].order_id)
     AND ta.task_status_cd=task_status_complete
     AND ta.task_status_reason_cd != task_status_reason_notdone
     AND ta.task_type_cd != response)
    JOIN (ce
    WHERE ta.event_id > 0.0
     AND ce.parent_event_id=ta.event_id
     AND ((ta.catalog_type_cd != pharmacy) OR (ta.catalog_type_cd=pharmacy
     AND ce.event_class_cd != grp_event_class))
     AND (ce.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
     AND  NOT (ce.result_status_cd IN (result_status_inerror, result_status_inerrnomut,
    result_status_inerrnoview))
     AND ce.record_status_cd != record_status_deleted
     AND ce.event_class_cd != event_class_placeholder)
    JOIN (cmr
    WHERE (cmr.event_id= Outerjoin(ce.event_id))
     AND (cmr.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   ORDER BY d.seq, ce.event_end_dt_tm DESC
   HEAD d.seq
    IF ((((order_group->order_task_info[d.seq].last_done_dt_tm < cnvtdatetime(ce.event_end_dt_tm)))
     OR ((order_group->order_task_info[d.seq].last_done_dt_tm=0))) )
     order_group->order_task_info[d.seq].last_done_dt_tm = cnvtdatetime(ce.event_end_dt_tm),
     order_group->order_task_info[d.seq].last_done_tz = ce.event_end_tz, order_group->
     order_task_info[d.seq].initial_volume = cmr.initial_volume,
     order_group->order_task_info[d.seq].initial_dosage = cmr.initial_dosage, order_group->
     order_task_info[d.seq].admin_dosage = cmr.admin_dosage, order_group->order_task_info[d.seq].
     dosage_unit_cd = cmr.dosage_unit_cd,
     order_group->order_task_info[d.seq].admin_site_cd = cmr.admin_site_cd, order_group->
     order_task_info[d.seq].infusion_rate = cmr.infusion_rate, order_group->order_task_info[d.seq].
     infusion_unit_cd = cmr.infusion_unit_cd,
     order_group->order_task_info[d.seq].iv_event_cd = cmr.iv_event_cd
    ENDIF
   WITH check
  ;end select
 END ;Subroutine
 SUBROUTINE get_floating_dosage_info_by_result_set_ids(null)
  CALL echo("Starting retrieval of floating dosage info by result_set_ids.")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(order_group->order_task_info,5))),
    task_activity ta,
    ce_result_set_link rsl,
    clinical_event ce,
    ce_med_result cmr
   PLAN (d)
    JOIN (ta
    WHERE (ta.order_id=order_group->order_task_info[d.seq].order_id)
     AND ta.task_status_cd=task_status_complete
     AND ta.task_status_reason_cd != task_status_reason_notdone
     AND ta.task_type_cd != response)
    JOIN (rsl
    WHERE ta.result_set_id > 0.0
     AND rsl.result_set_id=ta.result_set_id
     AND rsl.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
    JOIN (ce
    WHERE ce.parent_event_id=rsl.event_id
     AND ((ta.catalog_type_cd != pharmacy) OR (ta.catalog_type_cd=pharmacy
     AND ce.event_class_cd != grp_event_class))
     AND (ce.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
     AND  NOT (ce.result_status_cd IN (result_status_inerror, result_status_inerrnomut,
    result_status_inerrnoview))
     AND ce.record_status_cd != record_status_deleted
     AND ce.event_class_cd != event_class_placeholder)
    JOIN (cmr
    WHERE (cmr.event_id= Outerjoin(ce.event_id))
     AND (cmr.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   ORDER BY d.seq, ce.event_end_dt_tm DESC
   HEAD d.seq
    IF ((((order_group->order_task_info[d.seq].last_done_dt_tm < cnvtdatetime(ce.event_end_dt_tm)))
     OR ((order_group->order_task_info[d.seq].last_done_dt_tm=0))) )
     order_group->order_task_info[d.seq].last_done_dt_tm = cnvtdatetime(ce.event_end_dt_tm),
     order_group->order_task_info[d.seq].last_done_tz = ce.event_end_tz, order_group->
     order_task_info[d.seq].initial_volume = cmr.initial_volume,
     order_group->order_task_info[d.seq].initial_dosage = cmr.initial_dosage, order_group->
     order_task_info[d.seq].admin_dosage = cmr.admin_dosage, order_group->order_task_info[d.seq].
     dosage_unit_cd = cmr.dosage_unit_cd,
     order_group->order_task_info[d.seq].admin_site_cd = cmr.admin_site_cd, order_group->
     order_task_info[d.seq].infusion_rate = cmr.infusion_rate, order_group->order_task_info[d.seq].
     infusion_unit_cd = cmr.infusion_unit_cd,
     order_group->order_task_info[d.seq].iv_event_cd = cmr.iv_event_cd
    ENDIF
   WITH check
  ;end select
 END ;Subroutine
 SUBROUTINE get_floating_dosage_info_by_template_order_id_and_result_set_ids(null)
  CALL echo("Joining to orders table using template_order_id and result_set_id.")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(order_group->order_task_info,5))),
    task_activity ta,
    ce_result_set_link rsl,
    clinical_event ce,
    ce_med_result cmr,
    orders o
   PLAN (d)
    JOIN (o
    WHERE (o.template_order_id=order_group->order_task_info[d.seq].order_id))
    JOIN (ta
    WHERE ta.order_id=o.order_id
     AND ta.task_status_cd=task_status_complete
     AND ta.task_status_reason_cd != task_status_reason_notdone
     AND ta.task_type_cd != response)
    JOIN (rsl
    WHERE ta.result_set_id > 0.0
     AND rsl.result_set_id=ta.result_set_id
     AND rsl.valid_until_dt_tm=cnvtdatetimeutc("31-DEC-2100"))
    JOIN (ce
    WHERE ce.parent_event_id=rsl.event_id
     AND ((ta.catalog_type_cd != pharmacy) OR (ta.catalog_type_cd=pharmacy
     AND ce.event_class_cd != grp_event_class))
     AND (ce.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
     AND  NOT (ce.result_status_cd IN (result_status_inerror, result_status_inerrnomut,
    result_status_inerrnoview))
     AND ce.record_status_cd != record_status_deleted
     AND ce.event_class_cd != event_class_placeholder)
    JOIN (cmr
    WHERE (cmr.event_id= Outerjoin(ce.event_id))
     AND (cmr.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   ORDER BY d.seq, ce.event_end_dt_tm DESC
   HEAD d.seq
    IF ((((order_group->order_task_info[d.seq].last_done_dt_tm < cnvtdatetime(ce.event_end_dt_tm)))
     OR ((order_group->order_task_info[d.seq].last_done_dt_tm=0))) )
     order_group->order_task_info[d.seq].last_done_dt_tm = cnvtdatetime(ce.event_end_dt_tm),
     order_group->order_task_info[d.seq].last_done_tz = ce.event_end_tz, order_group->
     order_task_info[d.seq].initial_volume = cmr.initial_volume,
     order_group->order_task_info[d.seq].initial_dosage = cmr.initial_dosage, order_group->
     order_task_info[d.seq].admin_dosage = cmr.admin_dosage, order_group->order_task_info[d.seq].
     dosage_unit_cd = cmr.dosage_unit_cd,
     order_group->order_task_info[d.seq].admin_site_cd = cmr.admin_site_cd, order_group->
     order_task_info[d.seq].infusion_rate = cmr.infusion_rate, order_group->order_task_info[d.seq].
     infusion_unit_cd = cmr.infusion_unit_cd,
     order_group->order_task_info[d.seq].iv_event_cd = cmr.iv_event_cd
    ENDIF
   WITH check
  ;end select
 END ;Subroutine
 SUBROUTINE get_floating_dosage_info_by_template_order_id_and_event_ids(null)
  CALL echo("Joining to orders table using template_order_id and event_id")
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(order_group->order_task_info,5))),
    task_activity ta,
    clinical_event ce,
    ce_med_result cmr,
    orders o
   PLAN (d)
    JOIN (o
    WHERE (o.template_order_id=order_group->order_task_info[d.seq].order_id))
    JOIN (ta
    WHERE ta.order_id=o.order_id
     AND ta.task_status_cd=task_status_complete
     AND ta.task_status_reason_cd != task_status_reason_notdone
     AND ta.task_type_cd != response)
    JOIN (ce
    WHERE ta.event_id > 0.0
     AND ce.parent_event_id=ta.event_id
     AND ((ta.catalog_type_cd != pharmacy) OR (ta.catalog_type_cd=pharmacy
     AND ce.event_class_cd != grp_event_class))
     AND (ce.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00")))
     AND  NOT (ce.result_status_cd IN (result_status_inerror, result_status_inerrnomut,
    result_status_inerrnoview))
     AND ce.record_status_cd != record_status_deleted
     AND ce.event_class_cd != event_class_placeholder)
    JOIN (cmr
    WHERE (cmr.event_id= Outerjoin(ce.event_id))
     AND (cmr.valid_until_dt_tm= Outerjoin(cnvtdatetime("31-DEC-2100 00:00:00"))) )
   ORDER BY d.seq, ce.event_end_dt_tm DESC
   HEAD d.seq
    IF ((((order_group->order_task_info[d.seq].last_done_dt_tm < cnvtdatetime(ce.event_end_dt_tm)))
     OR ((order_group->order_task_info[d.seq].last_done_dt_tm=0))) )
     order_group->order_task_info[d.seq].last_done_dt_tm = cnvtdatetime(ce.event_end_dt_tm),
     order_group->order_task_info[d.seq].last_done_tz = ce.event_end_tz, order_group->
     order_task_info[d.seq].initial_volume = cmr.initial_volume,
     order_group->order_task_info[d.seq].initial_dosage = cmr.initial_dosage, order_group->
     order_task_info[d.seq].admin_dosage = cmr.admin_dosage, order_group->order_task_info[d.seq].
     dosage_unit_cd = cmr.dosage_unit_cd,
     order_group->order_task_info[d.seq].admin_site_cd = cmr.admin_site_cd, order_group->
     order_task_info[d.seq].infusion_rate = cmr.infusion_rate, order_group->order_task_info[d.seq].
     infusion_unit_cd = cmr.infusion_unit_cd,
     order_group->order_task_info[d.seq].iv_event_cd = cmr.iv_event_cd
    ENDIF
   WITH check
  ;end select
 END ;Subroutine
 SUBROUTINE populate_task_info(null)
   CALL echo(
    "Start populating the last done dosage information onto the reply from the internal structure.")
   DECLARE cust_loopcount = i4 WITH protect, noconstant(0)
   DECLARE reply_idx = i4 WITH protect, noconstant(0)
   FOR (cust_loopcount = 1 TO size(order_group->order_task_info,5))
    SET reply_idx = locateval(index,1,size(reply->task_list,5),order_group->order_task_info[
     cust_loopcount].order_id,reply->task_list[index].order_id)
    WHILE (reply_idx != 0)
     IF (is_task_active_and_floating(reply_idx))
      SET reply->task_list[reply_idx].last_done_dt_tm = order_group->order_task_info[cust_loopcount].
      last_done_dt_tm
      SET reply->task_list[reply_idx].last_done_tz = order_group->order_task_info[cust_loopcount].
      last_done_tz
      SET reply->task_list[reply_idx].initial_volume = order_group->order_task_info[cust_loopcount].
      initial_volume
      SET reply->task_list[reply_idx].initial_dosage = order_group->order_task_info[cust_loopcount].
      initial_dosage
      SET reply->task_list[reply_idx].admin_dosage = order_group->order_task_info[cust_loopcount].
      admin_dosage
      SET reply->task_list[reply_idx].dosage_unit_cd = order_group->order_task_info[cust_loopcount].
      dosage_unit_cd
      SET reply->task_list[reply_idx].admin_site_cd = order_group->order_task_info[cust_loopcount].
      admin_site_cd
      SET reply->task_list[reply_idx].infusion_rate = order_group->order_task_info[cust_loopcount].
      infusion_rate
      SET reply->task_list[reply_idx].infusion_unit_cd = order_group->order_task_info[cust_loopcount]
      .infusion_unit_cd
      SET reply->task_list[reply_idx].iv_event_cd = order_group->order_task_info[cust_loopcount].
      iv_event_cd
     ENDIF
     SET reply_idx = locateval(index,(reply_idx+ 1),size(reply->task_list,5),order_group->
      order_task_info[cust_loopcount].order_id,reply->task_list[index].order_id)
    ENDWHILE
   ENDFOR
 END ;Subroutine
 SUBROUTINE (is_task_active_and_floating(reply_idx=i4) =i2)
  CALL echo(build2("Processing task with id:  ",reply->task_list[reply_idx].task_id))
  IF ((((reply->task_list[reply_idx].task_status_cd=task_status_inprocess)) OR ((((reply->task_list[
  reply_idx].task_status_cd=task_status_validation)) OR ((reply->task_list[reply_idx].task_status_cd=
  task_status_pending))) ))
   AND (((reply->task_list[reply_idx].task_class_cd=task_class_prn)) OR ((((reply->task_list[
  reply_idx].task_class_cd=task_class_continuous)) OR ((reply->task_list[reply_idx].task_class_cd=
  task_class_nonscheduled))) )) )
   CALL echo(build2("Task with id:  ",reply->task_list[reply_idx].task_id," is active and floating.")
    )
   RETURN(1)
  ELSE
   CALL echo(build2("Task with id:  ",reply->task_list[reply_idx].task_id,
     " is either not active or not           floating."))
   RETURN(0)
  ENDIF
 END ;Subroutine
 FREE RECORD order_ids_associated_to_tasks
END GO
