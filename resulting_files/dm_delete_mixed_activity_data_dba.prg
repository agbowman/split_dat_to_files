CREATE PROGRAM dm_delete_mixed_activity_data:dba
 PAINT
 RECORD tname(
   1 tcnt = i4
   1 qual[*]
     2 tname = vc
     2 nextext = f8
     2 ext_mgmt = vc
 )
 IF (( $1=1))
  SET display_str = "PRSNL that were added on the fly"
 ELSEIF (( $1=2))
  SET display_str = "free text ORGANIZATIONS"
 ELSEIF (( $1=3))
  SET display_str = "ORGANIZATIONS that were added on the fly"
 ELSEIF (( $1=4))
  SET display_str = "ORG_PLAN_RELTN rows that were added on the fly"
 ELSEIF (( $1=5))
  SET display_str = "HEALTH PLANS that were added on the fly"
 ELSEIF (( $1=6))
  SET display_str =
  "LONG_TEXT, LONG_BLOB, ACCESSION, ADDRESS, PHONE and PERSON rows that are activity"
 ELSEIF (( $1=7))
  SET display_str = "ALL ACTIVITY DATA"
 ELSEIF (( $1=8))
  SET display_str = "rows on tables that contain activity and reference data"
 ELSE
  CALL text(1,1,"Command line parameter must be between 1 - 6")
  GO TO end_program
 ENDIF
 IF (( $1=6))
  CALL text(2,1,"***** This program will DELETE ALL LONG_TEXT, LONG_BLOB, ACCESSION, ADDRESS,")
  CALL text(3,1,"      PHONE and PERSON rows that are activity!!!            *****")
  CALL text(4,1,"***** This program will DELETE ALL LONG_TEXT, LONG_BLOB, ACCESSION, ADDRESS,")
  CALL text(5,1,"      PHONE and PERSON rows that are activity!!!            *****")
  CALL text(6,1,"***** This program will DELETE ALL LONG_TEXT, LONG_BLOB, ACCESSION, ADDRESS,")
  CALL text(7,1,"      PHONE and PERSON rows that are activity!!!            *****")
 ELSEIF (( $1=8))
  CALL text(2,1,"***** This program will DELETE ALL PRSNL,PERSON,ADDRESS,PHONE,ORGANIZATION,")
  CALL text(3,1,
   "      ORGANIZATION_ALIAS,PRSNL_ORG_RELTN,ORG_PLAN_RELTN,HEALTH_PLAN,HEALTH_PLAN_ALIAS,")
  CALL text(4,1,
   "      LONG_TEXT,LONG_BLOB,PERSON_NAME,PERSON_ALIAS,PRSNL_ALIAS,ACCESSION rows!!!       *****")
  CALL text(5,1,"***** This program will DELETE ALL PRSNL,PERSON,ADDRESS,PHONE,ORGANIZATION,")
  CALL text(6,1,
   "      ORGANIZATION_ALIAS,PRSNL_ORG_RELTN,ORG_PLAN_RELTN,HEALTH_PLAN,HEALTH_PLAN_ALIAS,")
  CALL text(7,1,
   "      LONG_TEXT,LONG_BLOB,PERSON_NAME,PERSON_ALIAS,PRSNL_ALIAS,ACCESSION rows!!!       *****")
 ELSE
  CALL text(2,1,concat("***** This program will DELETE ALL ",display_str,"!!!*****"))
  CALL text(3,1,concat("***** This program will DELETE ALL ",display_str,"!!!*****"))
  CALL text(4,1,concat("***** This program will DELETE ALL ",display_str,"!!!*****"))
  CALL text(5,1,concat("***** This program will DELETE ALL ",display_str,"!!!*****"))
  CALL text(6,1,concat("***** This program will DELETE ALL ",display_str,"!!!*****"))
  CALL text(7,1,concat("***** This program will DELETE ALL ",display_str,"!!!*****"))
 ENDIF
