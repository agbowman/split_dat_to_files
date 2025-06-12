CREATE PROGRAM bhs_ma_email_file:dba
 DECLARE emailfile(filenamein=vc,filenameout=vc,eaddress=vc,emailsubject=vc,removefile=i2) = i2 WITH
 copy
 SUBROUTINE emailfile(filenamein,filenameout,emailaddress,emailsubject,removefileind)
   CALL echo("Emailing the file")
   IF (value(filenamein) != value(filenameout))
    SET ms_dclcom_rename = build2("mv -v ",filenamein," ",filenameout)
    CALL echo(ms_dclcom_rename)
    SET len = size(trim(ms_dclcom_rename))
    SET status = 0
    SET stat = dcl(ms_dclcom_rename,len,status)
    CALL echo(build("file rename status: ",stat))
   ENDIF
   CALL echo(filenameout)
   SET ms_dclcom_email = build2('echo ""',' | mailx -s "',emailsubject,'" -a "',filenameout,
    '" ',emailaddress)
   CALL echo(ms_dclcom_email)
   SET len = size(trim(ms_dclcom_email))
   SET status = 0
   SET stat = dcl(ms_dclcom_email,len,status)
   CALL echo(build("Status: ",stat))
   IF (removefileind=1)
    SET ms_dcl_remove = build2("rm ",trim(filenameout))
    SET len = size(trim(ms_dcl_remove))
    SET status = 0
    SET stat = dcl(ms_dcl_remove,len,status)
    IF (stat=0)
     CALL echo("File could not be removed")
    ELSE
     CALL echo("File was removed")
    ENDIF
   ENDIF
 END ;Subroutine
END GO
