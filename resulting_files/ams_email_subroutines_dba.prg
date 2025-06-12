CREATE PROGRAM ams_email_subroutines:dba
 IF (validate(ams_email_subroutines_defined,0) != 0)
  GO TO exit_script
 ENDIF
 DECLARE ams_email_subroutines_defined = i2 WITH constant(1), persistscript
 DECLARE sdefaultemailattachment = vc WITH protect, constant(""), persistscript
 DECLARE sdefaultemailbody = vc WITH protect, constant(
  "DO NOT REPLY TO THIS EMAIL.  THE RETURN EMAIL ADDRESS IS UNMONITORED."), persistscript
 DECLARE subgetlinuxversion(dummy) = f8 WITH copy
 DECLARE subsendemail(stoaddress=vc,semailsubject=vc,semailbody=vc(value,sdefaultemailbody),
  sfullospathfilename=vc(value,sdefaultemailattachment)) = i2 WITH copy
 SUBROUTINE subgetlinuxversion(dummy)
   DECLARE sfilelinuxversiontemp = vc WITH protect, constant(build2("ams_os_ver_",cnvtdatetime(
      curdate,curtime3),".dat"))
   DECLARE scmdlinuxver = vc WITH protect, constant(build2("cat /etc/redhat-release >> ",trim(
      sfilelinuxversiontemp,3)))
   DECLARE icmdlength = i4 WITH protect, noconstant(textlen(scmdlinuxver))
   DECLARE istatus = i4 WITH protect, noconstant(0)
   DECLARE sversion = vc WITH protect, noconstant("")
   DECLARE sdcloutput = vc WITH protect, noconstant("")
   DECLARE dreturnvalue = f8 WITH protect, noconstant(- (0.5))
   DECLARE bcontinue = i2 WITH protect, noconstant(true)
   DECLARE iwknt = i4 WITH protect, noconstant(1)
   SET stat = remove(sfilelinuxversiontemp)
   CALL dcl(scmdlinuxver,icmdlength,istatus)
   FREE DEFINE rtl
   DEFINE rtl sfilelinuxversiontemp
   SELECT INTO "nl:"
    FROM rtlt r
    HEAD REPORT
     sdcloutput = cnvtupper(trim(r.line,3))
    WITH nocounter
   ;end select
   SET stat = remove(sfilelinuxversiontemp)
   SET sversion = substring((findstring("RELEASE",sdcloutput)+ 8),1,sdcloutput)
   IF (isnumeric(sversion)=1)
    WHILE (bcontinue
     AND iwknt < 4)
     SET iwknt = (iwknt+ 1)
     IF (isnumeric(substring(((findstring("RELEASE",sdcloutput)+ 8)+ iwknt),1,sdcloutput))=1)
      IF (iwknt=2)
       SET sversion = concat(trim(sversion,3),".",substring(((findstring("RELEASE",sdcloutput)+ 8)+
         iwknt),1,sdcloutput))
      ELSE
       SET sversion = concat(trim(sversion,3),substring(((findstring("RELEASE",sdcloutput)+ 8)+ iwknt
         ),1,sdcloutput))
      ENDIF
     ELSE
      SET bcontinue = false
     ENDIF
    ENDWHILE
    IF (isnumeric(sversion) > 0)
     SET dreturnvalue = cnvtreal(sversion)
    ENDIF
   ENDIF
   RETURN(dreturnvalue)
 END ;Subroutine
 SUBROUTINE subsendemail(stoaddress,semailsubject,semailbody,sfullospathfilename)
   DECLARE icclversion = i4 WITH private, constant(cnvtint(build(currev,currevminor,currevminor2)))
   DECLARE bcontinue = i4 WITH private, noconstant(true)
   DECLARE ipos = i4 WITH private, noconstant(1)
   DECLARE stemp = vc WITH private, noconstant("")
   DECLARE stheemailaddress = vc WITH private, noconstant("")
   DECLARE sattachfilename = vc WITH private, noconstant("")
   DECLARE battachfile = i2 WITH private, noconstant(false)
   DECLARE bemailbody = i2 WITH private, noconstant(true)
   DECLARE dlinuxversion = f8 WITH private, noconstant(0.0)
   DECLARE sdclcommand = vc WITH private, noconstant("")
   DECLARE idclstatus = i2 WITH private, noconstant(9)
   DECLARE ireturnvalue = i4 WITH private, noconstant(0)
   IF ((( NOT (cursys2 IN ("AIX", "HPX", "LNX"))) OR (icclversion < 844)) )
    RETURN(- (1))
   ENDIF
   WHILE (bcontinue=true
    AND ipos < 500)
     SET stemp = piece(stoaddress,";",ipos,"NOT FOUND")
     IF (stemp != "NOT FOUND")
      IF (size(trim(stheemailaddress,3))=0)
       SET stheemailaddress = stemp
      ELSE
       SET stheemailaddress = concat(stheemailaddress," ",stemp)
      ENDIF
     ELSE
      SET bcontinue = false
     ENDIF
     SET ipos = (ipos+ 1)
   ENDWHILE
   IF (size(trim(sfullospathfilename,3)) > 0)
    SET battachfile = true
    SET ipos = findstring("/",sfullospathfilename,1,1)
    IF (ipos > 0)
     SET sattachfilename = trim(substring((ipos+ 1),((size(sfullospathfilename) - ipos)+ 1),
       sfullospathfilename),3)
    ELSE
     SET sattachfilename = sfullospathfilename
    ENDIF
   ENDIF
   IF (size(trim(semailbody,3)) < 1)
    SET semailbody = sdefaultemailbody
   ENDIF
   IF (size(trim(semailsubject,3)) < 1)
    SET semailsubject = concat(trim(curprog,3)," : ",format(cnvtdatetime(curdate,curtime3),
      "mm/dd/yy hh:mm:ss;;q"))
   ENDIF
   IF (cursys2="AIX")
    IF (battachfile=false)
     SET sdclcommand = concat('( echo "',semailbody,'" ) | mailx -s "',semailsubject,'" ',
      stheemailaddress)
    ELSE
     SET sdclcommand = concat('( echo "',semailbody,'";uuencode ',sfullospathfilename," ",
      sattachfilename,' ) | mailx -s "',semailsubject,'" ',stheemailaddress)
    ENDIF
   ELSEIF (cursys2="HPX")
    IF (battachfile=false)
     SET sdclcommand = concat('( echo "',semailbody,'" ) | mailx -m -s "',semailsubject,'" ',
      stheemailaddress)
    ELSE
     SET sdclcommand = concat('( echo "',semailbody,'";uuencode ',sfullospathfilename," ",
      sattachfilename,' ) | mailx -m -s "',semailsubject,'" ',stheemailaddress)
    ENDIF
   ELSEIF (cursys2="LNX")
    SET dlinuxversion = subgetlinuxversion(0)
    IF (dlinuxversion < 1)
     RETURN(- (2))
    ELSEIF (dlinuxversion >= 6)
     IF (bemailbody=true
      AND battachfile=false)
      SET sdclcommand = concat('echo "',semailbody,'" | mailx -s "',semailsubject,'" ',
       stheemailaddress)
     ELSE
      SET sdclcommand = concat('echo "',semailbody,'" | mailx -s "',semailsubject,'" -a ',
       sfullospathfilename," ",stheemailaddress)
     ENDIF
    ELSE
     IF (battachfile=false)
      SET sdclcommand = concat('echo "',semailbody,'" | mailx -s "',semailsubject,'" ',
       stheemailaddress)
     ELSE
      SET sdclcommand = concat('( echo "',semailbody,'" ;uuencode ',sfullospathfilename," ",
       sattachfilename,' ) | mailx -s "',semailsubject,'" ',stheemailaddress)
     ENDIF
    ENDIF
   ENDIF
   CALL echo("***")
   CALL echo(build2("***   sDCLCommand: ",sdclcommand))
   CALL echo("***")
   SET ireturnvalue = dcl(sdclcommand,size(trim(sdclcommand)),idclstatus)
   RETURN(ireturnvalue)
 END ;Subroutine
#exit_script
 SET script_ver = "000 11/03/15 Initial Release"
END GO
