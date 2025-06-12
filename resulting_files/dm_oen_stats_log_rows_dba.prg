CREATE PROGRAM dm_oen_stats_log_rows:dba
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE token_size = i4 WITH protect, noconstant(0)
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 SET token_size = size(request->tokens,5)
 FOR (tok_ndx = 1 TO token_size)
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (days_to_keep < 0)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s1",
   "You must look back at least 0 days. You entered %1 days or did not enter any value.","i",
   days_to_keep)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 SET reply->table_name = "OEN_TX_STATS_LOG"
 SET reply->rows_between_commit = minval(10000,request->max_rows)
 SET rows = 0
 SELECT INTO "nl:"
  s.rowid
  FROM oen_tx_stats_log s
  WHERE parser(sbr_getrowidnotexists("s.stat_id+0 > 0","s"))
   AND s.start_dt_tm < cnvtdatetime((curdate - days_to_keep),curtime3)
  DETAIL
   rows += 1
   IF (mod(rows,10)=1)
    stat = alterlist(reply->rows,(rows+ 9))
   ENDIF
   reply->rows[rows].row_id = s.rowid
  FOOT REPORT
   stat = alterlist(reply->rows,rows)
  WITH nocounter, maxqual(s,value(request->max_rows))
 ;end select
 SET reply->err_code = error(reply->err_msg,1)
 IF ((reply->err_code > 0))
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
   nullterm(reply->err_msg))
  SET reply->status_data.status = "F"
  GO TO the_end
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#the_end
END GO
