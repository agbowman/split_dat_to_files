CREATE PROGRAM dm_glb_auto_verify_code_rows:dba
 DECLARE getcodevaluebymeaning(code_set=i4(value),cdf_meaning=vc(value)) = f8
 SUBROUTINE getcodevaluebymeaning(code_set,cdf_meaning)
   DECLARE _code_set = i4 WITH noconstant(code_set), protect
   DECLARE _code_value = f8 WITH noconstant(0.0), protect
   DECLARE _cdf_meaning = c12 WITH noconstant, protect
   IF (((code_set=0) OR (size(trim(cdf_meaning,1),1)=0)) )
    RETURN(_code_value)
   ENDIF
   SET _cdf_meaning = fillstring(12," ")
   SET _cdf_meaning = cnvtupper(cdf_meaning)
   SET stat = uar_get_meaning_by_codeset(_code_set,_cdf_meaning,1,_code_value)
   IF (_code_value=0.0)
    SELECT INTO "nl:"
     c.code_value
     FROM code_value c
     WHERE c.code_set=_code_set
      AND c.cdf_meaning=_cdf_meaning
      AND c.active_ind=1
      AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
     HEAD REPORT
      _code_value = c.code_value
     WITH nocounter
    ;end select
   ENDIF
   RETURN(_code_value)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET reply->table_name = "AUTO_VERIFY_CODE"
 SET reply->rows_between_commit = minval(10000,request->max_rows)
 DECLARE ldaystokeep = i4 WITH protect, noconstant(0)
 DECLARE ltokenndx = i4 WITH protect, noconstant(0)
 DECLARE result_status_performed_cd = f8 WITH protect, noconstant(0.0)
 DECLARE result_status_inreview_cd = f8 WITH protect, noconstant(0.0)
 DECLARE result_status_corrinreview_cd = f8 WITH protect, noconstant(0.0)
 DECLARE batchsize = f8 WITH protect, noconstant(50000.0)
 DECLARE maxid = f8 WITH protect, noconstant(0.0)
 DECLARE curminid = f8 WITH protect, noconstant(1.0)
 DECLARE curmaxid = f8 WITH protect, noconstant(0.0)
 DECLARE rowsleft = i4 WITH protect, noconstant(request->max_rows)
 DECLARE rows = i4 WITH protect, noconstant(0)
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET result_status_performed_cd = getcodevaluebymeaning(1901,"PERFORMED")
 SET result_status_inreview_cd = getcodevaluebymeaning(1901,"INREVIEW")
 SET result_status_corrinreview_cd = getcodevaluebymeaning(1901,"CORRINREV")
 IF (result_status_performed_cd=0.0)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"PERFORMED",
   "Unable to find CDF meaning 'PERFORMED' in code set 1901.")
  GO TO exit_script
 ENDIF
 IF (result_status_inreview_cd=0.0)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"INREVIEW",
   "Unable to find CDF meaning 'INREVIEW' in code set 1901.")
  GO TO exit_script
 ENDIF
 IF (result_status_corrinreview_cd=0.0)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18ngetmessage(i18nhandle,"CORRINREV",
   "Unable to find CDF meaning 'CORRINREV' in code set 1901.")
  GO TO exit_script
 ENDIF
 FOR (ltokenndx = 1 TO size(request->tokens,5))
   IF ((request->tokens[ltokenndx].token_str="DAYSTOKEEP"))
    SET ldaystokeep = ceil(cnvtreal(request->tokens[ltokenndx].value))
   ENDIF
 ENDFOR
 IF (ldaystokeep < 5)
  SET reply->err_code = - (1)
  SET reply->status_data.status = "F"
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"TOKENOUTOFRANGE",
   "You must keep at least 5 days' worth of data.  You entered %1 days or did not enter any value.",
   "i",ldaystokeep)
  GO TO exit_script
 ENDIF
 IF (batch_ndx=1)
  SELECT INTO "nl:"
   seqval = min(avc.parent_entity_id)
   FROM auto_verify_code avc
   WHERE avc.parent_entity_id > 0
   DETAIL
    curminid = maxval(cnvtreal(seqval),1.0)
   WITH nocounter
  ;end select
 ELSE
  SET curminid = sbr_fetch_starting_id(null)
 ENDIF
 SELECT INTO "nl:"
  seqval = max(avc.parent_entity_id)
  FROM auto_verify_code avc
  DETAIL
   maxid = cnvtreal(seqval)
  WITH nocounter
 ;end select
 SET curmaxid = (curminid+ (batchsize - 1))
 WHILE (curminid <= maxid
  AND rowsleft > 0)
   SELECT INTO "nl:"
    avc.rowid
    FROM auto_verify_code avc
    WHERE parser(sbr_getrowidnotexists("avc.parent_entity_id between curMinID and curMaxID","avc"))
     AND avc.updt_dt_tm <= cnvtdatetime((curdate - ldaystokeep),curtime3)
     AND avc.parent_entity_id > 0.0
     AND ((avc.parent_entity_name="PERFORM_RESULT"
     AND  NOT ( EXISTS (
    (SELECT
     pr.perform_result_id
     FROM perform_result pr
     WHERE pr.perform_result_id=avc.parent_entity_id
      AND pr.result_status_cd IN (result_status_performed_cd, result_status_inreview_cd,
     result_status_corrinreview_cd))))) OR (avc.parent_entity_name="QC_RESULT"
     AND  NOT ( EXISTS (
    (SELECT
     qr.qc_result_id
     FROM qc_result qr
     WHERE qr.qc_result_id=avc.parent_entity_id
      AND qr.result_status_cd=result_status_performed_cd)))))
    DETAIL
     rows = (rows+ 1)
     IF (mod(rows,50)=1)
      stat = alterlist(reply->rows,(rows+ 49))
     ENDIF
     reply->rows[rows].row_id = avc.rowid
    WITH nocounter, maxqual(avc,value(rowsleft))
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
