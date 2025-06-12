CREATE PROGRAM dm_move_refdata:dba
 RECORD str(
   1 str = vc
 )
 RECORD column_list(
   1 col_count = i4
   1 qual[*]
     2 col_name = vc
 )
 DECLARE dmr_curqual_hold = f8
 DECLARE dmr_str = c132
 SET dmr_str = fillstring(132," ")
 SET dmr_curqual_hold = 0.0
 SET column_list->col_count = 0
 SET errcode = 0
 SET errmsg = fillstring(132," ")
 SET adm_link = fillstring(20," ")
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  r.*
  FROM v$database@ref_data_link r
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (curqual=0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying v$database@REF_DATA_LINK table.")
  CALL echo(trim(errmsg))
  CALL echo("REF_DATA_LINK not created accurately.")
  CALL echo("Please recreate the REF_DATA_LINK correctly.")
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SELECT INTO "nl:"
  a.*
  FROM all_synonyms a
  WHERE a.table_name="DM_ENVIRONMENT"
  DETAIL
   adm_link = cnvtupper(trim(substring(1,(findstring(".",a.db_link) - 1),a.db_link)))
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("******************************************************************************")
  CALL echo("Error querying all_synonyms table looking for DM_ENVIRONMENT.")
  CALL echo("Synonym for DM_ENVIRONMENT does not exist.")
  CALL echo("Please create a synonym pointing to the ADMIN database.")
  CALL echo("For e.g.:")
  CALL echo("   ccl> rdb create public synonym DM_ENVIRONMENT for DM_ENVIRONMENT@admin1 go")
  CALL echo('        where "admin1" is the ADMIN database link.')
  CALL echo("******************************************************************************")
  GO TO end_program
 ELSE
  SELECT INTO "nl:"
   a.*
   FROM all_synonyms a
   WHERE a.table_name="DM_TABLES_DOC"
    AND a.db_link=concat(adm_link,".WORLD")
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo("******************************************************************************")
   CALL echo(build("Error querying all_synonyms table looking for DM_TABLES_DOC with link:",adm_link)
    )
   CALL echo("Correct synonym for DM_TABLES_DOC does not exist.")
   CALL echo("Please create a synonym pointing to the correct ADMIN database.")
   CALL echo("For e.g.:")
   CALL echo("   ccl> rdb create public synonym DM_TABLES_DOC for DM_TABLES_DOC@admin1 go")
   CALL echo('        where "admin1" is the admin database link.')
   CALL echo("******************************************************************************")
   GO TO end_program
  ELSE
   FREE SET table1
   SET table1 = build("USER_OBJECTS@",adm_link)
   SELECT INTO "nl:"
    a.object_type
    FROM (value(table1) a)
    WHERE a.object_name="DM_SCHEMA_VERSION"
     AND a.object_type="TABLE"
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo("**********************************************************************")
    CALL echo("Successful connection to ADMIN not made.")
    CALL echo(build("The admin link is not valid:",adm_link))
    CALL echo("Please make sure the admin link is valid and the listener is running.")
    CALL echo("**********************************************************************")
    GO TO end_program
   ENDIF
  ENDIF
 ENDIF
 SET errcode = error(errmsg,1)
 DELETE  FROM pft_acct_reltn
  WHERE pft_acct_reltn_id > 0
   AND parent_entity_name="PERSON"
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error cleaning activity data from PFT_ACCT_RELTN.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 SET errcode = error(errmsg,1)
 DELETE  FROM at_acct_reltn
  WHERE at_acct_reltn_id > 0
   AND acct_id IN (
  (SELECT
   a.acct_id
   FROM account a,
    code_value c
   WHERE c.code_set=20849
    AND c.cdf_meaning="PATIENT"
    AND a.acct_sub_type_cd=c.code_value))
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error cleaning activity data from AT_ACCT_RELTN.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 SET errcode = error(errmsg,1)
 DELETE  FROM account
  WHERE acct_id > 0
   AND acct_id IN (
  (SELECT
   a.acct_id
   FROM account a,
    code_value c
   WHERE code_set=20849
    AND cdf_meaning="PATIENT"
    AND a.acct_sub_type_cd=c.code_value))
  WITH nocounter
 ;end delete
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error cleaning activity data from ACCOUNT.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 SET errcode = error(errmsg,1)
 UPDATE  FROM account
  (pending_acct_bal, unapplied_payment_balance, charge_balance,
  applied_payment_balance, bad_debt_balance, adjustment_balance,
  hi_acct_balance, acct_balance, adj_bal_dr_cr_flag,
  chrg_bal_dr_cr_flag, bad_debt_bal_dr_cr_flag)
  VALUES(0.0, 0.0, 0.0,
  0.0, 0.0, 0.0,
  0.0, 0.0, 0,
  0, 0)
  WHERE acct_id > 0
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error resetting balance columns in ACCOUNT.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  ROLLBACK
  GO TO end_program
 ELSE
  COMMIT
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="PERSON"
  DETAIL
   column_list->col_count = (column_list->col_count+ 1), stat = alterlist(column_list->qual,
    column_list->col_count), column_list->qual[column_list->col_count].col_name = utc.column_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying PERSON for reference data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM dual
  HEAD REPORT
   IF (((cursys="VMS") OR (cursys="AXP")) )
    "spool ccluserdir:dm_move_refdata.log", row + 2
   ELSE
    "spool $CCLUSERDIR/dm_move_refdata.log", row + 2
   ENDIF
   "set echo on", row + 1, "rem Moving person rows that are personnel!",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1
  DETAIL
   "declare", row + 1, "err_num NUMBER;",
   row + 1, "err_msg VARCHAR2(200);", row + 1,
   "       cursor c1 is", row + 1, "               select p.* ",
   row + 1, "                 from person@ref_data_link p, prsnl@ref_data_link a ", row + 1,
   "                 where a.person_id = p.person_id;", row + 1, "begin",
   row + 2, "for c1rec in c1 loop", row + 1,
   "   begin", row + 1, "       insert into person",
   row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "   exception",
   row + 1, "   when DUP_VAL_ON_INDEX then", row + 1,
   "     NULL;", row + 1, "   when others then",
   row + 1, "     err_num := sqlcode;", row + 1,
   "     err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "     dbms_output.put_line (err_msg);",
   row + 1, "     EXIT;", row + 1,
   "   end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1
  WITH nocounter, formfeed = none, format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error populating person info to sql file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET column_list->col_count = 0
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="PERSON_NAME"
  DETAIL
   column_list->col_count = (column_list->col_count+ 1), stat = alterlist(column_list->qual,
    column_list->col_count), column_list->qual[column_list->col_count].col_name = utc.column_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying PERSON_NAME  for reference data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM dual
  HEAD REPORT
   "set echo on", row + 1, "rem Moving person_name rows that are personnel!",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1
  DETAIL
   "declare", row + 1, "err_num NUMBER;",
   row + 1, "err_msg VARCHAR2(200);", row + 1,
   "       cursor c1 is", row + 1, "               select p.* ",
   row + 1, "                 from person_name@ref_data_link p, prsnl@ref_data_link a ", row + 1,
   "                 where a.person_id = p.person_id;", row + 1, "begin",
   row + 2, "for c1rec in c1 loop", row + 1,
   "   begin", row + 1, "       insert into person_name",
   row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "   exception",
   row + 1, "   when DUP_VAL_ON_INDEX then", row + 1,
   "      NULL;", row + 1, "   when others then",
   row + 1, "      err_num := sqlcode;", row + 1,
   "      err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "      dbms_output.put_line (err_msg);",
   row + 1, "      EXIT;", row + 1,
   "   end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1
  WITH nocounter, formfeed = none, append,
   format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error populating PERSON_NAME info to sql file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET column_list->col_count = 0
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="PERSON_ALIAS"
  DETAIL
   column_list->col_count = (column_list->col_count+ 1), stat = alterlist(column_list->qual,
    column_list->col_count), column_list->qual[column_list->col_count].col_name = utc.column_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying PERSON_ALIAS  for reference data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM dual
  HEAD REPORT
   "set echo on", row + 1, "rem Moving person_alias rows that are personnel!",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1
  DETAIL
   "declare", row + 1, "err_num NUMBER;",
   row + 1, "err_msg VARCHAR2(200);", row + 1,
   "       cursor c1 is", row + 1, "               select p.* ",
   row + 1, "                 from person_alias@ref_data_link p, prsnl@ref_data_link a ", row + 1,
   "                 where a.person_id = p.person_id;", row + 1, "begin",
   row + 2, "for c1rec in c1 loop", row + 1,
   "   begin", row + 1, "       insert into person_alias",
   row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "  exception",
   row + 1, "  when DUP_VAL_ON_INDEX then", row + 1,
   "     NULL;", row + 1, "  when others then",
   row + 1, "     err_num := sqlcode;", row + 1,
   "     err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "     dbms_output.put_line (err_msg);",
   row + 1, "     EXIT;", row + 1,
   "  end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1
  WITH nocounter, formfeed = none, append,
   format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error populating PERSON_ALIAS info to sql file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET column_list->col_count = 0
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="ADDRESS"
  DETAIL
   column_list->col_count = (column_list->col_count+ 1), stat = alterlist(column_list->qual,
    column_list->col_count), column_list->qual[column_list->col_count].col_name = utc.column_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying ADDRESS  for reference data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM dual
  HEAD REPORT
   "set echo on", row + 1, "rem Moving address rows that are personnel!",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1
  DETAIL
   "declare", row + 1, "err_num NUMBER;",
   row + 1, "err_msg VARCHAR2(200);", row + 1,
   "       cursor c1 is", row + 1, "               select p.* ",
   row + 1, "                 from address@ref_data_link p, prsnl@ref_data_link a ", row + 1,
   "                 where p.parent_entity_name = 'PERSON' ", row + 1,
   "                 and p.parent_entity_id = a.person_id; ",
   row + 1, "begin", row + 2,
   "for c1rec in c1 loop", row + 1, "   begin",
   row + 1, "       insert into address", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "  exception",
   row + 1, "  when DUP_VAL_ON_INDEX then", row + 1,
   "     NULL;", row + 1, "  when others then",
   row + 1, "     err_num := sqlcode;", row + 1,
   "     err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "     dbms_output.put_line (err_msg);",
   row + 1, "     EXIT;", row + 1,
   "  end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1
  WITH nocounter, formfeed = none, append,
   format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error populating ADDRESS info to sql file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM user_constraints@ref_data_link uc,
   user_cons_columns@ref_data_link ducc,
   dm_tables_doc dtc
  WHERE dtc.reference_ind=1
   AND uc.table_name=dtc.table_name
   AND uc.constraint_type="P"
   AND ducc.table_name=dtc.table_name
   AND ducc.constraint_name=uc.constraint_name
   AND ducc.position=1
   AND dtc.table_name IN (
  (SELECT
   a.parent_entity_name
   FROM address@ref_data_link a))
  DETAIL
   str->str = build(dtc.table_name," "), "set echo on", row + 1,
   "rem Moving address rows that are ", str->str, "s",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1, "declare",
   row + 1, "err_num NUMBER;", row + 1,
   "err_msg VARCHAR2(200);", row + 1, "       cursor c1 is",
   row + 1, "               select * ", row + 1,
   "                 from address@ref_data_link p2 ", row + 1,
   "                   where p2.address_id in ",
   row + 1, "                       (select p.address_id ", row + 1,
   "                          from address@ref_data_link p, ", str->str, "@ref_data_link a ",
   row + 1, "                 where p.parent_entity_name = '", str->str,
   "'", row + 1, str->str = build(ducc.column_name," "),
   "                           and p.parent_entity_id = a.", str->str, ");",
   row + 1, "begin", row + 2,
   "for c1rec in c1 loop", row + 1, "   begin",
   row + 1, "       insert into address", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "  exception",
   row + 1, "  when DUP_VAL_ON_INDEX then", row + 1,
   "     NULL;", row + 1, "  when others then",
   row + 1, "     err_num := sqlcode;", row + 1,
   "     err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "     dbms_output.put_line (err_msg);",
   row + 1, "     EXIT;", row + 1,
   "  end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1
  WITH nocounter, formfeed = none, append,
   format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error populating ADDRESS parent entities info to sql file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET column_list->col_count = 0
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="PHONE"
  DETAIL
   column_list->col_count = (column_list->col_count+ 1), stat = alterlist(column_list->qual,
    column_list->col_count), column_list->qual[column_list->col_count].col_name = utc.column_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying PHONE for reference data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM dual
  HEAD REPORT
   "set echo on", row + 1, "rem Moving phone rows that are personnel!",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1
  DETAIL
   "declare", row + 1, "err_num NUMBER;",
   row + 1, "err_msg VARCHAR2(200);", row + 1,
   "       cursor c1 is", row + 1, "               select * ",
   row + 1, "                 from phone@ref_data_link p ", row + 1,
   "         where p.phone_id in (select p2.phone_id ", row + 1,
   "                       from phone@ref_data_link p2, prsnl@ref_data_link a",
   row + 1, "           where p2.parent_entity_name = 'PERSON'", row + 1,
   "                   and p2.parent_entity_id = a.person_id);", row + 1, "begin",
   row + 2, "for c1rec in c1 loop", row + 1,
   "   begin", row + 1, "       insert into phone",
   row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "  exception",
   row + 1, "  when DUP_VAL_ON_INDEX then", row + 1,
   "     NULL;", row + 1, "  when others then",
   row + 1, "     err_num := sqlcode;", row + 1,
   "     err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "     dbms_output.put_line (err_msg);",
   row + 1, "     EXIT;", row + 1,
   "  end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1
  WITH nocounter, formfeed = none, append,
   format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error populating PHONE data to sql file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM user_constraints@ref_data_link uc,
   user_cons_columns@ref_data_link ducc,
   dm_tables_doc dtc
  WHERE dtc.reference_ind=1
   AND uc.table_name=dtc.table_name
   AND uc.constraint_type="P"
   AND ducc.table_name=dtc.table_name
   AND ducc.constraint_name=uc.constraint_name
   AND ducc.position=1
   AND dtc.table_name IN (
  (SELECT
   a.parent_entity_name
   FROM phone@ref_data_link a))
  DETAIL
   str->str = build(dtc.table_name," "), "set echo on", row + 1,
   "rem Moving phone rows that are ", str->str, "s",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1, "declare",
   row + 1, "err_num NUMBER;", row + 1,
   "err_msg VARCHAR2(200);", row + 1, "       cursor c1 is",
   row + 1, "               select * ", row + 1,
   "                 from phone@ref_data_link p2 ", row + 1,
   "                   where p2.phone_id in ",
   row + 1, "                       (select p.phone_id ", row + 1,
   "                          from phone@ref_data_link p, ", str->str, "@ref_data_link a ",
   row + 1, "                 where p.parent_entity_name = '", str->str,
   "'", row + 1, str->str = build(ducc.column_name," "),
   "                           and p.parent_entity_id = a.", str->str, ");",
   row + 1, "begin", row + 2,
   "for c1rec in c1 loop", row + 1, "   begin",
   row + 1, "       insert into phone", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "  exception",
   row + 1, "  when DUP_VAL_ON_INDEX then", row + 1,
   "     NULL;", row + 1, "  when others then",
   row + 1, "     err_num := sqlcode;", row + 1,
   "     err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "     dbms_output.put_line (err_msg);",
   row + 1, "     EXIT;", row + 1,
   "  end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1
  WITH nocounter, formfeed = none, append,
   format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying for PHONE parent entities pk data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT DISTINCT INTO "nl:"
  lt.parent_entity_name
  FROM long_text@ref_data_link lt
  WHERE  EXISTS (
  (SELECT
   "x"
   FROM dm_tables_doc d
   WHERE d.reference_ind=1
    AND d.table_name=lt.parent_entity_name))
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying LONG_TEXT for reference data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET dm2_curqual_hold = curqual
 IF (curqual=0)
  SET errcode = error(errmsg,1)
  SELECT DISTINCT INTO "nl:"
   lb.parent_entity_name
   FROM long_blob@ref_data_link lb
   WHERE  EXISTS (
   (SELECT
    "x"
    FROM dm_tables_doc d
    WHERE d.reference_ind=1
     AND d.table_name=lb.parent_entity_name))
   WITH nocounter
  ;end select
  SET errcode = error(errmsg,0)
  IF (errcode > 0)
   CALL echo("*****************************************************************")
   CALL echo("Error querying LONG_BLOB for reference data.")
   CALL echo(trim(errmsg))
   CALL echo("*****************************************************************")
   GO TO end_program
  ENDIF
  SET dm2_curqual_hold = curqual
 ENDIF
 IF (dm2_curqual_hold=0)
  SET dmr_str = "query='where 1=2'"
 ELSE
  SET dmr_str = concat("query='where parent_entity_name in  (select d.table_name ",
   " from dm_tables_doc d   where d.reference_ind = 1)'")
 ENDIF
 SET column_list->col_count = 0
 SET errcode = error(errmsg,1)
 SELECT INTO "nl:"
  FROM user_tab_columns utc
  WHERE utc.table_name="ACCESSION"
  DETAIL
   column_list->col_count = (column_list->col_count+ 1), stat = alterlist(column_list->qual,
    column_list->col_count), column_list->qual[column_list->col_count].col_name = utc.column_name
  WITH nocounter
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error querying ACCESSION for reference data.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata.sql"
  FROM dual
  HEAD REPORT
   "set echo on", row + 1, "rem Moving accession rows that are related to reference data!",
   row + 1, "set echo off", row + 1,
   "set serveroutput on", row + 1
  DETAIL
   "declare", row + 1, "err_num NUMBER;",
   row + 1, "err_msg VARCHAR2(200);", row + 1,
   "       cursor c1 is", row + 1, "               select p.* ",
   row + 1, "                 from accession@ref_data_link p, resource_accession_r@ref_data_link a ",
   row + 1,
   "                 where a.accession_id = p.accession_id;", row + 1, "begin",
   row + 2, "for c1rec in c1 loop", row + 1,
   "   begin", row + 1, "       insert into accession",
   row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ")", row + 1
     ENDIF
   ENDFOR
   "       values", row + 1
   FOR (i = 1 TO column_list->col_count)
     IF (i=1)
      "          ("
     ELSE
      "           "
     ENDIF
     "c1rec.", column_list->qual[i].col_name
     IF ((i != column_list->col_count))
      ",", row + 1
     ELSE
      ");", row + 1
     ENDIF
   ENDFOR
   "       commit;", row + 2, "  exception",
   row + 1, "  when DUP_VAL_ON_INDEX then", row + 1,
   "     NULL;", row + 1, "  when others then",
   row + 1, "     err_num := sqlcode;", row + 1,
   "     err_msg := SUBSTR(SQLERRM, 1, 200);", row + 1, "     dbms_output.put_line (err_msg);",
   row + 1, "     EXIT;", row + 1,
   "  end;", row + 1, "end loop;",
   row + 1, "commit;", row + 1,
   "end;", row + 1, "/",
   row + 1, "set echo on", row + 1,
   "spool off", row + 1, "rem *******************************************************************",
   row + 1, "rem Please check DM_MOVE_REFDATA.LOG in CCLUSERDIR for any ORA-* errors", row + 1,
   "rem *******************************************************************", row + 1
  WITH nocounter, formfeed = none, append,
   format = stream
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error populating ACCESSION data to sql file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 SET errcode = error(errmsg,1)
 SELECT INTO "dm_move_refdata_long.par"
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   col 0, "# Export reference data contained in activity tables LONG_TEXT and LONG_BLOB", row + 1,
   col 0, "indexes=n", row + 1,
   col 0, "constraints=n", row + 1,
   col 0, "triggers=n", row + 1,
   col 0, "rows=y", row + 1,
   col 0, dmr_str, row + 1,
   col 0, "tables=(LONG_TEXT,LONG_BLOB)", row + 1
  WITH nocounter, format = stream, formfeed = none,
   maxcol = 200
 ;end select
 SET errcode = error(errmsg,0)
 IF (errcode > 0)
  CALL echo("*****************************************************************")
  CALL echo("Error occurred building par file.")
  CALL echo(trim(errmsg))
  CALL echo("*****************************************************************")
  GO TO end_program
 ENDIF
 CALL echo(
  "**************************************************************************************************"
  )
 CALL echo(
  "**************************************************************************************************"
  )
 CALL echo(
  "*****  File CCLUSERDIR: DM_MOVE_REFDATA.SQL and DM_MOVE_REFDATA_LONG.PAR have been created   *****"
  )
 CALL echo(
  "**************************************************************************************************"
  )
 CALL echo(
  "**************************************************************************************************"
  )
#end_program
END GO
