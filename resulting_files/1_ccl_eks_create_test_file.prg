CREATE PROGRAM 1_ccl_eks_create_test_file
 SELECT INTO "1_ccl_eks_test_file.tst"
  FROM dummyt d
  DETAIL
   col 0, "set eksevent             = ", "'",
   eksevent, "'", " go",
   row + 1, col 0, "set eksresquest          = ",
   eksrequest, " go", row + 1,
   col 0, "set tname                = ", "'",
   tname, "'", " go",
   row + 1, col 0, "set retval               = ",
   retval, " go", row + 2,
   col 0, "set trigger_personid     = ", trigger_personid,
   " go", row + 1, col 0,
   "set trigger_encntrid     = ", trigger_encntrid, " go",
   row + 1, col 0, "set trigger_accessionid  = ",
   trigger_accessionid, " go", row + 1,
   col 0, "set trigger_orderid      = ", trigger_orderid,
   " go", row + 2
   IF (validate(link_template,0) != 0)
    col 0, "set link_template        = ", link_template,
    " go", row + 1, col 0,
    "set link_accessionid     = ", link_accessionid, " go",
    row + 1, col 0, "set link_orderid         = ",
    link_orderid, " go", row + 1,
    col 0, "set link_encntrid        = ", link_encntrid,
    " go", row + 1, col 0,
    "set link_personid        = ", link_personid, " go",
    row + 1, col 0, "set link_taskassaycd     = ",
    link_taskassaycd, " go", row + 1,
    col 0, "set link_clineventid     = ", link_clineventid,
    " go", row + 1, col 0,
    "set link_tname           = ", "'", link_tname,
    "'", " go", row + 2
   ENDIF
   col 0, "declare log_accessionid = f8 go", row + 1,
   col 0, "declare log_orderid     = f8 go", row + 1,
   col 0, "declare log_encntrid    = f8 go", row + 1,
   col 0, "declare log_personid    = f8 go", row + 1,
   col 0, "declare log_taskassaycd = f8 go", row + 1,
   col 0, "declare log_clineventid = f8 go", row + 1,
   col 0, "declare log_message     = vc go", row + 1,
   col 0, "declare log_misc1       = vc go", row + 1,
   col 0, ";Execute your program here", row + 1,
   col 0, ";Execute program_name go", row + 2,
   col 0, "call echo(retval)          go", row + 1
   IF (validate(link_template,0)=0)
    col 0, "call echo(build('log_personid=',    log_personid))    go", row + 1,
    col 0, "call echo(build('log_encntrid=',    log_encntrid))    go", row + 1,
    col 0, "call echo(build('log_accessionid=', log_accessionid)) go", row + 1,
    col 0, "call echo(build('log_orderid=',     log_orderid))     go", row + 1
   ELSE
    col 0, "call echo(build('log_personid=',    log_personid))    go", row + 1,
    col 0, "call echo(build('log_encntrid=',    log_encntrid))    go", row + 1,
    col 0, "call echo(build('log_accessionid=', log_accessionid)) go", row + 1,
    col 0, "call echo(build('log_orderid=',     log_orderid))     go", row + 1,
    col 0, "call echo(build('log_taskassaycd=', log_taskassaycd)) go", row + 1,
    col 0, "call echo(build('log_clineventid=', log_clineventid)) go", row + 1,
    col 0, "call echo(build('log_message=',     log_message))       go", row + 1,
    col 0, "call echo(build('log_misc1=',       log_misc1))       go", row + 1
   ENDIF
  WITH format, separator = " ", format = variable
 ;end select
END GO
