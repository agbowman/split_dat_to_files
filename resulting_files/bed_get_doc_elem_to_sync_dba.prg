CREATE PROGRAM bed_get_doc_elem_to_sync:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 doc_set_elements[*]
      2 task_assay_cd = f8
      2 doc_set_element_name = vc
      2 dta_display = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
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
 DECLARE dtacodeset = i4 WITH protect, constant(14003)
 DECLARE outofsynccnt = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv,
   doc_set_element_ref dse
  PLAN (cv
   WHERE cv.code_set=dtacodeset)
   JOIN (dse
   WHERE cv.code_value=dse.task_assay_cd
    AND trim(cv.display) != trim(dse.doc_set_element_name)
    AND dse.active_ind=1)
  DETAIL
   outofsynccnt = (outofsynccnt+ 1), stat = alterlist(reply->doc_set_elements,outofsynccnt), reply->
   doc_set_elements[outofsynccnt].task_assay_cd = cv.code_value,
   reply->doc_set_elements[outofsynccnt].doc_set_element_name = dse.doc_set_element_name, reply->
   doc_set_elements[outofsynccnt].dta_display = cv.display
  WITH nocounter
 ;end select
 CALL bederrorcheck("GetOutOfSyncItems error.")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
