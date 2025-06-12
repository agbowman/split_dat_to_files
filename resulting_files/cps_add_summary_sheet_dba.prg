CREATE PROGRAM cps_add_summary_sheet:dba
 RECORD summary_sheet(
   1 summary_sheet_qual = i4
   1 sheet_array[1]
     2 summary_sheet_id = f8
     2 summary_section_qual = i4
     2 summary_section[*]
       3 section_id = f8
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 summary_sheet_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET reply->status_data.status = "F"
 SET script_name = fillstring(132," ")
 SET count = 0
 SELECT INTO "nl:"
  s.summary_sheet_id
  FROM summary_sheet s
  PLAN (s
   WHERE (s.prsnl_id=request->prsnl_id)
    AND s.summary_sheet_id > 0)
  DETAIL
   count += 1
   IF (mod(count,10)=1)
    stat = alter(summary_sheet->sheet_array,(count+ 10))
   ENDIF
   summary_sheet->sheet_array[count].summary_sheet_id = s.summary_sheet_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET summary_sheet->summary_sheet_qual = 0
 ELSE
  IF (curqual > 0)
   SET summary_sheet->summary_sheet_qual = count
  ELSE
   SET failed = select_error
   GO TO check_error
  ENDIF
 ENDIF
 EXECUTE cps_del_summary_sheet
 IF (failed != false)
  SET script_name = "cps_del_summary_sheet"
  GO TO error_check
 ENDIF
 SET table_name = "SUMMARY_SHEET"
 IF ((request->summary_sheet_id=0))
  SELECT INTO "nl:"
   y = seq(cpo_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    reply->summary_sheet_id = cnvtint(y)
   WITH format, counter
  ;end select
 ELSE
  SET reply->summary_sheet_id = request->summary_sheet_id
 ENDIF
 SET code_value = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 INSERT  FROM summary_sheet css
  SET css.summary_sheet_id = reply->summary_sheet_id, css.prsnl_id =
   IF ((request->prsnl_id_ind=false)) reqinfo->updt_id
   ELSE request->prsnl_id
   ENDIF
   , css.display = request->display,
   css.description = request->description, css.active_ind = 1, css.active_status_cd = code_value,
   css.active_status_dt_tm = cnvtdatetime(sysdate), css.active_status_prsnl_id = reqinfo->updt_id,
   css.beg_effective_dt_tm = cnvtdatetime(sysdate),
   css.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), css.updt_dt_tm = cnvtdatetime(sysdate), css
   .updt_cnt = 0,
   css.updt_id = reqinfo->updt_id, css.updt_task = reqinfo->updt_task, css.updt_applctx = reqinfo->
   updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = insert_error
  GO TO check_error
 ENDIF
 SET table_name = "SUMMARY_SECTION_R"
 INSERT  FROM summary_section_r cds,
   (dummyt d  WITH seq = value(request->document_section_r_qual))
  SET cds.summary_sheet_id = reply->summary_sheet_id, cds.section_id = request->document_section_r[d
   .seq].section_id, cds.sequence = request->document_section_r[d.seq].sequence,
   cds.default_expand_ind = request->document_section_r[d.seq].default_expand_ind, cds.active_ind = 1,
   cds.active_status_cd = code_value,
   cds.active_status_dt_tm = cnvtdatetime(sysdate), cds.active_status_prsnl_id = reqinfo->updt_id,
   cds.beg_effective_dt_tm = cnvtdatetime(sysdate),
   cds.end_effective_dt_tm = cnvtdatetime("31-DEC-2100"), cds.updt_dt_tm = cnvtdatetime(curdate,
    curtime), cds.updt_cnt = 0,
   cds.updt_id = reqinfo->updt_id, cds.updt_task = reqinfo->updt_task, cds.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d)
   JOIN (cds)
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = insert_error
  GO TO check_error
 ENDIF
 SET failed = false
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  IF (failed=none_found)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = true
  ELSE
   CASE (failed)
    OF gen_nbr_error:
     SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
    OF insert_error:
     SET reply->status_data.subeventstatus[1].operationname = "INSERT"
    OF update_error:
     SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    OF replace_error:
     SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
    OF delete_error:
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
    OF undelete_error:
     SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
    OF remove_error:
     SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
    OF attribute_error:
     SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
    OF lock_error:
     SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    OF select_error:
     SET reply->status_data.subeventstatus[1].operationname = "GET"
    ELSE
     SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   ENDCASE
  ENDIF
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET ierrcode = error(serrmsg,0)
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
  CALL echo("FAILED: Table = [",0)
  CALL echo(table_name,0)
  CALL echo("]  failed to [",0)
  SET op_name = reply->status_data.subeventstatus[1].operationname
  CALL echo(op_name,0)
  CALL echo("]  ",1)
  CALL echo("        CCL error = [",0)
  CALL echo(serrmsg,0)
  CALL echo("]",1)
 ENDIF
 GO TO end_program
#end_program
 SET pco_script_version = "001 10/03/02 SF3151"
END GO
