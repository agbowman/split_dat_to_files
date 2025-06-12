CREATE PROGRAM bbt_rpt_daily_patient_rsl:dba
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
 DECLARE susername = c50 WITH protect, noconstant("")
 DECLARE nstatus = i4 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE sunknownstring = vc WITH protect, noconstant("")
 DECLARE sstillbornstring = vc WITH protect, noconstant("")
 SET nstatus = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET sunknownstring = uar_i18ngetmessage(i18nhandle,"UNKNOWN_AGE","Unknown")
 SET sstillbornstring = uar_i18ngetmessage(i18nhandle,"STILLBORN_AGE","Stillborn")
 SELECT INTO "nl:"
  FROM prsnl pl
  WHERE (person_id=reqinfo->updt_id)
  DETAIL
   susername = pl.username
  WITH nocounter
 ;end select
 SUBROUTINE (formatage(birth_dt_tm=f8,deceased_dt_tm=f8,policy=vc) =vc WITH protect)
   DECLARE eff_end_dt_tm = f8 WITH private, noconstant(0.0)
   SET eff_end_dt_tm = deceased_dt_tm
   IF (((eff_end_dt_tm=null) OR (eff_end_dt_tm=0.00)) )
    SET eff_end_dt_tm = cnvtdatetime(sysdate)
   ENDIF
   IF (((birth_dt_tm > eff_end_dt_tm) OR (birth_dt_tm=null)) )
    RETURN(sunknownstring)
   ELSEIF (birth_dt_tm=deceased_dt_tm)
    RETURN(sstillbornstring)
   ELSE
    RETURN(cnvtage2(birth_dt_tm,eff_end_dt_tm,0,concat(policy,"/",trim(susername),"/",trim(cnvtstring
       (reqinfo->position_cd,32,2)))))
   ENDIF
 END ;Subroutine
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
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SUBROUTINE (determineexpandtotal(lactualsize=i4,lexpandsize=i4) =i4 WITH protect, noconstant(0))
   RETURN((ceil((cnvtreal(lactualsize)/ lexpandsize)) * lexpandsize))
 END ;Subroutine
 SUBROUTINE (determineexpandsize(lrecordsize=i4,lmaximumsize=i4) =i4 WITH protect, noconstant(0))
   DECLARE lreturn = i4 WITH protect, noconstant(0)
   IF (lrecordsize <= 1)
    SET lreturn = 1
   ELSEIF (lrecordsize <= 10)
    SET lreturn = 10
   ELSEIF (lrecordsize <= 500)
    SET lreturn = 50
   ELSE
    SET lreturn = 100
   ENDIF
   IF (lmaximumsize < lreturn)
    SET lreturn = lmaximumsize
   ENDIF
   RETURN(lreturn)
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
 RECORD ops_params(
   1 qual[*]
     2 param = c100
 )
 RECORD patientmrnlist(
   1 qual[*]
     2 mrn = c20
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
 RECORD perf_results(
   1 qual[*]
     2 result_id = f8
     2 order_id = f8
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 perform_result_id = f8
     2 service_resource_cd = f8
     2 detail_mnemonic = c12
     2 drawn_time = c12
     2 bb_result_id = f8
     2 product_nbr = c25
     2 bb_processing_cd = f8
     2 event_sequence = i4
     2 long_text_id = f8
     2 result_status_cd = f8
     2 arg_min_digits = i4
     2 arg_max_digits = i4
     2 arg_min_dec_places = i4
     2 arg_less_great_flag = i2
 )
 RECORD r_long_text(
   1 qual[*]
     2 result_id = f8
     2 perform_result_id = f8
     2 event_sequence = i4
     2 order_id = f8
     2 task_assay_cd = f8
     2 result_status_cd = f8
     2 comment_text = vc
     2 note_text = vc
     2 text_result = vc
 )
 RECORD captions(
   1 rpt_date = vc
   1 rpt_time = vc
   1 rpt_by = vc
   1 page_no = vc
   1 test_site = vc
   1 beg_date = vc
   1 end_date = vc
   1 person_name = vc
   1 order_proc = vc
   1 number = vc
   1 accession = vc
   1 age_sex = vc
   1 collect_dt_tm = vc
   1 performed = vc
   1 verified = vc
   1 provider = vc
   1 priority = vc
   1 cell_product = vc
   1 procedure = vc
   1 result = vc
   1 tech_id = vc
   1 date = vc
   1 time = vc
   1 end_of_report = vc
   1 title_text = vc
   1 report_id = vc
   1 unknown = vc
   1 comment = vc
   1 note = vc
   1 text_result = vc
   1 text_result_correct = vc
   1 not_on_file = vc
 )
 SET captions->rpt_date = uar_i18ngetmessage(i18nhandle,"rpt_date","DATE:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","  BY:")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE:")
 SET captions->test_site = uar_i18ngetmessage(i18nhandle,"test_site","TEST SITE:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->person_name = uar_i18ngetmessage(i18nhandle,"person_name","PERSON NAME")
 SET captions->order_proc = uar_i18ngetmessage(i18nhandle,"order_proc","ORDERED PROC")
 SET captions->number = uar_i18ngetmessage(i18nhandle,"number","NUMBER")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"accession","ACCESSION #")
 SET captions->age_sex = uar_i18ngetmessage(i18nhandle,"age_sex","AGE/SEX")
 SET captions->collect_dt_tm = uar_i18ngetmessage(i18nhandle,"collect_dt_tm","COLLECT DATE/TIME")
 SET captions->performed = uar_i18ngetmessage(i18nhandle,"performed","PERFORMED")
 SET captions->verified = uar_i18ngetmessage(i18nhandle,"verified","VERIFIED")
 SET captions->provider = uar_i18ngetmessage(i18nhandle,"provider","PROVIDER")
 SET captions->priority = uar_i18ngetmessage(i18nhandle,"priority","PRIORITY")
 SET captions->cell_product = uar_i18ngetmessage(i18nhandle,"cell_product","CELL/PRODUCT")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","PROCEDURE")
 SET captions->result = uar_i18ngetmessage(i18nhandle,"result","RESULT")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","TECH ID")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","DATE")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** END OF REPORT ***")
 SET captions->title_text = uar_i18ngetmessage(i18nhandle,"title_text",
  "BLOOD BANK PATIENT RESULTS ACTIVITY REPORT")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_DAILY_PATIENT_RSL")
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"unknown","Unknown")
 SET captions->comment = uar_i18ngetmessage(i18nhandle,"comment","Comment:  ")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note:  ")
 SET captions->text_result = uar_i18ngetmessage(i18nhandle,"text_result","Text Result:  ")
 SET captions->text_result_correct = uar_i18ngetmessage(i18nhandle,"text_result_correct",
  "Text Result (Corrected): ")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 DECLARE const_result_event_cs = i4 WITH protect, constant(1901)
 DECLARE const_alias_type_cs = i4 WITH protect, constant(319)
 DECLARE const_comment_type_cs = i4 WITH protect, constant(14)
 DECLARE const_bb_processing_cs = i4 WITH protect, constant(1635)
 DECLARE const_activity_type_cs = i4 WITH protect, constant(106)
 DECLARE const_xm_cdf = c2 WITH protect, constant("XM")
 DECLARE const_pat_abo_cdf = c11 WITH protect, constant("PATIENT ABO")
 DECLARE const_antigen_cdf = c7 WITH protect, constant("ANTIGEN")
 DECLARE const_antibody_cdf = c11 WITH protect, constant("ANTIBODY ID")
 DECLARE const_absc_cdf = c12 WITH protect, constant("ANTIBDY SCRN")
 DECLARE const_rh_phen_cdf = c12 WITH protect, constant("RH PHENOTYPE")
 DECLARE const_hlx_cdf = c3 WITH protect, constant("HLX")
 DECLARE const_mrn_cdf = c3 WITH protect, constant("MRN")
 DECLARE const_performed_cdf = c9 WITH protect, constant("PERFORMED")
 DECLARE const_verified_cdf = c8 WITH protect, constant("VERIFIED")
 DECLARE const_corrected_cdf = c9 WITH protect, constant("CORRECTED")
 DECLARE const_oldcorrected_cdf = c12 WITH protect, constant("OLDCORRECTED")
 DECLARE const_inreview_cdf = c8 WITH protect, constant("INREVIEW")
 DECLARE const_oldinreview_cdf = c11 WITH protect, constant("OLDINREVIEW")
 DECLARE const_corrinrev_cdf = c9 WITH protect, constant("CORRINREV")
 DECLARE const_oldcorrinrev_cdf = c12 WITH protect, constant("OLDCORRINREV")
 DECLARE const_res_comment_cdf = c11 WITH protect, constant("RES COMMENT")
 DECLARE const_res_note_cdf = c8 WITH protect, constant("RES NOTE")
 DECLARE crossmatch_cd = f8 WITH protect, constant(get_code_value(const_bb_processing_cs,const_xm_cdf
   ))
 DECLARE patient_abo_cd = f8 WITH protect, constant(get_code_value(const_bb_processing_cs,
   const_pat_abo_cdf))
 DECLARE antigen_cd = f8 WITH protect, constant(get_code_value(const_bb_processing_cs,
   const_antigen_cdf))
 DECLARE antibody_id_cd = f8 WITH protect, constant(get_code_value(const_bb_processing_cs,
   const_antibody_cdf))
 DECLARE antibody_scrn_cd = f8 WITH protect, constant(get_code_value(const_bb_processing_cs,
   const_absc_cdf))
 DECLARE rh_phenotype_cd = f8 WITH protect, constant(get_code_value(const_bb_processing_cs,
   const_rh_phen_cdf))
 DECLARE dhelixcd = f8 WITH protect, constant(get_code_value(const_activity_type_cs,const_hlx_cdf))
 DECLARE aliastype_cd = f8 WITH protect, constant(get_code_value(const_alias_type_cs,const_mrn_cdf))
 DECLARE performed_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_performed_cdf))
 DECLARE verified_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_verified_cdf))
 DECLARE corrected_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_corrected_cdf))
 DECLARE oldcorrected_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_oldcorrected_cdf))
 DECLARE inreview_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_inreview_cdf))
 DECLARE oldinreview_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_oldinreview_cdf))
 DECLARE corrinreview_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_corrinrev_cdf))
 DECLARE oldcorrinrev_cd = f8 WITH protect, constant(get_code_value(const_result_event_cs,
   const_oldcorrinrev_cdf))
 DECLARE chartabletype_cd = f8 WITH protect, constant(get_code_value(const_comment_type_cs,
   const_res_comment_cdf))
 DECLARE notetype_cd = f8 WITH protect, constant(get_code_value(const_comment_type_cs,
   const_res_note_cdf))
 DECLARE hyphen_line = c131 WITH protect, constant(fillstring(126,"-"))
 DECLARE nbr_prs = i4 WITH protect, noconstant(0)
 DECLARE nbr_comments = i4 WITH protect, noconstant(0)
 DECLARE resultflagstr = vc WITH protect, noconstant(" ")
 DECLARE offset = i2 WITH protect, noconstant(0)
 DECLARE order_row = i2 WITH protect, noconstant(0)
 DECLARE detail_row = i2 WITH protect, noconstant(0)
 DECLARE store_perform_result_id = f8 WITH protect, noconstant(0.0)
 DECLARE store_perfresultids = c50 WITH protect, noconstant("")
 DECLARE dont_print_proc = i2 WITH protect, noconstant(0)
 DECLARE procedure_row_hold = i2 WITH protect, noconstant(0)
 DECLARE ts_cnt = i4 WITH protect, noconstant(0)
 DECLARE reportbyusername = vc WITH protect, constant(get_username(reqinfo->updt_id))
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE first_service_resource = vc WITH protect, noconstant(fillstring(50," "))
 DECLARE mrn_idx = i4 WITH noconstant(0)
 DECLARE mrn_count = i4 WITH protect, noconstant(0)
 IF (crossmatch_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get BB Proc Codes"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "XM CDF_Meaning not found on 1635"
  GO TO exit_script
 ENDIF
 IF (patient_abo_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get BB Proc Codes"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "PATIENT ABO CDF_Meaning not found on 1635"
  GO TO exit_script
 ENDIF
 IF (antigen_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get BB Proc Codes"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ANTIGEN CDF_Meaning not found on 1635"
  GO TO exit_script
 ENDIF
 IF (antibody_id_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get BB Proc Codes"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ANTIBODY ID CDF_Meaning not found on 1635"
  GO TO exit_script
 ENDIF
 IF (antibody_scrn_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get BB Proc Codes"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "ANTIBODY SCRN CDF_Meaning not found on 1635"
  GO TO exit_script
 ENDIF
 IF (rh_phenotype_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get BB Proc Codes"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "RH PHENOTYPE CDF_Meaning not found on 1635"
  GO TO exit_script
 ENDIF
 IF (aliastype_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get MRN Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "MRN CDF_Meaning not found on 319"
  GO TO exit_script
 ENDIF
 IF (performed_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get PERFORMED Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "PERFORMED CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (verified_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get VERIFIED Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "VERIFIED CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (corrected_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get CORRECTED Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "CORRECTED CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (oldcorrected_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get OLDCORRECTED Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "OLDCORRECTED CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (inreview_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get INREVIEW Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "INREVIEW CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (oldinreview_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get OLDINREVIEW Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "OLDINREVIEW CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (corrinreview_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get CORRINREVIEW Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "CORRINREVIEW CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (oldcorrinrev_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get OLDCORRINREVIEW Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "OLDCORRINREVIEW CDF_Meaning not found on 1901"
  GO TO exit_script
 ENDIF
 IF (chartabletype_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get RES COMMENT Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "RES COMMENT CDF_Meaning not found on 14"
  GO TO exit_script
 ENDIF
 IF (notetype_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "Get RES NOTE Code"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "RES NOTE CDF_Meaning not found on 14"
  GO TO exit_script
 ENDIF
 SET nsecurityind = const_security_on
 IF (size(trim(request->batch_selection),1) > 0)
  SET nsecurityind = const_security_off
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_daily_patient_rsl")
  IF ((reply->status_data.status != "F"))
   SET request->dt_tm_begin = begday
   SET request->dt_tm_end = endday
  ENDIF
  CALL check_svc_opt("bbt_rpt_daily_patient_rsl")
  CALL check_location_cd("bbt_rpt_daily_patient_rsl")
  SET request->printer_name = request->output_dist
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
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "InitServResRoutine()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Status Returned."
  GO TO exit_script
 ENDIF
 SET nreturnstat = determineservresaccess(request->qual[1].service_resource_cd)
 IF (nreturnstat=const_return_invalid)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid Service Resource"
  GO TO exit_script
 ELSEIF (nreturnstat=const_return_no_security)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_daily_patient_rsl"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "DetermineServResAccess()"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "No security access for specified Service Resource"
  GO TO exit_script
 ENDIF
 SET first_service_resource = uar_get_code_display(request->qual[1].service_resource_cd)
 SELECT INTO "nl:"
  perfresultids = build(pr.result_id,pr.perform_result_id,re.event_sequence), drawntime = format(c
   .drawn_dt_tm,"@DATETIMECONDENSED;;d")
  FROM result_event re,
   perform_result pr,
   container c
  PLAN (re
   WHERE re.event_dt_tm BETWEEN cnvtdatetime(request->dt_tm_begin) AND cnvtdatetime(request->
    dt_tm_end))
   JOIN (pr
   WHERE pr.perform_result_id=re.perform_result_id
    AND  NOT (pr.result_status_cd IN (oldinreview_cd, oldcorrinrev_cd))
    AND expand(ts_cnt,1,size(testsites->qual,5),pr.service_resource_cd,testsites->qual[ts_cnt].
    service_resource_cd))
   JOIN (c
   WHERE c.container_id=pr.container_id)
  ORDER BY perfresultids
  HEAD REPORT
   stat = alterlist(perf_results->qual,100), nbr_prs = 0
  HEAD perfresultids
   nbr_prs += 1
   IF (size(perf_results->qual,5) < nbr_prs)
    stat = alterlist(perf_results->qual,(nbr_prs+ 99))
   ENDIF
   perf_results->qual[nbr_prs].perform_result_id = pr.perform_result_id, perf_results->qual[nbr_prs].
   result_id = pr.result_id, perf_results->qual[nbr_prs].service_resource_cd = pr.service_resource_cd,
   perf_results->qual[nbr_prs].event_sequence = re.event_sequence, perf_results->qual[nbr_prs].
   long_text_id = pr.long_text_id, perf_results->qual[nbr_prs].result_status_cd = pr.result_status_cd,
   perf_results->qual[nbr_prs].arg_less_great_flag = pr.less_great_flag, perf_results->qual[nbr_prs].
   drawn_time = drawntime
  FOOT  perfresultids
   row + 0
  FOOT REPORT
   stat = alterlist(perf_results->qual,nbr_prs)
  WITH nocounter, orahintcbo(" OPT_PARAM('_optimizer_skip_scan_enabled' 'false') AHTEST4 ")
 ;end select
 SET expandstart = 1
 SET expandsize = determineexpandsize(nbr_prs,100)
 SET expandtotal = determineexpandtotal(nbr_prs,expandsize)
 SET stat = alterlist(perf_results->qual,expandtotal)
 FOR (i_idx = (nbr_prs+ 1) TO expandtotal)
   SET perf_results->qual[i_idx].result_id = - (1)
 ENDFOR
 SELECT INTO "nl:"
  r.result_id, r.order_id, detail_mnem = substring(1,12,uar_get_code_display(r.task_assay_cd)),
  pe.product_id, p.product_nbr, sd.bb_processing_cd,
  sd.seq, locatestart = expandstart, result_id_expand = build(r.result_id,expandstart)
  FROM (dummyt d_r  WITH seq = value((expandtotal/ expandsize))),
   result r,
   discrete_task_assay dta,
   service_directory sd,
   dummyt d_pe,
   product_event pe,
   product p,
   blood_product bp
  PLAN (d_r
   WHERE assign(expandstart,evaluate(d_r.seq,1,1,(expandstart+ expandsize))))
   JOIN (r
   WHERE expand(i_idx,expandstart,((expandstart+ expandsize) - 1),r.result_id,perf_results->qual[
    i_idx].result_id))
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd
    AND ((dta.activity_type_cd+ 0) != dhelixcd))
   JOIN (sd
   WHERE r.catalog_cd=sd.catalog_cd)
   JOIN (d_pe)
   JOIN (pe
   WHERE pe.order_id=r.order_id
    AND sd.bb_processing_cd=crossmatch_cd
    AND ((pe.bb_result_id+ 0)=r.bb_result_id)
    AND ((pe.bb_result_id+ 0) != 0))
   JOIN (p
   WHERE pe.product_id=p.product_id)
   JOIN (bp
   WHERE bp.product_id=p.product_id)
  ORDER BY result_id_expand
  HEAD REPORT
   row + 0
  HEAD result_id_expand
   i = 0, locateend = ((locatestart+ expandsize) - 1), perfresindex = locateval(i,locatestart,
    locateend,r.result_id,perf_results->qual[i].result_id)
   WHILE (perfresindex > 0)
     perf_results->qual[perfresindex].order_id = r.order_id, perf_results->qual[perfresindex].
     catalog_cd = r.catalog_cd, perf_results->qual[perfresindex].task_assay_cd = r.task_assay_cd,
     perf_results->qual[perfresindex].detail_mnemonic = detail_mnem, perf_results->qual[perfresindex]
     .bb_result_id = r.bb_result_id, perf_results->qual[perfresindex].product_nbr = concat(trim(bp
       .supplier_prefix),trim(p.product_nbr)," ",trim(p.product_sub_nbr)),
     perf_results->qual[perfresindex].bb_processing_cd = sd.bb_processing_cd, perfresindex =
     locateval(i,(perfresindex+ 1),locateend,r.result_id,perf_results->qual[i].result_id)
   ENDWHILE
  DETAIL
   row + 0
  FOOT  r.result_id
   row + 0
  FOOT REPORT
   stat = alterlist(perf_results->qual,nbr_prs)
  WITH nocounter, outerjoin = d_pe
 ;end select
 SELECT INTO "nl:"
  dm.task_assay_cd, dm.service_resource_cd, data_map_exists = decode(dm.seq,"Y","N"),
  rg_exists = decode(rg.seq,"Y","N")
  FROM (dummyt d  WITH seq = value(nbr_prs)),
   (dummyt d_dm  WITH seq = 1),
   data_map dm,
   (dummyt d_rg  WITH seq = 1),
   resource_group rg
  PLAN (d
   WHERE d.seq <= nbr_prs
    AND (perf_results->qual[d.seq].result_id > 0.0))
   JOIN (d_dm
   WHERE d_dm.seq=1)
   JOIN (dm
   WHERE (dm.task_assay_cd=perf_results->qual[d.seq].task_assay_cd)
    AND dm.data_map_type_flag=0
    AND dm.active_ind=1)
   JOIN (d_rg
   WHERE d_rg.seq=1)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=dm.service_resource_cd
    AND (rg.child_service_resource_cd=perf_results->qual[d.seq].service_resource_cd)
    AND rg.resource_group_type_cd=dservressubsectioncd
    AND ((rg.root_service_resource_cd+ 0)=0.0))
  ORDER BY d.seq, d_dm.seq
  HEAD d.seq
   perf_results->qual[d.seq].arg_min_digits = 1, perf_results->qual[d.seq].arg_max_digits = 14,
   perf_results->qual[d.seq].arg_min_dec_places = 0,
   data_map_level = 0
  HEAD d_dm.seq
   IF (data_map_exists="Y")
    IF (data_map_level <= 2
     AND dm.service_resource_cd > 0
     AND (dm.service_resource_cd=perf_results->qual[d.seq].service_resource_cd))
     data_map_level = 3, perf_results->qual[d.seq].arg_min_digits = dm.min_digits, perf_results->
     qual[d.seq].arg_max_digits = dm.max_digits,
     perf_results->qual[d.seq].arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level <= 1
     AND dm.service_resource_cd > 0.0
     AND rg_exists="Y"
     AND rg.parent_service_resource_cd=dm.service_resource_cd
     AND (rg.child_service_resource_cd=perf_results->qual[d.seq].service_resource_cd))
     data_map_level = 2, perf_results->qual[d.seq].arg_min_digits = dm.min_digits, perf_results->
     qual[d.seq].arg_max_digits = dm.max_digits,
     perf_results->qual[d.seq].arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level=0
     AND dm.service_resource_cd=0)
     data_map_level = 1, perf_results->qual[d.seq].arg_min_digits = dm.min_digits, perf_results->
     qual[d.seq].arg_max_digits = dm.max_digits,
     perf_results->qual[d.seq].arg_min_dec_places = dm.min_decimal_places
    ENDIF
   ENDIF
  WITH nocounter, outerjoin(d_dm), outerjoin(d_rg)
 ;end select
 SELECT INTO "nl:"
  rc.result_id, rc.action_sequence, lt.seq,
  lt.long_text_id
  FROM (dummyt d1  WITH seq = value(nbr_prs)),
   result_comment rc,
   long_text lt
  PLAN (d1)
   JOIN (rc
   WHERE (rc.result_id=perf_results->qual[d1.seq].result_id)
    AND ((rc.comment_type_cd=chartabletype_cd) OR (rc.comment_type_cd=notetype_cd)) )
   JOIN (lt
   WHERE rc.long_text_id=lt.long_text_id
    AND lt.long_text_id > 0)
  ORDER BY rc.result_id, rc.comment_type_cd, rc.action_sequence DESC
  HEAD rc.result_id
   row + 0
  HEAD rc.comment_type_cd
   nbr_comments += 1, stat = alterlist(r_long_text->qual,nbr_comments), r_long_text->qual[
   nbr_comments].result_id = rc.result_id,
   r_long_text->qual[nbr_comments].perform_result_id = perf_results->qual[d1.seq].perform_result_id,
   r_long_text->qual[nbr_comments].event_sequence = perf_results->qual[d1.seq].event_sequence,
   r_long_text->qual[nbr_comments].order_id = perf_results->qual[d1.seq].order_id,
   r_long_text->qual[nbr_comments].task_assay_cd = perf_results->qual[d1.seq].task_assay_cd
   IF (rc.comment_type_cd=chartabletype_cd)
    r_long_text->qual[nbr_comments].comment_text = trim(lt.long_text)
   ELSEIF (rc.comment_type_cd=notetype_cd)
    r_long_text->qual[nbr_comments].note_text = trim(lt.long_text)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  result_id = perf_results->qual[d1.seq].result_id, perf_result = perf_results->qual[d1.seq].
  perform_result_id, lt.seq,
  lt.long_text_id, lt_long_text = substring(1,32000,lt.long_text)
  FROM (dummyt d1  WITH seq = value(nbr_prs)),
   long_text lt
  PLAN (d1
   WHERE (perf_results->qual[d1.seq].long_text_id > 0))
   JOIN (lt
   WHERE (perf_results->qual[d1.seq].long_text_id=lt.long_text_id))
  ORDER BY result_id, perf_result DESC
  HEAD REPORT
   rtf_out_text = fillstring(32000," "),
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
  DETAIL
   nbr_comments += 1, stat = alterlist(r_long_text->qual,nbr_comments), r_long_text->qual[
   nbr_comments].result_id = perf_results->qual[d1.seq].result_id,
   r_long_text->qual[nbr_comments].perform_result_id = perf_results->qual[d1.seq].perform_result_id,
   r_long_text->qual[nbr_comments].event_sequence = perf_results->qual[d1.seq].event_sequence,
   r_long_text->qual[nbr_comments].order_id = perf_results->qual[d1.seq].order_id,
   r_long_text->qual[nbr_comments].task_assay_cd = perf_results->qual[d1.seq].task_assay_cd,
   r_long_text->qual[nbr_comments].result_status_cd = perf_results->qual[d1.seq].result_status_cd
   IF (lt.seq != null
    AND lt.seq > 0)
    CALL remove_rtf2(lt_long_text), r_long_text->qual[nbr_comments].text_result = trim(rtf_out_text)
   ENDIF
  WITH nocounter
 ;end select
 SET begin_date = format(request->dt_tm_begin,"@DATETIMECONDENSED;;d")
 SET end_date = format(request->dt_tm_end,"@DATETIMECONDENSED;;d")
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_dailypatrsl", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  pr.result_id, p.person_id, p.name_full_formatted,
  re.event_type_cd, pr.result_status_cd, re.perform_result_id,
  cv_oc.display, detail_mnem = perf_results->qual[d_pr.seq].detail_mnemonic, alpha_result = trim(
   substring(1,11,pr.result_value_alpha)),
  result_code_set_disp = trim(substring(1,11,uar_get_code_display(pr.result_code_set_cd))),
  profile_task_yn = decode(ptr.seq,"Y",pr.seq,"N","Z"), order_cell_yn = decode(oc.seq,"Y",pr.seq,"N",
   "Z"),
  cell_yn = decode(cv_oc.seq,"Y",pr.seq,"N","Z"), product_yn = decode(prod.seq,"Y",pr.seq,"N","Z"),
  type_cdf_meaning = decode(pr.seq,uar_get_code_meaning(pr.result_type_cd)," "),
  ptr.sequence, phs_grp.sequence, re.event_sequence,
  re.event_dt_tm, nowtime = format(curtime,"@TIMENOSECONDS;;M"), nowdate = format(curdate,
   "@DATECONDENSED;;d"),
  drawntime = perf_results->qual[d_pr.seq].drawn_time, event_date = format(re.event_dt_tm,
   "@DATETIMECONDENSED;;d"), ascii_text = trim(substring(1,13,pr.ascii_text)),
  pr.result_value_numeric, text_results = trim(substring(1,11,pr.ascii_text)), date_result = format(
   pr.result_value_dt_tm,"@DATECONDENSED;;d"),
  date_time_result = format(pr.result_value_dt_tm,"@DATETIMECONDENSED;;d"), norm_display = decode(pr
   .seq,uar_get_code_display(pr.normal_cd)," "), crit_display = decode(pr.seq,uar_get_code_display(pr
    .critical_cd)," "),
  notify_disp = decode(pr.seq,uar_get_code_display(pr.notify_cd)," "), revw_display = decode(pr.seq,
   uar_get_code_display(pr.review_cd)," "), delta_display = decode(pr.seq,uar_get_code_display(pr
    .delta_cd)," "),
  tech_name =
  IF (nullind(pl.username)=0) substring(1,7,pl.username)
  ELSE fillstring(7," ")
  ENDIF
  , ord_mnem = trim(substring(1,19,o.order_mnemonic)), short_name = trim(substring(1,20,p
    .name_full_formatted)),
  aor.accession, ea.alias, doctor_name = concat("DR. ",substring(1,19,p_doc.name_full_formatted)),
  bb_processing_cd = perf_results->qual[d_pr.seq].bb_processing_cd, product_nbr = perf_results->qual[
  d_pr.seq].product_nbr, pr.result_id,
  o.order_id, orderunique = build(o.catalog_cd,o.order_id), o.person_id,
  personunique = build(trim(p.name_full_formatted),p.person_id), pr.perform_result_id, psex = decode(
   p.seq,uar_get_code_display(p.sex_cd)," "),
  p_doc_exists = decode(p_doc.seq,"Y","N"), shortpri = decode(ol.seq,uar_get_code_display(ol
    .report_priority_cd)," "), ol_exists = decode(ol.seq,"Y","N"),
  test_site2 = decode(pr.seq,uar_get_code_display(pr.service_resource_cd)," "), oc.bb_result_id, oc
  .order_cell_id,
  prod.product_nbr, oc.cell_cd, pr.long_text_id,
  perfresultids = build(pr.result_id,pr.perform_result_id,re.event_sequence), performdttm = format(pr
   .perform_dt_tm,"@DATETIMECONDENSED;;d"), perftechname =
  IF (nullind(pl2.username)=0) substring(1,7,pl2.username)
  ELSE fillstring(7," ")
  ENDIF
  FROM (dummyt d_pr  WITH seq = value(nbr_prs)),
   result_event re,
   perform_result pr,
   (dummyt d_result  WITH seq = 1),
   orders o,
   person p,
   accession_order_r aor,
   person p_doc,
   order_laboratory ol,
   (dummyt d_ea  WITH seq = 1),
   encntr_alias ea,
   (dummyt d_ea2  WITH seq = 1),
   prsnl pl,
   (dummyt d_ptr  WITH seq = 1),
   profile_task_r ptr,
   bb_order_cell oc,
   (dummyt d_cv_oc  WITH seq = 1),
   code_value cv_oc,
   product prod,
   (dummyt d_bp2  WITH seq = 1),
   blood_product bp2,
   (dummyt d_phs_grp  WITH seq = 1),
   bb_order_phase op,
   phase_group phs_grp,
   (dummyt d_phase  WITH seq = 1),
   prsnl pl2
  PLAN (d_pr
   WHERE (perf_results->qual[d_pr.seq].result_id > 0.0))
   JOIN (pr
   WHERE (pr.perform_result_id=perf_results->qual[d_pr.seq].perform_result_id))
   JOIN (pl2
   WHERE pl2.person_id=pr.perform_personnel_id)
   JOIN (d_result
   WHERE d_result.seq=1)
   JOIN (re
   WHERE (re.result_id=perf_results->qual[d_pr.seq].result_id)
    AND (re.perform_result_id=perf_results->qual[d_pr.seq].perform_result_id)
    AND (re.event_sequence=perf_results->qual[d_pr.seq].event_sequence))
   JOIN (o
   WHERE (o.order_id=perf_results->qual[d_pr.seq].order_id))
   JOIN (ol
   WHERE (ol.order_id=perf_results->qual[d_pr.seq].order_id))
   JOIN (p
   WHERE p.person_id=o.person_id
    AND o.person_id > 0
    AND o.person_id != null)
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd=aliastype_cd
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND ea.active_ind=1)
   JOIN (d_ea2
   WHERE d_ea2.seq=1)
   JOIN (aor
   WHERE (aor.order_id=perf_results->qual[d_pr.seq].order_id)
    AND aor.primary_flag=0)
   JOIN (p_doc
   WHERE p_doc.person_id=o.last_update_provider_id)
   JOIN (pl
   WHERE pl.person_id=re.event_personnel_id)
   JOIN (d_ptr
   WHERE d_ptr.seq=1)
   JOIN (((ptr
   WHERE (ptr.catalog_cd=perf_results->qual[d_pr.seq].catalog_cd)
    AND (ptr.task_assay_cd=perf_results->qual[d_pr.seq].task_assay_cd)
    AND (((perf_results->qual[d_pr.seq].bb_processing_cd != antigen_cd)
    AND (perf_results->qual[d_pr.seq].bb_processing_cd != antibody_scrn_cd)) OR ((((perf_results->
   qual[d_pr.seq].bb_processing_cd=crossmatch_cd)) OR ((((perf_results->qual[d_pr.seq].
   bb_processing_cd=patient_abo_cd)) OR ((perf_results->qual[d_pr.seq].bb_result_id=0))) )) )) )
   ) ORJOIN ((oc
   WHERE (oc.order_id=perf_results->qual[d_pr.seq].order_id)
    AND (oc.bb_result_id=perf_results->qual[d_pr.seq].bb_result_id))
   JOIN (d_phs_grp
   WHERE d_phs_grp.seq=1)
   JOIN (op
   WHERE (op.order_id=perf_results->qual[d_pr.seq].order_id))
   JOIN (d_phase
   WHERE d_phase.seq=1)
   JOIN (phs_grp
   WHERE op.phase_grp_cd=phs_grp.phase_group_cd
    AND op.phase_grp_cd > 0
    AND (phs_grp.task_assay_cd=perf_results->qual[d_pr.seq].task_assay_cd))
   JOIN (d_cv_oc
   WHERE d_cv_oc.seq=1)
   JOIN (((cv_oc
   WHERE cv_oc.code_value=oc.cell_cd
    AND oc.cell_cd > 0)
   ) ORJOIN ((prod
   WHERE prod.product_id=oc.product_id
    AND oc.product_id > 0)
   JOIN (d_bp2
   WHERE d_bp2.seq=1)
   JOIN (bp2
   WHERE bp2.product_id=prod.product_id)
   )) ))
  ORDER BY test_site2, personunique, aor.accession,
   orderunique, oc.bb_result_id, product_nbr,
   ptr.sequence, phs_grp.sequence, perfresultids
  HEAD REPORT
   MACRO (print_stuff)
    FOR (i = 1 TO limit)
      saverow = row, nbr_rows_left = reportstuff->qual[i].detailcount
      IF (nbr_rows_left > 0
       AND ((nbr_rows_left+ saverow) > 57)
       AND nbr_rows_left < 42)
       BREAK
      ENDIF
      IF (row > 57)
       BREAK
      ENDIF
      col 0, reportstuff->qual[i].printline, row + 1,
      CALL clear_item(0,i,blank_line), reportstuff->qual[i].detailcount = 0
    ENDFOR
    limit = 0
   ENDMACRO
   ,
   CALL clear_reportstuff(" "), first_page = "Y",
   select_ok_ind = 0, pat_nbr = fillstring(20," "), status_disp = fillstring(21," "),
   numeric_result = fillstring(50," ")
  HEAD PAGE
   CALL center(captions->title_text,1,132), col 114, captions->rpt_date,
   col + 1, curdate"@DATECONDENSED;;d", row + 1,
   col 114, captions->rpt_time, col + 1,
   curtime"@TIMENOSECONDS;;M", row + 1, col 114,
   captions->rpt_by, col 120, reportbyusername"##########;L",
   row + 1, col 114, captions->page_no,
   col + 1, curpage"##", inc_i18nhandle = 0,
   inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
   save_row = row, row 1, row save_row,
   row + 1, col 0, captions->test_site
   IF (textlen(trim(test_site2))=0)
    col + 1, first_service_resource
   ELSE
    col + 1, test_site2
   ENDIF
   row + 2, col 20, captions->beg_date,
   col 36, begin_date, col 60,
   captions->end_date, col 74, end_date,
   row + 2, row + 1, col 25,
   captions->order_proc, row + 1, col 26,
   captions->accession, row + 1, col 4,
   captions->person_name, col 22, captions->collect_dt_tm,
   row + 1, col 7, captions->number,
   col 27, captions->priority, col 89,
   captions->performed, col 111, captions->verified,
   row + 1, col 6, captions->age_sex,
   col 27, captions->provider, col 43,
   captions->cell_product, col 60, captions->procedure,
   col 73, captions->result, col 85,
   captions->tech_id, col 94, captions->date,
   col 101, captions->time, col 106,
   captions->tech_id, col 115, captions->date,
   col 122, captions->time, row + 1,
   col 0, hyphen_line, col 20,
   " ", col 42, " ",
   col 59, " ", col 72,
   " ", col 84, " ",
   col 92, " ", col 100,
   " ", col 105, " ",
   col 113, " ", col 121,
   " ", row + 1
  HEAD test_site2
   IF (first_page="N")
    BREAK
   ELSE
    first_page = "N"
   ENDIF
   first_person = "Y"
  HEAD personunique
   pat_nbr = "", mrn_count = 0, short_age = formatage(p.birth_dt_tm,p.deceased_dt_tm,"LABRPTAGE"),
   CALL store_item(0,1,short_name), order_row = 0, detail_row = 0
  HEAD orderunique
   pat_nbr = ""
   IF (trim(ea.alias,3) != "")
    pat_nbr = cnvtalias(ea.alias,ea.alias_pool_cd), mrn_index_found = locateval(mrn_idx,1,size(
      patientmrnlist->qual,5),pat_nbr,patientmrnlist->qual[mrn_idx].mrn)
    IF (mrn_index_found <= 0)
     mrn_count += 1
     IF (mod(mrn_count,10)=1)
      stat = alterlist(patientmrnlist->qual,(mrn_count+ 9))
     ENDIF
     patientmrnlist->qual[mrn_count].mrn = pat_nbr,
     CALL store_item(0,(mrn_count+ 1),pat_nbr)
    ENDIF
   ENDIF
   IF (detail_row > order_row)
    order_row = detail_row
   ELSE
    detail_row = order_row
   ENDIF
   order_row += 1, detail_row += 1, save1stline = order_row,
   CALL store_item(21,order_row,ord_mnem), order_row += 1,
   CALL store_item(21,order_row,cnvtacc(aor.accession)),
   order_row += 1
   IF (size(trim(drawntime),3) > 0)
    CALL store_item(21,order_row,drawntime), order_row += 1
   ENDIF
   IF (ol_exists="Y")
    CALL store_item(21,order_row,shortpri), order_row += 1
   ENDIF
   IF (trim(p_doc.name_full_formatted) != "DR.")
    CALL store_item(21,order_row,p_doc.name_full_formatted), order_row += 1
   ENDIF
  HEAD oc.bb_result_id
   IF (cell_yn="Y"
    AND product_yn="N")
    CALL store_item(43,detail_row,cv_oc.display)
   ELSEIF (cell_yn="N"
    AND product_yn="Y")
    prod_nbr_display = concat(trim(bp2.supplier_prefix),trim(prod.product_nbr)," ",trim(prod
      .product_sub_nbr)),
    CALL store_item(43,detail_row,prod_nbr_display)
   ENDIF
  HEAD product_nbr
   IF (product_nbr > " ")
    CALL store_item(43,detail_row,product_nbr)
   ENDIF
  HEAD ptr.sequence
   no_op = 0
  HEAD phs_grp.sequence
   no_op = 0
  HEAD perfresultids
   IF (store_perform_result_id=pr.perform_result_id)
    dont_print_proc = 1
   ELSE
    dont_print_proc = 0
   ENDIF
   IF (pr.result_id > 0
    AND dont_print_proc=0)
    store_perform_result_id = pr.perform_result_id, procedure_row_hold = detail_row,
    CALL store_item(60,detail_row,detail_mnem)
    IF (type_cdf_meaning IN ("1", "7"))
     IF (pr.long_text_id=0)
      CALL store_item(73,detail_row,text_results), offset = (size(trim(text_results),3)+ 73)
     ELSE
      no_op = 0, offset = 76
     ENDIF
    ELSEIF (((type_cdf_meaning="2") OR (type_cdf_meaning="4"
     AND bb_processing_cd != patient_abo_cd)) )
     CALL store_item(73,detail_row,alpha_result), offset = (size(trim(alpha_result),3)+ 73)
    ELSEIF (type_cdf_meaning IN ("3", "8"))
     arg_min_digits = perf_results->qual[d_pr.seq].arg_min_digits, arg_max_digits = perf_results->
     qual[d_pr.seq].arg_max_digits, arg_min_dec_places = perf_results->qual[d_pr.seq].
     arg_min_dec_places,
     arg_less_great_flag = perf_results->qual[d_pr.seq].arg_less_great_flag, arg_raw_value = pr
     .result_value_numeric, numeric_result = cnvtstring(pr.result_value_numeric),
     numeric_result = uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
      arg_less_great_flag,arg_raw_value),
     CALL store_item(73,detail_row,numeric_result), offset = (size(trim(numeric_result),3)+ 73)
    ELSEIF (type_cdf_meaning="6")
     CALL store_item(73,detail_row,date_result), offset = (size(trim(date_result),3)+ 73)
    ELSEIF (type_cdf_meaning="11")
     CALL store_item(73,detail_row,date_time_result), offset = (size(trim(date_time_result),3)+ 73)
    ELSE
     CALL store_item(73,detail_row,result_code_set_disp), offset = (size(trim(result_code_set_disp),3
      )+ 73)
    ENDIF
    IF (pr.result_status_cd IN (corrected_cd, oldcorrected_cd))
     correction_flag = "Y"
    ELSE
     correction_flag = " "
    ENDIF
    resultflagstr = bldresultflagstr(norm_display,crit_display,revw_display,delta_display,"N",
     "N",correction_flag,notify_disp)
    IF (size(trim(resultflagstr),3) > 0)
     offset += 1
     IF (((offset+ size(trim(resultflagstr),3)) > 84))
      resultflagstr = substring(1,(84 - offset),resultflagstr)
     ENDIF
     CALL store_item(offset,detail_row,resultflagstr), no_op = 0
    ENDIF
   ENDIF
  DETAIL
   IF (store_perfresultids != perfresultids)
    store_perfresultids = perfresultids
    IF (pr.result_id > 0)
     IF (re.event_type_cd IN (verified_cd, corrected_cd))
      offset = 106,
      CALL clear_item(105,procedure_row_hold,fillstring(21," "))
      IF (tech_name > " ")
       CALL store_item(offset,procedure_row_hold,tech_name)
      ENDIF
      offset += 8,
      CALL store_item(offset,procedure_row_hold,event_date)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ELSEIF (re.event_type_cd IN (performed_cd))
      offset = 85,
      CALL clear_item(105,procedure_row_hold,fillstring(21," "))
      IF (tech_name > " ")
       CALL store_item(offset,procedure_row_hold,tech_name)
      ENDIF
      offset += 8,
      CALL store_item(offset,procedure_row_hold,event_date)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ELSEIF (re.event_type_cd=inreview_cd)
      offset = 85,
      CALL clear_item(offset,procedure_row_hold,fillstring(20," "))
      IF (perftechname > " ")
       CALL store_item(offset,procedure_row_hold,perftechname)
      ENDIF
      offset += 8,
      CALL store_item(offset,procedure_row_hold,performdttm), status_disp = substring(1,20,concat(
        "<<< ",trim(uar_get_code_display(re.event_type_cd))," >>>")),
      offset = 107,
      CALL store_item(offset,procedure_row_hold,status_disp)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ELSEIF (re.event_type_cd=corrinreview_cd)
      status_disp = substring(1,21,concat("<<< ",trim(uar_get_code_display(re.event_type_cd))," >>>")
       ), offset = 105,
      CALL store_item(offset,procedure_row_hold,status_disp)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  perfresultids
   IF (dont_print_proc=0)
    FOR (i = 1 TO nbr_comments)
      IF ((r_long_text->qual[i].perform_result_id=pr.perform_result_id)
       AND (r_long_text->qual[i].event_sequence=re.event_sequence)
       AND size(r_long_text->qual[i].text_result,1) > 0)
       IF ((r_long_text->qual[i].result_status_cd IN (corrected_cd, oldcorrected_cd)))
        CALL store_item(63,detail_row,captions->text_result_correct), vcstring = r_long_text->qual[i]
        .text_result, detail_row = store_varchar_item2(detail_row,88,39,1)
       ELSE
        CALL store_item(63,detail_row,captions->text_result), vcstring = r_long_text->qual[i].
        text_result, detail_row = store_varchar_item2(detail_row,76,51,1)
       ENDIF
      ENDIF
    ENDFOR
    FOR (i = 1 TO nbr_comments)
      IF ((r_long_text->qual[i].perform_result_id=pr.perform_result_id)
       AND (r_long_text->qual[i].event_sequence=re.event_sequence))
       IF (size(r_long_text->qual[i].comment_text,1) > 0)
        detail_row += 1,
        CALL store_item(63,detail_row,captions->comment), vcstring = r_long_text->qual[i].
        comment_text,
        detail_row = store_varchar_item2(detail_row,72,55,1)
       ENDIF
       IF (size(r_long_text->qual[i].note_text,1) > 0)
        detail_row += 1,
        CALL store_item(63,detail_row,captions->note), vcstring = r_long_text->qual[i].note_text,
        detail_row = store_varchar_item2(detail_row,72,55,1)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  FOOT  orderunique
   reportstuff->qual[save1stline].detailcount = ((detail_row - save1stline)+ 1)
  FOOT  personunique
   stat = initrec(patientmrnlist)
   IF (mrn_count=0)
    CALL store_item(0,2,captions->not_on_file), mrn_count += 1
   ENDIF
   CALL store_item(0,(mrn_count+ 2),short_age)
   IF (trim(psex) > "")
    CALL store_item(9,(mrn_count+ 2),psex)
   ELSE
    CALL store_item(9,(mrn_count+ 2),captions->unknown)
   ENDIF
   IF (first_person="Y")
    first_person = "N"
   ELSE
    row + 2
   ENDIF
   print_stuff
  FOOT PAGE
   row 59, col 0, hyphen_line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 110, curdate"@DATECONDENSED;;d",
   col 120, curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   print_stuff, row + 2,
   CALL center(captions->end_of_report,1,126),
   select_ok_ind = 1
  WITH nocounter, dontcare = p_doc, outerjoin = d_ptr,
   outerjoin = ptr, outerjoin = oc, outerjoin = d_phs_grp,
   dontcare = bp2, dontcare = op, dontcare = phs_grp,
   outerjoin = d_cv_oc, dontcare = cv_oc, dontcare = prod,
   outerjoin = d_ea, dontcare = ea, outerjoin = d_ea2,
   compress, nolandscape, nullreport,
   maxrow = 63
 ;end select
 IF (nbr_prs=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > " ")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->printer_name)
 ENDIF
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE SET testsites
END GO
