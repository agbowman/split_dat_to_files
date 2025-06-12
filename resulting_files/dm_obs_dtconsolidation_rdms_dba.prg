CREATE PROGRAM dm_obs_dtconsolidation_rdms:dba
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
 SET readme_data->message = "Failed to execute obsolete process"
 SET ver_str = "OBS OBJ CONS RDM VER-019"
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   FROM dm_info
   WHERE info_domain="DATA MANAGEMENT"
    AND info_name=ver_str
  ;end select
  IF (curqual=0)
   DECLARE cnt = i4
   SET errmsg = fillstring(132," ")
   SET errcode = 0
   SET cnt = 0
   CALL echo("Running Obsolete Process on a list of Constraints, Indexes, Triggers, & Tables...")
   FREE RECORD tblnames
   RECORD tblnames(
     1 list[*]
       2 tblname = vc
   )
   FREE RECORD idxnames
   RECORD idxnames(
     1 list[*]
       2 idxname = vc
   )
   FREE RECORD connames
   RECORD connames(
     1 list[*]
       2 conname = vc
   )
   FREE RECORD trgnames
   RECORD trgnames(
     1 list[*]
       2 trgname = vc
   )
   SET stat = alterlist(tblnames->list,665)
   SET tblnames->list[1].tblname = "ACCT_PRSNL_EXCL"
   SET tblnames->list[2].tblname = "ACCT_PRSNL_RELTN"
   SET tblnames->list[3].tblname = "ACK_LINE_ITEM"
   SET tblnames->list[4].tblname = "ACKNOWLEDGMENT"
   SET tblnames->list[5].tblname = "ACQUIREMENT_PROPERTIES"
   SET tblnames->list[6].tblname = "ADDITIONAL_GL_TRANS_T"
   SET tblnames->list[7].tblname = "ALIQUOT_TRIGGER"
   SET tblnames->list[8].tblname = "ANESTHESIA_CHAT"
   SET tblnames->list[9].tblname = "ANESTHESIA_DOC_LAYOUT"
   SET tblnames->list[10].tblname = "ANESTHESIA_DOC_PANES"
   SET tblnames->list[11].tblname = "ANESTHESIA_MACRO_DEFINITION"
   SET tblnames->list[12].tblname = "ANESTHESIA_MACRO_REFERENCE"
   SET tblnames->list[13].tblname = "ANESTHESIA_MEDICATION"
   SET tblnames->list[14].tblname = "ANESTHESIA_PREFERENCES"
   SET tblnames->list[15].tblname = "ANESTHESIA_SYMBOLS"
   SET tblnames->list[16].tblname = "AP_PREFIX_SPEC_PROTOCOL"
   SET tblnames->list[17].tblname = "AT_GROUP_RELTN"
   SET tblnames->list[18].tblname = "AUTH_AMB_DETAIL"
   SET tblnames->list[19].tblname = "AUTH_ASSIGN_RELTN"
   SET tblnames->list[20].tblname = "AUTH_COND_DETAIL"
   SET tblnames->list[21].tblname = "AUTH_DELIVERY_DETAIL"
   SET tblnames->list[22].tblname = "AUTH_DET"
   SET tblnames->list[23].tblname = "AUTH_DIAG_DETAIL"
   SET tblnames->list[24].tblname = "AUTH_DOCUMENTATION"
   SET tblnames->list[25].tblname = "AUTH_DT"
   SET tblnames->list[26].tblname = "AUTH_HEALTH_DETAIL"
   SET tblnames->list[27].tblname = "AUTH_HP_R"
   SET tblnames->list[28].tblname = "AUTH_OXYGEN_DETAIL"
   SET tblnames->list[29].tblname = "AUTH_PROC_DETAIL"
   SET tblnames->list[30].tblname = "AUTH_PROCEDURE"
   SET tblnames->list[31].tblname = "AUTH_PRSNL"
   SET tblnames->list[32].tblname = "AUTH_PRSNL_R"
   SET tblnames->list[33].tblname = "AUTH_PRSNL_RELTN"
   SET tblnames->list[34].tblname = "AUTH_SERVICE_DETAIL"
   SET tblnames->list[35].tblname = "AUTH_SPINAL_DETAIL"
   SET tblnames->list[36].tblname = "AUTHORIZE"
   SET tblnames->list[37].tblname = "BAM_SPLIT"
   SET tblnames->list[38].tblname = "BATCH_ERROR_REF"
   SET tblnames->list[39].tblname = "BE_FINCHRG_RELTN"
   SET tblnames->list[40].tblname = "BE_GLI_RELTN"
   SET tblnames->list[41].tblname = "BENEFIT_AUTH"
   SET tblnames->list[42].tblname = "BLOT_ALLELE_PTRN_MATCH"
   SET tblnames->list[43].tblname = "BLOT_SPEC_PTRN_MATCH"
   SET tblnames->list[44].tblname = "BO_HP_RELTN_MOD"
   SET tblnames->list[45].tblname = "CASE_ATTENDANCE_TIMES"
   SET tblnames->list[46].tblname = "CASE_OVERVIEW"
   SET tblnames->list[47].tblname = "CC_CALL_LOG"
   SET tblnames->list[48].tblname = "CC_CALL_NOTE"
   SET tblnames->list[49].tblname = "CC_CALL_RESPONSE"
   SET tblnames->list[50].tblname = "CC_CALL_STATUS"
   SET tblnames->list[51].tblname = "CC_CONTACT"
   SET tblnames->list[52].tblname = "CC_NOTE_STORY"
   SET tblnames->list[53].tblname = "CC_PE_DETAIL"
   SET tblnames->list[54].tblname = "CC_PER_EXT"
   SET tblnames->list[55].tblname = "CC_RFC"
   SET tblnames->list[56].tblname = "CHART_REQ_PROVIDER"
   SET tblnames->list[57].tblname = "CHART_TEMP2"
   SET tblnames->list[58].tblname = "CN_TASK"
   SET tblnames->list[59].tblname = "COMMENT_ENTRY"
   SET tblnames->list[60].tblname = "CONCEPT_EXPLODE"
   SET tblnames->list[61].tblname = "CONTAINER_ASSAY"
   SET tblnames->list[62].tblname = "CONTRACT_CHANGE_T"
   SET tblnames->list[63].tblname = "COST_CHANGE_T"
   SET tblnames->list[64].tblname = "CPO_SECTION_R"
   SET tblnames->list[65].tblname = "CQM_FSIESO_LOG"
   SET tblnames->list[66].tblname = "CQM_FSIESO_PAR"
   SET tblnames->list[67].tblname = "CQM_FSIOCC_PAR"
   SET tblnames->list[68].tblname = "CSM_CONTACT"
   SET tblnames->list[69].tblname = "CV_REGISTRY_EVENT"
   SET tblnames->list[70].tblname = "DCP_CLINICAL_CATEGORY"
   SET tblnames->list[71].tblname = "DCP_PL"
   SET tblnames->list[72].tblname = "DCP_PL_PRIORITY"
   SET tblnames->list[73].tblname = "DEFAULT_FLOWSHEET"
   SET tblnames->list[74].tblname = "DELIVERY_TICKET"
   SET tblnames->list[75].tblname = "DIAG_EPISODE_RELTN"
   SET tblnames->list[76].tblname = "DIST_TCKT"
   SET tblnames->list[77].tblname = "DM_ARCHIVE_LOG"
   SET tblnames->list[78].tblname = "DM_FS_FILES"
   SET tblnames->list[79].tblname = "DM_FS_LOG"
   SET tblnames->list[80].tblname = "DM_FS_LOG_TEXT"
   SET tblnames->list[81].tblname = "DM_FS_PROCESS"
   SET tblnames->list[82].tblname = "DM_FS_TABLES"
   SET tblnames->list[83].tblname = "DM_HTML_LINK"
   SET tblnames->list[84].tblname = "DM_INVALID_TABLE_VALUE"
   SET tblnames->list[85].tblname = "DM_OBS_WORKING_VIEW_PI"
   SET tblnames->list[86].tblname = "DM_OCD_TEST"
   SET tblnames->list[87].tblname = "DM_OCD_TEST_CHILD"
   SET tblnames->list[88].tblname = "DM_RETENTION_CRITERIA"
   SET tblnames->list[89].tblname = "DM_SCRIPT_INFO"
   SET tblnames->list[90].tblname = "DM_TABLE_LIST"
   SET tblnames->list[91].tblname = "DMS_MEDIA_TAG"
   SET tblnames->list[92].tblname = "DVP_TEST"
   SET tblnames->list[93].tblname = "DYM_ERRORS"
   SET tblnames->list[94].tblname = "DYM_JUNK"
   SET tblnames->list[95].tblname = "DYM_JUNK2"
   SET tblnames->list[96].tblname = "EEM_EB_COMBO"
   SET tblnames->list[97].tblname = "EEM_LABEL"
   SET tblnames->list[98].tblname = "EKS_AOI"
   SET tblnames->list[99].tblname = "EKS_AUDIT"
   SET tblnames->list[100].tblname = "EKS_CONFIG"
   SET tblnames->list[101].tblname = "EKS_DATA_TEMPLATE"
   SET tblnames->list[102].tblname = "EKS_DATA_TEMPLATE_R"
   SET tblnames->list[103].tblname = "EKS_DATA_TEMPLATE_REC"
   SET tblnames->list[104].tblname = "EKS_EKM_TRUE"
   SET tblnames->list[105].tblname = "EKS_MODULE_ARCH"
   SET tblnames->list[106].tblname = "EKS_MODULESTORAGE_ARCH"
   SET tblnames->list[107].tblname = "EKS_RECOVERY"
   SET tblnames->list[108].tblname = "EKS_RECOVERY_MODULE"
   SET tblnames->list[109].tblname = "EKS_RECOVERY_REQUEST"
   SET tblnames->list[110].tblname = "EKS_TEMPLATE_ARCH"
   SET tblnames->list[111].tblname = "EKS_TEMPLATE_VALIDATE"
   SET tblnames->list[112].tblname = "EKS_TEMPLATEPARAM_ARCH"
   SET tblnames->list[113].tblname = "EQUIPMENT_INSTANCE"
   SET tblnames->list[114].tblname = "EQUIPMENT_LOCATION_T"
   SET tblnames->list[115].tblname = "ESI_ENCNTR_PRSNL"
   SET tblnames->list[116].tblname = "FAILURE"
   SET tblnames->list[117].tblname = "FILTER_INI"
   SET tblnames->list[118].tblname = "FINCHRG_CHRG_RELTN"
   SET tblnames->list[119].tblname = "FLOWSHEET"
   SET tblnames->list[120].tblname = "HEA_ENV_ORG_RELTN"
   SET tblnames->list[121].tblname = "HEALTH_PLAN_COMBINE_DET"
   SET tblnames->list[122].tblname = "HLA_TYP_TRAY_LOCI"
   SET tblnames->list[123].tblname = "HLA_TYP_TRAY_RESULT"
   SET tblnames->list[124].tblname = "HP_BNFT_INFO"
   SET tblnames->list[125].tblname = "HP_BNFT_R"
   SET tblnames->list[126].tblname = "HP_BNFT_SET"
   SET tblnames->list[127].tblname = "HP_PROC_BNFT"
   SET tblnames->list[128].tblname = "HP_PRSNL_R"
   SET tblnames->list[129].tblname = "HP_SOFT_BNFT"
   SET tblnames->list[130].tblname = "HP_SOFT_BNFT_ALIAS"
   SET tblnames->list[131].tblname = "IC_STUDY_ST"
   SET tblnames->list[132].tblname = "IMPLANT_MASTER"
   SET tblnames->list[133].tblname = "INCLUDED_ASSAYS"
   SET tblnames->list[134].tblname = "INPUT_FIELD_DEFINITION"
   SET tblnames->list[135].tblname = "INTERNAL_TRANSFER_T"
   SET tblnames->list[136].tblname = "INV_TRANS_GL"
   SET tblnames->list[137].tblname = "INV_TRANS_LOG"
   SET tblnames->list[138].tblname = "INV_TRANS_LOT_INFO"
   SET tblnames->list[139].tblname = "INVENTORY_AREA"
   SET tblnames->list[140].tblname = "INVENTORY_CONTROL_T"
   SET tblnames->list[141].tblname = "IQH_CATEGORYGROUP_PERSON"
   SET tblnames->list[142].tblname = "IQH_DBQUERY"
   SET tblnames->list[143].tblname = "IQH_MEMBER_CALC_VALUE"
   SET tblnames->list[144].tblname = "IQH_MEMBER_HRA_OUTCOME"
   SET tblnames->list[145].tblname = "IQH_MEMBER_HRA_RELTN"
   SET tblnames->list[146].tblname = "IQH_MEMBER_HRA_RESPONSE"
   SET tblnames->list[147].tblname = "IQH_OLAP_DIM"
   SET tblnames->list[148].tblname = "IQH_OLAP_DIM_LEVEL_MAP"
   SET tblnames->list[149].tblname = "IQH_OLAP_DIMTYPE_MES_RELTN"
   SET tblnames->list[150].tblname = "IQH_OLAP_FACT"
   SET tblnames->list[151].tblname = "IQH_OLAP_FACT_LEVEL_MAP"
   SET tblnames->list[152].tblname = "IQH_OLAP_POPULATION"
   SET tblnames->list[153].tblname = "ITEM_DEFINITION_EXTENSION"
   SET tblnames->list[154].tblname = "ITEM_EXTENSION"
   SET tblnames->list[155].tblname = "ITEM_STORAGE_REQUIREMENTS"
   SET tblnames->list[156].tblname = "LAB_MDI_CONTACT"
   SET tblnames->list[157].tblname = "LABOR_COST"
   SET tblnames->list[158].tblname = "LINE_ITEM_MANIFEST_R"
   SET tblnames->list[159].tblname = "LOT_INFO_T"
   SET tblnames->list[160].tblname = "MANIFEST"
   SET tblnames->list[161].tblname = "MANUFACTURER_CATALOG"
   SET tblnames->list[162].tblname = "MANUFACTURING_REFERENCE_T"
   SET tblnames->list[163].tblname = "MEDICATION"
   SET tblnames->list[164].tblname = "MIC_ERR_RECOVER"
   SET tblnames->list[165].tblname = "MIC_TASK_COMMENT"
   SET tblnames->list[166].tblname = "MLTM_NDC_ACTIVE_INGRED_LIST"
   SET tblnames->list[167].tblname = "MMR_ABS_DATA"
   SET tblnames->list[168].tblname = "MMR_ABS_DEF"
   SET tblnames->list[169].tblname = "MMR_ABSTRACT_ST"
   SET tblnames->list[170].tblname = "MMR_CHECK_REG_ST"
   SET tblnames->list[171].tblname = "MMR_CLAIMANT"
   SET tblnames->list[172].tblname = "MMR_CONTROL"
   SET tblnames->list[173].tblname = "MMR_CONTROL_GRP"
   SET tblnames->list[174].tblname = "MMR_FOLDER"
   SET tblnames->list[175].tblname = "MMR_FOLDER_ITEM"
   SET tblnames->list[176].tblname = "MMR_FORM"
   SET tblnames->list[177].tblname = "MMR_FORM_CONTROL"
   SET tblnames->list[178].tblname = "MMR_GRID"
   SET tblnames->list[179].tblname = "MMR_GRID_DETAILS"
   SET tblnames->list[180].tblname = "MMR_LIAB_HISTORY_ST"
   SET tblnames->list[181].tblname = "MMR_LONG_TEXT"
   SET tblnames->list[182].tblname = "MMR_PAYEE"
   SET tblnames->list[183].tblname = "MMR_PV_RELATION"
   SET tblnames->list[184].tblname = "MMR_QI_ACTIVITY"
   SET tblnames->list[185].tblname = "MMR_QI_CODEDVALUE"
   SET tblnames->list[186].tblname = "MMR_QI_DATE_RANGE"
   SET tblnames->list[187].tblname = "MMR_QI_DAYS_ST"
   SET tblnames->list[188].tblname = "MMR_QI_INDEMNITY"
   SET tblnames->list[189].tblname = "MMR_QI_LIT_ACTIVITY"
   SET tblnames->list[190].tblname = "MMR_QI_OSHA_ST"
   SET tblnames->list[191].tblname = "MMR_QI_PERSON"
   SET tblnames->list[192].tblname = "MMR_QI_QUESTION_RSLT"
   SET tblnames->list[193].tblname = "MMR_QUALITY_ITEM"
   SET tblnames->list[194].tblname = "MMR_QUALITY_ITEM_ST"
   SET tblnames->list[195].tblname = "MMR_QUESTION_ST"
   SET tblnames->list[196].tblname = "MMR_REF_ITEM"
   SET tblnames->list[197].tblname = "MMR_REPORT_WIZ_DEF"
   SET tblnames->list[198].tblname = "MMR_SURVEY_GROUP"
   SET tblnames->list[199].tblname = "MMR_SYS_FLOW"
   SET tblnames->list[200].tblname = "MMR_TAB"
   SET tblnames->list[201].tblname = "MMR_TAB_DETAILS"
   SET tblnames->list[202].tblname = "MMR_VIEWER_PREFS"
   SET tblnames->list[203].tblname = "MMR_VIEWER_PREFS_SL"
   SET tblnames->list[204].tblname = "MODULE"
   SET tblnames->list[205].tblname = "NOMEN_CAT_FLEX"
   SET tblnames->list[206].tblname = "NOMEN_DUP_HOLD"
   SET tblnames->list[207].tblname = "NORMALIZED_WORD_INDEX"
   SET tblnames->list[208].tblname = "OAF_BENEFIT"
   SET tblnames->list[209].tblname = "OAF_BENEFIT_DETAIL"
   SET tblnames->list[210].tblname = "OASIS_AUTO_ANSWERS"
   SET tblnames->list[211].tblname = "OASIS_DATA"
   SET tblnames->list[212].tblname = "OASIS_DATA_SET"
   SET tblnames->list[213].tblname = "OASIS_DETAIL"
   SET tblnames->list[214].tblname = "OASIS_EXT_ENCNTR_CD"
   SET tblnames->list[215].tblname = "OASIS_EXTRACTION_SET"
   SET tblnames->list[216].tblname = "OASIS_PROMPT"
   SET tblnames->list[217].tblname = "OASIS_RECORD_SET"
   SET tblnames->list[218].tblname = "OASIS_SKIP_RULE"
   SET tblnames->list[219].tblname = "OASIS_XREF"
   SET tblnames->list[220].tblname = "ODS_OPR_RELTN"
   SET tblnames->list[221].tblname = "ODS_OXR_RELTN"
   SET tblnames->list[222].tblname = "OEN_FILE_STATUS"
   SET tblnames->list[223].tblname = "OEN_OBJ_LIB"
   SET tblnames->list[224].tblname = "OEN_PRUNEJOB_CONFIG"
   SET tblnames->list[225].tblname = "OMF_ABS_DAYS"
   SET tblnames->list[226].tblname = "OMF_APP_GRID_R"
   SET tblnames->list[227].tblname = "OMF_CALC_ENG_QUE"
   SET tblnames->list[228].tblname = "OMF_CPT4_PROCEDURE_ST"
   SET tblnames->list[229].tblname = "OMF_ENCNTR_SMRY"
   SET tblnames->list[230].tblname = "OMF_EVENT_DTL"
   SET tblnames->list[231].tblname = "OMF_GRID_GROUPING"
   SET tblnames->list[232].tblname = "OMF_GRID_INDICATOR"
   SET tblnames->list[233].tblname = "OMF_GRID_VP"
   SET tblnames->list[234].tblname = "OMF_HEALTH_PLAN_SMRY_ST"
   SET tblnames->list[235].tblname = "OMF_HF_DRILL"
   SET tblnames->list[236].tblname = "OMF_HF_GRID_GROUPING"
   SET tblnames->list[237].tblname = "OMF_IC_CAND_ST"
   SET tblnames->list[238].tblname = "OMF_ICD9_DIAGNOSIS_ST"
   SET tblnames->list[239].tblname = "OMF_ICD9_PROCEDURE_ST"
   SET tblnames->list[240].tblname = "OMF_IND_DICTIONARY"
   SET tblnames->list[241].tblname = "OMF_INDICATOR_GROUP"
   SET tblnames->list[242].tblname = "OMF_INDICATOR_GROUPING"
   SET tblnames->list[243].tblname = "OMF_LOG"
   SET tblnames->list[244].tblname = "OMF_LOG_DESC"
   SET tblnames->list[245].tblname = "OMF_MEMBER_SMRY_ST"
   SET tblnames->list[246].tblname = "OMF_PERM_FILTER"
   SET tblnames->list[247].tblname = "OMF_PROCESS_ENG_QUE"
   SET tblnames->list[248].tblname = "OMF_PRODUCT_QUEUE"
   SET tblnames->list[249].tblname = "OMF_PV_DATA_ST"
   SET tblnames->list[250].tblname = "OMF_PV_FAVORITES"
   SET tblnames->list[251].tblname = "OMF_PVF_COLUMNS"
   SET tblnames->list[252].tblname = "OMF_PVF_DATE"
   SET tblnames->list[253].tblname = "OMF_PVF_FILTER"
   SET tblnames->list[254].tblname = "OMF_PVF_FOLDERS"
   SET tblnames->list[255].tblname = "OMF_PVF_GRAPHS"
   SET tblnames->list[256].tblname = "OMF_PVF_GRAPHS_ATTRIB"
   SET tblnames->list[257].tblname = "OMF_PVF_STOPLIGHT"
   SET tblnames->list[258].tblname = "OMF_PVF_VO"
   SET tblnames->list[259].tblname = "OMF_RH_INDICATOR"
   SET tblnames->list[260].tblname = "OMF_SAVED_FILTER"
   SET tblnames->list[261].tblname = "OMF_SAVED_VP"
   SET tblnames->list[262].tblname = "OMF_ST_QUEUE"
   SET tblnames->list[263].tblname = "OMF_TIME_BLOCK"
   SET tblnames->list[264].tblname = "OMF_TIME_BLOCK_DTL"
   SET tblnames->list[265].tblname = "OMF_TRANS_CALC"
   SET tblnames->list[266].tblname = "OMF_TRANS_EXPRESS"
   SET tblnames->list[267].tblname = "OMF_TRANS_IND_XREF"
   SET tblnames->list[268].tblname = "OMF_TRANS_INDICATOR"
   SET tblnames->list[269].tblname = "OMF_TRANS_NAME"
   SET tblnames->list[270].tblname = "OMF_TRANS_OUTBOUND"
   SET tblnames->list[271].tblname = "OMF_TRANS_QUAL"
   SET tblnames->list[272].tblname = "OMF_TRANS_TABSEQ"
   SET tblnames->list[273].tblname = "OMF_TRANSIN_TRIGGER"
   SET tblnames->list[274].tblname = "OMF_VP_DISPLAY"
   SET tblnames->list[275].tblname = "OMF_VP_INDICATOR"
   SET tblnames->list[276].tblname = "OMF_VP_TYPE"
   SET tblnames->list[277].tblname = "OPF_ATTRIBUTE"
   SET tblnames->list[278].tblname = "OPF_JOB"
   SET tblnames->list[279].tblname = "OPF_JOB_TYPE"
   SET tblnames->list[280].tblname = "OPF_NAME"
   SET tblnames->list[281].tblname = "OPF_NAME_POOL"
   SET tblnames->list[282].tblname = "OPF_NAME_POOL_RELTN"
   SET tblnames->list[283].tblname = "OPF_PARAMETER"
   SET tblnames->list[284].tblname = "OPF_WEIGHT"
   SET tblnames->list[285].tblname = "ORC_CODE_R"
   SET tblnames->list[286].tblname = "ORDER_BLOT"
   SET tblnames->list[287].tblname = "ORDER_CATALOG_GROUPING_COMP"
   SET tblnames->list[288].tblname = "OSM_CHART_REQUEST"
   SET tblnames->list[289].tblname = "OUTBOUND_FORMATTING"
   SET tblnames->list[290].tblname = "PA_AUDIT"
   SET tblnames->list[291].tblname = "PA_CRITERIA"
   SET tblnames->list[292].tblname = "PA_CRITERIA_VALUE"
   SET tblnames->list[293].tblname = "PA_LOG"
   SET tblnames->list[294].tblname = "PA_REQ_DEPENDENCY"
   SET tblnames->list[295].tblname = "PA_REQ_INDEX"
   SET tblnames->list[296].tblname = "PA_REQUEST"
   SET tblnames->list[297].tblname = "PA_SEARCH_PROCESS"
   SET tblnames->list[298].tblname = "PARENTAL_HAPLOTYPE"
   SET tblnames->list[299].tblname = "PARENTAL_LOCI"
   SET tblnames->list[300].tblname = "PARENTAL_LOCI_DEFAULT"
   SET tblnames->list[301].tblname = "PART_COST"
   SET tblnames->list[302].tblname = "PAT_ED_ACTIVITY"
   SET tblnames->list[303].tblname = "PC_485_OTHER"
   SET tblnames->list[304].tblname = "PC_ACTIVITIES_PERMITTED"
   SET tblnames->list[305].tblname = "PC_ADMISSION_ST"
   SET tblnames->list[306].tblname = "PC_ADVANCE_DIRECTIVE"
   SET tblnames->list[307].tblname = "PC_CLIENT_STATS_ST"
   SET tblnames->list[308].tblname = "PC_DIET"
   SET tblnames->list[309].tblname = "PC_DO_NOT_MATCH"
   SET tblnames->list[310].tblname = "PC_ENCNTR_CONTACT_RELTN"
   SET tblnames->list[311].tblname = "PC_FORM_DETAIL"
   SET tblnames->list[312].tblname = "PC_FUNCTIONAL_LIMITATION"
   SET tblnames->list[313].tblname = "PC_GEOG_CHOICES"
   SET tblnames->list[314].tblname = "PC_GEOG_COVERAGE"
   SET tblnames->list[315].tblname = "PC_HCFA_485"
   SET tblnames->list[316].tblname = "PC_HISTORY"
   SET tblnames->list[317].tblname = "PC_HOSPICE_MC_BFT"
   SET tblnames->list[318].tblname = "PC_IO_SECTION_DETAIL"
   SET tblnames->list[319].tblname = "PC_LOC_ENC_333_RELTN"
   SET tblnames->list[320].tblname = "PC_MED_LIST"
   SET tblnames->list[321].tblname = "PC_MENTAL_STATUS"
   SET tblnames->list[322].tblname = "PC_NOTE_COMMENT"
   SET tblnames->list[323].tblname = "PC_NOTE_ORDER_RELTN"
   SET tblnames->list[324].tblname = "PC_NOTE_SECTION"
   SET tblnames->list[325].tblname = "PC_PBS_PAT_DIAG"
   SET tblnames->list[326].tblname = "PC_PBS_PAT_PHYSICIAN"
   SET tblnames->list[327].tblname = "PC_PRSNL_INFO"
   SET tblnames->list[328].tblname = "PC_REC_PATTERN"
   SET tblnames->list[329].tblname = "PC_REF_FORM_ENCNTR"
   SET tblnames->list[330].tblname = "PC_REF_PRSNL_ORG"
   SET tblnames->list[331].tblname = "PC_REF_REQ_FIELD"
   SET tblnames->list[332].tblname = "PC_REF_SOURCE"
   SET tblnames->list[333].tblname = "PC_REF_SRC_XFER"
   SET tblnames->list[334].tblname = "PC_REF_VIEW_MATCH"
   SET tblnames->list[335].tblname = "PC_REFERRAL_LIST"
   SET tblnames->list[336].tblname = "PC_REFERRAL_ST"
   SET tblnames->list[337].tblname = "PC_REMINDERS_LIST"
   SET tblnames->list[338].tblname = "PC_TEAM_ALTS_LIST"
   SET tblnames->list[339].tblname = "PC_TIME_AVAILABILITY"
   SET tblnames->list[340].tblname = "PC_TRANSFER_TO"
   SET tblnames->list[341].tblname = "PC_VISIT_AUTH"
   SET tblnames->list[342].tblname = "PC_VISIT_ORDER"
   SET tblnames->list[343].tblname = "PC_VISIT_ORDER_RELTN"
   SET tblnames->list[344].tblname = "PC_VISIT_SIGN"
   SET tblnames->list[345].tblname = "PERSON_BNFT_SET_R"
   SET tblnames->list[346].tblname = "PERSON_NTWK_PRVDR"
   SET tblnames->list[347].tblname = "PERSON_PLAN_ALIAS"
   SET tblnames->list[348].tblname = "PFT_EXPECTED_BATCH"
   SET tblnames->list[349].tblname = "PFT_EXPECTED_DETAIL"
   SET tblnames->list[350].tblname = "PFT_FILE_ADJ_RELTN"
   SET tblnames->list[351].tblname = "PFT_TAG"
   SET tblnames->list[352].tblname = "PHA_ONETOMANY_1"
   SET tblnames->list[353].tblname = "PHA_ONETOMANY_2"
   SET tblnames->list[354].tblname = "PHASED_INVOICE"
   SET tblnames->list[355].tblname = "PM_DOC_DIST_DEF"
   SET tblnames->list[356].tblname = "PM_DOC_DIST_REL"
   SET tblnames->list[357].tblname = "PM_DOC_TRANSACTION"
   SET tblnames->list[358].tblname = "PM_MENTAL_HEALTH_INFO"
   SET tblnames->list[359].tblname = "PM_PROCEDURE"
   SET tblnames->list[360].tblname = "POM_APP_CLASS_R"
   SET tblnames->list[361].tblname = "POM_CLASS"
   SET tblnames->list[362].tblname = "POM_COMMAND_PARM"
   SET tblnames->list[363].tblname = "POM_ENUM"
   SET tblnames->list[364].tblname = "POM_EXPRESSION"
   SET tblnames->list[365].tblname = "POM_METHOD"
   SET tblnames->list[366].tblname = "POM_METHOD_RULE_R"
   SET tblnames->list[367].tblname = "POM_PROP_CTRL_PROP_R"
   SET tblnames->list[368].tblname = "POM_PROPERTY"
   SET tblnames->list[369].tblname = "PPS_CUR_ANSWER"
   SET tblnames->list[370].tblname = "PPS_EPISODE"
   SET tblnames->list[371].tblname = "PPS_HHRG"
   SET tblnames->list[372].tblname = "PPS_LEVEL"
   SET tblnames->list[373].tblname = "PPS_PARAMS"
   SET tblnames->list[374].tblname = "PPS_SCORE_ITEM"
   SET tblnames->list[375].tblname = "PPS_SCORE_LEVEL"
   SET tblnames->list[376].tblname = "PPS_SCORE_LINE"
   SET tblnames->list[377].tblname = "PPS_WAGE_INDEX"
   SET tblnames->list[378].tblname = "PREF_CARD_SURGEON_COMMENT"
   SET tblnames->list[379].tblname = "PREF_CARD_TEXT"
   SET tblnames->list[380].tblname = "PREFERENCE_CARD_DEFAULT"
   SET tblnames->list[381].tblname = "PREVENTIVE_MAINTENANCE"
   SET tblnames->list[382].tblname = "PROBLEM_ENTITY_R"
   SET tblnames->list[383].tblname = "PROCESS"
   SET tblnames->list[384].tblname = "PROCINFO_SYSTEM_R"
   SET tblnames->list[385].tblname = "PROFILE_PV_CHART"
   SET tblnames->list[386].tblname = "PROFILE_PV_DOCUMENT"
   SET tblnames->list[387].tblname = "PROP_QUEUE"
   SET tblnames->list[388].tblname = "PURCHASE_ORDER_LINE_ITEM"
   SET tblnames->list[389].tblname = "PURCHASE_PRICE_UPDATE_T"
   SET tblnames->list[390].tblname = "QUANTITY_REQUIREMENTS"
   SET tblnames->list[391].tblname = "RECEIPT_LINE_ITEM_QUANTITY"
   SET tblnames->list[392].tblname = "REORDER_POINT_T"
   SET tblnames->list[393].tblname = "REQ_FLEX_PRINTER"
   SET tblnames->list[394].tblname = "REQ_FLEX_RTG_OPTION"
   SET tblnames->list[395].tblname = "REQ_PO_TEMPLATE"
   SET tblnames->list[396].tblname = "REQUEST_EVENT"
   SET tblnames->list[397].tblname = "REQUISITION_FLEX_RTG_DEST"
   SET tblnames->list[398].tblname = "REQUISITION_FLEXIBLE_RTG"
   SET tblnames->list[399].tblname = "REQUISITION_LINE_ITEM"
   SET tblnames->list[400].tblname = "REQUISITION_ROUTES"
   SET tblnames->list[401].tblname = "RESOURCE_ROUTE"
   SET tblnames->list[402].tblname = "ROBOTICS_LOGIN_LOC_R"
   SET tblnames->list[403].tblname = "ROBOTICS_PARAMETERS"
   SET tblnames->list[404].tblname = "ROI_REQUEST_CRITERIA"
   SET tblnames->list[405].tblname = "ROUTE_CODE_RESOURCE_LIST"
   SET tblnames->list[406].tblname = "SCD_PHRASE_TYPE"
   SET tblnames->list[407].tblname = "SCH_ACTION_REASON"
   SET tblnames->list[408].tblname = "SCH_README"
   SET tblnames->list[409].tblname = "SCH_README_ACTION"
   SET tblnames->list[410].tblname = "SCH_RES_LOC"
   SET tblnames->list[411].tblname = "SCH_USER_TEXT"
   SET tblnames->list[412].tblname = "SEGMENT_TEXT"
   SET tblnames->list[413].tblname = "SEL_TASK_PRSNL_R"
   SET tblnames->list[414].tblname = "SERVICE_GROUP"
   SET tblnames->list[415].tblname = "SM_COMPLETE_ST"
   SET tblnames->list[416].tblname = "SMR_CHARGE_EVENT_ST"
   SET tblnames->list[417].tblname = "SMRY_TBL_QUE"
   SET tblnames->list[418].tblname = "SMRY_TBL_QUE_ERRORS"
   SET tblnames->list[419].tblname = "SMRY_TBL_SCRIPTS"
   SET tblnames->list[420].tblname = "SN_GAPCHECK"
   SET tblnames->list[421].tblname = "SN_GAPCHECK_RULES"
   SET tblnames->list[422].tblname = "SRDEF"
   SET tblnames->list[423].tblname = "SRSTRE1"
   SET tblnames->list[424].tblname = "STAFF_ASSIGN"
   SET tblnames->list[425].tblname = "STATUS_T"
   SET tblnames->list[426].tblname = "STERILIZATION_T"
   SET tblnames->list[427].tblname = "SUBSTITUTE_ITEM"
   SET tblnames->list[428].tblname = "SURG_PRINT_DETAILS"
   SET tblnames->list[429].tblname = "SURGICAL_TEAM_MEMBER"
   SET tblnames->list[430].tblname = "TASK_PLAN"
   SET tblnames->list[431].tblname = "TASK_PLAN_RELTN"
   SET tblnames->list[432].tblname = "TEXT_LINE_ITEM"
   SET tblnames->list[433].tblname = "TRACK_EVENT_POSITION"
   SET tblnames->list[434].tblname = "TRACKING_PREF_REL"
   SET tblnames->list[435].tblname = "TRANS_HOLD_T"
   SET tblnames->list[436].tblname = "TRANSACTION_LOG"
   SET tblnames->list[437].tblname = "TRANSMISSION_LOG"
   SET tblnames->list[438].tblname = "UPLOAD_REPORT"
   SET tblnames->list[439].tblname = "UPLOAD_USER"
   SET tblnames->list[440].tblname = "USAGE_T"
   SET tblnames->list[441].tblname = "V300_V500_CONVERSION"
   SET tblnames->list[442].tblname = "VENDOR_CATALOG"
   SET tblnames->list[443].tblname = "VENDOR_CUSTOMER_ACCOUNT"
   SET tblnames->list[444].tblname = "VENDOR_SERVICE_REQUEST_INFO"
   SET tblnames->list[445].tblname = "VENDOR_T"
   SET tblnames->list[446].tblname = "WORD_INDEX"
   SET tblnames->list[447].tblname = "WORKLOAD_ALPHAS"
   SET tblnames->list[448].tblname = "WORKLOAD_CANCEL"
   SET tblnames->list[449].tblname = "WORKLOAD_ORDERABLES"
   SET tblnames->list[450].tblname = "WP_ACT"
   SET tblnames->list[451].tblname = "WP_ACT_ALERT"
   SET tblnames->list[452].tblname = "WP_ACT_DATA"
   SET tblnames->list[453].tblname = "WP_ACT_MAIL"
   SET tblnames->list[454].tblname = "WP_ACT_PART_DEF"
   SET tblnames->list[455].tblname = "WP_ACT_SCRIPT"
   SET tblnames->list[456].tblname = "WP_ACTI"
   SET tblnames->list[457].tblname = "WP_ACTI_ALERT"
   SET tblnames->list[458].tblname = "WP_ACTI_DATA"
   SET tblnames->list[459].tblname = "WP_ACTI_MAIL"
   SET tblnames->list[460].tblname = "WP_ACTI_PART_DEF"
   SET tblnames->list[461].tblname = "WP_ACTI_SCRIPT"
   SET tblnames->list[462].tblname = "WP_ALERT"
   SET tblnames->list[463].tblname = "WP_ALERT_ACT"
   SET tblnames->list[464].tblname = "WP_ALERT_ACT_STATE"
   SET tblnames->list[465].tblname = "WP_ALERT_CAT"
   SET tblnames->list[466].tblname = "WP_ALERT_MONITOR"
   SET tblnames->list[467].tblname = "WP_ALERT_STATE"
   SET tblnames->list[468].tblname = "WP_ASSIGN_TYPE"
   SET tblnames->list[469].tblname = "WP_BULK_STORAGE"
   SET tblnames->list[470].tblname = "WP_BUS_CAL"
   SET tblnames->list[471].tblname = "WP_BUS_HOURS"
   SET tblnames->list[472].tblname = "WP_CAT"
   SET tblnames->list[473].tblname = "WP_DATABASE"
   SET tblnames->list[474].tblname = "WP_FIFO_GEN"
   SET tblnames->list[475].tblname = "WP_GRP_TYPE"
   SET tblnames->list[476].tblname = "WP_GRP_TYPE_CAT"
   SET tblnames->list[477].tblname = "WP_HOL_CAL"
   SET tblnames->list[478].tblname = "WP_HOL_DATE"
   SET tblnames->list[479].tblname = "WP_ID_GEN"
   SET tblnames->list[480].tblname = "WP_INI"
   SET tblnames->list[481].tblname = "WP_JOB_MONITOR"
   SET tblnames->list[482].tblname = "WP_MAIL"
   SET tblnames->list[483].tblname = "WP_MAIL_CAT"
   SET tblnames->list[484].tblname = "WP_MAIL_MONITOR"
   SET tblnames->list[485].tblname = "WP_MAIL_RECIP"
   SET tblnames->list[486].tblname = "WP_MAIL_RECIP_TYPE"
   SET tblnames->list[487].tblname = "WP_MONITOR"
   SET tblnames->list[488].tblname = "WP_MONITOR_TYPE"
   SET tblnames->list[489].tblname = "WP_NODE_STATE"
   SET tblnames->list[490].tblname = "WP_NODE_STATE_MAP"
   SET tblnames->list[491].tblname = "WP_NODE_TYPE"
   SET tblnames->list[492].tblname = "WP_OBJECT_TYPE"
   SET tblnames->list[493].tblname = "WP_PRIOR"
   SET tblnames->list[494].tblname = "WP_PRIOR_CAT"
   SET tblnames->list[495].tblname = "WP_PROC"
   SET tblnames->list[496].tblname = "WP_PROC_ALERT"
   SET tblnames->list[497].tblname = "WP_PROC_CAT"
   SET tblnames->list[498].tblname = "WP_PROC_DATA"
   SET tblnames->list[499].tblname = "WP_PROC_DESC"
   SET tblnames->list[500].tblname = "WP_PROC_MAIL"
   SET tblnames->list[501].tblname = "WP_PROC_NODE"
   SET tblnames->list[502].tblname = "WP_PROC_NODE_TEMPLATE"
   SET tblnames->list[503].tblname = "WP_PROC_NODE_TEMPLATE_CAT"
   SET tblnames->list[504].tblname = "WP_PROC_PART_DEF"
   SET tblnames->list[505].tblname = "WP_PROC_SCRIPT"
   SET tblnames->list[506].tblname = "WP_PROC_STATE"
   SET tblnames->list[507].tblname = "WP_PROC_STATE_MAP"
   SET tblnames->list[508].tblname = "WP_PROCI"
   SET tblnames->list[509].tblname = "WP_PROCI_ALERT"
   SET tblnames->list[510].tblname = "WP_PROCI_ALERT_ACT"
   SET tblnames->list[511].tblname = "WP_PROCI_ALERT_HIST"
   SET tblnames->list[512].tblname = "WP_PROCI_CAT"
   SET tblnames->list[513].tblname = "WP_PROCI_DATA"
   SET tblnames->list[514].tblname = "WP_PROCI_DELETE"
   SET tblnames->list[515].tblname = "WP_PROCI_ERR"
   SET tblnames->list[516].tblname = "WP_PROCI_HIST"
   SET tblnames->list[517].tblname = "WP_PROCI_MAIL"
   SET tblnames->list[518].tblname = "WP_PROCI_NODE"
   SET tblnames->list[519].tblname = "WP_PROCI_NODE_HIST"
   SET tblnames->list[520].tblname = "WP_PROCI_PART"
   SET tblnames->list[521].tblname = "WP_PROCI_PART_DEF"
   SET tblnames->list[522].tblname = "WP_PROCI_SCRIPT"
   SET tblnames->list[523].tblname = "WP_RESOURCE"
   SET tblnames->list[524].tblname = "WP_RESRC_CATEGORY"
   SET tblnames->list[525].tblname = "WP_SCRIPT"
   SET tblnames->list[526].tblname = "WP_SCRIPT_CAT"
   SET tblnames->list[527].tblname = "WP_SCRIPT_CLASS"
   SET tblnames->list[528].tblname = "WP_SCRIPT_LINE"
   SET tblnames->list[529].tblname = "WP_SCRIPT_MONITOR"
   SET tblnames->list[530].tblname = "WP_SCRIPT_TYPE"
   SET tblnames->list[531].tblname = "WP_SESS_ERROR"
   SET tblnames->list[532].tblname = "WP_SESS_TRACE"
   SET tblnames->list[533].tblname = "WP_TEXT"
   SET tblnames->list[534].tblname = "WP_TEXT_LINE"
   SET tblnames->list[535].tblname = "WP_TRAN"
   SET tblnames->list[536].tblname = "WP_TRAN_STATE"
   SET tblnames->list[537].tblname = "WP_TRAN_STATE_MAP"
   SET tblnames->list[538].tblname = "WP_TRAN_TYPE"
   SET tblnames->list[539].tblname = "WP_TRANI"
   SET tblnames->list[540].tblname = "WP_TRANI_HIST"
   SET tblnames->list[541].tblname = "WP_USER_DATA"
   SET tblnames->list[542].tblname = "WP_WI_ALERT"
   SET tblnames->list[543].tblname = "WP_WI_ALERT_ACT"
   SET tblnames->list[544].tblname = "WP_WI_ALERT_HIST"
   SET tblnames->list[545].tblname = "WP_WORK_ITEM"
   SET tblnames->list[546].tblname = "WP_WORK_ITEM_HIST"
   SET tblnames->list[547].tblname = "WP_WORK_ITEM_PART"
   SET tblnames->list[548].tblname = "WP_WORK_STATE"
   SET tblnames->list[549].tblname = "WP_WORK_STATE_MAP"
   SET tblnames->list[550].tblname = "BPM_ARCH_DATASTORE"
   SET tblnames->list[551].tblname = "BPM_ARCH_SYSTEM"
   SET tblnames->list[552].tblname = "BPM_AUDIT_EVENT"
   SET tblnames->list[553].tblname = "BPM_CLIENT"
   SET tblnames->list[554].tblname = "BPM_COMPONENT_ATTACH"
   SET tblnames->list[555].tblname = "BPM_COMPONENT_ELEMENT_RELTN"
   SET tblnames->list[556].tblname = "BPM_COMPONENT_NOTE"
   SET tblnames->list[557].tblname = "BPM_CONCEPT"
   SET tblnames->list[558].tblname = "BPM_CONCEPT_OBJ_RELTN"
   SET tblnames->list[559].tblname = "BPM_CONTAINER"
   SET tblnames->list[560].tblname = "BPM_CONTRIBUTOR"
   SET tblnames->list[561].tblname = "BPM_DS_ELEMENT"
   SET tblnames->list[562].tblname = "BPM_ELEMENT_PROP"
   SET tblnames->list[563].tblname = "BPM_FACILITY"
   SET tblnames->list[564].tblname = "BPM_MOD_OBJ_PROPERTY"
   SET tblnames->list[565].tblname = "BPM_MODEL"
   SET tblnames->list[566].tblname = "BPM_MODEL_OBJECT_RELTN"
   SET tblnames->list[567].tblname = "BPM_OBJECT"
   SET tblnames->list[568].tblname = "BPM_OBJECT_ASSOC"
   SET tblnames->list[569].tblname = "BPM_PROC_CONTAINER_RELTN"
   SET tblnames->list[570].tblname = "BPM_PROC_INSTANCE"
   SET tblnames->list[571].tblname = "BPM_PROCESS"
   SET tblnames->list[572].tblname = "BPM_PROCINST_CONTRIB_RELTN"
   SET tblnames->list[573].tblname = "BPM_RATE"
   SET tblnames->list[574].tblname = "BPM_SWIMLANE_OBJ"
   SET tblnames->list[575].tblname = "BPM_UNIT_USAGE"
   SET tblnames->list[576].tblname = "CE_IO_RESULT"
   SET tblnames->list[577].tblname = "DCP_NOMENCATEGORY"
   SET tblnames->list[578].tblname = "DCP_NOMENCATEGORYDEF"
   SET tblnames->list[579].tblname = "IQH_CONTENT"
   SET tblnames->list[580].tblname = "IQH_CONTENT_DATA"
   SET tblnames->list[581].tblname = "IQH_CONTENT_RULE"
   SET tblnames->list[582].tblname = "IQH_HRA_FORMAT"
   SET tblnames->list[583].tblname = "IQH_HRA_MASTER"
   SET tblnames->list[584].tblname = "IQH_HRA_OUTCOME"
   SET tblnames->list[585].tblname = "IQH_HRA_PROCESS"
   SET tblnames->list[586].tblname = "IQH_HRA_PROCESS_CALC"
   SET tblnames->list[587].tblname = "IQH_HRA_QUESTION"
   SET tblnames->list[588].tblname = "IQH_HRA_QUESTION_RELTN"
   SET tblnames->list[589].tblname = "IQH_HRA_RESPONSE"
   SET tblnames->list[590].tblname = "IQH_OLAP_MEASURE"
   SET tblnames->list[591].tblname = "IQH_OUTCOME_REPORT_RELTN"
   SET tblnames->list[592].tblname = "IQH_PAPER_BATCH"
   SET tblnames->list[593].tblname = "IQH_PERSON_QUEST_INSTANCE"
   SET tblnames->list[594].tblname = "IQH_PERSON_RESPONSES"
   SET tblnames->list[595].tblname = "IQH_QUEST_ORG_RELTN"
   SET tblnames->list[596].tblname = "IQH_QUESTION_CAT"
   SET tblnames->list[597].tblname = "IQH_QUESTION_LIBRARY"
   SET tblnames->list[598].tblname = "IQH_QUESTIONNAIRE_DEFINITION"
   SET tblnames->list[599].tblname = "IQH_REPORT_LONG_TEXT"
   SET tblnames->list[600].tblname = "IQH_RESPONSE_LIBRARY"
   SET tblnames->list[601].tblname = "IQH_RISK"
   SET tblnames->list[602].tblname = "IQH_RISK_FACTOR_R"
   SET tblnames->list[603].tblname = "IQH_STANDARD_VALUE"
   SET tblnames->list[604].tblname = "IQH_SURVEY_LONG_TEXT"
   SET tblnames->list[605].tblname = "IQH_SURVEY_TEXT"
   SET tblnames->list[606].tblname = "MEMBERSHIP"
   SET tblnames->list[607].tblname = "ITEM_PACKAGE_TYPE"
   SET tblnames->list[608].tblname = "POM_APP_CLASS_R"
   SET tblnames->list[609].tblname = "POM_APPLICATION"
   SET tblnames->list[610].tblname = "POM_CLASS"
   SET tblnames->list[611].tblname = "POM_COMMAND"
   SET tblnames->list[612].tblname = "POM_COMMAND_COLUMN"
   SET tblnames->list[613].tblname = "POM_COMMAND_PARM"
   SET tblnames->list[614].tblname = "POM_CONTROL"
   SET tblnames->list[615].tblname = "POM_CONTROL_PROP"
   SET tblnames->list[616].tblname = "POM_ENUM"
   SET tblnames->list[617].tblname = "POM_EXPRESSION"
   SET tblnames->list[618].tblname = "POM_GROUP"
   SET tblnames->list[619].tblname = "POM_ICON"
   SET tblnames->list[620].tblname = "POM_METHOD"
   SET tblnames->list[621].tblname = "POM_METHOD_RULE_R"
   SET tblnames->list[622].tblname = "POM_PROP_CTRL_PROP_R"
   SET tblnames->list[623].tblname = "POM_PROP_RULE_R"
   SET tblnames->list[624].tblname = "POM_PROPERTY"
   SET tblnames->list[625].tblname = "POM_RULE"
   SET tblnames->list[626].tblname = "POM_SECTION"
   SET tblnames->list[627].tblname = "RAD_HNAC_EXAM_XREF"
   SET tblnames->list[628].tblname = "RAD_LOAN_LETTER_CONTROLS"
   SET tblnames->list[629].tblname = "RAD_LOAN_LETTER_SETTINGS"
   SET tblnames->list[630].tblname = "RXS_COUNTBACK"
   SET tblnames->list[631].tblname = "RXS_TASK"
   SET tblnames->list[632].tblname = "RXS_TASK_REPLENISH"
   SET tblnames->list[633].tblname = "RXS_TASK_REPLENISH_ACT"
   SET tblnames->list[634].tblname = "SURVEY_CATEGORY"
   SET tblnames->list[635].tblname = "SURVEY_DISPLAY"
   SET tblnames->list[636].tblname = "SURVEY_INST_RPT_DOC"
   SET tblnames->list[637].tblname = "SURVEY_INSTANCE_RELTN"
   SET tblnames->list[638].tblname = "SURVEY_INSTANCE_REPORT"
   SET tblnames->list[639].tblname = "SURVEY_INSTANCE_RESPONSE"
   SET tblnames->list[640].tblname = "SURVEY_INSTANCE_VARIABLE"
   SET tblnames->list[641].tblname = "SURVEY_MASTER"
   SET tblnames->list[642].tblname = "SURVEY_ORG_RELTN"
   SET tblnames->list[643].tblname = "SURVEY_REPORT_CATEGORY"
   SET tblnames->list[644].tblname = "SURVEY_REPORT_DISPLAY"
   SET tblnames->list[645].tblname = "SURVEY_REPORT_MASTER"
   SET tblnames->list[646].tblname = "SURVEY_RESPONSE"
   SET tblnames->list[647].tblname = "SURVEY_VARIABLE"
   SET tblnames->list[648].tblname = "CHART_MIC_OPTIONS_2"
   SET tblnames->list[649].tblname = "TEMP_CHARTING_OPERATIONS"
   SET tblnames->list[650].tblname = "CHART_MIC_OPTIONS2"
   SET tblnames->list[651].tblname = "CHART_MIC_OPTIONS"
   SET tblnames->list[652].tblname = "ASSAY_DOCUMENTATION"
   SET tblnames->list[653].tblname = "NOTIFICATION"
   SET tblnames->list[654].tblname = "AGED_TRIAL_BALANCE"
   SET tblnames->list[655].tblname = "BATCH_PRINT_LOG"
   SET tblnames->list[656].tblname = "PAYMENT_SESSION"
   SET tblnames->list[657].tblname = "PFT_AR_CONV_CORSP"
   SET tblnames->list[658].tblname = "PFT_AR_CONV_INS"
   SET tblnames->list[659].tblname = "PFT_AR_CONV_OFF_LOAD"
   SET tblnames->list[660].tblname = "PFT_BALANCING_SUMMARY"
   SET tblnames->list[661].tblname = "PFT_FISCAL_BALANCING_SUM"
   SET tblnames->list[662].tblname = "PFT_FISCAL_DAILY_ACCT_BAL"
   SET tblnames->list[663].tblname = "PFT_FISCAL_DAILY_BO_HP_BAL"
   SET tblnames->list[664].tblname = "PFT_FISCAL_DAILY_ENCNTR_BAL"
   SET tblnames->list[665].tblname = "PFT_PRORATE_DEDUCT"
   SET stat = alterlist(idxnames->list,70)
   SET idxnames->list[1].idxname = "XAK1CDI_AC_BATCH"
   SET idxnames->list[2].idxname = "XAK1DMS_DISTLIST"
   SET idxnames->list[3].idxname = "XAK1HIM_REQUEST_TEMPLATE_R"
   SET idxnames->list[4].idxname = "XAK1PATHOLOGY_CASE"
   SET idxnames->list[5].idxname = "XAK1RX_LOC_RESOURCE_RELTN"
   SET idxnames->list[6].idxname = "XIE10CR_REPORT_REQUEST"
   SET idxnames->list[7].idxname = "XIE10PHA_DISP_OBS_ST"
   SET idxnames->list[8].idxname = "XIE10PHA_ORD_ACT_OBS_ST"
   SET idxnames->list[9].idxname = "XIE11PHA_DISP_OBS_ST"
   SET idxnames->list[10].idxname = "XIE11PHA_ORD_ACT_OBS_ST"
   SET idxnames->list[11].idxname = "XIE12PHA_DISP_OBS_ST"
   SET idxnames->list[12].idxname = "XIE12PHA_ORD_ACT_OBS_ST"
   SET idxnames->list[13].idxname = "XIE13PHA_DISP_OBS_ST"
   SET idxnames->list[14].idxname = "XIE15SCH_EVENT_ACTION"
   SET idxnames->list[15].idxname = "XIE16PHA_PROD_DISP_OBS_ST"
   SET idxnames->list[16].idxname = "XIE16SCH_EVENT_ACTION"
   SET idxnames->list[17].idxname = "XIE17PHA_PROD_DISP_OBS_ST"
   SET idxnames->list[18].idxname = "XIE17SCH_EVENT_ACTION"
   SET idxnames->list[19].idxname = "XIE18PHA_PROD_DISP_OBS_ST"
   SET idxnames->list[20].idxname = "XIE19PHA_PROD_DISP_OBS_ST"
   SET idxnames->list[21].idxname = "XIE1BBD_RECRUITING_LIST"
   SET idxnames->list[22].idxname = "XIE1CDI_BATCH_SUMMARY"
   SET idxnames->list[23].idxname = "XIE1CR_REPORT_REQUEST"
   SET idxnames->list[24].idxname = "XIE1CV_STEP_SCHED"
   SET idxnames->list[25].idxname = "XIE1EEM_TRANSACTION"
   SET idxnames->list[26].idxname = "XIE1ENCNTR_AUGM_CARE_PERIOD"
   SET idxnames->list[27].idxname = "XIE1PERSON_DONOR"
   SET idxnames->list[28].idxname = "XIE1PM_FLX_PROMPT"
   SET idxnames->list[29].idxname = "XIE1SEG_GRP_SEQ_R"
   SET idxnames->list[30].idxname = "XIE1TRACKING_EVENT"
   SET idxnames->list[31].idxname = "XIE1TRANS_TRANS_RELTN"
   SET idxnames->list[32].idxname = "XIE20PHA_PROD_DISP_OBS_ST"
   SET idxnames->list[33].idxname = "XIE21PHA_PROD_DISP_OBS_ST"
   SET idxnames->list[34].idxname = "XIE22PHA_PROD_DISP_OBS_ST"
   SET idxnames->list[35].idxname = "XIE2CR_REPORT_REQUEST"
   SET idxnames->list[36].idxname = "XIE2ENCNTR_ACP_HIST"
   SET idxnames->list[37].idxname = "XIE2ENCNTR_AUGM_CARE_PERIOD"
   SET idxnames->list[38].idxname = "XIE2PERSON_DONOR"
   SET idxnames->list[39].idxname = "XIE2TRACKING_EVENT"
   SET idxnames->list[40].idxname = "XIE3ENCNTR_ACP_HIST"
   SET idxnames->list[41].idxname = "XIE4CDI_TRANS_LOG"
   SET idxnames->list[42].idxname = "XIE4CV_STEP_SCHED"
   SET idxnames->list[43].idxname = "XIE4TRACKING_EVENT"
   SET idxnames->list[44].idxname = "XIE5CR_REPORT_REQUEST"
   SET idxnames->list[45].idxname = "XIE5HIM_EVENT_ALLOCATION"
   SET idxnames->list[46].idxname = "XIE5TRACKING_EVENT"
   SET idxnames->list[47].idxname = "XIE6CR_REPORT_REQUEST"
   SET idxnames->list[48].idxname = "XIE6PERFORM_RESULT"
   SET idxnames->list[49].idxname = "XIE7CR_REPORT_REQUEST"
   SET idxnames->list[50].idxname = "XIE7PHA_ORD_ACT_OBS_ST"
   SET idxnames->list[51].idxname = "XIE8CR_REPORT_REQUEST"
   SET idxnames->list[52].idxname = "XIE8PHA_ORD_ACT_OBS_ST"
   SET idxnames->list[53].idxname = "XIE98SCH_BOOKING"
   SET idxnames->list[54].idxname = "XIE9PHA_DISP_OBS_ST"
   SET idxnames->list[55].idxname = "XIE9PHA_ORD_ACT_OBS_ST"
   SET idxnames->list[56].idxname = "XIF003PAYMENT_SESSION"
   SET idxnames->list[57].idxname = "XIF53V500_EVENT_SET_CANON"
   SET idxnames->list[58].idxname = "XIF864ORDERS"
   SET idxnames->list[59].idxname = "XPK_CCL_PROMPT_PROGRAMS"
   SET idxnames->list[60].idxname = "XPKCODE_VALUE_ALIAS"
   SET idxnames->list[61].idxname = "XPKCODE_VALUE_FILTER_R"
   SET idxnames->list[62].idxname = "XPKRAD_ACR_CODES"
   SET idxnames->list[63].idxname = "XPKREF_TEXT_RELTN"
   SET idxnames->list[64].idxname = "XPKTRACK_ORD_EVENT_RELTN"
   SET idxnames->list[65].idxname = "XAK1HEA_CLAIM_VISIT"
   SET idxnames->list[66].idxname = "XIE2CLINICAL_EVENT"
   SET idxnames->list[67].idxname = "XIE10CLINICAL_EVENT"
   SET idxnames->list[68].idxname = "XAK1DM_STAT_SNAPS"
   SET idxnames->list[69].idxname = "XIE1DM_STAT_SNAPS"
   SET idxnames->list[70].idxname = "XAK1DMS_MEDIA_INSTANCE"
   SET stat = alterlist(connames->list,25)
   SET connames->list[1].conname = "XARC1ENCNTR_AUGM_CARE_PERIOD"
   SET connames->list[2].conname = "XARCENCNTR_ACP_HIST"
   SET connames->list[3].conname = "XARCENCNTR_AUGM_CARE_PERIOD"
   SET connames->list[4].conname = "XFK10CORRECTED_PRODUCT"
   SET connames->list[5].conname = "XFK12ORDER_REVIEW"
   SET connames->list[6].conname = "XFK1BLOT_BATCH"
   SET connames->list[7].conname = "XFK1HIM_PV_PHYSICIAN"
   SET connames->list[8].conname = "XFK1HLA_AB_SCREEN_BATCH"
   SET connames->list[9].conname = "XFK1PERSON_DONOR"
   SET connames->list[10].conname = "XFK2ENCNTR_ACP_HIST"
   SET connames->list[11].conname = "XFK2ENCNTR_AUGM_CARE_PERIOD"
   SET connames->list[12].conname = "XFK2OSM_CLIENT_DEFAULTS"
   SET connames->list[13].conname = "XFK2PERSON_DONOR"
   SET connames->list[14].conname = "XFK2QC_SCHEDULE_CTRL"
   SET connames->list[15].conname = "XFK2SN_CHARGE_DETAIL"
   SET connames->list[16].conname = "XFK3OSM_CLIENT_DEFAULTS"
   SET connames->list[17].conname = "XFK3QC_RESULT_RULE_R"
   SET connames->list[18].conname = "XFK4CASE_ATTENDANCE"
   SET connames->list[19].conname = "XFK4CHARGE"
   SET connames->list[20].conname = "XFK4ENCNTR_ACP_HIST"
   SET connames->list[21].conname = "XFK4TRANS_TRANS_RELTN"
   SET connames->list[22].conname = "XFK5TRACKING_ITEM"
   SET connames->list[23].conname = "XFK5TRANS_TRANS_RELTN"
   SET connames->list[24].conname = "XFK6TRACKING_ITEM"
   SET connames->list[25].conname = "XFK7TRACKING_ITEM"
   SET stat = alterlist(trgnames->list,2)
   SET trgnames->list[1].trgname = "TRG_CHARGE_EVENT_MOD_QCF"
   SET trgnames->list[2].trgname = "TRG_CHARGE_MOD_QCF"
   CALL echo("Processing Table Obsoletions...")
   FOR (i = 1 TO size(tblnames->list,5))
     EXECUTE dm_drop_obsolete_objects tblnames->list[i].tblname, "TABLE", 1
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      SET readme_data->message = build("Table Obsoletion Failure:",tblnames->list[i].tblname,"-",
       errmsg)
      GO TO exit_script
     ENDIF
   ENDFOR
   CALL echo("Processing Index Obsoletions...")
   FOR (i = 1 TO size(idxnames->list,5))
     EXECUTE dm_drop_obsolete_objects idxnames->list[i].idxname, "INDEX", 1
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      SET readme_data->message = build("Index Obsoletion Failure:",idxnames->list[i].idxname,"-",
       errmsg)
      GO TO exit_script
     ENDIF
   ENDFOR
   CALL echo("Processing Constraint Obsoletions...")
   FOR (i = 1 TO size(connames->list,5))
     EXECUTE dm_drop_obsolete_objects connames->list[i].conname, "CONSTRAINT", 1
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      SET readme_data->message = build("Constraint Obsoletion Failure:",connames->list[i].conname,"-",
       errmsg)
      GO TO exit_script
     ENDIF
   ENDFOR
   CALL echo("Processing Trigger Obsoletions...")
   FOR (i = 1 TO size(trgnames->list,5))
     EXECUTE dm_drop_obsolete_objects trgnames->list[i].trgname, "TRIGGER", 1
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      SET readme_data->message = build("Trigger Obsoletion Failure:",trgnames->list[i].trgname,"-",
       errmsg)
      GO TO exit_script
     ENDIF
   ENDFOR
   FREE RECORD tblnames
   FREE RECORD idxnames
   FREE RECORD connames
   FREE RECORD trgnames
   CALL echo("Removing Constraint Rows from DM_INFO for un-obsoleted objects...")
   DELETE  FROM dm_info di
    WHERE di.info_domain="OBSOLETE_CONSTRAINT"
     AND di.info_name IN ("XFK1PFT_SEL_TASK_R", "XFK1SELECTED_TASK", "XPKBT_CRITERIA_LIMIT",
    "XPKPFT_PRORATE_EXCLUDE", "XPKPFT_SEL_TASK_R",
    "XPKSELECTED_TASK", "XPKTASK_AVAILABLE", "XPKTASK_CRITERIA", "XPKCQM_STDBATCH_TR_1",
    "XPKCQM_STDBATCH_QUE")
     AND di.info_char="CONSTRAINT"
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->message = build(errmsg," - Readme Failed trying to remove DM_INFO rows")
    GO TO exit_script
   ENDIF
   COMMIT
   CALL echo("Removing Index Rows from DM_INFO for un-obsoleted objects...")
   DELETE  FROM dm_info di
    WHERE di.info_domain="OBSOLETE_OBJECT"
     AND di.info_name IN ("XIF001SELECTED_TASK", "XIF001TASK_CRITERIA", "XPKBT_CRITERIA_LIMIT",
    "XPKPFT_PRORATE_EXCLUDE", "XPKPFT_SEL_TASK_R",
    "XPKSELECTED_TASK", "XPKTASK_AVAILABLE", "XPKTASK_CRITERIA", "XIE1CQM_STDBATCH_QUE",
    "XIE1CQM_STDBATCH_QUE",
    "XIE2CQM_STDBATCH_QUE", "XIE2CQM_STDBATCH_QUE", "XPKCQM_STDBATCH_QUE", "XIE1CQM_STDBATCH_TR_1",
    "XIE1CQM_STDBATCH_TR_1",
    "XFK1CQM_STDBATCH_TR_1", "XPKCQM_STDBATCH_TR_1", "XIE1PFT_SEL_TASK_R", "XIE2PFT_SEL_TASK_R",
    "XIF001BT_CRITERIA_LIMIT")
     AND di.info_char="INDEX"
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->message = build(errmsg," - Readme Failed trying to remove DM_INFO rows")
    GO TO exit_script
   ENDIF
   COMMIT
   CALL echo("Removing Table Rows from DM_INFO for un-obsoleted objects...")
   DELETE  FROM dm_info di
    WHERE di.info_domain="OBSOLETE_OBJECT"
     AND di.info_name IN ("SELECTED_TASK", "TASK_AVAILABLE", "TASK_CRITERIA", "PFT_PRORATE_EXCLUDE",
    "BT_CRITERIA_LIMIT",
    "PFT_SEL_TASK_R", "CQM_STDBATCH_TR_1", "CQM_STDBATCH_QUE")
     AND di.info_char="TABLE"
   ;end delete
   DELETE  FROM dm_info di
    WHERE di.info_domain="OBSOLETE_OBJECT"
     AND di.info_name IN (
    (SELECT
     dtc2.suffixed_table_name
     FROM dm_tables_doc dtc2
     WHERE dtc2.table_name IN ("SELECTED_TASK", "TASK_AVAILABLE", "TASK_CRITERIA",
     "PFT_PRORATE_EXCLUDE", "BT_CRITERIA_LIMIT",
     "PFT_SEL_TASK_R", "CQM_STDBATCH_TR_1", "CQM_STDBATCH_QUE")))
     AND di.info_char="TABLE"
   ;end delete
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->message = build(errmsg," - Readme Failed trying to remove DM_INFO rows")
    GO TO exit_script
   ENDIF
   COMMIT
   CALL echo("Updating DM_INDEXES_DOC for un-obsoleted indexes...")
   UPDATE  FROM dm_indexes_doc dic
    SET dic.updt_dt_tm = cnvtdatetime(curdate,curtime3), dic.updt_task = reqinfo->updt_task, dic
     .drop_ind = 0
    WHERE dic.index_name IN ("XIF001SELECTED_TASK", "XIF001TASK_CRITERIA", "XPKBT_CRITERIA_LIMIT",
    "XPKPFT_PRORATE_EXCLUDE", "XPKPFT_SEL_TASK_R",
    "XPKSELECTED_TASK", "XPKTASK_AVAILABLE", "XPKTASK_CRITERIA", "XIE1CQM_STDBATCH_QUE",
    "XIE1CQM_STDBATCH_QUE",
    "XIE2CQM_STDBATCH_QUE", "XIE2CQM_STDBATCH_QUE", "XPKCQM_STDBATCH_QUE", "XIE1CQM_STDBATCH_TR_1",
    "XIE1CQM_STDBATCH_TR_1",
    "XFK1CQM_STDBATCH_TR_1", "XPKCQM_STDBATCH_TR_1")
     AND dic.drop_ind=1
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->message = build("Readme Failed trying to update DM_INDEXES_DOC rows:",errmsg)
    GO TO exit_script
   ENDIF
   COMMIT
   CALL echo("Updating DM_TABLES_DOC for un-obsoleted tables...")
   UPDATE  FROM dm_tables_doc dtc
    SET dtc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dtc.updt_task = reqinfo->updt_task, dtc
     .drop_ind = 0
    WHERE dtc.table_name IN ("SELECTED_TASK", "TASK_AVAILABLE", "TASK_CRITERIA",
    "PFT_PRORATE_EXCLUDE", "BT_CRITERIA_LIMIT",
    "PFT_SEL_TASK_R", "CQM_STDBATCH_TR_1", "CQM_STDBATCH_QUE")
     AND dtc.drop_ind=1
    WITH nocounter
   ;end update
   UPDATE  FROM dm_tables_doc dtc
    SET dtc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dtc.updt_task = reqinfo->updt_task, dtc
     .drop_ind = 0
    WHERE dtc.table_name IN (
    (SELECT
     dtc2.suffixed_table_name
     FROM dm_tables_doc dtc2
     WHERE dtc2.table_name IN ("SELECTED_TASK", "TASK_AVAILABLE", "TASK_CRITERIA",
     "PFT_PRORATE_EXCLUDE", "BT_CRITERIA_LIMIT",
     "PFT_SEL_TASK_R", "CQM_STDBATCH_TR_1", "CQM_STDBATCH_QUE")))
     AND dtc.drop_ind=1
    WITH nocounter
   ;end update
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET readme_data->message = build(errmsg," - Readme Failed trying to udpate DM_TABLES_DOC rows")
    GO TO exit_script
   ENDIF
   COMMIT
   INSERT  FROM dm_info
    SET info_domain = "DATA MANAGEMENT", info_name = ver_str, updt_dt_tm = cnvtdatetime(curdate,
      curtime3),
     updt_task = reqinfo->updt_task
   ;end insert
   SET readme_data->status = "S"
   SET readme_data->message =
   "Obsolesced Constraints, Indexes, Triggers, and Tables were dropped successfully"
   COMMIT
  ELSE
   SET readme_data->status = "S"
   SET readme_data->message =
   "This version of consolidated obs objs has already executed successfully"
  ENDIF
 ELSEIF (currdb="DB2UDB")
  SET readme_data->status = "S"
  SET readme_data->message = "Auto-success for DB2 database"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 CALL echo(ver_str)
 CALL echorecord(readme_data)
END GO
