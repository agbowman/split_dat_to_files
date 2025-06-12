CREATE PROGRAM bed_get_power_plan_details:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 power_plan_id = f8
    1 display_description = vc
    1 type_mean = vc
    1 display_method
      2 display_method_code_value = f8
      2 display_method_mean = vc
      2 display_method_disp = vc
    1 phase[*]
      2 phase_id = f8
      2 display_description = vc
      2 display_method
        3 display_method_code_value = f8
        3 display_method_mean = vc
        3 display_method_disp = vc
      2 component[*]
        3 comp_id = f8
        3 comp_type = vc
        3 sequence = i4
        3 parent_entity_id = f8
        3 parent_entity_name = vc
        3 comp_description = vc
        3 clin_category
          4 dcp_clin_cat_code_value = f8
          4 dcp_clin_cat_mean = vc
          4 dcp_clin_cat_disp = vc
          4 collation_seq = i4
        3 clin_sub_category
          4 dcp_clin_sub_cat_code_value = f8
          4 dcp_clin_sub_cat_mean = vc
          4 dcp_clin_sub_cat_disp = vc
        3 order_sentence[*]
          4 sequence = i4
          4 order_sentence_id = f8
          4 order_sentence_display_line = vc
          4 os_oe_format_id = f8
          4 rx_type_mean = vc
          4 intermittent_ind = i2
          4 details[*]
            5 value = f8
            5 display = vc
            5 oef_id = f8
            5 sequence = i4
            5 oef_description = vc
            5 field_type_flag = i2
          4 comment = vc
        3 iv_ingredient[*]
          4 synonym_id = f8
          4 mnemonic = vc
          4 iv_sequence = i4
          4 iv_order_sentence
            5 order_sentence_id = f8
            5 order_sentence_display_line = vc
            5 sequence = i4
            5 os_oe_format_id = f8
            5 details[*]
              6 value = f8
              6 display = vc
              6 oef_id = f8
              6 sequence = i4
              6 oef_description = vc
              6 field_type_flag = i2
            5 comment = vc
          4 iv_oe_format_id = f8
          4 rx_mask = i4
          4 has_sentence_ind = i2
        3 catalog_cd = f8
        3 comp_oe_format_id = f8
        3 include_ind = i2
        3 required_ind = i2
        3 evidence_type_mean = vc
        3 evidence_locator = vc
        3 default_os_ind = i2
        3 persistent_ind = i2
        3 intermittent_ind = i2
        3 rx_mask = i4
        3 offset
          4 offset_unit_code_value = f8
          4 offset_unit_display = vc
          4 offset_unit_meaning = vc
          4 offset_quantity = f8
        3 schedule_phases_ind = i2
        3 uuid = vc
        3 synonym_active_ind = i2
        3 synonym_type_code_value = f8
        3 synonym_type_mean = vc
        3 synonym_type_display = vc
        3 synonym_vv[*]
          4 facility_code_value = f8
          4 facility_display = vc
        3 placeholder_id = f8
        3 placeholder_name = vc
        3 placeholder_type_flag = i2
        3 placeholder_required_ind = i2
        3 placeholder_include_ind = i2
        3 has_sentences_ind = i2
      2 sequence = i4
      2 uuid = vc
      2 alerts_on_plan_ind = i2
      2 alerts_on_plan_upd_ind = i2
      2 phase_evidence_type_mean = vc
      2 phase_evidence_locator = vc
      2 ref_text_ind = i2
      2 clin_cat_evidence_links[*]
        3 cat_code_value = f8
        3 cat_mean = vc
        3 cat_disp = vc
        3 cat_evidence_type_mean = vc
        3 cat_evidence_locator = vc
        3 clin_subcat_evidence_links[*]
          4 subcat_code_value = f8
          4 subcat_mean = vc
          4 subcat_disp = vc
          4 subcat_evidence_type_mean = vc
          4 subcat_evidence_locator = vc
    1 subphase_ind = i2
    1 vv_all_facilities_ind = i2
    1 vv_facility[*]
      2 id = f8
      2 display = vc
    1 description = vc
    1 uuid = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 synonyms[*]
      2 display = vc
      2 id = f8
    1 pathway_type
      2 code_value = f8
      2 display = vc
      2 meaning = vc
    1 evidence_type_mean = vc
    1 evidence_locator = vc
    1 cross_encntr_ind = i2
    1 diagnosis_capture_ind = i2
    1 hide_flexed_comp_ind = i2
    1 provider_prompt_ind = i2
    1 allow_copy_forward_ind = i2
    1 ref_text_ind = i2
    1 cycle_ind = i2
    1 updt_cnt = i4
  )
 ENDIF
 RECORD temp(
   1 oclist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_cat_disp = vc
     2 dcp_clin_cat_mean = vc
     2 dcp_clin_cat_seq = i4
     2 dcp_clin_sub_cat_cd = f8
     2 dcp_clin_sub_cat_disp = vc
     2 dcp_clin_sub_cat_mean = vc
     2 ocs_clin_cat_cd = f8
     2 sequence = i4
     2 comp_type_cd = f8
     2 comp_type = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 synonym_id = f8
     2 synonym_type = f8
     2 synonym_type_mean = vc
     2 synonym_type_disp = vc
     2 synonym_active_ind = i2
     2 synonym_vv[*]
       3 fac_code = f8
       3 fac_disp = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 mnemonic = vc
     2 orderable_type_flag = i2
     2 sort_cd = f8
     2 ordsentlist[*]
       3 order_sentence_seq = i4
       3 order_sentence_id = f8
       3 order_sentence_display_line = vc
       3 iv_comp_syn_id = f8
       3 os_oe_format_id = f8
       3 rx_type_mean = vc
       3 intermittent_ind = i2
       3 details[*]
         4 value = f8
         4 display = vc
         4 oef_id = f8
         4 sequence = i4
         4 oef_description = vc
         4 field_type_flag = i2
       3 comment = vc
     2 ingredientlist[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 catalog_cd = f8
       3 comp_seq = i4
       3 iv_oe_format_id = f8
       3 rx_mask = i4
     2 parent_active_ind = i2
     2 comp_oe_format_id = f8
     2 include_ind = i2
     2 required_ind = i2
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 default_os_ind = i2
     2 persistent_ind = i2
     2 intermittent_ind = i2
     2 rx_mask = i4
     2 offset
       3 offset_unit_code_value = f8
       3 offset_unit_display = vc
       3 offset_unit_meaning = vc
       3 offset_quantity = f8
     2 schedule_phases_ind = i2
     2 uuid = vc
   1 ltlist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_cat_disp = vc
     2 dcp_clin_cat_mean = vc
     2 dcp_clin_cat_seq = i4
     2 dcp_clin_sub_cat_cd = f8
     2 dcp_clin_sub_cat_disp = vc
     2 dcp_clin_sub_cat_mean = vc
     2 sequence = i4
     2 comp_type_cd = f8
     2 comp_type = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 sort_cd = f8
     2 comp_text_id = f8
     2 comp_text = vc
     2 comp_text_updt_cnt = i4
     2 include_ind = i2
     2 required_ind = i2
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 default_os_ind = i2
     2 persistent_ind = i2
     2 uuid = vc
     2 placeholder_id = f8
     2 placeholder_name = vc
     2 placeholder_type_flag = i2
     2 placeholder_required_ind = i2
     2 placeholder_include_ind = i2
   1 splist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_cat_disp = vc
     2 dcp_clin_cat_mean = vc
     2 dcp_clin_cat_seq = i4
     2 dcp_clin_sub_cat_cd = f8
     2 dcp_clin_sub_cat_disp = vc
     2 dcp_clin_sub_cat_mean = vc
     2 sequence = i4
     2 comp_type_cd = f8
     2 comp_type = vc
     2 comp_label = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 sort_cd = f8
     2 parent_active_ind = i2
     2 parent_phase_desc = vc
     2 parent_phase_display_desc = vc
     2 include_ind = i2
     2 required_ind = i2
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 default_os_ind = i2
     2 offset
       3 offset_unit_code_value = f8
       3 offset_unit_display = vc
       3 offset_unit_meaning = vc
       3 offset_quantity = f8
     2 schedule_phases_ind = i2
     2 uuid = vc
     2 active_ind = i2
     2 facilities[*]
       3 fac_code = f8
       3 fac_disp = vc
   1 outcomelist[*]
     2 pathway_catalog_id = f8
     2 pathway_comp_id = f8
     2 dcp_clin_cat_cd = f8
     2 dcp_clin_cat_disp = vc
     2 dcp_clin_cat_mean = vc
     2 dcp_clin_cat_seq = i4
     2 dcp_clin_sub_cat_cd = f8
     2 dcp_clin_sub_cat_disp = vc
     2 dcp_clin_sub_cat_mean = vc
     2 sequence = i4
     2 comp_type_cd = f8
     2 comp_type = vc
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 sort_cd = f8
     2 include_ind = i2
     2 required_ind = i2
     2 evidence_type_mean = vc
     2 evidence_locator = vc
     2 uuid = vc
     2 description = vc
 )
 RECORD temp2(
   1 ivlist[*]
     2 pathway_comp_id = f8
     2 synonym_id = f8
     2 catalog_cd = f8
     2 oe_format_id = f8
     2 ingrdlist[*]
       3 synonym_id = f8
       3 catalog_cd = f8
       3 mnemonic = vc
       3 catalog_cd = f8
       3 comp_seq = i4
       3 iv_oe_format_id = f8
       3 rx_mask = i4
 )
 DECLARE phasecnt = i4 WITH noconstant(0), protect
 DECLARE occnt = i4 WITH noconstant(0), protect
 DECLARE otcnt = i4 WITH noconstant(0), protect
 DECLARE ltcnt = i4 WITH noconstant(0), protect
 DECLARE spcnt = i4 WITH noconstant(0), protect
 DECLARE outcomecnt = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE high = i4 WITH noconstant(0), protect
 DECLARE dummy = i4 WITH noconstant(0), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 DECLARE i = i2 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE ingredcnt = i4 WITH noconstant(0), protect
 DECLARE ivcnt = i4 WITH noconstant(0), protect
 DECLARE intermittent_oe_field_id = f8 WITH noconstant(0), protect
 DECLARE order_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"ORDER CREATE")), protect
 DECLARE note_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"NOTE")), protect
 DECLARE subphase_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"SUBPHASE")), protect
 DECLARE prescription_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"PRESCRIPTION")),
 protect
 DECLARE outcome_comp_cd = f8 WITH constant(uar_get_code_by("MEANING",16750,"RESULT OUTCO")), protect
 DECLARE med_ord_ct_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY")), protect
 DECLARE med_ord_at_cd = f8 WITH constant(uar_get_code_by("MEANING",106,"PHARMACY")), protect
 DECLARE clin_cat_display_method_cd = f8 WITH constant(uar_get_code_by("MEANING",30720,"CLINCAT")),
 protect
 DECLARE error_flag = vc
 SET cnt = 0
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET intermittent_oe_field_id = 0.0
 SELECT INTO "nl:"
  FROM order_entry_fields oef
  WHERE oef.oe_field_meaning_id=2070.00
  DETAIL
   intermittent_oe_field_id = oef.oe_field_id
  WITH nocounter
 ;end select
 IF (intermittent_oe_field_id=0.0)
  SET error_flag = "Y"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].targetobjectname = concat(
   "Intermittent oe_field_id not found")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 IF ((request->power_plan_id=0.0))
  GO TO exit_script
 ENDIF
 SET syncnt = 0
 SET totalsyncnt = 0
 SET stat = alterlist(reply->synonyms,10)
 SELECT INTO "nl:"
  pwc.pathway_catalog_id
  FROM pathway_catalog pwc,
   pw_evidence_reltn per,
   pw_cat_synonym pcs,
   ref_text_reltn rtr
  PLAN (pwc
   WHERE (pwc.pathway_catalog_id=request->power_plan_id))
   JOIN (per
   WHERE per.pathway_catalog_id=outerjoin(pwc.pathway_catalog_id)
    AND per.pathway_comp_id=outerjoin(0.0)
    AND per.dcp_clin_cat_cd=outerjoin(0.0)
    AND per.dcp_clin_sub_cat_cd=outerjoin(0.0))
   JOIN (pcs
   WHERE pcs.pathway_catalog_id=outerjoin(pwc.pathway_catalog_id))
   JOIN (rtr
   WHERE rtr.parent_entity_name=outerjoin("PATHWAY_CATALOG")
    AND rtr.parent_entity_id=outerjoin(pwc.pathway_catalog_id)
    AND rtr.active_ind=outerjoin(1)
    AND rtr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND rtr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY pwc.pathway_catalog_id, pcs.pw_cat_synonym_id
  HEAD pwc.pathway_catalog_id
   reply->power_plan_id = pwc.pathway_catalog_id, reply->type_mean = pwc.type_mean, reply->
   display_description = pwc.display_description,
   reply->description = pwc.description, reply->display_method.display_method_code_value = pwc
   .display_method_cd, reply->display_method.display_method_disp = uar_get_code_display(pwc
    .display_method_cd),
   reply->display_method.display_method_mean = uar_get_code_meaning(pwc.display_method_cd), reply->
   subphase_ind = pwc.sub_phase_ind, reply->uuid = pwc.pathway_uuid,
   reply->pathway_type.code_value = pwc.pathway_type_cd, reply->pathway_type.display =
   uar_get_code_display(pwc.pathway_type_cd), reply->pathway_type.meaning = uar_get_code_meaning(pwc
    .pathway_type_cd)
   IF (per.type_mean IN ("URL", "ZYNX"))
    reply->evidence_locator = per.evidence_locator, reply->evidence_type_mean = per.type_mean
   ENDIF
   reply->cross_encntr_ind = pwc.cross_encntr_ind, reply->diagnosis_capture_ind = pwc
   .diagnosis_capture_ind, reply->hide_flexed_comp_ind = pwc.hide_flexed_comp_ind,
   reply->provider_prompt_ind = pwc.provider_prompt_ind, reply->allow_copy_forward_ind = pwc
   .allow_copy_forward_ind, reply->cycle_ind = pwc.cycle_ind,
   reply->updt_cnt = pwc.updt_cnt
  HEAD pcs.pw_cat_synonym_id
   IF (pcs.synonym_name > " "
    AND pcs.synonym_name != pwc.display_description)
    syncnt = (syncnt+ 1), totalsyncnt = (totalsyncnt+ 1)
    IF (syncnt > 10)
     stat = alterlist(reply->synonyms,(syncnt+ 10)), syncnt = 1
    ENDIF
    reply->synonyms[totalsyncnt].display = pcs.synonym_name, reply->synonyms[totalsyncnt].id = pcs
    .pw_cat_synonym_id
   ENDIF
  HEAD rtr.ref_text_reltn_id
   IF (rtr.ref_text_reltn_id > 0)
    reply->ref_text_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->synonyms,totalsyncnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 SET facility_count = 0
 SET alter_facility_count = 0
 SELECT INTO "nl:"
  FROM pw_cat_flex p,
   code_value c
  PLAN (p
   WHERE (p.pathway_catalog_id=request->power_plan_id)
    AND p.parent_entity_name="CODE_VALUE")
   JOIN (c
   WHERE c.code_value=p.parent_entity_id)
  HEAD REPORT
   stat = alterlist(reply->vv_facility,10), facility_count = 0, alter_facility_count = 0
  DETAIL
   IF (c.code_value=0.0)
    reply->vv_all_facilities_ind = 1
   ENDIF
   IF (c.active_ind=1)
    facility_count = (facility_count+ 1), alter_facility_count = (alter_facility_count+ 1)
    IF (alter_facility_count > 10)
     stat = alterlist(reply->vv_facility,(facility_count+ 10)), alter_facility_count = 1
    ENDIF
    reply->vv_facility[facility_count].id = p.parent_entity_id, reply->vv_facility[facility_count].
    display = c.display
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->vv_facility,facility_count)
  WITH nocounter
 ;end select
 IF ((((reply->type_mean="CAREPLAN")) OR ((((reply->type_mean="PHASE")) OR ((reply->type_mean=
 "TAPERPLAN"))) )) )
  SET stat = alterlist(reply->phase,1)
  SET reply->phase[1].phase_id = reply->power_plan_id
  SET reply->phase[1].display_description = reply->display_description
  SET reply->phase[1].display_method.display_method_disp = reply->display_method.display_method_disp
  SET reply->phase[1].display_method.display_method_code_value = reply->display_method.
  display_method_code_value
  SET reply->phase[1].display_method.display_method_mean = reply->display_method.display_method_mean
  SET reply->phase[1].uuid = reply->uuid
 ELSEIF ((reply->type_mean="PATHWAY"))
  SELECT INTO "nl:"
   FROM pathway_catalog pwc,
    pw_cat_reltn pcr1,
    pw_cat_reltn pcr2,
    pw_evidence_reltn per,
    ref_text_reltn rtr
   PLAN (pcr1
    WHERE (pcr1.pw_cat_s_id=reply->power_plan_id)
     AND pcr1.type_mean="GROUP")
    JOIN (pwc
    WHERE pwc.pathway_catalog_id=pcr1.pw_cat_t_id)
    JOIN (pcr2
    WHERE pcr2.pw_cat_s_id=outerjoin(pwc.pathway_catalog_id))
    JOIN (per
    WHERE per.pathway_catalog_id=outerjoin(pwc.pathway_catalog_id)
     AND per.pathway_comp_id=outerjoin(0.0)
     AND per.dcp_clin_cat_cd=outerjoin(0.0)
     AND per.dcp_clin_sub_cat_cd=outerjoin(0.0))
    JOIN (rtr
    WHERE rtr.parent_entity_name=outerjoin("PATHWAY_CATALOG")
     AND rtr.parent_entity_id=outerjoin(pwc.pathway_catalog_id)
     AND rtr.active_ind=outerjoin(1)
     AND rtr.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND rtr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
   ORDER BY pcr1.pw_cat_t_id, pcr2.pw_cat_t_id, per.pathway_catalog_id
   HEAD REPORT
    phasecnt = 0
   HEAD pcr1.pw_cat_t_id
    phasecnt = (phasecnt+ 1)
    IF (phasecnt > size(reply->phase,5))
     stat = alterlist(reply->phase,(phasecnt+ 10))
    ENDIF
    reply->phase[phasecnt].phase_id = pwc.pathway_catalog_id, reply->phase[phasecnt].
    display_description = pwc.description, reply->phase[phasecnt].display_method.
    display_method_code_value = pwc.display_method_cd,
    reply->phase[phasecnt].display_method.display_method_mean = uar_get_code_meaning(pwc
     .display_method_cd), reply->phase[phasecnt].display_method.display_method_disp =
    uar_get_code_display(pwc.display_method_cd), reply->phase[phasecnt].uuid = pwc.pathway_uuid,
    reply->phase[phasecnt].alerts_on_plan_ind = pwc.alerts_on_plan_ind, reply->phase[phasecnt].
    alerts_on_plan_upd_ind = pwc.alerts_on_plan_upd_ind
    IF (per.type_mean IN ("URL", "ZYNX"))
     reply->phase[phasecnt].phase_evidence_locator = per.evidence_locator, reply->phase[phasecnt].
     phase_evidence_type_mean = per.type_mean
    ENDIF
   HEAD rtr.ref_text_reltn_id
    IF (rtr.ref_text_reltn_id > 0)
     reply->phase[phasecnt].ref_text_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->phase,phasecnt)
   WITH nocounter
  ;end select
  IF (curqual=0)
   GO TO exit_script
  ENDIF
  SET parent_id = 0.0
  SET p_id = 0.0
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(reply->phase,5))),
    pw_cat_reltn pcr1
   PLAN (d
    WHERE size(reply->phase,5) > 0)
    JOIN (pcr1
    WHERE (pcr1.pw_cat_s_id=reply->phase[d.seq].phase_id)
     AND pcr1.type_mean="SUCCEED"
     AND  NOT ( EXISTS (
    (SELECT
     pcr.pw_cat_t_id
     FROM pw_cat_reltn pcr
     WHERE pcr.type_mean="SUCCEED"
      AND pcr.pw_cat_t_id=pcr1.pw_cat_s_id))))
   DETAIL
    parent_id = pcr1.pw_cat_s_id, reply->phase[d.seq].sequence = 1
   WITH nocounter
  ;end select
  SET p_id = parent_id
  SET s = 1
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = (value(size(reply->phase,5)) - 1)),
    pw_cat_reltn pcr
   PLAN (d)
    JOIN (pcr
    WHERE pcr.pw_cat_s_id=p_id
     AND pcr.type_mean="SUCCEED")
   HEAD d.seq
    p_id = pcr.pw_cat_t_id, s = (s+ 1), d = 0,
    index = locateval(d,1,size(reply->phase,5),pcr.pw_cat_t_id,reply->phase[d].phase_id), reply->
    phase[index].sequence = s
   WITH nocounter
  ;end select
 ENDIF
 SET high = value(size(reply->phase,5))
 SELECT INTO "nl:"
  FROM pathway_comp pc,
   code_value cv1,
   code_value cv2,
   pw_evidence_reltn per,
   code_value cv3,
   outcome_catalog oc
  PLAN (pc
   WHERE expand(num,1,high,pc.pathway_catalog_id,reply->phase[num].phase_id)
    AND pc.active_ind=1)
   JOIN (cv1
   WHERE cv1.code_value=pc.dcp_clin_cat_cd)
   JOIN (cv2
   WHERE cv2.code_value=pc.dcp_clin_sub_cat_cd)
   JOIN (per
   WHERE per.pathway_catalog_id=outerjoin(pc.pathway_catalog_id)
    AND per.pathway_comp_id=outerjoin(pc.pathway_comp_id)
    AND per.dcp_clin_cat_cd=outerjoin(0.0)
    AND per.dcp_clin_sub_cat_cd=outerjoin(0.0))
   JOIN (cv3
   WHERE cv3.code_value=outerjoin(pc.offset_unit_cd))
   JOIN (oc
   WHERE oc.outcome_catalog_id=outerjoin(pc.parent_entity_id))
  ORDER BY pc.pathway_catalog_id, pc.parent_entity_id
  HEAD REPORT
   occnt = 0, ocsize = 0, ltcnt = 0,
   spcnt = 0, outcomecnt = 0, idx = 0,
   displaymethodcd = 0
  HEAD pc.pathway_catalog_id
   idx = locateval(idx,1,high,pc.pathway_catalog_id,reply->phase[idx].phase_id), displaymethodcd =
   reply->phase[idx].display_method.display_method_code_value
  DETAIL
   IF (pc.comp_type_cd IN (order_comp_cd, prescription_comp_cd))
    occnt = (occnt+ 1)
    IF (occnt > ocsize)
     ocsize = (ocsize+ 20), stat = alterlist(temp->oclist,ocsize)
    ENDIF
    temp->oclist[occnt].pathway_catalog_id = pc.pathway_catalog_id, temp->oclist[occnt].
    pathway_comp_id = pc.pathway_comp_id, temp->oclist[occnt].dcp_clin_cat_cd = pc.dcp_clin_cat_cd,
    temp->oclist[occnt].dcp_clin_cat_disp = cv1.display, temp->oclist[occnt].dcp_clin_cat_mean = cv1
    .cdf_meaning, temp->oclist[occnt].dcp_clin_cat_seq = cv1.collation_seq,
    temp->oclist[occnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->oclist[occnt].
    dcp_clin_sub_cat_disp = cv2.display, temp->oclist[occnt].dcp_clin_sub_cat_mean = cv2.cdf_meaning,
    temp->oclist[occnt].sequence = pc.sequence, temp->oclist[occnt].comp_type_cd = pc.comp_type_cd,
    temp->oclist[occnt].parent_entity_name = pc.parent_entity_name,
    temp->oclist[occnt].parent_entity_id = pc.parent_entity_id
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->oclist[occnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
    temp->oclist[occnt].include_ind = pc.include_ind, temp->oclist[occnt].required_ind = pc
    .required_ind
    IF (per.type_mean IN ("ZYNX", "URL"))
     temp->oclist[occnt].evidence_type_mean = per.type_mean, temp->oclist[occnt].evidence_locator =
     per.evidence_locator
    ENDIF
    temp->oclist[occnt].default_os_ind = pc.default_os_ind, temp->oclist[occnt].offset.
    offset_quantity = pc.offset_quantity, temp->oclist[occnt].offset.offset_unit_code_value = pc
    .offset_unit_cd,
    temp->oclist[occnt].offset.offset_unit_display = cv3.display, temp->oclist[occnt].offset.
    offset_unit_meaning = cv3.description, temp->oclist[occnt].uuid = pc.pathway_uuid
   ELSEIF (pc.comp_type_cd=note_comp_cd)
    ltcnt = (ltcnt+ 1)
    IF (ltcnt > size(temp->ltlist,5))
     stat = alterlist(temp->ltlist,(ltcnt+ 10))
    ENDIF
    temp->ltlist[ltcnt].pathway_catalog_id = pc.pathway_catalog_id, temp->ltlist[ltcnt].
    pathway_comp_id = pc.pathway_comp_id, temp->ltlist[ltcnt].dcp_clin_cat_cd = pc.dcp_clin_cat_cd,
    temp->ltlist[ltcnt].dcp_clin_cat_disp = cv1.display, temp->ltlist[ltcnt].dcp_clin_cat_mean = cv1
    .cdf_meaning, temp->ltlist[ltcnt].dcp_clin_cat_seq = cv1.collation_seq,
    temp->ltlist[ltcnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->ltlist[ltcnt].
    dcp_clin_sub_cat_disp = cv2.display, temp->ltlist[ltcnt].dcp_clin_sub_cat_mean = cv2.cdf_meaning,
    temp->ltlist[ltcnt].sequence = pc.sequence, temp->ltlist[ltcnt].comp_type_cd = pc.comp_type_cd,
    temp->ltlist[ltcnt].comp_type = "NOTE",
    temp->ltlist[ltcnt].parent_entity_name = pc.parent_entity_name, temp->ltlist[ltcnt].
    parent_entity_id = pc.parent_entity_id
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->ltlist[ltcnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
    temp->ltlist[ltcnt].include_ind = pc.include_ind, temp->ltlist[ltcnt].required_ind = pc
    .required_ind
    IF (per.type_mean IN ("ZYNX", "URL"))
     temp->ltlist[ltcnt].evidence_type_mean = per.type_mean, temp->ltlist[ltcnt].evidence_locator =
     per.evidence_locator
    ENDIF
    temp->ltlist[ltcnt].default_os_ind = pc.default_os_ind, temp->ltlist[ltcnt].persistent_ind = pc
    .persistent_ind, temp->ltlist[ltcnt].uuid = pc.pathway_uuid
   ELSEIF (pc.comp_type_cd=subphase_comp_cd)
    spcnt = (spcnt+ 1)
    IF (spcnt > size(temp->splist,5))
     stat = alterlist(temp->splist,(spcnt+ 10))
    ENDIF
    temp->splist[spcnt].pathway_catalog_id = pc.pathway_catalog_id, temp->splist[spcnt].
    pathway_comp_id = pc.pathway_comp_id, temp->splist[spcnt].dcp_clin_cat_cd = pc.dcp_clin_cat_cd,
    temp->splist[spcnt].dcp_clin_cat_disp = cv1.display, temp->splist[spcnt].dcp_clin_cat_mean = cv1
    .cdf_meaning, temp->splist[spcnt].dcp_clin_cat_seq = cv1.collation_seq,
    temp->splist[spcnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->splist[spcnt].
    dcp_clin_sub_cat_disp = cv2.display, temp->splist[spcnt].dcp_clin_sub_cat_mean = cv2.cdf_meaning,
    temp->splist[spcnt].sequence = pc.sequence, temp->splist[spcnt].comp_type_cd = pc.comp_type_cd,
    temp->splist[spcnt].comp_type = "SUBPHASE",
    temp->splist[spcnt].parent_entity_name = pc.parent_entity_name, temp->splist[spcnt].
    parent_entity_id = pc.parent_entity_id
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->splist[spcnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
    temp->splist[spcnt].include_ind = pc.include_ind, temp->splist[spcnt].required_ind = pc
    .required_ind
    IF (per.type_mean IN ("ZYNX", "URL"))
     temp->splist[spcnt].evidence_type_mean = per.type_mean, temp->splist[spcnt].evidence_locator =
     per.evidence_locator
    ENDIF
    temp->splist[spcnt].default_os_ind = pc.default_os_ind, temp->splist[spcnt].offset.
    offset_quantity = pc.offset_quantity, temp->splist[spcnt].offset.offset_unit_code_value = pc
    .offset_unit_cd,
    temp->splist[spcnt].offset.offset_unit_display = cv3.display, temp->splist[spcnt].offset.
    offset_unit_meaning = cv3.description, temp->splist[spcnt].uuid = pc.pathway_uuid
   ELSEIF (pc.comp_type_cd=outcome_comp_cd)
    outcomecnt = (outcomecnt+ 1)
    IF (outcomecnt > size(temp->outcomelist,5))
     stat = alterlist(temp->outcomelist,(outcomecnt+ 10))
    ENDIF
    temp->outcomelist[outcomecnt].pathway_catalog_id = pc.pathway_catalog_id, temp->outcomelist[
    outcomecnt].pathway_comp_id = pc.pathway_comp_id, temp->outcomelist[outcomecnt].dcp_clin_cat_cd
     = pc.dcp_clin_cat_cd,
    temp->outcomelist[outcomecnt].dcp_clin_cat_disp = cv1.display, temp->outcomelist[outcomecnt].
    dcp_clin_cat_mean = cv1.cdf_meaning, temp->outcomelist[outcomecnt].dcp_clin_cat_seq = cv1
    .collation_seq,
    temp->outcomelist[outcomecnt].dcp_clin_sub_cat_cd = pc.dcp_clin_sub_cat_cd, temp->outcomelist[
    outcomecnt].dcp_clin_sub_cat_disp = cv2.display, temp->outcomelist[outcomecnt].
    dcp_clin_sub_cat_mean = cv2.cdf_meaning,
    temp->outcomelist[outcomecnt].sequence = pc.sequence, temp->outcomelist[outcomecnt].comp_type_cd
     = pc.comp_type_cd, temp->outcomelist[outcomecnt].comp_type = "OUTCOME",
    temp->outcomelist[outcomecnt].parent_entity_name = pc.parent_entity_name, temp->outcomelist[
    outcomecnt].parent_entity_id = pc.parent_entity_id, temp->outcomelist[outcomecnt].description =
    oc.description
    IF (displaymethodcd IN (clin_cat_display_method_cd, 0))
     temp->outcomelist[outcomecnt].sort_cd = pc.dcp_clin_cat_cd
    ENDIF
    temp->outcomelist[outcomecnt].include_ind = pc.include_ind, temp->outcomelist[outcomecnt].
    required_ind = pc.required_ind
    IF (per.type_mean IN ("ZYNX", "URL"))
     temp->outcomelist[outcomecnt].evidence_type_mean = per.type_mean, temp->outcomelist[outcomecnt].
     evidence_locator = per.evidence_locator
    ENDIF
    temp->outcomelist[outcomecnt].uuid = pc.pathway_uuid
   ENDIF
  FOOT REPORT
   IF (occnt > 0
    AND occnt < ocsize)
    stat = alterlist(temp->oclist,occnt)
   ENDIF
   IF (ltcnt > 0)
    stat = alterlist(temp->ltlist,ltcnt)
   ENDIF
   IF (spcnt > 0)
    stat = alterlist(temp->splist,spcnt)
   ENDIF
   IF (outcomecnt > 0)
    stat = alterlist(temp->outcomelist,outcomecnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (occnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = occnt),
    pw_comp_cat_reltn pwccr
   PLAN (d)
    JOIN (pwccr
    WHERE (pwccr.pathway_comp_id=temp->oclist[d.seq].pathway_comp_id)
     AND pwccr.type_mean="SCHEDANCHOR")
   DETAIL
    temp->oclist[d.seq].schedule_phases_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (spcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = spcnt),
    pw_comp_cat_reltn pwccr
   PLAN (d)
    JOIN (pwccr
    WHERE (pwccr.pathway_comp_id=temp->splist[d.seq].pathway_comp_id)
     AND pwccr.type_mean="SCHEDANCHOR")
   DETAIL
    temp->splist[d.seq].schedule_phases_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (value(size(temp->ltlist,5)) > 0)
  SET high = value(size(temp->ltlist,5))
  SELECT INTO "nl:"
   FROM long_text lt
   PLAN (lt
    WHERE expand(num,1,high,lt.long_text_id,temp->ltlist[num].parent_entity_id)
     AND lt.parent_entity_name="PATHWAY_COMP")
   HEAD REPORT
    idx = 0
   DETAIL
    idx = locateval(idx,1,high,lt.long_text_id,temp->ltlist[idx].parent_entity_id), temp->ltlist[idx]
    .comp_text_id = lt.long_text_id, temp->ltlist[idx].comp_text = trim(lt.long_text),
    temp->ltlist[idx].comp_text_updt_cnt = lt.updt_cnt
   FOOT REPORT
    idx = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(high)),
    br_pw_comp_placehldr_r r,
    br_pw_comp_placehldr b
   PLAN (d)
    JOIN (r
    WHERE (r.pathway_uuid=temp->ltlist[d.seq].uuid))
    JOIN (b
    WHERE b.br_pw_comp_placehldr_id=r.br_pw_comp_placehldr_id)
   ORDER BY d.seq
   DETAIL
    temp->ltlist[d.seq].placeholder_id = b.br_pw_comp_placehldr_id, temp->ltlist[d.seq].
    placeholder_include_ind = r.include_ind, temp->ltlist[d.seq].placeholder_name = b.placehldr_name,
    temp->ltlist[d.seq].placeholder_required_ind = r.required_ind, temp->ltlist[d.seq].
    placeholder_type_flag = b.comp_type_flag, temp->ltlist[d.seq].comp_text = b.placehldr_name,
    temp->ltlist[d.seq].comp_type = "PLACEHOLDER"
   WITH nocounter
  ;end select
 ENDIF
 IF (value(size(temp->oclist,5)) > 0)
  SET high = value(size(temp->oclist,5))
  SELECT INTO "nl:"
   ocs.mnemonic, ocs.synonym_id
   FROM order_catalog_synonym ocs,
    order_catalog oc,
    code_value cv
   PLAN (ocs
    WHERE expand(num,1,high,ocs.synonym_id,temp->oclist[num].parent_entity_id))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
    JOIN (cv
    WHERE cv.code_value=ocs.mnemonic_type_cd
     AND cv.active_ind=1)
   ORDER BY ocs.synonym_id
   HEAD REPORT
    idx = 0, ivcnt = 0
   HEAD ocs.synonym_id
    idx = locateval(idx,1,high,ocs.synonym_id,temp->oclist[idx].parent_entity_id), temp->oclist[idx].
    synonym_id = ocs.synonym_id, temp->oclist[idx].synonym_type_disp = cv.display,
    temp->oclist[idx].synonym_type_mean = cv.cdf_meaning, temp->oclist[idx].synonym_active_ind = ocs
    .active_ind, temp->oclist[idx].synonym_type = ocs.mnemonic_type_cd,
    temp->oclist[idx].catalog_cd = ocs.catalog_cd, temp->oclist[idx].catalog_type_cd = ocs
    .catalog_type_cd, temp->oclist[idx].activity_type_cd = ocs.activity_type_cd,
    temp->oclist[idx].mnemonic = trim(ocs.mnemonic), temp->oclist[idx].ocs_clin_cat_cd = ocs
    .dcp_clin_cat_cd, temp->oclist[idx].orderable_type_flag = ocs.orderable_type_flag,
    temp->oclist[idx].comp_oe_format_id = ocs.oe_format_id
    IF ((temp->oclist[idx].comp_type_cd=prescription_comp_cd))
     temp->oclist[idx].comp_type = "PRESCRIPTION", temp->oclist[idx].rx_mask = ocs.rx_mask
    ELSEIF ((temp->oclist[idx].comp_type_cd=order_comp_cd))
     IF (ocs.orderable_type_flag IN (8, 11))
      temp->oclist[idx].comp_type = "IV", ivcnt = (ivcnt+ 1), stat = alterlist(temp2->ivlist,ivcnt),
      temp2->ivlist[ivcnt].pathway_comp_id = temp->oclist[idx].pathway_comp_id, temp2->ivlist[ivcnt].
      synonym_id = temp->oclist[idx].synonym_id, temp2->ivlist[ivcnt].catalog_cd = temp->oclist[idx].
      catalog_cd,
      temp2->ivlist[ivcnt].oe_format_id = temp->oclist[idx].comp_oe_format_id
     ELSEIF (ocs.catalog_type_cd=med_ord_ct_cd
      AND ocs.activity_type_cd=med_ord_at_cd
      AND ocs.orderable_type_flag IN (0, 1))
      temp->oclist[idx].comp_type = "MED", temp->oclist[idx].intermittent_ind = ocs.intermittent_ind,
      temp->oclist[idx].rx_mask = ocs.rx_mask
     ELSE
      temp->oclist[idx].comp_type = "NONMED"
     ENDIF
    ENDIF
   FOOT  ocs.synonym_id
    idx2 = idx
    WHILE (idx != 0)
     idx2 = locateval(idx2,(idx+ 1),high,ocs.synonym_id,temp->oclist[idx2].parent_entity_id),
     IF (idx2 != 0)
      idx = idx2, temp->oclist[idx].synonym_id = ocs.synonym_id, temp->oclist[idx].synonym_active_ind
       = ocs.active_ind,
      temp->oclist[idx].synonym_type_disp = cv.display, temp->oclist[idx].synonym_type_mean = cv
      .cdf_meaning, temp->oclist[idx].synonym_type = ocs.mnemonic_type_cd,
      temp->oclist[idx].catalog_cd = ocs.catalog_cd, temp->oclist[idx].catalog_type_cd = ocs
      .catalog_type_cd, temp->oclist[idx].activity_type_cd = ocs.activity_type_cd,
      temp->oclist[idx].mnemonic = trim(ocs.mnemonic), temp->oclist[idx].ocs_clin_cat_cd = ocs
      .dcp_clin_cat_cd, temp->oclist[idx].orderable_type_flag = ocs.orderable_type_flag,
      temp->oclist[idx].comp_oe_format_id = ocs.oe_format_id, temp->oclist[idx].rx_mask = ocs.rx_mask,
      temp->oclist[idx].intermittent_ind = ocs.intermittent_ind
      IF ((temp->oclist[idx].comp_type_cd=prescription_comp_cd))
       temp->oclist[idx].comp_type = "PRESCRIPTION"
      ELSEIF ((temp->oclist[idx].comp_type_cd=order_comp_cd))
       IF (ocs.orderable_type_flag IN (8, 11))
        temp->oclist[idx].comp_type = "IV", ivcnt = (ivcnt+ 1), stat = alterlist(temp2->ivlist,ivcnt),
        temp2->ivlist[ivcnt].pathway_comp_id = temp->oclist[idx].pathway_comp_id, temp2->ivlist[ivcnt
        ].synonym_id = temp->oclist[idx].synonym_id, temp2->ivlist[ivcnt].catalog_cd = temp->oclist[
        idx].catalog_cd
       ELSEIF (ocs.catalog_type_cd=med_ord_ct_cd
        AND ocs.activity_type_cd=med_ord_at_cd
        AND ocs.orderable_type_flag IN (0, 1))
        temp->oclist[idx].comp_type = "MED"
       ELSE
        temp->oclist[idx].comp_type = "NONMED"
       ENDIF
      ENDIF
     ELSE
      idx = idx2
     ENDIF
    ENDWHILE
   FOOT REPORT
    idx = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(size(temp->oclist,5))),
    ocs_facility_r ofr,
    code_value cv
   PLAN (d)
    JOIN (ofr
    WHERE (ofr.synonym_id=temp->oclist[d.seq].parent_entity_id))
    JOIN (cv
    WHERE cv.code_value=outerjoin(ofr.facility_cd)
     AND cv.active_ind=outerjoin(1))
   ORDER BY d.seq, cv.code_value
   HEAD d.seq
    vv_cnt = 0
   HEAD cv.code_value
    IF (((cv.code_value > 0.0) OR (ofr.facility_cd=0.0)) )
     vv_cnt = (vv_cnt+ 1), stat = alterlist(temp->oclist[d.seq].synonym_vv,vv_cnt), temp->oclist[d
     .seq].synonym_vv[vv_cnt].fac_code = cv.code_value,
     temp->oclist[d.seq].synonym_vv[vv_cnt].fac_disp = cv.display
    ENDIF
   WITH nocounter
  ;end select
  IF (value(size(temp2->ivlist,5)) > 0)
   SET high = value(size(temp2->ivlist,5))
   SELECT INTO "nl:"
    FROM cs_component cc,
     order_catalog_synonym ocs
    PLAN (cc
     WHERE expand(num,1,high,cc.catalog_cd,temp2->ivlist[num].catalog_cd))
     JOIN (ocs
     WHERE ocs.synonym_id=cc.comp_id
      AND ocs.active_ind=1)
    ORDER BY cc.catalog_cd, cc.comp_seq
    HEAD REPORT
     idx = 0
    HEAD cc.catalog_cd
     ingredcnt = 0
    HEAD cc.comp_seq
     dummy = 0
    DETAIL
     ingredcnt = (ingredcnt+ 1), idx = locateval(idx,1,high,cc.catalog_cd,temp2->ivlist[idx].
      catalog_cd), stat = alterlist(temp2->ivlist[idx].ingrdlist,ingredcnt),
     temp2->ivlist[idx].ingrdlist[ingredcnt].synonym_id = ocs.synonym_id, temp2->ivlist[idx].
     ingrdlist[ingredcnt].catalog_cd = ocs.catalog_cd, temp2->ivlist[idx].ingrdlist[ingredcnt].
     mnemonic = trim(ocs.mnemonic),
     temp2->ivlist[idx].ingrdlist[ingredcnt].catalog_cd = ocs.catalog_cd, temp2->ivlist[idx].
     ingrdlist[ingredcnt].comp_seq = cc.comp_seq, temp2->ivlist[idx].ingrdlist[ingredcnt].
     iv_oe_format_id = ocs.oe_format_id,
     temp2->ivlist[idx].ingrdlist[ingredcnt].rx_mask = ocs.rx_mask, idx2 = idx
     WHILE (idx != 0)
      idx2 = locateval(idx2,(idx+ 1),high,cc.catalog_cd,temp2->ivlist[idx2].catalog_cd),
      IF (idx2 != 0)
       idx = idx2, stat = alterlist(temp2->ivlist[idx].ingrdlist,ingredcnt), temp2->ivlist[idx].
       ingrdlist[ingredcnt].synonym_id = ocs.synonym_id,
       temp2->ivlist[idx].ingrdlist[ingredcnt].catalog_cd = ocs.catalog_cd, temp2->ivlist[idx].
       ingrdlist[ingredcnt].mnemonic = trim(ocs.mnemonic), temp2->ivlist[idx].ingrdlist[ingredcnt].
       catalog_cd = ocs.catalog_cd,
       temp2->ivlist[idx].ingrdlist[ingredcnt].comp_seq = cc.comp_seq, temp2->ivlist[idx].ingrdlist[
       ingredcnt].iv_oe_format_id = ocs.oe_format_id, temp2->ivlist[idx].ingrdlist[ingredcnt].rx_mask
        = ocs.rx_mask
      ELSE
       idx = idx2
      ENDIF
     ENDWHILE
    FOOT  cc.catalog_cd
     ingredcnt = ingredcnt
    FOOT REPORT
     idx = 0
    WITH nocounter
   ;end select
   SET ivcnt = value(size(temp2->ivlist,5))
   SET high = value(size(temp->oclist,5))
   FOR (i = 1 TO ivcnt)
     SET num = 0
     SET idx = 0
     SET ingredcnt = value(size(temp2->ivlist[i].ingrdlist,5))
     SET idx = locateval(num,1,high,temp2->ivlist[i].pathway_comp_id,temp->oclist[num].
      pathway_comp_id)
     SET stat = alterlist(temp->oclist[idx].ingredientlist,ingredcnt)
     FOR (j = 1 TO ingredcnt)
       SET temp->oclist[idx].ingredientlist[j].synonym_id = temp2->ivlist[i].ingrdlist[j].synonym_id
       SET temp->oclist[idx].ingredientlist[j].mnemonic = trim(temp2->ivlist[i].ingrdlist[j].mnemonic
        )
       SET temp->oclist[idx].ingredientlist[j].catalog_cd = temp2->ivlist[i].ingrdlist[j].catalog_cd
       SET temp->oclist[idx].ingredientlist[j].comp_seq = temp2->ivlist[i].ingrdlist[j].comp_seq
       SET temp->oclist[idx].ingredientlist[j].iv_oe_format_id = temp2->ivlist[i].ingrdlist[j].
       iv_oe_format_id
       SET temp->oclist[idx].ingredientlist[j].rx_mask = temp2->ivlist[i].ingrdlist[j].rx_mask
     ENDFOR
   ENDFOR
   FREE RECORD temp2
  ENDIF
  SELECT INTO "nl:"
   FROM pw_comp_os_reltn pcor,
    order_sentence os,
    long_text lt
   PLAN (pcor
    WHERE expand(num,1,high,pcor.pathway_comp_id,temp->oclist[num].pathway_comp_id))
    JOIN (os
    WHERE os.order_sentence_id=pcor.order_sentence_id)
    JOIN (lt
    WHERE lt.long_text_id=outerjoin(os.ord_comment_long_text_id))
   ORDER BY pcor.pathway_comp_id, pcor.order_sentence_seq
   HEAD REPORT
    idx = 0
   HEAD pcor.pathway_comp_id
    osrcnt = 0, idx = locateval(idx,1,high,pcor.pathway_comp_id,temp->oclist[idx].pathway_comp_id)
   DETAIL
    osrcnt = (osrcnt+ 1)
    IF (osrcnt > size(temp->oclist[idx].ordsentlist,5))
     stat = alterlist(temp->oclist[idx].ordsentlist,(osrcnt+ 5))
    ENDIF
    temp->oclist[idx].ordsentlist[osrcnt].order_sentence_id = pcor.order_sentence_id, temp->oclist[
    idx].ordsentlist[osrcnt].order_sentence_seq = pcor.order_sentence_seq, temp->oclist[idx].
    ordsentlist[osrcnt].iv_comp_syn_id = pcor.iv_comp_syn_id,
    temp->oclist[idx].ordsentlist[osrcnt].os_oe_format_id = os.oe_format_id, temp->oclist[idx].
    ordsentlist[osrcnt].rx_type_mean = os.rx_type_mean
    IF (pcor.os_display_line != null
     AND pcor.os_display_line != "")
     temp->oclist[idx].ordsentlist[osrcnt].order_sentence_display_line = trim(pcor.os_display_line)
    ELSE
     temp->oclist[idx].ordsentlist[osrcnt].order_sentence_display_line = trim(os
      .order_sentence_display_line)
    ENDIF
    temp->oclist[idx].ordsentlist[osrcnt].comment = lt.long_text
   FOOT  pcor.pathway_comp_id
    IF (osrcnt > 0)
     stat = alterlist(temp->oclist[idx].ordsentlist,osrcnt)
    ENDIF
   FOOT REPORT
    idx = 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(temp->oclist,5))),
    (dummyt d2  WITH seq = 1),
    order_sentence_detail osd,
    order_entry_fields oef
   PLAN (d1
    WHERE maxrec(d2,size(temp->oclist[d1.seq].ordsentlist,5)))
    JOIN (d2)
    JOIN (osd
    WHERE (temp->oclist[d1.seq].ordsentlist[d2.seq].order_sentence_id=osd.order_sentence_id))
    JOIN (oef
    WHERE oef.oe_field_id=osd.oe_field_id
     AND oef.oe_field_meaning_id=osd.oe_field_meaning_id)
   ORDER BY d1.seq, d2.seq, osd.sequence
   HEAD d1.seq
    detailcnt = 0
   HEAD d2.seq
    detailcnt = 0
   DETAIL
    detailcnt = (detailcnt+ 1)
    IF (detailcnt > size(temp->oclist[d1.seq].ordsentlist[d2.seq].details,5))
     stat = alterlist(temp->oclist[d1.seq].ordsentlist[d2.seq].details,(detailcnt+ 5))
    ENDIF
    temp->oclist[d1.seq].ordsentlist[d2.seq].details[detailcnt].oef_id = osd.oe_field_id, temp->
    oclist[d1.seq].ordsentlist[d2.seq].details[detailcnt].display = osd.oe_field_display_value
    IF (osd.field_type_flag IN (0, 1, 2, 3, 5,
    7, 11, 14, 15))
     temp->oclist[d1.seq].ordsentlist[d2.seq].details[detailcnt].value = osd.oe_field_value
    ELSEIF (osd.field_type_flag IN (6, 8, 9, 10, 12,
    13))
     temp->oclist[d1.seq].ordsentlist[d2.seq].details[detailcnt].value = osd.default_parent_entity_id
    ENDIF
    temp->oclist[d1.seq].ordsentlist[d2.seq].details[detailcnt].sequence = osd.sequence, temp->
    oclist[d1.seq].ordsentlist[d2.seq].details[detailcnt].oef_description = oef.description, temp->
    oclist[d1.seq].ordsentlist[d2.seq].details[detailcnt].field_type_flag = oef.field_type_flag
   FOOT  d2.seq
    stat = alterlist(temp->oclist[d1.seq].ordsentlist[d2.seq].details,detailcnt)
   WITH nocounter
  ;end select
 ENDIF
 IF (value(size(temp->splist,5)) > 0)
  SET high = value(size(temp->splist,5))
  SELECT INTO "nl:"
   pwc.display_description, pwc.description
   FROM pathway_catalog pwc
   WHERE expand(num,1,high,pwc.pathway_catalog_id,temp->splist[num].parent_entity_id)
    AND pwc.sub_phase_ind=1
   ORDER BY pwc.pathway_catalog_id
   HEAD REPORT
    idx = 0
   HEAD pwc.pathway_catalog_id
    idx = locateval(idx,1,high,pwc.pathway_catalog_id,temp->splist[idx].parent_entity_id), temp->
    splist[idx].parent_phase_desc = pwc.description, temp->splist[idx].parent_phase_display_desc =
    pwc.display_description,
    temp->splist[idx].active_ind = pwc.active_ind
   FOOT  pwc.pathway_catalog_id
    idx2 = idx
    WHILE (idx != 0)
     idx2 = locateval(idx2,(idx+ 1),high,pwc.pathway_catalog_id,temp->splist[idx2].parent_entity_id),
     IF (idx2 != 0)
      idx = idx2, temp->splist[idx].parent_phase_desc = pwc.description, temp->splist[idx].
      parent_phase_display_desc = pwc.display_description,
      temp->splist[idx].active_ind = pwc.active_ind
     ELSE
      idx = idx2
     ENDIF
    ENDWHILE
   FOOT REPORT
    idx = 0
   WITH nocounter
  ;end select
  DECLARE spfaccnt = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(temp->splist,5)),
    pw_cat_flex p,
    code_value c
   PLAN (d
    WHERE (temp->splist[d.seq].parent_entity_id > 0))
    JOIN (p
    WHERE (p.pathway_catalog_id=temp->splist[d.seq].parent_entity_id)
     AND p.parent_entity_name="CODE_VALUE")
    JOIN (c
    WHERE c.code_value=p.parent_entity_id)
   HEAD p.pathway_catalog_id
    spfaccnt = 0
   DETAIL
    spfaccnt = (spfaccnt+ 1), stat = alterlist(temp->splist[d.seq].facilities,spfaccnt), temp->
    splist[d.seq].facilities[spfaccnt].fac_code = p.parent_entity_id,
    temp->splist[d.seq].facilities[spfaccnt].fac_disp = trim(c.display,3)
   WITH nocounter
  ;end select
 ENDIF
 SET occnt = value(size(temp->oclist,5))
 SET ltcnt = value(size(temp->ltlist,5))
 SET spcnt = value(size(temp->splist,5))
 SET outcomecnt = value(size(temp->outcomelist,5))
 DECLARE sp_vv_cnt = i4 WITH protect, noconstant(0)
 IF (((occnt > 0) OR (((ltcnt > 0) OR (((spcnt > 0) OR (outcomecnt > 0)) )) )) )
  SELECT INTO "nl:"
   phase_idx = d1.seq, sort_cd = decode(d2.seq,temp->oclist[d2.seq].sort_cd,d3.seq,temp->ltlist[d3
    .seq].sort_cd,d4.seq,
    temp->splist[d4.seq].sort_cd,d5.seq,temp->outcomelist[d5.seq].sort_cd,0.0), comp_seq = decode(d2
    .seq,temp->oclist[d2.seq].sequence,d3.seq,temp->ltlist[d3.seq].sequence,d4.seq,
    temp->splist[d4.seq].sequence,d5.seq,temp->outcomelist[d5.seq].sequence,0),
   check = decode(d2.seq,"oc",d3.seq,"lt",d4.seq,
    "sp",d5.seq,"outcome","zz")
   FROM (dummyt d1  WITH seq = value(size(reply->phase,5))),
    (dummyt d2  WITH seq = value(size(temp->oclist,5))),
    (dummyt d3  WITH seq = value(size(temp->ltlist,5))),
    (dummyt d4  WITH seq = value(size(temp->splist,5))),
    (dummyt d5  WITH seq = value(size(temp->outcomelist,5)))
   PLAN (d1)
    JOIN (((d2
    WHERE (temp->oclist[d2.seq].pathway_catalog_id=reply->phase[d1.seq].phase_id))
    ) ORJOIN ((((d3
    WHERE (temp->ltlist[d3.seq].pathway_catalog_id=reply->phase[d1.seq].phase_id))
    ) ORJOIN ((((d4
    WHERE (temp->splist[d4.seq].pathway_catalog_id=reply->phase[d1.seq].phase_id))
    ) ORJOIN ((d5
    WHERE (temp->outcomelist[d5.seq].pathway_catalog_id=reply->phase[d1.seq].phase_id))
    )) )) ))
   ORDER BY phase_idx, sort_cd, comp_seq
   HEAD REPORT
    idx = 0, compcnt = 0
   HEAD phase_idx
    compcnt = 0
   HEAD sort_cd
    compcnt = compcnt
   HEAD comp_seq
    IF (check != "zz")
     IF (check="oc")
      compcnt = (compcnt+ 1)
      IF (compcnt > size(reply->phase[d1.seq].component,5))
       stat = alterlist(reply->phase[d1.seq].component,(compcnt+ 10))
      ENDIF
      reply->phase[d1.seq].component[compcnt].comp_id = temp->oclist[d2.seq].pathway_comp_id, reply->
      phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_code_value = temp->oclist[d2.seq].
      dcp_clin_cat_cd, reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_mean = temp
      ->oclist[d2.seq].dcp_clin_cat_mean,
      reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_disp = temp->oclist[d2.seq].
      dcp_clin_cat_disp, reply->phase[d1.seq].component[compcnt].clin_category.collation_seq = temp->
      oclist[d2.seq].dcp_clin_cat_seq, reply->phase[d1.seq].component[compcnt].clin_sub_category.
      dcp_clin_sub_cat_code_value = temp->oclist[d2.seq].dcp_clin_sub_cat_cd,
      reply->phase[d1.seq].component[compcnt].clin_sub_category.dcp_clin_sub_cat_mean = temp->oclist[
      d2.seq].dcp_clin_sub_cat_mean, reply->phase[d1.seq].component[compcnt].clin_sub_category.
      dcp_clin_sub_cat_disp = temp->oclist[d2.seq].dcp_clin_sub_cat_disp, reply->phase[d1.seq].
      component[compcnt].sequence = temp->oclist[d2.seq].sequence,
      reply->phase[d1.seq].component[compcnt].comp_type = temp->oclist[d2.seq].comp_type, reply->
      phase[d1.seq].component[compcnt].parent_entity_name = temp->oclist[d2.seq].parent_entity_name,
      reply->phase[d1.seq].component[compcnt].parent_entity_id = temp->oclist[d2.seq].
      parent_entity_id,
      reply->phase[d1.seq].component[compcnt].comp_description = temp->oclist[d2.seq].mnemonic, reply
      ->phase[d1.seq].component[compcnt].catalog_cd = temp->oclist[d2.seq].catalog_cd, reply->phase[
      d1.seq].component[compcnt].comp_oe_format_id = temp->oclist[d2.seq].comp_oe_format_id,
      reply->phase[d1.seq].component[compcnt].include_ind = temp->oclist[d2.seq].include_ind, reply->
      phase[d1.seq].component[compcnt].required_ind = temp->oclist[d2.seq].required_ind, reply->
      phase[d1.seq].component[compcnt].evidence_type_mean = temp->oclist[d2.seq].evidence_type_mean,
      reply->phase[d1.seq].component[compcnt].evidence_locator = temp->oclist[d2.seq].
      evidence_locator, reply->phase[d1.seq].component[compcnt].default_os_ind = temp->oclist[d2.seq]
      .default_os_ind, reply->phase[d1.seq].component[compcnt].intermittent_ind = temp->oclist[d2.seq
      ].intermittent_ind,
      reply->phase[d1.seq].component[compcnt].rx_mask = temp->oclist[d2.seq].rx_mask, reply->phase[d1
      .seq].component[compcnt].offset.offset_quantity = temp->oclist[d2.seq].offset.offset_quantity,
      reply->phase[d1.seq].component[compcnt].offset.offset_unit_code_value = temp->oclist[d2.seq].
      offset.offset_unit_code_value,
      reply->phase[d1.seq].component[compcnt].offset.offset_unit_display = temp->oclist[d2.seq].
      offset.offset_unit_display, reply->phase[d1.seq].component[compcnt].offset.offset_unit_meaning
       = temp->oclist[d2.seq].offset.offset_unit_meaning, reply->phase[d1.seq].component[compcnt].
      schedule_phases_ind = temp->oclist[d2.seq].schedule_phases_ind,
      reply->phase[d1.seq].component[compcnt].uuid = temp->oclist[d2.seq].uuid, reply->phase[d1.seq].
      component[compcnt].synonym_active_ind = temp->oclist[d2.seq].synonym_active_ind, reply->phase[
      d1.seq].component[compcnt].synonym_type_code_value = temp->oclist[d2.seq].synonym_type,
      reply->phase[d1.seq].component[compcnt].synonym_type_display = temp->oclist[d2.seq].
      synonym_type_disp, reply->phase[d1.seq].component[compcnt].synonym_type_mean = temp->oclist[d2
      .seq].synonym_type_mean, syn_vv_cnt = size(temp->oclist[d2.seq].synonym_vv,5),
      stat = alterlist(reply->phase[d1.seq].component[compcnt].synonym_vv,syn_vv_cnt)
      FOR (vv = 1 TO syn_vv_cnt)
       reply->phase[d1.seq].component[compcnt].synonym_vv[vv].facility_code_value = temp->oclist[d2
       .seq].synonym_vv[vv].fac_code,reply->phase[d1.seq].component[compcnt].synonym_vv[vv].
       facility_display = temp->oclist[d2.seq].synonym_vv[vv].fac_disp
      ENDFOR
      reply->phase[d1.seq].component[compcnt].persistent_ind = 0, count = size(temp->oclist[d2.seq].
       ingredientlist,5)
      IF (count > 0)
       stat = alterlist(reply->phase[d1.seq].component[compcnt].iv_ingredient,count)
       FOR (j = 1 TO count)
         reply->phase[d1.seq].component[compcnt].iv_ingredient[j].synonym_id = temp->oclist[d2.seq].
         ingredientlist[j].synonym_id, reply->phase[d1.seq].component[compcnt].iv_ingredient[j].
         mnemonic = trim(temp->oclist[d2.seq].ingredientlist[j].mnemonic), reply->phase[d1.seq].
         component[compcnt].iv_ingredient[j].iv_sequence = temp->oclist[d2.seq].ingredientlist[j].
         comp_seq,
         reply->phase[d1.seq].component[compcnt].iv_ingredient[j].iv_oe_format_id = temp->oclist[d2
         .seq].ingredientlist[j].iv_oe_format_id, reply->phase[d1.seq].component[compcnt].
         iv_ingredient[j].rx_mask = temp->oclist[d2.seq].ingredientlist[j].rx_mask
       ENDFOR
      ENDIF
      count = size(temp->oclist[d2.seq].ordsentlist,5)
      IF (count > 0)
       FOR (j = 1 TO count)
         IF ((temp->oclist[d2.seq].comp_type="IV"))
          high = size(reply->phase[d1.seq].component[compcnt].iv_ingredient,5), idx = locateval(idx,1,
           high,temp->oclist[d2.seq].ordsentlist[j].iv_comp_syn_id,reply->phase[d1.seq].component[
           compcnt].iv_ingredient[idx].synonym_id)
          IF (idx != 0)
           reply->phase[d1.seq].component[compcnt].iv_ingredient[idx].has_sentence_ind = 1
           IF (((validate(request->ignore_sentence_flag)=0) OR ((request->ignore_sentence_flag=0))) )
            reply->phase[d1.seq].component[compcnt].iv_ingredient[idx].iv_order_sentence.sequence =
            temp->oclist[d2.seq].ordsentlist[j].order_sentence_seq, reply->phase[d1.seq].component[
            compcnt].iv_ingredient[idx].iv_order_sentence.order_sentence_id = temp->oclist[d2.seq].
            ordsentlist[j].order_sentence_id, reply->phase[d1.seq].component[compcnt].iv_ingredient[
            idx].iv_order_sentence.order_sentence_display_line = trim(temp->oclist[d2.seq].
             ordsentlist[j].order_sentence_display_line),
            reply->phase[d1.seq].component[compcnt].iv_ingredient[idx].iv_order_sentence.
            os_oe_format_id = temp->oclist[d2.seq].ordsentlist[j].os_oe_format_id, reply->phase[d1
            .seq].component[compcnt].iv_ingredient[idx].iv_order_sentence.comment = temp->oclist[d2
            .seq].ordsentlist[j].comment, detail_cnt = size(temp->oclist[d2.seq].ordsentlist[j].
             details,5),
            stat = alterlist(reply->phase[d1.seq].component[compcnt].iv_ingredient[idx].
             iv_order_sentence.details,detail_cnt)
            FOR (k = 1 TO detail_cnt)
              reply->phase[d1.seq].component[compcnt].iv_ingredient[idx].iv_order_sentence.details[k]
              .oef_id = temp->oclist[d2.seq].ordsentlist[j].details[k].oef_id, reply->phase[d1.seq].
              component[compcnt].iv_ingredient[idx].iv_order_sentence.details[k].display = temp->
              oclist[d2.seq].ordsentlist[j].details[k].display, reply->phase[d1.seq].component[
              compcnt].iv_ingredient[idx].iv_order_sentence.details[k].value = temp->oclist[d2.seq].
              ordsentlist[j].details[k].value,
              reply->phase[d1.seq].component[compcnt].iv_ingredient[idx].iv_order_sentence.details[k]
              .sequence = temp->oclist[d2.seq].ordsentlist[j].details[k].sequence, reply->phase[d1
              .seq].component[compcnt].iv_ingredient[idx].iv_order_sentence.details[k].
              oef_description = temp->oclist[d2.seq].ordsentlist[j].details[k].oef_description, reply
              ->phase[d1.seq].component[compcnt].iv_ingredient[idx].iv_order_sentence.details[k].
              field_type_flag = temp->oclist[d2.seq].ordsentlist[j].details[k].field_type_flag
            ENDFOR
           ENDIF
           idx = 0
          ELSE
           idx = 0
          ENDIF
         ELSE
          reply->phase[d1.seq].component[compcnt].has_sentences_ind = 1
          IF (((validate(request->ignore_sentence_flag)=0) OR ((request->ignore_sentence_flag=0))) )
           stat = alterlist(reply->phase[d1.seq].component[compcnt].order_sentence,count), reply->
           phase[d1.seq].component[compcnt].order_sentence[j].sequence = temp->oclist[d2.seq].
           ordsentlist[j].order_sentence_seq, reply->phase[d1.seq].component[compcnt].order_sentence[
           j].order_sentence_id = temp->oclist[d2.seq].ordsentlist[j].order_sentence_id,
           reply->phase[d1.seq].component[compcnt].order_sentence[j].order_sentence_display_line =
           trim(temp->oclist[d2.seq].ordsentlist[j].order_sentence_display_line), reply->phase[d1.seq
           ].component[compcnt].order_sentence[j].os_oe_format_id = temp->oclist[d2.seq].ordsentlist[
           j].os_oe_format_id, reply->phase[d1.seq].component[compcnt].order_sentence[j].rx_type_mean
            = temp->oclist[d2.seq].ordsentlist[j].rx_type_mean,
           reply->phase[d1.seq].component[compcnt].order_sentence[j].comment = temp->oclist[d2.seq].
           ordsentlist[j].comment, detail_cnt = size(temp->oclist[d2.seq].ordsentlist[j].details,5),
           stat = alterlist(reply->phase[d1.seq].component[compcnt].order_sentence[j].details,
            detail_cnt)
           FOR (k = 1 TO detail_cnt)
             IF ((temp->oclist[d2.seq].ordsentlist[j].details[k].oef_id=intermittent_oe_field_id))
              IF ((temp->oclist[d2.seq].ordsentlist[j].details[k].value=2))
               reply->phase[d1.seq].component[compcnt].order_sentence[j].intermittent_ind = 2
              ELSE
               reply->phase[d1.seq].component[compcnt].order_sentence[j].intermittent_ind = 1
              ENDIF
             ELSE
              reply->phase[d1.seq].component[compcnt].order_sentence[j].details[k].oef_id = temp->
              oclist[d2.seq].ordsentlist[j].details[k].oef_id, reply->phase[d1.seq].component[compcnt
              ].order_sentence[j].details[k].display = temp->oclist[d2.seq].ordsentlist[j].details[k]
              .display, reply->phase[d1.seq].component[compcnt].order_sentence[j].details[k].value =
              temp->oclist[d2.seq].ordsentlist[j].details[k].value,
              reply->phase[d1.seq].component[compcnt].order_sentence[j].details[k].sequence = temp->
              oclist[d2.seq].ordsentlist[j].details[k].sequence, reply->phase[d1.seq].component[
              compcnt].order_sentence[j].details[k].oef_description = temp->oclist[d2.seq].
              ordsentlist[j].details[k].oef_description, reply->phase[d1.seq].component[compcnt].
              order_sentence[j].details[k].field_type_flag = temp->oclist[d2.seq].ordsentlist[j].
              details[k].field_type_flag
             ENDIF
           ENDFOR
           IF ((reply->phase[d1.seq].component[compcnt].order_sentence[j].intermittent_ind > 0))
            detail_cnt = (detail_cnt - 1)
           ENDIF
           stat = alterlist(reply->phase[d1.seq].component[compcnt].order_sentence[j].details,
            detail_cnt)
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
     ELSEIF (check="lt")
      compcnt = (compcnt+ 1)
      IF (compcnt > size(reply->phase[d1.seq].component,5))
       stat = alterlist(reply->phase[d1.seq].component,(compcnt+ 10))
      ENDIF
      reply->phase[d1.seq].component[compcnt].comp_id = temp->ltlist[d3.seq].pathway_comp_id, reply->
      phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_code_value = temp->ltlist[d3.seq].
      dcp_clin_cat_cd, reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_mean = temp
      ->ltlist[d3.seq].dcp_clin_cat_mean,
      reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_disp = temp->ltlist[d3.seq].
      dcp_clin_cat_disp, reply->phase[d1.seq].component[compcnt].clin_category.collation_seq = temp->
      ltlist[d3.seq].dcp_clin_cat_seq, reply->phase[d1.seq].component[compcnt].clin_sub_category.
      dcp_clin_sub_cat_code_value = temp->ltlist[d3.seq].dcp_clin_sub_cat_cd,
      reply->phase[d1.seq].component[compcnt].clin_sub_category.dcp_clin_sub_cat_mean = temp->ltlist[
      d3.seq].dcp_clin_sub_cat_mean, reply->phase[d1.seq].component[compcnt].clin_sub_category.
      dcp_clin_sub_cat_disp = temp->ltlist[d3.seq].dcp_clin_sub_cat_disp, reply->phase[d1.seq].
      component[compcnt].sequence = temp->ltlist[d3.seq].sequence,
      reply->phase[d1.seq].component[compcnt].comp_description = temp->ltlist[d3.seq].comp_text,
      reply->phase[d1.seq].component[compcnt].comp_type = temp->ltlist[d3.seq].comp_type, reply->
      phase[d1.seq].component[compcnt].parent_entity_name = temp->ltlist[d3.seq].parent_entity_name,
      reply->phase[d1.seq].component[compcnt].parent_entity_id = temp->ltlist[d3.seq].
      parent_entity_id, reply->phase[d1.seq].component[compcnt].include_ind = temp->ltlist[d3.seq].
      include_ind, reply->phase[d1.seq].component[compcnt].required_ind = temp->ltlist[d3.seq].
      required_ind,
      reply->phase[d1.seq].component[compcnt].evidence_type_mean = temp->ltlist[d3.seq].
      evidence_type_mean, reply->phase[d1.seq].component[compcnt].evidence_locator = temp->ltlist[d3
      .seq].evidence_locator, reply->phase[d1.seq].component[compcnt].default_os_ind = temp->ltlist[
      d3.seq].default_os_ind,
      reply->phase[d1.seq].component[compcnt].persistent_ind = temp->ltlist[d3.seq].persistent_ind,
      reply->phase[d1.seq].component[compcnt].uuid = temp->ltlist[d3.seq].uuid, reply->phase[d1.seq].
      component[compcnt].placeholder_id = temp->ltlist[d3.seq].placeholder_id,
      reply->phase[d1.seq].component[compcnt].placeholder_include_ind = temp->ltlist[d3.seq].
      placeholder_include_ind, reply->phase[d1.seq].component[compcnt].placeholder_name = temp->
      ltlist[d3.seq].placeholder_name, reply->phase[d1.seq].component[compcnt].
      placeholder_required_ind = temp->ltlist[d3.seq].placeholder_required_ind,
      reply->phase[d1.seq].component[compcnt].placeholder_type_flag = temp->ltlist[d3.seq].
      placeholder_type_flag
     ELSEIF (check="sp")
      compcnt = (compcnt+ 1)
      IF (compcnt > size(reply->phase[d1.seq].component,5))
       stat = alterlist(reply->phase[d1.seq].component,(compcnt+ 10))
      ENDIF
      reply->phase[d1.seq].component[compcnt].comp_id = temp->splist[d4.seq].pathway_comp_id, reply->
      phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_code_value = temp->splist[d4.seq].
      dcp_clin_cat_cd, reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_mean = temp
      ->splist[d4.seq].dcp_clin_cat_mean,
      reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_disp = temp->splist[d4.seq].
      dcp_clin_cat_disp, reply->phase[d1.seq].component[compcnt].clin_category.collation_seq = temp->
      splist[d4.seq].dcp_clin_cat_seq, reply->phase[d1.seq].component[compcnt].clin_sub_category.
      dcp_clin_sub_cat_code_value = temp->splist[d4.seq].dcp_clin_sub_cat_cd,
      reply->phase[d1.seq].component[compcnt].clin_sub_category.dcp_clin_sub_cat_mean = temp->splist[
      d4.seq].dcp_clin_sub_cat_mean, reply->phase[d1.seq].component[compcnt].clin_sub_category.
      dcp_clin_sub_cat_disp = temp->splist[d4.seq].dcp_clin_sub_cat_disp, reply->phase[d1.seq].
      component[compcnt].sequence = temp->splist[d4.seq].sequence,
      reply->phase[d1.seq].component[compcnt].comp_description = temp->splist[d4.seq].
      parent_phase_desc, reply->phase[d1.seq].component[compcnt].comp_type = temp->splist[d4.seq].
      comp_type, reply->phase[d1.seq].component[compcnt].parent_entity_name = temp->splist[d4.seq].
      parent_entity_name,
      reply->phase[d1.seq].component[compcnt].parent_entity_id = temp->splist[d4.seq].
      parent_entity_id, reply->phase[d1.seq].component[compcnt].include_ind = temp->splist[d4.seq].
      include_ind, reply->phase[d1.seq].component[compcnt].required_ind = temp->splist[d4.seq].
      required_ind,
      reply->phase[d1.seq].component[compcnt].evidence_type_mean = temp->splist[d4.seq].
      evidence_type_mean, reply->phase[d1.seq].component[compcnt].evidence_locator = temp->splist[d4
      .seq].evidence_locator, reply->phase[d1.seq].component[compcnt].default_os_ind = temp->splist[
      d4.seq].default_os_ind,
      reply->phase[d1.seq].component[compcnt].offset.offset_quantity = temp->splist[d2.seq].offset.
      offset_quantity, reply->phase[d1.seq].component[compcnt].offset.offset_unit_code_value = temp->
      splist[d2.seq].offset.offset_unit_code_value, reply->phase[d1.seq].component[compcnt].offset.
      offset_unit_display = temp->splist[d2.seq].offset.offset_unit_display,
      reply->phase[d1.seq].component[compcnt].offset.offset_unit_meaning = temp->splist[d2.seq].
      offset.offset_unit_meaning, reply->phase[d1.seq].component[compcnt].schedule_phases_ind = temp
      ->splist[d2.seq].schedule_phases_ind, reply->phase[d1.seq].component[compcnt].uuid = temp->
      splist[d2.seq].uuid,
      sp_vv_cnt = size(temp->splist[d4.seq].facilities,5), stat = alterlist(reply->phase[d1.seq].
       component[compcnt].synonym_vv,sp_vv_cnt)
      FOR (spvv = 1 TO sp_vv_cnt)
       reply->phase[d1.seq].component[compcnt].synonym_vv[spvv].facility_code_value = temp->splist[d4
       .seq].facilities[spvv].fac_code,reply->phase[d1.seq].component[compcnt].synonym_vv[spvv].
       facility_display = temp->splist[d4.seq].facilities[spvv].fac_disp
      ENDFOR
      reply->phase[d1.seq].component[compcnt].synonym_active_ind = temp->splist[d4.seq].active_ind,
      reply->phase[d1.seq].component[compcnt].persistent_ind = 0
     ELSEIF (check="outcome")
      compcnt = (compcnt+ 1)
      IF (compcnt > size(reply->phase[d1.seq].component,5))
       stat = alterlist(reply->phase[d1.seq].component,(compcnt+ 10))
      ENDIF
      reply->phase[d1.seq].component[compcnt].comp_id = temp->outcomelist[d5.seq].pathway_comp_id,
      reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_code_value = temp->
      outcomelist[d5.seq].dcp_clin_cat_cd, reply->phase[d1.seq].component[compcnt].clin_category.
      dcp_clin_cat_mean = temp->outcomelist[d5.seq].dcp_clin_cat_mean,
      reply->phase[d1.seq].component[compcnt].clin_category.dcp_clin_cat_disp = temp->outcomelist[d5
      .seq].dcp_clin_cat_disp, reply->phase[d1.seq].component[compcnt].clin_category.collation_seq =
      temp->outcomelist[d5.seq].dcp_clin_cat_seq, reply->phase[d1.seq].component[compcnt].
      clin_sub_category.dcp_clin_sub_cat_code_value = temp->outcomelist[d5.seq].dcp_clin_sub_cat_cd,
      reply->phase[d1.seq].component[compcnt].clin_sub_category.dcp_clin_sub_cat_mean = temp->
      outcomelist[d5.seq].dcp_clin_sub_cat_mean, reply->phase[d1.seq].component[compcnt].
      clin_sub_category.dcp_clin_sub_cat_disp = temp->outcomelist[d5.seq].dcp_clin_sub_cat_disp,
      reply->phase[d1.seq].component[compcnt].sequence = temp->outcomelist[d5.seq].sequence,
      reply->phase[d1.seq].component[compcnt].comp_description = temp->outcomelist[d5.seq].
      description, reply->phase[d1.seq].component[compcnt].comp_type = temp->outcomelist[d5.seq].
      comp_type, reply->phase[d1.seq].component[compcnt].parent_entity_name = temp->outcomelist[d5
      .seq].parent_entity_name,
      reply->phase[d1.seq].component[compcnt].parent_entity_id = temp->outcomelist[d5.seq].
      parent_entity_id, reply->phase[d1.seq].component[compcnt].include_ind = temp->outcomelist[d5
      .seq].include_ind, reply->phase[d1.seq].component[compcnt].required_ind = temp->outcomelist[d5
      .seq].required_ind,
      reply->phase[d1.seq].component[compcnt].evidence_type_mean = temp->outcomelist[d5.seq].
      evidence_type_mean, reply->phase[d1.seq].component[compcnt].evidence_locator = temp->
      outcomelist[d5.seq].evidence_locator, reply->phase[d1.seq].component[compcnt].uuid = temp->
      outcomelist[d5.seq].uuid,
      reply->phase[d1.seq].component[compcnt].persistent_ind = 0
     ENDIF
    ENDIF
   DETAIL
    dummy = 0
   FOOT  comp_seq
    dummy = 0
   FOOT  sort_cd
    dummy = 0
   FOOT  phase_idx
    stat = alterlist(reply->phase[d1.seq].component,compcnt)
   FOOT REPORT
    dummy = 0
   WITH nocounter, outerjoin = d1
  ;end select
  SET phasecount = size(reply->phase,5)
  IF (phasecount > 0)
   SELECT INTO "nl"
    FROM code_value cv,
     pw_evidence_reltn per,
     (dummyt d  WITH seq = phasecount)
    PLAN (d)
     JOIN (cv
     WHERE cv.code_set=16389
      AND cv.active_ind=1
      AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND cv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND cv.code_value > 0
      AND cv.display > " "
      AND cv.cdf_meaning > " ")
     JOIN (per
     WHERE per.dcp_clin_cat_cd=outerjoin(cv.code_value)
      AND per.pathway_catalog_id=outerjoin(reply->phase[d.seq].phase_id)
      AND per.pathway_comp_id=outerjoin(0)
      AND per.dcp_clin_sub_cat_cd=outerjoin(0))
    DETAIL
     clincatcnt = (size(reply->phase[d.seq].clin_cat_evidence_links,5)+ 1), stat = alterlist(reply->
      phase[d.seq].clin_cat_evidence_links,clincatcnt), reply->phase[d.seq].clin_cat_evidence_links[
     clincatcnt].cat_code_value = cv.code_value,
     reply->phase[d.seq].clin_cat_evidence_links[clincatcnt].cat_disp = cv.display, reply->phase[d
     .seq].clin_cat_evidence_links[clincatcnt].cat_mean = cv.cdf_meaning
     IF (per.type_mean IN ("ZYNX", "URL"))
      reply->phase[d.seq].clin_cat_evidence_links[clincatcnt].cat_evidence_locator = per
      .evidence_locator, reply->phase[d.seq].clin_cat_evidence_links[clincatcnt].
      cat_evidence_type_mean = per.type_mean
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl"
    FROM pw_evidence_reltn per,
     (dummyt d1  WITH seq = phasecount),
     (dummyt d2  WITH seq = 1)
    PLAN (d1
     WHERE maxrec(d2,size(reply->phase[d1.seq].clin_cat_evidence_links,5)))
     JOIN (d2)
     JOIN (per
     WHERE (per.pathway_catalog_id=reply->phase[d1.seq].phase_id)
      AND per.pathway_comp_id=0
      AND (per.dcp_clin_cat_cd=reply->phase[d1.seq].clin_cat_evidence_links[d2.seq].cat_code_value)
      AND per.dcp_clin_sub_cat_cd > 0
      AND per.type_mean IN ("ZYNX", "URL"))
    DETAIL
     clinsubcatcnt = (size(reply->phase[d1.seq].clin_cat_evidence_links[d2.seq].
      clin_subcat_evidence_links,5)+ 1), stat = alterlist(reply->phase[d1.seq].
      clin_cat_evidence_links[d2.seq].clin_subcat_evidence_links,clinsubcatcnt), reply->phase[d1.seq]
     .clin_cat_evidence_links[d2.seq].clin_subcat_evidence_links[clinsubcatcnt].subcat_code_value =
     per.dcp_clin_sub_cat_cd,
     reply->phase[d1.seq].clin_cat_evidence_links[d2.seq].clin_subcat_evidence_links[clinsubcatcnt].
     subcat_disp = uar_get_code_display(per.dcp_clin_sub_cat_cd), reply->phase[d1.seq].
     clin_cat_evidence_links[d2.seq].clin_subcat_evidence_links[clinsubcatcnt].
     subcat_evidence_locator = per.evidence_locator, reply->phase[d1.seq].clin_cat_evidence_links[d2
     .seq].clin_subcat_evidence_links[clinsubcatcnt].subcat_evidence_type_mean = per.type_mean,
     reply->phase[d1.seq].clin_cat_evidence_links[d2.seq].clin_subcat_evidence_links[clinsubcatcnt].
     subcat_mean = uar_get_code_meaning(per.dcp_clin_sub_cat_cd)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