#display
 CALL text(8,1,"Are you sure you want to DELETE these rows? (y/n): n")
 SET validate = 0
 CALL accept(8,52,"A;cu","N")
 IF (curaccept != "N"
  AND curaccept != "Y")
  GO TO display
 ENDIF
 IF (curaccept="N")
  GO TO end_program
 ENDIF
 SET message = nowindow
 IF (( $1=1))
  CALL perform_delete("PRSNL")
  CALL perform_delete("PRSNL_ALIAS")
 ELSEIF (( $1=2))
  CALL perform_delete("ORGANIZATION")
  CALL perform_delete("ORGANIZATION_ALIAS")
  CALL perform_delete("PRSNL_ORG_RELTN")
 ELSEIF (( $1=3))
  CALL perform_delete("ORGANIZATION")
  CALL perform_delete("ORGANIZATION_ALIAS")
  CALL perform_delete("PRSNL_ORG_RELTN")
 ELSEIF (( $1=4))
  CALL perform_delete("ORG_PLAN_RELTN")
 ELSEIF (( $1=5))
  CALL perform_delete("HEALTH_PLAN")
  CALL perform_delete("HEALTH_PLAN_ALIAS")
 ELSEIF (( $1=6))
  CALL perform_delete("LONG_TEXT")
  CALL perform_delete("LONG_BLOB")
  CALL perform_delete("PERSON")
  CALL perform_delete("PRSNL")
  CALL perform_delete("PERSON_NAME")
  CALL perform_delete("PRSNL_ORG_RELTN")
  CALL perform_delete("PERSON_ALIAS")
  CALL perform_delete("PRSNL_ALIAS")
  CALL perform_delete("ADDRESS")
  CALL perform_delete("orphaned ADDRESS")
  CALL perform_delete("PHONE")
  CALL perform_delete("orphaned PHONE")
  CALL perform_delete("ACCESSION")
 ELSEIF (( $1=7))
  CALL delete_all_activity(1)
  CALL generate_log(7)
 ELSEIF (( $1=8))
  CALL delete_mixed_tables(1)
  CALL generate_log(8)
 ENDIF
 CALL echo(concat(display_str," deleted!"))
 GO TO end_program
 SUBROUTINE delete_mixed_tables(d)
   SET tname->tcnt = 0
   SET stat = alterlist(tname->qual,tname->tcnt)
   SELECT INTO "nl:"
    FROM user_tables ut,
     dm_tables_doc dtd,
     dba_tablespaces dt
    WHERE ut.table_name=dtd.table_name
     AND dtd.table_name IN ("PHONE", "ADDRESS", "PERSON", "PRSNL", "ACCESSION",
    "LONG_TEXT", "LONG_BLOB", "ORGANIZATION", "ORGANIZATION_ALIAS", "PRSNL_ORG_RELTN",
    "ORG_PLAN_RELTN", "HEALTH_PLAN", "HEALTH_PLAN_ALIAS", "PERSON_NAME", "PRSNL_ALIAS",
    "PERSON_ALIAS")
     AND ut.tablespace_name=dt.tablespace_name
    DETAIL
     tname->tcnt = (tname->tcnt+ 1), stat = alterlist(tname->qual,tname->tcnt), tname->qual[tname->
     tcnt].tname = dtd.table_name,
     tname->qual[tname->tcnt].nextext = ut.next_extent, tname->qual[tname->tcnt].ext_mgmt = dt
     .extent_management
    WITH nocounter
   ;end select
   CALL echo("Truncating mixed tables")
   FOR (i = 1 TO tname->tcnt)
     CALL echo(concat("Truncating table ",tname->qual[i].tname))
     CALL parser(concat("rdb truncate table ",tname->qual[i].tname," go"))
     IF ((tname->qual[i].ext_mgmt="DICTIONARY"))
      CALL parser(concat("rdb alter table ",tname->qual[i].tname))
      CALL parser(concat(" storage (next ",cnvtstring(tname->qual[i].nextext),") go"))
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE delete_all_activity(d)
   RECORD cons(
     1 cons_cnt = i4
     1 qual[*]
       2 cons_name = vc
       2 cons_table_name = vc
   )
   SET cons->cons_cnt = 0
   SELECT INTO "nl:"
    u.table_name, u.constraint_name
    FROM user_constraints u
    WHERE u.constraint_type="R"
     AND u.status="ENABLED"
    DETAIL
     cons->cons_cnt = (cons->cons_cnt+ 1), stat = alterlist(cons->qual,cons->cons_cnt), cons->qual[
     cons->cons_cnt].cons_table_name = u.table_name,
     cons->qual[cons->cons_cnt].cons_name = u.constraint_name
    WITH nocounter
   ;end select
   CALL echo("*** disable fk constraints ***")
   FOR (x = 1 TO cons->cons_cnt)
     CALL echo(concat("disabling fk constraint ",cons->qual[x].cons_name))
     CALL parser(concat("rdb alter table ",cons->qual[x].cons_table_name))
     CALL parser(concat(" disable constraint ",cons->qual[x].cons_name," go "))
   ENDFOR
   SET tname->tcnt = 0
   SET stat = alterlist(tname->qual,tname->tcnt)
   SELECT INTO "nl:"
    FROM user_tables ut,
     dm_tables_doc dtd,
     dba_tablespaces dt
    WHERE dtd.reference_ind=0
     AND ut.table_name=dtd.table_name
     AND  NOT (dtd.table_name IN ("PHONE", "ADDRESS", "PERSON", "PRSNL", "ACCESSION",
    "LONG_TEXT", "LONG_BLOB", "ORGANIZATION", "ORGANIZATION_ALIAS", "PRSNL_ORG_RELTN",
    "ORG_PLAN_RELTN", "HEALTH_PLAN", "HEALTH_PLAN_ALIAS", "PERSON_NAME", "PRSNL_ALIAS",
    "PERSON_ALIAS"))
     AND ut.tablespace_name=dt.tablespace_name
    ORDER BY dtd.table_name
    DETAIL
     tname->tcnt = (tname->tcnt+ 1), stat = alterlist(tname->qual,tname->tcnt), tname->qual[tname->
     tcnt].tname = dtd.table_name,
     tname->qual[tname->tcnt].nextext = ut.next_extent, tname->qual[tname->tcnt].ext_mgmt = dt
     .extent_management
    WITH nocounter
   ;end select
   CALL echo("Truncating activity tables")
   FOR (i = 1 TO tname->tcnt)
     CALL echo(concat("Truncating table ",tname->qual[i].tname))
     CALL parser(concat("rdb truncate table ",tname->qual[i].tname," go"))
     IF ((tname->qual[i].ext_mgmt="DICTIONARY"))
      CALL parser(concat("rdb alter table ",tname->qual[i].tname))
      CALL parser(" storage (next ")
      CALL parser(cnvtstring(tname->qual[i].nextext))
      CALL parser(") go")
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE generate_log(filenum)
   SET filestr = build("dm_delete_activity_",filenum,".log")
   SELECT INTO value(filestr)
    d.*
    FROM dual d
    HEAD REPORT
     curdate"mm/dd/yyyy;;d", " ", curtime3"hh:mm;;m",
     row + 1, "The following are the table names and their existing next_extent value that ", row + 1,
     "will be affected by this program.", row + 2,
     "Table Name                                          Next_Extent",
     row + 2, line = fillstring(125,"-")
    DETAIL
     FOR (i = 1 TO tname->tcnt)
       IF ((tname->qual[i].ext_mgmt="DICTIONARY"))
        tname->qual[i].tname, col + 40, tname->qual[i].nextext,
        row + 1
       ENDIF
     ENDFOR
    WITH nocounter, noformfeed, noheading
   ;end select
   SET tab_row = fillstring(125," ")
   SELECT INTO value(filestr)
    d.*
    FROM dual
    HEAD REPORT
     "The following commands were issued to truncate the selected tables.", row + 2
    DETAIL
     FOR (i = 1 TO tname->tcnt)
       tab_row = concat("rdb truncate table ",tname->qual[i].tname," go"), tab_row, row + 1
     ENDFOR
    WITH nocounter, append, noformfeed,
     noheading
   ;end select
   SET tab_row = fillstring(125," ")
   SELECT INTO value(filestr)
    d.*
    FROM dual
    HEAD REPORT
     "The following commands were issued to fix the next_extent of the tables to", row + 1,
     "revert back to the original value.",
     row + 2
    DETAIL
     FOR (i = 1 TO tname->tcnt)
       IF ((tname->qual[i].ext_mgmt="DICTIONARY"))
        tab_row = concat("rdb alter table ",tname->qual[i].tname," storage (next ",cnvtstring(tname->
          qual[i].nextext),") go"), tab_row, row + 1
       ENDIF
     ENDFOR
    WITH nocounter, append, noformfeed,
     noheading
   ;end select
 END ;Subroutine
 SUBROUTINE perform_delete(table_to_delete)
   SET done = 0
   SET total_deleted = 0
   CALL echo(concat("Deleting ",table_to_delete," rows."))
   WHILE (done=0)
     IF (( $1=1))
      IF (table_to_delete="PRSNL")
       DELETE  FROM prsnl a
        WHERE ((a.person_id+ 0) > 0)
         AND  NOT (a.prsnl_type_cd IN (
        (SELECT
         code_value
         FROM code_value
         WHERE code_set=309
          AND cdf_meaning="CONTRSYS")))
         AND a.person_id IN (
        (SELECT
         b.person_id
         FROM person b
         WHERE b.data_status_cd IN (
         (SELECT
          code_value
          FROM code_value
          WHERE code_set=8
           AND cdf_meaning="UNAUTH"))))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="PRSNL_ALIAS")
       DELETE  FROM prsnl_alias pra
        WHERE pra.person_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl a
         WHERE a.person_id=pra.person_id)))
        WITH maxqual(pra,10000)
       ;end delete
      ENDIF
     ELSEIF (( $1=2))
      IF (table_to_delete="ORGANIZATION")
       DELETE  FROM organization a
        WHERE a.organization_id > 0
         AND a.org_class_cd IN (
        (SELECT
         cv.code_value
         FROM code_value cv
         WHERE cv.code_set=396
          AND cv.cdf_meaning="FREETEXT"))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="ORGANIZATION_ALIAS")
       DELETE  FROM organization_alias oa
        WHERE oa.organization_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM organization o
         WHERE o.organization_id=oa.organization_id)))
        WITH maxqual(oa,10000)
       ;end delete
      ELSEIF (table_to_delete="PRSNL_ORG_RELTN")
       DELETE  FROM prsnl_org_reltn por
        WHERE  NOT ( EXISTS (
        (SELECT
         "x"
         FROM organization o
         WHERE o.organization_id=por.organization_id)))
        WITH maxqual(por,10000)
       ;end delete
      ENDIF
     ELSEIF (( $1=3))
      IF (table_to_delete="ORGANIZATION")
       DELETE  FROM organization a
        WHERE a.organization_id > 0
         AND a.data_status_cd IN (
        (SELECT
         cv.code_value
         FROM code_value cv
         WHERE cv.code_set=8
          AND cv.cdf_meaning="UNAUTH"))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="ORGANIZATION_ALIAS")
       DELETE  FROM organization_alias oa
        WHERE oa.organization_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM organization o
         WHERE o.organization_id=oa.organization_id)))
        WITH maxqual(oa,10000)
       ;end delete
      ELSEIF (table_to_delete="PRSNL_ORG_RELTN")
       DELETE  FROM prsnl_org_reltn por
        WHERE  NOT ( EXISTS (
        (SELECT
         "x"
         FROM organization o
         WHERE o.organization_id=por.organization_id)))
        WITH maxqual(por,10000)
       ;end delete
      ENDIF
     ELSEIF (( $1=4))
      DELETE  FROM org_plan_reltn a
       WHERE a.org_plan_reltn_id > 0
        AND a.data_status_cd IN (
       (SELECT
        cv.code_value
        FROM code_value cv
        WHERE cv.code_set=8
         AND cv.cdf_meaning="UNAUTH"))
       WITH maxqual(a,10000)
      ;end delete
     ELSEIF (( $1=5))
      IF (table_to_delete="HEALTH_PLAN")
       DELETE  FROM health_plan a
        WHERE a.health_plan_id > 0
         AND a.data_status_cd IN (
        (SELECT
         cv.code_value
         FROM code_value cv
         WHERE cv.code_set=8
          AND cv.cdf_meaning="UNAUTH"))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="HEALTH_PLAN_ALIAS")
       DELETE  FROM health_plan_alias oa
        WHERE  NOT ( EXISTS (
        (SELECT
         "x"
         FROM health_plan o
         WHERE o.health_plan_id=oa.health_plan_id)))
        WITH maxqual(oa,10000)
       ;end delete
      ENDIF
     ELSEIF (( $1=6))
      IF (table_to_delete="LONG_TEXT")
       DELETE  FROM long_text lt
        WHERE lt.long_text_id > 0
         AND  EXISTS (
        (SELECT
         table_name
         FROM dm_tables_doc dtd
         WHERE dtd.reference_ind=0
          AND lt.parent_entity_name=dtd.table_name))
        WITH maxqual(lt,10000)
       ;end delete
      ELSEIF (table_to_delete="LONG_BLOB")
       DELETE  FROM long_blob lb
        WHERE lb.long_blob_id > 0
         AND  EXISTS (
        (SELECT
         table_name
         FROM dm_tables_doc dtd
         WHERE dtd.reference_ind=0
          AND lb.parent_entity_name=dtd.table_name))
        WITH maxqual(lb,10000)
       ;end delete
      ELSEIF (table_to_delete="PERSON")
       DELETE  FROM person a
        WHERE  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl b
         WHERE a.person_id=b.person_id)))
         AND a.person_id > 0
         AND (( NOT (a.name_last_key IN ("SYSTEMOE", "SYSTEM", "CERNER"))) OR (((a.name_last_key=null
        ) OR (a.name_full_formatted=null)) ))
         AND  NOT (a.person_type_cd IN (
        (SELECT
         code_value
         FROM code_value
         WHERE code_set=302
          AND cdf_meaning="CONTRSYS")))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="PRSNL")
       DELETE  FROM prsnl a
        WHERE a.person_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM person b
         WHERE a.person_id=b.person_id)))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="PRSNL_ALIAS")
       DELETE  FROM prsnl_alias a
        WHERE a.person_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl b
         WHERE a.person_id=b.person_id)))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="PERSON_NAME")
       DELETE  FROM person_name a
        WHERE a.person_name_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl b
         WHERE a.person_id=b.person_id)))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="PRSNL_ORG_RELTN")
       DELETE  FROM prsnl_org_reltn a
        WHERE a.prsnl_org_reltn_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl b
         WHERE a.person_id=b.person_id)))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="PERSON_ALIAS")
       DELETE  FROM person_alias a
        WHERE a.person_alias_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl b
         WHERE a.person_id=b.person_id)))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="ADDRESS")
       DELETE  FROM address a
        WHERE a.address_id > 0
         AND  NOT (a.parent_entity_name IN ("PERSON", "ORGANIZATION", "ORG_PLAN_RELTN", "HEALTH_PLAN"
        ))
         AND  EXISTS (
        (SELECT
         "x"
         FROM dm_tables_doc dtd
         WHERE dtd.reference_ind=0
          AND dtd.table_name=a.parent_entity_name))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="orphaned ADDRESS")
       DELETE  FROM address a
        WHERE address_id > 0
         AND parent_entity_name IN ("PERSON", "ORG_PLAN_RELTN", "HEALTH_PLAN", "ORGANIZATION")
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl b
         WHERE a.parent_entity_id=b.person_id
          AND a.parent_entity_name="PERSON")))
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM org_plan_reltn opr
         WHERE a.parent_entity_id=opr.org_plan_reltn_id
          AND a.parent_entity_name="ORG_PLAN_RELTN")))
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM health_plan h
         WHERE a.parent_entity_id=h.health_plan_id
          AND a.parent_entity_name="HEALTH_PLAN")))
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM organization o
         WHERE a.parent_entity_id=o.organization_id
          AND a.parent_entity_name="ORGANIZATION")))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="PHONE")
       DELETE  FROM phone p
        WHERE p.phone_id > 0
         AND  NOT (p.parent_entity_name IN ("PERSON", "ORGANIZATION", "ORG_PLAN_RELTN", "HEALTH_PLAN",
        "ADDRESS"))
         AND  EXISTS (
        (SELECT
         "x"
         FROM dm_tables_doc dtd
         WHERE dtd.reference_ind=0
          AND dtd.table_name=p.parent_entity_name))
        WITH maxqual(p,10000)
       ;end delete
      ELSEIF (table_to_delete="orphaned PHONE")
       DELETE  FROM phone a
        WHERE phone_id > 0
         AND parent_entity_name IN ("PERSON", "ORG_PLAN_RELTN", "HEALTH_PLAN", "ORGANIZATION",
        "ADDRESS")
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM prsnl b
         WHERE a.parent_entity_id=b.person_id
          AND a.parent_entity_name="PERSON")))
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM org_plan_reltn opr
         WHERE a.parent_entity_id=opr.org_plan_reltn_id
          AND a.parent_entity_name="ORG_PLAN_RELTN")))
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM health_plan h
         WHERE a.parent_entity_id=h.health_plan_id
          AND a.parent_entity_name="HEALTH_PLAN")))
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM organization o
         WHERE a.parent_entity_id=o.organization_id
          AND a.parent_entity_name="ORGANIZATION")))
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM address ad
         WHERE a.parent_entity_id=ad.address_id
          AND a.parent_entity_name="ADDRESS")))
        WITH maxqual(a,10000)
       ;end delete
      ELSEIF (table_to_delete="ACCESSION")
       DELETE  FROM accession a
        WHERE a.accession_id > 0
         AND  NOT ( EXISTS (
        (SELECT
         "x"
         FROM resource_accession_r rar
         WHERE rar.accession_id=a.accession_id)))
        WITH maxqual(a,10000)
       ;end delete
      ENDIF
     ENDIF
     IF (curqual=0)
      SET done = 1
     ENDIF
     SET total_deleted = (total_deleted+ curqual)
     CALL echo(concat("Deleted ",cnvtstring(curqual)," ",table_to_delete," rows."))
     COMMIT
   ENDWHILE
   CALL echo(concat("Deleted ",cnvtstring(total_deleted)," ",table_to_delete," rows."))
 END ;Subroutine
#end_program
END GO
