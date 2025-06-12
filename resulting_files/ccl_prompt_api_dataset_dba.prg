CREATE PROGRAM ccl_prompt_api_dataset:dba
 PROMPT
  "ctx option #1" = "-",
  "ctx option #2" = "-",
  "ctx option #3" = "-",
  "ctx option #4" = "-",
  "ctx option #5" = "-",
  "ctx option #6" = "-"
  WITH ctx1, ctx2, ctx3,
  ctx4, ctx5, ctx6
 IF (validate(_ccl_prompt_api_dataset_,0)=0)
  DECLARE _ccl_prompt_api_dataset_ = i1 WITH constant(1), persistscript
  DECLARE i2_std_size = i2 WITH constant(8), persistscript
  DECLARE i4_std_size = i2 WITH constant(14), persistscript
  DECLARE i8_std_size = i2 WITH constant(20), persistscript
  DECLARE f4_std_size = i2 WITH constant(12), persistscript
  DECLARE f8_std_size = i2 WITH constant(16), persistscript
  DECLARE dq_std_size = i2 WITH constant(20), persistscript
  DECLARE _ccltype_undef_ = i2 WITH constant(0), persistscript
  DECLARE _ccltype_int_ = i2 WITH constant(1), persistscript
  DECLARE _ccltype_real_ = i2 WITH constant(2), persistscript
  DECLARE _ccltype_char_ = i2 WITH constant(3), persistscript
  DECLARE _ccltype_blob_ = i2 WITH constant(4), persistscript
  DECLARE _ccltype_list_ = i2 WITH constant(5), persistscript
  DECLARE _ccltype_date_ = i2 WITH constant(6), persistscript
  DECLARE _ccltype_string_ = i2 WITH constant(7), persistscript
  DECLARE _mb_none_ = c2 WITH constant("0"), persistscript
  DECLARE _mb_info_ = c2 WITH constant("1"), persistscript
  DECLARE _mb_warn_ = c2 WITH constant("2"), persistscript
  DECLARE _mb_error_ = c2 WITH constant("3"), persistscript
  DECLARE _mb_question_ = c2 WITH constant("4"), persistscript
  DECLARE mb_none = c2 WITH constant("0"), persistscript
  DECLARE mb_info = c2 WITH constant("1"), persistscript
  DECLARE mb_warning = c2 WITH constant("2"), persistscript
  DECLARE mb_error = c2 WITH constant("3"), persistscript
  DECLARE mb_question = c2 WITH constant("4"), persistscript
  DECLARE _in_ = i2 WITH constant(0), persistscript
  DECLARE _out_ = i2 WITH constant(1), persistscript
 ENDIF
 DECLARE setstatus(cstatus=c1) = i1 WITH copy
 DECLARE getstatus(void=i2) = c1 WITH copy
 DECLARE setmessagebox(msg=vc) = i1 WITH copy
 DECLARE setmessageboxex(msg=vc,title=vc,icon=c2) = i1 WITH copy
 DECLARE ctx = vc WITH private
 FOR (arg = 1 TO 6)
  CASE (arg)
   OF 1:
    SET ctx =  $CTX1
   OF 2:
    SET ctx =  $CTX2
   OF 3:
    SET ctx =  $CTX3
   OF 4:
    SET ctx =  $CTX4
   OF 5:
    SET ctx =  $CTX5
   OF 6:
    SET ctx =  $CTX6
  ENDCASE
  IF (ctx != "-")
   IF (cnvtlower(trim(ctx))="all")
    SET ccl_prompt_api_autoset = 1
    SET ccl_prompt_api_dataset = 1
    SET ccl_prompt_api_context = 1
    SET ccl_prompt_api_misc = 1
    SET ccl_prompt_api_argument = 1
    SET ccl_prompt_api_parameter = 1
    SET ccl_prompt_api_advapi = 1
   ELSE
    CASE (trim(cnvtlower(ctx)))
     OF "autoset":
      SET ccl_prompt_api_autoset = 1
     OF "noautoset":
      SET ccl_prompt_api_autoset = 0
     OF "dataset":
      SET ccl_prompt_api_dataset = 1
     OF "nodataset":
      SET ccl_prompt_api_dataset = 0
     OF "context":
      SET ccl_prompt_api_context = 1
     OF "nocontext":
      SET ccl_prompt_api_context = 0
     OF "misc":
      SET ccl_prompt_api_misc = 1
     OF "nomisc":
      SET ccl_prompt_api_misc = 0
     OF "argument":
      SET ccl_prompt_api_argument = 1
     OF "noargument":
      SET ccl_prompt_api_noargument = 0
     OF "noparameter":
      SET ccl_prompt_api_parameter = 0
     OF "parameter":
      SET ccl_prompt_api_parameter = 1
     OF "disable":
      SET ccl_prompt_api_disable = 1
     OF "test":
      SET ccl_prompt_api_test = 1
     OF "srv":
      SET ccl_prompt_api_srv = 1
     OF "advapi":
      SET ccl_prompt_api_advapi = 1
     OF "noadvapi":
      SET ccl_prompt_api_advapi = 0
    ENDCASE
   ENDIF
  ENDIF
 ENDFOR
 IF (validate(ccl_prompt_api_disable,0)=0)
  DECLARE getdplversion(void=i1) = f4 WITH copy
  DECLARE getmajorversion(void=i1) = i2 WITH copy
  DECLARE getminorversion(void=i1) = i2 WITH copy
  DECLARE isvalidationquery(void=i2) = i2 WITH copy
  DECLARE resetdataset(ntotalrecs=i4) = i1 WITH copy
  DECLARE checkdataset(recno=i2,delta=i2) = i1 WITH copy
  DECLARE expanddataset(naddrecs=i2) = i1 WITH copy
  DECLARE makedataset(initreccount=i4) = i1 WITH copy
  DECLARE recordcount(dummy=i2) = i4 WITH copy
  DECLARE appendrecord(nrecno=i4) = i1 WITH copy
  DECLARE parameterexist(paramname=vc) = i2 WITH copy
  DECLARE getparameter(paramname=vc) = vc WITH copy
  DECLARE initdataset(ninitrec=i4) = i1 WITH copy
  DECLARE closedataset(_null=i1) = i1 WITH copy
  DECLARE setvalidation(bvalid=i2) = i1 WITH copy
  DECLARE isvalid(void=i2) = i2 WITH copy
  DECLARE isdebugmode(void=i2) = i2 WITH copy
  DECLARE isdesignmode(void=i2) = i2 WITH copy
  IF (validate(ccl_prompt_api_autoset,1) > 0)
   DECLARE writerecord(void=i2) = i1 WITH copy
   DECLARE setrecord(recno=i4,delta=i4) = null WITH copy
   DECLARE builddescriptors(void=i1) = i1 WITH copy
   DECLARE checkduplicates(fldname=vc) = vc WITH copy
   DECLARE parsefieldname(at_pos=i2) = i1 WITH copy
   DECLARE skipwhitespace(at_pos=i2) = i1 WITH copy
  ENDIF
  IF (validate(ccl_prompt_api_dataset,0) > 0)
   DECLARE checkfield(recno=i4,fieldno=i2) = i1 WITH copy
   DECLARE getfieldcount(_null=i2) = i2 WITH copy
   DECLARE showfieldno(fieldno=i2,bshow=i1) = i1 WITH copy
   DECLARE showfield(fieldname=vc,bshow=i1) = i1 WITH copy
   DECLARE isfieldvisible(fieldno=i2) = i1 WITH copy
   DECLARE findfield(fieldname=vc) = i2 WITH copy
   DECLARE getfieldname(fieldno=i2) = vc WITH copy
   DECLARE getintegerfield(recno=i4,fieldno=i2) = i4 WITH copy
   DECLARE getrealfield(recno=i4,fieldno=i2) = f8 WITH copy
   DECLARE getdatefield(recno=i4,fieldno=i2) = f8 WITH copy
   DECLARE getstringfield(recno=i4,fieldno=i2) = vc WITH copy, notrim
   DECLARE getfieldtitle(fieldno=i4) = vc WITH copy
   DECLARE setfieldtitleno(fieldno=i4,title=vc) = i1 WITH copy
   DECLARE setfieldtitle(fieldname=vc,title=vc) = i1 WITH copy
   DECLARE getcurrecord(dummy=i1) = i4 WITH copy
   DECLARE formatrecord(nrecno=i4) = i1 WITH copy
   DECLARE addfield(strname=vc,strtitle=vc,visible=i2,nsize=i2) = i4 WITH copy
   DECLARE addstringfield(strname=vc,strtitle=vc,visible=i2,nmaxchar=i2) = i4 WITH copy
   DECLARE addintegerfield(strname=vc,strtitle=vc,visible=i2) = i4 WITH copy
   DECLARE addrealfield(strname=vc,strtitle=vc,visible=i2) = i4 WITH copy
   DECLARE adddatefield(strname=vc,strtitle=vc,visible=i2) = i4 WITH copy
   DECLARE setfield(nrecno=i4,strfieldname=vc,strvalue=vc) = i1 WITH copy
   DECLARE setfieldno(nrecno=i4,nfieldno=i2,strvalue=vc) = i1 WITH copy
   DECLARE setstringfield(nrecno=i4,nfieldno=i2,value=vc) = i1 WITH copy
   DECLARE setintegerfield(nrecno=i4,nfieldno=i2,value=i4) = i1 WITH copy
   DECLARE setrealfield(nrecno=i4,nfieldno=i2,value=f8) = i1 WITH copy
   DECLARE setdatefield(nrecno=i4,nfieldno=i2,value=f8) = i1 WITH copy
   DECLARE getnextrecord(void=i1) = i4 WITH copy
  ENDIF
 ENDIF
 IF (validate(ccl_prompt_api_context,0) > 0)
  DECLARE setcontextrecord(recno=i4,data=vc) = i1 WITH copy
  DECLARE getcontextrecord(recno=i4) = vc WITH copy
  DECLARE getcontextcount(null=i2) = i4 WITH copy
  DECLARE setcontextsize(n=i4) = i1 WITH copy
 ENDIF
 IF (validate(ccl_prompt_api_misc,0) > 0)
  DECLARE setmiscrecord(which=i2,recno=i4,data=vc) = i1 WITH copy
  DECLARE getmiscrecord(which=i2,recno=i4) = vc WITH copy
  DECLARE getmisccount(which=i2) = i4 WITH copy
  DECLARE setmiscsize(which=i2,n=i4) = i1 WITH copy
 ENDIF
 IF (validate(ccl_prompt_api_parameter,0) > 0)
  DECLARE getparametercount(void=i2) = i2 WITH copy
  DECLARE getparameterno(paramno=i2) = vc WITH copy
  DECLARE getparametername(paramno=i2) = vc WITH copy
  DECLARE isparameterreserved(paramno=i2) = i2 WITH copy
 ENDIF
 IF (validate(ccl_prompt_api_argument,0) > 0)
  DECLARE getargumentcount(void=i2) = i2 WITH copy
  DECLARE getargumenttype(argno=i2) = vc WITH copy
  DECLARE getargumentvalue(argno=i2) = vc WITH copy
  DECLARE getargumentsize(argno=i2) = i2 WITH copy
  DECLARE getargumentlistcount(argno=i2) = i2 WITH copy
  DECLARE getargumentlistvalue(argno=i2) = vc WITH copy
  DECLARE getargumentlistitemtype(argno=i2,itemno=i2) = vc WITH copy
  DECLARE getargumentlistitemvalue(argno=i2,itemno=i2) = vc WITH copy
  DECLARE getargumentlistitemsize(argno=i2,itemno=i2) = i2 WITH copy
  DECLARE parsecommandline(void=i2) = i1 WITH copy
 ENDIF
 IF (validate(ccl_prompt_api_advapi,0) > 0)
  DECLARE adddefaultkey(keyvalue=vc) = i2 WITH copy
  DECLARE setkeyfield(fieldno=i2,keyflag=i2) = i2 WITH copy
  DECLARE iskeyfield(fieldno=i2) = i2 WITH copy
 ENDIF
 IF (validate(ccl_prompt_api_test,0) > 0)
  IF ((validate(totalerrors,- (1))=- (1)))
   DECLARE totalerrors = i2 WITH noconstant(0), persistscript
   DECLARE testcount = i2 WITH noconstant(0), persistscript
   DECLARE runresult = i2 WITH noconstant(0), persistscript
   DECLARE runcomplete = i2 WITH noconstant(0), persistscript
  ENDIF
  DECLARE addparameter(parname=vc,parvalue=vc,partype=i2) = i2 WITH copy
  DECLARE clearparameters(void=i2) = null WITH copy
  DECLARE clearreply(void=i2) = null WITH copy
  DECLARE clearrequest(void=i2) = null WITH copy
  DECLARE run(qry=vc) = c1 WITH copy
  DECLARE runvalidation(qry=vc) = i2 WITH copy
  DECLARE start(tst=vc) = null WITH copy
  DECLARE done(tst=vc,status=c1) = null WITH copy
  DECLARE fail(tst=vc) = null WITH copy
  DECLARE reporttestresults(void=i2) = null WITH copy
 ENDIF
 IF (validate(ccl_prompt_api_srv,0) > 0
  AND validate(request->query,"N")="N")
  FREE RECORD request
  RECORD request(
    1 query = vc
    1 parameters[*]
      2 name = vc
      2 value = vc
      2 datatype = i2
    1 context[*]
      2 value = vc
    1 misc[*]
      2 value = vc
    1 options[*]
      2 option = vc
    1 returndata = i2
  ) WITH persistscript
  FREE RECORD reply
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
 IF ((validate(_utilruntime->currec,- (1))=- (1)))
  RECORD _utilruntime(
    1 currec = i4
    1 expanddelta = i4
    1 settype = i2
    1 columndesc[*]
      2 columntype = i2
    1 argument[*]
      2 type = vc
      2 length = i2
      2 value = vc
      2 listvalue = vc
      2 list[*]
        3 type = vc
        3 length = i2
        3 value = vc
  ) WITH persistscript
 ENDIF
 SET _utilruntime->currec = 0
 SET _utilruntime->expanddelta = 1
 SUBROUTINE initdataset(ninitrec)
   DECLARE stat = i2 WITH protect
   SET createdataset = 0
   SET stat = setstatus("F")
   SET stat = alterlist(reply->columndesc,0)
   SET stat = alterlist(reply->misc,0)
   SET stat = alterlist(reply->data,ninitrec)
   SET stat = alterlist(_utilruntime->columndesc,0)
   SET _utilruntime->currec = 0
   SET _utilruntime->expanddelta = ninitrec
   SET _utilruntime->settype = 0
   SET reply->recordlength = 0
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getnextrecord(void)
   DECLARE stat = i2 WITH protect
   SET _utilruntime->currec = (_utilruntime->currec+ 1)
   IF ((_utilruntime->currec > size(reply->data,5)))
    SET stat = alterlist(reply->data,(size(reply->data,5)+ _utilruntime->expanddelta))
   ENDIF
   SET stat = formatrecord(_utilruntime->currec)
   RETURN(_utilruntime->currec)
 END ;Subroutine
 SUBROUTINE addfield(strname,strtitle,visible,nsize)
   DECLARE reclen = i2 WITH protect
   DECLARE ncolcnt = i2 WITH protect
   DECLARE stat = i2 WITH protect
   SET reclen = reply->recordlength
   SET ncolcnt = (size(reply->columndesc,5)+ 1)
   SET stat = alterlist(reply->columndesc,ncolcnt)
   SET reply->columndesc[ncolcnt].name = trim(cnvtupper(strname))
   SET reply->columndesc[ncolcnt].title = strtitle
   SET reply->columndesc[ncolcnt].visible = visible
   SET reply->columndesc[ncolcnt].offset = reclen
   SET reply->columndesc[ncolcnt].length = nsize
   SET reply->recordlength = (reply->recordlength+ nsize)
   SET stat = alterlist(_utilruntime->columndesc,ncolcnt)
   SET _utilruntime->columndesc[ncolcnt].columntype = _ccltype_undef_
   RETURN(ncolcnt)
 END ;Subroutine
 SUBROUTINE addstringfield(strname,strtitle,visible,maxsize)
   DECLARE ncolcnt = i2 WITH protect
   SET ncolcnt = addfield(strname,strtitle,visible,maxsize)
   SET _utilruntime->columndesc[ncolcnt].columntype = _ccltype_string_
   RETURN(ncolcnt)
 END ;Subroutine
 SUBROUTINE addintegerfield(strname,strtitle,visible)
   DECLARE ncolcnt = i2 WITH protect
   SET ncolcnt = addfield(strname,strtitle,visible,i4_std_size)
   SET _utilruntime->columndesc[ncolcnt].columntype = _ccltype_int_
   RETURN(ncolcnt)
 END ;Subroutine
 SUBROUTINE addrealfield(strname,strtitle,visible)
   DECLARE ncolcnt = i2 WITH protect
   SET ncolcnt = addfield(strname,strtitle,visible,f8_std_size)
   SET _utilruntime->columndesc[ncolcnt].columntype = _ccltype_real_
   RETURN(ncolcnt)
 END ;Subroutine
 SUBROUTINE adddatefield(strname,strtitle,visible)
   DECLARE ncolcnt = i2 WITH protect
   SET ncolcnt = addfield(strname,strtitle,visible,dq_std_size)
   SET _utilruntime->columndesc[ncolcnt].columntype = _ccltype_date_
   RETURN(ncolcnt)
 END ;Subroutine
 SUBROUTINE setfield(nrecno,strfieldname,strvalue)
   DECLARE colcount = i2 WITH protect
   DECLARE found = i1 WITH protect
   DECLARE fld = i2 WITH protect
   DECLARE txtbuffer = vc WITH notrim, protect
   DECLARE r = i2 WITH protect
   DECLARE f = i2 WITH protect
   DECLARE ptr = i2 WITH protect
   DECLARE len = i2 WITH protect
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
     RETURN(setfieldno(nrecno,fld,strvalue))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE setfieldno(nrecno,fieldno,strvalue)
   DECLARE txtbuffer = vc WITH protect, notrim
   DECLARE txtfront = vc WITH protect, notrim
   DECLARE txtrear = vc WITH protect, notrim
   DECLARE field = vc WITH notrim, protect
   DECLARE len = i4 WITH protect
   DECLARE offset = i4 WITH protect
   DECLARE txtlen = i2 WITH protect
   DECLARE tailoffset = i4 WITH protect
   IF (fieldno > 0
    AND fieldno <= size(reply->columndesc,5))
    SET offset = reply->columndesc[fieldno].offset
    SET len = reply->columndesc[fieldno].length
    SET tailoffset = ((offset+ len)+ 1)
    SET txtbuffer = notrim(reply->data[nrecno].buffer)
    SET txtfront = " "
    SET txtrear = " "
    IF ((textlen(txtbuffer) != reply->recordlength))
     RETURN(false)
    ENDIF
    IF (offset > 0)
     SET txtfront = notrim(substring(1,offset,txtbuffer))
    ENDIF
    IF ((tailoffset < reply->recordlength))
     SET txtrear = notrim(substring(tailoffset,(reply->recordlength - tailoffset),txtbuffer))
    ENDIF
    SET field = strvalue
    SET txtlen = textlen(field)
    IF (txtlen < len)
     FOR (i = txtlen TO (len - 1))
       SET field = notrim(concat(notrim(field),char(32)))
     ENDFOR
    ELSEIF (txtlen > len)
     SET field = notrim(substring(1,len,field))
    ENDIF
    SET reply->data[nrecno].buffer = notrim(concat(notrim(txtfront),notrim(field),notrim(txtrear),"$"
      ))
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE setstringfield(recno,fieldno,svalue)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   IF ((_utilruntime->columndesc[fieldno].columntype=_ccltype_string_))
    RETURN(setfieldno(recno,fieldno,substring(1,reply->columndesc[fieldno].length,svalue)))
   ENDIF
   RETURN(setfieldno(recno,fieldno,substring(1,reply->columndesc[fieldno].length,svalue)))
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE setintegerfield(recno,fieldno,ivalue)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   IF ((_utilruntime->columndesc[fieldno].columntype=_ccltype_int_))
    RETURN(setfieldno(recno,fieldno,format(ivalue,"##############;R;I")))
   ENDIF
   RETURN(setfieldno(recno,fieldno,cnvtstring(ivalue)))
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE setrealfield(recno,fieldno,fvalue)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   IF ((_utilruntime->columndesc[fieldno].columntype=_ccltype_real_))
    RETURN(setfieldno(recno,fieldno,build(fvalue)))
   ENDIF
   RETURN(setfieldno(recno,fieldno,cnvtstring(ivalue)))
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE setdatefield(recno,fieldno,dtvalue)
   RETURN(setfieldno(recno,fieldno,format(dtvalue,";;q")))
 END ;Subroutine
 SUBROUTINE closedataset(_null)
   DECLARE stat = i2 WITH protect
   SET stat = alterlist(reply->data,_utilruntime->currec)
   IF (size(reply->data,5) > 0)
    SET stat = setstatus("S")
   ELSE
    SET stat = setstatus("Z")
   ENDIF
   IF (size(request->context,5) > 0)
    SET stat = alterlist(reply->context,size(request->context,5))
    FOR (ctxline = 1 TO size(reply->context,5))
      SET reply->context[ctxline].value = request->context[ctxline].value
    ENDFOR
   ELSE
    SET stat = alterlist(reply->context,0)
   ENDIF
   IF (size(reply->columndesc,5)=0)
    SET createdataset = 1
   ELSE
    SET createdataset = 0
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE formatrecord(nrecno)
   DECLARE txtbuffer = vc WITH notrim, protect
   DECLARE reccnt = i2 WITH protect
   DECLARE i = i4 WITH protect
   SET txtbuffer = " "
   FOR (i = 1 TO reply->recordlength)
     SET txtbuffer = notrim(concat(txtbuffer,char(32)))
   ENDFOR
   SET reply->data[nrecno].buffer = notrim(txtbuffer)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE setmessagebox(msg)
   SET reply->status_data.subeventstatus[1].targetobjectname = "MSGBOX"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = msg
   RETURN(0)
 END ;Subroutine
 SUBROUTINE setmessageboxex(msg,title,icon)
   DECLARE parcnt = i2 WITH protect
   DECLARE ctrlver = f8 WITH protect, noconstant(1.0)
   DECLARE stat = i2 WITH protect
   DECLARE size = i2 WITH protect
   SET parcnt = size(request->parameters,5)
   SET paramname = trim(cnvtupper("_DPL_VERSION_"))
   FOR (i = 1 TO parcnt)
     IF (paramname=trim(cnvtupper(request->parameters[i].name)))
      SET ctrlver = cnvtreal(request->parameters[i].value)
      IF (ctrlver >= 1.0016)
       SET size = (size(reply->status_data.subeventstatus,5)+ 1)
       SET stat = alter(reply->status_data.subeventstatus,size)
       SET reply->status_data.subeventstatus[size].operationname = "DIALOG"
       SET reply->status_data.subeventstatus[size].operationstatus = "S"
       SET reply->status_data.subeventstatus[size].targetobjectname = "MSGBOX"
       SET reply->status_data.subeventstatus[size].targetobjectvalue = notrim(concat(msg,char(7),
         title,char(7),icon))
       RETURN(1)
      ENDIF
     ENDIF
   ENDFOR
   RETURN(setmessagebox(msg))
 END ;Subroutine
 SUBROUTINE setstatus(cstatus)
  SET reply->status_data.status = cnvtupper(cstatus)
  RETURN(0)
 END ;Subroutine
 SUBROUTINE getstatus(void)
   RETURN(reply->status_data.status)
 END ;Subroutine
 SUBROUTINE setvalidation(bvalid)
  SET reply->validation = bvalid
  RETURN(0)
 END ;Subroutine
 SUBROUTINE isvalid(void)
   RETURN(reply->validation)
 END ;Subroutine
 SUBROUTINE isdebugmode(void)
   DECLARE mode = vc WITH protect
   SET mode = getparameter("_DEBUG_")
   IF (textlen(mode) > 0)
    RETURN(cnvtint(mode))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE isdesignmode(void)
   DECLARE mode = vc WITH protect
   SET mode = getparameter("_DESIGN_MODE_")
   IF (textlen(mode) > 0)
    RETURN(cnvtint(mode))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE resetdataset(ntotalrecs)
   DECLARE stat = i2 WITH protect
   IF (ntotalrecs >= 0
    AND ntotalrecs < size(reply->data,5))
    SET stat = alterlist(reply->data,ntotalrecs)
   ENDIF
   IF (size(request->context,5) > 0)
    SET stat = alterlist(reply->context,size(request->context,5))
    FOR (ctxline = 1 TO size(reply->context,5))
      SET reply->context[ctxline].value = request->context[ctxline].value
    ENDFOR
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE expanddataset(naddrecs)
   DECLARE nsize = i4 WITH protect
   DECLARE stat = i2 WITH protect
   IF (naddrecs > 0)
    SET nsize = (size(reply->data,5)+ naddrecs)
    SET stat = alterlist(reply->data,nsize)
    RETURN(nsize)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE checkdataset(recno,delta)
   DECLARE stat = i2 WITH protect
   IF (recno >= recordcount(0))
    SET recno = (recordcount(0)+ delta)
    SET stat = expanddataset(recno)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE recordcount(dummy)
   DECLARE reccnt = i2 WITH protect
   SET reccnt = size(reply->data,5)
   RETURN(cnvtint(reccnt))
 END ;Subroutine
 SUBROUTINE appendrecord(nrecno)
   DECLARE txtbuffer = vc WITH notrim, protect
   DECLARE reccnt = i2 WITH protect
   SET txtbuffer = " "
   FOR (i = 1 TO reply->recordlength)
     SET txtbuffer = notrim(concat(txtbuffer,char(32)))
   ENDFOR
   SET reply->data[nrecno].buffer = notrim(txtbuffer)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getdplversion(void)
   DECLARE sverstr = vc WITH protect
   SET sverstr = getparameter("_DPL_VERSION_")
   IF (textlen(sverstr) > 0)
    RETURN(cnvtreal(sverstr))
   ENDIF
   RETURN(0001.0001)
 END ;Subroutine
 SUBROUTINE getmajorversion(void)
   DECLARE sverstr = vc WITH protect
   SET sverstr = getparameter("_DPL_VERSION_")
   IF (textlen(sverstr) > 4)
    RETURN(cnvtint(build(sverstr)))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getminorversion(void)
   DECLARE sverstr = vc WITH protect
   SET sverstr = trim(getparameter("_DPL_VERSION_"))
   IF (textlen(sverstr) > 5)
    RETURN(cnvtint(substring(6,4,sverstr)))
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE isvalidationquery(void)
   DECLARE svalflag = vc
   SET svalflag = getparameter("_VALIDATE_")
   IF (trim(svalflag)="1")
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE seteventmessage(msg)
  SET reply->error_msg = concat(trim(reply->error_msg),trim(msg),";")
  RETURN(0)
 END ;Subroutine
 SUBROUTINE adderrormessage(opname,cstatus,objname,msgvalue)
   DECLARE msgline = i2 WITH protect
   DECLARE stat = i2 WITH protect
   IF (cnvtupper(cstatus) IN ("S", "F", "Z"))
    SET msglinecount = (size(reply->status_data.subeventstatus,5)+ 1)
    IF (msglinecount=1)
     SET msglinecount = 2
    ENDIF
    SET stat = alter(reply->status_data.subeventstatus,msglinecount)
    SET reply->status_data.subeventstatus[msglinecount].operationname = opname
    SET reply->status_data.subeventstatus[msglinecount].operationstatus = cnvtupper(cstatus)
    SET reply->status_data.subeventstatus[msglinecount].targetobjectname = objname
    SET reply->status_data.subeventstatus[msglinecount].targetobjectvalue = msgvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE getparameter(paramname)
   DECLARE pndx = i2 WITH protect
   SET pndx = parameterexist(paramname)
   IF (pndx > 0)
    RETURN(request->parameters[pndx].value)
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE parameterexist(paramname)
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
 SUBROUTINE makedataset(initreccount)
   DECLARE stat = i2 WITH protect
   SET reply->status_data.status = "F"
   SET reply->recordlength = 0
   SET stat = alterlist(reply->columndesc,0)
   SET stat = alterlist(reply->misc,0)
   SET stat = alterlist(reply->data,initreccount)
   SET stat = alterlist(reply->context,0)
   SET _utilruntime->currec = 0
   SET _utilruntime->expanddelta = initreccount
   SET _utilruntime->settype = 0
   SET stat = alterlist(_utilruntime->columndesc,0)
   RETURN(0)
 END ;Subroutine
 SUBROUTINE writerecord(void)
   DECLARE stat = i2 WITH protect
   IF ((_utilruntime->settype=0))
    SET createdataset = 0
    SET columntitle = concat(reportinfo(1),"$")
    CALL builddescriptors(0)
    SET _utilruntime->settype = 1
   ENDIF
   SET _utilruntime->currec = (_utilruntime->currec+ 1)
   IF ((_utilruntime->currec >= size(reply->data,5)))
    SET stat = alterlist(reply->data,(size(reply->data,5)+ _utilruntime->expanddelta))
   ENDIF
   SET reply->data[_utilruntime->currec].buffer = concat(reportinfo(2),"$")
   RETURN(_utilruntime->currec)
 END ;Subroutine
 SUBROUTINE setrecord(recno,delta)
   DECLARE nsize = i4 WITH protect
   DECLARE stat = i2 WITH protect
   IF (recno >= size(reply->data,5))
    SET nsize = (size(reply->data,5)+ delta)
    SET stat = alterlist(reply->data,nsize)
   ENDIF
   SET reply->data[recno].buffer = concat(reportinfo(2),"$")
 END ;Subroutine
 SUBROUTINE builddescriptors(void)
   DECLARE node = i2 WITH noconstant(0)
   DECLARE charpos = i4 WITH noconstant(1)
   DECLARE fldstart = i4 WITH noconstant(1)
   DECLARE fldend = i4 WITH noconstant(1)
   DECLARE fldname = vc
   DECLARE stat = i2 WITH protect
   SET error = build_exception
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
   RETURN(0)
 END ;Subroutine
 SUBROUTINE checkduplicates(fldname)
   DECLARE dups = i2 WITH noconstant(0), protect
   DECLARE newname = vc WITH protect
   SET newname = trim(fldname)
   FOR (i = 1 TO size(reply->columndesc,5))
     IF ((reply->columndesc[i].name=newname))
      SET dups = (dups+ 1)
     ENDIF
   ENDFOR
   IF (dups > 0)
    SET newname = concat(newname,trim(cnvtstring((dups+ 1))))
   ENDIF
   RETURN(newname)
 END ;Subroutine
 SUBROUTINE parsefieldname(at_pos)
   DECLARE atpos = i2 WITH protect
   SET error = parse_exception
   SET atpos = at_pos
   WHILE (atpos <= size(columntitle)
    AND substring(atpos,1,columntitle) != " ")
     SET atpos = (atpos+ 1)
   ENDWHILE
   RETURN(atpos)
 END ;Subroutine
 SUBROUTINE skipwhitespace(at_pos)
   DECLARE atpos = i2 WITH protect
   SET error = skip_exception
   SET atpos = at_pos
   WHILE (atpos <= size(columntitle)
    AND substring(atpos,1,columntitle)=" ")
     SET atpos = (atpos+ 1)
   ENDWHILE
   RETURN(atpos)
 END ;Subroutine
 SUBROUTINE getfieldcount(_null)
   RETURN(size(reply->columndesc,5))
 END ;Subroutine
 SUBROUTINE showfieldno(fieldno,bshow)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   SET reply->columndesc[fieldno].visible = bshow
   RETURN(1)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE showfield(fieldname,bshow)
   DECLARE fld = i4
   SET fld = findfield(fieldname)
   IF (fld > 0)
    SET reply->columndesc[fld].visible = bshow
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE isfieldvisible(fieldno)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   RETURN(reply->columndesc[fieldno].visible)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE getfieldtitle(fieldno)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   RETURN(reply->columndesc[fieldno].title)
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE setfieldtitleno(fieldno,title)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   SET reply->columndesc[fieldno].title = title
   RETURN(1)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE setfieldtitle(fieldname,title)
   SET fdno = findfield(fieldname)
   IF (fdno > 0)
    CALL setfieldtitleno(fdno,title)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE findfield(fieldname)
   DECLARE found = i1 WITH protect
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
 SUBROUTINE getfieldname(fieldno)
  IF (fieldno > 0
   AND fieldno <= getfieldcount(0))
   RETURN(reply->columndesc[fieldno].name)
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE addfieldnotitle(strname,nsize)
   DECLARE stat = i2 WITH protect
   SET reclen = reply->recordlength
   SET ncolcnt = (size(reply->columndesc,5)+ 1)
   SET stat = alterlist(reply->columndesc,ncolcnt)
   SET reply->columndesc[ncolcnt].name = trim(cnvtupper(strname))
   SET reply->columndesc[ncolcnt].offset = reclen
   SET reply->columndesc[ncolcnt].length = nsize
   SET reply->recordlength = (reply->recordlength+ nsize)
   SET stat = alterlist(_utilruntime->columndesc,ncolcnt)
   SET _utilruntime->columndesc[ncolcnt].columntype = _ccltype_undef_
   RETURN(ncolcnt)
 END ;Subroutine
 SUBROUTINE getcurrentrecord(dummy)
   RETURN(_utilruntime->currec)
 END ;Subroutine
 SUBROUTINE getintegerfield(recno,fieldno)
   DECLARE value = vc WITH protect
   IF ((_utilruntime->columndesc[fieldno].columntype=_ccltype_int_))
    SET value = getstringfield(recno,fieldno)
    IF (textlen(value) > 0
     AND isnumeric(value))
     RETURN(cnvtint(value))
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getrealfield(recno,fieldno)
   DECLARE value = vc WITH protect
   IF ((_utilruntime->columndesc[fieldno].columntype=_ccltype_real_))
    SET value = getstringfield(recno,fieldno)
    IF (textlen(value) > 0
     AND isnumeric(value))
     RETURN(cnvtreal(value))
    ENDIF
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE getdatefield(recno,fieldno)
   DECLARE value = vc WITH protect, notrim
   IF ((_utilruntime->columndesc[fieldno].columntype=_ccltype_date_))
    SET value = notrim(getstringfield(recno,fieldno))
    IF (textlen(value) > 0)
     RETURN(cnvtdatetime(value))
    ENDIF
   ENDIF
   RETURN(0.0)
 END ;Subroutine
 SUBROUTINE getstringfield(recno,fieldno)
   DECLARE len = i4 WITH protect
   DECLARE offset = i4 WITH protect
   DECLARE value = vc WITH protect
   DECLARE txtbuffer = vc WITH protect, notrim
   IF (fieldno > 0
    AND fieldno <= size(reply->columndesc,5))
    SET offset = reply->columndesc[fieldno].offset
    SET len = reply->columndesc[fieldno].length
    SET txtbuffer = notrim(reply->data[recno].buffer)
    SET value = notrim(substring((offset+ 1),len,txtbuffer))
    RETURN(value)
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE checkfield(recno,fieldno)
   DECLARE value = vc WITH protect
   SET value = trim(getstringfield(recno,fieldno))
   IF (textlen(value) > 0)
    CASE (_utilruntime->columndesc[fieldno].columntype)
     OF _ccltype_int_:
     OF _ccltype_real_:
      IF (isnumeric(value))
       RETURN(true)
      ENDIF
     OF _ccltype_date_:
     OF _ccltype_string_:
      RETURN(true)
    ENDCASE
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE setcontextrecord(recno,data)
   DECLARE rec = i4 WITH protect
   SET request->context[recno].value = data
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getcontextrecord(recno)
  IF (recno <= size(request->context,5))
   RETURN(request->context[recno].value)
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE getcontextcount(null)
   RETURN(size(request->context,5))
 END ;Subroutine
 SUBROUTINE setcontextsize(n)
   DECLARE stat = i2 WITH protect
   SET stat = alterlist(request->context,n)
   RETURN(n)
 END ;Subroutine
 SUBROUTINE setmiscrecord(which,recno,data)
   DECLARE rec = i4 WITH protect
   IF (which=_in_)
    SET request->misc[recno].value = data
   ELSE
    SET reply->misc[recno].value = data
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE getmiscrecord(which,recno)
  IF (which=_in_)
   IF (recno <= size(request->misc,5))
    RETURN(request->misc[recno].value)
   ENDIF
  ELSE
   IF (recno <= size(reply->misc,5))
    RETURN(reply->misc[recno].value)
   ENDIF
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE getmisccount(which)
   IF (which=_in_)
    RETURN(size(request->misc,5))
   ELSE
    RETURN(size(reply->misc,5))
   ENDIF
 END ;Subroutine
 SUBROUTINE setmiscsize(which,n)
   DECLARE stat = i2 WITH protect
   IF (which=_in_)
    SET stat = alterlist(request->misc,n)
   ELSE
    SET stat = alterlist(reply->misc,n)
   ENDIF
   RETURN(n)
 END ;Subroutine
 SUBROUTINE getparametercount(void)
   RETURN(size(request->parameters,5))
 END ;Subroutine
 SUBROUTINE getparameterno(paramno)
  IF (paramno > 0
   AND paramno <= size(request->parameters,5))
   RETURN(request->parameters[paramno].value)
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE getparametername(paramno)
  IF (paramno > 0
   AND paramno <= size(request->parameters,5))
   RETURN(request->parameters[paramno].name)
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE isparameterreserved(paramno)
   DECLARE sname = vc WITH protect
   SET sname = cnvtupper(trim(getparametername(paramno)))
   IF (sname="_DPL_VERSION_")
    RETURN(true)
   ELSEIF (sname="_VALIDATE_")
    RETURN(true)
   ELSEIF (sname="_DEBUG_")
    RETURN(true)
   ELSEIF (substring(1,1,sname)="_")
    RETURN(true)
   ENDIF
   RETURN(false)
 END ;Subroutine
 SUBROUTINE parsecommandline(void)
   DECLARE count = i2 WITH protect
   DECLARE tp = vc WITH protect
   DECLARE sub = i2 WITH protect
   DECLARE del = vc WITH protect
   DECLARE sep = vc WITH protect
   DECLARE stat = i2 WITH protect
   SET count = 1
   SET tp = reflect(parameter(count,0))
   WHILE (tp > substring(1,1,tp)
    AND count < 100)
     SET stat = alterlist(_utilruntime->argument,count)
     SET _utilruntime->argument[count].type = substring(1,1,tp)
     SET _utilruntime->argument[count].length = cnvtint(substring(2,10,tp))
     SET _utilruntime->argument[count].value = build(parameter(count,0))
     IF (substring(1,1,tp)="L")
      SET sub = 1
      SET _utilruntime->argument[count].listvalue = "VALUE("
      SET sep = " "
      SET tp = reflect(parameter(count,sub))
      WHILE (substring(1,1,tp) > " ")
        SET stat = alterlist(_utilruntime->argument[count].list,sub)
        SET _utilruntime->argument[count].list[sub].type = substring(1,1,tp)
        SET _utilruntime->argument[count].list[sub].length = cnvtint(substring(2,10,tp))
        SET _utilruntime->argument[count].list[sub].value = build(parameter(count,sub))
        IF (substring(1,1,tp)="C")
         SET del = "^"
        ELSE
         SET del = " "
        ENDIF
        IF (sub > 1)
         SET sep = ","
        ENDIF
        SET _utilruntime->argument[count].listvalue = notrim(concat(_utilruntime->argument[count].
          listvalue,sep,del,_utilruntime->argument[count].list[sub].value,del))
        SET sub = (sub+ 1)
        SET tp = reflect(parameter(count,sub))
      ENDWHILE
      SET _utilruntime->argument[count].listvalue = notrim(concat(_utilruntime->argument[count].
        listvalue,")"))
     ENDIF
     SET count = (count+ 1)
     SET tp = reflect(parameter(count,0))
   ENDWHILE
   RETURN(count)
 END ;Subroutine
 SUBROUTINE getargumentcount(void)
   RETURN(size(_utilruntime->argument,5))
 END ;Subroutine
 SUBROUTINE getargumenttype(argno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   RETURN(_utilruntime->argument[argno].type)
  ENDIF
  RETURN(" ")
 END ;Subroutine
 SUBROUTINE getargumentvalue(argno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   RETURN(_utilruntime->argument[argno].value)
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE getargumentsize(argno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   RETURN(_utilruntime->argument[argno].length)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE getargumentlistcount(argno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   RETURN(size(_utilruntime->argument[argno].list,5))
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE getargumentlistvalue(argno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   IF (getargumenttype(argno)="L")
    RETURN(_utilruntime->argument[argno].listvalue)
   ENDIF
  ENDIF
  RETURN(" ")
 END ;Subroutine
 SUBROUTINE getargumentlistitemtype(argno,itemno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   IF (getargumenttype(argno)="L")
    IF (itemno > 0
     AND itemno <= getargumentlistcount(argno))
     RETURN(_utilruntime->argument[argno].list[itemno].type)
    ENDIF
   ENDIF
  ENDIF
  RETURN(" ")
 END ;Subroutine
 SUBROUTINE getargumentlistitemvalue(argno,itemno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   IF (getargumenttype(argno)="L")
    IF (itemno > 0
     AND itemno <= getargumentlistcount(argno))
     RETURN(_utilruntime->argument[argno].list[itemno].value)
    ENDIF
   ENDIF
  ENDIF
  RETURN("")
 END ;Subroutine
 SUBROUTINE getargumentlistitemsize(argno,itemno)
  IF (argno > 0
   AND argno <= getargumentcount(0))
   IF (getargumenttype(argno)="L")
    IF (itemno > 0
     AND itemno <= getargumentlistcount(argno))
     RETURN(_utilruntime->argument[argno].list[itemno].length)
    ENDIF
   ENDIF
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE addparameter(parname,parvalue,partype)
   DECLARE ndx = i2 WITH private
   SET ndx = (size(request->parameters,5)+ 1)
   SET stata = alterlist(request->parameters,ndx)
   SET request->parameters[ndx].name = parname
   SET request->parameters[ndx].value = parvalue
   SET request->parameters[ndx].datatype = partype
 END ;Subroutine
 SUBROUTINE start(tst)
   CALL echo("***************************************")
   CALL echo(concat("Start Test : ",tst))
   CALL echo("***************************************")
   CALL clearrequest(0)
   CALL clearreply(0)
   SET runresult = 0
   SET testcount = (testcount+ 1)
 END ;Subroutine
 SUBROUTINE fail(tst)
   CALL echo("")
   CALL echo(concat("failed step: ",tst))
   SET totalerrors = (totalerrors+ 1)
   SET runresult = (runresult+ 1)
 END ;Subroutine
 SUBROUTINE done(tst,status,expected)
   CALL echo("")
   SET runcomplete = (runcomplete+ 1)
   IF (runresult=0)
    CALL echo(concat("Test run :",tst," OK"))
   ELSE
    CALL echo(concat("Test : ",tst," completed with error count = ",build(runresult)))
   ENDIF
   IF (status != "-")
    CALL echo(concat("Status = '",status,"'"))
    IF (status != expected)
     CALL echorecord(request)
     CALL echorecord(reply)
     SET totalerrors = (totalerrors+ 1)
     SET runresult = (runresult+ 1)
    ENDIF
   ENDIF
   CALL echo("")
   CALL echo("")
 END ;Subroutine
 SUBROUTINE clearparameters(void)
   SET stat = alterlist(request->parameters,0)
 END ;Subroutine
 SUBROUTINE clearrequest(void)
   CALL clearparameters(0)
   SET request->query = ""
   SET stat = alterlist(request->context,0)
   SET stat = alterlist(request->misc,0)
 END ;Subroutine
 SUBROUTINE clearreply(void)
   SET stat = alterlist(reply->columndesc,0)
   SET stat = alterlist(reply->data,0)
   SET stat = alterlist(reply->misc,0)
   SET stat = alterlist(reply->context,0)
   SET reply->recordlength = 0
   SET reply->status_data.status = "Z"
   SET statf = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus.operationname = ""
   SET reply->status_data.subeventstatus.operationstatus = " "
   SET reply->status_data.subeventstatus.targetobjectname = ""
   SET reply->status_data.subeventstatus.targetobjectvalue = ""
   SET reply->error_msg = ""
 END ;Subroutine
 SUBROUTINE run(qry)
   SET request->query = qry
   SET request->returndata = 1
   CALL clearreply(0)
   CALL echo(concat("run:",qry))
   CALL addparameter("_DPL_VERSION_","0001.0016",3)
   CALL addparameter("_DPL_HOST_","win32 (DEVTEST_ALPHA,CERTQB)",1)
   EXECUTE ccl_prompt_run_query
   RETURN(reply->status_data.status)
 END ;Subroutine
 SUBROUTINE runvalidation(qry)
  IF (run(qry)="S")
   RETURN(reply->validation)
  ENDIF
  RETURN("X")
 END ;Subroutine
 SUBROUTINE reporttestresults(void)
   CALL echo("CCL_PROMPT_TST_DATASOURCE_API test completed")
   CALL echo("********************************************")
   CALL echo(concat("Total Test Count : ",build(testcount)))
   CALL echo(concat("Total Error Count: ",build(runresult)))
   CALL echo(concat("Total Completed  : ",build(runcomplete)))
   IF (totalerrors > 0)
    CALL echo(build("Conclusion: ",totalerrors," test steps failed"))
   ELSE
    IF (runcomplete=testcount)
     CALL echo("Conclusion: all test were successful")
    ELSE
     CALL echo(
      "Conclusion: test count does not equal test completed, not all test completed normally")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE adddefaultkey(keyvalue)
   DECLARE stat = i2 WITH protect
   DECLARE ndx = i2 WITH protect
   SET ndx = (size(reply->default_key_list,5)+ 1)
   SET stat = alterlist(reply->default_key_list,ndx)
   SET reply->default_key_list[ndx].buffer = notrim(keyvalue)
   RETURN(ndx)
 END ;Subroutine
 SUBROUTINE setkeyfield(fieldno,keyflag)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   SET reply->columndesc[fieldno].keycolumn = keyflag
   RETURN(1)
  ENDIF
  RETURN(0)
 END ;Subroutine
 SUBROUTINE iskeyfield(fieldno)
  IF (fieldno > 0
   AND fieldno <= size(reply->columndesc,5))
   RETURN(reply->columndesc[fieldno].keycolumn)
  ENDIF
  RETURN(- (1))
 END ;Subroutine
END GO
