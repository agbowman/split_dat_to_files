CREATE PROGRAM dm2_find_sequence_match_c2:dba
 DECLARE dfsm_c2_cnt = i4
 DECLARE v_errcode = i2
 SET fsm_sql->sql_lst[3].sql_stmt = concat(" WHERE t2.",dfsm_c1_col_name,
  " BETWEEN v_low_val AND v_my_current ")
 FOR (dfsm_c2_cnt = 1 TO dfsm_c1_chk_col_cnt)
   IF (dfsm_c2_cnt < dfsm_c1_chk_col_cnt)
    CALL parser(fsm_sql->sql_lst[dfsm_c2_cnt].sql_stmt,0)
   ELSE
    CALL parser(fsm_sql->sql_lst[dfsm_c2_cnt].sql_stmt,1)
   ENDIF
   SET v_errcode = 0
   SET v_errcode = error(v_errmsg,1)
   IF (v_errcode != 0)
    SET fms_c1_err_cd = 1
    GO TO end_program
   ENDIF
 ENDFOR
#end_program
END GO
