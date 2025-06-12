CREATE PROGRAM bhs_mp_get_icu_narc:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 s_min_date = vc
   1 s_max_date = vc
   1 meds[*]
     2 f_order_id = f8
     2 f_cat_cd = f8
     2 s_cat_disp = vc
     2 s_mnemonic = vc
     2 admins[*]
       3 s_db_date = vc
       3 s_date = vc
       3 f_dose = f8
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE mf_critcare_drip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CRITICALCAREDRIPS"))
 DECLARE mf_iv_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,"IVSOLUTIONS"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 SET m_info->s_max_date = trim(format(cnvtlookbehind("5,H",sysdate),"mm-dd-yyyy hh:mm;;d"))
 SET m_info->s_min_date = trim(format(cnvtlookbehind("29,H",sysdate),"mm-dd-yyyy hh:mm;;d"))
 CALL echo(m_info->s_max_date)
 CALL echo(m_info->s_min_date)
 CALL echo("get orders")
 SELECT INTO "nl:"
  ps_date = trim(format(cnvtlookbehind("5,H",cmr.admin_start_dt_tm),"mm-dd-yyyy hh:mm;;d")),
  ps_db_date = trim(format(cmr.admin_start_dt_tm,"mm-dd-yyyy hh:mm;;d"))
  FROM orders o,
   clinical_event ce,
   ce_med_result cmr,
   orders o1
  PLAN (o
   WHERE o.encntr_id=mf_encntr_id
    AND o.orig_ord_as_flag != 2
    AND o.template_order_flag IN (0, 1)
    AND o.active_ind=1
    AND o.order_status_cd=mf_ordered_cd
    AND o.hna_order_mnemonic != "*Sodium Chloride*")
   JOIN (o1
   WHERE o1.order_id=o.cs_order_id
    AND o1.catalog_cd != mf_critcare_drip_cd)
   JOIN (ce
   WHERE ce.order_id=o.order_id
    AND ce.event_end_dt_tm BETWEEN cnvtlookbehind("24,h",sysdate) AND sysdate
    AND ce.result_status_cd IN (25, 34, 35)
    AND ce.event_title_text="IVPARENT"
    AND ce.valid_until_dt_tm >= sysdate)
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id
    AND cmr.admin_start_dt_tm BETWEEN cnvtlookbehind("24,h",sysdate) AND sysdate
    AND ((cmr.admin_dosage > 0.0) OR (cmr.infusion_rate > 0.0))
    AND cmr.valid_until_dt_tm >= sysdate)
  ORDER BY o.order_id, cmr.admin_start_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0, pl_admin_cnt = 0
  HEAD o.order_id
   pl_admin_cnt = 0, pl_cnt = (pl_cnt+ 1)
   IF (pl_cnt > size(m_info->meds,5))
    stat = alterlist(m_info->meds,(pl_cnt+ 10))
   ENDIF
   m_info->meds[pl_cnt].f_order_id = o.order_id, m_info->meds[pl_cnt].f_cat_cd = o.catalog_cd, m_info
   ->meds[pl_cnt].s_cat_disp = trim(uar_get_code_display(o.catalog_cd)),
   m_info->meds[pl_cnt].s_mnemonic = o.order_mnemonic,
   CALL echo(fillstring(80,"-")),
   CALL echo(build2("order id: ",trim(cnvtstring(o.order_id)))),
   CALL echo(o.order_mnemonic),
   CALL echo(build2("cat disp: ",trim(uar_get_code_display(o.catalog_cd)))),
   CALL echo(build2("db date: ",ps_db_date)),
   CALL echo(build2("order status: ",trim(uar_get_code_display(o.order_status_cd))))
  DETAIL
   CALL echo(ce.clinical_event_id),
   CALL echo(cmr.event_id),
   CALL echo(build2("admin date: ",ps_db_date)),
   CALL echo(build2("res status: ",trim(uar_get_code_display(ce.result_status_cd)))),
   CALL echo(build2("refusal code: ",trim(uar_get_code_display(cmr.refusal_cd)))),
   CALL echo(build2("order status: ",trim(uar_get_code_display(o.order_status_cd)))),
   pl_admin_cnt = (pl_admin_cnt+ 1), stat = alterlist(m_info->meds[pl_cnt].admins,pl_admin_cnt)
   IF (cmr.admin_dosage > 0.0)
    m_info->meds[pl_cnt].admins[pl_admin_cnt].f_dose = cmr.admin_dosage,
    CALL echo(build2("dose: ",cmr.admin_dosage))
   ELSEIF (cmr.infusion_rate > 0.0)
    m_info->meds[pl_cnt].admins[pl_admin_cnt].f_dose = cmr.infusion_rate,
    CALL echo(build2("infu: ",cmr.infusion_rate))
   ENDIF
   m_info->meds[pl_cnt].admins[pl_admin_cnt].s_date = ps_date, m_info->meds[pl_cnt].admins[
   pl_admin_cnt].s_db_date = ps_db_date
  FOOT REPORT
   stat = alterlist(m_info->meds,pl_cnt)
  WITH nocounter
 ;end select
#exit_script
 CALL echo("rectojson")
 CALL echo(cnvtrectojson(m_info))
 CALL echo("echojson")
 CALL echojson(m_info, $OUTDEV)
 CALL echorecord(m_info)
 FREE RECORD m_info
END GO
