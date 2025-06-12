CREATE PROGRAM br_fsi_config:dba
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
 SET readme_data->message = "Readme Failed: Starting <br_fsi_config.prg> script"
 DELETE  FROM br_fsi
  WHERE fsi_id > 0.0
  WITH nocounter
 ;end delete
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET fsi_request
 RECORD fsi_request(
   1 fsilist[*]
     2 fsi_id = f8
     2 action_flag = i4
     2 fsi_supplier_name = vc
     2 fsi_system_name = vc
     2 adt_ind = i2
     2 order_ind = i2
     2 transcription_ind = i2
     2 result_ind = i2
     2 charge_ind = i2
     2 document_ind = i2
     2 dictation_ind = i2
     2 rli_ind = i2
     2 schedule_ind = i2
     2 phys_mfn_ind = i2
     2 problem_ind = i2
     2 allergy_ind = i2
     2 immun_ind = i2
     2 claims_ind = i2
     2 supply_ind = i2
     2 misc_type_ind = i2
     2 misc_type_desc = vc
 )
 FREE SET fsi_reply
 RECORD fsi_reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE error_msg = vc WITH private
 DECLARE error_flag = vc WITH private
 DECLARE numrows = i4
 DECLARE dup_found = vc
 DECLARE fsicount = i4
 SET error_flag = "N"
 SET numrows = size(requestin->list_0,5)
 SET insert_cnt = 0
 SET fsicount = 0
 SET y = 0
 SET active_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="ACTIVE")
  DETAIL
   active_cd = c.code_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO numrows)
   SET dup_found = "N"
   CALL checkdup(x)
   IF (dup_found="N")
    SET y = (y+ 1)
    SET stat = alterlist(fsi_request->fsilist,x)
    SET fsi_request->fsilist[y].action_flag = 1
    SET fsi_request->fsilist[y].fsi_supplier_name = requestin->list_0[x].supplier
    SET fsi_request->fsilist[y].fsi_system_name = requestin->list_0[x].system
    IF (cnvtupper(requestin->list_0[x].adt)="X")
     SET fsi_request->fsilist[y].adt_ind = 1
    ELSE
     SET fsi_request->fsilist[y].adt_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].orders)="X")
     SET fsi_request->fsilist[y].order_ind = 1
    ELSE
     SET fsi_request->fsilist[y].order_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].transcription)="X")
     SET fsi_request->fsilist[y].transcription_ind = 1
    ELSE
     SET fsi_request->fsilist[y].transcription_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].result)="X")
     SET fsi_request->fsilist[y].result_ind = 1
    ELSE
     SET fsi_request->fsilist[y].result_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].charge)="X")
     SET fsi_request->fsilist[y].charge_ind = 1
    ELSE
     SET fsi_request->fsilist[y].charge_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].document)="X")
     SET fsi_request->fsilist[y].document_ind = 1
    ELSE
     SET fsi_request->fsilist[y].document_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].dictation)="X")
     SET fsi_request->fsilist[y].dictation_ind = 1
    ELSE
     SET fsi_request->fsilist[y].dictation_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].rli)="X")
     SET fsi_request->fsilist[y].rli_ind = 1
    ELSE
     SET fsi_request->fsilist[y].rli_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].schedule)="X")
     SET fsi_request->fsilist[y].schedule_ind = 1
    ELSE
     SET fsi_request->fsilist[y].schedule_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].phys_mfn)="X")
     SET fsi_request->fsilist[y].phys_mfn_ind = 1
    ELSE
     SET fsi_request->fsilist[y].phys_mfn_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].problem)="X")
     SET fsi_request->fsilist[y].problem_ind = 1
    ELSE
     SET fsi_request->fsilist[y].problem_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].allergy)="X")
     SET fsi_request->fsilist[y].allergy_ind = 1
    ELSE
     SET fsi_request->fsilist[y].allergy_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].immunization)="X")
     SET fsi_request->fsilist[y].immun_ind = 1
    ELSE
     SET fsi_request->fsilist[y].immun_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].claims)="X")
     SET fsi_request->fsilist[y].claims_ind = 1
    ELSE
     SET fsi_request->fsilist[y].claims_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].supply)="X")
     SET fsi_request->fsilist[y].supply_ind = 1
    ELSE
     SET fsi_request->fsilist[y].supply_ind = 0
    ENDIF
    IF (cnvtupper(requestin->list_0[x].misc_type)="X")
     SET fsi_request->fsilist[y].misc_type_ind = 1
     SET fsi_request->fsilist[y].misc_type_desc = requestin->list_0[x].misc_type_description
    ELSE
     SET fsi_request->fsilist[y].misc_type_ind = 0
    ENDIF
   ENDIF
 ENDFOR
 SET newrows = size(fsi_request->fsilist,5)
 FOR (i = 1 TO newrows)
   IF ((fsi_request->fsilist[i].fsi_supplier_name > " "))
    SET fsicount = (fsicount+ 1)
    SET new_fsi_id = 0.0
    SELECT INTO "nl:"
     j = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_fsi_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM br_fsi b
     SET b.fsi_id = new_fsi_id, b.fsi_supplier_name = trim(fsi_request->fsilist[i].fsi_supplier_name),
      b.fsi_system_name = trim(fsi_request->fsilist[i].fsi_system_name),
      b.adt_ind = fsi_request->fsilist[i].adt_ind, b.order_ind = fsi_request->fsilist[i].order_ind, b
      .transcription_ind = fsi_request->fsilist[i].transcription_ind,
      b.result_ind = fsi_request->fsilist[i].result_ind, b.charge_ind = fsi_request->fsilist[i].
      charge_ind, b.document_ind = fsi_request->fsilist[i].document_ind,
      b.dictation_ind = fsi_request->fsilist[i].dictation_ind, b.rli_ind = fsi_request->fsilist[i].
      rli_ind, b.schedule_ind = fsi_request->fsilist[i].schedule_ind,
      b.phys_mfn_ind = fsi_request->fsilist[i].phys_mfn_ind, b.problem_ind = fsi_request->fsilist[i].
      problem_ind, b.allergy_ind = fsi_request->fsilist[i].allergy_ind,
      b.immun_ind = fsi_request->fsilist[i].immun_ind, b.claims_ind = fsi_request->fsilist[i].
      claims_ind, b.supply_ind = fsi_request->fsilist[i].supply_ind,
      b.misc_type_ind = fsi_request->fsilist[i].misc_type_ind, b.misc_type_desc = fsi_request->
      fsilist[i].misc_type_desc, b.active_ind = 1,
      b.active_status_cd = active_cd, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id =
      reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "T"
     SET insert_cnt = (insert_cnt+ 1)
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
 SUBROUTINE checkdup(x)
  SELECT INTO "nl:"
   FROM br_fsi b
   PLAN (b
    WHERE cnvtupper(trim(b.fsi_supplier_name))=cnvtupper(trim(requestin->list_0[x].supplier))
     AND cnvtupper(trim(b.fsi_system_name))=cnvtupper(trim(requestin->list_0[x].system)))
   DETAIL
    z = 1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET dup_found = "Y"
  ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="T")
  SET error_msg = concat("Unable to insert: ",cnvtstring(insert_cnt))
 ENDIF
 IF (((error_flag="N") OR (error_flag="T")) )
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Succeeded: <br_fsi_config.prg> script"
  COMMIT
 ELSE
  SET readme_data->status = "F"
  SET readme_data->message = "Readme Failed: <br_fsi_config.prg> script"
  ROLLBACK
 ENDIF
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
