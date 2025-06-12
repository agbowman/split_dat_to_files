CREATE PROGRAM ccl_prompt_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Group",
  "Program Name" = ""
  WITH outdev, grpno, prgname
 DECLARE getformdef(sformname=vc,ngroup=i2) = i2 WITH private
 DECLARE xlate(skey=vc) = vc
 DECLARE convertcode(skey=vc,svalue=vc) = vc
 DECLARE parseproperties(promptno=i2,compno=i2,propno=i2) = vc
 DECLARE readmultiline(promptno=i2,compno=i2,propno=i2) = vc
 DECLARE parsecompact(spropval=vc) = vc
 DECLARE parsedevices(spropval=vc) = vc
 DECLARE parsecolumndefs(spropval=vc) = vc
 DECLARE parsecoltbl(spropval=vc) = vc
 DECLARE parsestringtbl(spropval=vc) = vc
 DECLARE addproperty(sname=vc,sdisplay=vc) = i2
 DECLARE skipwhitespace(ws=i2,str=vc) = i2
 DECLARE getstring(ws=i2,str=vc) = i2
 DECLARE getword(ws=i2,str=vc) = i2
 DECLARE padstr(text=vc,tbpos=i2) = vc
 DECLARE theprompt = i2 WITH protect
 DECLARE thecomp = i2 WITH protect
 DECLARE theprop = i2 WITH protect
 DECLARE gp = f8 WITH protect
 DECLARE tempstr = vc WITH notrim
 DECLARE stridval = vc
 DECLARE strstrval = vc
 RECORD promptreq(
   1 programname = vc
   1 groupno = i2
 )
 RECORD promptrep(
   1 prompts[*]
     2 promptid = f8
     2 promptname = vc
     2 position = i2
     2 control = i2
     2 display = vc
     2 description = vc
     2 defaultvalue = vc
     2 resulttype = i2
     2 width = i4
     2 height = i4
     2 components[*]
       3 componentname = vc
       3 properties[*]
         4 propertyname = vc
         4 propertyvalue = vc
     2 excludeind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD xlatenames(
   1 items[*]
     2 name = vc
     2 display = vc
 )
 RECORD propitems(
   1 items[*]
     2 name = c30
     2 value = c40
 )
 SET new_line = concat(char(13),char(10))
 IF (getformdef( $PRGNAME,cnvtint( $GRPNO)))
  SET gp = 0.0
  CALL settranslations(0)
  SET padding = fillstring(160,char(160))
  SELECT INTO  $OUTDEV
   FROM (dummyt p  WITH seq = size(promptrep->prompts,5))
   HEAD REPORT
    line = fillstring(130,"-"), stars = fillstring(130,"*"), theprompt = 0
   HEAD PAGE
    col 5, "Page: ", curpage"###;L",
    col 115, curdate"DD-MMM-YYYY;;q", " ",
    curtime"HH:MM;;M", row + 1,
    CALL center("DISCERN EXPLORER",5,137),
    row + 2,
    CALL center("DISCERN PROMPT LIBRARY",5,137), row + 1,
    CALL center("FORM DEFINITION LISTING",5,137), row + 2, col 5,
    "Form Name : ", col 20, promptreq->programname,
    row + 1, col 5, "Access    : ",
    col 20
    IF ((promptreq->groupno=0))
     "DBA"
    ELSE
     "Group:", promptreq->groupno"##;l"
    ENDIF
    row + 1, col 5, stars,
    row + 1
    IF (curpage > 1)
     col 5, "Listing for:", promptrep->prompts[p.seq].promptname,
     " continued...", row + 2
    ENDIF
   DETAIL
    col 5, "Prompt Name    : ", promptrep->prompts[p.seq].promptname"##############################",
    col 60, "Control Type : "
    CASE (promptrep->prompts[p.seq].control)
     OF 0:
      "Text Box"
     OF 2:
      "Combo Box"
     OF 3:
      "List Box"
     OF 4:
      "Code Set"
     OF 5:
      "Date Time"
     OF 6:
      "Output Device"
    ENDCASE
    col 105, "Prompt ID  : ", promptrep->prompts[p.seq].promptid"###########;l",
    row + 1, col 5, "Result Type    : "
    CASE (promptrep->prompts[p.seq].resulttype)
     OF 1:
      "String"
     OF 3:
      "Expression"
     ELSE
      promptrep->prompts[p.seq].resulttype"##"
    ENDCASE
    col 105, "Position   : ", promptrep->prompts[p.seq].position"##;l",
    row + 1, col 5, "Display        : ",
    promptrep->prompts[p.seq].display, row + 1, col 5,
    "Status Text    : ", promptrep->prompts[p.seq].description, row + 1,
    col 5, "Prompt Default : ", promptrep->prompts[p.seq].defaultvalue,
    row + 2, col 5, "Prompt Control Property Sheet:",
    row + 1, col 5, "------------------------------",
    row + 1
    FOR (comp = 1 TO size(promptrep->prompts[p.seq].components,5))
      cmpname = promptrep->prompts[p.seq].components[comp].componentname, cmp = xlate(cmpname), col 5,
      "Component: ", col 18, cmp,
      row + 1, propcount = size(promptrep->prompts[p.seq].components[comp].properties,5)
      FOR (propitem = 1 TO propcount)
        propstr = parseproperties(p.seq,comp,propitem), propname = promptrep->prompts[p.seq].
        components[comp].properties[propitem].propertyname
        IF (findstring(":",propname) > 0)
         IF (findstring(":00",propname) > 0)
          propname = substring(1,(findstring(":",propname) - 1),propname), propname = xlate(propname)
          IF (propname != ".")
           col 15, propname"####################", trackpos = 1,
           nl = findstring(new_line,propstr)
           WHILE (nl > 0)
             subline = substring(trackpos,(nl - trackpos),propstr), col 35, subline,
             row + 1, trackpos = (nl+ 2), nl = findstring(new_line,propstr,trackpos)
           ENDWHILE
           subline = substring(trackpos,(textlen(propstr) - trackpos),propstr), col 35, subline,
           row + 1
          ENDIF
         ENDIF
        ELSE
         propname = xlate(propname)
         IF (propname != ".")
          col 15, propname"####################", trackpos = 1,
          nl = findstring(new_line,propstr)
          WHILE (nl > 0)
            subline = substring(trackpos,(nl - trackpos),propstr), col 35, subline,
            row + 1, trackpos = (nl+ 2), nl = findstring(new_line,propstr,trackpos)
          ENDWHILE
          subline = substring(trackpos,(textlen(propstr) - trackpos),propstr), col 35, subline,
          row + 1
         ENDIF
        ENDIF
      ENDFOR
      row + 1
    ENDFOR
    col 5, line, row + 1
   FOOT REPORT
    CALL center("END OF LISTING",5,137)
   WITH nocounter, maxcol = 160, compress
  ;end select
 ENDIF
 RETURN
 SUBROUTINE parseproperties(promptno,compno,propno)
   SET tempstr = ""
   SET scompname = promptrep->prompts[promptno].components[compno].componentname
   SET spropname = promptrep->prompts[promptno].components[compno].properties[propno].propertyname
   SET spropval = promptrep->prompts[promptno].components[compno].properties[propno].propertyvalue
   IF (findstring(":00",spropname) > 0)
    SET spropname = substring(1,(findstring(":",spropname) - 1),spropname)
   ENDIF
   CASE (cnvtlower(scompname))
    OF "text properties":
     CASE (cnvtlower(spropname))
      OF "default-value":
       SET tempstr = trim(spropval)
      OF "max-char-len":
       SET tempstr = trim(spropval)
      OF "text-attrib":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
     ENDCASE
    OF "validation":
     CASE (cnvtlower(spropname))
      OF "querydlg":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
      OF "settings":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
     ENDCASE
    OF "cwizdatasource":
     CASE (cnvtlower(spropname))
      OF "datasrc":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
      OF "settings":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
      OF "string-table":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsestringtbl(tempstr)
      OF "table-header":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecolumndefs(tempstr)
     ENDCASE
    OF "cwizcodeset":
     CASE (cnvtlower(spropname))
      OF "codeset":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
     ENDCASE
    OF "cwizdatetime":
     CASE (cnvtlower(spropname))
      OF "date-time-attr":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
     ENDCASE
    OF "cwizoutputdevice":
     CASE (cnvtlower(spropname))
      OF "output-devices":
       SET tempstr = readmultiline(promptno,compno,propno)
       SET tempstr = parsecompact(tempstr)
     ENDCASE
    OF "general":
     CASE (cnvtlower(spropname))
      OF "program":
       SET tempstr = parsecompact(spropval)
      OF "prompt":
       SET tempstr = parsecompact(spropval)
     ENDCASE
   ENDCASE
   SET tempstr = replace(tempstr,"&#034;",'"',0)
   SET tempstr = replace(tempstr,"&#123;","{",0)
   SET tempstr = replace(tempstr,"&#125;","}",0)
   SET tempstr = replace(tempstr,"&#061;","=",0)
   SET tempstr = replace(tempstr,"&#039;","'",0)
   RETURN(tempstr)
 END ;Subroutine
 SUBROUTINE readmultiline(promptno,compno,propno)
   DECLARE sline = vc WITH notrim
   DECLARE ndx = i2 WITH private
   DECLARE spropname1 = vc WITH private
   SET sline = " "
   SET spropname1 = promptrep->prompts[promptno].components[compno].properties[propno].propertyname
   SET spropname1 = substring(1,(findstring(":",spropname1) - 1),spropname1)
   SET ndx = 0
   SET slinename = concat(spropname1,":",format(ndx,"##;p0"))
   SET propcount = size(promptrep->prompts[promptno].components[compno].properties,5)
   WHILE (propno <= propcount
    AND trim(promptrep->prompts[promptno].components[compno].properties[propno].propertyname)=trim(
    slinename))
     SET sline = concat(sline,promptrep->prompts[promptno].components[compno].properties[propno].
      propertyvalue)
     SET ndx = (ndx+ 1)
     SET slinename = concat(spropname1,":",format(ndx,"##;p0"))
     SET propno = (propno+ 1)
   ENDWHILE
   RETURN(sline)
 END ;Subroutine
 SUBROUTINE parsestringtbl(spropval)
   DECLARE str = vc WITH private, notrim
   DECLARE strtbl = vc WITH private, notrim
   DECLARE npos = i2
   DECLARE len = i2
   DECLARE length = i2
   DECLARE ncol = i2
   DECLARE ch = c
   SET len = textlen(spropval)
   SET npos = 0
   SET ncol = 0
   SET strtbl = " "
   WHILE (npos <= len)
     SET ch = substring(npos,1,spropval)
     IF (ch="{")
      SET str = " "
     ELSEIF (ch="}")
      IF (textlen(str) < 60)
       SET strtbl = concat(strtbl,str,new_line)
      ELSE
       SET strtbl = concat(strtbl,substring(1,60,str)," ...",new_line)
      ENDIF
      SET str = " "
     ELSE
      SET str = concat(str,ch)
     ENDIF
     SET npos = (npos+ 1)
   ENDWHILE
   SET strtbl = replace(strtbl,"&#034;",'"',0)
   SET strtbl = replace(strtbl,"&#123;","{",0)
   SET strtbl = replace(strtbl,"&#125;","}",0)
   SET strtbl = replace(strtbl,"&#061;","=",0)
   SET strtbl = replace(strtbl,"&#039;","'",0)
   RETURN(strtbl)
 END ;Subroutine
 SUBROUTINE parsedevices(spropval)
   DECLARE pos = i2 WITH private
   DECLARE sdev = vc WITH private, notrim
   DECLARE devlst = vc WITH private, notrim
   DECLARE len = i2 WITH private
   IF (trim(spropval)="")
    RETURN("")
   ENDIF
   SET pos = 2
   SET sdev = " "
   SET offset = fillstring(6,char(160))
   SET devlst = concat(new_line,offset,"NAME           DESCRIPTION",new_line,offset,
    "-------------- --------------------------------------",new_line,"     *",char(160))
   SET len = textlen(spropval)
   SET spropval = replace(spropval,"&#034;","'",0)
   SET spropval = replace(spropval,"&#009;",char(9),0)
   SET spropval = replace(spropval," ",char(160),0)
   SET spaces = fillstring(100,char(160))
   WHILE (pos <= len)
     IF (substring(pos,1,spropval)="'")
      SET pos = (pos+ 1)
      IF (sdev > " ")
       SET devlen = (15 - findstring(char(9),sdev))
       SET sdev = replace(sdev,char(9),substring(1,devlen,spaces),0)
       SET devlst = concat(devlst,sdev,new_line,offset)
       SET sdev = char(160)
      ENDIF
      WHILE (pos <= len
       AND substring(pos,1,spropval) != "'")
        SET pos = (pos+ 1)
      ENDWHILE
      SET pos = (pos+ 1)
     ELSE
      SET sdev = concat(sdev,substring(pos,1,spropval))
      SET pos = (pos+ 1)
     ENDIF
   ENDWHILE
   SET devlst = concat(devlst,"----------",new_line,offset,"* = Default Device",
    new_line)
   RETURN(devlst)
 END ;Subroutine
 SUBROUTINE parsecolumndefs(spropval)
   DECLARE sval = vc WITH notrim
   DECLARE ssubval = vc WITH private
   DECLARE pos = i2 WITH private
   DECLARE len = i2 WITH private
   DECLARE fldno = i2 WITH private
   SET spropval = replace(spropval,"&#123;","{",0)
   SET spropval = replace(spropval,"&#125;","}",0)
   SET spropval = replace(spropval,"&#034;","'",0)
   SET spropval = replace(spropval,"&#061;","=",0)
   SET pos = 1
   SET len = textlen(spropval)
   SET pos = 1
   SET epos = 0
   SET fldno = 1
   SET pos = findstring("{",spropval)
   WHILE (pos > 0)
     SET epos = findstring("}",spropval,(pos+ 1))
     SET ssubval = substring((pos+ 1),(epos - pos),spropval)
     SET sval = concat(sval,format(fldno,"###;l"),char(160),char(160),parsecoltbl(ssubval),
      new_line)
     SET pos = findstring("{",spropval,epos)
     SET fldno = (fldno+ 1)
   ENDWHILE
   IF (textlen(sval) > 0)
    SET sval = concat(new_line,"FLD# ",
     "BINDING                        TITLE                          ","VIS.   ORD# TABLE",new_line,
     "---- ","------------------------------ ------------------------------ ",
     "----- ---- --------------------",new_line,sval)
    SET sval = concat(sval,"----------",new_line,"* = Key Field",new_line)
   ELSE
    SET sval = "No Columns defined"
   ENDIF
   RETURN(sval)
 END ;Subroutine
 SUBROUTINE parsecoltbl(spropval)
   DECLARE sval = vc WITH notrim
   DECLARE pos = i2 WITH private
   DECLARE len = i2 WITH private
   DECLARE id = vc WITH private
   DECLARE val = vc WITH private
   DECLARE sbinding = vc WITH private
   DECLARE stitle = vc WITH private
   DECLARE stype = vc WITH private
   DECLARE stable = vc WITH private
   DECLARE salias = vc WITH private
   DECLARE sformat = vc WITH private
   DECLARE swidth = vc WITH private
   DECLARE svisible = vc WITH private
   DECLARE scolumn = vc WITH private
   DECLARE sordinal = vc WITH private
   DECLARE svalue = vc WITH private
   DECLARE fld = i2 WITH private
   SET pos = 1
   SET len = textlen(spropval)
   SET strstrval = " "
   SET sbinding = strstrval
   SET stitle = strstrval
   SET stype = strstrval
   SET stable = strstrval
   SET salias = strstrval
   SET sformat = strstrval
   SET swidth = strstrval
   SET svisible = strstrval
   SET scolumn = strstrval
   SET sordinal = strstrval
   SET svalue = strstrval
   WHILE (pos < len)
     SET pos = skipwhitespace(pos,spropval)
     IF (pos < len)
      SET pos = getword(pos,spropval)
      SET pos = skipwhitespace(pos,spropval)
      IF (pos < len
       AND substring(pos,1,spropval)="=")
       SET pos = skipwhitespace((pos+ 1),spropval)
       IF (pos < len
        AND substring(pos,1,spropval)="'")
        SET pos = getstring((pos+ 1),spropval)
       ENDIF
      ENDIF
     ENDIF
     CASE (cnvtlower(stridval))
      OF "binding":
       SET sbinding = strstrval
      OF "title":
       SET stitle = strstrval
      OF "type":
       SET stype = strstrval
      OF "table":
       SET stable = strstrval
      OF "alias":
       SET salias = strstrval
      OF "format":
       SET sformat = strstrval
      OF "width":
       SET swidth = strstrval
      OF "visible":
       SET svisible = strstrval
      OF "column":
       SET scolumn = strstrval
      OF "ordinal":
       SET sordinal = strstrval
      OF "value":
       SET svalue = strstrval
     ENDCASE
     SET pos = (pos+ 1)
   ENDWHILE
   IF (cnvtlower(svalue)="true")
    SET sval = concat("*",format(sbinding,"############################## "),format(stitle,
      "############################## "),format(svisible,"##### "),format(sordinal,"### ;l"),
     format(stable,"#################### "))
   ELSE
    SET sval = concat(char(160),format(sbinding,"############################## "),format(stitle,
      "############################## "),format(svisible,"##### "),format(sordinal,"### ;l"),
     format(stable,"#################### "))
   ENDIF
   RETURN(sval)
 END ;Subroutine
 SUBROUTINE padstr(text,tbpos)
   RETURN(concat(text,substring(1,(textlen(text)+ tbpos),padding)))
 END ;Subroutine
 SUBROUTINE parsecompact(spropval)
   DECLARE sval = vc WITH notrim
   DECLARE pos = i2 WITH private
   DECLARE len = i2 WITH private
   DECLARE id = vc WITH private
   DECLARE val = vc WITH private
   SET pos = 1
   SET len = textlen(spropval)
   WHILE (pos < len)
     SET pos = skipwhitespace(pos,spropval)
     IF (pos < len)
      SET pos = getword(pos,spropval)
      SET pos = skipwhitespace(pos,spropval)
      IF (pos < len
       AND substring(pos,1,spropval)="=")
       SET pos = skipwhitespace((pos+ 1),spropval)
       IF (pos < len
        AND substring(pos,1,spropval)="'")
        SET pos = getstring((pos+ 1),spropval)
       ENDIF
      ENDIF
     ENDIF
     SET xlatedid = xlate(stridval)
     IF (trim(cnvtlower(stridval))="devices")
      SET sval = concat(sval,xlatedid,convertcode(stridval,strstrval),new_line)
     ELSEIF (trim(xlatedid,3) != ".")
      SET sval = concat(sval,xlatedid," = '",convertcode(stridval,strstrval),"'",
       new_line)
     ENDIF
     SET pos = (pos+ 1)
   ENDWHILE
   RETURN(sval)
 END ;Subroutine
 SUBROUTINE skipwhitespace(ws,str)
  WHILE (ws < textlen(str)
   AND substring(ws,1,str) <= " ")
    SET ws = (ws+ 1)
  ENDWHILE
  RETURN(ws)
 END ;Subroutine
 SUBROUTINE getstring(ws,str)
   DECLARE s = vc WITH protect, notrim
   SET s = " "
   WHILE (ws <= textlen(str)
    AND substring(ws,1,str) != "'")
    IF (substring(ws,1,str)=" ")
     SET s = concat(s,char(160))
    ELSE
     SET s = concat(s,substring(ws,1,str))
    ENDIF
    SET ws = (ws+ 1)
   ENDWHILE
   SET strstrval = replace(s,char(160)," ",0)
   RETURN((ws+ 1))
 END ;Subroutine
 SUBROUTINE getword(ws,str)
   DECLARE s = vc WITH private, notrim
   SET s = " "
   WHILE (ws <= textlen(str)
    AND  NOT (substring(ws,1,str) IN (" ", "'", "=")))
    SET s = concat(s,substring(ws,1,str))
    SET ws = (ws+ 1)
   ENDWHILE
   SET stridval = s
   RETURN(ws)
 END ;Subroutine
 SUBROUTINE addproperty(sname,sdisplay)
   SET x = (size(propitems->items,5)+ 1)
   SET stat = alterlist(propitems->items,x)
   SET propitems->items[x].name = sname
   SET propitems->items[x].value = sdisplay
   RETURN(x)
 END ;Subroutine
 SUBROUTINE settranslations(dummy)
   CALL addtranslation("GENERAL","General Control Properties")
   CALL addtranslation("PROMPT","Prompt Control")
   CALL addtranslation("PROGRAM","Global Form")
   CALL addtranslation("UPDT_DT_TM","Update Date")
   CALL addtranslation("PDL-VERSION","PDL Control Version")
   CALL addtranslation("STREAM-VER","PDL Storage Format")
   CALL addtranslation("VERSION","Form Update Count")
   CALL addtranslation("AUTO-ARRANGE","Auto Arrange")
   CALL addtranslation("TOP","Ctrl Top")
   CALL addtranslation("LEFT","Ctrl Left")
   CALL addtranslation("RIGHT","Ctrl Width")
   CALL addtranslation("BOTTOM","Ctrl Height")
   CALL addtranslation("LABEL-LEFT","Label Left")
   CALL addtranslation("EXCLUDE-RUNTIME","Prompt Only")
   CALL addtranslation("Text Properties","Text Control Properties")
   CALL addtranslation("DEFAULT-VALUE","Default Value")
   CALL addtranslation("MAX-CHAR-LEN","Maximum Characters")
   CALL addtranslation("CHAR-TYPE","Character Validation")
   CALL addtranslation("CHAR-CASE","Character Case")
   CALL addtranslation("FORMAT-CODE","Display Templates")
   CALL addtranslation("MASK","Display Mask")
   CALL addtranslation("PSW","Display Password")
   CALL addtranslation("text-attrib","Text Properties")
   CALL addtranslation("Validation","Text Control Validation")
   CALL addtranslation("db-exe","Database Source Type")
   CALL addtranslation("query-string","Query")
   CALL addtranslation("qbe-source","Query Builder Name")
   CALL addtranslation("columns","Column Definitions")
   CALL addtranslation("query-options","Query Viewer Option Code")
   CALL addtranslation("CWizDataSource","Data Source Properties")
   CALL addtranslation("querydlg","Data Source")
   CALL addtranslation("settings","Data Settings")
   CALL addtranslation("hide-search","Hide Search Button")
   CALL addtranslation("multi","Multiple Selection")
   CALL addtranslation("multi-select","Multiple Selection")
   CALL addtranslation("db-name","Object Name")
   CALL addtranslation("dual-list","Dual List Support")
   CALL addtranslation("label-columns","Label Columns")
   CALL addtranslation("multi_column","Display Multiple Columns")
   CALL addtranslation("val-reccnt","Record Count Validation")
   CALL addtranslation("select-type","Data Source From")
   CALL addtranslation("modifiable","Modifiable")
   CALL addtranslation("stored-proc","Stored Program Name")
   CALL addtranslation("default-key","Default Key Value")
   CALL addtranslation("string-table","String Table")
   CALL addtranslation("datasrc","Data Source")
   CALL addtranslation("table-header","Column Definitions")
   CALL addtranslation("CWizCodeSet","Code Set Properties")
   CALL addtranslation("CWizDateTime","Date/Time Properties")
   CALL addtranslation("date-time-attr","Date/Time")
   CALL addtranslation("DATE-CAL","Show Calendar")
   CALL addtranslation("TIME-OFFSET","Offset From Current Time")
   CALL addtranslation("TIME-ENABLE","Time Enabled")
   CALL addtranslation("TIME-SRVTM",".")
   CALL addtranslation("DATE-LONG",".")
   CALL addtranslation("date-invdate",".")
   CALL addtranslation("enable-mask","Enabled Mask")
   CALL addtranslation("time-now-input",".")
   CALL addtranslation("date-offset","Offset From Current Date")
   CALL addtranslation("date-spin","Show Date Spinner")
   CALL addtranslation("date-enable","Date Enabled")
   CALL addtranslation("output-format","Parameter Format")
   CALL addtranslation("time-rel-input","Allow Relative Time")
   CALL addtranslation("date-today",".")
   CALL addtranslation("date-srvtm",".")
   CALL addtranslation("time-spininc","Time Increment Value")
   CALL addtranslation("time-spin","Show Time Spiner")
   CALL addtranslation("time-now",".")
   CALL addtranslation("time-mode",".")
   CALL addtranslation("date-fmt",".")
   CALL addtranslation("CWizOutputDevice","Output Device Properties")
   CALL addtranslation("CHAR-TYPE","Character Validation")
   CALL addtranslation("CHAR-CASE","Character Case")
   CALL addtranslation("FORMAT-CODE","Display Templates")
   CALL addtranslation("MASK","Display Mask")
   CALL addtranslation("PSW","Display Password")
   CALL addtranslation("output-devices","Output Device")
   CALL addtranslation("devices","Default Devices:")
   CALL addtranslation("disallow-freetext","Disallow Freetext")
   CALL addtranslation("hide-browser","Hide Browser")
   CALL addtranslation("display-all","Enable Device List")
 END ;Subroutine
 SUBROUTINE convertcode(skey,svalue)
   IF (trim(skey)=".")
    RETURN("")
   ENDIF
   CASE (cnvtlower(skey))
    OF "format-code":
     CASE (cnvtint(svalue))
      OF 0:
       RETURN("none")
      OF 1:
       RETURN("User-defined")
     ENDCASE
    OF "max-char-len":
     IF (cnvtint(svalue)=0)
      RETURN("0 (< 132)")
     ELSE
      RETURN(svalue)
     ENDIF
    OF "pdl-version":
     RETURN(replace(svalue," ",".",2))
    OF "val-reccnt":
     CASE (cnvtint(svalue))
      OF 0:
       RETURN("Ignore")
      OF 1:
       RETURN("One and only one")
      OF 2:
       RETURN("One or more")
      OF 3:
       RETURN("Match None")
     ENDCASE
    OF "devices":
     RETURN(parsedevices(svalue))
    OF "script":
     IF (textlen(svalue) > 100)
      SET tl = textlen(svalue)
      SET sold = svalue
      SET svalue = " "
      FOR (i = 1 TO ((tl/ 100)+ 1) BY 100)
        SET svalue = concat(svalue,substring(i,100,sold),new_line)
      ENDFOR
      RETURN(svalue)
     ENDIF
    OF "columns":
     RETURN(parsecolumndefs(svalue))
    OF "query-string":
     RETURN(concat(svalue,new_line))
   ENDCASE
   RETURN(svalue)
 END ;Subroutine
 SUBROUTINE xlate(skey)
   SET len = size(xlatenames->items,5)
   SET skey = cnvtlower(skey)
   FOR (i = 1 TO len)
     IF ((xlatenames->items[i].name=skey))
      RETURN(xlatenames->items[i].display)
     ENDIF
   ENDFOR
   RETURN(skey)
 END ;Subroutine
 SUBROUTINE addtranslation(sname,sdisplay)
   SET x = (size(xlatenames->items,5)+ 1)
   SET stat = alterlist(xlatenames->items,x)
   SET xlatenames->items[x].name = cnvtlower(sname)
   SET xlatenames->items[x].display = sdisplay
 END ;Subroutine
 SUBROUTINE getformdef(sformname,ngroup)
   SET promptreq->programname = sformname
   SET promptreq->groupno = ngroup
   EXECUTE ccl_prompt_get_prompts  WITH replace(request,promptreq), replace(reply,promptrep)
   RETURN(size(promptrep->prompts,5))
 END ;Subroutine
END GO
