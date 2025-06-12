CREATE PROGRAM dc_mp_open_mpage:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getrootpath(null) = vc
 DECLARE openpage(sfile=vc) = i2
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE tempend = i2 WITH protect, noconstant(0)
 DECLARE sxml = vc WITH protect
 DECLARE params = vc WITH protect
 DECLARE rpath = vc WITH protect
 DECLARE par = c20
 DECLARE tempstr = vc
 DECLARE html_fname = vc
 DECLARE tempstr2 = vc
 DECLARE errmsg = vc WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE sscript_name = vc WITH protect, constant("dc_mp_open_mpage")
 DECLARE current_locale = vc WITH protect, constant(trim(curlocale))
 SET rpath = getrootpath(0)
 SET params = rpath
 SET lnum = 0
 SET num = 2
 SET cnt = 0
 SET cnt2 = 0
 WHILE (num > 0)
  SET par = reflect(parameter(num,0))
  IF (par=" ")
   SET cnt = (num - 1)
   SET num = 0
  ELSE
   IF (substring(1,1,par)="L")
    CALL echo(build("$(",num,")",par))
    SET lnum = 1
    WHILE (lnum > 0)
     SET par = reflect(parameter(num,lnum))
     IF (par=" ")
      SET cnt2 = (lnum - 1)
      SET lnum = 0
     ELSE
      CALL echo(build("$(",num,".",lnum,")",
        par,"=",parameter(num,lnum)))
      IF (isnumeric(parameter(num,lnum)))
       SET tempstr = cnvtstring(parameter(num,lnum))
      ELSE
       SET tempstr = parameter(num,lnum)
      ENDIF
      SET tempstr = replace(tempstr,",","@44@")
      SET params = concat(params,",",tempstr)
      SET lnum += 1
     ENDIF
    ENDWHILE
   ELSE
    CALL echo(build("$(",num,")",par,"=",
      parameter(num,lnum)))
    IF (num=2)
     SET html_fname = parameter(num,lnum)
    ELSE
     IF (isnumeric(parameter(num,lnum)))
      SET tempstr = cnvtstring(parameter(num,lnum))
     ELSE
      SET tempstr = parameter(num,lnum)
     ENDIF
     SET tempstr = replace(tempstr,",","@44@")
     SET params = concat(params,",",tempstr)
    ENDIF
   ENDIF
   SET num += 1
  ENDIF
 ENDWHILE
 CALL echo(build("num param=",cnt))
 SET params = trim(params,4)
 SET params = replace(replace(params,"<","@60@"),">","@62@")
 CALL echo(build("current_locale -->",current_locale))
 SET params = concat(params,",",current_locale)
 CALL echo(build("params-->",trim(params)))
 SET html_fname = replace(html_fname,"\","\\",0)
 SET html_fname = replace(html_fname,"/","\\",0)
 IF (findstring("$",html_fname,1,0)=1)
  SET html_fname = replace(html_fname,"$","",0)
  IF (findstring("HTTP:",cnvtupper(html_fname),1,0)=0)
   SET html_fname = concat("file:///",html_fname)
  ENDIF
 ELSE
  SET html_fname = concat(rpath,"\\",html_fname)
 ENDIF
 SET html_fname = replace(html_fname," ","%20",0)
 SET lstat = openhtml(html_fname)
 GO TO exit_script
 SUBROUTINE getrootpath(null)
   DECLARE pstr = vc WITH protect
   SELECT INTO "nl"
    FROM dm_info di
    WHERE di.info_name="FE_WH"
    DETAIL
     pstr = trim(cnvtupper(di.info_char))
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select (DM_INFO):",errmsg)
   ENDIF
   SET lstat = 0
   SET lstat = findstring("WININTEL",pstr)
   IF (lstat=0)
    SET pstr = concat(pstr,"\WININTEL")
   ENDIF
   SET pstr = replace(pstr,"\","\\",0)
   SET pstr = replace(pstr,"/","\\",0)
   CALL echo(build("pStr ==>",trim(pstr)))
   RETURN(pstr)
 END ;Subroutine
 SUBROUTINE (openhtml(sfile=vc) =i2)
  IF (trim(cnvtupper( $OUTDEV))=patstring("EXPERTHTMLFILE*"))
   IF (validate(eksdata))
    SET tempstr2 = concat('<html> <body onload = window.location.replace("',sfile,"?",trim(params),
     '")>',
     "</body></html>")
    CALL echo(tempstr2)
    EXECUTE cpm_create_file_name "mp", "dat"
    CALL echo(cpm_cfn_info->file_name_full_path)
    SELECT INTO value(cpm_cfn_info->file_name_full_path)
     FROM dummyt
     DETAIL
      col 0, tempstr2
     WITH nocounter, maxcol = 10000, format = variable
    ;end select
    SET msgindx = 0
    IF ((eksdata->bldmsg_cnt > 0))
     FOR (indx = 1 TO eksdata->bldmsg_cnt)
       IF (cnvtupper(eksdata->bldmsg[indx].name)=trim(cnvtupper( $OUTDEV)))
        SET msgindx = indx
        SET indx = eksdata->bldmsg_cnt
       ENDIF
     ENDFOR
    ENDIF
    IF (msgindx=0)
     SET eksdata->bldmsg_cnt += 1
     SET stat = alterlist(eksdata->bldmsg,eksdata->bldmsg_cnt)
     SET msgindx = eksdata->bldmsg_cnt
    ENDIF
    SET eksdata->bldmsg[msgindx].name = trim(cnvtupper( $OUTDEV))
    SET eksdata->bldmsg[msgindx].text = cpm_cfn_info->file_name_full_path
    SET log_message = concat(sfile,"?",",",trim(params))
    CALL echo(log_message)
    SET retval = 100
   ELSE
    CALL echo("Not inside Rule execution")
   ENDIF
  ELSE
   IF (validate(_memory_reply_string))
    SET _memory_reply_string = concat('<html> <body onload = window.location.replace("',sfile,"?",
     trim(params),'")>',
     "</body></html>")
    CALL echo(_memory_reply_string)
   ELSE
    SET tempstr2 = concat('<html> <body onload = window.location.replace("',sfile,"?",trim(params),
     '")>',
     "</body></html>")
    CALL echo(tempstr2)
    SELECT INTO  $OUTDEV
     FROM dummyt d
     DETAIL
      row + 1, col 0, tempstr2
     WITH nocounter, maxcol = 2000
    ;end select
   ENDIF
  ENDIF
  RETURN(1)
 END ;Subroutine
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET lstat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = sscript_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#exit_script
END GO
