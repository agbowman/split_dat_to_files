CREATE PROGRAM dpo_sch_job_rows:dba
 IF (validate(getcodevalue,char(128))=char(128))
  EXECUTE NULL ;noop
 ENDIF
 IF (validate(s_cdf_meaning,char(128))=char(128))
  DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 ENDIF
 IF ((validate(s_code_value,- (0.00001))=- (0.00001)))
  DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 ENDIF
 DECLARE pa_table_name = vc WITH protect, noconstant("")
 SUBROUTINE (getcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) =f8)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,s_cdf_meaning,1,s_code_value)
   IF (((stat != 0) OR (s_code_value <= 0.0)) )
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      SET pft_failed = uar_error
      EXECUTE pft_log "getcodevalue", pa_table_name, 0
      GO TO exit_script
     OF 1:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
     OF 2:
      SET pa_table_name = build("INFO-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      EXECUTE pft_log "getcodevalue", pa_table_name, 3
     OF 3:
      SET pa_table_name = build("ERROR-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(pa_table_name)
      CALL err_add_message(pa_table_name)
      SET pft_failed = uar_error
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->GetCodeValue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(cs23061_error_cd)))
  DECLARE cs23061_error_cd = f8 WITH protect, constant(getcodevalue(23061,"ERROR",0))
 ENDIF
 IF ( NOT (validate(cs23061_completed_cd)))
  DECLARE cs23061_completed_cd = f8 WITH protect, constant(getcodevalue(23061,"COMPLETED",0))
 ENDIF
 SET dpo_reply->status_data.status = "F"
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET dpo_reply->owner_name = "V500"
 SET dpo_reply->table_name = "SCH_JOB"
 SET dpo_reply->fetch_size = 10000
 DECLARE v_daystokeep = i4 WITH protect, noconstant(- (1))
 DECLARE v_tok_ndx = i4 WITH protect, noconstant(0)
 FOR (v_tok_ndx = 1 TO size(b_request->tokens,5))
   IF ((b_request->tokens[v_tok_ndx].token_str="DAYSTOKEEP"))
    SET v_daystokeep = ceil(cnvtreal(b_request->tokens[v_tok_ndx].value))
   ENDIF
 ENDFOR
 IF (v_daystokeep < 1)
  SET dpo_reply->status_data.status = "F"
  SET dpo_reply->err_code = - (1)
  SET reply->err_msg = uar_i18nbuildmessage(i18nhandle,"k1",
   "You must keep at least 1 day worth of data. You entered %1 days.","i",v_days_to_keep)
  GO TO exit_script
 ENDIF
 SET dpo_reply->cursor_query = build("select rowid from SCH_JOB WHERE UPDT_DT_TM <"," to_date('",
  format(datetimeadd(sysdate,(v_daystokeep * - (1))),"YYYY-MM-DD;;D"),"', 'YYYY-MM-DD')",
  " and parent_entity_name in ('WFSTATEEVAL', 'PFT_ENCNTR', 'pft_encntr',",
  " 'PFTENCNTR', 'corsp_log', 'ACTIVITY_LOG', 'CONS_BO_SCHED')"," and job_state_cd in (",
  cs23061_error_cd,", ",cs23061_completed_cd,
  ")")
 SET dpo_reply->status_data.status = "S"
 SET dpo_reply->err_code = 0
#exit_script
END GO
