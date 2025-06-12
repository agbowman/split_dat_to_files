CREATE PROGRAM ams_ftp_get_file:dba
 PROMPT
  "Enter file name to retrieve from ftp.cerner.com\incoming:" = ""
  WITH file
 DECLARE getfile(commandstr=vc) = i2 WITH protect
 DECLARE emailme(null) = null WITH protect
 DECLARE getclient(null) = vc WITH protect
 DECLARE quote_str = c1 WITH protect, constant('"')
 DECLARE file_name = vc WITH protect, constant(trim( $FILE))
 DECLARE local_dir = vc WITH protect, constant(trim(logical("CCLUSERDIR")))
 DECLARE remote_host = vc WITH protect, constant("ftp.cerner.com")
 DECLARE remote_dir = vc WITH protect, constant("incoming")
 DECLARE user_name = vc WITH protect, constant("anonymous")
 DECLARE password = vc WITH protect, constant("password")
 DECLARE last_mod = vc WITH protect
 DECLARE dclcom = vc WITH protect
 DECLARE statusmsg = vc WITH protect
 DECLARE finished = i2 WITH protect
 DECLARE trycnt = i4 WITH protect
 DECLARE subj = vc WITH protect
 DECLARE fromaddr = vc WITH protect, noconstant("testingftp@cerner.com")
 DECLARE mail_to = vc WITH protect, noconstant("adam.tibbs@cerner.com")
 DECLARE bodystr = vc WITH protect
 DECLARE client = vc WITH protect
 SET client = getclient(null)
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
 IF (cursys="AIX")
  WHILE (finished=0
   AND trycnt < 3)
    SET trycnt = (trycnt+ 1)
    SET dclcom = build2("printf ",quote_str,"open ",remote_host,"\nuser ",
     user_name," ",password,"\nlcd ",local_dir,
     "\ncd ",remote_dir,"\nbin","\nget ",file_name,
     "\nquit",quote_str," | ftp -i -n")
    IF (trycnt=3)
     SET subj = build2("FTP warning for ",client,":",trim(curdomain)," tryCnt: ",
      trim(cnvtstring(trycnt)),"a")
     SET bodystr = dclcom
     CALL emailme(null)
    ENDIF
    IF (getfile(dclcom)=1)
     IF (trycnt=3)
      SET subj = build2("FTP warning for ",client,":",trim(curdomain)," tryCnt: ",
       trim(cnvtstring(trycnt)),"a SUCCESS")
      SET bodystr = dclcom
      CALL emailme(null)
     ENDIF
     SET finished = 1
     SET reply->status_data.status = "S"
     SET reply->ops_event = statusmsg
    ELSE
     SET dclcom = build2("printf ",quote_str,"open ",remote_host,"\nuser ",
      user_name," ",password,"\nlcd ",local_dir,
      "\ncd ",remote_dir,"\nbin","\npassive off","\nget ",
      file_name,"\nquit",quote_str," | ftp -i -n")
     IF (trycnt=3)
      SET subj = build2("FTP warning for ",client,":",trim(curdomain)," tryCnt: ",
       trim(cnvtstring(trycnt)),"b")
      SET bodystr = dclcom
      CALL emailme(null)
     ENDIF
     IF (getfile(dclcom)=1)
      IF (trycnt=3)
       SET subj = build2("FTP warning for ",client,":",trim(curdomain)," tryCnt: ",
        trim(cnvtstring(trycnt)),"b SUCCESS")
       SET bodystr = dclcom
       CALL emailme(null)
      ENDIF
      SET finished = 1
      SET reply->status_data.status = "S"
      SET reply->ops_event = statusmsg
     ELSE
      SET reply->status_data.status = "F"
      SET reply->ops_event = statusmsg
     ENDIF
    ENDIF
  ENDWHILE
 ELSE
  SET statusmsg = "Script does not support VMS"
  SET reply->status_data.status = "F"
  SET reply->ops_event = statusmsg
 ENDIF
 CALL echo(statusmsg)
 IF (trycnt=3)
  SET subj = build2("FTP warning for ",client,":",trim(curdomain)," tryCnt: ",
   trim(cnvtstring(trycnt))," status = ",statusmsg)
  SET bodystr = dclcom
  CALL emailme(null)
 ENDIF
 SUBROUTINE getfile(commandstr)
   DECLARE retstat = i4 WITH protect
   DECLARE dclstatus = i4 WITH protect
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
 SUBROUTINE emailme(null)
   DECLARE dclcom = vc WITH protect
   DECLARE dclstatus = i2 WITH protect, noconstant(1)
   SELECT INTO "ccluserdir:tempfile.txt"
    FROM dummyt d
    DETAIL
     x = substring(1,100,bodystr), col 0, x
    WITH nocounter
   ;end select
   IF (cursys2="AIX")
    SET dclcom = concat('(cat tempfile.txt)|mailx -s "',subj,'" ',"-r ",fromaddr,
     " ",mail_to)
   ELSEIF (cursys2="LNX")
    SET dclcom = concat('(cat tempfile.txt)|mailx -s "',subj,'" '," ",mail_to)
   ELSEIF (cursys2="HPX")
    SET dclcom = concat('(cat tempfile.txt)|mailx -m -s "',subj,'" ',"-r ",fromaddr,
     " ",mail_to)
   ENDIF
   SET retval = dcl(dclcom,size(trim(dclcom)),dclstatus)
 END ;Subroutine
 SUBROUTINE getclient(null)
   DECLARE retval = vc WITH protect, noconstant("")
   SET retval = logical("CLIENT_MNEMONIC")
   IF (retval="")
    SELECT INTO "nl:"
     d.info_char
     FROM dm_info d
     WHERE d.info_domain="DATA MANAGEMENT"
      AND d.info_name="CLIENT MNEMONIC"
     DETAIL
      retval = trim(d.info_char)
     WITH nocounter
    ;end select
   ENDIF
   IF (retval="")
    SET retval = "unknown"
   ENDIF
   RETURN(retval)
 END ;Subroutine
 SET last_mod = "002"
END GO
