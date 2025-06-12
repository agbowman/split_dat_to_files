CREATE PROGRAM dm_combine_code_value:dba
 RECORD reply(
   1 sql[*]
     2 line = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET dcc_err_ind = 0
 SET dcc_err_msg = fillstring(132," ")
 SET dec_p = 0
 SET more_combine_rows = 1
 WHILE (more_combine_rows=1)
   EXECUTE dm_combine_code_value_sub
 ENDWHILE
 IF ((reply->status_data.status="S"))
  UPDATE  FROM code_value c
   SET c.active_ind = false, c.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), c.inactive_dt_tm
     = cnvtdatetime(curdate,curtime),
    c.data_status_cd = request->auth_cd, c.data_status_prsnl_id = request->current_user_id, c
    .data_status_dt_tm = cnvtdatetime(curdate,curtime3),
    c.active_type_cd = request->inactive_cd, c.active_dt_tm = cnvtdatetime(curdate,curtime), c
    .active_status_prsnl_id = request->current_user_id,
    c.updt_id = request->current_user_id, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt
     = (c.updt_cnt+ 1)
   WHERE (c.code_value=request->from_cv)
   WITH nocounter
  ;end update
  CALL dcc_err_chk(0)
  UPDATE  FROM code_value_alias c
   SET c.code_value = request->to_cv, c.updt_id = request->current_user_id, c.updt_dt_tm =
    cnvtdatetime(curdate,curtime3),
    c.updt_cnt = (c.updt_cnt+ 1)
   WHERE (c.code_value=request->from_cv)
   WITH nocounter
  ;end update
  CALL dcc_err_chk(0)
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
 SUBROUTINE dcc_err_chk(dec_p)
  SET dcc_err_ind = error(dcc_err_msg,1)
  IF (dcc_err_ind > 0)
   ROLLBACK
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 END ;Subroutine
#exit_script
END GO
