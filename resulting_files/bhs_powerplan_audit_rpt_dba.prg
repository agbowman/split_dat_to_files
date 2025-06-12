CREATE PROGRAM bhs_powerplan_audit_rpt:dba
 PROMPT
  "Output to File/Printer/MINE/E-Mail" = "MINE"
  WITH outdev
 FREE RECORD m_pws
 RECORD m_pws(
   1 cnt = i4
   1 qual[*]
     2 f_pathway_catalog_id = f8
     2 c_description = c100
     2 s_synonym_name = vc
     2 c_sub_phase_ind = c50
     2 c_version = c50
     2 c_facility_flex = c15
     2 c_bmc_out = c50
     2 c_bmc_psych_out = c50
     2 c_fmc_out = c50
     2 c_fmc_psych_out = c50
     2 c_mlh_out = c50
     2 c_bwh_out = c50
     2 c_bwh_psych_out = c50
     2 c_bnh_out = c50
     2 c_bnh_psych_out = c50
     2 c_bnh_rehab_out = c50
     2 c_ctr_ca_care_out = c50
     2 c_mock_out = c50
     2 s_other_loc = vc
     2 c_updt_dt_tm = c50
     2 c_name_full_formatted = c100
 )
 FREE RECORD loc
 RECORD loc(
   1 list[*]
     2 pathway_catalog_id = f8
     2 sublist[*]
       3 cnt = i4
       3 code_value = f8
 )
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = h
   1 file_offset = h
   1 file_dir = h
 )
 DECLARE mf_bmc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_fmc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_mlh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bmc_inptpsych_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_fmc_inptpsych_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_mock_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bwh_inptpsych_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bwh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bwh_cd2 = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bnh_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bnh_inptpsych_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_bnh_rehab_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_ctr_ca_care_cd = f8 WITH protect, noconstant(0.0)
 DECLARE mf_parent_entity_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_data_type = vc WITH protect, noconstant(" ")
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_tmp_str = vc WITH protect, noconstant(" ")
 DECLARE ms_unit_p = vc WITH protect, noconstant(" ")
 DECLARE mn_email_ind = i2 WITH protect, noconstant(0)
 DECLARE ms_output_dest = vc WITH protect, noconstant(" ")
 DECLARE ms_date_disp = vc WITH protect, noconstant(" ")
 DECLARE ms_outstring = vc WITH protect, noconstant(" ")
 DECLARE ms_filename_in = vc WITH protect, noconstant(" ")
 DECLARE md_filename_out = vc WITH protect, noconstant(" ")
 DECLARE ms_bmc_out = vc WITH protect, noconstant(" ")
 DECLARE ms_fmc_out = vc WITH protect, noconstant(" ")
 DECLARE ms_mlh_out = vc WITH protect, noconstant(" ")
 DECLARE ms_bmc_psych_out = vc WITH protect, noconstant(" ")
 DECLARE ms_fmc_psych_out = vc WITH protect, noconstant(" ")
 DECLARE ms_ctr_ca_care_out = vc WITH protect, noconstant(" ")
 DECLARE ms_mock_out = vc WITH protect, noconstant(" ")
 DECLARE ms_bwh_psych_out = vc WITH protect, noconstant(" ")
 DECLARE ms_bwh_out = vc WITH protect, noconstant(" ")
 DECLARE ms_bnh_out = vc WITH protect, noconstant(" ")
 DECLARE ms_bnh_psych_out = vc WITH protect, noconstant(" ")
 DECLARE ms_bnh_rehab_out = vc WITH protect, noconstant(" ")
 DECLARE ms_other_out = vc WITH protect, noconstant(" ")
 DECLARE ms_other_loc = vc WITH protect, noconstant(" ")
 DECLARE mn_pc_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_ndx = i4 WITH protect, noconstant(0)
 DECLARE mn_loc_pos = i4 WITH protect, noconstant(0)
 DECLARE mn_ndx2 = i4 WITH protect, noconstant(0)
 DECLARE mn_loc_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_pc_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_other_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=220
    AND cv.cdf_meaning="FACILITY"
    AND cv.display_key IN ("BMC", "BFMC", "BMLH", "BMCINPTPSYCH", "BFMCINPTPSYCH",
   "MOCK", "BWHINPTPSYCH", "BWH", "BNH", "BNHINPTPSYCH",
   "BNHREHAB", "CTRCACARE")
    AND cv.active_ind=1)
  ORDER BY cv.display_key
  DETAIL
   CALL echo(build2("cv.display_key: ",cv.display_key," - ",cv.description))
   CASE (cv.display_key)
    OF "BMC":
     mf_bmc_cd = cv.code_value
    OF "BFMC":
     mf_fmc_cd = cv.code_value
    OF "BMLH":
     mf_mlh_cd = cv.code_value
    OF "BMCINPTPSYCH":
     mf_bmc_inptpsych_cd = cv.code_value
    OF "BFMCINPTPSYCH":
     mf_fmc_inptpsych_cd = cv.code_value
    OF "MOCK":
     mf_mock_cd = cv.code_value
    OF "BWHINPTPSYCH":
     mf_bwh_inptpsych_cd = cv.code_value
    OF "BWH":
     IF (cv.description="BAYSTATE WING HOSPITAL")
      mf_bwh_cd = cv.code_value
     ELSE
      mf_bwh_cd2 = cv.code_value
     ENDIF
    OF "BNH":
     mf_bnh_cd = cv.code_value
    OF "BNHINPTPSYCH":
     mf_bnh_inptpsych_cd = cv.code_value
    OF "BNHREHAB":
     mf_bnh_rehab_cd = cv.code_value
    OF "CTRCACARE":
     mf_ctr_ca_care_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (findstring("@", $OUTDEV) > 0)
  SET mn_email_ind = 1
  SET ms_output_dest = trim(concat(trim(cnvtlower(curprog)),format(cnvtdatetime(sysdate),
     "MMDDYYYYHHMMSS;;D")))
 ELSE
  SET mn_email_ind = 0
  SET ms_output_dest =  $OUTDEV
 ENDIF
 SELECT INTO "nl:"
  FROM pathway_catalog pc,
   pw_cat_flex pcf,
   prsnl p
  PLAN (pc
   WHERE pc.description > " "
    AND pc.active_ind=1
    AND pc.pathway_type_cd != 0.0)
   JOIN (pcf
   WHERE (pcf.pathway_catalog_id= Outerjoin(pc.pathway_catalog_id)) )
   JOIN (p
   WHERE p.person_id=pc.updt_id)
  ORDER BY pc.description_key, pc.pathway_catalog_id, 0
  HEAD REPORT
   ml_cnt = 1, m_pws->cnt = ml_cnt, stat = alterlist(m_pws->qual,ml_cnt),
   m_pws->qual[ml_cnt].c_description = "Powerplan Audit", ml_cnt += 1, m_pws->cnt = ml_cnt,
   stat = alterlist(m_pws->qual,ml_cnt), m_pws->qual[ml_cnt].c_description = build2("Current Date: ",
    format(sysdate,"mm/dd/yyyy;;d")), ml_cnt += 1,
   m_pws->cnt = ml_cnt, stat = alterlist(m_pws->qual,ml_cnt), m_pws->qual[ml_cnt].c_description =
   "Powerplan",
   m_pws->qual[ml_cnt].s_synonym_name = "Synonym", m_pws->qual[ml_cnt].c_sub_phase_ind =
   "Sub Phase Ind", m_pws->qual[ml_cnt].c_version = "Version",
   m_pws->qual[ml_cnt].c_facility_flex = "Facility Flex", m_pws->qual[ml_cnt].c_bmc_out = "BMC",
   m_pws->qual[ml_cnt].c_bmc_psych_out = "BMC INPTPSYCH",
   m_pws->qual[ml_cnt].c_fmc_out = "FMC", m_pws->qual[ml_cnt].c_fmc_psych_out = "FMC INPTPSYCH",
   m_pws->qual[ml_cnt].c_mlh_out = "MLH",
   m_pws->qual[ml_cnt].c_bwh_out = "BWH", m_pws->qual[ml_cnt].c_bwh_psych_out = "BWH INPTPSYCH",
   m_pws->qual[ml_cnt].c_bnh_out = "BNH",
   m_pws->qual[ml_cnt].c_bnh_psych_out = "BNH INPTPSYCH", m_pws->qual[ml_cnt].c_bnh_rehab_out =
   "BNH REHAB", m_pws->qual[ml_cnt].c_ctr_ca_care_out = "CTR_CA_CARE",
   m_pws->qual[ml_cnt].c_mock_out = "MOCK", m_pws->qual[ml_cnt].s_other_loc = "OTHER LOC", m_pws->
   qual[ml_cnt].c_updt_dt_tm = "UPDT_DT_TM",
   m_pws->qual[ml_cnt].c_name_full_formatted = "UPDATED BY"
  HEAD pc.description_key
   null
  HEAD pc.pathway_catalog_id
   ms_bmc_out = " ", ms_fmc_out = " ", ms_mlh_out = " ",
   ms_bmc_psych_out = " ", ms_fmc_psych_out = " ", ms_mock_out = " ",
   ms_bwh_psych_out = " ", ms_bwh_out = " ", ms_bnh_out = " ",
   ms_bnh_psych_out = " ", ms_bnh_rehab_out = " ", ms_ctr_ca_care_out = " ",
   ms_other_out = " ", ms_other_loc = " ", mn_loc_cnt = 0,
   mn_other_ind = 0
  DETAIL
   IF (pcf.parent_entity_id > 0.00)
    CASE (pcf.parent_entity_id)
     OF mf_bmc_cd:
      ms_bmc_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_fmc_cd:
      ms_fmc_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_mlh_cd:
      ms_mlh_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_bmc_inptpsych_cd:
      ms_bmc_psych_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_fmc_inptpsych_cd:
      ms_fmc_psych_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_mock_cd:
      ms_mock_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_bwh_inptpsych_cd:
      ms_bwh_psych_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_bwh_cd:
      ms_bwh_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_bwh_cd2:
      ms_bwh_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_bnh_cd:
      ms_bnh_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_bnh_inptpsych_cd:
      ms_bnh_psych_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_bnh_rehab_cd:
      ms_bnh_rehab_out = uar_get_code_display(pcf.parent_entity_id)
     OF mf_ctr_ca_care_cd:
      ms_ctr_ca_care_out = uar_get_code_display(pcf.parent_entity_id)
     ELSE
      IF (ms_other_loc=" ")
       ms_other_loc = trim(uar_get_code_display(pcf.parent_entity_id),3)
      ELSE
       ms_other_loc = concat(ms_other_loc,", ",trim(uar_get_code_display(pcf.parent_entity_id),3))
      ENDIF
    ENDCASE
   ENDIF
  FOOT  pc.pathway_catalog_id
   ml_cnt += 1, m_pws->cnt = ml_cnt, stat = alterlist(m_pws->qual,ml_cnt),
   m_pws->qual[ml_cnt].f_pathway_catalog_id = pc.pathway_catalog_id, m_pws->qual[ml_cnt].
   c_description = trim(pc.description,3), m_pws->qual[ml_cnt].c_sub_phase_ind = build(pc
    .sub_phase_ind),
   m_pws->qual[ml_cnt].c_version = build(pc.version), m_pws->qual[ml_cnt].c_facility_flex = evaluate(
    pcf.parent_entity_id,0.00,"all facilities","by location"), m_pws->qual[ml_cnt].c_bmc_out = trim(
    ms_bmc_out,3),
   m_pws->qual[ml_cnt].c_bmc_psych_out = trim(ms_bmc_psych_out,3), m_pws->qual[ml_cnt].c_fmc_out =
   trim(ms_fmc_out,3), m_pws->qual[ml_cnt].c_fmc_psych_out = trim(ms_fmc_psych_out,3),
   m_pws->qual[ml_cnt].c_mlh_out = trim(ms_mlh_out,3), m_pws->qual[ml_cnt].c_bwh_out = trim(
    ms_bwh_out,3), m_pws->qual[ml_cnt].c_bwh_psych_out = trim(ms_bwh_psych_out,3),
   m_pws->qual[ml_cnt].c_bnh_out = trim(ms_bnh_out,3), m_pws->qual[ml_cnt].c_bnh_psych_out = trim(
    ms_bnh_psych_out,3), m_pws->qual[ml_cnt].c_bnh_rehab_out = trim(ms_bnh_rehab_out,3),
   m_pws->qual[ml_cnt].c_ctr_ca_care_out = trim(ms_ctr_ca_care_out,3), m_pws->qual[ml_cnt].c_mock_out
    = trim(ms_mock_out,3), m_pws->qual[ml_cnt].s_other_loc = trim(ms_other_loc,3),
   m_pws->qual[ml_cnt].c_updt_dt_tm = trim(format(pc.updt_dt_tm,"MM/DD/YYYY;;D"),3), m_pws->qual[
   ml_cnt].c_name_full_formatted = trim(p.name_full_formatted,3)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = m_pws->cnt),
   pw_cat_synonym pcs
  PLAN (d)
   JOIN (pcs
   WHERE (pcs.pathway_catalog_id=m_pws->qual[d.seq].f_pathway_catalog_id)
    AND pcs.pathway_catalog_id > 0.00
    AND (pcs.synonym_name != m_pws->qual[d.seq].c_description))
  ORDER BY d.seq
  HEAD d.seq
   m_pws->qual[d.seq].s_synonym_name = " "
  DETAIL
   IF ((m_pws->qual[d.seq].s_synonym_name=" "))
    m_pws->qual[d.seq].s_synonym_name = trim(pcs.synonym_name,3)
   ELSE
    m_pws->qual[d.seq].s_synonym_name = concat(m_pws->qual[d.seq].s_synonym_name,", ",trim(pcs
      .synonym_name,3))
   ENDIF
  WITH nocounter
 ;end select
 IF (mn_email_ind=1)
  SET ms_filename_in = trim(concat(ms_output_dest,".dat"))
  SET frec->file_name = ms_filename_in
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  FOR (ml_loop = 1 TO m_pws->cnt)
   SET frec->file_buf = concat('"',trim(m_pws->qual[ml_loop].c_description,3),'"',',"',trim(m_pws->
     qual[ml_loop].s_synonym_name,3),
    '"',',"',trim(m_pws->qual[ml_loop].c_sub_phase_ind,3),'"',',"',
    trim(m_pws->qual[ml_loop].c_version,3),'"',',"',trim(m_pws->qual[ml_loop].c_facility_flex,3),'"',
    ',"',trim(m_pws->qual[ml_loop].c_bmc_out,3),'"',',"',trim(m_pws->qual[ml_loop].c_bmc_psych_out,3),
    '"',',"',trim(m_pws->qual[ml_loop].c_fmc_out,3),'"',',"',
    trim(m_pws->qual[ml_loop].c_fmc_psych_out,3),'"',',"',trim(m_pws->qual[ml_loop].c_mlh_out,3),'"',
    ',"',trim(m_pws->qual[ml_loop].c_bwh_out,3),'"',',"',trim(m_pws->qual[ml_loop].c_bwh_psych_out,3),
    '"',',"',trim(m_pws->qual[ml_loop].c_bnh_out,3),'"',',"',
    trim(m_pws->qual[ml_loop].c_bnh_psych_out,3),'"',',"',trim(m_pws->qual[ml_loop].c_bnh_rehab_out,3
     ),'"',
    ',"',trim(m_pws->qual[ml_loop].c_ctr_ca_care_out,3),'"',',"',trim(m_pws->qual[ml_loop].c_mock_out,
     3),
    '"',',"',trim(m_pws->qual[ml_loop].s_other_loc,3),'"',',"',
    trim(m_pws->qual[ml_loop].c_updt_dt_tm,3),'"',',"',trim(m_pws->qual[ml_loop].
     c_name_full_formatted,3),'"',
    char(13),char(10))
   SET stat = cclio("PUTS",frec)
  ENDFOR
  SET stat = cclio("WRITE",frec)
  SET stat = cclio("CLOSE",frec)
  SET ms_filename_out = concat("PowerPlanAudit",format(curdate,"MMDDYYYY;;D"),".csv")
  EXECUTE bhs_ma_email_file
  CALL emailfile(ms_filename_in,ms_filename_out, $OUTDEV,concat(curprog,
    "- Baystate Medical Center Powerplan Audit"),1)
 ELSE
  SELECT INTO  $OUTDEV
   description = trim(m_pws->qual[d.seq].c_description,3), synonym_name = trim(substring(1,10000,
     m_pws->qual[d.seq].s_synonym_name),3), sub_phase_ind = trim(m_pws->qual[d.seq].c_sub_phase_ind,3
    ),
   version = trim(m_pws->qual[d.seq].c_version,3), facility_flex = trim(m_pws->qual[d.seq].
    c_facility_flex,3), bmc_out = trim(m_pws->qual[d.seq].c_bmc_out,3),
   bmc_psych_out = trim(m_pws->qual[d.seq].c_bmc_psych_out,3), fmc_out = trim(m_pws->qual[d.seq].
    c_fmc_out,3), fmc_psych_out = trim(m_pws->qual[d.seq].c_fmc_psych_out,3),
   mlh_out = trim(m_pws->qual[d.seq].c_mlh_out,3), bwh_out = trim(m_pws->qual[d.seq].c_bwh_out,3),
   bwh_psych_out = trim(m_pws->qual[d.seq].c_bwh_psych_out,3),
   bnh_out = trim(m_pws->qual[d.seq].c_bnh_out,3), bnh_psych_out = trim(m_pws->qual[d.seq].
    c_bnh_psych_out,3), bnh_rehab_out = trim(m_pws->qual[d.seq].c_bnh_rehab_out,3),
   ctr_ca_care_out = trim(m_pws->qual[d.seq].c_ctr_ca_care_out,3), mock_out = trim(m_pws->qual[d.seq]
    .c_mock_out,3), other_loc = trim(substring(1,10000,m_pws->qual[d.seq].s_other_loc),3),
   updt_dt_tm = trim(m_pws->qual[d.seq].c_updt_dt_tm,3), updated_by = trim(m_pws->qual[d.seq].
    c_name_full_formatted,3)
   FROM (dummyt d  WITH seq = m_pws->cnt)
   WITH format, separator = " ", nocounter
  ;end select
 ENDIF
#exit_program
 FREE RECORD loc
 FREE RECORD m_pws
END GO
