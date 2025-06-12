CREATE PROGRAM bed_run_prsnl
 PROMPT
  "Bedrock Personnel Import Enter Option: A=AUDIT or I=IMPORT (Return=A): " = "A"
 SET option = cnvtupper(trim( $1))
 SET bed_audit_prsnl_mode = 0
 IF (option="A")
  SET bed_audit_prsnl_mode = 1
 ENDIF
 SET filename = "CER_INSTALL:prsnl.csv"
 SET scriptname = "bed_imp_prsnl"
 EXECUTE bed_dm_dbimport filename, scriptname, 15000
END GO
