CREATE PROGRAM cps_get_rec_diag:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 RECORD reply(
   1 reltn_type_cd = f8
   1 reltn_type_mean = vc
   1 diag_qual = i4
   1 diag[*]
     2 nomen_id = f8
     2 nomen_string = vc
     2 nomen_source_identifier = vc
     2 reltn_mean = vc
     2 source_vocabulary_cd = f8
   1 nomen_cat_qual = i4
   1 nomen_cat[*]
     2 nomen_category_id = f8
     2 category_name = vc
     2 reltn_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE code_set = i4 WITH public, noconstant(14369)
 DECLARE current_mean = vc WITH public, noconstant(fillstring(132," "))
 DECLARE stat = i2 WITH public, noconstant(0)
 DECLARE get_order_nomen(null) = null
 DECLARE get_order_nomencat(null) = null
 DECLARE get_ordercat_nomen(null) = null
 DECLARE get_ordercat_nomencat(null) = null
 SET reply->diag_qual = 0
 SET reply->nomen_cat_qual = 0
 IF ((validate(request->reltn_mean_knt,- (1))=- (1)))
  SET current_mean = request->reltn_mean
  SET reply->reltn_type_mean = current_mean
  IF (((current_mean="ORC/ICD9") OR ((request->catalog_cd > 0)
   AND  NOT (current_mean > " "))) )
   CALL get_order_nomen(null)
  ELSEIF (current_mean="ORC/NOMENCAT")
   CALL get_order_nomencat(null)
  ELSEIF (current_mean="ALTSEL/NOMEN")
   CALL get_ordercat_nomen(null)
  ELSEIF (current_mean="ALTSEL/NOMCT")
   CALL get_ordercat_nomencat(null)
  ENDIF
 ELSEIF ((request->reltn_mean_knt > 0))
  FOR (fork = 1 TO request->reltn_mean_knt)
   SET current_mean = request->reltn_mean_list[fork].reltn_mean
   IF (((current_mean="ORC/ICD9") OR ((request->catalog_cd > 0)
    AND  NOT (current_mean > " "))) )
    CALL get_order_nomen(null)
   ELSEIF (current_mean="ORC/NOMENCAT")
    CALL get_order_nomencat(null)
   ELSEIF (current_mean="ALTSEL/NOMEN")
    CALL get_ordercat_nomen(null)
   ELSEIF (current_mean="ALTSEL/NOMCT")
    CALL get_ordercat_nomencat(null)
   ENDIF
  ENDFOR
 ENDIF
 SUBROUTINE get_order_nomen(null)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "NL:"
    FROM dcp_entity_reltn d,
     nomenclature n
    PLAN (d
     WHERE d.entity_reltn_mean=current_mean
      AND (d.entity1_id=request->catalog_cd))
     JOIN (n
     WHERE n.nomenclature_id=d.entity2_id
      AND n.source_string > " "
      AND n.active_ind > 0
      AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND n.end_effective_dt_tm >= cnvtdatetime(sysdate))
    HEAD REPORT
     count1 = reply->diag_qual, stat = alterlist(reply->diag,(count1+ 10))
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->diag,(count1+ 9))
     ENDIF
     reply->diag[count1].nomen_id = n.nomenclature_id, reply->diag[count1].nomen_string = n
     .source_string, reply->diag[count1].nomen_source_identifier = n.source_identifier,
     reply->diag[count1].reltn_mean = current_mean, reply->diag[count1].source_vocabulary_cd = n
     .source_vocabulary_cd
    FOOT REPORT
     stat = alterlist(reply->diag,count1), reply->diag_qual = count1
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "DCP_ENTITY_RELTN"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE get_order_nomencat(null)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "NL:"
    FROM dcp_entity_reltn d,
     nomen_category n
    PLAN (d
     WHERE d.entity_reltn_mean=current_mean
      AND (d.entity1_id=request->catalog_cd))
     JOIN (n
     WHERE n.nomen_category_id=d.entity2_id)
    HEAD REPORT
     count1 = reply->nomen_cat_qual, stat = alterlist(reply->nomen_cat,(count1+ 10))
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->nomen_cat,(count1+ 9))
     ENDIF
     reply->nomen_cat[count1].nomen_category_id = n.nomen_category_id, reply->nomen_cat[count1].
     category_name = n.category_name, reply->nomen_cat[count1].reltn_mean = current_mean
    FOOT REPORT
     reply->nomen_cat_qual = count1, stat = alterlist(reply->nomen_cat,count1)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "DCP_ENTITY_RELTN"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE get_ordercat_nomen(null)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "NL:"
    FROM dcp_entity_reltn d,
     nomenclature n
    PLAN (d
     WHERE d.entity_reltn_mean=current_mean
      AND (d.entity1_id=request->alt_sel_cat_id))
     JOIN (n
     WHERE n.nomenclature_id=d.entity2_id
      AND n.source_string > " "
      AND n.active_ind > 0
      AND n.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND n.end_effective_dt_tm >= cnvtdatetime(sysdate))
    HEAD REPORT
     count1 = reply->diag_qual, stat = alterlist(reply->diag,(count1+ 10))
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->diag,(count1+ 9))
     ENDIF
     reply->diag[count1].nomen_id = n.nomenclature_id, reply->diag[count1].nomen_string = n
     .source_string, reply->diag[count1].nomen_source_identifier = n.source_identifier,
     reply->diag[count1].reltn_mean = current_mean, reply->diag[count1].source_vocabulary_cd = n
     .source_vocabulary_cd
    FOOT REPORT
     stat = alterlist(reply->diag,count1), reply->diag_qual = count1
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "DCP_ENTITY_RELTN"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE get_ordercat_nomencat(null)
   SET ierrcode = error(serrmsg,1)
   SET ierrcode = 0
   SELECT INTO "NL:"
    FROM dcp_entity_reltn d,
     nomen_category n
    PLAN (d
     WHERE d.entity_reltn_mean=current_mean
      AND (d.entity1_id=request->alt_sel_cat_id))
     JOIN (n
     WHERE d.entity2_id=n.nomen_category_id)
    HEAD REPORT
     count1 = reply->nomen_cat_qual, stat = alterlist(reply->nomen_cat,(count1+ 10))
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1
      AND count1 != 1)
      stat = alterlist(reply->nomen_cat,(count1+ 9))
     ENDIF
     reply->nomen_cat[count1].nomen_category_id = n.nomen_category_id, reply->nomen_cat[count1].
     category_name = n.category_name, reply->nomen_cat[count1].reltn_mean = current_mean
    FOOT REPORT
     reply->nomen_cat_qual = count1, stat = alterlist(reply->nomen_cat,count1)
    WITH nocounter
   ;end select
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "DCP_ENTITY_RELTN"
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((((reply->diag_qual > 0)) OR ((reply->nomen_cat_qual > 0))) )
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "005 JF7198 08/05/02"
END GO
