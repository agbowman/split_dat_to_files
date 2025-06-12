CREATE PROGRAM dm_him_media_movement_rows:dba
 SET reply->status_data.status = "F"
 SET reply->table_name = "MEDIA_MOVEMENT"
 SET reply->rows_between_commit = 50
 DECLARE v_days_to_keep = i4 WITH protect, noconstant(- (1))
 DECLARE tok_ndx = i4 WITH protect, noconstant(0)
 DECLARE batchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(1.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE rows = i4 WITH protect, noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 60)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"KEEPDAYS",
   "You must keep at least 60 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",v_days_to_keep)
  GO TO exit_script
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   seqval = min(mm.media_movement_id)
   FROM media_movement mm
   WHERE mm.media_movement_id > 0
   DETAIL
    curminid = maxval(cnvtreal(seqval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET curminid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  seqval = max(mm.media_movement_id)
  FROM media_movement mm
  DETAIL
   maxid = cnvtreal(seqval)
  WITH nocounter
 ;end select
 SET curmaxid = (curminid+ (batchsize - 1))
 WHILE (curminid <= maxid
  AND rowsleft > 0)
   SELECT INTO "nl:"
    mm.rowid
    FROM media_movement mm
    WHERE parser(sbr_getrowidnotexists("mm.media_movement_id between curMinID and curMaxID","mm"))
     AND mm.updt_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
     AND mm.active_ind=1
    DETAIL
     rows = (rows+ 1)
     IF (mod(rows,50)=1)
      stat = alterlist(reply->rows,(rows+ 49))
     ENDIF
     reply->rows[rows].row_id = mm.rowid
    WITH nocounter, maxqual(mm,value(rowsleft))
   ;end select
   SET reply->err_code = error(reply->err_msg,1)
   IF ((reply->err_code > 0))
    SET reply->status_data.status = "F"
    SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"COLLECTERROR",
     "Failed in row collection: %1","s",nullterm(reply->err_msg))
    GO TO exit_script
   ENDIF
   CALL sbr_update_starting_id(curminid)
   SET curminid = (curmaxid+ 1)
   SET curmaxid = (curminid+ (batchsize - 1))
   SET rowsleft = (request->max_rows - rows)
 ENDWHILE
 SET stat = alterlist(reply->rows,rows)
 SET reply->status_data.status = "S"
 SET reply->err_code = 0
#exit_script
END GO
