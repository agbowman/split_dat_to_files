CREATE PROGRAM dm_obsolete_tables_80:dba
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
  DECLARE tmpstr = vc
  DECLARE droptotal = i4
  DECLARE xx = i4
  DECLARE yy = i4
  DECLARE parse_str = vc
  DECLARE failedcnt = i4
  DECLARE successcnt = i4
  DECLARE recordcnt = i4
  SET recordcnt = 300
  SET errmsg = fillstring(132," ")
  SET errcode = 0
  SET droptotal = 0
  SET xx = 0
  SET yy = 0
  SET failedcnt = 0
  SET successcnt = 0
  EXECUTE dm_readme_status
  RECORD tmp(
    1 qual[*]
      2 table_name = vc
      2 drop_ind = i2
      2 err_code = i4
      2 err_msg = vc
  )
  SET stat = alterlist(tmp->qual,recordcnt)
  SET tmp->qual[1].table_name = "MMI_MICROBIOLOGY"
  SET tmp->qual[1].drop_ind = - (1)
  SET tmp->qual[2].table_name = "MMI_IC_CAND_ST"
  SET tmp->qual[2].drop_ind = - (1)
  SET tmp->qual[3].table_name = "AP_ACTIVITY_TYPE"
  SET tmp->qual[3].drop_ind = - (1)
  SET tmp->qual[4].table_name = "CASE_NUMBER_DB"
  SET tmp->qual[4].drop_ind = - (1)
  SET tmp->qual[5].table_name = "CASE_SPECIMEN_ADDL_INFO"
  SET tmp->qual[5].drop_ind = - (1)
  SET tmp->qual[6].table_name = "CASSETTE_SLIDE_R"
  SET tmp->qual[6].drop_ind = - (1)
  SET tmp->qual[7].table_name = "SPECIMEN_CASSETTE_R"
  SET tmp->qual[7].drop_ind = - (1)
  SET tmp->qual[8].table_name = "CHART_PPR_FORMAT"
  SET tmp->qual[8].drop_ind = - (1)
  SET tmp->qual[9].table_name = "CHART_VISITLIST_FORMAT"
  SET tmp->qual[9].drop_ind = - (1)
  SET tmp->qual[10].table_name = "CV_ACC_PERSON"
  SET tmp->qual[10].drop_ind = - (1)
  SET tmp->qual[11].table_name = "SI_DATA_MAP"
  SET tmp->qual[11].drop_ind = - (1)
  SET tmp->qual[12].table_name = "SI_ESIRTL_MSG_MAP_R"
  SET tmp->qual[12].drop_ind = - (1)
  SET tmp->qual[13].table_name = "QC_INC_COMPONENT"
  SET tmp->qual[13].drop_ind = - (1)
  SET tmp->qual[14].table_name = "QC_INST_R"
  SET tmp->qual[14].drop_ind = - (1)
  SET tmp->qual[15].table_name = "QC_RUN_INFO"
  SET tmp->qual[15].drop_ind = - (1)
  SET tmp->qual[16].table_name = "QC_STAT_PERIOD_ELEMENT"
  SET tmp->qual[16].drop_ind = - (1)
  SET tmp->qual[17].table_name = "RUN_PERIOD"
  SET tmp->qual[17].drop_ind = - (1)
  SET tmp->qual[18].table_name = "RUN_PERIOD_QC"
  SET tmp->qual[18].drop_ind = - (1)
  SET tmp->qual[19].table_name = "INSTR_EVENT_LOG"
  SET tmp->qual[19].drop_ind = - (1)
  SET tmp->qual[20].table_name = "QC_CYCLE_CTRL"
  SET tmp->qual[20].drop_ind = - (1)
  SET tmp->qual[21].table_name = "QC_CYCLE_STEP"
  SET tmp->qual[21].drop_ind = - (1)
  SET tmp->qual[22].table_name = "QC_CYCLE"
  SET tmp->qual[22].drop_ind = - (1)
  SET tmp->qual[23].table_name = "CYCLE_CTRL"
  SET tmp->qual[23].drop_ind = - (1)
  SET tmp->qual[24].table_name = "CYCLE_STEP"
  SET tmp->qual[24].drop_ind = - (1)
  SET tmp->qual[25].table_name = "CYCLE_QC_REQUIRED"
  SET tmp->qual[25].drop_ind = - (1)
  SET tmp->qual[26].table_name = "CYCLE_CTRL_QC"
  SET tmp->qual[26].drop_ind = - (1)
  SET tmp->qual[27].table_name = "CYCLE_STEP_QC"
  SET tmp->qual[27].drop_ind = - (1)
  SET tmp->qual[28].table_name = "CYCLE_QC"
  SET tmp->qual[28].drop_ind = - (1)
  SET tmp->qual[29].table_name = "CYCLE_SETUP"
  SET tmp->qual[29].drop_ind = - (1)
  SET tmp->qual[30].table_name = "MIC_AR_ORGANISM"
  SET tmp->qual[30].drop_ind = - (1)
  SET tmp->qual[31].table_name = "MIC_AR_ORGANISM_ID"
  SET tmp->qual[31].drop_ind = - (1)
  SET tmp->qual[32].table_name = "MIC_AR_REPORT"
  SET tmp->qual[32].drop_ind = - (1)
  SET tmp->qual[33].table_name = "MIC_AR_SUSCEPTIBILITY"
  SET tmp->qual[33].drop_ind = - (1)
  SET tmp->qual[34].table_name = "MIC_AR_BIOCHEMICAL"
  SET tmp->qual[34].drop_ind = - (1)
  SET tmp->qual[35].table_name = "MIC_AR_LOG_ORGANISM"
  SET tmp->qual[35].drop_ind = - (1)
  SET tmp->qual[36].table_name = "MIC_AR_TASK"
  SET tmp->qual[36].drop_ind = - (1)
  SET tmp->qual[37].table_name = "MIC_AR_CONTAINER"
  SET tmp->qual[37].drop_ind = - (1)
  SET tmp->qual[38].table_name = "MIC_AR_MEDIA"
  SET tmp->qual[38].drop_ind = - (1)
  SET tmp->qual[39].table_name = "MIC_AR_ORDER"
  SET tmp->qual[39].drop_ind = - (1)
  SET tmp->qual[40].table_name = "MIC_AR_LOG_SUSCEPTIBILITY"
  SET tmp->qual[40].drop_ind = - (1)
  SET tmp->qual[41].table_name = "MIC_AR_PERSON"
  SET tmp->qual[41].drop_ind = - (1)
  SET tmp->qual[42].table_name = "MIC_BREAKPOINT_DILUTION"
  SET tmp->qual[42].drop_ind = - (1)
  SET tmp->qual[43].table_name = "MIC_SORT_FIELD"
  SET tmp->qual[43].drop_ind = - (1)
  SET tmp->qual[44].table_name = "MIC_SORT_ITEM"
  SET tmp->qual[44].drop_ind = - (1)
  SET tmp->qual[45].table_name = "MIC_FIELD_REFERENCE"
  SET tmp->qual[45].drop_ind = - (1)
  SET tmp->qual[46].table_name = "MIC_GROUP_RESPONSE_RPTS"
  SET tmp->qual[46].drop_ind = - (1)
  SET tmp->qual[47].table_name = "MIC_SUS_CHARGES"
  SET tmp->qual[47].drop_ind = - (1)
  SET tmp->qual[48].table_name = "MIC_PREFERENCES"
  SET tmp->qual[48].drop_ind = - (1)
  SET tmp->qual[49].table_name = "MIC_SEQUENCE_ITEM"
  SET tmp->qual[49].drop_ind = - (1)
  SET tmp->qual[50].table_name = "MIC_SORT_SEQ"
  SET tmp->qual[50].drop_ind = - (1)
  SET tmp->qual[51].table_name = "MIC_STAT_ATTRIBUTE"
  SET tmp->qual[51].drop_ind = - (1)
  SET tmp->qual[52].table_name = "MIC_STAT_CELL"
  SET tmp->qual[52].drop_ind = - (1)
  SET tmp->qual[53].table_name = "MIC_STAT_FIELD"
  SET tmp->qual[53].drop_ind = - (1)
  SET tmp->qual[54].table_name = "MIC_STAT_FIELD_EXT"
  SET tmp->qual[54].drop_ind = - (1)
  SET tmp->qual[55].table_name = "MIC_STAT_FILTER_EXT"
  SET tmp->qual[55].drop_ind = - (1)
  SET tmp->qual[56].table_name = "MIC_STAT_FILTER"
  SET tmp->qual[56].drop_ind = - (1)
  SET tmp->qual[57].table_name = "MIC_STAT_SELECT"
  SET tmp->qual[57].drop_ind = - (1)
  SET tmp->qual[58].table_name = "MIC_STAT_REQUEST"
  SET tmp->qual[58].drop_ind = - (1)
  SET tmp->qual[59].table_name = "MIC_STAT_STATUS"
  SET tmp->qual[59].drop_ind = - (1)
  SET tmp->qual[60].table_name = "MIC_STAT_STYLE"
  SET tmp->qual[60].drop_ind = - (1)
  SET tmp->qual[61].table_name = "MIC_STAT_MCU"
  SET tmp->qual[61].drop_ind = - (1)
  SET tmp->qual[62].table_name = "MIC_STAT_REPORT"
  SET tmp->qual[62].drop_ind = - (1)
  SET tmp->qual[63].table_name = "MIC_STAT_REPORT_TYPE"
  SET tmp->qual[63].drop_ind = - (1)
  SET tmp->qual[64].table_name = "MIC_STAT_START"
  SET tmp->qual[64].drop_ind = - (1)
  SET tmp->qual[65].table_name = "MIC_STAT_START_CHILD"
  SET tmp->qual[65].drop_ind = - (1)
  SET tmp->qual[66].table_name = "MIC_STAT_STD_FIELD"
  SET tmp->qual[66].drop_ind = - (1)
  SET tmp->qual[67].table_name = "MIC_STAT_TABLE"
  SET tmp->qual[67].drop_ind = - (1)
  SET tmp->qual[68].table_name = "MIC_STAT_TEMPLATE_FILTER_R"
  SET tmp->qual[68].drop_ind = - (1)
  SET tmp->qual[69].table_name = "MIC_TEMP_SEQ"
  SET tmp->qual[69].drop_ind = - (1)
  SET tmp->qual[70].table_name = "FILL_BATCH_INGR_HX"
  SET tmp->qual[70].drop_ind = - (1)
  SET tmp->qual[71].table_name = "FILL_BATCH_ORD_HX"
  SET tmp->qual[71].drop_ind = - (1)
  SET tmp->qual[72].table_name = "FILL_BATCH_PROD_HX"
  SET tmp->qual[72].drop_ind = - (1)
  SET tmp->qual[73].table_name = "FILL_BATCH_RUN_HX"
  SET tmp->qual[73].drop_ind = - (1)
  SET tmp->qual[74].table_name = "FORMULARY_HP_R"
  SET tmp->qual[74].drop_ind = - (1)
  SET tmp->qual[75].table_name = "INGREDIENT_DETAIL"
  SET tmp->qual[75].drop_ind = - (1)
  SET tmp->qual[76].table_name = "MEDICATION_CLASS"
  SET tmp->qual[76].drop_ind = - (1)
  SET tmp->qual[77].table_name = "PHA_RANGE"
  SET tmp->qual[77].drop_ind = - (1)
  SET tmp->qual[78].table_name = "PROFILE_PV_CHART"
  SET tmp->qual[78].drop_ind = - (1)
  SET tmp->qual[79].table_name = "PROFILE_PV_DOCUMENT"
  SET tmp->qual[79].drop_ind = - (1)
  SET tmp->qual[80].table_name = "PROFILE_PV_PHYSICIAN"
  SET tmp->qual[80].drop_ind = - (1)
  SET tmp->qual[81].table_name = "ROI_REQUEST_PATIENT"
  SET tmp->qual[81].drop_ind = - (1)
  SET tmp->qual[82].table_name = "ACCT_ADJ_RELTN"
  SET tmp->qual[82].drop_ind = - (1)
  SET tmp->qual[83].table_name = "ACCT_CHARGE_RELTN"
  SET tmp->qual[83].drop_ind = - (1)
  SET tmp->qual[84].table_name = "ACCT_CONSOLIDATION"
  SET tmp->qual[84].drop_ind = - (1)
  SET tmp->qual[85].table_name = "ACCT_CORSP_RELTN"
  SET tmp->qual[85].drop_ind = - (1)
  SET tmp->qual[86].table_name = "ACCT_GL_TRANS_RELTN"
  SET tmp->qual[86].drop_ind = - (1)
  SET tmp->qual[87].table_name = "ACCT_ORG_RELTN"
  SET tmp->qual[87].drop_ind = - (1)
  SET tmp->qual[88].table_name = "ACCT_PAYMENT_RELTN"
  SET tmp->qual[88].drop_ind = - (1)
  SET tmp->qual[89].table_name = "ACCT_PERSON_RELTN"
  SET tmp->qual[89].drop_ind = - (1)
  SET tmp->qual[90].table_name = "ACT_ACT_RELTN"
  SET tmp->qual[90].drop_ind = - (1)
  SET tmp->qual[91].table_name = "ACTIVITY_ACCT_RELTN"
  SET tmp->qual[91].drop_ind = - (1)
  SET tmp->qual[92].table_name = "ASB_RULE"
  SET tmp->qual[92].drop_ind = - (1)
  SET tmp->qual[93].table_name = "ASB_TERTIARY_RULE"
  SET tmp->qual[93].drop_ind = - (1)
  SET tmp->qual[94].table_name = "BATCH_CORSP_RELTN"
  SET tmp->qual[94].drop_ind = - (1)
  SET tmp->qual[95].table_name = "BE_DEPACCT_RELTN"
  SET tmp->qual[95].drop_ind = - (1)
  SET tmp->qual[96].table_name = "BILL_PERSON_RELTN"
  SET tmp->qual[96].drop_ind = - (1)
  SET tmp->qual[97].table_name = "BT_FIELD_PATTERN_R"
  SET tmp->qual[97].drop_ind = - (1)
  SET tmp->qual[98].table_name = "CHARGE_JOURNAL"
  SET tmp->qual[98].drop_ind = - (1)
  SET tmp->qual[99].table_name = "CHARGE_JOURNAL_MOD"
  SET tmp->qual[99].drop_ind = - (1)
  SET tmp->qual[100].table_name = "CLAIM_STRUCT"
  SET tmp->qual[100].drop_ind = - (1)
  SET tmp->qual[101].table_name = "CORSP_CORSP_RELTN"
  SET tmp->qual[101].drop_ind = - (1)
  SET tmp->qual[102].table_name = "CSI_TPM_RELTN"
  SET tmp->qual[102].drop_ind = - (1)
  SET tmp->qual[103].table_name = "FIELD_PATTERN"
  SET tmp->qual[103].drop_ind = - (1)
  SET tmp->qual[104].table_name = "FIELD_GROUPING"
  SET tmp->qual[104].drop_ind = - (1)
  SET tmp->qual[105].table_name = "TEMPLATE_FIELD_RELTN"
  SET tmp->qual[105].drop_ind = - (1)
  SET tmp->qual[106].table_name = "DOCUMENT_FIELD"
  SET tmp->qual[106].drop_ind = - (1)
  SET tmp->qual[107].table_name = "TEMPL_FIELD_HIST_R"
  SET tmp->qual[107].drop_ind = - (1)
  SET tmp->qual[108].table_name = "DOC_TEMPLATE_HIST"
  SET tmp->qual[108].drop_ind = - (1)
  SET tmp->qual[109].table_name = "DOC_TEMPLATE"
  SET tmp->qual[109].drop_ind = - (1)
  SET tmp->qual[110].table_name = "TPM"
  SET tmp->qual[110].drop_ind = - (1)
  SET tmp->qual[111].table_name = "GL_ACCT_UNIT_FLD_R"
  SET tmp->qual[111].drop_ind = - (1)
  SET tmp->qual[112].table_name = "GL_COMP_UNIT_FLD_R"
  SET tmp->qual[112].drop_ind = - (1)
  SET tmp->qual[113].table_name = "GL_COMP_UNIT_FLD_RESULT"
  SET tmp->qual[113].drop_ind = - (1)
  SET tmp->qual[114].table_name = "GL_INTERFACE"
  SET tmp->qual[114].drop_ind = - (1)
  SET tmp->qual[115].table_name = "INV_STRUCT"
  SET tmp->qual[115].drop_ind = - (1)
  SET tmp->qual[116].table_name = "PAY_SESSION_LOG"
  SET tmp->qual[116].drop_ind = - (1)
  SET tmp->qual[117].table_name = "PE_BO_RELTN"
  SET tmp->qual[117].drop_ind = - (1)
  SET tmp->qual[118].table_name = "PE_TRANS_RELTN"
  SET tmp->qual[118].drop_ind = - (1)
  SET tmp->qual[119].table_name = "PFT_CLAIM"
  SET tmp->qual[119].drop_ind = - (1)
  SET tmp->qual[120].table_name = "PFT_INVOICE"
  SET tmp->qual[120].drop_ind = - (1)
  SET tmp->qual[121].table_name = "PFT_MESSAGE"
  SET tmp->qual[121].drop_ind = - (1)
  SET tmp->qual[122].table_name = "PFT_OBJ_VRSN"
  SET tmp->qual[122].drop_ind = - (1)
  SET tmp->qual[123].table_name = "PFT_PRSNL_GRP_ALIAS"
  SET tmp->qual[123].drop_ind = - (1)
  SET tmp->qual[124].table_name = "PFT_STATEMENT"
  SET tmp->qual[124].drop_ind = - (1)
  SET tmp->qual[125].table_name = "PRSNL_ALIAS_HP_R"
  SET tmp->qual[125].drop_ind = - (1)
  SET tmp->qual[126].table_name = "PRSNL_GRP_ALIAS_HP_R"
  SET tmp->qual[126].drop_ind = - (1)
  SET tmp->qual[127].table_name = "STMT_STRUCT"
  SET tmp->qual[127].drop_ind = - (1)
  SET tmp->qual[128].table_name = "TPM_ADJ_PAY_HIST"
  SET tmp->qual[128].drop_ind = - (1)
  SET tmp->qual[129].table_name = "TPM_ADJ_PAY_RULE"
  SET tmp->qual[129].drop_ind = - (1)
  SET tmp->qual[130].table_name = "TPM_FIELD_CAT"
  SET tmp->qual[130].drop_ind = - (1)
  SET tmp->qual[131].table_name = "TPM_FIELD_VALUE"
  SET tmp->qual[131].drop_ind = - (1)
  SET tmp->qual[132].table_name = "TPM_ROOT_CONDITION"
  SET tmp->qual[132].drop_ind = - (1)
  SET tmp->qual[133].table_name = "TPM_ROOT_HIST"
  SET tmp->qual[133].drop_ind = - (1)
  SET tmp->qual[134].table_name = "TPM_RULE"
  SET tmp->qual[134].drop_ind = - (1)
  SET tmp->qual[135].table_name = "TPM_RULE_HIST"
  SET tmp->qual[135].drop_ind = - (1)
  SET tmp->qual[136].table_name = "TRANS_BO_RELTN"
  SET tmp->qual[136].drop_ind = - (1)
  SET tmp->qual[137].table_name = "TRANS_BR_RELTN"
  SET tmp->qual[137].drop_ind = - (1)
  SET tmp->qual[138].table_name = "TRANS_CORSP_RELTN"
  SET tmp->qual[138].drop_ind = - (1)
  SET tmp->qual[139].table_name = "TRANS_GROUP_RELTN"
  SET tmp->qual[139].drop_ind = - (1)
  SET tmp->qual[140].table_name = "TRANS_GROUP"
  SET tmp->qual[140].drop_ind = - (1)
  SET tmp->qual[141].table_name = "SENDING_METHOD"
  SET tmp->qual[141].drop_ind = - (1)
  SET tmp->qual[142].table_name = "JOURNAL_BO_RELTN"
  SET tmp->qual[142].drop_ind = - (1)
  SET tmp->qual[143].table_name = "BE_GEN_RELTN"
  SET tmp->qual[143].drop_ind = - (1)
  SET tmp->qual[144].table_name = "BE_GL_COMPANY_RELTN"
  SET tmp->qual[144].drop_ind = - (1)
  SET tmp->qual[145].table_name = "BE_PRSNL_RELTN"
  SET tmp->qual[145].drop_ind = - (1)
  SET tmp->qual[146].table_name = "BE_SUBMIT_RELTN"
  SET tmp->qual[146].drop_ind = - (1)
  SET tmp->qual[147].table_name = "BILL_GEN_SCHED"
  SET tmp->qual[147].drop_ind = - (1)
  SET tmp->qual[148].table_name = "BILL_SUBMIT_LOG"
  SET tmp->qual[148].drop_ind = - (1)
  SET tmp->qual[149].table_name = "BO_BILL_RELTN"
  SET tmp->qual[149].drop_ind = - (1)
  SET tmp->qual[150].table_name = "CORSP_BE_RELTN"
  SET tmp->qual[150].drop_ind = - (1)
  SET tmp->qual[151].table_name = "CORSP_ENCNTR_RELTN"
  SET tmp->qual[151].drop_ind = - (1)
  SET tmp->qual[152].table_name = "CORSP_HP_RELTN"
  SET tmp->qual[152].drop_ind = - (1)
  SET tmp->qual[153].table_name = "CORSP_ORG_RELTN"
  SET tmp->qual[153].drop_ind = - (1)
  SET tmp->qual[154].table_name = "CORSP_PERSON_RELTN"
  SET tmp->qual[154].drop_ind = - (1)
  SET tmp->qual[155].table_name = "CORSP_PRSNL_RELTN"
  SET tmp->qual[155].drop_ind = - (1)
  SET tmp->qual[156].table_name = "CORSP_SESSION_RELTN"
  SET tmp->qual[156].drop_ind = - (1)
  SET tmp->qual[157].table_name = "CSI_EXCEPTION_LOG"
  SET tmp->qual[157].drop_ind = - (1)
  SET tmp->qual[158].table_name = "GL_ACCT_FIELD_RESULT"
  SET tmp->qual[158].drop_ind = - (1)
  SET tmp->qual[159].table_name = "GL_ACCT_FIELD_RELTN"
  SET tmp->qual[159].drop_ind = - (1)
  SET tmp->qual[160].table_name = "GL_ACCOUNT_ALIAS"
  SET tmp->qual[160].drop_ind = - (1)
  SET tmp->qual[161].table_name = "GL_ACCT_TYPE_RELTN"
  SET tmp->qual[161].drop_ind = - (1)
  SET tmp->qual[162].table_name = "GL_ACCT_UNIT_FLD_RESULT"
  SET tmp->qual[162].drop_ind = - (1)
  SET tmp->qual[163].table_name = "GL_ACCT_UNIT_FLD_RELTN"
  SET tmp->qual[163].drop_ind = - (1)
  SET tmp->qual[164].table_name = "GL_ACCT_UNIT_ALIAS"
  SET tmp->qual[164].drop_ind = - (1)
  SET tmp->qual[165].table_name = "GL_COMP_UNIT_FLD_RELTN"
  SET tmp->qual[165].drop_ind = - (1)
  SET tmp->qual[166].table_name = "GL_COMPANY_UNIT_ALIAS"
  SET tmp->qual[166].drop_ind = - (1)
  SET tmp->qual[167].table_name = "GL_COMPANY_ALIAS"
  SET tmp->qual[167].drop_ind = - (1)
  SET tmp->qual[168].table_name = "BT_COND_RESULT_R"
  SET tmp->qual[168].drop_ind = - (1)
  SET tmp->qual[169].table_name = "BT_COND_RESULT"
  SET tmp->qual[169].drop_ind = - (1)
  SET tmp->qual[170].table_name = "BILL_SUBMIT_SCHED"
  SET tmp->qual[170].drop_ind = - (1)
  SET tmp->qual[171].table_name = "PURGE_SETUP_JOB_TOKENS"
  SET tmp->qual[171].drop_ind = - (1)
  SET tmp->qual[172].table_name = "PURGE_JOB_LOG"
  SET tmp->qual[172].drop_ind = - (1)
  SET tmp->qual[173].table_name = "PURGE_SETUP_JOB"
  SET tmp->qual[173].drop_ind = - (1)
  SET tmp->qual[174].table_name = "PURGE_JOB_TOKENS"
  SET tmp->qual[174].drop_ind = - (1)
  SET tmp->qual[175].table_name = "PURGE_TOKEN_TYPE"
  SET tmp->qual[175].drop_ind = - (1)
  SET tmp->qual[176].table_name = "PURGE_CRITERIA"
  SET tmp->qual[176].drop_ind = - (1)
  SET tmp->qual[177].table_name = "PURGE_JOB"
  SET tmp->qual[177].drop_ind = - (1)
  SET tmp->qual[178].table_name = "REPORT_DISTRIBUTION_LOG"
  SET tmp->qual[178].drop_ind = - (1)
  SET tmp->qual[179].table_name = "REQUEST_QUEUE"
  SET tmp->qual[179].drop_ind = - (1)
  SET tmp->qual[180].table_name = "SENDING_STATISTICS"
  SET tmp->qual[180].drop_ind = - (1)
  SET tmp->qual[181].table_name = "SCR_PATTERN_INDICATION"
  SET tmp->qual[181].drop_ind = - (1)
  SET tmp->qual[182].table_name = "SCH_EVENT_WARN"
  SET tmp->qual[182].drop_ind = - (1)
  SET tmp->qual[183].table_name = "SCH_EVENT_WARNING"
  SET tmp->qual[183].drop_ind = - (1)
  SET tmp->qual[184].table_name = "REQUEST_GROUP"
  SET tmp->qual[184].drop_ind = - (1)
  SET tmp->qual[185].table_name = "CASE_ATTENDANCE_PROCEDURE"
  SET tmp->qual[185].drop_ind = - (1)
  SET tmp->qual[186].table_name = "CASE_BOARD_EXTRACT"
  SET tmp->qual[186].drop_ind = - (1)
  SET tmp->qual[187].table_name = "CASE_BOARD_PARAMS"
  SET tmp->qual[187].drop_ind = - (1)
  SET tmp->qual[188].table_name = "CASE_CART_COMMENTS"
  SET tmp->qual[188].drop_ind = - (1)
  SET tmp->qual[189].table_name = "CASE_CART_ITEM"
  SET tmp->qual[189].drop_ind = - (1)
  SET tmp->qual[190].table_name = "CASE_CART_LOT_NUMBER"
  SET tmp->qual[190].drop_ind = - (1)
  SET tmp->qual[191].table_name = "CASE_CART_MED"
  SET tmp->qual[191].drop_ind = - (1)
  SET tmp->qual[192].table_name = "CASE_CART_SERIAL_NUMBER"
  SET tmp->qual[192].drop_ind = - (1)
  SET tmp->qual[193].table_name = "CASE_CART_WASTAGE"
  SET tmp->qual[193].drop_ind = - (1)
  SET tmp->qual[194].table_name = "CASE_DICTATION_STATUS"
  SET tmp->qual[194].drop_ind = - (1)
  SET tmp->qual[195].table_name = "DOCUMENTATION_AREA"
  SET tmp->qual[195].drop_ind = - (1)
  SET tmp->qual[196].table_name = "EQUIPMENT_SETTINGS"
  SET tmp->qual[196].drop_ind = - (1)
  SET tmp->qual[197].table_name = "EQUIPMENT_SETTINGS_PROCEDURE"
  SET tmp->qual[197].drop_ind = - (1)
  SET tmp->qual[198].table_name = "EQUIPMENT_USAGE"
  SET tmp->qual[198].drop_ind = - (1)
  SET tmp->qual[199].table_name = "EQUIPMENT_USAGE_ACCESSORY"
  SET tmp->qual[199].drop_ind = - (1)
  SET tmp->qual[200].table_name = "EQUIPMENT_USAGE_TIMES"
  SET tmp->qual[200].drop_ind = - (1)
  SET tmp->qual[201].table_name = "EXPLANT_CASE_DETAILS"
  SET tmp->qual[201].drop_ind = - (1)
  SET tmp->qual[202].table_name = "EXPLANT_PROCEDURE"
  SET tmp->qual[202].drop_ind = - (1)
  SET tmp->qual[203].table_name = "IMPLANT_ACTIVITY"
  SET tmp->qual[203].drop_ind = - (1)
  SET tmp->qual[204].table_name = "IMPLANT_CASE_DETAILS"
  SET tmp->qual[204].drop_ind = - (1)
  SET tmp->qual[205].table_name = "IMPLANT_PROCEDURE"
  SET tmp->qual[205].drop_ind = - (1)
  SET tmp->qual[206].table_name = "IMPLANT_RECEIPT"
  SET tmp->qual[206].drop_ind = - (1)
  SET tmp->qual[207].table_name = "IMPLANT_SALE"
  SET tmp->qual[207].drop_ind = - (1)
  SET tmp->qual[208].table_name = "IMPLANT_TRACKING"
  SET tmp->qual[208].drop_ind = - (1)
  SET tmp->qual[209].table_name = "INTRAOP_COUNT_CATEGORY_STATUS"
  SET tmp->qual[209].drop_ind = - (1)
  SET tmp->qual[210].table_name = "INTRAOP_COUNT_CLASS_STATUS"
  SET tmp->qual[210].drop_ind = - (1)
  SET tmp->qual[211].table_name = "INTRAOP_COUNT_CONFIRM"
  SET tmp->qual[211].drop_ind = - (1)
  SET tmp->qual[212].table_name = "OTHER_IMPLANT_ACTIVITY"
  SET tmp->qual[212].drop_ind = - (1)
  SET tmp->qual[213].table_name = "PERIOP_DOC_COMMENT"
  SET tmp->qual[213].drop_ind = - (1)
  SET tmp->qual[214].table_name = "PREF_CARD_CHANGE_PROPOSAL"
  SET tmp->qual[214].drop_ind = - (1)
  SET tmp->qual[215].table_name = "PREF_CARD_CHANGE_RESPONSE"
  SET tmp->qual[215].drop_ind = - (1)
  SET tmp->qual[216].table_name = "PREF_CARD_ITEM"
  SET tmp->qual[216].drop_ind = - (1)
  SET tmp->qual[217].table_name = "PREF_CARD_MED"
  SET tmp->qual[217].drop_ind = - (1)
  SET tmp->qual[218].table_name = "PREFERENCE_CARD_RECENT_AVERAGE"
  SET tmp->qual[218].drop_ind = - (1)
  SET tmp->qual[219].table_name = "PREFERENCE_CARD_TEXT"
  SET tmp->qual[219].drop_ind = - (1)
  SET tmp->qual[220].table_name = "PREOP_POSTOP_DIAGNOSIS"
  SET tmp->qual[220].drop_ind = - (1)
  SET tmp->qual[221].table_name = "SPECIMEN_CULTURE_PROCEDURE"
  SET tmp->qual[221].drop_ind = - (1)
  SET tmp->qual[222].table_name = "SPECIMENS_CULTURES"
  SET tmp->qual[222].drop_ind = - (1)
  SET tmp->qual[223].table_name = "SURG_PROC_GROUP_DETAIL"
  SET tmp->qual[223].drop_ind = - (1)
  SET tmp->qual[224].table_name = "SURG_PROC_PERF_MODIFIER"
  SET tmp->qual[224].drop_ind = - (1)
  SET tmp->qual[225].table_name = "SURGERY_RESULT_PERSONNEL"
  SET tmp->qual[225].drop_ind = - (1)
  SET tmp->qual[226].table_name = "SURGICAL_CONSENTS"
  SET tmp->qual[226].drop_ind = - (1)
  SET tmp->qual[227].table_name = "SURGICAL_DELAY_PROCEDURE"
  SET tmp->qual[227].drop_ind = - (1)
  SET tmp->qual[228].table_name = "SURGICAL_OCCURRENCE"
  SET tmp->qual[228].drop_ind = - (1)
  SET tmp->qual[229].table_name = "SURGICAL_OCCURRENCE_PROCEDURE"
  SET tmp->qual[229].drop_ind = - (1)
  SET tmp->qual[230].table_name = "SURGICAL_PROCEDURE_GROUP"
  SET tmp->qual[230].drop_ind = - (1)
  SET tmp->qual[231].table_name = "SURGICAL_PROCEDURES_PERFORMED"
  SET tmp->qual[231].drop_ind = - (1)
  SET tmp->qual[232].table_name = "SCHEDULED_CASE_COMMENTS"
  SET tmp->qual[232].drop_ind = - (1)
  SET tmp->qual[233].table_name = "SCHEDULED_CASE_DETAIL"
  SET tmp->qual[233].drop_ind = - (1)
  SET tmp->qual[234].table_name = "SCHED_PROC_MODIFIER"
  SET tmp->qual[234].drop_ind = - (1)
  SET tmp->qual[235].table_name = "SCHEDULED_CASE_PROCEDURE"
  SET tmp->qual[235].drop_ind = - (1)
  SET tmp->qual[236].table_name = "SEGMENT_LIST_DEFINITION"
  SET tmp->qual[236].drop_ind = - (1)
  SET tmp->qual[237].table_name = "SEGMENT_LIST_REFERENCE"
  SET tmp->qual[237].drop_ind = - (1)
  SET tmp->qual[238].table_name = "SN_REPORT_GROUP_R"
  SET tmp->qual[238].drop_ind = - (1)
  SET tmp->qual[239].table_name = "SN_REPORT"
  SET tmp->qual[239].drop_ind = - (1)
  SET tmp->qual[240].table_name = "SN_REPORT_GROUP"
  SET tmp->qual[240].drop_ind = - (1)
  SET tmp->qual[241].table_name = "INTRAOP_COUNT"
  SET tmp->qual[241].drop_ind = - (1)
  SET tmp->qual[242].table_name = "SURG_PROC_PERF_GROUP"
  SET tmp->qual[242].drop_ind = - (1)
  SET tmp->qual[243].table_name = "LABEL_XREF"
  SET tmp->qual[243].drop_ind = - (1)
  SET tmp->qual[244].table_name = "LABEL_PROGRAM"
  SET tmp->qual[244].drop_ind = - (1)
  SET tmp->qual[245].table_name = "SYS_EVENT"
  SET tmp->qual[245].drop_ind = - (1)
  SET tmp->qual[246].table_name = "SYS_EVENT_DETAIL"
  SET tmp->qual[246].drop_ind = - (1)
  SET tmp->qual[247].table_name = "SYS_MESSAGE"
  SET tmp->qual[247].drop_ind = - (1)
  SET tmp->qual[248].table_name = "SYS_MESSAGE_CATEGORY"
  SET tmp->qual[248].drop_ind = - (1)
  SET tmp->qual[249].table_name = "SYS_OBJECT"
  SET tmp->qual[249].drop_ind = - (1)
  SET tmp->qual[250].table_name = "SYS_OBJECT_OPERATION_R"
  SET tmp->qual[250].drop_ind = - (1)
  SET tmp->qual[251].table_name = "SYS_OPERATION"
  SET tmp->qual[251].drop_ind = - (1)
  SET tmp->qual[252].table_name = "SYS_OPERATION_CATEGORY"
  SET tmp->qual[252].drop_ind = - (1)
  SET tmp->qual[253].table_name = "SYS_REPLY"
  SET tmp->qual[253].drop_ind = - (1)
  SET tmp->qual[254].table_name = "SYS_STATE"
  SET tmp->qual[254].drop_ind = - (1)
  SET tmp->qual[255].table_name = "SYS_STEP"
  SET tmp->qual[255].drop_ind = - (1)
  SET tmp->qual[256].table_name = "SYSEVENT_MNEMONIC"
  SET tmp->qual[256].drop_ind = - (1)
  SET tmp->qual[257].table_name = "SYSEVENT_TOKEN"
  SET tmp->qual[257].drop_ind = - (1)
  SET tmp->qual[258].table_name = "IQH_OLAP_SPON_POP_RELTN"
  SET tmp->qual[258].drop_ind = - (1)
  SET tmp->qual[259].table_name = "IQH_OLAP_SUMMARY_FACT"
  SET tmp->qual[259].drop_ind = - (1)
  SET tmp->qual[260].table_name = "DM_FOR_KEY_EXCEPT"
  SET tmp->qual[260].drop_ind = - (1)
  SET tmp->qual[261].table_name = "DM_INVALID_TABLE_ROWS_EXCEPT"
  SET tmp->qual[261].drop_ind = - (1)
  SET tmp->qual[262].table_name = "OMF_ICD9_DIAGNOSIS_ST"
  SET tmp->qual[262].drop_ind = - (1)
  SET tmp->qual[263].table_name = "OMF_ICD9_PROCEDURE_ST"
  SET tmp->qual[263].drop_ind = - (1)
  SET tmp->qual[264].table_name = "PA_CRITERIA"
  SET tmp->qual[264].drop_ind = - (1)
  SET tmp->qual[265].table_name = "PA_CRITERIA_VALUE"
  SET tmp->qual[265].drop_ind = - (1)
  SET tmp->qual[266].table_name = "PA_LOG"
  SET tmp->qual[266].drop_ind = - (1)
  SET tmp->qual[267].table_name = "PA_REQUEST"
  SET tmp->qual[267].drop_ind = - (1)
  SET tmp->qual[268].table_name = "PA_REQ_DEPENDENCY"
  SET tmp->qual[268].drop_ind = - (1)
  SET tmp->qual[269].table_name = "PA_REQ_INDEX"
  SET tmp->qual[269].drop_ind = - (1)
  SET tmp->qual[270].table_name = "PA_SEARCH_PROCESS"
  SET tmp->qual[270].drop_ind = - (1)
  SET tmp->qual[271].table_name = "PA_CRITERIA_VA1104"
  SET tmp->qual[271].drop_ind = - (1)
  SET tmp->qual[272].table_name = "PA_LOG1108"
  SET tmp->qual[272].drop_ind = - (1)
  SET tmp->qual[273].table_name = "PA_REQUEST1109"
  SET tmp->qual[273].drop_ind = - (1)
  SET tmp->qual[274].table_name = "PA_REQ_DEPENDE1111"
  SET tmp->qual[274].drop_ind = - (1)
  SET tmp->qual[275].table_name = "PA_REQ_INDEX1112"
  SET tmp->qual[275].drop_ind = - (1)
  SET tmp->qual[276].table_name = "PA_SEARCH_PROC1102"
  SET tmp->qual[276].drop_ind = - (1)
  SET tmp->qual[277].table_name = "PA_CRITERIA1103"
  SET tmp->qual[277].drop_ind = - (1)
  SET tmp->qual[278].table_name = "DESIGNATED_REFER"
  SET tmp->qual[278].drop_ind = - (1)
  SET tmp->qual[279].table_name = "DM_FS_FILES"
  SET tmp->qual[279].drop_ind = - (1)
  SET tmp->qual[280].table_name = "MULTUM_CATEGORY_DRUG_XREF"
  SET tmp->qual[280].drop_ind = - (1)
  SET tmp->qual[281].table_name = "MULTUM_CATEGORY_SUB_XREF"
  SET tmp->qual[281].drop_ind = - (1)
  SET tmp->qual[282].table_name = "MULTUM_DOSE_FORM"
  SET tmp->qual[282].drop_ind = - (1)
  SET tmp->qual[283].table_name = "MULTUM_DRUG_CATEGORIES"
  SET tmp->qual[283].drop_ind = - (1)
  SET tmp->qual[284].table_name = "MULTUM_DRUG_ID"
  SET tmp->qual[284].drop_ind = - (1)
  SET tmp->qual[285].table_name = "MULTUM_DRUG_NAME"
  SET tmp->qual[285].drop_ind = - (1)
  SET tmp->qual[286].table_name = "MULTUM_DRUG_NAME_DERIVATION"
  SET tmp->qual[286].drop_ind = - (1)
  SET tmp->qual[287].table_name = "MULTUM_DRUG_NAME_MAP"
  SET tmp->qual[287].drop_ind = - (1)
  SET tmp->qual[288].table_name = "MULTUM_MMDC_NAME_MAP"
  SET tmp->qual[288].drop_ind = - (1)
  SET tmp->qual[289].table_name = "MULTUM_PRODUCT_ROUTE"
  SET tmp->qual[289].drop_ind = - (1)
  SET tmp->qual[290].table_name = "MULTUM_PRODUCT_STRENGTH"
  SET tmp->qual[290].drop_ind = - (1)
  SET tmp->qual[291].table_name = "MULTUM_UNITS"
  SET tmp->qual[291].drop_ind = - (1)
  SET tmp->qual[292].table_name = "NDC_ACTIVE_INGRED_LIST"
  SET tmp->qual[292].drop_ind = - (1)
  SET tmp->qual[293].table_name = "NDC_BRAND_NAME"
  SET tmp->qual[293].drop_ind = - (1)
  SET tmp->qual[294].table_name = "NDC_CORE_DESCRIPTION"
  SET tmp->qual[294].drop_ind = - (1)
  SET tmp->qual[295].table_name = "NDC_COST"
  SET tmp->qual[295].drop_ind = - (1)
  SET tmp->qual[296].table_name = "NDC_MAIN_MULTUM_DRUG_CODE"
  SET tmp->qual[296].drop_ind = - (1)
  SET tmp->qual[297].table_name = "NDC_ORANGE_BOOK"
  SET tmp->qual[297].drop_ind = - (1)
  SET tmp->qual[298].table_name = "NDC_SOURCE"
  SET tmp->qual[298].drop_ind = - (1)
  SET tmp->qual[299].table_name = "LABEL"
  SET tmp->qual[299].drop_ind = - (1)
  SET tmp->qual[300].table_name = "LABEL_DRUG_XREF"
  SET tmp->qual[300].drop_ind = - (1)
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
   SET readme_data->message = build(errmsg,"- Readme FAILURE. Check dm_obsolete_tables_80.log")
   SET readme_data->status = "F"
  ELSE
   SET readme_data->message = build(errmsg,"- Readme SUCCESS. Check dm_obsolete_tables_80.log")
   SET readme_data->status = "S"
  ENDIF
  CALL echo(readme_data->message)
  SELECT INTO "dm_obsolete_tables_80.log"
   d.seq
   FROM dummyt d
   FOOT REPORT
    "***********************************************************************", row + 1
    IF (droptotal=recordcnt)
     "  TRACE LOG - DM_DROP_OBSOLETE_TABLES_80: SUCCESS"
    ELSE
     "  TRACE LOG - DM_DROP_OBSOLETE_TABLES_80: FAILURE"
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
  SET readme_data->message = "Auto-success, obsolete tables 8.0 only for Oracle"
 ENDIF
#end_program
 EXECUTE dm_readme_status
 IF (currdb="ORACLE")
  FREE RECORD tmp
 ENDIF
END GO
