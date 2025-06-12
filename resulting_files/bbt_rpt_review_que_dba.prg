CREATE PROGRAM bbt_rpt_review_que:dba
 RECORD temp_review(
   1 list_cnt = i4
   1 list[*]
     2 from_person_id = f8
     2 to_person_id = f8
     2 from_person_index = i4
     2 to_person_index = i4
     2 display_entry = c1
     2 uncombine_ind = c1
     2 rev_cmb_ind = c1
     2 active_status_date = vc
     2 active_status_time = vc
     2 person_combine_id = f8
     2 from_pr_count = i4
     2 to_pr_count = i4
     2 review_queue_entity_list[*]
       3 review_que_id = f8
       3 from_entity_id = f8
       3 to_entity_id = f8
       3 bb_review_prsnl_id = f8
       3 bb_active_status_dt_tm = di8
     2 from_rec
       3 from_antigen[*]
         4 antigen = c10
       3 from_antibody[*]
         4 antibody = vc
       3 from_aborh[*]
         4 aborh = c10
       3 from_abr[*]
         4 aborh_results = c10
       3 from_prp[*]
         4 short_string = vc
         4 pa_cnt = i4
         4 pa[*]
           5 antigen_disp = c10
       3 from_prpr[*]
         4 short_string = vc
       3 from_comment = vc
       3 from_spec_indicator = i2
       3 from_trans_req[*]
         4 trans_req = vc
     2 to_rec
       3 to_antigen[*]
         4 antigen = c10
       3 to_antibody[*]
         4 antibody = vc
       3 to_aborh[*]
         4 aborh = c10
       3 to_abr[*]
         4 aborh_results = c10
       3 to_prp[*]
         4 short_string = vc
         4 pa_cnt = i4
         4 pa[*]
           5 antigen_disp = c10
       3 to_prpr[*]
         4 short_string = vc
       3 to_comment = vc
       3 to_spec_indicator = i2
       3 to_trans_req[*]
         4 trans_req = vc
 )
 RECORD processed_reviews(
   1 review_item_list[*]
     2 review_queue_id = f8
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
   1 bb_review_queue = vc
   1 time = vc
   1 as_of_date = vc
   1 rpt = vc
   1 beg_date = vc
   1 end_date = vc
   1 from_patient = vc
   1 to_patient = vc
   1 name = vc
   1 not_on_file = vc
   1 gender = vc
   1 date_of_birth = vc
   1 ssn = vc
   1 mrn = vc
   1 registration = vc
   1 reg = vc
   1 pre = vc
   1 dis = vc
   1 location = vc
   1 antibodies = vc
   1 antigens = vc
   1 aborh = vc
   1 aborh_results = vc
   1 rhp = vc
   1 rhp_antigens = vc
   1 rhp_results = vc
   1 combined = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 indicates_comments = vc
   1 end_of_report = vc
   1 encounter_combine = vc
   1 reviewed = vc
   1 comments = vc
   1 blank = vc
   1 specimen_exp_comments1 = vc
   1 specimen_exp_comments2 = vc
   1 specimen_exp_comment1 = vc
   1 specimen_exp_comment2 = vc
   1 none = vc
   1 facility = vc
   1 bb_comments = vc
   1 trans_req = vc
 )
 DECLARE revlistindex = i4 WITH protect, noconstant(0)
 DECLARE entitylistindex = i4 WITH protect, noconstant(0)
 DECLARE from_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE to_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE uncombine_flag = c1
 DECLARE revcmb_flag = c1
 DECLARE indx1 = i4 WITH protect, noconstant(0)
 DECLARE indx2 = i4 WITH protect, noconstant(0)
 DECLARE temp_entity_id = f8 WITH protect, noconstant(0)
 DECLARE from_or_to = c1 WITH protect, noconstant("Y")
 DECLARE person_index_from = i4 WITH protect, noconstant(0)
 DECLARE person_index_to = i4 WITH protect, noconstant(0)
 DECLARE curr_from_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE curr_to_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE rpt_cnt = i4 WITH protect, noconstant(0)
 DECLARE curr_uncmb_ind = c1 WITH protect, noconstant(" ")
 DECLARE temp_bb_review_queue_id = f8 WITH protect, noconstant(0)
 DECLARE combine_count = i4 WITH protect, noconstant(100)
 DECLARE continue = i2 WITH protect, noconstant(1)
 DECLARE curr_person_combine_id = f8 WITH protect, noconstant(0.0)
 DECLARE lastprocessedreviewqueueid = f8 WITH protect, noconstant(0.0)
 DECLARE reviewitemsqualified = i4 WITH protect, noconstant(0)
 SET captions->bb_review_queue = uar_i18ngetmessage(i18nhandle,"bb_review_queue",
  "B L O O D   B A N K   R E V I E W   Q U E U E")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"rpt","R E P O R T")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->from_patient = uar_i18ngetmessage(i18nhandle,"from_patient",
  "                  From Patient")
 SET captions->to_patient = uar_i18ngetmessage(i18nhandle,"to_patient","                  To Patient"
  )
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Name:")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on file>")
 SET captions->gender = uar_i18ngetmessage(i18nhandle,"gender","Gender:")
 SET captions->date_of_birth = uar_i18ngetmessage(i18nhandle,"date_of_birth","Date of Birth:")
 SET captions->ssn = uar_i18ngetmessage(i18nhandle,"ssn","SSN(s):")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN(s):")
 SET captions->registration = uar_i18ngetmessage(i18nhandle,"registration","Registration:")
 SET captions->reg = uar_i18ngetmessage(i18nhandle,"reg","REG:")
 SET captions->pre = uar_i18ngetmessage(i18nhandle,"pre","PRE:")
 SET captions->dis = uar_i18ngetmessage(i18nhandle,"dis","DIS:")
 SET captions->location = uar_i18ngetmessage(i18nhandle,"location","Location:")
 SET captions->antibodies = uar_i18ngetmessage(i18nhandle,"antibodies","Antibodies:")
 SET captions->antigens = uar_i18ngetmessage(i18nhandle,"antigens","Antigens:")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh:")
 SET captions->aborh_results = uar_i18ngetmessage(i18nhandle,"aborh_results","ABO/Rh Results")
 SET captions->rhp = uar_i18ngetmessage(i18nhandle,"rhp","RhPheno(RhP):")
 SET captions->rhp_antigens = uar_i18ngetmessage(i18nhandle,"rhp_antigens","RhP Antigens:")
 SET captions->rhp_results = uar_i18ngetmessage(i18nhandle,"rhp_results","RhP Results:")
 SET captions->combined = uar_i18ngetmessage(i18nhandle,"combined","Combined:")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_REVIEW_QUE")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->indicates_comments = uar_i18ngetmessage(i18nhandle,"indicates_comments",
  "** Indicates Comments")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->encounter_combine = uar_i18ngetmessage(i18nhandle,"encounter_combine",
  "E N C O U N T E R  C O M B I N E  R E P O R T")
 SET captions->reviewed = uar_i18ngetmessage(i18nhandle,"reviewed","Reviewed")
 SET captions->comments = uar_i18ngetmessage(i18nhandle,"comments","**Comments** ")
 SET captions->blank = uar_i18ngetmessage(i18nhandle,"blank","<blank>")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"None","(None)")
 SET captions->facility = uar_i18ngetmessage(i18nhandle,"facility","Facility:")
 SET captions->bb_comments = uar_i18ngetmessage(i18nhandle,"bb_comments","Blood Bank Comments:")
 SET captions->specimen_exp_comments1 = uar_i18ngetmessage(i18nhandle,"specExpComs",
  "Specimen Exp Comments:")
 SET captions->specimen_exp_comment1 = uar_i18ngetmessage(i18nhandle,"specExpCom1",build(
   'Specimen expiration dates and/or crossmatch expiration dates for the "To" person have changed.'))
 SET captions->specimen_exp_comment2 = uar_i18ngetmessage(i18nhandle,"specExpCom2",build(
   "See Override New Specimen Expiration exception report."))
 SET captions->trans_req = uar_i18ngetmessage(i18nhandle,"trans_req","Transfusion Req:")
 RECORD temp(
   1 from_pre_dt_tm = dq8
   1 from_reg_dt_tm = dq8
   1 from_disch_dt_tm = dq8
   1 to_pre_dt_tm = dq8
   1 to_reg_dt_tm = dq8
   1 to_disch_dt_tm = dq8
 )
 IF (trim(request->batch_selection) > " ")
  SET temp_string = cnvtupper(trim(request->batch_selection))
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET hoursentered = 0
  CALL check_hrs_opt("bbt_rpt_review_que")
  IF (hoursentered > 0)
   SET interval = build(abs(hoursentered),"h")
   SET request->beg_dt_tm = cnvtlookbehind(interval,cnvtdatetime(request->ops_date))
   SET request->end_dt_tm = cnvtdatetime(request->ops_date)
  ELSE
   CALL check_opt_date_passed("bbt_rpt_review_que")
   IF ((reply->status_data.status != "F"))
    SET request->beg_dt_tm = begday
    SET request->end_dt_tm = endday
   ENDIF
  ENDIF
  CALL check_location_cd("bbt_rpt_review_que")
  CALL check_facility_cd("bbt_rpt_review_que")
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
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(bbt_get_pref_def,999)=999)
  DECLARE bbt_get_pref_def = i2 WITH protect, constant(1)
  RECORD prefvalues(
    1 prefs[*]
      2 value = vc
  )
  RECORD flexspectransparams(
    1 params[*]
      2 index = i4
      2 transfusionstartrange = i4
      2 transfusionendrange = i4
      2 specimenexpiration = i4
  )
  RECORD encounterlocations(
    1 locs[*]
      2 encfacilitycd = f8
  )
  DECLARE pref_level_bb = i2 WITH public, constant(1)
  DECLARE pref_level_flex = i2 WITH public, constant(2)
  DECLARE flex_spec_group = vc WITH protect, constant("flexible specimen")
  DECLARE pref_flex_spec_yes = vc WITH protect, constant("YES")
  DECLARE pref_flex_spec_no = vc WITH protect, constant("NO")
  DECLARE prefentryexists = i2 WITH protect, noconstant(0)
  DECLARE statbbpref = i2 WITH protect, noconstant(0)
 ENDIF
 SUBROUTINE (bbtgetencounterlocations(facility_code=f8(value),level_flag=i2(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE loccnt = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE flexprefentry = vc WITH protect, constant("patient encounter locations")
   SET statbbpref = initrec(encounterlocations)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    flexprefentry)
   IF ((statbbpref=- (1)))
    IF (prefentryexists=1)
     RETURN(1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prefcount = size(prefvalues->prefs,5)
   IF (prefcount=0)
    RETURN(1)
   ENDIF
   FOR (index = 1 TO prefcount)
     IF (cnvtreal(prefvalues->prefs[index].value) > 0.0)
      SET loccnt += 1
      IF (size(encounterlocations->locs,5) < loccnt)
       SET stat = alterlist(encounterlocations->locs,(loccnt+ 9))
      ENDIF
      SET encounterlocations->locs[loccnt].encfacilitycd = cnvtreal(prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET stat = alterlist(encounterlocations->locs,loccnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (bbtgethistoricinfopreference(facility_code=f8(value)) =i2)
   DECLARE historical_demog_ind = i2 WITH protect, noconstant(0)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("print historical demographics")
   DECLARE code_set = i4 WITH protect, constant(20790)
   DECLARE historycd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set,"HISTORY"))
   IF ((historycd=- (1)))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=historycd
     AND cve.field_name="OPTION"
     AND cve.code_set=code_set
    DETAIL
     IF (trim(cve.field_value,3)="1")
      historical_demog_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (historical_demog_ind=0)
    RETURN(0)
   ENDIF
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="Yes"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcustompacklistpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("custom packing list program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierdispenseassignpreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require dispense courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierreturnproductspreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require return courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetinterfaceddevicespreference(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("uses interfaced devices")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetbbtestingfacility(facility_code=f8(value)) =f8)
   RETURN(bbtgetflexspectestingfacility(facility_code))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectestingfacility(facility_code=f8(value)) =f8)
   DECLARE prefentry = vc WITH protect, constant("transfusion service facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF (size(trim(prefvalues->prefs[1].value)) > 0)
     SET strlogmessage = build("PrefEntry- ",prefentry,":",prefvalues->prefs[1].value,
      ",Facility Code:",
      facility_code)
     CALL log_message(strlogmessage,log_level_debug)
     RETURN(cnvtreal(trim(prefvalues->prefs[1].value,3)))
    ELSE
     RETURN(0.0)
    ENDIF
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecenableflexexpiration(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("enable flex expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
    CALL log_message(strlogmessage,log_level_error)
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF ((prefvalues->prefs[1].value="1"))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecdefclinsigantibodyparams(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("def clin sig antibody params")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmalloexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm allogeneic expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmautoexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm autologous expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecmaxspecexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("max specimen expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecclinsigantibodiesexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("clin sig antibodies exp units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecextendtransfoverride(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend transf override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspeccalcposttransfspecsfromdawndt(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("calc post transf specs from drawn dt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexpunittypemean(facility_code=f8(value)) =c12)
   DECLARE prefentry = vc WITH protect, constant("flex spec expiration unit type")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(trim(prefvalues->prefs[1].value,3))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmtagsprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("xm tags printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexceptionrptprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("exception rpt printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectransfusionparameters(facility_code=f8(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE strposhold = i2 WITH protect, noconstant(0)
   DECLARE strprevposhold = i2 WITH protect, noconstant(0)
   DECLARE strsize = i2 WITH protect, noconstant(0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE maxparamitems = i2 WITH protect, constant(4)
   DECLARE prefentry = vc WITH protect, constant("transfusion parameters")
   SET statbbpref = initrec(flexspectransparams)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   SET prefcount = size(prefvalues->prefs,5)
   IF (((statbbpref != 1) OR (prefcount < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET statbbpref = alterlist(flexspectransparams->params,prefcount)
   FOR (index = 1 TO prefcount)
     SET strsize = 0
     SET strsize = size(prefvalues->prefs[index].value)
     SET strposhold = findstring(",",prefvalues->prefs[index].value)
     SET flexspectransparams->params[index].index = cnvtint(substring(1,(strposhold - 1),prefvalues->
       prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionstartrange = cnvtint(substring((strprevposhold
       + 1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionendrange = cnvtint(substring((strprevposhold+
       1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET flexspectransparams->params[index].specimenexpiration = cnvtint(substring((strposhold+ 1),(
       strsize - strposhold),prefvalues->prefs[index].value))
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getbbpreference(sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssubgroup=vc,sprefentry=vc
  ) =i2)
   DECLARE success_ind = i2 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE subgroupcount = i4 WITH protect, noconstant(0)
   DECLARE namelen = i4 WITH protect, noconstant(255)
   DECLARE entryname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE valname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE subgroupexists = i2 WITH protect, noconstant(0)
   EXECUTE prefrtl
   SET statbbpref = initrec(prefvalues)
   SET prefentryexists = 0
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL log_message("Bad hPref, try logging in",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddcontext(hpref,"default","system")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad default context",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(sfacilityctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"facility",nullterm(sfacilityctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad facility context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(spositionctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"position",nullterm(spositionctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad position context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(suserctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"user",nullterm(suserctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad user context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefsetsection(hpref,"module")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad section",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hgroup = uar_prefcreategroup()
   SET statbbpref = uar_prefsetgroupname(hgroup,"blood bank")
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad group name",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddgroup(hpref,hgroup)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error adding group",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(ssubgroup)) > 0)
    SET subgroupexists = 1
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(ssubgroup))
    IF (hsubgroup <= 0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error adding sub group",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefperform(hpref)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error performing preference query",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hsection = uar_prefgetsectionbyname(hpref,"module")
   SET hgroup2 = uar_prefgetgroupbyname(hsection,"blood bank")
   IF (subgroupexists=1)
    SET hsubgroup2 = uar_prefgetsubgroup(hgroup2,0)
    IF (hsubgroup2 <= 0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroygroup(hgroup2)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error obtaining sub group",log_level_error)
     RETURN(- (1))
    ENDIF
    SET hgroup2 = hsubgroup2
   ENDIF
   SET entrycount = 0
   SET statbbpref = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (statbbpref != 1)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error getting group entry count",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (entrycount <= 0)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Preferences not found",log_level_error)
    RETURN(0)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET namelen = 255
     SET entryname = fillstring(255," ")
     SET statbbpref = uar_prefgetentryname(hentry,entryname,namelen)
     IF (statbbpref != 1)
      CALL uar_prefdestroyentry(hentry)
      CALL uar_prefdestroysection(hsection)
      CALL uar_prefdestroygroup(hgroup2)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL log_message("Error getting entry name",log_level_error)
      RETURN(- (1))
     ENDIF
     IF (nullterm(entryname)=nullterm(sprefentry))
      SET prefentryexists = 1
      SET attrcount = 0
      SET statbbpref = uar_prefgetentryattrcount(hentry,attrcount)
      IF (((statbbpref != 1) OR (attrcount=0)) )
       CALL uar_prefdestroyentry(hentry)
       CALL uar_prefdestroysection(hsection)
       CALL uar_prefdestroygroup(hgroup2)
       CALL uar_prefdestroygroup(hgroup)
       CALL uar_prefdestroyinstance(hpref)
       CALL log_message("Bad entryAttrCount",log_level_error)
       RETURN(- (1))
      ENDIF
      FOR (idxattr = 0 TO (attrcount - 1))
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        DECLARE attrname = c255
        SET namelen = 255
        SET statbbpref = uar_prefgetattrname(hattr,attrname,namelen)
        IF (nullterm(attrname)="prefvalue")
         SET valcount = 0
         SET statbbpref = uar_prefgetattrvalcount(hattr,valcount)
         SET idxval = 0
         SET statbbpref = alterlist(prefvalues->prefs,valcount)
         FOR (idxval = 0 TO (valcount - 1))
           SET valname = fillstring(255," ")
           SET namelen = 255
           SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
           SET prefvalues->prefs[(idxval+ 1)].value = nullterm(valname)
         ENDFOR
         IF (hattr > 0)
          CALL uar_prefdestroyattr(hattr)
         ENDIF
         IF (hentry > 0)
          CALL uar_prefdestroyentry(hentry)
         ENDIF
         IF (hsection > 0)
          CALL uar_prefdestroysection(hsection)
         ENDIF
         IF (hgroup2 > 0)
          CALL uar_prefdestroygroup(hgroup2)
         ENDIF
         IF (hgroup > 0)
          CALL uar_prefdestroygroup(hgroup)
         ENDIF
         IF (hpref > 0)
          CALL uar_prefdestroyinstance(hpref)
         ENDIF
         RETURN(1)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (hattr > 0)
    CALL uar_prefdestroyattr(hattr)
   ENDIF
   IF (hentry > 0)
    CALL uar_prefdestroyentry(hentry)
   ENDIF
   IF (hsection > 0)
    CALL uar_prefdestroysection(hsection)
   ENDIF
   IF (hgroup2 > 0)
    CALL uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hgroup > 0)
    CALL uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hpref > 0)
    CALL uar_prefdestroyinstance(hpref)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetxmtagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("crossmatch tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcomponenttagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("component tag program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetemergencytagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("emergency tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexfilterbyfacility(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("filter specimens by facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtdispgetproductorderassocpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("associate to prod orders on dispense")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecahgxmatch(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("ahg crossmatch")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetaborhdiscrepancy(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("abo discrepancy")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecneonatedaysdefined(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("neonate day spec override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenexpirationovrd(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend expired specimen expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponcurrentaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on current aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponsecondaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on two aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenneonatedischarge(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend neonate specimen discharge")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtcorrectcommentpromptpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("result comment prompt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE bbtprintdispenseencounteridentifier(facility_code)
   DECLARE prefentry = vc WITH protect, constant("print dispense encounter identifier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetsamplevalidityorderspreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("sample validity qualifying orders")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE strpref = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   FOR (index = 1 TO size(prefvalues->prefs,5))
     IF (strpref="")
      SET strpref = concat(strpref,prefvalues->prefs[index].value)
     ELSE
      SET strpref = concat(strpref,",",prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",strpref,",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(strpref)
 END ;Subroutine
 SUBROUTINE bbtgetbbidtagpreference(facility_code)
   DECLARE prefentry = vc WITH protect, constant("disp bbid 2d tags")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetprodtagverifypreference(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("product tag verification")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
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
 SET count1 = 0
 SET b_strg = 0
 SET schar = " "
 SET cont_flag = " "
 SET word_len = 0
 SET inc_flag = " "
 SET mrn_code = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"MRN",code_cnt,mrn_code)
 SET ssn_code = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"SSN",code_cnt,ssn_code)
 DECLARE override_reason_combine_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1621,
   "SYS_COMBINE"))
 IF (override_reason_combine_cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "OVERRIDE_REASON_COMBINE_CD"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "0"
  GO TO exit_script
 ENDIF
 DECLARE add_row = i4 WITH protect, noconstant(0)
 DECLARE combineoverridefound = i2 WITH protect, noconstant(0)
 DECLARE facility_disp = vc WITH protect, noconstant("")
 DECLARE facidx = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE is_filter_fac = i2 WITH protect, noconstant(0)
 DECLARE check_add_row = i4 WITH protect, noconstant(0)
 DECLARE review_item_processed = i4 WITH protect, noconstant(0)
 DECLARE reviewed_item_count = i4 WITH protect, noconstant(0)
 DECLARE batchnumber = i4 WITH protect, noconstant(0)
 DECLARE batchlowerlimit = i4 WITH protect, noconstant(0)
 DECLARE batchupperlimit = i4 WITH protect, noconstant(0)
 DECLARE overallcombinecount = i4 WITH protect, noconstant(0)
 RECORD aborh(
   1 aborh_list[*]
     2 aborh_display = c15
     2 abo_code = f8
     2 rh_code = f8
 )
 SET stat = alterlist(aborh->aborh_list,10)
 SET aborh_index = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_extension cve1,
   code_value_extension cve2,
   (dummyt d1  WITH seq = 1),
   code_value cv2,
   (dummyt d2  WITH seq = 1),
   code_value cv3
  PLAN (cv1
   WHERE cv1.code_set=1640
    AND cv1.active_ind=1)
   JOIN (cve1
   WHERE cve1.code_set=1640
    AND cv1.code_value=cve1.code_value
    AND cve1.field_name="ABOOnly_cd")
   JOIN (cve2
   WHERE cve2.code_set=1640
    AND cv1.code_value=cve2.code_value
    AND cve2.field_name="RhOnly_cd")
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (cv2
   WHERE cv2.code_set=1641
    AND cnvtint(cve1.field_value)=cv2.code_value)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (cv3
   WHERE cv3.code_set=1642
    AND cnvtint(cve2.field_value)=cv3.code_value)
  ORDER BY cve1.field_value, cve2.field_value
  DETAIL
   aborh_index += 1
   IF (mod(aborh_index,10)=1
    AND aborh_index != 1)
    stat = alterlist(aborh->aborh_list,(aborh_index+ 9))
   ENDIF
   aborh->aborh_list[aborh_index].aborh_display = cv1.display, aborh->aborh_list[aborh_index].
   abo_code = cv2.code_value, aborh->aborh_list[aborh_index].rh_code = cv3.code_value
  WITH outerjoin(d1), outerjoin(d2), check,
   nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(aborh->aborh_list,aborh_index)
 ENDIF
 IF ((request->facility_cd > 0))
  SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
  IF ((stat=- (1)))
   SET count1 += 1
   IF (count1 > 0)
    SET stat = alter(reply->status_data.subeventstatus,count1)
   ENDIF
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationname = "BbtGetEncounterLocations"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_review_que"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "-1"
  ENDIF
 ENDIF
 DECLARE dm_loop_increment = vc WITH constant("PTC_LOOP_INCREMENT")
 DECLARE dm_domain = vc WITH constant("PATHNET_BBT")
 SELECT INTO "nl:"
  dm.info_date
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=dm_domain
    AND dm.info_name=dm_loop_increment)
  DETAIL
   combine_count = cnvtint(trim(dm.info_char))
  WITH nocounter
 ;end select
 IF (combine_count < 500)
  SET combine_count = 500
 ENDIF
 RECORD bb_details(
   1 aborh_list[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 aborh_rs_list[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 antigen_list[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 antibody_list[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 rh_ph_list[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 rh_ph_rs_list[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 comments[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 spec_override[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
   1 trans_req_list[*]
     2 entity_id = f8
     2 entity_position = i4
     2 from_or_to = c1
 )
 DECLARE pab_count = i4 WITH protect, noconstant(0)
 DECLARE pag_count = i4 WITH protect, noconstant(0)
 DECLARE paborh_count = i4 WITH protect, noconstant(0)
 DECLARE paborh_rs_count = i4 WITH protect, noconstant(0)
 DECLARE ph_rh_count = i4 WITH protect, noconstant(0)
 DECLARE ph_rh_rs_count = i4 WITH protect, noconstant(0)
 DECLARE pcmnt_count = i4 WITH protect, noconstant(0)
 DECLARE bseo_count = i4 WITH protect, noconstant(0)
 DECLARE ptr_count = i4 WITH protect, noconstant(0)
 SUBROUTINE populatebloodbankdetails(null)
   SET num = 0
   SET listcnt = 0
   SET temp_entity_position = 0
   SET from_count = 0
   SET to_count = 0
   SET pab_count = 0
   SET pag_count = 0
   SET paborh_count = 0
   SET paborh_rs_count = 0
   SET ph_rh_count = 0
   SET ph_rh_rs_count = 0
   SET pcmnt_count = 0
   SET bseo_count = 0
   IF (size(bb_details->antibody_list,5) > 0)
    SELECT INTO "nl:"
     entity_loc = bb_details->antibody_list[d_pb.seq].entity_position, antibody_disp =
     uar_get_code_display(pb.antibody_cd)
     FROM person_antibody pb,
      (dummyt d_pb  WITH seq = value(size(bb_details->antibody_list,5)))
     PLAN (pb
      WHERE expand(num,1,size(bb_details->antibody_list,5),pb.person_antibody_id,bb_details->
       antibody_list[num].entity_id)
       AND  NOT (pb.person_antibody_id IN (null, 0.0)))
      JOIN (d_pb
      WHERE (pb.person_antibody_id=bb_details->antibody_list[d_pb.seq].entity_id))
     ORDER BY entity_loc, bb_details->antibody_list[d_pb.seq].entity_id
     HEAD entity_loc
      from_count = 0, to_count = 0
     DETAIL
      from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->antibody_list[d_pb.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->antibody_list[d_pb.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->antibody_list[d_pb.seq].from_or_to
      ENDIF
      IF (from_or_to="F")
       IF ((temp_review->list[entity_loc].from_person_id=pb.person_id))
        IF (locateval(indx1,1,size(temp_review->list[entity_loc].from_rec.from_antibody,5),
         antibody_disp,temp_review->list[entity_loc].from_rec.from_antibody[indx1].antibody) <= 0)
         from_count += 1
         IF (mod(from_count,5)=1)
          stat = alterlist(temp_review->list[entity_loc].from_rec.from_antibody,(from_count+ 4))
         ENDIF
         temp_review->list[entity_loc].from_rec.from_antibody[from_count].antibody = antibody_disp
        ENDIF
       ENDIF
      ENDIF
      IF (from_or_to="T")
       IF ((temp_review->list[entity_loc].to_person_id=pb.person_id))
        IF (locateval(indx1,1,size(temp_review->list[entity_loc].to_rec.to_antibody,5),antibody_disp,
         temp_review->list[entity_loc].to_rec.to_antibody[indx1].antibody) <= 0)
         to_count += 1
         IF (mod(to_count,5)=1)
          stat = alterlist(temp_review->list[entity_loc].to_rec.to_antibody,(to_count+ 4))
         ENDIF
         temp_review->list[entity_loc].to_rec.to_antibody[to_count].antibody = antibody_disp
        ENDIF
       ENDIF
      ENDIF
     FOOT  entity_loc
      stat = alterlist(temp_review->list[entity_loc].from_rec.from_antibody,from_count), stat =
      alterlist(temp_review->list[entity_loc].to_rec.to_antibody,to_count)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->antigen_list,5) > 0)
    SELECT INTO "nl:"
     antigen_disp = uar_get_code_display(pa.antigen_cd), entity_loc = bb_details->antigen_list[d_pa
     .seq].entity_position
     FROM person_antigen pa,
      (dummyt d_pa  WITH seq = value(size(bb_details->antigen_list,5)))
     PLAN (pa
      WHERE expand(num,1,size(bb_details->antigen_list,5),pa.person_antigen_id,bb_details->
       antigen_list[num].entity_id)
       AND  NOT (pa.person_antigen_id IN (null, 0.0)))
      JOIN (d_pa
      WHERE (pa.person_antigen_id=bb_details->antigen_list[d_pa.seq].entity_id))
     ORDER BY entity_loc, bb_details->antigen_list[d_pa.seq].entity_id
     HEAD entity_loc
      from_count = 0, to_count = 0
     DETAIL
      from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->antigen_list[d_pa.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->antigen_list[d_pa.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->antigen_list[d_pa.seq].from_or_to
      ENDIF
      IF (from_or_to="F")
       IF ((temp_review->list[entity_loc].from_person_id=pa.person_id))
        from_count += 1
        IF (mod(from_count,5)=1)
         stat = alterlist(temp_review->list[entity_loc].from_rec.from_antigen,(from_count+ 4))
        ENDIF
        temp_review->list[entity_loc].from_rec.from_antigen[from_count].antigen = antigen_disp
       ENDIF
      ENDIF
      IF (from_or_to="T")
       IF ((temp_review->list[entity_loc].to_person_id=pa.person_id))
        to_count += 1
        IF (mod(to_count,5)=1)
         stat = alterlist(temp_review->list[entity_loc].to_rec.to_antigen,(to_count+ 4))
        ENDIF
        temp_review->list[entity_loc].to_rec.to_antigen[to_count].antigen = antigen_disp
       ENDIF
      ENDIF
     FOOT  entity_loc
      stat = alterlist(temp_review->list[entity_loc].from_rec.from_antigen,from_count), stat =
      alterlist(temp_review->list[entity_loc].to_rec.to_antigen,to_count)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->aborh_list,5) > 0)
    SELECT INTO "nl:"
     entity_loc = bb_details->aborh_list[d_ab.seq].entity_position, aborh_disp = concat(trim(
       uar_get_code_display(ab.abo_cd)),trim(uar_get_code_display(ab.rh_cd)))
     FROM person_aborh ab,
      (dummyt d_ab  WITH seq = value(size(bb_details->aborh_list,5)))
     PLAN (ab
      WHERE expand(num,1,size(bb_details->aborh_list,5),ab.person_aborh_id,bb_details->aborh_list[num
       ].entity_id)
       AND  NOT (ab.person_aborh_id IN (null, 0.0)))
      JOIN (d_ab
      WHERE (ab.person_aborh_id=bb_details->aborh_list[d_ab.seq].entity_id))
     ORDER BY entity_loc, bb_details->aborh_list[d_ab.seq].entity_id
     HEAD entity_loc
      from_count = 0, to_count = 0
     DETAIL
      indx2 = locateval(indx1,1,size(aborh->aborh_list,5),ab.abo_cd,aborh->aborh_list[indx1].abo_code,
       ab.rh_cd,aborh->aborh_list[indx1].rh_code), from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->aborh_list[d_ab.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->aborh_list[d_ab.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->aborh_list[d_ab.seq].from_or_to
      ENDIF
      IF (from_or_to="F")
       IF ((temp_review->list[entity_loc].from_person_id=ab.person_id))
        IF (indx2 > 0)
         from_count += 1
         IF (mod(from_count,5)=1)
          stat = alterlist(temp_review->list[entity_loc].from_rec.from_aborh,(from_count+ 4))
         ENDIF
         temp_review->list[entity_loc].from_rec.from_aborh[from_count].aborh = aborh->aborh_list[
         indx2].aborh_display
        ENDIF
       ENDIF
      ENDIF
      IF (from_or_to="T")
       IF ((temp_review->list[entity_loc].to_person_id=ab.person_id))
        IF (indx2 > 0)
         to_count += 1
         IF (mod(to_count,5)=1)
          stat = alterlist(temp_review->list[entity_loc].to_rec.to_aborh,(to_count+ 4))
         ENDIF
         temp_review->list[entity_loc].to_rec.to_aborh[to_count].aborh = aborh->aborh_list[indx2].
         aborh_display
        ENDIF
       ENDIF
      ENDIF
     FOOT  entity_loc
      stat = alterlist(temp_review->list[entity_loc].from_rec.from_aborh,from_count), stat =
      alterlist(temp_review->list[entity_loc].to_rec.to_aborh,to_count)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->aborh_rs_list,5) > 0)
    SELECT INTO "nl:"
     entity_loc = bb_details->aborh_rs_list[d_abr.seq].entity_position, abr_aborh_result_disp =
     uar_get_code_display(abr.result_cd)
     FROM person_aborh_result abr,
      (dummyt d_abr  WITH seq = value(size(bb_details->aborh_rs_list,5)))
     PLAN (abr
      WHERE expand(num,1,size(bb_details->aborh_rs_list,5),abr.person_aborh_rs_id,bb_details->
       aborh_rs_list[num].entity_id)
       AND  NOT (abr.person_aborh_rs_id IN (null, 0.0)))
      JOIN (d_abr
      WHERE (abr.person_aborh_rs_id=bb_details->aborh_rs_list[d_abr.seq].entity_id))
     ORDER BY entity_loc, bb_details->aborh_rs_list[d_abr.seq].entity_id
     HEAD entity_loc
      from_count = 0, to_count = 0
     DETAIL
      from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->aborh_rs_list[d_abr.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->aborh_rs_list[d_abr.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->aborh_rs_list[d_abr.seq].from_or_to
      ENDIF
      IF (from_or_to="F")
       IF ((temp_review->list[entity_loc].from_person_id=abr.person_id))
        IF (locateval(indx1,1,size(temp_review->list[entity_loc].from_rec.from_abr,5),
         abr_aborh_result_disp,temp_review->list[entity_loc].from_rec.from_abr[indx1].aborh_results)
         <= 0)
         from_count += 1
         IF (mod(from_count,5)=1)
          stat = alterlist(temp_review->list[entity_loc].from_rec.from_abr,(from_count+ 4))
         ENDIF
         temp_review->list[entity_loc].from_rec.from_abr[from_count].aborh_results =
         abr_aborh_result_disp
        ENDIF
       ENDIF
      ENDIF
      IF (from_or_to="T")
       IF ((temp_review->list[entity_loc].to_person_id=abr.person_id))
        IF (locateval(indx1,1,size(temp_review->list[entity_loc].to_rec.to_abr,5),
         abr_aborh_result_disp,temp_review->list[entity_loc].to_rec.to_abr[indx1].aborh_results) <= 0
        )
         to_count += 1
         IF (mod(to_count,5)=1)
          stat = alterlist(temp_review->list[entity_loc].to_rec.to_abr,(to_count+ 4))
         ENDIF
         temp_review->list[entity_loc].to_rec.to_abr[to_count].aborh_results = abr_aborh_result_disp
        ENDIF
       ENDIF
      ENDIF
     FOOT  entity_loc
      stat = alterlist(temp_review->list[entity_loc].from_rec.from_abr,from_count), stat = alterlist(
       temp_review->list[entity_loc].to_rec.to_abr,to_count)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->rh_ph_list,5) > 0)
    SELECT INTO "nl:"
     pa_rh_ph_antigen_disp = uar_get_code_display(pa_rh_ph.antigen_cd), n_rh_ph_short_string =
     n_rh_ph.short_string, entity_loc = bb_details->rh_ph_list[d_rh_ph.seq].entity_position
     FROM person_rh_phenotype rh_ph,
      nomenclature n_rh_ph,
      person_antigen pa_rh_ph,
      (dummyt d_rh_ph  WITH seq = value(size(bb_details->rh_ph_list,5)))
     PLAN (rh_ph
      WHERE expand(num,1,size(bb_details->rh_ph_list,5),rh_ph.person_rh_phenotype_id,bb_details->
       rh_ph_list[num].entity_id)
       AND  NOT (rh_ph.person_rh_phenotype_id IN (null, 0.0)))
      JOIN (n_rh_ph
      WHERE n_rh_ph.nomenclature_id=rh_ph.nomenclature_id)
      JOIN (pa_rh_ph
      WHERE pa_rh_ph.person_rh_phenotype_id=rh_ph.person_rh_phenotype_id)
      JOIN (d_rh_ph
      WHERE (rh_ph.person_rh_phenotype_id=bb_details->rh_ph_list[d_rh_ph.seq].entity_id))
     ORDER BY entity_loc, rh_ph.person_rh_phenotype_id
     HEAD entity_loc
      temp_review->list[entity_loc].from_pr_count = 0, temp_review->list[entity_loc].to_pr_count = 0,
      from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->rh_ph_list[d_rh_ph.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->rh_ph_list[d_rh_ph.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->rh_ph_list[d_rh_ph.seq].from_or_to
      ENDIF
     HEAD rh_ph.person_rh_phenotype_id
      IF (from_or_to="F")
       temp_review->list[entity_loc].from_pr_count += 1, rh_phenotype_count = temp_review->list[
       entity_loc].from_pr_count, stat = alterlist(temp_review->list[entity_loc].from_rec.from_prp,
        temp_review->list[entity_loc].from_pr_count),
       temp_review->list[entity_loc].from_rec.from_prp[rh_phenotype_count].short_string =
       n_rh_ph_short_string, temp_review->list[entity_loc].from_rec.from_prp[rh_phenotype_count].
       pa_cnt = 0
      ENDIF
      IF (from_or_to="T")
       temp_review->list[entity_loc].to_pr_count += 1, rh_phenotype_count = temp_review->list[
       entity_loc].to_pr_count, stat = alterlist(temp_review->list[entity_loc].to_rec.to_prp,
        temp_review->list[entity_loc].to_pr_count),
       temp_review->list[entity_loc].to_rec.to_prp[rh_phenotype_count].short_string =
       n_rh_ph_short_string, temp_review->list[entity_loc].to_rec.to_prp[rh_phenotype_count].pa_cnt
        = 0
      ENDIF
     DETAIL
      IF (from_or_to="F")
       temp_review->list[entity_loc].from_rec.from_prp[rh_phenotype_count].pa_cnt += 1, stat =
       alterlist(temp_review->list[entity_loc].from_rec.from_prp[rh_phenotype_count].pa,temp_review->
        list[entity_loc].from_rec.from_prp[rh_phenotype_count].pa_cnt), pa_cnt = temp_review->list[
       entity_loc].from_rec.from_prp[rh_phenotype_count].pa_cnt,
       temp_review->list[entity_loc].from_rec.from_prp[rh_phenotype_count].pa[pa_cnt].antigen_disp =
       pa_rh_ph_antigen_disp
      ENDIF
      IF (from_or_to="T")
       temp_review->list[entity_loc].to_rec.to_prp[rh_phenotype_count].pa_cnt += 1, stat = alterlist(
        temp_review->list[entity_loc].to_rec.to_prp[rh_phenotype_count].pa,temp_review->list[
        entity_loc].to_rec.to_prp[rh_phenotype_count].pa_cnt), pa_cnt = temp_review->list[entity_loc]
       .to_rec.to_prp[rh_phenotype_count].pa_cnt,
       temp_review->list[entity_loc].to_rec.to_prp[rh_phenotype_count].pa[pa_cnt].antigen_disp =
       pa_rh_ph_antigen_disp
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->rh_ph_rs_list,5) > 0)
    SELECT INTO "nl:"
     n_rh_ph_rs_short_string = n_rh_ph_rs.short_string, entity_loc = bb_details->rh_ph_rs_list[
     d_rh_ph_rs.seq].entity_position
     FROM person_rh_pheno_result rh_ph_rs,
      nomenclature n_rh_ph_rs,
      (dummyt d_rh_ph_rs  WITH seq = value(size(bb_details->rh_ph_rs_list,5)))
     PLAN (rh_ph_rs
      WHERE expand(num,1,size(bb_details->rh_ph_rs_list,5),rh_ph_rs.person_rh_pheno_rs_id,bb_details
       ->rh_ph_rs_list[num].entity_id)
       AND  NOT (rh_ph_rs.person_rh_pheno_rs_id IN (null, 0.0)))
      JOIN (n_rh_ph_rs
      WHERE n_rh_ph_rs.nomenclature_id=rh_ph_rs.nomenclature_id)
      JOIN (d_rh_ph_rs
      WHERE (bb_details->rh_ph_rs_list[d_rh_ph_rs.seq].entity_id=rh_ph_rs.person_rh_pheno_rs_id))
     ORDER BY entity_loc
     HEAD entity_loc
      from_count = 0, to_count = 0
     DETAIL
      from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->rh_ph_rs_list[d_rh_ph_rs.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->rh_ph_rs_list[d_rh_ph_rs.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->rh_ph_rs_list[d_rh_ph_rs.seq].from_or_to
      ENDIF
      IF (from_or_to="F")
       IF ((temp_review->list[entity_loc].from_person_id=rh_ph_rs.person_id))
        from_count += 1
        IF (mod(from_count,5)=1)
         stat = alterlist(temp_review->list[entity_loc].from_rec.from_prpr,(from_count+ 4))
        ENDIF
        temp_review->list[entity_loc].from_rec.from_prpr[from_count].short_string =
        n_rh_ph_rs_short_string
       ENDIF
      ENDIF
      IF (from_or_to="T")
       IF ((temp_review->list[entity_loc].to_person_id=rh_ph_rs.person_id))
        to_count += 1
        IF (mod(to_count,5)=1)
         stat = alterlist(temp_review->list[entity_loc].to_rec.to_prpr,(to_count+ 4))
        ENDIF
        temp_review->list[entity_loc].to_rec.to_prpr[to_count].short_string = n_rh_ph_rs_short_string
       ENDIF
      ENDIF
     FOOT  entity_loc
      stat = alterlist(temp_review->list[entity_loc].from_rec.from_prpr,from_count), stat = alterlist
      (temp_review->list[entity_loc].to_rec.to_prpr,to_count)
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->comments,5) > 0)
    SELECT INTO "nl:"
     bbc_long_text = clt.long_text
     FROM blood_bank_comment bbc,
      long_text clt,
      (dummyt d_bbc  WITH seq = value(size(bb_details->comments,5)))
     PLAN (bbc
      WHERE expand(num,1,size(bb_details->comments,5),bbc.bb_comment_id,bb_details->comments[num].
       entity_id)
       AND  NOT (bbc.bb_comment_id IN (null, 0.0)))
      JOIN (clt
      WHERE clt.long_text_id=bbc.long_text_id)
      JOIN (d_bbc
      WHERE (bbc.bb_comment_id=bb_details->comments[d_bbc.seq].entity_id))
     DETAIL
      entity_loc = bb_details->comments[d_bbc.seq].entity_position, from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->comments[d_bbc.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->comments[d_bbc.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->comments[d_bbc.seq].from_or_to
      ENDIF
      IF ((temp_review->list[entity_loc].from_person_id=bbc.person_id))
       IF (from_or_to="F")
        temp_review->list[entity_loc].from_comment = substring(1,53,trim(bbc_long_text))
       ENDIF
      ELSEIF ((temp_review->list[entity_loc].to_person_id=bbc.person_id))
       IF (from_or_to="T")
        temp_review->list[entity_loc].to_rec.to_comment = substring(1,53,trim(bbc_long_text))
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->spec_override,5) > 0)
    SELECT INTO "nl:"
     entity_loc = bb_details->spec_override[d_seo.seq].entity_position
     FROM bb_spec_expire_ovrd seo,
      (dummyt d_seo  WITH seq = value(size(bb_details->spec_override,5)))
     PLAN (seo
      WHERE expand(num,1,size(bb_details->spec_override,5),seo.bb_spec_expire_ovrd_id,bb_details->
       spec_override[num].entity_id)
       AND  NOT (seo.bb_spec_expire_ovrd_id IN (null, 0.0))
       AND seo.override_reason_cd=override_reason_combine_cd
       AND seo.active_ind=1)
      JOIN (d_seo
      WHERE (seo.bb_spec_expire_ovrd_id=bb_details->spec_override[d_seo.seq].entity_id))
     DETAIL
      temp_review->list[entity_loc].to_rec.to_spec_indicator = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (size(bb_details->trans_req_list,5) > 0)
    SELECT INTO "nl:"
     trans_req_display = uar_get_code_display(ptr.requirement_cd), entity_loc = bb_details->
     trans_req_list[d_ptr.seq].entity_position
     FROM person_trans_req ptr,
      (dummyt d_ptr  WITH seq = value(size(bb_details->trans_req_list,5)))
     PLAN (ptr
      WHERE expand(num,1,size(bb_details->trans_req_list,5),ptr.person_trans_req_id,bb_details->
       trans_req_list[num].entity_id)
       AND  NOT (ptr.person_trans_req_id IN (null, 0.0)))
      JOIN (d_ptr
      WHERE (ptr.person_trans_req_id=bb_details->trans_req_list[d_ptr.seq].entity_id))
     ORDER BY entity_loc, bb_details->trans_req_list[d_ptr.seq].entity_id
     HEAD entity_loc
      from_count = 0, to_count = 0
     DETAIL
      from_or_to = ""
      IF ((temp_review->list[entity_loc].rev_cmb_ind="Y"))
       IF ((bb_details->trans_req_list[d_ptr.seq].from_or_to="F"))
        from_or_to = "T"
       ENDIF
       IF ((bb_details->trans_req_list[d_ptr.seq].from_or_to="T"))
        from_or_to = "F"
       ENDIF
      ELSE
       from_or_to = bb_details->trans_req_list[d_ptr.seq].from_or_to
      ENDIF
      IF (from_or_to="F")
       IF ((temp_review->list[entity_loc].from_person_id=ptr.person_id))
        from_count += 1
        IF (mod(from_count,5)=1)
         stat = alterlist(temp_review->list[entity_loc].from_rec.from_trans_req,(from_count+ 4))
        ENDIF
        temp_review->list[entity_loc].from_rec.from_trans_req[from_count].trans_req =
        trans_req_display
       ENDIF
      ENDIF
      IF (from_or_to="T")
       IF ((temp_review->list[entity_loc].to_person_id=ptr.person_id))
        to_count += 1
        IF (mod(to_count,5)=1)
         stat = alterlist(temp_review->list[entity_loc].to_rec.to_trans_req,(to_count+ 4))
        ENDIF
        temp_review->list[entity_loc].to_rec.to_trans_req[to_count].trans_req = trans_req_display
       ENDIF
      ENDIF
     FOOT  entity_loc
      stat = alterlist(temp_review->list[entity_loc].from_rec.from_trans_req,from_count), stat =
      alterlist(temp_review->list[entity_loc].to_rec.to_trans_req,to_count)
     WITH nocounter
    ;end select
   ENDIF
   SET stat = initrec(bb_details)
   SET pab_count = 0
   SET pag_count = 0
   SET paborh_count = 0
   SET paborh_rs_count = 0
   SET ph_rh_count = 0
   SET ph_rh_rs_count = 0
   SET pcmnt_count = 0
   SET bseo_count = 0
 END ;Subroutine
 SUBROUTINE (addtobbdetailslist(entity_name=vc,entity_id=f8,rindex=i4,from_or_to=c1) =null)
   IF (trim(entity_name)="PERSON_ANTIBODY")
    IF (entity_id > 0)
     SET pab_count += 1
     IF (mod(pab_count,10)=1)
      SET stat = alterlist(bb_details->antibody_list,(pab_count+ 9))
     ENDIF
     SET bb_details->antibody_list[pab_count].entity_id = entity_id
     SET bb_details->antibody_list[pab_count].entity_position = rindex
     SET bb_details->antibody_list[pab_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="PERSON_ANTIGEN")
    IF (entity_id > 0)
     SET pag_count += 1
     IF (mod(pag_count,10)=1)
      SET stat = alterlist(bb_details->antigen_list,(pag_count+ 9))
     ENDIF
     SET bb_details->antigen_list[pag_count].entity_id = entity_id
     SET bb_details->antigen_list[pag_count].entity_position = rindex
     SET bb_details->antigen_list[pag_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="PERSON_ABORH")
    IF (entity_id > 0)
     SET paborh_count += 1
     IF (mod(paborh_count,10)=1)
      SET stat = alterlist(bb_details->aborh_list,(paborh_count+ 9))
     ENDIF
     SET bb_details->aborh_list[paborh_count].entity_id = entity_id
     SET bb_details->aborh_list[paborh_count].entity_position = rindex
     SET bb_details->aborh_list[paborh_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="PERSON_ABORH_RESULT")
    IF (entity_id > 0)
     SET paborh_rs_count += 1
     IF (mod(paborh_rs_count,10)=1)
      SET stat = alterlist(bb_details->aborh_rs_list,(paborh_rs_count+ 9))
     ENDIF
     SET bb_details->aborh_rs_list[paborh_rs_count].entity_id = entity_id
     SET bb_details->aborh_rs_list[paborh_rs_count].entity_position = rindex
     SET bb_details->aborh_rs_list[paborh_rs_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="PERSON_RH_PHENOTYPE")
    IF (entity_id > 0)
     SET ph_rh_count += 1
     IF (mod(ph_rh_count,10)=1)
      SET stat = alterlist(bb_details->rh_ph_list,(ph_rh_count+ 9))
     ENDIF
     SET bb_details->rh_ph_list[ph_rh_count].entity_id = entity_id
     SET bb_details->rh_ph_list[ph_rh_count].entity_position = rindex
     SET bb_details->rh_ph_list[ph_rh_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="PERSON_RH_PHENO_RESULT")
    IF (entity_id > 0)
     SET ph_rh_rs_count += 1
     IF (mod(ph_rh_rs_count,10)=1)
      SET stat = alterlist(bb_details->rh_ph_rs_list,(ph_rh_rs_count+ 9))
     ENDIF
     SET bb_details->rh_ph_rs_list[ph_rh_rs_count].entity_id = entity_id
     SET bb_details->rh_ph_rs_list[ph_rh_rs_count].entity_position = rindex
     SET bb_details->rh_ph_rs_list[ph_rh_rs_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="PERSON_COMMENT")
    IF (entity_id > 0)
     SET pcmnt_count += 1
     IF (mod(pcmnt_count,10)=1)
      SET stat = alterlist(bb_details->comments,(pcmnt_count+ 9))
     ENDIF
     SET bb_details->comments[pcmnt_count].entity_id = entity_id
     SET bb_details->comments[pcmnt_count].entity_position = rindex
     SET bb_details->comments[pcmnt_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="BB_SPEC_EXPIRE_OVRD")
    IF (entity_id > 0)
     SET bseo_count += 1
     IF (mod(bseo_count,10)=1)
      SET stat = alterlist(bb_details->spec_override,(bseo_count+ 9))
     ENDIF
     SET bb_details->spec_override[bseo_count].entity_id = entity_id
     SET bb_details->spec_override[bseo_count].entity_position = rindex
     SET bb_details->spec_override[bseo_count].from_or_to = from_or_to
    ENDIF
   ELSEIF (trim(entity_name)="PERSON_TRANS_REQ")
    IF (entity_id > 0)
     SET ptr_count += 1
     IF (mod(ptr_count,10)=1)
      SET stat = alterlist(bb_details->trans_req_list,(ptr_count+ 9))
     ENDIF
     SET bb_details->trans_req_list[ptr_count].entity_id = entity_id
     SET bb_details->trans_req_list[ptr_count].entity_position = rindex
     SET bb_details->trans_req_list[ptr_count].from_or_to = from_or_to
    ENDIF
   ENDIF
 END ;Subroutine
 RECORD person_details(
   1 person_list[*]
     2 person_id = f8
     2 name = c30
     2 birth_dt_tm = di8
     2 birth_tz = i4
     2 sex_disp = c13
     2 mrn_list[*]
       3 mrn = c25
       3 raw_mrn = c25
     2 ssn_list[*]
       3 ssn = c25
       3 raw_ssn = c25
     2 encntr[*]
       3 enc_id = f8
       3 enc_status = c15
       3 enc_type = c20
       3 enc_pre_dt_tm = di8
       3 enc_reg_dt_tm = di8
       3 enc_disch_dt_tm = di8
       3 enc_patient_loc = c40
 )
 DECLARE mrn_code = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4,"MRN",1,mrn_code)
 DECLARE ssn_code = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(4,"SSN",1,ssn_code)
 DECLARE populatepersonlist(null) = null WITH protect
 DECLARE get_from_person(null) = null WITH protect
 DECLARE get_to_person(null) = null WITH protect
 SUBROUTINE populatepersonlist(null)
   DECLARE num = i4 WITH noconstant(0)
   DECLARE perlistcnt = i4 WITH noconstant(0)
   DECLARE perlistidx = i4 WITH noconstant(0)
   CALL get_from_person(null)
   CALL get_to_person(null)
 END ;Subroutine
 SUBROUTINE get_from_person(null)
   SELECT INTO "nl:"
    *
    FROM person per,
     (dummyt d_per  WITH seq = value(size(temp_review->list,5))),
     person_combine pc,
     (dummyt d_cdv  WITH seq = 1),
     combine_det_value cdv
    PLAN (d_per
     WHERE (temp_review->list[d_per.seq].display_entry="Y"))
     JOIN (per
     WHERE (per.person_id=
     IF ((temp_review->list[d_per.seq].rev_cmb_ind="Y")) temp_review->list[d_per.seq].to_person_id
     ELSE temp_review->list[d_per.seq].from_person_id
     ENDIF
     ))
     JOIN (pc
     WHERE per.person_id=pc.from_person_id)
     JOIN (d_cdv
     WHERE d_cdv.seq=1)
     JOIN (cdv
     WHERE cdv.combine_id=pc.person_combine_id
      AND cdv.entity_name="PERSON"
      AND cdv.column_name IN ("NAME_FULL_FORMATTED", "BIRTH_DT_TM", "BIRTH_TZ", "SEX_CD"))
    ORDER BY per.person_id
    HEAD per.person_id
     perlistcnt += 1
     IF (perlistcnt > size(person_details->person_list,5))
      stat = alterlist(person_details->person_list,(perlistcnt+ 10))
     ENDIF
     person_details->person_list[perlistcnt].person_id = per.person_id, temp_review->list[d_per.seq].
     from_person_index = perlistcnt, person_details->person_list[perlistcnt].name = per
     .name_full_formatted,
     person_details->person_list[perlistcnt].birth_dt_tm = cnvtdatetime(per.birth_dt_tm),
     person_details->person_list[perlistcnt].birth_tz = cnvtint(per.birth_tz), person_details->
     person_list[perlistcnt].sex_disp = uar_get_code_display(cnvtreal(per.sex_cd))
    DETAIL
     IF (cdv.combine_id > 0
      AND (temp_review->list[d_per.seq].uncombine_ind="N"))
      CASE (cdv.column_name)
       OF "NAME_FULL_FORMATTED":
        person_details->person_list[perlistcnt].name = cdv.to_value
       OF "BIRTH_DT_TM":
        person_details->person_list[perlistcnt].birth_dt_tm = cnvtdatetime(cdv.to_value)
       OF "BIRTH_TZ":
        person_details->person_list[perlistcnt].birth_tz = cnvtint(cdv.to_value)
       OF "SEX_CD":
        person_details->person_list[perlistcnt].sex_disp = uar_get_code_display(cnvtreal(cdv.to_value
          ))
      ENDCASE
     ENDIF
    FOOT REPORT
     stat = alterlist(person_details->person_list,perlistcnt)
    WITH nocounter, outerjoin(d_cdv)
   ;end select
   SELECT INTO "nl:"
    *
    FROM person per,
     (dummyt d_per  WITH seq = value(size(temp_review->list,5))),
     person_combine pc,
     person_combine_det pcd,
     person_alias pa
    PLAN (d_per
     WHERE (temp_review->list[d_per.seq].display_entry="Y"))
     JOIN (per
     WHERE (per.person_id=
     IF ((temp_review->list[d_per.seq].rev_cmb_ind="Y")) temp_review->list[d_per.seq].to_person_id
     ELSE temp_review->list[d_per.seq].from_person_id
     ENDIF
     ))
     JOIN (pc
     WHERE per.person_id=pc.from_person_id)
     JOIN (pcd
     WHERE pcd.person_combine_id=pc.person_combine_id
      AND pcd.entity_name="PERSON_ALIAS")
     JOIN (pa
     WHERE pa.person_alias_id=pcd.entity_id
      AND pa.person_alias_type_cd IN (mrn_code, ssn_code))
    ORDER BY per.person_id
    HEAD per.person_id
     mrn_cnt = 0, ssn_cnt = 0, perlistidx = locateval(num,1,size(person_details->person_list,5),per
      .person_id,person_details->person_list[num].person_id)
    DETAIL
     CALL populate_alias_info(mrn_cnt,ssn_cnt,perlistidx,1)
    FOOT  per.person_id
     stat = alterlist(person_details->person_list[perlistidx].ssn_list,ssn_cnt), stat = alterlist(
      person_details->person_list[perlistidx].mrn_list,mrn_cnt)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    *
    FROM person per,
     (dummyt d_per  WITH seq = value(size(temp_review->list,5))),
     person_combine pc,
     person_combine_det pcd2,
     encounter encntr
    PLAN (d_per
     WHERE (temp_review->list[d_per.seq].display_entry="Y"))
     JOIN (per
     WHERE (per.person_id=
     IF ((temp_review->list[d_per.seq].rev_cmb_ind="Y")) temp_review->list[d_per.seq].to_person_id
     ELSE temp_review->list[d_per.seq].from_person_id
     ENDIF
     ))
     JOIN (pc
     WHERE per.person_id=pc.from_person_id)
     JOIN (pcd2
     WHERE pcd2.person_combine_id=pc.person_combine_id
      AND pcd2.active_ind=1
      AND pcd2.entity_name="ENCOUNTER")
     JOIN (encntr
     WHERE pcd2.entity_id=encntr.encntr_id)
    ORDER BY per.person_id
    HEAD per.person_id
     enc_cnt = 0, perlistidx = locateval(num,1,size(person_details->person_list,5),per.person_id,
      person_details->person_list[num].person_id)
    DETAIL
     CALL populate_encounter_info(perlistidx,enc_cnt)
    FOOT  per.person_id
     stat = alterlist(person_details->person_list[perlistidx].encntr,enc_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE get_to_person(null)
   SELECT INTO "nl:"
    pa_exists = decode(d_pa.seq,"Y","N")
    FROM person per,
     (dummyt d_per  WITH seq = value(size(temp_review->list,5))),
     (dummyt d_pa  WITH seq = 1),
     person_alias pa
    PLAN (d_per
     WHERE (temp_review->list[d_per.seq].display_entry="Y"))
     JOIN (per
     WHERE (per.person_id=
     IF ((temp_review->list[d_per.seq].rev_cmb_ind="Y")) temp_review->list[d_per.seq].from_person_id
     ELSE temp_review->list[d_per.seq].to_person_id
     ENDIF
     ))
     JOIN (d_pa
     WHERE d_pa.seq=1)
     JOIN (pa
     WHERE pa.person_id=per.person_id
      AND pa.person_alias_type_cd IN (mrn_code, ssn_code))
    ORDER BY per.person_id
    HEAD per.person_id
     perlistcnt += 1
     IF (perlistcnt > size(person_details->person_list,5))
      stat = alterlist(person_details->person_list,(perlistcnt+ 10))
     ENDIF
     mrn_cnt = 0, ssn_cnt = 0, person_details->person_list[perlistcnt].person_id = per.person_id,
     temp_review->list[d_per.seq].to_person_index = perlistcnt, person_details->person_list[
     perlistcnt].name = per.name_full_formatted, person_details->person_list[perlistcnt].birth_dt_tm
      = cnvtdatetime(per.birth_dt_tm),
     person_details->person_list[perlistcnt].birth_tz = cnvtint(per.birth_tz), person_details->
     person_list[perlistcnt].sex_disp = uar_get_code_display(cnvtreal(per.sex_cd))
    DETAIL
     IF (pa_exists="Y")
      CALL populate_alias_info(mrn_cnt,ssn_cnt,perlistcnt,0)
     ENDIF
    FOOT  per.person_id
     stat = alterlist(person_details->person_list[perlistcnt].ssn_list,ssn_cnt), stat = alterlist(
      person_details->person_list[perlistcnt].mrn_list,mrn_cnt)
    FOOT REPORT
     stat = alterlist(person_details->person_list,perlistcnt)
    WITH nocounter, outerjoin(d_pa)
   ;end select
   DECLARE frm_person_loc = i4 WITH noconstant(0)
   DECLARE frm_person_id = i4 WITH noconstant(0)
   SELECT INTO "nl:"
    *
    FROM person per,
     (dummyt d_per  WITH seq = value(size(temp_review->list,5))),
     encounter encntr
    PLAN (d_per
     WHERE (temp_review->list[d_per.seq].display_entry="Y"))
     JOIN (per
     WHERE (per.person_id=
     IF ((temp_review->list[d_per.seq].rev_cmb_ind="Y")) temp_review->list[d_per.seq].from_person_id
     ELSE temp_review->list[d_per.seq].to_person_id
     ENDIF
     ))
     JOIN (encntr
     WHERE encntr.person_id=per.person_id)
    ORDER BY per.person_id
    HEAD per.person_id
     enc_cnt = 0, perlistidx = locateval(num,1,size(person_details->person_list,5),per.person_id,
      person_details->person_list[num].person_id)
    DETAIL
     CALL populate_encounter_info(perlistidx,enc_cnt)
    FOOT  per.person_id
     stat = alterlist(person_details->person_list[perlistidx].encntr,enc_cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE (populate_alias_info(pai_mrn_cnt=i4(ref),pai_ssn_cnt=i4(ref),pai_perlistcnt=i4(val),
  pai_to_ind=i2(val)) =null WITH protect)
   DECLARE idx_cnt = i4 WITH noconstant(0)
   DECLARE fill_ssn = i2 WITH private, noconstant(0)
   IF (pa.person_alias_type_cd=mrn_code)
    IF (locateval(idx_cnt,1,size(person_details->person_list[pai_perlistcnt].mrn_list,5),pa.alias,
     person_details->person_list[pai_perlistcnt].mrn_list[idx_cnt].raw_mrn)=0)
     SET pai_mrn_cnt += 1
     IF (size(person_details->person_list[pai_perlistcnt].mrn_list,5) < pai_mrn_cnt)
      SET stat = alterlist(person_details->person_list[pai_perlistcnt].mrn_list,(pai_mrn_cnt+ 4))
     ENDIF
     SET person_details->person_list[pai_perlistcnt].mrn_list[pai_mrn_cnt].raw_mrn = pa.alias
     SET person_details->person_list[pai_perlistcnt].mrn_list[pai_mrn_cnt].mrn = cnvtalias(pa.alias,
      pa.alias_pool_cd)
    ENDIF
   ENDIF
   IF (pa.person_alias_type_cd=ssn_code)
    IF (locateval(idx_cnt,1,size(person_details->person_list[pai_perlistcnt].ssn_list,5),pa.alias,
     person_details->person_list[pai_perlistcnt].ssn_list[idx_cnt].raw_ssn)=0)
     IF (pai_to_ind=1)
      IF ((temp_review->list[d_per.seq].rev_cmb_ind="Y"))
       IF (pa.active_ind=1)
        SET fill_ssn = 1
       ENDIF
      ELSE
       SET fill_ssn = 1
      ENDIF
     ELSE
      SET fill_ssn = 1
     ENDIF
     IF (fill_ssn=1)
      SET pai_ssn_cnt += 1
      IF (size(person_details->person_list[pai_perlistcnt].ssn_list,5) < pai_ssn_cnt)
       SET stat = alterlist(person_details->person_list[pai_perlistcnt].ssn_list,(pai_ssn_cnt+ 4))
      ENDIF
      SET person_details->person_list[pai_perlistcnt].ssn_list[pai_ssn_cnt].raw_ssn = pa.alias
      SET person_details->person_list[pai_perlistcnt].ssn_list[pai_ssn_cnt].ssn = cnvtalias(pa.alias,
       pa.alias_pool_cd)
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_encounter_info(pei_perlistcnt=i4(val),pei_enc_cnt=i4(ref)) =null WITH protect)
   DECLARE loc_nurse_unit = c25 WITH constant(uar_get_code_display(encntr.loc_nurse_unit_cd))
   DECLARE loc_room = c25 WITH constant(uar_get_code_display(encntr.loc_room_cd))
   DECLARE loc_bed = c25 WITH constant(uar_get_code_display(encntr.loc_bed_cd))
   DECLARE enc_found = i2 WITH noconstant(0)
   DECLARE idx_cnt = i4 WITH noconstant(0)
   IF (locateval(idx_cnt,1,size(person_details->person_list[pei_perlistcnt].encntr,5),encntr
    .encntr_id,person_details->person_list[pei_perlistcnt].encntr[idx_cnt].enc_id)=0)
    SET pei_enc_cnt += 1
    IF (size(person_details->person_list[pei_perlistcnt].encntr,5) < pei_enc_cnt)
     SET stat = alterlist(person_details->person_list[pei_perlistcnt].encntr,(pei_enc_cnt+ 4))
    ENDIF
    SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_id = encntr.encntr_id
    SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_status =
    uar_get_code_display(encntr.encntr_status_cd)
    SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_type =
    uar_get_code_display(encntr.encntr_type_cd)
    SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_pre_dt_tm = encntr
    .pre_reg_dt_tm
    SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_reg_dt_tm = encntr
    .reg_dt_tm
    SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_disch_dt_tm = encntr
    .disch_dt_tm
    SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_patient_loc =
    uar_get_code_display(encntr.loc_building_cd)
    IF (trim(loc_nurse_unit) > " ")
     SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_patient_loc = concat(
      trim(person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_patient_loc)," ",trim(
       loc_nurse_unit))
    ENDIF
    IF (trim(loc_room) > " ")
     SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_patient_loc = concat(
      trim(person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_patient_loc)," ",trim(
       loc_room))
    ENDIF
    IF (trim(loc_bed) > " ")
     SET person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_patient_loc = concat(
      trim(person_details->person_list[pei_perlistcnt].encntr[pei_enc_cnt].enc_patient_loc)," ",trim(
       loc_bed))
    ENDIF
   ENDIF
 END ;Subroutine
 DECLARE printreport(null) = null
 SUBROUTINE printreport(null)
   DECLARE tempindx1 = i4 WITH protect, noconstant(0)
   DECLARE aliaslistlength = i4 WITH protect, noconstant(0)
   DECLARE to_idx = i4 WITH protect, noconstant(0)
   DECLARE alias_to_indx = i4 WITH protect, noconstant(0)
   DECLARE alias_from_indx = i4 WITH protect, noconstant(0)
   SET curr_from_person_id = 0.00
   SET curr_to_person_id = 0.00
   IF ((request->facility_cd > 0))
    SET facility_disp = uar_get_code_display(request->facility_cd)
   ENDIF
   EXECUTE cpm_create_file_name_logical "bbt_review_que", "txt", "x"
   SELECT
    IF (size(temp_review->list,5) > 0)
     WHERE (temp_review->list[d1.seq].display_entry="Y")
     ORDER BY temp_review->list[d1.seq].from_person_id, temp_review->list[d1.seq].to_person_id
    ELSE
    ENDIF
    INTO cpm_cfn_info->file_name_logical
    FROM (dummyt d1  WITH seq = size(temp_review->list,5))
    HEAD REPORT
     f_col = 12, row_added = "N", line = fillstring(125,"_")
    HEAD PAGE
     CALL center(captions->bb_review_queue,1,125), col 104, captions->time,
     col 118, curtime"@TIMENOSECONDS;;M", row + 1,
     col 104, captions->as_of_date, col 118,
     curdate"@DATECONDENSED;;d", inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,
      curprog,"",curcclrev),
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
     save_row = row, row 1,
     CALL center(captions->rpt,1,125),
     row save_row, row + 3, col 25,
     captions->beg_date, begin_dt_tm = cnvtdatetime(request->beg_dt_tm), col 41,
     begin_dt_tm"@DATECONDENSED;;d", col 49, begin_dt_tm"@TIMENOSECONDS;;M",
     col 65, captions->end_date, end_dt_time = cnvtdatetime(request->end_dt_tm),
     col 78, end_dt_time"@DATECONDENSED;;d", col 86,
     end_dt_time"@TIMENOSECONDS;;M"
     IF ((request->facility_cd > 0))
      row + 2, col 1, captions->facility,
      col 11, facility_disp
     ENDIF
     row + 3, col 17, captions->from_patient,
     col 70, captions->to_patient, row + 1,
     col 17, "--------------------------------------------------", col 70,
     "--------------------------------------------------"
    DETAIL
     IF (size(temp_review->list,5) > 0)
      temp_to_enc_type = fillstring(20," "), temp_to_enc_status = fillstring(15," "),
      temp_to_enc_patient_loc = fillstring(40," "),
      curr_from_person_id = temp_review->list[d1.seq].from_person_id, curr_to_person_id = temp_review
      ->list[d1.seq].to_person_id, person_index_from = temp_review->list[d1.seq].from_person_index,
      person_index_to = temp_review->list[d1.seq].to_person_index
      IF ((temp_review->list[d1.seq].rev_cmb_ind="N"))
       temp_person_index = 0
       IF (person_index_to <= 0)
        person_index_to = locateval(temp_person_index,1,size(person_details->person_list,5),
         curr_to_person_id,person_details->person_list[temp_person_index].person_id)
       ENDIF
       temp_person_index = 0
       IF (person_index_from <= 0)
        person_index_from = locateval(temp_person_index,1,size(person_details->person_list,5),
         curr_from_person_id,person_details->person_list[temp_person_index].person_id)
       ENDIF
      ELSE
       temp_person_index = 0
       IF (person_index_to <= 0)
        person_index_to = locateval(temp_person_index,1,size(person_details->person_list,5),
         curr_from_person_id,person_details->person_list[temp_person_index].person_id)
       ENDIF
       temp_person_index = 0
       IF (person_index_from <= 0)
        person_index_from = locateval(temp_person_index,1,size(person_details->person_list,5),
         curr_to_person_id,person_details->person_list[temp_person_index].person_id)
       ENDIF
      ENDIF
      temp_person_index = 0
      IF ((temp_review->list[d1.seq].uncombine_ind="Y")
       AND (temp_review->list[d1.seq].rev_cmb_ind="Y"))
       temp_person_index = person_index_from, person_index_from = person_index_to, person_index_to =
       temp_person_index
      ENDIF
      row + 1
      IF (row > 56)
       BREAK, row + 1
      ENDIF
      col 1, captions->name
      IF (person_index_from > 0
       AND (person_details->person_list[person_index_from].name > " "))
       col 17, person_details->person_list[person_index_from].name
      ELSE
       col 17, captions->not_on_file
      ENDIF
      IF (person_index_to > 0
       AND trim(person_details->person_list[person_index_to].name) > " ")
       col 70, person_details->person_list[person_index_to].name
      ELSE
       col 70, captions->not_on_file
      ENDIF
      row + 1
      IF (row > 56)
       BREAK, row + 1
      ENDIF
      col 1, captions->gender
      IF (person_index_from > 0
       AND trim(person_details->person_list[person_index_from].sex_disp) > " ")
       col 17, person_details->person_list[person_index_from].sex_disp
      ELSE
       col 17, captions->not_on_file
      ENDIF
      IF (person_index_to > 0
       AND trim(person_details->person_list[person_index_to].sex_disp) > " ")
       col 70, person_details->person_list[person_index_to].sex_disp
      ELSE
       col 70, captions->not_on_file
      ENDIF
      row + 1
      IF (row > 56)
       BREAK, row + 1
      ENDIF
      col 1, captions->date_of_birth
      IF (person_index_from > 0
       AND (person_details->person_list[person_index_from].birth_dt_tm > 0))
       IF (curutc=1)
        temp1 = format(datetimezone(person_details->person_list[person_index_from].birth_dt_tm,
          person_details->person_list[person_index_from].birth_tz),"@DATECONDENSED;4;q"), temp2 =
        format(datetimezone(person_details->person_list[person_index_from].birth_dt_tm,person_details
          ->person_list[person_index_from].birth_tz),"@TIMENOSECONDS;4;q")
       ELSE
        temp1 = format(person_details->person_list[person_index_from].birth_dt_tm,"@DATECONDENSED;;d"
         ), temp2 = format(person_details->person_list[person_index_from].birth_dt_tm,
         "@TIMENOSECONDS;;M")
       ENDIF
       col 17, temp1, col 25,
       temp2
      ELSE
       col 17, captions->not_on_file
      ENDIF
      IF (person_index_to > 0
       AND (person_details->person_list[person_index_to].birth_dt_tm > 0))
       IF (curutc=1)
        temp1 = format(datetimezone(person_details->person_list[person_index_to].birth_dt_tm,
          person_details->person_list[person_index_to].birth_tz),"@DATECONDENSED;4;q"), temp2 =
        format(datetimezone(person_details->person_list[person_index_to].birth_dt_tm,person_details->
          person_list[person_index_to].birth_tz),"@TIMENOSECONDS;4;q")
       ELSE
        temp1 = format(person_details->person_list[person_index_to].birth_dt_tm,"@DATECONDENSED;;d"),
        temp2 = format(person_details->person_list[person_index_to].birth_dt_tm,"@TIMENOSECONDS;;M")
       ENDIF
       col 70, temp1, col 78,
       temp2
      ELSE
       col 70, captions->not_on_file
      ENDIF
      temp_index_from = 0, temp_index_to = 0
      IF ((temp_review->list[d1.seq].uncombine_ind="N"))
       IF ((temp_review->list[d1.seq].rev_cmb_ind="Y"))
        temp_index_to = person_index_from, temp_index_from = person_index_to
       ELSE
        temp_index_to = person_index_to, temp_index_from = person_index_from
       ENDIF
      ELSE
       temp_index_to = person_index_to, temp_index_from = person_index_from
      ENDIF
      alias_to_indx = 0, alias_from_indx = 0
      IF (temp_index_to > 0
       AND temp_index_from > 0)
       IF ((temp_review->list[d1.seq].rev_cmb_ind="Y"))
        alias_to_indx = temp_index_from, alias_from_indx = temp_index_to
       ELSE
        alias_to_indx = temp_index_to, alias_from_indx = temp_index_from
       ENDIF
      ENDIF
      IF (alias_to_indx > 0
       AND alias_from_indx > 0)
       to_idx = 1, aliaslistlength = size(person_details->person_list[alias_to_indx].ssn_list,5)
       WHILE (to_idx <= aliaslistlength
        AND aliaslistlength > 0)
         temp_ssn = person_details->person_list[alias_to_indx].ssn_list[to_idx].ssn, tempindx1 =
         locateval(indx1,1,size(person_details->person_list[alias_from_indx].ssn_list,5),temp_ssn,
          person_details->person_list[alias_from_indx].ssn_list[indx1].ssn)
         IF (tempindx1 > 0)
          stat = alterlist(person_details->person_list[alias_to_indx].ssn_list,(size(person_details->
            person_list[alias_to_indx].ssn_list,5) - 1),(to_idx - 1)), aliaslistlength = size(
           person_details->person_list[alias_to_indx].ssn_list,5)
         ELSE
          to_idx += 1
         ENDIF
       ENDWHILE
      ENDIF
      from_ssn_idx = 0
      IF (temp_index_from > 0)
       from_ssn_idx = size(person_details->person_list[temp_index_from].ssn_list,5)
      ENDIF
      to_ssn_idx = 0
      IF (temp_index_to > 0)
       to_ssn_idx = size(person_details->person_list[temp_index_to].ssn_list,5)
      ENDIF
      IF (from_ssn_idx >= to_ssn_idx)
       hld_idx = from_ssn_idx
       IF (temp_index_to > 0)
        stat = alterlist(person_details->person_list[temp_index_to].ssn_list,hld_idx)
       ENDIF
      ELSE
       hld_idx = to_ssn_idx
       IF (temp_index_from > 0)
        stat = alterlist(person_details->person_list[temp_index_from].ssn_list,hld_idx)
       ENDIF
      ENDIF
      FOR (x = 1 TO hld_idx)
        row + 1
        IF (row > 56)
         BREAK, row + 1
        ENDIF
        IF (x=1)
         col 1, captions->ssn
        ENDIF
        IF (temp_index_from > 0)
         IF (trim(person_details->person_list[temp_index_from].ssn_list[x].ssn) > " ")
          col 17, person_details->person_list[temp_index_from].ssn_list[x].ssn
         ELSE
          IF (x=1)
           col 17, captions->not_on_file
          ENDIF
         ENDIF
        ENDIF
        IF (temp_index_to > 0)
         IF (trim(person_details->person_list[temp_index_to].ssn_list[x].ssn) > " ")
          col 70, person_details->person_list[temp_index_to].ssn_list[x].ssn
         ELSE
          IF (x=1)
           col 70, captions->not_on_file
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      IF (alias_to_indx > 0
       AND alias_from_indx > 0)
       aliaslistlength = size(person_details->person_list[alias_to_indx].mrn_list,5), to_idx = 1
       WHILE (to_idx <= aliaslistlength
        AND aliaslistlength > 0)
         temp_ssn = person_details->person_list[alias_to_indx].mrn_list[to_idx].mrn, tempindx1 =
         locateval(indx1,1,size(person_details->person_list[alias_from_indx].mrn_list,5),temp_ssn,
          person_details->person_list[alias_from_indx].mrn_list[indx1].mrn)
         IF (tempindx1 > 0)
          stat = alterlist(person_details->person_list[alias_to_indx].mrn_list,(size(person_details->
            person_list[alias_to_indx].mrn_list,5) - 1),(to_idx - 1)), aliaslistlength = size(
           person_details->person_list[alias_to_indx].mrn_list,5)
         ELSE
          to_idx += 1
         ENDIF
       ENDWHILE
      ENDIF
      from_mrn_indx = 0
      IF (temp_index_from > 0)
       from_mrn_idx = size(person_details->person_list[temp_index_from].mrn_list,5)
      ENDIF
      to_mrn_indx = 0
      IF (temp_index_to > 0)
       to_mrn_idx = size(person_details->person_list[temp_index_to].mrn_list,5)
      ENDIF
      IF (from_mrn_idx >= to_mrn_idx)
       hld_idx = from_mrn_idx
       IF (temp_index_to > 0)
        stat = alterlist(person_details->person_list[temp_index_to].mrn_list,hld_idx)
       ENDIF
      ELSE
       hld_idx = to_mrn_idx
       IF (temp_index_from > 0)
        stat = alterlist(person_details->person_list[temp_index_from].mrn_list,hld_idx)
       ENDIF
      ENDIF
      FOR (x = 1 TO hld_idx)
        row + 1
        IF (row > 56)
         BREAK, row + 1
        ENDIF
        IF (x=1)
         col 1, captions->mrn
        ENDIF
        IF (temp_index_from > 0)
         IF (trim(person_details->person_list[temp_index_from].mrn_list[x].mrn) > " ")
          col 17, person_details->person_list[temp_index_from].mrn_list[x].mrn
         ELSE
          IF (x=1)
           col 17, captions->not_on_file
          ENDIF
         ENDIF
        ENDIF
        IF (temp_index_to > 0)
         IF (trim(person_details->person_list[temp_index_to].mrn_list[x].mrn) > " ")
          col 70, person_details->person_list[temp_index_to].mrn_list[x].mrn
         ELSE
          IF (x=1)
           col 70, captions->not_on_file
          ENDIF
         ENDIF
        ENDIF
      ENDFOR
      from_enc_idx = 0
      IF (temp_index_from > 0)
       from_enc_idx = size(person_details->person_list[temp_index_from].encntr,5)
      ENDIF
      from_save_x_reg = 0, from_save_x_pre = 0, from_save_x_disch = 0,
      from_most_active = 0, temp->from_pre_dt_tm = 0, temp->from_reg_dt_tm = 0,
      temp->from_disch_dt_tm = 0, temp->to_pre_dt_tm = 0, temp->to_reg_dt_tm = 0,
      temp->to_disch_dt_tm = 0
      FOR (x = 1 TO from_enc_idx)
        IF ((person_details->person_list[temp_index_from].encntr[x].enc_disch_dt_tm <= 0))
         IF ((person_details->person_list[temp_index_from].encntr[x].enc_reg_dt_tm > 0))
          IF ((person_details->person_list[temp_index_from].encntr[x].enc_reg_dt_tm > temp->
          from_reg_dt_tm))
           from_save_x_reg = x, temp->from_reg_dt_tm = person_details->person_list[temp_index_from].
           encntr[x].enc_reg_dt_tm
          ENDIF
         ELSEIF ((person_details->person_list[temp_index_from].encntr[x].enc_pre_dt_tm > 0))
          IF ((person_details->person_list[temp_index_from].encntr[x].enc_reg_dt_tm > temp->
          from_pre_dt_tm))
           from_save_x_pre = x, temp->from_pre_dt_tm = person_details->person_list[temp_index_from].
           encntr[x].enc_pre_dt_tm
          ENDIF
         ENDIF
        ELSE
         IF ((person_details->person_list[temp_index_from].encntr[x].enc_disch_dt_tm > temp->
         from_disch_dt_tm))
          from_save_x_disch = x, temp->from_disch_dt_tm = person_details->person_list[temp_index_from
          ].encntr[x].enc_disch_dt_tm
         ENDIF
        ENDIF
      ENDFOR
      IF (from_save_x_reg > 0)
       from_most_active = from_save_x_reg
      ELSEIF (from_save_x_pre > 0)
       from_most_active = from_save_x_pre
      ELSE
       from_most_active = from_save_x_disch
      ENDIF
      IF (from_most_active > 0)
       temp->from_reg_dt_tm = person_details->person_list[temp_index_from].encntr[from_most_active].
       enc_reg_dt_tm, temp->from_pre_dt_tm = person_details->person_list[temp_index_from].encntr[
       from_most_active].enc_pre_dt_tm, temp->from_disch_dt_tm = person_details->person_list[
       temp_index_from].encntr[from_most_active].enc_disch_dt_tm,
       temp_from_enc_type = person_details->person_list[temp_index_from].encntr[from_most_active].
       enc_type, temp_from_enc_status = person_details->person_list[temp_index_from].encntr[
       from_most_active].enc_status, temp_from_enc_patient_loc = person_details->person_list[
       temp_index_from].encntr[from_most_active].enc_patient_loc
      ENDIF
      to_enc_idx = 0
      IF (temp_index_to > 0)
       to_enc_idx = alterlist(person_details->person_list[temp_index_to].encntr,5)
      ENDIF
      to_save_x_reg = 0, to_save_x_pre = 0, to_save_x_disch = 0,
      to_most_active = 0
      FOR (x = 1 TO to_enc_idx)
        IF ((person_details->person_list[temp_index_to].encntr[x].enc_disch_dt_tm <= 0))
         IF ((person_details->person_list[temp_index_to].encntr[x].enc_reg_dt_tm > 0))
          IF ((person_details->person_list[temp_index_to].encntr[x].enc_reg_dt_tm > temp->
          to_reg_dt_tm))
           to_save_x_reg = x, temp->to_reg_dt_tm = person_details->person_list[temp_index_to].encntr[
           x].enc_reg_dt_tm
          ENDIF
         ELSEIF ((person_details->person_list[temp_index_to].encntr[x].enc_pre_dt_tm > 0))
          IF ((person_details->person_list[temp_index_to].encntr[x].enc_reg_dt_tm > temp->
          to_pre_dt_tm))
           to_save_x_pre = x, temp->to_pre_dt_tm = person_details->person_list[temp_index_to].encntr[
           x].enc_pre_dt_tm
          ENDIF
         ENDIF
        ELSE
         IF ((person_details->person_list[temp_index_to].encntr[x].enc_disch_dt_tm > temp->
         to_disch_dt_tm))
          to_save_x_disch = x, temp->to_disch_dt_tm = person_details->person_list[temp_index_to].
          encntr[x].enc_disch_dt_tm
         ENDIF
        ENDIF
      ENDFOR
      IF (to_save_x_reg > 0)
       to_most_active = to_save_x_reg
      ELSEIF (to_save_x_pre > 0)
       to_most_active = to_save_x_pre
      ELSE
       to_most_active = to_save_x_disch
      ENDIF
      IF (to_most_active > 0)
       temp->to_reg_dt_tm = person_details->person_list[temp_index_to].encntr[to_most_active].
       enc_reg_dt_tm, temp->to_pre_dt_tm = person_details->person_list[temp_index_to].encntr[
       to_most_active].enc_pre_dt_tm, temp->to_disch_dt_tm = person_details->person_list[
       temp_index_to].encntr[to_most_active].enc_disch_dt_tm,
       temp_to_enc_type = person_details->person_list[temp_index_to].encntr[to_most_active].enc_type,
       temp_to_enc_status = person_details->person_list[temp_index_to].encntr[to_most_active].
       enc_status, temp_to_enc_patient_loc = person_details->person_list[temp_index_to].encntr[
       to_most_active].enc_patient_loc
      ENDIF
      IF (((from_most_active > 0) OR (to_most_active > 0)) )
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       col 1, captions->registration, col 17,
       temp_from_enc_type, col 37, temp_from_enc_status,
       col 70, temp_to_enc_type, col 95,
       temp_to_enc_status, row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       IF ((temp->from_reg_dt_tm > 0))
        col 17, captions->reg, col 22,
        temp->from_reg_dt_tm"@DATECONDENSED;;d", col 30, temp->from_reg_dt_tm"@TIMENOSECONDS;;M"
       ELSEIF ((temp->from_pre_dt_tm > 0))
        col 17, captions->pre, col 22,
        temp->from_pre_dt_tm"@DATECONDENSED;;d", col 30, temp->from_pre_dt_tm"@TIMENOSECONDS;;M"
       ENDIF
       IF ((temp->from_disch_dt_tm > 0))
        col 37, captions->dis, col 42,
        temp->from_disch_dt_tm"@DATECONDENSED;;d", col 50, temp->from_disch_dt_tm"@TIMENOSECONDS;;M"
       ENDIF
       IF ((temp->to_reg_dt_tm > 0))
        col 70, captions->reg, col 75,
        temp->to_reg_dt_tm"@DATECONDENSED;;d", col 83, temp->to_reg_dt_tm"@TIMENOSECONDS;;M"
       ELSEIF ((temp->to_pre_dt_tm > 0))
        col 70, captions->pre, col 75,
        temp->to_pre_dt_tm"@DATECONDENSED;;d", col 83, temp->to_pre_dt_tm"@TIMENOSECONDS;;M"
       ENDIF
       IF ((temp->to_disch_dt_tm > 0))
        col 90, captions->dis, col 95,
        temp->to_disch_dt_tm"@DATECONDENSED;;d", col 103, temp->to_disch_dt_tm"@TIMENOSECONDS;;M"
       ENDIF
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       col 1, captions->location, col 17,
       temp_from_enc_patient_loc, col 70, temp_to_enc_patient_loc
      ENDIF
      from_pab_cnt = 0, to_pab_cnt = 0, from_pab_cnt = size(temp_review->list[d1.seq].from_rec.
       from_antibody,5),
      to_pab_cnt = size(temp_review->list[d1.seq].to_rec.to_antibody,5)
      IF (((from_pab_cnt > 0) OR (to_pab_cnt > 0)) )
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       IF (from_pab_cnt > to_pab_cnt)
        max_pab_cnt = from_pab_cnt
       ELSE
        max_pab_cnt = to_pab_cnt
       ENDIF
       col 1, captions->antibodies, f_col = 17,
       t_col = 17, row_incr_ind = 0
       FOR (x = 1 TO max_pab_cnt)
         IF (from_pab_cnt >= x)
          IF (x != 1)
           f_col = ((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_antibody[(x - 1)].
            antibody))+ 1)
           IF (((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_antibody[x].antibody)) > 67))
            row + 1
            IF (row > 56)
             BREAK, row + 1
            ENDIF
            f_col = 17, t_col = 17, row_incr_ind = 1
           ENDIF
          ENDIF
          IF (((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_antibody[x].antibody)) > 67))
           row + 1
           IF (row > 56)
            BREAK, row + 1
           ENDIF
           f_col = 17, t_col = 17, row_incr_ind = 1
          ENDIF
          IF (textlen(temp_review->list[d1.seq].from_rec.from_antibody[x].antibody) > 50)
           antibody = substring(1,50,temp_review->list[d1.seq].from_rec.from_antibody[x].antibody),
           col f_col, antibody
          ELSE
           col f_col, temp_review->list[d1.seq].from_rec.from_antibody[x].antibody
          ENDIF
         ENDIF
         IF (to_pab_cnt >= x)
          IF (x != 1
           AND row_incr_ind=0)
           t_col = ((t_col+ textlen(temp_review->list[d1.seq].to_rec.to_antibody[(x - 1)].antibody))
           + 1)
          ENDIF
          IF ((((t_col+ 53)+ textlen(temp_review->list[d1.seq].to_rec.to_antibody[x].antibody)) > 120
          ))
           row + 1
           IF (row > 56)
            BREAK, row + 1
           ENDIF
           t_col = 17
          ENDIF
          IF (textlen(temp_review->list[d1.seq].to_rec.to_antibody[x].antibody) > 50)
           t_antibody = substring(1,50,temp_review->list[d1.seq].to_rec.to_antibody[x].antibody),
           call reportmove('COL',(t_col+ 53),0), t_antibody
          ELSE
           call reportmove('COL',(t_col+ 53),0), temp_review->list[d1.seq].to_rec.to_antibody[x].
           antibody
          ENDIF
         ENDIF
         row_incr_ind = 0
       ENDFOR
      ENDIF
      from_count = size(temp_review->list[d1.seq].from_rec.from_antigen,5), to_count = size(
       temp_review->list[d1.seq].to_rec.to_antigen,5)
      IF (((from_count > 0) OR (to_count > 0)) )
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       IF (from_count >= to_count)
        hld_idx = from_count, stat = alterlist(temp_review->list[d1.seq].to_rec.to_antigen,hld_idx)
       ELSE
        hld_idx = to_count, stat = alterlist(temp_review->list[d1.seq].from_rec.from_antigen,hld_idx)
       ENDIF
       col 1, captions->antigens, f_col = 7
       FOR (x = 1 TO hld_idx)
         f_col += 10
         IF (f_col > 34)
          row + 1
          IF (row > 56)
           BREAK, row + 1
          ENDIF
          f_col = 17
         ENDIF
         IF (from_count > 0)
          IF (trim(temp_review->list[d1.seq].from_rec.from_antigen[x].antigen) > " ")
           col f_col, temp_review->list[d1.seq].from_rec.from_antigen[x].antigen
          ENDIF
         ENDIF
         IF (to_count > 0)
          IF (trim(temp_review->list[d1.seq].to_rec.to_antigen[x].antigen) > " ")
           call reportmove('COL',(f_col+ 53),0), temp_review->list[d1.seq].to_rec.to_antigen[x].
           antigen
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      from_count = size(temp_review->list[d1.seq].from_rec.from_aborh,5), to_count = size(temp_review
       ->list[d1.seq].to_rec.to_aborh,5)
      IF (((from_count > 0) OR (to_count > 0)) )
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       IF (from_count >= to_count)
        hld_idx = from_count
       ELSE
        hld_idx = to_count
       ENDIF
       col 1, captions->aborh, f_col = 0
       FOR (x = 1 TO hld_idx)
         f_col += 17
         IF (f_col > 34)
          row + 1
          IF (row > 56)
           BREAK, row + 1
          ENDIF
          f_col = 17
         ENDIF
         IF (from_count > 0)
          IF (trim(temp_review->list[d1.seq].from_rec.from_aborh[x].aborh) > " ")
           col f_col, temp_review->list[d1.seq].from_rec.from_aborh[x].aborh
          ENDIF
         ENDIF
         IF (to_count > 0)
          IF (trim(temp_review->list[d1.seq].to_rec.to_aborh[x].aborh) > " ")
           call reportmove('COL',(f_col+ 53),0), temp_review->list[d1.seq].to_rec.to_aborh[x].aborh
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      from_count = size(temp_review->list[d1.seq].from_rec.from_abr,5), to_count = size(temp_review->
       list[d1.seq].to_rec.to_abr,5)
      IF (((from_count > 0) OR (to_count > 0)) )
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       IF (from_count >= to_count)
        hld_idx = from_count, stat = alterlist(temp_review->list[d1.seq].to_rec.to_abr,hld_idx)
       ELSE
        hld_idx = to_count, stat = alterlist(temp_review->list[d1.seq].from_rec.from_abr,hld_idx)
       ENDIF
       col 1, captions->aborh_results, f_col = 0
       FOR (x = 1 TO hld_idx)
         f_col += 17
         IF (f_col > 34)
          row + 1
          IF (row > 56)
           BREAK, row + 1
          ENDIF
          f_col = 17
         ENDIF
         IF (from_count > 0)
          IF (trim(temp_review->list[d1.seq].from_rec.from_abr[x].aborh_results) > " ")
           col f_col, temp_review->list[d1.seq].from_rec.from_abr[x].aborh_results
          ENDIF
         ENDIF
         IF (to_count > 0)
          IF (trim(temp_review->list[d1.seq].to_rec.to_abr[x].aborh_results) > " ")
           call reportmove('COL',(f_col+ 53),0), temp_review->list[d1.seq].to_rec.to_abr[x].
           aborh_results
          ENDIF
         ENDIF
       ENDFOR
      ENDIF
      from_prp_cnt = size(temp_review->list[d1.seq].from_rec.from_prp,5), to_prp_cnt = size(
       temp_review->list[d1.seq].to_rec.to_prp,5)
      IF (((from_prp_cnt > 0) OR (to_prp_cnt)) )
       IF (from_prp_cnt > to_prp_cnt)
        max_prp_cnt = from_prp_cnt
       ELSE
        max_prp_cnt = to_prp_cnt
       ENDIF
       FOR (prp = 1 TO max_prp_cnt)
         row + 1
         IF (row > 56)
          BREAK, row + 1
         ENDIF
         col 001, captions->rhp, max_prp_pa_cnt = 0
         IF (from_prp_cnt >= max_prp_cnt)
          from_prp_pa_cnt = temp_review->list[d1.seq].from_rec.from_prp[prp].pa_cnt, col 017,
          temp_review->list[d1.seq].from_rec.from_prp[prp].short_string
         ELSE
          from_prp_pa_cnt = 0
         ENDIF
         IF (to_prp_cnt >= max_prp_cnt)
          to_prp_pa_cnt = temp_review->list[d1.seq].to_rec.to_prp[prp].pa_cnt, col 070, temp_review->
          list[d1.seq].to_rec.to_prp[prp].short_string
         ELSE
          to_prp_pa_cnt = 0
         ENDIF
         IF (from_prp_pa_cnt > to_prp_pa_cnt)
          max_prp_pa_cnt = from_prp_pa_cnt
         ELSE
          max_prp_pa_cnt = to_prp_pa_cnt
         ENDIF
         row + 1
         IF (row > 56)
          BREAK, row + 1
         ENDIF
         col 001, captions->rhp_antigens, pa_col = 7
         FOR (pa = 1 TO max_prp_pa_cnt)
           pa_col += 10
           IF (pa_col > 34)
            row + 1, pa_col = 17
           ENDIF
           IF (from_prp_cnt >= prp
            AND from_prp_pa_cnt >= pa)
            col pa_col, temp_review->list[d1.seq].from_rec.from_prp[prp].pa[pa].antigen_disp
           ENDIF
           IF (to_prp_cnt >= prp
            AND to_prp_pa_cnt >= pa)
            call reportmove('COL',(pa_col+ 53),0), temp_review->list[d1.seq].to_rec.to_prp[prp].pa[pa
            ].antigen_disp
           ENDIF
         ENDFOR
       ENDFOR
      ENDIF
      from_prpr_cnt = size(temp_review->list[d1.seq].from_rec.from_prpr,5), to_prpr_cnt = size(
       temp_review->list[d1.seq].to_rec.to_prpr,5)
      IF (((from_prpr_cnt > 0) OR (to_prpr_cnt > 0)) )
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       IF (from_prpr_cnt > to_prpr_cnt)
        max_prpr_cnt = from_prpr_cnt
       ELSE
        max_prpr_cnt = to_prpr_cnt
       ENDIF
       col 001, captions->rhp_results, f_col = 17,
       t_col = 17, row_incr_ind = 0
       FOR (x = 1 TO max_prpr_cnt)
         IF (from_prpr_cnt >= x)
          IF (x != 1)
           f_col = ((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_prpr[(x - 1)].
            short_string))+ 1)
           IF (((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_prpr[x].short_string)) > 67))
            row + 1
            IF (row > 56)
             BREAK, row + 1
            ENDIF
            f_col = 17, t_col = 17, row_incr_ind = 1
           ENDIF
          ENDIF
          IF (((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_prpr[x].short_string)) > 67))
           row + 1
           IF (row > 56)
            BREAK, row + 1
           ENDIF
           f_col = 17, t_col = 17, row_incr_ind = 1
          ENDIF
          IF (textlen(temp_review->list[d1.seq].from_rec.from_prpr[x].short_string) > 50)
           short_string = substring(1,50,temp_review->list[d1.seq].from_rec.from_prpr[x].short_string
            ), col f_col, short_string
          ELSE
           col f_col, temp_review->list[d1.seq].from_rec.from_prpr[x].short_string
          ENDIF
         ENDIF
         IF (to_prpr_cnt >= x)
          IF (x != 1
           AND row_incr_ind=0)
           t_col = ((t_col+ textlen(temp_review->list[d1.seq].to_rec.to_prpr[(x - 1)].short_string))
           + 1)
          ENDIF
          IF ((((t_col+ 53)+ textlen(temp_review->list[d1.seq].to_rec.to_prpr[x].short_string)) > 120
          ))
           row + 1
           IF (row > 56)
            BREAK, row + 1
           ENDIF
           t_col = 17
          ENDIF
          IF (textlen(temp_review->list[d1.seq].to_rec.to_prpr[x].short_string) > 50)
           t_short_string = substring(1,50,temp_review->list[d1.seq].to_rec.to_prpr[x].short_string),
           call reportmove('COL',(t_col+ 53),0), t_short_string
          ELSE
           call reportmove('COL',(t_col+ 53),0), temp_review->list[d1.seq].to_rec.to_prpr[x].
           short_string
          ENDIF
         ENDIF
         row_incr_ind = 0
       ENDFOR
      ENDIF
      from_tr_cnt = size(temp_review->list[d1.seq].from_rec.from_trans_req,5), to_tr_cnt = size(
       temp_review->list[d1.seq].to_rec.to_trans_req,5)
      IF (((from_tr_cnt > 0) OR (to_tr_cnt > 0)) )
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       IF (from_tr_cnt > to_tr_cnt)
        max_tr_cnt = from_tr_cnt
       ELSE
        max_tr_cnt = to_tr_cnt
       ENDIF
       col 1, captions->trans_req, f_col = 17,
       t_col = 17, row_incr_ind = 0
       FOR (x = 1 TO max_tr_cnt)
         IF (from_tr_cnt >= x)
          IF (x != 1)
           f_col = ((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_trans_req[(x - 1)].
            trans_req))+ 1)
           IF (((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_trans_req[x].trans_req)) > 67
           ))
            row + 1
            IF (row > 56)
             BREAK, row + 1
            ENDIF
            f_col = 17, t_col = 17, row_incr_ind = 1
           ENDIF
          ENDIF
          IF (((f_col+ textlen(temp_review->list[d1.seq].from_rec.from_trans_req[x].trans_req)) > 67)
          )
           row + 1
           IF (row > 56)
            BREAK, row + 1
           ENDIF
           f_col = 17, t_col = 17, row_incr_ind = 1
          ENDIF
          IF (textlen(temp_review->list[d1.seq].from_rec.from_trans_req[x].trans_req) > 50)
           f_trans_req = substring(1,50,temp_review->list[d1.seq].from_rec.from_trans_req[x].
            trans_req), col f_col, f_trans_req
          ELSE
           col f_col, temp_review->list[d1.seq].from_rec.from_trans_req[x].trans_req
          ENDIF
         ENDIF
         IF (to_tr_cnt >= x)
          IF (x != 1
           AND row_incr_ind=0)
           t_col = ((t_col+ textlen(temp_review->list[d1.seq].to_rec.to_trans_req[(x - 1)].trans_req)
           )+ 1)
          ENDIF
          IF ((((t_col+ 53)+ textlen(temp_review->list[d1.seq].to_rec.to_trans_req[x].trans_req)) >
          120))
           row + 1
           IF (row > 56)
            BREAK, row + 1
           ENDIF
           t_col = 17
          ENDIF
          IF (textlen(temp_review->list[d1.seq].to_rec.to_trans_req[x].trans_req) > 50)
           t_trans_req = substring(1,50,temp_review->list[d1.seq].to_rec.to_trans_req[x].trans_req),
           call reportmove('COL',(t_col+ 53),0), t_trans_req
          ELSE
           call reportmove('COL',(t_col+ 53),0), temp_review->list[d1.seq].to_rec.to_trans_req[x].
           trans_req
          ENDIF
         ENDIF
         row_incr_ind = 0
       ENDFOR
      ENDIF
      row + 1, row + 1
      IF (row > 56)
       BREAK, row + 1
      ENDIF
      col 1, captions->combined, col 17,
      temp_review->list[d1.seq].active_status_date, col 25, temp_review->list[d1.seq].
      active_status_time,
      row + 2
      IF (row > 56)
       BREAK, row + 1
      ENDIF
      IF ((((temp_review->list[d1.seq].from_rec.from_comment > " ")) OR ((temp_review->list[d1.seq].
      to_rec.to_comment > " "))) )
       col 1, captions->bb_comments, row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       f_col = 0
       IF ((temp_review->list[d1.seq].from_rec.from_comment > " "))
        col f_col, temp_review->list[d1.seq].from_rec.from_comment
       ENDIF
       IF ((temp_review->list[d1.seq].to_rec.to_comment > " "))
        call reportmove('COL',(f_col+ 53),0), temp_review->list[d1.seq].to_rec.to_comment
       ENDIF
      ENDIF
      row + 2
      IF (row > 54)
       BREAK, row + 1
      ENDIF
      col 1, captions->specimen_exp_comments1
      IF ((temp_review->list[d1.seq].to_rec.to_spec_indicator=1))
       row + 1, col 17, captions->specimen_exp_comment1,
       row + 1, col 17, captions->specimen_exp_comment2
      ELSE
       row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       col 17, captions->none, row + 1
      ENDIF
      row + 1
     ENDIF
    FOOT PAGE
     row 57, col 1, line,
     row + 1, col 1, captions->report_id,
     col 58, captions->page_no, col 64,
     curpage"###", col 100, captions->printed,
     col 109, curdate"@DATECONDENSED;;d", col 120,
     curtime"@TIMENOSECONDS;;M"
    FOOT REPORT
     row 60,
     CALL center(captions->end_of_report,1,125)
    WITH nocounter, nullreport, maxrow = 80,
     maxcol = 200, compress, nolandscape
   ;end select
   IF (curqual=0)
    SET count1 += 1
    IF (count1 > 0)
     SET stat = alter(reply->status_data.subeventstatus,count1)
    ENDIF
    SET reply->status_data.status = "Z"
    SET reply->status_data.subeventstatus[count1].operationname = "No Records Found"
    SET reply->status_data.subeventstatus[count1].operationstatus = "F"
    SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_review_que"
    SET reply->status_data.subeventstatus[count1].targetobjectvalue = "No Records Found"
   ELSE
    SET rpt_cnt += 1
    SET stat = alterlist(reply->rpt_list,rpt_cnt)
    SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
    SET reply->status_data.status = "S"
    IF (trim(request->batch_selection) > " ")
     SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
    ENDIF
   ENDIF
 END ;Subroutine
 SET batchnumber = 0
 SET batchlowerlimit = 0
 SET batchupperlimit = 0
 SET overallcombinecount = 0
 WHILE (continue=1)
   SET temp_review->list_cnt = 0
   SET stat = initrec(temp_review)
   SET stat = initrec(person_details)
   SET batchnumber += 1
   SET batchlowerlimit = (batchupperlimit+ 1)
   SET batchupperlimit = (batchnumber * combine_count)
   SET overallcombinecount = 0
   SET reviewitemsqualified = 0
   SELECT INTO "nl:"
    rev_queue.bb_review_queue_id
    FROM bb_review_queue rev_queue,
     encounter rev_queue_encs
    PLAN (rev_queue
     WHERE rev_queue.active_ind=1
      AND rev_queue.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
      end_dt_tm))
     JOIN (rev_queue_encs
     WHERE ((((rev_queue_encs.encntr_id+ 0) > 0)) OR (((rev_queue_encs.person_id+ 0) > 0)))
      AND ((rev_queue_encs.encntr_id IN (rev_queue.from_encntr_id, rev_queue.to_encntr_id)) OR (
     rev_queue_encs.person_id IN (rev_queue.from_person_id, rev_queue.to_person_id))) )
    ORDER BY rev_queue.to_person_id, rev_queue.from_person_id, rev_queue.bb_review_queue_id
    HEAD rev_queue.to_person_id
     to_person_id = rev_queue.to_person_id
    HEAD rev_queue.from_person_id
     from_person_id = rev_queue.from_person_id, check_add_row = 0
     IF ((temp_review->list_cnt < combine_count))
      IF (((overallcombinecount+ 1) >= batchlowerlimit)
       AND ((overallcombinecount+ 1) <= batchupperlimit))
       temp_review->list_cnt += 1
       IF (mod(temp_review->list_cnt,10)=1)
        stat = alterlist(temp_review->list,(temp_review->list_cnt+ 9))
       ENDIF
       revlistindex = temp_review->list_cnt, temp_review->list[revlistindex].from_person_id =
       from_person_id, temp_review->list[revlistindex].to_person_id = to_person_id,
       temp_review->list[revlistindex].display_entry = "N", check_add_row = 1
      ENDIF
      overallcombinecount += 1
     ELSE
      check_add_row = 0
     ENDIF
    HEAD rev_queue.bb_review_queue_id
     is_filter_fac = 0, add_row = 0
     IF (rev_queue.uncombine_ind=1)
      uncombine_flag = "Y"
     ELSE
      uncombine_flag = "N"
     ENDIF
     IF (rev_queue.rev_cmb_ind=1)
      revcmb_flag = "Y"
     ELSE
      revcmb_flag = "N"
     ENDIF
     temp_bb_review_queue_id = rev_queue.bb_review_queue_id
    DETAIL
     IF ((temp_review->list_cnt <= combine_count)
      AND check_add_row=1)
      lastprocessedreviewqueueid = rev_queue.bb_review_queue_id
      IF (add_row=0)
       IF (is_filter_fac=0)
        IF ((request->facility_cd > 0))
         IF (((locateval(facidx,1,size(encounterlocations->locs,5),rev_queue_encs.loc_facility_cd,
          encounterlocations->locs[facidx].encfacilitycd) > 0) OR ((rev_queue_encs.loc_facility_cd=
         request->facility_cd))) )
          is_filter_fac = 1
         ENDIF
        ENDIF
       ENDIF
       IF ((request->facility_cd > 0))
        IF (((rev_queue.from_encntr_id > 0) OR (rev_queue.to_encntr_id > 0)) )
         IF (((rev_queue_encs.encntr_id=rev_queue.from_encntr_id) OR (rev_queue_encs.encntr_id=
         rev_queue.to_encntr_id)) )
          IF (is_filter_fac=1)
           add_row = 1
          ENDIF
         ENDIF
        ENDIF
        IF (((rev_queue.from_person_id > 0) OR (rev_queue.to_person_id > 0)) )
         IF (((rev_queue_encs.person_id=rev_queue.from_person_id) OR (rev_queue_encs.person_id=
         rev_queue.to_person_id)) )
          IF (is_filter_fac=1)
           add_row = 1
          ENDIF
         ENDIF
        ENDIF
       ELSE
        add_row = 1
       ENDIF
      ENDIF
     ENDIF
    FOOT  rev_queue.bb_review_queue_id
     IF (add_row=1)
      entitylistindex = 0, temp_review->list[revlistindex].display_entry = "Y", reviewitemsqualified
       = 1,
      temp_review->list[revlistindex].rev_cmb_ind = revcmb_flag, temp_review->list[revlistindex].
      uncombine_ind = uncombine_flag
      IF (revcmb_flag="Y")
       temp_review->list[revlistindex].rev_cmb_ind = revcmb_flag
      ENDIF
      entitylistindex = (size(temp_review->list[revlistindex].review_queue_entity_list,5)+ 1), stat
       = alterlist(temp_review->list[revlistindex].review_queue_entity_list,entitylistindex),
      temp_review->list[revlistindex].active_status_date = format(rev_queue.active_status_dt_tm,
       "@DATECONDENSED;;d"),
      temp_review->list[revlistindex].active_status_time = format(rev_queue.active_status_dt_tm,
       "@TIMENOSECONDS;;M"), temp_review->list[revlistindex].review_queue_entity_list[entitylistindex
      ].review_que_id = rev_queue.bb_review_queue_id, temp_entity_id = 0,
      from_or_to = ""
      IF (rev_queue.from_parent_entity_id > 0)
       temp_review->list[revlistindex].review_queue_entity_list[entitylistindex].from_entity_id =
       rev_queue.from_parent_entity_id, temp_entity_id = rev_queue.from_parent_entity_id, from_or_to
        = "F"
      ENDIF
      IF (temp_entity_id > 0)
       CALL addtobbdetailslist(rev_queue.parent_entity_name,temp_entity_id,revlistindex,from_or_to)
      ENDIF
      temp_entity_id = 0, from_or_to = ""
      IF (rev_queue.to_parent_entity_id > 0)
       temp_review->list[revlistindex].review_queue_entity_list[entitylistindex].to_entity_id =
       rev_queue.to_parent_entity_id, temp_entity_id = rev_queue.to_parent_entity_id, from_or_to =
       "T"
      ENDIF
      IF (temp_entity_id > 0)
       CALL addtobbdetailslist(rev_queue.parent_entity_name,temp_entity_id,revlistindex,from_or_to)
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(temp_review->list,temp_review->list_cnt)
     FOR (indx1 = 1 TO size(temp_review->list,5))
       IF ((temp_review->list[indx1].rev_cmb_ind="Y"))
        temp_person_id = temp_review->list[indx1].from_person_id, temp_review->list[indx1].
        from_person_id = temp_review->list[indx1].to_person_id, temp_review->list[indx1].to_person_id
         = temp_person_id
       ENDIF
     ENDFOR
     stat = alterlist(bb_details->aborh_list,paborh_count), stat = alterlist(bb_details->
      aborh_rs_list,paborh_rs_count), stat = alterlist(bb_details->antibody_list,pab_count),
     stat = alterlist(bb_details->antigen_list,pag_count), stat = alterlist(bb_details->comments,
      pcmnt_count), stat = alterlist(bb_details->rh_ph_list,ph_rh_count),
     stat = alterlist(bb_details->rh_ph_rs_list,ph_rh_rs_count), stat = alterlist(bb_details->
      spec_override,bseo_count), stat = alterlist(bb_details->trans_req_list,ptr_count)
    WITH nocounter
   ;end select
   IF (lastprocessedreviewqueueid=temp_bb_review_queue_id)
    SET continue = 0
   ENDIF
   IF ((temp_review->list_cnt < combine_count))
    SET continue = 0
   ENDIF
   IF (reviewitemsqualified=1)
    CALL populatebloodbankdetails(null)
    CALL populatepersonlist(null)
   ENDIF
   CALL printreport(null)
   SET temp_review->list_cnt = 0
   SET stat = initrec(temp_review)
   SET stat = initrec(person_details)
 ENDWHILE
END GO
