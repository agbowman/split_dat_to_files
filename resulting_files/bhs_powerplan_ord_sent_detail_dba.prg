CREATE PROGRAM bhs_powerplan_ord_sent_detail:dba
 PROMPT
  "Output to File/Printer/MINE/E-Mail" = "MINE",
  "Mnemonic (wildcard * accepted):" = ""
  WITH outdev, s_mnemonic
 FREE RECORD m_powerplans
 RECORD m_powerplans(
   1 powerplans[*]
     2 s_powerplan_name = vc
     2 f_powerplan_catalog_id = f8
     2 s_status = vc
     2 s_phase_name = vc
     2 orders[*]
       3 s_order_mnumonic = vc
       3 f_order_synonym_id = f8
       3 ord_sent[*]
         4 f_ord_sent_id = f8
         4 s_ord_sent_disp = vc
     2 phase[*]
       3 s_phase_name = vc
       3 f_phase_id = f8
       3 l_phase_cnt = i4
       3 orders[*]
         4 s_order_mnumonic = vc
         4 f_order_synonym_id = f8
         4 l_order_cnt = i4
         4 ord_sent[*]
           5 f_ord_sent_id = f8
           5 s_ord_sent_disp = vc
 ) WITH protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = h
   1 file_offset = h
   1 file_dir = h
 )
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_phase_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_sent_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_pos = i4 WITH protect, noconstant(0)
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_pp_desc = vc WITH protect, noconstant(" ")
 SUBROUTINE (emailcheck(mn_email_ind=i2) =null WITH protect)
   IF (mn_email_ind=1)
    SET ms_filename_in = trim(concat(ms_output_dest,".dat"))
    SET ms_filename_out = concat("powerplan_order_sent_audit_",format(curdate,"YYYYMMDD;;D"),".csv")
    EXECUTE bhs_ma_email_file
    CALL emailfile(ms_filename_in,ms_filename_out, $1,concat(curprog,
      "- Baystate Medical Center Powerplan Order Sentence Detail"),0)
   ENDIF
 END ;Subroutine
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT INTO "nl:"
  powerplan =
  IF (pc.type_mean != "PHASE") pc.description
  ELSE pcp.description
  ENDIF
  , status =
  IF (pc.type_mean != "PHASE")
   IF (pc.beg_effective_dt_tm > cnvtdatetime(sysdate)) "Testing"
   ELSE "Production"
   ENDIF
  ELSE
   IF (pcp.beg_effective_dt_tm > cnvtdatetime(sysdate)) "Testing"
   ELSE "Production"
   ENDIF
  ENDIF
  , phase =
  IF (pc.type_mean="PHASE") pc.description
  ENDIF
  ,
  pathway_id =
  IF (pc.type_mean != "PHASE") pc.pathway_catalog_id
  ELSE pcp.pathway_catalog_id
  ENDIF
  , active_plan_ind =
  IF (pc.type_mean != "PHASE") pc.active_ind
  ELSE pcp.active_ind
  ENDIF
  FROM order_catalog_synonym ocs,
   pathway_comp pwc,
   pw_comp_os_reltn pcor,
   order_sentence os,
   pathway_catalog pc,
   pw_cat_reltn pcr,
   pathway_catalog pcp
  PLAN (ocs
   WHERE cnvtupper(ocs.mnemonic)=patstring(concat(value(cnvtupper( $S_MNEMONIC)),"*"))
    AND ocs.active_ind=1)
   JOIN (pwc
   WHERE pwc.parent_entity_id=ocs.synonym_id
    AND pwc.active_ind=1)
   JOIN (pc
   WHERE pc.pathway_catalog_id=pwc.pathway_catalog_id
    AND pc.active_ind=1)
   JOIN (pcor
   WHERE (pcor.pathway_comp_id= Outerjoin(pwc.pathway_comp_id)) )
   JOIN (os
   WHERE (os.order_sentence_id= Outerjoin(pcor.order_sentence_id)) )
   JOIN (pcr
   WHERE (pcr.pw_cat_t_id= Outerjoin(pc.pathway_catalog_id))
    AND (pcr.type_mean= Outerjoin("GROUP")) )
   JOIN (pcp
   WHERE (pcp.pathway_catalog_id= Outerjoin(pcr.pw_cat_s_id))
    AND (pcp.type_mean!= Outerjoin("PHASE")) )
  ORDER BY powerplan, pathway_id, pcr.pw_cat_t_id,
   ocs.mnemonic_key_cap, pwc.parent_entity_id, pcor.order_sentence_id
  HEAD REPORT
   ml_pp_cnt = 0
  HEAD powerplan
   null
  HEAD pathway_id
   IF (active_plan_ind=1)
    IF ( NOT (pcr.pw_cat_t_id > 0.00))
     ml_pp_cnt += 1, d0 = alterlist(m_powerplans->powerplans,ml_pp_cnt), m_powerplans->powerplans[
     ml_pp_cnt].s_powerplan_name = powerplan,
     m_powerplans->powerplans[ml_pp_cnt].s_status = status, m_powerplans->powerplans[ml_pp_cnt].
     s_phase_name = phase, m_powerplans->powerplans[ml_pp_cnt].f_powerplan_catalog_id = pathway_id,
     ml_ord_cnt = 0, ml_phase_cnt = 0
    ENDIF
   ENDIF
  HEAD pcr.pw_cat_t_id
   IF (active_plan_ind=1)
    IF (pcr.pw_cat_t_id > 0.00)
     ml_pp_cnt += 1, d0 = alterlist(m_powerplans->powerplans,ml_pp_cnt), m_powerplans->powerplans[
     ml_pp_cnt].s_powerplan_name = powerplan,
     m_powerplans->powerplans[ml_pp_cnt].s_status = status, m_powerplans->powerplans[ml_pp_cnt].
     s_phase_name = phase, m_powerplans->powerplans[ml_pp_cnt].f_powerplan_catalog_id = pathway_id,
     ml_ord_cnt = 0, ml_phase_cnt = 0
    ENDIF
   ENDIF
  HEAD ocs.mnemonic_key_cap
   null
  HEAD pwc.parent_entity_id
   IF (active_plan_ind=1)
    ml_ord_cnt += 1, d0 = alterlist(m_powerplans->powerplans[ml_pp_cnt].orders,ml_ord_cnt),
    m_powerplans->powerplans[ml_pp_cnt].orders[ml_ord_cnt].s_order_mnumonic = ocs.mnemonic,
    m_powerplans->powerplans[ml_pp_cnt].orders[ml_ord_cnt].f_order_synonym_id = ocs.synonym_id,
    ml_ord_sent_cnt = 0
   ENDIF
  HEAD pcor.order_sentence_id
   IF (active_plan_ind=1)
    ml_ord_sent_cnt += 1, d0 = alterlist(m_powerplans->powerplans[ml_pp_cnt].orders[ml_ord_cnt].
     ord_sent,ml_ord_sent_cnt), m_powerplans->powerplans[ml_pp_cnt].orders[ml_ord_cnt].ord_sent[
    ml_ord_sent_cnt].f_ord_sent_id = os.order_sentence_id,
    m_powerplans->powerplans[ml_pp_cnt].orders[ml_ord_cnt].ord_sent[ml_ord_sent_cnt].s_ord_sent_disp
     = os.order_sentence_display_line
   ENDIF
  WITH nocounter
 ;end select
 IF (ml_pp_cnt=0)
  GO TO exit_script
 ENDIF
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(ms_output_dest,3)
  SET frec->file_name = ms_filename_in
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"BHS Order Sent Detail"',char(13),char(10))
  SET stat = cclio("PUTS",frec)
  SET frec->file_buf = build('"Powerplan Name","Status","Phase Name","Order Name","Order Sentence"',
   char(13),char(10))
  SET stat = cclio("PUTS",frec)
  FOR (ml_loop = 1 TO size(m_powerplans->powerplans,5))
    SET ms_pp_desc = m_powerplans->powerplans[ml_loop].s_powerplan_name
    SET pp_id = m_powerplans->powerplans[ml_loop].f_powerplan_catalog_id
    FOR (ml_cnt = 1 TO size(m_powerplans->powerplans[ml_loop].orders,5))
      FOR (ml_ord_sent_cnt = 1 TO size(m_powerplans->powerplans[ml_loop].orders[ml_cnt].ord_sent,5))
       SET frec->file_buf = build('"',trim(m_powerplans->powerplans[ml_loop].s_powerplan_name,3),'",',
        '"',trim(m_powerplans->powerplans[ml_loop].s_status,3),
        '",','"',trim(m_powerplans->powerplans[ml_loop].s_phase_name,3),'",','"',
        trim(m_powerplans->powerplans[ml_loop].orders[ml_cnt].s_order_mnumonic,3),'",','"',trim(
         m_powerplans->powerplans[ml_loop].orders[ml_cnt].ord_sent[ml_ord_sent_cnt].s_ord_sent_disp,3
         ),'"',
        char(13),char(10))
       IF (ml_loop < size(m_powerplans->powerplans,5)
        AND ml_cnt=size(m_powerplans->powerplans[ml_loop].orders,5))
        SET stat = cclio("PUTS",frec)
       ENDIF
      ENDFOR
    ENDFOR
  ENDFOR
  SET stat = cclio("WRITE",frec)
  SET stat = cclio("CLOSE",frec)
  CALL emailcheck(mn_email_ind)
 ELSE
  SELECT INTO  $OUTDEV
   powerplan_name = trim(substring(1,1000,m_powerplans->powerplans[d1.seq].s_powerplan_name),3),
   status = trim(substring(1,1000,m_powerplans->powerplans[d1.seq].s_status),3), phase_name = trim(
    substring(1,1000,m_powerplans->powerplans[d1.seq].s_phase_name),3),
   order_name = trim(substring(1,1000,m_powerplans->powerplans[d1.seq].orders[d2.seq].
     s_order_mnumonic),3), order_sentence = trim(substring(1,1000,m_powerplans->powerplans[d1.seq].
     orders[d2.seq].ord_sent[d3.seq].s_ord_sent_disp),3)
   FROM (dummyt d1  WITH seq = size(m_powerplans->powerplans,5)),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(m_powerplans->powerplans[d1.seq].orders,5)))
    JOIN (d2
    WHERE maxrec(d3,size(m_powerplans->powerplans[d1.seq].orders[d2.seq].ord_sent,5)))
    JOIN (d3)
   WITH format, separator = " ", nocounter
  ;end select
 ENDIF
#exit_script
END GO
