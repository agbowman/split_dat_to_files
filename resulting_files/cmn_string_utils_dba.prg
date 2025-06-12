CREATE PROGRAM cmn_string_utils:dba
 DECLARE PUBLIC::cmnisblank(str=vc) = i2 WITH copy
 DECLARE PUBLIC::cmnisnotblank(str=vc) = i2 WITH copy
 DECLARE PUBLIC::parsedelimitedstring(source=vc,delimiter=vc,itemindex=i4,remainder=vc(ref)) = vc
 WITH copy
 DECLARE PUBLIC::htmlscrub(source=vc) = vc WITH copy
 DECLARE PUBLIC::htmlunscrub(source=vc) = vc WITH copy
 DECLARE PUBLIC::escapertfcharacters(source=vc) = vc WITH copy
 IF ( NOT (validate(PUBLIC::cmn_string_utils_imported)))
  DECLARE PUBLIC::cmn_string_utils_imported = vc WITH protect, constant("CMN_STRING_UTILS_IMPORTED"),
  copy
 ENDIF
 IF (checkfun("UT_CMN_STRING_UTILS_MAIN")=7)
  CALL ut_cmn_string_utils_main(null)
 ENDIF
 SUBROUTINE PUBLIC::cmnisblank(str)
  IF (textlen(trim(str,3)) > 0)
   RETURN(false)
  ENDIF
  RETURN(true)
 END ;Subroutine
 SUBROUTINE PUBLIC::cmnisnotblank(str)
  IF (textlen(trim(str,3)) > 0)
   RETURN(true)
  ENDIF
  RETURN(false)
 END ;Subroutine
 SUBROUTINE PUBLIC::parsedelimitedstring(source,delimiter,itemindex,remainder)
   DECLARE first_occurrence = i4 WITH protect, constant(0)
   DECLARE sourcelen = i4 WITH protect, noconstant(textlen(source))
   DECLARE delimlen = i4 WITH protect, noconstant(textlen(delimiter))
   DECLARE delimpos = i4 WITH protect, noconstant(- (delimlen))
   DECLARE searchstart = i4 WITH protect, noconstant(1)
   DECLARE itemcount = i4 WITH protect, noconstant(0)
   DECLARE delimexists = i2 WITH protect, noconstant(false)
   DECLARE item = vc WITH protect, noconstant("")
   SET remainder = ""
   IF (trim(delimiter)=trim(""))
    RETURN(source)
   ENDIF
   IF (itemindex < 1)
    RETURN("")
   ENDIF
   WHILE (itemcount < itemindex
    AND delimpos != 0)
     SET itemcount = (itemcount+ 1)
     IF (delimpos < 0)
      SET delimpos = (delimpos+ 1)
     ENDIF
     SET searchstart = (delimpos+ delimlen)
     SET delimpos = findstring(delimiter,source,searchstart,first_occurrence)
     IF (delimpos > 0)
      SET delimexists = true
     ENDIF
   ENDWHILE
   IF (delimexists=true)
    IF (delimpos > 0)
     SET item = substring(searchstart,(delimpos - searchstart),source)
     SET remainder = substring((delimpos+ delimlen),(((1+ sourcelen) - delimpos) - delimlen),source)
    ELSEIF (itemcount=itemindex)
     SET item = substring(searchstart,((1+ sourcelen) - searchstart),source)
    ENDIF
   ELSE
    SET item = source
    SET remainder = " "
   ENDIF
   RETURN(item)
 END ;Subroutine
 SUBROUTINE PUBLIC::htmlscrub(source)
   CALL echo("htmlScrub")
   CALL echo(source)
   RETURN(replace(replace(replace(source,"&","&amp;"),"<","&lt;"),">","&gt;"))
 END ;Subroutine
 SUBROUTINE PUBLIC::htmlunscrub(source)
   CALL echo("htmlUnscrub")
   CALL echo(source)
   RETURN(replace(replace(replace(source,"&gt;",">"),"&lt;","<"),"&amp;","&"))
 END ;Subroutine
 SUBROUTINE PUBLIC::escapertfcharacters(source)
   RETURN(replace(replace(replace(source,"\","\\"),"}","\}"),"{","\{"))
 END ;Subroutine
#exit_script
END GO
