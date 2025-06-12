CREATE PROGRAM delete_ext_doc_template_config:dba
 DECLARE checkerrors(operation=vc) = null
 DECLARE fail(operation=vc) = null
 DECLARE deleterow(idx=i4) = null
 DECLARE inserttable(idx=i4) = null
 DECLARE for_idx = i4 WITH protect, noconstant(0)
 DECLARE request_size = i4 WITH protect, noconstant(0)
 DECLARE status_size = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = vc
        3 operationstatus = c1
        3 targetobjectname = vc
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET request_size = size(request->request_list,5)
 FOR (for_idx = 1 TO request_size)
   IF ((request->request_list[for_idx].ext_doc_template_config_id <= 0))
    CALL fail(concat("Invalid id:",build(request->request_list[for_idx].ext_doc_template_config_id)))
   ENDIF
 ENDFOR
 DELETE  FROM ext_doc_template_config t,
   (dummyt d  WITH seq = value(request_size))
  SET t.seq = 1
  PLAN (d)
   JOIN (t
   WHERE (t.ext_doc_template_config_id=request->request_list[d.seq].ext_doc_template_config_id))
  WITH counter
 ;end delete
 CALL checkerrors("Delete Rows: ")
 IF (curqual < request_size)
  CALL fail("One or more IDs did not exist.")
 ENDIF
 SUBROUTINE checkerrors(operation)
   IF (error(errmsg,0) != 0)
    CALL fail(operation)
   ENDIF
 END ;Subroutine
 SUBROUTINE fail(operation)
   SET reply->status_data.status = "F"
   SET status_size = size(reply->status_data.subeventstatus,5)
   CALL alterlist(reply->status_data.subeventstatus,(status_size+ 1))
   SET reply->status_data.subeventstatus[(status_size+ 1)].operationname = "DELETE"
   SET reply->status_data.subeventstatus[(status_size+ 1)].operationstatus = "F"
   SET reply->status_data.subeventstatus[(status_size+ 1)].targetobjectname =
   "EXT_DOC_TEMPLATE_CONFIG"
   SET reply->status_data.subeventstatus[(status_size+ 1)].targetobjectvalue = concat(operation,
    errmsg)
   ROLLBACK
   GO TO exit_program
 END ;Subroutine
 CALL checkerrors("General: ")
#success_exit
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_program
END GO
