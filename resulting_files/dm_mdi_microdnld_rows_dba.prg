CREATE PROGRAM dm_mdi_microdnld_rows:dba
 DECLARE rows = i4 WITH protect, noconstant(0)
 DECLARE days_to_keep = i4 WITH public, noconstant(- (1))
 DECLARE token_size = i4 WITH protect, noconstant(0)
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->table_name = "CQM_MICRODNLD_QUE"
 SET reply->rows_between_commit = 100
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET token_size = size(request->tokens,5)
 FOR (tok_ndx = 1 TO token_size)
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (days_to_keep < 4)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must keep at least 4 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",days_to_keep)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 SELECT INTO "nl:"
  q.rowid
  FROM cqm_microdnld_que q
  WHERE parser(sbr_getrowidnotexists("q.queue_id+0 > 0","q"))
   AND (( EXISTS (
  (SELECT
   a.trigger_id
   FROM cqm_microdnld_tr_1 a
   WHERE a.queue_id=q.queue_id
    AND a.create_dt_tm < cnvtdatetime((curdate - days_to_keep),0)
    AND ((a.trigger_id+ 0) > 0)
    AND ((a.process_status_flag=90) OR (a.active_ind=0)) ))) OR (q.create_dt_tm < cnvtdatetime((
   curdate - days_to_keep),0)))
  DETAIL
   rows = (rows+ 1)
   IF (mod(rows,100)=1)
    stat = alterlist(reply->rows,(rows+ 99))
   ENDIF
   reply->rows[rows].row_id = q.rowid
  FOOT REPORT
   stat = alterlist(reply->rows,rows)
  WITH nocounter, maxqual(q,value(request->max_rows))
 ;end select
 SET reply->err_code = error(reply->err_msg,1)
 IF ((reply->err_code > 0))
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR","Failed in row collection: %1",
   "s",nullterm(reply->err_msg))
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#the_end
END GO
