CREATE PROGRAM dcp_upd_omf_pathway:dba
 SET modify = nopredeclare
 SET dcp_info_ind = 0
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="PATHWAYS"
  DETAIL
   dcp_info_ind = 1
  WITH nocounter
 ;end select
 IF (dcp_info_ind=1)
  CALL echo("OMF tables are currently being re-populated by a readme")
  SET failed = "T"
  GO TO end_program
 ENDIF
 SET modify = predeclare
 RECORD phase(
   1 qual[*]
     2 pathway_id = f8
     2 pathway_catalog_id = f8
     2 version = i4
     2 description = vc
     2 pw_status_cd = f8
     2 pathway_ind = i2
     2 person_id = f8
     2 encntr_id = f8
     2 status_dt_tm = dq8
     2 status_dt_nbr = i4
     2 status_min_nbr = i4
     2 status_prsnl_id = f8
     2 ordered_ind = i2
     2 order_dt_tm = dq8
     2 order_dt_nbr = i4
     2 order_min_nbr = i4
     2 order_prsnl_id = f8
     2 started_ind = i2
     2 start_dt_tm = dq8
     2 start_dt_nbr = i4
     2 start_min_nbr = i4
     2 start_prsnl_id = f8
     2 complete_ind = i2
     2 discontinued_ind = i2
     2 discontinued_dt_tm = dq8
     2 discontinued_dt_nbr = i4
     2 discontinued_min_nbr = i4
     2 dc_prsnl_id = f8
     2 dc_reason_cd = f8
     2 dc_text_id = f8
     2 pw_duration_min_nbr = i4
     2 actual_duration_min_nbr = i4
     2 duration_delta_min_nbr = i4
     2 pw_phase_desc = vc
     2 type_mean = c12
     2 duration_qty = i4
     2 duration_unit_cd = f8
     2 pw_group_nbr = f8
     2 pw_cat_group_id = f8
     2 pw_group_desc = vc
     2 tf_desc = vc
     2 calc_end_dt_tm = dq8
     2 calc_end_min_nbr = i4
 )
 RECORD pw(
   1 pathway_id = f8
   1 pathway_catalog_id = f8
   1 version = i4
   1 description = vc
   1 person_id = f8
   1 ordered_ind = i2
   1 order_dt_tm = dq8
   1 order_prsnl_id = f8
   1 start_ind = f8
   1 start_dt_tm = dq8
   1 start_prsnl_id = f8
   1 dc_ind = i2
   1 dc_dt_tm = dq8
   1 dc_prsnl_id = f8
   1 dc_reason_cd = f8
   1 dc_text_id = f8
   1 status_cd = f8
   1 status_dt_tm = dq8
   1 status_prsnl_id = f8
 )
 RECORD tf(
   1 qual[*]
     2 act_tf_id = f8
     2 encntr_id = f8
     2 dc_ind = i2
     2 start_ind = i2
 )
 RECORD ord(
   1 qual[*]
     2 pw_ord_comp_id = f8
     2 pathway_comp_id = f8
     2 ord_comp_description = vc
     2 act_time_frame_id = f8
     2 encntr_id = f8
     2 person_id = f8
     2 order_id = f8
     2 order_catalog_cd = f8
     2 order_synonym_id = f8
     2 status_cd = f8
     2 status_dt_tm = dq8
     2 status_dt_nbr = i4
     2 status_min_nbr = i4
     2 status_prsnl_id = f8
     2 included_ind = i2
     2 included_dt_tm = dq8
     2 included_dt_nbr = i4
     2 included_min_nbr = i4
     2 included_prsnl_id = f8
     2 excluded_ind = i2
     2 excluded_dt_tm = dq8
     2 excluded_dt_nbr = i4
     2 excluded_min_nbr = i4
     2 excluded_prsnl_id = f8
     2 activated_ind = i2
     2 canceled_ind = i2
     2 canceled_dt_tm = dq8
     2 canceled_dt_nbr = i4
     2 canceled_min_nbr = i4
     2 canceled_prsnl_id = f8
     2 activated_dt_tm = dq8
     2 activated_dt_nbr = i4
     2 activated_min_nbr = i4
     2 activated_prsnl_id = f8
     2 required_ind = i2
     2 added_ind = i2
     2 removed_ind = i2
     2 default_incl_ind = i2
     2 default_excl_ind = i2
     2 active_ind = i2
     2 pw_phase_desc = vc
     2 type_mean = c12
     2 pw_group_nbr = f8
     2 pw_cat_group_id = f8
     2 pw_group_desc = vc
     2 tf_description = vc
     2 category_display = vc
     2 category_cd = f8
     2 sub_category_display = vc
     2 sub_category_cd = f8
     2 pw_catalog_id = f8
     2 pw_version = i4
 )
 RECORD out(
   1 qual[*]
     2 pw_out_comp_id = f8
     2 pathway_comp_id = f8
     2 act_time_frame_id = f8
     2 result_type_cd = f8
     2 rrf_age_qty = i4
     2 rrf_age_units_cd = f8
     2 rrf_sex_cd = f8
     2 task_assay_cd = f8
     2 result_value = f8
     2 out_comp_description = vc
     2 encntr_id = f8
     2 person_id = f8
     2 event_cd = f8
     2 outcome_operator = vc
     2 result_value_str = vc
     2 result_units = vc
     2 status_cd = f8
     2 status_dt_tm = dq8
     2 status_dt_nbr = i4
     2 status_min_nbr = i4
     2 status_prsnl_id = f8
     2 included_ind = i2
     2 included_dt_tm = dq8
     2 included_dt_nbr = i4
     2 included_min_nbr = i4
     2 included_prsnl_id = f8
     2 excluded_ind = i2
     2 excluded_dt_tm = dq8
     2 excluded_dt_nbr = i4
     2 excluded_min_nbr = i4
     2 excluded_prsnl_id = f8
     2 canceled_ind = i2
     2 canceled_dt_tm = dq8
     2 canceled_dt_nbr = i4
     2 canceled_min_nbr = i4
     2 canceled_prsnl_id = f8
     2 activated_ind = i2
     2 activated_dt_tm = dq8
     2 activated_dt_nbr = i4
     2 activated_min_nbr = i4
     2 activated_prsnl_id = f8
     2 required_ind = i2
     2 start_dt_tm = dq8
     2 start_dt_nbr = i4
     2 start_min_nbr = i4
     2 end_dt_tm = dq8
     2 end_dt_nbr = i4
     2 end_min_nbr = i4
     2 added_ind = i2
     2 removed_ind = i2
     2 default_incl_ind = i2
     2 default_excl_ind = i2
     2 active_ind = i2
     2 last_met_ind = i2
     2 last_not_met_ind = i2
     2 pw_phase_desc = vc
     2 type_mean = vc
     2 pw_group_nbr = f8
     2 pw_cat_group_id = f8
     2 pw_group_desc = vc
     2 tf_description = vc
     2 category_display = vc
     2 category_cd = f8
     2 sub_category_display = vc
     2 sub_category_cd = f8
     2 pw_catalog_id = f8
     2 pw_version = i4
 )
 RECORD out_ids(
   1 qual[*]
     2 act_out_id = f8
 )
 RECORD ord_ids(
   1 qual[*]
     2 act_ord_id = f8
 )
 DECLARE zero_dt_tm = q8 WITH constant(cnvtdatetime("01-JAN-1800")), protect
 DECLARE zero_dt_nbr = i4 WITH constant(cnvtdate(zero_dt_tm)), protect
 DECLARE zero_min_nbr = i4 WITH constant(cnvtmin(zero_dt_tm,1)), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE i = i4 WITH noconstant(0), protect
 DECLARE tf_count = i4 WITH noconstant(0), protect
 DECLARE out_count = i4 WITH noconstant(0), protect
 DECLARE ord_count = i4 WITH noconstant(0), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE failed = c1 WITH noconstant("F"), protect
 DECLARE omf_status = f8 WITH noconstant(0.0), protect
 DECLARE status_changed = c1 WITH noconstant("N"), protect
 DECLARE ord_comp_status = f8 WITH noconstant(0.0), protect
 DECLARE ord_status_changed = c1 WITH noconstant("N"), protect
 DECLARE out_comp_status = f8 WITH noconstant(0.0), protect
 DECLARE out_status_changed = c1 WITH noconstant("N"), protect
 DECLARE rrf_age_qty = i4 WITH noconstant(0), protect
 DECLARE rrf_age_units_mean = c12 WITH public, noconstant(fillstring(12," ")), protect
 DECLARE task_assay_cd = f8 WITH noconstant(0.0), protect
 DECLARE rrf_sex_cd = f8 WITH noconstant(0.0), protect
 DECLARE result_value = f8 WITH noconstant(0.0), protect
 DECLARE outcome_value_descript = vc WITH noconstant(fillstring(255," ")), protect
 DECLARE code_value = f8 WITH noconstant(0.0), protect
 DECLARE code_set = i4 WITH noconstant(0), protect
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," ")), protect
 DECLARE pw_started_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"STARTED"))
 DECLARE pw_ordered_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"ORDERED"))
 DECLARE pw_discontinued_cd = f8 WITH constant(uar_get_code_by("MEANING",16769,"DISCONTINUED"))
 DECLARE comp_activated_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"ACTIVATED"))
 DECLARE comp_included_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"INCLUDED"))
 DECLARE comp_canceled_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"CANCELED"))
 DECLARE comp_excluded_cd = f8 WITH constant(uar_get_code_by("MEANING",16789,"EXCLUDED"))
 DECLARE days_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"DAYS"))
 DECLARE hours_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"HOURS"))
 DECLARE minutes_cd = f8 WITH constant(uar_get_code_by("MEANING",340,"MINUTES"))
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE"))
 DECLARE outcome_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO"))
 DECLARE alpha_type_cd = f8 WITH constant(uar_get_code_by("MEANING",289,"2"))
 DECLARE multi_type_cd = f8 WITH constant(uar_get_code_by("MEANING",289,"5"))
 IF ((((pw_started_cd=- (1))) OR ((((pw_started_cd=- (1))) OR ((((pw_ordered_cd=- (1))) OR ((((
 pw_discontinued_cd=- (1))) OR ((((comp_activated_cd=- (1))) OR ((((comp_included_cd=- (1))) OR ((((
 comp_canceled_cd=- (1))) OR ((((comp_excluded_cd=- (1))) OR ((((days_cd=- (1))) OR ((((hours_cd=- (1
 ))) OR ((((minutes_cd=- (1))) OR ((((order_comp_cd=- (1))) OR ((((outcome_comp_cd=- (1))) OR ((((
 alpha_type_cd=- (1))) OR ((multi_type_cd=- (1)))) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  CALL echo("Unable to load code values")
  SET failed = "T"
  GO TO end_program
 ENDIF
 IF ((request->dc_ind=0))
  SET tf_count = size(request->qual_time_frame,5)
  SET stat = alterlist(tf->qual,tf_count)
  FOR (i = 1 TO tf_count)
   SET tf->qual[i].act_tf_id = request->qual_time_frame[i].act_time_frame_id
   SET tf->qual[i].encntr_id = request->encntr_id
  ENDFOR
  SELECT INTO "nl:"
   FROM act_pw_comp apc,
    (dummyt d  WITH seq = value(size(request->qual_component,5)))
   PLAN (d)
    JOIN (apc
    WHERE (apc.act_pw_comp_id=request->qual_component[d.seq].act_pw_comp_id))
   ORDER BY apc.act_pw_comp_id
   HEAD REPORT
    stat = alterlist(ord_ids->qual,10), ord_count = 0, stat = alterlist(out_ids->qual,10),
    out_count = 0
   HEAD apc.act_pw_comp_id
    IF (apc.comp_type_cd=order_comp_cd)
     ord_count = (ord_count+ 1)
     IF (mod(ord_count,10)=1
      AND ord_count != 1)
      stat = alterlist(ord_ids->qual,(ord_count+ 10))
     ENDIF
     ord_ids->qual[ord_count].act_ord_id = apc.act_pw_comp_id
    ELSEIF (apc.comp_type_cd=outcome_comp_cd)
     out_count = (out_count+ 1)
     IF (mod(out_count,10)=1
      AND out_count != 1)
      stat = alterlist(out_ids->qual,(out_count+ 10))
     ENDIF
     out_ids->qual[out_count].act_out_id = apc.act_pw_comp_id
    ENDIF
   FOOT REPORT
    stat = alterlist(ord_ids->qual,ord_count), stat = alterlist(out_ids->qual,out_count)
   WITH nocounter
  ;end select
 ELSEIF ((request->dc_ind=1))
  SELECT INTO "nl:"
   FROM act_time_frame atf
   WHERE (atf.pathway_id=request->pathway_id)
   HEAD REPORT
    stat = alterlist(tf->qual,10), tf_count = 0
   DETAIL
    tf_count = (tf_count+ 1)
    IF (mod(tf_count,10)=1
     AND tf_count != 1)
     stat = alterlist(tf->qual,(tf_count+ 10))
    ENDIF
    tf->qual[tf_count].act_tf_id = atf.act_time_frame_id
   FOOT REPORT
    stat = alterlist(tf->qual,tf_count)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM act_pw_comp apc
   WHERE (apc.pathway_id=request->pathway_id)
    AND apc.comp_type_cd IN (order_comp_cd, outcome_comp_cd)
   HEAD REPORT
    stat = alterlist(ord_ids->qual,10), ord_count = 0, stat = alterlist(out_ids->qual,10),
    out_count = 0
   DETAIL
    IF (apc.comp_type_cd=order_comp_cd)
     ord_count = (ord_count+ 1)
     IF (mod(ord_count,10)=1
      AND ord_count != 1)
      stat = alterlist(ord_ids->qual,(ord_count+ 10))
     ENDIF
     ord_ids->qual[ord_count].act_ord_id = apc.act_pw_comp_id
    ELSEIF (apc.comp_type_cd=outcome_comp_cd)
     out_count = (out_count+ 1)
     IF (mod(out_count,10)=1
      AND out_count != 1)
      stat = alterlist(out_ids->qual,(out_count+ 10))
     ENDIF
     out_ids->qual[out_count].act_out_id = apc.act_pw_comp_id
    ENDIF
   FOOT REPORT
    stat = alterlist(ord_ids->qual,ord_count), stat = alterlist(out_ids->qual,out_count)
   WITH nocounter
  ;end select
 ELSEIF ((request->dc_ind=2))
  SET tf_count = size(request->qual_time_frame,5)
  SET stat = alterlist(tf->qual,tf_count)
  FOR (i = 1 TO tf_count)
   SET tf->qual[i].act_tf_id = request->qual_time_frame[i].act_time_frame_id
   SET tf->qual[i].encntr_id = request->qual_time_frame[i].encntr_id
  ENDFOR
  SELECT INTO "nl:"
   FROM act_pw_comp apc
   WHERE (apc.pathway_id=request->pathway_id)
    AND apc.comp_type_cd IN (order_comp_cd, outcome_comp_cd)
   HEAD REPORT
    stat = alterlist(ord_ids->qual,10), ord_count = 0, stat = alterlist(out_ids->qual,10),
    out_count = 0
   DETAIL
    IF (apc.comp_type_cd=order_comp_cd)
     ord_count = (ord_count+ 1)
     IF (mod(ord_count,10)=1
      AND ord_count != 1)
      stat = alterlist(ord_ids->qual,(ord_count+ 10))
     ENDIF
     ord_ids->qual[ord_count].act_ord_id = apc.act_pw_comp_id
    ELSEIF (apc.comp_type_cd=outcome_comp_cd)
     out_count = (out_count+ 1)
     IF (mod(out_count,10)=1
      AND out_count != 1)
      stat = alterlist(out_ids->qual,(out_count+ 10))
     ENDIF
     out_ids->qual[out_count].act_out_id = apc.act_pw_comp_id
    ENDIF
   FOOT REPORT
    stat = alterlist(ord_ids->qual,ord_count), stat = alterlist(out_ids->qual,out_count)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  pw.pathway_id, pwa.pw_action_seq, atf.act_time_frame_id,
  atf.start_ind, check = decode(pwa.seq,"p",atf.seq,"t","z")
  FROM pathway pw,
   pathway_action pwa,
   act_time_frame atf,
   (dummyt d1  WITH seq = 1),
   (dummyt d  WITH seq = value(size(tf->qual,5)))
  PLAN (pw
   WHERE (pw.pathway_id=request->pathway_id))
   JOIN (d1)
   JOIN (((pwa
   WHERE pwa.pathway_id=pw.pathway_id)
   ) ORJOIN ((atf
   WHERE atf.pathway_id=pw.pathway_id)
   JOIN (d
   WHERE (atf.act_time_frame_id=tf->qual[d.seq].act_tf_id))
   ))
  ORDER BY pwa.pw_action_seq, atf.act_time_frame_id
  HEAD REPORT
   pw->pathway_id = pw.pathway_id, pw->pathway_catalog_id = pw.pathway_catalog_id, pw->version = pw
   .pw_cat_version,
   pw->description = pw.description, pw->person_id = pw.person_id
   IF (pw.pw_status_cd=pw_discontinued_cd)
    pw->dc_ind = 1, pw->dc_dt_tm = cnvtdatetime(pw.discontinued_dt_tm), pw->dc_prsnl_id = pw
    .status_prsnl_id,
    pw->dc_reason_cd = pw.dc_reason_cd, pw->dc_text_id = pw.dc_text_id
   ENDIF
   pw->status_cd = pw.pw_status_cd, pw->status_dt_tm = pw.status_dt_tm, pw->status_prsnl_id = pw
   .status_prsnl_id,
   prev_status_cd = 0
  HEAD pwa.pw_action_seq
   IF (check="p")
    IF (pwa.pw_action_seq=1)
     pw->ordered_ind = 1, pw->order_dt_tm = pwa.action_dt_tm, pw->order_prsnl_id = pwa
     .action_prsnl_id
     IF (pwa.pw_status_cd=pw_started_cd)
      pw->start_ind = 1, pw->start_dt_tm = pwa.action_dt_tm, pw->start_prsnl_id = pwa.action_prsnl_id
     ENDIF
    ELSEIF (pwa.pw_status_cd=pw_started_cd
     AND prev_status_cd=pw_ordered_cd)
     pw->start_ind = 1, pw->start_dt_tm = pwa.action_dt_tm, pw->start_prsnl_id = pwa.action_prsnl_id
    ENDIF
    prev_status_cd = pwa.pw_status_cd
   ENDIF
  HEAD atf.act_time_frame_id
   IF (check="t")
    tf->qual[d.seq].start_ind = atf.start_ind
    IF ((pw->dc_ind=1)
     AND (tf->qual[d.seq].start_ind=1))
     IF (datetimediff(atf.calc_end_dt_tm,pw->dc_dt_tm,5) > 0)
      tf->qual[d.seq].dc_ind = 1
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (value(size(ord_ids->qual,5)) > 0)
  SELECT INTO "nl:"
   FROM act_pw_comp apc,
    pathway_comp pc,
    order_catalog_synonym ocs,
    act_time_frame atf,
    act_care_cat acc,
    (dummyt d  WITH seq = value(size(ord_ids->qual,5)))
   PLAN (d)
    JOIN (apc
    WHERE (apc.act_pw_comp_id=ord_ids->qual[d.seq].act_ord_id))
    JOIN (pc
    WHERE apc.pathway_comp_id=pc.pathway_comp_id)
    JOIN (ocs
    WHERE apc.ref_prnt_ent_id=ocs.synonym_id)
    JOIN (atf
    WHERE apc.act_time_frame_id=atf.act_time_frame_id
     AND atf.active_ind > 0)
    JOIN (acc
    WHERE apc.act_care_cat_id=acc.act_care_cat_id
     AND acc.active_ind > 0)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > value(size(ord->qual,5)))
     stat = alterlist(ord->qual,(cnt+ 20))
    ENDIF
    ord->qual[cnt].pw_ord_comp_id = apc.act_pw_comp_id, ord->qual[cnt].pathway_comp_id = apc
    .pathway_comp_id, ord->qual[cnt].ord_comp_description = ocs.mnemonic,
    ord->qual[cnt].act_time_frame_id = apc.act_time_frame_id, ord->qual[cnt].encntr_id = apc
    .encntr_id, ord->qual[cnt].person_id = apc.person_id,
    ord->qual[cnt].order_id = apc.parent_entity_id, ord->qual[cnt].order_catalog_cd = ocs.catalog_cd,
    ord->qual[cnt].order_synonym_id = ocs.synonym_id,
    ord->qual[cnt].status_cd = apc.comp_status_cd, ord->qual[cnt].included_ind = apc.included_ind,
    ord->qual[cnt].included_dt_tm = cnvtdatetime(apc.included_dt_tm),
    ord->qual[cnt].included_dt_nbr = cnvtdate(cnvtdatetimeutc(apc.included_dt_tm,2)), ord->qual[cnt].
    included_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.included_dt_tm,2),5)+ 1), ord->qual[cnt].
    canceled_ind = apc.canceled_ind,
    ord->qual[cnt].canceled_dt_tm = cnvtdatetime(apc.canceled_dt_tm), ord->qual[cnt].canceled_dt_nbr
     = cnvtdate(cnvtdatetimeutc(apc.canceled_dt_tm,2)), ord->qual[cnt].canceled_min_nbr = (cnvtmin(
     cnvtdatetimeutc(apc.canceled_dt_tm,2),5)+ 1),
    ord->qual[cnt].activated_ind = apc.activated_ind, ord->qual[cnt].activated_dt_tm = cnvtdatetime(
     apc.activated_dt_tm), ord->qual[cnt].activated_dt_nbr = cnvtdate(cnvtdatetimeutc(apc
      .activated_dt_tm,2)),
    ord->qual[cnt].activated_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.activated_dt_tm,2),5)+ 1), ord->
    qual[cnt].activated_prsnl_id = apc.activated_prsnl_id, ord->qual[cnt].required_ind = apc
    .required_ind,
    ord->qual[cnt].active_ind = apc.active_ind, ord->qual[cnt].default_incl_ind = pc.include_ind, ord
    ->qual[cnt].pw_phase_desc = concat(trim(pw->description)," ",trim(atf.description)),
    ord->qual[cnt].type_mean = "PHASE", ord->qual[cnt].pw_group_nbr = pw->pathway_id, ord->qual[cnt].
    pw_cat_group_id = pw->pathway_catalog_id,
    ord->qual[cnt].pw_group_desc = pw->description, ord->qual[cnt].tf_description = trim(atf
     .description), ord->qual[cnt].pw_version = pw->version,
    ord->qual[cnt].pw_catalog_id = pw->pathway_catalog_id
    IF (acc.care_category_cd > 0)
     ord->qual[cnt].category_display = uar_get_code_display(acc.care_category_cd)
    ENDIF
    ord->qual[cnt].category_cd = acc.care_category_cd
   FOOT REPORT
    stat = alterlist(ord->qual,cnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (value(size(out_ids->qual,5)) > 0)
  SELECT INTO "nl:"
   FROM act_pw_comp apc,
    pathway_comp pc,
    act_time_frame atf,
    act_care_cat acc,
    (dummyt d  WITH seq = value(size(out_ids->qual,5)))
   PLAN (d)
    JOIN (apc
    WHERE (apc.act_pw_comp_id=out_ids->qual[d.seq].act_out_id))
    JOIN (pc
    WHERE apc.pathway_comp_id=pc.pathway_comp_id)
    JOIN (atf
    WHERE apc.act_time_frame_id=atf.act_time_frame_id
     AND atf.active_ind > 0)
    JOIN (acc
    WHERE apc.act_care_cat_id=acc.act_care_cat_id
     AND acc.active_ind > 0)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > value(size(out->qual,5)))
     stat = alterlist(out->qual,(cnt+ 20))
    ENDIF
    out->qual[cnt].pw_out_comp_id = apc.act_pw_comp_id, out->qual[cnt].pathway_comp_id = apc
    .pathway_comp_id, out->qual[cnt].act_time_frame_id = apc.act_time_frame_id,
    out->qual[cnt].out_comp_description = uar_get_code_display(apc.event_cd), out->qual[cnt].
    result_type_cd = apc.result_type_cd, out->qual[cnt].rrf_age_qty = apc.rrf_age_qty,
    out->qual[cnt].rrf_age_units_cd = apc.rrf_age_units_cd, out->qual[cnt].rrf_sex_cd = apc
    .rrf_sex_cd, out->qual[cnt].task_assay_cd = apc.task_assay_cd,
    out->qual[cnt].result_value = apc.result_value, out->qual[cnt].encntr_id = apc.encntr_id, out->
    qual[cnt].person_id = apc.person_id,
    out->qual[cnt].status_cd = apc.comp_status_cd, out->qual[cnt].event_cd = apc.event_cd, out->qual[
    cnt].outcome_operator = uar_get_code_display(apc.outcome_operator_cd),
    out->qual[cnt].result_value_str = cnvtstring(apc.result_value)
    IF (apc.result_units_cd > 0)
     out->qual[cnt].result_units = uar_get_code_display(apc.result_units_cd)
    ENDIF
    out->qual[cnt].included_ind = apc.included_ind, out->qual[cnt].included_dt_tm = cnvtdatetime(apc
     .included_dt_tm), out->qual[cnt].included_dt_nbr = cnvtdate(cnvtdatetimeutc(apc.included_dt_tm,2
      )),
    out->qual[cnt].included_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.included_dt_tm,2),5)+ 1), out->
    qual[cnt].canceled_ind = apc.canceled_ind, out->qual[cnt].canceled_dt_tm = cnvtdatetime(apc
     .canceled_dt_tm),
    out->qual[cnt].canceled_dt_nbr = cnvtdate(cnvtdatetimeutc(apc.canceled_dt_tm,2)), out->qual[cnt].
    canceled_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.canceled_dt_tm,2),5)+ 1), out->qual[cnt].
    activated_ind = apc.activated_ind,
    out->qual[cnt].activated_dt_tm = cnvtdatetime(apc.activated_dt_tm), out->qual[cnt].
    activated_dt_nbr = cnvtdate(cnvtdatetimeutc(apc.activated_dt_tm,2)), out->qual[cnt].
    activated_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.activated_dt_tm,2),5)+ 1),
    out->qual[cnt].activated_prsnl_id = apc.activated_prsnl_id, out->qual[cnt].start_dt_tm =
    cnvtdatetime(apc.start_dt_tm), out->qual[cnt].start_dt_nbr = cnvtdate(cnvtdatetimeutc(apc
      .start_dt_tm,2)),
    out->qual[cnt].start_min_nbr = (cnvtmin(cnvtdatetimeutc(apc.start_dt_tm,2),5)+ 1)
    IF ((out->qual[cnt].status_cd=comp_canceled_cd))
     out->qual[cnt].end_dt_tm = cnvtdatetime(apc.canceled_dt_tm), out->qual[cnt].end_dt_nbr =
     cnvtdate(cnvtdatetimeutc(apc.canceled_dt_tm,2)), out->qual[cnt].end_min_nbr = (cnvtmin(
      cnvtdatetimeutc(apc.canceled_dt_tm,2),5)+ 1)
    ELSE
     out->qual[cnt].end_dt_tm = cnvtdatetime(apc.end_dt_tm), out->qual[cnt].end_dt_nbr = cnvtdate(
      cnvtdatetimeutc(apc.end_dt_tm,2)), out->qual[cnt].end_min_nbr = (cnvtmin(cnvtdatetimeutc(apc
       .end_dt_tm,2),5)+ 1)
    ENDIF
    IF ((pw->dc_ind=1)
     AND datetimediff(out->qual[cnt].end_dt_tm,pw->dc_dt_tm,5) > 0)
     out->qual[cnt].end_dt_tm = cnvtdatetime(pw->dc_dt_tm), out->qual[cnt].end_dt_nbr = cnvtdate(
      cnvtdatetimeutc(pw->dc_dt_tm,2)), out->qual[cnt].end_min_nbr = (cnvtmin(cnvtdatetimeutc(pw->
       dc_dt_tm,2),5)+ 1)
    ENDIF
    out->qual[cnt].required_ind = apc.required_ind, out->qual[cnt].active_ind = apc.active_ind, out->
    qual[cnt].default_incl_ind = pc.include_ind,
    out->qual[cnt].pw_phase_desc = concat(trim(pw->description)," ",trim(atf.description)), out->
    qual[cnt].type_mean = "PHASE", out->qual[cnt].pw_group_nbr = pw->pathway_id,
    out->qual[cnt].pw_cat_group_id = pw->pathway_catalog_id, out->qual[cnt].pw_group_desc = pw->
    description, out->qual[cnt].tf_description = trim(atf.description),
    out->qual[cnt].pw_version = pw->version, out->qual[cnt].pw_catalog_id = pw->pathway_catalog_id
    IF (acc.care_category_cd > 0)
     out->qual[cnt].category_display = uar_get_code_display(acc.care_category_cd)
    ENDIF
    out->qual[cnt].category_cd = acc.care_category_cd
   FOOT REPORT
    stat = alterlist(out->qual,cnt)
   WITH nocounter
  ;end select
  SET cnt = value(size(out->qual,5))
  FOR (i = 1 TO cnt)
    IF ((((out->qual[i].result_type_cd=alpha_type_cd)) OR ((out->qual[i].result_type_cd=multi_type_cd
    ))) )
     SET rrf_age_qty = out->qual[i].rrf_age_qty
     IF ((out->qual[i].rrf_age_units_cd > 0))
      SET rrf_age_units_mean = uar_get_code_meaning(out->qual[i].rrf_age_units_cd)
     ELSE
      SET rrf_age_units_mean = ""
     ENDIF
     SET task_assay_cd = out->qual[i].task_assay_cd
     SET rrf_sex_cd = out->qual[i].rrf_sex_cd
     SET result_value = out->qual[i].result_value
     SET outcome_value_descript = fillstring(255," ")
     SET modify = nopredeclare
     SET count1 = 0
     SET rr_id = 0.00
     SET first_one = "Y"
     SET age_in_minutes = 0.0
     SET code_set = 226
     SET cdf_meaning = "HUMAN"
     EXECUTE cpm_get_cd_for_cdf
     SET human_type_cd = code_value
     IF (rrf_age_units_mean="HOURS")
      SET age_in_minutes = (rrf_age_qty * 60)
     ELSEIF (rrf_age_units_mean="DAYS")
      SET age_in_minutes = ((rrf_age_qty * 60) * 24)
     ELSEIF (rrf_age_units_mean="WEEKS")
      SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 7)
     ELSEIF (rrf_age_units_mean="MONTHS")
      SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 30)
     ELSEIF (rrf_age_units_mean="YEARS")
      SET age_in_minutes = (((rrf_age_qty * 60) * 24) * 365.25)
     ENDIF
     SELECT INTO "nl:"
      r.reference_range_factor_id, a.reference_range_factor_id, a.nomenclature_id,
      a.description
      FROM reference_range_factor r,
       alpha_responses a,
       (dummyt d1  WITH seq = 1)
      PLAN (r
       WHERE r.task_assay_cd=task_assay_cd
        AND r.active_ind=1
        AND r.species_cd=human_type_cd
        AND r.organism_cd=0.00
        AND r.service_resource_cd=0.00
        AND r.gestational_ind=0
        AND r.unknown_age_ind=0
        AND ((r.sex_cd=rrf_sex_cd) OR (r.sex_cd=0.00))
        AND r.age_from_minutes <= age_in_minutes
        AND r.age_to_minutes >= age_in_minutes)
       JOIN (d1)
       JOIN (a
       WHERE a.reference_range_factor_id=r.reference_range_factor_id)
      ORDER BY r.sex_cd DESC, r.precedence_sequence, r.reference_range_factor_id
      HEAD REPORT
       rr_id = 0.00, first_one = "Y"
      HEAD r.reference_range_factor_id
       count1 = 0
       IF (first_one="Y")
        rr_id = r.reference_range_factor_id
       ENDIF
      DETAIL
       IF (((rr_id=r.reference_range_factor_id) OR (first_one="Y")) )
        first_one = "N"
        IF (a.reference_range_factor_id > 0)
         IF (a.result_value=result_value)
          count1 = (count1+ 1)
          IF (count1=1)
           outcome_value_descript = a.description
          ELSE
           outcome_value_descript = concat(trim(outcome_value_descript),", ",trim(a.description))
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      WITH nocounter
     ;end select
     SET modify = predeclare
     SET out->qual[i].out_comp_description = concat(out->qual[i].out_comp_description," - ",trim(
       outcome_value_descript))
    ELSE
     SET out->qual[i].out_comp_description = concat(out->qual[i].out_comp_description," - ",trim(out
       ->qual[i].outcome_operator)," ",trim(out->qual[i].result_value_str),
      " ",trim(out->qual[i].result_units))
    ENDIF
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  FROM act_time_frame atf,
   time_frame tf,
   act_pw_comp apc,
   pw_comp_action pca,
   (dummyt d  WITH seq = value(size(tf->qual,5)))
  PLAN (d)
   JOIN (atf
   WHERE (atf.act_time_frame_id=tf->qual[d.seq].act_tf_id)
    AND atf.act_time_frame_id > 0)
   JOIN (tf
   WHERE tf.time_frame_id=atf.time_frame_id)
   JOIN (apc
   WHERE apc.act_time_frame_id=atf.act_time_frame_id)
   JOIN (pca
   WHERE pca.act_pw_comp_id=apc.act_pw_comp_id)
  ORDER BY atf.act_time_frame_id, apc.act_pw_comp_id, pca.pw_comp_action_seq
  HEAD atf.act_time_frame_id
   stat = alterlist(phase->qual,d.seq), phase->qual[d.seq].pathway_id = atf.act_time_frame_id, phase
   ->qual[d.seq].pathway_catalog_id = pw->pathway_catalog_id,
   phase->qual[d.seq].version = pw->version, phase->qual[d.seq].description = pw->description, phase
   ->qual[d.seq].encntr_id = tf->qual[d.seq].encntr_id,
   phase->qual[d.seq].person_id = pw->person_id, phase->qual[d.seq].pathway_ind = 1, phase->qual[d
   .seq].ordered_ind = 1,
   phase->qual[d.seq].order_dt_tm = cnvtdatetime(pw->order_dt_tm), phase->qual[d.seq].order_dt_nbr =
   cnvtdate(cnvtdatetimeutc(pw->order_dt_tm,2)), phase->qual[d.seq].order_min_nbr = (cnvtmin(
    cnvtdatetimeutc(pw->order_dt_tm,2),5)+ 1),
   phase->qual[d.seq].order_prsnl_id = pw->order_prsnl_id
   IF ((tf->qual[d.seq].start_ind=1))
    phase->qual[d.seq].pw_status_cd = pw_started_cd, phase->qual[d.seq].started_ind = atf.start_ind,
    phase->qual[d.seq].start_dt_tm = cnvtdatetime(atf.calc_start_dt_tm),
    phase->qual[d.seq].start_dt_nbr = cnvtdate(cnvtdatetimeutc(atf.calc_start_dt_tm,2)), phase->qual[
    d.seq].start_min_nbr = (cnvtmin(cnvtdatetimeutc(atf.calc_start_dt_tm,2),5)+ 1), phase->qual[d.seq
    ].status_dt_tm = cnvtdatetime(atf.calc_start_dt_tm),
    phase->qual[d.seq].status_dt_nbr = cnvtdate(cnvtdatetimeutc(atf.calc_start_dt_tm,2)), phase->
    qual[d.seq].status_min_nbr = (cnvtmin(cnvtdatetimeutc(atf.calc_start_dt_tm,2),5)+ 1)
   ENDIF
   IF ((tf->qual[d.seq].dc_ind=1))
    phase->qual[d.seq].pw_status_cd = pw_discontinued_cd, phase->qual[d.seq].status_dt_tm =
    cnvtdatetime(pw->dc_dt_tm), phase->qual[d.seq].status_dt_nbr = cnvtdate(cnvtdatetimeutc(pw->
      dc_dt_tm,2)),
    phase->qual[d.seq].status_min_nbr = (cnvtmin(cnvtdatetimeutc(pw->dc_dt_tm,2),5)+ 1), phase->qual[
    d.seq].status_prsnl_id = pw->dc_prsnl_id, phase->qual[d.seq].discontinued_ind = 1,
    phase->qual[d.seq].discontinued_dt_tm = cnvtdatetime(pw->dc_dt_tm), phase->qual[d.seq].
    discontinued_dt_nbr = cnvtdate(cnvtdatetimeutc(pw->dc_dt_tm,2)), phase->qual[d.seq].
    discontinued_min_nbr = (cnvtmin(cnvtdatetimeutc(pw->dc_dt_tm,2),5)+ 1),
    phase->qual[d.seq].dc_reason_cd = pw->dc_reason_cd, phase->qual[d.seq].dc_text_id = pw->
    dc_text_id, phase->qual[d.seq].dc_prsnl_id = pw->dc_prsnl_id
   ENDIF
   IF ((tf->qual[d.seq].start_ind=0)
    AND (tf->qual[d.seq].dc_ind=0))
    phase->qual[d.seq].pw_status_cd = pw_ordered_cd, phase->qual[d.seq].status_dt_tm = cnvtdatetime(
     pw->order_dt_tm), phase->qual[d.seq].status_dt_nbr = cnvtdate(cnvtdatetimeutc(pw->order_dt_tm,2)
     ),
    phase->qual[d.seq].status_min_nbr = (cnvtmin(cnvtdatetimeutc(pw->order_dt_tm,2),5)+ 1), phase->
    qual[d.seq].status_prsnl_id = pw->order_prsnl_id
   ENDIF
   phase->qual[d.seq].pw_phase_desc = concat(trim(pw->description)," ",trim(atf.description)), phase
   ->qual[d.seq].tf_desc = trim(atf.description), phase->qual[d.seq].type_mean = "PHASE",
   phase->qual[d.seq].pw_group_nbr = pw->pathway_id, phase->qual[d.seq].pw_cat_group_id = pw->
   pathway_catalog_id, phase->qual[d.seq].pw_group_desc = pw->description,
   phase->qual[d.seq].duration_qty = tf.duration_qty, phase->qual[d.seq].duration_unit_cd = tf
   .age_units_cd
   IF ((phase->qual[d.seq].duration_unit_cd=days_cd))
    phase->qual[d.seq].pw_duration_min_nbr = (phase->qual[d.seq].duration_qty * 1440)
   ELSEIF ((phase->qual[d.seq].duration_unit_cd=hours_cd))
    phase->qual[d.seq].pw_duration_min_nbr = (phase->qual[d.seq].duration_qty * 60)
   ELSEIF ((phase->qual[d.seq].duration_unit_cd=minutes_cd))
    phase->qual[d.seq].pw_duration_min_nbr = phase->qual[d.seq].duration_qty
   ENDIF
   IF ((phase->qual[d.seq].discontinued_ind=1))
    phase->qual[d.seq].calc_end_dt_tm = cnvtdatetime(pw->dc_dt_tm), phase->qual[d.seq].
    calc_end_min_nbr = cnvtmin(pw->dc_dt_tm,5), phase->qual[d.seq].actual_duration_min_nbr =
    datetimediff(pw->dc_dt_tm,atf.calc_start_dt_tm,4),
    phase->qual[d.seq].duration_delta_min_nbr = (phase->qual[d.seq].actual_duration_min_nbr - phase->
    qual[d.seq].pw_duration_min_nbr)
   ELSEIF ((phase->qual[d.seq].started_ind=1))
    phase->qual[d.seq].calc_end_dt_tm = cnvtdatetime(atf.calc_end_dt_tm), phase->qual[d.seq].
    calc_end_min_nbr = cnvtmin(atf.calc_end_dt_tm,5), phase->qual[d.seq].actual_duration_min_nbr =
    datetimediff(atf.calc_end_dt_tm,atf.calc_start_dt_tm,4),
    phase->qual[d.seq].duration_delta_min_nbr = (phase->qual[d.seq].actual_duration_min_nbr - phase->
    qual[d.seq].pw_duration_min_nbr)
   ENDIF
   found = 0
  DETAIL
   IF (found=0
    AND (phase->qual[d.seq].started_ind=1))
    IF (pca.comp_status_cd=comp_activated_cd)
     phase->qual[d.seq].start_prsnl_id = pca.action_prsnl_id
     IF ((tf->qual[d.seq].dc_ind != 1))
      phase->qual[d.seq].status_prsnl_id = pca.action_prsnl_id
     ENDIF
     found = 1
    ENDIF
   ENDIF
  FOOT  atf.act_time_frame_id
   found = 0
  WITH nocounter
 ;end select
 IF ((request->new_ind=1))
  SET cnt = value(size(phase->qual,5))
  FOR (i = 1 TO cnt)
    CALL insert_to_pathway(i)
  ENDFOR
 ELSE
  SET cnt = value(size(phase->qual,5))
  FOR (i = 1 TO cnt)
   SELECT INTO "nl:"
    FROM cn_pathway_st cn
    WHERE (cn.pathway_id=phase->qual[i].pathway_id)
    DETAIL
     omf_status = cn.pw_status_cd
    WITH nocounter, forupdate(cn)
   ;end select
   IF (curqual=0)
    CALL insert_to_pathway(i)
   ELSE
    IF ((omf_status != phase->qual[i].pw_status_cd))
     SET status_changed = "Y"
    ENDIF
    CALL update_to_pathway(i)
   ENDIF
  ENDFOR
 ENDIF
 SET cnt = value(size(ord->qual,5))
 FOR (i = 1 TO cnt)
   SELECT INTO "nl:"
    FROM pw_comp_action pca
    WHERE (pca.act_pw_comp_id=ord->qual[i].pw_ord_comp_id)
     AND (pca.comp_status_cd=ord->qual[i].status_cd)
    ORDER BY pca.comp_status_cd, pca.action_dt_tm DESC
    HEAD pca.comp_status_cd
     ord->qual[i].status_dt_tm = cnvtdatetime(pca.action_dt_tm), ord->qual[i].status_dt_nbr =
     cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), ord->qual[i].status_min_nbr = (cnvtmin(
      cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
     ord->qual[i].status_prsnl_id = pca.action_prsnl_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cn_pw_order_st cpo
    WHERE (cpo.pw_ord_comp_id=ord->qual[i].pw_ord_comp_id)
    DETAIL
     ord_comp_status = cpo.status_cd
    WITH nocounter, forupdate(cpo)
   ;end select
   IF (curqual=0)
    IF ((((ord->qual[i].status_cd=comp_included_cd)) OR ((ord->qual[i].status_cd=comp_activated_cd)
    )) )
     SET ord->qual[i].included_prsnl_id = ord->qual[i].status_prsnl_id
    ELSEIF ((ord->qual[i].status_cd=comp_excluded_cd))
     SET ord->qual[i].excluded_ind = 1
     SET ord->qual[i].excluded_dt_tm = cnvtdatetime(ord->qual[i].status_dt_tm)
     SET ord->qual[i].excluded_dt_nbr = ord->qual[i].status_dt_nbr
     SET ord->qual[i].excluded_min_nbr = ord->qual[i].status_min_nbr
     SET ord->qual[i].excluded_prsnl_id = ord->qual[i].status_prsnl_id
    ENDIF
    IF ((ord->qual[i].pathway_comp_id=0))
     SET ord->qual[i].added_ind = 1
    ELSE
     SET ord->qual[i].added_ind = 0
    ENDIF
    IF ((ord->qual[i].active_ind=0))
     SET ord->qual[i].removed_ind = 1
    ELSE
     SET ord->qual[i].removed_ind = 0
    ENDIF
    CALL insert_to_order(i)
   ELSE
    IF ((ord->qual[i].status_cd != ord_comp_status))
     SET ord_status_changed = "Y"
     IF ((ord->qual[i].status_cd=comp_included_cd))
      SET ord->qual[i].included_prsnl_id = ord->qual[i].status_prsnl_id
     ELSEIF ((ord->qual[i].status_cd=comp_canceled_cd))
      SET ord->qual[i].canceled_prsnl_id = ord->qual[i].status_prsnl_id
     ELSEIF ((ord->qual[i].status_cd=comp_excluded_cd))
      SET ord->qual[i].excluded_ind = 1
      SET ord->qual[i].excluded_dt_tm = cnvtdatetime(ord->qual[i].status_dt_tm)
      SET ord->qual[i].excluded_dt_nbr = ord->qual[i].status_dt_nbr
      SET ord->qual[i].excluded_min_nbr = ord->qual[i].status_min_nbr
      SET ord->qual[i].excluded_prsnl_id = ord->qual[i].status_prsnl_id
     ENDIF
    ENDIF
    IF ((ord->qual[i].pathway_comp_id=0))
     SET ord->qual[i].added_ind = 1
    ELSE
     SET ord->qual[i].added_ind = 0
    ENDIF
    IF ((ord->qual[i].active_ind=0))
     SET ord->qual[i].removed_ind = 1
    ELSE
     SET ord->qual[i].removed_ind = 0
    ENDIF
    CALL update_to_order(i)
   ENDIF
 ENDFOR
 FOR (i = 1 TO size(out->qual,5))
   SELECT INTO "nl:"
    FROM pw_comp_action pca
    WHERE (pca.act_pw_comp_id=out->qual[i].pw_out_comp_id)
     AND (pca.comp_status_cd=out->qual[i].status_cd)
    ORDER BY pca.comp_status_cd, pca.action_dt_tm DESC
    HEAD pca.comp_status_cd
     out->qual[i].status_dt_tm = cnvtdatetime(pca.action_dt_tm), out->qual[i].status_dt_nbr =
     cnvtdate(cnvtdatetimeutc(pca.action_dt_tm,2)), out->qual[i].status_min_nbr = (cnvtmin(
      cnvtdatetimeutc(pca.action_dt_tm,2),5)+ 1),
     out->qual[i].status_prsnl_id = pca.action_prsnl_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM cn_pw_outcome_st cpu
    WHERE (cpu.pw_out_comp_id=out->qual[i].pw_out_comp_id)
    DETAIL
     out_comp_status = cpu.status_cd
    WITH nocounter, forupdate(cpu)
   ;end select
   IF (curqual=0)
    CALL insert_to_outcome(i)
   ELSE
    CALL update_to_outcome(i)
   ENDIF
 ENDFOR
 SUBROUTINE insert_to_pathway(i)
  INSERT  FROM cn_pathway_st cn
   SET cn.pathway_id = phase->qual[i].pathway_id, cn.pathway_catalog_id = phase->qual[i].
    pathway_catalog_id, cn.version = phase->qual[i].version,
    cn.description = phase->qual[i].description, cn.encntr_id = phase->qual[i].encntr_id, cn
    .person_id = phase->qual[i].person_id,
    cn.pathway_ind = phase->qual[i].pathway_ind, cn.pw_status_cd = phase->qual[i].pw_status_cd, cn
    .status_dt_tm = cnvtdatetime(phase->qual[i].status_dt_tm),
    cn.status_dt_nbr = phase->qual[i].status_dt_nbr, cn.status_min_nbr = phase->qual[i].
    status_min_nbr, cn.status_prsnl_id = phase->qual[i].status_prsnl_id,
    cn.ordered_ind = phase->qual[i].ordered_ind, cn.order_dt_tm = cnvtdatetime(phase->qual[i].
     order_dt_tm), cn.order_dt_nbr = phase->qual[i].order_dt_nbr,
    cn.order_min_nbr = phase->qual[i].order_min_nbr, cn.order_prsnl_id = phase->qual[i].
    order_prsnl_id, cn.started_ind = phase->qual[i].started_ind,
    cn.start_dt_tm = cnvtdatetime(phase->qual[i].start_dt_tm), cn.start_dt_nbr = phase->qual[i].
    start_dt_nbr, cn.start_min_nbr = phase->qual[i].start_min_nbr,
    cn.start_prsnl_id = phase->qual[i].start_prsnl_id, cn.complete_ind = 0, cn.discontinued_ind =
    phase->qual[i].discontinued_ind,
    cn.discontinued_dt_tm = cnvtdatetime(phase->qual[i].discontinued_dt_tm), cn.discontinued_dt_nbr
     = phase->qual[i].discontinued_dt_nbr, cn.discontinued_min_nbr = phase->qual[i].
    discontinued_min_nbr,
    cn.dc_prsnl_id = phase->qual[i].dc_prsnl_id, cn.dc_reason_cd = phase->qual[i].dc_reason_cd, cn
    .dc_text_id = phase->qual[i].dc_text_id,
    cn.pw_duration_min_nbr = phase->qual[i].pw_duration_min_nbr, cn.actual_duration_min_nbr = phase->
    qual[i].actual_duration_min_nbr, cn.duration_delta_min_nbr = phase->qual[i].
    duration_delta_min_nbr,
    cn.pw_phase_desc = phase->qual[i].pw_phase_desc, cn.type_mean = phase->qual[i].type_mean, cn
    .duration_qty = phase->qual[i].duration_qty,
    cn.duration_unit_cd = phase->qual[i].duration_unit_cd, cn.pw_group_nbr = phase->qual[i].
    pw_group_nbr, cn.pw_cat_group_id = phase->qual[i].pw_cat_group_id,
    cn.pw_group_desc = phase->qual[i].pw_group_desc, cn.tf_desc = phase->qual[i].tf_desc, cn
    .calc_end_dt_tm = cnvtdatetime(phase->qual[i].calc_end_dt_tm),
    cn.calc_end_min_nbr = phase->qual[i].calc_end_min_nbr, cn.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), cn.updt_cnt = 0,
    cn.updt_id = reqinfo->updt_id, cn.updt_task = reqinfo->updt_task, cn.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO end_program
  ENDIF
 END ;Subroutine
 SUBROUTINE update_to_pathway(i)
  UPDATE  FROM cn_pathway_st cn
   SET cn.encntr_id =
    IF (status_changed="Y"
     AND (phase->qual[i].pw_status_cd=pw_started_cd)
     AND (phase->qual[i].encntr_id > 0)) phase->qual[i].encntr_id
    ELSE cn.encntr_id
    ENDIF
    , cn.pw_status_cd =
    IF (status_changed="Y") phase->qual[i].pw_status_cd
    ELSE cn.pw_status_cd
    ENDIF
    , cn.status_dt_tm =
    IF (status_changed="Y") cnvtdatetime(phase->qual[i].status_dt_tm)
    ELSE cn.status_dt_tm
    ENDIF
    ,
    cn.status_dt_nbr =
    IF (status_changed="Y") phase->qual[i].status_dt_nbr
    ELSE cn.status_dt_nbr
    ENDIF
    , cn.status_min_nbr =
    IF (status_changed="Y") phase->qual[i].status_min_nbr
    ELSE cn.status_min_nbr
    ENDIF
    , cn.status_prsnl_id =
    IF (status_changed="Y") phase->qual[i].status_prsnl_id
    ELSE cn.status_prsnl_id
    ENDIF
    ,
    cn.started_ind = phase->qual[i].started_ind, cn.start_dt_tm = cnvtdatetime(phase->qual[i].
     start_dt_tm), cn.start_dt_nbr = phase->qual[i].start_dt_nbr,
    cn.start_min_nbr = phase->qual[i].start_min_nbr, cn.start_prsnl_id = phase->qual[i].
    start_prsnl_id, cn.complete_ind = 0,
    cn.discontinued_ind = phase->qual[i].discontinued_ind, cn.discontinued_dt_tm = cnvtdatetime(phase
     ->qual[i].discontinued_dt_tm), cn.discontinued_dt_nbr = phase->qual[i].discontinued_dt_nbr,
    cn.discontinued_min_nbr = phase->qual[i].discontinued_min_nbr, cn.dc_prsnl_id = phase->qual[i].
    dc_prsnl_id, cn.dc_reason_cd = phase->qual[i].dc_reason_cd,
    cn.dc_text_id = phase->qual[i].dc_text_id, cn.actual_duration_min_nbr = phase->qual[i].
    actual_duration_min_nbr, cn.duration_delta_min_nbr = phase->qual[i].duration_delta_min_nbr,
    cn.calc_end_dt_tm =
    IF ((phase->qual[i].calc_end_dt_tm != null)) cnvtdatetime(phase->qual[i].calc_end_dt_tm)
    ELSE cn.calc_end_dt_tm
    ENDIF
    , cn.calc_end_min_nbr =
    IF ((phase->qual[i].calc_end_dt_tm != null)) phase->qual[i].calc_end_min_nbr
    ELSE cn.calc_end_min_nbr
    ENDIF
    , cn.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    cn.updt_cnt = (cn.updt_cnt+ 1), cn.updt_id = reqinfo->updt_id, cn.updt_task = reqinfo->updt_task,
    cn.updt_applctx = reqinfo->updt_applctx
   WHERE (cn.pathway_id=phase->qual[i].pathway_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   GO TO end_program
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_to_order(i)
  INSERT  FROM cn_pw_order_st cpo
   SET cpo.pw_ord_comp_id = ord->qual[i].pw_ord_comp_id, cpo.pathway_comp_id = ord->qual[i].
    pathway_comp_id, cpo.pw_ord_comp_ind = 1,
    cpo.ord_comp_description = ord->qual[i].ord_comp_description, cpo.pathway_id = ord->qual[i].
    act_time_frame_id, cpo.pathway_catalog_id = ord->qual[i].pw_catalog_id,
    cpo.version = ord->qual[i].pw_version, cpo.pw_description = ord->qual[i].pw_group_desc, cpo
    .encntr_id = ord->qual[i].encntr_id,
    cpo.person_id = ord->qual[i].person_id, cpo.order_id = ord->qual[i].order_id, cpo
    .order_catalog_cd = ord->qual[i].order_catalog_cd,
    cpo.order_synonym_id = ord->qual[i].order_synonym_id, cpo.status_cd = ord->qual[i].status_cd, cpo
    .status_dt_tm = cnvtdatetime(ord->qual[i].status_dt_tm),
    cpo.status_dt_nbr = ord->qual[i].status_dt_nbr, cpo.status_min_nbr = ord->qual[i].status_min_nbr,
    cpo.status_prsnl_id = ord->qual[i].status_prsnl_id,
    cpo.included_ind = ord->qual[i].included_ind, cpo.included_dt_tm =
    IF ((ord->qual[i].included_ind=1)) cnvtdatetime(ord->qual[i].included_dt_tm)
    ELSE cnvtdatetime(zero_dt_tm)
    ENDIF
    , cpo.included_dt_nbr =
    IF ((ord->qual[i].included_ind=1)) ord->qual[i].included_dt_nbr
    ELSE zero_dt_nbr
    ENDIF
    ,
    cpo.included_min_nbr =
    IF ((ord->qual[i].included_ind=1)) ord->qual[i].included_min_nbr
    ELSE zero_min_nbr
    ENDIF
    , cpo.included_prsnl_id =
    IF ((ord->qual[i].included_ind=1)) ord->qual[i].included_prsnl_id
    ELSE 0
    ENDIF
    , cpo.excluded_ind = ord->qual[i].excluded_ind,
    cpo.excluded_dt_tm =
    IF ((ord->qual[i].excluded_ind=1)) cnvtdatetime(ord->qual[i].excluded_dt_tm)
    ELSE cnvtdatetime(zero_dt_tm)
    ENDIF
    , cpo.excluded_dt_nbr =
    IF ((ord->qual[i].excluded_ind=1)) ord->qual[i].excluded_dt_nbr
    ELSE zero_dt_nbr
    ENDIF
    , cpo.excluded_min_nbr =
    IF ((ord->qual[i].excluded_ind=1)) ord->qual[i].excluded_min_nbr
    ELSE zero_min_nbr
    ENDIF
    ,
    cpo.excluded_prsnl_id =
    IF ((ord->qual[i].excluded_ind=1)) ord->qual[i].excluded_prsnl_id
    ELSE 0
    ENDIF
    , cpo.activated_ind = ord->qual[i].activated_ind, cpo.activated_dt_tm = cnvtdatetime(ord->qual[i]
     .activated_dt_tm),
    cpo.activated_dt_nbr = ord->qual[i].activated_dt_nbr, cpo.activated_min_nbr = ord->qual[i].
    activated_min_nbr, cpo.activated_prsnl_id = ord->qual[i].activated_prsnl_id,
    cpo.required_ind = ord->qual[i].required_ind, cpo.added_ind = ord->qual[i].added_ind, cpo
    .default_incl_ind = ord->qual[i].default_incl_ind,
    cpo.pw_phase_desc = ord->qual[i].pw_phase_desc, cpo.type_mean = ord->qual[i].type_mean, cpo
    .pw_group_nbr = ord->qual[i].pw_group_nbr,
    cpo.pw_cat_group_id = ord->qual[i].pw_cat_group_id, cpo.pw_group_desc = ord->qual[i].
    pw_group_desc, cpo.tf_description = ord->qual[i].tf_description,
    cpo.category_display = ord->qual[i].category_display, cpo.category_cd = ord->qual[i].category_cd,
    cpo.sub_category_display = ord->qual[i].sub_category_display,
    cpo.sub_category_cd = ord->qual[i].sub_category_cd, cpo.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), cpo.updt_cnt = 0,
    cpo.updt_id = reqinfo->updt_id, cpo.updt_task = reqinfo->updt_task, cpo.updt_applctx = reqinfo->
    updt_applctx
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = "T"
   GO TO end_program
  ENDIF
 END ;Subroutine
 SUBROUTINE update_to_order(i)
  UPDATE  FROM cn_pw_order_st cpo
   SET cpo.pw_ord_comp_id = ord->qual[i].pw_ord_comp_id, cpo.pathway_comp_id = ord->qual[i].
    pathway_comp_id, cpo.ord_comp_description = ord->qual[i].ord_comp_description,
    cpo.encntr_id = ord->qual[i].encntr_id, cpo.person_id = ord->qual[i].person_id, cpo.order_id =
    IF ((ord->qual[i].order_id != null)
     AND (ord->qual[i].order_id > 0)) ord->qual[i].order_id
    ELSE cpo.order_id
    ENDIF
    ,
    cpo.status_cd =
    IF (ord_status_changed="Y") ord->qual[i].status_cd
    ELSE cpo.status_cd
    ENDIF
    , cpo.status_dt_tm =
    IF (ord_status_changed="Y") cnvtdatetime(ord->qual[i].status_dt_tm)
    ELSE cpo.status_dt_tm
    ENDIF
    , cpo.status_dt_nbr =
    IF (ord_status_changed="Y") ord->qual[i].status_dt_nbr
    ELSE cpo.status_dt_nbr
    ENDIF
    ,
    cpo.status_min_nbr =
    IF (ord_status_changed="Y") ord->qual[i].status_min_nbr
    ELSE cpo.status_min_nbr
    ENDIF
    , cpo.status_prsnl_id =
    IF (ord_status_changed="Y") ord->qual[i].status_prsnl_id
    ELSE cpo.status_prsnl_id
    ENDIF
    , cpo.included_ind =
    IF ((ord->qual[i].included_ind=1)) ord->qual[i].included_ind
    ELSE cpo.included_ind
    ENDIF
    ,
    cpo.included_dt_tm = cnvtdatetime(ord->qual[i].included_dt_tm), cpo.included_dt_nbr = ord->qual[i
    ].included_dt_nbr, cpo.included_min_nbr = ord->qual[i].included_min_nbr,
    cpo.included_prsnl_id =
    IF ((ord->qual[i].included_prsnl_id != 0)
     AND (ord->qual[i].included_prsnl_id != null)) ord->qual[i].included_prsnl_id
    ELSE cpo.included_prsnl_id
    ENDIF
    , cpo.excluded_ind =
    IF ((ord->qual[i].excluded_ind=1)) ord->qual[i].excluded_ind
    ELSE cpo.excluded_ind
    ENDIF
    , cpo.excluded_dt_tm =
    IF ((ord->qual[i].excluded_ind=1)) cnvtdatetime(ord->qual[i].excluded_dt_tm)
    ELSE cpo.excluded_dt_tm
    ENDIF
    ,
    cpo.excluded_dt_nbr =
    IF ((ord->qual[i].excluded_ind=1)) ord->qual[i].excluded_dt_nbr
    ELSE cpo.excluded_dt_nbr
    ENDIF
    , cpo.excluded_min_nbr =
    IF ((ord->qual[i].excluded_ind=1)) ord->qual[i].excluded_min_nbr
    ELSE cpo.excluded_min_nbr
    ENDIF
    , cpo.excluded_prsnl_id =
    IF ((ord->qual[i].excluded_ind=1)) ord->qual[i].excluded_prsnl_id
    ELSE cpo.excluded_prsnl_id
    ENDIF
    ,
    cpo.canceled_ind =
    IF ((ord->qual[i].canceled_ind=1)) ord->qual[i].canceled_ind
    ELSE cpo.canceled_ind
    ENDIF
    , cpo.canceled_dt_tm = cnvtdatetime(ord->qual[i].canceled_dt_tm), cpo.canceled_dt_nbr = ord->
    qual[i].canceled_dt_nbr,
    cpo.canceled_min_nbr = ord->qual[i].canceled_min_nbr, cpo.canceled_prsnl_id =
    IF ((ord->qual[i].canceled_prsnl_id != 0)
     AND (ord->qual[i].canceled_prsnl_id != null)) ord->qual[i].canceled_prsnl_id
    ELSE cpo.canceled_prsnl_id
    ENDIF
    , cpo.activated_ind =
    IF ((ord->qual[i].activated_ind=1)) ord->qual[i].activated_ind
    ELSE cpo.activated_ind
    ENDIF
    ,
    cpo.activated_dt_tm = cnvtdatetime(ord->qual[i].activated_dt_tm), cpo.activated_dt_nbr = ord->
    qual[i].activated_dt_nbr, cpo.activated_min_nbr = ord->qual[i].activated_min_nbr,
    cpo.activated_prsnl_id = ord->qual[i].activated_prsnl_id, cpo.added_ind =
    IF ((ord->qual[i].added_ind=1)) ord->qual[i].added_ind
    ELSE cpo.added_ind
    ENDIF
    , cpo.removed_ind =
    IF ((ord->qual[i].removed_ind=1)) ord->qual[i].removed_ind
    ELSE cpo.added_ind
    ENDIF
    ,
    cpo.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpo.updt_cnt = (cpo.updt_cnt+ 1), cpo.updt_id =
    reqinfo->updt_id,
    cpo.updt_task = reqinfo->updt_task, cpo.updt_applctx = reqinfo->updt_applctx
   WHERE (cpo.pw_ord_comp_id=ord->qual[i].pw_ord_comp_id)
   WITH nocounter
  ;end update
  IF (curqual=0)
   SET failed = "T"
   GO TO end_program
  ENDIF
 END ;Subroutine
 SUBROUTINE insert_to_outcome(i)
   IF ((((out->qual[i].status_cd=comp_included_cd)) OR ((out->qual[i].status_cd=comp_activated_cd)))
   )
    SET out->qual[i].included_prsnl_id = out->qual[i].status_prsnl_id
   ENDIF
   IF ((out->qual[i].status_cd=comp_excluded_cd))
    SET out->qual[i].excluded_ind = 1
    SET out->qual[i].excluded_dt_tm = cnvtdatetime(out->qual[i].status_dt_tm)
    SET out->qual[i].excluded_dt_nbr = out->qual[i].status_dt_nbr
    SET out->qual[i].excluded_min_nbr = out->qual[i].status_min_nbr
    SET out->qual[i].excluded_prsnl_id = out->qual[i].status_prsnl_id
   ENDIF
   IF ((out->qual[i].active_ind=0))
    SET out->qual[i].removed_ind = 1
   ELSE
    SET out->qual[i].removed_ind = 0
   ENDIF
   INSERT  FROM cn_pw_outcome_st cpu
    SET cpu.pw_out_comp_id = out->qual[i].pw_out_comp_id, cpu.pathway_comp_id = out->qual[i].
     pathway_comp_id, cpu.pw_out_comp_ind = 1,
     cpu.out_comp_description = out->qual[i].out_comp_description, cpu.pathway_id = out->qual[i].
     act_time_frame_id, cpu.pathway_catalog_id = out->qual[i].pw_catalog_id,
     cpu.version = out->qual[i].pw_version, cpu.pw_description = out->qual[i].pw_group_desc, cpu
     .encntr_id = out->qual[i].encntr_id,
     cpu.person_id = out->qual[i].person_id, cpu.event_cd = out->qual[i].event_cd, cpu.status_cd =
     out->qual[i].status_cd,
     cpu.status_dt_tm = cnvtdatetime(out->qual[i].status_dt_tm), cpu.status_dt_nbr = out->qual[i].
     status_dt_nbr, cpu.status_min_nbr = out->qual[i].status_min_nbr,
     cpu.status_prsnl_id = out->qual[i].status_prsnl_id, cpu.included_ind = out->qual[i].included_ind,
     cpu.included_dt_tm =
     IF ((out->qual[i].included_ind=1)) cnvtdatetime(out->qual[i].included_dt_tm)
     ELSE cnvtdatetime(zero_dt_tm)
     ENDIF
     ,
     cpu.included_dt_nbr =
     IF ((out->qual[i].included_ind=1)) out->qual[i].included_dt_nbr
     ELSE zero_dt_nbr
     ENDIF
     , cpu.included_min_nbr =
     IF ((out->qual[i].included_ind=1)) out->qual[i].included_min_nbr
     ELSE zero_min_nbr
     ENDIF
     , cpu.included_prsnl_id =
     IF ((out->qual[i].included_ind=1)) out->qual[i].included_prsnl_id
     ELSE 0
     ENDIF
     ,
     cpu.excluded_ind = out->qual[i].excluded_ind, cpu.excluded_dt_tm =
     IF ((out->qual[i].excluded_ind=1)) cnvtdatetime(out->qual[i].excluded_dt_tm)
     ELSE cnvtdatetime(zero_dt_tm)
     ENDIF
     , cpu.excluded_dt_nbr =
     IF ((out->qual[i].excluded_ind=1)) out->qual[i].excluded_dt_nbr
     ELSE zero_dt_nbr
     ENDIF
     ,
     cpu.excluded_min_nbr =
     IF ((out->qual[i].excluded_ind=1)) out->qual[i].excluded_min_nbr
     ELSE zero_min_nbr
     ENDIF
     , cpu.excluded_prsnl_id =
     IF ((out->qual[i].excluded_ind=1)) out->qual[i].excluded_prsnl_id
     ELSE 0
     ENDIF
     , cpu.activated_ind = out->qual[i].activated_ind,
     cpu.activated_dt_tm = cnvtdatetime(out->qual[i].activated_dt_tm), cpu.activated_dt_nbr = out->
     qual[i].activated_dt_nbr, cpu.activated_min_nbr = out->qual[i].activated_min_nbr,
     cpu.activated_prsnl_id = out->qual[i].activated_prsnl_id, cpu.start_dt_tm = cnvtdatetime(out->
      qual[i].start_dt_tm), cpu.start_dt_nbr = out->qual[i].start_dt_nbr,
     cpu.start_min_nbr = out->qual[i].start_min_nbr, cpu.end_dt_tm = cnvtdatetime(out->qual[i].
      end_dt_tm), cpu.end_dt_nbr = out->qual[i].end_dt_nbr,
     cpu.end_min_nbr = out->qual[i].end_min_nbr, cpu.required_ind = out->qual[i].required_ind, cpu
     .added_ind = out->qual[i].added_ind,
     cpu.default_incl_ind = out->qual[i].default_incl_ind, cpu.pw_phase_desc = out->qual[i].
     pw_phase_desc, cpu.type_mean = out->qual[i].type_mean,
     cpu.pw_group_nbr = out->qual[i].pw_group_nbr, cpu.pw_cat_group_id = out->qual[i].pw_cat_group_id,
     cpu.pw_group_desc = out->qual[i].pw_group_desc,
     cpu.tf_description = out->qual[i].tf_description, cpu.category_display = out->qual[i].
     category_display, cpu.category_cd = out->qual[i].category_cd,
     cpu.sub_category_display = out->qual[i].sub_category_display, cpu.sub_category_cd = out->qual[i]
     .sub_category_cd, cpu.last_met_ind = 0,
     cpu.last_not_met_ind = 0, cpu.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpu.updt_cnt = 0,
     cpu.updt_id = reqinfo->updt_id, cpu.updt_task = reqinfo->updt_task, cpu.updt_applctx = reqinfo->
     updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET failed = "T"
    GO TO end_program
   ENDIF
 END ;Subroutine
 SUBROUTINE update_to_outcome(i)
   IF ((out->qual[i].status_cd != out_comp_status))
    SET out_status_changed = "Y"
    IF ((out->qual[i].status_cd=comp_included_cd))
     SET out->qual[i].included_prsnl_id = out->qual[i].status_prsnl_id
    ELSEIF ((out->qual[i].status_cd=comp_canceled_cd))
     SET out->qual[i].canceled_prsnl_id = out->qual[i].status_prsnl_id
    ELSEIF ((out->qual[i].status_cd=comp_excluded_cd))
     SET out->qual[i].excluded_ind = 1
     SET out->qual[i].excluded_dt_tm = cnvtdatetime(out->qual[i].status_dt_tm)
     SET out->qual[i].excluded_dt_nbr = out->qual[i].status_dt_nbr
     SET out->qual[i].excluded_min_nbr = out->qual[i].status_min_nbr
     SET out->qual[i].excluded_prsnl_id = out->qual[i].status_prsnl_id
    ENDIF
   ENDIF
   IF ((out->qual[i].pathway_comp_id=0))
    SET out->qual[i].added_ind = 1
   ELSE
    SET out->qual[i].added_ind = 0
   ENDIF
   IF ((out->qual[i].active_ind=0))
    SET out->qual[i].removed_ind = 1
   ELSE
    SET out->qual[i].removed_ind = 0
   ENDIF
   UPDATE  FROM cn_pw_outcome_st cpu
    SET cpu.pw_out_comp_id = out->qual[i].pw_out_comp_id, cpu.pathway_comp_id = out->qual[i].
     pathway_comp_id, cpu.out_comp_description = out->qual[i].out_comp_description,
     cpu.encntr_id = out->qual[i].encntr_id, cpu.person_id = out->qual[i].person_id, cpu.event_cd =
     out->qual[i].event_cd,
     cpu.status_cd =
     IF (out_status_changed="Y") out->qual[i].status_cd
     ELSE cpu.status_cd
     ENDIF
     , cpu.status_dt_tm =
     IF (out_status_changed="Y") cnvtdatetime(out->qual[i].status_dt_tm)
     ELSE cpu.status_dt_tm
     ENDIF
     , cpu.status_dt_nbr =
     IF (out_status_changed="Y") out->qual[i].status_dt_nbr
     ELSE cpu.status_dt_nbr
     ENDIF
     ,
     cpu.status_min_nbr =
     IF (out_status_changed="Y") out->qual[i].status_min_nbr
     ELSE cpu.status_min_nbr
     ENDIF
     , cpu.status_prsnl_id =
     IF (out_status_changed="Y") out->qual[i].status_prsnl_id
     ELSE cpu.status_prsnl_id
     ENDIF
     , cpu.included_ind =
     IF ((out->qual[i].included_ind=1)) out->qual[i].included_ind
     ELSE cpu.included_ind
     ENDIF
     ,
     cpu.included_dt_tm = cnvtdatetime(out->qual[i].included_dt_tm), cpu.included_dt_nbr = out->qual[
     i].included_dt_nbr, cpu.included_min_nbr = out->qual[i].included_min_nbr,
     cpu.included_prsnl_id =
     IF ((out->qual[i].included_prsnl_id != 0)
      AND (out->qual[i].included_prsnl_id != null)) out->qual[i].included_prsnl_id
     ELSE cpu.included_prsnl_id
     ENDIF
     , cpu.excluded_ind =
     IF ((out->qual[i].excluded_ind=1)) out->qual[i].excluded_ind
     ELSE cpu.excluded_ind
     ENDIF
     , cpu.excluded_dt_tm =
     IF ((out->qual[i].excluded_ind=1)) cnvtdatetime(out->qual[i].excluded_dt_tm)
     ELSE cpu.excluded_dt_tm
     ENDIF
     ,
     cpu.excluded_dt_nbr =
     IF ((out->qual[i].excluded_ind=1)) out->qual[i].excluded_dt_nbr
     ELSE cpu.excluded_dt_nbr
     ENDIF
     , cpu.excluded_min_nbr =
     IF ((out->qual[i].excluded_ind=1)) out->qual[i].excluded_min_nbr
     ELSE cpu.excluded_min_nbr
     ENDIF
     , cpu.excluded_prsnl_id =
     IF ((out->qual[i].excluded_ind=1)) out->qual[i].excluded_prsnl_id
     ELSE cpu.excluded_prsnl_id
     ENDIF
     ,
     cpu.canceled_dt_tm = cnvtdatetime(out->qual[i].canceled_dt_tm), cpu.canceled_dt_nbr = out->qual[
     i].canceled_dt_nbr, cpu.canceled_min_nbr = out->qual[i].canceled_min_nbr,
     cpu.canceled_prsnl_id =
     IF ((out->qual[i].canceled_prsnl_id != 0)
      AND (out->qual[i].canceled_prsnl_id != null)) out->qual[i].canceled_prsnl_id
     ELSE cpu.canceled_prsnl_id
     ENDIF
     , cpu.activated_ind =
     IF ((out->qual[i].activated_ind=1)) out->qual[i].activated_ind
     ELSE cpu.activated_ind
     ENDIF
     , cpu.activated_dt_tm = cnvtdatetime(out->qual[i].activated_dt_tm),
     cpu.activated_dt_nbr = out->qual[i].activated_dt_nbr, cpu.activated_min_nbr = out->qual[i].
     activated_min_nbr, cpu.activated_prsnl_id = out->qual[i].activated_prsnl_id,
     cpu.start_dt_tm = cnvtdatetime(out->qual[i].start_dt_tm), cpu.start_dt_nbr = out->qual[i].
     start_dt_nbr, cpu.start_min_nbr = out->qual[i].start_min_nbr,
     cpu.end_dt_tm = cnvtdatetime(out->qual[i].end_dt_tm), cpu.end_dt_nbr = out->qual[i].end_dt_nbr,
     cpu.end_min_nbr = out->qual[i].end_min_nbr,
     cpu.added_ind =
     IF ((out->qual[i].added_ind=1)) out->qual[i].added_ind
     ELSE cpu.added_ind
     ENDIF
     , cpu.removed_ind =
     IF ((out->qual[i].removed_ind=1)) out->qual[i].removed_ind
     ELSE cpu.removed_ind
     ENDIF
     , cpu.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cpu.updt_cnt = (cpu.updt_cnt+ 1), cpu.updt_id = reqinfo->updt_id, cpu.updt_task = reqinfo->
     updt_task,
     cpu.updt_applctx = reqinfo->updt_applctx
    WHERE (cpu.pw_out_comp_id=out->qual[i].pw_out_comp_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = "T"
    GO TO end_program
   ENDIF
 END ;Subroutine
#end_program
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 RETURN(failed)
 FREE RECORD phase
 FREE RECORD pw
 FREE RECORD ord
 FREE RECORD out
 FREE RECORD tf
 FREE RECORD out_ids
 FREE RECORD ord_ids
END GO
