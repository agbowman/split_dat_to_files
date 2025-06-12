CREATE PROGRAM bbt_rpt_result_corr:dba
 RECORD ord_r_rec(
   1 ord_r[*]
     2 order_id = f8
     2 result_id = f8
     2 task_assay_cd = f8
     2 person_id = f8
     2 encntr_id = f8
     2 patient_name = c25
     2 encntr_alias = c20
     2 accession = c20
     2 order_mnemonic = c20
     2 detail_mnemonic = c18
     2 cell_product = c26
     2 xm_order_ind = i2
     2 xm_product_id = f8
 )
 RECORD r_rec(
   1 r[*]
     2 result_id = f8
     2 perform_result_id = f8
     2 task_assay_cd = f8
     2 result_status_cd = f8
     2 result = vc
     2 result_dt_tm = dq8
     2 result_username = c10
     2 comment_text = vc
     2 note_text = vc
     2 numeric_result_ind = i2
     2 service_resource_cd = f8
     2 less_great_flag = i2
     2 numeric_result = f8
     2 result_flag_str = vc
 )
 RECORD result(
   1 resultlist[*]
     2 result_corrected_ind = c1
     2 result = vc
     2 result_dt_tm = dq8
     2 result_username = c10
     2 long_text_id = f8
     2 long_text = vc
     2 comment_text = vc
     2 note_text = vc
     2 result_status_cd = f8
 )
 RECORD ops_params(
   1 qual[*]
     2 param = c100
 )
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE get_username(sub_person_id) = c10
 SUBROUTINE get_username(sub_person_id)
   SET sub_get_username = fillstring(10," ")
   SELECT INTO "nl:"
    pnl.username
    FROM prsnl pnl
    WHERE pnl.person_id=sub_person_id
     AND pnl.person_id != null
     AND pnl.person_id > 0.0
    DETAIL
     sub_get_username = pnl.username
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET inc_i18nhandle = 0
    SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
    SET sub_get_username = uar_i18ngetmessage(inc_i18nhandle,"inc_unknown","<Unknown>")
   ENDIF
   RETURN(sub_get_username)
 END ;Subroutine
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
 RECORD reportstuff(
   1 qual[*]
     2 printline = c131
     2 detailcount = i4
 )
 SET nitems = 0
 SET limit = 0
 SET blank_line = fillstring(131," ")
 SET z = fillstring(131," ")
 SET vcstring = fillstring(32000," ")
 DECLARE store_item(c,r,reportitem) = i4
 SUBROUTINE store_item(c,r,reportitem)
   SET item_length = 0
   SET junk = 0
   WHILE (nitems < r)
     SET nitems += 1
     SET stat = alterlist(reportstuff->qual,nitems)
     SET junk = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
   ENDWHILE
   SET itemlength = size(trim(reportitem),3)
   IF (itemlength > 0)
    SET junk = movestring(notrim(reportitem),1,reportstuff->qual[r].printline,(c+ 1),itemlength)
   ENDIF
   IF (r > limit)
    SET limit = r
   ENDIF
 END ;Subroutine
 DECLARE clear_item(c,r,reportitem) = i4
 SUBROUTINE clear_item(c,r,reportitem)
   SET item_length = size(reportitem,3)
   SET move_len = movestring(reportitem,1,reportstuff->qual[r].printline,(c+ 1),item_length)
   IF (r > limit)
    SET limit = r
   ENDIF
 END ;Subroutine
 SUBROUTINE clear_reportstuff(fillchar)
   SET fill_line = fillstring(132,fillchar)
   FOR (i = 1 TO nitems)
    CALL store_item(0,i,fill_line)
    SET reportstuff->qual[i].detailcount = 0
   ENDFOR
   SET limit = 0
 END ;Subroutine
 DECLARE store_varchar_item(startrow,para_indent,maxperrow) = i4
 SUBROUTINE store_varchar_item(startrow,para_indent,maxperrow)
   SET j = startrow
   SET p = para_indent
   SET nchars = 0
   SET headptr = 1
   SET strsize = size(trim(vcstring),3)
   WHILE (headptr <= strsize)
     SET tailptr = ((headptr+ maxperrow) - 1)
     SET ch = substring(tailptr,1,vcstring)
     WHILE (tailptr > headptr
      AND ch != " ")
      SET tailptr -= 1
      SET ch = substring(tailptr,1,vcstring)
     ENDWHILE
     IF (tailptr=headptr)
      SET tailptr = ((headptr+ maxperrow) - 1)
     ENDIF
     SET nchars = ((tailptr - headptr)+ 1)
     SET z = substring(headptr,value(nchars),vcstring)
     SET item_length = 0
     SET junk = 0
     WHILE (nitems < j)
       SET nitems += 1
       SET stat = alterlist(reportstuff->qual,nitems)
       SET junk = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
     ENDWHILE
     SET itemlength = size(trim(z),3)
     SET junk = movestring(z,1,reportstuff->qual[j].printline,(p+ 1),itemlength)
     IF (j > limit)
      SET limit = j
     ENDIF
     SET headptr = (tailptr+ 1)
     SET j += 1
   ENDWHILE
   RETURN(j)
 END ;Subroutine
 DECLARE abbrevage(agething) = c20
 SUBROUTINE abbrevage(agething)
   SET agestr1 = substring(1,2,agething)
   SET agestr2 = substring(1,3,agething)
   SET agestr3 = substring(1,4,agething)
   SET inc_i18nhandle = 0
   SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
   SET pos = findstring("Year",agething)
   IF (pos > 0)
    SET i18n_yrs = uar_i18ngetmessage(inc_i18nhandle,"i18n_yrs","YRS ")
    IF (pos=3)
     SET ageabbrev = concat(agestr1,i18n_yrs)
    ELSEIF (pos=4)
     SET ageabbrev = concat(agestr2,i18n_yrs)
    ELSE
     SET ageabbrev = concat(agestr3,i18n_yrs)
    ENDIF
   ELSE
    SET pos = findstring("Month",agething)
    IF (pos > 0)
     SET i18n_mos = uar_i18ngetmessage(inc_i18nhandle,"i18n_mos","MOS ")
     IF (pos=3)
      SET ageabbrev = concat(agestr1,i18n_mos)
     ELSE
      SET ageabbrev = concat(agestr2,i18n_mos)
     ENDIF
    ELSE
     SET pos = findstring("Week",agething)
     IF (pos > 0)
      SET i18n_wks = uar_i18ngetmessage(inc_i18nhandle,"i18n_wks","WKS ")
      IF (pos=3)
       SET ageabbrev = concat(agestr1,i18n_wks)
      ELSE
       SET ageabbrev = concat(agestr2,i18n_wks)
      ENDIF
     ELSE
      SET pos = findstring("Day",agething)
      IF (pos > 0)
       SET i18n_dys = uar_i18ngetmessage(inc_i18nhandle,"i18n_dys","DYS ")
       IF (pos=3)
        SET ageabbrev = concat(agestr1,i18n_dys)
       ELSE
        SET ageabbrev = concat(agestr2,i18n_dys)
       ENDIF
      ELSE
       SET ageabbrev = substring(1,5,agething)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(ageabbrev)
 END ;Subroutine
 DECLARE bldresultflagstr(fnorm,fcrit,frevw,fdelta,fcomment,
  fnote,fcorr,fnotify) = vc
 SUBROUTINE bldresultflagstr(fnorm,fcrit,frevw,fdelta,fcomment,fnote,fcorr,fnotify)
   DECLARE flagstr = vc WITH protect, noconstant(" ")
   IF (fnorm != " ")
    SET flagstr = fnorm
   ENDIF
   IF (fcrit != " ")
    SET flagstr = concat(flagstr,fcrit)
   ENDIF
   IF (frevw != " ")
    SET flagstr = concat(flagstr,frevw)
   ENDIF
   IF (fdelta != " ")
    SET flagstr = concat(flagstr,fdelta)
   ENDIF
   IF (fcorr="Y")
    SET flagstr = concat(flagstr,"c")
   ENDIF
   IF (((fcomment="Y") OR (fnote="Y")) )
    SET flagstr = concat(flagstr,"f")
   ENDIF
   IF (fnotify != " ")
    SET flagstr = concat(flagstr,fnotify)
   ENDIF
   RETURN(flagstr)
 END ;Subroutine
 DECLARE store_varchar_item2(startrow,startcol,maxperrow,linespace) = i4
 SUBROUTINE store_varchar_item2(startrow,startcol,maxperrow,linespace)
   SET ht = 9
   SET lf = 10
   SET ff = 12
   SET cr = 13
   SET spaces = 32
   SET curr_row = startrow
   SET start_col = startcol
   SET end_col = ((startcol+ maxperrow) - 1)
   SET start_pos = 0
   SET last_space_pos = 0
   SET text_len = 0
   SET text_parse = fillstring(132," ")
   SET ptr = 1
   SET max_text_len = size(trim(vcstring),3)
   WHILE (ptr <= max_text_len)
     SET text_char = substring(ptr,1,vcstring)
     IF (ichar(text_char) < spaces)
      IF (((ichar(text_char)=cr) OR (((ichar(text_char)=ff) OR (ichar(text_char)=lf)) )) )
       IF (start_pos > 0)
        SET text_parse = substring(start_pos,text_len,vcstring)
        WHILE (nitems < curr_row)
          SET nitems += 1
          SET stat = alterlist(reportstuff->qual,nitems)
          SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
        ENDWHILE
        SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
         text_len)
        IF (curr_row > limit)
         SET limit = curr_row
        ENDIF
       ELSE
        WHILE (nitems < curr_row)
          SET nitems += 1
          SET stat = alterlist(reportstuff->qual,nitems)
          SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
        ENDWHILE
        SET move_len = movestring(" ",1,reportstuff->qual[curr_row].printline,(start_col+ 1),1)
        IF (curr_row > limit)
         SET limit = curr_row
        ENDIF
       ENDIF
       IF (ichar(text_char)=cr)
        SET text_char = substring((ptr+ 1),1,vcstring)
        IF (ichar(text_char)=lf)
         SET ptr += 1
        ENDIF
       ENDIF
       SET curr_row += linespace
       SET start_col = startcol
       SET start_pos = 0
       SET last_space_pos = 0
       SET text_len = 0
       SET text_parse = fillstring(132," ")
      ENDIF
      IF (ichar(text_char) != cr
       AND ichar(text_char) != ff
       AND ichar(text_char) != lf)
       IF (text_len > 0)
        SET text_parse = substring(start_pos,text_len,vcstring)
        WHILE (nitems < curr_row)
          SET nitems += 1
          SET stat = alterlist(reportstuff->qual,nitems)
          SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
        ENDWHILE
        SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
         text_len)
        IF (curr_row > limit)
         SET limit = curr_row
        ENDIF
        SET start_col = (startcol+ text_len)
       ENDIF
       IF (ichar(text_char)=ht)
        SET start_col += 8
       ELSE
        SET start_col += 1
       ENDIF
       IF (start_col >= end_col)
        SET curr_row += linespace
        SET start_col = startcol
       ENDIF
       SET start_pos = (ptr+ 1)
       SET last_space_pos = 0
       SET text_len = 0
       SET text_parse = fillstring(132," ")
      ENDIF
     ENDIF
     IF (ichar(text_char) >= spaces)
      IF (start_pos=0)
       SET start_pos = ptr
      ENDIF
      IF (ichar(text_char)=spaces)
       SET last_space_pos = ptr
      ENDIF
      SET text_len += 1
      IF (((start_col+ text_len) >= end_col))
       IF (last_space_pos > 0)
        SET text_len = ((last_space_pos - start_pos)+ 1)
        SET ptr = last_space_pos
       ENDIF
       SET text_parse = substring(start_pos,text_len,vcstring)
       WHILE (nitems < curr_row)
         SET nitems += 1
         SET stat = alterlist(reportstuff->qual,nitems)
         SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
       ENDWHILE
       SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
        text_len)
       IF (curr_row > limit)
        SET limit = curr_row
       ENDIF
       SET curr_row += linespace
       SET start_col = startcol
       SET start_pos = 0
       SET last_space_pos = 0
       SET text_len = 0
       SET text_parse = fillstring(132," ")
      ENDIF
     ENDIF
     SET ptr += 1
   ENDWHILE
   IF (text_len > 0)
    SET text_parse = substring(start_pos,text_len,vcstring)
    WHILE (nitems < curr_row)
      SET nitems += 1
      SET stat = alterlist(reportstuff->qual,nitems)
      SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
    ENDWHILE
    SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
     text_len)
    IF (curr_row > limit)
     SET limit = curr_row
    ENDIF
    SET curr_row += linespace
    SET start_col = startcol
    SET start_pos = 0
    SET last_space_pos = 0
    SET text_len = 0
    SET text_parse = fillstring(132," ")
   ENDIF
   SET vcstring = " "
   RETURN(curr_row)
 END ;Subroutine
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD temp_rsrc_security(
   1 l_cnt = i4
   1 list[*]
     2 service_resource_cd = f8
     2 viewable_srvc_rsrc_ind = i2
   1 security_enabled = i2
 )
 RECORD default_service_type_cd(
   1 service_type_cd_list[*]
     2 service_type_cd = f8
 )
 DECLARE nres_sec_failed = i2 WITH protect, constant(0)
 DECLARE nres_sec_passed = i2 WITH protect, constant(1)
 DECLARE nres_sec_err = i2 WITH protect, constant(2)
 DECLARE nres_sec_msg_type = i2 WITH protect, constant(0)
 DECLARE ncase_sec_msg_type = i2 WITH protect, constant(1)
 DECLARE ncorr_group_sec_msg_type = i2 WITH protect, constant(2)
 DECLARE sres_sec_error_msg = c23 WITH protect, constant("RESOURCE SECURITY ERROR")
 DECLARE sres_sec_failed_msg = c24 WITH protect, constant("RESOURCE SECURITY FAILED")
 DECLARE scase_sec_failed_msg = c20 WITH protect, constant("CASE SECURITY FAILED")
 DECLARE scorr_group_sec_failed_msg = c24 WITH protect, constant("CORR GRP SECURITY FAILED")
 DECLARE m_nressecind = i2 WITH protect, noconstant(0)
 DECLARE m_sressecstatus = c1 WITH protect, noconstant("S")
 DECLARE m_nressecapistatus = i2 WITH protect, noconstant(0)
 DECLARE m_nressecerrorind = i2 WITH protect, noconstant(0)
 DECLARE m_lressecfailedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_lresseccheckedcnt = i4 WITH protect, noconstant(0)
 DECLARE m_nressecalterstatus = i2 WITH protect, noconstant(0)
 DECLARE m_lressecstatusblockcnt = i4 WITH protect, noconstant(0)
 DECLARE m_ntaskgrantedind = i2 WITH protect, noconstant(0)
 DECLARE m_sfailedmsg = c25 WITH protect
 DECLARE m_bresourceapicalled = i2 WITH protect, noconstant(0)
 SET temp_rsrc_security->l_cnt = 0
 SUBROUTINE (initresourcesecurity(resource_security_ind=i2) =null)
   IF (resource_security_ind=1)
    SET m_nressecind = true
   ELSE
    SET m_nressecind = false
   ENDIF
 END ;Subroutine
 SUBROUTINE (isresourceviewable(service_resource_cd=f8) =i2)
   DECLARE srvc_rsrc_idx = i4 WITH protect, noconstant(0)
   DECLARE l_srvc_rsrc_pos = i4 WITH protect, noconstant(0)
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET m_lresseccheckedcnt += 1
   IF (m_nressecind=false)
    RETURN(true)
   ENDIF
   IF (m_nressecerrorind=true)
    RETURN(false)
   ENDIF
   IF (service_resource_cd=0)
    RETURN(true)
   ENDIF
   IF (m_bresourceapicalled=true)
    IF ((temp_rsrc_security->security_enabled=1)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((temp_rsrc_security->security_enabled=0)
     AND size(temp_rsrc_security->list,5)=0)
     SET m_nressecapistatus = nres_sec_passed
    ELSEIF ((temp_rsrc_security->l_cnt > 0))
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ELSE
    RECORD request_3202551(
      1 prsnl_id = f8
      1 explicit_ind = i4
      1 debug_ind = i4
      1 service_type_cd_list[*]
        2 service_type_cd = f8
    )
    RECORD reply_3202551(
      1 security_enabled = i2
      1 service_resource_list[*]
        2 service_resource_cd = f8
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
    SET request_3202551->prsnl_id = reqinfo->updt_id
    IF (size(default_service_type_cd->service_type_cd_list,5) > 0)
     SET stat = alterlist(request_3202551->service_type_cd_list,size(default_service_type_cd->
       service_type_cd_list,5))
     FOR (idx = 1 TO size(default_service_type_cd->service_type_cd_list,5))
       SET request_3202551->service_type_cd_list[idx].service_type_cd = default_service_type_cd->
       service_type_cd_list[idx].service_type_cd
     ENDFOR
    ELSE
     SET stat = alterlist(request_3202551->service_type_cd_list,5)
     SET request_3202551->service_type_cd_list[1].service_type_cd = uar_get_code_by("MEANING",223,
      "SECTION")
     SET request_3202551->service_type_cd_list[2].service_type_cd = uar_get_code_by("MEANING",223,
      "SUBSECTION")
     SET request_3202551->service_type_cd_list[3].service_type_cd = uar_get_code_by("MEANING",223,
      "BENCH")
     SET request_3202551->service_type_cd_list[4].service_type_cd = uar_get_code_by("MEANING",223,
      "INSTRUMENT")
     SET request_3202551->service_type_cd_list[5].service_type_cd = uar_get_code_by("MEANING",223,
      "DEPARTMENT")
    ENDIF
    EXECUTE msvc_get_prsnl_svc_resources  WITH replace("REQUEST",request_3202551), replace("REPLY",
     reply_3202551)
    SET m_bresourceapicalled = true
    IF ((reply_3202551->status_data.status != "S"))
     SET m_nressecapistatus = nres_sec_err
    ELSEIF ((reply_3202551->security_enabled=1)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 1
     SET m_nressecapistatus = nres_sec_failed
    ELSEIF ((reply_3202551->security_enabled=0)
     AND size(reply_3202551->service_resource_list,5)=0)
     SET temp_rsrc_security->security_enabled = 0
     SET m_nressecapistatus = nres_sec_passed
    ELSE
     SET temp_rsrc_security->l_cnt = size(reply_3202551->service_resource_list,5)
     SET temp_rsrc_security->security_enabled = reply_3202551->security_enabled
     IF ((temp_rsrc_security->l_cnt > 0))
      SET stat = alterlist(temp_rsrc_security->list,temp_rsrc_security->l_cnt)
      FOR (idx = 1 TO size(reply_3202551->service_resource_list,5))
       SET temp_rsrc_security->list[idx].service_resource_cd = reply_3202551->service_resource_list[
       idx].service_resource_cd
       SET temp_rsrc_security->list[idx].viewable_srvc_rsrc_ind = 1
      ENDFOR
     ENDIF
     SET l_srvc_rsrc_pos = locateval(srvc_rsrc_idx,1,temp_rsrc_security->l_cnt,service_resource_cd,
      temp_rsrc_security->list[srvc_rsrc_idx].service_resource_cd)
     IF (l_srvc_rsrc_pos > 0)
      IF ((temp_rsrc_security->list[l_srvc_rsrc_pos].viewable_srvc_rsrc_ind=1))
       SET m_nressecapistatus = nres_sec_passed
      ELSE
       SET m_nressecapistatus = nres_sec_failed
      ENDIF
     ELSE
      SET m_nressecapistatus = nres_sec_failed
     ENDIF
    ENDIF
   ENDIF
   CASE (m_nressecapistatus)
    OF nres_sec_passed:
     RETURN(true)
    OF nres_sec_failed:
     SET m_lressecfailedcnt += 1
     RETURN(false)
    ELSE
     SET m_nressecerrorind = true
     RETURN(false)
   ENDCASE
 END ;Subroutine
 SUBROUTINE (getresourcesecuritystatus(fail_all_ind=i2) =c1)
  IF (m_nressecerrorind=true)
   SET m_sressecstatus = "F"
  ELSEIF (m_lresseccheckedcnt > 0
   AND m_lresseccheckedcnt=m_lressecfailedcnt)
   SET m_sressecstatus = "Z"
  ELSEIF (fail_all_ind=1
   AND m_lressecfailedcnt > 0)
   SET m_sressecstatus = "Z"
  ELSE
   SET m_sressecstatus = "S"
  ENDIF
  RETURN(m_sressecstatus)
 END ;Subroutine
 SUBROUTINE (populateressecstatusblock(message_type=i2) =null)
   IF (((m_sressecstatus="S") OR (validate(reply->status_data.status,"-1")="-1")) )
    RETURN
   ENDIF
   SET m_lressecstatusblockcnt = size(reply->status_data.subeventstatus,5)
   IF (m_lressecstatusblockcnt=1
    AND trim(reply->status_data.subeventstatus[1].operationname)="")
    SET m_ressecalterstatus = 0
   ELSE
    SET m_lressecstatusblockcnt += 1
    SET m_nressecalterstatus = alter(reply->status_data.subeventstatus,m_lressecstatusblockcnt)
   ENDIF
   CASE (message_type)
    OF ncase_sec_msg_type:
     SET m_sfailedmsg = scase_sec_failed_msg
    OF ncorr_group_sec_msg_type:
     SET m_sfailedmsg = scorr_group_sec_failed_msg
    ELSE
     SET m_sfailedmsg = sres_sec_failed_msg
   ENDCASE
   CASE (m_sressecstatus)
    OF "F":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname =
     sres_sec_error_msg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "F"
    OF "Z":
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationname = m_sfailedmsg
     SET reply->status_data.subeventstatus[m_lressecstatusblockcnt].operationstatus = "Z"
   ENDCASE
 END ;Subroutine
 SUBROUTINE (istaskgranted(task_number=i4) =i2)
   SET m_ntaskgrantedind = false
   SELECT INTO "nl:"
    FROM application_group ag,
     task_access ta
    PLAN (ag
     WHERE (ag.position_cd=reqinfo->position_cd)
      AND ag.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ag.end_effective_dt_tm >= cnvtdatetime(sysdate))
     JOIN (ta
     WHERE ta.app_group_cd=ag.app_group_cd
      AND ta.task_number=task_number)
    DETAIL
     m_ntaskgrantedind = true
    WITH nocounter
   ;end select
   RETURN(m_ntaskgrantedind)
 END ;Subroutine
 RECORD testsites(
   1 qual[*]
     2 service_resource_cd = f8
     2 service_resource_disp = c40
 )
 DECLARE const_serv_res_section_cdf = c12 WITH protect, constant("SECTION")
 DECLARE const_serv_res_subsection_cdf = c12 WITH protect, constant("SUBSECTION")
 DECLARE const_serv_res_bench_cdf = c12 WITH protect, constant("BENCH")
 DECLARE const_serv_res_instrument_cdf = c12 WITH protect, constant("INSTRUMENT")
 DECLARE const_serv_res_type_cs = i4 WITH protect, constant(223)
 DECLARE const_return_security_ok = i2 WITH protect, constant(1)
 DECLARE const_return_no_security = i2 WITH protect, constant(0)
 DECLARE const_return_invalid = i2 WITH protect, constant(- (1))
 DECLARE const_security_on = i2 WITH protect, constant(1)
 DECLARE const_security_off = i2 WITH protect, constant(0)
 DECLARE dservressectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE dservressubsectioncd = f8 WITH protect, noconstant(0.0)
 DECLARE nstat = i4 WITH protect, noconstant(0)
 SUBROUTINE (initservresroutine(nservressecind=i2) =i2)
   SET nstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_section_cdf,1,
    dservressectioncd)
   IF (dservressectioncd=0.0)
    RETURN(const_return_invalid)
   ENDIF
   SET nstat = uar_get_meaning_by_codeset(const_serv_res_type_cs,const_serv_res_subsection_cdf,1,
    dservressubsectioncd)
   IF (dservressubsectioncd=0.0)
    RETURN(const_return_invalid)
   ENDIF
   CALL initresourcesecurity(nservressecind)
   RETURN(const_return_security_ok)
 END ;Subroutine
 SUBROUTINE (determineservresaccess(dserviceresourcecd=f8) =i2)
   DECLARE sservrescdfmeaning = vc WITH protect, noconstant("")
   DECLARE iservreslevelflag = i2 WITH protect, noconstant(- (1))
   DECLARE itestsitecnt = i2 WITH protect, noconstant(0)
   DECLARE dcurservres = f8 WITH protect, noconstant(0.0)
   DECLARE ierrorcd = i4 WITH protect, noconstant(0)
   DECLARE serrormsg = vc WITH protect, noconstant("")
   IF (dserviceresourcecd=0.0)
    SET iservreslevelflag = 3
   ELSE
    SET sservrescdfmeaning = uar_get_code_meaning(dserviceresourcecd)
    IF (trim(sservrescdfmeaning) IN (const_serv_res_bench_cdf, const_serv_res_instrument_cdf))
     IF (isresourceviewable(dserviceresourcecd)=true)
      SET itestsitecnt = 1
      SET nstat = alterlist(testsites->qual,itestsitecnt)
      SET testsites->qual[itestsitecnt].service_resource_cd = dserviceresourcecd
      SET testsites->qual[itestsitecnt].service_resource_disp = uar_get_code_display(
       dserviceresourcecd)
      RETURN(const_return_security_ok)
     ELSE
      RETURN(const_return_no_security)
     ENDIF
    ELSEIF (trim(sservrescdfmeaning)=const_serv_res_subsection_cdf)
     SET iservreslevelflag = 1
    ELSEIF (trim(sservrescdfmeaning)=const_serv_res_section_cdf)
     SET iservreslevelflag = 2
    ELSE
     RETURN(const_return_invalid)
    ENDIF
   ENDIF
   IF (iservreslevelflag=1)
    SELECT INTO "nl:"
     subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     FROM resource_group subsect
     WHERE subsect.parent_service_resource_cd=dserviceresourcecd
      AND subsect.resource_group_type_cd=dservressubsectioncd
      AND ((subsect.root_service_resource_cd+ 0)=0.0)
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ELSEIF (iservreslevelflag=2)
    SELECT INTO "nl:"
     sect.parent_service_resource_cd, subsect.parent_service_resource_cd, subsect
     .child_service_resource_cd
     FROM resource_group sect,
      resource_group subsect
     PLAN (sect
      WHERE sect.resource_group_type_cd=dservressectioncd
       AND sect.parent_service_resource_cd=dserviceresourcecd
       AND ((sect.root_service_resource_cd+ 0)=0.0))
      JOIN (subsect
      WHERE subsect.parent_service_resource_cd=sect.child_service_resource_cd
       AND subsect.resource_group_type_cd=dservressubsectioncd
       AND ((subsect.root_service_resource_cd+ 0)=0.0))
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ELSEIF (iservreslevelflag=3)
    SELECT INTO "nl:"
     sect.parent_service_resource_cd, subsect.parent_service_resource_cd, subsect
     .child_service_resource_cd
     FROM resource_group sect,
      resource_group subsect
     PLAN (sect
      WHERE sect.resource_group_type_cd=dservressectioncd
       AND sect.root_service_resource_cd=0.0)
      JOIN (subsect
      WHERE subsect.parent_service_resource_cd=sect.child_service_resource_cd
       AND subsect.resource_group_type_cd=dservressubsectioncd
       AND ((subsect.root_service_resource_cd+ 0)=0.0))
     ORDER BY subsect.parent_service_resource_cd, subsect.child_service_resource_cd
     HEAD REPORT
      itestsitecnt = 0, dcurservres = 0.0
     HEAD subsect.parent_service_resource_cd
      dcurservres = subsect.parent_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     HEAD subsect.child_service_resource_cd
      dcurservres = subsect.child_service_resource_cd
      IF (isresourceviewable(dcurservres)=true)
       itestsitecnt += 1
       IF (size(testsites->qual,5) < itestsitecnt)
        nstat = alterlist(testsites->qual,(itestsitecnt+ 5))
       ENDIF
       testsites->qual[itestsitecnt].service_resource_cd = dcurservres, testsites->qual[itestsitecnt]
       .service_resource_disp = uar_get_code_display(dcurservres)
      ENDIF
     FOOT REPORT
      nstat = alterlist(testsites->qual,itestsitecnt)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(testsites->qual,5) > 0)
    RETURN(const_return_security_ok)
   ELSE
    RETURN(const_return_no_security)
   ENDIF
 END ;Subroutine
 DECLARE nsecurityind = i2 WITH protect, noconstant(const_security_on)
 DECLARE nreturnstat = i2 WITH protect, noconstant(const_return_invalid)
 DECLARE first_service_resource = vc WITH protect, noconstant(fillstring(50," "))
 RECORD captions(
   1 patient_result = vc
   1 beg_date = vc
   1 end_date = vc
   1 patient_name = vc
   1 mrn = vc
   1 ordered_procedure = vc
   1 results = vc
   1 accession = vc
   1 detail_procedure = vc
   1 cell_product = vc
   1 corrected = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 rpt_by = vc
   1 end_of_report = vc
   1 testing_site = vc
   1 comment = vc
   1 note = vc
   1 not_on_file = vc
 )
 SET captions->patient_result = uar_i18ngetmessage(i18nhandle,"patient_result",
  "P A T I E N T   R E S U L T   C O R R E C T I O N   R E P O R T")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->patient_name = uar_i18ngetmessage(i18nhandle,"patient_name","PATIENT NAME")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN")
 SET captions->ordered_procedure = uar_i18ngetmessage(i18nhandle,"ordered_procedure",
  "ORDERED PROCEDURE  ")
 SET captions->results = uar_i18ngetmessage(i18nhandle,"results","RESULTS:")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"accession","ACCESSION")
 SET captions->detail_procedure = uar_i18ngetmessage(i18nhandle,"detail_procedure",
  "  DETAIL PROCEDURE")
 SET captions->cell_product = uar_i18ngetmessage(i18nhandle,"cell_product","       CELL/PRODUCT")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected",
  "  CORRECTED(*) / PREVIOUS       DATE   TIME    ID")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_RESULT_CORR"
  )
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->testing_site = uar_i18ngetmessage(i18nhandle,"testing_site","Testing Site: ")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->comment = uar_i18ngetmessage(i18nhandle,"comment","Comment:  ")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note:  ")
 SUBROUTINE check_opt_date_passed(script_name)
   SET ddmmyy_flag = 0
   SET dd_flag = 0
   SET mm_flag = 0
   SET yy_flag = 0
   SET dayentered = 0
   SET monthentered = 0
   SET yearentered = 0
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DAY[",temp_string)))
   IF (temp_pos > 0)
    SET day_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET day_pos = cnvtint(value(findstring("]",day_string)))
    IF (day_pos > 0)
     SET day_nbr = substring(1,(day_pos - 1),day_string)
     IF (trim(day_nbr) > " ")
      SET ddmmyy_flag += 1
      SET dd_flag = 1
      SET dayentered = cnvtreal(day_nbr)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("MONTH[",temp_string)))
    IF (temp_pos > 0)
     SET month_string = substring((temp_pos+ 6),size(temp_string),temp_string)
     SET month_pos = cnvtint(value(findstring("]",month_string)))
     IF (month_pos > 0)
      SET month_nbr = substring(1,(month_pos - 1),month_string)
      IF (trim(month_nbr) > " ")
       SET ddmmyy_flag += 1
       SET mm_flag = 1
       SET monthentered = cnvtreal(month_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("YEAR[",temp_string)))
    IF (temp_pos > 0)
     SET year_string = substring((temp_pos+ 5),size(temp_string),temp_string)
     SET year_pos = cnvtint(value(findstring("]",year_string)))
     IF (year_pos > 0)
      SET year_nbr = substring(1,(year_pos - 1),year_string)
      IF (trim(year_nbr) > " ")
       SET ddmmyy_flag += 1
       SET yy_flag = 1
       SET yearentered = cnvtreal(year_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
     ENDIF
    ENDIF
   ENDIF
   IF (ddmmyy_flag > 1)
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "multi date selection"
    GO TO exit_script
   ENDIF
   IF ((reply->status_data.status="F"))
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    GO TO exit_script
   ENDIF
   IF (dd_flag=1)
    IF (dayentered > 0)
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookahead(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookahead(interval,request->ops_date)
    ELSE
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookbehind(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookbehind(interval,request->ops_date)
    ENDIF
   ELSEIF (mm_flag=1)
    IF (monthentered > 0)
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSEIF (yy_flag=1)
    IF (yearentered > 0)
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO date selection"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_bb_organization(script_name)
   DECLARE norgpos = i2 WITH protect, noconstant(0)
   DECLARE ntemppos = i2 WITH protect, noconstant(0)
   DECLARE ncodeset = i4 WITH protect, constant(278)
   DECLARE sorgname = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE sorgstring = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE dbbmanufcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbsupplcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbclientcd = f8 WITH protect, noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBMANUF",1,dbbmanufcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBSUPPL",1,dbbsupplcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBCLIENT",1,dbbclientcd)
   SET ntemppos = cnvtint(value(findstring("ORG[",temp_string)))
   IF (ntemppos > 0)
    SET sorgstring = substring((ntemppos+ 4),size(temp_string),temp_string)
    SET norgpos = cnvtint(value(findstring("]",sorgstring)))
    IF (norgpos > 0)
     SET sorgname = substring(1,(norgpos - 1),sorgstring)
     IF (trim(sorgname) > " ")
      SELECT INTO "nl:"
       FROM org_type_reltn ot,
        organization o
       PLAN (ot
        WHERE ot.org_type_cd IN (dbbmanufcd, dbbsupplcd, dbbclientcd)
         AND ot.active_ind=1)
        JOIN (o
        WHERE o.org_name_key=trim(cnvtupper(sorgname))
         AND o.active_ind=1)
       DETAIL
        request->organization_id = o.organization_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ELSE
    SET request->organization_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_owner_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OWN[",temp_string)))
   IF (temp_pos > 0)
    SET own_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET own_pos = cnvtint(value(findstring("]",own_string)))
    IF (own_pos > 0)
     SET own_area = substring(1,(own_pos - 1),own_string)
     IF (trim(own_area) > " ")
      SET request->cur_owner_area_cd = cnvtreal(own_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_owner_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_inventory_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("INV[",temp_string)))
   IF (temp_pos > 0)
    SET inv_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET inv_pos = cnvtint(value(findstring("]",inv_string)))
    IF (inv_pos > 0)
     SET inv_area = substring(1,(inv_pos - 1),inv_string)
     IF (trim(inv_area) > " ")
      SET request->cur_inv_area_cd = cnvtreal(inv_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_inv_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_location_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("LOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->address_location_cd = cnvtreal(location_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->address_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_sort_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SORT[",temp_string)))
   IF (temp_pos > 0)
    SET sort_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET sort_pos = cnvtint(value(findstring("]",sort_string)))
    IF (sort_pos > 0)
     SET sort_selection = substring(1,(sort_pos - 1),sort_string)
    ELSE
     SET sort_selection = " "
    ENDIF
   ELSE
    SET sort_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_mode_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("MODE[",temp_string)))
   IF (temp_pos > 0)
    SET mode_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET mode_pos = cnvtint(value(findstring("]",mode_string)))
    IF (mode_pos > 0)
     SET mode_selection = substring(1,(mode_pos - 1),mode_string)
    ELSE
     SET mode_selection = " "
    ENDIF
   ELSE
    SET mode_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_rangeofdays_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("RANGEOFDAYS[",temp_string)))
   IF (temp_pos > 0)
    SET next_string = substring((temp_pos+ 12),size(temp_string),temp_string)
    SET next_pos = cnvtint(value(findstring("]",next_string)))
    SET days_look_ahead = cnvtint(trim(substring(1,(next_pos - 1),next_string)))
    IF (days_look_ahead > 0)
     SET days_look_ahead = days_look_ahead
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse look ahead days"
     GO TO exit_script
    ENDIF
   ELSE
    SET days_look_ahead = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_hrs_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("HRS[",temp_string)))
   IF (temp_pos > 0)
    SET hrs_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET hrs_pos = cnvtint(value(findstring("]",hrs_string)))
    IF (hrs_pos > 0)
     SET num_hrs = substring(1,(hrs_pos - 1),hrs_string)
     IF (trim(num_hrs) > " ")
      IF (cnvtint(trim(num_hrs)) > 0)
       SET hoursentered = cnvtreal(num_hrs)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = script_name
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
       GO TO exit_script
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
     GO TO exit_script
    ENDIF
   ELSE
    SET hoursentered = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_svc_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SVC[",temp_string)))
   IF (temp_pos > 0)
    SET svc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET svc_pos = cnvtint(value(findstring("]",svc_string)))
    SET parm_string = fillstring(100," ")
    SET parm_string = substring(1,(svc_pos - 1),svc_string)
    SET ptr = 1
    SET back_ptr = 1
    SET param_idx = 1
    SET nbr_of_services = size(trim(parm_string))
    SET flag_exit_loop = 0
    FOR (param_idx = 1 TO nbr_of_services)
      SET ptr = findstring(",",parm_string,back_ptr)
      IF (ptr=0)
       SET ptr = (nbr_of_services+ 1)
       SET flag_exit_loop = 1
      ENDIF
      SET parm_len = (ptr - back_ptr)
      SET stat = alterlist(ops_params->qual,param_idx)
      SET ops_params->qual[param_idx].param = trim(substring(back_ptr,value(parm_len),parm_string),3)
      SET back_ptr = (ptr+ 1)
      SET stat = alterlist(request->qual,param_idx)
      SET request->qual[param_idx].service_resource_cd = cnvtreal(ops_params->qual[param_idx].param)
      IF (flag_exit_loop=1)
       SET param_idx = nbr_of_services
      ENDIF
    ENDFOR
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse service resource"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_donation_location(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DLOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->donation_location_cd = cnvtreal(trim(location_cd))
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->donation_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_null_report(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("NULLRPT[",temp_string)))
   IF (temp_pos > 0)
    SET null_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET null_pos = cnvtint(value(findstring("]",null_string)))
    IF (null_pos > 0)
     SET null_selection = substring(1,(null_pos - 1),null_string)
     IF (trim(null_selection)="Y")
      SET request->null_ind = 1
     ELSE
      SET request->null_ind = 0
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse null report indicator"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_outcome_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OUTCOME[",temp_string)))
   IF (temp_pos > 0)
    SET outcome_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",outcome_string)))
    IF (loc_pos > 0)
     SET outcome_cd = substring(1,(loc_pos - 1),outcome_string)
     IF (trim(outcome_cd) > " ")
      SET request->outcome_cd = cnvtreal(outcome_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->outcome_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_facility_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("FACILITY[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 9),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET facility_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(facility_cd) > " ")
      SET request->facility_cd = cnvtreal(facility_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->facility_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_exception_type_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("EXCEPT[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 7),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET exception_type_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(exception_type_cd) > " ")
      IF (trim(exception_type_cd)="ALL")
       SET request->exception_type_cd = 0.0
      ELSE
       SET request->exception_type_cd = cnvtreal(exception_type_cd)
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "no exception type code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "no exception type code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->exception_type_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_misc_functionality(param_name)
   SET temp_pos = 0
   SET status_param = ""
   SET temp_str = concat(param_name,"[")
   SET temp_pos = cnvtint(value(findstring(temp_str,temp_string)))
   IF (temp_pos > 0)
    SET status_string = substring((temp_pos+ textlen(temp_str)),size(temp_string),temp_string)
    SET status_pos = cnvtint(value(findstring("]",status_string)))
    IF (status_pos > 0)
     SET status_param = substring(1,(status_pos - 1),status_string)
     IF (trim(status_param) > " ")
      SET ops_param_status = cnvtint(status_param)
     ENDIF
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 DECLARE commenttype_codeset = i4
 DECLARE chartabletype_cd = f8
 DECLARE notetype_cd = f8
 DECLARE rpt_cnt = i2
 DECLARE isqueue = i2
 DECLARE doldproductid = f8 WITH noconstant(0.0)
 DECLARE reportbyusername = vc WITH protect, noconstant("")
 SET reportbyusername = get_username(reqinfo->updt_id)
 SET result_status_code_set = 1901
 SET corrected_cdf_meaning = "CORRECTED"
 SET old_corrected_cdf_meaning = "OLDCORRECTED"
 SET verified_cdf_meaning = "VERIFIED"
 SET old_verified_cdf_meaning = "OLDVERIFIED"
 SET scorrected_inreview_cdf = "CORRINREV"
 SET soldcorrected_inreview_cdf = "OLDCORRINREV"
 SET alias_type_code_set = 319
 SET mrn_alias_cdf_meaning = "MRN"
 SET activity_type_code_set = 106
 SET bb_activity_cdf_meaning = "BB"
 SET product_state_code_set = 1610
 SET in_progress_cdf_meaning = "16"
 SET commenttype_codeset = 14
 SET count1 = 0
 SET detail_cnt = 0
 SET report_complete_ind = "N"
 SET corrected_status_cd = 0.0
 SET old_corrected_status_cd = 0.0
 SET verified_status_cd = 0.0
 SET old_verified_status_cd = 0.0
 SET dcorrinreview_cd = 0.0
 SET doldcorrinreview_cd = 0.0
 SET mrn_alias_type_cd = 0.0
 SET bb_activity_type_cd = 0.0
 SET in_progress_event_type_cd = 0.0
 SET line = fillstring(125,"_")
 SET result_cnt = 0
 SET rslt = 0
 SET rslt_row = 0
 SET name_full_formatted = fillstring(25," ")
 SET alias = fillstring(20," ")
 SET accession = fillstring(20," ")
 SET order_mnemonic = fillstring(20," ")
 SET mnemonic = fillstring(15," ")
 SET cell_product = fillstring(26," ")
 SET first_service_resource = fillstring(50," ")
 SET ops_ind = "N"
 SET ops_cnvt_dt_tm = cnvtdatetime(sysdate)
 SET chartabletype_cd = 0.0
 SET notetype_cd = 0.0
 SET ord_r_cnt = 0
 SET r_cnt = 0
 SET rpt_cnt = 0
 SET gsub_code_value = 0.0
 SET corrected_status_cd = 0.0
 CALL get_code_value(result_status_code_set,corrected_cdf_meaning)
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get corrected status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get corrected status code_value"
  GO TO exit_script
 ELSE
  SET corrected_status_cd = gsub_code_value
 ENDIF
 SET old_corrected_status_cd = 0.0
 CALL get_code_value(result_status_code_set,old_corrected_cdf_meaning)
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get old_corrected status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get old_corrected status code_value"
  GO TO exit_script
 ELSE
  SET old_corrected_status_cd = gsub_code_value
 ENDIF
 SET verified_status_cd = 0.0
 CALL get_code_value(result_status_code_set,verified_cdf_meaning)
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get verified status code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get verified status code_value"
  GO TO exit_script
 ELSE
  SET verified_status_cd = gsub_code_value
 ENDIF
 SET old_verified_status_cd = 0.0
 CALL get_code_value(result_status_code_set,old_verified_cdf_meaning)
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get old_verified status code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get old_verified status code_value"
  GO TO exit_script
 ELSE
  SET old_verified_status_cd = gsub_code_value
 ENDIF
 SET dcorrinreview_cd = 0.0
 CALL get_code_value(result_status_code_set,nullterm(scorrected_inreview_cdf))
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get Corr-InReview status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get Corr-InReview status code_value"
  GO TO exit_script
 ELSE
  SET dcorrinreview_cd = gsub_code_value
 ENDIF
 SET doldcorrinreview_cd = 0.0
 CALL get_code_value(result_status_code_set,nullterm(soldcorrected_inreview_cdf))
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get OldCorr-InReview status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get OldCorr-InReview status code_value"
  GO TO exit_script
 ELSE
  SET doldcorrinreview_cd = gsub_code_value
 ENDIF
 SET mrn_alias_type_cd = 0.0
 CALL get_code_value(alias_type_code_set,mrn_alias_cdf_meaning)
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get mrn_alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get mrn alias type code_value"
  GO TO exit_script
 ELSE
  SET mrn_alias_type_cd = gsub_code_value
 ENDIF
 SET bb_activity_type_cd = 0.0
 CALL get_code_value(activity_type_code_set,bb_activity_cdf_meaning)
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get bb_activity_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get mrn alias type code_value"
  GO TO exit_script
 ELSE
  SET bb_activity_type_cd = gsub_code_value
 ENDIF
 SET in_progress_event_type_cd = 0.0
 CALL get_code_value(product_state_code_set,in_progress_cdf_meaning)
 IF (gsub_code_value=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get in_progress state"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get in_progress product state code_value"
  GO TO exit_script
 ELSE
  SET in_progress_event_type_cd = gsub_code_value
 ENDIF
 SET stat = uar_get_meaning_by_codeset(commenttype_codeset,"RES COMMENT",1,chartabletype_cd)
 SET stat = uar_get_meaning_by_codeset(commenttype_codeset,"RES NOTE",1,notetype_cd)
 IF (((chartabletype_cd=0.0) OR (notetype_cd=0.0)) )
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get result comment or note"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get result chartable or non-chartable comment type code_value"
  GO TO exit_script
 ENDIF
 SET nsecurityind = const_security_on
 IF (size(trim(request->batch_selection),1) > 0)
  SET nsecurityind = const_security_off
  SET ops_ind = "Y"
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_result_corr")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_location_cd("bbt_rpt_result_corr")
  CALL check_svc_opt("bbt_rpt_result_corr")
 ENDIF
 SET sub_get_location_name = fillstring(25," ")
 SET sub_get_location_address1 = fillstring(100," ")
 SET sub_get_location_address2 = fillstring(100," ")
 SET sub_get_location_address3 = fillstring(100," ")
 SET sub_get_location_address4 = fillstring(100," ")
 SET sub_get_location_citystatezip = fillstring(100," ")
 SET sub_get_location_country = fillstring(100," ")
 IF ((request->address_location_cd != 0))
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",code_cnt,addr_type_cd)
  IF (addr_type_cd=0.0)
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr, a.street_addr2, a.street_addr3,
    a.street_addr4, a.city, a.state,
    a.zipcode, a.country, l.location_cd
    FROM address a
    WHERE a.active_ind=1
     AND a.address_type_cd=addr_type_cd
     AND a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=request->address_location_cd)
    DETAIL
     sub_get_location_name = uar_get_code_display(request->address_location_cd),
     sub_get_location_address1 = a.street_addr, sub_get_location_address2 = a.street_addr2,
     sub_get_location_address3 = a.street_addr3, sub_get_location_address4 = a.street_addr4,
     sub_get_location_citystatezip = concat(trim(a.city),", ",trim(a.state),"  ",trim(a.zipcode)),
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
 IF (initservresroutine(nsecurityind)=const_return_invalid)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "InitServResRoutine()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Status Returned."
  GO TO exit_script
 ENDIF
 SET nreturnstat = determineservresaccess(request->qual[1].service_resource_cd)
 IF (nreturnstat=const_return_invalid)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Service Resource"
  GO TO exit_script
 ELSEIF (nreturnstat=const_return_no_security)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No security access for specified Service Resource"
  GO TO exit_script
 ENDIF
 SET first_service_resource = uar_get_code_display(request->qual[1].service_resource_cd)
 SELECT INTO "nl:"
  per.person_id, dta_mnemonic = uar_get_code_display(r.task_assay_cd), sort_name_full_formatted =
  substring(1,50,per.name_full_formatted)"##########################",
  alias_exists = decode(d_ea.seq,"Y","N"), r.order_id, aor.accession_id,
  sort_accession = aor.accession"####################", o.order_mnemonic, r.result_id,
  r_result_status_disp = uar_get_code_display(r.result_status_cd)"###############", r.bb_result_id,
  r_pr.perform_result_id,
  pr_result_status_disp = uar_get_code_display(r_pr.result_status_cd)"###############", r_re
  .event_sequence, product_nbr = decode(p_boc.product_id,p_boc.product_nbr,cv_boc.code_value,cv_boc
   .display,p_pe.product_id,
   p_pe.product_nbr," ")"####################",
  product_sub_nbr = decode(p_boc.product_id,p_boc.product_sub_nbr,cv_boc.code_value," ",p_pe
   .product_id,
   p_pe.product_sub_nbr," ")"#####", supplier_prefix = decode(bp_boc.seq,bp_boc.supplier_prefix,bp_pe
   .seq,bp_pe.supplier_prefix,"     "), product_exists = decode(pe.seq,"PE_Y",boc.seq,"BOC_Y","N"),
  order_type = uar_get_code_meaning(sd.bb_processing_cd)
  FROM result r,
   (dummyt d_ts  WITH seq = value(size(testsites->qual,5))),
   perform_result r_pr,
   result_event r_re,
   order_catalog oc,
   accession_order_r aor,
   orders o,
   service_directory sd,
   person per,
   (dummyt d_ea  WITH seq = 1),
   encntr_alias ea,
   (dummyt d  WITH seq = 1),
   bb_order_cell boc,
   (dummyt d_boc  WITH seq = 1),
   product p_boc,
   (dummyt d_bp_boc  WITH seq = 1),
   blood_product bp_boc,
   code_value cv_boc,
   (dummyt d_pe  WITH seq = 1),
   product_event pe,
   product p_pe,
   (dummyt d_bp_pe  WITH seq = 1),
   blood_product bp_pe
  PLAN (r_re
   WHERE r_re.event_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND r_re.event_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND r_re.event_type_cd IN (corrected_status_cd, dcorrinreview_cd))
   JOIN (r
   WHERE r.result_id=r_re.result_id)
   JOIN (oc
   WHERE oc.catalog_cd=r.catalog_cd
    AND oc.activity_type_cd=bb_activity_type_cd)
   JOIN (o
   WHERE o.order_id=r.order_id
    AND o.person_id != null
    AND o.person_id > 0.0)
   JOIN (sd
   WHERE sd.catalog_cd=o.catalog_cd)
   JOIN (d_ts)
   JOIN (r_pr
   WHERE r_pr.perform_result_id=r_re.perform_result_id
    AND (r_pr.service_resource_cd=testsites->qual[d_ts.seq].service_resource_cd))
   JOIN (aor
   WHERE aor.order_id=r.order_id
    AND aor.primary_flag=0)
   JOIN (per
   WHERE per.person_id=o.person_id)
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1)
   JOIN (d_pe
   WHERE d_pe.seq=1)
   JOIN (pe
   WHERE pe.order_id=r.order_id
    AND pe.bb_result_id=r.bb_result_id
    AND pe.event_type_cd=in_progress_event_type_cd)
   JOIN (p_pe
   WHERE p_pe.product_id=pe.product_id)
   JOIN (d_bp_pe
   WHERE d_bp_pe.seq=1)
   JOIN (bp_pe
   WHERE bp_pe.product_id=p_pe.product_id)
   JOIN (d
   WHERE d.seq=1)
   JOIN (boc
   WHERE r.bb_result_id != 0.0
    AND r.bb_result_id != null
    AND boc.order_id=r.order_id
    AND boc.bb_result_id=r.bb_result_id)
   JOIN (d_boc
   WHERE d_boc.seq=1)
   JOIN (((p_boc
   WHERE p_boc.product_id=boc.product_id
    AND boc.product_id != null
    AND boc.product_id > 0.0)
   JOIN (d_bp_boc
   WHERE d_bp_boc.seq=1)
   JOIN (bp_boc
   WHERE bp_boc.product_id=p_boc.product_id)
   ) ORJOIN ((cv_boc
   WHERE boc.cell_cd != 0.0
    AND boc.cell_cd != null
    AND cv_boc.code_value=boc.cell_cd
    AND cv_boc.active_ind=1
    AND cv_boc.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND cv_boc.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ))
  ORDER BY r.result_id
  HEAD REPORT
   stat = alterlist(ord_r_rec->ord_r,20), encntr_alias = fillstring(20," ")
  HEAD r.result_id
   ord_r_cnt += 1
   IF (mod(ord_r_cnt,20)=1
    AND ord_r_cnt != 1)
    stat = alterlist(ord_r_rec->ord_r,(ord_r_cnt+ 19))
   ENDIF
   ord_r_rec->ord_r[ord_r_cnt].order_id = o.order_id, ord_r_rec->ord_r[ord_r_cnt].result_id = r
   .result_id, ord_r_rec->ord_r[ord_r_cnt].task_assay_cd = r.task_assay_cd,
   ord_r_rec->ord_r[ord_r_cnt].person_id = o.person_id, ord_r_rec->ord_r[ord_r_cnt].encntr_id = o
   .encntr_id, ord_r_rec->ord_r[ord_r_cnt].patient_name = sort_name_full_formatted
   IF (alias_exists="Y"
    AND ea.encntr_alias_id > 0)
    encntr_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSE
    encntr_alias = captions->not_on_file
   ENDIF
   ord_r_rec->ord_r[ord_r_cnt].encntr_alias = encntr_alias, ord_r_rec->ord_r[ord_r_cnt].accession =
   cnvtacc(sort_accession), ord_r_rec->ord_r[ord_r_cnt].order_mnemonic = substring(1,20,o
    .order_mnemonic),
   ord_r_rec->ord_r[ord_r_cnt].detail_mnemonic = dta_mnemonic
   IF (product_exists IN ("PE_Y", "BOC_Y"))
    ord_r_rec->ord_r[ord_r_cnt].cell_product = concat(trim(supplier_prefix,3),trim(product_nbr,3)," ",
     trim(product_sub_nbr,3))
   ELSE
    ord_r_rec->ord_r[ord_r_cnt].cell_product = fillstring(26," ")
   ENDIF
   IF (order_type="XM")
    ord_r_rec->ord_r[ord_r_cnt].xm_order_ind = 1, ord_r_rec->ord_r[ord_r_cnt].xm_product_id = pe
    .product_id
   ELSE
    ord_r_rec->ord_r[ord_r_cnt].xm_order_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(ord_r_rec->ord_r,ord_r_cnt)
  WITH nocounter, outerjoin(d_ea), dontcare(ea),
   outerjoin(d_pe), dontcare(pe), outerjoin(d),
   dontcare(bp_boc), dontcare(bp_pe)
 ;end select
 SELECT INTO "nl:"
  table_ind = decode(re.seq,"4re    ",lt.seq,"3lt    ",cv_rcs.seq,
   "2cv_rcs",pr.seq,"1pr    ","xxxxxx"), result_type_mean = uar_get_code_meaning(pr.result_type_cd),
  alpha_result = trim(pr.result_value_alpha),
  text_results = pr.ascii_text, date_result = format(pr.result_value_dt_tm,"@DATECONDENSED;;d"),
  date_time_result = format(pr.result_value_dt_tm,"@DATETIMECONDENSED;;d"),
  result_code_set_disp = trim(uar_get_code_display(pr.result_code_set_cd)), result_id = ord_r_rec->
  ord_r[d.seq].result_id, pr.perform_result_id,
  norm_display = uar_get_code_display(pr.normal_cd), crit_display = uar_get_code_display(pr
   .critical_cd), notify_disp = uar_get_code_display(pr.notify_cd),
  revw_display = uar_get_code_display(pr.review_cd), delta_display = uar_get_code_display(pr.delta_cd
   )
  FROM (dummyt d  WITH seq = value(ord_r_cnt)),
   perform_result pr,
   (dummyt d_pr  WITH seq = 1),
   (dummyt d_re  WITH seq = 1),
   code_value cv_rcs,
   long_text lt,
   result_event re,
   prsnl pnl
  PLAN (d)
   JOIN (pr
   WHERE (pr.result_id=ord_r_rec->ord_r[d.seq].result_id)
    AND pr.result_status_cd IN (corrected_status_cd, old_corrected_status_cd, old_verified_status_cd,
   dcorrinreview_cd, doldcorrinreview_cd))
   JOIN (((d_pr
   WHERE d_pr.seq=1)
   ) ORJOIN ((d_re
   WHERE d_re.seq=1)
   JOIN (((cv_rcs
   WHERE cv_rcs.code_value=pr.result_code_set_cd
    AND pr.result_code_set_cd != 0
    AND pr.result_code_set_cd != null
    AND cv_rcs.active_ind=1
    AND cv_rcs.begin_effective_dt_tm <= cnvtdatetime(sysdate)
    AND cv_rcs.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ) ORJOIN ((((lt
   WHERE lt.long_text_id=pr.long_text_id
    AND pr.long_text_id != null
    AND pr.long_text_id > 0)
   ) ORJOIN ((re
   WHERE re.result_id=pr.result_id
    AND re.perform_result_id=pr.perform_result_id
    AND ((re.event_type_cd=pr.result_status_cd) OR (((pr.result_status_cd=old_corrected_status_cd
    AND re.event_type_cd=corrected_status_cd) OR (((pr.result_status_cd=old_verified_status_cd
    AND re.event_type_cd=verified_status_cd) OR (pr.result_status_cd=doldcorrinreview_cd
    AND re.event_type_cd=dcorrinreview_cd)) )) )) )
   JOIN (pnl
   WHERE pnl.person_id=re.event_personnel_id)
   )) )) ))
  ORDER BY pr.result_id, pr.perform_result_id, table_ind
  HEAD REPORT
   stat = alterlist(r_rec->r,(ord_r_cnt * 2)), rtf_out_text = fillstring(32000," "),
   SUBROUTINE remove_rtf(sub_rtf_text)
     rtf_out_text = fillstring(32000," "), len_rtf_out_text = 0,
     CALL uar_rtf(sub_rtf_text,size(sub_rtf_text),rtf_out_text,size(rtf_out_text),len_rtf_out_text,0)
   END ;Subroutine report
   ,
   SUBROUTINE remove_rtf2(sub_rtf_text)
     rtf_out_text = fillstring(32000," "), len_rtf_out_text = 0,
     CALL uar_rtf2(sub_rtf_text,size(sub_rtf_text),rtf_out_text,size(rtf_out_text),len_rtf_out_text,0
     )
   END ;Subroutine report
  HEAD pr.perform_result_id
   r_cnt += 1
   IF (mod(r_cnt,10)=1
    AND r_cnt != 10)
    stat = alterlist(r_rec->r,(r_cnt+ 9))
   ENDIF
   r_rec->r[r_cnt].result_id = pr.result_id, r_rec->r[r_cnt].perform_result_id = pr.perform_result_id,
   r_rec->r[r_cnt].result_status_cd = pr.result_status_cd,
   r_rec->r[r_cnt].service_resource_cd = pr.service_resource_cd, r_rec->r[r_cnt].task_assay_cd =
   ord_r_rec->ord_r[d.seq].task_assay_cd, resultflagstr = bldresultflagstr(norm_display,crit_display,
    revw_display,delta_display,"N",
    "N","N",notify_disp)
   IF (size(trim(resultflagstr),3) > 0)
    r_rec->r[r_cnt].result_flag_str = resultflagstr
   ENDIF
  HEAD table_ind
   IF (table_ind="1pr    ")
    IF (result_type_mean IN ("1", "7"))
     IF (pr.long_text_id=0)
      r_rec->r[r_cnt].result = text_results
     ENDIF
    ELSEIF (((result_type_mean="2") OR (result_type_mean="4")) )
     IF (size(trim(alpha_result,1)) > 24)
      r_rec->r[r_cnt].result = concat(substring(1,24,alpha_result),"...")
     ELSE
      r_rec->r[r_cnt].result = alpha_result
     ENDIF
    ELSEIF (result_type_mean IN ("3", "8"))
     r_rec->r[r_cnt].numeric_result_ind = 1, r_rec->r[r_cnt].numeric_result = pr.result_value_numeric,
     r_rec->r[r_cnt].less_great_flag = pr.less_great_flag
    ELSEIF (result_type_mean="6")
     r_rec->r[r_cnt].result = date_result
    ELSEIF (result_type_mean="11")
     r_rec->r[r_cnt].result = date_time_result
    ELSEIF (result_type_mean="9")
     IF (size(trim(result_code_set_disp,1)) > 24)
      r_rec->r[r_cnt].result = concat(substring(1,24,result_code_set_disp),"...")
     ELSE
      r_rec->r[r_cnt].result = result_code_set_disp
     ENDIF
    ELSE
     r_rec->r[r_cnt].result = "<blank>"
    ENDIF
   ELSEIF (table_ind="2cv_rcs"
    AND cnvtreal(pr.result_code_set_cd) > 0)
    r_rec->r[r_cnt].result = cv_rcs.display
   ELSEIF (table_ind="3lt    "
    AND cnvtreal(pr.long_text_id) > 0)
    r_rec->r[r_cnt].result = trim(lt.long_text)
   ELSEIF (table_ind="4re    ")
    r_rec->r[r_cnt].result_dt_tm = re.event_dt_tm, r_rec->r[r_cnt].result_username = pnl.username
   ENDIF
  FOOT  pr.perform_result_id
   IF (trim(r_rec->r[r_cnt].result) <= "")
    r_rec->r[r_cnt].result = "result unknown"
   ENDIF
  FOOT REPORT
   stat = alterlist(r_rec->r,r_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dm.task_assay_cd, dm.service_resource_cd, data_map_exists = decode(dm.seq,"Y","N"),
  rg_exists = decode(rg.seq,"Y","N")
  FROM (dummyt d  WITH seq = value(r_cnt)),
   (dummyt d_dm  WITH seq = 1),
   data_map dm,
   (dummyt d_rg  WITH seq = 1),
   resource_group rg
  PLAN (d
   WHERE d.seq <= r_cnt
    AND (r_rec->r[d.seq].result_id > 0.0)
    AND (r_rec->r[d.seq].numeric_result_ind=1))
   JOIN (d_dm
   WHERE d_dm.seq=1)
   JOIN (dm
   WHERE (dm.task_assay_cd=r_rec->r[d.seq].task_assay_cd)
    AND dm.data_map_type_flag=0
    AND dm.active_ind=1)
   JOIN (d_rg
   WHERE d_rg.seq=1)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=dm.service_resource_cd
    AND (rg.child_service_resource_cd=r_rec->r[d.seq].service_resource_cd)
    AND rg.resource_group_type_cd=dservressubsectioncd
    AND ((rg.root_service_resource_cd+ 0)=0.0))
  ORDER BY d.seq, d_dm.seq
  HEAD d.seq
   arg_min_digits = 1, arg_max_digits = 8, arg_min_dec_places = 0,
   data_map_level = 0
  HEAD d_dm.seq
   IF (data_map_exists="Y")
    IF (data_map_level <= 2
     AND dm.service_resource_cd > 0
     AND (dm.service_resource_cd=r_rec->r[d.seq].service_resource_cd))
     data_map_level = 3, arg_min_digits = dm.min_digits, arg_max_digits = dm.max_digits,
     arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level <= 1
     AND dm.service_resource_cd > 0.0
     AND rg_exists="Y"
     AND rg.parent_service_resource_cd=dm.service_resource_cd
     AND (rg.child_service_resource_cd=r_rec->r[d.seq].service_resource_cd))
     data_map_level = 2, arg_min_digits = dm.min_digits, arg_max_digits = dm.max_digits,
     arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level=0
     AND dm.service_resource_cd=0)
     data_map_level = 1, arg_min_digits = dm.min_digits, arg_max_digits = dm.max_digits,
     arg_min_dec_places = dm.min_decimal_places
    ENDIF
   ENDIF
  FOOT  d.seq
   arg_less_great_flag = r_rec->r[d.seq].less_great_flag, arg_raw_value = r_rec->r[d.seq].
   numeric_result, numeric_result = fillstring(17," "),
   numeric_result = uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
    arg_less_great_flag,arg_raw_value), r_rec->r[d.seq].result = trim(numeric_result)
  WITH nocounter, outerjoin(d_dm), outerjoin(d_rg)
 ;end select
 SELECT INTO "nl:"
  rc.result_id, rc.action_sequence, lt.long_text_id,
  lt_long_text = substring(1,32000,lt.long_text)
  FROM (dummyt d1  WITH seq = value(r_cnt)),
   result_comment rc,
   long_text lt
  PLAN (d1
   WHERE d1.seq <= r_cnt)
   JOIN (rc
   WHERE (rc.result_id=r_rec->r[d1.seq].result_id)
    AND ((rc.comment_type_cd=chartabletype_cd) OR (rc.comment_type_cd=notetype_cd)) )
   JOIN (lt
   WHERE rc.long_text_id=lt.long_text_id
    AND lt.long_text_id > 0)
  ORDER BY rc.result_id, rc.comment_type_cd, rc.action_sequence DESC
  HEAD REPORT
   row + 0
  HEAD rc.result_id
   row + 0
  HEAD rc.comment_type_cd
   IF (rc.comment_type_cd=chartabletype_cd)
    r_rec->r[d1.seq].comment_text = lt_long_text
   ELSEIF (rc.comment_type_cd=notetype_cd)
    r_rec->r[d1.seq].note_text = lt_long_text
   ENDIF
  WITH nocounter
 ;end select
 SET select_ok_ind = 0
 SET doldproductid = 0.0
 EXECUTE cpm_create_file_name_logical "bbt_result_cor", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  person_id = ord_r_rec->ord_r[d_or.seq].person_id, encntr_id = ord_r_rec->ord_r[d_or.seq].encntr_id,
  patient_name = ord_r_rec->ord_r[d_or.seq].patient_name,
  encntr_alias = ord_r_rec->ord_r[d_or.seq].encntr_alias, order_id = ord_r_rec->ord_r[d_or.seq].
  order_id, accession = ord_r_rec->ord_r[d_or.seq].accession,
  result_id = ord_r_rec->ord_r[d_or.seq].result_id, perform_result_id = r_rec->r[d_r.seq].
  perform_result_id, test_site = uar_get_code_display(r_rec->r[d_r.seq].service_resource_cd)
  FROM (dummyt d_or  WITH seq = value(ord_r_cnt)),
   (dummyt d_r  WITH seq = value(r_cnt))
  PLAN (d_or
   WHERE (ord_r_rec->ord_r[d_or.seq].result_id > 0.0))
   JOIN (d_r
   WHERE (r_rec->r[d_r.seq].result_id=ord_r_rec->ord_r[d_or.seq].result_id))
  ORDER BY test_site, patient_name, person_id,
   encntr_id, accession, order_id,
   result_id, perform_result_id DESC
  HEAD REPORT
   rpt_row = 0, rslt_row = 0, beg_dt_tm = cnvtdatetime(request->beg_dt_tm),
   end_dt_tm = cnvtdatetime(request->end_dt_tm), rslt_ln = 0, rslt_ln_cnt = 0,
   rslt_ln_len = 0, rslt_text = fillstring(54," "), long_text_page_wrap_ind = "N",
   detail_cnt = 0, report_complete_ind = "N", select_ok_ind = 0,
   status_disp = fillstring(21," "), first_page = "Y"
  HEAD PAGE
   CALL center(captions->patient_result,1,125), inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(
    inc_i18nhandle,curprog,"",curcclrev),
   row 0
   IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
    inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
     "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
   ELSE
    col 1, sub_get_location_name
   ENDIF
   row + 1
   IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
    IF (sub_get_location_address1 != " ")
     col 1, sub_get_location_address1, row + 1
    ENDIF
    IF (sub_get_location_address2 != " ")
     col 1, sub_get_location_address2, row + 1
    ENDIF
    IF (sub_get_location_address3 != " ")
     col 1, sub_get_location_address3, row + 1
    ENDIF
    IF (sub_get_location_address4 != " ")
     col 1, sub_get_location_address4, row + 1
    ENDIF
    IF (sub_get_location_citystatezip != ",   ")
     col 1, sub_get_location_citystatezip, row + 1
    ENDIF
    IF (sub_get_location_country != " ")
     col 1, sub_get_location_country, row + 1
    ENDIF
   ENDIF
   new_page = "Y", rpt_row = row, row rpt_row,
   col 34, captions->beg_date, col 50,
   beg_dt_tm"@SHORTDATE;;d", col 59, beg_dt_tm"@TIMENOSECONDS;;m",
   col 73, captions->end_date, col 86,
   end_dt_tm"@SHORTDATE;;d", col 95, end_dt_tm"@TIMENOSECONDS;;m",
   rpt_row += 1, row rpt_row, col 1,
   captions->testing_site
   IF (textlen(trim(test_site))=0)
    col 15, first_service_resource
   ELSE
    col 15, test_site
   ENDIF
   rpt_row += 2, row rpt_row, col 001,
   captions->patient_name, rpt_row += 1, row rpt_row,
   col 002, captions->mrn, col 027,
   captions->ordered_procedure, col 075, captions->results,
   rpt_row += 1, row rpt_row, col 003,
   captions->accession, col 027, captions->detail_procedure,
   col 048, captions->cell_product, col 075,
   captions->corrected, rpt_row += 1, row rpt_row,
   col 001, "-------------------------", col 027,
   "--------------------", col 048, "--------------------------",
   col 075, "---------------------------------------------------"
  HEAD test_site
   IF (first_page="N")
    BREAK
   ELSE
    first_page = "N"
   ENDIF
  HEAD person_id
   new_person = "Y", pr_patient_name = ord_r_rec->ord_r[d_or.seq].patient_name, pr_encntr_alias =
   ord_r_rec->ord_r[d_or.seq].encntr_alias,
   rslt_row += 2
  HEAD accession
   new_accession = "Y", pr_accession = ord_r_rec->ord_r[d_or.seq].accession
   IF (new_person != "Y")
    rslt_row += 1
   ENDIF
  HEAD order_id
   new_order = "Y", doldproductid = 0.0, pr_order_mnemonic = ord_r_rec->ord_r[d_or.seq].
   order_mnemonic
   IF (new_accession != "Y")
    rslt_row += 1
   ENDIF
  HEAD result_id
   new_result = "Y", result_cnt = 0, stat = alterlist(result->resultlist,5),
   rslt_row += 1, pr_detail_mnemonic = ord_r_rec->ord_r[d_or.seq].detail_mnemonic, pr_cell_product =
   ord_r_rec->ord_r[d_or.seq].cell_product
  HEAD perform_result_id
   IF ((r_rec->r[d_r.seq].result_id > 0))
    result_cnt += 1
    IF (mod(result_cnt,5)=1
     AND result_cnt != 1)
     stat = alterlist(result->resultlist,(result_cnt+ 4))
    ENDIF
    IF (((new_result != "Y") OR (new_result="Y"
     AND result_cnt > 1)) )
     rslt_row += 1
    ENDIF
    IF (trim(r_rec->r[d_r.seq].result_flag_str) > "")
     result->resultlist[result_cnt].result = concat(r_rec->r[d_r.seq].result," ",r_rec->r[d_r.seq].
      result_flag_str)
    ELSE
     result->resultlist[result_cnt].result = r_rec->r[d_r.seq].result
    ENDIF
    result->resultlist[result_cnt].comment_text = r_rec->r[d_r.seq].comment_text, result->resultlist[
    result_cnt].note_text = r_rec->r[d_r.seq].note_text
    IF ((r_rec->r[d_r.seq].result_status_cd=corrected_status_cd))
     result->resultlist[result_cnt].result_corrected_ind = "*"
    ELSE
     result->resultlist[result_cnt].result_corrected_ind = " "
    ENDIF
    IF (size(trim(result->resultlist[result_cnt].result,1)) > 30)
     rslt_row += 1
    ENDIF
    IF (size(trim(result->resultlist[result_cnt].result,1)) > 54)
     rslt_row += 1
    ENDIF
    result->resultlist[result_cnt].result_dt_tm = cnvtdatetime(r_rec->r[d_r.seq].result_dt_tm),
    result->resultlist[result_cnt].result_username = r_rec->r[d_r.seq].result_username, result->
    resultlist[result_cnt].result_status_cd = r_rec->r[d_r.seq].result_status_cd
   ENDIF
  FOOT  result_id
   IF ((((rpt_row+ rslt_row)+ 1) >= 58))
    BREAK
   ENDIF
   IF (new_page="Y")
    new_page = "N"
    IF ("N" IN (new_person, new_accession, new_order)
     AND (ord_r_rec->ord_r[d_or.seq].xm_product_id != doldproductid)
     AND (ord_r_rec->ord_r[d_or.seq].xm_order_ind=1))
     rpt_row += 1
    ENDIF
   ELSE
    rpt_row += 1
   ENDIF
   IF (new_person="Y")
    rpt_row += 1, row rpt_row, col 001,
    pr_patient_name, rpt_row += 1, row rpt_row,
    col 002, pr_encntr_alias
   ENDIF
   IF (new_accession="Y")
    rpt_row += 1, row rpt_row, col 003,
    pr_accession
   ENDIF
   new_person = "N"
   IF (new_order="Y")
    new_order = "N"
    IF (new_accession != "Y")
     rpt_row += 1
    ENDIF
    row rpt_row, col 027, pr_order_mnemonic
   ENDIF
   IF ((ord_r_rec->ord_r[d_or.seq].xm_product_id != doldproductid))
    IF ((ord_r_rec->ord_r[d_or.seq].xm_order_ind=1))
     row rpt_row, col 027, pr_order_mnemonic,
     row rpt_row, col 048, pr_cell_product
    ENDIF
    doldproductid = ord_r_rec->ord_r[d_or.seq].xm_product_id
   ENDIF
   new_accession = "N"
   IF (new_result="Y")
    new_result = "N", rpt_row += 1, row rpt_row,
    col 029, pr_detail_mnemonic
    IF ((ord_r_rec->ord_r[d_or.seq].xm_order_ind=0))
     row rpt_row, col 048, pr_cell_product
    ENDIF
   ENDIF
   FOR (rslt = 1 TO cnvtint(result_cnt))
     IF (rslt != 1)
      rpt_row += 1
     ENDIF
     row rpt_row, col 075, result->resultlist[rslt].result_corrected_ind,
     rslt_len = cnvtint(size(trim(result->resultlist[rslt].result,1))), rslt_ln_cnt = cnvtint((
      rslt_len/ 54))
     IF (rslt_ln_cnt < 1)
      rslt_ln_cnt = 1
     ENDIF
     IF (rslt_ln_cnt <= 1)
      IF (rpt_row >= 58)
       BREAK
      ENDIF
      row rpt_row, col 077, result->resultlist[rslt].result
     ELSE
      first_row = "Y",
      CALL rtf_to_text(trim(result->resultlist[rslt].result),1,54)
      FOR (q_cnt = 1 TO size(tmptext->qual,5))
        IF (rpt_row >= 58)
         BREAK
         IF (first_row="Y")
          rpt_row += 1
         ENDIF
        ENDIF
        IF (first_row="Y")
         first_row = "N"
        ELSE
         rpt_row += 1
        ENDIF
        row rpt_row, col 77, tmptext->qual[q_cnt].text
        IF (q_cnt=size(tmptext->qual,5))
         IF (size(tmptext->qual[q_cnt].text) > 30)
          rpt_row += 1
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF ((result->resultlist[rslt].result_status_cd=dcorrinreview_cd))
      status_disp = concat("<<< ",trim(uar_get_code_display(dcorrinreview_cd))," >>>"), row rpt_row,
      col 105,
      status_disp
     ELSE
      row rpt_row, col 105, result->resultlist[rslt].result_dt_tm"@SHORTDATE;;d",
      col 114, result->resultlist[rslt].result_dt_tm"@TIMENOSECONDS;;m", col 120,
      result->resultlist[rslt].result_username"##########"
     ENDIF
     IF (trim(result->resultlist[rslt].comment_text) > "")
      first_row = "Y",
      CALL rtf_to_text(result->resultlist[rslt].comment_text,1,91)
      FOR (q_cnt = 1 TO size(tmptext->qual,5))
        IF (rpt_row >= 58)
         BREAK
        ENDIF
        rpt_row += 1, row rpt_row
        IF (first_row="Y")
         first_row = "N", col 30, captions->comment
        ENDIF
        col 40, tmptext->qual[q_cnt].text
      ENDFOR
     ENDIF
     IF (trim(result->resultlist[rslt].note_text) > "")
      first_row = "Y",
      CALL rtf_to_text(result->resultlist[rslt].note_text,1,91)
      FOR (q_cnt = 1 TO size(tmptext->qual,5))
        IF (rpt_row >= 58)
         BREAK
        ENDIF
        rpt_row += 1, row rpt_row
        IF (first_row="Y")
         first_row = "N", col 30, captions->note
        ENDIF
        col 40, tmptext->qual[q_cnt].text
      ENDFOR
     ENDIF
   ENDFOR
   IF (long_text_page_wrap_ind="Y")
    long_text_page_wrap_ind = "N", rpt_row += 1
   ENDIF
   rslt_row = 0, detail_cnt += 1
  FOOT PAGE
   row 59, col 001, line,
   row + 1, col 001, captions->report_id,
   col 060, captions->page_no, col 067,
   curpage"###", col 103, captions->printed,
   col 112, curdate"@SHORTDATE;;d", col 121,
   curtime"@TIMENOSECONDS;;m", row + 1, col 108,
   captions->rpt_by, col 112, reportbyusername"##############"
  FOOT REPORT
   row 62, col 053, captions->end_of_report,
   report_complete_ind = "Y", select_ok_ind = 1
  WITH maxrow = 63, nullreport, compress,
   nolandscape
 ;end select
 SET count1 += 1
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "print rslt corr rpt"
 IF (report_complete_ind="Y"
  AND curqual > 0)
  IF (detail_cnt > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "no data found for specified date range"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "SCRIPT ERROR:  Report ended abnormally"
 ENDIF
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
 GO TO exit_script
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,code_value)
   IF (stat=0
    AND code_value > 0)
    SET gsub_code_value = code_value
   ENDIF
 END ;Subroutine
#exit_script
 FREE SET testsites
 IF (rpt_cnt > 0
  AND ops_ind="Y"
  AND checkqueue(trim(request->output_dist)))
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 ENDIF
END GO
