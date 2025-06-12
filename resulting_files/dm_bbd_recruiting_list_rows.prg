CREATE PROGRAM dm_bbd_recruiting_list_rows
 DECLARE serrmsg = c132 WITH noconstant(" ")
 DECLARE lerrcode = i4 WITH noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->status_data.status = "F"
 SET reply->table_name = "BBD_RECRUITING_LIST"
 SET reply->rows_between_commit = 50
 SELECT INTO "nl:"
  b.rowid
  FROM bbd_recruiting_list b
  PLAN (b
   WHERE b.completed_ind=1
    AND b.list_id > 0.0)
  HEAD REPORT
   row_cnt = 0
  DETAIL
   row_cnt = (row_cnt+ 1)
   IF (mod(row_cnt,50)=1)
    stat = alterlist(reply->rows,(row_cnt+ 49))
   ENDIF
   reply->rows[row_cnt].row_id = b.rowid
  FOOT REPORT
   stat = alterlist(reply->rows,row_cnt)
  WITH nocounter, maxqual(bqga,value(cnvtint(request->max_rows)))
 ;end select
 SET lerrcode = error(serrmsg,1)
 IF (lerrcode=0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->err_code = lerrcode
  SET reply->err_msg = serrmsg
 ENDIF
END GO
