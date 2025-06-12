CREATE PROGRAM bb_rpt_qc_troubleshooting:dba
 RECORD reply(
   1 file_name = vc
   1 node = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD params(
   1 qual[*]
     2 active_ind = i2
     2 troubleshooting_step = vc
 )
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
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE nstatus = i2 WITH protect, noconstant(0)
 DECLARE nfirsttime = i2 WITH protect, noconstant(1)
 DECLARE li18nhandle = i4 WITH protect, noconstant(0)
 DECLARE ncount = i2 WITH protect, noconstant(0)
 DECLARE nlinelength = i2 WITH protect, constant(121)
 DECLARE nbreak = i2 WITH protect, noconstant(0)
 DECLARE nsegcount = i2 WITH protect, noconstant(0)
 DECLARE nlinesperpage = i2 WITH protect, constant(57)
 DECLARE serror = vc WITH protect, noconstant("")
 DECLARE ssegment = vc WITH protect, noconstant("")
 DECLARE ssixline = vc WITH protect, noconstant("")
 DECLARE sonetwentyline = vc WITH protect, noconstant("")
 DECLARE sdashlinestring = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET nstatus = uar_i18nlocalizationinit(li18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 stitle = vc
   1 susername = vc
   1 sdomain = vc
   1 sdate = vc
   1 stime = vc
   1 spage = vc
   1 sactive = vc
   1 stroubleshooting = vc
   1 sendofreport = vc
   1 syes = vc
   1 sno = vc
 )
 SET captions->stitle = uar_i18ngetmessage(li18nhandle,"TITLE",
  "PathNet Blood Bank: QC Troubleshooting Report")
 SET captions->susername = uar_i18ngetmessage(li18nhandle,"NAME","Name:")
 SET captions->sdomain = uar_i18ngetmessage(li18nhandle,"DOMAIN","Domain:")
 SET captions->sdate = uar_i18ngetmessage(li18nhandle,"DATE","Date:")
 SET captions->stime = uar_i18ngetmessage(li18nhandle,"TIME","Time:")
 SET captions->spage = uar_i18ngetmessage(li18nhandle,"PAGE","Page:")
 SET captions->sactive = uar_i18ngetmessage(li18nhandle,"ACTIVE","Active")
 SET captions->stroubleshooting = uar_i18ngetmessage(li18nhandle,"TROUBLESHOOTING",
  "Troubleshooting Step")
 SET captions->sendofreport = uar_i18ngetmessage(li18nhandle,"ENDOFREPORT",
  "* * * End of Report * * *")
 SET captions->syes = uar_i18ngetmessage(li18nhandle,"YES","YES")
 SET captions->sno = uar_i18ngetmessage(li18nhandle,"NO","NO")
 SELECT INTO "nl:"
  tempstring = substring(1,40,lt.long_text)
  FROM bb_qc_troubleshooting bbqct,
   long_text_reference lt
  PLAN (bbqct
   WHERE (((request->active_ind=0)) OR ((request->active_ind=bbqct.active_ind)))
    AND bbqct.troubleshooting_id > 0)
   JOIN (lt
   WHERE lt.long_text_id=bbqct.troubleshooting_text_id)
  ORDER BY tempstring
  HEAD REPORT
   ncount = 0
  DETAIL
   ncount += 1
   IF (ncount > size(params->qual,5))
    nstatus = alterlist(params->qual,(ncount+ 9))
   ENDIF
   params->qual[ncount].active_ind = bbqct.active_ind, params->qual[ncount].troubleshooting_step = lt
   .long_text
  FOOT REPORT
   nstatus = alterlist(params->qual,ncount)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_troubleshooting",serror)
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name "bb_qct", "txt"
 IF ((cpm_cfn_info->status_data.status != "S"))
  CALL subevent_add("REPORT","F","bb_rpt_qc_troubleshooting","Failed to create a file name")
  GO TO exit_script
 ENDIF
 IF (size(params->qual,5)=0)
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    sonetwentyline = fillstring(121,"-"), ssixline = fillstring(6,"-"), sdashlinestring = fillstring(
     129,"-")
   DETAIL
    CALL center(captions->stitle,1,129), row + 1, col 1,
    captions->susername, col 9, request->username,
    col 116, captions->sdate, col 122,
    curdate"@SHORTDATE", row + 1, col 1,
    captions->sdomain, col 9, request->domain,
    col 116, captions->stime, col 122,
    curtime3"@TIMEWITHSECONDS", row + 1, row + 1,
    col 1, captions->sactive, col 9,
    captions->stroubleshooting, row + 1, col 1,
    ssixline, col 9, sonetwentyline,
    row + 1
   FOOT PAGE
    row nlinesperpage, row + 1, col 1,
    sdashlinestring, row + 1, col 61,
    captions->spage, col + 2, curpage"####;L"
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = value(size(params->qual,5)))
   PLAN (d)
   HEAD REPORT
    sonetwentyline = fillstring(121,"-"), ssixline = fillstring(6,"-"), sdashlinestring = fillstring(
     129,"-")
   HEAD PAGE
    IF (((d.seq < value(size(params->qual,5))) OR (((nbreak=1) OR (value(size(params->qual,5))=1))
    )) )
     IF (((value(size(params->qual,5))=1
      AND ((nbreak=1) OR (nfirsttime=1)) ) OR (value(size(params->qual,5)) > 1)) )
      CALL center(captions->stitle,1,129), row + 1, col 1,
      captions->susername, col 9, request->username,
      col 116, captions->sdate, col 122,
      curdate"@SHORTDATE", row + 1, col 1,
      captions->sdomain, col 9, request->domain,
      col 116, captions->stime, col 122,
      curtime3"@TIMEWITHSECONDS", row + 1, row + 1,
      col 1, captions->sactive, col 9,
      captions->stroubleshooting, row + 1, col 1,
      ssixline, col 9, sonetwentyline,
      row + 1, nfirsttime = 0
     ENDIF
    ENDIF
   DETAIL
    IF ((row >= (nlinesperpage - 3)))
     nbreak = 1, BREAK
    ELSE
     nbreak = 0
    ENDIF
    IF ((params->qual[d.seq].active_ind=1))
     col 1, captions->syes
    ELSE
     col 1, captions->sno
    ENDIF
    ssegment = params->qual[d.seq].troubleshooting_step, tblobin = " ", tblobin = trim(ssegment),
    CALL rtf_to_text(trim(tblobin),1,nlinelength)
    FOR (z = 1 TO size(tmptext->qual,5))
      col 9, tmptext->qual[z].text, row + 1
      IF ((row >= (nlinesperpage - 3)))
       nbreak = 1, BREAK
      ELSE
       nbreak = 0
      ENDIF
    ENDFOR
    row + 2
    IF (d.seq=value(size(params->qual,5)))
     col 51, captions->sendofreport
    ENDIF
   FOOT PAGE
    row nlinesperpage, row + 1, col 1,
    sdashlinestring, row + 1, col 61,
    captions->spage, col + 2, curpage"####;L"
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("REPORT","F","bb_rpt_qc_troubleshoooting",serror)
  GO TO exit_script
 ENDIF
 SET reply->file_name = cpm_cfn_info->file_name_full_path
 SET reply->node = curnode
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD params
 FREE RECORD captions
END GO
