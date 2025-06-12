CREATE PROGRAM dm_chk_for_zero_row:dba
 PROMPT
  "Enter table_name in quotes:  " = ""
 IF (build( $1) != char(42))
  IF (build( $1)="")
   CALL echo(concat("Usage:  ",curprog," '<table_name>' GO"))
   GO TO end_of_program
  ENDIF
 ENDIF
 SET c_mod = "DM_CHK_FOR_ZERO_ROW 001"
 IF (validate(zrow_reply->status,"X")="X")
  FREE RECORD zrow_reply
  RECORD zrow_reply(
    1 status = c1
    1 zero_row_ind = i2
  ) WITH persistscript
 ENDIF
 SELECT INTO "nl:"
  FROM dm_tables_doc d
  WHERE d.table_name=cnvtupper( $1)
  DETAIL
   zrow_reply->zero_row_ind = d.default_row_ind
  WITH nocounter
 ;end select
 SET zrow_reply->status = "S"
END GO
