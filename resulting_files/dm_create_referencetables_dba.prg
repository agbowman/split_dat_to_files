CREATE PROGRAM dm_create_referencetables:dba
 SET tempstr = fillstring(254," ")
 FREE SET list1
 RECORD list1(
   1 table_cnt = i4
   1 tables[*]
     2 tname = c30
 )
 SET list1->table_cnt = 0
 SELECT INTO "nl:"
  dtc.table_name
  FROM dm_tables_doc dtc
  WHERE dtc.reference_ind=1
   AND  NOT (dtc.table_name IN ("PERSON", "PERSON_ALIAS", "PERSON_NAME", "LONG_TEXT"))
   AND dtc.table_name=dtc.full_table_name
  ORDER BY dtc.table_name
  DETAIL
   list1->table_cnt = (list1->table_cnt+ 1)
   IF (mod(list1->table_cnt,10)=1)
    stat = alterlist(list1->tables,(list1->table_cnt+ 9))
   ENDIF
   list1->tables[list1->table_cnt].tname = dtc.table_name
  FOOT REPORT
   stat = alterlist(list1->tables,list1->table_cnt)
  WITH nocounter
 ;end select
 SET file_cnt = 0
 SET filename = fillstring(50," ")
 SET table_cnt = list1->table_cnt
 SET first_table = 1
 IF ((list1->table_cnt > 400))
  SET last_table = 400
 ELSE
  SET last_table = list1->table_cnt
 ENDIF
 WHILE (table_cnt > 0)
   SET file_cnt = (file_cnt+ 1)
   SET filename = build("REFERENCETABLES",file_cnt,".PAR")
   SELECT INTO value(filename)
    *
    FROM dual
    HEAD REPORT
     tempstr = "tables=(", cnt = 0
    DETAIL
     FOR (x = first_table TO last_table)
       cnt = (cnt+ 1)
       IF (cnt > 1)
        tempstr = build(tempstr,", ",list1->tables[x].tname)
       ELSE
        tempstr = build(tempstr,list1->tables[x].tname)
       ENDIF
       IF (mod(cnt,10)=0)
        tempstr, row + 1, tempstr = " "
       ENDIF
     ENDFOR
    FOOT REPORT
     tempstr = build(tempstr,")"), tempstr, row + 1
    WITH nocounter, format = stream, maxrow = 1,
     maxcol = 512, formfeed = none
   ;end select
   IF (table_cnt > 400)
    SET table_cnt = (table_cnt - 400)
    SET first_table = (last_table+ 1)
    IF (table_cnt > 400)
     SET last_table = (first_table+ 399)
    ELSE
     SET last_table = list1->table_cnt
    ENDIF
   ELSE
    SET table_cnt = 0
   ENDIF
 ENDWHILE
 RECORD str(
   1 str = vc
 )
 SET filename = "dm_update_tables_doc.ccl"
 SELECT INTO value(filename)
  FROM dm_tables_doc dtd
  ORDER BY dtd.table_name
  HEAD REPORT
   ";dm_update_tables_doc.ccl", row + 1, "; generated ",
   curdate"MM/DD/YY;;D", row + 3
  DETAIL
   str->str = build("update into dm_tables_doc set reference_ind = ",dtd.reference_ind), str->str,
   row + 1,
   str->str = build(' where table_name = "',dtd.table_name,'" go'), str->str, row + 1,
   "commit go", row + 1
  WITH nocounter, format = stream, formfeed = none
 ;end select
 SET filename = "dm_mixedtables.par"
 SET i = 0
 SELECT INTO value(filename)
  FROM dm_tables_doc dtd
  WHERE table_name IN ("PRSNL", "PERSON", "ADDRESS", "PHONE", "ORGANIZATION",
  "ORGANIZATION_ALIAS", "PRSNL_ORG_RELTN", "ORG_PLAN_RELTN", "HEALTH_PLAN", "HEALTH_PLAN_ALIAS",
  "LONG_TEXT", "LONG_BLOB", "PERSON_NAME", "PRSNL_ALIAS", "PERSON_ALIAS",
  "ACCESSION")
  ORDER BY dtd.table_name
  HEAD REPORT
   "tables=(", row + 1
  DETAIL
   IF (i > 0)
    ",", row + 1
   ENDIF
   i = (i+ 1), str->str = dtd.table_name, str->str
  FOOT REPORT
   row + 1, ")", row + 1
  WITH nocounter, format = stream, formfeed = none
 ;end select
 CALL echo("This program now creates the following files in CCLUSERDIR:")
 CALL echo("  referencetables*.par")
 CALL echo("        These files must be updated on our share and CKN.  ")
 CALL echo("        The Domain Management page should be updated to reflect the update date.")
 CALL echo("  dm_update_tables_doc.ccl")
 CALL echo("  dm_mixedtables.par")
 CALL echo("        These files must be updated on our share and CKN.  ")
 CALL echo("        The Delete page should be updated to reflect the update dates.")
END GO
