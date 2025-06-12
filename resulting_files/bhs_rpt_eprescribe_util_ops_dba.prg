CREATE PROGRAM bhs_rpt_eprescribe_util_ops:dba
 RECORD m_rec(
   1 l_cnt = i4
   1 list[*]
     2 f_encntr_id = f8
     2 f_person_id = f8
     2 f_order_id = f8
     2 n_include = i2
     2 c_cki = c255
     2 c_drug_identifier = c6
     2 c_ordered_as_mnemonic = c100
     2 c_order_details = c500
     2 d_order_dt_tm = dq8
     2 c_order_dt_tm = c25
     2 c_routing_type = c255
     2 c_csa_schedule = c25
     2 c_order_status = c100
     2 c_location = c100
     2 c_encntr_type = c100
     2 c_fin = c25
     2 c_ordering_provider = c100
     2 c_position = c100
   1 l_scnt = i4
   1 l_ycnt = i4
   1 ylist[*]
     2 l_year = i4
     2 l_mcnt = i4
     2 mlist[*]
       3 l_month = i4
       3 c_month = c30
       3 l_tot_rx = i4
       3 l_tot_rx_esent = i4
       3 l_tot_cs = i4
       3 l_tot_cs_esent = i4
   1 l_gtot_rx = i4
   1 l_gtot_rx_esent = i4
   1 l_gtot_cs = i4
   1 l_gtot_cs_esent = i4
 )
 RECORD m_rpt(
   1 l_cnt = i4
   1 list[*]
     2 field01 = c100
     2 field02 = c100
     2 field03 = c100
     2 field04 = c100
     2 field05 = c100
     2 field06 = c100
     2 field07 = c100
     2 field08 = c100
     2 field09 = c100
     2 field10 = c100
     2 field11 = c100
     2 field12 = c100
     2 field13 = c100
     2 field14 = c100
     2 field15 = c100
     2 field16 = c100
     2 field17 = c100
     2 field18 = c100
     2 field19 = c100
     2 field20 = c100
 )
 IF ( NOT (validate(reply->status_data.status,0)))
  RECORD reply(
    1 ops_event = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE ms_beg_dt_tm = vc WITH protect
 DECLARE ms_end_dt_tm = vc WITH protect
 DECLARE ms_beg_dt_tm1 = vc WITH protect
 DECLARE ms_end_dt_tm1 = vc WITH protect
 DECLARE ms_beg_dt_tm2 = vc WITH protect
 DECLARE ms_end_dt_tm2 = vc WITH protect
 DECLARE ms_beg_dt_tm3 = vc WITH protect
 DECLARE ms_end_dt_tm3 = vc WITH protect
 DECLARE ms_beg_dt_tm4 = vc WITH protect
 DECLARE ms_end_dt_tm4 = vc WITH protect
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ycnt = i4 WITH protect, noconstant(0)
 DECLARE ml_mcnt = i4 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_subject = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_address_list = vc WITH protect, noconstant(" ")
 DECLARE mf_rx_esent_perc = f8 WITH protect, noconstant(0.00)
 DECLARE mf_cs_esent_perc = f8 WITH protect, noconstant(0.00)
 EXECUTE bhs_ma_email_file
 SET ms_beg_dt_tm1 = format(datetimefind(cnvtlookbehind("1 D",datetimefind(cnvtdatetime(curdate,0),
     "M","B","B")),"M","B","B"),"DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_end_dt_tm1 = format(cnvtlookahead("7 D",cnvtdatetime(ms_beg_dt_tm1)),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_beg_dt_tm2 = format(cnvtlookahead("7 D",cnvtdatetime(ms_beg_dt_tm1)),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_end_dt_tm2 = format(cnvtlookahead("7 D",cnvtdatetime(ms_end_dt_tm1)),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_beg_dt_tm3 = format(cnvtlookahead("7 D",cnvtdatetime(ms_beg_dt_tm2)),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_end_dt_tm3 = format(cnvtlookahead("7 D",cnvtdatetime(ms_end_dt_tm2)),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_beg_dt_tm4 = format(cnvtlookahead("7 D",cnvtdatetime(ms_beg_dt_tm3)),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET ms_end_dt_tm4 = format(datetimefind(cnvtdatetime(curdate,0),"M","B","B"),
  "DD-MMM-YYYY HH:mm:ss;;D")
 SET mn_email_ind = 1
 SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_",format(cnvtlookbehind("1 D",
     cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
 SELECT INTO "nl:"
  FROM dm_info di
  PLAN (di
   WHERE di.info_domain="BHS_RPT_EPRESCRIBE_UTILIZATION"
    AND di.info_char="EMAIL")
  HEAD REPORT
   ms_address_list = " "
  DETAIL
   IF (ms_address_list=" ")
    ms_address_list = trim(di.info_name)
   ELSE
    ms_address_list = concat(ms_address_list," ",trim(di.info_name))
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build2("ms_beg_dt_tm1: ",ms_beg_dt_tm1))
 CALL echo(build2("ms_end_dt_tm1: ",ms_end_dt_tm1))
 CALL echo(build2("ms_beg_dt_tm2: ",ms_beg_dt_tm2))
 CALL echo(build2("ms_end_dt_tm2: ",ms_end_dt_tm2))
 CALL echo(build2("ms_beg_dt_tm3: ",ms_beg_dt_tm3))
 CALL echo(build2("ms_end_dt_tm3: ",ms_end_dt_tm3))
 CALL echo(build2("ms_beg_dt_tm4: ",ms_beg_dt_tm4))
 CALL echo(build2("ms_end_dt_tm4: ",ms_end_dt_tm4))
 FOR (ml_loop = 1 TO 4)
   CASE (ml_loop)
    OF 1:
     SET ms_beg_dt_tm = ms_beg_dt_tm1
     SET ms_end_dt_tm = ms_end_dt_tm1
    OF 2:
     SET ms_beg_dt_tm = ms_beg_dt_tm2
     SET ms_end_dt_tm = ms_end_dt_tm2
    OF 3:
     SET ms_beg_dt_tm = ms_beg_dt_tm3
     SET ms_end_dt_tm = ms_end_dt_tm3
    OF 4:
     SET ms_beg_dt_tm = ms_beg_dt_tm4
     SET ms_end_dt_tm = ms_end_dt_tm4
   ENDCASE
   CALL echo(build2("ms_beg_dt_tm: ",ms_beg_dt_tm))
   CALL echo(build2("ms_end_dt_tm: ",ms_end_dt_tm))
   SELECT INTO "nl:"
    FROM order_action oa,
     orders o,
     order_detail od,
     order_catalog oc,
     encounter e,
     encntr_alias ea,
     prsnl pr
    PLAN (oa
     WHERE oa.action_dt_tm >= cnvtdatetime(ms_beg_dt_tm)
      AND oa.action_dt_tm < cnvtdatetime(ms_end_dt_tm)
      AND oa.action_sequence=1)
     JOIN (o
     WHERE o.order_id=oa.order_id
      AND o.catalog_type_cd=value(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
      AND o.orig_ord_as_flag=1
      AND o.order_status_cd=value(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
      AND o.active_ind=1)
     JOIN (od
     WHERE od.order_id=o.order_id
      AND od.oe_field_meaning="REQROUTINGTYPE"
      AND od.action_sequence IN (
     (SELECT
      max(od0.action_sequence)
      FROM order_detail od0
      WHERE od0.order_id=od.order_id
       AND od0.oe_field_id=od.oe_field_id))
      AND od.oe_field_display_value >= " ")
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
     JOIN (e
     WHERE e.encntr_id=o.encntr_id
      AND e.active_ind=1
      AND e.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (ea
     WHERE ea.encntr_id=e.encntr_id
      AND ea.encntr_alias_type_cd=value(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (pr
     WHERE pr.person_id=oa.order_provider_id)
    ORDER BY o.order_id
    HEAD REPORT
     ml_cnt = 0
    HEAD o.order_id
     ml_cnt += 1, m_rec->l_cnt = ml_cnt, stat = alterlist(m_rec->list,ml_cnt),
     m_rec->list[ml_cnt].f_order_id = o.order_id, m_rec->list[ml_cnt].f_encntr_id = o.encntr_id,
     m_rec->list[ml_cnt].f_person_id = o.person_id,
     m_rec->list[ml_cnt].n_include = 0, m_rec->list[ml_cnt].c_ordered_as_mnemonic = trim(substring(1,
       100,o.ordered_as_mnemonic),3)
     IF ( NOT (oc.cki IN (null, "IGNORE")))
      m_rec->list[ml_cnt].c_cki = trim(oc.cki,3), m_rec->list[ml_cnt].c_drug_identifier = substring(9,
       (size(oc.cki) - 8),oc.cki)
     ENDIF
     m_rec->list[ml_cnt].c_order_details = trim(replace(replace(o.clinical_display_line,char(13)," "),
       char(10)," "),3), m_rec->list[ml_cnt].c_order_dt_tm = format(oa.order_dt_tm,
      "mm/dd/yyyy hh:mm;;d"), m_rec->list[ml_cnt].d_order_dt_tm = oa.order_dt_tm,
     m_rec->list[ml_cnt].c_routing_type = trim(substring(1,255,od.oe_field_display_value),3), m_rec->
     list[ml_cnt].c_order_status = uar_get_code_display(o.order_status_cd), m_rec->list[ml_cnt].
     c_location = trim(substring(1,100,build2(trim(uar_get_code_display(e.loc_facility_cd),3),"/",
        trim(uar_get_code_display(e.loc_nurse_unit_cd),3))),3),
     m_rec->list[ml_cnt].c_encntr_type = trim(uar_get_code_display(e.encntr_type_cd),3), m_rec->list[
     ml_cnt].c_fin = ea.alias, m_rec->list[ml_cnt].c_ordering_provider = trim(substring(1,100,pr
       .name_full_formatted),3),
     m_rec->list[ml_cnt].c_position = trim(uar_get_code_display(pr.position_cd),3)
    WITH filesort, nocounter
   ;end select
 ENDFOR
 IF (ml_cnt < 1)
  SELECT
   IF (mn_email_ind=1)
    WITH format = stream, pcformat('"',",",1), nocounter
   ELSE
   ENDIF
   INTO value(ms_output_dest)
   no_data = "No Eprescribe Utilization Found"
   FROM dummyt d
   WITH format, separator = " ", nocounter
  ;end select
  SET ms_subject = concat("Eprescribe Utilization Audit for - No Eprescribe Utilization Found ",
   format(cnvtlookbehind("1 D",cnvtdatetime(ms_end_dt_tm)),"mm/dd/yyyy;;D"))
  CALL emailfile(ms_output_dest,ms_filename_out,ms_address_list,ms_subject,1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = m_rec->l_cnt),
   mltm_ndc_main_drug_code mmdc
  PLAN (d)
   JOIN (mmdc
   WHERE (mmdc.drug_identifier=m_rec->list[d.seq].c_drug_identifier)
    AND mmdc.csa_schedule >= "0")
  ORDER BY d.seq
  HEAD d.seq
   m_rec->list[d.seq].c_csa_schedule = mmdc.csa_schedule, m_rec->list[d.seq].n_include = 1
  WITH nocounter
 ;end select
#summary_report
 IF (mn_email_ind=1)
  SET ms_subject = concat("Eprescribe Utilization Summary Audit for ",format(cnvtlookbehind("1 D",
     cnvtdatetime(ms_end_dt_tm)),"mm/dd/yyyy;;D"))
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),"_summary_",format(cnvtlookbehind("1 D",
      cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv"))
 ENDIF
 SELECT INTO "nl:"
  year = cnvtint(format(m_rec->list[d1.seq].d_order_dt_tm,"yyyy;;D")), month = cnvtint(format(m_rec->
    list[d1.seq].d_order_dt_tm,"MM;;D")), order_id = m_rec->list[d1.seq].f_order_id
  FROM (dummyt d1  WITH seq = m_rec->l_cnt)
  PLAN (d1
   WHERE (m_rec->list[d1.seq].n_include=1))
  ORDER BY year, month, order_id
  HEAD REPORT
   ml_ycnt = 0
  HEAD year
   ml_ycnt += 1, m_rec->l_ycnt = ml_ycnt, stat = alterlist(m_rec->ylist,ml_ycnt),
   m_rec->ylist[ml_ycnt].l_year = year, ml_mcnt = 0
  HEAD month
   ml_mcnt += 1, m_rec->ylist[ml_ycnt].l_mcnt = ml_mcnt, stat = alterlist(m_rec->ylist[ml_ycnt].mlist,
    ml_mcnt),
   m_rec->ylist[ml_ycnt].mlist[ml_mcnt].c_month = build(format(m_rec->list[d1.seq].d_order_dt_tm,
     "MMMMMMMMM;;D")), m_rec->ylist[ml_ycnt].mlist[ml_mcnt].l_tot_cs = 0, m_rec->ylist[ml_ycnt].
   mlist[ml_mcnt].l_tot_cs_esent = 0,
   m_rec->ylist[ml_ycnt].mlist[ml_mcnt].l_tot_rx = 0, m_rec->ylist[ml_ycnt].mlist[ml_mcnt].
   l_tot_rx_esent = 0
  HEAD order_id
   IF ((m_rec->list[d1.seq].c_csa_schedule != "0"))
    m_rec->ylist[ml_ycnt].mlist[ml_mcnt].l_tot_cs += 1, m_rec->l_gtot_cs += 1
    IF ((m_rec->list[d1.seq].c_routing_type="Route to Pharmacy Electronically"))
     m_rec->ylist[ml_ycnt].mlist[ml_mcnt].l_tot_cs_esent += 1, m_rec->l_gtot_cs_esent += 1
    ENDIF
   ENDIF
   m_rec->ylist[ml_ycnt].mlist[ml_mcnt].l_tot_rx += 1, m_rec->l_gtot_rx += 1
   IF ((m_rec->list[d1.seq].c_routing_type="Route to Pharmacy Electronically"))
    m_rec->ylist[ml_ycnt].mlist[ml_mcnt].l_tot_rx_esent += 1, m_rec->l_gtot_rx_esent += 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt dy  WITH seq = m_rec->l_ycnt),
   (dummyt dm  WITH seq = 1)
  PLAN (dy
   WHERE maxrec(dm,m_rec->ylist[dy.seq].l_mcnt))
   JOIN (dm)
  ORDER BY dy.seq, dm.seq
  HEAD REPORT
   l_cnt = 0, l_cnt += 1, m_rpt->l_cnt = l_cnt,
   stat = alterlist(m_rpt->list,l_cnt), m_rpt->list[l_cnt].field01 =
   "EPrescribe Utilization Summary Report", l_cnt += 1,
   m_rpt->l_cnt = l_cnt, stat = alterlist(m_rpt->list,l_cnt), m_rpt->list[l_cnt].field01 = " ",
   m_rpt->list[l_cnt].field02 = " ", m_rpt->list[l_cnt].field03 = "Controlled Substances", m_rpt->
   list[l_cnt].field04 = " ",
   m_rpt->list[l_cnt].field05 = "All Prescriptions", l_cnt += 1, m_rpt->l_cnt = l_cnt,
   stat = alterlist(m_rpt->list,l_cnt), m_rpt->list[l_cnt].field01 = "Year", m_rpt->list[l_cnt].
   field02 = "Month",
   m_rpt->list[l_cnt].field03 = "Total", m_rpt->list[l_cnt].field04 = "Total Esent", m_rpt->list[
   l_cnt].field05 = "% Esent",
   m_rpt->list[l_cnt].field06 = "Total", m_rpt->list[l_cnt].field07 = "Total Esent", m_rpt->list[
   l_cnt].field08 = "% Esent"
  HEAD dy.seq
   mc_year_temp = build(m_rec->ylist[dy.seq].l_year)
  HEAD dm.seq
   l_cnt += 1, m_rpt->l_cnt = l_cnt, stat = alterlist(m_rpt->list,l_cnt),
   m_rpt->list[l_cnt].field01 = mc_year_temp, mc_year_temp = " ", m_rpt->list[l_cnt].field02 = build(
    m_rec->ylist[dy.seq].mlist[dm.seq].c_month),
   m_rpt->list[l_cnt].field03 = build(m_rec->ylist[dy.seq].mlist[dm.seq].l_tot_cs), m_rpt->list[l_cnt
   ].field04 = build(m_rec->ylist[dy.seq].mlist[dm.seq].l_tot_cs_esent), mf_cs_esent_perc = ((
   cnvtreal(m_rec->ylist[dy.seq].mlist[dm.seq].l_tot_cs_esent)/ cnvtreal(m_rec->ylist[dy.seq].mlist[
    dm.seq].l_tot_cs)) * 100),
   m_rpt->list[l_cnt].field05 = concat(trim(cnvtstring(mf_cs_esent_perc,5,2),3),"%"), m_rpt->list[
   l_cnt].field06 = build(m_rec->ylist[dy.seq].mlist[dm.seq].l_tot_rx), m_rpt->list[l_cnt].field07 =
   build(m_rec->ylist[dy.seq].mlist[dm.seq].l_tot_rx_esent),
   mf_rx_esent_perc = ((cnvtreal(m_rec->ylist[dy.seq].mlist[dm.seq].l_tot_rx_esent)/ cnvtreal(m_rec->
    ylist[dy.seq].mlist[dm.seq].l_tot_rx)) * 100), m_rpt->list[l_cnt].field08 = concat(trim(
     cnvtstring(mf_rx_esent_perc,5,2),3),"%")
  FOOT  dm.seq
   null
  FOOT  dy.seq
   null
  FOOT REPORT
   l_cnt += 1, m_rpt->l_cnt = l_cnt, stat = alterlist(m_rpt->list,l_cnt),
   m_rpt->list[l_cnt].field01 = "Totals", m_rpt->list[l_cnt].field02 = " ", m_rpt->list[l_cnt].
   field03 = build(m_rec->l_gtot_cs),
   m_rpt->list[l_cnt].field04 = build(m_rec->l_gtot_cs_esent), mf_cs_esent_perc = ((cnvtreal(m_rec->
    l_gtot_cs_esent)/ cnvtreal(m_rec->l_gtot_cs)) * 100), m_rpt->list[l_cnt].field05 = concat(trim(
     cnvtstring(mf_cs_esent_perc,5,2),3),"%"),
   m_rpt->list[l_cnt].field06 = build(m_rec->l_gtot_rx), m_rpt->list[l_cnt].field07 = build(m_rec->
    l_gtot_rx_esent), mf_rx_esent_perc = ((cnvtreal(m_rec->l_gtot_rx_esent)/ cnvtreal(m_rec->
    l_gtot_rx)) * 100),
   m_rpt->list[l_cnt].field08 = concat(trim(cnvtstring(mf_rx_esent_perc,5,2),3),"%")
  WITH nocounter
 ;end select
 SELECT
  IF (mn_email_ind=1)
   WITH format = stream, pcformat('"',",",1), nocounter
  ELSE
  ENDIF
  INTO value(ms_output_dest)
  year = m_rpt->list[d1.seq].field01, month = m_rpt->list[d1.seq].field02, total_cs = m_rpt->list[d1
  .seq].field03,
  total_cs_esent = m_rpt->list[d1.seq].field04, percent_cs_esent = m_rpt->list[d1.seq].field05,
  total_rx = m_rpt->list[d1.seq].field06,
  total_rx_esent = m_rpt->list[d1.seq].field07, percent_rx_esent = m_rpt->list[d1.seq].field08
  FROM (dummyt d1  WITH seq = m_rpt->l_cnt)
  WITH format, separator = " ", nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_out = concat("eprescribe_utilization_audit_summary_",format(cnvtlookbehind("1 D",
     cnvtdatetime(ms_end_dt_tm)),"YYYYMMDD;;D"),".csv")
  CALL emailfile(ms_output_dest,ms_filename_out,ms_address_list,ms_subject,1)
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->ops_event = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].operationstatus = "S"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "Ops Job completed successfully"
 SET reply->status_data.subeventstatus[1].targetobjectname = ""
END GO
