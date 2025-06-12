CREATE PROGRAM cps_get_order_sent:dba
 RECORD reply(
   1 catalog_cd = f8
   1 req_synonym_id = f8
   1 encntr_order_group_cd = f8
   1 synonym_qual = i4
   1 synonym[*]
     2 oe_format_id = f8
     2 synonym_id = f8
     2 order_sentence_id = f8
     2 order_sentence_display_line = vc
     2 usage_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 IF ((request->synonym_id > 0))
  CALL get_by_synonym(null)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "GET_BY_SYNONYM"
   GO TO exit_script
  ENDIF
  IF ((request->encntr_order_group_cd > 0)
   AND (reply->synonym_qual < 1))
   SET request->encntr_order_group_cd = 0
   CALL get_by_synonym(null)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "GET_BY_SYNONYM"
   ENDIF
  ENDIF
  GO TO exit_script
 ELSE
  CALL get_by_catalog(null)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET table_name = "GET_BY_CATALOG"
   GO TO exit_script
  ENDIF
  IF ((request->encntr_order_group_cd > 0)
   AND (reply->synonym_qual < 1))
   SET request->encntr_order_group_cd = 0
   CALL get_by_catalog(null)
   SET ierrcode = error(serrmsg,1)
   IF (ierrcode > 0)
    SET failed = select_error
    SET table_name = "GET_BY_CATALOG"
   ENDIF
  ENDIF
  GO TO exit_script
 ENDIF
 SUBROUTINE get_by_synonym(null)
   CALL echo("***")
   CALL echo(build("***   GET_BY_SYNONYM encntr_order_group_cd :",request->encntr_order_group_cd))
   CALL echo(build("***   usage_flag :",request->usage_flag))
   CALL echo("***")
   SELECT
    IF ((request->usage_flag=0))
     PLAN (ocsr
      WHERE (ocsr.synonym_id=request->synonym_id))
      JOIN (os
      WHERE os.order_sentence_id=ocsr.order_sentence_id
       AND (os.order_encntr_group_cd=request->encntr_order_group_cd))
      JOIN (ocs
      WHERE ocs.synonym_id=ocsr.synonym_id)
    ELSE
     PLAN (ocsr
      WHERE (ocsr.synonym_id=request->synonym_id))
      JOIN (os
      WHERE os.order_sentence_id=ocsr.order_sentence_id
       AND os.usage_flag IN (0, request->usage_flag)
       AND (os.order_encntr_group_cd=request->encntr_order_group_cd))
      JOIN (ocs
      WHERE ocs.synonym_id=ocsr.synonym_id)
    ENDIF
    INTO "nl:"
    ocsr.synonym_id, ocs.synonym_id, os.order_sentence_id
    FROM ord_cat_sent_r ocsr,
     order_sentence os,
     order_catalog_synonym ocs
    ORDER BY ocsr.display_seq, ocsr.order_sentence_disp_line
    HEAD REPORT
     reply->req_synonym_id = request->synonym_id, reply->encntr_order_group_cd = request->
     encntr_order_group_cd, reply->catalog_cd = ocsr.catalog_cd,
     knt = 0, stat = alterlist(reply->synonym,10)
    DETAIL
     knt += 1
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->synonym,(knt+ 9))
     ENDIF
     reply->synonym[knt].synonym_id = ocsr.synonym_id, reply->synonym[knt].oe_format_id = ocs
     .oe_format_id, reply->synonym[knt].order_sentence_id = ocsr.order_sentence_id,
     reply->synonym[knt].order_sentence_display_line = trim(ocsr.order_sentence_disp_line), reply->
     synonym[knt].usage_flag = os.usage_flag
    FOOT REPORT
     stat = alterlist(reply->synonym,knt), reply->synonym_qual = knt
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_by_catalog(null)
   CALL echo("***")
   CALL echo(build("***   GET_BY_CATALOG encntr_order_group_cd :",request->encntr_order_group_cd))
   CALL echo(build("***   usage_flag :",request->usage_flag))
   CALL echo("***")
   SELECT
    IF ((request->usage_flag=0))
     PLAN (ocsr
      WHERE (ocsr.catalog_cd=request->catalog_cd))
      JOIN (os
      WHERE os.order_sentence_id=ocsr.order_sentence_id
       AND (os.order_encntr_group_cd=request->encntr_order_group_cd))
      JOIN (ocs
      WHERE ocs.synonym_id=ocsr.synonym_id)
    ELSE
     PLAN (ocsr
      WHERE (ocsr.catalog_cd=request->catalog_cd))
      JOIN (os
      WHERE os.order_sentence_id=ocsr.order_sentence_id
       AND os.usage_flag IN (0, request->usage_flag)
       AND (os.order_encntr_group_cd=request->encntr_order_group_cd))
      JOIN (ocs
      WHERE ocs.synonym_id=ocsr.synonym_id)
    ENDIF
    INTO "nl:"
    ocsr.catalog_cd, os.order_sentence_id, ocs.order_sentence_id
    FROM ord_cat_sent_r ocsr,
     order_sentence os,
     order_catalog_synonym ocs
    ORDER BY ocsr.display_seq, ocsr.order_sentence_disp_line
    HEAD REPORT
     reply->req_synonym_id = request->synonym_id, reply->encntr_order_group_cd = request->
     encntr_order_group_cd, reply->catalog_cd = ocsr.catalog_cd,
     knt = 0, stat = alterlist(reply->synonym,10)
    DETAIL
     knt += 1
     IF (mod(knt,10)=1
      AND knt != 1)
      stat = alterlist(reply->synonym,(knt+ 9))
     ENDIF
     reply->synonym[knt].synonym_id = ocsr.synonym_id, reply->synonym[knt].oe_format_id = ocs
     .oe_format_id, reply->synonym[knt].order_sentence_id = ocsr.order_sentence_id,
     reply->synonym[knt].order_sentence_display_line = trim(ocsr.order_sentence_disp_line), reply->
     synonym[knt].usage_flag = os.usage_flag
    FOOT REPORT
     stat = alterlist(reply->synonym,knt), reply->synonym_qual = knt
    WITH nocounter
   ;end select
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
 ELSEIF ((reply->synonym_qual > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "MOD 007 04/22/04 SB8972"
END GO
