CREATE PROGRAM dm_dbmaint:dba
 PAINT
 SET menu_choice = " "
 SET execution_flg = " "
#main_menu
 SET width = 80
 SET message = - (1)
 SET help = off
 SET validate = off
 CALL video(n)
 CALL box(3,1,22,80)
 CALL text(4,24,"DATABASE MAINTENANCE - Main Menu")
 CALL text(6,9,"WARNING! This program will make permanent changes to the        ")
 CALL text(7,9,"existing database. Run the DM_VALIDATE_IDS or DM_CODEVALUE_VALID")
 CALL text(8,9,"programs to locate invalid data first. Then use choice 3 to     ")
 CALL text(9,9,"write zeros to or delete the invalid rows entirely.             ")
 CALL text(13,10,"1) Run DM_CODEVALUE_VALID program to find invalid _CD values  ")
 CALL text(14,10,"2) Run DM_VALIDATE_IDS program to find invalid _ID values     ")
 CALL text(15,10,"3) Write zeros or Delete the invalid rows                     ")
 CALL text(16,10,"4) Go to the Merge Utilities program                          ")
 CALL text(17,10,"5) View the Invalid data table                                ")
 CALL text(18,10,"0) Exit Program                                               ")
 CALL clear(23,1)
 CALL text(23,2,"Enter Choice: ")
 CALL accept(23,16,"9;H","0"
  WHERE curaccept IN (1, 2, 3, 4, 5,
  0))
 SET menu_choice = curaccept
 CASE (curaccept)
  OF 1:
   EXECUTE dm_codevalue_valid
   CALL text(24,2,"Program Complete!")
   CALL pause(2)
   CALL video(n)
   GO TO main_menu
  OF 2:
   EXECUTE dm_validate_ids
   CALL video(n)
   CALL text(24,2,"Program Complete!")
   CALL pause(1)
   CALL clear(23,1)
   CALL clear(24,1)
   GO TO main_menu
  OF 3:
   CALL clear(23,1)
   CALL text(23,1,"Please select a mode: A) Audit only, E) Execute")
   CALL accept(23,50,"A;CU","A"
    WHERE curaccept IN ("A", "E"))
   SET execution_flg = curaccept
   CASE (curaccept)
    OF "A":
     SET xmode = 0
     CALL clear(24,1)
     CALL text(24,1,"Audit mode set")
     CALL pause(1)
    OF "E":
     SET xmode = 1
     CALL clear(24,1)
     CALL text(24,1,"Execution mode set")
     CALL pause(1)
    ELSE
     GO TO main_menu
   ENDCASE
   GO TO clean_up
  OF 4:
   CALL clear(23,1)
   CALL text(23,1,"Loading MRG_UTILITIES...")
   CALL pause(2)
   CALL clear(23,1)
   EXECUTE mrg_utilities
   GO TO main_menu
  OF 5:
   CALL video(n)
   CALL clear(23,1)
   CALL text(23,1,"Selecting rows from DM_INVALID_TABLE_VALUE...")
   CALL pause(2)
   SELECT
    itv.table_name, itv.column_name, itv.row_id,
    itv.invalid_value
    FROM dm_invalid_table_value itv
    ORDER BY itv.table_name, itv.column_name
    WITH nocounter
   ;end select
   GO TO main_menu
  OF 0:
   GO TO exitprogram
  ELSE
   GO TO exitprogram
 ENDCASE
