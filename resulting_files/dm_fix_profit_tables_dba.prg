CREATE PROGRAM dm_fix_profit_tables:dba
 DECLARE dm_payment_detail_exists = c1 WITH public, noconstant("N")
 DECLARE dm_trans_log_exists = c1 WITH public, noconstant("N")
 DECLARE dm_detail_id_pd = c1 WITH public, noconstant("N")
 DECLARE dm_detail_id_tl = c1 WITH public, noconstant("N")
 DECLARE dm_fk_ai_dt = c1 WITH public, noconstant("N")
 DECLARE dm_pk_ai_dt = c1 WITH public, noconstant("N")
 DECLARE dm_fk_cons_name = c30 WITH public, noconstant(" ")
 DECLARE dm_pk_cons_name = c30 WITH public, noconstant(" ")
 DECLARE dm_drop_index = c30 WITH public, noconstant(" ")
 DECLARE dm_trans_log_nullable = c1 WITH public, noconstant("N")
 DECLARE dm_seq_exists = c1 WITH public, noconstant("N")
 DECLARE dm_max_id = i4 WITH public, noconstant(0)
 DECLARE dm_start_value = i4 WITH public, noconstant(0)
 DECLARE dm_end_value = i4 WITH public, noconstant(0)
 SELECT INTO "NL:"
  us.sequence_name
  FROM user_sequences us
  WHERE us.sequence_name="PFT_INTERFACE_SEQ"
  WITH nocounter
 ;end select
 IF ( NOT (curqual))
  CALL echo("*********************")
  CALL echo("The sequence PFT_INTERFACE_SEQ does not exist.")
  CALL echo("This sequence is  needed for this program to work.")
  CALL echo("Program aborted!!!")
  CALL echo("**********************")
  GO TO exit_program
 ENDIF
 SELECT INTO "NL:"
  utc.table_name, utc.column_name, utc.nullable
  FROM user_tab_columns utc
  WHERE utc.table_name IN ("PAYMENT_DETAIL", "TRANS_LOG")
  DETAIL
   IF (utc.table_name="PAYMENT_DETAIL")
    dm_payment_detail_exists = "Y"
    IF (utc.column_name="PAYMENT_DETAIL_ID")
     dm_detail_id_pd = "Y"
    ENDIF
   ENDIF
   IF (utc.table_name="TRANS_LOG")
    dm_trans_log_exists = "Y"
    IF (utc.column_name="PAYMENT_DETAIL_ID")
     dm_detail_id_tl = "Y", dm_trans_log_nullable = utc.nullable
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("payment_detail table exist?:",dm_payment_detail_exists))
 CALL echo(build("column exist on pd table?:",dm_detail_id_pd))
 CALL echo(build("trans_log table exist?:",dm_trans_log_exists))
 CALL echo(build("column exist on tl table?:",dm_detail_id_tl))
 IF (dm_payment_detail_exists="N")
  CALL echo("***************************")
  CALL echo("Payment_detail table does not exist! Program Aborted")
  CALL echo("***************************")
  GO TO exit_program
 ENDIF
 IF (dm_trans_log_exists="N")
  CALL echo("***************************")
  CALL echo("Trans_log table does not exist! Program Aborted!")
  CALL echo("***************************")
  GO TO exit_program
 ENDIF
 IF (dm_detail_id_pd="Y")
  GO TO trans_log_check
 ENDIF
 CALL parser("rdb alter table payment_detail add payment_detail_id number  go")
 CALL parser("rdb alter table payment_detail modify payment_detail_id default 0 go")
 EXECUTE oragen3 "payment_detail"
 UPDATE  FROM payment_detail pd
  SET pd.payment_detail_id = 0
  WHERE 1=1
  WITH nocounter
 ;end update
 COMMIT
 CALL parser("rdb alter table payment_detail modify payment_detail_id not null go")
 EXECUTE oragen3 "payment_detail"
#trans_log_check
 IF (dm_detail_id_pd="Y")
  GO TO populate_fields
 ENDIF
 CALL parser("rdb alter table trans_log add payment_detail_id number go")
 CALL parser("rdb alter table trans_log modify payment_detail_id default 0 go")
 EXECUTE oragen3 "trans_log"
 UPDATE  FROM trans_log tl
  SET tl.payment_detail_id = 0
  WHERE 1=1
  WITH nocounter
 ;end update
 COMMIT
 EXECUTE oragen3 "trans_log"
