CREATE PROGRAM bhs_mp_get_icu_meds:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID:" = 0
  WITH outdev, f_encntr_id
 FREE RECORD m_info
 RECORD m_info(
   1 s_min_date = vc
   1 s_max_date = vc
   1 cs_ord_ids[*]
     2 f_order_id = f8
   1 meds[*]
     2 f_order_id = f8
     2 f_orderable_cat_cd = f8
     2 s_orderable_cat_disp = vc
     2 s_orderable_mnemonic = vc
     2 s_orderable_label = vc
     2 f_synonym_id = f8
     2 n_iv_set_ind = i2
     2 f_iv_set_syn_id = f8
     2 n_include_ind = i2
     2 admins[*]
       3 s_db_date = vc
       3 s_date = vc
       3 f_dose = f8
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE mf_critcare_drip_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CRITICALCAREDRIPS"))
 DECLARE mf_label_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6030,
   "CARESETLABEL"))
 DECLARE mf_order_type_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6030,
   "CARESETORDERABLE"))
 DECLARE mf_med_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,"MEDICATIONS"))
 DECLARE mf_iv_cat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16389,"IVSOLUTIONS"))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 SET m_info->s_max_date = trim(format(cnvtlookbehind("5,H",sysdate),"mm-dd-yyyy hh:mm;;d"))
 SET m_info->s_min_date = trim(format(cnvtlookbehind("29,H",sysdate),"mm-dd-yyyy hh:mm;;d"))
 CALL echo(m_info->s_max_date)
 CALL echo(m_info->s_min_date)
 SELECT
  ocs.catalog_cd, oc1.dcp_clin_cat_cd, ocs.mnemonic,
  cc.comp_label
  FROM order_catalog oc,
   order_catalog oc1,
   cs_component cc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_cd=mf_critcare_drip_cd
    AND oc.catalog_cd > 0)
   JOIN (cc
   WHERE cc.catalog_cd=oc.catalog_cd)
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(cc.comp_id)
    AND ocs.active_ind=outerjoin(1)
    AND ocs.catalog_cd > outerjoin(0))
   JOIN (oc1
   WHERE oc1.catalog_cd=outerjoin(ocs.catalog_cd))
  ORDER BY oc.primary_mnemonic, cc.comp_seq
  HEAD REPORT
   pl_cnt = 0, pl_rec = 0, pf_idx = 0.0,
   pn_dup = 0, pl_start = 0
  DETAIL
   pl_rec = 0, pf_idx = 0, pn_dup = 0,
   pl_start = 0
   IF (cc.comp_seq > 1)
    IF (cc.comp_type_cd=mf_label_type_cd)
     ms_tmp = trim(cc.comp_label), ms_tmp = replace(ms_tmp,"* ","")
    ELSEIF (cc.comp_type_cd=mf_order_type_cd
     AND  NOT (cnvtupper(ms_tmp) IN ("IV LINE FLUSHES", "IV BOLUSES")))
     WHILE (pl_start <= pl_cnt)
       pf_idx = locateval(pl_rec,pl_start,pl_cnt,ocs.catalog_cd,m_info->meds[pl_rec].
        f_orderable_cat_cd)
       IF (pf_idx > 0)
        IF ((m_info->meds[pf_idx].s_orderable_label=ms_tmp)
         AND (m_info->meds[pf_idx].s_orderable_mnemonic=trim(ocs.mnemonic)))
         pn_dup = 1
        ENDIF
       ENDIF
       IF (pf_idx > 0
        AND pl_start < pl_cnt)
        pl_start = (pf_idx+ 1)
       ELSE
        pl_start = (pl_cnt+ 1)
       ENDIF
     ENDWHILE
     IF (pn_dup=0)
      pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->meds,pl_cnt)
      IF (oc1.dcp_clin_cat_cd=mf_iv_cat_cd)
       m_info->meds[pl_cnt].f_iv_set_syn_id = cc.comp_id, m_info->meds[pl_cnt].n_iv_set_ind = 1
      ENDIF
      m_info->meds[pl_cnt].f_orderable_cat_cd = ocs.catalog_cd, m_info->meds[pl_cnt].
      s_orderable_cat_disp = trim(uar_get_code_display(ocs.catalog_cd)), m_info->meds[pl_cnt].
      s_orderable_label = ms_tmp,
      m_info->meds[pl_cnt].s_orderable_mnemonic = trim(ocs.mnemonic), m_info->meds[pl_cnt].
      f_synonym_id = cc.comp_id
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   CALL echo(build2("pl_cnt: ",pl_cnt))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM orders o
  PLAN (o
   WHERE o.encntr_id=mf_encntr_id
    AND o.catalog_cd=mf_critcare_drip_cd)
  ORDER BY o.order_id DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD o.order_id
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->cs_ord_ids,pl_cnt), m_info->cs_ord_ids[pl_cnt].
   f_order_id = o.order_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  GO TO exit_script
 ENDIF
 CALL echo("get orders")
 SELECT INTO "nl:"
  pf_orderable_cat_cd = m_info->meds[d.seq].f_orderable_cat_cd, ps_date = trim(format(cnvtlookbehind(
     "5,H",cmr.admin_start_dt_tm),"mm-dd-yyyy hh:mm;;d")), ps_db_date = trim(format(cmr
    .admin_start_dt_tm,"mm-dd-yyyy hh:mm;;d"))
  FROM (dummyt d  WITH seq = value(size(m_info->meds,5))),
   orders o,
   clinical_event ce,
   ce_med_result cmr
  PLAN (d)
   JOIN (o
   WHERE o.encntr_id=mf_encntr_id
    AND o.orig_ord_as_flag != 2
    AND o.template_order_flag IN (0, 1)
    AND expand(ml_idx,1,size(m_info->cs_ord_ids,5),o.cs_order_id,m_info->cs_ord_ids[ml_idx].
    f_order_id)
    AND o.cs_flag=2
    AND (((o.catalog_cd=m_info->meds[d.seq].f_orderable_cat_cd)
    AND o.iv_set_synonym_id=0
    AND (o.synonym_id=m_info->meds[d.seq].f_synonym_id)) OR ((o.iv_set_synonym_id=m_info->meds[d.seq]
   .f_iv_set_syn_id)
    AND o.iv_ind=1
    AND o.iv_set_synonym_id > 0)) )
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
  ORDER BY d.seq, ce.order_id, cmr.admin_start_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD d.seq
   pl_cnt = 0
  HEAD ce.order_id
   m_info->meds[d.seq].f_order_id = o.order_id,
   CALL echo(d.seq),
   CALL echo(build2("orderable: ",m_info->meds[d.seq].s_orderable_cat_disp)),
   CALL echo(build2("catalog_disp : ",trim(uar_get_code_display(o.catalog_cd)))),
   CALL echo(build2("order status: ",trim(uar_get_code_display(o.order_status_cd))))
  DETAIL
   CALL echo(build2("clin_event_id: ",ce.clinical_event_id)),
   CALL echo(build2("event id: ",cmr.event_id)),
   CALL echo(build2("admin date: ",ps_db_date)),
   CALL echo(build2("res status: ",trim(uar_get_code_display(ce.result_status_cd)))),
   CALL echo(build2("refusal code: ",trim(uar_get_code_display(cmr.refusal_cd)))),
   CALL echo(build2("order status: ",trim(uar_get_code_display(o.order_status_cd)))),
   pl_cnt = (pl_cnt+ 1), stat = alterlist(m_info->meds[d.seq].admins,pl_cnt), m_info->meds[d.seq].
   n_include_ind = 1
   IF (cmr.admin_dosage > 0.0)
    m_info->meds[d.seq].admins[pl_cnt].f_dose = cmr.admin_dosage,
    CALL echo(build2("dose: ",cmr.admin_dosage))
   ELSEIF (cmr.infusion_rate > 0.0)
    m_info->meds[d.seq].admins[pl_cnt].f_dose = cmr.infusion_rate,
    CALL echo(build2("infu: ",cmr.infusion_rate))
   ENDIF
   m_info->meds[d.seq].admins[pl_cnt].s_date = ps_date, m_info->meds[d.seq].admins[pl_cnt].s_db_date
    = ps_db_date
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
