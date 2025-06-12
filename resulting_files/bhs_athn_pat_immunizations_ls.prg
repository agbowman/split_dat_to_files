CREATE PROGRAM bhs_athn_pat_immunizations_ls
 DECLARE where_params = vc WITH noconstant(" ")
 DECLARE where_res_status_params = vc WITH noconstant("1=1")
 DECLARE prev_prsnl_act_id = vc WITH noconstant("1")
 DECLARE ocf_comp_cd = f8 WITH public, constant(uar_get_code_by("MEANING",120,"OCFCOMP"))
 DECLARE adhoc = c10 WITH protect, constant("ADHOC")
 DECLARE history = c10 WITH protect, constant("HISTORY")
 DECLARE immunizations_event_set_name_key = c15 WITH protect, constant("IMMUNIZATIONS")
 IF (( $3=0))
  SET where_params = build(" C.PERSON_ID = ", $2)
 ELSE
  SET where_params = build(" C.PERSON_ID = ", $2," AND C.ENCNTR_ID = ", $3)
 ENDIF
 IF (( $4="ADHOC"))
  SET where_res_status_params = build("C.SOURCE_CD = 0")
 ELSEIF (( $4="HISTORY"))
  SET where_res_status_params = build("C.SOURCE_CD != 0")
 ENDIF
 DECLARE vcnt = i4
 FREE RECORD event_codes
 RECORD event_codes(
   1 qual[*]
     2 event_cd = f8
 )
 SELECT INTO "NL:"
  vese.event_cd
  FROM v500_event_set_code vesc,
   v500_event_set_explode vese
  PLAN (vesc
   WHERE vesc.event_set_name_key=immunizations_event_set_name_key)
   JOIN (vese
   WHERE vese.event_set_cd=vesc.event_set_cd)
  DETAIL
   vcnt += 1, stat = alterlist(event_codes->qual,vcnt), event_codes->qual[vcnt].event_cd = vese
   .event_cd
  WITH time = 10
 ;end select
 SELECT INTO  $1
  c.clinical_event_id, c_event_id = trim(replace(cnvtstring(c.event_id),".0*","",0),3),
  c_parent_event_id = trim(replace(cnvtstring(c.parent_event_id),".0*","",0),3),
  c_encntr_id = trim(replace(cnvtstring(c.encntr_id),".0*","",0),3), c_patient_id = trim(replace(
    cnvtstring(c.person_id),".0*","",0),3), c_event_cd = cnvtint(c.event_cd),
  c_event_disp = uar_get_code_display(c.event_cd), c_entry_mode_disp = uar_get_code_display(c
   .entry_mode_cd), c_event_end_dt_tm = format(c.event_end_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  c_event_end_tz = substring(21,3,datetimezoneformat(c.event_end_dt_tm,c.event_end_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), c_event_tag = trim(replace(replace(replace(replace(
       replace(trim(c.event_tag,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), c_expiration_dt_tm = format(c.expiration_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  c_order_id = trim(replace(cnvtstring(c.order_id),".0*","",0),3), c_publish_flag = substring(0,10,
   IF (c.publish_flag=0) "NonPublished"
   ELSEIF (c.publish_flag=1) "Published"
   ENDIF
   ), c_result_val = trim(replace(replace(replace(replace(replace(replace(replace(cnvtstring(c
           .result_val),".00*"," ",0),">","&gt;",0),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  c.updt_cnt, c_updt_dt_tm = format(c.updt_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"), c_clinsig_updt_dt_tm =
  format(c.clinsig_updt_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  c_result_status_cd = cnvtint(c.result_status_cd), c_result_status_disp = trim(replace(replace(
     replace(replace(replace(trim(uar_get_code_display(c.result_status_cd),3),"&","&amp;",0),"<",
       "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), c_result_status_mean = trim(
   replace(replace(replace(replace(replace(trim(uar_get_code_meaning(c.result_status_cd),3),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  c_event_class_cd = cnvtint(c.event_class_cd), c_event_class_disp = trim(replace(replace(replace(
      replace(replace(trim(uar_get_code_display(c.event_class_cd),3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), c_event_class_mean = trim(replace(replace(replace
     (replace(replace(trim(uar_get_code_meaning(c.event_class_cd),3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  c_event_reltn_cd = cnvtint(c.event_reltn_cd), c_event_reltn_disp = trim(replace(replace(replace(
      replace(replace(trim(uar_get_code_display(c.event_reltn_cd),3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), c_event_reltn_mean = trim(replace(replace(replace
     (replace(replace(trim(uar_get_code_meaning(c.event_reltn_cd),3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  c_record_status_cd = cnvtint(c.record_status_cd), c_record_status_disp = trim(replace(replace(
     replace(replace(replace(uar_get_code_display(c.record_status_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), c_record_status_mean = trim(replace(replace(
     replace(replace(uar_get_code_meaning(c.record_status_cd),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  c_result_units_cd = cnvtint(c.result_units_cd), c_result_units_disp = trim(replace(replace(replace(
      replace(uar_get_code_display(c.result_units_cd),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), c_result_units_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(c.result_units_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3),
  c_task_assay_cd = cnvtint(c.task_assay_cd), c_task_assay_disp = trim(replace(replace(replace(
      replace(uar_get_code_display(c.task_assay_cd),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), c_task_assay_mean = trim(replace(replace(replace(replace(replace(
        uar_get_code_meaning(c.task_assay_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
     0),'"',"&quot;",0),3),
  c_normalcy_cd = cnvtint(c.normalcy_cd), c_normalcy_disp = trim(replace(replace(replace(replace(
       replace(uar_get_code_display(c.normalcy_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), c_normalcy_mean = trim(replace(replace(replace(replace(
       uar_get_code_meaning(c.normalcy_cd),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3),
  c_contributor_system_cd = cnvtint(c.contributor_system_cd), c_contributor_system_disp = trim(
   replace(replace(replace(replace(replace(uar_get_code_display(c.contributor_system_cd),"&","&amp;",
        0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), c_contributor_system_mean
   = trim(replace(replace(replace(replace(uar_get_code_meaning(c.contributor_system_cd),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  c_entry_mode_cd = cnvtint(c.entry_mode_cd), c_entry_mode_disp = trim(replace(replace(replace(
      replace(replace(uar_get_code_display(c.entry_mode_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0
      ),"'","&apos;",0),'"',"&quot;",0),3), c_entry_mode_mean = trim(replace(replace(replace(replace(
       uar_get_code_meaning(c.entry_mode_cd),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3),
  c_source_cd = cnvtint(c.source_cd), c_source_disp = trim(replace(replace(replace(replace(replace(
        uar_get_code_display(c.source_cd),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
    '"',"&quot;",0),3), c_source_mean = trim(replace(replace(replace(replace(uar_get_code_meaning(c
        .source_cd),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  cep.ce_event_prsnl_id, cep_event_prsnl_id = trim(replace(cnvtstring(cep.event_prsnl_id),".0*","",0),
   3), cep_action_prsnl_id = trim(replace(cnvtstring(cep.action_prsnl_id),".0*","",0),3),
  ap_name_full_formatted = trim(replace(replace(replace(replace(replace(ap.name_full_formatted,"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), cep_action_dt_tm
   = format(cep.action_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"), cep_action_tz = substring(21,3,
   datetimezoneformat(cep.action_dt_tm,cep.action_tz,"MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)),
  cep_action_status_cd = cnvtint(cep.action_status_cd), cep_action_status_disp = trim(replace(replace
    (replace(replace(replace(uar_get_code_display(cep.action_status_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), cep_action_status_mean = trim(replace(replace
    (replace(replace(replace(uar_get_code_meaning(cep.action_status_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  cep_action_type_cd = cnvtint(cep.action_type_cd), cep_action_type_disp = trim(replace(replace(
     replace(replace(replace(uar_get_code_display(cep.action_type_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), cep_action_type_mean = trim(replace(replace(
     replace(replace(replace(uar_get_code_meaning(cep.action_type_cd),"&","&amp;",0),"<","&lt;",0),
      ">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  cm.admin_dosage, cm_admin_prov_id = cnvtint(cm.admin_prov_id), cm_admin_route_cd = cnvtint(cm
   .admin_route_cd),
  cm_admin_route_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(cm
          .admin_route_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), cm_admin_route_mean = trim(replace(replace(replace(replace(replace(trim(
         uar_get_code_meaning(cm.admin_route_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), cm_admin_site_cd = cnvtint(cm.admin_site_cd),
  cm_admin_site_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(cm
          .admin_site_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), cm_admin_site_mean = trim(replace(replace(replace(replace(trim(uar_get_code_meaning(cm
         .admin_site_cd),3),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  cm_admin_start_dt_tm = format(cm.admin_start_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  cm_admin_start_tz = substring(21,3,datetimezoneformat(cm.admin_start_dt_tm,cm.admin_start_tz,
    "MM/dd/yyyy hh:mm:ss ZZZ",curtimezonedef)), cm_dosage_unit_cd = cnvtint(cm.dosage_unit_cd),
  cm_dosage_unit_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(cm
          .dosage_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3),
  cm_dosage_unit_mean = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(cm
          .dosage_unit_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), cm_immunization_type_cd = cnvtint(cm.immunization_type_cd), cm_immunization_type_disp =
  trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(cm.immunization_type_cd),3),
        "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  cm_immunization_type_mean = trim(replace(replace(replace(replace(replace(trim(uar_get_code_meaning(
          cm.immunization_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), cm_substance_exp_dt_tm = format(cm.substance_exp_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  cm_substance_lot_number = cm.substance_lot_number,
  cm_substance_manufacturer_cd = cnvtint(cm.substance_manufacturer_cd),
  cm_substance_manufacturer_disp = trim(replace(replace(replace(replace(replace(trim(
         uar_get_code_display(cm.substance_manufacturer_cd),3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3), cm_substance_manufacturer_mean = trim(replace(
    replace(replace(replace(replace(trim(uar_get_code_meaning(cm.substance_manufacturer_cd),3),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  cm_synonym_id = cnvtint(cm.synonym_id), cm.updt_cnt, cm_updt_dt_tm = format(cm.updt_dt_tm,
   "YYYY-MM-DD HH:MM:SS;;D"),
  i_immunization_modifier_id = cnvtint(i.immunization_modifier_id), i_organization_id = cnvtint(i
   .organization_id), i_beg_effective_dt_tm = format(i.beg_effective_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  i_event_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(i.event_cd),3
         ),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  i_expect_meaning = trim(replace(replace(replace(replace(replace(trim(i.expect_meaning,3),"&",
        "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  i_funding_source_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(i
          .funding_source_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3),
  i_vfc_status_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(i
          .vfc_status_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), i_vis_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(i
          .vis_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  i_vis_dt_tm = format(i.vis_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"),
  i_vis_provided_on_dt_tm = format(i.vis_provided_on_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"), ce
  .ce_event_note_id, ce_event_note_id = trim(replace(cnvtstring(ce.event_note_id),".0*","",0),3),
  ce_event_id = trim(replace(cnvtstring(ce.event_id),".0*","",0),3), ce_note_dt_tm = format(ce
   .note_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"), ce_importance_flag =
  IF (ce.importance_flag=1) "Low"
  ELSEIF (ce.importance_flag=2) "Medium"
  ELSEIF (ce.importance_flag=4) "High"
  ELSE " "
  ENDIF
  ,
  ce_note_prsnl_id = cnvtint(ce.note_prsnl_id), ce_note_prsnl_name = trim(replace(replace(replace(
      replace(replace(trim(ce_pr.name_full_formatted,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
     "'","&apos;",0),'"',"&quot;",0),3), ce_entry_method_cd = cnvtint(ce.entry_method_cd),
  ce_entry_method_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(ce
          .entry_method_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
    "&quot;",0),3), ce_entry_method_mean = trim(replace(replace(replace(replace(replace(trim(
         uar_get_code_meaning(ce.entry_method_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), ce_note_type_cd = cnvtint(ce.note_type_cd),
  ce_note_type_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(ce
          .note_type_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0
    ),3), ce_note_type_mean = trim(replace(replace(replace(replace(trim(uar_get_code_meaning(ce
         .note_type_cd),3),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  ce_note_format_cd = cnvtint(ce.note_format_cd),
  ce_note_format_disp = trim(replace(replace(replace(replace(replace(trim(uar_get_code_display(ce
          .note_format_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
    0),3), ce_note_format_mean = trim(replace(replace(replace(replace(replace(trim(
         uar_get_code_meaning(ce.note_format_cd),3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
     "&apos;",0),'"',"&quot;",0),3), ce_record_status_disp = trim(replace(replace(replace(replace(
       replace(trim(uar_get_code_display(ce.record_status_cd),3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  ce.updt_cnt, ce_updt_dt_tm = format(ce.updt_dt_tm,"YYYY-MM-DD HH:MM:SS;;D"), l_long_blob = trim(
   replace(replace(replace(replace(replace(trim(l.long_blob,3),"&","&amp;",0),"<","&lt;",0),">",
      "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
  blob_contents = substring(1,32000,l.long_blob)
  FROM (dummyt d1  WITH seq = value(size(event_codes->qual,5))),
   clinical_event c,
   ce_event_prsnl cep,
   prsnl ap,
   ce_med_result cm,
   immunization_modifier i,
   ce_event_note ce,
   prsnl ce_pr,
   long_blob l
  PLAN (d1)
   JOIN (c
   WHERE (c.event_cd=event_codes->qual[d1.seq].event_cd)
    AND parser(where_params)
    AND parser(where_res_status_params)
    AND c.valid_from_dt_tm < sysdate
    AND c.valid_until_dt_tm > sysdate)
   JOIN (cep
   WHERE cep.event_id=c.event_id)
   JOIN (ap
   WHERE ap.person_id=cep.action_prsnl_id)
   JOIN (cm
   WHERE cm.event_id=c.event_id)
   JOIN (i
   WHERE (i.event_id= Outerjoin(c.event_id)) )
   JOIN (ce
   WHERE (ce.event_id= Outerjoin(c.event_id))
    AND (ce.valid_from_dt_tm< Outerjoin(sysdate))
    AND (ce.valid_until_dt_tm> Outerjoin(sysdate)) )
   JOIN (ce_pr
   WHERE (ce_pr.person_id= Outerjoin(ce.note_prsnl_id)) )
   JOIN (l
   WHERE (l.parent_entity_id= Outerjoin(ce.ce_event_note_id))
    AND (l.parent_entity_name= Outerjoin("CE_EVENT_NOTE")) )
  ORDER BY c.updt_dt_tm DESC, c.event_id, ce.ce_event_note_id,
   ce.updt_dt_tm DESC
  HEAD REPORT
   html_tag = build('<?xml version="1.0"?>'), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>"
  HEAD c.event_id
   col + 1, "<ImmunizationResult>", row + 1,
   c_ev_id = build("<EventId>",c_event_id,"</EventId>"), col + 1, c_ev_id,
   row + 1, par_ev_id = build("<ParentEventId>",c_parent_event_id,"</ParentEventId>"), col + 1,
   par_ev_id, row + 1, c_enc_id = build("<EncounterId>",c_encntr_id,"</EncounterId>"),
   col + 1, c_enc_id, row + 1,
   c_pat_id = build("<PatientId>",c_patient_id,"</PatientId>"), col + 1, c_pat_id,
   row + 1, col + 1, "<EventCode>",
   row + 1, c_ev_cd = build("<Value>",c_event_cd,"</Value>"), col + 1,
   c_ev_cd, row + 1, c_ev_disp = build("<Display>",c_event_disp,"</Display>"),
   col + 1, c_ev_disp, row + 1,
   col + 1, "</EventCode>", row + 1,
   c_ev_end_dt = build("<EventEndDateTime>",c_event_end_dt_tm,"</EventEndDateTime>"), col + 1,
   c_ev_end_dt,
   row + 1, c_ev_end_dt_tz = build("<EventEndTimeZone>",c_event_end_tz,"</EventEndTimeZone>"), col +
   1,
   c_ev_end_dt_tz, row + 1, c_ord_id = build("<OrderId>",c_order_id,"</OrderId>"),
   col + 1, c_ord_id, row + 1,
   c_pub_flg = build("<Publish>",c_publish_flag,"</Publish>"), col + 1, c_pub_flg,
   row + 1, c_updt_cnt = build("<UpdateCount>",c.updt_cnt,"</UpdateCount>"), col + 1,
   c_updt_cnt, row + 1, c_updt_dt = build("<UpdateDateTime>",c_updt_dt_tm,"</UpdateDateTime>"),
   col + 1, c_updt_dt, row + 1,
   c_sig_dt = build("<ClinicallySignificantUpdateDateTime>",c_clinsig_updt_dt_tm,
    "</ClinicallySignificantUpdateDateTime>"), col + 1, c_sig_dt,
   row + 1, c_ev_tag = build("<EventTag>",c.event_tag,"</EventTag>"), col + 1,
   c_ev_tag, row + 1, c_res_val = build("<ResultValue>",c_result_val,"</ResultValue>"),
   col + 1, c_res_val, row + 1,
   evn_typ = build("<ImmunizationResultType>",
    IF (c.source_cd=0) adhoc
    ELSE history
    ENDIF
    ,"</ImmunizationResultType>"), col + 1, evn_typ,
   row + 1, col + 1, "<ResultStatus>",
   row + 1, c_rs_v = build("<Value>",c_result_status_cd,"</Value>"), col + 1,
   c_rs_v, row + 1, c_rs_d = build("<Display>",c_result_status_disp,"</Display>"),
   col + 1, c_rs_d, row + 1,
   c_rs_m = build("<Meaning>",c_result_status_mean,"</Meaning>"), col + 1, c_rs_m,
   row + 1, col + 1, "</ResultStatus>",
   row + 1, col + 1, "<EventClass>",
   row + 1, c_ec_v = build("<Value>",c_event_class_cd,"</Value>"), col + 1,
   c_ec_v, row + 1, c_ec_d = build("<Display>",c_event_class_disp,"</Display>"),
   col + 1, c_ec_d, row + 1,
   c_ec_m = build("<Meaning>",c_event_class_mean,"</Meaning>"), col + 1, c_ec_m,
   row + 1, col + 1, "</EventClass>",
   row + 1, row + 1, "<EventRelation>",
   col + 1, c_er_v = build("<Value>",c_event_reltn_cd,"</Value>"), col + 1,
   c_er_v, row + 1, c_er_d = build("<Display>",c_event_reltn_disp,"</Display>"),
   col + 1, c_er_d, row + 1,
   c_er_m = build("<Meaning>",c_event_reltn_mean,"</Meaning>"), col + 1, c_er_m,
   row + 1, col + 1, "</EventRelation>",
   row + 1, col + 1, "<ContributorSystem>",
   row + 1, c_cs_v = build("<Display>",c_contributor_system_disp,"</Display>"), col + 1,
   c_cs_v, row + 1, c_cs_d = build("<Meaning>",c_contributor_system_mean,"</Meaning>"),
   col + 1, c_cs_d, row + 1,
   c_cs_m = build("<Value>",c_contributor_system_cd,"</Value>"), col + 1, c_cs_m,
   row + 1, v24 = "</ContributorSystem>", col + 1,
   v24, row + 1, col + 1,
   "<TaskAssay>", row + 1, c_ta_v = build("<Value>",c_task_assay_cd,"</Value>"),
   col + 1, c_ta_v, row + 1,
   c_ta_d = build("<Display>",c_task_assay_disp,"</Display>"), col + 1, c_ta_d,
   row + 1, c_ta_m = build("<Meaning>",c_task_assay_mean,"</Meaning>"), col + 1,
   c_ta_m, row + 1, v32 = "</TaskAssay>",
   col + 1, v32, row + 1,
   col + 1, "<RecordStatus>", row + 1,
   c_recst_v = build("<Value>",c_record_status_cd,"</Value>"), col + 1, c_recst_v,
   row + 1, c_recst_d = build("<Display>",c_record_status_disp,"</Display>"), col + 1,
   c_recst_d, row + 1, c_recst_m = build("<Meaning>",c_record_status_mean,"</Meaning>"),
   col + 1, c_recst_m, row + 1,
   col + 1, "</RecordStatus>", row + 1,
   col + 1, "<EntryMode>", row + 1,
   c_em_v = build("<Value>",c_entry_mode_cd,"</Value>"), col + 1, c_em_v,
   row + 1, c_em_d = build("<Display>",c_entry_mode_disp,"</Display>"), col + 1,
   c_em_d, row + 1, c_em_m = build("<Meaning>",c_entry_mode_mean,"</Meaning>"),
   col + 1, c_em_m, row + 1,
   col + 1, "</EntryMode>", row + 1
   IF (c.source_cd != 0)
    col + 1, "<EventSource>", row + 1,
    c_sorc_v = build("<Value>",c_source_cd,"</Value>"), col + 1, c_sorc_v,
    row + 1, c_sorc_d = build("<Display>",c_source_disp,"</Display>"), col + 1,
    c_sorc_d, row + 1, c_sorc_m = build("<Meaning>",c_source_mean,"</Meaning>"),
    col + 1, c_sorc_m, row + 1,
    col + 1, "</EventSource>", row + 1
   ENDIF
   col + 1, "<EventPrsnlActions>", row + 1,
   col + 1, "<EventPrsnlAction>", row + 1,
   v82 = build("<EventPrsnlActionId>",cep_event_prsnl_id,"</EventPrsnlActionId>"), col + 1, v82,
   row + 1, v82a = build("<PrsnlId>",cep_action_prsnl_id,"</PrsnlId>"), col + 1,
   v82a, row + 1, v98 = build("<NameFullFormatted>",ap_name_full_formatted,"</NameFullFormatted>"),
   col + 1, v98, row + 1,
   col + 1, "<ActionType>", row + 1,
   v85 = build("<Value>",cep_action_type_cd,"</Value>"), col + 1, v85,
   row + 1, v86 = build("<Display>",cep_action_type_disp,"</Display>"), col + 1,
   v86, row + 1, v87 = build("<Meaning>",cep_action_type_mean,"</Meaning>"),
   col + 1, v87, row + 1,
   col + 1, "</ActionType>", row + 1,
   v89 = build("<ActionDateTime>",cep_action_dt_tm,"</ActionDateTime>"), col + 1, v89,
   row + 1, v90 = build("<ActionTimeZone>",cep_action_tz,"</ActionTimeZone>"), col + 1,
   v90, row + 1, col + 1,
   "<ActionStatus>", row + 1, v92 = build("<Value>",cep_action_status_cd,"</Value>"),
   col + 1, v92, row + 1,
   v93 = build("<Display>",cep_action_status_disp,"</Display>"), col + 1, v93,
   row + 1, v94 = build("<Meaning>",cep_action_status_mean,"</Meaning>"), col + 1,
   v94, row + 1, col + 1,
   "</ActionStatus>", row + 1, col + 1,
   "</EventPrsnlAction>", row + 1, col + 1,
   "</EventPrsnlActions>", row + 1, cm_admn_dos = build("<AdministrationDose>",cm.admin_dosage,
    "</AdministrationDose>"),
   col + 1, cm_admn_dos, row + 1,
   cm_admn_prov_id = build("<ProviderId>",cm_admin_prov_id,"</ProviderId>"), col + 1, cm_admn_prov_id,
   row + 1, col + 1, "<AdministrationRoute>",
   row + 1, cm_admn_routev = build("<Value>",cm_admin_route_cd,"</Value>"), col + 1,
   cm_admn_routev, row + 1, cm_admn_routed = build("<Dispaly>",cm_admin_route_disp,"</Dispaly>"),
   col + 1, cm_admn_routed, row + 1,
   cm_admn_routem = build("<Meaning>",cm_admin_route_mean,"</Meaning>"), col + 1, cm_admn_routem,
   row + 1, col + 1, "</AdministrationRoute>",
   row + 1, col + 1, "<AdministrationSite>",
   row + 1, cm_admn_sitev = build("<Value>",cm_admin_site_cd,"</Value>"), col + 1,
   cm_admn_sitev, row + 1, cm_admn_sited = build("<Display>",cm_admin_site_disp,"</Display>"),
   col + 1, cm_admn_sited, row + 1,
   cm_admn_sitem = build("<Meaning>",cm_admin_site_mean,"</Meaning>"), col + 1, cm_admn_sitem,
   row + 1, col + 1, "</AdministrationSite>",
   row + 1, col + 1, "<AdministrationDoseUnits>",
   row + 1, cm_dos_unitv = build("<Value>",cm_dosage_unit_cd,"</Value>"), col + 1,
   cm_dos_unitv, row + 1, cm_dos_unitd = build("<Display>",cm_dosage_unit_disp,"</Display>"),
   col + 1, cm_dos_unitd, row + 1,
   cm_dos_unitm = build("<Meaning>",cm_dosage_unit_mean,"</Meaning>"), col + 1, cm_dos_unitm,
   row + 1, col + 1, "</AdministrationDoseUnits>",
   row + 1, col + 1, "<ImmunizationType>",
   row + 1, cm_imm_typv = build("<Value>",cm_immunization_type_cd,"</Value>"), col + 1,
   cm_imm_typv, row + 1, cm_imm_typd = build("<Display>",cm_immunization_type_disp,"</Display>"),
   col + 1, cm_imm_typd, row + 1,
   cm_imm_typm = build("<Meaning>",cm_immunization_type_mean,"</Meaning>"), col + 1, cm_imm_typm,
   row + 1, col + 1, "</ImmunizationType>",
   row + 1, col + 1, "<SubstanceManufacturer>",
   row + 1, cm_sub_manfv = build("<Value>",cm_substance_manufacturer_cd,"</Value>"), col + 1,
   cm_sub_manfv, row + 1, cm_sub_manfd = build("<Display>",cm_substance_manufacturer_disp,
    "</Display>"),
   col + 1, cm_sub_manfd, row + 1,
   cm_sub_manfm = build("<Meaning>",cm_substance_manufacturer_mean,"</Meaning>"), col + 1,
   cm_sub_manfm,
   row + 1, col + 1, "</SubstanceManufacturer>",
   row + 1, cm_st_dt = build("<AdministrationDateTime>",cm_admin_start_dt_tm,
    "</AdministrationDateTime>"), col + 1,
   cm_st_dt, row + 1, cm_st_dt_tz = build("<AdministrationTimeZone>",cm_admin_start_tz,
    "</AdministrationTimeZone>"),
   col + 1, cm_st_dt_tz, row + 1,
   cm_sub_exp_dt = build("<SubstanceExpireDateTime>",cm_substance_exp_dt_tm,
    "</SubstanceExpireDateTime>"), col + 1, cm_sub_exp_dt,
   row + 1, cm_sub_lot_nm = build("<SubstanceLotNumber>",cm_substance_lot_number,
    "</SubstanceLotNumber>"), col + 1,
   cm_sub_lot_nm, row + 1, cm_syn_id = build("<SynonymId>",cm_synonym_id,"</SynonymId>"),
   col + 1, cm_syn_id, row + 1,
   cm_updt_cnt = build("<SubstanceUpdateCount>",cm.updt_cnt,"</SubstanceUpdateCount>"), col + 1,
   cm_updt_cnt,
   row + 1, cm_updt_dt = build("<SubstanceUpdatedDateTime>",cm_updt_dt_tm,
    "</SubstanceUpdatedDateTime>"), col + 1,
   cm_updt_dt, row + 1
   IF (i.immunization_modifier_id != 0)
    i_mod_id = build("<ImmunizationModifierId>",i_immunization_modifier_id,
     "</ImmunizationModifierId>"), col + 1, i_mod_id,
    row + 1, i_org_id = build("<OrganizationId>",i_organization_id,"</OrganizationId>"), col + 1,
    i_org_id, row + 1, i_beg_dt = build("<ImmunizationBeginDateTime>",i_beg_effective_dt_tm,
     "</ImmunizationBeginDateTime>"),
    col + 1, i_beg_dt, row + 1,
    i_ev_disp = build("<EventDisplay>",i_event_disp,"</EventDisplay>"), col + 1, i_ev_disp,
    row + 1, i_exp_mean = build("<ExpectMeaning>",i_expect_meaning,"</ExpectMeaning>"), col + 1,
    i_exp_mean, row + 1, i_fund_src = build("<FundingSource>",i_funding_source_disp,
     "</FundingSource>"),
    col + 1, i_fund_src, row + 1,
    i_vfc_st = build("<VFCStatus>",i_vfc_status_disp,"</VFCStatus>"), col + 1, i_vfc_st,
    row + 1, i_vis = build("<VIS>",i_vis_disp,"</VIS>"), col + 1,
    i_vis, row + 1, i_vis_dt = build("<VISDateTime>",i_vis_dt_tm,"</VISDateTime>"),
    col + 1, i_vis_dt, row + 1,
    i_vis_prov_dt = build("<VISProviderOnDateTime>",i_vis_provided_on_dt_tm,
     "</VISProviderOnDateTime>"), col + 1, i_vis_prov_dt,
    row + 1
   ENDIF
   col + 1, "<EventNotes>", row + 1
  HEAD ce.ce_event_note_id
   IF (ce.ce_event_note_id != 0)
    col + 1, "<EventNote>", row + 1,
    v61 = build("<EventNoteId>",ce_event_note_id,"</EventNoteId>"), col + 1, v61,
    row + 1, ce_ev_id = build("<EventId>",ce_event_id,"</EventId>"), col + 1,
    ce_ev_id, row + 1, v63 = build("<DateTime>",ce_note_dt_tm,"</DateTime>"),
    col + 1, v63, row + 1,
    v69 = build("<Importance>",ce_importance_flag,"</Importance>"), col + 1, v69,
    row + 1, v71 = build("<PrsnlId>",ce_note_prsnl_id,"</PrsnlId>"), col + 1,
    v71, row + 1, v71n = build("<NameFullFormatted>",ce_note_prsnl_name,"</NameFullFormatted>"),
    col + 1, v71n, row + 1,
    v77 = build("<NonChartableIndicator>",
     IF (ce.non_chartable_flag=1) "true"
     ELSE "false"
     ENDIF
     ,"</NonChartableIndicator>"), col + 1, v77,
    row + 1, ce_updt_dt = build("<UpdatedDateTime>",ce_updt_dt_tm,"</UpdatedDateTime>"), col + 1,
    ce_updt_dt, row + 1, blob_out = fillstring(32000," "),
    blob_out1 = fillstring(32000," ")
    IF (ce.compression_cd=ocf_comp_cd)
     blob_ret_len = 0,
     CALL uar_ocf_uncompress(blob_contents,32000,blob_out,32000,blob_ret_len),
     CALL uar_rtf3(blob_out,textlen(blob_out),blob_out1,32000,32000,1),
     blob_out1 = replace(blob_out1,char(13)," ",0), blob_out1 = replace(blob_out1,char(10)," ",0),
     blob_out1 = trim(replace(replace(replace(replace(replace(trim(blob_out1,3),"&","&amp;",0),"<",
          "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
    ELSE
     blob_out1 = trim(replace(replace(replace(replace(replace(l.long_blob,"&","&amp;",0),"<","&lt;",0
          ),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3)
    ENDIF
    l_blob = build("<Body>",trim(replace(trim(blob_out1,3),"ocf_blob",""),3),"</Body>"), col + 1,
    l_blob,
    row + 1, col + 1, "<Type>",
    row + 1, v65 = build("<Value>",ce_note_type_cd,"</Value>"), col + 1,
    v65, row + 1, v66 = build("<Display>",ce_note_type_disp,"</Display>"),
    col + 1, v66, row + 1,
    v67 = build("<Meaning>",ce_note_type_mean,"</Meaning>"), col + 1, v67,
    row + 1, col + 1, "</Type>",
    row + 1, col + 1, "<Format>",
    row + 1, v65f = build("<Value>",ce_note_format_cd,"</Value>"), col + 1,
    v65f, row + 1, v66f = build("<Display>",ce_note_format_disp,"</Display>"),
    col + 1, v66f, row + 1,
    v67f = build("<Meaning>",ce_note_format_mean,"</Meaning>"), col + 1, v67f,
    row + 1, col + 1, "</Format>",
    row + 1, col + 1, "<EntryMethod>",
    row + 1, v73 = build("<Value>",ce_entry_method_cd,"</Value>"), col + 1,
    v73, row + 1, v74 = build("<Display>",ce_entry_method_disp,"</Display>"),
    col + 1, v74, row + 1,
    v75 = build("<Meaning>",ce_entry_method_mean,"</Meaning>"), col + 1, v75,
    row + 1, col + 1, "</EntryMethod>",
    row + 1, col + 1, "</EventNote>",
    row + 1
   ENDIF
  FOOT  c.event_id
   col + 1, "</EventNotes>", row + 1,
   col + 1, "</ImmunizationResult>", row + 1
  FOOT REPORT
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 33000, maxrow = 0, nocounter,
   nullreport, formfeed = none, format = variable,
   time = 30
 ;end select
END GO
