CREATE PROGRAM ccl_prompt_run_query:dba
 DECLARE dt_unassigned = i2 WITH constant(0), protect
 DECLARE dt_string = i2 WITH constant(1), protect
 DECLARE dt_numeric = i2 WITH constant(2), protect
 DECLARE dt_expression = i2 WITH constant(3), protect
 DECLARE dt_stringlist = i2 WITH constant(17), protect
 DECLARE dt_expressionlist = i2 WITH constant(19), protect
 IF ((validate(reply->recordlength,- (1))=- (1)))
  RECORD reply(
    1 recordlength = i4
    1 columndesc[*]
      2 name = vc
      2 title = vc
      2 visible = i2
      2 offset = i4
      2 length = i4
      2 keycolumn = i2
    1 data[*]
      2 buffer = vc
    1 validation = i2
    1 context[*]
      2 value = vc
    1 error_msg = vc
    1 misc[*]
      2 value = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 default_key_list[*]
      2 buffer = vc
    1 record_count = i4
    1 overflow[*]
      2 data[*]
        3 buffer = vc
  )
 ENDIF
 RECORD tokenrequest(
   1 source = gvc
   1 ignorewhitespace = i2
 ) WITH protect
 RECORD tokenreply(
   1 token[*]
     2 value = vc
     2 isliteral = i4
     2 iscomment = i4
 ) WITH protect
 IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
  CALL echo("omf_functions.inc: declaring omfsql_def")
  DECLARE omfsql_def = i2 WITH persist
  SET omfsql_def = 1
  IF ("Z"=validate(omf_function->v_func[1].v_func_name,"Z"))
   SET trace = recpersist
   DECLARE v_omfcnt = i4 WITH protect
   SET v_omfcnt = 0
   FREE SET omf_function
   RECORD omf_function(
     1 v_func[*]
       2 v_func_name = c40
       2 v_dtype = c10
   )
   SELECT INTO "nl:"
    function_name = function_name, dtype = return_dtype
    FROM omf_function
    WHERE function_name != "uar*"
     AND function_name != "cclsql*"
    ORDER BY function_name
    DETAIL
     v_omfcnt += 1
     IF (mod(v_omfcnt,100)=1)
      stat = alterlist(omf_function->v_func,(v_omfcnt+ 99))
     ENDIF
     omf_function->v_func[v_omfcnt].v_func_name = trim(function_name)
     IF (trim(dtype)="q8")
      omf_function->v_func[v_omfcnt].v_dtype = "dq8"
     ELSE
      omf_function->v_func[v_omfcnt].v_dtype = trim(dtype)
     ENDIF
    FOOT REPORT
     stat = alterlist(omf_function->v_func,v_omfcnt)
    WITH nocounter
   ;end select
   SET trace = norecpersist
  ENDIF
  DECLARE _omfcnt = i4 WITH protect
  IF (size(omf_function->v_func,5) > 0)
   FOR (_omfcnt = 1 TO size(omf_function->v_func,5))
     IF ((omf_function->v_func[_omfcnt].v_func_name > " "))
      SET v_declare = fillstring(100," ")
      SET v_declare = concat("declare ",trim(omf_function->v_func[_omfcnt].v_func_name),"() = ",trim(
        omf_function->v_func[_omfcnt].v_dtype)," WITH PERSIST GO")
      CALL parser(trim(v_declare))
     ENDIF
   ENDFOR
  ENDIF
  CALL echo("omf_functions: defined")
 ELSE
  CALL echo("omf_functions: already defined")
 ENDIF
 DECLARE statement = vc WITH protect
 DECLARE createdataset = i1 WITH noconstant(0)
 DECLARE columntitle = vc WITH protect
 DECLARE err = i2 WITH noconstant(0)
 DECLARE _debugflag = i2 WITH noconstant(0), protect
 DECLARE _logfilename = vc WITH protect
 DECLARE user = vc WITH protect
 DECLARE firsttoken = i2 WITH protect
 SET newline = concat(char(10),char(13))
 SET reply->status_data.status = "F"
 SET reply->validation = 1
 SET error = qry_exception
 SET createdataset = request->returndata
 SET statement = request->query
 IF (textlen(trim(statement))=0)
  SET reply->status_data.status = "Z"
  RETURN
 ENDIF
 SET _debugflag = 0
 IF ( NOT (err))
  CALL substituteparameters(0)
 ENDIF
 IF (_debugflag)
  SELECT INTO nl
   p.username
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    user = p.username
   WITH nocounter
  ;end select
  SET _logfilename = concat("discern_form_rtl_",cnvtalphanum(user),format(curdate,"yymmdd;;q"),".log"
   )
  CALL writestartlog(0)
  CALL logrequest(0)
 ENDIF
 SET tokenrequest->source = cnvtupper(statement)
 SET tokenrequest->ignorewhitespace = 1
 EXECUTE ccl_tokenscanner  WITH replace("REQUEST","TOKENREQUEST"), replace("REPLY","TOKENREPLY")
 SET firsttoken = 1
 WHILE (firsttoken <= size(tokenreply->token,5)
  AND tokenreply->token[firsttoken].iscomment)
   SET firsttoken += 1
 ENDWHILE
 IF (firsttoken <= size(tokenreply->token,5))
  IF ((tokenreply->token[firsttoken].value="EXECUTE"))
   CALL runprocedure(0)
  ELSEIF ((tokenreply->token[firsttoken].value="FUNCTION"))
   SET statement = trim(substring(9,(textlen(statement) - 8),statement))
   CALL runfunction(0)
  ELSEIF ((tokenreply->token[firsttoken].value="SELECT"))
   IF ( NOT (err))
    CALL appendoptions(0)
   ENDIF
   IF ( NOT (err))
    CALL executequery(0)
   ENDIF
  ELSEIF ((tokenreply->token[firsttoken].value="CALL"))
   IF ( NOT (err))
    CALL callstatement(0)
   ENDIF
  ELSE
   IF ( NOT (err))
    CALL appendoptions(0)
   ENDIF
   IF ( NOT (err))
    CALL executequery(0)
   ENDIF
   SET reply->error_msg = concat("warning: anonymous CCL command [",tokenreply->token[firsttoken].
    value,"] executed")
  ENDIF
 ELSE
  SET reply->error_msg = concat(reply->error_msg,"*unexpected end of token list.")
 ENDIF
 SET error = off
 CALL handleoverflow(0)
 SET reply->error_msg = concat(reply->error_msg," [",statement,"]")
 CALL logreply(0)
 RETURN
