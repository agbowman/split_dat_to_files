CREATE PROGRAM dm_cmb_comp_tmp_tbls:dba
 PAINT
 SET modify = system
 SET width = 80
#100_start
 SET dt = cnvtdatetime(sysdate)
 SELECT INTO "nl:"
  d.updt_dt_tm
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="TEMPLASTBLD"
  DETAIL
   dt = d.updt_dt_tm
  WITH nocounter
 ;end select
 CALL video(n)
 CALL box(3,1,23,80)
 CALL text(2,2,"Last update:")
 CALL text(2,15,format(dt,"DD-MMM-YYYY HH:MM;3;d"))
 CALL text(5,30,"current         ORACLE")
 CALL text(24,2,"Extracting data...")
 SET dm_uc_cnt = 0
 SET dm_duc_cnt = 0
 SELECT INTO "nl:"
  uc.seq
  FROM user_constraints uc
  WHERE uc.owner=currdbuser
   AND uc.constraint_type IN ("R", "P", "U")
  DETAIL
   dm_uc_cnt += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  duc.seq
  FROM dm_user_constraints duc
  WHERE duc.constraint_type IN ("R", "P", "U")
  DETAIL
   dm_duc_cnt += 1
  WITH nocounter
 ;end select
 CALL text(7,3,"dm_user_constraints")
 CALL text(7,30,format(dm_duc_cnt,"#######"))
 CALL text(7,45,format(dm_uc_cnt,"#######"))
 CALL text(24,2,"Extracting data...")
 SET dm_ucc_cnt = 0
 SET dm_ducc_cnt = 0
 SELECT INTO "nl:"
  cc.seq
  FROM user_cons_columns cc,
   user_constraints c
  WHERE c.constraint_type IN ("P", "U")
   AND cc.owner=c.owner
   AND cc.table_name=c.table_name
   AND cc.constraint_name=c.constraint_name
  DETAIL
   dm_ucc_cnt += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cc.seq
  FROM user_cons_columns cc,
   user_constraints c1,
   user_constraints c
  WHERE c.constraint_type="R"
   AND c1.owner=c.r_owner
   AND c1.constraint_name=c.r_constraint_name
   AND cc.owner=c.owner
   AND cc.table_name=c.table_name
   AND cc.constraint_name=c.constraint_name
  DETAIL
   dm_ucc_cnt += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ducc.seq
  FROM dm_user_cons_columns ducc
  DETAIL
   dm_ducc_cnt += 1
  WITH nocounter
 ;end select
 CALL text(9,3,"dm_user_cons_columns")
 CALL text(9,30,format(dm_ducc_cnt,"#######"))
 CALL text(9,45,format(dm_ucc_cnt,"#######"))
 CALL text(24,2,"Extracting data...")
 SET dm_uic_cnt = 0
 SET dm_duic_cnt = 0
 SELECT INTO "nl:"
  b.seq
  FROM user_indexes a,
   user_ind_columns b
  WHERE a.table_name=b.table_name
   AND a.index_name=b.index_name
  DETAIL
   dm_uic_cnt += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  duic.seq
  FROM dm_user_ind_columns duic
  DETAIL
   dm_duic_cnt += 1
  WITH nocounter
 ;end select
 CALL text(11,3,"dm_user_ind_columns")
 CALL text(11,30,format(dm_duic_cnt,"#######"))
 CALL text(11,45,format(dm_uic_cnt,"#######"))
 CALL text(24,2,"Extracting data...")
 SET dm_utc_cnt = 0
 SET dm_dutc_cnt = 0
 SELECT INTO "nl:"
  a.seq
  FROM user_tab_columns a,
   user_tables b
  WHERE a.table_name=b.table_name
  DETAIL
   dm_utc_cnt += 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dutc.seq
  FROM dm_user_tab_cols dutc
  DETAIL
   dm_dutc_cnt += 1
  WITH nocounter
 ;end select
 CALL text(13,3,"dm_user_tab_cols")
 CALL text(13,30,format(dm_dutc_cnt,"#######"))
 CALL text(13,45,format(dm_utc_cnt,"#######"))
 CALL clear(24,1)
 CALL text(24,2,"Update temp tables (Y/N)? ")
 CALL accept(24,28,"p;cud","N"
  WHERE curaccept IN ("Y", "N"))
 CALL clear(24,1)
 IF (curaccept="Y")
  CALL clear(24,1)
  CALL text(24,2,"Working... ")
  EXECUTE dm_temp_tables
  FOR (x = 1 TO 23)
    CALL clear(x,1,80)
  ENDFOR
  GO TO 100_start
 ENDIF
END GO
