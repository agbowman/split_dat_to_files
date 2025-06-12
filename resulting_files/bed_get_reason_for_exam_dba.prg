CREATE PROGRAM bed_get_reason_for_exam:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 exam_reason[*]
      2 exam_reason_id = f8
      2 sequence = i4
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 IF ((request->catalog_code_value=0.0))
  GO TO exit_script
 ENDIF
 DECLARE cnt = i4 WITH protect
 SET cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog_synonym ocs,
   exam_reason er,
   coded_exam_reason cer
  PLAN (ocs
   WHERE (ocs.synonym_id=request->catalog_code_value))
   JOIN (er
   WHERE er.catalog_cd=ocs.catalog_cd)
   JOIN (cer
   WHERE cer.exam_reason_id=er.exam_reason_id
    AND cer.active_ind=1)
  ORDER BY er.exam_reason_id
  HEAD er.exam_reason_id
   cnt = (cnt+ 1), stat = alterlist(reply->exam_reason,cnt), reply->exam_reason[cnt].exam_reason_id
    = er.exam_reason_id,
   reply->exam_reason[cnt].description = cer.description, reply->exam_reason[cnt].sequence = er
   .sequence
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
