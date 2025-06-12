CREATE PROGRAM dm_obs_indexes_pthnt_80:dba
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
 RECORD tmp(
   1 qual[*]
     2 index_name = vc
     2 drop_ind = i2
     2 err_code = i4
     2 err_msg = vc
 )
 DECLARE tmpstr = c160
 DECLARE droptotal = i4
 DECLARE xx = i4
 DECLARE yy = i4
 DECLARE parse_str = c100
 DECLARE failedcnt = i4
 DECLARE successcnt = i4
 DECLARE recordcnt = i4
 SET recordcnt = 6
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 SET droptotal = 0
 SET xx = 0
 SET yy = 0
 SET failedcnt = 0
 SET successcnt = 0
 IF (currdb != "ORACLE")
  SET readme_data->status = "S"
  SET readme_data->message = "SUCCESS: readme skipped because this is a non oracle database"
  GO TO end_program
 ENDIF
 SET stat = alterlist(tmp->qual,recordcnt)
 SET tmp->qual[1].index_name = "XIE2QC_RESULT"
 SET tmp->qual[1].drop_ind = - (1)
 SET tmp->qual[2].index_name = "XIE3QC_RESULT"
 SET tmp->qual[2].drop_ind = - (1)
 SET tmp->qual[3].index_name = "XIE4QC_RESULT"
 SET tmp->qual[3].drop_ind = - (1)
 SET tmp->qual[4].index_name = "XIE5QC_RESULT"
 SET tmp->qual[4].drop_ind = - (1)
 SET tmp->qual[5].index_name = "XIF221QC_RESULT"
 SET tmp->qual[5].drop_ind = - (1)
 SET tmp->qual[6].index_name = "XIE1PCS_REVIEW_HISTORY"
 SET tmp->qual[6].drop_ind = - (1)
 FOR (xx = 1 TO 50)
  SET droptotal = 0
  FOR (yy = 1 TO recordcnt)
    IF ((tmp->qual[yy].drop_ind != 1))
     CALL pause(5)
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
 IF (droptotal != recordcnt)
  SET readme_data->message = build(errmsg,"- Readme FAILURE. Check dm_obs_indexes_pthnt_80.log")
  SET readme_data->status = "F"
 ELSE
  SET readme_data->message = build(errmsg,"- Readme SUCCESS. Check dm_obs_indexes_pthnt_80.log")
  SET readme_data->status = "S"
 ENDIF
 CALL echo(readme_data->message)
 SELECT INTO "dm_obs_indexes_pthnt_80.log"
  d.seq
  FROM dummyt d
  FOOT REPORT
   "***********************************************************************", row + 1
   IF (droptotal=recordcnt)
    "  TRACE LOG - DM_OBS_INDEXES_PTHNT_80: SUCCESS"
   ELSE
    "  TRACE LOG - DM_OBS_INDEXES_PTHNT_80: FAILURE"
   ENDIF
   row + 1, "***********************************************************************", row + 2,
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
  WITH nocounter, format = variable, formfeed = none,
   maxrow = 1, maxcol = 1000
 ;end select
#end_program
 EXECUTE dm_readme_status
 FREE RECORD tmp
END GO
