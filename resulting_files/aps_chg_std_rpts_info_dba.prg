CREATE PROGRAM aps_chg_std_rpts_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 standard_rpt_cd = f8
     2 description = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET cur_r_updt_cnt[500] = 0
 SET nbr_of_reports = size(request->qual,5)
 SET x = 1
 SET error_cnt = 0
#start_of_script
 FOR (x = x TO nbr_of_reports)
   IF ((request->qual[x].action="A"))
    SELECT INTO "nl:"
     next_seq_nbr = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      request->qual[x].standard_rpt_cd = cnvtreal(next_seq_nbr)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     CALL handle_errors("NEXTVAL","F","SEQUENCE","REFERENCE_SEQ")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
    INSERT  FROM cyto_standard_rpt csr
     SET csr.standard_rpt_id =
      IF ((request->qual[x].standard_rpt_cd=0)) null
      ELSE request->qual[x].standard_rpt_cd
      ENDIF
      , csr.catalog_cd = request->qual[x].catalog_cd, csr.description = request->qual[x].description,
      csr.hot_key_sequence = request->qual[x].hot_key_sequence, csr.short_desc = request->qual[x].
      code, csr.active_ind = request->qual[x].active_ind,
      csr.updt_dt_tm = cnvtdatetime(curdate,curtime), csr.updt_id = reqinfo->updt_id, csr.updt_task
       = reqinfo->updt_task,
      csr.updt_applctx = reqinfo->updt_applctx, csr.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL handle_errors("INSERT","F","TABLE","CYTO_STANDARD_RPT")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
   ELSEIF ((request->qual[x].action="C"))
    SELECT INTO "nl:"
     csr.*
     FROM cyto_standard_rpt csr
     WHERE (csr.standard_rpt_id=request->qual[x].standard_rpt_cd)
      AND (csr.catalog_cd=request->qual[x].catalog_cd)
     DETAIL
      cur_updt_cnt = csr.updt_cnt
     WITH forupdate(csr)
    ;end select
    IF (curqual=0)
     CALL handle_errors("SELECT","F","TABLE","CYTO_STANDARD_RPT")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
    IF ((request->qual[x].updt_cnt != cur_updt_cnt))
     CALL handle_errors("LOCK","F","TABLE","CYTO_STANDARD_RPT")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
    SET cur_updt_cnt = (cur_updt_cnt+ 1)
    UPDATE  FROM cyto_standard_rpt csr
     SET csr.catalog_cd = request->qual[x].catalog_cd, csr.description = request->qual[x].description,
      csr.hot_key_sequence = request->qual[x].hot_key_sequence,
      csr.short_desc = request->qual[x].code, csr.active_ind = request->qual[x].active_ind, csr
      .updt_dt_tm = cnvtdatetime(curdate,curtime),
      csr.updt_cnt = cur_updt_cnt, csr.updt_id = reqinfo->updt_id, csr.updt_task = reqinfo->updt_task,
      csr.updt_applctx = reqinfo->updt_applctx
     WHERE (csr.standard_rpt_id=request->qual[x].standard_rpt_cd)
      AND (csr.catalog_cd=request->qual[x].catalog_cd)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("UPDATE","F","TABLE","CYTO_STANDARD_RPT")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].task_chg_cnt > 0))
    SELECT INTO "nl:"
     csr_r.*
     FROM cyto_standard_rpt_r csr_r,
      (dummyt d  WITH seq = value(request->qual[x].task_chg_cnt))
     PLAN (d)
      JOIN (csr_r
      WHERE (csr_r.standard_rpt_id=request->qual[x].standard_rpt_cd)
       AND (csr_r.task_assay_cd=request->qual[x].task_chg_qual[d.seq].task_assay_cd))
     HEAD REPORT
      count1 = 0
     DETAIL
      count1 = (count1+ 1), cur_r_updt_cnt[count1] = csr_r.updt_cnt
     WITH nocounter, forupdate(csr_r)
    ;end select
    IF (curqual=0)
     CALL handle_errors("CHANGE","F","TABLE","CYTO_STANDARD_RPT_R")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
    FOR (chg_cnt = 1 TO request->qual[x].task_chg_cnt)
      IF ((request->qual[x].task_chg_qual[chg_cnt].updt_cnt != cur_r_updt_cnt[chg_cnt]))
       CALL handle_errors("CHANGE","F","TABLE","CYTO_STANDARD_RPT_R john")
       SET x = (x+ 1)
       GO TO start_of_script
      ENDIF
    ENDFOR
    UPDATE  FROM cyto_standard_rpt_r csr_r,
      (dummyt d  WITH seq = value(request->qual[x].task_chg_cnt))
     SET csr_r.seq = 1, csr_r.standard_rpt_id = request->qual[x].standard_rpt_cd, csr_r.task_assay_cd
       = request->qual[x].task_chg_qual[d.seq].task_assay_cd,
      csr_r.nomenclature_id = request->qual[x].task_chg_qual[d.seq].result_cd, csr_r.result_text =
      request->qual[x].task_chg_qual[d.seq].result_text, csr_r.updt_cnt = (csr_r.updt_cnt+ 1),
      csr_r.updt_dt_tm = cnvtdatetime(curdate,curtime3), csr_r.updt_id = reqinfo->updt_id, csr_r
      .updt_task = reqinfo->updt_task,
      csr_r.updt_applctx = reqinfo->updt_applctx
     PLAN (d)
      JOIN (csr_r
      WHERE (csr_r.standard_rpt_id=request->qual[x].standard_rpt_cd)
       AND (csr_r.task_assay_cd=request->qual[x].task_chg_qual[d.seq].task_assay_cd))
     WITH nocounter
    ;end update
    IF ((curqual != request->qual[x].task_chg_cnt))
     CALL handle_errors("CHANGE","F","TABLE","CYTO_STANDARD_RPT_R")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].task_add_cnt > 0))
    INSERT  FROM cyto_standard_rpt_r csr_r,
      (dummyt d  WITH seq = value(request->qual[x].task_add_cnt))
     SET csr_r.standard_rpt_id = request->qual[x].standard_rpt_cd, csr_r.task_assay_cd = request->
      qual[x].task_add_qual[d.seq].task_assay_cd, csr_r.nomenclature_id = request->qual[x].
      task_add_qual[d.seq].result_cd,
      csr_r.result_text = request->qual[x].task_add_qual[d.seq].result_text, csr_r.updt_dt_tm =
      cnvtdatetime(curdate,curtime), csr_r.updt_id = reqinfo->updt_id,
      csr_r.updt_task = reqinfo->updt_task, csr_r.updt_applctx = reqinfo->updt_applctx, csr_r
      .updt_cnt = 0
     PLAN (d)
      JOIN (csr_r)
     WITH nocounter
    ;end insert
    IF ((curqual != request->qual[x].task_add_cnt))
     CALL handle_errors("ADD","F","TABLE","CYTO_STANDARD_RPT_R")
     SET x = (x+ 1)
     GO TO start_of_script
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
#exit_script
 IF (error_cnt > 0)
  IF (error_cnt=nbr_of_reports)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   IF ((request->qual[x].action="A"))
    SET reply->exception_data[error_cnt].description = request->qual[x].description
   ELSE
    SET reply->exception_data[error_cnt].standard_rpt_cd = request->qual[x].standard_rpt_cd
   ENDIF
   SET x = (x+ 1)
 END ;Subroutine
END GO
