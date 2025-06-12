CREATE PROGRAM dm_delete_environment:dba
 RECORD rchildren(
   1 child[*]
     2 tname = vc
     2 cname = vc
 )
 SET cnt = 0
 SET env_name = cnvtupper( $1)
 SET env_id = 0.0
 SELECT INTO "nl:"
  u.table_name
  FROM user_tables u
  WHERE u.table_name="DM_ENVIRONMENT"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo(" ")
  CALL echo("DM_ENVIRONMENT TABLE DOES NOT EXIST IN THIS DATABASE.")
  CALL echo("YOU MUST BE LOGGED INTO AN ADMIN DATABASE TO RUN THIS PROGRAM.")
  CALL echo("PLEASE LOG INTO THE ADMIN DATABASE AND RE-RUN THE PROGRAM.")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  e.environment_id
  FROM dm_environment e
  WHERE e.environment_name=env_name
  DETAIL
   env_id = e.environment_id
  WITH nocounter
 ;end select
 IF (env_id=0.0)
  CALL echo(" ")
  CALL echo("ENVIRONMENT TO DELETE DOES NOT EXIST.")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  uc.table_name
  FROM user_constraints uc,
   user_cons_columns ucc
  WHERE uc.constraint_type="R"
   AND uc.r_constraint_name="XPKDM_ENVIRONMENT"
   AND uc.constraint_name=ucc.constraint_name
   AND uc.table_name=ucc.table_name
   AND uc.owner=ucc.owner
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(rchildren->child,cnt), rchildren->child[cnt].tname = uc
   .table_name,
   rchildren->child[cnt].cname = ucc.column_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  utc.column_name
  FROM user_tab_columns utc
  WHERE utc.column_name="ENVIRONMENT_ID"
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(rchildren->child,cnt), rchildren->child[cnt].tname = utc
   .table_name,
   rchildren->child[cnt].cname = "ENVIRONMENT_ID"
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   CALL parser(concat("delete from ",trim(rchildren->child[x].tname)," t"))
   CALL parser(concat("where t.",trim(rchildren->child[x].cname)))
   CALL parser(build("= ",env_id))
   CALL parser(" go")
 ENDFOR
 COMMIT
#exit_script
END GO
