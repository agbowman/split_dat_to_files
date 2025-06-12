CREATE PROGRAM dcpreqlbl01:dba
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 RECORD orders(
   1 name = vc
   1 age = vc
   1 dob = vc
   1 sex = vc
   1 race = vc
   1 admitting_dr = vc
   1 admitting_dr_num = vc
   1 mrn = vc
   1 ssn = vc
   1 fnbr = vc
   1 admit_diagnosis = vc
   1 type = vc
   1 financial_num = vc
   1 admit_dt_tm = dq8
   1 location = vc
   1 facility = vc
   1 nurse_unit = vc
   1 room = vc
   1 bed = vc
   1 isolation = vc
   1 hphone = vc
   1 wphone = vc
   1 med_service = vc
   1 street = vc
   1 city_state_zip = vc
   1 allergy_cnt = i2
   1 aqual[*]
     2 allergy_display = vc
   1 diag_cnt = i2
   1 dqual[*]
     2 diag_display = vc
   1 order_location = vc
   1 spoolout_ind = i2
   1 qual[*]
     2 display_ind = i2
     2 template_order_flag = i4
     2 special_action_ind = i2
     2 stat_ind = i2
     2 order_id = f8
     2 order_mnemonic = vc
     2 oe_format_id = f8
     2 action_type_cd = f8
     2 catalog_type = vc
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 action = vc
     2 action_prsnl_name = vc
     2 action_dt_tm = dq8
     2 action_sequence = i4
     2 order_provider_name = vc
     2 current_start_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 active_status_dt_tm = dq8
     2 accession = vc
     2 details_retrieved = i2
     2 detail_cnt = i2
     2 detail_qual[*]
       3 field_id = f8
       3 field_description = vc
       3 label_text = vc
       3 display_value = vc
       3 field_value = f8
       3 oe_field_meaning_id = f8
       3 group_seq = i4
       3 print_ind = i2
     2 comment_cnt = i2
     2 comments_ind = c1
     2 comment_qual[*]
       3 comment_text = vc
 )
 SET retrieve_allergy_info = 0
 SET retrieve_accession_info = 0
 SET retrieve_diag_info = 0
 SET retrieve_phone_addr_info = 0
 SET retrieve_ocf_results = 0
 SET num_of_orders = 0
 SET num_of_orders = size(request->order_qual,5)
 SET stat = alterlist(orders->qual,num_of_orders)
 SET orders->allergy_cnt = 0
 SET orders->diag_cnt = 0
 SET orders->spoolout_ind = 0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 43
 SET cdf_meaning = "PAGER BUS"
 EXECUTE cpm_get_cd_for_cdf
 SET pager_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "MRN"
 EXECUTE cpm_get_cd_for_cdf
 SET mrn_alias_cd = code_value
 SET code_set = 4
 SET cdf_meaning = "SSN"
 EXECUTE cpm_get_cd_for_cdf
 SET ssn_alias_cd = code_value
 SET code_set = 319
 SET cdf_meaning = "FIN NBR"
 EXECUTE cpm_get_cd_for_cdf
 SET finnbr_cd = code_value
 SET code_set = 333
 SET cdf_meaning = "ADMITDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET admit_doc_cd = code_value
 SET attending = fillstring(25," ")
 SET code_set = 333
 SET cdf_meaning = "ATTENDDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET attend_doc_cd = code_value
 SET resident = fillstring(25," ")
 SET code_set = 333
 SET cdf_meaning = "RESIDENTDOC"
 EXECUTE cpm_get_cd_for_cdf
 SET resident_doc_cd = code_value
 SET code_set = 14
 SET cdf_meaning = "ORD COMMENT"
 EXECUTE cpm_get_cd_for_cdf
 SET comment_type_cd = code_value
 SET order_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "ORDER"
 EXECUTE cpm_get_cd_for_cdf
 SET order_code = code_value
 SET complete_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "COMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET complete_code = code_value
 SET incomplete_code = 0.0
 SET code_set = 6004
 SET cdf_meaning = "INCOMPLETE"
 EXECUTE cpm_get_cd_for_cdf
 SET incomplete_code = code_value
 SET cancel_code = 0.0
 SET code_set = 6003
 SET cdf_meaning = "CANCEL"
 EXECUTE cpm_get_cd_for_cdf
 SET cancel_code = code_value
 SELECT INTO "nl:"
  p.person_id, e.encntr_id, ea.enctnr_id,
  epr.encntr_id, pl.person_id, pa.person_id
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1)
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd IN (mrn_alias_cd, ssn_alias_cd)
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=finnbr_cd
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND ((epr.encntr_prsnl_r_cd=admit_doc_cd) OR (((epr.encntr_prsnl_r_cd=attend_doc_cd) OR (epr
   .encntr_prsnl_r_cd=resident_doc_cd)) )) )
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   orders->dob = format(p.birth_dt_tm,"MM/DD/YYYY;;D"), orders->name = trim(p.name_full_formatted),
   orders->sex = trim(uar_get_code_display(p.sex_cd)),
   orders->admit_diagnosis = trim(e.reason_for_visit), orders->race = trim(uar_get_code_display(p
     .race_cd)), orders->admit_dt_tm = e.reg_dt_tm,
   orders->facility = trim(uar_get_code_display(e.loc_facility_cd)), orders->nurse_unit = trim(
    uar_get_code_display(e.loc_nurse_unit_cd)), orders->room = trim(uar_get_code_display(e
     .loc_room_cd)),
   orders->bed = trim(uar_get_code_display(e.loc_bed_cd)), orders->location = concat(orders->
    nurse_unit,"   ",orders->room,"/",orders->bed), orders->age = trim(cnvtage(cnvtdate(p.birth_dt_tm
      ),curdate),3),
   orders->type = trim(uar_get_code_display(e.encntr_type_cd)), orders->isolation = trim(
    uar_get_code_display(e.isolation_cd)), orders->med_service = trim(uar_get_code_display(e
     .med_service_cd))
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    orders->admitting_dr = trim(pl.name_full_formatted), orders->admitting_dr_num = trim(cnvtstring(
      cnvtint(epr.prsnl_person_id)))
   ELSEIF (epr.encntr_prsnl_r_cd=attend_doc_cd)
    attending = trim(pl.name_full_formatted)
   ELSEIF (epr.encntr_prsnl_r_cd=resident_doc_cd)
    resident = trim(pl.name_full_formatted)
   ELSE
    resident = "    "
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=mrn_alias_cd)
    IF (pa.alias_pool_cd > 0)
     orders->mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     orders->mrn = pa.alias
    ENDIF
   ENDIF
   IF (pa.person_alias_type_cd=ssn_alias_cd)
    IF (pa.alias_pool_cd > 0)
     orders->ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     orders->ssn = pa.alias
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=finnbr_cd)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->fnbr = ea.alias
    ENDIF
   ENDIF
  WITH outerjoin = d1, dontcare = pa, outerjoin = d2,
   dontcare = ea, outerjoin = d3, nocounter
 ;end select
 IF (retrieve_allergy_info=1)
  SET code_set = 12025
  SET cdf_meaning = "ACTIVE"
  EXECUTE cpm_get_cd_for_cdf
  SET active_status_cd = code_value
  SELECT INTO "NL:"
   a.allergy_id, a.allergy_instance_id, n.nomenclature_id
   FROM allergy a,
    nomenclature n
   PLAN (a
    WHERE (a.person_id=request->person_id)
     AND a.active_ind=1
     AND a.reaction_status_cd=active_status_cd)
    JOIN (n
    WHERE n.nomenclature_id=a.substance_nom_id)
   ORDER BY a.allergy_instance_id
   HEAD a.allergy_instance_id
    orders->allergy_cnt = (orders->allergy_cnt+ 1)
    IF ((orders->allergy_cnt > size(orders->aqual,5)))
     stat = alterlist(orders->aqual,(orders->allergy_cnt+ 5))
    ENDIF
    orders->aqual[orders->allergy_cnt].allergy_display = a.substance_ftdesc
    IF (n.source_string > " ")
     orders->aqual[orders->allergy_cnt].allergy_display = n.source_string
    ENDIF
   FOOT REPORT
    stat = alterlist(orders->aqual[orders->allergy_cnt],orders->allergy_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (retrieve_diag_info=1)
  SELECT INTO "NL:"
   d.diagnosis_id, n.nomenclature_id
   FROM diagnosis d,
    nomenclature n
   PLAN (d
    WHERE (d.encntr_id=request->order_qual[1].encntr_id))
    JOIN (n
    WHERE n.nomenclature_id=d.nomenclature_id)
   DETAIL
    orders->diag_cnt = (orders->diag_cnt+ 1)
    IF ((orders->diag_cnt > size(orders->dqual,5)))
     stat = alterlist(orders->dqual,(orders->diag_cnt+ 5))
    ENDIF
    orders->dqual[orders->diag_cnt].diag_display = d.diag_ftdesc
    IF (n.source_string > " ")
     orders->dqual[orders->diag_cnt].diag_display = n.source_string
    ENDIF
   FOOT REPORT
    stat = alterlist(orders->dqual[orders->diag_cnt],orders->diag_cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (retrieve_phone_addr_info=1)
  SET code_set = 43
  SET cdf_meaning = "HOME"
  EXECUTE cpm_get_cd_for_cdf
  SET home_phone_cd = code_value
  SET code_set = 212
  SET cdf_meaning = "HOME"
  EXECUTE cpm_get_cd_for_cdf
  SET home_address_cd = code_value
  SELECT INTO "nl:"
   p.person_id, a.address_id, ph.phone_id
   FROM person p,
    (dummyt d1  WITH seq = 1),
    address a,
    phone ph
   PLAN (p
    WHERE (p.person_id=request->person_id))
    JOIN (d1)
    JOIN (a
    WHERE a.parent_entity_id=p.person_id
     AND a.parent_entity_name="PERSON"
     AND a.address_type_cd=home_address_cd
     AND a.active_ind=1
     AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (ph
    WHERE ph.parent_entity_id=p.person_id
     AND ph.parent_entity_name="PERSON"
     AND ph.phone_type_cd=home_phone_cd
     AND ph.active_ind=1
     AND ph.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ph.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   DETAIL
    orders->street = trim(a.street_addr), orders->city_state_zip = concat(trim(a.city),", ",trim(a
      .state),"  ",trim(a.zipcode))
    IF (ph.phone_type_cd=home_phone_cd)
     IF (ph.phone_format_cd > 0)
      orders->hphone = cnvtphone(trim(ph.phone_num),ph.phone_format_cd)
     ELSE
      orders->hphone = trim(ph.phone_num)
     ENDIF
    ENDIF
   WITH nocounter, outerjoin = d1, dontcare = a
  ;end select
 ENDIF
 IF (retrieve_ocf_results=1)
  SET pt_weight = fillstring(25," ")
  SET pt_height = fillstring(25," ")
  SET pt_transport_mode = fillstring(25," ")
  SET pt_precautions = fillstring(100," ")
  SET pt_allergies = fillstring(100," ")
  FREE SET clinattr
  RECORD clinattr(
    1 allergy_cnt = i2
    1 aqual[*]
      2 allergy_display = vc
    1 prec_cnt = i2
    1 pqual[*]
      2 prec_display = vc
  )
  SET clinattr->allergy_cnt = 0
  SET clinattr->prec_cnt = 0
  SELECT INTO "nl"
   c.clinical_event_id, c.event_cd, c.event_end_dt_tm
   FROM clinical_event c
   PLAN (c
    WHERE (c.person_id=request->person_id)
     AND (c.encntr_id=request->order_qual[1].encntr_id)
     AND c.view_level=1
     AND c.publish_flag=1
     AND c.event_cd IN (710741, 710750, 62616)
     AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00"))
   ORDER BY c.event_cd, c.event_end_dt_tm DESC
   HEAD REPORT
    hght_ind = 0, wght_ind = 0, trm_ind = 0
   HEAD c.event_cd
    all_ind = 0, all_last_ind = 0, prec_ind = 0,
    prec_last_ind = 0
    IF (c.event_cd=710750
     AND hght_ind=0)
     pt_height = concat(trim(c.event_tag)," cm"), hght_ind = 1
    ELSEIF (c.event_cd=710741
     AND wght_ind=0)
     pt_weight = concat(trim(c.event_tag)," kg"), wght_ind = 1
    ELSEIF (c.event_cd=62616
     AND trm_ind=0)
     pt_transport_mode = trim(c.event_tag), trm_ind = 1
    ENDIF
   HEAD c.event_end_dt_tm
    IF (all_ind=1)
     all_last_ind = 1
    ENDIF
    IF (prec_ind=1)
     prec_last_ind = 1
    ENDIF
   DETAIL
    IF (c.event_cd IN (62610, 62611, 62589, 62612))
     IF (all_last_ind=0)
      clinattr->allergy_cnt = (clinattr->allergy_cnt+ 1), stat = alterlist(clinattr->aqual,clinattr->
       allergy_cnt), clinattr->aqual[clinattr->allergy_cnt].allergy_display = trim(c.event_tag),
      all_ind = 1
     ENDIF
    ELSEIF (c.event_cd IN (710741, 710750, 62616))
     IF (prec_last_ind=0)
      clinattr->prec_cnt = (clinattr->prec_cnt+ 1), stat = alterlist(clinattr->pqual,clinattr->
       prec_cnt), clinattr->pqual[clinattr->prec_cnt].prec_display = trim(c.event_tag),
      prec_ind = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET provider = fillstring(10," ")
 SET signed = fillstring(27," ")
 SELECT INTO "nl:"
  o.order_id, oa.order_id, p.person_id,
  p.position_cd, p2.person_id, p2.position_cd,
  o.current_start_dt_tm
  FROM orders o,
   order_action oa,
   prsnl p,
   prsnl p2,
   (dummyt d1  WITH seq = value(num_of_orders))
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND oa.action_sequence=o.last_action_sequence)
   JOIN (p
   WHERE oa.action_personnel_id=p.person_id)
   JOIN (p2
   WHERE oa.order_provider_id=p2.person_id)
  ORDER BY o.current_start_dt_tm
  HEAD REPORT
   orders->order_location = trim(uar_get_code_display(oa.order_locn_cd))
  HEAD o.order_id
   provider = cnvtstring(cnvtint(oa.order_provider_id)), signed = format(o.orig_order_dt_tm,
    "MM/DD/YYYY HH:MM;;d"), orders->qual[d1.seq].order_id = o.order_id,
   orders->qual[d1.seq].order_mnemonic = o.hna_order_mnemonic, orders->qual[d1.seq].oe_format_id = o
   .oe_format_id, orders->qual[d1.seq].template_order_flag = o.template_order_flag,
   orders->qual[d1.seq].current_start_dt_tm = o.current_start_dt_tm, orders->qual[d1.seq].updt_dt_tm
    = o.updt_dt_tm, orders->qual[d1.seq].active_status_dt_tm = o.active_status_dt_tm,
   orders->qual[d1.seq].action_type_cd = oa.action_type_cd, temp_action = trim(uar_get_code_meaning(
     oa.action_type_cd))
   IF (temp_action="ORDER")
    orders->qual[d1.seq].special_action_ind = 0
   ELSE
    orders->qual[d1.seq].special_action_ind = 1
   ENDIF
   orders->qual[d1.seq].action = trim(uar_get_code_display(oa.action_type_cd)), orders->qual[d1.seq].
   catalog_type = trim(uar_get_code_display(o.catalog_type_cd)), orders->qual[d1.seq].catalog_type_cd
    = o.catalog_type_cd,
   orders->qual[d1.seq].action_prsnl_name = trim(p.name_full_formatted), orders->qual[d1.seq].
   action_dt_tm = oa.action_dt_tm, orders->qual[d1.seq].action_sequence = oa.action_sequence,
   orders->qual[d1.seq].order_provider_name = trim(p2.name_full_formatted), comment_cnt = 0
   IF (o.order_comment_ind=1)
    orders->qual[d1.seq].comments_ind = "T"
   ELSE
    orders->qual[d1.seq].comments_ind = "F"
   ENDIF
   IF (oa.action_type_cd=order_code
    AND (orders->qual[d1.seq].template_order_flag != 2))
    orders->qual[d1.seq].display_ind = 1, orders->spoolout_ind = 1
   ELSE
    orders->qual[d1.seq].display_ind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET cd = 0
 SELECT INTO "nl:"
  od.order_id, oef.oe_field_id, od.action_sequence
  FROM order_detail od,
   oe_format_fields oef,
   (dummyt d1  WITH seq = value(num_of_orders))
  PLAN (d1)
   JOIN (od
   WHERE (orders->qual[d1.seq].order_id=od.order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=orders->qual[d1.seq].oe_format_id)
    AND ((oef.oe_field_id+ 0)=od.oe_field_id))
  ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   orders->qual[d1.seq].detail_cnt = 0
  HEAD od.order_id
   stat = alterlist(orders->qual[d1.seq].detail_qual,5), orders->qual[d1.seq].stat_ind = 0
  HEAD od.oe_field_id
   act_seq = od.action_sequence, odflag = 1
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    odflag = 0
   ENDIF
  DETAIL
   IF (odflag=1)
    orders->qual[d1.seq].detail_cnt = (orders->qual[d1.seq].detail_cnt+ 1), dc = orders->qual[d1.seq]
    .detail_cnt
    IF (dc > size(orders->qual[d1.seq].detail_qual,5))
     stat = alterlist(orders->qual[d1.seq].detail_qual,(dc+ 5))
    ENDIF
    orders->qual[d1.seq].detail_qual[dc].label_text = trim(oef.label_text), orders->qual[d1.seq].
    detail_qual[dc].field_id = od.oe_field_id, orders->qual[d1.seq].detail_qual[dc].field_value = od
    .oe_field_value,
    orders->qual[d1.seq].detail_qual[dc].print_ind = 0, orders->qual[d1.seq].detail_qual[dc].
    group_seq = oef.group_seq, orders->qual[d1.seq].detail_qual[dc].oe_field_meaning_id = od
    .oe_field_meaning_id,
    orders->qual[d1.seq].detail_qual[dc].display_value = trim(od.oe_field_display_value)
    IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od.oe_field_meaning_id=
    127) OR (od.oe_field_meaning_id=43)) )) ))
     AND trim(cnvtupper(od.oe_field_display_value))="STAT")
     orders->qual[d1.seq].stat_ind = 1
    ENDIF
   ENDIF
  FOOT  od.order_id
   stat = alterlist(orders->qual[d1.seq].detail_qual,dc)
  WITH nocounter
 ;end select
 IF (retrieve_accession_info=1)
  SELECT INTO "NL:"
   aor.order_id
   FROM accession_order_r aor,
    (dummyt d1  WITH seq = value(num_of_orders))
   PLAN (d1)
    JOIN (aor
    WHERE (aor.order_id=request->order_qual[x].order_id))
   DETAIL
    orders->qual[d1.seq].accession = aor.accession
   WITH nocounter
  ;end select
 ENDIF
 SET b_linefeed = concat(char(10))
 SET row_cnt = 0
 FOR (cqual = 1 TO value(num_of_orders))
   IF ((orders->qual[cqual].comments_ind="T"))
    SELECT INTO "nl:"
     lt.long_text
     FROM long_text lt,
      order_comment oc
     PLAN (oc
      WHERE (oc.order_id=orders->qual[cqual].order_id))
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     DETAIL
      b_cc = 1, orders->qual[cqual].comment_cnt = 0, b_s = 1
      WHILE (b_cc)
        b_tmp_comment = substring(b_s,80,lt.long_text), b_e = findstring(b_linefeed,b_tmp_comment,1)
        IF (b_e)
         orders->qual[cqual].comment_cnt = (orders->qual[cqual].comment_cnt+ 1), tmp_var = orders->
         qual[cqual].comment_cnt, stat = alterlist(orders->qual[cqual].comment_qual,tmp_var),
         orders->qual[cqual].comment_qual[tmp_var].comment_text = substring(1,b_e,b_tmp_comment), b_s
          = (b_s+ b_e)
        ELSE
         IF (b_tmp_comment > " ")
          orders->qual[cqual].comment_cnt = (orders->qual[cqual].comment_cnt+ 1), tmp_var = orders->
          qual[cqual].comment_cnt, stat = alterlist(orders->qual[cqual].comment_qual,tmp_var),
          t_cc = 1, t_l = 80
          WHILE (t_cc)
            tstr = substring(t_l,1,b_tmp_comment)
            IF (tstr=" ")
             t_cc = 0
            ENDIF
            t_l = (t_l - 1)
            IF (t_l=1)
             t_cc = 0, t_l = 60
            ENDIF
          ENDWHILE
          orders->qual[cqual].comment_qual[tmp_var].comment_text = substring(1,t_l,b_tmp_comment),
          b_s = (b_s+ t_l), row_cnt = (row_cnt+ 1)
         ELSE
          b_cc = 0
         ENDIF
        ENDIF
      ENDWHILE
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF ((orders->spoolout_ind=1))
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq","_",new_timedisp),".dat")
  SELECT INTO value(request->printer_name)
   d1.seq
   FROM (dummyt d1  WITH seq = 1)
   PLAN (d1)
   HEAD REPORT
    bc_dio = "{LPI/24}{CPI/8}{BCR/250}{FONT/28/7}", reg3_dio = "{LPI/8}{CPI/21}{FONT/12}", first_page
     = "Y"
   HEAD PAGE
    first_page = "Y", line9 = fillstring(80,"_"), qty = fillstring(10," "),
    pri_cd = fillstring(20," ")
   DETAIL
    FOR (vv = 1 TO value(num_of_orders))
      spoolout = 1
      IF (first_page="N")
       BREAK
      ENDIF
      first_page = "N"
      FOR (fsub = 1 TO 31)
        FOR (ww = 1 TO orders->qual[vv].detail_cnt)
          IF ((((orders->qual[vv].detail_qual[ww].group_seq=fsub)) OR (fsub=31
           AND (orders->qual[vv].detail_qual[ww].print_ind=0))) )
           orders->qual[vv].detail_qual[ww].print_ind = 1
           IF ((orders->qual[vv].detail_qual[ww].field_id=396501))
            qty = orders->qual[vv].detail_qual[ww].display_value
           ELSEIF ((orders->qual[vv].detail_qual[ww].field_id=672158))
            pri_cd = orders->qual[vv].detail_qual[ww].display_value
           ENDIF
          ENDIF
        ENDFOR
      ENDFOR
      reg3_dio, "  ", "{CPI/21}{POS/15/6}",
      orders->name, "{CPI/21}{POS/200/6}",
      CALL print(substring(1,40,orders->qual[vv].order_mnemonic)),
      row + 1, "{CPI/21}{POS/15/16}", orders->fnbr
      IF (substring(41,10,orders->qual[vv].order_mnemonic) > " ")
       "{CPI/21}{POS/75/16}", "Pt Loc: ", orders->location,
       "{CPI/21}{POS/200/16}",
       CALL print(substring(41,40,orders->qual[vv].order_mnemonic)), row + 1
      ELSE
       "{CPI/21}{POS/75/16}", "Pt Loc: ", orders->location,
       row + 1
      ENDIF
      "{CPI/21}{POS/15/26}", "Qty: ", qty,
      "{CPI/21}{POS/75/26}", "Priority: ", pri_cd,
      "{CPI/21}{POS/200/26}", orders->order_location, "{CPI/21}{POS/270/26}",
      pri_cd, row + 1, "{CPI/21}{POS/15/36}",
      orders->qual[vv].order_mnemonic, row + 1
    ENDFOR
   FOOT PAGE
    cur_dt_tm_jul = cnvtdatetime(curdate,curtime2), upd_dt_tm_jul = cnvtdatetime(orders->qual[1].
     updt_dt_tm), dt_tm_dif_min = ((cur_dt_tm_jul - upd_dt_tm_jul)/ 600000000),
    act_st_dt_tm_jul = cnvtdatetime(orders->qual[1].active_status_dt_tm), dt_tm_dif_min2 = ((
    cur_dt_tm_jul - act_st_dt_tm_jul)/ 600000000)
    IF (dt_tm_dif_min > 15)
     IF (dt_tm_dif_min2 > 15)
      "{CPI/21}{POS/20/46}{b}", "*** REPRINT ***", "{CPI/21}{POS/205/46}{b}",
      "*** REPRINT ***"
     ENDIF
    ENDIF
   WITH nocounter, dio = 16, maxcol = 350,
    maxrow = 5
  ;end select
 ENDIF
END GO
