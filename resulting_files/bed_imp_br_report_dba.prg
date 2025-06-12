CREATE PROGRAM bed_imp_br_report:dba
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
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET new_id = 0.0
 SET row_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO row_cnt)
   SET upd_ind = 0
   SET upd_rpt_id = 0.0
   SELECT INTO "NL:"
    FROM br_report br
    WHERE br.program_name=trim(requestin->list_0[x].program_name)
    DETAIL
     upd_ind = 1, upd_rpt_id = br.br_report_id
    WITH nocounter
   ;end select
   IF (upd_ind=0
    AND upd_rpt_id=0.0)
    INSERT  FROM br_report b
     SET b.br_report_id = seq(reference_seq,nextval), b.br_client_id = 0.0, b.report_name = requestin
      ->list_0[x].report_name,
      b.program_name = requestin->list_0[x].program_name, b.step_cat_mean = requestin->list_0[x].
      step_cat, b.sequence = cnvtint(requestin->list_0[x].rpt_sequence),
      b.report_type_flag = cnvtint(requestin->list_0[x].report_type_flag), b.solution_mean =
      requestin->list_0[x].solution_mean, b.solution_disp = requestin->list_0[x].solution_disp,
      b.refresh_nbr_of_days = cnvtint(requestin->list_0[x].refresh_nbr_of_days), b.updt_dt_tm =
      cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id,
      b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    SET errcode = error(errmsg,1)
    IF (errcode != 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ELSE
    UPDATE  FROM br_report b
     SET b.report_name = requestin->list_0[x].report_name, b.step_cat_mean = requestin->list_0[x].
      step_cat, b.report_type_flag = cnvtint(requestin->list_0[x].report_type_flag),
      b.solution_mean = requestin->list_0[x].solution_mean, b.solution_disp = requestin->list_0[x].
      solution_disp, b.refresh_nbr_of_days = cnvtint(requestin->list_0[x].refresh_nbr_of_days),
      b.updt_dt_tm = cnvtdatetime(curdate,curtime3), b.updt_id = reqinfo->updt_id, b.updt_task =
      reqinfo->updt_task,
      b.updt_cnt = (b.updt_cnt+ 1), b.updt_applctx = reqinfo->updt_applctx
     WHERE b.br_report_id=upd_rpt_id
     WITH nocounter
    ;end update
    SET errcode = error(errmsg,1)
    IF (errcode != 0)
     ROLLBACK
     SET readme_data->status = "F"
     SET readme_data->message = concat("Readme Failed: ",errmsg)
     GO TO exit_script
    ELSE
     COMMIT
    ENDIF
   ENDIF
 ENDFOR
 GO TO exit_script
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_IMP_BR_REPORT","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
