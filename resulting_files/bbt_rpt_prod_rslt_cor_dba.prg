CREATE PROGRAM bbt_rpt_prod_rslt_cor:dba
 RECORD ord_r_rec(
   1 ord_r[*]
     2 order_id = f8
     2 result_id = f8
     2 task_assay_cd = f8
     2 product_id = f8
     2 product_nbr = c26
     2 product_cd = f8
     2 product_disp = c23
     2 order_mnemonic = c20
     2 detail_mnemonic = c18
     2 cell_product = c26
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
 RECORD captions(
   1 product_result = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 prod_no = vc
   1 ordered_procedure = vc
   1 results = vc
   1 product_type = vc
   1 detail_procedure = vc
   1 cell_product = vc
   1 corrected = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 rpt_by = vc
   1 end_of_report = vc
   1 all = vc
   1 comment = vc
   1 note = vc
 )
 SET captions->product_result = uar_i18ngetmessage(i18nhandle,"product_result",
  "P R O D U C T   R E S U L T   C O R R E C T I O N   R E P O R T")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->prod_no = uar_i18ngetmessage(i18nhandle,"prod_no","PRODUCT NUMBER")
 SET captions->ordered_procedure = uar_i18ngetmessage(i18nhandle,"ordered_procedure",
  "ORDERED PROCEDURE")
 SET captions->results = uar_i18ngetmessage(i18nhandle,"results","RESULTS:")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","  PRODUCT TYPE")
 SET captions->detail_procedure = uar_i18ngetmessage(i18nhandle,"detail_procedure",
  "  DETAIL PROCEDURE")
 SET captions->cell_product = uar_i18ngetmessage(i18nhandle,"cell_product","CELL/PRODUCT")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected",
  "  CORRECTED(*) / PREVIOUS       DATE   TIME    ID")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_PROD_RSLT_COR")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->comment = uar_i18ngetmessage(i18nhandle,"comment","Comment:  ")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note:  ")
 DECLARE commenttype_codeset = i4
 DECLARE chartabletype_cd = f8
 DECLARE notetype_cd = f8
 DECLARE subsection_group_cd = f8
 DECLARE resourcegroup_codeset = i4
 DECLARE reportbyusername = vc WITH protect, noconstant("")
 SET reportbyusername = get_username(reqinfo->updt_id)
 SET stat = 0
 SET ord_r_cnt = 0
 SET r_cnt = 0
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 SET result_status_code_set = 1901
 SET corrected_cdf_meaning = "CORRECTED"
 SET old_corrected_cdf_meaning = "OLDCORRECTED"
 SET verified_cdf_meaning = "VERIFIED"
 SET old_verified_cdf_meaning = "OLDVERIFIED"
 SET scorrected_inreview_cdf = "CORRINREV"
 SET soldcorrected_inreview_cdf = "OLDCORRINREV"
 SET activity_type_code_set = 106
 SET bb_activity_cdf_meaning = "BB"
 SET commenttype_codeset = 14
 SET resourcegroup_codeset = 223
 SET count1 = 0
 SET detail_cnt = 0
 SET report_complete_ind = "N"
 SET corrected_status_cd = 0.0
 SET old_corrected_status_cd = 0.0
 SET verified_status_cd = 0.0
 SET old_verified_status_cd = 0.0
 SET dcorrinreview_cd = 0.0
 SET doldcorrinreview_cd = 0.0
 SET bb_activity_type_cd = 0.0
 SET line = fillstring(130,"_")
 SET result_cnt = 0
 SET rslt = 0
 SET rslt_row = 0
 SET order_mnemonic = fillstring(20," ")
 SET mnemonic = fillstring(25," ")
 SET product_number = fillstring(26," ")
 SET ops_ind = "N"
 SET ops_cnvt_dt_tm = cnvtdatetime(sysdate)
 SET chartabletype_cd = 0.0
 SET notetype_cd = 0.0
 SET subsection_group_cd = 0.0
 SET gsub_code_value = 0.0
 SET corrected_status_cd = 0.0
 CALL get_code_value(result_status_code_set,nullterm(corrected_cdf_meaning))
 IF (stat=1)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "corrected status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get corrected status code_value"
  GO TO exit_script
 ELSE
  SET corrected_status_cd = gsub_code_value
 ENDIF
 SET old_corrected_status_cd = 0.0
 CALL get_code_value(result_status_code_set,nullterm(old_corrected_cdf_meaning))
 IF (stat=1)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "old_corrected status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get old_corrected status code_value"
  GO TO exit_script
 ELSE
  SET old_corrected_status_cd = gsub_code_value
 ENDIF
 SET verified_status_cd = 0.0
 CALL get_code_value(result_status_code_set,nullterm(verified_cdf_meaning))
 IF (stat=1)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "verified status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_result_corr"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get verified status code_value"
  GO TO exit_script
 ELSE
  SET verified_status_cd = gsub_code_value
 ENDIF
 SET old_verified_status_cd = 0.0
 CALL get_code_value(result_status_code_set,nullterm(old_verified_cdf_meaning))
 IF (stat=1)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "old_verified status"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
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
 SET bb_activity_type_cd = 0.0
 CALL get_code_value(activity_type_code_set,nullterm(bb_activity_cdf_meaning))
 IF (stat=1)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "bb_activity_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get bb activity type code_value"
  GO TO exit_script
 ELSE
  SET bb_activity_type_cd = gsub_code_value
 ENDIF
 SET stat = uar_get_meaning_by_codeset(commenttype_codeset,nullterm("RES COMMENT"),1,chartabletype_cd
  )
 SET stat = uar_get_meaning_by_codeset(commenttype_codeset,nullterm("RES NOTE"),1,notetype_cd)
 IF (((chartabletype_cd=0.0) OR (notetype_cd=0.0)) )
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "result comment or note cv"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get result chartable or non-chartable comment type code_value"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(resourcegroup_codeset,nullterm("SUBSECTION"),1,
  subsection_group_cd)
 IF (subsection_group_cd=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "subsection code_value"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get subsection code_value"
  GO TO exit_script
 ENDIF
 IF (trim(request->batch_selection) > " ")
  SET ops_ind = "Y"
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_prod_rslt_cor")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_prod_rslt_cor")
  CALL check_inventory_cd("bbt_rpt_prod_rslt_cor")
  CALL check_location_cd("bbt_rpt_prod_rslt_cor")
 ENDIF
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
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 IF ((request->cur_owner_area_cd=0.0))
  SET cur_owner_area_disp = captions->all
 ELSE
  SET cur_owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd=0.0))
  SET cur_inv_area_disp = captions->all
 ELSE
  SET cur_inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 SELECT INTO "nl:"
  r.result_id, p.product_id, product_disp = uar_get_code_display(p.product_cd),
  r.bb_result_id, cell_product_wk = substring(1,25,uar_get_code_display(boc.cell_cd))
  FROM result r,
   perform_result r_pr,
   result_event r_re,
   order_catalog oc,
   orders o,
   discrete_task_assay dta,
   product p,
   (dummyt d_bp  WITH seq = 1),
   blood_product bp,
   (dummyt d  WITH seq = 1),
   bb_order_cell boc
  PLAN (r
   WHERE r.result_status_cd IN (corrected_status_cd, dcorrinreview_cd))
   JOIN (r_pr
   WHERE r_pr.result_id=r.result_id
    AND r_pr.result_status_cd IN (corrected_status_cd, old_corrected_status_cd, dcorrinreview_cd,
   doldcorrinreview_cd))
   JOIN (r_re
   WHERE r_re.result_id=r_pr.result_id
    AND r_re.perform_result_id=r_pr.perform_result_id
    AND ((r_re.event_type_cd=r_pr.result_status_cd) OR (((r_pr.result_status_cd=
   old_corrected_status_cd
    AND r_re.event_type_cd=corrected_status_cd) OR (((r_pr.result_status_cd=old_verified_status_cd
    AND r_re.event_type_cd=verified_status_cd) OR (r_pr.result_status_cd=doldcorrinreview_cd
    AND r_re.event_type_cd=dcorrinreview_cd)) )) ))
    AND r_re.event_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND r_re.event_dt_tm <= cnvtdatetime(request->end_dt_tm))
   JOIN (oc
   WHERE oc.catalog_cd=r.catalog_cd
    AND oc.activity_type_cd=bb_activity_type_cd)
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd)
   JOIN (o
   WHERE o.order_id=r.order_id
    AND o.product_id != null
    AND o.product_id > 0.0)
   JOIN (p
   WHERE p.product_id=o.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (d_bp
   WHERE d_bp.seq=1)
   JOIN (bp
   WHERE bp.product_id=p.product_id)
   JOIN (d
   WHERE d.seq=1)
   JOIN (boc
   WHERE r.bb_result_id != 0.0
    AND r.bb_result_id != null
    AND boc.order_id=r.order_id
    AND boc.bb_result_id=r.bb_result_id
    AND boc.cell_cd > 0.0
    AND boc.cell_cd != null)
  ORDER BY r.result_id
  HEAD REPORT
   stat = alterlist(ord_r_rec->ord_r,20)
  HEAD r.result_id
   ord_r_cnt += 1
   IF (mod(ord_r_cnt,20)=1
    AND ord_r_cnt != 1)
    stat = alterlist(ord_r_rec->ord_r,(ord_r_cnt+ 19))
   ENDIF
   ord_r_rec->ord_r[ord_r_cnt].order_id = o.order_id, ord_r_rec->ord_r[ord_r_cnt].result_id = r
   .result_id, ord_r_rec->ord_r[ord_r_cnt].task_assay_cd = r.task_assay_cd,
   ord_r_rec->ord_r[ord_r_cnt].product_id = p.product_id, ord_r_rec->ord_r[ord_r_cnt].product_nbr =
   concat(trim(bp.supplier_prefix),trim(p.product_nbr,3)," ",trim(p.product_sub_nbr,3)), ord_r_rec->
   ord_r[ord_r_cnt].product_cd = p.product_cd,
   ord_r_rec->ord_r[ord_r_cnt].product_disp = product_disp, ord_r_rec->ord_r[ord_r_cnt].
   order_mnemonic = o.order_mnemonic, ord_r_rec->ord_r[ord_r_cnt].detail_mnemonic = substring(1,25,
    dta.mnemonic),
   ord_r_rec->ord_r[ord_r_cnt].cell_product = cell_product_wk
  FOOT REPORT
   stat = alterlist(ord_r_rec->ord_r,ord_r_cnt)
  WITH nocounter, outerjoin(d), outerjoin(d_bp)
 ;end select
 SELECT INTO "nl:"
  table_ind = decode(re.seq,"4re    ",lt.seq,"3lt    ",pr.seq,
   "1pr    ","xxxxxx"), result_type_mean = uar_get_code_meaning(pr.result_type_cd), alpha_result =
  trim(substring(1,13,pr.result_value_alpha)),
  text_results = pr.ascii_text, date_result = format(pr.result_value_dt_tm,"ddmmmyy;;d"),
  date_time_result = format(pr.result_value_dt_tm,"ddmmmyy hhmm;;d"),
  result_code_set_disp = trim(substring(1,13,uar_get_code_display(pr.result_code_set_cd))), result_id
   = ord_r_rec->ord_r[d.seq].result_id, pr.perform_result_id,
  pr_display = uar_get_code_display(pr.result_code_set_cd), norm_display = uar_get_code_display(pr
   .normal_cd), crit_display = uar_get_code_display(pr.critical_cd),
  notify_display = uar_get_code_display(pr.notify_cd), revw_display = uar_get_code_display(pr
   .review_cd), delta_display = uar_get_code_display(pr.delta_cd)
  FROM (dummyt d  WITH seq = value(ord_r_cnt)),
   perform_result pr,
   (dummyt d_pr  WITH seq = 1),
   (dummyt d_re  WITH seq = 1),
   long_text lt,
   result_event re,
   prsnl pnl
  PLAN (d)
   JOIN (pr
   WHERE (pr.result_id=ord_r_rec->ord_r[d.seq].result_id)
    AND pr.result_status_cd IN (corrected_status_cd, old_corrected_status_cd, old_verified_status_cd,
   dcorrinreview_cd))
   JOIN (((d_pr
   WHERE d_pr.seq=1)
   ) ORJOIN ((d_re
   WHERE d_re.seq=1)
   JOIN (((lt
   WHERE lt.long_text_id=pr.long_text_id
    AND pr.long_text_id != null
    AND pr.long_text_id > 0)
   ) ORJOIN ((re
   WHERE re.result_id=pr.result_id
    AND re.perform_result_id=pr.perform_result_id
    AND ((re.event_type_cd=pr.result_status_cd) OR (((pr.result_status_cd=old_corrected_status_cd
    AND re.event_type_cd=corrected_status_cd) OR (pr.result_status_cd=old_verified_status_cd
    AND re.event_type_cd=verified_status_cd)) )) )
   JOIN (pnl
   WHERE pnl.person_id=re.event_personnel_id)
   )) ))
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
   r_rec->r[r_cnt].result = pr_display, r_rec->r[r_cnt].task_assay_cd = ord_r_rec->ord_r[d.seq].
   task_assay_cd, cv_normflag = concat(" ",norm_display),
   cv_critflag = concat(" ",crit_display), cv_revwflag = concat(" ",revw_display), cv_deltaflag =
   concat(" ",delta_display),
   cv_notifyflag = concat(" ",notify_display), comment_exists = "N", note_exists = "N",
   correction_flag = "N", resultflagstr = bldresultflagstr(cv_normflag,cv_critflag,cv_revwflag,
    cv_deltaflag,comment_exists,
    note_exists,correction_flag,cv_notifyflag)
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
     r_rec->r[r_cnt].result = alpha_result
    ELSEIF (result_type_mean IN ("3", "8"))
     r_rec->r[r_cnt].numeric_result_ind = 1, r_rec->r[r_cnt].numeric_result = pr.result_value_numeric,
     r_rec->r[r_cnt].less_great_flag = pr.less_great_flag
    ELSEIF (result_type_mean="6")
     r_rec->r[r_cnt].result = date_result
    ELSEIF (result_type_mean="11")
     r_rec->r[r_cnt].result = date_time_result
    ELSEIF (result_type_mean="9")
     r_rec->r[r_cnt].result = result_code_set_disp
    ELSE
     r_rec->r[r_cnt].result = "<blank>"
    ENDIF
   ELSEIF (table_ind="3lt    "
    AND cnvtint(pr.long_text_id) > 0)
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
    AND rg.resource_group_type_cd=subsection_group_cd
    AND ((rg.root_service_resource_cd+ 0)=0.0))
  ORDER BY d.seq, d_dm.seq
  HEAD d.seq
   arg_min_digits = 1, arg_max_digits = 8, arg_min_dec_places = 0,
   data_map_level = 0, numeric_result = fillstring(50," ")
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
   numeric_result, numeric_result = uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
    arg_less_great_flag,arg_raw_value),
   r_rec->r[d.seq].result = trim(substring(1,17,numeric_result))
  WITH nocounter, outerjoin(d_dm), outerjoin(d_rg)
 ;end select
 SELECT INTO "nl:"
  rc.result_id, rc.action_sequence, lt.long_text_id,
  lt_long_text = substring(1,32000,lt.long_text)
  FROM (dummyt d1  WITH seq = value(r_cnt)),
   result_comment rc,
   long_text lt
  PLAN (d1)
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
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_prd_rslt_cor", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  product_id = ord_r_rec->ord_r[d_or.seq].product_id, sort_product_nbr = ord_r_rec->ord_r[d_or.seq].
  product_nbr, order_id = ord_r_rec->ord_r[d_or.seq].order_id,
  result_id = ord_r_rec->ord_r[d_or.seq].result_id, perform_result_id = r_rec->r[d_r.seq].
  perform_result_id
  FROM (dummyt d_or  WITH seq = value(ord_r_cnt)),
   (dummyt d_r  WITH seq = value(r_cnt))
  PLAN (d_or
   WHERE (ord_r_rec->ord_r[d_or.seq].result_id > 0.0))
   JOIN (d_r
   WHERE (r_rec->r[d_r.seq].result_id=ord_r_rec->ord_r[d_or.seq].result_id))
  ORDER BY sort_product_nbr, product_id, order_id,
   result_id, perform_result_id DESC
  HEAD REPORT
   rpt_row = 0, rslt_row = 0, beg_dt_tm = cnvtdatetime(request->beg_dt_tm),
   end_dt_tm = cnvtdatetime(request->end_dt_tm), rslt_ln = 0, rslt_ln_cnt = 0,
   rslt_ln_len = 0, rslt_text = fillstring(54," "), long_text_page_wrap_ind = "N",
   detail_cnt = 0, report_complete_ind = "N", select_ok_ind = 0,
   status_disp = fillstring(21," ")
  HEAD PAGE
   new_page = "Y", rpt_row = 1,
   CALL center(captions->product_result,1,132),
   inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
   rpt_row += 4, row rpt_row, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   rpt_row += 1, row rpt_row, col 1,
   captions->inventory_area, col 17, cur_inv_area_disp,
   rpt_row += 2, row rpt_row, col 34,
   captions->beg_date, col 50, beg_dt_tm"@DATETIMECONDENSED;;d",
   col 73, captions->end_date, col 86,
   end_dt_tm"@DATETIMECONDENSED;;d", rpt_row += 2, row rpt_row,
   col 006, captions->prod_no, col 029,
   captions->ordered_procedure, col 081, captions->results,
   rpt_row += 1, row rpt_row, col 005,
   captions->product_type, col 027, captions->detail_procedure,
   col 059, captions->cell_product, col 079,
   captions->corrected, rpt_row += 1, row rpt_row,
   col 001, "-------------------------", col 027,
   "-------------------------", col 053, "-------------------------",
   col 079, "----------------------------------------------------"
  HEAD product_id
   new_product = "Y", rslt_row += 1, product_number = ord_r_rec->ord_r[d_or.seq].product_nbr,
   product_disp = ord_r_rec->ord_r[d_or.seq].product_disp
  HEAD order_id
   new_order = "Y", order_mnemonic = ord_r_rec->ord_r[d_or.seq].order_mnemonic
  HEAD result_id
   new_result = "Y", result_cnt = 0, stat = alterlist(result->resultlist,5),
   rslt_row += 1, mnemonic = ord_r_rec->ord_r[d_or.seq].detail_mnemonic, cell_product = ord_r_rec->
   ord_r[d_or.seq].cell_product
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
     result->resultlist[result_cnt].result = concat(r_rec->r[d_r.seq].result,r_rec->r[d_r.seq].
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
   ELSE
    rpt_row += 1
   ENDIF
   IF (new_order="Y")
    IF (rpt_row >= 58)
     BREAK
    ENDIF
    rpt_row += 1, row rpt_row, col 001,
    product_number, new_order = "N", row rpt_row,
    col 027, order_mnemonic"#########################"
   ENDIF
   IF (new_result="Y")
    rpt_row += 1
    IF (rpt_row >= 58)
     BREAK
    ENDIF
    IF (new_product="Y")
     new_product = "N", row rpt_row, col 001,
     product_disp
    ENDIF
    new_result = "N", row rpt_row, col 028,
    mnemonic"#########################", row rpt_row, col 053,
    cell_product
   ENDIF
   FOR (rslt = 1 TO cnvtint(result_cnt))
     IF (rslt != 1)
      rpt_row += 1
     ENDIF
     row rpt_row, col 079, result->resultlist[rslt].result_corrected_ind,
     rslt_len = cnvtint(size(trim(result->resultlist[rslt].result,1))), rslt_ln_cnt = cnvtint((
      rslt_len/ 54))
     IF (rslt_ln_cnt < 1)
      rslt_ln_cnt = 1
     ENDIF
     IF (rslt_ln_cnt <= 1)
      IF (rpt_row >= 58)
       BREAK
      ENDIF
      row rpt_row, col 081, result->resultlist[rslt].result
     ELSE
      first_row = "Y",
      CALL rtf_to_text(trim(result->resultlist[rslt].result),1,50)
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
        row rpt_row, col 81, tmptext->qual[q_cnt].text
        IF (q_cnt=size(tmptext->qual,5))
         IF (size(tmptext->qual[q_cnt].text,1) > 30)
          rpt_row += 1
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF ((result->resultlist[rslt].result_status_cd=dcorrinreview_cd))
      status_disp = concat("<<< ",trim(uar_get_code_display(dcorrinreview_cd))," >>>"), row rpt_row,
      col 110,
      status_disp
     ELSE
      row rpt_row, col 110, result->resultlist[rslt].result_dt_tm"@DATETIMECONDENSED;;d",
      col 124, result->resultlist[rslt].result_username"#######"
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
   curpage"###", col 108, captions->printed,
   col 117, curdate"@DATECONDENSED;;d", col 126,
   curtime"@TIMENOSECONDS;;M", row + 1, col 113,
   captions->rpt_by, col 117, reportbyusername"##########;L"
  FOOT REPORT
   row 62,
   CALL center(captions->end_of_report,1,125), report_complete_ind = "Y",
   select_ok_ind = 1
  WITH maxrow = 63, nullreport, compress,
   nolandscape
 ;end select
 SET count1 += 1
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 SET reply->status_data.subeventstatus[count1].operationname = "result correction report"
 IF (report_complete_ind="Y"
  AND curqual > 0)
  IF (detail_cnt > 0)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "no data found for specified date range"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_prod_rslt_cor"
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
   SET cdf_meaning = fillstring(12," ")
   SET code_value = 0.0
   SET code_set = sub_code_set
   SET cdf_meaning = sub_cdf_meaning
   SET gsub_code_value = 0.0
   SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,1,code_value)
   SET gsub_code_value = code_value
 END ;Subroutine
#exit_script
 IF (ops_ind="Y")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 ENDIF
END GO
