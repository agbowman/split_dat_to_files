CREATE PROGRAM dcpreqgen03:dba
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = c50
 )
 FREE SET orders
 FREE SET allergy
 FREE SET diagnosis
 FREE SET pt
 RECORD orders(
   1 name = vc
   1 pat_type = vc
   1 age = vc
   1 dob = vc
   1 mrn = vc
   1 location = vc
   1 facility = vc
   1 nurse_unit = vc
   1 room = vc
   1 bed = vc
   1 sex = vc
   1 fnbr = vc
   1 med_service = vc
   1 admit_diagnosis = vc
   1 height = vc
   1 height_dt_tm = vc
   1 weight = vc
   1 weight_dt_tm = vc
   1 admit_dt = vc
   1 attending = vc
   1 admitting = vc
   1 order_location = vc
   1 spoolout_ind = i2
   1 cnt = i2
   1 qual[*]
     2 order_id = f8
     2 display_ind = i2
     2 template_order_flag = i2
     2 cs_flag = i2
     2 iv_ind = i2
     2 mnemonic = vc
     2 mnem_ln_cnt = i2
     2 mnem_ln_qual[*]
       3 mnem_line = vc
     2 display_line = vc
     2 disp_ln_cnt = i2
     2 disp_ln_qual[*]
       3 disp_line = vc
     2 order_dt = vc
     2 signed_dt = vc
     2 status = vc
     2 accession = vc
     2 catalog = vc
     2 catalog_type_cd = f8
     2 activity = vc
     2 activity_type_cd = f8
     2 last_action_seq = i4
     2 enter_by = vc
     2 order_dr = vc
     2 type = vc
     2 action = vc
     2 action_type_cd = f8
     2 comment_ind = i2
     2 comment = vc
     2 com_ln_cnt = i2
     2 com_ln_qual[*]
       3 com_line = vc
     2 oe_format_id = f8
     2 clin_line_ind = i2
     2 stat_ind = i2
     2 d_cnt = i2
     2 d_qual[*]
       3 field_description = vc
       3 label_text = vc
       3 value = vc
       3 value_cnt = i2
       3 value_qual[*]
         4 value_line = vc
       3 field_value = f8
       3 oe_field_meaning_id = f8
       3 group_seq = i4
       3 print_ind = i2
       3 clin_line_ind = i2
       3 label = vc
       3 suffix = i2
       3 field_type_flag = i2
     2 priority = vc
     2 req_st_dt = vc
     2 frequency = vc
     2 rate = vc
     2 duration = vc
     2 duration_unit = vc
     2 nurse_collect = vc
     2 fmt_action_cd = f8
 )
 RECORD allergy(
   1 cnt = i2
   1 qual[*]
     2 list = vc
   1 line = vc
   1 line_cnt = i2
   1 line_qual[*]
     2 line = vc
 )
 RECORD diagnosis(
   1 cnt = i2
   1 qual[*]
     2 diag = vc
   1 dline = vc
   1 dline_cnt = i2
   1 dline_qual[*]
     2 dline = vc
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE order_cnt = i4 WITH protect, noconstant(size(request->order_qual,5))
 DECLARE ord_cnt = i4 WITH protect, noconstant(size(request->order_qual,5))
 SET stat = alterlist(orders->qual,order_cnt)
 DECLARE person_id = f8 WITH protect, noconstant(0.0)
 DECLARE encntr_id = f8 WITH protect, noconstant(0.0)
 SET orders->spoolout_ind = 0
 SET pharm_flag = 0
 DECLARE mrn_alias_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE comment_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE fnbr_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE admit_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ADMITDOC"))
 DECLARE attend_doc_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ATTENDDOC"))
 DECLARE canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",12025,"CANCELED"))
 DECLARE inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE pharmacy_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE iv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",16389,"IVSOLUTIONS"))
 DECLARE complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"COMPLETE"))
 DECLARE modify_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE order_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"CANCEL"))
 DECLARE discont_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"DISCONTINUE"))
 DECLARE studactivate_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"STUDACTIVATE"))
 DECLARE activate_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ACTIVATE"))
 DECLARE void_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"VOID"))
 DECLARE suspend_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"SUSPEND"))
 DECLARE resume_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"RESUME"))
 DECLARE intermittent_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3,"000"))
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE daylight = i2 WITH protect, noconstant(0)
 DECLARE saved_pos = i4 WITH protect, noconstant(0)
 DECLARE max_length = i4 WITH protect, noconstant(0)
 DECLARE xcol = i4 WITH protect, noconstant(0)
 DECLARE ycol = i4 WITH protect, noconstant(0)
 DECLARE mnemonic_size = i4 WITH protect, noconstant(0)
 DECLARE mnem_length = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM person p,
   encounter e,
   person_alias pa,
   encntr_alias ea,
   encntr_prsnl_reltn epr,
   prsnl pl,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   encntr_loc_hist elh,
   time_zone_r t
  PLAN (p
   WHERE (p.person_id=request->person_id))
   JOIN (e
   WHERE (e.encntr_id=request->order_qual[1].encntr_id))
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id)
   JOIN (t
   WHERE t.parent_entity_id=outerjoin(elh.loc_facility_cd)
    AND t.parent_entity_name=outerjoin("LOCATION"))
   JOIN (d1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_alias_cd
    AND pa.active_ind=1
    AND pa.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=fnbr_cd
    AND ea.active_ind=1)
   JOIN (d3)
   JOIN (epr
   WHERE epr.encntr_id=e.encntr_id
    AND ((epr.encntr_prsnl_r_cd=admit_doc_cd) OR (epr.encntr_prsnl_r_cd=attend_doc_cd))
    AND epr.active_ind=1)
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  HEAD REPORT
   person_id = p.person_id, encntr_id = e.encntr_id, orders->name = p.name_full_formatted,
   orders->pat_type = trim(uar_get_code_display(e.encntr_type_cd)), orders->sex =
   uar_get_code_display(p.sex_cd), orders->age = cnvtage(p.birth_dt_tm),
   orders->dob = format(datetimezone(p.birth_dt_tm,p.birth_tz,2),"@SHORTDATE"), orders->admit_dt =
   format(e.reg_dt_tm,"@SHORTDATE"), orders->facility = uar_get_code_description(e.loc_facility_cd),
   orders->nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd), orders->room =
   uar_get_code_display(e.loc_room_cd), orders->bed = uar_get_code_display(e.loc_bed_cd),
   orders->location = concat(trim(orders->nurse_unit),"/",trim(orders->room),"/",trim(orders->bed)),
   orders->admit_diagnosis = trim(e.reason_for_visit,3), orders->med_service = uar_get_code_display(e
    .med_service_cd)
  HEAD epr.encntr_prsnl_r_cd
   IF (epr.encntr_prsnl_r_cd=admit_doc_cd)
    orders->admitting = pl.name_full_formatted
   ENDIF
  DETAIL
   IF (pa.person_alias_type_cd=mrn_alias_cd)
    IF (pa.alias_pool_cd > 0)
     orders->mrn = cnvtalias(pa.alias,pa.alias_pool_cd)
    ELSE
     orders->mrn = pa.alias
    ENDIF
   ENDIF
   IF (ea.encntr_alias_type_cd=fnbr_cd)
    IF (ea.alias_pool_cd > 0)
     orders->fnbr = cnvtalias(ea.alias,ea.alias_pool_cd)
    ELSE
     orders->fnbr = ea.alias
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1, dontcare = pa,
   outerjoin = d2, dontcare = ea, outerjoin = d3,
   dontcare = epr
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pl
  PLAN (epr
   WHERE epr.encntr_prsnl_r_cd=attend_doc_cd
    AND (epr.encntr_id=request->order_qual[1].encntr_id)
    AND ((epr.expiration_ind+ 0)=0))
   JOIN (pl
   WHERE pl.person_id=epr.prsnl_person_id)
  ORDER BY epr.active_status_dt_tm
  HEAD REPORT
   orders->attending = pl.name_full_formatted
  DETAIL
   IF ((epr.prsnl_person_id=request->print_prsnl_id))
    orders->attending = pl.name_full_formatted
   ENDIF
 ;end select
 SET height_cd = uar_get_code_by("DISPLAYKEY",72,"CLINICALHEIGHT")
 SET weight_cd = uar_get_code_by("DISPLAYKEY",72,"CLINICALWEIGHT")
 SELECT INTO "nl:"
  FROM clinical_event c
  PLAN (c
   WHERE c.person_id=person_id
    AND c.event_cd IN (height_cd, weight_cd)
    AND c.view_level=1
    AND c.publish_flag=1
    AND c.valid_until_dt_tm=cnvtdatetime("31-DEC-2100,00:00:00")
    AND c.result_status_cd != inerror_cd)
  ORDER BY c.event_end_dt_tm
  DETAIL
   IF (c.event_cd=height_cd)
    orders->height = concat(trim(c.event_tag)," ",trim(uar_get_code_display(c.result_units_cd))),
    orders->height_dt_tm = format(datetimezone(c.updt_dt_tm,c.performed_tz),"@SHORTDATE")
   ELSEIF (c.event_cd=weight_cd)
    orders->weight = concat(trim(c.event_tag)," ",trim(uar_get_code_display(c.result_units_cd))),
    orders->weight_dt_tm = format(datetimezone(c.updt_dt_tm,c.performed_tz),"@SHORTDATE")
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM allergy a,
   (dummyt d  WITH seq = 1),
   nomenclature n
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.active_ind=1
    AND a.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ((a.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (a.end_effective_dt_tm=null))
    AND a.reaction_status_cd != canceled_cd)
   JOIN (d)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
  ORDER BY cnvtdatetime(a.onset_dt_tm)
  HEAD REPORT
   allergy->cnt = 0
  DETAIL
   IF (((size(n.source_string,1) > 0) OR (size(a.substance_ftdesc,1) > 0)) )
    allergy->cnt = (allergy->cnt+ 1), stat = alterlist(allergy->qual,allergy->cnt), allergy->qual[
    allergy->cnt].list = a.substance_ftdesc
    IF (size(n.source_string,1) > 0)
     allergy->qual[allergy->cnt].list = n.source_string
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d, dontcare = n
 ;end select
 FOR (x = 1 TO allergy->cnt)
   IF (x=1)
    SET allergy->line = allergy->qual[x].list
   ELSE
    SET allergy->line = concat(trim(allergy->line),", ",trim(allergy->qual[x].list))
   ENDIF
 ENDFOR
 IF ((allergy->cnt > 0))
  SET pt->line_cnt = 0
  SET max_length = 90
  EXECUTE dcp_parse_text value(allergy->line), value(max_length)
  SET stat = alterlist(allergy->line_qual,pt->line_cnt)
  SET allergy->line_cnt = pt->line_cnt
  FOR (x = 1 TO pt->line_cnt)
    SET allergy->line_qual[x].line = pt->lns[x].line
  ENDFOR
 ENDIF
 SET mnem_disp_level = "1"
 SET iv_disp_level = "0"
 IF (pharm_flag=1)
  SELECT INTO "nl:"
   FROM name_value_prefs n,
    app_prefs a
   PLAN (n
    WHERE n.pvc_name IN ("MNEM_DISP_LEVEL", "IV_DISP_LEVEL"))
    JOIN (a
    WHERE a.app_prefs_id=n.parent_entity_id
     AND a.prsnl_id=0
     AND a.position_cd=0)
   DETAIL
    IF (n.pvc_name="MNEM_DISP_LEVEL"
     AND n.pvc_value IN ("0", "1", "2"))
     mnem_disp_level = n.pvc_value
    ELSEIF (n.pvc_name="IV_DISP_LEVEL"
     AND n.pvc_value IN ("0", "1"))
     iv_disp_level = n.pvc_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 DECLARE oicnt = i4 WITH protect, noconstant(0)
 SET ord_cnt = 0
 SET oicnt = 0
 SET max_length = 70
 SELECT INTO "nl:"
  FROM orders o,
   order_action oa,
   prsnl pl,
   prsnl pl2,
   (dummyt d1  WITH seq = value(order_cnt)),
   (dummyt d2  WITH seq = value(order_cnt)),
   order_ingredient oi
  PLAN (d1)
   JOIN (o
   WHERE (o.order_id=request->order_qual[d1.seq].order_id))
   JOIN (oa
   WHERE oa.order_id=o.order_id
    AND (((request->order_qual[d1.seq].conversation_id > 0)
    AND (oa.order_conversation_id=request->order_qual[d1.seq].conversation_id)) OR ((request->
   order_qual[d1.seq].conversation_id <= 0)
    AND oa.action_sequence=o.last_action_sequence)) )
   JOIN (pl
   WHERE pl.person_id=oa.action_personnel_id)
   JOIN (pl2
   WHERE pl2.person_id=oa.order_provider_id)
   JOIN (d2)
   JOIN (oi
   WHERE o.order_id=oi.order_id
    AND o.last_ingred_action_sequence=oi.action_sequence)
  ORDER BY o.oe_format_id, o.activity_type_cd, o.current_start_dt_tm
  HEAD REPORT
   orders->order_location = trim(uar_get_code_display(oa.order_locn_cd)), mnemonic_size = (size(o
    .hna_order_mnemonic,3) - 1)
  HEAD o.order_id
   ord_cnt = (ord_cnt+ 1), orders->qual[ord_cnt].status = uar_get_code_display(o.order_status_cd),
   orders->qual[ord_cnt].catalog = uar_get_code_display(o.catalog_type_cd),
   orders->qual[ord_cnt].catalog_type_cd = o.catalog_type_cd, orders->qual[ord_cnt].activity =
   uar_get_code_display(o.activity_type_cd), orders->qual[ord_cnt].activity_type_cd = o
   .activity_type_cd,
   orders->qual[ord_cnt].display_line = o.clinical_display_line, orders->qual[ord_cnt].order_id = o
   .order_id, orders->qual[ord_cnt].display_ind = 1,
   orders->qual[ord_cnt].template_order_flag = o.template_order_flag, orders->qual[ord_cnt].cs_flag
    = o.cs_flag, orders->qual[ord_cnt].oe_format_id = o.oe_format_id
   IF (size(substring(245,10,o.clinical_display_line),1) > 0)
    orders->qual[ord_cnt].clin_line_ind = 1
   ELSE
    orders->qual[ord_cnt].clin_line_ind = 0
   ENDIF
   mnem_length = size(trim(o.hna_order_mnemonic),1)
   IF (mnem_length >= mnemonic_size
    AND substring((mnem_length - 3),mnem_length,o.hna_order_mnemonic) != "...")
    orders->qual[ord_cnt].mnemonic = concat(cnvtupper(trim(o.hna_order_mnemonic)),"...")
   ELSE
    orders->qual[ord_cnt].mnemonic = cnvtupper(trim(o.hna_order_mnemonic))
   ENDIF
   IF (curutc > 0)
    orders->qual[ord_cnt].order_dt = concat(format(datetimezone(oa.order_dt_tm,oa.order_tz),
      "@SHORTDATETIME;;Q")," ",datetimezonebyindex(oa.order_tz,offset,daylight,7,oa.order_dt_tm))
   ELSE
    orders->qual[ord_cnt].order_dt = format(datetimezone(oa.order_dt_tm,oa.order_tz),
     "@SHORTDATETIMENOSEC")
   ENDIF
   orders->qual[ord_cnt].signed_dt = format(datetimezone(o.orig_order_dt_tm,o.orig_order_tz),
    "@SHORTDATETIMENOSEC"), orders->qual[ord_cnt].comment_ind = o.order_comment_ind, orders->qual[
   ord_cnt].last_action_seq = o.last_action_sequence,
   orders->qual[ord_cnt].enter_by = pl.name_full_formatted, orders->qual[ord_cnt].order_dr = pl2
   .name_full_formatted, orders->qual[ord_cnt].type = uar_get_code_display(oa.communication_type_cd),
   orders->qual[ord_cnt].action_type_cd = oa.action_type_cd, orders->qual[ord_cnt].action =
   uar_get_code_display(oa.action_type_cd), orders->qual[ord_cnt].iv_ind = o.iv_ind
   IF (o.dcp_clin_cat_cd=iv_cd)
    orders->qual[ord_cnt].iv_ind = 1
   ENDIF
  HEAD oi.comp_sequence
   IF (oi.comp_sequence > 0
    AND o.med_order_type_cd=intermittent_cd)
    IF (oi.ingredient_type_flag=2
     AND oi.clinically_significant_flag=2)
     oicnt = (oicnt+ 1)
    ELSE
     IF (oi.ingredient_type_flag=3)
      oicnt = (oicnt+ 1)
     ENDIF
    ENDIF
   ENDIF
  FOOT  o.order_id
   IF (o.catalog_type_cd=pharmacy_cd)
    IF (((o.iv_ind=1) OR (o.med_order_type_cd=intermittent_cd
     AND oicnt > 1)) )
     IF (iv_disp_level="1")
      mnem_length = size(trim(o.ordered_as_mnemonic),1)
      IF (mnem_length > max_length)
       orders->qual[ord_cnt].mnemonic = trim(concat(substring(1,(max_length - 3),o
          .ordered_as_mnemonic),"..."))
      ELSE
       orders->qual[ord_cnt].mnemonic = o.ordered_as_mnemonic
      ENDIF
     ELSE
      mnem_length = size(trim(o.hna_order_mnemonic),1)
      IF (mnem_length > max_length)
       orders->qual[ord_cnt].mnemonic = trim(concat(substring(1,(max_length - 3),o.hna_order_mnemonic
          ),"..."))
      ELSE
       orders->qual[ord_cnt].mnemonic = o.hna_order_mnemonic
      ENDIF
     ENDIF
    ELSE
     IF (mnem_disp_level="0")
      mnem_length = size(trim(o.hna_order_mnemonic),1)
      IF (mnem_length >= mnemonic_size
       AND substring((mnem_length - 3),mnem_length,o.hna_order_mnemonic) != "...")
       orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"...")
      ELSE
       orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
      ENDIF
     ENDIF
     IF (mnem_disp_level="1")
      IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (size(o.ordered_as_mnemonic,1)=0)) )
       mnem_length = size(trim(o.hna_order_mnemonic),1)
       IF (mnem_length >= mnemonic_size
        AND substring((mnem_length - 3),mnem_length,o.hna_order_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"...")
       ELSE
        orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
       ENDIF
      ELSE
       mnem_length = size(trim(o.hna_order_mnemonic),1)
       IF (mnem_length >= mnemonic_size
        AND substring((mnem_length - 3),mnem_length,o.hna_order_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"...")
       ELSE
        orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
       ENDIF
       mnem_length = size(trim(o.ordered_as_mnemonic),1)
       IF (mnem_length >= mnemonic_size
        AND substring((mnem_length - 3),mnem_length,o.ordered_as_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o
          .ordered_as_mnemonic),"...)")
       ELSE
        orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o
          .ordered_as_mnemonic),")")
       ENDIF
      ENDIF
     ENDIF
     IF (mnem_disp_level="2"
      AND o.iv_ind != 1)
      IF (((o.hna_order_mnemonic=o.ordered_as_mnemonic) OR (size(o.ordered_as_mnemonic,1)=0)) )
       mnem_length = size(trim(o.hna_order_mnemonic),1)
       IF (mnem_length >= mnemonic_size
        AND substring((mnem_length - 3),mnem_length,o.hna_order_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"...")
       ELSE
        orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
       ENDIF
      ELSE
       mnem_length = size(trim(o.hna_order_mnemonic),1)
       IF (mnem_length >= mnemonic_size
        AND substring((mnem_length - 3),mnem_length,o.hna_order_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(trim(o.hna_order_mnemonic),"...")
       ELSE
        orders->qual[ord_cnt].mnemonic = trim(o.hna_order_mnemonic)
       ENDIF
       mnem_length = size(trim(o.ordered_as_mnemonic),1)
       IF (mnem_length >= mnemonic_size
        AND substring((mnem_length - 3),mnem_length,o.ordered_as_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o
          .ordered_as_mnemonic),"...)")
       ELSE
        orders->qual[ord_cnt].mnemonic = concat(orders->qual[ord_cnt].mnemonic,"(",trim(o
          .ordered_as_mnemonic),")")
       ENDIF
      ENDIF
      IF (o.order_mnemonic != o.ordered_as_mnemonic
       AND size(o.order_mnemonic,1) > 0)
       mnem_length = size(trim(o.order_mnemonic),1)
       IF (mnem_length >= mnemonic_size
        AND substring((mnem_length - 3),mnem_length,o.order_mnemonic) != "...")
        orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o
          .order_mnemonic),"...)")
       ELSE
        orders->qual[ord_cnt].mnemonic = concat(trim(orders->qual[ord_cnt].mnemonic),"(",trim(o
          .order_mnemonic),")")
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (oa.action_type_cd IN (order_cd, suspend_cd, resume_cd, cancel_cd, discont_cd,
   void_cd))
    orders->qual[ord_cnt].fmt_action_cd = oa.action_type_cd
   ELSE
    orders->qual[ord_cnt].fmt_action_cd = order_cd
   ENDIF
   IF (oa.action_type_cd IN (order_cd, modify_cd, cancel_cd, discont_cd, activate_cd,
   studactivate_cd)
    AND o.encntr_id > 0
    AND o.template_order_flag != 7)
    orders->qual[ord_cnt].display_ind = 1, orders->spoolout_ind = 1
   ELSE
    orders->qual[ord_cnt].display_ind = 0
   ENDIF
  WITH outerjoin = d2, nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_detail od,
   oe_format_fields oef,
   order_entry_fields of1,
   (dummyt d1  WITH seq = value(order_cnt))
  PLAN (d1)
   JOIN (od
   WHERE (orders->qual[d1.seq].order_id=od.order_id))
   JOIN (oef
   WHERE (oef.oe_format_id=orders->qual[d1.seq].oe_format_id)
    AND (oef.action_type_cd=orders->qual[d1.seq].fmt_action_cd)
    AND oef.oe_field_id=od.oe_field_id)
   JOIN (of1
   WHERE of1.oe_field_id=oef.oe_field_id)
  ORDER BY od.order_id, od.oe_field_id, od.action_sequence DESC
  HEAD REPORT
   orders->qual[d1.seq].d_cnt = 0
  HEAD od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,5), orders->qual[d1.seq].stat_ind = 0
  HEAD od.oe_field_id
   act_seq = od.action_sequence, odflag = 1
   IF (((od.oe_field_meaning="COLLPRI") OR (od.oe_field_meaning="PRIORITY")) )
    orders->qual[d1.seq].priority = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="REQSTARTDTTM")
    orders->qual[d1.seq].req_st_dt = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="FREQ")
    orders->qual[d1.seq].frequency = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="RATE")
    orders->qual[d1.seq].rate = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="DURATION")
    orders->qual[d1.seq].duration = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="DURATIONUNIT")
    orders->qual[d1.seq].duration_unit = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning="NURSECOLLECT")
    orders->qual[d1.seq].nurse_collect = od.oe_field_display_value
   ENDIF
  HEAD od.action_sequence
   IF (act_seq != od.action_sequence)
    odflag = 0
   ENDIF
  DETAIL
   IF (odflag=1)
    orders->qual[d1.seq].d_cnt = (orders->qual[d1.seq].d_cnt+ 1), dc = orders->qual[d1.seq].d_cnt
    IF (dc > size(orders->qual[d1.seq].d_qual,5))
     stat = alterlist(orders->qual[d1.seq].d_qual,(dc+ 5))
    ENDIF
    orders->qual[d1.seq].d_qual[dc].label_text = trim(oef.label_text), orders->qual[d1.seq].d_qual[dc
    ].field_value = od.oe_field_value, orders->qual[d1.seq].d_qual[dc].group_seq = oef.group_seq,
    orders->qual[d1.seq].d_qual[dc].oe_field_meaning_id = od.oe_field_meaning_id, orders->qual[d1.seq
    ].d_qual[dc].value = trim(od.oe_field_display_value,3), orders->qual[d1.seq].d_qual[dc].
    clin_line_ind = oef.clin_line_ind,
    orders->qual[d1.seq].d_qual[dc].label = trim(oef.clin_line_label), orders->qual[d1.seq].d_qual[dc
    ].suffix = oef.clin_suffix_ind, orders->qual[d1.seq].d_qual[dc].field_type_flag = of1
    .field_type_flag
    IF (size(od.oe_field_display_value,1) > 0)
     orders->qual[d1.seq].d_qual[dc].print_ind = 0
    ELSE
     orders->qual[d1.seq].d_qual[dc].print_ind = 1
    ENDIF
    IF (((od.oe_field_meaning_id=1100) OR (((od.oe_field_meaning_id=8) OR (((od.oe_field_meaning_id=
    127) OR (od.oe_field_meaning_id=43)) )) ))
     AND trim(cnvtupper(od.oe_field_display_value),3)="STAT")
     orders->qual[d1.seq].stat_ind = 1
    ENDIF
    IF (of1.field_type_flag=7)
     IF (od.oe_field_value=1)
      IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=1)) )
       orders->qual[d1.seq].d_qual[dc].value = trim(oef.label_text)
      ELSE
       orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
      ENDIF
     ELSE
      IF (((oef.disp_yes_no_flag=0) OR (oef.disp_yes_no_flag=2)) )
       orders->qual[d1.seq].d_qual[dc].value = trim(oef.clin_line_label)
      ELSE
       orders->qual[d1.seq].d_qual[dc].clin_line_ind = 0
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  od.order_id
   stat = alterlist(orders->qual[d1.seq].d_qual,dc)
  WITH nocounter
 ;end select
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].clin_line_ind=1))
    SET started_build_ind = 0
    FOR (fsub = 1 TO 31)
      FOR (xx = 1 TO orders->qual[x].d_cnt)
        IF ((((orders->qual[x].d_qual[xx].group_seq=fsub)) OR (fsub=31))
         AND (orders->qual[x].d_qual[xx].print_ind=0))
         IF ((orders->qual[x].d_qual[xx].clin_line_ind=1))
          IF (started_build_ind=0)
           SET started_build_ind = 1
           IF ((orders->qual[x].d_qual[xx].suffix=0)
            AND size(orders->qual[x].d_qual[xx].label,1) > 0)
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].d_qual[xx].label)," ",trim
             (orders->qual[x].d_qual[xx].value))
           ELSEIF ((orders->qual[x].d_qual[xx].suffix=1)
            AND size(orders->qual[x].d_qual[xx].label,1) > 0)
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].d_qual[xx].value)," ",trim
             (orders->qual[x].d_qual[xx].label))
           ELSE
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].d_qual[xx].value)," ")
           ENDIF
          ELSE
           IF ((orders->qual[x].d_qual[xx].suffix=0)
            AND size(orders->qual[x].d_qual[xx].label,1) > 0)
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].display_line),",",trim(
              orders->qual[x].d_qual[xx].label)," ",trim(orders->qual[x].d_qual[xx].value))
           ELSEIF ((orders->qual[x].d_qual[xx].suffix=1)
            AND size(orders->qual[x].d_qual[xx].label,1) > 0)
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].display_line),",",trim(
              orders->qual[x].d_qual[xx].value)," ",trim(orders->qual[x].d_qual[xx].label))
           ELSE
            SET orders->qual[x].display_line = concat(trim(orders->qual[x].display_line),",",trim(
              orders->qual[x].d_qual[xx].value)," ")
           ENDIF
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
    ENDFOR
   ENDIF
 ENDFOR
 SET max_length = 50
 FOR (x = 1 TO order_cnt)
  IF (size(orders->qual[x].display_line,1) > 0)
   SET pt->line_cnt = 0
   EXECUTE dcp_parse_text value(orders->qual[x].display_line), value(max_length)
   SET stat = alterlist(orders->qual[x].disp_ln_qual,pt->line_cnt)
   SET orders->qual[x].disp_ln_cnt = pt->line_cnt
   FOR (y = 1 TO pt->line_cnt)
     SET orders->qual[x].disp_ln_qual[y].disp_line = pt->lns[y].line
   ENDFOR
  ENDIF
  FOR (ww = 1 TO orders->qual[x].d_cnt)
    IF ((((orders->qual[x].d_qual[ww].field_type_flag=0)) OR ((((orders->qual[x].d_qual[ww].
    field_type_flag=11)) OR (textlen(trim(orders->qual[x].d_qual[ww].value,3)) > max_length)) )) )
     SET pt->line_cnt = 0
     EXECUTE dcp_parse_text value(orders->qual[x].d_qual[ww].value), value(max_length)
     SET stat = alterlist(orders->qual[x].d_qual[ww].value_qual,pt->line_cnt)
     SET orders->qual[x].d_qual[ww].value_cnt = pt->line_cnt
     FOR (y = 1 TO pt->line_cnt)
       SET orders->qual[x].d_qual[ww].value_qual[y].value_line = pt->lns[y].line
     ENDFOR
    ELSE
     SET orders->qual[x].d_qual[ww].value_cnt = 1
    ENDIF
  ENDFOR
 ENDFOR
 FOR (x = 1 TO order_cnt)
   SELECT INTO "nl:"
    FROM accession_order_r aor
    PLAN (aor
     WHERE (aor.order_id=orders->qual[x].order_id))
    DETAIL
     orders->qual[x].accession = aor.accession
    WITH nocounter
   ;end select
 ENDFOR
 SET max_length = 90
 FOR (x = 1 TO order_cnt)
   IF (textlen(orders->qual[x].mnemonic) > 0)
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(orders->qual[x].mnemonic), value(max_length)
    SET stat = alterlist(orders->qual[x].mnem_ln_qual,pt->line_cnt)
    SET orders->qual[x].mnem_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].mnem_ln_qual[y].mnem_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 SET max_length = 120
 FOR (x = 1 TO order_cnt)
   IF ((orders->qual[x].comment_ind=1))
    SELECT INTO "nl:"
     FROM order_comment oc,
      long_text lt
     PLAN (oc
      WHERE (oc.order_id=orders->qual[x].order_id)
       AND oc.comment_type_cd=comment_cd)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
     DETAIL
      orders->qual[x].comment = lt.long_text
     WITH nocounter
    ;end select
    SET pt->line_cnt = 0
    EXECUTE dcp_parse_text value(orders->qual[x].comment), value(max_length)
    SET stat = alterlist(orders->qual[x].com_ln_qual,pt->line_cnt)
    SET orders->qual[x].com_ln_cnt = pt->line_cnt
    FOR (y = 1 TO pt->line_cnt)
      SET orders->qual[x].com_ln_qual[y].com_line = pt->lns[y].line
    ENDFOR
   ENDIF
 ENDFOR
 IF ((orders->spoolout_ind=1))
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:dcpreq","_",new_timedisp),".dat")
  SELECT INTO value(tempfile1a)
   d1.seq
   FROM (dummyt d1  WITH seq = 1)
   PLAN (d1)
   HEAD REPORT
    first_page = "Y", saved_pos = 0
   HEAD PAGE
    "{lpi/8}{cpi/12}{font/8}", "  ", row + 1,
    line1 = fillstring(30,"_"), spaces = fillstring(50," "), "{cpi/12}{pos/1/35}{b}",
    CALL center(orders->facility,1,220), row + 1, "{cpi/14}{pos/40/110}",
    "Pt. Name: ", orders->name, "{cpi/14}{pos/380/110}",
    "Admit Date: ", orders->admit_dt, row + 1,
    "{cpi/14}{pos/40/120}", "Fin #: ", orders->fnbr,
    "{cpi/14}{pos/230/120}", "Med Rec #: ", orders->mrn,
    "{cpi/14}{pos/380/120}", "Ordering Date/Time: ", orders->qual[ord_cnt].signed_dt,
    row + 1, "{cpi/14}{pos/40/130}", "DOB: ",
    orders->dob, "{cpi/14}{pos/150/130}", "Age: ",
    orders->age, "{cpi/14}{pos/230/130}", "Sex: ",
    orders->sex, "{cpi/14}{pos/380/130}", "Admitting Diagnosis: "
    IF (textlen(orders->admit_diagnosis) > 18)
     CALL print(trim(concat(substring(1,15,orders->admit_diagnosis),"..."))), row + 1
    ELSE
     CALL print(orders->admit_diagnosis), row + 1
    ENDIF
    "{cpi/14}{pos/40/140}", "Attending MD: ", orders->attending,
    "{cpi/14}{pos/40/150}", "Height as of ",
    CALL print(trim(orders->height_dt_tm)),
    ": ", orders->height, row + 1,
    "{cpi/14}{pos/380/150}", "Patient Location: ", orders->location,
    row + 1, "{cpi/14}{pos/40/160}", "Weight as of ",
    CALL print(trim(orders->weight_dt_tm)), ": ", orders->weight,
    "{cpi/14}{pos/380/160}", "Patient Type: ", orders->pat_type,
    row + 1, "{cpi/2}{pos/35/190}{b}", line1,
    "{endb}", row + 1
    IF (saved_pos > 0)
     "{cpi/14}{pos/380/140}", "Ordering MD: ", orders->qual[saved_pos].order_dr
     IF (cnvtupper(orders->qual[saved_pos].action) IN ("CANCEL", "DISCONTINUE"))
      "{cpi/12}{pos/155/220}{b}",
      CALL print(cnvtupper(orders->qual[saved_pos].action)), " REQUISITION   ",
      "{cpi/13}", "Discontinued date/time: ", orders->qual[saved_pos].order_dt,
      row + 1
     ELSE
      "{cpi/10}{pos/1/220}{b}",
      CALL center(build(cnvtupper(orders->qual[saved_pos].action)," REQUISITION"),1,275)
     ENDIF
     "{cpi/12}{pos/40/250}", "Orderable: ", "{cpi/12}{pos/212/250}{b}",
     orders->qual[saved_pos].mnemonic, "{endb}", saved_pos = 0
    ENDIF
   DETAIL
    FOR (vv = 1 TO value(ord_cnt))
      IF ((orders->qual[vv].display_ind=1))
       spoolout = 1
       IF (first_page="N")
        BREAK
       ENDIF
       first_page = "N", "{cpi/14}{pos/380/140}", "Ordering MD: ",
       orders->qual[vv].order_dr
       IF (cnvtupper(orders->qual[vv].action) IN ("CANCEL", "DISCONTINUE"))
        "{cpi/12}{pos/155/220}{b}",
        CALL print(cnvtupper(orders->qual[vv].action)), " REQUISITION   ",
        "{cpi/13}", "Discontinued date/time: ", orders->qual[vv].order_dt,
        row + 1
       ELSE
        "{cpi/10}{pos/1/220}{b}",
        CALL center(build(cnvtupper(orders->qual[vv].action)," REQUISITION"),1,275)
       ENDIF
       "{cpi/12}{pos/40/250}", "Orderable: ", "{cpi/12}{pos/212/250}{b}",
       orders->qual[vv].mnemonic, "{endb}", xcol = 40,
       ycol = 270
       FOR (fsub = 1 TO 31)
         FOR (ww = 1 TO orders->qual[vv].d_cnt)
          IF ((((orders->qual[vv].d_qual[ww].group_seq=fsub)) OR (fsub=31
           AND (orders->qual[vv].d_qual[ww].print_ind=0))) )
           orders->qual[vv].d_qual[ww].print_ind = 1
           IF (textlen(trim(orders->qual[vv].d_qual[ww].value,3)) > 0)
            "{cpi/12}",
            CALL print(calcpos(xcol,ycol)),
            CALL print(orders->qual[vv].d_qual[ww].label_text),
            "  ", row + 1, xcol = 212
            IF (textlen(orders->qual[vv].d_qual[ww].label_text) > 36)
             ycol = (ycol+ 12)
            ENDIF
            IF ((orders->qual[vv].d_qual[ww].value_cnt > 1))
             FOR (dsub = 1 TO orders->qual[vv].d_qual[ww].value_cnt)
               CALL print(calcpos(xcol,ycol)), "{b}", orders->qual[vv].d_qual[ww].value_qual[dsub].
               value_line,
               "{endb}", row + 1, ycol = (ycol+ 12)
               IF (ycol > 680
                AND (dsub < orders->qual[vv].d_qual[ww].value_cnt))
                CALL print(calcpos(xcol,ycol)), "{b}", "**Continued on next page**",
                "{endb}", saved_pos = vv, BREAK,
                xcol = 40, ycol = 270, "{CPI/12}",
                CALL print(calcpos(xcol,ycol)),
                CALL print(concat(orders->qual[vv].d_qual[ww].label_text," cont. ")), xcol = 212
                IF (textlen(orders->qual[vv].d_qual[ww].label_text) > 36)
                 ycol = (ycol+ 12)
                ENDIF
               ENDIF
             ENDFOR
            ELSE
             CALL print(calcpos(xcol,ycol)), "{b}", orders->qual[vv].d_qual[ww].value,
             "{endb}", row + 1, ycol = (ycol+ 12)
            ENDIF
           ENDIF
           xcol = 40
          ENDIF
          ,
          IF (ycol > 680
           AND (ww < orders->qual[vv].d_cnt))
           saved_pos = vv, BREAK, xcol = 40,
           ycol = 270
          ENDIF
         ENDFOR
       ENDFOR
       IF (ycol > 544)
        saved_pos = vv, BREAK, ycol = 270
       ELSE
        ycol = (ycol+ 12)
       ENDIF
       IF ((orders->qual[vv].comment_ind=1)
        AND (orders->qual[vv].com_ln_cnt > 0))
        xcol = 40,
        CALL print(calcpos(xcol,ycol)), "Comments:  ",
        ycol = (ycol+ 12)
        IF ((orders->qual[vv].com_ln_cnt > 7))
         ocnt = 7
        ELSE
         ocnt = orders->qual[vv].com_ln_cnt
        ENDIF
        FOR (com_cnt = 1 TO ocnt)
          CALL print(calcpos(xcol,ycol)), "{b}", orders->qual[vv].com_ln_qual[com_cnt].com_line,
          "{endb}", row + 1, ycol = (ycol+ 12)
        ENDFOR
        IF ((orders->qual[vv].com_ln_cnt > 7))
         CALL print(calcpos(xcol,ycol)), "{cpi/14}",
         "**** Please check chart for further comments ****",
         row + 1
        ENDIF
       ENDIF
      ENDIF
    ENDFOR
   FOOT PAGE
    print_time = format(datetimezone(cnvtdatetime(curdate,curtime),curtimezoneapp),
     "@SHORTDATETIMENOSEC"), "{cpi/13}{pos/40/720}", "PRINT INITIATED: ",
    print_time, row + 1, "{cpi/13}{pos/255/720}",
    "BY: ", orders->qual[1].enter_by
   WITH nocounter, maxrow = 800, maxcol = 750,
    dio = postscript
  ;end select
  SET spool value(trim(tempfile1a)) value(trim(request->printer_name)) WITH deleted
 ENDIF
#exit_script
 SET last_mod = "025"
END GO
