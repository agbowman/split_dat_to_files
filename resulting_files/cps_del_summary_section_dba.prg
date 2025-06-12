CREATE PROGRAM cps_del_summary_section:dba
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
    1 status_data
      2 status = c1
      2 subeventstatus[2]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET called = false
 ENDIF
 SET called = true
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = false
 SET reply->status_data.status = "F"
 SET sectkount = 0
 SET kount1 = 0
 SET table_name = "summary_section"
 SELECT INTO "NL:"
  s.section_id, r.summary_sheet_id
  FROM summary_section s,
   summary_section_r r,
   (dummyt d1  WITH seq = value(summary_sheet->summary_sheet_qual))
  PLAN (d1)
   JOIN (r
   WHERE (r.summary_sheet_id=summary_sheet->sheet_array[d1.seq].summary_sheet_id))
   JOIN (s
   WHERE r.section_id=s.section_id)
  HEAD r.summary_sheet_id
   sectkount = 0
  DETAIL
   sectkount += 1
   IF (mod(sectkount,10)=1)
    stat = alterlist(summary_sheet->sheet_array[d1.seq].summary_section,(sectkount+ 10))
   ENDIF
   summary_sheet->sheet_array[d1.seq].summary_section[sectkount].section_id = s.section_id
  FOOT  r.summary_sheet_id
   summary_sheet->sheet_array[d1.seq].summary_section_qual = sectkount
  WITH nocounter
 ;end select
 IF (curqual < 0)
  SET failed = select_error
  IF (called=true)
   GO TO end_program
  ELSE
   GO TO error_check
  ENDIF
 ENDIF
 FOR (inx = 1 TO summary_sheet->summary_sheet_qual)
   SET table_name = "summary_section_r 1st time"
   SET kount = 0
   SET sectkount = summary_sheet->sheet_array[inx].summary_section_qual
   SELECT INTO "NL:"
    r.parent_id, r.child_id
    FROM section_section_r r,
     (dummyt d  WITH seq = value(summary_sheet->sheet_array[inx].summary_section_qual))
    PLAN (d)
     JOIN (r
     WHERE (r.parent_id=summary_sheet->sheet_array[inx].summary_section[d.seq].section_id))
    DETAIL
     sectkount += 1
     IF (mod(sectkount,10)=1)
      stat = alterlist(summary_sheet->sheet_array[inx].summary_section,(sectkount+ 10))
     ENDIF
     summary_sheet->sheet_array[inx].summary_section[sectkount].section_id = r.child_id
    WITH nocounter
   ;end select
   IF (curqual < 0)
    SET failed = select_error
    IF (called=true)
     GO TO end_program
    ELSE
     GO TO error_check
    ENDIF
   ENDIF
   WHILE ((summary_sheet->sheet_array[inx].summary_section_qual != sectkount))
     SET table_name = "summary_section_r (generation)"
     SET beginkount = (summary_sheet->sheet_array[inx].summary_section_qual+ 1)
     SET summary_sheet->sheet_array[inx].summary_section_qual = sectkount
     FOR (inx1 = beginkount TO summary_sheet->sheet_array[inx].summary_section_qual)
       SET kount = 0
       SELECT INTO "NL:"
        r.child_id, r.parent_id
        FROM section_section_r r
        PLAN (r
         WHERE (r.parent_id=summary_sheet->sheet_array[inx].summary_section[inx1].section_id))
        DETAIL
         sectkount += 1
         IF (mod(sectkount,10)=1)
          stat = alterlist(summary_sheet->sheet_array[inx].summary_section,(sectkount+ 10))
         ENDIF
         summary_sheet->sheet_array[inx].summary_section[sectkount].section_id = r.child_id
        WITH nocounter
       ;end select
       IF (curqual < 0)
        SET failed = select_error
        IF (called=true)
         GO TO end_program
        ELSE
         GO TO error_check
        ENDIF
       ENDIF
     ENDFOR
   ENDWHILE
 ENDFOR
 FOR (inx = 1 TO summary_sheet->summary_sheet_qual)
   SET stat = alterlist(summary_sheet->sheet_array[inx].summary_section,summary_sheet->sheet_array[
    inx].summary_section_qual)
 ENDFOR
 FOR (i = 1 TO summary_sheet->summary_sheet_qual)
   IF ((summary_sheet->sheet_array[i].summary_section_qual > 0))
    SET table_name = "SECTION_ATTRIBUTE"
    DELETE  FROM section_attribute csa,
      (dummyt d1  WITH seq = value(summary_sheet->sheet_array[i].summary_section_qual))
     SET csa.seq = 1
     PLAN (d1)
      JOIN (csa
      WHERE (csa.section_id=summary_sheet->sheet_array[i].summary_section[d1.seq].section_id))
     WITH nocounter
    ;end delete
    IF (curqual < 0)
     SET failed = delete_error
     IF (called=true)
      GO TO end_program
     ELSE
      GO TO error_check
     ENDIF
    ENDIF
    SET table_name = "SECTION_SECTION_R"
    DELETE  FROM section_section_r csr,
      (dummyt d1  WITH seq = value(summary_sheet->sheet_array[i].summary_section_qual))
     SET csr.seq = 1
     PLAN (d1)
      JOIN (csr
      WHERE (csr.parent_id=summary_sheet->sheet_array[i].summary_section[d1.seq].section_id))
     WITH nocounter
    ;end delete
    IF (curqual < 0)
     SET failed = delete_error
     IF (called=true)
      GO TO end_program
     ELSE
      GO TO error_check
     ENDIF
    ENDIF
    SET table_name = "SUMMARY_SECTION"
    DELETE  FROM summary_section css,
      (dummyt d1  WITH seq = value(summary_sheet->sheet_array[i].summary_section_qual))
     SET css.seq = 1
     PLAN (d1)
      JOIN (css
      WHERE (css.section_id=summary_sheet->sheet_array[i].summary_section[d1.seq].section_id))
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET failed = delete_error
     IF (called=true)
      GO TO end_program
     ELSE
      GO TO error_check
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  IF (failed=none_found)
   SET reply->status_data.status = "Z"
   SET reqinfo->commit_ind = true
  ELSE
   CASE (failed)
    OF delete_error:
     SET reply->status_data.subeventstatus[1].operationname = "DELETE"
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
END GO
