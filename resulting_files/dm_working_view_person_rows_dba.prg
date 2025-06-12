CREATE PROGRAM dm_working_view_person_rows:dba
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "WORKING_VIEW_PERSON"
 SET reply->rows_between_commit = 50
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 7)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must keep at least 7 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  SET reply->status_data.status = "F"
 ELSE
  SELECT INTO "nl:"
   wvp.rowid
   FROM working_view_person wvp
   WHERE parser(sbr_getrowidnotexists("wvp.working_view_person_id+0 > 0","wvp"))
    AND  EXISTS (
   (SELECT
    e.encntr_id
    FROM encounter e
    WHERE e.encntr_id=wvp.encntr_id
     AND e.disch_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)))
   HEAD REPORT
    v_rows = 0
   DETAIL
    v_rows = (v_rows+ 1)
    IF (mod(v_rows,50)=1)
     stat = alterlist(reply->rows,(v_rows+ 49))
    ENDIF
    reply->rows[v_rows].row_id = wvp.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,v_rows)
   WITH nocounter, maxqual(wvp,value(request->max_rows))
  ;end select
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2 > 0)
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
    "Failed in row collections: %1","s",nullterm(v_errmsg2))
   SET reply->status_data.status = "F"
  ELSE
   SET reply->err_code = 0
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
