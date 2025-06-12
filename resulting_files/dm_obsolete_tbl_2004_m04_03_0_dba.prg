CREATE PROGRAM dm_obsolete_tbl_2004_m04_03_0:dba
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
 SET readme_data->status = "F"
 IF (currdb="ORACLE")
  DECLARE tmpstr = vc
  DECLARE droptotal = i4
  DECLARE xx = i4
  DECLARE yy = i4
  DECLARE parse_str = vc
  DECLARE failedcnt = i4
  DECLARE successcnt = i4
  DECLARE recordcnt = i4
  SET recordcnt = 241
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  SET droptotal = 0
  SET xx = 0
  SET yy = 0
  SET failedcnt = 0
  SET successcnt = 0
  RECORD tmp(
    1 qual[*]
      2 table_name = vc
      2 drop_ind = i2
      2 err_code = i4
      2 err_msg = vc
  )
  SET stat = alterlist(tmp->qual,recordcnt)
  SET tmp->qual[1].table_name = "ESI_ENCNTR_PRSNL"
  SET tmp->qual[1].drop_ind = - (1)
  SET tmp->qual[2].table_name = "FILTER_INI"
  SET tmp->qual[2].drop_ind = - (1)
  SET tmp->qual[3].table_name = "WORKLOAD_ALPHAS"
  SET tmp->qual[3].drop_ind = - (1)
  SET tmp->qual[4].table_name = "WORKLOAD_CANCEL"
  SET tmp->qual[4].drop_ind = - (1)
  SET tmp->qual[5].table_name = "WORKLOAD_ORDERABLES"
  SET tmp->qual[5].drop_ind = - (1)
  SET tmp->qual[6].table_name = "ROBOTICS_LOGIN_LOC_R"
  SET tmp->qual[6].drop_ind = - (1)
  SET tmp->qual[7].table_name = "ROBOTICS_PARAMETERS"
  SET tmp->qual[7].drop_ind = - (1)
  SET tmp->qual[8].table_name = "CV_REGISTRY_EVENT"
  SET tmp->qual[8].drop_ind = - (1)
  SET tmp->qual[9].table_name = "CQM_FSIESO_LOG"
  SET tmp->qual[9].drop_ind = - (1)
  SET tmp->qual[10].table_name = "CQM_FSIESO_PAR"
  SET tmp->qual[10].drop_ind = - (1)
  SET tmp->qual[11].table_name = "OEN_FILE_STATUS"
  SET tmp->qual[11].drop_ind = - (1)
  SET tmp->qual[12].table_name = "OEN_OBJ_LIB"
  SET tmp->qual[12].drop_ind = - (1)
  SET tmp->qual[13].table_name = "PAT_ED_ACTIVITY"
  SET tmp->qual[13].drop_ind = - (1)
  SET tmp->qual[14].table_name = "TRACKING_PREF_REL"
  SET tmp->qual[14].drop_ind = - (1)
  SET tmp->qual[15].table_name = "REQUEST_EVENT"
  SET tmp->qual[15].drop_ind = - (1)
  SET tmp->qual[16].table_name = "CQM_STDBATCH_QUE"
  SET tmp->qual[16].drop_ind = - (1)
  SET tmp->qual[17].table_name = "CQM_STDBATCH_TR_1"
  SET tmp->qual[17].drop_ind = - (1)
  SET tmp->qual[18].table_name = "BLOT_ALLELE_PTRN_MATCH"
  SET tmp->qual[18].drop_ind = - (1)
  SET tmp->qual[19].table_name = "BLOT_SPEC_PTRN_MATCH"
  SET tmp->qual[19].drop_ind = - (1)
  SET tmp->qual[20].table_name = "ORDER_BLOT"
  SET tmp->qual[20].drop_ind = - (1)
  SET tmp->qual[21].table_name = "ACCT_PRSNL_EXCL"
  SET tmp->qual[21].drop_ind = - (1)
  SET tmp->qual[22].table_name = "ACCT_PRSNL_RELTN"
  SET tmp->qual[22].drop_ind = - (1)
  SET tmp->qual[23].table_name = "AT_GROUP_RELTN"
  SET tmp->qual[23].drop_ind = - (1)
  SET tmp->qual[24].table_name = "BE_FINCHRG_RELTN"
  SET tmp->qual[24].drop_ind = - (1)
  SET tmp->qual[25].table_name = "BT_CRITERIA_LIMIT"
  SET tmp->qual[25].drop_ind = - (1)
  SET tmp->qual[26].table_name = "PFT_PRORATE_EXCLUDE"
  SET tmp->qual[26].drop_ind = - (1)
  SET tmp->qual[27].table_name = "CONCEPT_EXPLODE"
  SET tmp->qual[27].drop_ind = - (1)
  SET tmp->qual[28].table_name = "NOMEN_CAT_FLEX"
  SET tmp->qual[28].drop_ind = - (1)
  SET tmp->qual[29].table_name = "DMS_MEDIA_TAG"
  SET tmp->qual[29].drop_ind = - (1)
  SET tmp->qual[30].table_name = "EKS_AUDIT"
  SET tmp->qual[30].drop_ind = - (1)
  SET tmp->qual[31].table_name = "EKS_CONFIG"
  SET tmp->qual[31].drop_ind = - (1)
  SET tmp->qual[32].table_name = "EKS_MODULE_ARCH"
  SET tmp->qual[32].drop_ind = - (1)
  SET tmp->qual[33].table_name = "EKS_MODULESTORAGE_ARCH"
  SET tmp->qual[33].drop_ind = - (1)
  SET tmp->qual[34].table_name = "EKS_TEMPLATE_ARCH"
  SET tmp->qual[34].drop_ind = - (1)
  SET tmp->qual[35].table_name = "EKS_TEMPLATEPARAM_ARCH"
  SET tmp->qual[35].drop_ind = - (1)
  SET tmp->qual[36].table_name = "AUTH_AMB_DETAIL"
  SET tmp->qual[36].drop_ind = - (1)
  SET tmp->qual[37].table_name = "AUTH_ASSIGN_RELTN"
  SET tmp->qual[37].drop_ind = - (1)
  SET tmp->qual[38].table_name = "AUTH_COND_DETAIL"
  SET tmp->qual[38].drop_ind = - (1)
  SET tmp->qual[39].table_name = "AUTH_DELIVERY_DETAIL"
  SET tmp->qual[39].drop_ind = - (1)
  SET tmp->qual[40].table_name = "AUTH_DIAG_DETAIL"
  SET tmp->qual[40].drop_ind = - (1)
  SET tmp->qual[41].table_name = "AUTH_DOCUMENTATION"
  SET tmp->qual[41].drop_ind = - (1)
  SET tmp->qual[42].table_name = "AUTH_DT"
  SET tmp->qual[42].drop_ind = - (1)
  SET tmp->qual[43].table_name = "AUTH_HEALTH_DETAIL"
  SET tmp->qual[43].drop_ind = - (1)
  SET tmp->qual[44].table_name = "AUTH_OXYGEN_DETAIL"
  SET tmp->qual[44].drop_ind = - (1)
  SET tmp->qual[45].table_name = "AUTH_PROC_DETAIL"
  SET tmp->qual[45].drop_ind = - (1)
  SET tmp->qual[46].table_name = "AUTH_PRSNL_RELTN"
  SET tmp->qual[46].drop_ind = - (1)
  SET tmp->qual[47].table_name = "AUTH_SERVICE_DETAIL"
  SET tmp->qual[47].drop_ind = - (1)
  SET tmp->qual[48].table_name = "AUTH_SPINAL_DETAIL"
  SET tmp->qual[48].drop_ind = - (1)
  SET tmp->qual[49].table_name = "BENEFIT_AUTH"
  SET tmp->qual[49].drop_ind = - (1)
  SET tmp->qual[50].table_name = "EEM_EB_COMBO"
  SET tmp->qual[50].drop_ind = - (1)
  SET tmp->qual[51].table_name = "EEM_LABEL"
  SET tmp->qual[51].drop_ind = - (1)
  SET tmp->qual[52].table_name = "HEALTH_PLAN_COMBINE_DET"
  SET tmp->qual[52].drop_ind = - (1)
  SET tmp->qual[53].table_name = "HP_BNFT_SET"
  SET tmp->qual[53].drop_ind = - (1)
  SET tmp->qual[54].table_name = "OAF_BENEFIT"
  SET tmp->qual[54].drop_ind = - (1)
  SET tmp->qual[55].table_name = "PERSON_BNFT_SET_R"
  SET tmp->qual[55].drop_ind = - (1)
  SET tmp->qual[56].table_name = "PC_HOSPICE_MC_BFT"
  SET tmp->qual[56].drop_ind = - (1)
  SET tmp->qual[57].table_name = "PC_REF_PRSNL_ORG"
  SET tmp->qual[57].drop_ind = - (1)
  SET tmp->qual[58].table_name = "PC_REF_REQ_FIELD"
  SET tmp->qual[58].drop_ind = - (1)
  SET tmp->qual[59].table_name = "PC_REF_VIEW_MATCH"
  SET tmp->qual[59].drop_ind = - (1)
  SET tmp->qual[60].table_name = "ROI_REQUEST_CRITERIA"
  SET tmp->qual[60].drop_ind = - (1)
  SET tmp->qual[61].table_name = "TASK_PLAN"
  SET tmp->qual[61].drop_ind = - (1)
  SET tmp->qual[62].table_name = "TASK_PLAN_RELTN"
  SET tmp->qual[62].drop_ind = - (1)
  SET tmp->qual[63].table_name = "SCH_ACTION_REASON"
  SET tmp->qual[63].drop_ind = - (1)
  SET tmp->qual[64].table_name = "SCH_RES_LOC"
  SET tmp->qual[64].drop_ind = - (1)
  SET tmp->qual[65].table_name = "SCH_USER_TEXT"
  SET tmp->qual[65].drop_ind = - (1)
  SET tmp->qual[66].table_name = "SCD_PHRASE_TYPE"
  SET tmp->qual[66].drop_ind = - (1)
  SET tmp->qual[67].table_name = "HEA_ENV_ORG_RELTN"
  SET tmp->qual[67].drop_ind = - (1)
  SET tmp->qual[68].table_name = "OMF_ABS_DAYS"
  SET tmp->qual[68].drop_ind = - (1)
  SET tmp->qual[69].table_name = "OMF_GRID_GROUPING"
  SET tmp->qual[69].drop_ind = - (1)
  SET tmp->qual[70].table_name = "OMF_GRID_INDICATOR"
  SET tmp->qual[70].drop_ind = - (1)
  SET tmp->qual[71].table_name = "OMF_INDICATOR_GROUP"
  SET tmp->qual[71].drop_ind = - (1)
  SET tmp->qual[72].table_name = "OMF_INDICATOR_GROUPING"
  SET tmp->qual[72].drop_ind = - (1)
  SET tmp->qual[73].table_name = "OMF_PRODUCT_QUEUE"
  SET tmp->qual[73].drop_ind = - (1)
  SET tmp->qual[74].table_name = "OMF_TIME_BLOCK"
  SET tmp->qual[74].drop_ind = - (1)
  SET tmp->qual[75].table_name = "OMF_TIME_BLOCK_DTL"
  SET tmp->qual[75].drop_ind = - (1)
  SET tmp->qual[76].table_name = "BATCH_ERROR_REF"
  SET tmp->qual[76].drop_ind = - (1)
  SET tmp->qual[77].table_name = "BO_HP_RELTN_MOD"
  SET tmp->qual[77].drop_ind = - (1)
  SET tmp->qual[78].table_name = "PFT_EXPECTED_BATCH"
  SET tmp->qual[78].drop_ind = - (1)
  SET tmp->qual[79].table_name = "PFT_EXPECTED_DETAIL"
  SET tmp->qual[79].drop_ind = - (1)
  SET tmp->qual[80].table_name = "PFT_TAG"
  SET tmp->qual[80].drop_ind = - (1)
  SET tmp->qual[81].table_name = "OMF_PV_DATA_ST"
  SET tmp->qual[81].drop_ind = - (1)
  SET tmp->qual[82].table_name = "CHART_TEMP2"
  SET tmp->qual[82].drop_ind = - (1)
  SET tmp->qual[83].table_name = "DEFAULT_FLOWSHEET"
  SET tmp->qual[83].drop_ind = - (1)
  SET tmp->qual[84].table_name = "FLOWSHEET"
  SET tmp->qual[84].drop_ind = - (1)
  SET tmp->qual[85].table_name = "CQM_FSIOCC_PAR"
  SET tmp->qual[85].drop_ind = - (1)
  SET tmp->qual[86].table_name = "PROCINFO_SYSTEM_R"
  SET tmp->qual[86].drop_ind = - (1)
  SET tmp->qual[87].table_name = "CN_TASK"
  SET tmp->qual[87].drop_ind = - (1)
  SET tmp->qual[88].table_name = "MLTM_NDC_ACTIVE_INGRED_LIST"
  SET tmp->qual[88].drop_ind = - (1)
  SET tmp->qual[89].table_name = "TRACK_EVENT_POSITION"
  SET tmp->qual[89].drop_ind = - (1)
  SET tmp->qual[90].table_name = "TRANSMISSION_LOG"
  SET tmp->qual[90].drop_ind = - (1)
  SET tmp->qual[91].table_name = "INPUT_FIELD_DEFINITION"
  SET tmp->qual[91].drop_ind = - (1)
  SET tmp->qual[92].table_name = "PREF_CARD_SURGEON_COMMENT"
  SET tmp->qual[92].drop_ind = - (1)
  SET tmp->qual[93].table_name = "PREFERENCE_CARD_DEFAULT"
  SET tmp->qual[93].drop_ind = - (1)
  SET tmp->qual[94].table_name = "SN_GAPCHECK"
  SET tmp->qual[94].drop_ind = - (1)
  SET tmp->qual[95].table_name = "SN_GAPCHECK_RULES"
  SET tmp->qual[95].drop_ind = - (1)
  SET tmp->qual[96].table_name = "SURG_PRINT_DETAILS"
  SET tmp->qual[96].drop_ind = - (1)
  SET tmp->qual[97].table_name = "SURGICAL_TEAM_MEMBER"
  SET tmp->qual[97].drop_ind = - (1)
  SET tmp->qual[98].table_name = "MODULE"
  SET tmp->qual[98].drop_ind = - (1)
  SET tmp->qual[99].table_name = "AP_PREFIX_SPEC_PROTOCOL"
  SET tmp->qual[99].drop_ind = - (1)
  SET tmp->qual[100].table_name = "ALIQUOT_TRIGGER"
  SET tmp->qual[100].drop_ind = - (1)
  SET tmp->qual[101].table_name = "UPLOAD_REPORT"
  SET tmp->qual[101].drop_ind = - (1)
  SET tmp->qual[102].table_name = "UPLOAD_USER"
  SET tmp->qual[102].drop_ind = - (1)
  SET tmp->qual[103].table_name = "HLA_TYP_TRAY_LOCI"
  SET tmp->qual[103].drop_ind = - (1)
  SET tmp->qual[104].table_name = "HLA_TYP_TRAY_RESULT"
  SET tmp->qual[104].drop_ind = - (1)
  SET tmp->qual[105].table_name = "PARENTAL_HAPLOTYPE"
  SET tmp->qual[105].drop_ind = - (1)
  SET tmp->qual[106].table_name = "PARENTAL_LOCI"
  SET tmp->qual[106].drop_ind = - (1)
  SET tmp->qual[107].table_name = "PARENTAL_LOCI_DEFAULT"
  SET tmp->qual[107].drop_ind = - (1)
  SET tmp->qual[108].table_name = "MIC_ERR_RECOVER"
  SET tmp->qual[108].drop_ind = - (1)
  SET tmp->qual[109].table_name = "CSM_CONTACT"
  SET tmp->qual[109].drop_ind = - (1)
  SET tmp->qual[110].table_name = "OSM_CHART_REQUEST"
  SET tmp->qual[110].drop_ind = - (1)
  SET tmp->qual[111].table_name = "PROP_QUEUE"
  SET tmp->qual[111].drop_ind = - (1)
  SET tmp->qual[112].table_name = "RESOURCE_ROUTE"
  SET tmp->qual[112].drop_ind = - (1)
  SET tmp->qual[113].table_name = "ROUTE_CODE_RESOURCE_LIST"
  SET tmp->qual[113].drop_ind = - (1)
  SET tmp->qual[114].table_name = "EKS_AOI"
  SET tmp->qual[114].drop_ind = - (1)
  SET tmp->qual[115].table_name = "EKS_DATA_TEMPLATE"
  SET tmp->qual[115].drop_ind = - (1)
  SET tmp->qual[116].table_name = "EKS_DATA_TEMPLATE_R"
  SET tmp->qual[116].drop_ind = - (1)
  SET tmp->qual[117].table_name = "EKS_DATA_TEMPLATE_REC"
  SET tmp->qual[117].drop_ind = - (1)
  SET tmp->qual[118].table_name = "EKS_EKM_TRUE"
  SET tmp->qual[118].drop_ind = - (1)
  SET tmp->qual[119].table_name = "EKS_RECOVERY"
  SET tmp->qual[119].drop_ind = - (1)
  SET tmp->qual[120].table_name = "EKS_RECOVERY_MODULE"
  SET tmp->qual[120].drop_ind = - (1)
  SET tmp->qual[121].table_name = "EKS_RECOVERY_REQUEST"
  SET tmp->qual[121].drop_ind = - (1)
  SET tmp->qual[122].table_name = "EKS_TEMPLATE_VALIDATE"
  SET tmp->qual[122].drop_ind = - (1)
  SET tmp->qual[123].table_name = "HP_BNFT_INFO"
  SET tmp->qual[123].drop_ind = - (1)
  SET tmp->qual[124].table_name = "HP_BNFT_R"
  SET tmp->qual[124].drop_ind = - (1)
  SET tmp->qual[125].table_name = "HP_PROC_BNFT"
  SET tmp->qual[125].drop_ind = - (1)
  SET tmp->qual[126].table_name = "HP_PRSNL_R"
  SET tmp->qual[126].drop_ind = - (1)
  SET tmp->qual[127].table_name = "HP_SOFT_BNFT"
  SET tmp->qual[127].drop_ind = - (1)
  SET tmp->qual[128].table_name = "HP_SOFT_BNFT_ALIAS"
  SET tmp->qual[128].drop_ind = - (1)
  SET tmp->qual[129].table_name = "ACKNOWLEDGMENT"
  SET tmp->qual[129].drop_ind = - (1)
  SET tmp->qual[130].table_name = "AUTHORIZE"
  SET tmp->qual[130].drop_ind = - (1)
  SET tmp->qual[131].table_name = "COMMENT_ENTRY"
  SET tmp->qual[131].drop_ind = - (1)
  SET tmp->qual[132].table_name = "FAILURE"
  SET tmp->qual[132].drop_ind = - (1)
  SET tmp->qual[133].table_name = "INV_TRANS_GL"
  SET tmp->qual[133].drop_ind = - (1)
  SET tmp->qual[134].table_name = "INV_TRANS_LOG"
  SET tmp->qual[134].drop_ind = - (1)
  SET tmp->qual[135].table_name = "INV_TRANS_LOT_INFO"
  SET tmp->qual[135].drop_ind = - (1)
  SET tmp->qual[136].table_name = "LABOR_COST"
  SET tmp->qual[136].drop_ind = - (1)
  SET tmp->qual[137].table_name = "LINE_ITEM_MANIFEST_R"
  SET tmp->qual[137].drop_ind = - (1)
  SET tmp->qual[138].table_name = "MANIFEST"
  SET tmp->qual[138].drop_ind = - (1)
  SET tmp->qual[139].table_name = "PART_COST"
  SET tmp->qual[139].drop_ind = - (1)
  SET tmp->qual[140].table_name = "PHASED_INVOICE"
  SET tmp->qual[140].drop_ind = - (1)
  SET tmp->qual[141].table_name = "PM_PROCEDURE"
  SET tmp->qual[141].drop_ind = - (1)
  SET tmp->qual[142].table_name = "PREVENTIVE_MAINTENANCE"
  SET tmp->qual[142].drop_ind = - (1)
  SET tmp->qual[143].table_name = "REQ_PO_TEMPLATE"
  SET tmp->qual[143].drop_ind = - (1)
  SET tmp->qual[144].table_name = "SERVICE_GROUP"
  SET tmp->qual[144].drop_ind = - (1)
  SET tmp->qual[145].table_name = "TEXT_LINE_ITEM"
  SET tmp->qual[145].drop_ind = - (1)
  SET tmp->qual[146].table_name = "VENDOR_SERVICE_REQUEST_INFO"
  SET tmp->qual[146].drop_ind = - (1)
  SET tmp->qual[147].table_name = "PC_REF_SOURCE"
  SET tmp->qual[147].drop_ind = - (1)
  SET tmp->qual[148].table_name = "DIAG_EPISODE_RELTN"
  SET tmp->qual[148].drop_ind = - (1)
  SET tmp->qual[149].table_name = "DM_OBS_WORKING_VIEW_PI"
  SET tmp->qual[149].drop_ind = - (1)
  SET tmp->qual[150].table_name = "AUTH_DET"
  SET tmp->qual[150].drop_ind = - (1)
  SET tmp->qual[151].table_name = "BAM_SPLIT"
  SET tmp->qual[151].drop_ind = - (1)
  SET tmp->qual[152].table_name = "DM_OCD_TEST"
  SET tmp->qual[152].drop_ind = - (1)
  SET tmp->qual[153].table_name = "DM_OCD_TEST_CHILD"
  SET tmp->qual[153].drop_ind = - (1)
  SET tmp->qual[154].table_name = "NOMEN_DUP_HOLD"
  SET tmp->qual[154].drop_ind = - (1)
  SET tmp->qual[155].table_name = "OAF_BENEFIT_DETAIL"
  SET tmp->qual[155].drop_ind = - (1)
  SET tmp->qual[156].table_name = "OASIS_AUTO_ANSWERS"
  SET tmp->qual[156].drop_ind = - (1)
  SET tmp->qual[157].table_name = "OASIS_DATA"
  SET tmp->qual[157].drop_ind = - (1)
  SET tmp->qual[158].table_name = "OASIS_DATA_SET"
  SET tmp->qual[158].drop_ind = - (1)
  SET tmp->qual[159].table_name = "OASIS_DETAIL"
  SET tmp->qual[159].drop_ind = - (1)
  SET tmp->qual[160].table_name = "OASIS_EXTRACTION_SET"
  SET tmp->qual[160].drop_ind = - (1)
  SET tmp->qual[161].table_name = "OASIS_EXT_ENCNTR_CD"
  SET tmp->qual[161].drop_ind = - (1)
  SET tmp->qual[162].table_name = "OASIS_PROMPT"
  SET tmp->qual[162].drop_ind = - (1)
  SET tmp->qual[163].table_name = "OASIS_RECORD_SET"
  SET tmp->qual[163].drop_ind = - (1)
  SET tmp->qual[164].table_name = "OASIS_SKIP_RULE"
  SET tmp->qual[164].drop_ind = - (1)
  SET tmp->qual[165].table_name = "OASIS_XREF"
  SET tmp->qual[165].drop_ind = - (1)
  SET tmp->qual[166].table_name = "ODS_OPR_RELTN"
  SET tmp->qual[166].drop_ind = - (1)
  SET tmp->qual[167].table_name = "ODS_OXR_RELTN"
  SET tmp->qual[167].drop_ind = - (1)
  SET tmp->qual[168].table_name = "OMF_APP_GRID_R"
  SET tmp->qual[168].drop_ind = - (1)
  SET tmp->qual[169].table_name = "PC_485_OTHER"
  SET tmp->qual[169].drop_ind = - (1)
  SET tmp->qual[170].table_name = "PC_ACTIVITIES_PERMITTED"
  SET tmp->qual[170].drop_ind = - (1)
  SET tmp->qual[171].table_name = "PC_ADMISSION_ST"
  SET tmp->qual[171].drop_ind = - (1)
  SET tmp->qual[172].table_name = "PC_ADVANCE_DIRECTIVE"
  SET tmp->qual[172].drop_ind = - (1)
  SET tmp->qual[173].table_name = "PC_CLIENT_STATS_ST"
  SET tmp->qual[173].drop_ind = - (1)
  SET tmp->qual[174].table_name = "PC_DIET"
  SET tmp->qual[174].drop_ind = - (1)
  SET tmp->qual[175].table_name = "PC_DO_NOT_MATCH"
  SET tmp->qual[175].drop_ind = - (1)
  SET tmp->qual[176].table_name = "PC_ENCNTR_CONTACT_RELTN"
  SET tmp->qual[176].drop_ind = - (1)
  SET tmp->qual[177].table_name = "PC_FORM_DETAIL"
  SET tmp->qual[177].drop_ind = - (1)
  SET tmp->qual[178].table_name = "PC_FUNCTIONAL_LIMITATION"
  SET tmp->qual[178].drop_ind = - (1)
  SET tmp->qual[179].table_name = "PC_GEOG_CHOICES"
  SET tmp->qual[179].drop_ind = - (1)
  SET tmp->qual[180].table_name = "PC_GEOG_COVERAGE"
  SET tmp->qual[180].drop_ind = - (1)
  SET tmp->qual[181].table_name = "PC_HCFA_485"
  SET tmp->qual[181].drop_ind = - (1)
  SET tmp->qual[182].table_name = "PC_HISTORY"
  SET tmp->qual[182].drop_ind = - (1)
  SET tmp->qual[183].table_name = "PC_IO_SECTION_DETAIL"
  SET tmp->qual[183].drop_ind = - (1)
  SET tmp->qual[184].table_name = "PC_LOC_ENC_333_RELTN"
  SET tmp->qual[184].drop_ind = - (1)
  SET tmp->qual[185].table_name = "PC_MED_LIST"
  SET tmp->qual[185].drop_ind = - (1)
  SET tmp->qual[186].table_name = "PC_MENTAL_STATUS"
  SET tmp->qual[186].drop_ind = - (1)
  SET tmp->qual[187].table_name = "PC_NOTE_COMMENT"
  SET tmp->qual[187].drop_ind = - (1)
  SET tmp->qual[188].table_name = "PC_NOTE_ORDER_RELTN"
  SET tmp->qual[188].drop_ind = - (1)
  SET tmp->qual[189].table_name = "PC_NOTE_SECTION"
  SET tmp->qual[189].drop_ind = - (1)
  SET tmp->qual[190].table_name = "PC_PRSNL_INFO"
  SET tmp->qual[190].drop_ind = - (1)
  SET tmp->qual[191].table_name = "PC_REC_PATTERN"
  SET tmp->qual[191].drop_ind = - (1)
  SET tmp->qual[192].table_name = "PC_REFERRAL_LIST"
  SET tmp->qual[192].drop_ind = - (1)
  SET tmp->qual[193].table_name = "PC_REFERRAL_ST"
  SET tmp->qual[193].drop_ind = - (1)
  SET tmp->qual[194].table_name = "PC_REF_FORM_ENCNTR"
  SET tmp->qual[194].drop_ind = - (1)
  SET tmp->qual[195].table_name = "PC_REF_SRC_XFER"
  SET tmp->qual[195].drop_ind = - (1)
  SET tmp->qual[196].table_name = "PC_REMINDERS_LIST"
  SET tmp->qual[196].drop_ind = - (1)
  SET tmp->qual[197].table_name = "PC_TEAM_ALTS_LIST"
  SET tmp->qual[197].drop_ind = - (1)
  SET tmp->qual[198].table_name = "PC_TIME_AVAILABILITY"
  SET tmp->qual[198].drop_ind = - (1)
  SET tmp->qual[199].table_name = "PC_TRANSFER_TO"
  SET tmp->qual[199].drop_ind = - (1)
  SET tmp->qual[200].table_name = "PC_VISIT_AUTH"
  SET tmp->qual[200].drop_ind = - (1)
  SET tmp->qual[201].table_name = "PC_VISIT_ORDER"
  SET tmp->qual[201].drop_ind = - (1)
  SET tmp->qual[202].table_name = "PC_VISIT_ORDER_RELTN"
  SET tmp->qual[202].drop_ind = - (1)
  SET tmp->qual[203].table_name = "PC_VISIT_SIGN"
  SET tmp->qual[203].drop_ind = - (1)
  SET tmp->qual[204].table_name = "PHA_ONETOMANY_1"
  SET tmp->qual[204].drop_ind = - (1)
  SET tmp->qual[205].table_name = "PHA_ONETOMANY_2"
  SET tmp->qual[205].drop_ind = - (1)
  SET tmp->qual[206].table_name = "PPS_CUR_ANSWER"
  SET tmp->qual[206].drop_ind = - (1)
  SET tmp->qual[207].table_name = "PPS_EPISODE"
  SET tmp->qual[207].drop_ind = - (1)
  SET tmp->qual[208].table_name = "PPS_HHRG"
  SET tmp->qual[208].drop_ind = - (1)
  SET tmp->qual[209].table_name = "PPS_LEVEL"
  SET tmp->qual[209].drop_ind = - (1)
  SET tmp->qual[210].table_name = "PPS_PARAMS"
  SET tmp->qual[210].drop_ind = - (1)
  SET tmp->qual[211].table_name = "PPS_SCORE_ITEM"
  SET tmp->qual[211].drop_ind = - (1)
  SET tmp->qual[212].table_name = "PPS_SCORE_LEVEL"
  SET tmp->qual[212].drop_ind = - (1)
  SET tmp->qual[213].table_name = "PPS_SCORE_LINE"
  SET tmp->qual[213].drop_ind = - (1)
  SET tmp->qual[214].table_name = "PPS_WAGE_INDEX"
  SET tmp->qual[214].drop_ind = - (1)
  SET tmp->qual[215].table_name = "OPF_ATTRIBUTE"
  SET tmp->qual[215].drop_ind = - (1)
  SET tmp->qual[216].table_name = "OPF_JOB"
  SET tmp->qual[216].drop_ind = - (1)
  SET tmp->qual[217].table_name = "OPF_JOB_TYPE"
  SET tmp->qual[217].drop_ind = - (1)
  SET tmp->qual[218].table_name = "OPF_NAME"
  SET tmp->qual[218].drop_ind = - (1)
  SET tmp->qual[219].table_name = "OPF_NAME_POOL"
  SET tmp->qual[219].drop_ind = - (1)
  SET tmp->qual[220].table_name = "OPF_NAME_POOL_RELTN"
  SET tmp->qual[220].drop_ind = - (1)
  SET tmp->qual[221].table_name = "OPF_PARAMETER"
  SET tmp->qual[221].drop_ind = - (1)
  SET tmp->qual[222].table_name = "OPF_WEIGHT"
  SET tmp->qual[222].drop_ind = - (1)
  SET tmp->qual[223].table_name = "DM_RETENTION_CRITERIA"
  SET tmp->qual[223].drop_ind = - (1)
  SET tmp->qual[224].table_name = "DM_ARCHIVE_LOG"
  SET tmp->qual[224].drop_ind = - (1)
  SET tmp->qual[225].table_name = "TASK_CRITERIA"
  SET tmp->qual[225].drop_ind = - (1)
  SET tmp->qual[226].table_name = "TASK_AVAILABLE"
  SET tmp->qual[226].drop_ind = - (1)
  SET tmp->qual[227].table_name = "PFT_SEL_TASK_R"
  SET tmp->qual[227].drop_ind = - (1)
  SET tmp->qual[228].table_name = "SELECTED_TASK"
  SET tmp->qual[228].drop_ind = - (1)
  SET tmp->qual[229].table_name = "SEL_TASK_PRSNL_R"
  SET tmp->qual[229].drop_ind = - (1)
  SET tmp->qual[230].table_name = "SCH_README"
  SET tmp->qual[230].drop_ind = - (1)
  SET tmp->qual[231].table_name = "SCH_README_ACTION"
  SET tmp->qual[231].drop_ind = - (1)
  SET tmp->qual[232].table_name = "LAB_MDI_CONTACT"
  SET tmp->qual[232].drop_ind = - (1)
  SET tmp->qual[233].table_name = "POM_APP_CLASS_R"
  SET tmp->qual[233].drop_ind = - (1)
  SET tmp->qual[234].table_name = "POM_CLASS"
  SET tmp->qual[234].drop_ind = - (1)
  SET tmp->qual[235].table_name = "POM_COMMAND_PARM"
  SET tmp->qual[235].drop_ind = - (1)
  SET tmp->qual[236].table_name = "POM_ENUM"
  SET tmp->qual[236].drop_ind = - (1)
  SET tmp->qual[237].table_name = "POM_EXPRESSION"
  SET tmp->qual[237].drop_ind = - (1)
  SET tmp->qual[238].table_name = "POM_METHOD_RULE_R"
  SET tmp->qual[238].drop_ind = - (1)
  SET tmp->qual[239].table_name = "POM_PROP_CTRL_PROP_R"
  SET tmp->qual[239].drop_ind = - (1)
  SET tmp->qual[240].table_name = "POM_PROPERTY"
  SET tmp->qual[240].drop_ind = - (1)
  SET tmp->qual[241].table_name = "POM_METHOD"
  SET tmp->qual[241].drop_ind = - (1)
  FOR (xx = 1 TO 10)
   SET droptotal = 0
   FOR (yy = 1 TO recordcnt)
     IF ((tmp->qual[yy].drop_ind != 1))
      SET tmpstr = concat("Execution ",trim(cnvtstring(xx),3)," of 10")
      CALL echo(tmpstr)
      SET tmpstr = concat("   Record ",trim(cnvtstring(yy),3)," of ",trim(cnvtstring(recordcnt),3))
      CALL echo(tmpstr)
      SET parse_str = concat("execute dm_drop_obsolete_objects '",tmp->qual[yy].table_name,
       "','TABLE',1 go")
      CALL echo(parse_str)
      CALL parser(parse_str)
      IF (errcode=0)
       SET tmp->qual[yy].drop_ind = 1
       SELECT INTO "nl:"
        u.table_name
        FROM user_tables u
        WHERE (u.table_name=tmp->qual[yy].table_name)
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
  IF (droptotal != recordcnt)
   SET readme_data->message = build(errmsg,
    "- Readme FAILURE. Check dm_obsolete_tbl_2004_M04_03_0.log")
   SET readme_data->status = "F"
  ELSE
   SET readme_data->message = build(errmsg,
    "- Readme SUCCESS. Check dm_obsolete_tbl_2004_M04_03_0.log")
   SET readme_data->status = "S"
  ENDIF
  CALL echo(readme_data->message)
  SELECT INTO "dm_obsolete_tbl_2004_M04_03_0.log"
   d.seq
   FROM dummyt d
   FOOT REPORT
    "***********************************************************************", row + 1
    IF (droptotal=recordcnt)
     "  TRACE LOG - dm_obsolete_tbl_2004_M04_03_0: SUCCESS"
    ELSE
     "  TRACE LOG - dm_obsolete_tbl_2004_M04_03_0: FAILURE"
    ENDIF
    row + 1, "***********************************************************************", row + 1,
    row + 1, "++++++++++ SUCCESSFUL DROPS +++++++", row + 1,
    row + 1
    FOR (yy = 1 TO recordcnt)
      IF ((tmp->qual[yy].drop_ind=1))
       successcnt = (successcnt+ 1), tmpstr = trim(cnvtstring(successcnt),3), tmpstr,
       col 5, tmpstr = concat(tmp->qual[yy].table_name,":  SUCCESS "), tmpstr,
       row + 1
      ENDIF
    ENDFOR
    row + 1, row + 1, "++++++++++ FAILED DROPS +++++++",
    row + 1, row + 1
    FOR (yy = 1 TO recordcnt)
      IF ((tmp->qual[yy].drop_ind != 1))
       failedcnt = (failedcnt+ 1), tmpstr = trim(cnvtstring(failedcnt),3), tmpstr,
       col 5, tmpstr = concat(tmp->qual[yy].table_name,":  FAILED"), tmpstr,
       row + 1, col 5, tmpstr = concat("ERROR: ",trim(cnvtstring(tmp->qual[yy].err_code),3)," ",tmp->
        qual[yy].err_msg),
       tmpstr, row + 1
      ENDIF
    ENDFOR
    row + 1, row + 1
   WITH nocounter, format = variable, formfeed = none,
    maxrow = 1, maxcol = 1000
  ;end select
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success, obsolete tables 2004.M04.03.0 only for Oracle"
 ENDIF
#end_program
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
 IF (currdb="ORACLE")
  FREE RECORD tmp
 ENDIF
END GO
