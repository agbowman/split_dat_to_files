CREATE PROGRAM dm2_revcmb_chk_config:dba
 IF ((validate(rev_cmb_request->reverse_ind,- (1))=- (1))
  AND (validate(rev_cmb_request->application_flag,- (999))=- (999)))
  FREE RECORD rev_cmb_request
  RECORD rev_cmb_request(
    1 reverse_ind = i2
    1 application_flag = i4
  )
 ENDIF
 CALL echo(fillstring(90,"*"))
 CALL echo("Current domain reverse demographic combine status:")
 CALL echo("   Reverse Demographic Combine ON for all applications")
 CALL echo("   Reverse Combine with PRSNL ON")
 CALL echo(fillstring(90,"*"))
#exit_program
END GO
