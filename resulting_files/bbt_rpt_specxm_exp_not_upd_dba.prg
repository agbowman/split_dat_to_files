CREATE PROGRAM bbt_rpt_specxm_exp_not_upd:dba
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
 RECORD flextransprods(
   1 patienttrlist[*]
     2 person_name = vc
     2 person_id = f8
     2 pattprintind = i2
     2 productlist[*]
       3 transfused_product_id = f8
       3 product_nbr = vc
       3 product_type_cd = f8
       3 product_type_disp = vc
       3 transfused_dt_tm = dq8
     2 spectranslist[*]
       3 specimen_id = f8
       3 accession = vc
       3 drawn_dt_tm = dq8
       3 cur_exp_dt_tm = dq8
       3 calc_exp_dt_tm = dq8
 )
 RECORD flexabprods(
   1 patientablist[*]
     2 person_name = vc
     2 person_id = f8
     2 patabprintind = i2
     2 antibodylist[*]
       3 antibody_disp = vc
       3 antibody_cd = f8
       3 ab_identify_dt_tm = dq8
     2 specablist[*]
       3 accession = vc
       3 drawn_dt_tm = dq8
       3 cur_exp_dt_tm = dq8
       3 calc_exp_dt_tm = dq8
       3 specimen_id = f8
 )
 RECORD flexxmprods(
   1 patientxmlist[*]
     2 person_name = vc
     2 person_id = f8
     2 patxmprintind = i2
     2 xmlist[*]
       3 crossmatch_product_id = f8
       3 product_nbr = vc
       3 product_type_cd = f8
       3 product_type_disp = vc
       3 crossmatched_dt_tm = dq8
     2 specxmlist[*]
       3 specimen_id = f8
       3 accession = vc
       3 reinstate_reason_disp = vc
       3 cur_exp_dt_tm = dq8
       3 drawn_dt_tm = dq8
       3 calc_exp_dt_tm = dq8
       3 new_spec_expire_dt_tm = dq8
       3 override_id = f8
       3 override_cd = f8
 )
 DECLARE rpt_cnt = i2 WITH noconstant(0)
 DECLARE flexspecenabled = i2 WITH protect, noconstant(0)
 DECLARE flexspecenabledforencnt = i2 WITH protect, noconstant(0)
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE exp_size = i4 WITH protect, noconstant(0)
 DECLARE x_idx = i4 WITH protect, noconstant(0)
 DECLARE i_idx = i4 WITH protect, noconstant(0)
 DECLARE j_idx = i4 WITH protect, noconstant(0)
 DECLARE validencntpos = i4 WITH protect, noconstant(0)
 DECLARE personexitspos = i4 WITH protect, noconstant(0)
 DECLARE validatefacility = i4 WITH protect, noconstant(0)
 DECLARE patientcnt = i4 WITH protect, noconstant(0)
 DECLARE patientabcnt = i4 WITH protect, noconstant(0)
 DECLARE patientxmcnt = i4 WITH protect, noconstant(0)
 DECLARE productcnt = i4 WITH protect, noconstant(0)
 DECLARE productabcnt = i4 WITH protect, noconstant(0)
 DECLARE productxmcnt = i4 WITH protect, noconstant(0)
 DECLARE spectranscnt = i4 WITH protect, noconstant(0)
 DECLARE specabcnt = i4 WITH protect, noconstant(0)
 DECLARE specxmcnt = i4 WITH protect, noconstant(0)
 DECLARE flex_allo_param = i4 WITH protect, noconstant(0)
 DECLARE flex_end_range = i4 WITH protect, noconstant(0)
 DECLARE flex_anti_param = i4 WITH protect, noconstant(0)
 DECLARE transfused_state_cd = f8 WITH protect, noconstant(0.0)
 DECLARE expdttm = dq8 WITH protect, noconstant(0.0)
 DECLARE temp_cal_exp_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE flex_expiration_unit_type_mean = c12 WITH protect, noconstant("")
 DECLARE neonate_ovrd_cdf_meaning = c12 WITH protect, constant("NEONATE")
 DECLARE facility_disp = vc WITH protect, noconstant("")
 DECLARE line = vc WITH noconstant(fillstring(125,"_"))
 DECLARE catalog_type_cs = i4 WITH protect, constant(6000)
 DECLARE gen_lab_cat_type_mean = c12 WITH protect, constant("GENERAL LAB")
 DECLARE gen_lab_cat_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE activity_type_cs = i4 WITH protect, constant(106)
 DECLARE bb_activity_type_mean = c12 WITH protect, constant("BB")
 DECLARE bb_activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE sup_grp_ord_type = i2 WITH protect, constant(2)
 DECLARE ord_set_ord_type = i2 WITH protect, constant(6)
 DECLARE order_status_cs = i4 WITH protect, constant(6004)
 DECLARE ordered_status_mean = c12 WITH protect, constant("ORDERED")
 DECLARE ordered_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inprocess_status_mean = c12 WITH protect, constant("INPROCESS")
 DECLARE inprocess_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE completed_status_mean = c12 WITH protect, constant("COMPLETED")
 DECLARE completed_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dept_order_status_cs = i4 WITH protect, constant(14281)
 DECLARE inlab_dept_status_mean = c12 WITH protect, constant("LABINLAB")
 DECLARE inlab_dept_status_cd = f8 WITH protect, noconstant(0.0)
 DECLARE collected_dept_status_mean = c12 WITH protect, constant("LABCOLLECTED")
 DECLARE collected_dept_status_cd = f8 WITH protect, noconstant(0.0)
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
   1 as_of_date = vc
   1 rpt_time = vc
   1 beg_date = vc
   1 end_date = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_id = vc
   1 end_of_report = vc
   1 facility = vc
   1 all = vc
   1 date = vc
   1 person_name = vc
   1 accession = vc
   1 product_number = vc
   1 product_type = vc
   1 specimen_drawn = vc
   1 transfused = vc
   1 incorrect_exp = vc
   1 correct_exp = vc
   1 date_time = vc
   1 antibody = vc
   1 identified = vc
   1 rpt_spec_title = vc
   1 rpt_xm_title = vc
   1 reinstate_reason = vc
   1 modified_reason = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As Of Date:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "SPECIMEN AND CROSSMATCH EXPIRATIONS NOT UPDATED BY THE SYSTEM")
 SET captions->rpt_spec_title = uar_i18ngetmessage(i18nhandle,"rpt_spec_title",
  "SPECIMEN EXPIRATIONS NOT UPDATED")
 SET captions->rpt_xm_title = uar_i18ngetmessage(i18nhandle,"rpt_xm_title",
  "CROSSMATCH EXPIRATIONS NOT UPDATED")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BB_RPT_EXP_NT_UPD")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 SET captions->facility = uar_i18ngetmessage(i18nhandle,"facility","Facility")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date")
 SET captions->person_name = uar_i18ngetmessage(i18nhandle,"Person_Name","Person Name  ")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"Accession","Accession")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"Product_number","Product Number")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->specimen_drawn = uar_i18ngetmessage(i18nhandle,"specimen_Drawn","Specimen Drawn")
 SET captions->transfused = uar_i18ngetmessage(i18nhandle,"Transfused","Transfused")
 SET captions->incorrect_exp = uar_i18ngetmessage(i18nhandle,"Incorrect_Exp","Incorrect Exp")
 SET captions->identified = uar_i18ngetmessage(i18nhandle,"identified","Identified")
 SET captions->correct_exp = uar_i18ngetmessage(i18nhandle,"Correct_Exp","Correct Exp")
 SET captions->date_time = uar_i18ngetmessage(i18nhandle,"date_time","Date/Time")
 SET captions->reinstate_reason = uar_i18ngetmessage(i18nhandle,"reinstate_reason","Reinstate or")
 SET captions->modified_reason = uar_i18ngetmessage(i18nhandle,"modified_reason","Modified Reason")
 SET captions->antibody = uar_i18ngetmessage(i18nhandle,"Antibody","Antibody")
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
 IF (trim(request->batch_selection) > " ")
  SET temp_string = cnvtupper(trim(request->batch_selection))
  SET begday = request->ops_date
  SET endday = request->ops_date
  CALL check_opt_date_passed("bbt_rpt_specxm_exp_not_upd")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL echo(format(request->beg_dt_tm,"@LONGDATE;;q"))
  CALL echo(format(request->end_dt_tm,"@LONGDATE;;q"))
  CALL check_facility_cd("bbt_rpt_specxm_exp_not_upd")
  CALL check_location_cd("bbt_rpt_specxm_exp_not_upd")
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
 RECORD flex_param_out(
   1 testing_facility_cd = f8
   1 flex_on_ind = i2
   1 flex_param = i4
   1 allo_param = i4
   1 auto_param = i4
   1 anti_flex_ind = i2
   1 anti_param = i4
   1 max_spec_validity = i4
   1 expiration_unit_type_mean = c12
   1 max_transfusion_end_range = i4
   1 transfusion_flex_params[*]
     2 index = i4
     2 start_range = i4
     2 end_range = i4
     2 flex_param = i4
   1 extend_trans_ovrd_ind = i2
   1 calc_trans_drawn_dt_ind = i2
   1 neonate_age = i4
 )
 RECORD flex_patient_out(
   1 person_id = f8
   1 encntr_id = f8
   1 anti_exist_ind = i2
   1 transfusion[*]
     2 transfusion_dt_tm = dq8
     2 critical_dt_tm = dq8
 )
 RECORD flex_codes(
   1 codes_loaded_ind = i2
   1 transfused_state_cd = f8
   1 blood_product_cd = f8
 )
 RECORD flex_max_out(
   1 max_expire_dt_tm = dq8
   1 max_expire_flag = i2
 )
 FREE SET facilityinfo
 RECORD facilityinfo(
   1 facilities[*]
     2 testing_facility_cd = f8
     2 flex_on_ind = i2
     2 flex_param = i4
     2 allo_param = i4
     2 auto_param = i4
     2 anti_flex_ind = i2
     2 anti_param = i4
     2 max_spec_validity = i4
     2 expiration_unit_type_mean = c12
     2 max_transfusion_end_range = i4
     2 transfusion_flex_params[*]
       3 index = i4
       3 start_range = i4
       3 end_range = i4
       3 flex_param = i4
     2 extend_trans_ovrd_ind = i2
     2 calc_trans_drawn_dt_ind = i2
     2 extend_expired_specimen = i2
     2 neonate_age = i4
     2 load_flex_params = i2
     2 extend_neonate_disch_spec = i2
 )
 DECLARE getcriticaldtstms() = i2
 DECLARE getflexcodesbycdfmeaning() = i2
 DECLARE statbbcalcflex = i2 WITH protect, noconstant(0)
 DECLARE ntrans_flag = i2 WITH protect, constant(1)
 DECLARE nanti_flag = i2 WITH protect, constant(2)
 DECLARE nneonate_flag = i2 WITH protect, constant(3)
 DECLARE nmax_param_flag = i2 WITH protect, constant(4)
 SET flex_param_out->testing_facility_cd = - (1)
 SUBROUTINE (loadflexparams(encntrfacilitycd=f8(value)) =i2)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE prefindex = i2 WITH protect, noconstant(0)
   DECLARE testingfacilitycd = f8 WITH protect, noconstant(0.0)
   SET testingfacilitycd = bbtgetflexspectestingfacility(encntrfacilitycd)
   IF ((testingfacilitycd=- (1)))
    CALL log_message("Error getting transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((flex_param_out->testing_facility_cd=testingfacilitycd))
    RETURN(1)
   ENDIF
   SET statbbcalcflex = initrec(flex_param_out)
   SET statbbcalcflex = initrec(flex_patient_out)
   SET flex_param_out->flex_on_ind = bbtgetflexspecenableflexexpiration(testingfacilitycd)
   CASE (flex_param_out->flex_on_ind)
    OF 0:
     RETURN(0)
    OF - (1):
     CALL log_message("Error getting flex on preference.",log_level_error)
     RETURN(- (1))
   ENDCASE
   SET flex_param_out->allo_param = bbtgetflexspecxmalloexpunits(testingfacilitycd)
   IF ((flex_param_out->allo_param=- (1)))
    CALL log_message("Error getting flex param preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->auto_param = bbtgetflexspecxmautoexpunits(testingfacilitycd)
   IF ((flex_param_out->auto_param=- (1)))
    CALL log_message("Error getting auto param pref.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->anti_flex_ind = bbtgetflexspecdefclinsigantibodyparams(testingfacilitycd)
   IF ((flex_param_out->anti_flex_ind=- (1)))
    CALL log_message("Error getting anti_flex_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->anti_param = bbtgetflexspecclinsigantibodiesexpunits(testingfacilitycd)
   IF ((flex_param_out->anti_param=- (1)))
    CALL log_message("Error getting anti_param.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->max_spec_validity = bbtgetflexspecmaxspecexpunits(testingfacilitycd)
   IF ((flex_param_out->max_spec_validity=- (1)))
    CALL log_message("Error getting max spec validity preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->expiration_unit_type_mean = bbtgetflexspecexpunittypemean(testingfacilitycd)
   IF (size(flex_param_out->expiration_unit_type_mean,1) <= 0)
    CALL log_message("Error getting expiration unit type preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (bbtgetflexspectransfusionparameters(testingfacilitycd)=1)
    SET prefcount = size(flexspectransparams->params,5)
    SET statbbcalcflex = alterlist(flex_param_out->transfusion_flex_params,prefcount)
    FOR (prefindex = 1 TO prefcount)
      SET flex_param_out->transfusion_flex_params[prefindex].index = flexspectransparams->params[
      prefindex].index
      SET flex_param_out->transfusion_flex_params[prefindex].start_range = flexspectransparams->
      params[prefindex].transfusionstartrange
      SET flex_param_out->transfusion_flex_params[prefindex].end_range = flexspectransparams->params[
      prefindex].transfusionendrange
      SET flex_param_out->transfusion_flex_params[prefindex].flex_param = flexspectransparams->
      params[prefindex].specimenexpiration
      IF ((flexspectransparams->params[prefindex].transfusionendrange > flex_param_out->
      max_transfusion_end_range))
       SET flex_param_out->max_transfusion_end_range = flexspectransparams->params[prefindex].
       transfusionendrange
      ENDIF
    ENDFOR
   ELSE
    CALL log_message("Error getting transfusion flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->extend_trans_ovrd_ind = bbtgetflexspecextendtransfoverride(testingfacilitycd)
   IF ((flex_param_out->extend_trans_ovrd_ind=- (1)))
    CALL log_message("Error getting extend_trans_ovrd_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->calc_trans_drawn_dt_ind = bbtgetflexspeccalcposttransfspecsfromdawndt(
    testingfacilitycd)
   IF ((flex_param_out->calc_trans_drawn_dt_ind=- (1)))
    CALL log_message("Error getting calc_trans_drawn_dt_ind.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->neonate_age = bbtgetflexspecneonatedaysdefined(testingfacilitycd)
   IF ((flex_param_out->neonate_age=- (1)))
    CALL log_message("Error getting neonate days defined.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_param_out->testing_facility_cd = testingfacilitycd
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (loadflexpatient(personid=f8(value),encntrid=f8(value)) =i2)
   DECLARE current_dt_tm = dq8 WITH protect, constant(cnvtdatetime(curdate,0))
   DECLARE transfusioncount = i4 WITH protect, noconstant(0)
   DECLARE earliesttransfusionenddttm = dq8 WITH protect, noconstant(0.0)
   SET statbbcalcflex = initrec(flex_patient_out)
   IF ((flex_param_out->anti_flex_ind=1))
    SELECT
     IF (encntrid > 0.0)
      FROM person_antibody pa,
       transfusion_requirements tr
      PLAN (pa
       WHERE pa.encntr_id=encntrid
        AND pa.active_ind=1)
       JOIN (tr
       WHERE tr.requirement_cd=pa.antibody_cd
        AND tr.significance_ind=1)
     ELSE
      FROM person_antibody pa,
       transfusion_requirements tr
      PLAN (pa
       WHERE pa.person_id=personid
        AND pa.active_ind=1)
       JOIN (tr
       WHERE tr.requirement_cd=pa.antibody_cd
        AND tr.significance_ind=1)
     ENDIF
     INTO "nl:"
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET flex_patient_out->anti_exist_ind = 1
    ENDIF
   ENDIF
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (((2 * flex_param_out->max_transfusion_end_range) < flex_param_out->max_spec_validity))
    SET earliesttransfusionenddttm = datetimeadd(current_dt_tm,- ((flex_param_out->
     max_transfusion_end_range+ flex_param_out->max_spec_validity)))
   ELSE
    SET earliesttransfusionenddttm = datetimeadd(current_dt_tm,- ((2 * flex_param_out->
     max_transfusion_end_range)))
   ENDIF
   SELECT INTO "nl:"
    FROM transfusion t,
     product p,
     product_index pi,
     product_category pc,
     product_event pe
    PLAN (t
     WHERE t.person_id=personid
      AND t.active_ind=1)
     JOIN (p
     WHERE p.product_id=t.product_id
      AND (p.product_class_cd=flex_codes->blood_product_cd)
      AND p.active_ind=1)
     JOIN (pi
     WHERE pi.product_cd=p.product_cd
      AND pi.active_ind=1)
     JOIN (pc
     WHERE pc.product_cat_cd=pi.product_cat_cd
      AND pc.active_ind=1)
     JOIN (pe
     WHERE pe.product_id=p.product_id
      AND (pe.event_type_cd=flex_codes->transfused_state_cd)
      AND pe.event_dt_tm >= cnvtdatetime(earliesttransfusionenddttm)
      AND ((encntrid > 0.0
      AND pe.encntr_id=encntrid) OR (encntrid=0.0))
      AND pe.active_ind=1)
    ORDER BY pe.event_dt_tm DESC
    HEAD REPORT
     transfusioncount = 0
    HEAD pe.event_dt_tm
     row + 0
    DETAIL
     IF (pi.autologous_ind=0)
      IF (pc.xmatch_required_ind=1)
       transfusioncount += 1
       IF (transfusioncount > size(flex_patient_out->transfusion,5))
        statbbcalcflex = alterlist(flex_patient_out->transfusion,(transfusioncount+ 9))
       ENDIF
       flex_patient_out->transfusion[transfusioncount].transfusion_dt_tm = pe.event_dt_tm
      ENDIF
     ENDIF
    FOOT  pe.event_dt_tm
     row + 0
    FOOT REPORT
     statbbcalcflex = alterlist(flex_patient_out->transfusion,transfusioncount)
    WITH nocounter
   ;end select
   SET flex_patient_out->person_id = personid
   SET flex_patient_out->encntr_id = encntrid
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getcriticaldtstms(null)
   DECLARE criticalrange = i4 WITH protect, noconstant(0)
   DECLARE transfusionflexparamscount = i4 WITH protect, noconstant(0)
   DECLARE transfusionflexparamsindex = i4 WITH protect, noconstant(0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET transfusionflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transfusionflexparamsindex = 1 TO transfusionflexparamscount)
     IF ((flex_param_out->transfusion_flex_params[transfusionflexparamsindex].index=1))
      SET criticalrange = flex_param_out->transfusion_flex_params[transfusionflexparamsindex].
      end_range
      SET transfusionflexparamsindex = transfusionflexparamscount
     ENDIF
   ENDFOR
   SET transcount = size(flex_patient_out->transfusion,5)
   FOR (transindex = 1 TO transcount)
     IF (trim(flex_param_out->expiration_unit_type_mean)="D")
      SET flex_patient_out->transfusion[transindex].critical_dt_tm = datetimeadd(cnvtdatetime(
        cnvtdate(flex_patient_out->transfusion[transindex].transfusion_dt_tm),235959),criticalrange)
     ELSE
      SET flex_patient_out->transfusion[transindex].critical_dt_tm = datetimeadd(flex_patient_out->
       transfusion[transindex].transfusion_dt_tm,criticalrange)
     ENDIF
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE getflexcodesbycdfmeaning(null)
   DECLARE bb_inventory_states_cs = i4 WITH protect, constant(1610)
   DECLARE transfused_state_mean = c12 WITH protect, constant("7")
   DECLARE product_class_cs = i4 WITH protect, constant(1606)
   DECLARE blood_product_mean = c12 WITH protect, constant("BLOOD")
   SET statbbcalcflex = initrec(flex_codes)
   SET flex_codes->codes_loaded_ind = 0
   SET flex_codes->transfused_state_cd = uar_get_code_by("MEANING",bb_inventory_states_cs,nullterm(
     transfused_state_mean))
   IF ((flex_codes->transfused_state_cd <= 0.0))
    CALL log_message("Error getting transfused state cd.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_codes->blood_product_cd = uar_get_code_by("MEANING",product_class_cs,nullterm(
     blood_product_mean))
   IF ((flex_codes->blood_product_cd <= 0.0))
    CALL log_message("Error getting blood product cd.",log_level_error)
    RETURN(- (1))
   ENDIF
   SET flex_codes->codes_loaded_ind = 1
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexexpiration(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value),disregarddefaultind=i2(value)) =dq8)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF (loadflexparams(encntrfacilitycd) != 1)
    CALL log_message("Error loading flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (disregarddefaultind=1)
    IF ((flex_patient_out->anti_exist_ind=1))
     SET flex_param_out->flex_param = flex_param_out->anti_param
    ELSE
     SET flex_param_out->flex_param = - (1)
    ENDIF
   ELSE
    SET flex_param_out->flex_param = flex_param_out->allo_param
    IF ((flex_patient_out->anti_exist_ind=1))
     IF ((flex_param_out->anti_param < flex_param_out->flex_param))
      SET flex_param_out->flex_param = flex_param_out->anti_param
     ENDIF
    ENDIF
   ENDIF
   IF ((flex_param_out->flex_param != - (1)))
    IF (trim(flex_param_out->expiration_unit_type_mean)="D")
     SET expiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->flex_param
      )
    ELSE
     SET expiredttm = datetimeadd(drawndttm,flex_param_out->flex_param)
    ENDIF
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((((expiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm)) OR (expiredttm=
      0.0)) )
       SET expiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (((expiredttm > paramdttm) OR (expiredttm=0.0)) )
          SET expiredttm = paramdttm
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(expiredttm)
 END ;Subroutine
 SUBROUTINE (getflexmaxexpiration(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value)) =i2)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   DECLARE maxparamexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE nantiparamind = i2 WITH protect, noconstant(0)
   DECLARE ntransparamind = i2 WITH protect, noconstant(0)
   DECLARE calcflexparam = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbcalcflex = initrec(flex_max_out)
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF (loadflexparams(encntrfacilitycd) != 1)
    CALL log_message("Error loading flex params.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET calcflexparam = flex_param_out->max_spec_validity
   IF ((flex_patient_out->anti_exist_ind=1))
    IF ((flex_param_out->anti_param < calcflexparam))
     SET calcflexparam = flex_param_out->anti_param
     SET nantiparamind = 1
    ENDIF
   ENDIF
   IF (trim(flex_param_out->expiration_unit_type_mean)="D")
    SET maxparamexpiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),calcflexparam)
   ELSE
    SET maxparamexpiredttm = datetimeadd(drawndttm,calcflexparam)
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   SET transexpiredttm = maxparamexpiredttm
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((transexpiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm))
       SET transexpiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
       SET ntransparamind = 1
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (transexpiredttm > paramdttm)
          SET transexpiredttm = paramdttm
          SET ntransparamind = 1
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (ntransparamind=1)
    IF ((flex_param_out->extend_trans_ovrd_ind=0))
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(transexpiredttm)
     SET flex_max_out->max_expire_flag = ntrans_flag
    ELSE
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
     IF (nantiparamind=0)
      SET flex_max_out->max_expire_flag = nmax_param_flag
     ELSE
      SET flex_max_out->max_expire_flag = nanti_flag
     ENDIF
    ENDIF
   ELSEIF (nantiparamind=1)
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nanti_flag
   ELSE
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nmax_param_flag
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexexpirationforperson(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value),disregarddefaultind=i2(value)) =dq8)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (disregarddefaultind=1)
    IF ((flex_patient_out->anti_exist_ind=1))
     SET flex_param_out->flex_param = flex_param_out->anti_param
    ELSE
     SET flex_param_out->flex_param = - (1)
    ENDIF
   ELSE
    SET flex_param_out->flex_param = flex_param_out->allo_param
    IF ((flex_patient_out->anti_exist_ind=1))
     IF ((flex_param_out->anti_param < flex_param_out->flex_param))
      SET flex_param_out->flex_param = flex_param_out->anti_param
     ENDIF
    ENDIF
   ENDIF
   IF ((flex_param_out->flex_param != - (1)))
    IF (trim(flex_param_out->expiration_unit_type_mean)="D")
     SET expiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->flex_param
      )
    ELSE
     SET expiredttm = datetimeadd(drawndttm,flex_param_out->flex_param)
    ENDIF
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((((expiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm)) OR (expiredttm=
      0.0)) )
       SET expiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (((expiredttm > paramdttm) OR (expiredttm=0.0)) )
          SET expiredttm = paramdttm
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   RETURN(expiredttm)
 END ;Subroutine
 SUBROUTINE (getflexmaxexpirationforperson(personid=f8(value),encntrid=f8(value),drawndttm=dq8(value),
  encntrfacilitycd=f8(value)) =i2)
   DECLARE expiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE paramdttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transcount = i4 WITH protect, noconstant(0)
   DECLARE transindex = i4 WITH protect, noconstant(0)
   DECLARE transdttmdrawndttmdiff = i4 WITH protect, noconstant(0)
   DECLARE transflexparamscount = i2 WITH protect, noconstant(0)
   DECLARE transflexparamsindex = i2 WITH protect, noconstant(0)
   DECLARE recalccriticaldttmind = i2 WITH protect, noconstant(0)
   DECLARE prevtestingfaccdhold = f8 WITH protect, noconstant(0.0)
   DECLARE usecritind = i2 WITH protect, noconstant(0)
   DECLARE maxparamexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE transexpiredttm = dq8 WITH protect, noconstant(0.0)
   DECLARE nantiparamind = i2 WITH protect, noconstant(0)
   DECLARE ntransparamind = i2 WITH protect, noconstant(0)
   DECLARE calcflexparam = i4 WITH protect, noconstant(0)
   IF ((flex_codes->codes_loaded_ind != 1))
    IF (getflexcodesbycdfmeaning(null) != 1)
     CALL log_message("Error calling GetFlexCodesByCDFMeaning.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbcalcflex = initrec(flex_max_out)
   SET prevtestingfaccdhold = flex_param_out->testing_facility_cd
   IF ((prevtestingfaccdhold != flex_param_out->testing_facility_cd))
    SET recalccriticaldttmind = 1
   ENDIF
   IF ((((flex_patient_out->person_id != personid)) OR ((flex_patient_out->encntr_id != encntrid))) )
    IF (loadflexpatient(personid,encntrid) != 1)
     CALL log_message("Error loading patient info.",log_level_error)
     RETURN(- (1))
    ENDIF
    SET recalccriticaldttmind = 1
   ENDIF
   IF (recalccriticaldttmind=1)
    IF (getcriticaldtstms(null) != 1)
     CALL log_message("Error loading critical dates/times.",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET calcflexparam = flex_param_out->max_spec_validity
   IF ((flex_patient_out->anti_exist_ind=1))
    IF ((flex_param_out->anti_param < calcflexparam))
     SET calcflexparam = flex_param_out->anti_param
     SET nantiparamind = 1
    ENDIF
   ENDIF
   IF (trim(flex_param_out->expiration_unit_type_mean)="D")
    SET maxparamexpiredttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),calcflexparam)
   ELSE
    SET maxparamexpiredttm = datetimeadd(drawndttm,calcflexparam)
   ENDIF
   SET transcount = size(flex_patient_out->transfusion,5)
   SET transflexparamscount = size(flex_param_out->transfusion_flex_params,5)
   SET transexpiredttm = maxparamexpiredttm
   FOR (transindex = 1 TO transcount)
     SET usecritind = 0
     IF ((drawndttm < flex_patient_out->transfusion[transindex].transfusion_dt_tm))
      SET usecritind = 1
     ELSEIF ((drawndttm < flex_patient_out->transfusion[transindex].critical_dt_tm))
      IF ((flex_param_out->calc_trans_drawn_dt_ind=0))
       SET usecritind = 1
      ENDIF
     ENDIF
     IF (usecritind=1)
      IF ((transexpiredttm > flex_patient_out->transfusion[transindex].critical_dt_tm))
       SET transexpiredttm = flex_patient_out->transfusion[transindex].critical_dt_tm
       SET ntransparamind = 1
      ENDIF
     ELSE
      SET transdttmdrawndttmdiff = ceil(datetimediff(drawndttm,flex_patient_out->transfusion[
        transindex].transfusion_dt_tm))
      FOR (transflexparamsindex = 1 TO transflexparamscount)
        IF ((transdttmdrawndttmdiff >= flex_param_out->transfusion_flex_params[transflexparamsindex].
        start_range)
         AND (transdttmdrawndttmdiff <= flex_param_out->transfusion_flex_params[transflexparamsindex]
        .end_range))
         IF (trim(flex_param_out->expiration_unit_type_mean)="D")
          SET paramdttm = datetimeadd(cnvtdatetime(cnvtdate(drawndttm),235959),flex_param_out->
           transfusion_flex_params[transflexparamsindex].flex_param)
         ELSE
          SET paramdttm = datetimeadd(drawndttm,flex_param_out->transfusion_flex_params[
           transflexparamsindex].flex_param)
         ENDIF
         IF (transexpiredttm > paramdttm)
          SET transexpiredttm = paramdttm
          SET ntransparamind = 1
         ENDIF
         SET transflexparamsindex = transflexparamscount
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (ntransparamind=1)
    IF ((flex_param_out->extend_trans_ovrd_ind=0))
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(transexpiredttm)
     SET flex_max_out->max_expire_flag = ntrans_flag
    ELSE
     SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
     IF (nantiparamind=0)
      SET flex_max_out->max_expire_flag = nmax_param_flag
     ELSE
      SET flex_max_out->max_expire_flag = nanti_flag
     ENDIF
    ENDIF
   ELSEIF (nantiparamind=1)
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nanti_flag
   ELSE
    SET flex_max_out->max_expire_dt_tm = cnvtdatetime(maxparamexpiredttm)
    SET flex_max_out->max_expire_flag = nmax_param_flag
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getflexspecimenparams(facilityindex=i4(value),enc_facility_cd=f8(value),addreadind=i2(
   value),appkey=c10(value)) =null)
   DECLARE transparamscount = i4 WITH protect, noconstant(0)
   SET facilityinfo->facilities[facilityindex].load_flex_params = 1
   IF (addreadind=1)
    IF ((loadflexparams(enc_facility_cd)=- (1)))
     SET facilityinfo->facilities[facilityindex].load_flex_params = - (1)
     CALL log_message("Error loading flex params.",log_level_error)
    ENDIF
    SET facilityinfo->facilities[facilityindex].testing_facility_cd = flex_param_out->
    testing_facility_cd
    SET facilityinfo->facilities[facilityindex].flex_on_ind = flex_param_out->flex_on_ind
    SET facilityinfo->facilities[facilityindex].flex_param = flex_param_out->flex_param
    SET facilityinfo->facilities[facilityindex].allo_param = flex_param_out->allo_param
    SET facilityinfo->facilities[facilityindex].auto_param = flex_param_out->auto_param
    SET facilityinfo->facilities[facilityindex].anti_flex_ind = flex_param_out->anti_flex_ind
    SET facilityinfo->facilities[facilityindex].anti_param = flex_param_out->anti_param
    SET facilityinfo->facilities[facilityindex].max_spec_validity = flex_param_out->max_spec_validity
    SET facilityinfo->facilities[facilityindex].expiration_unit_type_mean = flex_param_out->
    expiration_unit_type_mean
    SET facilityinfo->facilities[facilityindex].max_transfusion_end_range = flex_param_out->
    max_transfusion_end_range
    SET facilityinfo->facilities[facilityindex].extend_trans_ovrd_ind = flex_param_out->
    extend_trans_ovrd_ind
    SET facilityinfo->facilities[facilityindex].calc_trans_drawn_dt_ind = flex_param_out->
    calc_trans_drawn_dt_ind
    SET facilityinfo->facilities[facilityindex].neonate_age = flex_param_out->neonate_age
    SET transparamscount = size(flex_param_out->transfusion_flex_params,5)
    SET stat = alterlist(facilityinfo->facilities[facilityindex].transfusion_flex_params,
     transparamscount)
    FOR (x_idx = 1 TO transparamscount)
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].index =
      flex_param_out->transfusion_flex_params[x_idx].index
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].start_range =
      flex_param_out->transfusion_flex_params[x_idx].start_range
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].end_range =
      flex_param_out->transfusion_flex_params[x_idx].end_range
      SET facilityinfo->facilities[facilityindex].transfusion_flex_params[x_idx].flex_param =
      flex_param_out->transfusion_flex_params[x_idx].flex_param
    ENDFOR
    IF (trim(appkey)="AVAILSPECS")
     SET facilityinfo->facilities[facilityindex].extend_expired_specimen =
     bbtgetflexexpiredspecimenexpirationovrd(facilityinfo->facilities[facilityindex].
      testing_facility_cd)
     SET facilityinfo->facilities[facilityindex].extend_neonate_disch_spec =
     bbtgetflexexpiredspecimenneonatedischarge(facilityinfo->facilities[facilityindex].
      testing_facility_cd)
    ENDIF
   ELSE
    SET flex_param_out->testing_facility_cd = facilityinfo->facilities[facilityindex].
    testing_facility_cd
    SET flex_param_out->flex_on_ind = facilityinfo->facilities[facilityindex].flex_on_ind
    SET flex_param_out->flex_param = facilityinfo->facilities[facilityindex].flex_param
    SET flex_param_out->allo_param = facilityinfo->facilities[facilityindex].allo_param
    SET flex_param_out->auto_param = facilityinfo->facilities[facilityindex].auto_param
    SET flex_param_out->anti_flex_ind = facilityinfo->facilities[facilityindex].anti_flex_ind
    SET flex_param_out->anti_param = facilityinfo->facilities[facilityindex].anti_param
    SET flex_param_out->max_spec_validity = facilityinfo->facilities[facilityindex].max_spec_validity
    SET flex_param_out->expiration_unit_type_mean = facilityinfo->facilities[facilityindex].
    expiration_unit_type_mean
    SET flex_param_out->max_transfusion_end_range = facilityinfo->facilities[facilityindex].
    max_transfusion_end_range
    SET flex_param_out->extend_trans_ovrd_ind = facilityinfo->facilities[facilityindex].
    extend_trans_ovrd_ind
    SET flex_param_out->calc_trans_drawn_dt_ind = facilityinfo->facilities[facilityindex].
    calc_trans_drawn_dt_ind
    SET flex_param_out->neonate_age = facilityinfo->facilities[facilityindex].neonate_age
    SET transparamscount = size(facilityinfo->facilities[facilityindex].transfusion_flex_params,5)
    SET stat = alterlist(flex_param_out->transfusion_flex_params,transparamscount)
    FOR (x_idx = 1 TO transparamscount)
      SET flex_param_out->transfusion_flex_params[x_idx].index = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].index
      SET flex_param_out->transfusion_flex_params[x_idx].start_range = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].start_range
      SET flex_param_out->transfusion_flex_params[x_idx].end_range = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].end_range
      SET flex_param_out->transfusion_flex_params[x_idx].flex_param = facilityinfo->facilities[
      facilityindex].transfusion_flex_params[x_idx].flex_param
    ENDFOR
   ENDIF
 END ;Subroutine
 SET lstat = uar_get_meaning_by_codeset(1610,nullterm("7"),1,transfused_state_cd)
 SET gen_lab_cat_type_cd = uar_get_code_by("MEANING",catalog_type_cs,nullterm(gen_lab_cat_type_mean))
 IF (gen_lab_cat_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve catalog type code with meaning of ",trim(
    gen_lab_cat_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET bb_activity_type_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(bb_activity_type_mean)
  )
 IF (bb_activity_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve activity type code with meaning of ",trim(
    bb_activity_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET ordered_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(ordered_status_mean))
 IF (ordered_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    ordered_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET inprocess_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(inprocess_status_mean))
 IF (inprocess_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    inprocess_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET completed_status_cd = uar_get_code_by("MEANING",order_status_cs,nullterm(completed_status_mean))
 IF (completed_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve order status code with meaning of ",trim(
    completed_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET inlab_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   inlab_dept_status_mean))
 IF (inlab_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    inlab_dept_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET collected_dept_status_cd = uar_get_code_by("MEANING",dept_order_status_cs,nullterm(
   collected_dept_status_mean))
 IF (collected_dept_status_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve department order status code with meaning of ",trim(
    collected_dept_status_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET flexspecenabled = bbtgetflexspecenableflexexpiration(request->facility_cd)
 IF (flexspecenabled=1
  AND (request->facility_cd > 0.0))
  SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
  IF ((stat=- (1)))
   CALL log_message("Error getting encounter facilities for transfusion facility.",log_level_error)
   CALL errorhandler("F","BbtGetEncounterLocations Failed",
    "BbtGetEncounterLocations returned a failure.")
  ENDIF
  SET exp_size = size(encounterlocations->locs,5)
  SET validatefacility = locateval(x_idx,1,exp_size,request->facility_cd,encounterlocations->locs[
   x_idx].encfacilitycd)
  IF (validatefacility=0)
   SET exp_size += 1
   SET stat = alterlist(encounterlocations->locs,exp_size)
   SET encounterlocations->locs[exp_size].encfacilitycd = request->facility_cd
  ENDIF
 ELSEIF (flexspecenabled=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET flex_allo_param = bbtgetflexspecxmalloexpunits(request->facility_cd)
 IF ((flex_allo_param=- (1)))
  CALL log_message("Error getting flex param preference.",log_level_error)
  CALL errorhandler("F","BbtGetFlexSpecXMAlloExpUnits Failed",
   "BbtGetFlexSpecXMAlloExpUnits returned a failure.")
 ENDIF
 SET flex_expiration_unit_type_mean = bbtgetflexspecexpunittypemean(request->facility_cd)
 IF (size(flex_expiration_unit_type_mean,1) <= 0)
  CALL log_message("Error getting expiration unit type preference.",log_level_error)
  CALL errorhandler("F","BbtGetFlexSpecExpUnitTypeMean Failed",
   "BbtGetFlexSpecExpUnitTypeMean returned a failure.")
 ENDIF
 IF (bbtgetflexspectransfusionparameters(request->facility_cd)=1)
  SET flex_end_range = flexspectransparams->params[1].transfusionendrange
 ELSE
  CALL log_message("Error getting transfusion flex params.",log_level_error)
  CALL errorhandler("F","BbtGetFlexSpecTransfusionParameters Failed",
   "BbtGetFlexSpecTransfusionParameters returned a failur")
 ENDIF
 SET anti_flex_ind = bbtgetflexspecdefclinsigantibodyparams(request->facility_cd)
 IF ((anti_flex_ind=- (1)))
  CALL log_message("Error getting anti_flex_ind.",log_level_error)
  CALL errorhandler("F","BbtGetFlexSpecDefClinSigAntibodyParams Failed",
   "BbtGetFlexSpecDefClinSigAntibodyParams returned a failure.")
 ENDIF
 SET flex_anti_param = bbtgetflexspecclinsigantibodiesexpunits(request->facility_cd)
 IF ((flex_anti_param=- (1)))
  CALL log_message("Error getting flex param preference.",log_level_error)
  CALL errorhandler("F","BbtGetFlexSpecClinSigAntibodiesExpUnits Failed",
   "BbtGetFlexSpecClinSigAntibodiesExpUnits returned a failure.")
 ENDIF
 SELECT INTO "nl:"
  FROM product_event pe,
   product p,
   blood_product b,
   person pn,
   product_index pi,
   product_category pc,
   bb_spec_expire_ovrd be,
   container c,
   order_container_r ocr,
   orders o,
   encounter e,
   accession_order_r aor
  PLAN (pe
   WHERE pe.event_type_cd=transfused_state_cd
    AND pe.active_ind=1
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   JOIN (p
   WHERE p.product_id=pe.product_id)
   JOIN (b
   WHERE b.product_id=p.product_id)
   JOIN (pn
   WHERE pn.person_id=pe.person_id)
   JOIN (pi
   WHERE pi.product_cd=p.product_cd
    AND pi.active_ind=1
    AND pi.autologous_ind=0)
   JOIN (pc
   WHERE pc.product_cat_cd=pi.product_cat_cd
    AND pc.active_ind=1
    AND pc.xmatch_required_ind=1)
   JOIN (be
   WHERE be.person_id=pe.person_id
    AND be.new_spec_expire_dt_tm > pe.event_dt_tm
    AND be.active_ind=1)
   JOIN (c
   WHERE c.specimen_id=be.specimen_id
    AND c.drawn_dt_tm < pe.event_dt_tm)
   JOIN (ocr
   WHERE ocr.container_id=c.container_id)
   JOIN (o
   WHERE o.order_id=ocr.order_id
    AND ((o.catalog_type_cd+ 0.0)=gen_lab_cat_type_cd)
    AND ((o.activity_type_cd+ 0.0)=bb_activity_type_cd)
    AND ((o.order_status_cd IN (inprocess_status_cd, completed_status_cd)) OR (o.order_status_cd=
   ordered_status_cd
    AND o.dept_status_cd IN (inlab_dept_status_cd, collected_dept_status_cd))) )
   JOIN (e
   WHERE e.encntr_id=o.encntr_id)
   JOIN (aor
   WHERE aor.order_id=o.order_id
    AND aor.primary_flag=0)
  ORDER BY e.loc_facility_cd, pn.person_id, p.product_id,
   c.specimen_id
  HEAD REPORT
   patientcnt = 0, productcnt = 0
  HEAD e.loc_facility_cd
   validencntpos = 0, validencntind = 0, flexspecenabledforencnt = 0
   IF ((request->facility_cd > 0.0))
    validencntpos = locateval(x_idx,1,exp_size,e.loc_facility_cd,encounterlocations->locs[x_idx].
     encfacilitycd)
   ENDIF
   IF (((validencntpos > 0) OR ((request->facility_cd=0.0))) )
    validencntind = 1
   ENDIF
  HEAD pn.person_id
   personexitspos = 0, personexitspos = locateval(x_idx,1,size(flextransprods->patienttrlist,5),pn
    .person_id,flextransprods->patienttrlist[x_idx].person_id)
   IF (personexitspos=0
    AND validencntind=1)
    patientcnt += 1
    IF (patientcnt > size(flextransprods->patienttrlist,5))
     lstat = alterlist(flextransprods->patienttrlist,(patientcnt+ 9))
    ENDIF
    flextransprods->patienttrlist[patientcnt].person_name = pn.name_full_formatted, flextransprods->
    patienttrlist[patientcnt].person_id = pe.person_id, spectranscnt = 0,
    productcnt = 0, personexitspos = patientcnt
   ENDIF
  HEAD p.product_id
   IF (validencntind=1)
    productcnt += 1
    IF (productcnt > size(flextransprods->patienttrlist[personexitspos].productlist,5))
     lstat = alterlist(flextransprods->patienttrlist[personexitspos].productlist,(productcnt+ 9))
    ENDIF
    flextransprods->patienttrlist[personexitspos].productlist[productcnt].transfused_product_id = p
    .product_id, flextransprods->patienttrlist[personexitspos].productlist[productcnt].product_nbr =
    build(b.supplier_prefix,p.product_nbr," ",p.product_sub_nbr), flextransprods->patienttrlist[
    personexitspos].productlist[productcnt].product_type_cd = p.product_cd,
    flextransprods->patienttrlist[personexitspos].productlist[productcnt].product_type_disp =
    uar_get_code_display(p.product_cd), flextransprods->patienttrlist[personexitspos].productlist[
    productcnt].transfused_dt_tm = pe.event_dt_tm
   ENDIF
  HEAD c.specimen_id
   IF (validencntind=1)
    pos = locateval(x_idx,1,spectranscnt,c.specimen_id,flextransprods->patienttrlist[personexitspos].
     spectranslist[x_idx].specimen_id)
    IF (uar_get_code_meaning(be.override_reason_cd) != neonate_ovrd_cdf_meaning
     AND pos=0)
     spectranscnt += 1
     IF (spectranscnt > size(flextransprods->patienttrlist[personexitspos].spectranslist,5))
      lstat = alterlist(flextransprods->patienttrlist[personexitspos].spectranslist,(spectranscnt+ 9)
       )
     ENDIF
     flextransprods->patienttrlist[personexitspos].spectranslist[spectranscnt].specimen_id = c
     .specimen_id, flextransprods->patienttrlist[personexitspos].spectranslist[spectranscnt].
     accession = cnvtacc(aor.accession), flextransprods->patienttrlist[personexitspos].spectranslist[
     spectranscnt].drawn_dt_tm = c.drawn_dt_tm,
     flextransprods->patienttrlist[personexitspos].spectranslist[spectranscnt].cur_exp_dt_tm = be
     .new_spec_expire_dt_tm
     IF (flex_expiration_unit_type_mean="D")
      flextransprods->patienttrlist[personexitspos].spectranslist[spectranscnt].calc_exp_dt_tm =
      datetimeadd(cnvtdatetime(cnvtdate(flextransprods->patienttrlist[personexitspos].productlist[
         productcnt].transfused_dt_tm),235959),flex_end_range)
     ELSE
      flextransprods->patienttrlist[personexitspos].spectranslist[spectranscnt].calc_exp_dt_tm =
      datetimeadd(flextransprods->patienttrlist[personexitspos].productlist[productcnt].
       transfused_dt_tm,flex_end_range)
     ENDIF
    ELSEIF (pos != 0)
     IF (flex_expiration_unit_type_mean="D")
      temp_cal_exp_dt_tm = datetimeadd(cnvtdatetime(cnvtdate(flextransprods->patienttrlist[
         personexitspos].productlist[productcnt].transfused_dt_tm),235959),flex_end_range)
     ELSE
      temp_cal_exp_dt_tm = datetimeadd(flextransprods->patienttrlist[personexitspos].productlist[
       productcnt].transfused_dt_tm,flex_end_range)
     ENDIF
     IF ((temp_cal_exp_dt_tm <= flextransprods->patienttrlist[personexitspos].spectranslist[pos].
     calc_exp_dt_tm))
      flextransprods->patienttrlist[personexitspos].spectranslist[pos].calc_exp_dt_tm =
      temp_cal_exp_dt_tm
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  c.specimen_id
   IF (patientcnt > 0)
    lstat = alterlist(flextransprods->patienttrlist[patientcnt].spectranslist,spectranscnt)
   ENDIF
  FOOT  p.product_id
   IF (patientcnt > 0)
    lstat = alterlist(flextransprods->patienttrlist[patientcnt].productlist,productcnt)
   ENDIF
  FOOT  pn.person_id
   row + 0
  FOOT  e.loc_facility_cd
   row + 0
  FOOT REPORT
   lstat = alterlist(flextransprods->patienttrlist,patientcnt)
  WITH nocounter
 ;end select
 IF (anti_flex_ind > 0)
  SELECT INTO "nl:"
   FROM person_antibody pa,
    transfusion_requirements tr,
    person pn,
    bb_spec_expire_ovrd be,
    container c,
    order_container_r ocr,
    orders o,
    encounter e,
    accession_order_r aor
   PLAN (pa
    WHERE pa.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
     AND pa.active_ind=1)
    JOIN (tr
    WHERE tr.requirement_cd=pa.antibody_cd
     AND tr.significance_ind=1)
    JOIN (pn
    WHERE pn.person_id=pa.person_id)
    JOIN (be
    WHERE be.person_id=pa.person_id
     AND be.new_spec_expire_dt_tm > pa.updt_dt_tm
     AND be.active_ind=1)
    JOIN (c
    WHERE c.specimen_id=be.specimen_id
     AND c.drawn_dt_tm < pa.updt_dt_tm)
    JOIN (ocr
    WHERE ocr.container_id=c.container_id)
    JOIN (o
    WHERE o.order_id=ocr.order_id
     AND ((o.catalog_type_cd+ 0.0)=gen_lab_cat_type_cd)
     AND ((o.activity_type_cd+ 0.0)=bb_activity_type_cd)
     AND ((o.order_status_cd IN (inprocess_status_cd, completed_status_cd)) OR (o.order_status_cd=
    ordered_status_cd
     AND o.dept_status_cd IN (inlab_dept_status_cd, collected_dept_status_cd))) )
    JOIN (e
    WHERE e.encntr_id=o.encntr_id)
    JOIN (aor
    WHERE aor.order_id=o.order_id
     AND aor.primary_flag=0)
   ORDER BY e.loc_facility_cd, pn.person_id, pa.antibody_cd,
    c.specimen_id
   HEAD REPORT
    patientabcnt = 0
   HEAD e.loc_facility_cd
    validencntpos = 0, validencntind = 0, flexspecenabledforencnt = 0
    IF ((request->facility_cd > 0.0))
     validencntpos = locateval(x_idx,1,exp_size,e.loc_facility_cd,encounterlocations->locs[x_idx].
      encfacilitycd)
    ENDIF
    IF (((validencntpos > 0) OR ((request->facility_cd=0.0))) )
     validencntind = 1
    ENDIF
   HEAD pn.person_id
    personexitspos = 0, personexitspos = locateval(x_idx,1,size(flexabprods->patientablist,5),pn
     .person_id,flexabprods->patientablist[x_idx].person_id)
    IF (personexitspos=0
     AND validencntind=1)
     patientabcnt += 1
     IF (patientabcnt > size(flexabprods->patientablist,5))
      lstat = alterlist(flexabprods->patientablist,(patientabcnt+ 9))
     ENDIF
     flexabprods->patientablist[patientabcnt].person_name = pn.name_full_formatted, flexabprods->
     patientablist[patientabcnt].person_id = pa.person_id, specabcnt = 0,
     productabcnt = 0, personexitspos = patientabcnt
    ENDIF
   HEAD pa.antibody_cd
    IF (validencntind=1)
     productabcnt += 1
     IF (productabcnt > size(flexabprods->patientablist[personexitspos].antibodylist,5))
      lstat = alterlist(flexabprods->patientablist[personexitspos].antibodylist,(productabcnt+ 19))
     ENDIF
     flexabprods->patientablist[personexitspos].antibodylist[productabcnt].antibody_cd = pa
     .antibody_cd, flexabprods->patientablist[personexitspos].antibodylist[productabcnt].
     antibody_disp = uar_get_code_display(pa.antibody_cd), flexabprods->patientablist[personexitspos]
     .antibodylist[productabcnt].ab_identify_dt_tm = pa.updt_dt_tm
    ENDIF
   HEAD c.specimen_id
    IF (validencntind=1)
     pos = locateval(x_idx,1,specabcnt,c.specimen_id,flexabprods->patientablist[personexitspos].
      specablist[x_idx].specimen_id)
     IF (uar_get_code_meaning(be.override_reason_cd) != neonate_ovrd_cdf_meaning
      AND pos=0)
      specabcnt += 1
      IF (specabcnt > size(flexabprods->patientablist[personexitspos].specablist,5))
       lstat = alterlist(flexabprods->patientablist[personexitspos].specablist,(specabcnt+ 5))
      ENDIF
      flexabprods->patientablist[personexitspos].specablist[specabcnt].specimen_id = c.specimen_id,
      flexabprods->patientablist[personexitspos].specablist[specabcnt].accession = cnvtacc(aor
       .accession), flexabprods->patientablist[personexitspos].specablist[specabcnt].drawn_dt_tm = c
      .drawn_dt_tm,
      flexabprods->patientablist[personexitspos].specablist[specabcnt].cur_exp_dt_tm = be
      .new_spec_expire_dt_tm
      IF (flex_expiration_unit_type_mean="D")
       flexabprods->patientablist[personexitspos].specablist[specabcnt].calc_exp_dt_tm = datetimeadd(
        cnvtdatetime(cnvtdate(c.drawn_dt_tm),235959),flex_anti_param)
      ELSE
       flexabprods->patientablist[personexitspos].specablist[specabcnt].calc_exp_dt_tm = datetimeadd(
        c.drawn_dt_tm,flex_anti_param)
      ENDIF
     ENDIF
    ENDIF
   DETAIL
    row + 0
   FOOT  c.specimen_id
    IF (patientabcnt > 0)
     lstat = alterlist(flexabprods->patientablist[patientabcnt].specablist,specabcnt)
    ENDIF
   FOOT  pa.person_antibody_id
    IF (patientabcnt > 0)
     lstat = alterlist(flexabprods->patientablist[patientabcnt].antibodylist,productabcnt)
    ENDIF
   FOOT  pn.person_id
    row + 0
   FOOT  e.loc_facility_cd
    row + 0
   FOOT REPORT
    lstat = alterlist(flexabprods->patientablist,patientabcnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM product_event pe,
   crossmatch cr,
   product p,
   blood_product b,
   product_index pi,
   product_category pc,
   person pn,
   encounter e,
   orders o,
   order_container_r ocr,
   container c,
   accession_order_r aor
  PLAN (cr
   WHERE cr.crossmatch_exp_dt_tm >= cnvtdatetime(sysdate)
    AND cr.active_ind=1)
   JOIN (pe
   WHERE pe.product_event_id=cr.product_event_id)
   JOIN (p
   WHERE p.product_id=pe.product_id)
   JOIN (b
   WHERE b.product_id=p.product_id)
   JOIN (pn
   WHERE pn.person_id=pe.person_id)
   JOIN (pi
   WHERE pi.product_cd=p.product_cd
    AND pi.active_ind=1
    AND pi.autologous_ind=0)
   JOIN (pc
   WHERE pc.product_cat_cd=pi.product_cat_cd
    AND pc.active_ind=1
    AND pc.xmatch_required_ind=1)
   JOIN (e
   WHERE e.encntr_id=pe.encntr_id)
   JOIN (o
   WHERE o.order_id=pe.order_id)
   JOIN (ocr
   WHERE ocr.order_id=pe.order_id)
   JOIN (c
   WHERE c.container_id=ocr.container_id)
   JOIN (aor
   WHERE aor.order_id=o.order_id
    AND aor.primary_flag=0)
  ORDER BY e.loc_facility_cd, pn.person_id, p.product_id,
   c.specimen_id
  HEAD REPORT
   patientxmcnt = 0
  HEAD e.loc_facility_cd
   validencntpos = 0, validencntind = 0, flexspecenabledforencnt = 0.0
   IF ((request->facility_cd > 0.0))
    validencntpos = locateval(x_idx,1,exp_size,e.loc_facility_cd,encounterlocations->locs[x_idx].
     encfacilitycd)
   ENDIF
   IF (((validencntpos > 0) OR ((request->facility_cd=0.0))) )
    validencntind = 1
   ENDIF
  HEAD pn.person_id
   personexitspos = 0, personexitspos = locateval(x_idx,1,size(flexxmprods->patientxmlist,5),pn
    .person_id,flexxmprods->patientxmlist[x_idx].person_id)
   IF (personexitspos=0
    AND validencntind=1)
    patientxmcnt += 1
    IF (patientxmcnt > size(flexxmprods->patientxmlist,5))
     lstat = alterlist(flexxmprods->patientxmlist,(patientxmcnt+ 9))
    ENDIF
    flexxmprods->patientxmlist[patientxmcnt].person_name = pn.name_full_formatted, flexxmprods->
    patientxmlist[patientxmcnt].person_id = pe.person_id, specxmcnt = 0,
    productxmcnt = 0, personexitspos = patientxmcnt
   ENDIF
  HEAD p.product_id
   IF (validencntind=1)
    productxmcnt += 1
    IF (productxmcnt > size(flexxmprods->patientxmlist[personexitspos].xmlist,5))
     lstat = alterlist(flexxmprods->patientxmlist[personexitspos].xmlist,(productxmcnt+ 9))
    ENDIF
    flexxmprods->patientxmlist[personexitspos].xmlist[productxmcnt].crossmatch_product_id = p
    .product_id, flexxmprods->patientxmlist[personexitspos].xmlist[productxmcnt].product_nbr = build(
     b.supplier_prefix,p.product_nbr," ",p.product_sub_nbr), flexxmprods->patientxmlist[
    personexitspos].xmlist[productxmcnt].product_type_cd = p.product_cd,
    flexxmprods->patientxmlist[personexitspos].xmlist[productxmcnt].product_type_disp =
    uar_get_code_display(p.product_cd), flexxmprods->patientxmlist[personexitspos].xmlist[
    productxmcnt].crossmatched_dt_tm = pe.event_dt_tm
   ENDIF
  HEAD c.specimen_id
   IF (validencntind=1)
    pos = locateval(x_idx,1,specxmcnt,c.specimen_id,flexxmprods->patientxmlist[personexitspos].
     specxmlist[x_idx].specimen_id)
    IF (pos=0)
     specxmcnt += 1
     IF (specxmcnt > size(flexxmprods->patientxmlist[personexitspos].specxmlist,5))
      lstat = alterlist(flexxmprods->patientxmlist[personexitspos].specxmlist,(specxmcnt+ 5))
     ENDIF
     flexxmprods->patientxmlist[personexitspos].specxmlist[specxmcnt].specimen_id = c.specimen_id,
     flexxmprods->patientxmlist[personexitspos].specxmlist[specxmcnt].accession = cnvtacc(aor
      .accession)
     IF (uar_get_code_meaning(cr.reinstate_reason_cd)=null)
      flexxmprods->patientxmlist[personexitspos].specxmlist[specxmcnt].reinstate_reason_disp =
      uar_get_code_display(cr.reinstate_reason_cd)
     ENDIF
     flexxmprods->patientxmlist[personexitspos].specxmlist[specxmcnt].cur_exp_dt_tm = cr
     .crossmatch_exp_dt_tm, flexxmprods->patientxmlist[personexitspos].specxmlist[specxmcnt].
     drawn_dt_tm = c.drawn_dt_tm
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  c.specimen_id
   IF (patientxmcnt > 0)
    lstat = alterlist(flexxmprods->patientxmlist[patientxmcnt].specxmlist,specxmcnt)
   ENDIF
  FOOT  p.product_id
   IF (patientxmcnt > 0)
    lstat = alterlist(flexxmprods->patientxmlist[patientxmcnt].xmlist,productxmcnt)
   ENDIF
  FOOT  pn.person_id
   row + 0
  FOOT  e.loc_facility_cd
   row + 0
  FOOT REPORT
   lstat = alterlist(flexxmprods->patientxmlist,patientxmcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(size(flexxmprods->patientxmlist,5))),
   (dummyt d2  WITH seq = 1),
   bb_spec_expire_ovrd be
  PLAN (d1
   WHERE maxrec(d2,size(flexxmprods->patientxmlist[d1.seq].specxmlist,5)))
   JOIN (d2)
   JOIN (be
   WHERE (be.specimen_id=flexxmprods->patientxmlist[d1.seq].specxmlist[d2.seq].specimen_id)
    AND be.active_ind=1)
  ORDER BY d1.seq, d2.seq
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   row + 0
  DETAIL
   flexxmprods->patientxmlist[d1.seq].specxmlist[d2.seq].new_spec_expire_dt_tm = be
   .new_spec_expire_dt_tm, flexxmprods->patientxmlist[d1.seq].specxmlist[d2.seq].override_id = be
   .bb_spec_expire_ovrd_id, flexxmprods->patientxmlist[d1.seq].specxmlist[d2.seq].override_cd = be
   .override_reason_cd
  WITH nocounter
 ;end select
 FOR (i_idx = 1 TO size(flexxmprods->patientxmlist,5))
   FOR (j_idx = 1 TO size(flexxmprods->patientxmlist[i_idx].specxmlist,5))
    IF ((flexxmprods->patientxmlist[i_idx].specxmlist[j_idx].override_id > 0.0))
     SET expdttm = flexxmprods->patientxmlist[i_idx].specxmlist[j_idx].new_spec_expire_dt_tm
    ELSE
     SET expdttm = null
     SET expdttm = getflexexpiration(flexxmprods->patientxmlist[i_idx].person_id,0.0,flexxmprods->
      patientxmlist[i_idx].specxmlist[j_idx].drawn_dt_tm,request->facility_cd,0)
     IF ((expdttm=- (1)))
      CALL errorhandler("F","GetFlexExpiration Failed","GetFlexExpiration returned a failure.")
     ENDIF
    ENDIF
    SET flexxmprods->patientxmlist[i_idx].specxmlist[j_idx].calc_exp_dt_tm = expdttm
   ENDFOR
 ENDFOR
 IF ((request->facility_cd > 0.0))
  SET facility_disp = uar_get_code_display(request->facility_cd)
 ELSE
  SET facility_disp = captions->all
 ENDIF
 EXECUTE cpm_create_file_name_logical "bb_rpt_exp_ntupd", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   line = fillstring(125,"_"), specprodtvalue = 0, specprodavalue = 0,
   specprodxvalue = 0, pattvalue = 1, patavalue = 1,
   patxvalue = 1, printdatafoundind = 0, pattcnt = size(flextransprods->patienttrlist,5),
   patacnt = size(flexabprods->patientablist,5), patxcnt = size(flexxmprods->patientxmlist,5)
  HEAD PAGE
   col 104, captions->rpt_time, col 118,
   curtime"@TIMENOSECONDS;;M",
   CALL center(captions->rpt_title,1,132), row + 1,
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
   save_row1 = row, row save_row1, row + 1,
   col 31, captions->beg_date, begin_dt_tm = cnvtdatetime(request->beg_dt_tm),
   col 47, begin_dt_tm"@DATECONDENSED;;d", col 55,
   begin_dt_tm"@TIMENOSECONDS;;M", col 71, captions->end_date,
   end_dt_time = cnvtdatetime(request->end_dt_tm), col 84, end_dt_time"@DATECONDENSED;;d",
   col 92, end_dt_time"@TIMENOSECONDS;;M", row + 2,
   col 1, captions->facility, col 11,
   facility_disp, nextpageind = 1, nextpageabind = 1,
   nextpagexmind = 1, save_row2 = 0, save_row3 = 0,
   save_row4 = 0
  DETAIL
   FOR (pa_idx = pattvalue TO pattcnt)
     save_row2 = row, patprodtcnt = size(flextransprods->patienttrlist[pa_idx].productlist,5),
     patspectcnt = size(flextransprods->patienttrlist[pa_idx].spectranslist,5)
     IF (patprodtcnt >= patspectcnt)
      stat = alterlist(flextransprods->patienttrlist[pa_idx].spectranslist,patprodtcnt), specprodtcnt
       = patprodtcnt
     ELSE
      stat = alterlist(flextransprods->patienttrlist[pa_idx].productlist,patspectcnt), specprodtcnt
       = patspectcnt
     ENDIF
     printdatafoundtrind = 0
     FOR (s_idx = (specprodtvalue+ 1) TO specprodtcnt)
       IF ((flextransprods->patienttrlist[pa_idx].spectranslist[s_idx].cur_exp_dt_tm > flextransprods
       ->patienttrlist[pa_idx].spectranslist[s_idx].calc_exp_dt_tm))
        printdatafoundtrind = 1, printdatafoundind = 1, s_idx = specprodtcnt
       ENDIF
     ENDFOR
     IF (printdatafoundtrind=1)
      FOR (s_idx = (specprodtvalue+ 1) TO specprodtcnt)
        IF (nextpageind=1)
         nextpageind = 0, row + 1, col 1,
         captions->rpt_spec_title, row + 1, col 91,
         captions->incorrect_exp, col 113, captions->correct_exp,
         col 1, captions->person_name, col 24,
         captions->product_number, col 47, captions->transfused,
         col 70, captions->specimen_drawn, row + 1,
         col 1, captions->accession, col 24,
         captions->product_type, col 47, captions->date_time,
         col 70, captions->date_time, col 91,
         captions->date_time, col 113, captions->date_time,
         row + 1, col 1, line
        ENDIF
        IF ((flextransprods->patienttrlist[pa_idx].pattprintind=0))
         flextransprods->patienttrlist[pa_idx].pattprintind = 1, row + 1, person_name = substring(1,
          20,flextransprods->patienttrlist[pa_idx].person_name),
         col 1, person_name
        ENDIF
        IF (trim(flextransprods->patienttrlist[pa_idx].productlist[s_idx].product_nbr) > ""
         AND s_idx != 1)
         row + 1
        ENDIF
        IF ((flextransprods->patienttrlist[pa_idx].productlist[s_idx].transfused_product_id > 0))
         col 24, flextransprods->patienttrlist[pa_idx].productlist[s_idx].product_nbr
        ENDIF
        row + 1, drawndate = format(flextransprods->patienttrlist[pa_idx].spectranslist[s_idx].
         drawn_dt_tm,cclfmt->mediumdate), drawntime = format(flextransprods->patienttrlist[pa_idx].
         spectranslist[s_idx].drawn_dt_tm,cclfmt->timenoseconds),
        calcexpiredt = format(flextransprods->patienttrlist[pa_idx].spectranslist[s_idx].
         calc_exp_dt_tm,cclfmt->mediumdate), calcexpiretm = format(flextransprods->patienttrlist[
         pa_idx].spectranslist[s_idx].calc_exp_dt_tm,cclfmt->timenoseconds), curexpiredt = format(
         flextransprods->patienttrlist[pa_idx].spectranslist[s_idx].cur_exp_dt_tm,cclfmt->mediumdate),
        curexpiretm = format(flextransprods->patienttrlist[pa_idx].spectranslist[s_idx].cur_exp_dt_tm,
         cclfmt->timenoseconds), transfuseddt = format(flextransprods->patienttrlist[pa_idx].
         productlist[s_idx].transfused_dt_tm,cclfmt->mediumdate), transfusedtm = format(
         flextransprods->patienttrlist[pa_idx].productlist[s_idx].transfused_dt_tm,cclfmt->
         timenoseconds)
        IF ((flextransprods->patienttrlist[pa_idx].spectranslist[s_idx].specimen_id > 0))
         col 70, drawndate, col 81,
         drawntime, col 91, curexpiredt,
         col 103, curexpiretm, col 113,
         calcexpiredt, col 124, calcexpiretm,
         col 1, flextransprods->patienttrlist[pa_idx].spectranslist[s_idx].accession
        ENDIF
        IF ((flextransprods->patienttrlist[pa_idx].productlist[s_idx].transfused_product_id > 0))
         col 47, transfuseddt, col 58,
         transfusedtm, prod_type_disp = substring(1,20,flextransprods->patienttrlist[pa_idx].
          productlist[s_idx].product_type_disp), col 24,
         prod_type_disp
        ENDIF
        IF (row >= 52)
         pattvalue = pa_idx
         IF (s_idx < specprodtcnt)
          specprodtvalue = s_idx
         ELSE
          specprodtvalue = 0
         ENDIF
         BREAK
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FOR (a_idx = patavalue TO patacnt)
     save_row3 = row, patprodacnt = size(flexabprods->patientablist[a_idx].antibodylist,5),
     patspecacnt = size(flexabprods->patientablist[a_idx].specablist,5)
     IF (patprodacnt >= patspecacnt)
      stat = alterlist(flexabprods->patientablist[a_idx].specablist,patprodacnt), specprodacnt =
      patprodacnt
     ELSE
      stat = alterlist(flexabprods->patientablist[a_idx].antibodylist,patspecacnt), specprodacnt =
      patspecacnt
     ENDIF
     printdatafoundabind = 0
     FOR (b_idx = (specprodavalue+ 1) TO specprodacnt)
       IF ((flexabprods->patientablist[a_idx].specablist[b_idx].cur_exp_dt_tm > flexabprods->
       patientablist[a_idx].specablist[b_idx].calc_exp_dt_tm))
        printdatafoundabind = 1, printdatafoundind = 1, b_idx = specprodacnt
       ENDIF
     ENDFOR
     IF (printdatafoundabind=1)
      FOR (b_idx = (specprodavalue+ 1) TO specprodacnt)
        IF (nextpageind=1)
         nextpageind = 0, row + 2, col 1,
         captions->rpt_spec_title
        ENDIF
        IF (nextpageabind=1)
         nextpageabind = 0, row + 2, col 91,
         captions->incorrect_exp, col 113, captions->correct_exp,
         col 1, captions->person_name, col 24,
         captions->antibody, col 47, captions->identified,
         col 70, captions->specimen_drawn, row + 1,
         col 1, captions->accession, col 47,
         captions->date_time, col 70, captions->date_time,
         col 91, captions->date_time, col 113,
         captions->date_time, row + 1, col 1,
         line
        ENDIF
        row + 1
        IF ((flexabprods->patientablist[a_idx].patabprintind=0))
         flexabprods->patientablist[a_idx].patabprintind = 1, person_name = substring(1,20,
          flexabprods->patientablist[a_idx].person_name), col 1,
         person_name, row + 1
        ENDIF
        antibody_disp = substring(1,20,flexabprods->patientablist[a_idx].antibodylist[b_idx].
         antibody_disp), col 24, antibody_disp,
        drawndate = format(flexabprods->patientablist[a_idx].specablist[b_idx].drawn_dt_tm,cclfmt->
         mediumdate), drawntime = format(flexabprods->patientablist[a_idx].specablist[b_idx].
         drawn_dt_tm,cclfmt->timenoseconds), calcexpiredt = format(flexabprods->patientablist[a_idx].
         specablist[b_idx].calc_exp_dt_tm,cclfmt->mediumdate),
        calcexpiretm = format(flexabprods->patientablist[a_idx].specablist[b_idx].calc_exp_dt_tm,
         cclfmt->timenoseconds), curexpiredt = format(flexabprods->patientablist[a_idx].specablist[
         b_idx].cur_exp_dt_tm,cclfmt->mediumdate), curexpiretm = format(flexabprods->patientablist[
         a_idx].specablist[b_idx].cur_exp_dt_tm,cclfmt->timenoseconds),
        identifieddt = format(flexabprods->patientablist[a_idx].antibodylist[b_idx].ab_identify_dt_tm,
         cclfmt->mediumdate), identifiedtm = format(flexabprods->patientablist[a_idx].antibodylist[
         b_idx].ab_identify_dt_tm,cclfmt->timenoseconds)
        IF ((flexabprods->patientablist[a_idx].specablist[b_idx].specimen_id > 0))
         col 70, drawndate, col 81,
         drawntime, col 113, calcexpiredt,
         col 124, calcexpiretm, col 91,
         curexpiredt, col 103, curexpiretm,
         col 1, flexabprods->patientablist[a_idx].specablist[b_idx].accession
        ENDIF
        IF ((flexabprods->patientablist[a_idx].antibodylist[b_idx].ab_identify_dt_tm > 0))
         col 47, identifieddt, col 58,
         identifiedtm
        ENDIF
        IF (row >= 52)
         patavalue = a_idx
         IF (b_idx < specprodacnt)
          specprodavalue = b_idx
         ELSE
          specprodavalue = 0
         ENDIF
         BREAK
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   FOR (c_idx = patxvalue TO patxcnt)
     save_row4 = row, patprodxcnt = size(flexxmprods->patientxmlist[c_idx].xmlist,5), patspecxcnt =
     size(flexxmprods->patientxmlist[c_idx].specxmlist,5)
     IF (patprodxcnt >= patspecxcnt)
      stat = alterlist(flexxmprods->patientxmlist[c_idx].specxmlist,patprodxcnt), specprodxcnt =
      patprodxcnt
     ELSE
      stat = alterlist(flexxmprods->patientxmlist[c_idx].xmlist,patspecxcnt), specprodxcnt =
      patspecxcnt
     ENDIF
     printdatafoundxmind = 0
     FOR (d_idx = (specprodxvalue+ 1) TO specprodxcnt)
       IF ((flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].cur_exp_dt_tm > flexxmprods->
       patientxmlist[c_idx].specxmlist[d_idx].calc_exp_dt_tm))
        printdatafoundxmind = 1, printdatafoundind = 1, d_idx = specprodxcnt
       ENDIF
     ENDFOR
     IF (printdatafoundxmind=1)
      FOR (d_idx = (specprodxvalue+ 1) TO specprodxcnt)
        IF (nextpagexmind=1)
         nextpagexmind = 0, row + 2, col 1,
         captions->rpt_xm_title, row + 1, col 1,
         captions->person_name, col 24, captions->product_number,
         col 47, captions->reinstate_reason, col 68,
         captions->specimen_drawn, col 91, captions->incorrect_exp,
         col 113, captions->correct_exp, row + 1,
         col 1, captions->accession, col 24,
         captions->product_type, col 47, captions->modified_reason,
         col 68, captions->date_time, col 91,
         captions->date_time, col 113, captions->date_time,
         row + 1, col 1, line
        ENDIF
        IF ((flexxmprods->patientxmlist[c_idx].patxmprintind=0))
         flexxmprods->patientxmlist[c_idx].patxmprintind = 1, row + 1, person_name = substring(1,20,
          flexxmprods->patientxmlist[c_idx].person_name),
         col 1, person_name
        ENDIF
        IF (trim(flexxmprods->patientxmlist[c_idx].xmlist[d_idx].product_nbr) > ""
         AND d_idx != 1)
         row + 1
        ENDIF
        IF ((flexxmprods->patientxmlist[c_idx].xmlist[d_idx].crossmatch_product_id > 0))
         col 24, flexxmprods->patientxmlist[c_idx].xmlist[d_idx].product_nbr
        ENDIF
        row + 1, drawndate = format(flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].drawn_dt_tm,
         cclfmt->mediumdate), drawntime = format(flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].
         drawn_dt_tm,cclfmt->timenoseconds),
        calcexpiredt = format(flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].calc_exp_dt_tm,
         cclfmt->mediumdate), calcexpiretm = format(flexxmprods->patientxmlist[c_idx].specxmlist[
         d_idx].calc_exp_dt_tm,cclfmt->timenoseconds), curexpiredt = format(flexxmprods->
         patientxmlist[c_idx].specxmlist[d_idx].cur_exp_dt_tm,cclfmt->mediumdate),
        curexpiretm = format(flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].cur_exp_dt_tm,cclfmt
         ->timenoseconds)
        IF ((flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].specimen_id > 0))
         col 68, drawndate, col 80,
         drawntime, col 113, calcexpiredt,
         col 124, calcexpiretm, col 91,
         curexpiredt, col 103, curexpiretm,
         col 1, flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].accession, reason = substring(1,
          20,flexxmprods->patientxmlist[c_idx].specxmlist[d_idx].reinstate_reason_disp),
         col 47, reason
        ENDIF
        IF ((flexxmprods->patientxmlist[c_idx].xmlist[d_idx].crossmatch_product_id > 0))
         prod_type_disp = substring(1,20,flexxmprods->patientxmlist[c_idx].xmlist[d_idx].
          product_type_disp), col 24, prod_type_disp
        ENDIF
        IF (row >= 52)
         patxvalue = c_idx
         IF (d_idx < specprodxcnt)
          specprodxvalue = d_idx
         ELSE
          specprodxvalue = 0
         ENDIF
         BREAK
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (printdatafoundind=0)
    reply->status_data.status = "Z"
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 101, captions->rpt_page, col 106,
   curpage"###"
  FOOT REPORT
   row 59,
   CALL center(captions->end_of_report,1,125)
  WITH nocounter
 ;end select
 IF ((reply->status_data.status="Z"))
  GO TO exit_script
 ENDIF
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > " ")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 ENDIF
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) =null)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_specxm_exp_not_upd"
   SET reply->status_data.subeventstatus[1].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[1].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status != "F")
  AND (reply->status_data.status != "Z"))
  SET reply->status_data.status = "S"
 ENDIF
 FREE SET flextransprods
 FREE SET flexabprods
 FREE SET flexxmprods
 FREE SET caption
END GO
