CREATE PROGRAM dm_bmdi_acquireddatatrack_rows:dba
 DECLARE v_days_to_keep = i4 WITH noconstant(0)
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE v_errmsg2 = vc WITH protect, noconstant("")
 DECLARE v_err_code2 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "BMDI_ACQUIRED_DATA_TRACK"
 SET reply->rows_between_commit = 50
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 0)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"DAYSTOKEEP",
   "You must enter a number greater than or equal to 0.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  SET reply->status_data.status = "F"
 ELSE
  SELECT
   IF (v_days_to_keep=0)
    WHERE badt.association_id != 0
     AND badt.active_ind=0
     AND parser(sbr_getrowidnotexists("badt.dis_association_dt_tm != NULL","badt"))
   ELSE
    WHERE badt.dis_association_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
     AND badt.dis_association_dt_tm != null
     AND badt.association_id != 0
     AND parser(sbr_getrowidnotexists("badt.active_ind = 0","badt"))
   ENDIF
   INTO "nl:"
   badt.rowid
   FROM bmdi_acquired_data_track badt
   HEAD REPORT
    v_rows = 0
   DETAIL
    v_rows = (v_rows+ 1)
    IF (mod(v_rows,50)=1)
     stat = alterlist(reply->rows,(v_rows+ 49))
    ENDIF
    reply->rows[v_rows].row_id = badt.rowid
   FOOT REPORT
    stat = alterlist(reply->rows,v_rows)
   WITH nocounter, maxqual(badt,value(request->max_rows))
  ;end select
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2 > 0)
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
    "Failed in row collection: %1","s",nullterm(v_errmsg2))
   SET reply->status_data.status = "F"
   GO TO end_program
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
 ENDIF
#end_program
END GO
