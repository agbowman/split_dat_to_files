CREATE PROGRAM dm_cmb_bld_tmp_tbls:dba
 SELECT INTO "nl:"
  *
  FROM user_tables
  WHERE table_name IN ("DM_CMB_CONSTRAINTS", "DM_CMB_CONS_COLUMNS", "DM_CMB_TAB_COLUMNS")
 ;end select
 IF (curqual != 3)
  EXECUTE dm_cmb_create_tmp_tbls
 ENDIF
 SET prsn_constraint_name = fillstring(30," ")
 SET encntr_constraint_name = fillstring(30," ")
 SET loc_constraint_name = fillstring(30," ")
 SET org_constraint_name = fillstring(30," ")
 SET hp_constraint_name = fillstring(30," ")
 SET dynamic_where = fillstring(132," ")
 SELECT INTO "nl:"
  u.constraint_name
  FROM user_constraints u
  WHERE u.table_name IN ("PERSON", "ENCOUNTER", "LOCATION", "ORGANIZATION", "HEALTH_PLAN")
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
   ELSEIF (u.table_name="HEALTH_PLAN")
    hp_constraint_name = u.constraint_name
   ENDIF
  WITH nocounter
 ;end select
 SET dynamic_where = concat("uc.r_constraint_name in ('",trim(prsn_constraint_name),"', '",trim(
   encntr_constraint_name),"', '",
  trim(loc_constraint_name),"', '",trim(org_constraint_name),"', '",trim(hp_constraint_name),
  "')")
 DELETE  FROM dm_cmb_tab_columns
  WHERE 1=1
 ;end delete
 DELETE  FROM dm_cmb_cons_columns
  WHERE 1=1
 ;end delete
 DELETE  FROM dm_cmb_constraints
  WHERE 1=1
 ;end delete
 INSERT  FROM dm_cmb_constraints dcc
  (dcc.constraint_name, dcc.table_name, dcc.constraint_type,
  dcc.r_constraint_name, dcc.updt_dt_tm)(SELECT
   uc.constraint_name, uc.table_name, uc.constraint_type,
   uc.r_constraint_name, cnvtdatetime(curdate,curtime3)
   FROM user_constraints uc
   WHERE uc.constraint_type="R"
    AND parser(dynamic_where))
 ;end insert
 INSERT  FROM dm_cmb_constraints dcc
  (dcc.constraint_name, dcc.table_name, dcc.constraint_type,
  dcc.r_constraint_name, dcc.updt_dt_tm)(SELECT
   u.constraint_name, u.table_name, u.constraint_type,
   u.r_constraint_name, cnvtdatetime(curdate,curtime3)
   FROM user_constraints u
   WHERE u.constraint_type="P")
 ;end insert
 RDB analyze table dm_cmb_constraints estimate statistics
 END ;Rdb
 INSERT  FROM dm_cmb_cons_columns dccc
  (dccc.column_name, dccc.constraint_name, dccc.position,
  dccc.table_name, dccc.updt_dt_tm)(SELECT
   ucc.column_name, ucc.constraint_name, ucc.position,
   ucc.table_name, cnvtdatetime(curdate,curtime3)
   FROM user_cons_columns ucc,
    dm_cmb_constraints dcc
   WHERE ucc.constraint_name=dcc.constraint_name)
 ;end insert
 INSERT  FROM dm_cmb_tab_columns dctc
  (dctc.table_name, dctc.column_name, dctc.updt_dt_tm)(SELECT
   utc.table_name, utc.column_name, cnvtdatetime(curdate,curtime3)
   FROM user_tab_columns utc)
 ;end insert
 COMMIT
END GO
