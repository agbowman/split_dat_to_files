CREATE PROGRAM dm_obsolete_indexes_80:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 IF (currdb="ORACLE")
  RECORD tmp(
    1 qual[*]
      2 index_name = vc
      2 drop_ind = i2
      2 err_code = i4
      2 err_msg = vc
  )
  RECORD ora_info(
    1 ora_version = i4
    1 ora_complete_version = vc
  )
  DECLARE tmpstr = vc
  DECLARE droptotal = i4
  DECLARE xx = i4
  DECLARE yy = i4
  DECLARE parse_str = vc
  DECLARE failedcnt = i4
  DECLARE successcnt = i4
  DECLARE recordcnt = i4
  SET recordcnt = 282
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  SET droptotal = 0
  SET xx = 0
  SET yy = 0
  SET failedcnt = 0
  SET successcnt = 0
  EXECUTE dm_readme_status
  SET stat = alterlist(tmp->qual,recordcnt)
  SET tmp->qual[1].index_name = "XAK1ABN_RULE"
  SET tmp->qual[1].drop_ind = - (1)
  SET tmp->qual[2].index_name = "XAK2ABN_RULE"
  SET tmp->qual[2].drop_ind = - (1)
  SET tmp->qual[3].index_name = "XAK3ABN_RULE"
  SET tmp->qual[3].drop_ind = - (1)
  SET tmp->qual[4].index_name = "XAK4ABN_RULE"
  SET tmp->qual[4].drop_ind = - (1)
  SET tmp->qual[5].index_name = "XIF171ACT_ACT_RELTN"
  SET tmp->qual[5].drop_ind = - (1)
  SET tmp->qual[6].index_name = "XIE4ACT_PW_COMP"
  SET tmp->qual[6].drop_ind = - (1)
  SET tmp->qual[7].index_name = "XIE1ADDITIONAL_AMOUNT_DEF"
  SET tmp->qual[7].drop_ind = - (1)
  SET tmp->qual[8].index_name = "XIE2APP_PREFS"
  SET tmp->qual[8].drop_ind = - (1)
  SET tmp->qual[9].index_name = "XAK1AP_TAG_GROUP"
  SET tmp->qual[9].drop_ind = - (1)
  SET tmp->qual[10].index_name = "XIDX1BB_RH_PHENOTYPE"
  SET tmp->qual[10].drop_ind = - (1)
  SET tmp->qual[11].index_name = "XIF189BE_AT_RELTN"
  SET tmp->qual[11].drop_ind = - (1)
  SET tmp->qual[12].index_name = "XIF12ALPHA_RESPONSE_ITEMS"
  SET tmp->qual[12].drop_ind = - (1)
  SET tmp->qual[13].index_name = "XIF005BILL_TEMPL"
  SET tmp->qual[13].drop_ind = - (1)
  SET tmp->qual[14].index_name = "XIE1CE_SUSCEP_FOOTNOTE_R"
  SET tmp->qual[14].drop_ind = - (1)
  SET tmp->qual[15].index_name = "XIF2CHARGE_JOURNAL"
  SET tmp->qual[15].drop_ind = - (1)
  SET tmp->qual[16].index_name = "XIE2CN_PATHWAY_ST"
  SET tmp->qual[16].drop_ind = - (1)
  SET tmp->qual[17].index_name = "XIF002CORSP_CORSP_RELTN"
  SET tmp->qual[17].drop_ind = - (1)
  SET tmp->qual[18].index_name = "XIE2CQM_FSIESO_TR_1"
  SET tmp->qual[18].drop_ind = - (1)
  SET tmp->qual[19].index_name = "XIE1CQM_FSIOCC_QUE"
  SET tmp->qual[19].drop_ind = - (1)
  SET tmp->qual[20].index_name = "XIE3CQM_FSIOCC_QUE"
  SET tmp->qual[20].drop_ind = - (1)
  SET tmp->qual[21].index_name = "XFK1CQM_ROPRESULTS_QUE"
  SET tmp->qual[21].drop_ind = - (1)
  SET tmp->qual[22].index_name = "XFK2CQM_ROPRESULTS_TR_1"
  SET tmp->qual[22].drop_ind = - (1)
  SET tmp->qual[23].index_name = "XIF67CYTO_STANDARD_REPORT"
  SET tmp->qual[23].drop_ind = - (1)
  SET tmp->qual[24].index_name = "XFK1DCP_ACTIVITY_LOG"
  SET tmp->qual[24].drop_ind = - (1)
  SET tmp->qual[25].index_name = "XFK2DCP_CARE_TEAM_PRSNL"
  SET tmp->qual[25].drop_ind = - (1)
  SET tmp->qual[26].index_name = "XIF38DCP_EQUA_COMPONENENT"
  SET tmp->qual[26].drop_ind = - (1)
  SET tmp->qual[27].index_name = "XFK1DCP_FORMS_ACTIVITY"
  SET tmp->qual[27].drop_ind = - (1)
  SET tmp->qual[28].index_name = "XFK2DCP_FORMS_ACTIVITY"
  SET tmp->qual[28].drop_ind = - (1)
  SET tmp->qual[29].index_name = "XFK1DCP_FORMS_DEF"
  SET tmp->qual[29].drop_ind = - (1)
  SET tmp->qual[30].index_name = "XFK2DCP_FORMS_DEF"
  SET tmp->qual[30].drop_ind = - (1)
  SET tmp->qual[31].index_name = "XFK1DCP_INPUT_REF"
  SET tmp->qual[31].drop_ind = - (1)
  SET tmp->qual[32].index_name = "XIE1DCP_INTERP_COMPONENT"
  SET tmp->qual[32].drop_ind = - (1)
  SET tmp->qual[33].index_name = "XIE1DCP_INTERP_STATE"
  SET tmp->qual[33].drop_ind = - (1)
  SET tmp->qual[34].index_name = "XFK1DCP_NOMENCATEGORYDEF"
  SET tmp->qual[34].drop_ind = - (1)
  SET tmp->qual[35].index_name = "XFK1DCP_PL_RELTN"
  SET tmp->qual[35].drop_ind = - (1)
  SET tmp->qual[36].index_name = "XFK1DCP_SHIFT_ASSIGNMENT"
  SET tmp->qual[36].drop_ind = - (1)
  SET tmp->qual[37].index_name = "XFK2DCP_SHIFT_ASSIGNMENT"
  SET tmp->qual[37].drop_ind = - (1)
  SET tmp->qual[38].index_name = "XIE5DEVICE"
  SET tmp->qual[38].drop_ind = - (1)
  SET tmp->qual[39].index_name = "XIE1DM_MERGE_AUDIT"
  SET tmp->qual[39].drop_ind = - (1)
  SET tmp->qual[40].index_name = "XIE1DONOR_VENIPUNCTURE_SITE"
  SET tmp->qual[40].drop_ind = - (1)
  SET tmp->qual[41].index_name = "XIE4DRG"
  SET tmp->qual[41].drop_ind = - (1)
  SET tmp->qual[42].index_name = "XIF5EKS_DLG_EVT_ACTION_R"
  SET tmp->qual[42].drop_ind = - (1)
  SET tmp->qual[43].index_name = "XIF1EKS_DLG_EVT_ANSWER_R"
  SET tmp->qual[43].drop_ind = - (1)
  SET tmp->qual[44].index_name = "XIE3ESO_TRIG_ROUTINE_R"
  SET tmp->qual[44].drop_ind = - (1)
  SET tmp->qual[45].index_name = "XIE2EVENTSET_TASK_RLTN"
  SET tmp->qual[45].drop_ind = - (1)
  SET tmp->qual[46].index_name = "XIF11EXPEDITE_CODED_RESP"
  SET tmp->qual[46].drop_ind = - (1)
  SET tmp->qual[47].index_name = "XIE1HIM_EVENT_ALLOCATION"
  SET tmp->qual[47].drop_ind = - (1)
  SET tmp->qual[48].index_name = "XIE1_HLA_SERA_QUERY_R"
  SET tmp->qual[48].drop_ind = - (1)
  SET tmp->qual[49].index_name = "XIE1INITIAL_PRODUCT_STATE"
  SET tmp->qual[49].drop_ind = - (1)
  SET tmp->qual[50].index_name = "XIE1ITEM_DEFINITION"
  SET tmp->qual[50].drop_ind = - (1)
  SET tmp->qual[51].index_name = "XIE1ITEM_INTERVAL_TABLE"
  SET tmp->qual[51].drop_ind = - (1)
  SET tmp->qual[52].index_name = "XAK1ITEM_LOCATION_COST"
  SET tmp->qual[52].drop_ind = - (1)
  SET tmp->qual[53].index_name = "XIE1ITEM_PRICE"
  SET tmp->qual[53].drop_ind = - (1)
  SET tmp->qual[54].index_name = "XAK1LABEL_XREF"
  SET tmp->qual[54].drop_ind = - (1)
  SET tmp->qual[55].index_name = "XIE2MED_COST_HX"
  SET tmp->qual[55].drop_ind = - (1)
  SET tmp->qual[56].index_name = "XI1MIC_AR_SUSCEPTIBILITY"
  SET tmp->qual[56].drop_ind = - (1)
  SET tmp->qual[57].index_name = "XIE1MIC_FOOTNOTE_FORMAT"
  SET tmp->qual[57].drop_ind = - (1)
  SET tmp->qual[58].index_name = "XIF75MIC_GROUP_RESPONSE_MBR"
  SET tmp->qual[58].drop_ind = - (1)
  SET tmp->qual[59].index_name = "XIE1MIC_INTERP"
  SET tmp->qual[59].drop_ind = - (1)
  SET tmp->qual[60].index_name = "XIE1MIC_INTERP_RANGE"
  SET tmp->qual[60].drop_ind = - (1)
  SET tmp->qual[61].index_name = "XIE1MIC_REQUIRED_TASK"
  SET tmp->qual[61].drop_ind = - (1)
  SET tmp->qual[62].index_name = "XIE1MIC_REQ_RPT"
  SET tmp->qual[62].drop_ind = - (1)
  SET tmp->qual[63].index_name = "XIE1MIC_SORT_FIELD"
  SET tmp->qual[63].drop_ind = - (1)
  SET tmp->qual[64].index_name = "XIE1MIC_STAT_FILTER_EXT"
  SET tmp->qual[64].drop_ind = - (1)
  SET tmp->qual[65].index_name = "XIE1MIC_VALID_SUS_RESULT"
  SET tmp->qual[65].drop_ind = - (1)
  SET tmp->qual[66].index_name = "XIE2MMI_MICROBIOLOGY"
  SET tmp->qual[66].drop_ind = - (1)
  SET tmp->qual[67].index_name = "XIE1MM_COMMENT"
  SET tmp->qual[67].drop_ind = - (1)
  SET tmp->qual[68].index_name = "XIF9MONITOR_COMPONENT"
  SET tmp->qual[68].drop_ind = - (1)
  SET tmp->qual[69].index_name = "XIF10MONITOR_VIEW_FIELD"
  SET tmp->qual[69].drop_ind = - (1)
  SET tmp->qual[70].index_name = "XIE16NOMENCLATURE"
  SET tmp->qual[70].drop_ind = - (1)
  SET tmp->qual[71].index_name = "XIF41NOMENCLATURE_OUTBOUND"
  SET tmp->qual[71].drop_ind = - (1)
  SET tmp->qual[72].index_name = "XIE2NOMEN_CAT_LIST"
  SET tmp->qual[72].drop_ind = - (1)
  SET tmp->qual[73].index_name = "XIE1OASIS_EXT_ENCNTR_CD"
  SET tmp->qual[73].drop_ind = - (1)
  SET tmp->qual[74].index_name = "XAK3OEN_PROCINFO"
  SET tmp->qual[74].drop_ind = - (1)
  SET tmp->qual[75].index_name = "XIE1OMF_BM_CHA"
  SET tmp->qual[75].drop_ind = - (1)
  SET tmp->qual[76].index_name = "XIE1OMF_CC_PPP_CHARGE_ST"
  SET tmp->qual[76].drop_ind = - (1)
  SET tmp->qual[77].index_name = "XIE1OMF_CC_TS_CHARGE_ST"
  SET tmp->qual[77].drop_ind = - (1)
  SET tmp->qual[78].index_name = "XIE1OMF_CPT4_PROCEDURE_ST"
  SET tmp->qual[78].drop_ind = - (1)
  SET tmp->qual[79].index_name = "XIE1OMF_ICD9_DIAGNOSIS_ST"
  SET tmp->qual[79].drop_ind = - (1)
  SET tmp->qual[80].index_name = "XIE1OMF_ICD9_PROCEDURE_ST"
  SET tmp->qual[80].drop_ind = - (1)
  SET tmp->qual[81].index_name = "XIE8OMF_PRSNL_PAYPERIOD_ST"
  SET tmp->qual[81].drop_ind = - (1)
  SET tmp->qual[82].index_name = "XIE9OMF_PRSNL_TIMEDATE_ST"
  SET tmp->qual[82].drop_ind = - (1)
  SET tmp->qual[83].index_name = "XIE2OMF_PRSNL_TIMEHOUR_ST"
  SET tmp->qual[83].drop_ind = - (1)
  SET tmp->qual[84].index_name = "XIE1OMF_PV_BATCH"
  SET tmp->qual[84].drop_ind = - (1)
  SET tmp->qual[85].index_name = "XIE1OPS_SCHEDULE_CONTROL_GROUP"
  SET tmp->qual[85].drop_ind = - (1)
  SET tmp->qual[86].index_name = "XIE1OPS_SCHEDULE_JOB_STEP"
  SET tmp->qual[86].drop_ind = - (1)
  SET tmp->qual[87].index_name = "XIF17ORDER_CATALOG_ITEM_R"
  SET tmp->qual[87].drop_ind = - (1)
  SET tmp->qual[88].index_name = "XIE1ORDER_CATALOG_SYNONYM"
  SET tmp->qual[88].drop_ind = - (1)
  SET tmp->qual[89].index_name = "XFKNDX1ORDER_DISPENSE"
  SET tmp->qual[89].drop_ind = - (1)
  SET tmp->qual[90].index_name = "XIE3ORDER_SERV_RES_CONTAINER"
  SET tmp->qual[90].drop_ind = - (1)
  SET tmp->qual[91].index_name = "XIE1OUTBOUND_SELECTION"
  SET tmp->qual[91].drop_ind = - (1)
  SET tmp->qual[92].index_name = "XAK1OUTPUT_DEST"
  SET tmp->qual[92].drop_ind = - (1)
  SET tmp->qual[93].index_name = "XIE1PATHWAY_CATALOG"
  SET tmp->qual[93].drop_ind = - (1)
  SET tmp->qual[94].index_name = "XIE1PATHWAY_COMP_FOCUS_R"
  SET tmp->qual[94].drop_ind = - (1)
  SET tmp->qual[95].index_name = "XIE2PAT_ED_DOCUMENT"
  SET tmp->qual[95].drop_ind = - (1)
  SET tmp->qual[96].index_name = "XIE1PC_FORM_DETAIL"
  SET tmp->qual[96].drop_ind = - (1)
  SET tmp->qual[97].index_name = "XIE1PERSON_HLA_AB_SCN_AUDIT"
  SET tmp->qual[97].drop_ind = - (1)
  SET tmp->qual[98].index_name = "XIE1PERSON_HLA_AB_SCREEN"
  SET tmp->qual[98].drop_ind = - (1)
  SET tmp->qual[99].index_name = "XIE1PERSON_HLA_AB_SPEC"
  SET tmp->qual[99].drop_ind = - (1)
  SET tmp->qual[100].index_name = "XIE1PERSON_HLA_EVENT"
  SET tmp->qual[100].drop_ind = - (1)
  SET tmp->qual[101].index_name = "XIE1PERSON_HLA_EVENT_AUDIT"
  SET tmp->qual[101].drop_ind = - (1)
  SET tmp->qual[102].index_name = "XIE1PERSON_HLA_TYPE_AUDIT"
  SET tmp->qual[102].drop_ind = - (1)
  SET tmp->qual[103].index_name = "XIE1PERSON_HLA_XM"
  SET tmp->qual[103].drop_ind = - (1)
  SET tmp->qual[104].index_name = "XIE1PERSON_ORGAN_DONOR"
  SET tmp->qual[104].drop_ind = - (1)
  SET tmp->qual[105].index_name = "XIF316PERSON_PRSNL_RELTN"
  SET tmp->qual[105].drop_ind = - (1)
  SET tmp->qual[106].index_name = "XIF315PERSON_PRSNL_RELTN"
  SET tmp->qual[106].drop_ind = - (1)
  SET tmp->qual[107].index_name = "XIE1PERSON_TRANSPLANT_CAND"
  SET tmp->qual[107].drop_ind = - (1)
  SET tmp->qual[108].index_name = "XFI3PE_BO_RELTN"
  SET tmp->qual[108].drop_ind = - (1)
  SET tmp->qual[109].index_name = "XIF1PFT_ALIAS"
  SET tmp->qual[109].drop_ind = - (1)
  SET tmp->qual[110].index_name = "XIF1PFT_ENCNTR"
  SET tmp->qual[110].drop_ind = - (1)
  SET tmp->qual[111].index_name = "XFK1PIP_COLUMN"
  SET tmp->qual[111].drop_ind = - (1)
  SET tmp->qual[112].index_name = "XFK1PIP_SECTION"
  SET tmp->qual[112].drop_ind = - (1)
  SET tmp->qual[113].index_name = "XIE2PLCATALOGSEGMENTS"
  SET tmp->qual[113].drop_ind = - (1)
  SET tmp->qual[114].index_name = "XIF92PRICE_SCHED_ITEMS"
  SET tmp->qual[114].drop_ind = - (1)
  SET tmp->qual[115].index_name = "XIF661PRIVILEGE"
  SET tmp->qual[115].drop_ind = - (1)
  SET tmp->qual[116].index_name = "XIF658PRIVILEGE_EXCEPTION"
  SET tmp->qual[116].drop_ind = - (1)
  SET tmp->qual[117].index_name = "XIE2PRIV_LOC_RELTN"
  SET tmp->qual[117].drop_ind = - (1)
  SET tmp->qual[118].index_name = "XIF1PROBLEM"
  SET tmp->qual[118].drop_ind = - (1)
  SET tmp->qual[119].index_name = "XIE2PROCEDURE_BAG_TYPE_R"
  SET tmp->qual[119].drop_ind = - (1)
  SET tmp->qual[120].index_name = "XIE1PROCEDURE_ELIGIBILITY_R"
  SET tmp->qual[120].drop_ind = - (1)
  SET tmp->qual[121].index_name = "XIE1PROCEDURE_OUTCOME_R"
  SET tmp->qual[121].drop_ind = - (1)
  SET tmp->qual[122].index_name = "XIE1PROCINFO_SYSTEM_R"
  SET tmp->qual[122].drop_ind = - (1)
  SET tmp->qual[123].index_name = "XIE3PROC_BAG_PRODUCT_R"
  SET tmp->qual[123].drop_ind = - (1)
  SET tmp->qual[124].index_name = "XIE1PROC_OUTCOME_REASON_R"
  SET tmp->qual[124].drop_ind = - (1)
  SET tmp->qual[125].index_name = "XIE2PRODUCT_PATIENT_ABORH"
  SET tmp->qual[125].drop_ind = - (1)
  SET tmp->qual[126].index_name = "XIF33PRSNL_NOTIFY"
  SET tmp->qual[126].drop_ind = - (1)
  SET tmp->qual[127].index_name = "XIF34PRSNL_NOTIFY_PPR"
  SET tmp->qual[127].drop_ind = - (1)
  SET tmp->qual[128].index_name = "XIE2PSN_PPR_RELTN"
  SET tmp->qual[128].drop_ind = - (1)
  SET tmp->qual[129].index_name = "XIE10RAD_OMF_MAMMO"
  SET tmp->qual[129].drop_ind = - (1)
  SET tmp->qual[130].index_name = "XIE10RAD_OMF_MAMMO_FIND"
  SET tmp->qual[130].drop_ind = - (1)
  SET tmp->qual[131].index_name = "XIE2RAD_TEMPLATE_GROUP"
  SET tmp->qual[131].drop_ind = - (1)
  SET tmp->qual[132].index_name = "XIE1RAD_TRACK_EVENT_DETAIL"
  SET tmp->qual[132].drop_ind = - (1)
  SET tmp->qual[133].index_name = "XIE3RAD_WORKLIST"
  SET tmp->qual[133].drop_ind = - (1)
  SET tmp->qual[134].index_name = "XIE1RAD_WORKLIST_SECTION_R"
  SET tmp->qual[134].drop_ind = - (1)
  SET tmp->qual[135].index_name = "XIE1REF_TEXT_RELTN"
  SET tmp->qual[135].drop_ind = - (1)
  SET tmp->qual[136].index_name = "XIE2ROBOTICS_AV_TRANSACTION"
  SET tmp->qual[136].drop_ind = - (1)
  SET tmp->qual[137].index_name = "XIE2ROBOTICS_DEST_CODES"
  SET tmp->qual[137].drop_ind = - (1)
  SET tmp->qual[138].index_name = "XIE1SCH_ACTION_ROLE"
  SET tmp->qual[138].drop_ind = - (1)
  SET tmp->qual[139].index_name = "XIE1SCH_APPLY_EXCEPT"
  SET tmp->qual[139].drop_ind = - (1)
  SET tmp->qual[140].index_name = "XIE1SCH_APPT"
  SET tmp->qual[140].drop_ind = - (1)
  SET tmp->qual[141].index_name = "XIE4SCH_APPT"
  SET tmp->qual[141].drop_ind = - (1)
  SET tmp->qual[142].index_name = "XIE4SCH_ASSOC"
  SET tmp->qual[142].drop_ind = - (1)
  SET tmp->qual[143].index_name = "XIE4SCH_BOOKING"
  SET tmp->qual[143].drop_ind = - (1)
  SET tmp->qual[144].index_name = "XIE6SCH_BOOKING"
  SET tmp->qual[144].drop_ind = - (1)
  SET tmp->qual[145].index_name = "XIE4SCH_DATE_COMMENT"
  SET tmp->qual[145].drop_ind = - (1)
  SET tmp->qual[146].index_name = "XIE1SCH_DEF_SLOT"
  SET tmp->qual[146].drop_ind = - (1)
  SET tmp->qual[147].index_name = "XIE2SCH_EVENT_ACTION"
  SET tmp->qual[147].drop_ind = - (1)
  SET tmp->qual[148].index_name = "XIE1SCH_EVENT_COMM"
  SET tmp->qual[148].drop_ind = - (1)
  SET tmp->qual[149].index_name = "XIE1SCH_EVENT_DETAIL"
  SET tmp->qual[149].drop_ind = - (1)
  SET tmp->qual[150].index_name = "XIE1SCH_EVENT_ROLE"
  SET tmp->qual[150].drop_ind = - (1)
  SET tmp->qual[151].index_name = "XIE2SCH_LOCK"
  SET tmp->qual[151].drop_ind = - (1)
  SET tmp->qual[152].index_name = "XIE2SCH_ORDER_DURATION"
  SET tmp->qual[152].drop_ind = - (1)
  SET tmp->qual[153].index_name = "XIE1SCH_ORDER_INTER"
  SET tmp->qual[153].drop_ind = - (1)
  SET tmp->qual[154].index_name = "XIE1SCH_ROUTE_LIST"
  SET tmp->qual[154].drop_ind = - (1)
  SET tmp->qual[155].index_name = "XIE3SCH_SECURITY"
  SET tmp->qual[155].drop_ind = - (1)
  SET tmp->qual[156].index_name = "XIE2SCH_SIMPLE_ASSOC"
  SET tmp->qual[156].drop_ind = - (1)
  SET tmp->qual[157].index_name = "XIE1SCH_SIMPLE_ASSOC"
  SET tmp->qual[157].drop_ind = - (1)
  SET tmp->qual[158].index_name = "XIE1SCH_TEMP_FLEX"
  SET tmp->qual[158].drop_ind = - (1)
  SET tmp->qual[159].index_name = "XIE1SCH_USER_LINK"
  SET tmp->qual[159].drop_ind = - (1)
  SET tmp->qual[160].index_name = "XIE1SCH_USER_TEXT"
  SET tmp->qual[160].drop_ind = - (1)
  SET tmp->qual[161].index_name = "XIE2SCH_WARNING"
  SET tmp->qual[161].drop_ind = - (1)
  SET tmp->qual[162].index_name = "XIE1SCR_PARAGRAPH"
  SET tmp->qual[162].drop_ind = - (1)
  SET tmp->qual[163].index_name = "XIE1SEGMENT_HEADER"
  SET tmp->qual[163].drop_ind = - (1)
  SET tmp->qual[164].index_name = "XIE2SEG_GRP_SEQ_R"
  SET tmp->qual[164].drop_ind = - (1)
  SET tmp->qual[165].index_name = "XIF3SEMANTIC_NETWORK"
  SET tmp->qual[165].drop_ind = - (1)
  SET tmp->qual[166].index_name = "XIESESSION_XREF"
  SET tmp->qual[166].drop_ind = - (1)
  SET tmp->qual[167].index_name = "XIE2SI_BATCH"
  SET tmp->qual[167].drop_ind = - (1)
  SET tmp->qual[168].index_name = "XIE3SI_BATCH"
  SET tmp->qual[168].drop_ind = - (1)
  SET tmp->qual[169].index_name = "XIE1SI_BATCH_EVENT"
  SET tmp->qual[169].drop_ind = - (1)
  SET tmp->qual[170].index_name = "XIE4SI_BATCH_EVENT"
  SET tmp->qual[170].drop_ind = - (1)
  SET tmp->qual[171].index_name = "XIE3SI_BATCH_EVENT"
  SET tmp->qual[171].drop_ind = - (1)
  SET tmp->qual[172].index_name = "XIE2SI_BATCH_EVENT"
  SET tmp->qual[172].drop_ind = - (1)
  SET tmp->qual[173].index_name = "XIE1SI_BATCH_EVENT_MSG"
  SET tmp->qual[173].drop_ind = - (1)
  SET tmp->qual[174].index_name = "XIE1SI_BATCH_EVENT_SYS"
  SET tmp->qual[174].drop_ind = - (1)
  SET tmp->qual[175].index_name = "XIE3SI_BATCH_EVENT_SYS"
  SET tmp->qual[175].drop_ind = - (1)
  SET tmp->qual[176].index_name = "XIE4SI_BATCH_EVENT_SYS"
  SET tmp->qual[176].drop_ind = - (1)
  SET tmp->qual[177].index_name = "XFK1SI_BATCH_STATS"
  SET tmp->qual[177].drop_ind = - (1)
  SET tmp->qual[178].index_name = "XIE1SI_BATCH_STATS"
  SET tmp->qual[178].drop_ind = - (1)
  SET tmp->qual[179].index_name = "XIE3SI_BATCH_STATS"
  SET tmp->qual[179].drop_ind = - (1)
  SET tmp->qual[180].index_name = "XIE1SI_COMSRV_MSG_MAP_R"
  SET tmp->qual[180].drop_ind = - (1)
  SET tmp->qual[181].index_name = "XIE4SI_COMSRV_MSG_MAP_R"
  SET tmp->qual[181].drop_ind = - (1)
  SET tmp->qual[182].index_name = "XIE2SI_MAPPING_OBJECT"
  SET tmp->qual[182].drop_ind = - (1)
  SET tmp->qual[183].index_name = "XIE3SI_MAPPING_OBJECT"
  SET tmp->qual[183].drop_ind = - (1)
  SET tmp->qual[184].index_name = "XIE2SI_MESSAGE"
  SET tmp->qual[184].drop_ind = - (1)
  SET tmp->qual[185].index_name = "XIE3SI_MESSAGE"
  SET tmp->qual[185].drop_ind = - (1)
  SET tmp->qual[186].index_name = "XIE4SI_MESSAGE"
  SET tmp->qual[186].drop_ind = - (1)
  SET tmp->qual[187].index_name = "XIE6SI_MESSAGE"
  SET tmp->qual[187].drop_ind = - (1)
  SET tmp->qual[188].index_name = "XIE5SI_MESSAGE"
  SET tmp->qual[188].drop_ind = - (1)
  SET tmp->qual[189].index_name = "XIE2SI_PARAMETER"
  SET tmp->qual[189].drop_ind = - (1)
  SET tmp->qual[190].index_name = "XIE3SI_PARAMETER"
  SET tmp->qual[190].drop_ind = - (1)
  SET tmp->qual[191].index_name = "XIE4SI_PARAMETER"
  SET tmp->qual[191].drop_ind = - (1)
  SET tmp->qual[192].index_name = "XIE2SN_APP_PREFS"
  SET tmp->qual[192].drop_ind = - (1)
  SET tmp->qual[193].index_name = "XIE1SN_CE_EXTRACT_ST"
  SET tmp->qual[193].drop_ind = - (1)
  SET tmp->qual[194].index_name = "XIE1SN_CHARGE_ITEM"
  SET tmp->qual[194].drop_ind = - (1)
  SET tmp->qual[195].index_name = "XIE2SN_COMMENT"
  SET tmp->qual[195].drop_ind = - (1)
  SET tmp->qual[196].index_name = "XIE1SN_COMMENT_TEXT"
  SET tmp->qual[196].drop_ind = - (1)
  SET tmp->qual[197].index_name = "XIE1SN_DIAGNOSTIC_REL"
  SET tmp->qual[197].drop_ind = - (1)
  SET tmp->qual[198].index_name = "XIFK1SN_IMPLANT_LOG_ST"
  SET tmp->qual[198].drop_ind = - (1)
  SET tmp->qual[199].index_name = "XIE1SN_REPORT"
  SET tmp->qual[199].drop_ind = - (1)
  SET tmp->qual[200].index_name = "XIF878SPEC_LBL_PRINTER_DEF"
  SET tmp->qual[200].drop_ind = - (1)
  SET tmp->qual[201].index_name = "XIF87STORAGE_GROUP"
  SET tmp->qual[201].drop_ind = - (1)
  SET tmp->qual[202].index_name = "XIE1SURGICAL_STAFF"
  SET tmp->qual[202].drop_ind = - (1)
  SET tmp->qual[203].index_name = "XIE1SURGICAL_TEAM"
  SET tmp->qual[203].drop_ind = - (1)
  SET tmp->qual[204].index_name = "XIE1SURG_NEXT_VAL"
  SET tmp->qual[204].drop_ind = - (1)
  SET tmp->qual[205].index_name = "XAK1TAG_GROUP_FOUNDATION"
  SET tmp->qual[205].drop_ind = - (1)
  SET tmp->qual[206].index_name = "XIE11TASK_ACTIVITY"
  SET tmp->qual[206].drop_ind = - (1)
  SET tmp->qual[207].index_name = "XIE1TRACKING_CHECKIN"
  SET tmp->qual[207].drop_ind = - (1)
  SET tmp->qual[208].index_name = "XIE3TRACKING_ENCNTR_PRSNL_REL"
  SET tmp->qual[208].drop_ind = - (1)
  SET tmp->qual[209].index_name = "XIE1TRACKING_EVENT"
  SET tmp->qual[209].drop_ind = - (1)
  SET tmp->qual[210].index_name = "XIF6TRACKING_ITEM"
  SET tmp->qual[210].drop_ind = - (1)
  SET tmp->qual[211].index_name = "XIF7TRACKING_ITEM"
  SET tmp->qual[211].drop_ind = - (1)
  SET tmp->qual[212].index_name = "XIF5TRACKING_ITEM"
  SET tmp->qual[212].drop_ind = - (1)
  SET tmp->qual[213].index_name = "XIF8TRACKING_ITEM"
  SET tmp->qual[213].drop_ind = - (1)
  SET tmp->qual[214].index_name = "XIE2TRACKING_PRSNL"
  SET tmp->qual[214].drop_ind = - (1)
  SET tmp->qual[215].index_name = "XIE1TRACKING_PRSNL_REF"
  SET tmp->qual[215].drop_ind = - (1)
  SET tmp->qual[216].index_name = "XIE1TRACK_COMP_PREFS"
  SET tmp->qual[216].drop_ind = - (1)
  SET tmp->qual[217].index_name = "XIE1TRACK_TRIGGER_ACTIVITY"
  SET tmp->qual[217].drop_ind = - (1)
  SET tmp->qual[218].index_name = "XIF002TRANS_CORSP_RELTN"
  SET tmp->qual[218].drop_ind = - (1)
  SET tmp->qual[219].index_name = "XIF75TRANS_TRANS_RELTN"
  SET tmp->qual[219].drop_ind = - (1)
  SET tmp->qual[220].index_name = "XIE1VENDOR_PRICE_SCHEDULE"
  SET tmp->qual[220].drop_ind = - (1)
  SET tmp->qual[221].index_name = "XIE1VENDOR_SITE"
  SET tmp->qual[221].drop_ind = - (1)
  SET tmp->qual[222].index_name = "XIE2VIEW_PREFS"
  SET tmp->qual[222].drop_ind = - (1)
  SET tmp->qual[223].index_name = "XIE2WORKLIST_REF"
  SET tmp->qual[223].drop_ind = - (1)
  SET tmp->qual[224].index_name = "XIFK7SURG_CASE_PROCEDURE"
  SET tmp->qual[224].drop_ind = - (1)
  SET tmp->qual[225].index_name = "XAK_MODEM_POOL"
  SET tmp->qual[225].drop_ind = - (1)
  SET tmp->qual[226].index_name = "XAK_MODEM_PORT"
  SET tmp->qual[226].drop_ind = - (1)
  SET tmp->qual[227].index_name = "XAK_PAGER_SERVICE"
  SET tmp->qual[227].drop_ind = - (1)
  SET tmp->qual[228].index_name = "XAK1ALIQUOTTED_PRIMER_KIT"
  SET tmp->qual[228].drop_ind = - (1)
  SET tmp->qual[229].index_name = "XAK1AP_DC_DISCREPANCY_TERM"
  SET tmp->qual[229].drop_ind = - (1)
  SET tmp->qual[230].index_name = "XAK1AP_DC_EVALUATION_TERM"
  SET tmp->qual[230].drop_ind = - (1)
  SET tmp->qual[231].index_name = "XAK1CREG"
  SET tmp->qual[231].drop_ind = - (1)
  SET tmp->qual[232].index_name = "XAK1HLA_SERA_QUERY"
  SET tmp->qual[232].drop_ind = - (1)
  SET tmp->qual[233].index_name = "XAK1MM_PROFILE"
  SET tmp->qual[233].drop_ind = - (1)
  SET tmp->qual[234].index_name = "XAK1MODIFY_OPTION"
  SET tmp->qual[234].drop_ind = - (1)
  SET tmp->qual[235].index_name = "XAK1RES_REVIEW_GROUP"
  SET tmp->qual[235].drop_ind = - (1)
  SET tmp->qual[236].index_name = "XAK1RES_REVIEW_HIERARCHY"
  SET tmp->qual[236].drop_ind = - (1)
  SET tmp->qual[237].index_name = "XAK1THERMOCYCLER_RACK"
  SET tmp->qual[237].drop_ind = - (1)
  SET tmp->qual[238].index_name = "XAK1THERMOCYCLER_RACK_TYPE"
  SET tmp->qual[238].drop_ind = - (1)
  SET tmp->qual[239].index_name = "XIE1SCR_PHRASE"
  SET tmp->qual[239].drop_ind = - (1)
  SET tmp->qual[240].index_name = "XAK1TEMPORARY_EXAM"
  SET tmp->qual[240].drop_ind = - (1)
  SET tmp->qual[241].index_name = "XIE2CHARGE"
  SET tmp->qual[241].drop_ind = - (1)
  SET tmp->qual[242].index_name = "XIE2SCH_BOOKING"
  SET tmp->qual[242].drop_ind = - (1)
  SET tmp->qual[243].index_name = "XPK_EXPLORER_SECURITY_GROUP"
  SET tmp->qual[243].drop_ind = - (1)
  SET tmp->qual[244].index_name = "XIE3PC_REF_SOURCE"
  SET tmp->qual[244].drop_ind = - (1)
  SET tmp->qual[245].index_name = "XAK2SCH_TEXT_LINK"
  SET tmp->qual[245].drop_ind = - (1)
  SET tmp->qual[246].index_name = "XIE2SCH_TEXT_LINK"
  SET tmp->qual[246].drop_ind = - (1)
  SET tmp->qual[247].index_name = "XIE3SCH_TEXT_LINK"
  SET tmp->qual[247].drop_ind = - (1)
  SET tmp->qual[248].index_name = "XIE5SCH_TEXT_LINK"
  SET tmp->qual[248].drop_ind = - (1)
  SET tmp->qual[249].index_name = "XIE6SCH_TEXT_LINK"
  SET tmp->qual[249].drop_ind = - (1)
  SET tmp->qual[250].index_name = "XIE7SCH_TEXT_LINK"
  SET tmp->qual[250].drop_ind = - (1)
  SET tmp->qual[251].index_name = "XIE4PC_REF_SOURCE"
  SET tmp->qual[251].drop_ind = - (1)
  SET tmp->qual[252].index_name = "XIE5PC_REF_SOURCE"
  SET tmp->qual[252].drop_ind = - (1)
  SET tmp->qual[253].index_name = "XIE4SCH_TEXT_LINK"
  SET tmp->qual[253].drop_ind = - (1)
  SET tmp->qual[254].index_name = "XIE1PHYS_COUNT_SHEET_ITEM"
  SET tmp->qual[254].drop_ind = - (1)
  SET tmp->qual[255].index_name = "XAK2SCH_LIST_ROLE"
  SET tmp->qual[255].drop_ind = - (1)
  SET tmp->qual[256].index_name = "XIE1SCH_NOTIFY"
  SET tmp->qual[256].drop_ind = - (1)
  SET tmp->qual[257].index_name = "XIE2SCH_NOTIFY"
  SET tmp->qual[257].drop_ind = - (1)
  SET tmp->qual[258].index_name = "XAK1OEN_TX_STATS_LOG"
  SET tmp->qual[258].drop_ind = - (1)
  SET tmp->qual[259].index_name = "XAK2OEN_TX_STATS_LOG"
  SET tmp->qual[259].drop_ind = - (1)
  SET tmp->qual[260].index_name = "XIE2SCH_ACTION_LOC"
  SET tmp->qual[260].drop_ind = - (1)
  SET tmp->qual[261].index_name = "XIE3ENCOUNTER"
  SET tmp->qual[261].drop_ind = - (1)
  SET tmp->qual[262].index_name = "XAK1CODE_DOMAIN_FILTER"
  SET tmp->qual[262].drop_ind = - (1)
  SET tmp->qual[263].index_name = "XAK1SCH_SUB_TEXT"
  SET tmp->qual[263].drop_ind = - (1)
  SET tmp->qual[264].index_name = "XAK1CODE_VALUE_GROUP"
  SET tmp->qual[264].drop_ind = - (1)
  SET tmp->qual[265].index_name = "XIE1DM_PLAN"
  SET tmp->qual[265].drop_ind = - (1)
  SET tmp->qual[266].index_name = "XAK1PHA_TRANSFER_ACTION"
  SET tmp->qual[266].drop_ind = - (1)
  SET tmp->qual[267].index_name = "XIE1PHYS_COUNT_SHEET_ITEM"
  SET tmp->qual[267].drop_ind = - (1)
  SET tmp->qual[268].index_name = "XIF27STRT_MODEL_ASSAY_ALPHA_RE"
  SET tmp->qual[268].drop_ind = - (1)
  SET tmp->qual[269].index_name = "XIE1TASK_ACCESS"
  SET tmp->qual[269].drop_ind = - (1)
  SET tmp->qual[270].index_name = "XIE2ROBOTICS_LOG_EVENTS"
  SET tmp->qual[270].drop_ind = - (1)
  SET tmp->qual[271].index_name = "XIE1PREFDIR_DESCENDANT"
  SET tmp->qual[271].drop_ind = - (1)
  SET tmp->qual[272].index_name = "FTSORDER_PRODUCT"
  SET tmp->qual[272].drop_ind = - (1)
  SET tmp->qual[273].index_name = "XIF257APPLICATION_TASK_R"
  SET tmp->qual[273].drop_ind = - (1)
  SET tmp->qual[274].index_name = "XF1IQH_OLAP_SPON_POP_RELTN"
  SET tmp->qual[274].drop_ind = - (1)
  SET tmp->qual[275].index_name = "XF3IQH_OLAP_SUMMARY_FACT"
  SET tmp->qual[275].drop_ind = - (1)
  SET tmp->qual[276].index_name = "AK1OMF_ICD9_DIAGNOSIS_ST"
  SET tmp->qual[276].drop_ind = - (1)
  SET tmp->qual[277].index_name = "AK1OMF_ICD9_PROCEDURE_ST"
  SET tmp->qual[277].drop_ind = - (1)
  SET tmp->qual[278].index_name = "AK1OMF_ICD9_DIAGNOSIS_ST"
  SET tmp->qual[278].drop_ind = - (1)
  SET tmp->qual[279].index_name = "AK1OMF_ICD9_PROCEDURE_ST"
  SET tmp->qual[279].drop_ind = - (1)
  SET tmp->qual[280].index_name = "XIE1SEGMENT_LIST_DEFINITION"
  SET tmp->qual[280].drop_ind = - (1)
  SET tmp->qual[281].index_name = "XIE1SEGMENT_LIST_REFERENCE"
  SET tmp->qual[281].drop_ind = - (1)
  SET tmp->qual[282].index_name = "XIE1SN_REPORT_GROUP"
  SET tmp->qual[282].drop_ind = - (1)
  SELECT INTO "nl:"
   p.version, p.product
   FROM product_component_version p
   WHERE cnvtupper(p.product)="ORACLE*"
   DETAIL
    IF (cnvtupper(substring(1,7,p.product))="ORACLE7")
     ora_info->ora_version = 7
    ELSEIF (cnvtupper(substring(1,7,p.product))="ORACLE8")
     ora_info->ora_version = 8
    ENDIF
    ora_info->ora_complete_version = p.version
   WITH nocounter
  ;end select
  CALL echo(concat("Oracle Version:",ora_info->ora_complete_version))
  IF ((ora_info->ora_version=7))
   FOR (yy = 1 TO recordcnt)
     SET tmp->qual[yy].drop_ind = - (2)
   ENDFOR
   SET droptotal = recordcnt
  ELSE
   FOR (xx = 1 TO 50)
    SET droptotal = 0
    FOR (yy = 1 TO recordcnt)
      IF ((tmp->qual[yy].drop_ind != 1))
       SET tmpstr = concat("Execution ",trim(cnvtstring(xx),3)," of 50")
       CALL echo(tmpstr)
       SET tmpstr = concat("   Record ",trim(cnvtstring(yy),3)," of ",trim(cnvtstring(recordcnt),3))
       CALL echo(tmpstr)
       SET parse_str = concat("execute dm_drop_obsolete_objects '",tmp->qual[yy].index_name,
        "','INDEX',1 go")
       CALL echo(parse_str)
       CALL parser(parse_str)
       IF (errcode=0)
        SET tmp->qual[yy].drop_ind = 1
        SELECT INTO "nl:"
         u.index_name
         FROM user_indexes u
         WHERE (u.index_name=tmp->qual[yy].index_name)
         DETAIL
          tmp->qual[yy].drop_ind = - (1)
         WITH nocounter
        ;end select
       ELSE
        SET tmp->qual[yy].err_code = errcode
        SET tmp->qual[yy].err_msg = errmsg
       ENDIF
      ELSE
       SET droptotal = (droptotal+ 1)
      ENDIF
    ENDFOR
   ENDFOR
  ENDIF
  IF (droptotal != recordcnt)
   SET readme_data->message = build(errmsg,"- Readme FAILURE. Check dm_obsolete_indexes_80.log")
   SET readme_data->status = "F"
  ELSE
   SET readme_data->message = build(errmsg,"- Readme SUCCESS. Check dm_obsolete_indexes_80.log")
   SET readme_data->status = "S"
  ENDIF
  CALL echo(readme_data->message)
  SELECT INTO "dm_obsolete_indexes_80.log"
   d.seq
   FROM dummyt d
   FOOT REPORT
    "***********************************************************************", row + 1
    IF (droptotal=recordcnt)
     "  TRACE LOG - DM_DROP_OBSOLETE_indexes_80: SUCCESS"
    ELSE
     "  TRACE LOG - DM_DROP_OBSOLETE_indexes_80: FAILURE"
    ENDIF
    row + 1, "  ORACLE VERSION: ", ora_info->ora_complete_version,
    row + 1, "***********************************************************************", row + 2
    IF ((ora_info->ora_version=7))
     "Obsolete index logic skipped since Oracle version is NOT 8i."
    ELSE
     "++++++++++ SUCCESSFUL DROPS +++++++", row + 2
     FOR (yy = 1 TO recordcnt)
      col 5,
      IF ((tmp->qual[yy].drop_ind=1))
       successcnt = (successcnt+ 1), tmpstr = trim(cnvtstring(successcnt),3), tmpstr,
       col 5, tmpstr = concat(tmp->qual[yy].index_name,":  SUCCESS "), tmpstr,
       row + 1
      ENDIF
     ENDFOR
     row + 2, "++++++++++ FAILED DROPS +++++++", row + 2
     FOR (yy = 1 TO recordcnt)
      col 5,
      IF ((tmp->qual[yy].drop_ind=- (1)))
       failedcnt = (failedcnt+ 1), tmpstr = trim(cnvtstring(failedcnt),3), tmpstr,
       col 5, tmpstr = concat(tmp->qual[yy].index_name,":  FAILED"), tmpstr,
       row + 1, col 5, tmpstr = concat("ERROR: ",trim(cnvtstring(tmp->qual[yy].err_code),3)," ",tmp->
        qual[yy].err_msg),
       tmpstr, row + 1
      ENDIF
     ENDFOR
     row + 2
    ENDIF
   WITH nocounter, format = variable, formfeed = none,
    maxrow = 1, maxcol = 1000
  ;end select
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success, obsolete tables 8.0 only for Oracle"
 ENDIF
#end_program
 EXECUTE dm_readme_status
 IF (currdb="ORACLE")
  FREE RECORD tmp
  FREE RECORD ora_info
 ENDIF
END GO
