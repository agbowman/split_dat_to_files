CREATE PROGRAM cp_update_consultdoc:dba
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
 SET cnt_code_set = 0
 SET consult_encntr_cd = 0.0
 SET consult_order_cd = 0.0
 SET updated_cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.active_ind=1
   AND cv.code_set=22333
  HEAD REPORT
   cnt_code_set = 0, consult_encntr_cd = 0.0, consult_order_cd = 0.0
  DETAIL
   IF (cv.cdf_meaning="CONSENCNTR")
    consult_encntr_cd = cv.code_value, cnt_code_set += 1
   ELSEIF (cv.cdf_meaning="CONSORDER")
    consult_order_cd = cv.code_value, cnt_code_set += 1
   ENDIF
  WITH nocounter
 ;end select
 SET failed = "F"
 IF (((cnt_code_set != 2) OR (((consult_order_cd=0) OR (consult_encntr_cd=0)) )) )
  SET failed = "T"
  CALL echo("Failed to find new code_values from code_set 22333")
  GO TO exit_script
 ENDIF
 SET consult_doc_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=333
   AND cv.cdf_meaning="CONSULTDOC"
   AND cv.active_ind=1
  HEAD REPORT
   consult_doc_cd = 0.0
  DETAIL
   consult_doc_cd = cv.code_value
  WITH nocounter
 ;end select
 FREE RECORD ops_rec
 RECORD ops_rec(
   1 qual[*]
     2 ops_id = f8
     2 sequence = i4
     2 scope = i2
     2 param = vc
 )
 SELECT INTO "nl:"
  co.param
  FROM charting_operations co
  WHERE co.param_type_flag=6
  ORDER BY co.charting_operations_id, co.sequence
  HEAD REPORT
   do_nothing = 0, ops_cnt = 0
  DETAIL
   IF (cnvtint(co.param)=consult_doc_cd)
    ops_cnt += 1, stat = alterlist(ops_rec->qual,ops_cnt), ops_rec->qual[ops_cnt].ops_id = co
    .charting_operations_id,
    ops_rec->qual[ops_cnt].sequence = co.sequence, ops_rec->qual[ops_cnt].param = co.param
   ENDIF
  WITH nocounter
 ;end select
 SET size_ops = 0
 SET size_ops = size(ops_rec->qual,5)
 IF (size_ops=0)
  CALL echo("No operations to update providers")
  GO TO exit_script
 ENDIF
 SET x = 0
 FOR (x = 1 TO size_ops)
   SELECT INTO "nl:"
    co.charting_operations_id
    FROM charting_operations co
    WHERE (co.charting_operations_id=ops_rec->qual[x].ops_id)
     AND co.param_type_flag=1
    HEAD REPORT
     do_nothing = 0
    DETAIL
     ops_rec->qual[x].scope = cnvtint(co.param)
    WITH nocounter
   ;end select
 ENDFOR
 FOR (x = 1 TO size_ops)
   UPDATE  FROM charting_operations co
    SET co.param = cnvtstring(consult_encntr_cd)
    WHERE (co.charting_operations_id=ops_rec->qual[x].ops_id)
     AND (ops_rec->qual[x].scope != 4)
     AND (co.sequence=ops_rec->qual[x].sequence)
    WITH nocounter
   ;end update
   SET updated_cnt += curqual
   CALL echo(build("updated_cnt on CONSENCNTR = ",updated_cnt))
   UPDATE  FROM charting_operations co
    SET co.param = cnvtstring(consult_order_cd)
    WHERE (co.charting_operations_id=ops_rec->qual[x].ops_id)
     AND (ops_rec->qual[x].scope=4)
     AND (co.sequence=ops_rec->qual[x].sequence)
    WITH nocounter
   ;end update
   SET updated_cnt += curqual
   CALL echo(build("updated_cnt on CONSORDER = ",updated_cnt))
 ENDFOR
 CALL echo(build("TOTAL updated_cnt = ",updated_cnt))
#exit_script
 IF (failed="T")
  ROLLBACK
  SET readme_data->message =
  "Could not update consulting doctor values on charting_operations table - FAILURE"
  SET readme_data->status = "F"
  EXECUTE dm_readme_status
  COMMIT
  CALL echo("UPDATE CONSULTDOC - FAILED")
  ROLLBACK
 ELSE
  COMMIT
  SET readme_data->message =
  "Updated consulting doctor values on charting_operations table - SUCCESS"
  SET readme_data->status = "S"
  EXECUTE dm_readme_status
  COMMIT
  IF (updated_cnt=0)
   CALL echo("UPDATE CONSULTDOC - ZERO ROWS")
  ELSE
   CALL echo("UPDATE CONSULTDOC - SUCCESSFUL")
   CALL echo(build("UPDATED #ROWS = ",updated_cnt))
  ENDIF
 ENDIF
END GO
