CREATE PROGRAM dm_entity_activity_rows:dba
 SET reply->status_data.status = "F"
 DECLARE v_days_to_keep = f8 WITH noconstant(0.0)
 DECLARE v_errmsg2 = c132
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE i18nhandle = i4
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET v_days_to_keep = - (1)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 0)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 0 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSE
  SET reply->table_name = "DM_ENTITY_ACTIVITY"
  SET reply->rows_between_commit = 250
  SELECT INTO "nl:"
   ea.rowid
   FROM dm_entity_activity ea
   WHERE ((ea.entity_activity_id+ 0) > 0)
    AND ((ea.parent_entity_name="ENCOUNTER"
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encounter e
    WHERE e.encntr_id=ea.parent_entity_id
     AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm >= cnvtdatetime((curdate - v_days_to_keep),
     curtime3))) )))) OR (ea.parent_entity_name="PERSON"
    AND  NOT ( EXISTS (
   (SELECT
    1
    FROM encounter e
    WHERE e.person_id=ea.parent_entity_id
     AND ((e.disch_dt_tm = null) OR (e.disch_dt_tm >= cnvtdatetime((curdate - v_days_to_keep),
     curtime3))) )))))
   HEAD REPORT
    row_cnt = 0
   DETAIL
    row_cnt = (row_cnt+ 1)
    IF (mod(row_cnt,50)=1)
     stat = alterlist(reply->rows,(row_cnt+ 49))
    ENDIF
    reply->rows[row_cnt].row_id = ea.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,row_cnt)
   WITH nocounter, maxqual(ea,value(request->max_rows))
  ;end select
  SET v_errmsg2 = fillstring(132," ")
  SET v_err_code2 = 0
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = v_errmsg2
  ENDIF
 ENDIF
END GO
