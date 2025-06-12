CREATE PROGRAM bed_get_check_ords_for_tasks:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 orderables[*]
      2 catalog_code_value = f8
      2 primary_mnemonic = vc
      2 task_exists_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET task_activity_code_value = 0.0
 SET task_activity_code_value = uar_get_code_by("MEANING",6027,"CHART RESULT")
 SET ocnt = size(request->orderables,5)
 SET stat = alterlist(reply->orderables,ocnt)
 IF (ocnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt)
   PLAN (d)
   DETAIL
    reply->orderables[d.seq].catalog_code_value = request->orderables[d.seq].catalog_code_value,
    reply->orderables[d.seq].primary_mnemonic = request->orderables[d.seq].primary_mnemonic
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = ocnt),
    order_task_xref otx,
    order_task ot
   PLAN (d)
    JOIN (otx
    WHERE (otx.catalog_cd=request->orderables[d.seq].catalog_code_value))
    JOIN (ot
    WHERE otx.reference_task_id=ot.reference_task_id
     AND (ot.task_description=request->orderables[d.seq].primary_mnemonic))
   DETAIL
    reply->orderables[d.seq].task_exists_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
