CREATE PROGRAM dm_mmc_activity_log_rows:dba
 DECLARE v_years = i2 WITH noconstant(- (1))
 DECLARE v_err_code2 = i4
 DECLARE v_errmsg2 = vc
 DECLARE tok_ndx = i4
 SET reply->status_data.status = "F"
 SET reply->err_code = 1
 FOR (tok_ndx = 1 TO size(request->tokens,5))
   IF (trim(cnvtupper(request->tokens[tok_ndx].token_str),3)="YEARSOFACTIVITYLOGDATA")
    SET v_years = cnvtreal(request->tokens[tok_ndx].value)
   ENDIF
 ENDFOR
 IF ((v_years=- (1)))
  SET reply->err_code = - (1)
  SET reply->err_msg = build("The token, YEARSOFACTIVITYLOGDATA was not found!")
  GO TO exit_script
 ELSEIF (v_years < 2)
  SET reply->err_code = - (1)
  SET reply->err_msg = build("You must keep a minimum of two years worth of data. You entered  ",
   nullterm(trim(cnvtstring(v_years),3))," years to keep.")
  GO TO exit_script
 ENDIF
 SET reply->table_name = "MMC_ACTIVITY_LOG"
 SET reply->rows_between_commit = 100
 SELECT INTO "nl:"
  jl.rowid
  FROM mmc_activity_log jl
  WHERE jl.updt_dt_tm < cnvtdatetime((curdate - (v_years * 366)),curtime3)
   AND jl.activity_log_id != 0
  HEAD REPORT
   v_rows = 0
  DETAIL
   v_rows = (v_rows+ 1)
   IF (mod(v_rows,50)=1)
    stat = alterlist(reply->rows,(v_rows+ 49))
   ENDIF
   reply->rows[v_rows].row_id = jl.rowid
  FOOT REPORT
   stat = alterlist(reply->rows,v_rows)
  WITH nocounter, maxqual(jl,value(request->max_rows))
 ;end select
 SET v_errmsg2 = fillstring(132," ")
 SET v_err_code2 = 0
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET reply->status_data.status = "S"
  SET reply->err_code = 0
 ELSE
  SET reply->err_code = v_err_code2
 ENDIF
#exit_script
END GO
