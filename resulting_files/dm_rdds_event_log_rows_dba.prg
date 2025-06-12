CREATE PROGRAM dm_rdds_event_log_rows:dba
 DECLARE v_trig_hist_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_setup_hist_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_mvr_cnfg_hist_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_mvr_act_hist_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_ctvr_act_hist_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_dcl_manip_hist_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_user_cntxt_hist_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE v_rows = i4 WITH protect, noconstant(0)
 DECLARE v_max = i4 WITH protect, noconstant(0)
 DECLARE v_year = f8 WITH protect, constant(365.0)
 DECLARE v_sixty = f8 WITH protect, constant(60.0)
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE drelr_loop = i4 WITH protect, noconstant(0)
 FREE RECORD drelr_data
 RECORD drelr_data(
   1 cnt = i4
   1 qual[*]
     2 cur_environment_id = f8
 )
 SET v_max = value(request->max_rows)
 SET reply->status_data.status = "F"
 SET reply->table_name = "DM_RDDS_EVENT_LOG"
 SET reply->rows_between_commit = 50
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="TRIGHISTTOKEEP"))
    SET v_trig_hist_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF ((request->tokens[tok_ndx].token_str="SETUPHISTTOKEEP"))
    SET v_setup_hist_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF ((request->tokens[tok_ndx].token_str="MVRCNFGHISTTOKEEP"))
    SET v_mvr_cnfg_hist_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF ((request->tokens[tok_ndx].token_str="MVRACTHISTTOKEEP"))
    SET v_mvr_act_hist_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF ((request->tokens[tok_ndx].token_str="CTVRACTHISTTOKEEP"))
    SET v_ctvr_act_hist_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF ((request->tokens[tok_ndx].token_str="DCLMANIPHISTTOKEEP"))
    SET v_dcl_manip_hist_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ELSEIF ((request->tokens[tok_ndx].token_str="USERCNXTHISTTOKEEP"))
    SET v_user_cntxt_hist_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_trig_hist_to_keep < v_year)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"TRIGHISTTOKEEP",
   "You must keep at least 365 days' worth of trigger history data. You entered %1 days or did not enter any value.",
   "i",v_trig_hist_to_keep)
 ELSEIF (v_setup_hist_to_keep < v_year)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"SETUPHISTTOKEEP",
   "You must keep at least 365 days' worth of setup history data. You entered %1 days or did not enter any value.",
   "i",v_setup_hist_to_keep)
 ELSEIF (v_mvr_cnfg_hist_to_keep < v_year)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"MVRCNFGHISTTOKEEP",
   "You must keep at least 365 days' worth of mover configuration data. You entered %1 days or did not enter any value.",
   "i",v_mvr_cnfg_hist_to_keep)
 ELSEIF (v_mvr_act_hist_to_keep < v_sixty)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"MVRACTHISTTOKEEP",
   "You must keep at least 60 days' worth of mover activity data. You entered %1 days or did not enter any value.",
   "i",v_mvr_act_hist_to_keep)
 ELSEIF (v_ctvr_act_hist_to_keep < v_sixty)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"CTVRACTHISTTOKEEP",
   "You must keep at least 60 days' worth of cutover activity data. You entered %1 days or did not enter any value.",
   "i",v_ctvr_act_hist_to_keep)
 ELSEIF (v_dcl_manip_hist_to_keep < v_year)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DCLMANIPHISTTOKEEP",
   "You must keep at least 365 days' worth of DCL manipulation data. You entered %1 days or did not enter any value.",
   "i",v_dcl_manip_hist_to_keep)
 ELSEIF (v_user_cntxt_hist_to_keep < v_year)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"USERCNXTHISTTOKEEP",
   "You must keep at least 365 days' worth of user context data. You entered %1 days or did not enter any value.",
   "i",v_user_cntxt_hist_to_keep)
 ELSE
  SELECT DISTINCT INTO "NL:"
   d.cur_environment_id
   FROM dm_rdds_event_log d
   WHERE d.cur_environment_id > 0.0
   ORDER BY d.cur_environment_id
   DETAIL
    drelr_data->cnt = (drelr_data->cnt+ 1), stat = alterlist(drelr_data->qual,drelr_data->cnt),
    drelr_data->qual[drelr_data->cnt].cur_environment_id = d.cur_environment_id
   WITH nocounter
  ;end select
  SET v_err_code2 = error(v_errmsg2,0)
  IF (v_err_code2 != 0)
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERRMN",
    "Failed querying for distinct environment values: %1","s",nullterm(v_errmsg2))
   GO TO exit_main
  ENDIF
  FOR (drelr_loop = 1 TO drelr_data->cnt)
    SELECT INTO "nl:"
     el.rowid
     FROM dm_rdds_event_log el
     WHERE el.rdds_event_key IN ("SUBSETOFTRIGGERSADDED", "DROPENVIRONMENTTRIGGERS",
     "SUBSETOFTRIGGERSDROPPED")
      AND el.event_dt_tm <= cnvtdatetime((curdate - v_trig_hist_to_keep),curtime3)
      AND ((el.dm_rdds_event_log_id+ 0) > 0)
      AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
     DETAIL
      v_rows = (v_rows+ 1)
      IF (mod(v_rows,20)=1)
       stat = alterlist(reply->rows,(v_rows+ 19))
      ENDIF
      reply->rows[v_rows].row_id = el.rowid
     WITH nocounter, maxqual(el,value(v_max))
    ;end select
    SET v_max = (value(request->max_rows) - v_rows)
    SET v_err_code2 = error(v_errmsg2,0)
    IF (v_err_code2 != 0)
     SET reply->err_code = v_err_code2
     SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR1",
      "Failed in trigger history row collection for event keys: %1","s",nullterm(v_errmsg2))
     GO TO exit_main
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key="METADATACHANGE"
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_trig_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
       AND  NOT (list(el.rdds_event_key,el.event_dt_tm) IN (
      (SELECT
       el2.rdds_event_key, max(el2.event_dt_tm)
       FROM dm_rdds_event_log el2
       WHERE el2.rdds_event_key="METADATACHANGE"
        AND (el2.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       GROUP BY el2.rdds_event_key)))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR2",
       "Failed in trigger history row collection for event keys: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key="ADDENVIRONMENTTRIGGERS"
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_trig_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
       AND  NOT (list(el.rdds_event_key,el.paired_environment_id,el.event_dt_tm) IN (
      (SELECT
       el2.rdds_event_key, el2.paired_environment_id, max(el2.event_dt_tm)
       FROM dm_rdds_event_log el2
       WHERE el2.rdds_event_key="ADDENVIRONMENTTRIGGERS"
        AND (el2.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       GROUP BY el2.rdds_event_key, el2.paired_environment_id)))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR3",
       "Failed in trigger history row collection for event keys: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("UNMAPPEDUSERCONTEXTCHANGE", "DUALBUILDTRIGGERCHANGE")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_trig_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
       AND  NOT (list(el.rdds_event_key,el.event_dt_tm) IN (
      (SELECT
       el2.rdds_event_key, max(el2.event_dt_tm)
       FROM dm_rdds_event_log el2
       WHERE el2.rdds_event_key IN ("UNMAPPEDUSERCONTEXTCHANGE", "DUALBUILDTRIGGERCHANGE")
        AND (el2.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       GROUP BY el2.rdds_event_key)))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR4",
       "Failed in trigger history row collection for event keys: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("DROPENVIRONMENTRELATION", "ADDENVIRONMENTRELATION",
      "MOCKCOPYOFPRODCHANGE", "DROPRTABLES", "TRUNCATERDDSTABLES")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_setup_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR5",
       "Failed in setup history row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("AUTOPLANNEDRELATIONSHIPCHANGE", "FULLCIRCLERELATIONSETUP")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_setup_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
       AND  NOT (list(el.rdds_event_key,el.paired_environment_id,el.event_dt_tm) IN (
      (SELECT
       el2.rdds_event_key, el2.paired_environment_id, max(el2.event_dt_tm)
       FROM dm_rdds_event_log el2
       WHERE el2.rdds_event_key=el.rdds_event_key
        AND (el2.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       GROUP BY el2.rdds_event_key, el2.paired_environment_id)))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR6",
       "Failed in setup history row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("CREATINGDBLINK", "CREATINGSEQUENCEMATCHROW",
      "TRANSLATIONBACKFILLSTARTED", "TRANSLATIONBACKFILLFINISHED")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_setup_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
       AND  NOT (list(el.rdds_event_key,el.paired_environment_id,el.event_dt_tm) IN (
      (SELECT
       el2.rdds_event_key, el2.paired_environment_id, max(el2.event_dt_tm)
       FROM dm_rdds_event_log el2
       WHERE el2.rdds_event_key=el.rdds_event_key
        AND (el2.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       GROUP BY el2.rdds_event_key, el2.paired_environment_id)))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR7",
       "Failed in setup history row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("CODEVERSIONREQUIREMENTS", "INSTRUCTIONSETDELETED",
      "INSTRUCTIONSETUPLOADED")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_setup_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
       AND  NOT (list(el.rdds_event_key,el.event_dt_tm) IN (
      (SELECT
       el2.rdds_event_key, max(el2.event_dt_tm)
       FROM dm_rdds_event_log el2
       WHERE el2.rdds_event_key IN ("CODEVERSIONREQUIREMENTS", "INSTRUCTIONSETDELETED",
       "INSTRUCTIONSETUPLOADED")
        AND (el2.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       GROUP BY el2.rdds_event_key, el2.cur_environment_id)))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR8",
       "Failed in setup history row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("TARGETREACTIVATIONSETTING", "MOVERBATCHSIZESETTING",
      "MOVERLOGLEVELSETTING", "MOVERRESETTIMESETTING")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_mvr_cnfg_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR9",
       "Failed in mover configuration row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("STARTINGRDDSMOVER", "STOPPINGRDDSMOVER", "STOPPINGALLRDDSMOVERS",
      "STARTINGRDDSMOVERS", "MOVEFINISHED",
      "STALEMOVER", "ORPHANEDMOVER", "UNPROCESSEDRRESETS", "REPORTEMAILED", "LOCALMETADATAREFRESH",
      "TIERINGINFORMATIONLOADED", "AUTOCUTOVERDUALBUILDISSUES", "UNPROCESSEDRRESETSACKNOWLEDGED",
      "AUTOCUTOVERDUALBUILDISSUESACKNOWLEDGED", "TASKQUEUEERROR",
      "TASKQUEUEFINISHED", "TASKQUEUESTARTED", "INSTRUCTIONSETRUNSUCCESS", "INSTRUCTIONSETRUNFAILED")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_mvr_act_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR10",
       "Failed in mover configuration row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("BEGINREFERENCEDATASYNC", "ENDREFERENCEDATASYNC",
      "CHILDEXCEPTIONSETTINGCHANGE")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_mvr_act_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
       AND  NOT (list(el.rdds_event_key,el.paired_environment_id,el.event_dt_tm) IN (
      (SELECT
       el2.rdds_event_key, el2.paired_environment_id, max(el2.event_dt_tm)
       FROM dm_rdds_event_log el2
       WHERE el2.rdds_event_key=el.rdds_event_key
        AND (el2.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       GROUP BY el2.rdds_event_key, el2.cur_environment_id, el2.paired_environment_id)))
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR11",
       "Failed in mover activity row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("CUTOVERPROCESSSTARTED", "UIDUPCHECKER", "CUTOVERFINISHED",
      "CUTOVERSTARTED", "AUTOCUTOVERSTARTED",
      "AUTOCUTOVERFINISHED", "AUTOCUTOVERERROR", "CUTOVERPROCESSSTOPPED",
      "CANCELSCHEDULEDAUTOCUTOVER", "DUALBUILDREPORTCREATION")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_ctvr_act_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR12",
       "Failed in cutover activity row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("EXPORTUPDTID0ROWS", "IMPORTUPDTID0ROWS",
      "BACKFILLDMCHGLOGCONTEXTNAME")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_dcl_manip_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR13",
       "Failed in DCL manipulation row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max > 0)
     SELECT INTO "nl:"
      el.rowid
      FROM dm_rdds_event_log el
      WHERE el.rdds_event_key IN ("ADDUSERMAPPING", "CHANGEUSERMAPPING", "REMOVEUSERMAPPING")
       AND (el.cur_environment_id=drelr_data->qual[drelr_loop].cur_environment_id)
       AND el.event_dt_tm <= cnvtdatetime((curdate - v_user_cntxt_hist_to_keep),curtime3)
       AND ((el.dm_rdds_event_log_id+ 0) > 0)
      DETAIL
       v_rows = (v_rows+ 1)
       IF (mod(v_rows,20)=1)
        stat = alterlist(reply->rows,(v_rows+ 19))
       ENDIF
       reply->rows[v_rows].row_id = el.rowid
      WITH nocounter, maxqual(el,value(v_max))
     ;end select
     SET v_max = (value(request->max_rows) - v_rows)
     SET v_err_code2 = error(v_errmsg2,0)
     IF (v_err_code2 != 0)
      SET reply->err_code = v_err_code2
      SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR14",
       "Failed in user context row collection: %1","s",nullterm(v_errmsg2))
      GO TO exit_main
     ENDIF
    ENDIF
    IF (v_max=0)
     SET drelr_loop = (drelr_data->cnt+ 1)
    ENDIF
  ENDFOR
  SET stat = alterlist(reply->rows,v_rows)
 ENDIF
#exit_main
 IF (v_err_code2=0
  AND (reply->err_code != - (1)))
  SET reply->status_data.status = "S"
 ENDIF
END GO