#qry_exception
 SET reply->error_msg = concat("exeception:",reply->error_msg," [",statement,"]")
 SET reply->status_data.status = "F"
 CALL writelog(reply->error_msg)
 RETURN
 SUBROUTINE (substituteparameters(void=i2) =null WITH protect)
   DECLARE paramname = vc WITH private
   DECLARE paramval = vc WITH private
   DECLARE datatype = i2 WITH private
   IF (size(request->parameters,5) > 0)
    FOR (pl = 1 TO size(request->parameters,5))
      SET paramname = trim(concat("$",trim(request->parameters[pl].name)))
      SET paramval = trim(request->parameters[pl].value)
      SET datatype = request->parameters[pl].datatype
      IF (trim(request->parameters[pl].name)="_DEBUG_")
       SET _debugflag = cnvtint(trim(request->parameters[pl].value))
      ENDIF
      IF (findstring(paramname,statement) > 0)
       CASE (datatype)
        OF dt_string:
         SET paramval = concat("^",paramval,"^")
         SET statement = replace(statement,paramname,paramval,0)
        OF dt_numeric:
         SET statement = replace(statement,paramname,paramval,0)
        OF dt_expression:
         SET statement = replace(statement,paramname,paramval,0)
        OF dt_stringlist:
         SET paramval = concat("VALUE(",paramval,")")
         SET statement = replace(statement,paramname,paramval,0)
        OF dt_expressionlist:
         SET paramval = concat("VALUE(",paramval,")")
         SET statement = replace(statement,paramname,paramval,0)
        ELSE
         CALL writelog(concat("unknown parameter type:",cnvtstring(datatype)," ",paramname,
           " using string type instead"))
         SET paramval = concat("^",paramval,"^")
         SET statement = replace(statement,paramname,paramval,0)
       ENDCASE
      ENDIF
    ENDFOR
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE (appendoptions(void=i2) =null WITH protect)
   DECLARE withpos = i2
   DECLARE reportsection = vc
   DECLARE origstatement = vc
   DECLARE state1 = vc
   DECLARE state2 = vc
   DECLARE statementupper = vc
   IF (createdataset=1)
    SET statementupper = cnvtupper(statement)
    SET statementupper = replace(statementupper,char(10)," ",0)
    SET statementupper = replace(statementupper,char(13)," ",0)
    IF ((tokenreply->token[firsttoken].value != "SELECT"))
     RETURN
    ENDIF
    SET withpos = findstring(" WITH ",statementupper,1,1)
    SET reportsection = concat(" head report","   columnTitle = ConCat(reportInfo(1), '$')",
     "   count = 0 ","   stat = AlterList(reply->data, 1000) "," detail ",
     "   count = count + 1 ","   if (Mod(count, 1000) = 0) ",
     "      stat = AlterList(reply->data, count+1000) ","	endif ",
     " reply->data[count].buffer = ConCat(reportinfo(2),'$') ",
     " "," foot report ","   stat = AlterList(reply->data, count) "," ")
    IF (withpos > 0)
     SET state1 = substring(1,withpos,statement)
     SET state2 = substring(withpos,size(statement),statement)
     SET statement = concat(trim(state1),reportsection,trim(state2),
      ", maxrow = 1, reportHelp, check, nullreport ")
    ELSE
     SET statement = concat(statement,reportsection," with maxrow = 1, reportHelp, check, nullreport"
      )
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE (executequery(void=i2) =null WITH protect)
   DECLARE sqlstmt = vc WITH private
   SET sqlstmt = concat(statement," GO ")
   CALL writelog(concat("QUERY: ",sqlstmt))
   IF (createdataset=1)
    SET columntitle = ""
    CALL parser(sqlstmt)
    CALL builddescriptors(0)
   ELSE
    SET stat = alterlist(reply->columndesc,0)
    SET stat = alterlist(reply->data,0)
    CALL parser(sqlstmt)
   ENDIF
   SET reply->status_data.status = "S"
   RETURN
 END ;Subroutine
 SUBROUTINE (runprocedure(void=i2) =null WITH protect)
   SET statement = concat(statement," go")
   CALL writelog(concat("Run Program [",statement,"]"))
   SET reply->status_data.subeventstatus[1].targetobjectname = ""
   SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
   SET reply->status_data.status = "S"
   CALL parser(statement)
   IF (createdataset=1)
    CALL builddescriptors(0)
   ENDIF
   RETURN
 END ;Subroutine
 SUBROUTINE (runfunction(void=i2) =null WITH protect)
   DECLARE stat = i2 WITH protect
   SET statement = build(statement)
   CALL writelog(concat("Function [",statement,"]"))
   SET reply->status_data.subeventstatus[1].targetobjectname = ""
   SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
   SET reply->status_data.status = "F"
   SET stat = alterlist(reply->misc,1)
   SET reply->misc[1].value = build(parser(statement))
   SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE (callstatement(void=i2) =null WITH protect)
   FREE RECORD callrequest
   FREE RECORD callreply
   SET statement = build(statement)
   CALL writelog(concat("Call [",statement,"]"))
   SET reply->status_data.subeventstatus[1].targetobjectname = ""
   SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
   SET reply->status_data.status = "F"
   RECORD callrequest(
     1 program_name = c31
     1 query_command = vc
     1 output_device = vc
     1 params = vc
     1 is_printer = c1
     1 is_odbc = c1
     1 isblob = c1
     1 qual[*]
       2 parameter = vc
       2 data_type = c1
   )
   SET callrequest->program_name = getprogramname(request->query)
   SET callrequest->output_device = "MINE"
   SET callrequest->params = buildparameters(0)
   SET callrequest->is_printer = "0"
   SET callrequest->is_odbc = "0"
   SET callrequest->isblob = "0"
   RECORD callreply(
     1 pgm_complete = vc
     1 columntitle = vc
     1 cpc_line = vc
     1 bisreport = c1
     1 nreporttype = i2
     1 norientation = i2
     1 lpdfsize = i4
     1 ltxtsize = i4
     1 ltxtlinemaxsize = i4
     1 rptreport
       2 m_reportname = c32
       2 m_pagewidth = f8
       2 m_pageheight = f8
       2 m_marginleft = f8
       2 m_marginright = f8
       2 m_margintop = f8
       2 m_marginbottom = f8
       2 m_orientation = i2
       2 m_errorsize = i4
     1 rpterrors[*]
       2 m_text = c256
       2 m_source = c64
       2 m_severity = i2
     1 qual[*]
       2 new_line = vc
     1 ntotalrecords = i4
     1 overflowpage[*]
       2 ofr_qual[*]
         3 ofr_line = vc
     1 qual2[*]
       2 pdf_line = gvc
       2 pdf_line_size = i4
     1 info_line[*]
       2 new_line = vc
     1 document = gvc
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SET keepreply = 1
   EXECUTE vccl_run_program  WITH replace("REQUEST","CALLREQUEST"), replace("REPLY","CALLREPLY")
   IF (size(callreply->qual,5) > 0)
    DECLARE recordcount = i1 WITH private
    DECLARE maxsize = i2 WITH private
    DECLARE d = i2 WITH private
    DECLARE rn = i2 WITH private
    SET maxsize = 0
    SET recordcount = size(callreply->qual,5)
    SET stat = alterlist(reply->data,(recordcount - 1))
    IF (recordcount > 0)
     FOR (rn = 1 TO recordcount)
       SET maxsize = lmax(maxsize,textlen(notrim(callreply->qual[rn].new_line)))
     ENDFOR
     DECLARE delta = i2 WITH private
     DECLARE filler = vc
     SET columntitle = notrim(callreply->qual[1].new_line)
     IF (textlen(columntitle) < maxsize)
      SET delta = (maxsize - textlen(columntitle))
      FOR (d = 1 TO delta)
        SET columntitle = notrim(concat(columntitle,char(32)))
      ENDFOR
      SET columntitle = notrim(concat(columntitle,"$"))
     ENDIF
     CALL builddescriptors(0)
     SET reply->recordlength = cnvtint(maxsize)
     FOR (rn = 2 TO cnvtint(size(callreply->qual,5)))
       SET delta = (maxsize - textlen(callreply->qual[rn].new_line))
       SET reply->data[(rn - 1)].buffer = notrim(callreply->qual[rn].new_line)
       WHILE (delta > 0)
        SET reply->data[(rn - 1)].buffer = notrim(concat(reply->data[(rn - 1)].buffer," "))
        SET delta -= 1
       ENDWHILE
       SET reply->data[(rn - 1)].buffer = notrim(concat(reply->data[(rn - 1)].buffer,"$"))
     ENDFOR
    ENDIF
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = callreply->status_data.status
    SET reply->status_data.subeventstatus.operationname = callreply->status_data.subeventstatus.
    operationname
    SET reply->status_data.subeventstatus.operationstatus = callreply->status_data.subeventstatus.
    operationstatus
    SET reply->status_data.subeventstatus.targetobjectname = callreply->status_data.subeventstatus.
    targetobjectname
    SET reply->status_data.subeventstatus.targetobjectvalue = callreply->status_data.subeventstatus.
    targetobjectvalue
   ENDIF
   FREE RECORD callrequest
   FREE RECORD callreply
   FREE SET apireply
 END ;Subroutine
 SUBROUTINE (lmax(leftmaxvalue=i2,rightmaxvalue=i2) =i2 WITH protect)
  IF (leftmaxvalue >= rightmaxvalue)
   RETURN(leftmaxvalue)
  ENDIF
  RETURN(rightmaxvalue)
 END ;Subroutine
 SUBROUTINE (getprogramname(st=vc) =vc WITH protect)
   DECLARE prgname = vc WITH private
   DECLARE ndx = i2 WITH private
   SET prgname = trim(substring(5,(textlen(st) - 5),st),3)
   SET ndx = findstring(" ",prgname)
   IF (ndx > 0)
    SET prgname = substring(0,ndx,prgname)
   ENDIF
   RETURN(prgname)
 END ;Subroutine
 SUBROUTINE (buildparameters(void=i2) =vc WITH protect)
   DECLARE paramname = vc WITH private
   DECLARE paramval = vc WITH private
   DECLARE datatype = i2 WITH private
   DECLARE arguments = vc WITH private
   DECLARE pl = i2 WITH private
   SET arguments = " "
   IF (size(request->parameters,5) > 0)
    FOR (pl = 1 TO size(request->parameters,5))
      SET paramname = trim(concat("$",trim(request->parameters[pl].name)))
      SET paramval = trim(request->parameters[pl].value)
      SET datatype = request->parameters[pl].datatype
      IF (pl > 1)
       SET arguments = concat(arguments,", ")
      ENDIF
      IF (trim(request->parameters[pl].name)="_DEBUG_")
       SET _debugflag = cnvtint(request->parameters[pl].name)
      ENDIF
      CASE (datatype)
       OF dt_string:
        SET paramval = concat("^",paramval,"^")
        SET arguments = build(arguments,paramval)
       OF dt_numeric:
        SET arguments = build(arguments,paramval)
       OF dt_expression:
        SET arguments = build(arguments,paramval)
       OF dt_stringlist:
        SET paramval = concat("VALUE(",paramval,")")
        SET arguments = build(arguments,paramval)
       OF dt_expressionlist:
        SET paramval = concat("VALUE(",paramval,")")
        SET arguments = build(arguments,paramval)
       ELSE
        CALL writelog(concat("unknown parameter type:",cnvtstring(datatype)," ",paramname,
          " using string type instead"))
        SET paramval = concat("^",paramval,"^")
        SET arguments = build(arguments,paramval)
      ENDCASE
    ENDFOR
   ENDIF
   RETURN(arguments)
 END ;Subroutine
 SUBROUTINE (builddescriptors(void=i2) =null WITH protect)
   DECLARE node = i2 WITH noconstant(0)
   DECLARE charpos = i4 WITH noconstant(1)
   DECLARE fldstart = i4 WITH noconstant(1)
   DECLARE fldend = i4 WITH noconstant(1)
   DECLARE fldname = vc
   SET strlen = textlen(columntitle)
   SET reply->recordlength = strlen
   WHILE (charpos <= strlen)
     SET node += 1
     SET stat = alterlist(reply->columndesc,node)
     SET reply->columndesc[node].offset = (fldstart - 1)
     SET charpos = parsefieldname(charpos)
     SET fldname = trim(substring(fldstart,((charpos - fldstart)+ 1),columntitle))
     SET reply->columndesc[node].name = checkduplicates(fldname)
     SET charpos = skipwhitespace(charpos)
     SET reply->columndesc[node].length = ((charpos - fldstart) - 1)
     SET reply->columndesc[node].title = reply->columndesc[node].name
     SET reply->columndesc[node].visible = 1
     SET fldstart = charpos
   ENDWHILE
   SET stat = alterlist(reply->columndesc,(size(reply->columndesc,5) - 1))
   RETURN
 END ;Subroutine
 SUBROUTINE (checkduplicates(fldname=vc) =vc WITH protect)
   DECLARE dups = i2 WITH noconstant(0), private
   DECLARE newname = vc
   DECLARE i = i2 WITH private
   SET newname = trim(fldname)
   FOR (i = 1 TO size(reply->columndesc,5))
     IF ((reply->columndesc[i].name=newname))
      SET dups += 1
     ENDIF
   ENDFOR
   IF (dups > 0)
    SET newname = concat(newname,trim(cnvtstring((dups+ 1))))
   ENDIF
   RETURN(newname)
 END ;Subroutine
 SUBROUTINE (parsefieldname(at_pos=i2) =i2 WITH protect)
   DECLARE atpos = i2
   SET atpos = at_pos
   WHILE (atpos <= textlen(columntitle)
    AND substring(atpos,1,columntitle) != " ")
     SET atpos += 1
   ENDWHILE
   RETURN(atpos)
 END ;Subroutine
 SUBROUTINE (skipwhitespace(at_pos=i2) =i2 WITH protect)
   DECLARE atpos = i2
   SET atpos = at_pos
   WHILE (atpos <= size(columntitle)
    AND substring(atpos,1,columntitle)=" ")
     SET atpos += 1
   ENDWHILE
   RETURN(atpos)
 END ;Subroutine
 SUBROUTINE (logrequest(dummy=i2) =null WITH protect)
  DECLARE lg = vc WITH protect
  IF (isdebugmode(0))
   DECLARE fn = vc WITH private
   SET fn = concat("dpl_run_ccl_query",format(curdate,"yyyymmdd;;q"),".log")
   SELECT INTO value(_logfilename)
    d.*
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0, "REQUEST", row + 1,
     colcnt = size(request->parameters,5), col 5, "PARAMETERS[",
     colcnt"###", "]", row + 1
     FOR (i = 1 TO colcnt)
       col 5, "PARAMETER(", i"###",
       ") ", request->parameters[i].name, "= ^",
       request->parameters[i].value, "^ [", request->parameters[i].datatype"##",
       "]", row + 1
     ENDFOR
     misccnt = size(request->context,5), col 5, "CONTEXT[",
     misccnt"###", "]", row + 1
     IF (misccnt > 0)
      FOR (i = 1 TO misccnt)
        col 5, "CONTEXT(", i"###",
        ") ", request->context[i].value, row + 1
      ENDFOR
     ENDIF
     IF (size(request->misc,5) > 0)
      FOR (i = 1 TO size(request->misc,5))
        col 5, "MISC(", i"###",
        ") ", request->misc[i].value, row + 1
      ENDFOR
     ENDIF
     col 5, "RETURNDATA = ", request->returndata"#",
     row + 1
    WITH nocounter, maxcol = 500, append
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE (logreply(dummy=i2) =null WITH protect)
   IF (isdebugmode(0))
    DECLARE fn = vc WITH protect
    DECLARE columnnumber = i2 WITH protect
    DECLARE hexchar = i2 WITH protect
    DECLARE collen = i2 WITH protect
    DECLARE maxlen = i2 WITH protect
    DECLARE reccount = i2 WITH protect
    DECLARE rn = i2 WITH protect
    SET fn = concat("dpl_run_ccl_query",format(curdate,"yyyymmdd;;q"),".log")
    SELECT INTO value(_logfilename)
     d.*
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      col 0, "REPLY", row + 1,
      col 5, "RECORDLENGTH = ", reply->recordlength,
      col + 1, row + 1, collen = size(reply->columndesc,5),
      col 5, "COLUMNDESC(", collen"###",
      ")", row + 1, col 10,
      "COLUMN     ", col 20, "NAME       ",
      col 50, "TITLE      ", col 80,
      "VISIBLE", col 90, "OFFSET",
      col 100, "LENGTH", col 116,
      "TYPE", row + 1, col 10,
      "-------  ", col 20, "-----------",
      col 50, "-----------", col 80,
      "-----", col 90, "-----",
      col 100, "-----", col 116,
      "--------------------", row + 1
      FOR (columnnumber = 1 TO collen)
        col 10, columnnumber"###", col 20,
        reply->columndesc[columnnumber].name"##############################", col 50, reply->
        columndesc[columnnumber].title"##############################",
        col 80, reply->columndesc[columnnumber].visible"#", col 90,
        reply->columndesc[columnnumber].offset"######", col 100, reply->columndesc[columnnumber].
        length"######",
        row + 1
      ENDFOR
      col 5, "RECORDS", row + 1,
      reccount = size(reply->data,5)
      FOR (rn = 1 TO reccount)
        col 10, rn"######", ") ",
        reply->data[rn].buffer"################################################################"
        IF (textlen(reply->data[rn].buffer) > 65)
         "<"
        ENDIF
        maxlen = maxval(64,textlen(reply->data[rn].buffer))
        FOR (hexchar = 1 TO maxlen)
          ch = substring(hexchar,1,reply->data[rn].buffer), hexstr = cnvtrawhex(ch), row + 1,
          " ", hexstr
        ENDFOR
        row + 1
      ENDFOR
      col 5, "VALIDATION = ", reply->validation"#",
      row + 1, col 5, "ERROR_MSG  = ",
      reply->error_msg"################################################################", row + 1
      IF (size(reply->misc,5) > 0)
       col 5, "MISC", row + 1
       FOR (i = 1 TO size(reply->misc,5))
         col 10, i"####", reply->misc[i].value
         "################################################################",
         row + 1
       ENDFOR
      ENDIF
      col 5, "DEFAULT KEY LIST", row + 1
      FOR (i = 1 TO size(reply->default_key_list,5))
        col 10, i"####", reply->default_key_list[i].buffer
        "################################################################",
        row + 1
      ENDFOR
      row + 1, col 5, "STATUS [",
      reply->status_data.status, "]", row + 1
     WITH nocounter, maxcol = 500, append
    ;end select
   ENDIF
 END ;Subroutine
 SUBROUTINE (writelog(msg=vc) =null WITH protect)
  IF (isdebugmode(0))
   EXECUTE ccl_prompt_write_log msg
  ENDIF
  RETURN
 END ;Subroutine
 SUBROUTINE (writestartlog(void=i2) =null WITH protect)
  IF (isdebugmode(0))
   DECLARE fn = vc WITH private
   SET fn = concat("dpl_run_ccl_query",format(curdate,"yyyymmdd;;q"),".log")
   SELECT INTO value(_logfilename)
    d.*
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     col 0, "******************************************************************", row + 1,
     col 0, "* ", curdate"yyyymmdd;;q",
     " ", curtime, " ",
     user, " ", "begin",
     row + 1
    WITH nocounter, maxcol = 500, append
   ;end select
  ENDIF
  RETURN
 END ;Subroutine
 SUBROUTINE (isdebugmode(void=i2) =i2 WITH protect)
   DECLARE mode = vc WITH protect
   SET mode = getparameter("_DEBUG_")
   IF (textlen(mode) > 0)
    RETURN(cnvtint(mode))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (getparameter(paramname=vc) =vc WITH protect)
   DECLARE pndx = i2 WITH protect
   SET pndx = parameterexist(paramname)
   IF (pndx > 0)
    RETURN(request->parameters[pndx].value)
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE (parameterexist(paramname=vc) =i2 WITH protect)
   DECLARE parcnt = i2 WITH protect
   SET parcnt = size(request->parameters,5)
   SET paramname = trim(cnvtupper(paramname))
   FOR (i = 1 TO parcnt)
     IF (paramname=trim(cnvtupper(request->parameters[i].name)))
      RETURN(i)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (handleoverflow(dummy=i2) =null WITH protect)
   DECLARE maxrecords = i4 WITH protect, constant(65535)
   DECLARE pos = i4 WITH protect, noconstant(0)
   DECLARE overflowitem = i4 WITH protect, noconstant(0)
   DECLARE overflowitemrecord = i4 WITH protect, noconstant(0)
   SET reply->record_count = size(reply->data,5)
   IF (size(reply->data,5) > maxrecords)
    SET pos = maxrecords
    SET stat = alterlist(reply->overflow,((size(reply->data,5) - 1)/ maxrecords))
    WHILE (pos < size(reply->data,5))
      SET overflowitem += 1
      SET overflowitemrecord = (size(reply->data,5) - pos)
      IF (overflowitemrecord > maxrecords)
       SET overflowitemrecord = maxrecords
      ENDIF
      SET stat = movereclist(reply->data,reply->overflow[overflowitem].data,(pos+ 1),0,
       overflowitemrecord,
       1)
      SET pos += maxrecords
    ENDWHILE
    SET stat = alterlist(reply->data,maxrecords)
   ENDIF
 END ;Subroutine
END GO
