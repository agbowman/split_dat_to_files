CREATE PROGRAM bbt_rpt_qc_pat_prod_results:dba
 RECORD reply(
   1 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD results(
   1 group_list[*]
     2 group_id = f8
     2 group_name = c40
     2 schedule_cd = f8
     2 segment_time = vc
     2 service_resource_cd = f8
     2 sr_location_name = c25
     2 sr_address1 = vc
     2 sr_address2 = vc
     2 sr_address3 = vc
     2 sr_address4 = vc
     2 sr_city_state_zip = vc
     2 sr_country = vc
     2 reagent_list[*]
       3 lot_information_id = f8
       3 visual_inspection_cd = f8
       3 interpretation_cd = f8
       3 action_prsnl_id = f8
       3 action_prsnl_username = vc
       3 action_dt_tm = dq8
       3 reagent_cd = f8
       3 lot_ident = c40
       3 exp_dt_tm = dq8
       3 manufacturer_cd = f8
     2 result_list[*]
       3 result_id = f8
       3 order_id = f8
       3 catalog_cd = f8
       3 assay_cd = f8
       3 person_id = f8
       3 perform_result_id = f8
 )
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
 SET reply->status_data.status = "F"
 DECLARE serror = vc WITH protect, noconstant("")
 DECLARE ngroupcnt = i2 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE nmaxresults = i4 WITH protect, noconstant(0)
 DECLARE ssingle_line = vc WITH protect, constant(fillstring(130,"-"))
 DECLARE sdouble_line = vc WITH protect, constant(fillstring(130,"="))
 DECLARE lcodeset = i4 WITH protect, noconstant(0)
 DECLARE dcodevalue = f8 WITH protect, noconstant(0.0)
 DECLARE smeaning = c12 WITH protect, noconstant("")
 DECLARE ncodecnt = i2 WITH protect, noconstant(0)
 DECLARE dmrntypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dperformstatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE dverifystatuscd = f8 WITH protect, noconstant(0.0)
 DECLARE susername = c8 WITH protect, noconstant("")
 SET lcodeset = 319
 SET smeaning = "MRN"
 SET ncodecnt = 1
 SET stat = uar_get_meaning_by_codeset(lcodeset,nullterm(smeaning),ncodecnt,dmrntypecd)
 IF (dmrntypecd=0.0)
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=lcodeset
     AND c.cdf_meaning=smeaning)
   DETAIL
    dmrntypecd = c.code_value
   WITH nocounter
  ;end select
  IF (dmrntypecd=0.0)
   CALL subevent_add("UAR","F",curprog,"dMRNTypeCd is 0")
   GO TO exit_script
  ENDIF
 ENDIF
 SET lcodeset = 1901
 SET smeaning = "PERFORMED"
 SET ncodecnt = 1
 SET stat = uar_get_meaning_by_codeset(lcodeset,nullterm(smeaning),ncodecnt,dperformstatuscd)
 IF (dperformstatuscd=0.0)
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=lcodeset
     AND c.cdf_meaning=smeaning)
   DETAIL
    dperformstatuscd = c.code_value
   WITH nocounter
  ;end select
  IF (dperformstatuscd=0.0)
   CALL subevent_add("UAR","F",curprog,"dPerformStatusCd is 0")
   GO TO exit_script
  ENDIF
 ENDIF
 SET lcodeset = 1901
 SET smeaning = "VERIFIED"
 SET ncodecnt = 1
 SET stat = uar_get_meaning_by_codeset(lcodeset,nullterm(smeaning),ncodecnt,dverifystatuscd)
 IF (dverifystatuscd=0.0)
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=lcodeset
     AND c.cdf_meaning=smeaning)
   DETAIL
    dverifystatuscd = c.code_value
   WITH nocounter
  ;end select
  IF (dverifystatuscd=0.0)
   CALL subevent_add("UAR","F",curprog,"dVerifyStatusCd is 0")
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  p.username
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   susername = trim(p.username)
  WITH nocounter
 ;end select
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
 CALL uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 report_title = vc
   1 report_date = vc
   1 report_time = vc
   1 report_user = vc
   1 service_resource = vc
   1 qc_group = vc
   1 schedule_name = vc
   1 reagents_results = vc
   1 reagent = vc
   1 manufacturer = vc
   1 lot_number = vc
   1 exp_date = vc
   1 visual = vc
   1 inspection = vc
   1 interpretation = vc
   1 tech_id = vc
   1 date = vc
   1 time = vc
   1 pat_prod_testing = vc
   1 person_name_prod_nbr = vc
   1 alias_prod_type = vc
   1 ordered_proc = vc
   1 accession_nbr = vc
   1 collection_dt_tm = vc
   1 assay = vc
   1 result = vc
   1 performed = vc
   1 verified = vc
   1 page_nbr = vc
   1 all_test_sites = vc
   1 all = vc
 )
 SET captions->report_title = uar_i18ngetmessage(i18nhandle,"report_title",
  "Patient-Product QC Result Report")
 SET captions->report_date = uar_i18ngetmessage(i18nhandle,"report_date","Date:")
 SET captions->report_time = uar_i18ngetmessage(i18nhandle,"report_time","Time:")
 SET captions->report_user = uar_i18ngetmessage(i18nhandle,"report_user","By:")
 SET captions->service_resource = uar_i18ngetmessage(i18nhandle,"service_resource",
  "Service Resource:")
 SET captions->qc_group = uar_i18ngetmessage(i18nhandle,"qc_group","Group:")
 SET captions->schedule_name = uar_i18ngetmessage(i18nhandle,"schedule_name",
  "Schedule Name and Segment Time:")
 SET captions->reagents_results = uar_i18ngetmessage(i18nhandle,"reagents_results",
  "QC Reagents/Results:")
 SET captions->reagent = uar_i18ngetmessage(i18nhandle,"reagent","Reagent")
 SET captions->manufacturer = uar_i18ngetmessage(i18nhandle,"manufacturer","Manufacturer")
 SET captions->lot_number = uar_i18ngetmessage(i18nhandle,"lot_number","Lot Number")
 SET captions->exp_date = uar_i18ngetmessage(i18nhandle,"exp_date","Exp. Date")
 SET captions->visual = uar_i18ngetmessage(i18nhandle,"visual","Visual")
 SET captions->inspection = uar_i18ngetmessage(i18nhandle,"inspection","Inspection")
 SET captions->interpretation = uar_i18ngetmessage(i18nhandle,"interpretation","Interpretation")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time")
 SET captions->pat_prod_testing = uar_i18ngetmessage(i18nhandle,"pat_prod_testing",
  "Patient-product testing:")
 SET captions->person_name_prod_nbr = uar_i18ngetmessage(i18nhandle,"person_name_prod_nbr",
  "Person name/Product #")
 SET captions->alias_prod_type = uar_i18ngetmessage(i18nhandle,"alias_prod_type","Alias/Prod Type")
 SET captions->ordered_proc = uar_i18ngetmessage(i18nhandle,"ordered_proc","Ordered Proc/")
 SET captions->accession_nbr = uar_i18ngetmessage(i18nhandle,"accession_nbr","Accession #")
 SET captions->collection_dt_tm = uar_i18ngetmessage(i18nhandle,"collection_dt_tm",
  "Collection Date/Time")
 SET captions->assay = uar_i18ngetmessage(i18nhandle,"assay","Assay")
 SET captions->result = uar_i18ngetmessage(i18nhandle,"result","Result")
 SET captions->performed = uar_i18ngetmessage(i18nhandle,"performed","Performed")
 SET captions->verified = uar_i18ngetmessage(i18nhandle,"verified","Verified")
 SET captions->page_nbr = uar_i18ngetmessage(i18nhandle,"page_nbr","PAGE ")
 SET captions->all_test_sites = uar_i18ngetmessage(i18nhandle,"all_test_sites","<<ALL TEST SITES>>")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
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
 SELECT INTO "nl:"
  reagent_disp = uar_get_code_display(pld.parent_entity_id)
  FROM (dummyt d  WITH seq = value(size(request->group_list,5))),
   bb_qc_grp_reagent_activity bqgra,
   bb_qc_grp_reagent_lot bqgrl,
   bb_qc_group_activity bqga,
   result r,
   perform_result pr,
   pcs_lot_information pli,
   pcs_lot_definition pld,
   prsnl p
  PLAN (d)
   JOIN (bqgra
   WHERE (bqgra.group_reagent_activity_id=request->group_list[d.seq].group_reagent_activity_id))
   JOIN (p
   WHERE p.person_id=bqgra.activity_prsnl_id)
   JOIN (bqga
   WHERE bqga.group_activity_id=bqgra.group_activity_id)
   JOIN (bqgrl
   WHERE bqgrl.prev_group_reagent_lot_id=bqgra.group_reagent_lot_id
    AND bqgrl.beg_effective_dt_tm <= bqga.scheduled_dt_tm
    AND bqgrl.end_effective_dt_tm > bqga.scheduled_dt_tm)
   JOIN (pli
   WHERE pli.lot_information_id=bqgrl.lot_information_id
    AND pli.end_effective_dt_tm > bqga.scheduled_dt_tm)
   JOIN (pld
   WHERE pld.lot_definition_id=pli.lot_definition_id)
   JOIN (r
   WHERE r.bb_group_id=bqga.group_id
    AND r.lot_information_id=bqgrl.lot_information_id)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.perform_dt_tm > bqga.scheduled_dt_tm
    AND pr.perform_dt_tm < cnvtdatetime(request->group_list[d.seq].next_schedule_dt_tm))
  ORDER BY bqga.group_id, reagent_disp, bqgra.group_reagent_activity_id
  HEAD REPORT
   ngroupcnt = 0, nreagentcnt = 0, nresultcnt = 0
  HEAD bqga.group_id
   ngroupcnt += 1
   IF (size(results->group_list,5) < ngroupcnt)
    stat = alterlist(results->group_list,(ngroupcnt+ 9))
   ENDIF
   results->group_list[ngroupcnt].group_id = bqga.group_id, nreagentcnt = 0
  HEAD bqgra.group_reagent_activity_id
   nreagentcnt += 1
   IF (size(results->group_list[ngroupcnt].reagent_list,5) < nreagentcnt)
    stat = alterlist(results->group_list[ngroupcnt].reagent_list,(nreagentcnt+ 9))
   ENDIF
   results->group_list[ngroupcnt].reagent_list[nreagentcnt].lot_information_id = bqgrl
   .lot_information_id, results->group_list[ngroupcnt].reagent_list[nreagentcnt].visual_inspection_cd
    = bqgra.visual_inspection_cd, results->group_list[ngroupcnt].reagent_list[nreagentcnt].
   interpretation_cd = bqgra.interpretation_cd,
   results->group_list[ngroupcnt].reagent_list[nreagentcnt].action_prsnl_id = bqgra.activity_prsnl_id,
   results->group_list[ngroupcnt].reagent_list[nreagentcnt].action_dt_tm = bqgra.activity_dt_tm,
   results->group_list[ngroupcnt].reagent_list[nreagentcnt].lot_ident = pli.lot_ident,
   results->group_list[ngroupcnt].reagent_list[nreagentcnt].exp_dt_tm = pli.expire_dt_tm, results->
   group_list[ngroupcnt].reagent_list[nreagentcnt].manufacturer_cd = pld.manufacturer_cd, results->
   group_list[ngroupcnt].reagent_list[nreagentcnt].reagent_cd = pld.parent_entity_id,
   results->group_list[ngroupcnt].reagent_list[nreagentcnt].action_prsnl_username = p.username
  HEAD pr.perform_result_id
   nresultcnt += 1
   IF (size(results->group_list[ngroupcnt].result_list,5) < nresultcnt)
    stat = alterlist(results->group_list[ngroupcnt].result_list,(nresultcnt+ 9))
   ENDIF
   IF (nresultcnt > nmaxresults)
    nmaxresults = nresultcnt
   ENDIF
   results->group_list[ngroupcnt].result_list[nresultcnt].order_id = r.order_id, results->group_list[
   ngroupcnt].result_list[nresultcnt].assay_cd = r.task_assay_cd, results->group_list[ngroupcnt].
   result_list[nresultcnt].result_id = r.result_id,
   results->group_list[ngroupcnt].result_list[nresultcnt].person_id = r.person_id, results->
   group_list[ngroupcnt].result_list[nresultcnt].catalog_cd = r.catalog_cd, results->group_list[
   ngroupcnt].result_list[nresultcnt].perform_result_id = pr.perform_result_id
  FOOT  bqga.group_id
   stat = alterlist(results->group_list[ngroupcnt].reagent_list,nreagentcnt), stat = alterlist(
    results->group_list[ngroupcnt].result_list,nresultcnt)
  FOOT REPORT
   stat = alterlist(results->group_list,ngroupcnt)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("RETRIEVE PAT/PROD RESULTS","F",curprog,serror)
  GO TO exit_script
 ENDIF
 IF (ngroupcnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ngroupcnt)),
   bb_qc_group bqg,
   bb_qc_schedule_segment bqss
  PLAN (d)
   JOIN (bqg
   WHERE (bqg.group_id=results->group_list[d.seq].group_id))
   JOIN (bqss
   WHERE (bqss.schedule_cd= Outerjoin(bqg.schedule_cd)) )
  ORDER BY bqg.group_id
  HEAD bqg.group_id
   nfirst = "Y", results->group_list[d.seq].group_name = bqg.group_name, results->group_list[d.seq].
   service_resource_cd = bqg.service_resource_cd,
   results->group_list[d.seq].schedule_cd = bqg.schedule_cd, results->group_list[d.seq].segment_time
    = format(bqss.time_nbr,"0000")
  DETAIL
   IF (nfirst="Y")
    nfirst = "N", results->group_list[d.seq].segment_time = format(bqss.time_nbr,"0000")
   ELSE
    results->group_list[d.seq].segment_time = build(results->group_list[d.seq].segment_time,",",
     format(bqss.time_nbr,"0000"))
   ENDIF
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F",curprog,serror)
  GO TO exit_script
 ENDIF
 FOR (ngroupidx = 1 TO ngroupcnt)
   IF ((results->group_list[ngroupidx].service_resource_cd > 0.0))
    SET request->address_location_cd = results->group_list[ngroupidx].service_resource_cd
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
    SET results->group_list[ngroupidx].sr_location_name = sub_get_location_name
    SET results->group_list[ngroupidx].sr_address1 = sub_get_location_address1
    SET results->group_list[ngroupidx].sr_address2 = sub_get_location_address2
    SET results->group_list[ngroupidx].sr_address3 = sub_get_location_address3
    SET results->group_list[ngroupidx].sr_address4 = sub_get_location_address4
    SET results->group_list[ngroupidx].sr_city_state_zip = sub_get_location_citystatezip
    SET results->group_list[ngroupidx].sr_country = sub_get_location_country
   ELSE
    SET results->group_list[ngroupidx].sr_location_name = captions->all_test_sites
   ENDIF
 ENDFOR
 EXECUTE cpm_create_file_name_logical "bb_qc_pat_prod", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  group_name = results->group_list[d1.seq].group_name, service_resource_disp = trim(
   uar_get_code_display(results->group_list[d1.seq].service_resource_cd)), schedule_disp = trim(
   uar_get_code_display(results->group_list[d1.seq].schedule_cd),3),
  proc_disp = substring(1,26,uar_get_code_display(results->group_list[d1.seq].result_list[d2.seq].
    catalog_cd)), sort_identifier = evaluate(nullind(p.product_id),1,build("0|",p1
    .name_full_formatted),0,build("1|",p.product_nbr)), identifier = evaluate(nullind(p.product_id),1,
   p1.name_full_formatted,0,p.product_nbr),
  alias = evaluate(nullind(p.product_id),1,cnvtalias(ea.alias,ea.alias_pool_cd),0,
   uar_get_code_display(p.product_cd)), assay_disp = substring(1,9,uar_get_code_display(results->
    group_list[d1.seq].result_list[d2.seq].assay_cd)), accession = substring(1,26,uar_fmt_accession(
    aor.accession,size(aor.accession,1))),
  result_type_meaning = uar_get_code_meaning(pr.result_type_cd), alpha_result = substring(1,9,pr
   .result_value_alpha), collect_dttm = format(c.drawn_dt_tm,"@DATETIMECONDENSED;;d"),
  event_dt = format(re.event_dt_tm,"@DATECONDENSED;;D"), event_tm = format(re.event_dt_tm,
   "@TIMENOSECONDS;;M"), perfresultids = build(pr.result_id,pr.perform_result_id,re.event_sequence),
  perform_user = substring(1,11,p2.username)
  FROM (dummyt d1  WITH seq = value(ngroupcnt)),
   (dummyt d2  WITH seq = value(nmaxresults)),
   orders o,
   encntr_alias ea,
   product p,
   person p1,
   accession_order_r aor,
   perform_result pr,
   container c,
   result_event re,
   prsnl p2
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(results->group_list[d1.seq].result_list,5))
   JOIN (o
   WHERE (o.order_id=results->group_list[d1.seq].result_list[d2.seq].order_id))
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(o.encntr_id))
    AND (ea.encntr_id> Outerjoin(0.0))
    AND (ea.encntr_alias_type_cd= Outerjoin(dmrntypecd))
    AND (ea.active_ind= Outerjoin(1)) )
   JOIN (p
   WHERE (p.product_id= Outerjoin(o.product_id))
    AND (p.product_id> Outerjoin(0.0)) )
   JOIN (p1
   WHERE (p1.person_id= Outerjoin(results->group_list[d1.seq].result_list[d2.seq].person_id)) )
   JOIN (aor
   WHERE (aor.order_id= Outerjoin(o.order_id))
    AND (aor.primary_flag= Outerjoin(0)) )
   JOIN (pr
   WHERE (pr.perform_result_id=results->group_list[d1.seq].result_list[d2.seq].perform_result_id))
   JOIN (c
   WHERE (c.container_id= Outerjoin(pr.container_id))
    AND (c.container_id> Outerjoin(0.0)) )
   JOIN (re
   WHERE (re.result_id=results->group_list[d1.seq].result_list[d2.seq].result_id)
    AND re.perform_result_id=pr.perform_result_id)
   JOIN (p2
   WHERE p2.person_id=re.event_personnel_id)
  ORDER BY group_name, sort_identifier, o.order_id,
   perfresultids
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
   CALL clear_reportstuff(" "), sfirstpage = "Y",
   sprintreagentheader = "Y", sprintreagents = "Y", sprintresultheader = "Y",
   dont_print_proc = 0, store_perform_result_id = 0.0
  HEAD PAGE
   CALL echo("HEAD PAGE"),
   CALL center(captions->report_title,1,132), col 114,
   captions->report_date, col + 1, curdate"@DATECONDENSED;;D",
   row + 1, col 114, captions->report_time,
   col + 1, curtime"@TIMENOSECONDS;;M", row + 1,
   col 116, captions->report_user, col + 1,
   susername, row 0
   IF (size(results->group_list[d1.seq].sr_location_name,3) != 0)
    col 1, results->group_list[d1.seq].sr_location_name, row + 1
   ENDIF
   IF (size(results->group_list[d1.seq].sr_address1,3) != 0)
    col 1, results->group_list[d1.seq].sr_address1, row + 1
   ENDIF
   IF (size(results->group_list[d1.seq].sr_address2,3) != 0)
    col 1, results->group_list[d1.seq].sr_address2, row + 1
   ENDIF
   IF (size(results->group_list[d1.seq].sr_address3,3) != 0)
    col 1, results->group_list[d1.seq].sr_address3, row + 1
   ENDIF
   IF (size(results->group_list[d1.seq].sr_address4,3) != 0)
    col 1, results->group_list[d1.seq].sr_address4, row + 1
   ENDIF
   IF (size(results->group_list[d1.seq].sr_city_state_zip,3) != 0)
    col 1, results->group_list[d1.seq].sr_city_state_zip, row + 1
   ENDIF
   IF (size(results->group_list[d1.seq].sr_country,3) != 0)
    col 1, results->group_list[d1.seq].sr_country, row + 1
   ENDIF
   row + 2
   IF (service_resource_disp=" ")
    sserviceresource = captions->all
   ELSE
    sserviceresource = service_resource_disp
   ENDIF
   sheader1 = uar_i18nbuildmessage(i18nhandle,"header1","Service Resource: %1  Group: %2","ss",
    nullterm(sserviceresource),
    nullterm(group_name)),
   CALL center(sheader1,1,132), row + 1,
   sheader2 = uar_i18nbuildmessage(i18nhandle,"header2","Schedule Name and Segment Time:  %1 - %2",
    "ss",nullterm(schedule_disp),
    nullterm(results->group_list[d1.seq].segment_time)),
   CALL center(sheader2,1,132)
   IF (sprintreagentheader="Y")
    row + 2, col 1, captions->reagents_results,
    row + 2, col 1, captions->reagent,
    col 18, captions->manufacturer, col 36,
    captions->lot_number, col 54, captions->exp_date,
    col 70, captions->inspection, col 86,
    captions->interpretation, col 104, captions->tech_id,
    col 115, captions->date, col 126,
    captions->time, row + 1, col 1,
    ssingle_line, sprintreagentheader = "N"
   ENDIF
   IF (sprintreagents="Y")
    nreagentcnt = size(results->group_list[d1.seq].reagent_list,5)
    FOR (nreagentidx = 1 TO nreagentcnt)
      row + 1, reagent_disp = uar_get_code_display(results->group_list[d1.seq].reagent_list[
       nreagentidx].reagent_cd), manuf_disp = uar_get_code_display(results->group_list[d1.seq].
       reagent_list[nreagentidx].manufacturer_cd),
      exp_date = format(results->group_list[d1.seq].reagent_list[nreagentidx].exp_dt_tm,
       "@DATECONDENSED;;D"), vi_disp = uar_get_code_display(results->group_list[d1.seq].reagent_list[
       nreagentidx].visual_inspection_cd), interp_disp = uar_get_code_display(results->group_list[d1
       .seq].reagent_list[nreagentidx].interpretation_cd),
      act_date = format(results->group_list[d1.seq].reagent_list[nreagentidx].action_dt_tm,
       "@DATECONDENSED;;D"), act_time = format(results->group_list[d1.seq].reagent_list[nreagentidx].
       action_dt_tm,"@TIMENOSECONDS;;M"), col 1,
      reagent_disp, col 18, manuf_disp,
      col 36, results->group_list[d1.seq].reagent_list[nreagentidx].lot_ident, col 54,
      exp_date, col 70, vi_disp,
      col 86, interp_disp, col 104,
      results->group_list[d1.seq].reagent_list[nreagentidx].action_prsnl_username, col 115, act_date,
      col 126, act_time
    ENDFOR
    row + 2, col 1, sdouble_line
   ENDIF
   IF (sprintresultheader="Y")
    row + 2, col 1, captions->pat_prod_testing,
    row + 2, col 1, captions->person_name_prod_nbr,
    col 39, captions->ordered_proc, row + 1,
    col 1, captions->alias_prod_type, col 40,
    captions->accession_nbr, col 91, captions->performed,
    col 116, captions->verified, row + 1,
    col 34, captions->collection_dt_tm, col 61,
    captions->assay, col 71, captions->result,
    col 82, captions->tech_id, col 94,
    captions->date, col 100, captions->time,
    col 109, captions->tech_id, col 119,
    captions->date, col 126, captions->time,
    row + 1, col 1, ssingle_line,
    row + 1
   ENDIF
   sprintreagentheader = "N", sprintreagents = "N"
  HEAD group_name
   IF (sfirstpage="N")
    sprintreagentheader = "Y", sprintreagents = "Y", BREAK
   ELSE
    sfirstpage = "N"
   ENDIF
  HEAD sort_identifier
   CALL store_item(0,1,identifier)
   IF (alias != " ")
    CALL store_item(0,2,alias)
   ENDIF
   lorderrow = 0, ldetailrow = 0
  HEAD o.order_id
   IF (ldetailrow > lorderrow)
    lorderrow = ldetailrow
   ELSE
    ldetailrow = lorderrow
   ENDIF
   lorderrow += 1, ldetailrow += 1, lfirstorderrow = lorderrow,
   CALL store_item(33,lorderrow,proc_disp)
   IF (accession != " ")
    lorderrow += 1,
    CALL store_item(33,lorderrow,accession)
   ENDIF
   IF (collect_dttm != " ")
    lorderrow += 1,
    CALL store_item(33,lorderrow,collect_dttm)
   ENDIF
  HEAD perfresultids
   IF (store_perform_result_id=pr.perform_result_id)
    dont_print_proc = 1
   ELSE
    dont_print_proc = 0
   ENDIF
   IF (dont_print_proc=0)
    store_perform_result_id = pr.perform_result_id,
    CALL store_item(61,ldetailrow,assay_disp),
    CALL store_item(70,ldetailrow,alpha_result)
   ENDIF
   IF (re.event_type_cd=dperformstatuscd)
    CALL store_item(80,ldetailrow,perform_user),
    CALL store_item(92,ldetailrow,event_dt),
    CALL store_item(100,ldetailrow,event_tm)
   ELSEIF (re.event_type_cd=dverifystatuscd)
    CALL store_item(107,ldetailrow,perform_user),
    CALL store_item(117,ldetailrow,event_dt),
    CALL store_item(125,ldetailrow,event_tm)
   ENDIF
  FOOT  perfresultids
   IF (dont_print_proc=1)
    ldetailrow += 1
   ENDIF
  FOOT  o.order_id
   reportstuff->qual[lfirstorderrow].detailcount = ((ldetailrow - lfirstorderrow)+ 1)
  FOOT  sort_identifier
   row + 2, print_stuff
  FOOT PAGE
   row 58, col 1, ssingle_line,
   row + 1, col 58, captions->page_nbr,
   col + 1, curpage"###"
  FOOT REPORT
   print_stuff
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("PRINT REPORT","F",curprog,serror)
  GO TO exit_script
 ENDIF
 SET reply->rpt_filename = concat("cer_print:",cpm_cfn_info->file_name)
 SET reply->status_data.status = "S"
#exit_script
 FREE SET results
END GO
