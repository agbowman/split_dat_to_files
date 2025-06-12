CREATE PROGRAM dm_obsolete_tables_83_2:dba
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
  SET recordcnt = 82
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
  SET tmp->qual[1].table_name = "OMF_ABS_DAYS"
  SET tmp->qual[1].drop_ind = - (1)
  SET tmp->qual[2].table_name = "OMF_GRID_GROUPING"
  SET tmp->qual[2].drop_ind = - (1)
  SET tmp->qual[3].table_name = "OMF_GRID_INDICATOR"
  SET tmp->qual[3].drop_ind = - (1)
  SET tmp->qual[4].table_name = "OMF_INDICATOR_GROUP"
  SET tmp->qual[4].drop_ind = - (1)
  SET tmp->qual[5].table_name = "OMF_INDICATOR_GROUPING"
  SET tmp->qual[5].drop_ind = - (1)
  SET tmp->qual[6].table_name = "OMF_PRODUCT_QUEUE"
  SET tmp->qual[6].drop_ind = - (1)
  SET tmp->qual[7].table_name = "OMF_TIME_BLOCK"
  SET tmp->qual[7].drop_ind = - (1)
  SET tmp->qual[8].table_name = "OMF_TIME_BLOCK_DTL"
  SET tmp->qual[8].drop_ind = - (1)
  SET tmp->qual[9].table_name = "BATCH_ERROR_REF"
  SET tmp->qual[9].drop_ind = - (1)
  SET tmp->qual[10].table_name = "BO_HP_RELTN_MOD"
  SET tmp->qual[10].drop_ind = - (1)
  SET tmp->qual[11].table_name = "PFT_EXPECTED_BATCH"
  SET tmp->qual[11].drop_ind = - (1)
  SET tmp->qual[12].table_name = "PFT_EXPECTED_DETAIL"
  SET tmp->qual[12].drop_ind = - (1)
  SET tmp->qual[13].table_name = "PFT_TAG"
  SET tmp->qual[13].drop_ind = - (1)
  SET tmp->qual[14].table_name = "OMF_PV_DATA_ST"
  SET tmp->qual[14].drop_ind = - (1)
  SET tmp->qual[15].table_name = "CHART_TEMP2"
  SET tmp->qual[15].drop_ind = - (1)
  SET tmp->qual[16].table_name = "DEFAULT_FLOWSHEET"
  SET tmp->qual[16].drop_ind = - (1)
  SET tmp->qual[17].table_name = "FLOWSHEET"
  SET tmp->qual[17].drop_ind = - (1)
  SET tmp->qual[18].table_name = "CQM_FSIOCC_PAR"
  SET tmp->qual[18].drop_ind = - (1)
  SET tmp->qual[19].table_name = "PROCINFO_SYSTEM_R"
  SET tmp->qual[19].drop_ind = - (1)
  SET tmp->qual[20].table_name = "CN_TASK"
  SET tmp->qual[20].drop_ind = - (1)
  SET tmp->qual[21].table_name = "MLTM_NDC_ACTIVE_INGRED_LIST"
  SET tmp->qual[21].drop_ind = - (1)
  SET tmp->qual[22].table_name = "TRACK_EVENT_POSITION"
  SET tmp->qual[22].drop_ind = - (1)
  SET tmp->qual[23].table_name = "TRANSMISSION_LOG"
  SET tmp->qual[23].drop_ind = - (1)
  SET tmp->qual[24].table_name = "INPUT_FIELD_DEFINITION"
  SET tmp->qual[24].drop_ind = - (1)
  SET tmp->qual[25].table_name = "PREF_CARD_SURGEON_COMMENT"
  SET tmp->qual[25].drop_ind = - (1)
  SET tmp->qual[26].table_name = "PREFERENCE_CARD_DEFAULT"
  SET tmp->qual[26].drop_ind = - (1)
  SET tmp->qual[27].table_name = "SN_GAPCHECK"
  SET tmp->qual[27].drop_ind = - (1)
  SET tmp->qual[28].table_name = "SN_GAPCHECK_RULES"
  SET tmp->qual[28].drop_ind = - (1)
  SET tmp->qual[29].table_name = "SURG_PRINT_DETAILS"
  SET tmp->qual[29].drop_ind = - (1)
  SET tmp->qual[30].table_name = "SURGICAL_TEAM_MEMBER"
  SET tmp->qual[30].drop_ind = - (1)
  SET tmp->qual[31].table_name = "MODULE"
  SET tmp->qual[31].drop_ind = - (1)
  SET tmp->qual[32].table_name = "AP_PREFIX_SPEC_PROTOCOL"
  SET tmp->qual[32].drop_ind = - (1)
  SET tmp->qual[33].table_name = "ALIQUOT_TRIGGER"
  SET tmp->qual[33].drop_ind = - (1)
  SET tmp->qual[34].table_name = "UPLOAD_REPORT"
  SET tmp->qual[34].drop_ind = - (1)
  SET tmp->qual[35].table_name = "UPLOAD_USER"
  SET tmp->qual[35].drop_ind = - (1)
  SET tmp->qual[36].table_name = "HLA_TYP_TRAY_LOCI"
  SET tmp->qual[36].drop_ind = - (1)
  SET tmp->qual[37].table_name = "HLA_TYP_TRAY_RESULT"
  SET tmp->qual[37].drop_ind = - (1)
  SET tmp->qual[38].table_name = "PARENTAL_HAPLOTYPE"
  SET tmp->qual[38].drop_ind = - (1)
  SET tmp->qual[39].table_name = "PARENTAL_LOCI"
  SET tmp->qual[39].drop_ind = - (1)
  SET tmp->qual[40].table_name = "PARENTAL_LOCI_DEFAULT"
  SET tmp->qual[40].drop_ind = - (1)
  SET tmp->qual[41].table_name = "MIC_ERR_RECOVER"
  SET tmp->qual[41].drop_ind = - (1)
  SET tmp->qual[42].table_name = "CSM_CONTACT"
  SET tmp->qual[42].drop_ind = - (1)
  SET tmp->qual[43].table_name = "OSM_CHART_REQUEST"
  SET tmp->qual[43].drop_ind = - (1)
  SET tmp->qual[44].table_name = "PROP_QUEUE"
  SET tmp->qual[44].drop_ind = - (1)
  SET tmp->qual[45].table_name = "RESOURCE_ROUTE"
  SET tmp->qual[45].drop_ind = - (1)
  SET tmp->qual[46].table_name = "ROUTE_CODE_RESOURCE_LIST"
  SET tmp->qual[46].drop_ind = - (1)
  SET tmp->qual[47].table_name = "EKS_AOI"
  SET tmp->qual[47].drop_ind = - (1)
  SET tmp->qual[48].table_name = "EKS_DATA_TEMPLATE"
  SET tmp->qual[48].drop_ind = - (1)
  SET tmp->qual[49].table_name = "EKS_DATA_TEMPLATE_R"
  SET tmp->qual[49].drop_ind = - (1)
  SET tmp->qual[50].table_name = "EKS_DATA_TEMPLATE_REC"
  SET tmp->qual[50].drop_ind = - (1)
  SET tmp->qual[51].table_name = "EKS_EKM_TRUE"
  SET tmp->qual[51].drop_ind = - (1)
  SET tmp->qual[52].table_name = "EKS_RECOVERY"
  SET tmp->qual[52].drop_ind = - (1)
  SET tmp->qual[53].table_name = "EKS_RECOVERY_MODULE"
  SET tmp->qual[53].drop_ind = - (1)
  SET tmp->qual[54].table_name = "EKS_RECOVERY_REQUEST"
  SET tmp->qual[54].drop_ind = - (1)
  SET tmp->qual[55].table_name = "EKS_TEMPLATE_VALIDATE"
  SET tmp->qual[55].drop_ind = - (1)
  SET tmp->qual[56].table_name = "HP_BNFT_INFO"
  SET tmp->qual[56].drop_ind = - (1)
  SET tmp->qual[57].table_name = "HP_BNFT_R"
  SET tmp->qual[57].drop_ind = - (1)
  SET tmp->qual[58].table_name = "HP_PROC_BNFT"
  SET tmp->qual[58].drop_ind = - (1)
  SET tmp->qual[59].table_name = "HP_PRSNL_R"
  SET tmp->qual[59].drop_ind = - (1)
  SET tmp->qual[60].table_name = "HP_SOFT_BNFT"
  SET tmp->qual[60].drop_ind = - (1)
  SET tmp->qual[61].table_name = "HP_SOFT_BNFT_ALIAS"
  SET tmp->qual[61].drop_ind = - (1)
  SET tmp->qual[62].table_name = "ACKNOWLEDGMENT"
  SET tmp->qual[62].drop_ind = - (1)
  SET tmp->qual[63].table_name = "AUTHORIZE"
  SET tmp->qual[63].drop_ind = - (1)
  SET tmp->qual[64].table_name = "COMMENT_ENTRY"
  SET tmp->qual[64].drop_ind = - (1)
  SET tmp->qual[65].table_name = "FAILURE"
  SET tmp->qual[65].drop_ind = - (1)
  SET tmp->qual[66].table_name = "INV_TRANS_GL"
  SET tmp->qual[66].drop_ind = - (1)
  SET tmp->qual[67].table_name = "INV_TRANS_LOG"
  SET tmp->qual[67].drop_ind = - (1)
  SET tmp->qual[68].table_name = "INV_TRANS_LOT_INFO"
  SET tmp->qual[68].drop_ind = - (1)
  SET tmp->qual[69].table_name = "LABOR_COST"
  SET tmp->qual[69].drop_ind = - (1)
  SET tmp->qual[70].table_name = "LINE_ITEM_MANIFEST_R"
  SET tmp->qual[70].drop_ind = - (1)
  SET tmp->qual[71].table_name = "MANIFEST"
  SET tmp->qual[71].drop_ind = - (1)
  SET tmp->qual[72].table_name = "PART_COST"
  SET tmp->qual[72].drop_ind = - (1)
  SET tmp->qual[73].table_name = "PHASED_INVOICE"
  SET tmp->qual[73].drop_ind = - (1)
  SET tmp->qual[74].table_name = "PM_PROCEDURE"
  SET tmp->qual[74].drop_ind = - (1)
  SET tmp->qual[75].table_name = "PREVENTIVE_MAINTENANCE"
  SET tmp->qual[75].drop_ind = - (1)
  SET tmp->qual[76].table_name = "REQ_PO_TEMPLATE"
  SET tmp->qual[76].drop_ind = - (1)
  SET tmp->qual[77].table_name = "SERVICE_GROUP"
  SET tmp->qual[77].drop_ind = - (1)
  SET tmp->qual[78].table_name = "TEXT_LINE_ITEM"
  SET tmp->qual[78].drop_ind = - (1)
  SET tmp->qual[79].table_name = "VENDOR_SERVICE_REQUEST_INFO"
  SET tmp->qual[79].drop_ind = - (1)
  SET tmp->qual[80].table_name = "PC_REF_SOURCE"
  SET tmp->qual[80].drop_ind = - (1)
  SET tmp->qual[81].table_name = "DIAG_EPISODE_RELTN"
  SET tmp->qual[81].drop_ind = - (1)
  SET tmp->qual[82].table_name = "DM_OBS_WORKING_VIEW_PI"
  SET tmp->qual[82].drop_ind = - (1)
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
   SET readme_data->message = build(errmsg,"- Readme FAILURE. Check dm_obsolete_tables_83_2.log")
   SET readme_data->status = "F"
  ELSE
   SET readme_data->message = build(errmsg,"- Readme SUCCESS. Check dm_obsolete_tables_83_2.log")
   SET readme_data->status = "S"
  ENDIF
  CALL echo(readme_data->message)
  SELECT INTO "dm_obsolete_tables_83_2.log"
   d.seq
   FROM dummyt d
   FOOT REPORT
    "***********************************************************************", row + 1
    IF (droptotal=recordcnt)
     "  TRACE LOG - dm_obsolete_tables_83_2: SUCCESS"
    ELSE
     "  TRACE LOG - dm_obsolete_tables_83_2: FAILURE"
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
