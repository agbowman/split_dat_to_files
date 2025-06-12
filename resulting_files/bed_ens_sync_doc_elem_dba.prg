CREATE PROGRAM bed_ens_sync_doc_elem:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 FREE RECORD tempelementstoupdate
 RECORD tempelementstoupdate(
   1 elements[*]
     2 doc_set_element_id = f8
     2 new_display = vc
     2 new_description = vc
 )
 DECLARE elementstoupdatecnt = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SELECT INTO "nl:"
  FROM code_value cv,
   doc_set_element_ref dser
  PLAN (cv
   WHERE cv.code_set=14003)
   JOIN (dser
   WHERE dser.task_assay_cd=cv.code_value
    AND dser.doc_set_element_name != cv.display
    AND dser.active_ind=1)
  DETAIL
   elementstoupdatecnt = (elementstoupdatecnt+ 1), stat = alterlist(tempelementstoupdate->elements,
    elementstoupdatecnt), tempelementstoupdate->elements[elementstoupdatecnt].doc_set_element_id =
   dser.doc_set_element_id,
   tempelementstoupdate->elements[elementstoupdatecnt].new_display = cv.display, tempelementstoupdate
   ->elements[elementstoupdatecnt].new_description = cv.description
  WITH nocounter
 ;end select
 CALL bederrorcheck("Getting elements to update error.")
 IF (elementstoupdatecnt=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM (dummyt d  WITH seq = elementstoupdatecnt),
   doc_set_element_ref dser
  SET dser.doc_set_element_name = tempelementstoupdate->elements[d.seq].new_display, dser
   .doc_set_element_description = tempelementstoupdate->elements[d.seq].new_description, dser
   .updt_cnt = (dser.updt_cnt+ 1),
   dser.updt_id = reqinfo->updt_id, dser.updt_dt_tm = cnvtdatetime(curdate,curtime), dser.updt_task
    = reqinfo->updt_task,
   dser.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (dser
   WHERE (dser.doc_set_element_id=tempelementstoupdate->elements[d.seq].doc_set_element_id))
  WITH nocounter
 ;end update
 CALL bederrorcheck("Syncing elements error.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
