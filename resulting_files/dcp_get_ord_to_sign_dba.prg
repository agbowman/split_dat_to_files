CREATE PROGRAM dcp_get_ord_to_sign:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 encntr_id = f8
     2 mrn = vc
     2 order_id = f8
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 med_order_type_cd = f8
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 order_comment = vc
     2 clinical_display_line = vc
     2 template_order_flag = i2
     2 order_status_cd = f8
     2 stop_type_cd = f8
     2 projected_stop_dt_tm = dq8
     2 projected_stop_tz = i4
     2 constant_ind = i2
     2 prn_ind = i2
     2 updt_id = f8
     2 updt_prsnl_name = vc
     2 orig_order_dt_tm = dq8
     2 orig_order_tz = i4
     2 action_dt_tm = dq8
     2 action_tz = i4
     2 additive_count_for_ivpb = i4
     2 orderable_type_flag = i4
     2 review_qual_cnt = i4
     2 cki = vc
     2 ref_text_mask = i4
     2 review_qual[*]
       3 review_type_flag = i2
       3 provider_id = f8
       3 location_cd = f8
       3 action_sequence = i4
       3 action_type_cd = f8
       3 action_type = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD order_cmt_array(
   1 qual[*]
     2 order_id = f8
     2 reply_index = i2
 )
 RECORD iv_piggyback(
   1 qual[*]
     2 order_id = f8
     2 reply_index = i2
     2 action_sequence = i4
 )
 DECLARE last_mod = c3 WITH public, noconstant("   ")
 DECLARE script_date = c10 WITH public, noconstant(fillstring(10," "))
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 DECLARE len_cdp = i2 WITH private, noconstant(0)
 DECLARE order_cmt_cnt = i2 WITH public, noconstant(0)
 DECLARE count_ivpb = i2 WITH public, noconstant(0)
 DECLARE encntr_mrn_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE person_mrn_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE ord_cmt_type_cd = f8 WITH public, constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE iv_piggy_back_cd = f8 WITH public, constant(uar_get_code_by("MEANING",18309,"INTERMITTENT"))
 SET reply->qual_cnt = 0
 SET stat = alterlist(reply->qual,10)
 SET reply->status_data.status = "F"
 IF ((request->action_flag=1))
  SET review_flag1 = 1
  SET review_flag2 = 1
 ELSEIF ((request->action_flag=2))
  SET review_flag1 = 2
  SET review_flag2 = 2
 ELSEIF ((request->action_flag=3))
  SET review_flag1 = 4
  SET review_flag2 = 4
 ELSEIF ((request->action_flag=4))
  SET review_flag1 = 2
  SET review_flag2 = 4
 ELSE
  SET review_flag1 = 99
  SET review_flag2 = 99
 ENDIF
 IF ((request->person_id=0))
  IF ((request->action_flag=1))
   SELECT INTO "nl:"
    orv.order_id, o.order_id, oa.order_id,
    p.name_full_formatted
    FROM order_review orv,
     orders o,
     order_action oa,
     person p
    PLAN (orv
     WHERE (orv.location_cd=request->location_cd)
      AND orv.review_type_flag=1
      AND orv.reviewed_status_flag=0)
     JOIN (o
     WHERE o.order_id=orv.order_id)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_sequence=orv.action_sequence)
     JOIN (p
     WHERE p.person_id=o.person_id)
    ORDER BY p.name_full_formatted
    DETAIL
     reply->qual_cnt = (reply->qual_cnt+ 1)
     IF ((reply->qual_cnt > size(reply->qual,5)))
      stat = alterlist(reply->qual,(reply->qual_cnt+ 10))
     ENDIF
     reply->qual[reply->qual_cnt].person_id = p.person_id, reply->qual[reply->qual_cnt].
     name_full_formatted = p.name_full_formatted, reply->qual[reply->qual_cnt].encntr_id = o
     .encntr_id,
     reply->qual[reply->qual_cnt].order_id = o.order_id, reply->qual[reply->qual_cnt].order_mnemonic
      = o.order_mnemonic, reply->qual[reply->qual_cnt].hna_order_mnemonic = o.hna_order_mnemonic,
     reply->qual[reply->qual_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->qual[reply->
     qual_cnt].catalog_cd = o.catalog_cd, reply->qual[reply->qual_cnt].catalog_type_cd = o
     .catalog_type_cd,
     reply->qual[reply->qual_cnt].clinical_display_line = trim(oa.clinical_display_line), len_cdp =
     textlen(reply->qual[reply->qual_cnt].clinical_display_line)
     IF (len_cdp >= 252)
      stat = movestring("...",1,reply->qual[reply->qual_cnt].clinical_display_line,(len_cdp - 2),3)
     ENDIF
     reply->qual[reply->qual_cnt].template_order_flag = o.template_order_flag, reply->qual[reply->
     qual_cnt].order_status_cd = o.order_status_cd, reply->qual[reply->qual_cnt].stop_type_cd = o
     .stop_type_cd,
     reply->qual[reply->qual_cnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->qual[reply->
     qual_cnt].projected_stop_tz = o.projected_stop_tz, reply->qual[reply->qual_cnt].constant_ind = o
     .constant_ind,
     reply->qual[reply->qual_cnt].prn_ind = o.prn_ind, reply->qual[reply->qual_cnt].med_order_type_cd
      = o.med_order_type_cd, reply->qual[reply->qual_cnt].orderable_type_flag = o.orderable_type_flag,
     reply->qual[reply->qual_cnt].updt_id = orv.updt_id, reply->qual[reply->qual_cnt].
     orig_order_dt_tm = o.orig_order_dt_tm, reply->qual[reply->qual_cnt].orig_order_tz = o
     .orig_order_tz,
     reply->qual[reply->qual_cnt].action_dt_tm = oa.action_dt_tm, reply->qual[reply->qual_cnt].
     action_tz = oa.action_tz, reply->qual[reply->qual_cnt].cki = o.cki,
     reply->qual[reply->qual_cnt].ref_text_mask = o.ref_text_mask, reply->qual[reply->qual_cnt].
     review_qual_cnt = 1, stat = alterlist(reply->qual[reply->qual_cnt].review_qual,1),
     reply->qual[reply->qual_cnt].review_qual[1].review_type_flag = orv.review_type_flag, reply->
     qual[reply->qual_cnt].review_qual[1].provider_id = orv.provider_id, reply->qual[reply->qual_cnt]
     .review_qual[1].location_cd = orv.location_cd,
     reply->qual[reply->qual_cnt].review_qual[1].action_sequence = orv.action_sequence, reply->qual[
     reply->qual_cnt].review_qual[1].action_type_cd = oa.action_type_cd, reply->qual[reply->qual_cnt]
     .review_qual[1].action_type = trim(uar_get_code_display(oa.action_type_cd))
     IF (band(o.comment_type_mask,1)=1)
      order_cmt_cnt = (order_cmt_cnt+ 1)
      IF (order_cmt_cnt > size(order_cmt_array->qual,5))
       stat = alterlist(order_cmt_array->qual,(order_cmt_cnt+ 5))
      ENDIF
      order_cmt_array->qual[order_cmt_cnt].order_id = o.order_id, order_cmt_array->qual[order_cmt_cnt
      ].reply_index = reply->qual_cnt
     ENDIF
     IF (o.med_order_type_cd=iv_piggy_back_cd)
      count_ivpb = (count_ivpb+ 1)
      IF (count_ivpb > size(iv_piggyback->qual,5))
       stat = alterlist(iv_piggyback->qual,(count_ivpb+ 5))
      ENDIF
      iv_piggyback->qual[count_ivpb].order_id = o.order_id, iv_piggyback->qual[count_ivpb].
      reply_index = reply->qual_cnt, iv_piggyback->qual[count_ivpb].action_sequence = o
      .last_ingred_action_sequence
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    orv.order_id, o.order_id, oa.order_id,
    p.name_full_formatted
    FROM order_review orv,
     orders o,
     order_action oa,
     person p
    PLAN (orv
     WHERE (orv.provider_id=request->prsnl_id)
      AND ((orv.review_type_flag=review_flag1) OR (orv.review_type_flag=review_flag2))
      AND orv.reviewed_status_flag=0)
     JOIN (o
     WHERE o.order_id=orv.order_id)
     JOIN (oa
     WHERE oa.order_id=o.order_id
      AND oa.action_sequence=orv.action_sequence)
     JOIN (p
     WHERE p.person_id=o.person_id)
    ORDER BY p.name_full_formatted
    DETAIL
     reply->qual_cnt = (reply->qual_cnt+ 1)
     IF ((reply->qual_cnt > size(reply->qual,5)))
      stat = alterlist(reply->qual,(reply->qual_cnt+ 10))
     ENDIF
     reply->qual[reply->qual_cnt].person_id = p.person_id, reply->qual[reply->qual_cnt].
     name_full_formatted = p.name_full_formatted, reply->qual[reply->qual_cnt].encntr_id = o
     .encntr_id,
     reply->qual[reply->qual_cnt].order_id = o.order_id, reply->qual[reply->qual_cnt].order_mnemonic
      = o.order_mnemonic, reply->qual[reply->qual_cnt].hna_order_mnemonic = o.hna_order_mnemonic,
     reply->qual[reply->qual_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->qual[reply->
     qual_cnt].catalog_cd = o.catalog_cd, reply->qual[reply->qual_cnt].catalog_type_cd = o
     .catalog_type_cd,
     reply->qual[reply->qual_cnt].clinical_display_line = trim(oa.clinical_display_line), len_cdp =
     textlen(reply->qual[reply->qual_cnt].clinical_display_line)
     IF (len_cdp >= 252)
      stat = movestring("...",1,reply->qual[reply->qual_cnt].clinical_display_line,(len_cdp - 2),3)
     ENDIF
     reply->qual[reply->qual_cnt].template_order_flag = o.template_order_flag, reply->qual[reply->
     qual_cnt].order_status_cd = o.order_status_cd, reply->qual[reply->qual_cnt].stop_type_cd = o
     .stop_type_cd,
     reply->qual[reply->qual_cnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->qual[reply->
     qual_cnt].projected_stop_tz = o.projected_stop_tz, reply->qual[reply->qual_cnt].constant_ind = o
     .constant_ind,
     reply->qual[reply->qual_cnt].prn_ind = o.prn_ind, reply->qual[reply->qual_cnt].med_order_type_cd
      = o.med_order_type_cd, reply->qual[reply->qual_cnt].orderable_type_flag = o.orderable_type_flag,
     reply->qual[reply->qual_cnt].updt_id = orv.updt_id, reply->qual[reply->qual_cnt].
     orig_order_dt_tm = o.orig_order_dt_tm, reply->qual[reply->qual_cnt].orig_order_tz = o
     .orig_order_tz,
     reply->qual[reply->qual_cnt].action_dt_tm = oa.action_dt_tm, reply->qual[reply->qual_cnt].
     action_tz = oa.action_tz, reply->qual[reply->qual_cnt].cki = o.cki,
     reply->qual[reply->qual_cnt].ref_text_mask = o.ref_text_mask, reply->qual[reply->qual_cnt].
     review_qual_cnt = 1, stat = alterlist(reply->qual[reply->qual_cnt].review_qual,1),
     reply->qual[reply->qual_cnt].review_qual[1].review_type_flag = orv.review_type_flag, reply->
     qual[reply->qual_cnt].review_qual[1].provider_id = orv.provider_id, reply->qual[reply->qual_cnt]
     .review_qual[1].location_cd = orv.location_cd,
     reply->qual[reply->qual_cnt].review_qual[1].action_sequence = orv.action_sequence, reply->qual[
     reply->qual_cnt].review_qual[1].action_type_cd = oa.action_type_cd, reply->qual[reply->qual_cnt]
     .review_qual[1].action_type = trim(uar_get_code_display(oa.action_type_cd))
     IF (band(o.comment_type_mask,1)=1)
      order_cmt_cnt = (order_cmt_cnt+ 1)
      IF (order_cmt_cnt > size(order_cmt_array->qual,5))
       stat = alterlist(order_cmt_array->qual,(order_cmt_cnt+ 5))
      ENDIF
      order_cmt_array->qual[order_cmt_cnt].order_id = o.order_id, order_cmt_array->qual[order_cmt_cnt
      ].reply_index = reply->qual_cnt
     ENDIF
     IF (o.med_order_type_cd=iv_piggy_back_cd)
      count_ivpb = (count_ivpb+ 1)
      IF (count_ivpb > size(iv_piggyback->qual,5))
       stat = alterlist(iv_piggyback->qual,(count_ivpb+ 5))
      ENDIF
      iv_piggyback->qual[count_ivpb].order_id = o.order_id, iv_piggyback->qual[count_ivpb].
      reply_index = reply->qual_cnt, iv_piggyback->qual[count_ivpb].action_sequence = o
      .last_ingred_action_sequence
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
  FOR (i = 1 TO reply->qual_cnt)
   SELECT
    ea.alias
    FROM encntr_alias ea
    WHERE (ea.encntr_id=reply->qual[i].encntr_id)
     AND ea.encntr_alias_type_cd=encntr_alias_type_cd
    DETAIL
     reply->qual[i].mrn = ea.alias
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SELECT
     pa.alias
     FROM person_alias pa
     WHERE (pa.person_id=reply->qual[i].person_id)
      AND pa.person_alias_type_cd=person_alias_type_cd
     DETAIL
      reply->qual[i].mrn = pa.alias
     WITH nocounter
    ;end select
   ENDIF
  ENDFOR
  GO TO load_details
 ENDIF
 IF ((request->person_id > 0)
  AND (request->encntr_id=0))
  SELECT INTO "nl:"
   o.order_id, oa.order_id, p.name_full_formatted,
   orv.order_id
   FROM order_review orv,
    orders o,
    order_action oa,
    person p
   PLAN (o
    WHERE (o.person_id=request->person_id))
    JOIN (orv
    WHERE orv.order_id=o.order_id
     AND ((orv.review_type_flag=review_flag1) OR (orv.review_type_flag=review_flag2))
     AND orv.reviewed_status_flag=0)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_sequence=orv.action_sequence)
    JOIN (p
    WHERE p.person_id=o.person_id)
   ORDER BY p.name_full_formatted
   DETAIL
    reply->qual_cnt = (reply->qual_cnt+ 1)
    IF ((reply->qual_cnt > size(reply->qual,5)))
     stat = alterlist(reply->qual,(reply->qual_cnt+ 10))
    ENDIF
    reply->qual[reply->qual_cnt].person_id = p.person_id, reply->qual[reply->qual_cnt].
    name_full_formatted = p.name_full_formatted, reply->qual[reply->qual_cnt].encntr_id = o.encntr_id,
    reply->qual[reply->qual_cnt].order_id = o.order_id, reply->qual[reply->qual_cnt].order_mnemonic
     = o.order_mnemonic, reply->qual[reply->qual_cnt].hna_order_mnemonic = o.hna_order_mnemonic,
    reply->qual[reply->qual_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->qual[reply->
    qual_cnt].catalog_cd = o.catalog_cd, reply->qual[reply->qual_cnt].catalog_type_cd = o
    .catalog_type_cd,
    reply->qual[reply->qual_cnt].clinical_display_line = trim(oa.clinical_display_line), len_cdp =
    textlen(reply->qual[reply->qual_cnt].clinical_display_line)
    IF (len_cdp >= 252)
     stat = movestring("...",1,reply->qual[reply->qual_cnt].clinical_display_line,(len_cdp - 2),3)
    ENDIF
    reply->qual[reply->qual_cnt].template_order_flag = o.template_order_flag, reply->qual[reply->
    qual_cnt].order_status_cd = o.order_status_cd, reply->qual[reply->qual_cnt].stop_type_cd = o
    .stop_type_cd,
    reply->qual[reply->qual_cnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->qual[reply->
    qual_cnt].projected_stop_tz = o.projected_stop_tz, reply->qual[reply->qual_cnt].constant_ind = o
    .constant_ind,
    reply->qual[reply->qual_cnt].prn_ind = o.prn_ind, reply->qual[reply->qual_cnt].med_order_type_cd
     = o.med_order_type_cd, reply->qual[reply->qual_cnt].orderable_type_flag = o.orderable_type_flag,
    reply->qual[reply->qual_cnt].updt_id = orv.updt_id, reply->qual[reply->qual_cnt].orig_order_dt_tm
     = o.orig_order_dt_tm, reply->qual[reply->qual_cnt].orig_order_tz = o.orig_order_tz,
    reply->qual[reply->qual_cnt].action_dt_tm = oa.action_dt_tm, reply->qual[reply->qual_cnt].
    action_tz = oa.action_tz, reply->qual[reply->qual_cnt].cki = o.cki,
    reply->qual[reply->qual_cnt].ref_text_mask = o.ref_text_mask, reply->qual[reply->qual_cnt].
    review_qual_cnt = 1, stat = alterlist(reply->qual[reply->qual_cnt].review_qual,1),
    reply->qual[reply->qual_cnt].review_qual[1].review_type_flag = orv.review_type_flag, reply->qual[
    reply->qual_cnt].review_qual[1].provider_id = orv.provider_id, reply->qual[reply->qual_cnt].
    review_qual[1].location_cd = orv.location_cd,
    reply->qual[reply->qual_cnt].review_qual[1].action_sequence = orv.action_sequence, reply->qual[
    reply->qual_cnt].review_qual[1].action_type_cd = oa.action_type_cd, reply->qual[reply->qual_cnt].
    review_qual[1].action_type = trim(uar_get_code_display(oa.action_type_cd))
    IF (band(o.comment_type_mask,1)=1)
     order_cmt_cnt = (order_cmt_cnt+ 1)
     IF (order_cmt_cnt > size(order_cmt_array->qual,5))
      stat = alterlist(order_cmt_array->qual,(order_cmt_cnt+ 5))
     ENDIF
     order_cmt_array->qual[order_cmt_cnt].order_id = o.order_id, order_cmt_array->qual[order_cmt_cnt]
     .reply_index = reply->qual_cnt
    ENDIF
    IF (o.med_order_type_cd=iv_piggy_back_cd)
     count_ivpb = (count_ivpb+ 1)
     IF (count_ivpb > size(iv_piggyback->qual,5))
      stat = alterlist(iv_piggyback->qual,(count_ivpb+ 5))
     ENDIF
     iv_piggyback->qual[count_ivpb].order_id = o.order_id, iv_piggyback->qual[count_ivpb].reply_index
      = reply->qual_cnt, iv_piggyback->qual[count_ivpb].action_sequence = o
     .last_ingred_action_sequence
    ENDIF
   WITH nocounter
  ;end select
  GO TO load_details
 ENDIF
 IF ((request->person_id > 0)
  AND (request->encntr_id > 0))
  SELECT INTO "nl:"
   o.order_id, oa.order_id, p.name_full_formatted,
   orv.order_id
   FROM order_review orv,
    orders o,
    order_action oa,
    person p
   PLAN (o
    WHERE (o.encntr_id=request->encntr_id))
    JOIN (orv
    WHERE orv.order_id=o.order_id
     AND ((orv.review_type_flag=review_flag1) OR (orv.review_type_flag=review_flag2))
     AND orv.reviewed_status_flag=0)
    JOIN (oa
    WHERE oa.order_id=o.order_id
     AND oa.action_sequence=orv.action_sequence)
    JOIN (p
    WHERE p.person_id=o.person_id)
   ORDER BY p.name_full_formatted
   DETAIL
    reply->qual_cnt = (reply->qual_cnt+ 1)
    IF ((reply->qual_cnt > size(reply->qual,5)))
     stat = alterlist(reply->qual,(reply->qual_cnt+ 10))
    ENDIF
    reply->qual[reply->qual_cnt].person_id = p.person_id, reply->qual[reply->qual_cnt].
    name_full_formatted = p.name_full_formatted, reply->qual[reply->qual_cnt].encntr_id = o.encntr_id,
    reply->qual[reply->qual_cnt].order_id = o.order_id, reply->qual[reply->qual_cnt].order_mnemonic
     = o.order_mnemonic, reply->qual[reply->qual_cnt].hna_order_mnemonic = o.hna_order_mnemonic,
    reply->qual[reply->qual_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic, reply->qual[reply->
    qual_cnt].catalog_cd = o.catalog_cd, reply->qual[reply->qual_cnt].catalog_type_cd = o
    .catalog_type_cd,
    reply->qual[reply->qual_cnt].clinical_display_line = trim(oa.clinical_display_line), len_cdp =
    textlen(reply->qual[reply->qual_cnt].clinical_display_line)
    IF (len_cdp >= 252)
     stat = movestring("...",1,reply->qual[reply->qual_cnt].clinical_display_line,(len_cdp - 2),3)
    ENDIF
    reply->qual[reply->qual_cnt].template_order_flag = o.template_order_flag, reply->qual[reply->
    qual_cnt].order_status_cd = o.order_status_cd, reply->qual[reply->qual_cnt].stop_type_cd = o
    .stop_type_cd,
    reply->qual[reply->qual_cnt].projected_stop_dt_tm = o.projected_stop_dt_tm, reply->qual[reply->
    qual_cnt].projected_stop_tz = o.projected_stop_tz, reply->qual[reply->qual_cnt].constant_ind = o
    .constant_ind,
    reply->qual[reply->qual_cnt].prn_ind = o.prn_ind, reply->qual[reply->qual_cnt].med_order_type_cd
     = o.med_order_type_cd, reply->qual[reply->qual_cnt].orderable_type_flag = o.orderable_type_flag,
    reply->qual[reply->qual_cnt].updt_id = orv.updt_id, reply->qual[reply->qual_cnt].orig_order_dt_tm
     = o.orig_order_dt_tm, reply->qual[reply->qual_cnt].orig_order_tz = o.orig_order_tz,
    reply->qual[reply->qual_cnt].action_dt_tm = oa.action_dt_tm, reply->qual[reply->qual_cnt].
    action_tz = oa.action_tz, reply->qual[reply->qual_cnt].cki = o.cki,
    reply->qual[reply->qual_cnt].ref_text_mask = o.ref_text_mask, reply->qual[reply->qual_cnt].
    review_qual_cnt = 1, stat = alterlist(reply->qual[reply->qual_cnt].review_qual,1),
    reply->qual[reply->qual_cnt].review_qual[1].review_type_flag = orv.review_type_flag, reply->qual[
    reply->qual_cnt].review_qual[1].provider_id = orv.provider_id, reply->qual[reply->qual_cnt].
    review_qual[1].location_cd = orv.location_cd,
    reply->qual[reply->qual_cnt].review_qual[1].action_sequence = orv.action_sequence, reply->qual[
    reply->qual_cnt].review_qual[1].action_type_cd = oa.action_type_cd, reply->qual[reply->qual_cnt].
    review_qual[1].action_type = trim(uar_get_code_display(oa.action_type_cd))
    IF (band(o.comment_type_mask,1)=1)
     order_cmt_cnt = (order_cmt_cnt+ 1)
     IF (order_cmt_cnt > size(order_cmt_array->qual,5))
      stat = alterlist(order_cmt_array->qual,(order_cmt_cnt+ 5))
     ENDIF
     order_cmt_array->qual[order_cmt_cnt].order_id = o.order_id, order_cmt_array->qual[order_cmt_cnt]
     .reply_index = reply->qual_cnt
    ENDIF
    IF (o.med_order_type_cd=iv_piggy_back_cd)
     count_ivpb = (count_ivpb+ 1)
     IF (count_ivpb > size(iv_piggyback->qual,5))
      stat = alterlist(iv_piggyback->qual,(count_ivpb+ 5))
     ENDIF
     iv_piggyback->qual[count_ivpb].order_id = o.order_id, iv_piggyback->qual[count_ivpb].reply_index
      = reply->qual_cnt, iv_piggyback->qual[count_ivpb].action_sequence = o
     .last_ingred_action_sequence
    ENDIF
   WITH nocounter
  ;end select
  GO TO load_details
 ENDIF
#load_details
 IF (order_cmt_cnt > 0)
  DECLARE seq_flag = i2 WITH public, noconstant(0)
  SELECT INTO "nl:"
   FROM order_comment oc,
    long_text l
   PLAN (oc
    WHERE expand(num,1,order_cmt_cnt,oc.order_id,order_cmt_array->qual[num].order_id)
     AND oc.comment_type_cd=ord_cmt_type_cd)
    JOIN (l
    WHERE l.long_text_id=oc.long_text_id)
   ORDER BY oc.order_id, oc.action_sequence DESC
   HEAD oc.order_id
    seq_flag = 0, pos = locateval(num,1,order_cmt_cnt,oc.order_id,order_cmt_array->qual[num].order_id
     )
   DETAIL
    IF (seq_flag=0)
     reply->qual[order_cmt_array->qual[pos].reply_index].order_comment = l.long_text, seq_flag = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (count_ivpb > 0)
  SELECT INTO "nl:"
   FROM order_ingredient oi
   WHERE expand(num,1,count_ivpb,oi.order_id,iv_piggyback->qual[num].order_id,
    oi.action_sequence,iv_piggyback->qual[num].action_sequence)
    AND oi.ingredient_type_flag=3
   DETAIL
    pos = locateval(num,1,count_ivpb,oi.order_id,iv_piggyback->qual[num].order_id), pos =
    iv_piggyback->qual[pos].reply_index, reply->qual[pos].additive_count_for_ivpb = (reply->qual[pos]
    .additive_count_for_ivpb+ 1)
   WITH nocounter
  ;end select
 ENDIF
 FREE RECORD iv_piggyback
 FREE RECORD order_cmt_array
#exit_script
 IF ((reply->qual_cnt > 0))
  DECLARE x = i4 WITH noconstant(1)
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE expand(num,1,reply->qual_cnt,p.person_id,reply->qual[num].updt_id)
   DETAIL
    FOR (x = 1 TO reply->qual_cnt)
      IF ((reply->qual[x].updt_id=p.person_id))
       reply->qual[x].updt_prsnl_name = p.name_full_formatted
      ENDIF
    ENDFOR
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->qual_cnt=0))
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->qual,reply->qual_cnt)
  SET reply->status_data.status = "S"
  FOR (zz = 1 TO reply->qual_cnt)
    CALL echo(build("--Mnemonic: ",reply->qual[zz].order_mnemonic))
    CALL echo(build("--Order Comment: ",reply->qual[zz].order_comment))
    CALL echo(build("--CKI: ",trim(reply->qual[zz].cki)))
  ENDFOR
 ENDIF
 SET time = cnvtdatetime(curdate,curtime3)
 CALL echo(build("End of dcp_get_ord_to_sign",time))
 SET last_mod = "017"
 SET script_date = "08/20/2009"
END GO