#populate_fields
 SELECT INTO "NL:"
  uc.table_name, ucc.column_name, ucc.constraint_name,
  uc.constraint_type
  FROM user_constraints uc,
   user_cons_columns ucc
  PLAN (uc
   WHERE uc.table_name="PAYMENT_DETAIL"
    AND uc.constraint_type IN ("P", "R"))
   JOIN (ucc
   WHERE ucc.table_name=uc.table_name
    AND ucc.constraint_name=uc.constraint_name
    AND ucc.column_name="ACTIVITY_ID")
  DETAIL
   IF (uc.constraint_type="R")
    dm_fk_ai_dt = "Y", dm_fk_cons_name = ucc.constraint_name
   ENDIF
   IF (uc.constraint_type="P")
    dm_pk_ai_dt = "Y", dm_pk_cons_name = ucc.constraint_name
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("determine max activity_id on payment_detail.")
 SELECT INTO "NL:"
  pd.activity_id
  FROM payment_detail pd
  HEAD REPORT
   row + 0
  DETAIL
   row + 0
  FOOT REPORT
   dm_max_id = max(pd.activity_id)
  WITH nocounter
 ;end select
 CALL echo("***********************")
 CALL echo(build("MAX activity_id on payment detail is:",dm_max_id))
 CALL echo("***********************")
 SET dm_start_value = 1
 SET dm_end_value = 5000
 CALL echo("***********************")
 CALL echo("Updating payment_detail table")
 CALL echo("***********************")
 WHILE (dm_end_value <= dm_max_id)
   CALL echo("**********************")
   CALL echo(build("Updating ids between:",dm_start_value))
   CALL echo(build("and:",dm_end_value))
   CALL echo(build("will end at id:",dm_max_id))
   CALL echo("**********************")
   UPDATE  FROM payment_detail pd
    SET pd.payment_detail_id = seq(pft_interface_seq,nextval)
    WHERE pd.activity_id BETWEEN dm_start_value AND dm_end_value
     AND pd.payment_detail_id=0
    WITH counter
   ;end update
   SET dm_start_value = (dm_end_value+ 1)
   SET dm_end_value = (dm_end_value+ 5000)
   COMMIT
 ENDWHILE
 IF (dm_trans_log_nullable="N"
  AND dm_detail_id_tl="Y")
  CALL parser("rdb alter table trans_log modify payment_detail_id null go")
 ENDIF
 CALL echo("determine max activity_id on trans_log table.")
 SELECT INTO "NL:"
  tl.activity_id
  FROM trans_log tl
  HEAD REPORT
   row + 0
  DETAIL
   row + 0
  FOOT REPORT
   dm_max_id = max(tl.activity_id)
  WITH nocounter
 ;end select
 CALL echo("***********************")
 CALL echo(build("MAX activity_id on trans_log is:",dm_max_id))
 CALL echo("***********************")
 SET dm_start_value = 1
 SET dm_end_value = 5000
 CALL echo("***********************")
 CALL echo("Updating tran_log table")
 CALL echo("***********************")
 WHILE (dm_end_value <= dm_max_id)
   CALL echo("**********************")
   CALL echo(build("Updating ids between:",dm_start_value))
   CALL echo(build("and:",dm_end_value))
   CALL echo(build("will end at id:",dm_max_id))
   CALL echo("**********************")
   UPDATE  FROM trans_log tl
    SET tl.payment_detail_id =
     (SELECT
      pd.payment_detail_id
      FROM payment_detail pd
      WHERE pd.activity_id=tl.activity_id
       AND pd.activity_id != 0)
    WHERE tl.activity_id BETWEEN dm_start_value AND dm_end_value
    WITH nocounter
   ;end update
   COMMIT
   SET dm_start_value = (dm_end_value+ 1)
   SET dm_end_value = (dm_end_value+ 5000)
 ENDWHILE
 UPDATE  FROM trans_log tl
  SET tl.payment_detail_id = 0
  WHERE tl.payment_detail_id=null
  WITH nocounter
 ;end update
 COMMIT
 CALL echo(build("Foreign key constraint?:",dm_fk_ai_dt))
 CALL echo(build("Primary key constraint?:",dm_pk_ai_dt))
 CALL echo(build("Primary key name:",dm_pk_cons_name))
 IF (dm_fk_ai_dt="Y")
  SET dm_fk_drop_command = concat("rdb alter table payment_detail drop constraint ",dm_fk_cons_name,
   " go")
  CALL parser(dm_fk_drop_command)
  CALL echo("Dropped foreign key constraint off payment_detail")
 ENDIF
 IF (dm_pk_ai_dt="Y")
  SET dm_pk_drop_command = concat("rdb alter table payment_detail drop constraint ",dm_pk_cons_name,
   " go")
  CALL parser(dm_pk_drop_command)
  CALL echo("Dropped primary key constraint off payment_detail")
 ENDIF
 CALL parser("rdb alter table trans_log modify payment_detail_id not null go")
 EXECUTE oragen3 "trans_log"
 CALL echo("***************************")
 CALL echo("Modifications to Payment_detail and Trans_log tables complete")
 CALL echo("***************************")
#exit_program
END GO
