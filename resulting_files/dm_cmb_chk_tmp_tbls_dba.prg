CREATE PROGRAM dm_cmb_chk_tmp_tbls:dba
 SET prsn_constraint_name = fillstring(30," ")
 SET encntr_constraint_name = fillstring(30," ")
 SET loc_constraint_name = fillstring(30," ")
 SET org_constraint_name = fillstring(30," ")
 SET dynamic_where = fillstring(132," ")
 SET constraints_row_cnt = 0
 SET cons_columns_row_cnt = 0
 SET tab_columns_row_cnt = 0
 SET dm_constraints_cnt = 0
 SET dm_cons_columns_cnt = 0
 SET dm_tab_columns_cnt = 0
 SELECT INTO "nl:"
  u.constraint_name
  FROM user_constraints u
  WHERE u.table_name IN ("PERSON", "ENCOUNTER", "LOCATION", "ORGANIZATION")
   AND u.constraint_type="P"
  DETAIL
   IF (u.table_name="PERSON")
    prsn_constraint_name = u.constraint_name
   ELSEIF (u.table_name="ENCOUNTER")
    encntr_constraint_name = u.constraint_name
   ELSEIF (u.table_name="LOCATION")
    loc_constraint_name = u.constraint_name
   ELSEIF (u.table_name="ORGANIZATION")
    org_constraint_name = u.constraint_name
   ENDIF
  WITH nocounter
 ;end select
 SET dynamic_where = concat("uc.r_constraint_name in ('",trim(prsn_constraint_name),"', '",trim(
   encntr_constraint_name),"', '",
  trim(loc_constraint_name),"', '",trim(org_constraint_name),"')")
 SELECT INTO "nl:"
  uc.constraint_name
  FROM user_constraints uc
  WHERE uc.constraint_type="R"
   AND parser(dynamic_where)
  DETAIL
   constraints_row_cnt = (constraints_row_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  u.constraint_name
  FROM user_constraints u,
   dm_cmb_constraints d
  WHERE u.table_name=d.table_name
   AND u.constraint_type="P"
  GROUP BY u.constraint_name
  DETAIL
   constraints_row_cnt = (constraints_row_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d.constraint_name
  FROM dm_cmb_constraints d
  DETAIL
   dm_constraints_cnt = (dm_constraints_cnt+ 1)
  WITH nocounter
 ;end select
 IF (dm_constraints_cnt != constraints_row_cnt)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "dm_cmb_constraints - Number of rows does not match. Please rebuild."
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  ucc.constraint_name
  FROM user_cons_columns ucc,
   dm_cmb_constraints dcc
  WHERE ucc.constraint_name=dcc.constraint_name
  DETAIL
   cons_columns_row_cnt = (cons_columns_row_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dccc.constraint_name
  FROM dm_cmb_cons_columns dccc
  DETAIL
   dm_cons_columns_cnt = (dm_cons_columns_cnt+ 1)
  WITH nocounter
 ;end select
 IF (dm_cons_columns_cnt != cons_columns_row_cnt)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "dm_cmb_cons_columns - Number of rows does not match. Please rebuild."
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  utc.*
  FROM user_tab_columns utc
  DETAIL
   tab_columns_row_cnt = (tab_columns_row_cnt+ 1)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM dm_cmb_tab_columns
  DETAIL
   dm_tab_columns_cnt = (dm_tab_columns_cnt+ 1)
  WITH nocounter
 ;end select
 IF (dm_tab_columns_cnt != tab_columns_row_cnt)
  SET request->setup_proc[1].success_ind = 0
  SET request->setup_proc[1].error_msg =
  "dm_cmb_tab_columns - Number of rows does not match. Please rebuild."
  GO TO end_script
 ENDIF
 SET request->setup_proc[1].success_ind = 1
 SET request->setup_proc[1].error_msg = "Temp tables have been successfully built."
#end_script
 EXECUTE dm_add_upt_setup_proc_log
END GO
