CREATE PROGRAM dcp_rpt_pvpatlist_no_sort:dba
 RECORD visit_persons(
   1 qual[*]
     2 person_id = f8
 )
 RECORD persons(
   1 qual[*]
     2 person_id = f8
     2 print_flg = i2
 )
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 name = vc
     2 unit = vc
     2 room = vc
     2 bed = vc
     2 mrn = vc
     2 gender = vc
     2 age = vc
     2 dob = vc
     2 dos = i2
     2 admit = vc
     2 disch = vc
     2 admitdoc = vc
 )
 FREE RECORD treq
 RECORD treq(
   1 encntrs[*]
     2 encntr_id = f8
     2 transaction_dt_tm = dq8
   1 facilities[*]
     2 loc_facility_cd = f8
 )
 FREE RECORD trep
 RECORD trep(
   1 encntrs_qual_cnt = i4
   1 encntrs[*]
     2 encntr_id = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 transaction_dt_tm = dq8
     2 check = i2
     2 status = i2
     2 loc_fac_cd = f8
   1 facilities_qual_cnt = i4
   1 facilities[*]
     2 loc_facility_cd = f8
     2 time_zone_indx = i4
     2 time_zone = vc
     2 status = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD wrap
 RECORD wrap(
   1 wrap_cnt = i4
   1 text_line[*]
     2 text_line = vc
     2 break_pos = i4
     2 num_breaks = i4
 )
 SET modify = predeclare
 DECLARE word_wrap(comment_text=vc,ll=i4) = i4
 DECLARE wrap_cnt = i4
 DECLARE break_pos = i4
 DECLARE break_hold_pos = i4
 DECLARE line_length = i4
 DECLARE ll_hold = i4
 DECLARE entire_text = vc
 DECLARE reg_tz = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE attend_doc_cd = f8 WITH noconstant(0.0)
 DECLARE cnt = i4 WITH noconstant(0)
 DECLARE disch_null_ind = i2 WITH noconstant(0)
 DECLARE g = vc WITH noconstant(fillstring(27,"_"))
 DECLARE k = vc WITH noconstant(fillstring(34,"_"))
 DECLARE life_mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE list_name = vc WITH noconstant(fillstring(40," "))
 DECLARE mrn_alias_cd = f8 WITH noconstant(0.0)
 DECLARE new_timedisp = vc WITH noconstant(cnvtstring(curtime3))
 DECLARE ops_ind = c1 WITH noconstant("N")
 DECLARE reg_null_ind = i2 WITH noconstant(0)
 DECLARE tempfile1a = vc WITH noconstant(fillstring(27," "))
 DECLARE uname = vc WITH noconstant(fillstring(50," "))
 DECLARE xxx = vc WITH noconstant(fillstring(50," "))
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE strsize = i4 WITH noconstant(0)
 DECLARE loops = i4 WITH noconstant(0)
 DECLARE strwraptext1 = vc WITH noconstant(fillstring(50," "))
 DECLARE strwraptext2 = vc WITH noconstant(fillstring(50," "))
 DECLARE strwraptext3 = vc WITH noconstant(fillstring(50," "))
 SUBROUTINE word_wrap(comment_text,ll)
   SET wrap_cnt = 0
   SET break_pos = 0
   SET break_hold_pos = 0
   SET line_length = 0
   SET ll_hold = 0
   SET line_length = ll
   SET ll_hold = ll
   SET entire_text = comment_text
   FOR (ptr = 1 TO size(entire_text))
    IF (substring(ptr,1,entire_text) IN (" ", ",", "\"))
     SET break_pos = ptr
    ELSEIF (((ptr=17) OR (ptr=32)) )
     SET break_pos = ptr
    ENDIF
    IF (ptr=line_length)
     IF (ptr < 19
      AND break_pos=0)
      SET break_pos = 17
     ENDIF
     IF (ptr > 19
      AND break_pos < 19)
      SET break_pos = (break_hold_pos+ 16)
     ENDIF
     IF (ptr > 37
      AND break_pos < 37)
      SET break_pos = (break_hold_pos+ 16)
     ENDIF
     SET wrap_cnt = (wrap_cnt+ 1)
     SET stat = alterlist(wrap->text_line,wrap_cnt)
     SET wrap->text_line[wrap_cnt].break_pos = (break_pos+ 1)
     SET break_hold_pos = break_pos
     SET line_length = (ll_hold+ break_pos)
    ENDIF
   ENDFOR
   IF (break_pos=0
    AND size(entire_text) > 0)
    IF (size(entire_text) <= line_length)
     SET stat = alterlist(wrap->text_line,1)
     SET wrap->wrap_cnt = 1
     SET wrap->text_line[1].text_line = entire_text
    ELSE
     IF (mod(size(entire_text),line_length)=0)
      SET wrap_cnt = cnvtint((size(entire_text)/ line_length))
     ELSE
      SET wrap_cnt = (cnvtint((size(entire_text)/ line_length))+ 1)
     ENDIF
     SET wrap->wrap_cnt = wrap_cnt
     SET stat = alterlist(wrap->text_line,wrap_cnt)
     FOR (xyz = 1 TO wrap_cnt)
       IF (xyz=1)
        SET wrap->text_line[xyz].text_line = substring(1,line_length,entire_text)
       ELSE
        SET wrap->text_line[xyz].text_line = substring((((xyz - 1) * line_length)+ 1),line_length,
         entire_text)
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    SET wrap_cnt = (wrap_cnt+ 1)
    SET wrap->wrap_cnt = wrap_cnt
    SET stat = alterlist(wrap->text_line,wrap_cnt)
    SET wrap->text_line[wrap_cnt].break_pos = (size(entire_text)+ 1)
    FOR (ln_cnt = 1 TO size(wrap->text_line,5))
      IF (ln_cnt=1)
       SET wrap->text_line[ln_cnt].text_line = substring(1,(wrap->text_line[ln_cnt].break_pos - 1),
        entire_text)
      ELSE
       SET wrap->text_line[ln_cnt].text_line = substring(wrap->text_line[(ln_cnt - 1)].break_pos,(
        wrap->text_line[ln_cnt].break_pos - wrap->text_line[(ln_cnt - 1)].break_pos),entire_text)
      ENDIF
    ENDFOR
   ENDIF
 END ;Subroutine
 IF ((request->batch_selection > " "))
  SET ops_ind = "Y"
 ENDIF
 SET mrn_alias_cd = uar_get_code_by("MEANING",319,"MRN")
 SET life_mrn_alias_cd = uar_get_code_by("MEANING",4,"MRN")
 SET attend_doc_cd = uar_get_code_by("MEANING",333,"ATTENDDOC")
 FOR (x = 1 TO request->nv_cnt)
   IF ((request->nv[x].pvc_name="LISTNAME"))
    SET list_name = trim(request->nv[x].pvc_value)
   ENDIF
 ENDFOR
 SET stat = alterlist(treq->encntrs,request->visit_cnt)
 FOR (x = 0 TO request->visit_cnt)
   SET treq->encntrs[x].encntr_id = request->visit[x].encntr_id
 ENDFOR
 EXECUTE pm_get_encntr_loc_tz  WITH replace("REQUEST","TREQ"), replace("REPLY","TREP")
 FREE RECORD treq
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id=reqinfo->updt_id))
  DETAIL
   uname = p.name_full_formatted
  WITH nocounter
 ;end select
 IF ((request->visit_cnt > 0))
  SELECT INTO "nl:"
   e.encntr_id, e.reg_dt_tm, p.name_full_formatted,
   p.birth_dt_tm, ea.alias, pl.name_full_formatted,
   e.loc_nurse_unit_cd, e.loc_room_cd, e.loc_bed_cd,
   epr.seq, disch_null_ind = nullind(e.disch_dt_tm), reg_null_ind = nullind(e.reg_dt_tm)
   FROM (dummyt d  WITH seq = value(request->visit_cnt)),
    encounter e,
    person p,
    (dummyt d1  WITH seq = 1),
    encntr_alias ea,
    (dummyt d2  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl pl
   PLAN (d)
    JOIN (e
    WHERE (e.encntr_id=request->visit[d.seq].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (d1)
    JOIN (ea
    WHERE ea.encntr_id=e.encntr_id
     AND ea.encntr_alias_type_cd=mrn_alias_cd
     AND ea.active_ind=1)
    JOIN (d2)
    JOIN (epr
    WHERE epr.encntr_id=e.encntr_id
     AND epr.encntr_prsnl_r_cd=attend_doc_cd
     AND epr.active_ind=1
     AND ((epr.expiration_ind != 1) OR (epr.expiration_ind = null))
     AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
    JOIN (pl
    WHERE pl.person_id=epr.prsnl_person_id)
   HEAD REPORT
    cnt = 0, gender = " ", dos = 0
   HEAD e.encntr_id
    cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), stat = alterlist(visit_persons->qual,cnt),
    pos = locateval(pos,1,size(trep->encntrs,5),e.encntr_id,trep->encntrs[1].encntr_id),
    visit_persons->qual[cnt].person_id = e.person_id, temp->qual[cnt].name = substring(1,30,p
     .name_full_formatted),
    temp->qual[cnt].age = cnvtage(datetimezone(p.birth_dt_tm,p.birth_tz,1)), temp->qual[cnt].dob =
    datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@SHORTDATE"), temp->qual[cnt].mrn = cnvtalias(ea
     .alias,ea.alias_pool_cd),
    gender = cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))), temp->qual[cnt].gender =
    gender, temp->qual[cnt].admitdoc = substring(1,30,pl.name_full_formatted),
    temp->qual[cnt].unit = substring(1,20,uar_get_code_display(e.loc_nurse_unit_cd)), temp->qual[cnt]
    .room = substring(1,10,uar_get_code_display(e.loc_room_cd)), temp->qual[cnt].bed = substring(1,10,
     uar_get_code_display(e.loc_bed_cd)),
    temp->qual[cnt].admit = datetimezoneformat(e.reg_dt_tm,trep->encntrs[pos].time_zone_indx,
     "@SHORTDATE")
    IF (disch_null_ind=0
     AND e.disch_dt_tm <= cnvtdatetime(curdate,curtime))
     temp->qual[cnt].disch = datetimezoneformat(e.disch_dt_tm,trep->encntrs[pos].time_zone_indx,
      "@SHORTDATE")
    ENDIF
    IF (reg_null_ind=0)
     dos = datetimediff(cnvtdatetime(curdate,curtime),e.reg_dt_tm), temp->qual[cnt].dos = (dos+ 1)
    ENDIF
   WITH nocounter, outerjoin = d1, dontcare = ea,
    outerjoin = d2
  ;end select
  IF ((request->person_cnt > 0))
   SET stat = alterlist(persons->qual,request->person_cnt)
   FOR (x = 1 TO request->person_cnt)
    SET persons->qual[x].person_id = request->person[x].person_id
    SET persons->qual[x].print_flg = 1
   ENDFOR
   SELECT INTO "nl"
    FROM (dummyt d1  WITH seq = value(request->person_cnt)),
     (dummyt d2  WITH seq = size(visit_persons->qual,5))
    PLAN (d1)
     JOIN (d2
     WHERE (visit_persons->qual[d2.seq].person_id=persons->qual[d1.seq].person_id))
    DETAIL
     persons->qual[d1.seq].print_flg = 0
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    p.name_full_formatted, p.birth_dt_tm, pa.alias,
    pl.name_full_formatted
    FROM (dummyt d  WITH seq = size(persons->qual,5)),
     person p,
     (dummyt d1  WITH seq = 1),
     person_alias pa
    PLAN (d
     WHERE (persons->qual[d.seq].print_flg=1))
     JOIN (p
     WHERE (p.person_id=persons->qual[d.seq].person_id))
     JOIN (d1)
     JOIN (pa
     WHERE pa.person_id=p.person_id
      AND pa.person_alias_type_cd=life_mrn_alias_cd
      AND pa.active_ind=1)
    HEAD REPORT
     gender = " "
    HEAD p.person_id
     cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].name = substring(1,30,p
      .name_full_formatted),
     temp->qual[cnt].age = cnvtage(datetimezone(p.birth_dt_tm,p.birth_tz,1)), temp->qual[cnt].dob =
     datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@SHORTDATE"), temp->qual[cnt].mrn = cnvtalias(pa
      .alias,pa.alias_pool_cd),
     temp->qual[cnt].unit = "Lifetime", temp->qual[cnt].bed = "Relation", gender = cnvtupper(
      substring(1,1,uar_get_code_display(p.sex_cd))),
     temp->qual[cnt].gender = gender
    WITH nocounter, outerjoin = d1, dontcare = pa
   ;end select
  ENDIF
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
  DECLARE i18n_handle = i4
  SET i18n_handle = 0
  DECLARE h = i4
  SET h = uar_i18nlocalizationinit(i18n_handle,curprog,"",curcclrev)
  DECLARE i18n_printedpatientlist = vc
  DECLARE i18n_listname = vc
  DECLARE i18n_for = vc
  DECLARE i18n_location = vc
  DECLARE i18n_mrn = vc
  DECLARE i18n_name = vc
  DECLARE i18n_sexage = vc
  DECLARE i18n_dob = vc
  DECLARE i18n_day = vc
  DECLARE i18n_admit = vc
  DECLARE i18n_dc = vc
  DECLARE i18n_attendingmd = vc
  DECLARE i18n_nopatients = vc
  DECLARE i18n_page = vc
  DECLARE i18n_medtele = vc
  SET i18n_printedpatientlist = uar_i18ngetmessage(i18n_handle,"i18n_key_PrintedPatientList",
   "Printed Patient List")
  SET i18n_listname = uar_i18ngetmessage(i18n_handle,"i18n_key_ListName","List Name")
  SET i18n_for = uar_i18ngetmessage(i18n_handle,"i18n_key_For","For")
  SET i18n_location = uar_i18ngetmessage(i18n_handle,"i18n_key_Location","Location")
  SET i18n_mrn = uar_i18ngetmessage(i18n_handle,"i18n_key_MRN","MRN")
  SET i18n_name = uar_i18ngetmessage(i18n_handle,"i18n_key_Name","Name")
  SET i18n_sexage = uar_i18ngetmessage(i18n_handle,"i18n_key_SexAge","Sex/Age")
  SET i18n_dob = uar_i18ngetmessage(i18n_handle,"i18n_key_DOB","DOB")
  SET i18n_day = uar_i18ngetmessage(i18n_handle,"i18n_key_Day","Day")
  SET i18n_admit = uar_i18ngetmessage(i18n_handle,"i18n_key_Admit","Admit")
  SET i18n_dc = uar_i18ngetmessage(i18n_handle,"i18n_key_DC","D/C")
  SET i18n_attendingmd = uar_i18ngetmessage(i18n_handle,"i18n_key_AttendingMD","Attending MD")
  SET i18n_nopatients = uar_i18ngetmessage(i18n_handle,"i18n_key_NoPatients",
   "No patients for this provider")
  SET i18n_page = uar_i18ngetmessage(i18n_handle,"i18n_key_Page","Page")
  SET i18n_medtele = uar_i18ngetmessage(i18n_handle,"i18n_key_MedTele","Med/Tele")
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  SELECT INTO value(tempfile1a)
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    start_cnt = 1
   HEAD PAGE
    "{pos/30/05}{f/13}{cpi/10}", i18n_printedpatientlist, row + 1
    IF (list_name > " ")
     "{pos/30/17}{cpi/14}", i18n_listname, ": ",
     list_name, row + 1, "{pos/30/29}{cpi/14}",
     i18n_for, ": ", uname,
     row + 1
    ELSE
     "{pos/30/17}{cpi/14}", i18n_for, ": ",
     uname, row + 1
    ENDIF
    ycol = 70, "{pos/30/50}{f/13}{cpi/14}", i18n_location,
    "{pos/115/50}", i18n_mrn, "{pos/180/50}",
    i18n_name, "  ", "{pos/280/50}",
    i18n_sexage, "{pos/330/50}", i18n_dob,
    "{pos/370/50}", i18n_day, "{pos/410/50}",
    i18n_admit, "{pos/450/50}", i18n_dc,
    "{pos/490/50}", i18n_attendingmd, "{f/12}{cpi/16}",
    row + 1
   DETAIL
    row + 0, xcol = 30
    FOR (x = start_cnt TO cnt)
      strwraptext1 = "", strwraptext2 = "", strwraptext3 = "",
      linebump = 0
      IF ((temp->qual[x].unit > " "))
       a = findstring(i18n_medtele,temp->qual[x].unit)
       IF (a > 1)
        unitstr = replace(temp->qual[x].unit,i18n_medtele,"",0), temp->qual[x].unit = unitstr
       ENDIF
       IF ((temp->qual[x].disch > " "))
        xxx = concat("{COLOR/7}",trim(temp->qual[x].unit)," ",trim(temp->qual[x].room),"-",
         trim(temp->qual[x].bed),"{COLOR/0}")
       ELSE
        xxx = concat(trim(temp->qual[x].unit)," ",trim(temp->qual[x].room),"-",trim(temp->qual[x].bed
          ))
       ENDIF
       CALL word_wrap(xxx,18)
       IF ((wrap->wrap_cnt > 0))
        strwraptext1 = wrap->text_line[1].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 1))
        strwraptext2 = wrap->text_line[2].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 2))
        strwraptext3 = wrap->text_line[3].text_line
       ENDIF
      ELSE
       xxx = fillstring(50," ")
      ENDIF
      CALL print(calcpos(30,ycol)), strwraptext1
      IF (size(strwraptext2,1) > 0)
       CALL print(calcpos(30,(ycol+ 7))), strwraptext2, linebump = (linebump+ 7)
      ENDIF
      IF (size(strwraptext3,1) > 0)
       CALL print(calcpos(30,(ycol+ 14))), strwraptext3, linebump = (linebump+ 7)
      ENDIF
      CALL print(calcpos(115,ycol)), temp->qual[x].mrn, strwraptext1 = "",
      strwraptext2 = "", strwraptext3 = "", linebump = 0
      IF ((temp->qual[x].name > " "))
       xxx = trim(temp->qual[x].name),
       CALL word_wrap(xxx,18)
       IF ((wrap->wrap_cnt > 0))
        strwraptext1 = wrap->text_line[1].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 1))
        strwraptext2 = wrap->text_line[2].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 2))
        strwraptext3 = wrap->text_line[3].text_line
       ENDIF
      ELSE
       xxx = fillstring(50," ")
      ENDIF
      CALL print(calcpos(180,ycol)), strwraptext1
      IF (size(strwraptext2,1) > 0)
       CALL print(calcpos(180,(ycol+ 7))), strwraptext2, linebump = (linebump+ 7)
      ENDIF
      IF (size(strwraptext3,1) > 0)
       CALL print(calcpos(180,(ycol+ 14))), strwraptext3, linebump = (linebump+ 7)
      ENDIF
      CALL print(calcpos(280,ycol)), temp->qual[x].gender,
      CALL print(calcpos(285,ycol)),
      temp->qual[x].age,
      CALL print(calcpos(330,ycol)), temp->qual[x].dob
      IF ((temp->qual[x].dos > 0))
       CALL print(calcpos(370,ycol)), temp->qual[x].dos";L"
      ENDIF
      CALL print(calcpos(410,ycol)), temp->qual[x].admit,
      CALL print(calcpos(450,ycol)),
      temp->qual[x].disch, strwraptext1 = "", strwraptext2 = "",
      strwraptext3 = "", linebump = 0
      IF ((temp->qual[x].admitdoc > " "))
       xxx = trim(temp->qual[x].admitdoc),
       CALL word_wrap(xxx,18)
       IF ((wrap->wrap_cnt > 0))
        strwraptext1 = wrap->text_line[1].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 1))
        strwraptext2 = wrap->text_line[2].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 2))
        strwraptext3 = wrap->text_line[3].text_line
       ENDIF
      ELSE
       xxx = fillstring(50," ")
      ENDIF
      CALL print(calcpos(490,ycol)), strwraptext1
      IF (size(strwraptext2,1) > 0)
       CALL print(calcpos(490,(ycol+ 7))), strwraptext2, linebump = (linebump+ 7)
      ENDIF
      IF (size(strwraptext3,1) > 0)
       CALL print(calcpos(490,(ycol+ 14))), strwraptext3, linebump = (linebump+ 7)
      ENDIF
      ycol = ((ycol+ 28)+ linebump), row + 1
      IF (ycol > 680
       AND x < cnt)
       start_cnt = (x+ 1), BREAK
      ENDIF
    ENDFOR
   FOOT PAGE
    ycol = 750, xcol = 250,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}{cpi/16}", i18n_page, curpage,
    row + 1, xcol = 310,
    CALL print(calcpos(xcol,ycol)),
    curdate, col + 3, curtime,
    row + 1
   WITH nocounter, dio = postscript, maxcol = 800,
    maxrow = 750
  ;end select
 ELSEIF ((request->person_cnt > 0))
  SELECT INTO "nl:"
   p.name_full_formatted, p.birth_dt_tm, pa.alias,
   pl.name_full_formatted
   FROM (dummyt d  WITH seq = value(request->person_cnt)),
    person p,
    (dummyt d1  WITH seq = 1),
    person_alias pa
   PLAN (d)
    JOIN (p
    WHERE (p.person_id=request->person[d.seq].person_id))
    JOIN (d1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=life_mrn_alias_cd
     AND pa.active_ind=1)
   HEAD REPORT
    cnt = 0, gender = " "
   HEAD p.person_id
    cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].name = substring(1,30,p
     .name_full_formatted),
    temp->qual[cnt].age = cnvtage(datetimezone(p.birth_dt_tm,p.birth_tz,1)), temp->qual[cnt].dob =
    datetimezoneformat(p.birth_dt_tm,p.birth_tz,"@SHORTDATE"), temp->qual[cnt].mrn = cnvtalias(pa
     .alias,pa.alias_pool_cd),
    gender = cnvtupper(substring(1,1,uar_get_code_display(p.sex_cd))), temp->qual[cnt].gender =
    gender
   WITH nocounter, outerjoin = d1, dontcare = pa
  ;end select
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  SELECT INTO value(tempfile1a)
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    start_cnt = 1
   HEAD PAGE
    "{pos/30/05}{f/13}{cpi/10}", i18n_printedpatientlist, row + 1
    IF (list_name > " ")
     "{pos/30/17}{cpi/14}", i18n_listname, ": ",
     list_name, row + 1, "{pos/30/29}{cpi/14}",
     i18n_for, ": ", uname,
     row + 1
    ELSE
     "{pos/30/17}{cpi/14}", i18n_for, ": ",
     uname, row + 1
    ENDIF
    ycol = 70, "{pos/30/50}{f/13}{cpi/14}", i18n_mrn,
    "{pos/120/50}", i18n_name, "  ",
    "{pos/230/50}", i18n_sexage, "{pos/290/50}",
    i18n_dob, "{f/12}{cpi/16}", row + 1
   DETAIL
    row + 0, xcol = 30
    FOR (x = start_cnt TO cnt)
      strwraptext1 = "", strwraptext2 = "", strwraptext3 = "",
      linebump = 0,
      CALL print(calcpos(30,ycol)), temp->qual[x].mrn
      IF ((temp->qual[x].name > " "))
       xxx = trim(temp->qual[x].name),
       CALL word_wrap(xxx,18)
       IF ((wrap->wrap_cnt > 0))
        strwraptext1 = wrap->text_line[1].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 1))
        strwraptext2 = wrap->text_line[2].text_line
       ENDIF
       IF ((wrap->wrap_cnt > 2))
        strwraptext3 = wrap->text_line[3].text_line
       ENDIF
      ELSE
       xxx = fillstring(50," ")
      ENDIF
      CALL print(calcpos(120,ycol)), strwraptext1
      IF (size(strwraptext2,1) > 0)
       CALL print(calcpos(120,(ycol+ 7))), strwraptext2, linebump = (linebump+ 7)
      ENDIF
      IF (size(strwraptext3,1) > 0)
       CALL print(calcpos(120,(ycol+ 14))), strwraptext3, linebump = (linebump+ 7)
      ENDIF
      CALL print(calcpos(230,ycol)), temp->qual[x].gender,
      CALL print(calcpos(235,ycol)),
      temp->qual[x].age,
      CALL print(calcpos(290,ycol)), temp->qual[x].dob,
      ycol = ((ycol+ 28)+ linebump), row + 1
      IF (ycol > 680
       AND x < cnt)
       start_cnt = (x+ 1), BREAK
      ENDIF
    ENDFOR
   FOOT PAGE
    ycol = 750, xcol = 250,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}{cpi/16}", i18n_page, curpage,
    row + 1, xcol = 310,
    CALL print(calcpos(xcol,ycol)),
    curdate, col + 3, curtime,
    row + 1
   WITH nocounter, dio = postscript, maxcol = 800,
    maxrow = 750
  ;end select
 ELSE
  SET new_timedisp = cnvtstring(curtime3)
  SET tempfile1a = build(concat("cer_temp:ptlrpt","_",new_timedisp),".dat")
  SELECT INTO value(tempfile1a)
   d.seq
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   HEAD REPORT
    start_cnt = 1
   HEAD PAGE
    "{pos/30/05}{f/13}{cpi/10}", i18n_printedpatientlist, row + 1
    IF (list_name > " ")
     "{pos/30/17}{cpi/14}", i18n_listname, ": ",
     list_name, row + 1, "{pos/30/29}{cpi/14}",
     i18n_for, ": ", uname,
     row + 1
    ELSE
     "{pos/30/17}{cpi/14}", i18n_for, ": ",
     uname, row + 1
    ENDIF
    ycol = 70, "{pos/30/50}{f/13}{cpi/14}", i18n_location,
    "{pos/115/50}", i18n_mrn, "{pos/180/50}",
    i18n_name, "  ", "{pos/280/50}",
    i18n_sexage, "{pos/330/50}", i18n_dob,
    "{pos/370/50}", i18n_day, "{pos/410/50}",
    i18n_admit, "{pos/450/50}", i18n_dc,
    "{pos/490/50}", i18n_attendingmd, "{f/12}{cpi/16}",
    row + 1, xcol = 180, ycol = 120,
    CALL print("*** ",i18n_nopatientsforthisprovider," *** "), row + 1
   DETAIL
    xcol = 180
   FOOT PAGE
    ycol = 750, xcol = 250,
    CALL print(calcpos(xcol,ycol)),
    "{f/8}{cpi/16}", i18n_page, curpage,
    row + 1, xcol = 310,
    CALL print(calcpos(xcol,ycol)),
    curdate, col + 3, curtime,
    row + 1
   WITH nocounter, dio = postscript, maxcol = 800,
    maxrow = 750
  ;end select
 ENDIF
 SET spool value(trim(tempfile1a)) value(request->output_device) WITH deleted
 SET reply->text = tempfile1a
 FREE RECORD trep
END GO
