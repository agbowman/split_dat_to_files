CREATE PROGRAM ccl_prompt_importform
 PROMPT
  "Import file location : " = ""
  WITH fileloc
 DECLARE uar_xml_readfile(source=vc,filehandle=i4(ref)) = i4
 DECLARE uar_xml_closefile(filehandle=i4(ref)) = null
 DECLARE uar_xml_geterrormsg(errorcode=i4(ref)) = vc
 DECLARE uar_xml_listtree(filehandle=i4(ref)) = vc
 DECLARE uar_xml_getroot(filehandle=i4(ref),nodehandle=i4(ref)) = i4
 DECLARE uar_xml_findchildnode(nodehandle=i4(ref),nodename=vc,childhandle=i4(ref)) = i4
 DECLARE uar_xml_getchildcount(nodehandle=i4(ref)) = i4
 DECLARE uar_xml_getchildnode(nodehandle=i4(ref),nodeno=i4(ref),childnode=i4(ref)) = i4
 DECLARE uar_xml_getparentnode(nodehandle=i4(ref),parentnode=i4(ref)) = i4
 DECLARE uar_xml_getnodename(nodehandle=i4(ref)) = vc
 DECLARE uar_xml_getnodecontent(nodehandle=i4(ref)) = vc
 DECLARE uar_xml_getattrbyname(nodehandle=i4(ref),attrname=vc,attributehandle=i4(ref)) = i4
 DECLARE uar_xml_getattrbypos(nodehandle=i4(ref),ndx=i4(ref),attributehandle=i4(ref)) = i4
 DECLARE uar_xml_getattrname(attributehandle=i4(ref)) = vc
 DECLARE uar_xml_getattrvalue(attributehandle=i4(ref)) = vc
 DECLARE uar_xml_getattributevalue(nodehandle=i4(ref),attrname=vc) = vc
 DECLARE uar_xml_getattrcount(nodehandle=i4(ref)) = i4
 DECLARE importnode(hparent=i4) = null
 DECLARE importcontrol(hctrlparent=i4) = null
 DECLARE importcomponent(hcmpparent=i4) = null
 DECLARE importproperty(hpropparent=i4) = null
 DECLARE importhelpfile(hhelpparent=i4) = null
 DECLARE importtable(htablenode=i4) = null
 DECLARE cvntboolean(val=vc) = i1
 DECLARE decodetags(txtstr=vc) = vc
 DECLARE deleteitems(hqualify=i4) = null
 DECLARE insertitems(hinsert=i4) = null
 DECLARE insertline(hline=i4) = null
 DECLARE hfile = i4 WITH private
 DECLARE hroot = i4 WITH private
 DECLARE hnode = i4 WITH private
 DECLARE hdplnode = i4 WITH private
 DECLARE htblnode = i4 WITH private
 DECLARE hattr = i4 WITH private
 DECLARE berror = i1 WITH noconstant(0)
 DECLARE bhelp = i1 WITH noconstant(0)
 FREE RECORD promptreq
 RECORD promptreq(
   1 programname = c30
   1 groupno = i1
   1 prompts[*]
     2 operation = i2
     2 promptid = f8
     2 promptname = c30
     2 position = i2
     2 control = i2
     2 display = c100
     2 description = c100
     2 defaultvalue = c100
     2 resulttype = i2
     2 width = i4
     2 height = i4
     2 components[*]
       3 componentname = c30
       3 properties[*]
         4 propertyname = c30
         4 propertyvalue = vc
     2 excludeind = i2
 )
 FREE RECORD promptreply
 RECORD promptreply(
   1 prompts[*]
     2 promptid = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD filereq
 RECORD filereq(
   1 folder_name = c100
   1 file_name = c100
   1 content = vc
   1 active_ind = i2
 )
 FREE RECORD filerep
 RECORD filerep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD progreq
 RECORD progreq(
   1 programname = vc
   1 groupno = i2
   1 display = vc
   1 description = vc
   1 classid = i2
 )
 DECLARE list = vc
 IF (validate(errorflag,5)=5)
  SET errorflag = 0
  SET errormsg = fillstring(255," ")
 ENDIF
 IF (errorflag != 0)
  CALL echo(concat("Open ('",trim( $FILELOC),"')"))
 ENDIF
 SET stat = 0
 SET stat = uar_xml_readfile(nullterm(trim( $FILELOC)),hfile)
 IF (stat=1)
  IF (uar_xml_getroot(hfile,hroot)=1)
   IF (uar_xml_findchildnode(hroot,nullterm("CCLREC"),htblnode)=1)
    IF (errorflag != 0)
     CALL echo("Import table")
    ENDIF
    CALL importtable(htblnode)
   ELSEIF (uar_xml_findchildnode(hroot,nullterm("prompt-def"),hdplnode)=1)
    IF (errorflag != 0)
     CALL echo("Import form definition")
    ENDIF
    CALL importnode(hdplnode)
    IF (berror=false)
     SET _user_override_ = "Y"
     EXECUTE ccl_prompt_del_form promptreq->programname, promptreq->groupno, "NL"
     IF (errorflag=0)
      CALL echo("update loading form definitions")
      EXECUTE ccl_prompt_updt_prompts  WITH replace(request,promptreq), replace(reply,promptreply)
      SET _user_override_ = "N"
      IF (bhelp=true)
       IF (errorflag=0)
        CALL echo("uploading help file")
        EXECUTE ccl_prompt_put_file  WITH replace(request,filereq), replace(reply,filerep)
       ENDIF
      ENDIF
     ELSE
      SET berror = 1
      SET errormsg = "%CCL-F-CCL_PROMPT_IMPORTFORM form not deleted, form import skipped"
     ENDIF
    ENDIF
   ELSE
    SET berror = 1
    SET errormsg = concat("%CCL-F-CCL_PROMPT_IMPORTFORM FORM STRUCTURE [",trim( $FILELOC),"]")
    IF (errorflag=0)
     CALL echo(errormsg)
    ENDIF
   ENDIF
  ENDIF
 ELSE
  SET berror = 1
  SET errormsg = uar_xml_geterrormsg(stat)
 ENDIF
 CALL uar_xml_closefile(hfile)
 SET _user_override_ = "N"
 IF (berror != 0)
  SET errorflag = 1
  CALL echo(errormsg)
 ENDIF
 RETURN
 SUBROUTINE importnode(hparent)
   DECLARE nodename = vc WITH private
   DECLARE nodeval = vc WITH private
   DECLARE promptcount = i2 WITH private
   DECLARE hattr = i4 WITH private
   DECLARE hchild = i4 WITH private
   DECLARE nodecount = i4 WITH private
   DECLARE i = i4 WITH private
   IF (hparent=0)
    RETURN
   ENDIF
   SET nodename = uar_xml_getnodename(hparent)
   IF (nodename != "prompt-def")
    IF (errorflag != 0)
     CALL echo(concat("error: invalid root node [",nodename,"]"))
    ENDIF
    SET berror = true
    RETURN
   ENDIF
   SET promptreq->programname = uar_xml_getattributevalue(hparent,nullterm("program"))
   SET promptreq->groupno = cnvtint(uar_xml_getattributevalue(hparent,nullterm("group")))
   SET nodecount = uar_xml_getchildcount(hparent)
   FOR (i = 0 TO (nodecount - 1))
     IF (uar_xml_getchildnode(hparent,i,hchild)=1)
      SET nodename = uar_xml_getnodename(hchild)
      CASE (nodename)
       OF "control":
        CALL importcontrol(hchild)
       OF "program-info":
        CALL importhelpfile(hchild)
      ENDCASE
     ELSE
      SET ec = uar_xml_getchildnode(hparent,i,hchild)
      SET errormsg = uar_xml_geterrormsg(ec)
      IF (errorflag != 0)
       CALL echo(concat("ImportNode::",uar_xml_geterrormsg(ec)))
      ENDIF
      SET berror = true
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE importcontrol(hctrlparent)
   DECLARE ctrlname = vc WITH private
   DECLARE ctrlval = vc WITH private
   DECLARE ctrlcount = i4 WITH private
   DECLARE ctrlchildcount = i4 WITH private
   DECLARE hctrlchild = i4 WITH private
   DECLARE ctrltxt = vc WITH private
   DECLARE hctrltemp = i4 WITH private
   DECLARE ctrl = i4 WITH private
   DECLARE rtf = vc WITH private
   IF (hctrlparent != 0)
    SET ctrlname = uar_xml_getattributevalue(hctrlparent,nullterm("name"))
    IF (ctrlname="")
     RETURN
    ENDIF
    SET ctrlcount = (size(promptreq->prompts,5)+ 1)
    SET stat = alterlist(promptreq->prompts,ctrlcount)
    SET curalias prmt promptreq->prompts[ctrlcount]
    SET promptreq->prompts[ctrlcount].operation = 1
    SET promptreq->prompts[ctrlcount].promptid = 0.0
    SET promptreq->prompts[ctrlcount].promptname = ctrlname
    SET promptreq->prompts[ctrlcount].control = cnvtint(uar_xml_getattributevalue(hctrlparent,
      nullterm("control")))
    SET promptreq->prompts[ctrlcount].position = cnvtint(uar_xml_getattributevalue(hctrlparent,
      nullterm("position")))
    SET promptreq->prompts[ctrlcount].resulttype = cnvtint(uar_xml_getattributevalue(hctrlparent,
      nullterm("result-type")))
    SET promptreq->prompts[ctrlcount].excludeind = cnvtboolean(uar_xml_getattributevalue(hctrlparent,
      nullterm("exclude")))
    SET promptreq->prompts[ctrlcount].width = cnvtint(uar_xml_getattributevalue(hctrlparent,nullterm(
       "width")))
    SET promptreq->prompts[ctrlcount].height = cnvtint(uar_xml_getattributevalue(hctrlparent,nullterm
      ("height")))
    SET ctrlchildcount = uar_xml_getchildcount(hctrlparent)
    FOR (ctrl = 0 TO (ctrlchildcount - 1))
      IF (uar_xml_getchildnode(hctrlparent,ctrl,hctrlchild)=1)
       SET txt = uar_xml_getnodename(hctrlchild)
       IF (hctrlchild > 0)
        SET rtf = uar_xml_getnodecontent(hctrlchild)
        CASE (txt)
         OF "display":
          SET promptreq->prompts[ctrlcount].display = decodetags(rtf)
         OF "description":
          SET promptreq->prompts[ctrlcount].description = decodetags(rtf)
         OF "default":
          SET promptreq->prompts[ctrlcount].defaultvalue = decodetags(rtf)
         OF "component":
          CALL importcomponent(hctrlchild)
        ENDCASE
       ELSE
        SET berror = true
       ENDIF
      ELSE
       SET ec = uar_xml_getchildnode(hctrlparent,ctrl,hctrlchild)
       SET errormsg = uar_xml_geterrormsg(ec)
       IF (errorflag != 0)
        CALL echo(concat("ImportControl::",uar_xml_geterrormsg(ec)))
       ENDIF
       SET berror = true
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE importcomponent(hcmpparent)
   DECLARE curctrl = i4 WITH private
   DECLARE cmpname = vc WITH private
   DECLARE cmpno = i4 WITH private
   DECLARE cmppropcount = i4 WITH private
   DECLARE cmpprop = i4 WITH private
   DECLARE cmphchild = i4 WITH private
   DECLARE cmpchildname = vc WITH private
   SET curctrl = size(promptreq->prompts,5)
   SET cmpname = uar_xml_getattributevalue(hcmpparent,nullterm("name"))
   IF (cmpname > "")
    SET cmpno = (size(promptreq->prompts[curctrl].components,5)+ 1)
    SET stat = alterlist(promptreq->prompts[curctrl].components,cmpno)
    SET promptreq->prompts[curctrl].components[cmpno].componentname = cmpname
    SET cmppropcount = uar_xml_getchildcount(hcmpparent)
    FOR (cmpprop = 0 TO (cmppropcount - 1))
      IF (uar_xml_getchildnode(hcmpparent,cmpprop,cmphchild)=1)
       SET cmpchildname = uar_xml_getnodename(cmphchild)
       IF (cmpchildname="property")
        CALL importproperty(cmphchild)
       ENDIF
      ELSE
       SET ec = uar_xml_getchildnode(hcmpparent,cmpprop,cmphchild)
       SET errormsg = uar_xml_geterrormsg(ec)
       IF (errorflag != 0)
        CALL echo(concat("ImportComponent::",uar_xml_geterrormsg(ec)))
       ENDIF
       SET berror = true
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE importproperty(hpropparent)
   DECLARE curctrl = i4 WITH private
   DECLARE curcmp = i4 WITH private
   DECLARE curprop = i4 WITH private
   DECLARE propname = vc WITH private
   DECLARE childcount = i4 WITH private
   DECLARE prop = i4 WITH private
   DECLARE hprop = i4 WITH private
   SET curctrl = size(promptreq->prompts,5)
   SET curcmp = size(promptreq->prompts[curctrl].components,5)
   SET propname = uar_xml_getattributevalue(hpropparent,nullterm("name"))
   IF (propname > "")
    SET curprop = (size(promptreq->prompts[curctrl].components[curcmp].properties,5)+ 1)
    SET stat = alterlist(promptreq->prompts[curctrl].components[curcmp].properties,curprop)
    SET childcount = uar_xml_getchildcount(hpropparent)
    FOR (prop = 0 TO (childcount - 1))
      IF (uar_xml_getchildnode(hpropparent,prop,hprop)=1)
       CALL echo(concat("uar_xml_getchildnode, hProp=",build(hprop)))
       IF (hprop > 0)
        SET promptreq->prompts[curctrl].components[curcmp].properties[curprop].propertyname =
        propname
        SET promptreq->prompts[curctrl].components[curcmp].properties[curprop].propertyvalue =
        uar_xml_getnodecontent(hprop)
       ELSE
        SET berror = true
        CALL echo(concat("uar_xml_getchildnode error!  hProp=",build(hprop)))
       ENDIF
      ELSE
       SET ec = uar_xml_getchildnode(hpropparent,prop,hprop)
       SET errormsg = uar_xml_geterrormsg(ec)
       IF (errorflag != 0)
        CALL echo(concat("ImportProperty::",uar_xml_geterrormsg(ec)))
       ENDIF
       SET berror = true
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE importhelpfile(hhelpparent)
   DECLARE rtf = vc WITH private
   DECLARE hdata = i4 WITH private
   DECLARE hchild = i4 WITH private
   DECLARE childcount = i4 WITH private
   DECLARE rtfnode = i4 WITH private
   DECLARE nodename = vc WITH private
   SET childcount = uar_xml_getchildcount(hhelpparent)
   FOR (rtfnode = 0 TO (childcount - 1))
     IF (uar_xml_getchildnode(hhelpparent,rtfnode,hchild)=1)
      SET nodename = uar_xml_getnodename(hchild)
      IF (nodename=nullterm("CDATA"))
       SET rtf = uar_xml_getnodecontent(hchild)
      ENDIF
     ELSE
      SET ec = uar_xml_getchildnode(hhelpparent,rtfnode,hchild)
      SET errormsg = uar_xml_geterrormsg(ec)
      IF (errorflag != 0)
       CALL echo(concat("ImportHelpFile::",uar_xml_geterrormsg(ec)))
      ENDIF
      SET berror = true
     ENDIF
   ENDFOR
   SET filereq->active_ind = 1
   SET filereq->file_name = promptreq->programname
   SET filereq->folder_name = concat("/PDDOC/GROUP",trim(cnvtstring(promptreq->groupno)))
   SET filereq->content = rtf
   SET bhelp = true
 END ;Subroutine
 SUBROUTINE importtable(htblnode)
   DECLARE tablename = vc WITH public
   DECLARE hinsert = i4 WITH private
   SET tablename = uar_xml_getattributevalue(htblnode,nullterm("name"))
   IF (substring(1,1,tablename)="_")
    SET tablename = substring(2,(textlen(tablename) - 1),tablename)
   ENDIF
   IF (uar_xml_findchildnode(htblnode,nullterm("INSERT_DATA"),hinsert)=1)
    CALL deleteitems(htblnode)
    CALL insertitems(hinsert)
   ENDIF
 END ;Subroutine
 SUBROUTINE insertitems(hinsert)
   DECLARE sqlinsert = vc WITH private, notrim
   DECLARE hitem = i4 WITH private
   DECLARE itemtype = vc WITH private
   DECLARE itemcount = i4 WITH private
   DECLARE item = i4 WITH private
   SET itemtype = cnvtlower(uar_xml_getattributevalue(hinsert,nullterm("type")))
   IF (itemtype="list")
    SET itemcount = uar_xml_getchildcount(hinsert)
    FOR (item = 0 TO (itemcount - 1))
      IF (uar_xml_getchildnode(hinsert,item,hitem)=1)
       CALL insertitems(hitem)
      ELSE
       SET ec = uar_xml_getchildnode(hinsert,item,hitem)
       SET errormsg = uar_xml_geterrormsg(ec)
       IF (errorflag != 0)
        CALL echo(uar_xml_geterrormsg(ec))
       ENDIF
       SET berror = true
      ENDIF
    ENDFOR
   ELSE
    CALL insertline(hinsert)
   ENDIF
 END ;Subroutine
 SUBROUTINE deleteitems(htblnode)
   DECLARE sqldelete = vc WITH private, notrim
   DECLARE hqual = i4 WITH private
   DECLARE hfield = i4 WITH private
   DECLARE hvalue = i4 WITH private
   DECLARE updtcol = i4 WITH private
   DECLARE colno = i4 WITH private
   SET sqldelete = notrim(concat("delete from ",trim(tablename)," where "))
   IF (uar_xml_findchildnode(htblnode,nullterm("QUALIFY_ON"),hqual)=1)
    SET updtcol = 0
    IF (uar_xml_findchildnode(htblnode,nullterm("QUALIFY_ON"),hqual)=1)
     SET colcount = uar_xml_getchildcount(hqual)
     FOR (colno = 0 TO (colcount - 1))
       IF (uar_xml_getchildnode(hqual,colno,hfield)=1)
        IF (updtcol > 0)
         SET sqldelete = notrim(concat(sqldelete," and "))
        ENDIF
        SET sqldelete = notrim(concat(sqldelete,uar_xml_getnodename(hfield)," = "))
        IF (uar_xml_getattrbyname(hfield,"value",hvalue)=1)
         SET sqldelete = notrim(concat(sqldelete,uar_xml_getattrvalue(hvalue)))
        ELSEIF (uar_xml_findchildnode(hfield,"CDATA",hvalue)=1)
         SET sqldelete = notrim(concat(sqldelete,'"',uar_xml_getnodecontent(hvalue),'"'))
        ENDIF
        SET updtcol = (updtcol+ 1)
       ENDIF
     ENDFOR
     SET sqldelete = notrim(concat(sqldelete," go "))
     CALL echo(sqldelete)
     CALL parser(sqldelete)
     COMMIT
    ENDIF
   ELSE
    SET ec = uar_xml_findchildnode(htblnode,nullterm("QUALIFY_ON"),hqual)
    SET errormsg = uar_xml_geterrormsg(ec)
    IF (errorflag != 0)
     CALL echo(uar_xml_geterrormsg(ec))
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE insertline(hitem)
   DECLARE sqlupdate = vc WITH private, notrim
   DECLARE sqlrecord = vc WITH private, notrim
   DECLARE hqual = i4 WITH private
   DECLARE hfield = i4 WITH private
   DECLARE hvalue = i4 WITH private
   DECLARE updtcol = i4 WITH private
   DECLARE colno = i4 WITH private
   DECLARE nodetpe = vc WITH private
   RECORD importreq(
     1 values[*]
       2 item = vc
   )
   SET sqlupdate = notrim(concat("insert into ",trim(tablename)," set "))
   SET updtcol = 0
   SET colcount = uar_xml_getchildcount(hitem)
   SET stat = alterlist(importreq->values,colcount)
   FOR (colno = 0 TO (colcount - 1))
     IF (uar_xml_getchildnode(hitem,colno,hfield)=1)
      IF (updtcol > 0)
       SET sqlupdate = notrim(concat(sqlupdate," , "))
      ENDIF
      SET nodetype = cnvtlower(uar_xml_getattributevalue(hfield,nullterm("type")))
      CASE (nodetype)
       OF "string":
        SET sqlupdate = notrim(concat(sqlupdate,uar_xml_getnodename(hfield)," = importReq->values[",
          trim(cnvtstring((colno+ 1))),"].item"))
       OF "int":
        SET sqlupdate = notrim(concat(sqlupdate,uar_xml_getnodename(hfield),
          " = CnvtInt(importReq->values[",trim(cnvtstring((colno+ 1))),"].item)"))
       OF "double":
        SET sqlupdate = notrim(concat(sqlupdate,uar_xml_getnodename(hfield),
          " = CnvtReal(importReq->values[",trim(cnvtstring((colno+ 1))),"].item)"))
       OF "datetime":
        SET sqlupdate = notrim(concat(sqlupdate,uar_xml_getnodename(hfield),
          "= CnvtDateTime(ConCat(Format(CnvtDate2(SubString(1, 10, importReq->values[",trim(
           cnvtstring((colno+ 1))),"].item), 'yyyy-mm-dd'), 'dd-mmm-yyyy;;q'), ' ', ",
          " SubString(12, 8, importReq->values[",trim(cnvtstring((colno+ 1))),"].item)))"))
      ENDCASE
      IF (uar_xml_getattrbyname(hfield,nullterm("value"),hvalue)=1)
       SET importreq->values[(colno+ 1)].item = uar_xml_getattrvalue(hvalue)
      ELSEIF (uar_xml_findchildnode(hfield,nullterm("CDATA"),hvalue)=1)
       SET importreq->values[(colno+ 1)].item = uar_xml_getnodecontent(hvalue)
      ENDIF
      SET updtcol = (updtcol+ 1)
     ENDIF
   ENDFOR
   IF (errorflag != 0)
    CALL echorecord(importreq)
   ENDIF
   SET sqlupdate = notrim(concat(sqlupdate," go "))
   CALL parser(sqlupdate)
   COMMIT
 END ;Subroutine
 SUBROUTINE cnvtboolean(val)
   IF (cnvtlower(val)="true")
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE decodetags(txtstr)
   DECLARE p = i2 WITH private
   DECLARE tc = i1 WITH private
   DECLARE len = i2 WITH private
   DECLARE str = vc WITH notrim, private
   SET p = 1
   SET len = size(txtstr)
   IF (findstring("&#",txtstr) > 0)
    WHILE (p <= len)
      IF (substring(p,2,txtstr)="&#")
       SET p = (p+ 2)
       SET tc = 0
       WHILE (substring(p,1,txtstr) != ";")
        SET tc = ((tc * 10)+ (ichar(substring(p,1,txtstr)) - ichar("0")))
        SET p = (p+ 1)
       ENDWHILE
       SET str = concat(str,char(tc))
       SET p = (p+ 1)
      ELSE
       SET str = notrim(concat(str,substring(p,1,txtstr)))
       SET p = (p+ 1)
      ENDIF
    ENDWHILE
   ELSE
    RETURN(txtstr)
   ENDIF
   RETURN(str)
 END ;Subroutine
END GO