#clean_up
 FREE DEFINE bad_data
 RECORD bad_data(
   1 list[*]
     2 table_name = c30
     2 column_name = c30
     2 row_id = c18
     2 invalid_value = f8
     2 defining_attribute_ind = i4
   1 count = i4
 )
 SET stat = alterlist(bad_data->list,10)
 SET bad_data->count = 0
 IF (xmode=0)
  GO TO results
 ELSEIF (xmode=1)
  CALL video(n)
  CALL clear(23,1)
  CALL text(23,1,"Executing modifications...")
  CALL pause(1)
  CALL clear(23,1)
  CALL text(23,1,"Building error list...")
  CALL pause(1)
  SELECT INTO "nl:"
   itv.table_name, itv.column_name, itv.row_id,
   itv.invalid_value, dcd.defining_attribute_ind
   FROM dm_columns_doc dcd,
    dm_invalid_table_value itv
   WHERE dcd.table_name=itv.table_name
    AND dcd.column_name=itv.column_name
   ORDER BY itv.table_name, itv.column_name
   DETAIL
    bad_data->count = (bad_data->count+ 1)
    IF (mod(bad_data->count,10)=1
     AND (bad_data->count != 1))
     stat = alterlist(bad_data->list,(bad_data->count+ 9))
    ENDIF
    bad_data->list[bad_data->count].table_name = itv.table_name, bad_data->list[bad_data->count].
    column_name = itv.column_name, bad_data->list[bad_data->count].row_id = itv.row_id,
    bad_data->list[bad_data->count].invalid_value = itv.invalid_value, bad_data->list[bad_data->count
    ].defining_attribute_ind = dcd.defining_attribute_ind
   WITH nocounter
  ;end select
  CALL clear(23,1)
  CALL text(23,1,"Building CCL commands...")
  CALL pause(1)
  SET i = 0
  SET j = 0
  SET n = 0
  SET parse_buffer[5] = fillstring(132," ")
  CALL video(b)
  CALL clear(23,1)
  CALL text(23,1,"Executing CCL commands...")
  CALL pause(1)
  FOR (i = 1 TO bad_data->count)
    SET n = 0
    IF ((bad_data->list[i].defining_attribute_ind=1))
     CALL clear(24,1)
     CALL text(24,1,concat("Deleting rows from ",trim(bad_data->list[i].table_name)))
     SET n = (n+ 1)
     SET parse_buffer[n] = concat("delete from ",trim(bad_data->list[i].table_name)," a ")
     SET n = (n+ 1)
     SET parse_buffer[n] = concat(" where a.rowid = '",bad_data->list[i].row_id,"'")
     SET n = (n+ 1)
     SET parse_buffer[n] = " go "
    ELSEIF ((bad_data->list[i].defining_attribute_ind=0))
     CALL clear(24,1)
     CALL text(24,1,concat("Updating rows in ",trim(bad_data->list[i].table_name)))
     SET n = (n+ 1)
     SET parse_buffer[n] = concat("update into ",trim(bad_data->list[i].table_name)," a ")
     SET n = (n+ 1)
     SET parse_buffer[n] = concat("set a.",trim(bad_data->list[i].column_name)," = 0")
     SET n = (n+ 1)
     SET parse_buffer[n] = concat(" where a.rowid = '",bad_data->list[i].row_id,"'")
     SET n = (n+ 1)
     SET parse_buffer[n] = " go "
    ENDIF
    FOR (j = 1 TO n)
      CALL parser(trim(parse_buffer[j]))
    ENDFOR
    COMMIT
  ENDFOR
 ENDIF
 CALL video(n)
 GO TO results
#results
 CALL clear(23,1)
 CALL text(23,1,"Creating report...")
 CALL pause(1)
 SELECT
  itv.table_name, itv.column_name, itv.invalid_value,
  dcd.defining_attribute_ind
  FROM dm_columns_doc dcd,
   dm_invalid_table_value itv
  WHERE dcd.table_name=itv.table_name
   AND dcd.column_name=itv.column_name
  ORDER BY itv.table_name
  HEAD REPORT
   line = fillstring(100,"-")
  HEAD PAGE
   col 0, "TABLE_NAME", col 32,
   "COLUMN_NAME", col 71, "BAD VALUE",
   col 85, "IND", col 92,
   "ACTION", row + 1, col 0,
   line, row + 1
  DETAIL
   col 0, itv.table_name, col 32,
   itv.column_name, col 64, itv.invalid_value,
   col 75, dcd.defining_attribute_ind
   IF (dcd.defining_attribute_ind=0)
    col 92, "Update"
   ELSEIF (dcd.defining_attribute_ind=1)
    col 92, "Delete"
   ENDIF
   row + 1
  WITH nocounter, maxcol = 132, formfeed = none
 ;end select
 CALL clear(23,1)
 CALL video(n)
 GO TO main_menu
#exitprogram
END GO
