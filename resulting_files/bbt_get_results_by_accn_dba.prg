CREATE PROGRAM bbt_get_results_by_accn:dba
 RECORD reply(
   1 qual[*]
     2 order_id = f8
     2 person_id = f8
     2 service_resource_cd = f8
     2 task_assay_cd = f8
     2 task_assay_mnemonic = vc
     2 event_cd = f8
     2 default_result_type_cd = f8
     2 default_result_type_disp = vc
     2 default_result_type_mean = c12
     2 data_map_ind = i2
     2 max_digits = i4
     2 min_decimal_places = i4
     2 min_digits = i4
     2 result_entry_format = i4
     2 bb_result_processing_cd = f8
     2 bb_result_processing_disp = vc
     2 bb_result_processing_mean = c12
     2 container_id = f8
     2 drawn_dt_tm = dq8
     2 results_cnt = i4
     2 results[*]
       3 perform_result_id = f8
       3 perform_dt_tm = dq8
       3 result_id = f8
       3 bb_result_id = f8
       3 bb_control_cell_cd = f8
       3 bb_control_cell_disp = vc
       3 bb_control_cell_mean = vc
       3 result_status_cd = f8
       3 result_status_disp = vc
       3 result_status_mean = c12
       3 normal_cd = f8
       3 normal_disp = c40
       3 normal_mean = c12
       3 critical_cd = f8
       3 critical_disp = c40
       3 critical_mean = c12
       3 review_cd = f8
       3 delta_cd = f8
       3 normal_low = f8
       3 normal_high = f8
       3 normal_alpha = vc
       3 result_type_cd = f8
       3 result_type_disp = vc
       3 result_type_mean = c12
       3 nomenclature_id = f8
       3 short_string = vc
       3 result_value_mean = c12
       3 result_value_numeric = f8
       3 numeric_raw_value = f8
       3 less_great_flag = i2
       3 result_value_alpha = vc
       3 result_value_dt_tm = dq8
       3 long_text_id = f8
       3 rtf_text = vc
       3 ascii_text = vc
       3 result_comment_ind = i2
       3 result_code_set_cd = f8
       3 result_code_set_disp = c40
       3 perform_result_updt_cnt = i4
       3 result_updt_cnt = i4
       3 interp_option_cd = f8
       3 interp_option_disp = c40
       3 person_aborh_id = f8
       3 result_dt_tm = dq8
       3 result_tech_id = f8
       3 result_tech_username = c50
       3 units_cd = f8
       3 units_disp = c40
       3 normal_range_flag = i2
       3 except_cnt = i4
       3 bb_group_id = f8
       3 bb_group_name = c40
       3 lot_information_id = f8
       3 lot_ident = c40
       3 interp_override_ind = i2
       3 bb_group_id = f8
       3 lot_information_id = f8
       3 notify_cd = f8
       3 notify_disp = vc
       3 notify_mean = c12
       3 exceptlist[*]
         4 exception_id = f8
         4 exception_type_cd = f8
         4 exception_type_disp = vc
         4 exception_type_mean = vc
         4 override_reason_cd = f8
         4 override_reason_disp = vc
         4 override_reason_mean = vc
         4 from_abo_cd = f8
         4 from_rh_cd = f8
         4 to_abo_cd = f8
         4 to_rh_cd = f8
         4 updt_cnt = i4
         4 active_ind = i2
         4 donor_contact_id = f8
         4 donor_contact_type_cd = f8
       3 nomenclature_term = vc
     2 prev_task_assay_cd = f8
     2 prev_task_assay_disp = vc
     2 prev_perform_result_id = f8
     2 prev_result_id = f8
     2 prev_result_status_cd = f8
     2 prev_result_status_disp = vc
     2 prev_result_status_mean = c12
     2 prev_result_type_cd = f8
     2 prev_result_type_disp = vc
     2 prev_result_type_mean = c12
     2 prev_nomenclature_id = f8
     2 prev_result_value_numeric = f8
     2 prev_numeric_raw_value = f8
     2 prev_less_great_flag = i2
     2 prev_result_value_alpha = vc
     2 prev_result_value_dt_tm = dq8
     2 prev_long_text_id = f8
     2 prev_rtf_text = vc
     2 prev_ascii_text = vc
     2 prev_collected_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET data_map_type_flag = 0
 SET nbr_of_assays = size(request->assays,5)
 DECLARE a_cnt = i4
 DECLARE r_cnt = i4
 DECLARE e_cnt = i4 WITH protect, noconstant(0)
 DECLARE idx = i4
 SET retrieve_results_yn = "N"
 SET reply->status_data.status = "F"
 DECLARE max_result_cnt = i4
 SET max_result_cnt = 0
 DECLARE result_status_cs = i4 WITH protect, constant(1901)
 DECLARE result_status_verified_mean = c8 WITH protect, constant("VERIFIED")
 DECLARE result_status_corrected_mean = c9 WITH protect, constant("CORRECTED")
 DECLARE result_status_verified_cd = f8 WITH protect, noconstant(0.0)
 DECLARE result_status_corrected_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(result_status_cs,nullterm(result_status_verified_mean),1,
  result_status_verified_cd)
 IF (stat=1)
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(result_status_cs,nullterm(result_status_corrected_mean),1,
  result_status_corrected_cd)
 IF (stat=1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d.seq, o.seq, o.order_id,
  dta.seq, dta.task_assay_cd, apr.seq,
  default_result_type_disp = uar_get_code_display(apr.default_result_type_cd),
  default_result_type_mean = uar_get_code_meaning(apr.default_result_type_cd), d_dm.seq,
  data_map_resource_exists = decode(dm.seq,"Y","N"), dm.seq, d_dmg.seq,
  data_map_group_exists = decode(dmg.seq,"Y","N"), dmg.seq, results_yn = decode(r.seq,"Y","N"),
  r.seq, r.result_id, pr.seq,
  pr.perform_result_id, result_type_disp = uar_get_code_display(pr.result_type_cd), result_type_mean
   = uar_get_code_meaning(pr.result_type_cd),
  par_seq = decode(par.seq,par.seq,0), person_aborh_id = decode(par.seq,par.person_aborh_id,0.0),
  d_rc.seq,
  rc.seq, result_comment_yn = decode(rc.seq,"Y","N"), ita.service_resource_cd
  FROM (dummyt d  WITH seq = value(nbr_of_assays)),
   orders o,
   (dummyt d_dta  WITH seq = 1),
   discrete_task_assay dta,
   assay_processing_r apr,
   (dummyt d_dm  WITH seq = 1),
   data_map dm,
   (dummyt d_dmg  WITH seq = 1),
   data_map dmg,
   (dummyt d_r  WITH seq = 1),
   result r,
   perform_result pr,
   pcs_lot_information pli,
   bb_qc_group bqg,
   (dummyt d_par  WITH seq = 1),
   person_aborh_result par,
   (dummyt d_rc  WITH seq = 1),
   result_comment rc,
   (dummyt d_ita  WITH seq = 1),
   interp_task_assay ita,
   result_event re,
   prsnl p,
   reference_range_factor rrf,
   container c,
   nomenclature n
  PLAN (d)
   JOIN (o
   WHERE (o.order_id=request->assays[d.seq].order_id))
   JOIN (d_dta
   WHERE d_dta.seq=1)
   JOIN (dta
   WHERE dta.active_ind=1
    AND (dta.task_assay_cd=request->assays[d.seq].task_assay_cd)
    AND dta.task_assay_cd > 0)
   JOIN (apr
   WHERE (apr.service_resource_cd=request->assays[d.seq].service_resource_cd)
    AND apr.active_ind=1
    AND apr.task_assay_cd=dta.task_assay_cd)
   JOIN (d_dm
   WHERE d_dm.seq=1)
   JOIN (dm
   WHERE dm.service_resource_cd=apr.service_resource_cd
    AND dm.active_ind=1
    AND dm.task_assay_cd=apr.task_assay_cd
    AND dm.data_map_type_flag=data_map_type_flag)
   JOIN (d_dmg
   WHERE d_dmg.seq=1)
   JOIN (dmg
   WHERE dmg.service_resource_cd=0.0
    AND dmg.active_ind=1
    AND dmg.task_assay_cd=apr.task_assay_cd
    AND dmg.data_map_type_flag=data_map_type_flag)
   JOIN (d_r
   WHERE d_r.seq=1)
   JOIN (r
   WHERE (r.order_id=request->assays[d.seq].order_id)
    AND (r.task_assay_cd=request->assays[d.seq].task_assay_cd))
   JOIN (pli
   WHERE (pli.lot_information_id= Outerjoin(r.lot_information_id)) )
   JOIN (bqg
   WHERE (bqg.group_id= Outerjoin(r.bb_group_id)) )
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(pr.nomenclature_id)) )
   JOIN (rrf
   WHERE rrf.reference_range_factor_id=pr.reference_range_factor_id)
   JOIN (c
   WHERE c.container_id=pr.container_id)
   JOIN (re
   WHERE re.result_id=pr.result_id
    AND re.event_type_cd=pr.result_status_cd
    AND re.perform_result_id=pr.perform_result_id)
   JOIN (p
   WHERE p.person_id=re.event_personnel_id)
   JOIN (d_par
   WHERE d_par.seq=1)
   JOIN (par
   WHERE par.result_id=r.result_id
    AND par.active_ind=1
    AND ((par.person_aborh_id+ 0) > 0)
    AND ((par.person_aborh_id+ 0) != null))
   JOIN (d_rc
   WHERE d_rc.seq=1)
   JOIN (rc
   WHERE rc.result_id=pr.result_id)
   JOIN (d_ita
   WHERE d_ita.seq=1)
   JOIN (ita
   WHERE ita.task_assay_cd=dta.task_assay_cd
    AND ita.task_assay_cd > 0.0
    AND ita.task_assay_cd != null
    AND ita.order_cat_cd=o.catalog_cd
    AND (((ita.service_resource_cd=request->assays[d.seq].service_resource_cd)) OR (ita
   .service_resource_cd=0))
    AND ita.active_ind=1)
  ORDER BY o.order_id, dta.task_assay_cd, r.result_id,
   re.event_sequence DESC, ita.service_resource_cd
  HEAD REPORT
   stat = alterlist(reply->qual,2), a_cnt = 0, r_cnt = 0
  HEAD o.order_id
   r_cnt = 0
  HEAD dta.task_assay_cd
   r_cnt = 0, a_cnt += 1
   IF (mod(a_cnt,2)=1
    AND a_cnt != 1)
    stat = alterlist(reply->qual,(a_cnt+ 1))
   ENDIF
   reply->qual[a_cnt].task_assay_cd = dta.task_assay_cd, reply->qual[a_cnt].task_assay_mnemonic = dta
   .mnemonic, reply->qual[a_cnt].event_cd = dta.event_cd,
   reply->qual[a_cnt].order_id = o.order_id, reply->qual[a_cnt].person_id = o.person_id, reply->qual[
   a_cnt].service_resource_cd = request->assays[d.seq].service_resource_cd,
   reply->qual[a_cnt].bb_result_processing_cd = dta.bb_result_processing_cd
   IF (data_map_resource_exists="Y")
    reply->qual[a_cnt].data_map_ind = 1, reply->qual[a_cnt].max_digits = dm.max_digits, reply->qual[
    a_cnt].min_decimal_places = dm.min_decimal_places,
    reply->qual[a_cnt].min_digits = dm.min_digits, reply->qual[a_cnt].result_entry_format = dm
    .result_entry_format
   ELSEIF (data_map_group_exists="Y")
    reply->qual[a_cnt].data_map_ind = 1, reply->qual[a_cnt].max_digits = dmg.max_digits, reply->qual[
    a_cnt].min_decimal_places = dmg.min_decimal_places,
    reply->qual[a_cnt].min_digits = dmg.min_digits, reply->qual[a_cnt].result_entry_format = dmg
    .result_entry_format
   ELSE
    reply->qual[a_cnt].data_map_ind = 0
   ENDIF
   reply->qual[a_cnt].default_result_type_cd = apr.default_result_type_cd, reply->qual[a_cnt].
   default_result_type_mean = default_result_type_disp, reply->qual[a_cnt].default_result_type_disp
    = default_result_type_mean,
   reply->qual[a_cnt].container_id = c.container_id, reply->qual[a_cnt].drawn_dt_tm = c.drawn_dt_tm
  HEAD r.result_id
   r_cnt += 1, stat = alterlist(reply->qual[a_cnt].results,r_cnt), reply->qual[a_cnt].results_cnt =
   r_cnt,
   reply->qual[a_cnt].results[r_cnt].perform_result_id = pr.perform_result_id, reply->qual[a_cnt].
   results[r_cnt].perform_dt_tm = pr.perform_dt_tm, reply->qual[a_cnt].results[r_cnt].result_id = r
   .result_id,
   reply->qual[a_cnt].results[r_cnt].bb_result_id = r.bb_result_id, reply->qual[a_cnt].results[r_cnt]
   .bb_control_cell_cd = r.bb_control_cell_cd, reply->qual[a_cnt].results[r_cnt].result_status_cd = r
   .result_status_cd,
   reply->qual[a_cnt].results[r_cnt].result_type_cd = pr.result_type_cd, reply->qual[a_cnt].results[
   r_cnt].result_type_disp = result_type_disp, reply->qual[a_cnt].results[r_cnt].result_type_mean =
   result_type_mean,
   reply->qual[a_cnt].results[r_cnt].normal_cd = pr.normal_cd, reply->qual[a_cnt].results[r_cnt].
   critical_cd = pr.critical_cd, reply->qual[a_cnt].results[r_cnt].review_cd = pr.review_cd,
   reply->qual[a_cnt].results[r_cnt].delta_cd = pr.delta_cd, reply->qual[a_cnt].results[r_cnt].
   normal_low = pr.normal_low, reply->qual[a_cnt].results[r_cnt].normal_high = pr.normal_high,
   reply->qual[a_cnt].results[r_cnt].normal_alpha = pr.normal_alpha, reply->qual[a_cnt].results[r_cnt
   ].nomenclature_id = pr.nomenclature_id, reply->qual[a_cnt].results[r_cnt].nomenclature_term = n
   .source_string_keycap,
   reply->qual[a_cnt].results[r_cnt].result_value_numeric = pr.result_value_numeric, reply->qual[
   a_cnt].results[r_cnt].numeric_raw_value = pr.numeric_raw_value, reply->qual[a_cnt].results[r_cnt].
   result_value_alpha = pr.result_value_alpha,
   reply->qual[a_cnt].results[r_cnt].result_code_set_cd = pr.result_code_set_cd
   IF (pr.result_code_set_cd > 0)
    reply->qual[a_cnt].results[r_cnt].result_value_alpha = uar_get_code_display(pr.result_code_set_cd
     )
   ENDIF
   reply->qual[a_cnt].results[r_cnt].result_value_dt_tm = pr.result_value_dt_tm, reply->qual[a_cnt].
   results[r_cnt].long_text_id = pr.long_text_id, reply->qual[a_cnt].results[r_cnt].ascii_text = pr
   .ascii_text,
   reply->qual[a_cnt].results[r_cnt].less_great_flag = pr.less_great_flag, reply->qual[a_cnt].
   results[r_cnt].perform_result_updt_cnt = pr.updt_cnt, reply->qual[a_cnt].results[r_cnt].units_cd
    = pr.units_cd,
   reply->qual[a_cnt].results[r_cnt].normal_range_flag = rrf.normal_ind, reply->qual[a_cnt].results[
   r_cnt].result_updt_cnt = r.updt_cnt, reply->qual[a_cnt].results[r_cnt].result_dt_tm = re
   .event_dt_tm,
   reply->qual[a_cnt].results[r_cnt].result_tech_id = re.event_personnel_id, reply->qual[a_cnt].
   results[r_cnt].result_tech_username = p.username, reply->qual[a_cnt].results[r_cnt].bb_group_id =
   r.bb_group_id,
   reply->qual[a_cnt].results[r_cnt].lot_information_id = r.lot_information_id, reply->qual[a_cnt].
   results[r_cnt].lot_ident = pli.lot_ident, reply->qual[a_cnt].results[r_cnt].bb_group_name = bqg
   .group_name
   IF (result_comment_yn="Y")
    reply->qual[a_cnt].results[r_cnt].result_comment_ind = 1
   ELSE
    reply->qual[a_cnt].results[r_cnt].result_comment_ind = 0
   ENDIF
   IF (par_seq > 0)
    reply->qual[a_cnt].results[r_cnt].person_aborh_id = par.person_aborh_id
   ENDIF
   reply->qual[a_cnt].results[r_cnt].interp_override_ind = pr.interp_override_ind, reply->qual[a_cnt]
   .results[r_cnt].bb_group_id = r.bb_group_id, reply->qual[a_cnt].results[r_cnt].lot_information_id
    = r.lot_information_id,
   reply->qual[a_cnt].results[r_cnt].notify_cd = pr.notify_cd
  DETAIL
   reply->qual[a_cnt].results[r_cnt].interp_option_cd = ita.interp_option_cd
  FOOT  dta.task_assay_cd
   stat = alterlist(reply->qual[a_cnt].results,r_cnt)
   IF (r_cnt > max_result_cnt)
    max_result_cnt = r_cnt
   ENDIF
  FOOT  o.order_id
   row 0
  WITH nocounter, outerjoin(d_dta), dontcare(dm),
   dontcare(dmg), outerjoin(d_r), dontcare(r),
   outerjoin(d_rc), dontcare(rc), dontcare(pr),
   outerjoin(d_ita), dontcare(par), maxqual(rc,1)
 ;end select
 IF (a_cnt > 0)
  SELECT INTO "nl:"
   d_a.seq, results_cnt = reply->qual[d_a.seq].results_cnt, d_r.seq,
   lt.seq, lt.long_text
   FROM (dummyt d_a  WITH seq = value(a_cnt)),
    (dummyt d_r  WITH seq = value(max_result_cnt)),
    long_text lt
   PLAN (d_a)
    JOIN (d_r
    WHERE d_r.seq > 0
     AND (d_r.seq <= reply->qual[d_a.seq].results_cnt)
     AND (reply->qual[d_a.seq].results[d_r.seq].long_text_id > 0)
     AND (reply->qual[d_a.seq].results[d_r.seq].long_text_id != null))
    JOIN (lt
    WHERE lt.long_text_id > 0
     AND lt.long_text_id != null
     AND (lt.long_text_id=reply->qual[d_a.seq].results[d_r.seq].long_text_id))
   HEAD REPORT
    msg_buf = fillstring(32767," "), retlen = 0
   DETAIL
    IF (lt.seq > 0)
     offset = 0, retlen = 1
     WHILE (retlen > 0)
       retlen = blobget(msg_buf,offset,lt.long_text)
       IF (retlen > 0)
        IF (retlen=size(msg_buf))
         reply->qual[d_a.seq].results[d_r.seq].rtf_text = notrim(concat(reply->qual[d_a.seq].results[
           d_r.seq].rtf_text,msg_buf))
        ELSE
         reply->qual[d_a.seq].results[d_r.seq].rtf_text = notrim(concat(reply->qual[d_a.seq].results[
           d_r.seq].rtf_text,substring(1,retlen,msg_buf)))
        ENDIF
       ENDIF
       offset += retlen
     ENDWHILE
    ENDIF
   WITH nocounter, rdbarrayfetch = 1
  ;end select
  SELECT INTO "nl:"
   d_a.seq, results_cnt = reply->qual[d_a.seq].results_cnt, d_r.seq,
   d_e.seq
   FROM (dummyt d_a  WITH seq = value(a_cnt)),
    (dummyt d_r  WITH seq = value(max_result_cnt)),
    bb_exception be
   PLAN (d_a)
    JOIN (d_r
    WHERE d_r.seq > 0
     AND (d_r.seq <= reply->qual[d_a.seq].results_cnt)
     AND (reply->qual[d_a.seq].results[d_r.seq].perform_result_id > 0)
     AND (reply->qual[d_a.seq].results[d_r.seq].perform_result_id != null))
    JOIN (be
    WHERE (be.result_id=reply->qual[d_a.seq].results[d_r.seq].result_id)
     AND (be.perform_result_id=reply->qual[d_a.seq].results[d_r.seq].perform_result_id))
   HEAD be.perform_result_id
    e_cnt = 0
   DETAIL
    e_cnt += 1, stat = alterlist(reply->qual[d_a.seq].results[d_r.seq].exceptlist,e_cnt), reply->
    qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].exception_id = be.exception_id,
    reply->qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].active_ind = be.active_ind, reply->qual[
    d_a.seq].results[d_r.seq].exceptlist[e_cnt].donor_contact_id = be.donor_contact_id, reply->qual[
    d_a.seq].results[d_r.seq].exceptlist[e_cnt].donor_contact_type_cd = be.donor_contact_type_cd,
    reply->qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].exception_type_cd = be.exception_type_cd,
    reply->qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].from_abo_cd = be.from_abo_cd, reply->
    qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].from_rh_cd = be.from_rh_cd,
    reply->qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].override_reason_cd = be
    .override_reason_cd, reply->qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].to_abo_cd = be
    .to_abo_cd, reply->qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].to_rh_cd = be.to_rh_cd,
    reply->qual[d_a.seq].results[d_r.seq].exceptlist[e_cnt].updt_cnt = be.updt_cnt
   FOOT  be.perform_result_id
    reply->qual[d_a.seq].results[d_r.seq].except_cnt = e_cnt
   WITH nocounter
  ;end select
  IF ((request->return_prev_results_ind=1))
   SELECT INTO "nl:"
    d_a.seq
    FROM (dummyt d_a  WITH seq = value(a_cnt)),
     result r,
     perform_result pr,
     long_text lt,
     container c
    PLAN (d_a)
     JOIN (r
     WHERE (r.person_id=reply->qual[d_a.seq].person_id)
      AND (r.task_assay_cd=reply->qual[d_a.seq].task_assay_cd)
      AND r.result_status_cd IN (result_status_verified_cd, result_status_corrected_cd))
     JOIN (pr
     WHERE pr.result_id=r.result_id
      AND pr.result_status_cd=r.result_status_cd)
     JOIN (lt
     WHERE lt.long_text_id=pr.long_text_id)
     JOIN (c
     WHERE c.container_id=pr.container_id)
    DETAIL
     IF (cnvtdatetime(c.drawn_dt_tm) < cnvtdatetime(reply->qual[d_a.seq].drawn_dt_tm)
      AND cnvtdatetime(c.drawn_dt_tm) > cnvtdatetime(reply->qual[d_a.seq].prev_collected_dt_tm))
      reply->qual[d_a.seq].prev_ascii_text = pr.ascii_text, reply->qual[d_a.seq].prev_collected_dt_tm
       = c.drawn_dt_tm, reply->qual[d_a.seq].prev_less_great_flag = pr.less_great_flag,
      reply->qual[d_a.seq].prev_long_text_id = lt.long_text_id, reply->qual[d_a.seq].
      prev_nomenclature_id = pr.nomenclature_id, reply->qual[d_a.seq].prev_numeric_raw_value = pr
      .numeric_raw_value,
      reply->qual[d_a.seq].prev_perform_result_id = pr.perform_result_id, reply->qual[d_a.seq].
      prev_result_id = r.result_id, reply->qual[d_a.seq].prev_result_status_cd = r.result_status_cd,
      reply->qual[d_a.seq].prev_result_type_cd = pr.result_type_cd, reply->qual[d_a.seq].
      prev_result_value_alpha = pr.result_value_alpha, reply->qual[d_a.seq].prev_result_value_dt_tm
       = pr.result_value_dt_tm,
      reply->qual[d_a.seq].prev_result_value_numeric = pr.result_value_numeric, reply->qual[d_a.seq].
      prev_rtf_text = lt.long_text, reply->qual[d_a.seq].prev_task_assay_cd = r.task_assay_cd
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#resize_reply
 IF (a_cnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  SET a_cnt = 1
 ENDIF
 SET stat = alterlist(reply->qual,a_cnt)
#exit_script
END GO
