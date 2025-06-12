CREATE PROGRAM al_bhs_rpt_powerplan_util:dba
 PROMPT
  "Output to File/Printer/MINE/E-Mail" = "MINE",
  "Beginning Date:" = curdate,
  "Ending Date:" = curdate,
  "Powerplan" = 0,
  "Physician" = 0,
  "Detail Level:" = 0
  WITH outdev, d_begdate, d_enddate,
  f_powerplan, f_physician, n_det_level
 FREE RECORD m_powerplans
 RECORD m_powerplans(
   1 powerplans[*]
     2 s_powerplan_name = vc
     2 f_powerplan_catalog_id = f8
     2 l_powerplan_cnt = i4
     2 s_phase_name = vc
     2 f_phase_id = f8
     2 orders[*]
       3 s_order_mnumonic = vc
       3 f_order_synonym_id = f8
       3 l_order_cnt = i4
     2 phase[*]
       3 s_phase_name = vc
       3 f_phase_id = f8
       3 l_phase_cnt = i4
       3 orders[*]
         4 s_order_mnumonic = vc
         4 f_order_synonym_id = f8
         4 l_order_cnt = i4
     2 status[*]
       3 s_description = vc
       3 l_status_cd = f8
       3 l_status_cnt = i4
 ) WITH protect
 FREE RECORD m_status_total
 RECORD m_status_total(
   1 status[*]
     2 s_description = vc
     2 l_status_cd = f8
     2 l_status_cnt = i4
 ) WITH protect
 DECLARE mf_beg_dt_qual = f8 WITH protect, constant(cnvtdatetime(cnvtdate( $D_BEGDATE),000000))
 DECLARE mf_end_dt_qual = f8 WITH protect, constant(cnvtdatetime(cnvtdate( $D_ENDDATE),235959))
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE mf_init_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",16769,"INITIATED"))
 DECLARE mc_pp_any_type = c1 WITH protect, noconstant(" ")
 DECLARE mc_phys_any_type = c1 WITH protect, noconstant(" ")
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE mn_col_size = i2 WITH protect, noconstant(0)
 DECLARE mn_detail_lvl = i2 WITH protect, noconstant( $N_DET_LEVEL)
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_stat_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_phase_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_pp_status_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_status_pos = i4 WITH protect, noconstant(0)
 DECLARE ml_ord_pos = i4 WITH protect, noconstant(0)
 DECLARE mf_phys_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_pp_id = f8 WITH protect, noconstant(0.00)
 DECLARE ms_begdate_disp1 = vc WITH protect, noconstant(" ")
 DECLARE ms_enddate_disp1 = vc WITH protect, noconstant(" ")
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_pat_name_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_fin_nbr_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_pp_name_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_phys_name_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_pp_status_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_ord_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_prsnl_pos_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_fac_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_pp_desc = vc WITH protect, noconstant(" ")
 DECLARE ms_pp_phase_disp = vc WITH protect, noconstant(" ")
 DECLARE ml_idx1 = i4 WITH protect, noconstant(0)
 SUBROUTINE (emailcheck(mn_email_ind=i2) =null WITH protect)
  IF (mn_email_ind=1)
   SET ms_filename_in = trim(concat(ms_output_dest,".dat"))
   SET ms_filename_out = concat(format(curdate,"MMDDYYYY;;D"),".csv")
   EXECUTE bhs_ma_email_file
   CALL emailfile(ms_filename_in,ms_filename_out, $1,concat(curprog,
     "- Baystate Medical Center Powerplan Utilization"),1)
  ENDIF
  GO TO exit_script
 END ;Subroutine
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 IF (mf_beg_dt_qual > mf_end_dt_qual)
  SELECT INTO  $OUTDEV
   FROM dummyt d
   DETAIL
    col 0,
    CALL print("Error: Please Select an End Date that is later than your Beginning Date")
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 IF (substring(1,1,reflect(parameter(4,0)))="C")
  SET mc_pp_any_type = "C"
 ELSE
  IF (( $F_POWERPLAN=0))
   SET mc_pp_any_type = "C"
  ELSE
   SET mc_pp_any_type = substring(1,1,reflect(parameter(4,0)))
  ENDIF
 ENDIF
 IF (substring(1,1,reflect(parameter(5,0)))="C")
  SET mc_phys_any_type = "C"
 ELSE
  IF (( $F_PHYSICIAN=0))
   SET mc_phys_any_type = "C"
  ELSE
   SET mc_phys_any_type = substring(1,1,reflect(parameter(5,0)))
  ENDIF
 ENDIF
 IF (mc_phys_any_type="F")
  SET mf_phys_id =  $F_PHYSICIAN
 ENDIF
 FREE RECORD m_pp
 RECORD m_pp(
   1 l_cnt = i4
   1 qual[*]
     2 f_pathway_catalog_id = f8
 )
 IF (mc_pp_any_type != "C")
  SELECT INTO "nl:"
   FROM pathway_catalog pc1,
    pathway_catalog pc2
   PLAN (pc1
    WHERE (pc1.pathway_catalog_id= $F_POWERPLAN))
    JOIN (pc2
    WHERE pc2.description_key=pc1.description_key)
   ORDER BY pc2.pathway_catalog_id
   HEAD REPORT
    m_pp->l_cnt = 0
   HEAD pc2.pathway_catalog_id
    m_pp->l_cnt += 1, stat = alterlist(m_pp->qual,m_pp->l_cnt), m_pp->qual[m_pp->l_cnt].
    f_pathway_catalog_id = pc2.pathway_catalog_id
   WITH nocounter
  ;end select
 ENDIF
 IF (mn_detail_lvl=1)
  SELECT
   IF (mc_pp_any_type="C"
    AND mc_phys_any_type="C")
    PLAN (pw)
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (pr
     WHERE pr.person_id=pa.action_prsnl_id)
     JOIN (pr1
     WHERE pr1.person_id=pa.provider_id)
     JOIN (p
     WHERE pw.person_id=p.person_id)
     JOIN (ea
     WHERE ea.encntr_id=pw.encntr_id
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=ea.encntr_id)
   ELSEIF (mc_pp_any_type != "C"
    AND mc_phys_any_type="C")
    PLAN (pw
     WHERE expand(ml_idx1,1,m_pp->l_cnt,pw.pathway_catalog_id,m_pp->qual[ml_idx1].
      f_pathway_catalog_id))
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (pr
     WHERE pr.person_id=pa.action_prsnl_id)
     JOIN (pr1
     WHERE pr1.person_id=pa.provider_id)
     JOIN (p
     WHERE pw.person_id=p.person_id)
     JOIN (ea
     WHERE ea.encntr_id=pw.encntr_id
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=ea.encntr_id)
   ELSEIF (mc_pp_any_type="C"
    AND mc_phys_any_type != "C")
    PLAN (pw)
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.action_prsnl_id=mf_phys_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (pr
     WHERE pr.person_id=pa.action_prsnl_id)
     JOIN (pr1
     WHERE pr1.person_id=pa.provider_id)
     JOIN (p
     WHERE pw.person_id=p.person_id)
     JOIN (ea
     WHERE ea.encntr_id=pw.encntr_id
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=ea.encntr_id)
   ELSEIF (mc_pp_any_type != "C"
    AND mc_phys_any_type != "C")
    PLAN (pw
     WHERE expand(ml_idx1,1,m_pp->l_cnt,pw.pathway_catalog_id,m_pp->qual[ml_idx1].
      f_pathway_catalog_id))
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.action_prsnl_id=mf_phys_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (pr
     WHERE pr.person_id=pa.action_prsnl_id)
     JOIN (pr1
     WHERE pr1.person_id=pa.provider_id)
     JOIN (p
     WHERE pw.person_id=p.person_id)
     JOIN (ea
     WHERE ea.encntr_id=pw.encntr_id
      AND ea.encntr_alias_type_cd=mf_fin_cd
      AND ea.active_ind=1
      AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (e
     WHERE e.encntr_id=ea.encntr_id)
   ELSE
   ENDIF
   INTO value(ms_output_dest)
   FROM pathway pw,
    pathway_action pa,
    person p,
    encntr_alias ea,
    prsnl pr,
    prsnl pr1,
    encounter e
   HEAD REPORT
    ml_cnt = 0, ms_outstring = ',"BHS Powerplan Utilization"', col 1,
    ms_outstring, row + 1
    IF (mc_pp_any_type="C")
     col 1, ',"All Powerplans"', row + 1
    ELSE
     FOR (ml_cnt = 1 TO size(m_powerplans->powerplans,5))
       IF (ml_cnt=1)
        ms_outstring = concat(',"Powerplan(s):","',m_powerplans->powerplans[ml_cnt].s_powerplan_name,
         '"')
       ELSE
        ms_outstring = concat(',"","',m_powerplans->powerplans[ml_cnt].s_powerplan_name,'"')
       ENDIF
       col 1, ms_outstring, row + 1
     ENDFOR
    ENDIF
    col 1, ',"Powerplan Level Detail"', row + 1,
    ms_begdate_disp1 = format(mf_beg_dt_qual,"mm/dd/yyyy;;d"), ms_enddate_disp1 = format(
     mf_end_dt_qual,"mm/dd/yyyy;;d"), ms_outstring = concat(',"Beginning Date: ",',ms_begdate_disp1),
    col 1, ms_outstring, row + 1,
    ms_outstring = concat(',"Ending Date: ",',ms_enddate_disp1), col 1, ms_outstring,
    row + 1, ms_outstring = build(
     ',"Patient Name","Account Number","Powerplan Name","Phase Name","Entered By",',
     '"Provider Name","Order Date","Facility","Status",'), col 1,
    ms_outstring, row + 1
   HEAD pa.pathway_action_id
    ms_pat_name_disp = substring(1,30,p.name_full_formatted), ms_fin_nbr_disp = substring(1,15,
     cnvtalias(ea.alias,ea.alias_pool_cd)), ms_pp_name_disp = substring(1,50,pw.pw_group_desc)
    IF (pw.description != pw.pw_group_desc)
     ms_pp_phase_disp = substring(1,50,pw.description)
    ELSE
     ms_pp_phase_disp = ""
    ENDIF
    ms_phys_name_disp = substring(1,30,pr.name_full_formatted), ms_provider_name_disp = substring(1,
     30,pr1.name_full_formatted), ms_ord_date_disp = format(pa.updt_dt_tm,"MM/DD/YYYY;;D"),
    ms_fac_disp = substring(1,15,uar_get_code_display(e.loc_facility_cd)), ms_pp_status_disp =
    substring(1,15,uar_get_code_display(pa.pw_status_cd)), ms_outstring = build(',"',ms_pat_name_disp,
     '","',ms_fin_nbr_disp,'","',
     ms_pp_name_disp,'","',ms_pp_phase_disp,'","',ms_phys_name_disp,
     '","',ms_provider_name_disp,'",',ms_ord_date_disp,',"',
     ms_fac_disp,'","',ms_pp_status_disp,'",'),
    col 1, ms_outstring, row + 1
   WITH maxcol = 250, maxrow = 1, nullreport
  ;end select
  CALL emailcheck(mn_email_ind)
 ENDIF
 IF (mn_detail_lvl=2)
  IF (mc_pp_any_type != "C")
   SELECT INTO "nl:"
    FROM pathway_catalog pcg,
     pw_cat_reltn pcr,
     pathway_catalog pcg1,
     pathway_comp pwc,
     order_catalog_synonym ocs
    PLAN (pcg
     WHERE expand(ml_idx1,1,m_pp->l_cnt,pcg.pathway_catalog_id,m_pp->qual[ml_idx1].
      f_pathway_catalog_id))
     JOIN (pcr
     WHERE (pcr.pw_cat_s_id= Outerjoin(pcg.pathway_catalog_id)) )
     JOIN (pcg1
     WHERE (pcg1.pathway_catalog_id= Outerjoin(pcr.pw_cat_t_id))
      AND (pcg1.active_ind= Outerjoin(1)) )
     JOIN (pwc
     WHERE (pwc.pathway_catalog_id= Outerjoin(pcg1.pathway_catalog_id))
      AND (pwc.parent_entity_name= Outerjoin("ORDER_CATALOG_SYNONYM"))
      AND (pwc.active_ind= Outerjoin(1)) )
     JOIN (ocs
     WHERE (ocs.synonym_id= Outerjoin(pwc.parent_entity_id))
      AND (ocs.active_ind= Outerjoin(1)) )
    ORDER BY pcg.pathway_catalog_id, pcg1.pathway_catalog_id, ocs.synonym_id
    HEAD REPORT
     ml_pp_cnt = 0
    HEAD pcg.pathway_catalog_id
     ml_pp_cnt += 1,
     CALL alterlist(m_powerplans->powerplans,ml_pp_cnt), m_powerplans->powerplans[ml_pp_cnt].
     s_powerplan_name = pcg.description_key,
     m_powerplans->powerplans[ml_pp_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id,
     ml_phase_cnt = 0
    HEAD pcg1.pathway_catalog_id
     IF (pcg1.pathway_catalog_id > 0)
      ml_phase_cnt += 1,
      CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase,ml_phase_cnt), m_powerplans->
      powerplans[ml_pp_cnt].phase[ml_phase_cnt].f_phase_id = pcg1.pathway_catalog_id,
      ml_ord_cnt = 0
     ENDIF
    HEAD pwc.parent_entity_id
     IF (pcg1.pathway_catalog_id > 0)
      ml_ord_cnt += 1,
      CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders,ml_ord_cnt),
      m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders[ml_ord_cnt].s_order_mnumonic =
      ocs.mnemonic,
      m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders[ml_ord_cnt].f_order_synonym_id
       = ocs.synonym_id, ml_ord_sent_cnt = 0
     ENDIF
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM pathway_catalog pcg,
     pathway_comp pwc,
     order_catalog_synonym ocs
    PLAN (pcg
     WHERE expand(ml_idx1,1,m_pp->l_cnt,pcg.pathway_catalog_id,m_pp->qual[ml_idx1].
      f_pathway_catalog_id))
     JOIN (pwc
     WHERE (pwc.pathway_catalog_id= Outerjoin(pcg.pathway_catalog_id))
      AND (pwc.parent_entity_name= Outerjoin("ORDER_CATALOG_SYNONYM"))
      AND (pwc.active_ind= Outerjoin(1)) )
     JOIN (ocs
     WHERE (ocs.synonym_id= Outerjoin(pwc.parent_entity_id))
      AND (ocs.active_ind= Outerjoin(1)) )
    ORDER BY pcg.pathway_catalog_id, ocs.synonym_id
    HEAD pwc.pathway_catalog_id
     ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pwc.pathway_catalog_id,
      m_powerplans->powerplans[ml_cnt].f_powerplan_catalog_id)
     IF (ml_pp_pos=0)
      ml_pp_cnt += 1,
      CALL alterlist(m_powerplans->powerplans,ml_pp_cnt), m_powerplans->powerplans[ml_pp_cnt].
      s_powerplan_name = pcg.description_key,
      m_powerplans->powerplans[ml_pp_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, ml_pp_pos
       = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pwc.pathway_catalog_id,m_powerplans->
       powerplans[ml_cnt].f_powerplan_catalog_id)
     ENDIF
     ml_ord_cnt = 0
    HEAD pwc.parent_entity_id
     ml_ord_cnt += 1,
     CALL alterlist(m_powerplans->powerplans[ml_pp_pos].orders,ml_ord_cnt), m_powerplans->powerplans[
     ml_pp_pos].orders[ml_ord_cnt].s_order_mnumonic = ocs.mnemonic,
     m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_cnt].f_order_synonym_id = ocs.synonym_id,
     ml_ord_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].orders,5),ocs
      .synonym_id,m_powerplans->powerplans[ml_pp_pos].orders[ml_cnt].f_order_synonym_id)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM pathway_catalog pcg,
     pw_cat_reltn pcr,
     pathway_catalog pcg1,
     pathway_comp pwc,
     order_catalog_synonym ocs
    PLAN (pcg
     WHERE pcg.type_mean IN ("PATHWAY", "CAREPLAN"))
     JOIN (pcr
     WHERE (pcr.pw_cat_s_id= Outerjoin(pcg.pathway_catalog_id)) )
     JOIN (pcg1
     WHERE (pcg1.pathway_catalog_id= Outerjoin(pcr.pw_cat_t_id))
      AND (pcg1.active_ind= Outerjoin(1)) )
     JOIN (pwc
     WHERE (pwc.pathway_catalog_id= Outerjoin(pcg1.pathway_catalog_id))
      AND (pwc.parent_entity_name= Outerjoin("ORDER_CATALOG_SYNONYM"))
      AND (pwc.active_ind= Outerjoin(1)) )
     JOIN (ocs
     WHERE (ocs.synonym_id= Outerjoin(pwc.parent_entity_id))
      AND (ocs.active_ind= Outerjoin(1)) )
    ORDER BY pcg.pathway_catalog_id, pcg1.pathway_catalog_id, ocs.synonym_id
    HEAD REPORT
     ml_pp_cnt = 0
    HEAD pcg.pathway_catalog_id
     ml_pp_cnt += 1
     IF (((mod(ml_pp_cnt,50)=1) OR (ml_pp_cnt=1)) )
      CALL alterlist(m_powerplans->powerplans,(ml_pp_cnt+ 49))
     ENDIF
     m_powerplans->powerplans[ml_pp_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
     powerplans[ml_pp_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, ml_phase_cnt = 0
    HEAD pcg1.pathway_catalog_id
     IF (pcg1.pathway_catalog_id > 0)
      ml_phase_cnt += 1
      IF (((mod(ml_phase_cnt,20)=1) OR (ml_phase_cnt=1)) )
       CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase,(ml_phase_cnt+ 19))
      ENDIF
      m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].s_phase_name = pcg1.description_key,
      m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].f_phase_id = pcg1.pathway_catalog_id,
      ml_ord_cnt = 0
     ENDIF
    HEAD pwc.parent_entity_id
     IF (pcg1.pathway_catalog_id > 0)
      ml_ord_cnt += 1
      IF (((mod(ml_ord_cnt,20)=1) OR (ml_ord_cnt=1)) )
       CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders,(ml_ord_cnt+ 19)
       )
      ENDIF
      m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders[ml_ord_cnt].s_order_mnumonic =
      ocs.mnemonic, m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders[ml_ord_cnt].
      f_order_synonym_id = ocs.synonym_id, ml_ord_sent_cnt = 0
     ENDIF
    FOOT  pcg.pathway_catalog_id
     CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase,ml_phase_cnt)
    FOOT  pcg1.pathway_catalog_id
     CALL alterlist(m_powerplans->powerplans[ml_pp_cnt].phase[ml_phase_cnt].orders,ml_ord_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM pathway_catalog pcg,
     pathway_comp pwc,
     order_catalog_synonym ocs
    PLAN (pcg
     WHERE pcg.type_mean IN ("PATHWAY", "CAREPLAN"))
     JOIN (pwc
     WHERE pwc.pathway_catalog_id=pcg.pathway_catalog_id
      AND pwc.parent_entity_name="ORDER_CATALOG_SYNONYM"
      AND pwc.active_ind=1)
     JOIN (ocs
     WHERE ocs.synonym_id=pwc.parent_entity_id
      AND ocs.active_ind=1)
    ORDER BY pcg.pathway_catalog_id, ocs.synonym_id
    HEAD pwc.pathway_catalog_id
     ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pwc.pathway_catalog_id,
      m_powerplans->powerplans[ml_cnt].f_powerplan_catalog_id)
     IF (ml_pp_pos=0)
      ml_pp_cnt += 1
      IF (((mod(ml_pp_cnt,50)=1) OR (ml_pp_cnt=1)) )
       CALL alterlist(m_powerplans->powerplans,(ml_pp_cnt+ 49))
      ENDIF
      m_powerplans->powerplans[ml_pp_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
      powerplans[ml_pp_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, ml_pp_pos = locateval(
       ml_cnt,1,size(m_powerplans->powerplans,5),pwc.pathway_catalog_id,m_powerplans->powerplans[
       ml_cnt].f_powerplan_catalog_id)
     ENDIF
     ml_ord_cnt = 0
    HEAD pwc.parent_entity_id
     ml_ord_cnt += 1
     IF (((mod(ml_ord_cnt,20)=1) OR (ml_ord_cnt=1)) )
      CALL alterlist(m_powerplans->powerplans[ml_pp_pos].orders,(ml_ord_cnt+ 19))
     ENDIF
     m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_cnt].s_order_mnumonic = ocs.mnemonic,
     m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_cnt].f_order_synonym_id = ocs.synonym_id,
     ml_ord_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].orders,5),ocs
      .synonym_id,m_powerplans->powerplans[ml_pp_pos].orders[ml_cnt].f_order_synonym_id)
    FOOT  pwc.pathway_catalog_id
     CALL alterlist(m_powerplans->powerplans[ml_pp_pos].orders,ml_ord_cnt)
    FOOT REPORT
     CALL alterlist(m_powerplans->powerplans,ml_pp_cnt)
    WITH nocounter
   ;end select
  ENDIF
  SELECT
   IF (mc_phys_any_type="C"
    AND mc_pp_any_type="C")
    PLAN (p)
     JOIN (pa
     WHERE pa.pathway_id=p.pathway_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (apc
     WHERE apc.pathway_id=pa.pathway_id
      AND apc.parent_entity_name="ORDERS")
     JOIN (o
     WHERE apc.parent_entity_id=o.order_id
      AND o.encntr_id=p.encntr_id)
   ELSEIF (mc_phys_any_type != "C"
    AND mc_pp_any_type="C")
    PLAN (p)
     JOIN (pa
     WHERE pa.pathway_id=p.pathway_id
      AND pa.action_prsnl_id=mf_phys_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (apc
     WHERE apc.pathway_id=pa.pathway_id
      AND apc.parent_entity_name="ORDERS")
     JOIN (o
     WHERE apc.parent_entity_id=o.order_id
      AND o.encntr_id=p.encntr_id)
   ELSEIF (mc_phys_any_type="C"
    AND mc_pp_any_type != "C")
    PLAN (p
     WHERE expand(ml_cnt,1,size(m_powerplans->powerplans,5),p.pw_cat_group_id,m_powerplans->
      powerplans[ml_cnt].f_powerplan_catalog_id))
     JOIN (pa
     WHERE pa.pathway_id=p.pathway_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (apc
     WHERE apc.pathway_id=pa.pathway_id
      AND apc.parent_entity_name="ORDERS")
     JOIN (o
     WHERE apc.parent_entity_id=o.order_id
      AND o.encntr_id=p.encntr_id)
   ELSEIF (mc_phys_any_type != "C"
    AND mc_pp_any_type != "C")
    PLAN (p
     WHERE expand(ml_cnt,1,size(m_powerplans->powerplans,5),p.pw_cat_group_id,m_powerplans->
      powerplans[ml_cnt].f_powerplan_catalog_id))
     JOIN (pa
     WHERE pa.pathway_id=p.pathway_id
      AND pa.action_prsnl_id=mf_phys_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
     JOIN (apc
     WHERE apc.pathway_id=pa.pathway_id
      AND apc.parent_entity_name="ORDERS")
     JOIN (o
     WHERE apc.parent_entity_id=o.order_id
      AND o.encntr_id=p.encntr_id)
   ELSE
   ENDIF
   INTO "nl:"
   FROM orders o,
    act_pw_comp apc,
    pathway p,
    pathway_action pa
   HEAD o.order_id
    IF (p.pw_cat_group_id=p.pathway_catalog_id)
     ml_pp_pos = locateval(ml_pp_cnt,1,size(m_powerplans->powerplans,5),p.pathway_catalog_id,
      m_powerplans->powerplans[ml_pp_cnt].f_powerplan_catalog_id), ml_ord_pos = locateval(ml_ord_cnt,
      1,size(m_powerplans->powerplans[ml_pp_pos].orders,5),o.synonym_id,m_powerplans->powerplans[
      ml_pp_pos].orders[ml_ord_cnt].f_order_synonym_id)
     IF (ml_ord_pos > 0)
      m_powerplans->powerplans[ml_pp_pos].orders[ml_ord_pos].l_order_cnt += 1
     ENDIF
    ELSE
     ml_pp_pos = locateval(ml_pp_cnt,1,size(m_powerplans->powerplans,5),p.pw_cat_group_id,
      m_powerplans->powerplans[ml_pp_cnt].f_powerplan_catalog_id), ml_phase_pos = locateval(
      ml_phase_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].phase,5),p.pathway_catalog_id,
      m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_cnt].f_phase_id), ml_ord_pos = locateval(
      ml_ord_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders,5),o
      .synonym_id,m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[ml_ord_cnt].
      f_order_synonym_id)
     IF (ml_phase_pos > 0
      AND ml_ord_pos > 0)
      m_powerplans->powerplans[ml_pp_pos].phase[ml_phase_pos].orders[ml_ord_pos].l_order_cnt += 1
     ENDIF
    ENDIF
   WITH counter
  ;end select
  SELECT INTO value(ms_output_dest)
   ms_pp_desc = m_powerplans->powerplans[d1.seq].s_powerplan_name, mf_pp_id = m_powerplans->
   powerplans[d1.seq].f_powerplan_catalog_id
   FROM (dummyt d1  WITH seq = size(m_powerplans->powerplans,5))
   ORDER BY ms_pp_desc
   HEAD REPORT
    ms_outstring = ',"BHS Powerplan Utilization"', col 1, ms_outstring,
    row + 1
    IF (mc_pp_any_type="C")
     col 1, ',"All Powerplans"', row + 1
    ELSE
     FOR (ml_cnt = 1 TO size(m_powerplans->powerplans,5))
       IF (ml_cnt=1)
        ms_outstring = build2('"Powerplan(s):","',m_powerplans->powerplans[ml_cnt].s_powerplan_name,
         '"'), col 1, ms_outstring,
        row + 1
       ELSE
        ms_outstring = build2('"',m_powerplans->powerplans[ml_cnt].s_powerplan_name,'"'), col 1,
        ms_outstring,
        row + 1
       ENDIF
     ENDFOR
    ENDIF
    col 1, ',"Order Level Detail"', row + 1,
    ms_begdate_disp1 = format(mf_beg_dt_qual,"mm/dd/yyyy;;d"), ms_enddate_disp1 = format(
     mf_end_dt_qual,"mm/dd/yyyy;;d"), ms_outstring = concat(',"Beginning Date: ",',ms_begdate_disp1),
    col 1, ms_outstring, row + 1,
    ms_outstring = concat(',"Ending Date: ",',ms_enddate_disp1), col 1, ms_outstring,
    row + 1, ms_outstring = build(',"Powerplan Name","Phase Name","Order Name","Order Count",'), col
    1,
    ms_outstring, row + 1,
    CALL echorecord(m_powerplans)
   HEAD mf_pp_id
    FOR (ml_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].orders,5))
      ms_outstring = build(',"',m_powerplans->powerplans[d1.seq].s_powerplan_name,'",','"",',",",
       '"',m_powerplans->powerplans[d1.seq].orders[ml_cnt].s_order_mnumonic,'",',m_powerplans->
       powerplans[d1.seq].orders[ml_cnt].l_order_cnt), col 1, ms_outstring,
      row + 1
    ENDFOR
    IF (size(m_powerplans->powerplans[d1.seq].phase,5) > 0)
     FOR (ml_phase_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].phase,5))
       FOR (ml_ord_cnt = 1 TO size(m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].orders,5))
         ms_outstring = build(',"',m_powerplans->powerplans[d1.seq].s_powerplan_name,'",','"',
          m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].s_phase_name,
          '",','"',m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].orders[ml_ord_cnt].
          s_order_mnumonic,'",',m_powerplans->powerplans[d1.seq].phase[ml_phase_cnt].orders[
          ml_ord_cnt].l_order_cnt), col 1, ms_outstring,
         row + 1
       ENDFOR
     ENDFOR
    ENDIF
   WITH nocounter, maxrow = 1, format = variable,
    maxcol = 200
  ;end select
  CALL emailcheck(mn_email_ind)
 ENDIF
 IF (mn_detail_lvl=3)
  IF (mc_pp_any_type != "C")
   SELECT INTO "nl:"
    FROM pathway_catalog pcg,
     pathway_catalog pcg1,
     pw_cat_reltn pcr,
     dummyt d
    PLAN (pcg
     WHERE expand(ml_idx1,1,m_pp->l_cnt,pcg.pathway_catalog_id,m_pp->qual[ml_idx1].
      f_pathway_catalog_id))
     JOIN (d)
     JOIN (pcr
     WHERE pcr.pw_cat_s_id=pcg.pathway_catalog_id)
     JOIN (pcg1
     WHERE pcg1.pathway_catalog_id=pcr.pw_cat_t_id
      AND pcg1.active_ind=1)
    ORDER BY pcg.pathway_catalog_id
    HEAD REPORT
     ml_cnt = 0
    HEAD pcg.pathway_catalog_id
     ml_cnt += 1
     IF (((mod(ml_cnt,25)=1) OR (ml_cnt=1)) )
      CALL alterlist(m_powerplans->powerplans,(ml_cnt+ 24))
     ENDIF
     m_powerplans->powerplans[ml_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
     powerplans[ml_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, m_powerplans->powerplans[
     ml_cnt].s_phase_name = "",
     m_powerplans->powerplans[ml_cnt].f_phase_id = 0
    DETAIL
     IF (pcg1.pathway_catalog_id > 0)
      ml_cnt += 1
      IF (((mod(ml_cnt,25)=1) OR (ml_cnt=1)) )
       CALL alterlist(m_powerplans->powerplans,(ml_cnt+ 24))
      ENDIF
      m_powerplans->powerplans[ml_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
      powerplans[ml_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, m_powerplans->powerplans[
      ml_cnt].s_phase_name = pcg1.description_key,
      m_powerplans->powerplans[ml_cnt].f_phase_id = pcg1.pathway_catalog_id
     ENDIF
    FOOT REPORT
     CALL alterlist(m_powerplans->powerplans,ml_cnt)
    WITH nocounter, outerjoin = d
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM pathway_catalog pcg,
     pathway_catalog pcg1,
     pw_cat_reltn pcr,
     dummyt d
    PLAN (pcg
     WHERE pcg.type_mean IN ("PATHWAY", "CAREPLAN"))
     JOIN (d)
     JOIN (pcr
     WHERE pcr.pw_cat_s_id=pcg.pathway_catalog_id)
     JOIN (pcg1
     WHERE pcg1.pathway_catalog_id=pcr.pw_cat_t_id
      AND pcg1.active_ind=1)
    ORDER BY pcg.pathway_catalog_id
    HEAD REPORT
     ml_cnt = 0
    HEAD pcg.pathway_catalog_id
     ml_cnt += 1
     IF (((mod(ml_cnt,25)=1) OR (ml_cnt=1)) )
      CALL alterlist(m_powerplans->powerplans,(ml_cnt+ 24))
     ENDIF
     m_powerplans->powerplans[ml_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
     powerplans[ml_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, m_powerplans->powerplans[
     ml_cnt].s_phase_name = "",
     m_powerplans->powerplans[ml_cnt].f_phase_id = 0
    DETAIL
     IF (pcg1.pathway_catalog_id > 0)
      ml_cnt += 1
      IF (((mod(ml_cnt,25)=1) OR (ml_cnt=1)) )
       CALL alterlist(m_powerplans->powerplans,(ml_cnt+ 24))
      ENDIF
      m_powerplans->powerplans[ml_cnt].s_powerplan_name = pcg.description_key, m_powerplans->
      powerplans[ml_cnt].f_powerplan_catalog_id = pcg.pathway_catalog_id, m_powerplans->powerplans[
      ml_cnt].s_phase_name = pcg1.description_key,
      m_powerplans->powerplans[ml_cnt].f_phase_id = pcg1.pathway_catalog_id
     ENDIF
    FOOT REPORT
     CALL alterlist(m_powerplans->powerplans,ml_cnt)
    WITH nocounter, outerjoin = d
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE cv.code_set=16769
   HEAD cv.cdf_meaning
    ml_stat_cnt += 1
    IF (((mod(ml_stat_cnt,10)=1) OR (ml_stat_cnt=1)) )
     CALL alterlist(m_status_total->status,(ml_stat_cnt+ 9))
    ENDIF
    m_status_total->status[ml_stat_cnt].s_description = cv.cdf_meaning, m_status_total->status[
    ml_stat_cnt].l_status_cd = cv.code_value
   FOOT REPORT
    CALL alterlist(m_status_total->status,ml_stat_cnt)
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   mf_pp_id = m_powerplans->powerplans[d.seq].f_powerplan_catalog_id, phase_id = m_powerplans->
   powerplans[d.seq].f_phase_id
   FROM code_value cv,
    (dummyt d  WITH seq = size(m_powerplans->powerplans,5))
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=16769)
   HEAD mf_pp_id
    ml_cnt = 0
   HEAD phase_id
    ml_cnt = 0
   DETAIL
    ml_cnt += 1
    IF (((mod(ml_cnt,10)=1) OR (ml_cnt=1)) )
     CALL alterlist(m_powerplans->powerplans[d.seq].status,(ml_cnt+ 9))
    ENDIF
    m_powerplans->powerplans[d.seq].status[ml_cnt].s_description = cv.cdf_meaning, m_powerplans->
    powerplans[d.seq].status[ml_cnt].l_status_cd = cv.code_value
   FOOT  mf_pp_id
    CALL alterlist(m_powerplans->powerplans[d.seq].status,ml_cnt)
   FOOT  phase_id
    CALL alterlist(m_powerplans->powerplans[d.seq].status,ml_cnt)
   WITH nocounter
  ;end select
  SELECT
   IF (mc_phys_any_type="C"
    AND mc_pp_any_type="C")
    PLAN (pw)
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
   ELSEIF (mc_phys_any_type != "C"
    AND mc_pp_any_type="C")
    PLAN (pw)
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.action_prsnl_id=mf_phys_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
   ELSEIF (mc_phys_any_type="C"
    AND mc_pp_any_type != "C")
    PLAN (pw
     WHERE expand(ml_cnt,1,size(m_powerplans->powerplans,5),pw.pathway_catalog_id,m_powerplans->
      powerplans[ml_cnt].f_powerplan_catalog_id))
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
   ELSEIF (mc_phys_any_type != "C"
    AND mc_pp_any_type != "C")
    PLAN (pw
     WHERE expand(ml_cnt,1,size(m_powerplans->powerplans,5),pw.pathway_catalog_id,m_powerplans->
      powerplans[ml_cnt].f_powerplan_catalog_id))
     JOIN (pa
     WHERE pa.pathway_id=pw.pathway_id
      AND pa.action_prsnl_id=mf_phys_id
      AND pa.pw_status_cd != 0
      AND pa.action_dt_tm BETWEEN cnvtdatetime(mf_beg_dt_qual) AND cnvtdatetime(mf_end_dt_qual))
   ELSE
   ENDIF
   INTO "nl:"
   FROM pathway_action pa,
    pathway pw
   ORDER BY pw.pathway_id
   HEAD pa.pathway_action_id
    IF (pw.pw_cat_group_id=pw.pathway_catalog_id)
     ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pw.pw_cat_group_id,m_powerplans
      ->powerplans[ml_cnt].f_powerplan_catalog_id)
    ELSE
     ml_pp_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans,5),pw.pathway_catalog_id,
      m_powerplans->powerplans[ml_cnt].f_phase_id)
    ENDIF
    ml_pp_status_pos = locateval(ml_cnt,1,size(m_powerplans->powerplans[ml_pp_pos].status,5),pa
     .pw_status_cd,m_powerplans->powerplans[ml_pp_pos].status[ml_cnt].l_status_cd), ml_status_pos =
    locateval(ml_cnt,1,size(m_status_total->status,5),pa.pw_status_cd,m_status_total->status[ml_cnt].
     l_status_cd), m_status_total->status[ml_status_pos].l_status_cnt += 1,
    m_powerplans->powerplans[ml_pp_pos].status[ml_pp_status_pos].l_status_cnt += 1
   WITH counter
  ;end select
  SELECT INTO value(ms_output_dest)
   ms_pp_desc = m_powerplans->powerplans[d.seq].s_powerplan_name
   FROM (dummyt d  WITH seq = size(m_powerplans->powerplans,5))
   ORDER BY ms_pp_desc
   HEAD REPORT
    ms_outstring = '"BHS Powerplan Utilization"', col 1, ms_outstring,
    row + 1
    IF (mc_pp_any_type="C")
     col 1, '"All Powerplans"', row + 1
    ELSE
     FOR (ml_cnt = 1 TO size(m_powerplans->powerplans,5))
       IF (ml_cnt=1)
        IF ((m_powerplans->powerplans[ml_cnt].f_phase_id=0))
         ms_outstring = build2('"Powerplan(s):","',m_powerplans->powerplans[ml_cnt].s_powerplan_name,
          '"'), col 1, ms_outstring,
         row + 1
        ENDIF
       ELSE
        IF ((m_powerplans->powerplans[ml_cnt].f_phase_id=0))
         ms_outstring = build2('"',m_powerplans->powerplans[ml_cnt].s_powerplan_name,'"'), col 1,
         ms_outstring,
         row + 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    col 1, '"Executive Level Detail"', row + 1,
    ms_begdate_disp1 = format(mf_beg_dt_qual,"mm/dd/yyyy;;d"), ms_enddate_disp1 = format(
     mf_end_dt_qual,"mm/dd/yyyy;;d"), ms_outstring = concat('"Beginning Date: ",',ms_begdate_disp1),
    col 1, ms_outstring, row + 1,
    ms_outstring = concat('"Ending Date: ",',ms_enddate_disp1), col 1, ms_outstring,
    row + 1
    FOR (ml_cnt = 1 TO size(m_powerplans->powerplans[d.seq].status,5))
      IF (ml_cnt=1)
       IF ((m_status_total->status[ml_cnt].l_status_cnt > 0))
        ms_outstring = build('"Powerplan Name",','"Phase",','"',m_powerplans->powerplans[d.seq].
         status[ml_cnt].s_description,'",')
       ELSE
        ms_outstring = build('"Powerplan Name","Phase",')
       ENDIF
       col 1, ms_outstring, mn_col_size = size(ms_outstring,1)
      ELSE
       IF ((m_status_total->status[ml_cnt].l_status_cnt > 0))
        ms_outstring = build('"',m_powerplans->powerplans[d.seq].status[ml_cnt].s_description,'"',","
         ), call reportmove('COL',(mn_col_size+ 1),0), ms_outstring,
        mn_col_size = (size(ms_outstring,1)+ mn_col_size)
       ENDIF
      ENDIF
    ENDFOR
    row + 1
   DETAIL
    FOR (ml_cnt = 1 TO size(m_powerplans->powerplans[d.seq].status,5))
      IF (ml_cnt=1)
       IF ((m_status_total->status[ml_cnt].l_status_cnt > 0))
        ms_outstring = build('"',m_powerplans->powerplans[d.seq].s_powerplan_name,'",','"',
         m_powerplans->powerplans[d.seq].s_phase_name,
         '",',m_powerplans->powerplans[d.seq].status[ml_cnt].l_status_cnt,",")
       ELSE
        ms_outstring = build('"',m_powerplans->powerplans[d.seq].s_powerplan_name,'",','"',
         m_powerplans->powerplans[d.seq].s_phase_name,
         '",')
       ENDIF
       col 1, ms_outstring, mn_col_size = size(ms_outstring,1)
      ELSE
       IF ((m_status_total->status[ml_cnt].l_status_cnt > 0))
        ms_outstring = build(m_powerplans->powerplans[d.seq].status[ml_cnt].l_status_cnt,","),
        call reportmove('COL',(mn_col_size+ 1),0), ms_outstring,
        mn_col_size = (size(ms_outstring,1)+ mn_col_size)
       ENDIF
      ENDIF
    ENDFOR
    row + 1
   FOOT REPORT
    FOR (ml_cnt = 1 TO size(m_status_total->status))
      IF (ml_cnt=1)
       IF ((m_status_total->status[ml_cnt].l_status_cnt > 0))
        ms_outstring = build(",Totals:,",m_status_total->status[ml_cnt].l_status_cnt,",")
       ELSE
        ms_outstring = build(",Totals:,")
       ENDIF
       col 1, ms_outstring, mn_col_size = size(ms_outstring,1)
      ELSE
       IF ((m_status_total->status[ml_cnt].l_status_cnt > 0))
        ms_outstring = build(m_status_total->status[ml_cnt].l_status_cnt,","), call reportmove('COL',
        (mn_col_size+ 1),0), ms_outstring,
        mn_col_size = (size(ms_outstring,1)+ mn_col_size)
       ENDIF
      ENDIF
    ENDFOR
   WITH nocounter, maxrow = 1, maxcol = 250
  ;end select
  CALL emailcheck(mn_email_ind)
 ENDIF
#exit_script
END GO
