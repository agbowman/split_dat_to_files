CREATE PROGRAM dm_create_cmb_views:dba
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
 SET readme_data->status = "F"
 SET dummy = 0
 SET dcc_err_msg = fillstring(132," ")
 SET p_exist = 0
 SET e_exist = 0
 SET b_exist = 0
 SET db_view = 0
 SET ccl_view = 0
 DECLARE err_chk(dummy) = null
 DECLARE view_chk(dummy) = null
 IF (currdb="ORACLE")
  CALL parser("rdb create or replace view dm_cmb_person_children")
  CALL parser("(child_table, child_column, child_pk)")
  CALL parser("as")
  CALL parser("select distinct a.child_table, a.child_column, a.child_pk")
  CALL parser("from dm_cmb_children a")
  CALL parser("where a.parent_table = 'PERSON'")
  CALL parser("and not exists")
  CALL parser("(select 'x' from dm_cmb_exception dce")
  CALL parser("where dce.operation_type = 'COMBINE'")
  CALL parser("and dce.parent_entity = 'PERSON'")
  CALL parser("and dce.child_entity = a.child_table)")
  CALL parser("go")
  CALL err_chk(dummy)
  DROP TABLE dm_cmb_person_children
  CALL err_chk(dummy)
  CALL parser("oragen3 'dm_cmb_person_children' go")
  CALL parser("rdb create or replace view dm_cmb_encounter_children")
  CALL parser("(child_table, child_column, child_pk)")
  CALL parser("as")
  CALL parser("select distinct a.child_table, a.child_column, a.child_pk")
  CALL parser("from dm_cmb_children a")
  CALL parser("where a.parent_table = 'ENCOUNTER'")
  CALL parser("and not exists")
  CALL parser("(select 'x' from dm_cmb_exception dce")
  CALL parser("where dce.operation_type = 'COMBINE'")
  CALL parser("and dce.parent_entity = 'ENCOUNTER'")
  CALL parser("and dce.child_entity = a.child_table)")
  CALL parser("go")
  CALL err_chk(dummy)
  DROP TABLE dm_cmb_encounter_children
  CALL err_chk(dummy)
  CALL parser("oragen3 'dm_cmb_encounter_children' go")
  CALL parser("rdb create or replace view dm_cmb_both_children")
  CALL parser("(child_table, person_column, encounter_column, child_pk)")
  CALL parser("as")
  CALL parser("select distinct a1.child_table, a1.child_column, a2.child_column, a1.child_pk")
  CALL parser("from dm_cmb_children a1, dm_cmb_children a2")
  CALL parser("where a1.parent_table = 'PERSON'")
  CALL parser("and a2.parent_table = 'ENCOUNTER'")
  CALL parser("and a1.child_table = a2.child_table")
  CALL parser("and not exists")
  CALL parser("(select 'x' from dm_cmb_exception dce")
  CALL parser("where dce.operation_type = 'COMBINE'")
  CALL parser("and dce.parent_entity = 'PERSON'")
  CALL parser("and dce.child_entity = a1.child_table)")
  CALL parser("go")
  CALL err_chk(dummy)
  DROP TABLE dm_cmb_both_children
  CALL err_chk(dummy)
  CALL parser("oragen3 'dm_cmb_both_children' go ")
 ELSEIF (currdb="DB2UDB")
  CALL view_chk(dummy)
  IF (p_exist=1)
   CALL echo("drop dm_cmb_person_children.")
   CALL parser("rdb drop view dm_cmb_person_children go")
   CALL err_chk(dummy)
  ENDIF
  CALL parser("rdb create view dm_cmb_person_children")
  CALL parser("(child_table, child_column, child_pk)")
  CALL parser("as")
  CALL parser("select distinct a.child_table, a.child_column, a.child_pk")
  CALL parser("from dm_cmb_children a")
  CALL parser("where a.parent_table = 'PERSON'")
  CALL parser("and not exists")
  CALL parser("(select 'x' from dm_cmb_exception dce")
  CALL parser("where dce.operation_type = 'COMBINE'")
  CALL parser("and dce.parent_entity = 'PERSON'")
  CALL parser("and dce.child_entity = a.child_table)")
  CALL parser("go")
  CALL err_chk(dummy)
  DROP TABLE dm_cmb_person_children
  CALL err_chk(dummy)
  CALL parser("oragen3 'dm_cmb_person_children' go")
  IF (e_exist=1)
   CALL echo("drop dm_cmb_encounter_children.")
   CALL parser("rdb drop view dm_cmb_encounter_children go")
   CALL err_chk(dummy)
  ENDIF
  CALL parser("rdb create view dm_cmb_encounter_children")
  CALL parser("(child_table, child_column, child_pk)")
  CALL parser("as")
  CALL parser("select distinct a.child_table, a.child_column, a.child_pk")
  CALL parser("from dm_cmb_children a")
  CALL parser("where a.parent_table = 'ENCOUNTER'")
  CALL parser("and not exists")
  CALL parser("(select 'x' from dm_cmb_exception dce")
  CALL parser("where dce.operation_type = 'COMBINE'")
  CALL parser("and dce.parent_entity = 'ENCOUNTER'")
  CALL parser("and dce.child_entity = a.child_table)")
  CALL parser("go")
  CALL err_chk(dummy)
  DROP TABLE dm_cmb_encounter_children
  CALL err_chk(dummy)
  CALL parser("oragen3 'dm_cmb_encounter_children' go")
  IF (b_exist=1)
   CALL echo("drop dm_cmb_both_children.")
   CALL parser("rdb drop view dm_cmb_both_children go")
   CALL err_chk(dummy)
  ENDIF
  CALL parser("rdb create view dm_cmb_both_children")
  CALL parser("(child_table, person_column, encounter_column, child_pk)")
  CALL parser("as")
  CALL parser("select distinct a1.child_table, a1.child_column, a2.child_column, a1.child_pk")
  CALL parser("from dm_cmb_children a1, dm_cmb_children a2")
  CALL parser("where a1.parent_table = 'PERSON'")
  CALL parser("and a2.parent_table = 'ENCOUNTER'")
  CALL parser("and a1.child_table = a2.child_table")
  CALL parser("and not exists")
  CALL parser("(select 'x' from dm_cmb_exception dce")
  CALL parser("where dce.operation_type = 'COMBINE'")
  CALL parser("and dce.parent_entity = 'PERSON'")
  CALL parser("and dce.child_entity = a1.child_table)")
  CALL parser("go")
  CALL err_chk(dummy)
  DROP TABLE dm_cmb_both_children
  CALL err_chk(dummy)
  CALL parser("oragen3 'dm_cmb_both_children' go ")
 ENDIF
 CALL view_chk(dummy)
 SET ccl_view = 0
 SELECT INTO "nl:"
  FROM dtableattr a
  WHERE a.table_name IN ("DM_CMB_PERSON_CHILDREN", "DM_CMB_ENCOUNTER_CHILDREN",
  "DM_CMB_BOTH_CHILDREN")
  DETAIL
   ccl_view = (ccl_view+ 1)
  WITH nocounter
 ;end select
 CALL err_chk(dummy)
 CALL echo(build("db_view=",db_view,",ccl_view=",ccl_view))
 IF (db_view=3
  AND ccl_view=3)
  SET readme_data->message = "Combine views were created Successfully."
  SET readme_data->status = "S"
 ELSEIF (db_view=3
  AND ccl_view != 3)
  SET readme_data->message =
  "Failed to create combine views.  CCL definitions for combine views were not created correctly."
  SET readme_data->status = "F"
 ELSE
  SET readme_data->message = "Failed to create combine views."
  SET readme_data->status = "F"
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 SUBROUTINE err_chk(dummy)
   IF (error(dcc_err_msg,1))
    SET readme_data->status = "F"
    SET readme_data->message = dcc_err_msg
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE view_chk(dummy)
   SET db_view = 0
   SELECT INTO "nl:"
    FROM user_views u
    WHERE u.view_name IN ("DM_CMB_PERSON_CHILDREN", "DM_CMB_ENCOUNTER_CHILDREN",
    "DM_CMB_BOTH_CHILDREN")
    DETAIL
     CASE (u.view_name)
      OF "DM_CMB_PERSON_CHILDREN":
       p_exist = 1
      OF "DM_CMB_ENCOUNTER_CHILDREN":
       e_exist = 1
      OF "DM_CMB_BOTH_CHILDREN":
       b_exist = 1
     ENDCASE
     db_view = (db_view+ 1)
    WITH nocounter
   ;end select
   CALL err_chk(dummy)
 END ;Subroutine
END GO
