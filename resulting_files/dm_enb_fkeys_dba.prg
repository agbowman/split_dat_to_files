CREATE PROGRAM dm_enb_fkeys:dba
 SELECT
  IF (cnvtupper( $1)="ALL")
   WHERE table_name="*"
    AND u.constraint_type="R"
    AND u.status="DISABLED"
  ELSE
   WHERE table_name=patstring(cnvtupper( $1))
    AND u.constraint_type="R"
    AND u.status="DISABLED"
  ENDIF
  INTO dm_enb_fkeys
  u.table_name, u.constraint_name
  FROM user_constraints u
  HEAD REPORT
   row + 1
  DETAIL
   row + 1, col 0, "RDB ALTER TABLE ",
   CALL print(trim(u.table_name)), " ENABLE CONSTRAINT ",
   CALL print(trim(u.constraint_name)),
   " EXCEPTIONS INTO DM_FOR_KEY_EXCEPT GO", row + 1
  WITH format = stream, noheading, formfeed = none,
   maxcol = 140
 ;end select
 CALL compile("DM_ENB_FKEYS.DAT","DM_ENB_FKEYS.LOG")
 COMMIT
END GO
