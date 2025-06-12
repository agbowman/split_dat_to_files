CREATE PROGRAM dm_mdi_ropresults_rows:dba
 DECLARE rows = i4 WITH public, noconstant(0)
 DECLARE rm_count = i4 WITH public, noconstant(0)
 DECLARE days_to_keep = i4 WITH public, noconstant(- (1))
 DECLARE i18nhandle = i4 WITH private, noconstant(0)
 DECLARE rstat = i4 WITH private, noconstant(0)
 DECLARE rstat = i4 WITH private, noconstant(0)
 DECLARE token_size = i4 WITH private, noconstant(0)
 DECLARE tok_ndx = i4 WITH private, noconstant(0)
 DECLARE err = vc WITH private, noconstant(" ")
 SET reply->status_data.status = "F"
 SET reply->err_code = - (1)
 SET rstat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET max_rows = cnvtint(request->max_rows)
 SET token_size = size(request->tokens,5)
 FOR (tok_ndx = 1 TO token_size)
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (days_to_keep < 0)
  SET err = build("DaysToKeep parameter is invalid.")
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"s1",err)
  GO TO the_end
 ENDIF
 IF (max_rows < 1)
  SET err = build("The Max Top level rows to purge must be greater than 0.")
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"s1",err)
  GO TO the_end
 ENDIF
 SET reply->table_name = "CQM_ROPRESULTS_QUE"
 SET reply->rows_between_commit = 100
 SELECT INTO "nl:"
  a.rowid
  FROM cqm_ropresults_que a,
   cqm_ropresults_tr_1 b
  PLAN (a
   WHERE a.create_dt_tm < cnvtdatetime((curdate - days_to_keep),0)
    AND ((a.queue_id+ 0) > 0))
   JOIN (b
   WHERE b.queue_id=a.queue_id
    AND ((b.process_status_flag+ 0) != 10))
  DETAIL
   rows = (rows+ 1)
   IF (mod(rows,10)=1)
    stat = alterlist(reply->rows,(rows+ 9))
   ENDIF
   reply->rows[rows].row_id = a.rowid
  WITH nocounter, maxqual(a,value(request->max_rows))
 ;end select
 SET rstat = alterlist(reply->rows,rows)
 IF ((rows=request->max_rows))
  SELECT INTO "nl:"
   xxx = count(rowid)
   FROM cqm_ropresults_tr_1 t
   WHERE t.create_dt_tm < cnvtdatetime((curdate - days_to_keep),0)
    AND ((t.process_status_flag+ 0)=90)
    AND ((t.trigger_id+ 0) > 0)
   DETAIL
    rm_count = xxx
   WITH nocounter
  ;end select
  SET err = build("There are [",rm_count,"] entries on this table marked for removal when th",
   "e maximum allowed for removal is [",request->max_rows,
   "]. If this is consistent, th",
   "e table will grow and fill up the D_CQM tablespace.  Consider increasing th","e ",'"',
   "maximum rows to purge",
   '"'," parameter.")
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"s1",err)
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#the_end
END GO
