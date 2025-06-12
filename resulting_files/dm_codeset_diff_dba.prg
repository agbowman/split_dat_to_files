CREATE PROGRAM dm_codeset_diff:dba
 SET valid_ind = 1
 SET rec1_version = 0.0000
 SET rec2_version = 0.0000
 IF (( $1 >  $2))
  SET rec1_version =  $1
  SET rec2_version =  $2
 ELSE
  SET rec2_version =  $1
  SET rec1_version =  $2
 ENDIF
 RECORD dt(
   1 rdate[3]
     2 sch_date = dq8
 )
 SET count = 0
 SELECT INTO "nl:"
  a.schema_date
  FROM dm_schema_version a
  WHERE a.schema_version IN (rec1_version, rec2_version)
  DETAIL
   count = (count+ 1), dt->rdate[count].sch_date = a.schema_date
  WITH nocounter
 ;end select
 IF ((dt->rdate[1].sch_date > dt->rdate[2].sch_date))
  SET rec1_date = dt->rdate[1].sch_date
  SET rec2_date = dt->rdate[2].sch_date
 ELSE
  SET rec1_date = dt->rdate[2].sch_date
  SET rec2_date = dt->rdate[1].sch_date
 ENDIF
 SET x1 = cnvtstring(rec1_version,6,3,r)
 SET x2 = cnvtstring(rec2_version,6,3,r)
 SELECT INTO "nl:"
  a.schema_version
  FROM dm_schema_version a
  WHERE a.schema_version=rec1_version
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT
   *
   FROM dual
   DETAIL
    valid_ind = 0, col 10, "***************************************************************",
    row + 2, col 10, " Error in schema version ",
    col 40, x1, col 48,
    ".......Terminating ", row + 2, col 10,
    "***************************************************************", row + 1
   WITH nocounter
  ;end select
 ENDIF
 IF (valid_ind=1)
  SELECT INTO "nl:"
   a.schema_version
   FROM dm_schema_version a
   WHERE a.schema_version=rec2_version
   WITH nocounter
  ;end select
  IF (curqual=0)
   SELECT
    *
    FROM dual
    DETAIL
     valid_ind = 0, col 10, "****************************************************************",
     row + 2, col 14, " Error in schema version ",
     col 40, x2, col 48,
     " ....... Terminating Program ", row + 2, col 10,
     "****************************************************************", row + 1
    WITH nocounter
   ;end select
  ENDIF
  IF (valid_ind=1)
   SELECT INTO dm_codeset_diff
    *
    FROM dual
    DETAIL
     col 10, "********************************************************************", row + 2,
     col 24, " STARTER DATA REPORT ", row + 2,
     col 14, " Differences in the Starter Data between Rev's ", col 62,
     x1, col 70, "and",
     col 75, x2, row + 2,
     col 10, "********************************************************************", row + 3,
     col 24, " ADDITIONS / CHANGES  ", row + 2
    WITH nocounter
   ;end select
   SELECT INTO dm_codeset_diff
    a.code_set, a.display, a.description,
    a.definition
    FROM dm_code_value_set a
    WHERE a.schema_date=cnvtdatetime(rec1_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value_set b
     WHERE b.schema_date=cnvtdatetime(rec2_date)
      AND b.code_set=a.code_set
      AND b.display=a.display
      AND b.description=a.description
      AND b.definition=a.definition
      AND b.cache_ind=a.cache_ind
      AND b.add_access_ind=a.add_access_ind
      AND b.chg_access_ind=a.chg_access_ind
      AND b.del_access_ind=a.del_access_ind
      AND b.inq_access_ind=a.inq_access_ind
      AND b.def_dup_rule_flag=a.def_dup_rule_flag
      AND b.cdf_meaning_dup_ind=a.cdf_meaning_dup_ind
      AND b.display_key_dup_ind=a.display_key_dup_ind
      AND b.active_ind_dup_ind=a.active_ind_dup_ind
      AND b.display_dup_ind=a.display_dup_ind
      AND b.alias_dup_ind=a.alias_dup_ind)))
    ORDER BY a.code_set
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE SETS", row + 2, col 0,
     line2, row + 2
    HEAD PAGE
     col 5, "Code Set", col 20,
     "Display", col 60, "Description",
     col 100, "Definition", row + 1,
     col 0, line, row + 1
    DETAIL
     col 5, a.code_set, col 20,
     a.display, des = fillstring(30,""), des = substring(1,30,a.description),
     def = fillstring(30,""), def = substring(1,30,a.definition), col 60,
     des, col 100, def,
     row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Sets Added or Changed", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.cdf_meaning, a.display,
    a.definition
    FROM dm_common_data_foundation a
    WHERE a.schema_date=cnvtdatetime(rec1_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_common_data_foundation b
     WHERE b.schema_date=cnvtdatetime(rec2_date)
      AND b.cdf_meaning=a.cdf_meaning
      AND b.code_set=a.code_set
      AND b.display=a.display
      AND b.definition=a.definition)))
    ORDER BY a.code_set, a.cdf_meaning
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "COMMON DATA FOUNDATION", row + 1, col 0,
     line2, row + 2
    HEAD PAGE
     col 5, "Code Set", col 18,
     "Cdf Meaning", col 50, "Display",
     col 90, "Definition", row + 1,
     col 0, line, row + 1
    DETAIL
     def = fillstring(30,""), disp = fillstring(35,""), def = substring(1,30,a.definition),
     disp = substring(1,35,a.display), col 0, a.code_set,
     col 20, a.cdf_meaning, col 45,
     disp, col 90, def,
     row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Cdf Meanings Added or Changed", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.code_value, a.display,
    a.description, a.cdf_meaning
    FROM dm_code_value a
    WHERE a.schema_date=cnvtdatetime(rec1_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value b
     WHERE b.schema_date=cnvtdatetime(rec2_date)
      AND b.code_value=a.code_value
      AND b.code_set=a.code_set
      AND b.cdf_meaning=a.cdf_meaning)))
    ORDER BY a.code_set, a.code_value
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE VALUES", row + 1, col 0,
     line2, row + 2
    HEAD PAGE
     col 0, "Code Set", col 15,
     "Code Value", col 40, "Cdf Meaning",
     col 65, "Display", col 97,
     "Description", row + 1, col 0,
     line, row + 1
    DETAIL
     disp = fillstring(30,""), disp = substring(1,30,a.display), desc = fillstring(30,""),
     desc = substring(1,30,a.description), col 0, a.code_set,
     col 15, a.code_value, col 40,
     a.cdf_meaning, col 65, disp,
     col 97, desc, row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Values Added or Changed", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.alias, a.contributor_source_cd
    FROM dm_code_value_alias a
    WHERE a.schema_date=cnvtdatetime(rec1_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value_alias b
     WHERE b.schema_date=cnvtdatetime(rec2_date)
      AND b.code_set=a.code_set
      AND b.alias=a.alias)))
    ORDER BY a.code_set, a.alias
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE VALUE ALIAS", row + 1, col 0,
     line2, row + 2
    HEAD PAGE
     col 0, "Code Set", col 20,
     "Alias", col 70, "Contributor Source Cd",
     row + 1, col 0, line,
     row + 1
    DETAIL
     als = fillstring(40,""), als = substring(1,40,a.alias), col 0,
     a.code_set, col 20, als,
     col 70, a.contributor_source_cd, row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Value Alias Added or Changed", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.field_name
    FROM dm_code_set_extension a
    WHERE a.schema_date=cnvtdatetime(rec1_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_set_extension b
     WHERE b.schema_date=cnvtdatetime(rec2_date)
      AND b.code_set=a.code_set
      AND b.field_name=a.field_name)))
    ORDER BY a.code_set, a.field_name
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE SET EXTENSION", row + 2, col 0,
     line2, row + 2
    HEAD PAGE
     col 5, "Code Set", col 20,
     "Field Name", row + 1, col 0,
     line, row + 1
    DETAIL
     col 0, a.code_set, col 20,
     a.field_name, row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Set Extensions Added or Changed", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.code_value, a.field_name
    FROM dm_code_value_extension a
    WHERE a.schema_date=cnvtdatetime(rec1_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value_extension b
     WHERE b.schema_date=cnvtdatetime(rec2_date)
      AND b.code_set=a.code_set
      AND b.code_value=a.code_value
      AND b.field_name=a.field_name
      AND b.field_value=a.field_value)))
    ORDER BY a.code_set, a.code_value, a.field_name
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE VALUE EXTENSION", row + 2, col 0,
     line2, row + 2
    HEAD PAGE
     col 0, "Code Set", col 16,
     "Code Value", col 38, "Field Name",
     row + 1, col 0, line,
     row + 1
    DETAIL
     col 0, a.code_set, col 14,
     a.code_value, col 35, a.field_name,
     row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Value Extensions Added or Changed", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    *
    FROM dual
    DETAIL
     col 10, "**********************************************************", row + 2,
     col 34, " DELETIONS / CHANGES  ", row + 2,
     col 10, "**********************************************************", row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   SELECT INTO dm_codeset_diff
    a.code_set, a.display, a.description,
    a.definition
    FROM dm_code_value_set a
    WHERE a.schema_date=cnvtdatetime(rec2_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value_set b
     WHERE b.schema_date=cnvtdatetime(rec1_date)
      AND b.code_set=a.code_set
      AND b.display=a.display
      AND b.description=a.description
      AND b.definition=a.definition
      AND b.cache_ind=a.cache_ind
      AND b.add_access_ind=a.add_access_ind
      AND b.chg_access_ind=a.chg_access_ind
      AND b.del_access_ind=a.del_access_ind
      AND b.inq_access_ind=a.inq_access_ind
      AND b.def_dup_rule_flag=a.def_dup_rule_flag
      AND b.cdf_meaning_dup_ind=a.cdf_meaning_dup_ind
      AND b.display_key_dup_ind=a.display_key_dup_ind
      AND b.active_ind_dup_ind=a.active_ind_dup_ind
      AND b.display_dup_ind=a.display_dup_ind
      AND b.alias_dup_ind=a.alias_dup_ind)))
    ORDER BY a.code_set
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE SETS", row + 2, col 0,
     line2, row + 2
    HEAD PAGE
     col 5, "Code Set", col 20,
     "Display", col 60, "Description",
     col 100, "Definition", row + 1,
     col 0, line, row + 1
    DETAIL
     col 5, a.code_set, col 20,
     a.display, des = fillstring(30,""), des = substring(1,30,a.description),
     def = fillstring(30,""), def = substring(1,30,a.definition), col 60,
     des, col 100, def,
     row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Sets Deleted", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.cdf_meaning, a.display,
    a.definition
    FROM dm_common_data_foundation a
    WHERE a.schema_date=cnvtdatetime(rec2_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_common_data_foundation b
     WHERE b.schema_date=cnvtdatetime(rec1_date)
      AND b.cdf_meaning=a.cdf_meaning
      AND b.code_set=a.code_set
      AND b.display=a.display
      AND b.definition=a.definition)))
    ORDER BY a.code_set, a.cdf_meaning
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "COMMON DATA FOUNDATION", row + 1, col 0,
     line2, row + 2
    HEAD PAGE
     col 5, "Code Set", col 18,
     "Cdf Meaning", col 50, "Display",
     col 90, "Definition", row + 1,
     col 0, line, row + 1
    DETAIL
     def = fillstring(30,""), disp = fillstring(35,""), def = substring(1,30,a.definition),
     disp = substring(1,35,a.display), col 0, a.code_set,
     col 20, a.cdf_meaning, col 45,
     disp, col 90, def,
     row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Cdf Meanings Deleted", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.code_value, a.display,
    a.description, a.cdf_meaning
    FROM dm_code_value a
    WHERE a.schema_date=cnvtdatetime(rec2_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value b
     WHERE b.schema_date=cnvtdatetime(rec1_date)
      AND b.code_value=a.code_value
      AND b.code_set=a.code_set
      AND b.cdf_meaning=a.cdf_meaning)))
    ORDER BY a.code_set, a.code_value
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE VALUES", row + 1, col 0,
     line2, row + 2
    HEAD PAGE
     col 0, "Code Set", col 15,
     "Code Value", col 40, "Cdf Meaning",
     col 65, "Display", col 97,
     "Description", row + 1, col 0,
     line, row + 1
    DETAIL
     disp = fillstring(30,""), disp = substring(1,30,a.display), desc = fillstring(30,""),
     desc = substring(1,30,a.description), col 0, a.code_set,
     col 15, a.code_value, col 40,
     a.cdf_meaning, col 65, disp,
     col 97, desc, row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Values Deleted", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.alias, a.contributor_source_cd
    FROM dm_code_value_alias a
    WHERE a.schema_date=cnvtdatetime(rec2_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value_alias b
     WHERE b.schema_date=cnvtdatetime(rec1_date)
      AND b.code_set=a.code_set
      AND b.alias=a.alias)))
    ORDER BY a.code_set, a.alias
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE VALUE ALIAS", row + 1, col 0,
     line2, row + 2
    HEAD PAGE
     col 0, "Code Set", col 20,
     "Alias", col 70, "Contributor Source Cd",
     row + 1, col 0, line,
     row + 1
    DETAIL
     als = fillstring(40,""), als = substring(1,40,a.alias), col 0,
     a.code_set, col 20, als,
     col 70, a.contributor_source_cd, row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Value Aliases Deleted", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.field_name
    FROM dm_code_set_extension a
    WHERE a.schema_date=cnvtdatetime(rec2_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_set_extension b
     WHERE b.schema_date=cnvtdatetime(rec1_date)
      AND b.code_set=a.code_set
      AND b.field_name=a.field_name)))
    ORDER BY a.code_set, a.field_name
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE SET EXTENSION", row + 2, col 0,
     line2, row + 2
    HEAD PAGE
     col 5, "Code Set", col 20,
     "Field Name", row + 1, col 0,
     line, row + 1
    DETAIL
     col 0, a.code_set, col 20,
     a.field_name, row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Set Extensions Deleted", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
   SELECT INTO dm_codeset_diff
    a.code_set, a.code_value, a.field_name
    FROM dm_code_value_extension a
    WHERE a.schema_date=cnvtdatetime(rec2_date)
     AND  NOT ( EXISTS (
    (SELECT
     "x"
     FROM dm_code_value_extension b
     WHERE b.schema_date=cnvtdatetime(rec1_date)
      AND b.code_set=a.code_set
      AND b.code_value=a.code_value
      AND b.field_name=a.field_name
      AND b.field_value=a.field_value)))
    ORDER BY a.code_set, a.code_value, a.field_name
    HEAD REPORT
     line = fillstring(127,"="), line2 = fillstring(127,"*"), col 0,
     line2, row + 2, col 30,
     "CODE VALUE EXTENSION", row + 2, col 0,
     line2, row + 2
    HEAD PAGE
     col 0, "Code Set", col 16,
     "Code Value", col 38, "Field Name",
     row + 1, col 0, line,
     row + 1
    DETAIL
     col 0, a.code_set, col 14,
     a.code_value, col 35, a.field_name,
     row + 1
    WITH nocounter, maxcol = 132, formfeed = none,
     append
   ;end select
   IF (curqual=0)
    SELECT INTO dm_codeset_diff
     *
     FROM dual
     DETAIL
      col 10, "********************************************************************", row + 2,
      col 14, " No Code Value Extensions Deleted", row + 2,
      col 10, "********************************************************************"
     WITH nocounter, maxcol = 132, formfeed = none,
      append
    ;end select
   ENDIF
  ENDIF
 ENDIF
END GO
