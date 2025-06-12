CREATE PROGRAM dplprot
 PROMPT
  "Printer:" = "MINE",
  "Filter:" = "N",
  "Name:" = "",
  "Programs:" = value(""),
  "Forms:" = value(""),
  "Include Details:" = "N"
  WITH outdev, fltr, frmname,
  prgs, frms, incdet
 DECLARE appendrecord(nrecno=i4) = null
 DECLARE addfield(strname=vc,strtitle=vc,visible=i2,nsize=i2) = null
 DECLARE addfieldnotitle(strname=vc,nsize=i2) = null
 DECLARE checkdataset(recno=i2,delta=i2) = null
 DECLARE expanddataset(naddrecs=i2) = null
 DECLARE initdataset(ninitrec=i2) = null
 DECLARE setfield(nrecno=i4,strfieldname=vc,strvalue=vc) = i2
 DECLARE setfieldno(nrecno=i4,nfieldno=i2,strvalue=vc) = i2
 DECLARE recordcount(dummy=i2) = i2
 DECLARE resetdataset(ntotalrecs=i4) = null
 DECLARE showfieldno(fieldno=i4,bshow=i1) = null
 DECLARE showfield(fieldname=vc,bshow=i1) = null
 DECLARE isfieldvisible(fieldname=vc) = i1
 DECLARE getfield(fieldname=vc) = i4
 DECLARE setfieldtitleno(fieldno=i4,title=vc) = null
 DECLARE setfieldtitle(fieldname=vc,title=vc) = null
 DECLARE makedataset(initreccount=i4) = null
 DECLARE setrecord(recno=i4,delta=i4) = null
 DECLARE getparameter(paramname=vc) = vc
 DECLARE getparametercount(void=i2) = i2
 DECLARE getparameterno(paramno=i2) = vc
 DECLARE parameterexist(paramname=vc) = i2
 DECLARE getparametername(paramno=i2) = vc
 DECLARE isparameterreserved(paramno=i2) = i2
 DECLARE getpdlversion(void=i2) = f4
 DECLARE setmessagebox(msg=vc) = null
 DECLARE isvalidationquery(void=i2) = i2
 DECLARE parsecommandline(cmdparam=i2) = i2
 DECLARE seteventmessage(msg=vc) = null
 DECLARE setstatus(cstatus=c1,sopname=vc,copstatus=c1) = null
 DECLARE setvalidation(bvalid=i2) = null
 DECLARE isvalid(_null=i1) = i1
 DECLARE _ccltype_int_ = i2 WITH constant(1)
 DECLARE _ccltype_real_ = i2 WITH constant(2)
 DECLARE _ccltype_char_ = i2 WITH constant(3)
 DECLARE _ccltype_blob_ = i2 WITH constant(4)
 DECLARE _ccltype_list_ = i2 WITH constant(5)
 RECORD _arguments_(
   1 parameter[*]
     2 type = i2
     2 ccltype = c2
     2 size = i2
     2 value
       3 integer = i4
       3 real = f8
       3 char = vc
       3 blob = gc
       3 list[*]
         4 value
           5 integer = i4
           5 real = f8
           5 char = vc
           5 blob = gc
 )
 SUBROUTINE setvalidation(bvalid)
   SET reply->validation = bvalid
 END ;Subroutine
 SUBROUTINE isvalid(_null)
   RETURN(reply->validation)
 END ;Subroutine
 SUBROUTINE makedataset(ini)
   SET columntitle = concat(reportinfo(1),"$")
   CALL initdataset(ini)
   CALL builddescriptors(0)
 END ;Subroutine
 SUBROUTINE setrecord(recno,delta)
  SET stat = checkdataset(recno,delta)
  SET reply->data[recno].buffer = concat(reportinfo(2),"$")
 END ;Subroutine
 SUBROUTINE showfieldno(fieldno,bshow)
   IF (fieldno > 0
    AND fieldno <= size(reply->columndesc,5))
    SET reply->columndesc[fieldno].visible = bshow
   ENDIF
 END ;Subroutine
 SUBROUTINE showfield(fieldname,bshow)
   DECLARE fld = i4
   SET fld = getfield(fieldname)
   IF (fld > 0)
    SET reply->columndesc[fld].visible = bshow
   ENDIF
 END ;Subroutine
 SUBROUTINE isfieldvisible(fieldno)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   RETURN(reply->columndesc[fieldno].visible)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE setfieldtitleno(fieldno,title)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   SET reply->columndesc[fieldno].title = title
  ENDIF
  RETURN
 END ;Subroutine
 SUBROUTINE setfieldtitle(fieldname,title)
  SET fdno = getfield(fieldname)
  CALL setfieldtitleno(fdno,title)
 END ;Subroutine
 SUBROUTINE getfield(fieldname)
   DECLARE found = i1 WITH private
   SET colcount = size(reply->columndesc,5)
   IF (colcount > 0)
    SET found = 0
    SET fieldname = trim(cnvtupper(fieldname))
    SET f = 1
    WHILE (f <= colcount
     AND found=0)
     IF (trim(reply->columndesc[f].name)=fieldname)
      SET fld = f
      SET found = 1
     ENDIF
     SET f = (f+ 1)
    ENDWHILE
    IF (found)
     RETURN((f - 1))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE setfield(nrecno,strfieldname,strvalue)
   DECLARE colcount = i2 WITH private
   DECLARE found = i1 WITH private
   DECLARE fld = i2 WITH private
   DECLARE txtbuffer = vc WITH notrim, private
   DECLARE r = i2 WITH private
   DECLARE f = i2 WITH private
   DECLARE ptr = i2 WITH private
   DECLARE len = i2 WITH private
   SET colcount = size(reply->columndesc,5)
   IF (colcount > 0)
    SET found = 0
    SET strfieldname = trim(cnvtupper(strfieldname))
    SET f = 1
    WHILE (f <= colcount
     AND found=0)
     IF (trim(reply->columndesc[f].name)=strfieldname)
      SET fld = f
      SET found = 1
     ENDIF
     SET f = (f+ 1)
    ENDWHILE
    IF (found=1)
     SET ptr = (reply->columndesc[fld].offset+ 1)
     SET len = reply->columndesc[fld].length
     SET txtbuffer = reply->data[nrecno].buffer
     SET r = ((size(txtbuffer) - (ptr+ len))+ 1)
     SET txtbuffer = concat(substring(1,(ptr - 1),txtbuffer),strvalue,substring((ptr+ len),r,
       txtbuffer),char(160))
     SET reply->data[nrecno].buffer = substring(1,(reply->recordlength+ 1),txtbuffer)
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE setfieldno(nrecno,fieldno,strvalue)
   DECLARE field = vc WITH notrim, private
   DECLARE txtbuffer = vc WITH notrim, private
   DECLARE colcount = i2 WITH private
   DECLARE r = i2 WITH private
   DECLARE ptr = i2 WITH private
   DECLARE len = i2 WITH private
   IF (fieldno > 0
    AND fieldno <= size(reply->columndesc,5))
    SET ptr = (reply->columndesc[fieldno].offset+ 1)
    SET len = reply->columndesc[fieldno].length
    SET txtbuffer = reply->data[nrecno].buffer
    SET r = (size(txtbuffer) - (ptr+ len))
    FOR (i = 1 TO len)
      IF (i <= textlen(strvalue))
       SET field = concat(field,substring(i,1,strvalue))
      ELSE
       SET field = concat(field,char(160))
      ENDIF
    ENDFOR
    SET txtbuffer = concat(substring(1,(ptr - 1),txtbuffer),replace(field,char(160),char(32),0),
     substring((ptr+ len),r,txtbuffer),char(160))
    SET reply->data[nrecno].buffer = txtbuffer
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE expanddataset(naddrecs)
  SET nsize = (size(reply->data,5)+ naddrecs)
  SET stat = alterlist(reply->data,nsize)
 END ;Subroutine
 SUBROUTINE checkdataset(recno,delta)
   IF (recno >= recordcount(0))
    WHILE (recno >= recordcount(0))
      CALL expanddataset(delta)
    ENDWHILE
   ENDIF
 END ;Subroutine
 SUBROUTINE addfield(strname,strtitle,visible,nsize)
   SET reclen = reply->recordlength
   SET ncolcnt = (size(reply->columndesc,5)+ 1)
   SET stat = alterlist(reply->columndesc,ncolcnt)
   SET reply->columndesc[ncolcnt].name = trim(cnvtupper(strname))
   SET reply->columndesc[ncolcnt].title = strtitle
   SET reply->columndesc[ncolcnt].visible = visible
   SET reply->columndesc[ncolcnt].offset = reclen
   SET reply->columndesc[ncolcnt].length = nsize
   SET reply->recordlength = (reply->recordlength+ nsize)
 END ;Subroutine
 SUBROUTINE addfieldnotitle(strname,nsize)
   SET createdataset = 0
   SET reclen = reply->recordlength
   SET ncolcnt = (size(reply->columndesc,5)+ 1)
   SET stat = alterlist(reply->columndesc,ncolcnt)
   SET reply->columndesc[ncolcnt].name = trim(cnvtupper(strname))
   SET reply->columndesc[ncolcnt].offset = reclen
   SET reply->columndesc[ncolcnt].length = nsize
   SET reply->recordlength = (reply->recordlength+ nsize)
 END ;Subroutine
 SUBROUTINE initdataset(ninitrec)
   SET stat = alterlist(reply->columndesc,0)
   SET stat = alterlist(reply->context,0)
   SET stat = alterlist(reply->misc,0)
   SET stat = alterlist(reply->data,ninitrec)
 END ;Subroutine
 SUBROUTINE resetdataset(ntotalrecs)
   SET stat = alterlist(reply->data,ntotalrecs)
 END ;Subroutine
 SUBROUTINE appendrecord(nrecno)
   DECLARE txtbuffer = vc WITH notrim
   SET txtbuffer = char(160)
   FOR (i = 2 TO reply->recordlength)
     SET txtbuffer = concat(txtbuffer,char(160))
   ENDFOR
   SET txtbuffer = concat(txtbuffer,char(160))
   SET txtbuffer = replace(txtbuffer,char(160),char(32),0)
   SET reply->data[nrecno].buffer = txtbuffer
 END ;Subroutine
 SUBROUTINE recordcount(dummy)
   DECLARE cnt = i2 WITH private
   SET cnt = size(reply->data,5)
   RETURN(cnvtint(cnt))
 END ;Subroutine
 SUBROUTINE getparameter(paramname)
   DECLARE pndx = i2 WITH private
   SET pndx = parameterexist(paramname)
   IF (pndx > 0)
    RETURN(request->parameters[pndx].value)
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE getparameterno(paramno)
  IF (paramno > 0
   AND paramno <= size(request->parameters,5))
   RETURN(request->parameters[paramno].value)
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE parameterexist(paramname)
   DECLARE cnt = i2 WITH private
   SET cnt = size(request->parameters,5)
   SET paramname = trim(cnvtupper(paramname))
   FOR (i = 1 TO cnt)
     IF (paramname=trim(cnvtupper(request->parameters[i].name)))
      RETURN(i)
     ENDIF
   ENDFOR
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getparametername(paramno)
   RETURN(request->parameters[paramno].name)
 END ;Subroutine
 SUBROUTINE isparameterreserved(paramno)
   DECLARE sname = vc WITH private
   SET sname = cnvtupper(trim(getparametername(paramno)))
   IF (sname="_DPL_VERSION_")
    RETURN(true)
   ELSEIF (sname="_VALIDATE_")
    RETURN(true)
   ELSEIF (sname="_DEBUG_")
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE getpdlversion(void)
   DECLARE sverstr = vc WITH private
   SET sverstr = getparameter("_DPL_VERSION_")
   IF (textlen(sverstr) > 0)
    RETURN(cnvtreal(sverstr))
   ENDIF
   RETURN(0001.0001)
 END ;Subroutine
 SUBROUTINE isvalidationquery(void)
   DECLARE svalflag = vc
   SET svalflag = getparameter("_VALIDATE_")
   IF (trim(svalflag)="1")
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE getparametercount(void)
   RETURN(size(request->parameters,5))
 END ;Subroutine
 SUBROUTINE setmessagebox(msg)
  SET reply->status_data.subeventstatus[1].targetobjectname = "MSGBOX"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = msg
 END ;Subroutine
 SUBROUTINE setstatus(cstatus,sopname,copstatus)
   SET reply->status_data.status = cstatus
   SET reply->status_data.subeventstatus[1].operationname = sopname
   SET reply->status_data.subeventstatus[1].operationstatus = copstatus
 END ;Subroutine
 SUBROUTINE seteventmessage(msg)
   SET reply->error_msg = concat(trim(reply->error_msg),trim(msg),";")
 END ;Subroutine
 SUBROUTINE parsecommandline(cmdparam)
   DECLARE arg = i2 WITH private
   DECLARE argtype = c20 WITH private
   DECLARE argval = vc WITH private
   DECLARE done = i1 WITH private, noconstant(0)
   SET arg = 1
   WHILE (done=0)
    SET argtype = reflect(parameter(arg,0))
    IF (argtype != " ")
     SET arg = (arg+ 1)
    ELSE
     SET done = 1
     SET arg = (arg - 1)
    ENDIF
   ENDWHILE
   RETURN(arg)
 END ;Subroutine
 SUBROUTINE builddescriptors(void)
   DECLARE node = i2 WITH noconstant(0)
   DECLARE charpos = i4 WITH noconstant(1)
   DECLARE fldstart = i4 WITH noconstant(1)
   DECLARE fldend = i4 WITH noconstant(1)
   DECLARE fldname = vc
   SET strlen = size(columntitle)
   SET reply->recordlength = strlen
   WHILE (charpos <= strlen)
     SET node = (node+ 1)
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
   SET createdataset = 0
 END ;Subroutine
 IF (cnvtlower( $OUTDEV)="/nodevice:i"
  AND cnvtlower( $FLTR)="n")
  IF (trim( $FRMNAME) > " ")
   SELECT INTO "nl:"
    d.object_name, d.group, d.user_name,
    d.app_major_version, d.app_minor_version, d.ccl_version,
    d.timestamp, d.source_name
    FROM dprotect d
    PLAN (d
     WHERE d.object="P"
      AND d.object_name=patstring(cnvtupper( $FRMNAME)))
    ORDER BY d.object_name, d.group
    HEAD REPORT
     delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
     stat = alterlist(reply->data,delta)
    DETAIL
     count = (count+ 1)
     IF (mod(count,delta)=1)
      stat = alterlist(reply->data,(count+ delta))
     ENDIF
     reply->data[count].buffer = concat(reportinfo(2),"$")
    FOOT REPORT
     stat = alterlist(reply->data,count)
     IF (count=0)
      CALL setmessagebox(concat("No items found for ", $FRMNAME))
     ENDIF
    WITH maxrow = 1, reporthelp, check
   ;end select
  ENDIF
 ELSEIF (cnvtlower( $OUTDEV)="/nodevice:f"
  AND cnvtlower( $FLTR)="n")
  IF (trim( $FRMNAME) > " ")
   SELECT INTO "nl:"
    cpd.program_name, cpd.group_no, author = p.name_full_formatted,
    cpd.updt_cnt, cpd.updt_dt_tm
    FROM ccl_prompt_definitions cpd,
     person p
    PLAN (cpd
     WHERE cpd.program_name=patstring(cnvtupper( $FRMNAME))
      AND cpd.position=0)
     JOIN (p
     WHERE p.person_id=cpd.updt_id)
    ORDER BY cpd.program_name, cpd.group_no
    HEAD REPORT
     delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
     stat = alterlist(reply->data,delta)
    DETAIL
     count = (count+ 1)
     IF (mod(count,delta)=1)
      stat = alterlist(reply->data,(count+ delta))
     ENDIF
     reply->data[count].buffer = concat(reportinfo(2),"$")
    FOOT REPORT
     stat = alterlist(reply->data,count)
    WITH maxrow = 1, reporthelp, check
   ;end select
  ENDIF
 ELSEIF (cnvtlower( $OUTDEV)="/nodevice:i"
  AND cnvtlower( $FLTR)="o")
  IF (trim( $FRMNAME) > " ")
   SELECT INTO "nl:"
    d.object_name, d.group, d.user_name,
    d.app_major_version, d.app_minor_version, d.ccl_version,
    d.timestamp, d.source_name
    FROM dprotect d
    PLAN (d
     WHERE d.object="P"
      AND d.user_name=patstring(cnvtupper( $FRMNAME)))
    ORDER BY d.object_name, d.group
    HEAD REPORT
     delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
     stat = alterlist(reply->data,delta)
    DETAIL
     count = (count+ 1)
     IF (mod(count,delta)=1)
      stat = alterlist(reply->data,(count+ delta))
     ENDIF
     reply->data[count].buffer = concat(reportinfo(2),"$")
    FOOT REPORT
     stat = alterlist(reply->data,count)
     IF (count=0)
      CALL setmessagebox(concat("No items found for ", $FRMNAME))
     ENDIF
    WITH maxrow = 1, reporthelp, check
   ;end select
  ENDIF
 ELSEIF (cnvtlower( $OUTDEV)="/nodevice:f"
  AND cnvtlower( $FLTR)="o")
  IF (trim( $FRMNAME) > " ")
   SELECT INTO "nl:"
    cpd.program_name, cpd.group_no, author = p.name_full_formatted,
    cpd.updt_cnt, cpd.updt_dt_tm
    FROM ccl_prompt_definitions cpd,
     person p,
     prsnl
    PLAN (prsnl
     WHERE prsnl.username=patstring(cnvtupper( $FRMNAME)))
     JOIN (p
     WHERE p.person_id=prsnl.person_id)
     JOIN (cpd
     WHERE cpd.updt_id=p.person_id
      AND cpd.position=0)
    ORDER BY cpd.program_name, cpd.group_no
    HEAD REPORT
     delta = 1000, columntitle = concat(reportinfo(1),"$"), count = 0,
     stat = alterlist(reply->data,delta)
    DETAIL
     count = (count+ 1)
     IF (mod(count,delta)=1)
      stat = alterlist(reply->data,(count+ delta))
     ENDIF
     reply->data[count].buffer = concat(reportinfo(2),"$")
    FOOT REPORT
     stat = alterlist(reply->data,count)
    WITH maxrow = 1, reporthelp, check
   ;end select
  ENDIF
 ELSE
  RECORD dicprotect_rec FROM dic,dicprotect,dicprotect
  SET max_group = 10
  IF (( $4 != "y"))
   SET max_group = 3
  ENDIF
  SELECT INTO  $OUTDEV
   group = p.group, p.binary_cnt, p.ccl_version,
   p.app_minor_version, p.app_major_version, app_ocdmajor =
   IF (p.app_minor_version > 900000) mod(p.app_minor_version,1000000)
   ELSE p.app_minor_version
   ENDIF
   ,
   app_ocdminor =
   IF (p.app_minor_version > 900000) cnvtint((p.app_minor_version/ 1000000.0))
   ELSE 0
   ENDIF
   , object_name = p.object_name, object_break = concat(p.object,p.object_name),
   p.object, p.source_name, p.user_name,
   p.datestamp, p.timestamp, updt_id =
   IF (p.ccl_version >= 2) 0.0
   ELSE 0.0
   ENDIF
   ,
   updt_task =
   IF (p.ccl_version >= 2) validate(p.updt_task,0)
   ELSE 0
   ENDIF
   , updt_applctx =
   IF (p.ccl_version >= 2) validate(p.updt_applctx,0)
   ELSE 0
   ENDIF
   , cpd.program_name,
   cpd.group_no, cpd.updt_id, cpd.updt_cnt,
   cpd.updt_dt_tm, prsnl.username, cpg.program_name
   FROM dprotect p,
    (dummyt dt  WITH seq = p.seq),
    ccl_prompt_definitions cpd,
    prsnl,
    (dummyt dtf  WITH seq = 1),
    ccl_prompt_file cpf
   PLAN (p
    WHERE p.object="P"
     AND (((p.object_name= $PRGS)) OR ((p.object_name= $FRMS))) )
    JOIN (dt)
    JOIN (cpd
    WHERE cpd.program_name=p.object_name)
    JOIN (prsnl
    WHERE prsnl.person_id=cpd.updt_id)
    JOIN (dtf)
    JOIN (cpf
    WHERE cnvtupper(cpf.folder_name)=concat("/PDDOC/GROUP",trim(cnvtstring(cpd.group_no)),"/")
     AND cnvtupper(cpf.file_name)=cpd.program_name)
   ORDER BY object_break, p.object_name, p.group,
    cpd.group_no
   HEAD REPORT
    line = fillstring(130,"-"), last_group = 0
   HEAD PAGE
    "object", col 35, "group",
    col 41, "type", col 46,
    "owner", col 55, "size",
    col 65, "app_ver", col 78,
    "ccl_ver", col 86, "date    time",
    col 105, "(0 to ", max_group"##",
    " protection)", row + 1, col 46,
    "(e)xecute (s)elect (r)ead (w)rite (d)elete (i)nsert (u)pdate", row + 1, line,
    row + 1
   HEAD object_break
    object_name, last_group = group
   HEAD group
    newgrp = 1
    IF (last_group != group)
     row + 1, "<dup warning>"
    ENDIF
    IF (cpd.group_no=0)
     acclvl = "DBA"
    ELSE
     acclvl = build(cpd.group_no)
    ENDIF
    col 35, acclvl, col 44,
    p.object
    IF (p.datestamp BETWEEN 69000 AND curdate)
     new_format = 1, col 46, p.user_name,
     col 55, p.binary_cnt"######", col 65,
     CALL print(build(p.app_major_version,".",app_ocdmajor,".",app_ocdminor)), col 78, p.ccl_version
     "######",
     col 86, p.datestamp"ddmmmyy;;d", " ",
     p.timestamp"hh:mm:ss;2;m"
    ELSE
     new_format = 0
    ENDIF
   DETAIL
    IF (newgrp=1)
     newgrp = 0, stat = moverec(p.seq,dicprotect_rec), scol = 95
     FOR (gnum = 0 TO max_group)
      permit_info = dicprotect_rec->groups[(gnum+ 1)].permit_info,
      IF (permit_info != 0)
       IF (scol >= 125)
        row + 1, scol = 55
       ELSE
        scol = (scol+ 8)
       ENDIF
       col scol, gnum"##:"
       IF (permit_info=255)
        "all"
       ELSE
        IF (btest(permit_info,0)=1)
         "s"
        ENDIF
        IF (btest(permit_info,1)=1)
         "r"
        ENDIF
        IF (btest(permit_info,2)=1)
         "e"
        ENDIF
        IF (btest(permit_info,3)=1)
         "w"
        ENDIF
        IF (btest(permit_info,4)=1)
         "d"
        ENDIF
        IF (btest(permit_info,5)=1)
         "i"
        ENDIF
        IF (btest(permit_info,6)=1)
         "u"
        ENDIF
       ENDIF
      ENDIF
     ENDFOR
     row + 1
    ENDIF
   FOOT  cpd.group_no
    IF (cpd.program_name > " "
     AND ((cpd.group_no=0) OR (cpd.group_no=p.group)) )
     IF (cpd.group_no=0)
      acclvl = "DBA"
     ELSE
      acclvl = build(cpd.group_no)
     ENDIF
     col 5,
     CALL print(concat("Form with access level = ",acclvl," owned by ",build(prsnl.username),
      " last updated on ",
      format(cpd.updt_dt_tm,"dd-mmm-yyyy @ hh:mm:ss;;q")))
     IF (check(cpf.file_name) > " ")
      " with user documentation"
     ENDIF
     row + 1
    ENDIF
   FOOT  object_break
    IF (( $INCDET="Y"))
     IF (new_format=1)
      col 5,
      CALL print(build("source=",check(p.source_name)))
     ELSE
      col 5,
      CALL print(build("source=",substring(1,31,check(p.source_name))))
     ENDIF
     col 95, "id=", updt_id"#########",
     col + 1, "task=", updt_task"#########",
     col + 1, "app=", updt_applctx"#########",
     row + 1
    ENDIF
    row + 1
   WITH format, maxcol = 140, nocounter,
    outerjoin = p
  ;end select
 ENDIF
END GO
