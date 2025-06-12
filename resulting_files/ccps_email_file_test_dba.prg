CREATE PROGRAM ccps_email_file_test:dba
 CALL echo(concat("***  CURSYS: ",cursys))
 CALL echo(concat("***  CURSYS2: ",cursys2))
 DECLARE zipfile_full = vc WITH protect, constant("")
 DECLARE removing_file = i2 WITH protect, constant(0)
 DECLARE email_file(mail_addr=vc,from_addr=vc,mail_sub=vc,attach_file_full=vc,attach_zipfile_full=vc(
   value,zipfile_full),
  remove_files=i2(value,removing_file)) = i2
 SUBROUTINE email_file(mail_addr,from_addr,mail_sub,attach_file_full,attach_zipfile_full,remove_files
  )
   DECLARE ccl_ver = i4 WITH private, noconstant(cnvtint(build(currev,currevminor,currevminor2)))
   DECLARE start_pos = i4 WITH private, noconstant(0)
   DECLARE cur_pos = i4 WITH private, noconstant(0)
   DECLARE end_flag = i2 WITH private, noconstant(0)
   DECLARE stemp = vc WITH private, noconstant("")
   DECLARE mail_to = vc WITH private, noconstant("")
   DECLARE attach_file = vc WITH private, noconstant("")
   DECLARE attach_zipfile = vc WITH private, noconstant("")
   DECLARE email_full = vc WITH private, noconstant("")
   DECLARE email_file = vc WITH private, noconstant("")
   DECLARE dclcom = vc WITH private, noconstant("")
   DECLARE dclcom1 = vc WITH private, noconstant("")
   DECLARE dclstatus = i2 WITH private, noconstant(9)
   DECLARE dclstatus1 = i2 WITH private, noconstant(9)
   DECLARE returnval = i2 WITH private, noconstant(9)
   DECLARE removeval = i2 WITH private, noconstant(0)
   DECLARE zipping_file = i2 WITH private, noconstant(0)
   IF ( NOT (cursys2 IN ("AIX", "HPX", "LNX"))
    AND ccl_ver < 844)
    RETURN(0)
   ENDIF
   SET start_pos = 1
   SET cur_pos = 1
   SET end_flag = 0
   WHILE (end_flag=0
    AND cur_pos < 500)
     SET stemp = piece(mail_addr,";",cur_pos,"Not Found")
     IF (stemp != "Not Found")
      IF (size(trim(mail_to))=0)
       SET mail_to = stemp
      ELSE
       SET mail_to = concat(mail_to," ",stemp)
      ENDIF
     ELSE
      SET end_flag = 1
     ENDIF
     SET cur_pos = (cur_pos+ 1)
   ENDWHILE
   SET cur_pos = findstring("/",attach_file_full,start_pos,1)
   IF (cur_pos < 1)
    SET attach_file = trim(attach_file_full,3)
   ELSE
    SET attach_file = trim(substring((cur_pos+ 1),((size(attach_file_full) - cur_pos)+ 1),
      attach_file_full),3)
   ENDIF
   SET email_file = attach_file
   SET email_full = attach_file_full
   IF (textlen(trim(attach_zipfile_full,3)) > 0)
    SET zipping_file = 1
    SET start_pos = 1
    SET cur_pos = 1
    SET cur_pos = findstring("/",attach_zipfile_full,start_pos,1)
    IF (cur_pos < 1)
     SET attach_zipfile = trim(attach_zipfile_full,3)
    ELSE
     SET attach_zipfile = trim(substring((cur_pos+ 1),((size(attach_zipfile_full) - cur_pos)+ 1),
       attach_zipfile_full),3)
    ENDIF
    SET dclcom = concat("zip -j ",attach_zipfile," ",attach_file)
    CALL dcl(dclcom,size(trim(dclcom)),dclstatus)
    SET email_file = attach_zipfile
    SET email_full = attach_zipfile_full
   ENDIF
   IF (cursys2="AIX")
    IF (((dclstatus=0) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -s "',mail_sub,'" ',"-r ",
      from_addr," ",mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ELSEIF (cursys2="HPX")
    IF (((dclstatus=0) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -m -s "',mail_sub,'" ',"-r ",
      from_addr," ",mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ELSEIF (cursys2="LNX")
    IF (((dclstatus=1) OR (zipping_file=0)) )
     SET dclcom1 = concat("uuencode"," ",email_full," ",email_file,
      " ",'|mailx -s "',mail_sub,'" ',mail_to)
     SET returnval = dcl(dclcom1,size(trim(dclcom1)),dclstatus1)
    ENDIF
   ENDIF
   IF (returnval != 9
    AND remove_files != 0)
    IF (textlen(trim(attach_zipfile_full,3))=0)
     SET removeval = remove(attach_file_full)
    ELSEIF (textlen(trim(attach_zipfile_full,3)) > 0)
     SET removeval = remove(attach_file_full)
     SET removeval = remove(attach_zipfile_full)
    ENDIF
   ENDIF
   IF (returnval != 9
    AND removeval IN (0, 1))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
   SET last_mod = "02/02/2012 MP9098"
 END ;Subroutine
 DECLARE cur_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE sfullfilename = vc WITH protect, noconstant("")
 DECLARE email_stat = i2 WITH protect, noconstant(0)
 DECLARE srecipient = vc WITH protect, noconstant("matt.watt@cerner.com;mw017700@cerner.com")
 DECLARE sfilename = vc WITH protect, noconstant("ccps_email_file_test.dat")
 DECLARE slocalpath = vc WITH protect, noconstant(logical("cer_temp"))
 DECLARE ssubject = vc WITH protect, noconstant(concat("Test: ccps_email_file ",format(cur_dt_tm,
    "DD-MMM-YYYY;;D")))
 DECLARE sfrom = vc WITH protect, noconstant("Cerner")
 IF (cursys="AIX")
  SET sfullfilename = build(slocalpath,"/",sfilename)
 ELSE
  GO TO exit_script
 ENDIF
 CALL echo(concat("***  sFullFileName: ",sfullfilename))
 SELECT INTO value(sfullfilename)
  FROM (dummyt d  WITH seq = 1)
  DETAIL
   row 0, col 0,
   CALL print(format(cur_dt_tm,"DD-MMM-YYYY HH:MM;;Q")),
   row + 1,
   CALL print(concat("Executed: ",curprog)), row + 1,
   CALL print(concat("Domain: ",curdomain)), row + 1,
   CALL print(concat("CURSYS: ",cursys)),
   row + 1,
   CALL print(concat("CURSYS2: ",cursys2)), row + 1,
   CALL print(build2("CCL Version: ",trim(cnvtstring(currev)),".",trim(cnvtstring(currevminor)),".",
    trim(cnvtstring(currevminor2)))), row + 1,
   CALL print(concat("CURUSER: ",curuser))
  WITH nocounter, separator = " ", format
 ;end select
 IF (findfile(sfullfilename))
  SET email_stat = email_file(srecipient,sfrom,ssubject,sfullfilename)
  CALL echo(build2("***  File ",sfilename," Emailed to ",srecipient," with status ",
    trim(cnvtstring(email_stat),3)))
 ENDIF
#exit_script
 CALL echo("last mod = 002  09/22/11  MW017700")
END GO
