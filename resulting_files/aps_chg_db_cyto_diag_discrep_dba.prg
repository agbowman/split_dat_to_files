CREATE PROGRAM aps_chg_db_cyto_diag_discrep:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt[500] = 0
 SET count1 = 0
 SET error_cnt = 0
#start_of_script
 IF ((request->add_qual_cnt > 0))
  INSERT  FROM cyto_diag_discrepancy cdd,
    (dummyt d  WITH seq = value(request->add_qual_cnt))
   SET cdd.reference_range_factor_id = request->add_qual[d.seq].reference_range_factor_id, cdd
    .nomenclature_x_id = request->add_qual[d.seq].nomenclature_x_id, cdd.nomenclature_y_id = request
    ->add_qual[d.seq].nomenclature_y_id,
    cdd.internal_flag = request->add_qual[d.seq].internal_flag, cdd.hcfa_flag = request->add_qual[d
    .seq].hcfa_flag, cdd.updt_cnt = 0,
    cdd.updt_dt_tm = cnvtdatetime(curdate,curtime), cdd.updt_id = reqinfo->updt_id, cdd.updt_task =
    reqinfo->updt_task,
    cdd.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (cdd)
   WITH nocounter
  ;end insert
  IF (curqual=0)
   CALL handle_errors("INSERT","F","TABLE","CYTO_DIAG_DISCREPANCY")
  ENDIF
 ENDIF
 IF ((request->chg_qual_cnt > 0))
  SELECT INTO "nl:"
   cdd.*
   FROM cyto_diag_discrepancy cdd,
    (dummyt d  WITH seq = value(request->chg_qual_cnt))
   PLAN (d)
    JOIN (cdd
    WHERE (request->chg_qual[d.seq].reference_range_factor_id=cdd.reference_range_factor_id)
     AND (request->chg_qual[d.seq].nomenclature_x_id=cdd.nomenclature_x_id)
     AND (request->chg_qual[d.seq].nomenclature_y_id=cdd.nomenclature_y_id))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), cur_updt_cnt[count1] = cdd.updt_cnt
   WITH forupdate(cdd)
  ;end select
  IF (((curqual=0) OR ((count1 != request->chg_qual_cnt))) )
   CALL handle_errors("UPDATE","F","TABLE","CYTO_DIAG_DISCREPANCY")
  ELSE
   FOR (x = 1 TO request->chg_qual_cnt)
     IF ((request->chg_qual[x].updt_cnt != cur_updt_cnt[x]))
      CALL handle_errors("UPDATE","F","TABLE","CYTO_DIAG_DISCREPANCY")
     ENDIF
   ENDFOR
   UPDATE  FROM cyto_diag_discrepancy cdd,
     (dummyt d  WITH seq = value(request->chg_qual_cnt))
    SET cdd.internal_flag = request->chg_qual[d.seq].internal_flag, cdd.hcfa_flag = request->
     chg_qual[d.seq].hcfa_flag, cdd.updt_cnt = (request->chg_qual[d.seq].updt_cnt+ 1),
     cdd.updt_dt_tm = cnvtdatetime(curdate,curtime), cdd.updt_id = reqinfo->updt_id, cdd.updt_task =
     reqinfo->updt_task,
     cdd.updt_applctx = reqinfo->updt_applctx
    PLAN (d)
     JOIN (cdd
     WHERE (request->chg_qual[d.seq].reference_range_factor_id=cdd.reference_range_factor_id)
      AND (request->chg_qual[d.seq].nomenclature_x_id=cdd.nomenclature_x_id)
      AND (request->chg_qual[d.seq].nomenclature_y_id=cdd.nomenclature_y_id))
    WITH nocounter
   ;end update
   IF ((curqual != request->chg_qual_cnt))
    CALL handle_errors("UPDATE","F","TABLE","CYTO_DIAG_DISCREPANCY")
   ENDIF
  ENDIF
 ENDIF
 IF ((request->del_qual_cnt > 0))
  DELETE  FROM cyto_diag_discrepancy cdd,
    (dummyt d  WITH seq = value(request->del_qual_cnt))
   SET cdd.seq = 1
   PLAN (d)
    JOIN (cdd
    WHERE (cdd.reference_range_factor_id=request->del_qual[d.seq].reference_range_factor_id)
     AND (cdd.nomenclature_x_id=request->del_qual[d.seq].nomenclature_x_id)
     AND (cdd.nomenclature_y_id=request->del_qual[d.seq].nomenclature_y_id))
   WITH nocounter
  ;end delete
  IF ((curqual != request->del_qual_cnt))
   CALL handle_errors("DELETE","F","TABLE","CYTO_DIAG_DISCREPANCY")
  ENDIF
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = op_name
   SET reply->status_data.subeventstatus[1].operationstatus = op_status
   SET reply->status_data.subeventstatus[1].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[1].targetobjectvalue = tar_value
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF (error_cnt > 0)
  SET reply->status_data.status = "F"
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
 ENDIF
END GO
