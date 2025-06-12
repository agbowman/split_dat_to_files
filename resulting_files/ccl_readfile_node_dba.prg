CREATE PROGRAM ccl_readfile_node:dba
 PROMPT
  "Enter MINE/CRT/printer/file:" = "MINE",
  "Enter string log name:" = "*",
  "Orientation:" = 0,
  "Page Height(in):" = 11,
  "Page Width(in):" = 8.5,
  "Host Name (CURNODE) :" = ""
  WITH outdev, filename, orientation,
  pgheight, pgwidth, host
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE uar_crmnodeperform(p1=i4(value),p2=vc(ref)) = i2 WITH image_axp = "crmrtl", image_aix =
 "libcrm.a(libcrm.o)", uar = "CrmNodePerform",
 persist
 DECLARE i18nhandle = i4
 DECLARE i18n_file_not_found = vc
 SET i18nhandle = 0
 SET lretval = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET i18n_file_not_found = uar_i18ngetmessage(i18nhandle,"KeyGet1",
  "File does not exist or cannot be opened: ")
 DECLARE pcount1 = i4
 DECLARE stat = i4
 DECLARE pos = i4
 RECORD frec(
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 RECORD rec1(
   1 qual[*]
     2 line = vc
 )
 IF (((cnvtupper(trim( $HOST))=cnvtupper(trim(curnode))) OR (cnvtupper(trim( $HOST))=" ")) )
  IF (findfile(trim( $FILENAME,3))=1)
   SET frec->file_name = value( $FILENAME)
   SET frec->file_buf = "r+"
   SET stat = cclio("OPEN",frec)
   SET frec->file_buf = notrim(fillstring(2000," "))
   IF ((frec->file_desc != 0))
    SET stat = 1
    SET stat2 = alterlist(rec1->qual,100)
    SET pcount1 = 0
    WHILE (stat > 0)
     SET stat = cclio("GETS",frec)
     IF (stat > 0)
      SET pos = findstring(char(0),frec->file_buf)
      SET pcount1 += 1
      IF (mod(pcount1,10)=1
       AND pcount1 > 100)
       SET stat2 = alterlist(rec1->qual,(pcount1+ 9))
      ENDIF
      SET rec1->qual[pcount1].line = trim(substring(1,pos,frec->file_buf))
     ENDIF
    ENDWHILE
    SET stat = cclio("CLOSE",frec)
   ENDIF
   SET stat1 = alterlist(rec1->qual,pcount1)
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = value(size(rec1->qual,5)))
    DETAIL
     rec1->qual[d.seq].line, row + 1
    WITH nocounter, format = variable, maxcol = 2003,
     maxrow = 1
   ;end select
   SET rptreport->m_reportname =  $FILENAME
   SET rptreport->m_pagewidth =  $PGWIDTH
   SET rptreport->m_pageheight =  $PGHEIGHT
   SET rptreport->m_orientation =  $ORIENTATION
  ELSE
   SELECT INTO  $OUTDEV
    FROM dummyt
    DETAIL
     col 0, i18n_file_not_found,  $FILENAME
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  DECLARE _app = i4 WITH protect, noconstant(0)
  DECLARE _task = i4 WITH protect, noconstant(0)
  DECLARE _happ = i4 WITH protect, noconstant(0)
  DECLARE _htask = i4 WITH protect, noconstant(0)
  DECLARE _hreq = i4 WITH protect, noconstant(0)
  DECLARE _hrep = i4 WITH protect, noconstant(0)
  DECLARE _hstat = i4 WITH protect, noconstant(0)
  SET _app = 3010000
  SET _task = 3011002
  SET _reqnum = 3011001
  SET crmstatus = uar_crmbeginapp(_app,_happ)
  IF (crmstatus != 0)
   SET fillstr = fillstring(255," ")
   SET fillstr = concat("Error! uar_CrmBeginApp failed with status: ",build(crmstatus))
   CALL echo(fillstr)
   RETURN(0)
  ELSE
   CALL echo(concat("Uar_CrmBeginApp success, app: ",build(_app)))
  ENDIF
  SET crmstatus = uar_crmbegintask(_happ,_task,_htask)
  IF (crmstatus != 0)
   SET fillstr = fillstring(255," ")
   SET fillstr = concat("Error! uar_CrmBeginTask failed with status: ",build(crmstatus))
   CALL echo(fillstr)
   CALL uar_crmendapp(_happ)
   RETURN(0)
  ELSE
   CALL echo(concat("Uar_CrmBeginTask success, task: ",build(_task)))
  ENDIF
  SET crmstatus = uar_crmbeginreq(_htask,0,_reqnum,_hreq)
  IF (crmstatus != 0)
   SET fillstr = fillstring(255," ")
   SET fillstr = concat("Invalid CrmBeginReq return status of",build(crmstatus))
   CALL echo(fillstr)
   CALL uar_crmendtask(_htask)
   CALL uar_crmendapp(_happ)
   RETURN(0)
  ELSE
   CALL echo("uar_CrmBeginReq success")
  ENDIF
  SET _hrequest = uar_crmgetrequest(_hreq)
  IF (_hrequest)
   DECLARE directory_name = vc
   DECLARE file_name = vc
   DECLARE colon_index = i2 WITH noconstant(0)
   SET colon_index = findstring(":",trim( $FILENAME))
   IF (colon_index > 0)
    SET directory_name = substring(1,colon_index,trim( $FILENAME))
    SET file_name = substring((colon_index+ 1),(textlen(trim( $FILENAME)) - colon_index),trim(
       $FILENAME))
   ENDIF
   IF (trim(directory_name)="")
    SET directory_name = "ccluserdir:"
   ENDIF
   IF (trim(file_name)="")
    SET file_name = trim( $FILENAME)
   ENDIF
   SET stat = uar_srvsetstring(_hrequest,"Module_Dir",directory_name)
   SET stat = uar_srvsetstring(_hrequest,"Module_Name",file_name)
   SET stat = uar_srvsetshort(_hrequest,"bAsBlob",1)
   CALL echo(" calling uar_CrmNodePerform()")
   SET crmstatus = uar_crmnodeperform(_hreq,nullterm( $HOST))
   SET fillstr = concat("uar_CrmNodePerform : ",build(crmstatus))
   SET _hreply = uar_crmgetreply(_hreq)
   SET _hstat = uar_srvgetstruct(_hreply,"status_data")
   SET _status = uar_srvgetstringptr(_hstat,"status")
   CALL echo(concat("Called process returned: ",_status))
   IF (_status != "S")
    SET fillstr = fillstring(100," ")
    SET fillstr = concat("eks_get_source returned status :",build(crmstatus))
    CALL echo(fillstr)
    SET source_name = concat(directory_name,file_name)
    SELECT INTO  $OUTDEV
     FROM dummyt
     DETAIL
      col 0, i18n_file_not_found, source_name
     WITH nocounter
    ;end select
    RETURN(0)
   ELSE
    FREE RECORD datablob
    RECORD datablob(
      1 blobsize = i4
      1 blobtext = gvc
    )
    SET datablob->blobsize = uar_srvgetlong(_hreply,"data_blob_size")
    SET datablob->blobtext = uar_srvgetasisptr(_hreply,"data_blob")
    FREE RECORD putreq
    RECORD putreq(
      1 source_dir = vc
      1 source_filename = vc
      1 nbrlines = i4
      1 line[*]
        2 linedata = vc
      1 overflowpage[*]
        2 ofr_qual[*]
          3 ofr_line = vc
      1 isblob = c1
      1 document_size = i4
      1 document = gvc
    )
    SET putreq->document = datablob->blobtext
    IF (size(putreq->document) > 0)
     SET putreq->source_filename =  $OUTDEV
     SET putreq->isblob = "1"
     SET putreq->document_size = size(putreq->document)
     FREE RECORD putreply
     EXECUTE eks_put_source  WITH replace("REQUEST","PUTREQ"), replace("REPLY","PUTREPLY")
    ELSE
     SET fillstr = fillstring(255," ")
     SET fillstr = "Invalid blob size.  Failed to retrieve the blob text"
     CALL echo(fillstr)
     RETURN(0)
    ENDIF
   ENDIF
  ENDIF
 ENDIF
END GO
