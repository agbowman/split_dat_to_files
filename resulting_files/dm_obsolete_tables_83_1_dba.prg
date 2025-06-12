CREATE PROGRAM dm_obsolete_tables_83_1:dba
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
  SET recordcnt = 74
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
  SET tmp->qual[1].table_name = "AUTH_DET"
  SET tmp->qual[1].drop_ind = - (1)
  SET tmp->qual[2].table_name = "BAM_SPLIT"
  SET tmp->qual[2].drop_ind = - (1)
  SET tmp->qual[3].table_name = "DM_OCD_TEST"
  SET tmp->qual[3].drop_ind = - (1)
  SET tmp->qual[4].table_name = "DM_OCD_TEST_CHILD"
  SET tmp->qual[4].drop_ind = - (1)
  SET tmp->qual[5].table_name = "NOMEN_DUP_HOLD"
  SET tmp->qual[5].drop_ind = - (1)
  SET tmp->qual[6].table_name = "OAF_BENEFIT_DETAIL"
  SET tmp->qual[6].drop_ind = - (1)
  SET tmp->qual[7].table_name = "OASIS_AUTO_ANSWERS"
  SET tmp->qual[7].drop_ind = - (1)
  SET tmp->qual[8].table_name = "OASIS_DATA"
  SET tmp->qual[8].drop_ind = - (1)
  SET tmp->qual[9].table_name = "OASIS_DATA_SET"
  SET tmp->qual[9].drop_ind = - (1)
  SET tmp->qual[10].table_name = "OASIS_DETAIL"
  SET tmp->qual[10].drop_ind = - (1)
  SET tmp->qual[11].table_name = "OASIS_EXTRACTION_SET"
  SET tmp->qual[11].drop_ind = - (1)
  SET tmp->qual[12].table_name = "OASIS_EXT_ENCNTR_CD"
  SET tmp->qual[12].drop_ind = - (1)
  SET tmp->qual[13].table_name = "OASIS_PROMPT"
  SET tmp->qual[13].drop_ind = - (1)
  SET tmp->qual[14].table_name = "OASIS_RECORD_SET"
  SET tmp->qual[14].drop_ind = - (1)
  SET tmp->qual[15].table_name = "OASIS_SKIP_RULE"
  SET tmp->qual[15].drop_ind = - (1)
  SET tmp->qual[16].table_name = "OASIS_XREF"
  SET tmp->qual[16].drop_ind = - (1)
  SET tmp->qual[17].table_name = "ODS_OPR_RELTN"
  SET tmp->qual[17].drop_ind = - (1)
  SET tmp->qual[18].table_name = "ODS_OXR_RELTN"
  SET tmp->qual[18].drop_ind = - (1)
  SET tmp->qual[19].table_name = "OMF_APP_GRID_R"
  SET tmp->qual[19].drop_ind = - (1)
  SET tmp->qual[20].table_name = "PC_485_OTHER"
  SET tmp->qual[20].drop_ind = - (1)
  SET tmp->qual[21].table_name = "PC_ACTIVITIES_PERMITTED"
  SET tmp->qual[21].drop_ind = - (1)
  SET tmp->qual[22].table_name = "PC_ADMISSION_ST"
  SET tmp->qual[22].drop_ind = - (1)
  SET tmp->qual[23].table_name = "PC_ADVANCE_DIRECTIVE"
  SET tmp->qual[23].drop_ind = - (1)
  SET tmp->qual[24].table_name = "PC_CLIENT_STATS_ST"
  SET tmp->qual[24].drop_ind = - (1)
  SET tmp->qual[25].table_name = "PC_DIET"
  SET tmp->qual[25].drop_ind = - (1)
  SET tmp->qual[26].table_name = "PC_DO_NOT_MATCH"
  SET tmp->qual[26].drop_ind = - (1)
  SET tmp->qual[27].table_name = "PC_ENCNTR_CONTACT_RELTN"
  SET tmp->qual[27].drop_ind = - (1)
  SET tmp->qual[28].table_name = "PC_FORM_DETAIL"
  SET tmp->qual[28].drop_ind = - (1)
  SET tmp->qual[29].table_name = "PC_FUNCTIONAL_LIMITATION"
  SET tmp->qual[29].drop_ind = - (1)
  SET tmp->qual[30].table_name = "PC_GEOG_CHOICES"
  SET tmp->qual[30].drop_ind = - (1)
  SET tmp->qual[31].table_name = "PC_GEOG_COVERAGE"
  SET tmp->qual[31].drop_ind = - (1)
  SET tmp->qual[32].table_name = "PC_HCFA_485"
  SET tmp->qual[32].drop_ind = - (1)
  SET tmp->qual[33].table_name = "PC_HISTORY"
  SET tmp->qual[33].drop_ind = - (1)
  SET tmp->qual[34].table_name = "PC_IO_SECTION_DETAIL"
  SET tmp->qual[34].drop_ind = - (1)
  SET tmp->qual[35].table_name = "PC_LOC_ENC_333_RELTN"
  SET tmp->qual[35].drop_ind = - (1)
  SET tmp->qual[36].table_name = "PC_MED_LIST"
  SET tmp->qual[36].drop_ind = - (1)
  SET tmp->qual[37].table_name = "PC_MENTAL_STATUS"
  SET tmp->qual[37].drop_ind = - (1)
  SET tmp->qual[38].table_name = "PC_NOTE_COMMENT"
  SET tmp->qual[38].drop_ind = - (1)
  SET tmp->qual[39].table_name = "PC_NOTE_ORDER_RELTN"
  SET tmp->qual[39].drop_ind = - (1)
  SET tmp->qual[40].table_name = "PC_NOTE_SECTION"
  SET tmp->qual[40].drop_ind = - (1)
  SET tmp->qual[41].table_name = "PC_PRSNL_INFO"
  SET tmp->qual[41].drop_ind = - (1)
  SET tmp->qual[42].table_name = "PC_REC_PATTERN"
  SET tmp->qual[42].drop_ind = - (1)
  SET tmp->qual[43].table_name = "PC_REFERRAL_LIST"
  SET tmp->qual[43].drop_ind = - (1)
  SET tmp->qual[44].table_name = "PC_REFERRAL_ST"
  SET tmp->qual[44].drop_ind = - (1)
  SET tmp->qual[45].table_name = "PC_REF_FORM_ENCNTR"
  SET tmp->qual[45].drop_ind = - (1)
  SET tmp->qual[46].table_name = "PC_REF_SOURCE"
  SET tmp->qual[46].drop_ind = - (1)
  SET tmp->qual[47].table_name = "PC_REF_SRC_XFER"
  SET tmp->qual[47].drop_ind = - (1)
  SET tmp->qual[48].table_name = "PC_REMINDERS_LIST"
  SET tmp->qual[48].drop_ind = - (1)
  SET tmp->qual[49].table_name = "PC_TEAM_ALTS_LIST"
  SET tmp->qual[49].drop_ind = - (1)
  SET tmp->qual[50].table_name = "PC_TIME_AVAILABILITY"
  SET tmp->qual[50].drop_ind = - (1)
  SET tmp->qual[51].table_name = "PC_TRANSFER_TO"
  SET tmp->qual[51].drop_ind = - (1)
  SET tmp->qual[52].table_name = "PC_VISIT_AUTH"
  SET tmp->qual[52].drop_ind = - (1)
  SET tmp->qual[53].table_name = "PC_VISIT_ORDER"
  SET tmp->qual[53].drop_ind = - (1)
  SET tmp->qual[54].table_name = "PC_VISIT_ORDER_RELTN"
  SET tmp->qual[54].drop_ind = - (1)
  SET tmp->qual[55].table_name = "PC_VISIT_SIGN"
  SET tmp->qual[55].drop_ind = - (1)
  SET tmp->qual[56].table_name = "PHA_ONETOMANY_1"
  SET tmp->qual[56].drop_ind = - (1)
  SET tmp->qual[57].table_name = "PHA_ONETOMANY_2"
  SET tmp->qual[57].drop_ind = - (1)
  SET tmp->qual[58].table_name = "PPS_CUR_ANSWER"
  SET tmp->qual[58].drop_ind = - (1)
  SET tmp->qual[59].table_name = "PPS_EPISODE"
  SET tmp->qual[59].drop_ind = - (1)
  SET tmp->qual[60].table_name = "PPS_HHRG"
  SET tmp->qual[60].drop_ind = - (1)
  SET tmp->qual[61].table_name = "PPS_LEVEL"
  SET tmp->qual[61].drop_ind = - (1)
  SET tmp->qual[62].table_name = "PPS_PARAMS"
  SET tmp->qual[62].drop_ind = - (1)
  SET tmp->qual[63].table_name = "PPS_SCORE_ITEM"
  SET tmp->qual[63].drop_ind = - (1)
  SET tmp->qual[64].table_name = "PPS_SCORE_LEVEL"
  SET tmp->qual[64].drop_ind = - (1)
  SET tmp->qual[65].table_name = "PPS_SCORE_LINE"
  SET tmp->qual[65].drop_ind = - (1)
  SET tmp->qual[66].table_name = "PPS_WAGE_INDEX"
  SET tmp->qual[66].drop_ind = - (1)
  SET tmp->qual[67].table_name = "OPF_ATTRIBUTE"
  SET tmp->qual[67].drop_ind = - (1)
  SET tmp->qual[68].table_name = "OPF_JOB"
  SET tmp->qual[68].drop_ind = - (1)
  SET tmp->qual[69].table_name = "OPF_JOB_TYPE"
  SET tmp->qual[69].drop_ind = - (1)
  SET tmp->qual[70].table_name = "OPF_NAME"
  SET tmp->qual[70].drop_ind = - (1)
  SET tmp->qual[71].table_name = "OPF_NAME_POOL"
  SET tmp->qual[71].drop_ind = - (1)
  SET tmp->qual[72].table_name = "OPF_NAME_POOL_RELTN"
  SET tmp->qual[72].drop_ind = - (1)
  SET tmp->qual[73].table_name = "OPF_PARAMETER"
  SET tmp->qual[73].drop_ind = - (1)
  SET tmp->qual[74].table_name = "OPF_WEIGHT"
  SET tmp->qual[74].drop_ind = - (1)
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
   SET readme_data->message = build(errmsg,"- Readme FAILURE. Check dm_obsolete_tables_83_1.log")
   SET readme_data->status = "F"
  ELSE
   SET readme_data->message = build(errmsg,"- Readme SUCCESS. Check dm_obsolete_tables_83_1.log")
   SET readme_data->status = "S"
  ENDIF
  CALL echo(readme_data->message)
  SELECT INTO "dm_obsolete_tables_83_1.log"
   d.seq
   FROM dummyt d
   FOOT REPORT
    "***********************************************************************", row + 1
    IF (droptotal=recordcnt)
     "  TRACE LOG - dm_obsolete_tables_83_1: SUCCESS"
    ELSE
     "  TRACE LOG - dm_obsolete_tables_83_1: FAILURE"
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
