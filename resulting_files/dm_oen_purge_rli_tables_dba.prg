CREATE PROGRAM dm_oen_purge_rli_tables:dba
 DECLARE days_to_keep = i4 WITH public, noconstant(- (1))
 DECLARE token_size = i4 WITH private, noconstant(0)
 DECLARE tok_ndx = i4 WITH private, noconstant(0)
 DECLARE rows = i4 WITH public, noconstant(0)
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 DECLARE h = i2 WITH private, noconstant(0)
 SET reply->status_data.status = "F"
 SET reply->err_code = - (1)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET token_size = size(request->tokens,5)
 FOR (tok_ndx = 1 TO token_size)
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET days_to_keep = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF (days_to_keep < 0)
  DECLARE err = vc WITH public, noconstant(" ")
  SET err = build("The DaysToKeep parameter is invalid.")
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"s1",err)
  GO TO the_end
 ENDIF
 SET reply->table_name = "OEN_RLI_BATCH"
 SET reply->rows_between_commit = 500
 SELECT INTO "nl:"
  rli.rowid
  FROM oen_rli_batch rli
  WHERE rli.create_dt_tm < cnvtdatetime((curdate - days_to_keep),0)
   AND ((rli.process_status_flag=90) OR (rli.process_status_flag=70))
   AND ((rli.batch_id+ 0) > 0)
  DETAIL
   rows += 1
   IF (mod(rows,10)=1)
    stat = alterlist(reply->rows,(rows+ 9))
   ENDIF
   reply->rows[rows].row_id = rli.rowid
  WITH nocounter, maxqual(rli,value(request->max_rows))
 ;end select
 SET stat = alterlist(reply->rows,rows)
 IF ((rows=request->max_rows))
  DECLARE rm_count = i4 WITH public, noconstant(0)
  SELECT INTO "nl:"
   xxx = count(rowid)
   FROM oen_rli_batch rli
   WHERE rli.create_dt_tm < cnvtdatetime((curdate - days_to_keep),0)
    AND ((rli.process_status_flag=90) OR (rli.process_status_flag=70))
    AND ((rli.batch_id+ 0) > 0)
   DETAIL
    rm_count = xxx
   WITH nocounter
  ;end select
  DECLARE err = vc WITH public, noconstant(" ")
  SET err = build("There are [",rm_count,"] entries on this table marked for removal. Th",
   "e maximum allowed for removal is set to [",request->max_rows,
   "]. If this is con","sistent, the table will grow and fill up the D_OEN tablespace.")
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"s1",err)
 ENDIF
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#the_end
END GO
