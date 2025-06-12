CREATE PROGRAM bed_ens_br_fsi:dba
 FREE SET reply
 RECORD reply(
   1 fsis[*]
     2 br_fsi_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE active_cd = f8
 DECLARE inactive_cd = f8
 DECLARE error_msg = vc
 DECLARE error_flag = vc
 DECLARE new_fsi_id = f8
 DECLARE dup_found = vc
 DECLARE fsicount = i4
 SET reply->status_data.status = "F"
 SET error_flag = "N"
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
 SET inactive_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=48
    AND c.cdf_meaning="INACTIVE")
  DETAIL
   inactive_cd = c.code_value
  WITH nocounter
 ;end select
 SET numrows = size(request->fsilist,5)
 FOR (i = 1 TO numrows)
   IF ((request->fsilist[i].action_flag=1))
    SET dup_found = "N"
    CALL checkdup(i)
    IF (dup_found="N")
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
      SET b.fsi_id = new_fsi_id, b.fsi_supplier_name = trim(request->fsilist[i].fsi_supplier_name), b
       .fsi_system_name = trim(request->fsilist[i].fsi_system_name),
       b.adt_ind = request->fsilist[i].adt_ind, b.order_ind = request->fsilist[i].order_ind, b
       .transcription_ind = request->fsilist[i].transcription_ind,
       b.result_ind = request->fsilist[i].result_ind, b.charge_ind = request->fsilist[i].charge_ind,
       b.document_ind = request->fsilist[i].document_ind,
       b.dictation_ind = request->fsilist[i].dictation_ind, b.rli_ind = request->fsilist[i].rli_ind,
       b.schedule_ind = request->fsilist[i].schedule_ind,
       b.phys_mfn_ind = request->fsilist[i].phys_mfn_ind, b.problem_ind = request->fsilist[i].
       problem_ind, b.allergy_ind = request->fsilist[i].allergy_ind,
       b.immun_ind = request->fsilist[i].immun_ind, b.claims_ind = request->fsilist[i].claims_ind, b
       .supply_ind = request->fsilist[i].supply_ind,
       b.misc_type_ind = request->fsilist[i].misc_type_ind, b.misc_type_desc = request->fsilist[i].
       misc_type_desc, b.active_ind = 1,
       b.active_status_cd = active_cd, b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id =
       reqinfo->updt_id,
       b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (curqual=0)
      SET error_flag = "Y"
      SET error_msg = concat(error_msg,"Error inserting br_fsi row: ",request->fsilist[i].
       fsi_supplier_name,":",request->fsilist[i].fsi_system_name,
       ". ")
      GO TO exit_script
     ELSE
      SET stat = alterlist(reply->fsis,fsicount)
      SET reply->fsis[fsicount].br_fsi_id = new_fsi_id
     ENDIF
    ELSE
     SET error_msg = concat(error_msg,"Error adding FSI ",request->fsilist[i].fsi_supplier_name,":",
      request->fsilist[i].fsi_system_name,
      ". ","Supplier/System already exists.")
     SET error_flag = "Y"
    ENDIF
   ELSEIF ((request->fsilist[i].action_flag=2))
    UPDATE  FROM br_fsi b
     SET b.fsi_supplier_name = request->fsilist[i].fsi_supplier_name, b.fsi_system_name = request->
      fsilist[i].fsi_system_name, b.adt_ind = request->fsilist[i].adt_ind,
      b.order_ind = request->fsilist[i].order_ind, b.transcription_ind = request->fsilist[i].
      transcription_ind, b.result_ind = request->fsilist[i].result_ind,
      b.charge_ind = request->fsilist[i].charge_ind, b.document_ind = request->fsilist[i].
      document_ind, b.dictation_ind = request->fsilist[i].dictation_ind,
      b.rli_ind = request->fsilist[i].rli_ind, b.schedule_ind = request->fsilist[i].schedule_ind, b
      .phys_mfn_ind = request->fsilist[i].phys_mfn_ind,
      b.problem_ind = request->fsilist[i].problem_ind, b.allergy_ind = request->fsilist[i].
      allergy_ind, b.immun_ind = request->fsilist[i].immun_ind,
      b.claims_ind = request->fsilist[i].claims_ind, b.supply_ind = request->fsilist[i].supply_ind, b
      .misc_type_ind = request->fsilist[i].misc_type_ind,
      b.misc_type_desc = request->fsilist[i].misc_type_desc, b.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->
      updt_applctx
     WHERE (b.fsi_id=request->fsilist[i].fsi_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat(error_msg,"Error updating br_fsi row: ",request->fsilist[i].
      fsi_supplier_name,":",request->fsilist[i].fsi_system_name,
      ". ")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->fsilist[i].action_flag=3))
    UPDATE  FROM br_fsi b
     SET b.active_ind = 0, b.active_status_cd = inactive_cd, b.updt_dt_tm = cnvtdatetime(curdate,
       curtime3),
      b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_cnt = (b.updt_cnt+ 1),
      b.updt_applctx = reqinfo->updt_applctx
     WHERE (b.fsi_id=request->fsilist[i].fsi_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat(error_msg,"Error deleting br_fsi row: ",request->fsilist[i].
      fsi_supplier_name,":",request->fsilist[i].fsi_system_name,
      ". ")
     GO TO exit_script
    ENDIF
   ELSE
    SET error_flag = "Y"
    SET error_msg = concat(error_msg,"Invalid action flag for ",request->fsilist[i].fsi_supplier_name,
     ":",request->fsilist[i].fsi_system_name,
     ". ","Action flag: ",cnvtstring(request->fsilist[i].action_flag))
    GO TO exit_script
   ENDIF
 ENDFOR
 SUBROUTINE checkdup(i)
  SELECT INTO "nl:"
   FROM br_fsi b
   PLAN (b
    WHERE (b.fsi_supplier_name=request->fsilist[i].fsi_supplier_name)
     AND (b.fsi_system_name=request->fsilist[i].fsi_system_name))
   DETAIL
    x = 1
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET dup_found = "Y"
  ENDIF
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  SET reply->error_msg = concat(error_msg)
 ELSEIF (error_flag="Y")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_BR_FSI","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
