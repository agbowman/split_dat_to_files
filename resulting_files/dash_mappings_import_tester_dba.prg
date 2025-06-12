CREATE PROGRAM dash_mappings_import_tester:dba
 DECLARE includeinresponse = i4 WITH protect, noconstant(0)
 DECLARE logdetails(p1=vc(val),p2=vc(val),p3=vc(val)) = null WITH protect
 DECLARE logeffort(p1=vc(val),p2=dq8(val),p3=vc(ref)) = null WITH protect
 DECLARE findattrbyname(obj=vc(ref),name=vc,value=vc(ref)) = i2 WITH copy
 DECLARE getnextlistitem(json=vc(ref),pos=i4,item=vc(ref)) = i4 WITH copy
 DECLARE getnextattrandvalue(json=vc(ref),pos=i4,name=vc(ref),value=vc(ref)) = i4 WITH copy
 DECLARE getvalueatpos(string=vc(ref),pos=i4,max=i4,value=vc(ref)) = i4 WITH copy
 DECLARE findnexttokenchar(string=vc(ref),pos=i4,max=i4) = i4 WITH copy
 DECLARE findclosingdelimiter(string=vc(ref),pos=i4) = i4 WITH copy
 DECLARE skipwhitespace(string=vc(ref),pos=i4,max=i4) = i4 WITH copy
 DECLARE getquotedstring(json=vc(ref),pos=i4,string=vc(ref)) = i4 WITH copy
 SUBROUTINE findattrbyname(obj,name,value)
   DECLARE pos = i4 WITH protect, noconstant(1)
   DECLARE aname = vc WITH protect
   WHILE (pos > 0)
     SET pos = getnextattrandvalue(obj,pos,aname,value)
     IF (validate(debug_ind,0)=1)
      CALL echo("In FindAttrByName.  Just called GetNextAttrAndValue.")
      CALL echo(build("pos=",pos))
      CALL echo(build("name(looking for attribute)=",name))
      CALL echo(build("aname(found attribute)=",aname))
      CALL echo(build("value=",value))
     ENDIF
     IF (pos > 0
      AND aname=name)
      RETURN(1)
     ENDIF
   ENDWHILE
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE getnextlistitem(json,pos,item)
   DECLARE len = i4 WITH protect, constant(textlen(json))
   DECLARE char = c1 WITH protect
   DECLARE vpos = i4 WITH protect
   SET pos = skipwhitespace(json,pos,len)
   SET char = substring(pos,1,json)
   IF (char="]")
    RETURN(0)
   ELSEIF (char="[")
    SET vpos = skipwhitespace(json,(pos+ 1),len)
    IF (substring(vpos,1,json)="]")
     RETURN(0)
    ENDIF
   ELSEIF (char != ",")
    RETURN(- (1))
   ENDIF
   IF (char=",")
    SET vpos = skipwhitespace(json,(pos+ 1),len)
    IF (vpos > 0
     AND substring(vpos,1,json)="]")
     RETURN(0)
    ENDIF
   ENDIF
   SET vpos = getvalueatpos(json,(pos+ 1),len,item)
   IF (validate(debug_ind,0)=1)
    CALL echo("In GetNextListItem.  Just called GetValueAtPos.")
    CALL echo(build("item(value)=",item))
    CALL echo(build("pos=",pos))
    CALL echo(build("vpos=",vpos))
   ENDIF
   IF (vpos > 0)
    SET vpos = findnexttokenchar(json,vpos,len)
   ELSEIF (vpos=0)
    SET vpos = - (1)
   ENDIF
   RETURN(vpos)
 END ;Subroutine
 SUBROUTINE getnextattrandvalue(json,pos,name,value)
   DECLARE length = i4 WITH constant(textlen(json))
   DECLARE clpos = i4 WITH protect
   DECLARE qpos = i4 WITH protect
   DECLARE eqpos = i4 WITH protect
   DECLARE cmpos = i4 WITH protect
   DECLARE brpos = i4 WITH protect
   DECLARE vpos = i4 WITH protect
   DECLARE char = c1 WITH protect
   IF (validate(debug_ind,0)=1)
    CALL echo("In GetNextAttrAndValue.")
   ENDIF
   SET qpos = findstring('"',json,pos)
   SET brpos = findstring("}",json,pos)
   IF (((qpos=0) OR (qpos > brpos)) )
    IF (validate(debug_ind,0)=1)
     CALL echo("No more values. Returning 0.")
    ENDIF
    RETURN(0)
   ENDIF
   SET eqpos = getquotedstring(json,qpos,name)
   IF (eqpos=0)
    IF (validate(debug_ind,0)=1)
     CALL echo("Couldn't find attribute name. Returning -1.")
    ENDIF
    RETURN(- (1))
   ENDIF
   SET clpos = findnexttokenchar(json,eqpos,length)
   IF (((clpos=0) OR (substring(clpos,1,json) != ":")) )
    IF (validate(debug_ind,0)=1)
     CALL echo("Couldn't find ':'. Returning -1.")
    ENDIF
    RETURN(- (1))
   ENDIF
   SET vpos = getvalueatpos(json,(clpos+ 1),length,value)
   IF ((vpos < (clpos+ 1)))
    IF (validate(debug_ind,0)=1)
     CALL echo("Couldn't find value. Returning -1.")
    ENDIF
    RETURN(- (1))
   ENDIF
   SET vpos = findnexttokenchar(json,vpos,length)
   IF (vpos=0)
    SET vpos = (length+ 1)
   ENDIF
   RETURN(vpos)
 END ;Subroutine
 SUBROUTINE getvalueatpos(string,pos,max,value)
   DECLARE endpos = i4 WITH protect, noconstant(0)
   DECLARE char = c1 WITH protect
   DECLARE functiontxt = vc WITH protect, noconstant("")
   DECLARE strlen = i4 WITH protect, noconstant(0)
   DECLARE functblockstartpos = i4 WITH protect, noconstant(0)
   DECLARE functblockendpos = i4 WITH protect, noconstant(0)
   DECLARE valuedetermined = i4 WITH protect, noconstant(0)
   SET pos = skipwhitespace(string,pos,max)
   IF (pos=0)
    RETURN(0)
   ENDIF
   SET char = substring(pos,1,string)
   IF (char='"')
    SET endpos = getquotedstring(string,pos,value)
    SET valuedetermined = 1
    IF (validate(debug_ind,0)=1)
     CALL echo("Value is a String.")
    ENDIF
   ELSEIF (((char="{") OR (char="[")) )
    SET endpos = findclosingdelimiter(string,pos)
    IF (endpos > 0)
     SET endpos = (endpos+ 1)
     SET value = substring(pos,(endpos - pos),string)
     SET valuedetermined = 1
     IF (validate(debug_ind,0)=1)
      CALL echo("Value is an object or collection.")
     ENDIF
    ELSE
     SET endpos = - (1)
     SET value = ""
     IF (validate(debug_ind,0)=1)
      CALL echo("Value is an invalid object or collection.")
     ENDIF
    ENDIF
   ELSEIF (char="t")
    SET endpos = findnexttokenchar(string,pos,max)
    IF (substring(endpos,1,string) IN (",", "}"))
     SET strlen = (endpos - pos)
     SET value = substring(pos,strlen,string)
     SET value = trim(value)
     IF (value="true")
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is 'true'.")
      ENDIF
     ELSE
      SET value = ""
     ENDIF
    ENDIF
   ELSEIF (char="f")
    SET endpos = findnexttokenchar(string,pos,max)
    IF (substring(endpos,1,string) IN (",", "}"))
     SET strlen = (endpos - pos)
     SET value = substring(pos,strlen,string)
     SET value = trim(value)
     IF (value="false")
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is 'false'.")
      ENDIF
     ELSEIF (substring(pos,8,string)="function")
      SET endpos = findstring("{",string,(pos+ 9),1)
      SET endpos = findclosingdelimiter(string,endpos)
      SET strlen = (endpos - pos)
      SET value = substring(pos,strlen,string)
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is an inline function.  THIS CODEPATH IS NOT TESTED!")
      ENDIF
     ELSE
      SET value = ""
     ENDIF
    ENDIF
   ELSEIF (char IN ("0", "1", "2", "3", "4",
   "5", "6", "7", "8", "9",
   "-", "."))
    SET endpos = findnexttokenchar(string,pos,max)
    IF (endpos > 0)
     SET value = trim(substring(pos,(endpos - pos),string),3)
     IF (isnumeric(value)=1)
      SET valuedetermined = 1
      IF (validate(debug_ind,0)=1)
       CALL echo("Value is numeric.")
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (char IN (",", "}"))
    IF (validate(debug_ind,0)=1)
     CALL echo("Value is MISSING.")
    ENDIF
    SET endpos = - (1)
   ENDIF
   IF (valuedetermined=0
    AND  NOT ((endpos=- (1))))
    SET endpos = (findstring(",",string,pos,1) - 1)
    SET strlen = (endpos - pos)
    SET value = substring(pos,strlen,string)
    IF (validate(debug_ind,0)=1)
     CALL echo("Value is assumed to be an object reference.")
    ENDIF
   ENDIF
   RETURN(endpos)
 END ;Subroutine
 SUBROUTINE findnexttokenchar(string,pos,max)
   WHILE (pos <= max
    AND  NOT (substring(pos,1,string) IN ('"', ",", ":", "}", "]")))
     SET pos = (pos+ 1)
   ENDWHILE
   IF (pos > max)
    SET pos = 0
   ENDIF
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE findclosingdelimiter(string,pos)
   DECLARE length = i4 WITH protect, noconstant(textlen(string))
   DECLARE opencount = i4 WITH protect, noconstant(1)
   DECLARE openq = c1 WITH protect, noconstant(" ")
   DECLARE delimiter = c1 WITH protect
   DECLARE closer = c1 WITH protect
   DECLARE char = c1 WITH protect
   SET delimiter = substring(pos,1,string)
   IF (delimiter="[")
    SET closer = "]"
   ELSEIF (delimiter="{")
    SET closer = "}"
   ELSE
    RETURN(- (1))
   ENDIF
   WHILE (pos < length
    AND opencount > 0)
     SET pos = (pos+ 1)
     SET char = substring(pos,1,string)
     IF (char='"')
      IF (openq=" ")
       SET openq = char
      ELSEIF (substring((pos - 1),1,string) != "\")
       SET openq = " "
      ENDIF
     ELSEIF (char=closer)
      SET opencount = (opencount - 1)
     ELSEIF (char=delimiter)
      SET opencount = (opencount+ 1)
     ENDIF
   ENDWHILE
   IF (opencount > 0)
    RETURN(- (1))
   ENDIF
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE skipwhitespace(string,pos,max)
   DECLARE char = c1 WITH protect
   SET char = substring(pos,1,string)
   WHILE (pos <= max
    AND char IN (" ", char(9), char(10), char(13)))
    SET pos = (pos+ 1)
    SET char = substring(pos,1,string)
   ENDWHILE
   IF (pos > max)
    SET pos = 0
   ENDIF
   RETURN(pos)
 END ;Subroutine
 SUBROUTINE getquotedstring(json,pos,string)
   DECLARE eqpos = i4 WITH protect
   IF (substring(pos,1,json) != '"')
    RETURN(- (1))
   ENDIF
   SET eqpos = findstring('"',json,(pos+ 1))
   WHILE (eqpos > 0
    AND substring((eqpos - 1),1,json)="\")
     SET eqpos = findstring('"',json,(eqpos+ 1))
   ENDWHILE
   IF (eqpos=0)
    RETURN(- (1))
   ENDIF
   SET string = substring((pos+ 1),((eqpos - pos) - 1),json)
   RETURN((eqpos+ 1))
 END ;Subroutine
 SUBROUTINE logdetails(message,variblename,variable)
   CALL log_message(message,log_level_debug)
   SET response->results.output = concat(response->results.output,message)
   IF (validate(debug_ind,0)=1)
    SET includeinresponse = 1
   ENDIF
   IF (includeinresponse=1)
    IF ( NOT (variblename=""))
     SET response->results.output = build(response->results.output,variblename," = ",variable,"<br>")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE logeffort(subroutinename,begindatetime,result_record)
  CALL log_message(build("Exiting ",log_program_name,".",subroutinename,
    "(). Elapsed time in seconds: ",
    datetimediff(cnvtdatetime(curdate,curtime3),begindatetime,5)),log_level_debug)
  IF (validate(debug_ind,0)=1)
   CALL echo(result_record)
  ENDIF
 END ;Subroutine
 FREE RECORD frec
 RECORD frec(
   1 file_desc = i4
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 FREE RECORD request
 RECORD request(
   1 blob_in = gvc
 )
 DECLARE log_message(p1=vc(val)) = null WITH protect
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE filename = vc WITH protect, noconstant("")
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE config_string = vc WITH protect, noconstant("")
 DECLARE component_config = vc WITH protect, noconstant("")
 DECLARE name = vc WITH protect, noconstant("")
 DECLARE value = vc WITH protect, noconstant("")
 DECLARE locale = vc WITH protect, noconstant("")
 DECLARE locale_language = vc WITH protect, noconstant("")
 SET filename = "cer_install:AnesDashTempMappings.json"
 SET frec->file_name = filename
 SET frec->file_buf = "r"
 SET stat = cclio("OPEN",frec)
 SET frec->file_buf = notrim(fillstring(100000," "))
 IF ((frec->file_desc != 0))
  SET stat = cclio("READ",frec)
 ENDIF
 SET stat = cclio("CLOSE",frec)
 IF ( NOT ((frec->file_buf > " ")))
  CALL log_message(concat("File ",filename," was not Found."))
  GO TO exit_script
 ENDIF
 SET config_string = frec->file_buf
 SET request->blob_in = config_string
 EXECUTE dash_rdm_import_mappings "MINE"
 SUBROUTINE log_message(message)
   IF (validate(debug_ind,0)=1)
    CALL echo(message)
   ENDIF
 END ;Subroutine
#exit_script
 FREE RECORD frec
 FREE RECORD request
END GO
