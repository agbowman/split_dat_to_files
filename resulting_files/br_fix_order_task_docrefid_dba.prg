CREATE PROGRAM br_fix_order_task_docrefid:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed:  Starting script br_fix_order_task_docrefid"
 FREE RECORD docsetids
 RECORD docsetids(
   1 task_qual[*]
     2 reference_task_id = f8
 )
 DECLARE err_code = i4 WITH protect, noconstant(0)
 DECLARE err_msg = vc WITH protect, noconstant("")
 DECLARE selectdocsetrefids() = null
 DECLARE updatedocsetrefids() = null
 CALL selectdocsetrefids(null)
 IF (size(docsetids->task_qual,5) > 0)
  CALL updatedocsetrefids(null)
 ENDIF
 SUBROUTINE selectdocsetrefids(dummyvar)
  SELECT INTO "nl:"
   ot.reference_task_id, ot.dcp_forms_ref_id
   FROM order_task ot,
    doc_set_ref dsr
   PLAN (dsr
    WHERE dsr.doc_set_ref_id > 0.0
     AND dsr.active_ind=1)
    JOIN (ot
    WHERE ot.dcp_forms_ref_id=dsr.doc_set_ref_id
     AND ot.reference_task_id > 0.0
     AND ot.active_ind=1)
   HEAD REPORT
    ref_cnt = 0
   DETAIL
    ref_cnt = (ref_cnt+ 1)
    IF (mod(ref_cnt,50)=1)
     status = alterlist(docsetids->task_qual,(ref_cnt+ 49))
    ENDIF
    docsetids->task_qual[ref_cnt].reference_task_id = ot.reference_task_id
   FOOT REPORT
    status = alterlist(docsetids->task_qual,ref_cnt)
   WITH nocounter
  ;end select
  IF (error(err_msg,0) > 0)
   SET readme_data->status = "F"
   SET readme_data->message = concat(
    "docset_ref_id -  failed to get record from order_task,doc_set_ref table rows: ",err_msg)
   GO TO exit_script
  ENDIF
 END ;Subroutine
 SUBROUTINE updatedocsetrefids(null)
  UPDATE  FROM order_task ot,
    (dummyt d  WITH seq = value(size(docsetids->task_qual,5)))
   SET ot.dcp_forms_ref_id = 0, ot.updt_dt_tm = cnvtdatetime(curdate,curtime3), ot.updt_id = reqinfo
    ->updt_id,
    ot.updt_task = reqinfo->updt_task, ot.updt_applctx = reqinfo->updt_applctx, ot.updt_cnt = (ot
    .updt_cnt+ 1)
   PLAN (d)
    JOIN (ot
    WHERE (ot.reference_task_id=docsetids->task_qual[d.seq].reference_task_id)
     AND ot.active_ind=1)
  ;end update
  IF (error(err_msg,0) > 0)
   CALL echo("Readme Failed: Could not update the docset ref ids, link to a task")
   SET readme_data->message = concat("docset_ref_id -  failed to update order_task table rows: ",
    err_msg)
   SET readme_data->status = "F"
   GO TO exit_script
  ELSE
   CALL echo("*** br_fix_order_task_docrefid - Updated successfully ***")
   SET readme_data->message = "Readme Succeeded:  br_fix_order_task_docrefid - Updated successfully"
   SET readme_data->status = "S"
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
 IF ((readme_data->status="S"))
  COMMIT
  CALL echo("*** br_fix_order_task_docrefid - Updated successfully ***")
 ELSEIF (size(docsetids->task_qual,5)=0)
  SET readme_data->message = concat("docset_ref_id -  record not found in order_task table: ",err_msg
   )
  SET readme_data->status = "S"
 ELSE
  ROLLBACK
  CALL echo("Readme Failed: Could not update the docset ref ids, link to a task")
 ENDIF
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
