CREATE PROGRAM dm_cdi_pending_document_rows
 DECLARE v_days_to_keep = i4 WITH noconstant(0)
 DECLARE tok_ndx = i4 WITH noconstant(0)
 DECLARE v_rows = i4 WITH noconstant(0)
 DECLARE v_errmsg2 = vc WITH noconstant("")
 DECLARE v_err_code2 = i4 WITH noconstant(0)
 DECLARE lidx = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET reply->table_name = "CDI_PENDING_DOCUMENT"
 SET reply->rows_between_commit = 50
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[tok_ndx].token_str="DAYSTOKEEP"))
    SET v_days_to_keep = ceil(cnvtreal(request->tokens[tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_days_to_keep < 60)
  SET reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1","%1 %2 %3","sss",
   "You must keep at least 60 days worth of data.  You entered ",
   nullterm(trim(cnvtstring(v_days_to_keep),3))," days or did not enter any value.")
 ELSE
  SELECT INTO "nl:"
   cpd.rowid, cpd2.rowid
   FROM cdi_pending_document cpd,
    cdi_pending_document cpd2
   PLAN (cpd
    WHERE cpd.updt_dt_tm < cnvtdatetime((curdate - v_days_to_keep),curtime3)
     AND cpd.active_ind=1
     AND ((cpd.process_location_flag=0) OR (cpd.process_location_flag=4))
     AND parser(sbr_getrowidnotexists("cpd.cdi_pending_batch_id = 0","cpd"))
     AND cpd.cdi_pending_document_id != 0)
    JOIN (cpd2
    WHERE outerjoin(cpd.blob_handle)=cpd2.blob_handle
     AND outerjoin(0) != cpd2.cdi_pending_document_id
     AND outerjoin(0)=cpd2.active_ind)
   HEAD REPORT
    v_rows = 0
   HEAD cpd.rowid
    lpos = locateval(lidx,1,v_rows,cpd.rowid,reply->rows[lidx].row_id)
    IF (lpos <= 0)
     v_rows = (v_rows+ 1)
     IF (mod(v_rows,100)=1)
      stat = alterlist(reply->rows,(v_rows+ 99))
     ENDIF
     reply->rows[v_rows].row_id = cpd.rowid
    ENDIF
   DETAIL
    IF (trim(cpd2.rowid) != "")
     v_rows = (v_rows+ 1)
     IF (mod(v_rows,100)=1)
      stat = alterlist(reply->rows,(v_rows+ 99))
     ENDIF
     reply->rows[v_rows].row_id = cpd2.rowid
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->rows,v_rows)
   WITH nocounter, maxqual(cpd,value(request->max_rows))
  ;end select
  SET v_errmsg2 = fillstring(132," ")
  SET v_err_code2 = 0
  SET v_err_code2 = error(v_errmsg2,1)
  IF (v_err_code2=0)
   SET reply->err_code = 0
   SET reply->status_data.status = "S"
  ELSE
   SET reply->err_code = v_err_code2
   SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"s2","Failed in row collection: %1","s",
    nullterm(v_errmsg2))
  ENDIF
 ENDIF
END GO
