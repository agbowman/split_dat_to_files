CREATE PROGRAM ams_secure_ftp_get_file:dba
 PROMPT
  "Enter file name to retrieve from ftp3.cerner.com:" = ""
  WITH file
 DECLARE getfile(commandstr=vc) = i2 WITH protect
 DECLARE quote_str = c1 WITH protect, constant('"')
 DECLARE file_name = vc WITH protect, constant(trim( $FILE))
 DECLARE local_dir = vc WITH protect, constant(trim(logical("CCLUSERDIR")))
 DECLARE remote_host = vc WITH protect, constant("svcamsimport@ftp3.cerner.com")
 DECLARE ssh_key_file = vc WITH protect, constant("ams_key.txt")
 DECLARE script_name = c23 WITH protect, constant("AMS_SECURE_FTP_GET_FILE")
 DECLARE last_mod = vc WITH protect
 DECLARE dclcom = vc WITH protect
 DECLARE statusmsg = vc WITH protect
 DECLARE retstat = i4 WITH protect
 DECLARE dclstatus = i4 WITH protect
 DECLARE ssh_key = vc WITH protect, constant(concat("-----BEGIN RSA PRIVATE KEY-----",char(10),
   "MIIEoQIBAAKCAQEA029hXfeByyOwiLgSLKE44j4eY04QPXnpWvxFRhxH4ER+XemY",char(10),
   "VWHcd8TYF0qAbOeGoBE0akvDEEAJix0ZdIekZTlH+zSC1eWHZPVZSfI32w70DH5b",
   char(10),"tYkmv9gSsjnyxLkz7SzcEuUyiLMCTHKPb8YafZblf0zAiYr0YVKONIHzI7aIBGoR",char(10),
   "Sg+Xl7nnSGfjeCX395t7Tb12osBmlRnLqREeKw79wg0QoaQxaYJNSbSuurS3qXsp",char(10),
   "cKCegE3CZW1wjg3hUzDKbCL4iqdSbIw1X2i7gg5vWUu4FoeCJs5z3KKPFGNQvZOl",char(10),
   "Vh7w+WCAwtH7zFErYHBidxg3fW7Rlk8DHBhBlwIBIwKCAQEAoxtoXm56EbxyPZVP",char(10),
   "2Ukr4brkPfpkTK6A0SkCPWZGE2gJtik7AAmqE0AUab0hPhGw/yM3ECvQ/ehB4FhG",
   char(10),"1jzApdu7L4BHrFH6u5iymCFBCBLZhfsTjAq3fg0VvLBcMVurtva4ZlkJuektqLAl",char(10),
   "ghx61elvNlEm0IEi6/3balWeTr6bVPnwibPx/klTy0iHCIvFBTgT3sSvNwTYojXl",char(10),
   "JJUx0l6F3DP+BIkF9jCCfs3R+94LZZf1IeC0RqcN0KjRe5p25ENFe3YPyGRGM6of",char(10),
   "FkXs4pc9xuPVf/zFWXkrx0WE3+0A+FMDeB/fJgTqTLP3JkKIW9Cyezg0t9+WDH8Y",char(10),
   "b7sagwKBgQDxarqUxHL8iL9klLDqHvW25jtwSuDPbzHu/xVY6W65EnwBXF53sYD1",
   char(10),"aVellbwEW81oEzNsE37uBri4Rw5vZXY//2wIowUbTBUBrTDcTrSM+Vgqk2BHA5dw",char(10),
   "SooWciaEyQtLr9zhI5qd5/7g4hc/37BbVVzqho/5hF1GtG5F12BSwwKBgQDgNQMx",char(10),
   "wCUe/jykTWJwOyW87ipQEX7gg/B7NYWyAf1wXTTmlBXd4Mbx5vVA6at9uZgRZ+sN",char(10),
   "0maz0iTIzYQqfuJciq/sdO0eHlwuok9pp/q5FyGfW82VNCOpvZ3PVTTiykE8r14e",char(10),
   "g9ZEw6ca0qIJxIN0nYmtBPOH206GARYPXoyAnQKBgHVCd+HbwtJuTlVsyvVffqlL",
   char(10),"QXEObTGNx8va+714sh9gv+NnYRWQuvrbZRXppHclRoMCAwibwU8KlDw/xS7K4aoO",char(10),
   "WQuCYZDqcJpqEGsBqCc3SBSt+5A08cjTv2n87iM9FB1yrRzlaFtTbStmgFI5cuqI",char(10),
   "jDdl7ii8olWK1nmxwRJBAoGAebZg0d1V+uHJJf4ffsEF25c7io0nnnOCjAccsRcF",char(10),
   "7Ipei8y7adHLFZqiZREilLU1S0cKknmINbs4ikOuJbKYI5u+lk4aUi29A19s8Dae",char(10),
   "DLTJG/6izVbRiAfZU0uDHAdlPjNQWbVIbnjXDo+ZysnDtFWFQKrqmjU5QW5NzdQ9",
   char(10),"pOcCgYBMx48YPgRbZhaVrj5SJQQdyHblMNu6jpycVVEaTtlUfCaeTypkgVSEq4WX",char(10),
   "qXFlG7OWlvSHpSWAkqPsltOxHePYCaAeLPCuD63AZij/YTvaFVtpDenQwlR2RxNI",char(10),
   "3nWFKiC0dbxiS/IdU1X87hiD2nhFtERz5eD2a7NAB2rb4Ckpfw==",char(10),"-----END RSA PRIVATE KEY-----"))
 SET trace = nocallecho
 EXECUTE ams_define_toolkit_common
 SET trace = callecho
 IF (validate(request->batch_selection,"-1")="-1")
  IF ( NOT (validate(reply,0)))
   RECORD reply(
     1 ops_event = vc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
  ENDIF
 ENDIF
 SET statusmsg = "Error executing script"
 SET reply->status_data.status = "F"
 SET reply->ops_event = statusmsg
 IF (file_name=null)
  SET statusmsg = "Error: You must specify the filename"
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusmsg
  RETURN
 ENDIF
 SELECT INTO value(ssh_key_file)
  FROM dummyt d
  DETAIL
   col 0, ssh_key
  WITH nocounter, maxcol = 2000
 ;end select
 SET dclcom = build2("chmod 400 ",ssh_key_file)
 SET retstat = dcl(dclcom,textlen(dclcom),dclstatus)
 IF (((retstat != 1) OR (dclstatus != 1)) )
  SET statusmsg = trim(substring(1,100,build2("Error setting read/write permissions on ",ssh_key_file
     )))
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusmsg
  RETURN
 ENDIF
 IF (cursys="AIX")
  SET dclcom = build2("printf ",quote_str,"get ",file_name,"\nquit",
   quote_str," | sftp -oPreferredAuthentications=publickey "," -o StrictHostKeyChecking=no ",
   "-oIdentityFile=",ssh_key_file,
   " ",remote_host)
  IF (getfile(dclcom)=1)
   SET reply->status_data.status = "S"
   SET reply->ops_event = statusmsg
  ELSE
   SET reply->status_data.status = "F"
   SET reply->ops_event = statusmsg
  ENDIF
 ELSE
  SET statusmsg = "Script does not support VMS"
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusmsg
 ENDIF
 SET stat = remove(ssh_key_file)
 SET trace = nocallecho
 CALL updtdminfo(script_name,1.0)
 SET trace = callecho
 CALL echo(statusmsg)
 SUBROUTINE getfile(commandstr)
   IF (findfile(file_name))
    SET stat = remove(file_name)
    IF (stat=0)
     SET statusmsg = "Error removing existing file"
     RETURN(0)
    ENDIF
   ENDIF
   SET retstat = dcl(commandstr,textlen(commandstr),dclstatus)
   IF (retstat=1
    AND dclstatus=1)
    IF (findfile(file_name))
     SET statusmsg = trim(substring(1,100,build2("Successfully transferred ",file_name," to ",
        local_dir)))
     RETURN(1)
    ELSE
     SET statusmsg = trim(substring(1,100,build2("Error transferring ",file_name)))
     RETURN(0)
    ENDIF
   ELSE
    SET statusmsg = trim(substring(1,100,build2("Error transferring ",file_name)))
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET last_mod = "001"
END GO
