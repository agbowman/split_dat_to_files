CREATE PROGRAM dm_validate_ids:dba
 PAINT
 SET i = 0
 SET j = 0
 SET k = 0
 SET m = 0
 SET n = 0
 SET marker = 0
 SET condition = fillstring(155," ")
 SET buff[50] = fillstring(132," ")
 SET condition1 =
 "The table in the parent_entity_col has no primary key or contains an invalid table name"
 SET condition2 = "Table has both a root_entity_pair and a parent_entity_col entry filled out"
 SET condition3 = "Table has a root_entity_name entry but no root_entity_attr entry"
 SET solution1 = "Contact the table owner to fix the table else it cannot be merged"
 CALL clear(1,1)
 CALL clear(2,1)
 CALL clear(3,1)
 CALL clear(4,1)
 CALL clear(5,1)
 CALL box(1,1,5,80)
 CALL text(3,30,"ID VALIDATION")
 CALL clear(6,0)
 CALL text(6,0,"Executing DM_TEMP_TABLES...")
 EXECUTE dm_temp_tables
 COMMIT
 CALL clear(6,0)
 CALL text(6,0,"Deleting rows from DM_INVALID_TABLE_VALUE table...")
 DELETE  FROM dm_invalid_table_value
  WHERE 1=1
 ;end delete
 COMMIT
 CALL clear(6,0)
 CALL text(6,0,"Checking for the existence of the DM_TABLE_CONSTRUCTION_ERR table...")
 SELECT INTO "nl:"
  ut.table_name
  FROM user_tables ut
  WHERE ut.table_name="DM_TABLE_CONSTRUCTION_ERR"
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL clear(6,0)
  CALL text(6,0,"Creating the DM_TABLE_CONSTRUCTION_ERR table...")
  SET n = (n+ 1)
  SET buff[n] = " rdb create table DM_TABLE_CONSTRUCTION_ERR "
  SET n = (n+ 1)
  SET buff[n] = " (table_name   varchar(30), column_name  varchar(30), "
  SET n = (n+ 1)
  SET buff[n] = " condition    varchar(200), solution     varchar(200) ) "
  SET n = (n+ 1)
  SET buff[n] = " tablespace D_V500_REF_DATA storage(initial 16K next 16K) "
  FOR (j = 1 TO n)
    CALL parser(buff[j])
  ENDFOR
  SET j = 0
  SET n = 0
  COMMIT
  EXECUTE oragen3 "DM_TABLE_CONSTRUCTION_ERR"
 ELSE
  CALL clear(6,0)
  CALL text(6,0,"Deleting rows from DM_TABLE_CONSTRUCTION_ERR table...")
  DELETE  FROM dm_table_construction_err
   WHERE 1=1
  ;end delete
  COMMIT
 ENDIF
 CALL video(n)
 FREE SET rootdata
 RECORD rootdata(
   1 list[*]
     2 table_name = vc
     2 column_name = vc
     2 root_entity_name = vc
     2 root_entity_attr = vc
   1 num = i4
 )
 SET rootdata->num = 0
 SET stat = alterlist(rootdata->list,10)
 FREE SET parentdata
 RECORD parentdata(
   1 list[*]
     2 table_name = vc
     2 column_name = vc
     2 parent_entity_col = vc
   1 num = i4
 )
 SET parentdata->num = 0
 SET stat = alterlist(parentdata->list,10)
 FREE SET badconstr
 RECORD badconstr(
   1 list[*]
     2 table_name = vc
     2 column_name = vc
     2 condition = vc
     2 solution = vc
   1 num = i4
 )
 SET badconstr->num = 0
 SET stat = alterlist(badconstr->list,10)
 CALL video(b)
 CALL clear(6,0)
 CALL text(6,0,"Retreiving table and column data, this will take a minute or two...")
 SELECT INTO "nl:"
  dc.table_name, dc.column_name, dc.schema_date,
  dcd.parent_entity_col, dcd.root_entity_name, dcd.root_entity_attr
  FROM dm_columns dc,
   dm_tables_doc dtd,
   dm_user_tab_cols utc,
   dm_columns_doc dcd
  PLAN (utc
   WHERE utc.column_name="*_ID"
    AND  NOT (utc.column_name IN ("UPDT_ID", "ACTIVE_STATUS_PRSNL_ID")))
   JOIN (dcd
   WHERE dcd.table_name=utc.table_name
    AND dcd.column_name=utc.column_name)
   JOIN (dtd
   WHERE dtd.table_name=utc.table_name
    AND dtd.reference_ind=1)
   JOIN (dc
   WHERE dc.table_name=utc.table_name
    AND dc.column_name=utc.column_name)
  ORDER BY dc.table_name, dc.column_name
  DETAIL
   IF (dcd.root_entity_name > " "
    AND dcd.root_entity_attr > " "
    AND dcd.parent_entity_col=" ")
    rootdata->num = (rootdata->num+ 1)
    IF (mod(rootdata->num,10)=1)
     stat = alterlist(rootdata->list,(rootdata->num+ 9))
    ENDIF
    rootdata->list[rootdata->num].table_name = dcd.table_name, rootdata->list[rootdata->num].
    column_name = dcd.column_name, rootdata->list[rootdata->num].root_entity_name = dcd
    .root_entity_name,
    rootdata->list[rootdata->num].root_entity_attr = dcd.root_entity_attr
   ELSEIF (dcd.parent_entity_col > " "
    AND dcd.root_entity_name=" "
    AND dcd.root_entity_attr=" ")
    parentdata->num = (parentdata->num+ 1)
    IF (mod(parentdata->num,10)=1)
     stat = alterlist(parentdata->list,(parentdata->num+ 9))
    ENDIF
    parentdata->list[parentdata->num].table_name = dcd.table_name, parentdata->list[parentdata->num].
    column_name = dcd.column_name, parentdata->list[parentdata->num].parent_entity_col = dcd
    .parent_entity_col
   ELSEIF (dcd.root_entity_name > " "
    AND dcd.root_entity_attr=" ")
    badconstr->num = (badconstr->num+ 1)
    IF (mod(badconstr->num,10)=1)
     stat = alterlist(badconstr->list,(badconstr->num+ 9))
    ENDIF
    badconstr->list[badconstr->num].table_name = dcd.table_name, badconstr->list[badconstr->num].
    column_name = dcd.column_name, badconstr->list[badconstr->num].condition = condition3,
    badconstr->list[badconstr->num].solution = solution1
   ELSEIF (dcd.parent_entity_col > " "
    AND dcd.root_entity_name > " ")
    badconstr->num = (badconstr->num+ 1)
    IF (mod(badconstr->num,10)=1)
     stat = alterlist(badconstr->list,(badconstr->num+ 9))
    ENDIF
    badconstr->list[badconstr->num].table_name = dcd.table_name, badconstr->list[badconstr->num].
    column_name = dcd.column_name, badconstr->list[badconstr->num].condition = condition2,
    badconstr->list[badconstr->num].solution = solution1
   ENDIF
  WITH nocounter
 ;end select
 CALL video(n)
 SET trace symbol mark
 FOR (i = 1 TO rootdata->num)
   SET j = 0
   SET m = 0
   SET n = 0
   FREE SET buff
   SET buff[50] = fillstring(132," ")
   FREE SET baddata
   RECORD baddata(
     1 list[*]
       2 table_name = vc
       2 column_name = vc
       2 rowid = c18
       2 invalid_value = f8
     1 num = i4
   )
   SET baddata->num = 0
   SET stat = alterlist(baddata->list,10)
   CALL clear(6,0)
   CALL text(6,0,concat("Retreiving table name from parent_entity_col on ",rootdata->list[i].
     table_name))
   SET n = (n+ 1)
   SET buff[n] = " select into 'nl:' "
   SET n = (n+ 1)
   SET buff[n] = build("t1.rowid,"," ","t1.",rootdata->list[i].column_name)
   SET n = (n+ 1)
   SET buff[n] = concat("from ",rootdata->list[i].table_name," t1")
   SET n = (n+ 1)
   SET buff[n] = " where not exists(select 'X'"
   SET n = (n+ 1)
   SET buff[n] = concat("from ",rootdata->list[i].root_entity_name," t2")
   SET n = (n+ 1)
   SET buff[n] = build("where t2.",rootdata->list[i].root_entity_attr,"=t1.",rootdata->list[i].
    column_name,")")
   SET n = (n+ 1)
   SET buff[n] = " detail "
   SET n = (n+ 1)
   SET buff[n] = " baddata->num = baddata->num + 1 "
   SET n = (n+ 1)
   SET buff[n] = " if(mod(baddata->num,10)= 1) "
   SET n = (n+ 1)
   SET buff[n] = "    stat = alterlist(baddata->list, baddata->num + 9) "
   SET n = (n+ 1)
   SET buff[n] = " endif "
   SET n = (n+ 1)
   SET buff[n] = " baddata->list[baddata->num]->table_name = rootdata->list[i]->table_name "
   SET n = (n+ 1)
   SET buff[n] = " baddata->list[baddata->num]->column_name = rootdata->list[i]->column_name "
   SET n = (n+ 1)
   SET buff[n] = " baddata->list[baddata->num]->rowid = t1.rowid "
   SET n = (n+ 1)
   SET buff[n] = concat("baddata->list[baddata->num]->invalid_value = t1.",rootdata->list[i].
    column_name)
   SET n = (n+ 1)
   SET buff[n] = " with nocounter go "
   FOR (j = 1 TO n)
     CALL parser(buff[j])
   ENDFOR
   SET n = 0
   CALL clear(6,0)
   CALL text(6,0,"Inserting bad rows into DM_INVALID_TABLE_VALUE table...")
   FOR (m = 1 TO baddata->num)
     SET n = 0
     IF ((baddata->list[m].invalid_value != 0.00))
      SET n = (n+ 1)
      SET buff[n] =
      " insert into dm_invalid_table_value (table_name, column_name, row_id, invalid_value) values("
      SET n = (n+ 1)
      SET buff[n] = build("'",baddata->list[m].table_name,"', '",baddata->list[m].column_name,"'")
      SET n = (n+ 1)
      SET buff[n] = build(", '",baddata->list[m].rowid,"', ",baddata->list[m].invalid_value,")")
      SET n = (n+ 1)
      SET buff[n] = " go "
     ENDIF
     FOR (j = 1 TO n)
       CALL parser(buff[j])
     ENDFOR
     COMMIT
   ENDFOR
 ENDFOR
 FREE SET rootdata
 SET trace symbol release
 SET trace symbol mark
 SET i = 0
 FOR (i = 1 TO parentdata->num)
   SET j = 0
   SET k = 0
   SET m = 0
   SET n = 0
   FREE SET buff
   SET buff[50] = fillstring(132," ")
   FREE SET temp
   RECORD temp(
     1 list[*]
       2 table_name = vc
       2 column_name = vc
       2 pe_col_name = vc
       2 pe_table_name = vc
       2 pe_primary_key = vc
     1 num = i4
   )
   SET temp->num = 0
   SET stat = alterlist(temp->list,10)
   CALL clear(6,0)
   CALL text(6,0,concat("Retreiving table names from parent_entity_col on ",parentdata->list[i].
     table_name))
   SET n = (n+ 1)
   SET buff[n] = " select into 'nl:' "
   SET n = (n+ 1)
   SET buff[n] = concat(" t.",parentdata->list[i].parent_entity_col)
   SET n = (n+ 1)
   SET buff[n] = concat(" from ",parentdata->list[i].table_name," t ")
   SET n = (n+ 1)
   SET buff[n] = " detail "
   SET n = (n+ 1)
   SET buff[n] = " temp->num = temp->num + 1 "
   SET n = (n+ 1)
   SET buff[n] = " if(mod(temp->num,10) = 1) "
   SET n = (n+ 1)
   SET buff[n] = "    stat = alterlist(temp->list, temp->num + 9) "
   SET n = (n+ 1)
   SET buff[n] = " endif "
   SET n = (n+ 1)
   SET buff[n] = concat("temp->list[temp->num]->table_name = '",parentdata->list[i].table_name,"'")
   SET n = (n+ 1)
   SET buff[n] = concat("temp->list[temp->num]->column_name = '",parentdata->list[i].column_name,"'")
   SET n = (n+ 1)
   SET buff[n] = concat("temp->list[temp->num]->pe_col_name = '",parentdata->list[i].
    parent_entity_col,"'")
   SET n = (n+ 1)
   SET buff[n] = concat("temp->list[temp->num]->pe_table_name = t.",parentdata->list[i].
    parent_entity_col)
   SET n = (n+ 1)
   SET buff[n] = " with nocounter go "
   FOR (j = 1 TO n)
     CALL parser(buff[j])
   ENDFOR
   FOR (k = 1 TO temp->num)
     SET n = 0
     SET j = 0
     CALL clear(6,0)
     CALL clear(7,0)
     CALL clear(8,0)
     CALL clear(9,0)
     CALL clear(10,0)
     CALL clear(11,0)
     CALL clear(12,0)
     IF ((((temp->list[k].pe_table_name=" ")) OR ((temp->list[k].pe_table_name IN ("0", "1")))) )
      CALL clear(6,0)
      CALL text(6,0,concat("Invalid table name in parent_entity_col on ",parentdata->list[i].
        table_name))
      CALL pause(2)
      SET badconstr->num = (badconstr->num+ 1)
      IF (mod(badconstr->num,10)=1)
       SET stat = alterlist(badconstr->list,(badconstr->num+ 9))
      ENDIF
      SET badconstr->list[badconstr->num].table_name = temp->list[k].table_name
      SET badconstr->list[badconstr->num].column_name = temp->list[k].column_name
      SET badconstr->list[badconstr->num].condition = condition1
      SET badconstr->list[badconstr->num].solution = solution1
     ELSEIF ((temp->list[k].pe_table_name > " ")
      AND  NOT ((temp->list[k].pe_table_name IN ("0", "1"))))
      CALL clear(6,0)
      CALL text(6,0,concat("Getting primary key for ",temp->list[k].pe_table_name))
      SET n = (n+ 1)
      SET buff[n] = " select into 'nl:' ucc.column_name "
      SET n = (n+ 1)
      SET buff[n] = " from user_constraints uc, user_cons_columns ucc "
      SET n = (n+ 1)
      SET buff[n] = concat(" where uc.table_name = '",temp->list[k].pe_table_name,"'")
      SET n = (n+ 1)
      SET buff[n] = " and uc.constraint_type = 'P' "
      SET n = (n+ 1)
      SET buff[n] = " and ucc.table_name = uc.table_name "
      SET n = (n+ 1)
      SET buff[n] = " and ucc.constraint_name = uc.constraint_name "
      SET n = (n+ 1)
      SET buff[n] = " detail "
      SET n = (n+ 1)
      SET buff[n] = " temp->list[k]->pe_primary_key = ucc.column_name "
      SET n = (n+ 1)
      SET buff[n] = " with nocounter go "
      FOR (j = 1 TO n)
        CALL parser(buff[j])
      ENDFOR
     ELSE
      CALL clear(6,0)
      CALL text(6,0,concat("Error encountered while processing ",parentdata->list[i].table_name))
      CALL clear(6,0)
      CALL clear(7,0)
      CALL clear(8,0)
      CALL clear(9,0)
      CALL clear(10,0)
      CALL clear(11,0)
      CALL clear(12,0)
      CALL text(6,0,"*********************** ERROR ***************************")
      CALL text(7,0,concat("Table_name     = ",temp->list[k].table_name))
      CALL text(8,0,concat("Column_name    = ",temp->list[k].column_name))
      CALL text(9,0,concat("Pe_col_name    = ",temp->list[k].pe_col_name))
      CALL text(10,0,concat("Pe_table_name  = ",temp->list[k].pe_table_name))
      CALL text(11,0,concat("Pe_primary_key = ",temp->list[k].pe_primary_key))
      CALL text(12,0,"*********************************************************")
      CALL pause(5)
     ENDIF
   ENDFOR
   SET k = 0
   FOR (k = 1 TO temp->num)
     CALL clear(6,0)
     CALL clear(7,0)
     IF ((temp->list[k].pe_primary_key > " "))
      SET j = 0
      SET m = 0
      SET n = 0
      FREE SET buff
      SET buff[50] = fillstring(132," ")
      FREE SET baddata
      RECORD baddata(
        1 list[*]
          2 table_name = vc
          2 column_name = vc
          2 rowid = c18
          2 invalid_value = f8
        1 num = i4
      )
      SET baddata->num = 0
      SET stat = alterlist(baddata->list,10)
      CALL clear(6,0)
      CALL text(6,0,concat("Testing the ID value on ",temp->list[k].table_name))
      SET n = (n+ 1)
      SET buff[n] = " select into 'nl:' "
      SET n = (n+ 1)
      SET buff[n] = concat(" t1.rowid, t1.",temp->list[k].column_name)
      SET n = (n+ 1)
      SET buff[n] = concat(" from ",temp->list[k].table_name," t1")
      SET n = (n+ 1)
      SET buff[n] = " where not exists(select 'X'"
      SET n = (n+ 1)
      SET buff[n] = concat(" from ",temp->list[k].pe_table_name," t2")
      SET n = (n+ 1)
      SET buff[n] = build("where t2.",temp->list[k].pe_primary_key," = t1.",temp->list[k].column_name,
       ")")
      SET n = (n+ 1)
      SET buff[n] = " detail "
      SET n = (n+ 1)
      SET buff[n] = " baddata->num = baddata->num + 1 "
      SET n = (n+ 1)
      SET buff[n] = " if(mod(baddata->num,10)= 1) "
      SET n = (n+ 1)
      SET buff[n] = "    stat = alterlist(baddata->list, baddata->num + 9) "
      SET n = (n+ 1)
      SET buff[n] = " endif "
      SET n = (n+ 1)
      SET buff[n] = " baddata->list[baddata->num]->table_name = temp->list[k]->table_name "
      SET n = (n+ 1)
      SET buff[n] = " baddata->list[baddata->num]->column_name = temp->list[k]->column_name "
      SET n = (n+ 1)
      SET buff[n] = " baddata->list[baddata->num]->rowid = t1.rowid "
      SET n = (n+ 1)
      SET buff[n] = concat("baddata->list[baddata->num]->invalid_value =  t1.",temp->list[k].
       column_name)
      SET n = (n+ 1)
      SET buff[n] = " with nocounter go "
      FOR (j = 1 TO n)
        CALL parser(buff[j])
      ENDFOR
      SET n = 0
      CALL clear(6,0)
      CALL text(6,0,concat("Inserting bad rows into the DM_INVALID_TABLE_VALUE table..."))
      FOR (m = 1 TO baddata->num)
        SET n = 0
        IF ((baddata->list[m].invalid_value != 0.00))
         SET n = (n+ 1)
         SET buff[n] =
         "insert into dm_invalid_table_value (table_name, column_name, row_id, invalid_value) values("
         SET n = (n+ 1)
         SET buff[n] = build("'",baddata->list[m].table_name,"', '",baddata->list[m].column_name,"'")
         SET n = (n+ 1)
         SET buff[n] = build(", '",baddata->list[m].rowid,"', ",baddata->list[m].invalid_value,")")
         SET n = (n+ 1)
         SET buff[n] = " go "
        ENDIF
        FOR (j = 1 TO n)
          CALL parser(buff[j])
        ENDFOR
        COMMIT
      ENDFOR
     ELSE
      CALL clear(6,0)
      CALL text(6,0,concat("Primary_key NOT found for ",temp->list[k].pe_table_name))
      CALL clear(7,0)
      CALL text(7,0,"Inserting rows into the DM_TABLE_CONSTRUCTION_ERR table.")
      SET badconstr->num = (badconstr->num+ 1)
      IF (mod(badconstr->num,10)=1)
       SET stat = alterlist(badconstr->list,(badconstr->num+ 9))
      ENDIF
      SET badconstr->list[badconstr->num].table_name = temp->list[k].table_name
      SET badconstr->list[badconstr->num].column_name = temp->list[k].column_name
      SET badconstr->list[badconstr->num].condition = condition1
      SET badconstr->list[badconstr->num].solution = solution1
     ENDIF
   ENDFOR
 ENDFOR
 SET i = 0
 CALL clear(6,0)
 CALL text(6,0,"Inserting rows in the DM_TABLE_CONSTRUCTION_ERR table...")
 FOR (i = 1 TO badconstr->num)
   SET j = 0
   SET n = 0
   SET n = (n+ 1)
   SET buff[n] = " insert into dm_table_construction_err  "
   SET n = (n+ 1)
   SET buff[n] = " (table_name, column_name, condition, solution) "
   SET n = (n+ 1)
   SET buff[n] = build(" values('",badconstr->list[i].table_name,"', '",badconstr->list[i].
    column_name,"', '")
   SET n = (n+ 1)
   SET buff[n] = build(badconstr->list[i].condition,"', '",badconstr->list[i].solution,"') go")
   SET n = (n+ 1)
   SET buff[n] = " commit go"
   FOR (j = 1 TO n)
     CALL parser(buff[j])
   ENDFOR
 ENDFOR
 FREE SET parentdata
 FREE SET badconstr
 CALL clear(6,0)
 CALL text(6,0,"These tables have invalid values.")
 SELECT
  *
  FROM dm_invalid_table_value
  WITH nocounter
 ;end select
 CALL clear(6,0)
 CALL text(6,0,"These tables are constructed improperly.")
 SELECT
  *
  FROM dm_table_construction_err
  WITH nocounter
 ;end select
END GO
