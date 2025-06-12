CREATE PROGRAM aps_prt_caselog:dba
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
 RECORD captions(
   1 curuser = vc
   1 fail1 = vc
   1 fail2 = vc
   1 fail3 = vc
   1 fail4 = vc
   1 fail5 = vc
   1 unknown = vc
   1 rreport = vc
   1 ap = vc
   1 ddate = vc
   1 dir = vc
   1 ttime = vc
   1 caselog = vc
   1 bby = vc
   1 ppage = vc
   1 prefix = vc
   1 collected = vc
   1 received = vc
   1 verified = vc
   1 accession = vc
   1 name = vc
   1 id = vc
   1 type = vc
   1 collected2 = vc
   1 received2 = vc
   1 requestedby = vc
   1 nomatches = vc
   1 cancelled = vc
   1 rptcaselog = vc
   1 contd = vc
 )
 SET captions->curuser = uar_i18ngetmessage(i18nhandle,"curuser","Operations")
 SET captions->fail1 = uar_i18ngetmessage(i18nhandle,"fail1","Failure - Error with output_dist!")
 SET captions->fail2 = uar_i18ngetmessage(i18nhandle,"fail2","Failure - Error with accession setup!")
 SET captions->fail3 = uar_i18ngetmessage(i18nhandle,"fail3","Failure - Error with codeset 2062")
 SET captions->fail4 = uar_i18ngetmessage(i18nhandle,"fail4","Failure - Error with prefix setup!")
 SET captions->fail5 = uar_i18ngetmessage(i18nhandle,"fail5",
  "Failure - Error with date routine setup!")
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"unknown","Unknown")
 SET captions->rreport = uar_i18ngetmessage(i18nhandle,"rreport","REPORT: APS_PRT_CASELOG.PRG")
 SET captions->ap = uar_i18ngetmessage(i18nhandle,"ap","Anatomic Pathology")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","Date:")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME:")
 SET captions->caselog = uar_i18ngetmessage(i18nhandle,"caselog","CASE LOG")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY:")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE:")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","Prefix(es)")
 SET captions->collected = uar_i18ngetmessage(i18nhandle,"collected","(Collected date range)")
 SET captions->received = uar_i18ngetmessage(i18nhandle,"received","(Received date range)")
 SET captions->verified = uar_i18ngetmessage(i18nhandle,"verified","(Verified date range)")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"accession","ACCESSION")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","NAME")
 SET captions->id = uar_i18ngetmessage(i18nhandle,"id","ID")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","TYPE")
 SET captions->collected2 = uar_i18ngetmessage(i18nhandle,"collected2","COLLECTED")
 SET captions->received2 = uar_i18ngetmessage(i18nhandle,"received2","RECEIVED")
 SET captions->requestedby = uar_i18ngetmessage(i18nhandle,"requestedby","REQUESTED BY")
 SET captions->nomatches = uar_i18ngetmessage(i18nhandle,"nomatches",
  "No cases matching criteria were found.")
 SET captions->cancelled = uar_i18ngetmessage(i18nhandle,"cancelled","Cancelled")
 SET captions->rptcaselog = uar_i18ngetmessage(i18nhandle,"rptcaselog","REPORT: CASE LOG")
 SET captions->contd = uar_i18ngetmessage(i18nhandle,"contd","CONTINUED...")
 RECORD temp(
   1 qual[10]
     2 case_id = f8
     2 encntr_id = f8
     2 accession_nbr = c20
     2 case_collect_dt_tm = dq8
     2 case_received_dt_tm = dq8
     2 prefix_cd = f8
     2 req_physician_name = vc
     2 req_physician_id = f8
     2 case_cancel_cd = f8
     2 spec_cnt = i2
     2 spec_qual[*]
       3 specimen_tag_display = c7
       3 specimen_description = vc
       3 specimen_cd = f8
       3 specimen_cancel_cd = f8
       3 specimen_disp = c10
       3 specimen_tag_sequence = c4
     2 person_id = f8
     2 encntr_type_cd = f8
     2 encntr_type_disp = c1
     2 person_name = vc
     2 person_num = c22
     2 name_sort_key = vc
   1 max_spec_cnt = i4
 )
 RECORD temp_pref(
   1 pref_qual[1]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 site_cd = f8
     2 site_display = vc
     2 site_prefix = vc
 )
 RECORD reply(
   1 ops_event = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 IF (textlen(trim(request->batch_selection)) > 0)
  DECLARE text = c100
  DECLARE real = f8
  DECLARE six = i2
  DECLARE pos = i2
  DECLARE startpos2 = i2
  DECLARE len = i4
  DECLARE endstring = c2
  SUBROUTINE get_text(startpos,textstring,delimit)
    SET siz = size(trim(textstring),1)
    SET pos = startpos
    SET endstring = "F"
    WHILE (pos <= siz)
     IF (substring(pos,1,trim(textstring))=delimit)
      IF (pos=siz)
       SET endstring = "T"
      ENDIF
      SET len = (pos - startpos)
      SET text = substring(startpos,len,trim(textstring))
      SET real = cnvtreal(trim(text))
      SET startpos = (pos+ 1)
      SET startpos2 = (pos+ 1)
      SET pos = siz
     ENDIF
     SET pos = (pos+ 1)
    ENDWHILE
  END ;Subroutine
  SET site_code_len = 0
  SET site_str = "     "
  SET site_code = 0.0
  SET raw_prefix_str = fillstring(100," ")
  SET site_prefix_str = fillstring(100," ")
  SET prefix_str = fillstring(100," ")
  SET site_str = fillstring(100," ")
  SET prefix_code = 0.0
  SET raw_date_str = fillstring(4," ")
  SET raw_date_num_str = 0
  SET printer = fillstring(100," ")
  SET copies = 0
  IF (textlen(trim(request->output_dist))=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = captions->fail1
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   x = 1
   DETAIL
    CALL get_text(x,trim(request->batch_selection),"|")
    IF (substring(2,1,text)=",")
     text = concat(" ",text)
    ENDIF
    raw_prefix_str = concat(trim(text),","),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), raw_date_str = trim(text),
    request->scuruser = captions->curuser, request->prefix_cnt = 0,
    CALL get_text(startpos2,trim(request->batch_selection),"|"),
    request->date_type = trim(text),
    CALL get_text(startpos2,trim(request->batch_selection),"|"), request->order_by = trim(text),
    CALL get_text(1,trim(request->output_dist),"|"), printer = trim(text),
    CALL get_text(startpos2,trim(request->output_dist),"|"),
    copies = cnvtint(trim(text))
   WITH nocounter
  ;end select
  SET startpos2 = 1
  SET endstring = "F"
  SET new_size = 0
  SELECT INTO "nl:"
   ase.accession_setup_id
   FROM accession_setup ase
   WHERE ase.accession_setup_id > 0
   DETAIL
    site_code_len = ase.site_code_length
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "F"
   SET reply->ops_event = captions->fail2
   GO TO exit_script
  ENDIF
  WHILE (endstring="F")
    SELECT INTO "nl:"
     x = 1
     DETAIL
      CALL get_text(startpos2,trim(raw_prefix_str),","), site_prefix_str = text
     WITH nocounter
    ;end select
    IF (site_code_len > 0)
     SET site_str = substring(1,site_code_len,trim(site_prefix_str))
     SET prefix_str = substring((1+ site_code_len),len,trim(site_prefix_str))
     IF (cnvtint(site_str) > 0)
      SELECT INTO "nl:"
       cv.code_value
       FROM code_value cv
       WHERE 2062=cv.code_set
        AND site_str=cv.display_key
       DETAIL
        site_code = cv.code_value
       WITH nocounter
      ;end select
      IF (curqual=0)
       SET reply->status_data.status = "F"
       SET reply->ops_event = captions->fail3
       GO TO exit_script
      ENDIF
     ELSE
      SET site_code = 0.0
     ENDIF
    ELSE
     SET site_code = 0.0
     SET prefix_str = trim(site_prefix_str)
    ENDIF
    SELECT INTO "nl:"
     ap.prefix_id
     FROM ap_prefix ap
     WHERE site_code=ap.site_cd
      AND prefix_str=ap.prefix_name
     DETAIL
      new_size = (new_size+ 1), stat = alterlist(request->prefix_qual,new_size), request->
      prefix_qual[new_size].prefix_cd = ap.prefix_id,
      request->prefix_cnt = new_size
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET reply->status_data.status = "F"
     SET reply->ops_event = captions->fail4
     GO TO exit_script
    ENDIF
  ENDWHILE
  SET raw_date_num_str = cnvtint(substring(1,3,raw_date_str))
  SET request->date_to = cnvtdatetime(sysdate)
  CASE (substring(4,1,raw_date_str))
   OF "D":
    SET request->date_from = cnvtagedatetime(0,0,0,raw_date_num_str)
   OF "M":
    SET request->date_from = cnvtagedatetime(0,raw_date_num_str,0,0)
   OF "Y":
    SET request->date_from = cnvtagedatetime(raw_date_num_str,0,0,0)
   ELSE
    SET reply->status_data.status = "F"
    SET reply->ops_event = captions->fail5
    GO TO exit_script
  ENDCASE
 ENDIF
 RECORD dtemp(
   1 beg_of_day = dq8
   1 end_of_day = dq8
   1 beg_of_day_abs = dq8
   1 end_of_day_abs = dq8
   1 beg_of_month = dq8
   1 end_of_month = dq8
   1 beg_of_month_abs = dq8
   1 end_of_month_abs = dq8
 )
 SUBROUTINE change_times(start_date,end_date)
  CALL getstartofday(start_date,0)
  CALL getendofday(end_date,0)
 END ;Subroutine
 SUBROUTINE getstartofdayabs(date_time,date_offset)
  CALL getstartofday(date_time,date_offset)
  SET dtemp->beg_of_day_abs = cnvtdatetimeutc(dtemp->beg_of_day,2)
 END ;Subroutine
 SUBROUTINE getstartofday(date_time,date_offset)
   SET dtemp->beg_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),0)
 END ;Subroutine
 SUBROUTINE getendofdayabs(date_time,date_offset)
  CALL getendofday(date_time,date_offset)
  SET dtemp->end_of_day_abs = cnvtdatetimeutc(dtemp->end_of_day,2)
 END ;Subroutine
 SUBROUTINE getendofday(date_time,date_offset)
   SET dtemp->end_of_day = cnvtdatetime((cnvtdate(date_time) - date_offset),235959)
 END ;Subroutine
 SUBROUTINE getstartofmonthabs(date_time,month_offset)
  CALL getstartofmonth(date_time,month_offset)
  SET dtemp->beg_of_month_abs = cnvtdatetimeutc(dtemp->beg_of_month,2)
 END ;Subroutine
 SUBROUTINE getstartofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) <= 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = (((month(date_time)+ month_offset) - 1)/ 12)
    SET nmonthremainder = mod((month(date_time)+ month_offset),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->beg_of_month = cnvtdatetime(cnvtdate2(date_string,"ddmmyyyy"),0)
 END ;Subroutine
 SUBROUTINE getendofmonthabs(date_time,month_offset)
  CALL getendofmonth(date_time,month_offset)
  SET dtemp->end_of_month_abs = cnvtdatetimeutc(dtemp->end_of_month,2)
 END ;Subroutine
 SUBROUTINE getendofmonth(date_time,month_offset)
   DECLARE nyearoffset = i4
   DECLARE nmonthremainder = i4
   DECLARE nbeginningmonth = i4
   IF (((month(date_time)+ month_offset) < 0))
    IF (mod(((month(date_time)+ month_offset) - 12),12) != 0)
     SET nyearoffset = (((month(date_time)+ month_offset) - 12)/ 12)
    ELSE
     SET nyearoffset = (((month(date_time)+ month_offset) - 11)/ 12)
    ENDIF
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = (12+ nmonthremainder)
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ELSE
    SET nyearoffset = ((month(date_time)+ month_offset)/ 12)
    SET nmonthremainder = mod(((month(date_time)+ month_offset)+ 1),12)
    IF (nmonthremainder != 0)
     SET nbeginningmonth = nmonthremainder
    ELSE
     SET nbeginningmonth = 12
    ENDIF
   ENDIF
   SET date_string = build("01",format(nbeginningmonth,"##;p0"),(year(date_time)+ nyearoffset))
   SET dtemp->end_of_month = cnvtdatetime((cnvtdate2(date_string,"ddmmyyyy") - 1),235959)
 END ;Subroutine
 CALL change_times(request->date_from,request->date_to)
 SET request->date_to = dtemp->end_of_day
 SET request->date_from = dtemp->beg_of_day
 SET reply->status_data.status = "F"
 SET case_defined = "F"
 SET case_where = fillstring(3000," ")
 SELECT INTO "nl:"
  cv_display = cv.display"#####", site_prefix = build(substring(1,5,cv.display),ap.prefix_name), ap
  .prefix_name,
  ap.prefix_id, ap.site_cd
  FROM ap_prefix ap,
   code_value cv,
   (dummyt d  WITH seq = value(size(request->prefix_qual,5)))
  PLAN (d)
   JOIN (ap
   WHERE (request->prefix_qual[d.seq].prefix_cd=ap.prefix_id))
   JOIN (cv
   WHERE ap.site_cd=cv.code_value)
  ORDER BY site_prefix
  HEAD REPORT
   stat = alter(temp_pref->pref_qual,value(size(request->prefix_qual,5))), pref_cntr = 0
  HEAD site_prefix
   pref_cntr = (pref_cntr+ 1), temp_pref->pref_qual[pref_cntr].prefix_cd = ap.prefix_id, temp_pref->
   pref_qual[pref_cntr].prefix_name = ap.prefix_name,
   temp_pref->pref_qual[pref_cntr].site_cd = ap.site_cd, temp_pref->pref_qual[pref_cntr].site_display
    = cv.display
  FOOT REPORT
   stat = alter(temp_pref->pref_qual,pref_cntr)
  WITH nocounter
 ;end select
 IF ((request->date_type IN ("C", "R")))
  SET case_defined = "T"
  CASE (request->date_type)
   OF "C":
    SET case_where = concat(trim(case_where)," PC.CASE_COLLECT_DT_TM  BETWEEN CNVTDATETIME(",
     " request->date_from) AND CNVTDATETIME("," request->date_to)")
   OF "R":
    SET case_where = concat(trim(case_where)," PC.CASE_RECEIVED_DT_TM  BETWEEN CNVTDATETIME(",
     " request->date_from) AND CNVTDATETIME("," request->date_to)")
  ENDCASE
 ENDIF
 IF ((request->prefix_cnt > 0))
  SET case_where = build(trim(case_where)," AND")
  IF ((request->date_type IN ("C", "R")))
   SET case_where = concat(trim(case_where)," PC.PREFIX_ID+0 IN (")
  ELSE
   SET case_where = concat(trim(case_where)," PC.PREFIX_ID IN (")
  ENDIF
  FOR (x = 1 TO (request->prefix_cnt - 1))
    SET case_where = concat(trim(case_where)," ",cnvtstring(request->prefix_qual[x].prefix_cd,32,6,r),
     ",")
  ENDFOR
  SET case_where = concat(trim(case_where)," ",cnvtstring(request->prefix_qual[x].prefix_cd,32,6,r),
   ")")
 ENDIF
 SET case_where = concat(trim(case_where)," AND PC.RESERVED_IND != 1")
 SET cnt = 0
 SET no_cases_found = "F"
 SET mrn_alias_type_cd = 0.0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=319
   AND cv.cdf_meaning="MRN"
   AND cv.active_ind=1
  HEAD REPORT
   mrn_alias_type_cd = 0.0
  DETAIL
   mrn_alias_type_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.case_id, pc.accession_nbr, t.tag_group_id,
  t.tag_disp, t.tag_sequence
  FROM person p,
   pathology_case pc,
   prsnl pr,
   case_specimen cs,
   ap_tag t
  PLAN (pc
   WHERE parser(trim(case_where)))
   JOIN (pr
   WHERE pc.requesting_physician_id=pr.person_id)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (cs
   WHERE pc.case_id=cs.case_id)
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
  ORDER BY pc.accession_nbr, t.tag_sequence
  HEAD REPORT
   cnt = 0
  HEAD pc.accession_nbr
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alter(temp->qual,(cnt+ 9))
   ENDIF
   spec_cnt = 0, rpt_cnt = 0, stat = alterlist(temp->qual[cnt].spec_qual,5),
   temp->qual[cnt].case_id = pc.case_id, temp->qual[cnt].encntr_id = pc.encntr_id, temp->qual[cnt].
   encntr_type_disp = " ",
   temp->qual[cnt].accession_nbr = pc.accession_nbr, temp->qual[cnt].case_collect_dt_tm =
   cnvtdatetime(pc.case_collect_dt_tm), temp->qual[cnt].case_received_dt_tm = cnvtdatetime(pc
    .case_received_dt_tm),
   temp->qual[cnt].req_physician_name = pr.name_full_formatted, temp->qual[cnt].req_physician_id = pr
   .person_id, temp->qual[cnt].person_id = p.person_id,
   temp->qual[cnt].person_name = p.name_full_formatted, temp->qual[cnt].name_sort_key = build(p
    .name_last_key,", ",p.name_first_key), temp->qual[cnt].case_cancel_cd = pc.cancel_cd
  DETAIL
   spec_cnt = (spec_cnt+ 1)
   IF ((spec_cnt > temp->max_spec_cnt))
    temp->max_spec_cnt = spec_cnt
   ENDIF
   IF (mod(spec_cnt,5)=1
    AND spec_cnt != 1)
    stat = alterlist(temp->qual[cnt].spec_qual,(spec_cnt+ 4))
   ENDIF
   temp->qual[cnt].spec_cnt = spec_cnt, temp->qual[cnt].spec_qual[spec_cnt].specimen_cd = cs
   .specimen_cd, temp->qual[cnt].spec_qual[spec_cnt].specimen_cancel_cd = cs.cancel_cd,
   temp->qual[cnt].spec_qual[spec_cnt].specimen_tag_display = t.tag_disp, temp->qual[cnt].spec_qual[
   spec_cnt].specimen_description = trim(cs.specimen_description), temp->qual[cnt].spec_qual[spec_cnt
   ].specimen_tag_sequence = format(t.tag_sequence,"####")
  FOOT  pc.case_id
   stat = alterlist(temp->qual[cnt].spec_qual,spec_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
  SET no_cases_found = "T"
  GO TO report_maker
 ELSE
  SET reply->status_data.status = "S"
  SET no_cases_found = "F"
 ENDIF
 SET stat = alter(temp->qual,cnt)
 SELECT INTO "nl:"
  ea.encntr_alias_type_cd, e.encntr_type_cd, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd),
  d1.seq, temp->qual[d1.seq].person_name
  FROM encntr_alias ea,
   encounter e,
   (dummyt d2  WITH seq = 1),
   (dummyt d1  WITH seq = value(size(temp->qual,5)))
  PLAN (d1
   WHERE (temp->qual[d1.seq].encntr_id > 0))
   JOIN (e
   WHERE (temp->qual[d1.seq].encntr_id=e.encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (d2)
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d1.seq
  DETAIL
   IF (ea.encntr_alias_type_cd=mrn_alias_type_cd)
    temp->qual[d1.seq].person_num = substring(1,22,frmt_mrn)
   ELSE
    temp->qual[d1.seq].person_num = substring(1,22,captions->unknown)
   ENDIF
   temp->qual[d1.seq].encntr_type_cd = e.encntr_type_cd
  WITH nocounter, outerjoin = d2
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_spec_cnt))
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d.seq].spec_qual,5))
   JOIN (cv
   WHERE (temp->qual[d.seq].spec_qual[d2.seq].specimen_cd=cv.code_value))
  DETAIL
   temp->qual[d.seq].spec_qual[d2.seq].specimen_disp = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d
   WHERE (temp->qual[d.seq].encntr_type_cd > 0))
   JOIN (cv
   WHERE (temp->qual[d.seq].encntr_type_cd=cv.code_value))
  DETAIL
   temp->qual[d.seq].encntr_type_disp = substring(1,1,cv.display)
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_case_log", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT
  IF ((request->order_by="A"))
   ORDER BY sort_by_accn
  ELSE
   ORDER BY sort_by_name
  ENDIF
  INTO value(reply->print_status_data.print_filename)
  d.seq, d2.seq, acc_nbr = temp->qual[d.seq].accession_nbr,
  person_name = temp->qual[d.seq].person_name, spec_tag_disp = temp->qual[d.seq].spec_qual[d2.seq].
  specimen_tag_display, spec_descr = temp->qual[d.seq].spec_qual[d2.seq].specimen_description,
  spec_disp = temp->qual[d.seq].spec_qual[d2.seq].specimen_disp, spec_tag_seq = temp->qual[d.seq].
  spec_qual[d2.seq].specimen_tag_sequence, sort_by_accn = build(temp->qual[d.seq].accession_nbr,temp
   ->qual[d.seq].spec_qual[d2.seq].specimen_tag_sequence),
  sort_by_name = build(temp->qual[d.seq].name_sort_key,temp->qual[d.seq].accession_nbr,temp->qual[d
   .seq].spec_qual[d2.seq].specimen_tag_sequence)
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_spec_cnt))
  PLAN (d)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d.seq].spec_qual,5))
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), bbreak = 0
  HEAD PAGE
   cdate = format(curdate,"@SHORTDATE;;q"), dateup = cnvtupper(captions->ddate), row + 1,
   col 0, captions->rreport, col 56,
   CALL center(captions->ap,row,132), col 110, dateup,
   col 117, cdate, row + 1,
   col 0, captions->dir, col 110,
   captions->ttime, col 117, curtime,
   row + 1, col 52,
   CALL center(captions->caselog,row,132),
   col 112, captions->bby, col 117,
   request->scuruser"##############", row + 1, col 110,
   captions->ppage, col 117, curpage"###",
   row + 1, col 0, captions->prefix,
   "  : ", col 15, last_pref = value(size(temp_pref->pref_qual,5))
   FOR (x = 1 TO last_pref)
     IF ((temp_pref->pref_qual[x].site_cd > 0))
      temp_pref->pref_qual[x].site_display
     ENDIF
     temp_pref->pref_qual[x].prefix_name
     IF (x < last_pref)
      ", "
     ENDIF
     col + 1
     IF (col > 120)
      row + 1, col 15
     ENDIF
   ENDFOR
   row + 1, col 0, captions->ddate,
   "         ", datefrom = format(request->date_from,"@SHORTDATE;;q"), col 15,
   datefrom, col 26, "-",
   dateto = format(request->date_to,"@SHORTDATE;;q"), col 28, dateto,
   col 39
   IF ((request->date_type="C"))
    captions->collected
   ELSEIF ((request->date_type="R"))
    captions->received
   ELSEIF ((request->date_type="V"))
    captions->verified
   ENDIF
   row + 2, col 0, captions->accession,
   col 20, captions->name, col 44,
   captions->id, col 68, captions->type,
   col 74, captions->collected2, col 86,
   captions->received2, col 98, captions->requestedby,
   row + 1, col 0, line1,
   row + 1
   IF (no_cases_found="T")
    row + 5,
    CALL center(captions->nomatches,0,132)
   ENDIF
  HEAD d.seq
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, scuraccession = uar_fmt_accession(temp->qual[d.seq].accession_nbr,size(trim(temp->qual[d
      .seq].accession_nbr),1)), col 0,
   scuraccession, col 20, temp->qual[d.seq].person_name"######################",
   col 44, temp->qual[d.seq].person_num"######################", col 69,
   temp->qual[d.seq].encntr_type_disp, tempdate = format(temp->qual[d.seq].case_collect_dt_tm,
    "@SHORTDATE;;q"), col 74,
   tempdate, tempdate = format(temp->qual[d.seq].case_received_dt_tm,"@SHORTDATE;;q"), col 86,
   tempdate, col 98, temp->qual[d.seq].req_physician_name"#########################"
   IF ((temp->qual[d.seq].case_cancel_cd > 0))
    col 69, "*** ", captions->cancelled,
    " ***                                 "
   ENDIF
  DETAIL
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   IF ((((temp->qual[d.seq].case_cancel_cd > 0)) OR ((temp->qual[d.seq].spec_qual[d2.seq].
   specimen_cancel_cd > 0))) )
    row + 0
   ELSE
    row + 1, col 20, temp->qual[d.seq].spec_qual[d2.seq].specimen_tag_display"#####",
    col 26, temp->qual[d.seq].spec_qual[d2.seq].specimen_disp"##########", col 44,
    temp->qual[d.seq].spec_qual[d2.seq].specimen_description
    "#################################################"
   ENDIF
  FOOT  d.seq
   row + 1
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptcaselog,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@MEDIUMDATE;;q")), col 53,
   today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->contd
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
 IF (curqual > 0)
  IF (textlen(trim(request->output_dist)) > 0)
   SET spool value(reply->print_status_data.print_dir_and_filename) value(printer) WITH copy = value(
    copies)
   SET reply->ops_event = concat("Successful ",trim(reply->print_status_data.print_dir_and_filename))
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
