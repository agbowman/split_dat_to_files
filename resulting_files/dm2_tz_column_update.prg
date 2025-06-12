CREATE PROGRAM dm2_tz_column_update
 PROMPT
  "Enter Table Name: " = "",
  "Enter Column to Backfill: " = "",
  "Enter From Value: " = 0,
  "Enter To Value: " = 0,
  "Enter Number of Sessions (default: 1): " = 1,
  "Enter Additional Qualifications on Update: " = "",
  "Enter Column for Parallel Sessions: " = "",
  "Enter Output Filename: " = "",
  "Append to File? (1 = Yes, 0 = No): " = 0,
  "File Completion (1 = Yes, 0 = No): " = 0,
  "Update Updt_Dt_Tm (1 = Yes, 0 = No): " = 0
 DECLARE str_table_name = vc WITH protect, noconstant(cnvtupper( $1))
 DECLARE str_backfill_column = vc WITH protect, noconstant(cnvtupper( $2))
 DECLARE n_from_value = i4 WITH protect, noconstant( $3)
 DECLARE n_to_value = i4 WITH protect, noconstant( $4)
 DECLARE n_nbr_sessions = i4 WITH protect, noconstant( $5)
 DECLARE str_qualifications = vc WITH protect, noconstant( $6)
 DECLARE str_parallel_column = vc WITH protect, noconstant(cnvtupper( $7))
 DECLARE str_filename = vc WITH protect, noconstant(cnvtlower( $8))
 DECLARE n_append_ind = i2 WITH protect, noconstant( $9)
 DECLARE n_complete_ind = i2 WITH protect, noconstant( $10)
 DECLARE updt_dt_tm_ind = i2 WITH protect, noconstant( $11)
 DECLARE n_range_size = f8 WITH protect, noconstant(0.0)
 DECLARE n_max_id = f8 WITH protect, noconstant(0.0)
 DECLARE n_max_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE n_min_range_id = f8 WITH protect, noconstant(0.0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE ms_err_msg = vc WITH protect, noconstant("")
 IF (str_table_name="")
  CALL echo("Your must enter a valid Table Name")
  GO TO exit_program
 ENDIF
 IF (str_backfill_column="")
  CALL echo("Your must enter a valid Column to Backfill")
  GO TO exit_program
 ENDIF
 IF (n_nbr_sessions=0)
  SET n_nbr_sessions = 1
 ENDIF
 IF (str_parallel_column=""
  AND n_nbr_sessions > 1)
  CALL echo(
   "Your must enter a valid Column for Parallel Sessions if more than 1 session is requested")
  GO TO exit_program
 ENDIF
 IF (str_filename="")
  CALL echo("Your must enter a valid Output Filename")
  GO TO exit_program
 ENDIF
 IF ( NOT (n_append_ind IN (1, 0)))
  CALL echo("Your must enter a valid Append Option (1= Yes, 0 = No)")
  GO TO exit_program
 ENDIF
 IF ( NOT (n_complete_ind IN (1, 0)))
  CALL echo("Your must enter a valid Complete Option (1= Yes, 0 = No)")
  GO TO exit_program
 ENDIF
 IF (n_nbr_sessions > 1)
  CALL parser(concat("select into 'nl:' max_nbr=max(",str_parallel_column,") from ",str_table_name,
    " detail n_max_id=max_nbr go"))
  IF (n_max_id=0)
   CALL echo(concat("The MAX ",str_parallel_column," from the ",str_table_name," table is 0, exit"))
   GO TO exit_program
  ENDIF
  IF (error(ms_err_msg,0) != 0)
   CALL echo(concat("Error getting MAX ",str_parallel_column," from the ",str_table_name," table:",
     ms_err_msg))
   GO TO exit_program
  ENDIF
  SET n_min_range_id = 1.0
  SET n_range_size = ceil(((n_max_id - n_min_range_id)/ n_nbr_sessions))
 ENDIF
 FOR (idx = 1 TO n_nbr_sessions)
   IF (idx=n_nbr_sessions)
    SET n_max_range_id = n_max_id
   ELSE
    SET n_max_range_id = (n_min_range_id+ n_range_size)
   ENDIF
   SELECT
    IF (n_append_ind=1)
     WITH append, nocounter, format = variable,
      maxcol = 2000
    ELSE
    ENDIF
    INTO value(build(str_filename,idx,"_out",idx,".dat"))
    FROM dummyt d
    DETAIL
     IF (n_append_ind=0)
      row 0,
      CALL print(concat("%o ",str_filename,trim(cnvtstring(idx)),"_out.dat"))
     ENDIF
     row + 1,
     CALL print(concat("RDB ASIS (^ DECLARE CURSOR C1 is select a.rowid from ",str_table_name," a",
      "^)")), row + 1,
     CALL print(concat("asis(^        WHERE a.",str_backfill_column," = ",trim(cnvtstring(
        n_from_value)),"^)"))
     IF (str_qualifications != "")
      row + 1,
      CALL print(concat("asis(^AND ",str_qualifications,"^)"))
     ENDIF
     IF (n_nbr_sessions > 1)
      row + 1,
      CALL print(concat("asis(^          AND a.",str_parallel_column," BETWEEN ",trim(cnvtstring(
         n_min_range_id)),"^)")), row + 1,
      CALL print(concat("asis(^          AND ",trim(cnvtstring(n_max_range_id)),"^)"))
     ENDIF
     row + 1,
     CALL print("asis(^ ; ^)"), row + 1,
     CALL print("asis(^ finished number:=0; ^)"), row + 1,
     CALL print("asis(^ commit_cnt number:=0; ^)"),
     row + 1,
     CALL print("asis(^ err_msg varchar2(150);^)"), row + 1,
     CALL print("asis(^ snapshot_too_old EXCEPTION; ^)"), row + 1,
     CALL print("asis(^ PRAGMA exception_init(snapshot_too_old, -1555);^)"),
     row + 1,
     CALL print("asis(^ BEGIN ^)"), row + 1,
     CALL print("asis(^ WHILE (finished=0) LOOP BEGIN^)"), row + 1,
     CALL print("asis(^   finished:=1;^)"),
     row + 1,
     CALL print("asis(^   FOR C1REC in C1 LOOP ^)"), row + 1,
     CALL print(concat("asis(^     update ",str_table_name,"^)"))
     IF (updt_dt_tm_ind=0)
      row + 1,
      CALL print(concat("asis(^        set ",str_backfill_column," = ",trim(cnvtstring(n_to_value)),
       "^)"))
     ENDIF
     IF (updt_dt_tm_ind=1)
      row + 1,
      CALL print("asis(^        set UPDT_DT_TM = sysdate^)")
     ENDIF
     row + 1,
     CALL print("asis(^      WHERE rowid = c1rec.rowid;^)"), row + 1,
     CALL print("asis(^      commit_cnt := commit_cnt+1;^)"), row + 1,
     CALL print("asis(^      IF(commit_cnt = 10000) THEN^)"),
     row + 1,
     CALL print("asis(^         commit;^)"), row + 1,
     CALL print("asis(^         commit_cnt := 0;^)"), row + 1,
     CALL print("asis(^      END IF;^)"),
     row + 1,
     CALL print("asis(^   END LOOP;^)"), row + 1,
     CALL print("asis(^   EXCEPTION^)"), row + 1,
     CALL print("asis(^     WHEN snapshot_too_old then^)"),
     row + 1,
     CALL print("asis(^       finished:=0;^) "), row + 1,
     CALL print("asis(^     WHEN OTHERS then^)"), row + 1,
     CALL print("asis(^       rollback;^)"),
     row + 1,
     CALL print("asis(^       err_msg:=substr(sqlerrm, 1, 150); ^)"), row + 1,
     CALL print("asis(^       raise_application_error(-20555, err_msg);^) "), row + 1,
     CALL print("asis(^   END; ^)"),
     row + 1,
     CALL print("asis(^ END LOOP;^)"), row + 1,
     CALL print("asis(^ IF (commit_cnt > 0) THEN^)"), row + 1,
     CALL print("asis(^   commit;^) "),
     row + 1,
     CALL print("asis(^ END IF;^) "), row + 1,
     CALL print("asis(^ END;^) GO")
     IF (n_complete_ind=1)
      row + 1,
      CALL print("%o")
     ENDIF
    WITH nocounter, format = variable, maxcol = 2000
   ;end select
   IF (error(ms_err_msg,0) != 0)
    CALL echo(build("Error creating output file ",ms_err_msg))
    GO TO exit_program
   ELSE
    CALL echo("***********************************************************************")
    CALL echo(concat("Output File Created: ",str_filename,trim(cnvtstring(idx)),"_out",trim(
       cnvtstring(idx)),
      ".dat"))
    CALL echo("***********************************************************************")
   ENDIF
   SET n_min_range_id = (n_max_range_id+ 1)
 ENDFOR
#exit_program
END GO
