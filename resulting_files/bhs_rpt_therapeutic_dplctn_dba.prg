CREATE PROGRAM bhs_rpt_therapeutic_dplctn:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Please select the start date." = "CURDATE",
  "Please select the end date." = "CURDATE",
  "Please select the facility." = 0
  WITH s_outdev, s_start_date, s_end_date,
  f_facility
 FREE RECORD data
 RECORD data(
   1 l_cnt = i4
   1 data[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_patient_name = vc
     2 s_fin = vc
     2 s_patient_loc = vc
     2 f_order1_cat_cd = f8
     2 d_order1_dt_tm = dq8
     2 f_order2_cat_cd = f8
     2 d_order2_dt_tm = dq8
     2 s_provider_action = vc
     2 s_provider1_name = vc
     2 s_provider2_name = vc
     2 s_pharmacist_name = vc
     2 s_pharmacist_action = vc
     2 orders[*]
       3 f_order_id = f8
       3 d_order_dt_tm = dq8
       3 f_catalog_cd = f8
       3 l_order_ind = i4
       3 s_ordering_provider = vc
 )
 DECLARE mf_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_fin = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_inpatient = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT")), protect
 DECLARE mf_bhspharmacist = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSPHARMACIST")),
 protect
 DECLARE mf_bhspharmacymgr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSPHARMACYMGR")),
 protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE ml_acnt = i4 WITH noconstant(0), protect
 DECLARE ml_bcnt = i4 WITH noconstant(0), protect
 DECLARE ml_num = i4 WITH noconstant(0), protect
 DECLARE ml_pos = i4 WITH noconstant(0), protect
 DECLARE ms_ordering_provider = vc WITH noconstant(""), protect
 DECLARE ms_personnel_action = vc WITH noconstant(""), protect
 DECLARE ms_provider_action = vc WITH noconstant(""), protect
 DECLARE ms_pharmacist_name = vc WITH noconstant(""), protect
 DECLARE ms_pharmacist_action = vc WITH noconstant(""), protect
 DECLARE ms_last_mod = vc WITH noconstant(""), protect
 DECLARE md_order2_dt_tm = dq8 WITH noconstant(cnvtdatetime("01-jan-1900 00:00:00")), protect
 SET ms_start_date = concat( $S_START_DATE," 00:00:00")
 SET ms_end_date = concat( $S_END_DATE," 23:59:59")
 SELECT INTO "nl:"
  FROM eks_dlg_event ed,
   prsnl pr,
   encounter e,
   person p,
   org_alias_pool_reltn oapr,
   encntr_alias fin,
   orders o
  PLAN (ed
   WHERE ed.dlg_name="BHS_EKM!BHS_SYN_DUPMED_OPIATES"
    AND ed.dlg_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date))
   JOIN (pr
   WHERE pr.person_id=ed.dlg_prsnl_id)
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_class_cd=mf_inpatient
    AND (e.loc_facility_cd= $F_FACILITY)
    AND e.active_ind=1
    AND e.active_status_cd=mf_active
    AND e.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (oapr
   WHERE oapr.organization_id=e.organization_id
    AND oapr.alias_entity_name="ENCNTR_ALIAS"
    AND oapr.alias_entity_alias_type_cd=mf_fin
    AND oapr.active_ind=1)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_fin
    AND fin.alias_pool_cd=oapr.alias_pool_cd
    AND fin.active_ind=1
    AND fin.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (o
   WHERE o.order_id=ed.trigger_order_id
    AND o.active_ind=1)
  ORDER BY ed.person_id, ed.encntr_id, o.order_id
  HEAD REPORT
   ml_acnt = 0, ml_bcnt = 0
  HEAD ed.person_id
   null
  HEAD ed.encntr_id
   ml_acnt += 1, data->l_cnt = ml_acnt, stat = alterlist(data->data,ml_acnt),
   data->data[ml_acnt].f_person_id = ed.person_id, data->data[ml_acnt].f_encntr_id = ed.encntr_id,
   data->data[ml_acnt].s_patient_name = trim(p.name_full_formatted,3),
   data->data[ml_acnt].s_patient_loc = trim(uar_get_code_display(e.loc_nurse_unit_cd),3), data->data[
   ml_acnt].s_fin = trim(fin.alias,3), data->data[ml_acnt].d_order1_dt_tm = o.orig_order_dt_tm,
   data->data[ml_acnt].s_provider1_name = "", data->data[ml_acnt].s_provider2_name = "", data->data[
   ml_acnt].s_pharmacist_name = "",
   ml_bcnt = 0, ms_pharmacist_name = "", ms_personnel_action = "",
   ms_provider_action = "", ms_pharmacist_action = ""
  HEAD o.order_id
   null
  DETAIL
   ml_bcnt += 1, stat = alterlist(data->data[ml_acnt].orders,ml_bcnt)
   IF (ml_bcnt=1)
    data->data[ml_acnt].f_order1_cat_cd = ed.trigger_entity_id
   ENDIF
   data->data[ml_acnt].orders[ml_bcnt].f_order_id = ed.trigger_order_id, data->data[ml_acnt].orders[
   ml_bcnt].l_order_ind = ml_bcnt, data->data[ml_acnt].orders[ml_bcnt].f_catalog_cd = ed
   .trigger_entity_id,
   data->data[ml_acnt].orders[ml_bcnt].s_ordering_provider = ""
   CASE (ed.action_flag)
    OF 0:
     ms_personnel_action = "Non-specified action"
    OF 1:
     ms_personnel_action = "Alert message display only"
    OF 2:
     ms_personnel_action = "Cancel the triggering action"
    OF 3:
     ms_personnel_action = "Continue the triggering action"
    OF 4:
     ms_personnel_action = "Modify the triggering action"
    OF 5:
     ms_personnel_action = "Message from EKS_LOG_ACTION_A template"
   ENDCASE
   IF (pr.position_cd IN (mf_bhspharmacist, mf_bhspharmacymgr))
    ms_pharmacist_name = trim(pr.name_full_formatted,3), ms_pharmacist_action = ms_personnel_action
   ELSE
    ms_provider_action = ms_personnel_action
   ENDIF
  FOOT  ed.encntr_id
   data->data[ml_acnt].f_order2_cat_cd = ed.trigger_entity_id, data->data[ml_acnt].d_order2_dt_tm = o
   .orig_order_dt_tm, data->data[ml_acnt].s_provider_action = ms_provider_action,
   data->data[ml_acnt].s_pharmacist_name = ms_pharmacist_name, data->data[ml_acnt].
   s_pharmacist_action = ms_pharmacist_action
  FOOT REPORT
   data->l_cnt = ml_acnt
  WITH nocounter
 ;end select
 IF (ml_acnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(data->l_cnt)),
   (dummyt d2  WITH seq = 1),
   order_action o,
   prsnl p
  PLAN (d1
   WHERE maxrec(d2,size(data->data[d1.seq].orders,5)))
   JOIN (d2)
   JOIN (o
   WHERE (o.order_id=data->data[d1.seq].orders[d2.seq].f_order_id)
    AND o.action_sequence > 0
    AND o.order_provider_id > 0.0)
   JOIN (p
   WHERE p.person_id=o.order_provider_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY o.order_id
  HEAD REPORT
   ml_cnt = 0
  HEAD o.order_id
   ml_cnt = 0, ms_ordering_provider = ""
  DETAIL
   ml_cnt += 1
   IF (ml_cnt=1)
    data->data[d1.seq].s_provider1_name = trim(p.name_full_formatted,3)
   ENDIF
   data->data[d1.seq].orders[d2.seq].s_ordering_provider = trim(p.name_full_formatted,3),
   ms_ordering_provider = trim(p.name_full_formatted,3)
  FOOT  o.order_id
   data->data[d1.seq].s_provider2_name = ms_ordering_provider
  WITH nocounter
 ;end select
 SELECT INTO  $S_OUTDEV
  patient_name = trim(substring(1,100,data->data[d1.seq].s_patient_name),3), fin = trim(substring(1,
    50,data->data[d1.seq].s_fin),3), unit = trim(substring(1,100,data->data[d1.seq].s_patient_loc),3),
  order_1 = trim(uar_get_code_display(data->data[d1.seq].f_order1_cat_cd),3), order1_date_time =
  format(data->data[d1.seq].d_order1_dt_tm,"dd-mmm-yyyy hh:mm;;d"), order_2 = trim(
   uar_get_code_display(data->data[d1.seq].f_order2_cat_cd),3),
  order_2_date_time = format(data->data[d1.seq].d_order2_dt_tm,"dd-mmm-yyyy hh:mm;;d"),
  provider_action = trim(substring(1,50,data->data[d1.seq].s_provider_action),3), provider_1 = trim(
   substring(1,100,data->data[d1.seq].s_provider1_name),3),
  provider_2 = trim(substring(1,100,data->data[d1.seq].s_provider2_name),3), pharmacist = trim(
   substring(1,100,data->data[d1.seq].s_pharmacist_name),3), pharmacist_action = trim(substring(1,100,
    data->data[d1.seq].s_pharmacist_action),3)
  FROM (dummyt d1  WITH seq = value(data->l_cnt))
  PLAN (d1)
  WITH format, separator = " ", nocounter
 ;end select
 SET ms_last_mod = "000 - 26-Mar-2020 - Josh DeLeenheer/Matt Butler (HPG)"
#exit_script
 FREE RECORD data
END GO
