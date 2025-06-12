CREATE PROGRAM bbt_rpt_trans_cmte:dba
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
 FREE SET tc_rec
 RECORD tc_rec(
   1 trns_cmte[*]
     2 product_cd = f8
     2 found_ind = i2
     2 trans_commit_id = f8
     2 assoc_assays_exist = i2
 )
 FREE SET tca_rec
 RECORD tca_rec(
   1 tca[*]
     2 product_cd = f8
     2 task_assay_cd = f8
     2 detail_mnemonic = c20
     2 pre_hours = i4
     2 post_hours = i4
 )
 FREE SET pe_rec
 RECORD pe_rec(
   1 pe[*]
     2 encntr_id = f8
     2 person_id = f8
     2 product_event_id = f8
     2 event_dt_tm = dq8
     2 trans_time = f8
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = c18
     2 product_nbr = c26
     2 abo_cd = f8
     2 abo_disp = c10
     2 rh_cd = f8
     2 rh_disp = c8
     2 quantity = i4
     2 iu = i4
     2 dispense_prov_id = f8
     2 physician_name = c24
     2 related_product_event_id = f8
     2 dispense_to = c14
     2 serial_number = c20
 )
 FREE SET trans_cat_rec
 RECORD trans_cat_rec(
   1 trans_cat[*]
     2 encntr_id = f8
     2 person_id = f8
     2 dispense_prov_id = f8
     2 trans_time = f8
     2 catalog_cd = f8
     2 pre_hours = i4
     2 post_hours = i4
 )
 FREE SET rpt_pe_rec
 RECORD rpt_pe_rec(
   1 trans_time = f8
   1 pe[*]
     2 product_cd = f8
     2 product_disp = c18
     2 product_nbr = c26
     2 abo_rh_disp = c15
     2 quantity = i4
     2 iu = i4
     2 event_dt_tm = dq8
     2 physician_name = c24
     2 dispense_to = c14
     2 serial_number = c20
 )
 FREE SET dta_rec
 RECORD dta_rec(
   1 dta[*]
     2 product_cd = f8
     2 task_assay_cd = f8
     2 mnemonic = c15
     2 pre_time = f8
     2 post_time = f8
 )
 FREE SET per_rec
 RECORD per_rec(
   1 per[*]
     2 person_id = f8
     2 patient_name = c40
     2 patient_name_sort = c32
     2 encntr_id = f8
     2 mrn_alias = c20
     2 fin_alias = c20
     2 dispense_prov_id = f8
     2 physician_name = c30
     2 physician_name_sort = c32
     2 related_product_event_id = f8
     2 birth_dt_tm = dq8
     2 birth_tz = i4
     2 fac_location = c32
     2 medicalservice = c32
 )
 FREE SET cat_task_rec
 RECORD cat_task_rec(
   1 cat_task[*]
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 mnemonic = c15
 )
 FREE SET ord_rec
 RECORD ord_rec(
   1 ord[*]
     2 encntr_id = f8
     2 person_id = f8
     2 trans_time = f8
     2 order_id = f8
     2 catalog_cd = f8
     2 accession = c20
     2 order_mnemonic = c20
     2 collected_dt_tm = dq8
     2 collected_time = f8
     2 order_status_cd = f8
     2 order_status_disp = c15
 )
 FREE SET report_ord_rec
 RECORD rpt_ord_rec(
   1 ord[*]
     2 catalog_cd = f8
     2 accession = c20
     2 order_mnemonic = c20
     2 collected_dt_tm = dq8
     2 order_status_disp = c15
     2 rslt_cnt = i4
     2 results[*]
       3 task_assay_cd = f8
       3 mnemonic = c20
       3 event_dt_tm = dq8
       3 result_status_disp = c15
       3 result = c17
       3 result_flags = c4
 )
 FREE SET rslt_rec
 RECORD rslt_rec(
   1 rslt[*]
     2 encntr_id = f8
     2 person_id = f8
     2 order_id = f8
     2 result_id = f8
     2 task_assay_cd = f8
     2 mnemonic = c15
     2 sequence = i4
     2 result_status_cd = f8
     2 result_status_disp = c15
     2 perform_result_id = f8
     2 result_value_alpha = c15
     2 result_code_set_cd = f8
     2 result_code_set_disp = c15
     2 result_value_numeric = f8
     2 ascii_text = c15
     2 nomenclature_id = f8
     2 long_text_id = f8
     2 normal_cd = f8
     2 normal_disp = c1
     2 critical_cd = f8
     2 critical_disp = c1
     2 review_cd = f8
     2 review_disp = c1
     2 delta_cd = f8
     2 delta_disp = c1
     2 event_dt_tm = dq8
     2 arg_min_digits = i4
     2 arg_max_digits = i4
     2 arg_min_dec_places = i4
     2 arg_less_great_flag = i2
 )
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
     2 data_blob = gvc
     2 data_blob_size = i4
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
 FREE RECORD ekssourcerequest
 RECORD ekssourcerequest(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 )
 FREE RECORD eksreply
 RECORD eksreply(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (readexportfile(fullfilepath=vc) =null)
   SET stat = initrec(ekssourcerequest)
   SET stat = initrec(eksreply)
   DECLARE filename = vc WITH protect, noconstant
   DECLARE file_dir = vc WITH protect, noconstant
   DECLARE separator_pos = i2 WITH protect, noconstant(0)
   SET separator_pos = 0
   SET separator_pos = cnvtint(value(findstring(":",fullfilepath,1,1)))
   IF (separator_pos <= 0)
    SET separator_pos = cnvtint(value(findstring("/",fullfilepath,1,1)))
   ENDIF
   SET file_dir = concat(substring(1,(separator_pos - 1),fullfilepath),":")
   SET filename = substring((separator_pos+ 1),(size(fullfilepath) - separator_pos),fullfilepath)
   SET ekssourcerequest->module_dir = file_dir
   SET ekssourcerequest->module_name = filename
   SET ekssourcerequest->basblob = 1
   EXECUTE eks_get_source  WITH replace("REQUEST",ekssourcerequest), replace("REPLY",eksreply)
   RETURN
 END ;Subroutine
 DECLARE reportbyusername = vc WITH protect, noconstant("")
 SET reportbyusername = get_username(reqinfo->updt_id)
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
   1 medical_record_num = vc
   1 financial_num = vc
   1 pre_transfusion_tests = vc
   1 no_pre_transfusion = vc
   1 transfusion = vc
   1 physician = vc
   1 product_type = vc
   1 product_number = vc
   1 date_time = vc
   1 post_transfusion_tests = vc
   1 no_post_transfusion = vc
   1 not_resulted = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 printed_by = vc
   1 transfusion_report = vc
   1 patient = vc
   1 physician_filter = vc
   1 med_service = vc
   1 begin_date = vc
   1 end_date = vc
   1 ordered_procedure = vc
   1 patient_name = vc
   1 accession = vc
   1 detailed_procedure = vc
   1 date_time2 = vc
   1 status = vc
   1 result = vc
   1 flag = vc
   1 end_of_report = vc
   1 collected = vc
   1 not_on_file = vc
   1 date_of_birth = vc
   1 all = vc
   1 abo = vc
   1 rh = vc
   1 owner_area = vc
   1 inv_area = vc
   1 product_category = vc
   1 product_aborh = vc
   1 quantity = vc
   1 loc_facility = vc
   1 medical_service = vc
   1 dispense_to = vc
   1 serial_number = vc
 )
 SET captions->medical_record_num = uar_i18ngetmessage(i18nhandle,"medical_record_num","MRN:")
 SET captions->financial_num = uar_i18ngetmessage(i18nhandle,"financial_num","FIN:")
 SET captions->pre_transfusion_tests = uar_i18ngetmessage(i18nhandle,"pre_transfusion_tests",
  "PRE-TRANSFUSION TESTS")
 SET captions->no_pre_transfusion = uar_i18ngetmessage(i18nhandle,"no_pre_transfusion",
  "(no pre-transfusion tests)")
 SET captions->transfusion = uar_i18ngetmessage(i18nhandle,"transfusion","TRANSFUSION:")
 SET captions->physician = uar_i18ngetmessage(i18nhandle,"physician","PHYSICIAN        ")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","    PRODUCT TYPE    ")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","PRODUCT NUMBER/")
 SET captions->date_time = uar_i18ngetmessage(i18nhandle,"date_time","DATE/TIME")
 SET captions->post_transfusion_tests = uar_i18ngetmessage(i18nhandle,"post_transfusion_tests",
  "POST-TRANSFUSION TESTS")
 SET captions->no_post_transfusion = uar_i18ngetmessage(i18nhandle,"no_post_transfusion",
  "(no post-transfusion tests)")
 SET captions->not_resulted = uar_i18ngetmessage(i18nhandle,"not_resulted","<not resulted>")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBT_RPT_TRANS_CMTE")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->printed_by = uar_i18ngetmessage(i18nhandle,"printed_by","By:")
 SET captions->transfusion_report = uar_i18ngetmessage(i18nhandle,"transfusion_report",
  "T R A N S F U S I O N   C O M M I T T E E   R E P O R T")
 SET captions->patient = uar_i18ngetmessage(i18nhandle,"patient","Patient:")
 SET captions->physician_filter = uar_i18ngetmessage(i18nhandle,"physician_filter","Physician:")
 SET captions->begin_date = uar_i18ngetmessage(i18nhandle,"begin_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->ordered_procedure = uar_i18ngetmessage(i18nhandle,"ordered_procedure",
  "ORDERED PROCEDURE")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"accession","     ACCESSION      ")
 SET captions->detailed_procedure = uar_i18ngetmessage(i18nhandle,"detailed_procedure",
  "  DETAILED PROCEDURE")
 SET captions->date_time2 = uar_i18ngetmessage(i18nhandle,"date_time2","  DATE/TIME    ")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS      ")
 SET captions->result = uar_i18ngetmessage(i18nhandle,"result","RESULT")
 SET captions->flag = uar_i18ngetmessage(i18nhandle,"flag","FLAG")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->collected = uar_i18ngetmessage(i18nhandle,"collected","Collected")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->date_of_birth = uar_i18ngetmessage(i18nhandle,"date_of_birth","Date of Birth:")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->abo = uar_i18ngetmessage(i18nhandle,"abo","ABO:")
 SET captions->rh = uar_i18ngetmessage(i18nhandle,"rh","Rh:")
 SET captions->owner_area = uar_i18ngetmessage(i18nhandle,"owner_area","Blood Bank Owner:")
 SET captions->inv_area = uar_i18ngetmessage(i18nhandle,"inv_area","Inventory Area:")
 SET captions->product_category = uar_i18ngetmessage(i18nhandle,"product_category",
  "Product Category:")
 SET captions->product_aborh = uar_i18ngetmessage(i18nhandle,"product_aborh","PRODUCT ABO/RH")
 SET captions->quantity = uar_i18ngetmessage(i18nhandle,"quantity","QTY/IU")
 SET captions->loc_facility = uar_i18ngetmessage(i18nhandle,"loc_facility","LOCATION:")
 SET captions->medical_service = uar_i18ngetmessage(i18nhandle,"medical_service","MED SERVICE:")
 SET captions->dispense_to = uar_i18ngetmessage(i18nhandle,"dispense_to","DISPENSED LOC")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","SERIAL NUMBER")
 DECLARE product_state_code_set = i4 WITH public, constant(1610)
 DECLARE transfused_cdf_meaning = c12 WITH public, constant("7")
 DECLARE encntr_alias_type_code_set = i4 WITH public, constant(319)
 DECLARE mrn_alias_cdf_meaning = c12 WITH public, constant("MRN")
 DECLARE fin_alias_cdf_meaning = c12 WITH public, constant("FIN NBR")
 DECLARE serv_res_subsection_cdf = c12 WITH protect, constant("SUBSECTION")
 DECLARE rpt_cnt = i4 WITH noconstant(0)
 DECLARE report_type = c32 WITH protect, noconstant(" ")
 DECLARE serv_res_subsection_cd = f8
 SET service_resource_type_codeset = 223
 SET by_patient_ind = " "
 SET by_physician_ind = " "
 SET individual_id = 0.0
 SET individual_name = fillstring(50," ")
 SET physician_name_filter = fillstring(50," ")
 SET physician_id = 0.0
 SET abo_disp = fillstring(10," ")
 SET rh_disp = fillstring(8," ")
 SET owner_area_disp = fillstring(20," ")
 SET inv_area_disp = fillstring(20," ")
 SET product_cat_disp = fillstring(30," ")
 SET count1 = 0
 SET ops_ind = "N"
 SET ops_cnvt_dt_tm = cnvtdatetime(sysdate)
 SET report_complete_ind = "N"
 SET detail_cnt = 0
 SET transfused_event_type_cd = 0.0
 SET mrn_alias_type_cd = 0.0
 SET fin_alias_type_cd = 0.0
 SET tc_cnt = 0
 SET tca_cnt = 0
 SET pe_cnt = 0
 SET p_cnt = 0
 SET encntr_cnt = 0
 SET encntr_cat_cnt = 0
 SET ord_cnt = 0
 SET ord = 0
 SET per_cnt = 0
 SET cat_task_cnt = 0
 SET rslt_cnt_g = 0
 SET trans_cat_cnt = 0
 SET dta_cnt = 0
 IF (trim(request->batch_selection) > " ")
  SET ops_ind = "Y"
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_trans_cmte")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  SET sort_selection = fillstring(20," ")
  CALL check_sort_opt("bbt_rpt_trans_cmte")
  IF (trim(sort_selection) > " ")
   SET request->report_format = trim(sort_selection)
  ELSE
   SET request->report_format = " "
  ENDIF
  SET mode_selection = fillstring(5," ")
  CALL check_mode_opt("bbt_rpt_trans_cmte")
  IF (trim(mode_selection) > " ")
   IF (mode_selection="R")
    SET report_type = "PRINT"
   ELSEIF (mode_selection="E")
    SET report_type = "EXPORT"
   ELSEIF (mode_selection="R;E")
    SET report_type = "BOTH"
   ENDIF
  ELSE
   SET report_type = "PRINT"
  ENDIF
  CALL check_location_cd("bbt_rpt_trans_cmte")
 ELSE
  IF ((request->export_ind=1))
   SET report_type = "EXPORT"
  ELSE
   SET report_type = "PRINT"
  ENDIF
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
 IF (cnvtupper(request->report_format)="PATIENT")
  SET by_patient_ind = "Y"
 ELSEIF (cnvtupper(request->report_format)="PHYSICIAN")
  SET by_physician_ind = "Y"
 ELSE
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "determine report format"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "invalid requested report format:",request->report_format)
  GO TO exit_script
 ENDIF
 IF ((request->physician_id != null)
  AND (request->physician_id > 0))
  SET physician_id = request->physician_id
  SELECT INTO "nl:"
   per.name_full_formatted
   FROM prsnl per
   WHERE per.person_id=physician_id
   DETAIL
    physician_name_filter = per.name_full_formatted
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "retrieve physician name"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
   SET errmsg = concat("invalid requested individual ",trim(request->report_format),
    ".  Requested _id =")
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(errmsg,physician_id)
   GO TO exit_script
  ENDIF
 ELSE
  SET physician_id = 0.0
  SET physician_name_filter = ""
 ENDIF
 IF ((request->individual_id != null)
  AND (request->individual_id > 0))
  SET individual_id = request->individual_id
  SELECT INTO "nl:"
   per.name_full_formatted
   FROM person per
   WHERE per.person_id=individual_id
   DETAIL
    individual_name = per.name_full_formatted
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationname = "retrieve individual name"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
   SET errmsg = concat("invalid requested individual ",trim(request->report_format),
    ".  Requested _id =")
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(errmsg,individual_id)
   GO TO exit_script
  ENDIF
 ELSE
  SET individual_id = 0.0
  SET individual_name = ""
 ENDIF
 IF (trim(request->batch_selection) > " ")
  CALL check_owner_cd("bbt_rpt_trans_cmte.prg")
  CALL check_inventory_cd("bbt_rpt_trans_cmte.prg")
 ENDIF
 IF ((request->abo_cd > 0))
  SET abo_disp = uar_get_code_display(request->abo_cd)
 ENDIF
 IF ((request->rh_cd > 0))
  SET rh_disp = uar_get_code_display(request->rh_cd)
 ENDIF
 IF ((request->cur_owner_area_cd > 0))
  SET owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd > 0))
  SET inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 IF ((request->product_cat_cd > 0))
  SET product_cat_disp = uar_get_code_display(request->product_cat_cd)
 ENDIF
 SET stat = uar_get_meaning_by_codeset(service_resource_type_codeset,serv_res_subsection_cdf,1,
  serv_res_subsection_cd)
 SET stat = uar_get_meaning_by_codeset(product_state_code_set,transfused_cdf_meaning,1,
  transfused_event_type_cd)
 IF (transfused_event_type_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",product_state_code_set,"transfused_event_type_cd")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(encntr_alias_type_code_set,mrn_alias_cdf_meaning,1,
  mrn_alias_type_cd)
 IF (mrn_alias_type_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",encntr_alias_type_code_set,"mrn_alias_type_cd")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(encntr_alias_type_code_set,fin_alias_cdf_meaning,1,
  fin_alias_type_cd)
 IF (fin_alias_type_cd=0.0)
  SET failed = "T"
  CALL subevent_add("UAR","F",encntr_alias_type_code_set,"fin_alias_type_cd")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  tc.trans_commit_id, tc.product_cd, tca.trans_commit_assay_id,
  tca.task_assay_cd, tca.pre_hours, tca.post_hours,
  dta.mnemonic
  FROM transfusion_committee tc,
   trans_commit_assay tca,
   discrete_task_assay dta
  PLAN (tc
   WHERE tc.trans_commit_id > 0.0
    AND tc.active_ind=1
    AND (((tc.owner_cd=request->cur_owner_area_cd)) OR (tc.owner_cd=0.0))
    AND (((tc.inv_area_cd=request->cur_inv_area_cd)) OR (tc.inv_area_cd=0.0)) )
   JOIN (tca
   WHERE (tca.trans_commit_assay_id> Outerjoin(0.0))
    AND (tca.trans_commit_id= Outerjoin(tc.trans_commit_id))
    AND (tca.active_ind= Outerjoin(1)) )
   JOIN (dta
   WHERE (dta.task_assay_cd= Outerjoin(tca.task_assay_cd)) )
  ORDER BY tc.product_cd, tc.owner_cd DESC, tc.inv_area_cd DESC,
   tca.task_assay_cd
  HEAD REPORT
   tc_cnt = 0, stat = alterlist(tc_rec->trns_cmte,100), tca_cnt = 0,
   stat = alterlist(tca_rec->tca,5), tc_id = 0.0
  HEAD tc.product_cd
   tc_cnt += 1
   IF (mod(tc_cnt,100)=1
    AND tc_cnt != 1)
    stat = alterlist(tc_rec->trns_cmte,(tc_cnt+ 99))
   ENDIF
   tc_rec->trns_cmte[tc_cnt].product_cd = tc.product_cd, tc_rec->trns_cmte[tc_cnt].trans_commit_id =
   tc.trans_commit_id, tc_id = tc.trans_commit_id
  HEAD tca.task_assay_cd
   IF (tc_id=tca.trans_commit_id)
    tc_rec->trns_cmte[tc_cnt].assoc_assays_exist = 1, tca_cnt += 1
    IF (mod(tca_cnt,5)=1
     AND tca_cnt != 1)
     stat = alterlist(tca_rec->tca,(tca_cnt+ 4))
    ENDIF
    tca_rec->tca[tca_cnt].product_cd = tc.product_cd, tca_rec->tca[tca_cnt].task_assay_cd = tca
    .task_assay_cd, tca_rec->tca[tca_cnt].detail_mnemonic = dta.mnemonic,
    tca_rec->tca[tca_cnt].pre_hours = tca.pre_hours, tca_rec->tca[tca_cnt].post_hours = tca
    .post_hours
   ENDIF
  FOOT REPORT
   stat = alterlist(tc_rec->trns_cmte,tc_cnt), stat = alterlist(tca_rec->tca,tca_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get transfusion_committee"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "select failed for transfusion_committee/trans_commit_assay"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pe.encntr_id, pe.person_id, pe.product_event_id,
  pe.product_id, pe.event_dt_tm";;f", trans_time = cnvtmin2(cnvtdate2(format(pe.event_dt_tm,
     "mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(pe.event_dt_tm,"hhmmss;;m")),2),
  pe.product_id, p.product_cd, product_disp = uar_get_code_display(p.product_cd),
  cur_abo_disp = decode(bp.seq,uar_get_code_display(bp.cur_abo_cd)," "), cur_rh_disp = decode(bp.seq,
   uar_get_code_display(bp.cur_rh_cd)," "), bp.supplier_prefix,
  product_nbr = concat(trim(p.product_nbr)," ",trim(p.product_sub_nbr)), p.serial_number_txt, tfn
  .cur_transfused_qty,
  pd.dispense_prov_id, physician_name = trim(per_doc.name_full_formatted), dispense_to_disp =
  substring(1,14,uar_get_code_display(pd.dispense_to_locn_cd)),
  pe.related_product_event_id
  FROM (dummyt d_tc  WITH seq = value(tc_cnt)),
   product_event pe,
   transfusion tfn,
   product p,
   product_index pi,
   patient_dispense pd,
   person per_doc,
   blood_product bp
  PLAN (d_tc)
   JOIN (pe
   WHERE pe.event_type_cd=transfused_event_type_cd
    AND pe.active_ind=1
    AND pe.person_id != null
    AND pe.person_id > 0
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((pe.person_id=individual_id) OR (individual_id=0)) )
   JOIN (tfn
   WHERE tfn.product_event_id=pe.product_event_id)
   JOIN (p
   WHERE p.product_id=pe.product_id
    AND (p.product_cd=tc_rec->trns_cmte[d_tc.seq].product_cd)
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (pi
   WHERE pi.product_cd=p.product_cd
    AND (((request->product_cat_cd=0)) OR ((request->product_cat_cd=pi.product_cat_cd))) )
   JOIN (pd
   WHERE pd.product_event_id=pe.related_product_event_id
    AND ((pd.dispense_prov_id=physician_id) OR (physician_id=0)) )
   JOIN (per_doc
   WHERE per_doc.person_id=pd.dispense_prov_id)
   JOIN (bp
   WHERE ((bp.product_id=p.product_id) OR (bp.product_id=0.0)) )
  ORDER BY pe.encntr_id, pe.event_dt_tm, pe.product_event_id,
   bp.product_id DESC
  HEAD REPORT
   pe_cnt = 0, stat = alterlist(pe_rec->pe,500)
  HEAD pe.product_event_id
   IF (((bp.product_id=0.0
    AND (request->rh_cd=0.0)
    AND (request->abo_cd=0.0)) OR ((((request->abo_cd=0)
    AND (request->rh_cd=0)) OR ((((request->abo_cd > 0)
    AND (request->rh_cd=0)
    AND (request->abo_cd=bp.cur_abo_cd)) OR ((((request->abo_cd=0)
    AND (request->rh_cd > 0)
    AND (request->rh_cd=bp.cur_rh_cd)) OR ((request->abo_cd=bp.cur_abo_cd)
    AND (request->rh_cd=bp.cur_rh_cd))) )) )) )) )
    pe_cnt += 1
    IF (mod(pe_cnt,500)=1
     AND pe_cnt != 1)
     stat = alterlist(pe_rec->pe,(pe_cnt+ 499))
    ENDIF
    pe_rec->pe[pe_cnt].encntr_id = pe.encntr_id, pe_rec->pe[pe_cnt].person_id = pe.person_id, pe_rec
    ->pe[pe_cnt].product_event_id = pe.product_event_id,
    pe_rec->pe[pe_cnt].event_dt_tm = cnvtdatetime(pe.event_dt_tm), pe_rec->pe[pe_cnt].trans_time =
    trans_time, pe_rec->pe[pe_cnt].product_id = pe.product_id,
    pe_rec->pe[pe_cnt].product_cd = p.product_cd, pe_rec->pe[pe_cnt].product_disp = product_disp
    IF (bp.product_id > 0.0)
     pe_rec->pe[pe_cnt].product_nbr = concat(trim(bp.supplier_prefix),trim(product_nbr)), pe_rec->pe[
     pe_cnt].abo_cd = bp.cur_abo_cd, pe_rec->pe[pe_cnt].abo_disp = cur_abo_disp,
     pe_rec->pe[pe_cnt].rh_cd = bp.cur_rh_cd, pe_rec->pe[pe_cnt].rh_disp = cur_rh_disp, pe_rec->pe[
     pe_cnt].quantity = 0,
     pe_rec->pe[pe_cnt].iu = 0
    ELSE
     pe_rec->pe[pe_cnt].product_nbr = product_nbr, pe_rec->pe[pe_cnt].abo_cd = 0, pe_rec->pe[pe_cnt].
     abo_disp = " ",
     pe_rec->pe[pe_cnt].rh_cd = 0, pe_rec->pe[pe_cnt].rh_disp = " ", pe_rec->pe[pe_cnt].quantity =
     tfn.cur_transfused_qty,
     pe_rec->pe[pe_cnt].iu = tfn.transfused_intl_units, pe_rec->pe[pe_cnt].serial_number = p
     .serial_number_txt
    ENDIF
    pe_rec->pe[pe_cnt].dispense_prov_id = pd.dispense_prov_id, pe_rec->pe[pe_cnt].
    related_product_event_id = pe.related_product_event_id, pe_rec->pe[pe_cnt].dispense_prov_id = pd
    .dispense_prov_id,
    pe_rec->pe[pe_cnt].physician_name = physician_name, tc_rec->trns_cmte[d_tc.seq].found_ind = 1,
    pe_rec->pe[pe_cnt].dispense_to = dispense_to_disp
   ENDIF
  FOOT REPORT
   stat = alterlist(pe_rec->pe,pe_cnt)
  WITH nocounter
 ;end select
 IF (((curqual=0) OR (pe_cnt=0)) )
  IF (report_type="EXPORT")
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get person data"
  SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "ZERO:  No data found for specified date range"
  IF (report_type="EXPORT")
   GO TO exit_script
  ELSE
   GO TO output_report
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  ptr.catalog_cd, tca.task_assay_cd, mnemonic = uar_get_code_display(tca.task_assay_cd)
  FROM (dummyt d_tc  WITH seq = value(tc_cnt)),
   trans_commit_assay tca,
   profile_task_r ptr
  PLAN (d_tc)
   JOIN (tca
   WHERE tca.trans_commit_assay_id > 0
    AND (tca.trans_commit_id=tc_rec->trns_cmte[d_tc.seq].trans_commit_id)
    AND tca.active_ind=1
    AND (tc_rec->trns_cmte[d_tc.seq].found_ind=1))
   JOIN (ptr
   WHERE ptr.task_assay_cd=tca.task_assay_cd
    AND ptr.active_ind=1
    AND ptr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ptr.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY ptr.catalog_cd, tca.task_assay_cd
  HEAD REPORT
   cat_task_cnt = 0, stat = alterlist(cat_task_rec->cat_task,100)
  HEAD ptr.catalog_cd
   row 0
  HEAD tca.task_assay_cd
   cat_task_cnt += 1
   IF (mod(cat_task_cnt,100)=1
    AND cat_task_cnt != 1)
    stat = alterlist(cat_task_rec->cat_task,(cat_task_cnt+ 99))
   ENDIF
   cat_task_rec->cat_task[cat_task_cnt].catalog_cd = ptr.catalog_cd, cat_task_rec->cat_task[
   cat_task_cnt].task_assay_cd = tca.task_assay_cd, cat_task_rec->cat_task[cat_task_cnt].mnemonic =
   mnemonic
  FOOT REPORT
   stat = alterlist(cat_task_rec->cat_task,cat_task_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  encntr_id = pe_rec->pe[d_pe.seq].encntr_id, dispense_prov_id = pe_rec->pe[d_pe.seq].
  dispense_prov_id, trans_time = pe_rec->pe[d_pe.seq].trans_time,
  product_cd = tca_rec->tca[d_tca.seq].product_cd, task_assay_cd = tca_rec->tca[d_tca.seq].
  task_assay_cd, pre_hours = tca_rec->tca[d_tca.seq].pre_hours,
  post_hours = tca_rec->tca[d_tca.seq].post_hours, ptr.catalog_cd
  FROM (dummyt d_pe  WITH seq = value(pe_cnt)),
   (dummyt d_tca  WITH seq = value(tca_cnt)),
   profile_task_r ptr
  PLAN (d_pe)
   JOIN (d_tca
   WHERE (tca_rec->tca[d_tca.seq].product_cd=pe_rec->pe[d_pe.seq].product_cd))
   JOIN (ptr
   WHERE (ptr.task_assay_cd=tca_rec->tca[d_tca.seq].task_assay_cd)
    AND ptr.active_ind=1
    AND ptr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ptr.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY encntr_id, dispense_prov_id, trans_time,
   ptr.catalog_cd
  HEAD REPORT
   trans_cat_cnt = 0, stat = alterlist(trans_cat_rec->trans_cat,1000)
  HEAD encntr_id
   row 0
  HEAD dispense_prov_id
   row 0
  HEAD trans_time
   max_pre_hours = 0, max_post_hours = 0
  DETAIL
   IF (pre_hours > max_pre_hours)
    max_pre_hours = pre_hours
   ENDIF
   IF (post_hours > max_post_hours)
    max_post_hours = post_hours
   ENDIF
  FOOT  ptr.catalog_cd
   trans_cat_cnt += 1
   IF (mod(trans_cat_cnt,1000)=1
    AND trans_cat_cnt != 1)
    stat = alterlist(trans_cat_rec->trans_cat,(trans_cat_cnt+ 999))
   ENDIF
   trans_cat_rec->trans_cat[trans_cat_cnt].encntr_id = pe_rec->pe[d_pe.seq].encntr_id, trans_cat_rec
   ->trans_cat[trans_cat_cnt].person_id = pe_rec->pe[d_pe.seq].person_id, trans_cat_rec->trans_cat[
   trans_cat_cnt].dispense_prov_id = pe_rec->pe[d_pe.seq].dispense_prov_id,
   trans_cat_rec->trans_cat[trans_cat_cnt].trans_time = pe_rec->pe[d_pe.seq].trans_time,
   trans_cat_rec->trans_cat[trans_cat_cnt].catalog_cd = ptr.catalog_cd, trans_cat_rec->trans_cat[
   trans_cat_cnt].pre_hours = max_pre_hours,
   trans_cat_rec->trans_cat[trans_cat_cnt].post_hours = max_post_hours
  FOOT REPORT
   stat = alterlist(trans_cat_rec->trans_cat,trans_cat_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  per.person_id, patient_name = trim(per.name_full_formatted), encntr_id = pe_rec->pe[d_pe.seq].
  encntr_id,
  mrn_alias = decode(ea_mrn.alias,ea_mrn.alias,captions->not_on_file), fin_alias = decode(ea_fin
   .alias,ea_fin.alias,captions->not_on_file), dispense_prov_id = pe_rec->pe[d_pe.seq].
  dispense_prov_id,
  physician_name = trim(per_doc.name_full_formatted), med_service_disp = uar_get_code_display(e
   .med_service_cd), loc_facility_disp = uar_get_code_display(e.loc_facility_cd)
  FROM (dummyt d_pe  WITH seq = value(pe_cnt)),
   person per,
   (dummyt d_ea_mrn  WITH seq = 1),
   encntr_alias ea_mrn,
   (dummyt d_ea_fin  WITH seq = 1),
   encntr_alias ea_fin,
   patient_dispense pd,
   person per_doc,
   encounter e
  PLAN (d_pe)
   JOIN (per
   WHERE (per.person_id=pe_rec->pe[d_pe.seq].person_id))
   JOIN (pd
   WHERE (pd.product_event_id=pe_rec->pe[d_pe.seq].related_product_event_id)
    AND ((physician_id=0) OR (physician_id=pd.dispense_prov_id)) )
   JOIN (per_doc
   WHERE per_doc.person_id=pd.dispense_prov_id)
   JOIN (d_ea_mrn
   WHERE d_ea_mrn.seq=1)
   JOIN (ea_mrn
   WHERE (ea_mrn.encntr_id=pe_rec->pe[d_pe.seq].encntr_id)
    AND ea_mrn.encntr_id != null
    AND ea_mrn.encntr_id > 0
    AND ea_mrn.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea_mrn.active_ind=1
    AND ea_mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea_mrn.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d_ea_fin
   WHERE d_ea_fin.seq=1)
   JOIN (ea_fin
   WHERE (ea_fin.encntr_id=pe_rec->pe[d_pe.seq].encntr_id)
    AND ea_fin.encntr_id != null
    AND ea_fin.encntr_id > 0
    AND ea_fin.encntr_alias_type_cd=fin_alias_type_cd
    AND ea_fin.active_ind=1
    AND ea_fin.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea_fin.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (e
   WHERE (e.encntr_id=pe_rec->pe[d_pe.seq].encntr_id))
  ORDER BY encntr_id, dispense_prov_id
  HEAD REPORT
   per_cnt = 0, stat = alterlist(per_rec->per,300)
  HEAD encntr_id
   row 0
  HEAD dispense_prov_id
   per_cnt += 1
   IF (mod(per_cnt,300)=1
    AND per_cnt != 1)
    stat = alterlist(per_rec->per,(per_cnt+ 299))
   ENDIF
   per_rec->per[per_cnt].person_id = per.person_id, per_rec->per[per_cnt].patient_name = patient_name,
   per_rec->per[per_cnt].patient_name_sort = concat(substring(1,18,per.name_full_formatted),format(
     pe_rec->pe[d_pe.seq].encntr_id,"###########.##;p0;f")),
   per_rec->per[per_cnt].encntr_id = encntr_id, per_rec->per[per_cnt].mrn_alias = cnvtalias(mrn_alias,
    ea_mrn.alias_pool_cd), per_rec->per[per_cnt].fin_alias = cnvtalias(fin_alias,ea_fin.alias_pool_cd
    ),
   per_rec->per[per_cnt].dispense_prov_id = pd.dispense_prov_id, per_rec->per[per_cnt].
   related_product_event_id = pe_rec->pe[d_pe.seq].related_product_event_id, per_rec->per[per_cnt].
   physician_name = physician_name,
   per_rec->per[per_cnt].physician_name_sort = concat(substring(1,18,per_doc.name_full_formatted),
    format(pd.dispense_prov_id,"###########.##;p0;f")), per_rec->per[per_cnt].birth_dt_tm =
   cnvtdatetime(per.birth_dt_tm), per_rec->per[per_cnt].birth_tz = validate(per.birth_tz,0),
   per_rec->per[per_cnt].medicalservice = med_service_disp, per_rec->per[per_cnt].fac_location =
   loc_facility_disp
  FOOT REPORT
   stat = alterlist(per_rec->per,per_cnt)
  WITH nocounter, dontcare(ea_mrn), outerjoin(d_ea_mrn),
   dontcare(ea_fin), outerjoin(d_ea_fin)
 ;end select
 SELECT INTO "nl:"
  encntr_id = trans_cat_rec->trans_cat[d_tc.seq].encntr_id, person_id = trans_cat_rec->trans_cat[d_tc
  .seq].person_id, trans_time = trans_cat_rec->trans_cat[d_tc.seq].trans_time,
  catalog_cd = trans_cat_rec->trans_cat[d_tc.seq].catalog_cd, pre_hours = trans_cat_rec->trans_cat[
  d_tc.seq].pre_hours, post_hours = trans_cat_rec->trans_cat[d_tc.seq].post_hours,
  o.order_id, c.drawn_dt_tm";;f", collected_time = cnvtmin2(cnvtdate2(format(c.drawn_dt_tm,
     "mm/dd/yyyy;;d"),"mm/dd/yyyy"),cnvtint(format(c.drawn_dt_tm,"hhmmss;;m")),2),
  o.order_status_cd, order_status_disp = uar_get_code_display(o.order_status_cd), o.order_mnemonic,
  aor.accession
  FROM (dummyt d_tc  WITH seq = value(trans_cat_cnt)),
   orders o,
   accession_order_r aor,
   order_container_r ocr,
   container c
  PLAN (d_tc)
   JOIN (o
   WHERE (o.person_id=trans_cat_rec->trans_cat[d_tc.seq].person_id)
    AND (o.catalog_cd=trans_cat_rec->trans_cat[d_tc.seq].catalog_cd))
   JOIN (aor
   WHERE aor.order_id=o.order_id
    AND aor.primary_flag=0)
   JOIN (ocr
   WHERE ocr.order_id=o.order_id)
   JOIN (c
   WHERE c.container_id=ocr.container_id)
  ORDER BY encntr_id, trans_time, collected_time,
   o.order_id
  HEAD REPORT
   ord_cnt = 0, stat = alterlist(ord_rec->ord,1000)
  HEAD o.order_id
   IF ((collected_time >= (trans_time - (trans_cat_rec->trans_cat[d_tc.seq].pre_hours * 60)))
    AND (collected_time <= (trans_time+ (trans_cat_rec->trans_cat[d_tc.seq].post_hours * 60))))
    ord_cnt += 1
    IF (mod(ord_cnt,1000)=1
     AND ord_cnt != 1)
     stat = alterlist(ord_rec->ord,(ord_cnt+ 999))
    ENDIF
    ord_rec->ord[ord_cnt].encntr_id = encntr_id, ord_rec->ord[ord_cnt].person_id = person_id, ord_rec
    ->ord[ord_cnt].trans_time = trans_time,
    ord_rec->ord[ord_cnt].order_id = o.order_id, ord_rec->ord[ord_cnt].catalog_cd = o.catalog_cd,
    ord_rec->ord[ord_cnt].accession = cnvtacc(aor.accession),
    ord_rec->ord[ord_cnt].order_mnemonic = o.order_mnemonic, ord_rec->ord[ord_cnt].collected_dt_tm =
    cnvtdatetime(c.drawn_dt_tm), ord_rec->ord[ord_cnt].collected_time = collected_time,
    ord_rec->ord[ord_cnt].order_status_cd = o.order_status_cd, ord_rec->ord[ord_cnt].
    order_status_disp = order_status_disp
   ENDIF
  FOOT REPORT
   stat = alterlist(ord_rec->ord,ord_cnt)
  WITH nocounter
 ;end select
 IF (ord_cnt=0)
  GO TO output_report
 ENDIF
 SELECT INTO "nl:"
  encntr_id = ord_rec->ord[d_o.seq].encntr_id, person_id = ord_rec->ord[d_o.seq].person_id, r
  .order_id,
  r.result_id, r.result_status_cd, result_status_disp = uar_get_code_display(r.result_status_cd),
  dta.mnemonic, ptr.sequence, pr.perform_result_id,
  pr.result_value_alpha, pr.result_code_set_cd, result_code_set_disp = uar_get_code_display(pr
   .result_code_set_cd),
  pr.result_value_numeric, pr.ascii_text, pr.long_text_id,
  pr.normal_cd, normal_disp = uar_get_code_display(pr.normal_cd), pr.critical_cd,
  critical_disp = uar_get_code_display(pr.critical_cd), pr.review_cd, review_disp =
  uar_get_code_display(pr.review_cd),
  pr.delta_cd, delta_disp = uar_get_code_display(pr.delta_cd), re.event_dt_tm,
  dm.service_resource_cd, data_map_exists = decode(dm.seq,"Y","N"), rg_exists = decode(rg.seq,"Y","N"
   )
  FROM (dummyt d_o  WITH seq = value(ord_cnt)),
   (dummyt d_t  WITH seq = value(cat_task_cnt)),
   result r,
   discrete_task_assay dta,
   profile_task_r ptr,
   perform_result pr,
   result_event re,
   (dummyt d_dm  WITH seq = 1),
   data_map dm,
   (dummyt d_rg  WITH seq = 1),
   resource_group rg
  PLAN (d_o)
   JOIN (d_t
   WHERE (cat_task_rec->cat_task[d_t.seq].catalog_cd=ord_rec->ord[d_o.seq].catalog_cd))
   JOIN (r
   WHERE (r.order_id=ord_rec->ord[d_o.seq].order_id)
    AND (r.task_assay_cd=cat_task_rec->cat_task[d_t.seq].task_assay_cd))
   JOIN (dta
   WHERE dta.task_assay_cd=r.task_assay_cd)
   JOIN (ptr
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND ptr.catalog_cd=r.catalog_cd)
   JOIN (pr
   WHERE pr.result_id=r.result_id
    AND pr.result_status_cd=r.result_status_cd)
   JOIN (re
   WHERE re.perform_result_id=pr.perform_result_id
    AND re.result_id=r.result_id
    AND re.event_type_cd=pr.result_status_cd)
   JOIN (d_dm
   WHERE d_dm.seq=1)
   JOIN (dm
   WHERE (dm.task_assay_cd=cat_task_rec->cat_task[d_t.seq].task_assay_cd)
    AND dm.data_map_type_flag=0
    AND dm.active_ind=1)
   JOIN (d_rg
   WHERE d_rg.seq=1)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=dm.service_resource_cd
    AND rg.child_service_resource_cd=pr.service_resource_cd
    AND rg.resource_group_type_cd=serv_res_subsection_cd
    AND ((rg.root_service_resource_cd+ 0)=0.0))
  ORDER BY r.order_id, r.result_id, d_dm.seq
  HEAD REPORT
   rslt_cnt_g = 0, stat = alterlist(rslt_rec->rslt,5000), data_map_level = 0
  HEAD r.result_id
   rslt_cnt_g += 1
   IF (mod(rslt_cnt_g,5000)=1
    AND rslt_cnt_g != 1)
    stat = alterlist(rslt_rec->rslt,(rslt_cnt_g+ 4999))
   ENDIF
   rslt_rec->rslt[rslt_cnt_g].encntr_id = encntr_id, rslt_rec->rslt[rslt_cnt_g].person_id = person_id,
   rslt_rec->rslt[rslt_cnt_g].order_id = r.order_id,
   rslt_rec->rslt[rslt_cnt_g].result_id = r.result_id, rslt_rec->rslt[rslt_cnt_g].task_assay_cd = r
   .task_assay_cd, rslt_rec->rslt[rslt_cnt_g].mnemonic = dta.mnemonic,
   rslt_rec->rslt[rslt_cnt_g].sequence = ptr.sequence, rslt_rec->rslt[rslt_cnt_g].result_status_cd =
   r.result_status_cd, rslt_rec->rslt[rslt_cnt_g].result_status_disp = result_status_disp,
   rslt_rec->rslt[rslt_cnt_g].perform_result_id = pr.perform_result_id, rslt_rec->rslt[rslt_cnt_g].
   result_value_alpha = pr.result_value_alpha, rslt_rec->rslt[rslt_cnt_g].result_code_set_cd = pr
   .result_code_set_cd,
   rslt_rec->rslt[rslt_cnt_g].result_code_set_disp = result_code_set_disp, rslt_rec->rslt[rslt_cnt_g]
   .result_value_numeric = pr.result_value_numeric, rslt_rec->rslt[rslt_cnt_g].ascii_text = pr
   .ascii_text,
   rslt_rec->rslt[rslt_cnt_g].nomenclature_id = pr.nomenclature_id, rslt_rec->rslt[rslt_cnt_g].
   long_text_id = pr.long_text_id, rslt_rec->rslt[rslt_cnt_g].normal_cd = pr.normal_cd,
   rslt_rec->rslt[rslt_cnt_g].normal_disp = normal_disp, rslt_rec->rslt[rslt_cnt_g].critical_cd = pr
   .critical_cd, rslt_rec->rslt[rslt_cnt_g].critical_disp = critical_disp,
   rslt_rec->rslt[rslt_cnt_g].review_cd = pr.review_cd, rslt_rec->rslt[rslt_cnt_g].review_disp =
   review_disp, rslt_rec->rslt[rslt_cnt_g].delta_cd = pr.delta_cd,
   rslt_rec->rslt[rslt_cnt_g].delta_disp = delta_disp, rslt_rec->rslt[rslt_cnt_g].event_dt_tm =
   cnvtdatetime(re.event_dt_tm), rslt_rec->rslt[rslt_cnt_g].arg_less_great_flag = pr.less_great_flag,
   rslt_rec->rslt[rslt_cnt_g].arg_min_digits = 1, rslt_rec->rslt[rslt_cnt_g].arg_max_digits = 8,
   rslt_rec->rslt[rslt_cnt_g].arg_min_dec_places = 0,
   data_map_level = 0
  DETAIL
   IF (data_map_exists="Y")
    IF (data_map_level <= 2
     AND dm.service_resource_cd > 0
     AND dm.service_resource_cd=pr.service_resource_cd)
     data_map_level = 3, rslt_rec->rslt[rslt_cnt_g].arg_min_digits = dm.min_digits, rslt_rec->rslt[
     rslt_cnt_g].arg_max_digits = dm.max_digits,
     rslt_rec->rslt[rslt_cnt_g].arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level <= 1
     AND dm.service_resource_cd > 0.0
     AND rg_exists="Y"
     AND rg.parent_service_resource_cd=dm.service_resource_cd
     AND rg.child_service_resource_cd=pr.service_resource_cd)
     data_map_level = 2, rslt_rec->rslt[rslt_cnt_g].arg_min_digits = dm.min_digits, rslt_rec->rslt[
     rslt_cnt_g].arg_max_digits = dm.max_digits,
     rslt_rec->rslt[rslt_cnt_g].arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level=0
     AND dm.service_resource_cd=0)
     data_map_level = 1, rslt_rec->rslt[rslt_cnt_g].arg_min_digits = dm.min_digits, rslt_rec->rslt[
     rslt_cnt_g].arg_max_digits = dm.max_digits,
     rslt_rec->rslt[rslt_cnt_g].arg_min_dec_places = dm.min_decimal_places
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(rslt_rec->rslt,rslt_cnt_g)
  WITH nocounter, outerjoin(d_dm), outerjoin(d_rg)
 ;end select
#output_report
 IF (report_type != "EXPORT")
  DECLARE no_flag = c1
  SET select_ok_ind = 0
  SET rpt_cnt = 0
  EXECUTE cpm_create_file_name_logical "bbt_trans_cmte", "txt", "x"
  SELECT
   IF (by_patient_ind="Y")
    ORDER BY patient_name_sort, trans_time, table_ind,
     pe_trans_time, o_trans_time, collected_time,
     order_id_sort, dispense_prov_id_sort, ptr_sequence_sort,
     result_id_sort
   ELSEIF (by_physician_ind="Y")
    ORDER BY physician_name_sort, patient_name_sort, trans_time,
     table_ind, pe_trans_time, o_trans_time,
     collected_time, order_id_sort, dispense_prov_id_sort,
     result_id_sort
   ELSE
   ENDIF
   INTO cpm_cfn_info->file_name_logical
   table_ind = decode(d_o.seq,"2o ",d_pe.seq,"1pe","9xxx"), trans_time = decode(d_pe.seq,pe_rec->pe[
    d_pe.seq].trans_time,d_o.seq,ord_rec->ord[d_o.seq].trans_time,999999999999999.9), sort_time =
   decode(d_pe.seq,pe_rec->pe[d_pe.seq].trans_time,d_o.seq,ord_rec->ord[d_o.seq].collected_time,
    999999999999999.9),
   patient_name_sort = per_rec->per[d_per.seq].patient_name_sort, encntr_id = per_rec->per[d_per.seq]
   .encntr_id, person_id = per_rec->per[d_per.seq].person_id,
   dispense_prov_id = per_rec->per[d_per.seq].dispense_prov_id, dispense_prov_id_sort = decode(d_per
    .seq,format(per_rec->per[d_per.seq].dispense_prov_id,"##################;p0"),
    "000000000000000000"), physician_name_sort = per_rec->per[d_per.seq].physician_name_sort,
   product_event_id = pe_rec->pe[d_pe.seq].product_event_id, pe_trans_time = pe_rec->pe[d_pe.seq].
   trans_time, trans_dt_tm = pe_rec->pe[d_pe.seq].event_dt_tm,
   order_id = ord_rec->ord[d_o.seq].order_id, order_id_sort = decode(d_o.seq,format(ord_rec->ord[d_o
     .seq].order_id,"##################;p0"),"000000000000000000"), accession = ord_rec->ord[d_o.seq]
   .accession,
   o_trans_time = ord_rec->ord[d_o.seq].trans_time, collected_time = ord_rec->ord[d_o.seq].
   collected_time, collected_dt_tm = ord_rec->ord[d_o.seq].collected_dt_tm,
   ptr.sequence, ptr_sequence_sort = decode(ptr.sequence,format(ptr.sequence,"##########;p0"),
    "0000000000"), result_ind = decode(d_r.seq,"Y","N"),
   result_id = rslt_rec->rslt[d_r.seq].result_id, result_id_sort = decode(d_r.seq,format(rslt_rec->
     rslt[d_r.seq].result_id,"##################;p0"),"000000000000000000"), detail_mnemonic =
   rslt_rec->rslt[d_r.seq].mnemonic,
   minimize_order_by_for_physician = concat(format(ord_rec->ord[d_o.seq].order_id,
     "##################.##;p0;f")," ",format(per_rec->per[d_per.seq].dispense_prov_id,
     "##################.##;p0;f")," ",format(rslt_rec->rslt[d_r.seq].result_id,
     "##################.##;p0;f"))
   FROM (dummyt d_per  WITH seq = value(per_cnt)),
    (dummyt d1  WITH seq = 1),
    (dummyt d_pe  WITH seq = value(pe_cnt)),
    (dummyt d_tc  WITH seq = value(trans_cat_cnt)),
    (dummyt d_o  WITH seq = value(ord_cnt)),
    (dummyt d_r_r  WITH seq = 1),
    (dummyt d_r  WITH seq = value(rslt_cnt_g)),
    profile_task_r ptr
   PLAN (d_per)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (((d_pe
    WHERE (pe_rec->pe[d_pe.seq].encntr_id=per_rec->per[d_per.seq].encntr_id)
     AND (pe_rec->pe[d_pe.seq].dispense_prov_id=per_rec->per[d_per.seq].dispense_prov_id))
    ) ORJOIN ((d_tc
    WHERE (trans_cat_rec->trans_cat[d_tc.seq].encntr_id=per_rec->per[d_per.seq].encntr_id)
     AND (trans_cat_rec->trans_cat[d_tc.seq].dispense_prov_id=per_rec->per[d_per.seq].
    dispense_prov_id))
    JOIN (d_o
    WHERE (ord_rec->ord[d_o.seq].encntr_id=trans_cat_rec->trans_cat[d_tc.seq].encntr_id)
     AND (ord_rec->ord[d_o.seq].trans_time=trans_cat_rec->trans_cat[d_tc.seq].trans_time)
     AND (ord_rec->ord[d_o.seq].catalog_cd=trans_cat_rec->trans_cat[d_tc.seq].catalog_cd))
    JOIN (d_r_r
    WHERE d_r_r.seq=1)
    JOIN (d_r
    WHERE (rslt_rec->rslt[d_r.seq].order_id=ord_rec->ord[d_o.seq].order_id))
    JOIN (ptr
    WHERE (ptr.task_assay_cd=rslt_rec->rslt[d_r.seq].task_assay_cd)
     AND (ptr.catalog_cd=ord_rec->ord[d_o.seq].catalog_cd))
    ))
   HEAD REPORT
    dispense_prov_id_hd = 0.0, new_physician_ind = "N", print_physician_ind = "Y",
    person_id_hd = 0.0, new_person_ind = "N", print_person_ind = "N",
    encntr_id_hd = 0.0, new_encntr_ind = "N", patient_name = fillstring(40," "),
    birth_dt_tm = cnvtdatetime(null), birth_tz = 0, mrn_alias = fillstring(20," "),
    fin_alias = fillstring(20," "), fac_location = fillstring(20," "), medical_service = fillstring(
     20," "),
    first_trans_ind = "Y", trans_time_hd = 0.0, new_trans_time_ind = "N",
    trans_row_cnt = 0, rpt_pe_cnt = 0, dta = 0,
    tca = 0, order_id_hd = 0.0, new_order_ind = "N",
    rpt_ord_cnt = 0, pre_cnt = 0, post_cnt = 0,
    result_id_hd = 0.0, new_result_ind = "N", rslt_cnt = 0,
    rslt = 0, chk_row_cnt = 0, beg_dt_tm = cnvtdatetime(request->beg_dt_tm),
    end_dt_tm = cnvtdatetime(request->end_dt_tm), underscore_line = fillstring(130,"_"), dash_line =
    concat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - ",
     "- - - - - - - - - - - - - - - - - - - - -"),
    solid_dash_line = fillstring(130,"-"), equal_line = fillstring(130,"="), last_trans_row = 0,
    select_ok_ind = 0, result_value = fillstring(17," "), tc_prod_idx = 0,
    tc_search_idx = 0, tc_with_assoc_assays_exists = 0,
    MACRO (foot_trans_time)
     IF (rpt_pe_cnt > 0)
      IF (print_person_ind="Y")
       print_person_ind = "N", chk_row_cnt = 5
       IF (rpt_ord_cnt > 0
        AND pre_cnt > 0)
        IF ((rpt_ord_rec->ord[1].rslt_cnt > 0))
         chk_row_cnt += rpt_ord_rec->ord[1].rslt_cnt
        ELSE
         chk_row_cnt += 1
        ENDIF
       ENDIF
       IF (((chk_row_cnt+ row) > 58))
        row + 1
        IF (by_physician_ind
         AND print_physician_ind="Y")
         col 001, equal_line, print_physician_ind = "N"
        ELSE
         col 001, solid_dash_line
        ENDIF
        foot_page, BREAK
       ENDIF
       row + 1
       IF (new_page_ind="Y")
        new_page_ind = "N", col 001, equal_line
       ELSEIF (((by_physician_ind != "Y") OR (by_physician_ind="Y"
        AND print_physician_ind != "Y")) )
        col 001, solid_dash_line
       ELSEIF (by_physician_ind="Y"
        AND print_physician_ind="Y")
        col 001, equal_line, print_physician_ind = "N"
       ENDIF
       row + 1, col 001, patient_name,
       col 046, captions->date_of_birth
       IF (curutc=1)
        birth_datetime = format(datetimezone(birth_dt_tm,birth_tz),"@DATETIMECONDENSED;4;q")
       ELSE
        birth_datetime = format(birth_dt_tm,"@DATETIMECONDENSED;;d")
       ENDIF
       col 061, birth_datetime
      ENDIF
      chk_row_cnt = 4
      IF (rpt_ord_cnt > 0
       AND pre_cnt > 0)
       IF ((rpt_ord_rec->ord[1].rslt_cnt > 0))
        chk_row_cnt += rpt_ord_rec->ord[1].rslt_cnt
       ELSE
        chk_row_cnt += 1
       ENDIF
      ENDIF
      IF (((chk_row_cnt+ row) > 58))
       row + 1, col 001, dash_line,
       foot_page, BREAK
      ENDIF
      row + 1
      IF (new_page_ind="Y")
       new_page_ind = "N", col 001, equal_line
      ELSE
       col 001, dash_line
      ENDIF
      row + 1, col 003, captions->medical_record_num,
      col 008, mrn_alias"####################", col 031,
      captions->financial_num, col 036, fin_alias"####################",
      col 058, captions->loc_facility, col 068,
      fac_location"####################", col 095, captions->medical_service,
      col 108, medical_service"####################", new_encntr_ind = "N"
      IF (pre_cnt > 0)
       tc_with_assoc_assays_exists = 1, row + 2, col 003,
       captions->pre_transfusion_tests
       FOR (ord = 1 TO pre_cnt)
         IF (ord=1)
          chk_row_cnt = 0
         ELSE
          chk_row_cnt = 1
         ENDIF
         IF ((rpt_ord_rec->ord[ord].rslt_cnt > 0))
          chk_row_cnt += rpt_ord_rec->ord[ord].rslt_cnt
         ELSE
          chk_row_cnt += 1
         ENDIF
         IF (((row+ chk_row_cnt) > 58))
          foot_page, BREAK, new_page_ind = "N",
          row + 1, col 001, equal_line
         ENDIF
         print_order
       ENDFOR
      ELSE
       tc_with_assoc_assays_exists = 0
       FOR (pe = 1 TO rpt_pe_cnt)
        tc_prod_idx = locateval(tc_search_idx,1,tc_cnt,rpt_pe_rec->pe[pe].product_cd,tc_rec->
         trns_cmte[tc_search_idx].product_cd),
        IF ((tc_rec->trns_cmte[tc_prod_idx].assoc_assays_exist=1))
         row + 2, col 003, captions->pre_transfusion_tests,
         col 028, captions->no_pre_transfusion, pe = rpt_pe_cnt,
         tc_with_assoc_assays_exists = 1
        ENDIF
       ENDFOR
      ENDIF
      row + 2
      IF (((row+ 1) > 58))
       foot_page, BREAK, new_page_ind = "N",
       row + 1, col 001, equal_line,
       row + 1
      ENDIF
      col 003, captions->transfusion, col 016,
      captions->physician, col 037, captions->product_type,
      col 060, captions->product_aborh, col 076,
      captions->product_number,
      CALL center(captions->quantity,95,103), col 104,
      captions->dispense_to, col 119, captions->date_time,
      row + 1, col 076, captions->serial_number
      FOR (pe = 1 TO rpt_pe_cnt)
        IF (((row+ 1) >= 55))
         foot_page, BREAK, row + 1,
         col 001, equal_line
        ENDIF
        row + 1, col 016, rpt_pe_rec->pe[pe].physician_name,
        col 041, rpt_pe_rec->pe[pe].product_disp, col 060,
        rpt_pe_rec->pe[pe].abo_rh_disp, col 076, rpt_pe_rec->pe[pe].product_nbr
        IF ((rpt_pe_rec->pe[pe].quantity > 0)
         AND (rpt_pe_rec->pe[pe].iu > 0))
         CALL center(build(cnvtstring(rpt_pe_rec->pe[pe].quantity),"/",cnvtstring(rpt_pe_rec->pe[pe].
           iu)),95,103)
        ELSEIF ((rpt_pe_rec->pe[pe].quantity > 0))
         CALL center(trim(cnvtstring(rpt_pe_rec->pe[pe].quantity)),95,103)
        ENDIF
        col 104, rpt_pe_rec->pe[pe].dispense_to, col 119,
        rpt_pe_rec->pe[pe].event_dt_tm"@DATETIMECONDENSED;;d"
        IF ((rpt_pe_rec->pe[pe].serial_number != null))
         row + 1, col 076, rpt_pe_rec->pe[pe].serial_number
        ENDIF
      ENDFOR
      row + 1, chk_row_cnt = 1
      IF (rpt_ord_cnt > 0
       AND post_cnt > 0)
       IF ((ord=(pre_cnt+ 1)))
        chk_row_cnt = chk_row_cnt
       ELSE
        chk_row_cnt += 1
       ENDIF
       IF ((rpt_ord_rec->ord[(pre_cnt+ 1)].rslt_cnt > 0))
        chk_row_cnt += rpt_ord_rec->ord[(pre_cnt+ 1)].rslt_cnt
       ELSE
        chk_row_cnt += 1
       ENDIF
      ENDIF
      IF (((chk_row_cnt+ row) > 58))
       foot_page, BREAK, new_page_ind = "N",
       row + 1, col 001, equal_line
      ENDIF
      IF (post_cnt > 0)
       row + 1, col 003, captions->post_transfusion_tests
       FOR (ord = (pre_cnt+ 1) TO rpt_ord_cnt)
         IF ((ord=(pre_cnt+ 1)))
          chk_row_cnt = 0
         ELSE
          chk_row_cnt = 1
         ENDIF
         IF ((rpt_ord_rec->ord[ord].rslt_cnt > 0))
          chk_row_cnt += rpt_ord_rec->ord[ord].rslt_cnt
         ELSE
          chk_row_cnt += 1
         ENDIF
         IF (((row+ chk_row_cnt) > 58))
          foot_page, BREAK, new_page_ind = "N",
          row + 1, col 001, equal_line
         ENDIF
         print_order
       ENDFOR
      ELSE
       IF (tc_with_assoc_assays_exists=1)
        row + 1, col 003, captions->post_transfusion_tests,
        col 028, captions->no_post_transfusion, pe = rpt_pe_cnt
       ENDIF
      ENDIF
      last_trans_row = row
     ENDIF
    ENDMACRO
    ,
    MACRO (print_order)
     IF (ord != 1
      AND (ord != (pre_cnt+ 1)))
      row + 1
     ENDIF
     col 028, rpt_ord_rec->ord[ord].accession, col 050,
     rpt_ord_rec->ord[ord].order_mnemonic, col 072, rpt_ord_rec->ord[ord].collected_dt_tm
     "@DATETIMECONDENSED;;d",
     col 089, captions->collected
     IF ((rpt_ord_rec->ord[ord].rslt_cnt > 0))
      rslt = 0
      FOR (rslt = 1 TO rpt_ord_rec->ord[ord].rslt_cnt)
        row + 1, col 052, rpt_ord_rec->ord[ord].results[rslt].mnemonic,
        col 074, rpt_ord_rec->ord[ord].results[rslt].event_dt_tm"@DATETIMECONDENSED;;d", col 091,
        rpt_ord_rec->ord[ord].results[rslt].result_status_disp, col 108, rpt_ord_rec->ord[ord].
        results[rslt].result,
        col 127, rpt_ord_rec->ord[ord].results[rslt].result_flags
      ENDFOR
     ELSE
      row + 1, col 074, captions->not_resulted
     ENDIF
    ENDMACRO
    ,
    MACRO (foot_page)
     row 59, col 001, underscore_line,
     row + 1, col 001, captions->rpt_id,
     col 060, captions->rpt_page, col 067,
     curpage"###", col 108, captions->printed,
     col 117, curdate"@DATECONDENSED;;d", col 126,
     curtime"@TIMENOSECONDS;;M", row + 1, col 113,
     captions->printed_by, col 117, reportbyusername"##############"
    ENDMACRO
   HEAD PAGE
    new_page_ind = "Y", row 0,
    CALL center(captions->transfusion_report,1,132),
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
    row + 1, col 34, captions->begin_date,
    col 50, beg_dt_tm"@DATETIMECONDENSED;;d", col 73,
    captions->end_date, col 86, end_dt_tm"@DATETIMECONDENSED;;d",
    row + 2, col 001, captions->owner_area
    IF ((request->cur_owner_area_cd > 0))
     col 019, owner_area_disp
    ELSE
     col 019, captions->all
    ENDIF
    col 040, captions->inv_area
    IF ((request->cur_inv_area_cd > 0))
     col 056, inv_area_disp
    ELSE
     col 056, captions->all
    ENDIF
    row + 2, col 001, captions->product_category
    IF ((request->product_cat_cd > 0))
     col 019, product_cat_disp
    ELSE
     col 019, captions->all
    ENDIF
    col 051, captions->abo
    IF ((request->abo_cd > 0))
     col 056, abo_disp
    ELSE
     col 056, captions->all
    ENDIF
    col 070, captions->rh
    IF ((request->rh_cd > 0))
     col 074, rh_disp
    ELSE
     col 074, captions->all
    ENDIF
    row + 2, col 001, captions->patient
    IF (individual_id > 0)
     col 010, individual_name
    ELSE
     col 010, captions->all
    ENDIF
    col 045, captions->physician_filter
    IF (physician_id > 0)
     col 056, physician_name_filter
    ELSE
     col 056, captions->all
    ENDIF
    row + 2, col 050, captions->ordered_procedure,
    row + 1, col 001, captions->patient_name,
    col 028, captions->accession, col 050,
    captions->detailed_procedure, col 072, captions->date_time2,
    col 089, captions->status, col 108,
    captions->result, col 124, captions->flag
   HEAD dispense_prov_id
    IF (dispense_prov_id != dispense_prov_id_hd
     AND by_physician_ind="Y")
     new_physician_ind = "Y", dispense_prov_id_hd = dispense_prov_id, person_id_hd = 0.0,
     encntr_id_hd = 0.0, trans_time_hd = 0.0, order_id_hd = 0.0,
     result_id_hd = 0.0
    ENDIF
   HEAD person_id
    IF (person_id != person_id_hd)
     new_person_ind = "Y", person_id_hd = person_id, encntr_id_hd = 0.0,
     trans_time_hd = 0.0, order_id_hd = 0.0, result_id_hd = 0.0
    ENDIF
   HEAD encntr_id
    IF (encntr_id != encntr_id_hd)
     new_encntr_ind = "Y", encntr_id_hd = encntr_id, trans_time_hd = 0.0,
     order_id_hd = 0.0, result_id_hd = 0.0
    ENDIF
   HEAD trans_time
    IF (trans_time != trans_time_hd)
     IF (first_trans_ind="Y")
      first_trans_ind = "N"
     ELSE
      foot_trans_time
     ENDIF
     new_trans_time_ind = "Y", trans_time_hd = trans_time, rpt_ord_cnt = 0,
     valid_order_ind = "N", stat = alterlist(rpt_ord_rec->ord,0), stat = alterlist(rpt_ord_rec->ord,
      10),
     pre_cnt = 0, post_cnt = 0, rpt_pe_cnt = 0,
     stat = alterlist(rpt_pe_rec->pe,0), stat = alterlist(rpt_pe_rec->pe,10), rpt_pe_rec->trans_time
      = trans_time,
     dta_cnt = 0, dta = 0, stat = alterlist(dta_rec->dta,0),
     stat = alterlist(dta_rec->dta,10), tca = 0, order_id_hd = 0.0,
     result_id_hd = 0.0
    ENDIF
   HEAD order_id
    IF (trim(table_ind)="2o")
     IF (order_id != order_id_hd)
      new_order_ind = "Y", order_id_hd = order_id, result_id_hd = 0.0
     ENDIF
    ENDIF
   HEAD result_id
    IF (trim(table_ind)="2o")
     IF (result_id != result_id_hd)
      new_result_ind = "Y", result_id_hd = result_id
     ENDIF
    ENDIF
   DETAIL
    IF (new_physician_ind="Y")
     print_physician_ind = "Y", new_physician_ind = "N"
    ENDIF
    IF (new_person_ind="Y")
     new_person_ind = "N", print_person_ind = "Y"
    ENDIF
    patient_name = per_rec->per[d_per.seq].patient_name, birth_dt_tm = cnvtdatetime(per_rec->per[
     d_per.seq].birth_dt_tm), birth_tz = validate(per_rec->per[d_per.seq].birth_tz,0),
    new_encntr_ind = "N", mrn_alias = per_rec->per[d_per.seq].mrn_alias, fin_alias = per_rec->per[
    d_per.seq].fin_alias,
    medical_service = per_rec->per[d_per.seq].medicalservice, fac_location = per_rec->per[d_per.seq].
    fac_location, new_trans_time_ind = "N"
    IF (trim(table_ind)="1pe")
     IF ((pe_rec->pe[d_pe.seq].product_event_id > 0)
      AND (pe_rec->pe[d_pe.seq].product_event_id != null))
      rpt_pe_cnt += 1
      IF (mod(rpt_pe_cnt,10)=1
       AND rpt_pe_cnt != 1)
       stat = alterlist(rpt_pe_rec->pe,(rpt_pe_cnt+ 9))
      ENDIF
      rpt_pe_rec->pe[rpt_pe_cnt].product_cd = pe_rec->pe[d_pe.seq].product_cd, rpt_pe_rec->pe[
      rpt_pe_cnt].product_disp = pe_rec->pe[d_pe.seq].product_disp, rpt_pe_rec->pe[rpt_pe_cnt].
      product_nbr = pe_rec->pe[d_pe.seq].product_nbr,
      rpt_pe_rec->pe[rpt_pe_cnt].serial_number = pe_rec->pe[d_pe.seq].serial_number, rpt_pe_rec->pe[
      rpt_pe_cnt].abo_rh_disp = concat(trim(pe_rec->pe[d_pe.seq].abo_disp)," ",trim(pe_rec->pe[d_pe
        .seq].rh_disp)), rpt_pe_rec->pe[rpt_pe_cnt].quantity = pe_rec->pe[d_pe.seq].quantity,
      rpt_pe_rec->pe[rpt_pe_cnt].iu = pe_rec->pe[d_pe.seq].iu, rpt_pe_rec->pe[rpt_pe_cnt].event_dt_tm
       = cnvtdatetime(pe_rec->pe[d_pe.seq].event_dt_tm), rpt_pe_rec->pe[rpt_pe_cnt].physician_name =
      pe_rec->pe[d_pe.seq].physician_name,
      rpt_pe_rec->pe[rpt_pe_cnt].dispense_to = pe_rec->pe[d_pe.seq].dispense_to
     ENDIF
     product_found_ind = "N", dta = 0
     FOR (dta = 1 TO dta_cnt)
       IF ((dta_rec->dta[dta].product_cd=pe_rec->pe[d_pe.seq].product_cd))
        product_found_ind = "Y", dta = dta_cnt
       ENDIF
     ENDFOR
     IF (product_found_ind="N")
      FOR (tca = 1 TO tca_cnt)
        IF ((tca_rec->tca[tca].product_cd=pe_rec->pe[d_pe.seq].product_cd))
         product_found_ind = "Y", dta_cnt += 1
         IF (mod(dta_cnt,10)=1
          AND dta_cnt != 1)
          stat = alterlist(dta_rec->dta,(dta_cnt+ 9))
         ENDIF
         dta_rec->dta[dta_cnt].product_cd = tca_rec->tca[tca].product_cd, dta_rec->dta[dta_cnt].
         task_assay_cd = tca_rec->tca[tca].task_assay_cd, dta_rec->dta[dta_cnt].mnemonic = tca_rec->
         tca[tca].detail_mnemonic,
         dta_rec->dta[dta_cnt].pre_time = (trans_time - (tca_rec->tca[tca].pre_hours * 60)), dta_rec
         ->dta[dta_cnt].post_time = (trans_time+ (tca_rec->tca[tca].post_hours * 60))
        ELSEIF (product_found_ind="Y")
         tca = tca_cnt
        ENDIF
      ENDFOR
     ENDIF
    ELSEIF (trim(table_ind)="2o")
     IF (new_order_ind="Y")
      valid_order_ind = "N", cat = 0, catalog_found_ind = "N"
      FOR (cat = 1 TO cat_task_cnt)
        IF ((cat_task_rec->cat_task[cat].catalog_cd=ord_rec->ord[d_o.seq].catalog_cd))
         catalog_found_ind = "Y", dta = 0
         FOR (dta = 1 TO dta_cnt)
           IF ((dta_rec->dta[dta].task_assay_cd=cat_task_rec->cat_task[cat].task_assay_cd))
            IF ((collected_time >= dta_rec->dta[dta].pre_time)
             AND (collected_time <= dta_rec->dta[dta].post_time))
             valid_order_ind = "Y", dta = dta_cnt
            ENDIF
           ENDIF
         ENDFOR
        ELSEIF (catalog_found_ind="Y")
         cat = cat_task_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (new_order_ind="Y"
      AND valid_order_ind="Y")
      new_order_ind = "N"
      IF (collected_time <= trans_time)
       pre_cnt += 1
      ELSE
       post_cnt += 1
      ENDIF
      rpt_ord_cnt += 1
      IF (mod(rpt_ord_cnt,10)=1
       AND rpt_ord_cnt != 1)
       stat = alterlist(rpt_ord_rec->ord,(rpt_ord_cnt+ 9))
      ENDIF
      rpt_ord_rec->ord[rpt_ord_cnt].accession = ord_rec->ord[d_o.seq].accession, rpt_ord_rec->ord[
      rpt_ord_cnt].order_mnemonic = ord_rec->ord[d_o.seq].order_mnemonic, rpt_ord_rec->ord[
      rpt_ord_cnt].collected_dt_tm = cnvtdatetime(ord_rec->ord[d_o.seq].collected_dt_tm),
      rpt_ord_rec->ord[rpt_ord_cnt].order_status_disp = ord_rec->ord[d_o.seq].order_status_disp,
      rslt_cnt = 0, stat = alterlist(rpt_ord_rec->ord[rpt_ord_cnt].results,10)
     ENDIF
     IF (new_result_ind="Y"
      AND result_ind="Y"
      AND valid_order_ind="Y")
      new_result_ind = "N", dta_found_ind = "N", dta_pre_time = 0.0,
      dta_post_time = 0.0
      FOR (dta = 1 TO dta_cnt)
        IF ((dta_rec->dta[dta].task_assay_cd=rslt_rec->rslt[d_r.seq].task_assay_cd))
         dta_found_ind = "Y"
         IF ((dta_rec->dta[dta].pre_time > dta_pre_time))
          dta_pre_time = dta_rec->dta[dta].pre_time
         ENDIF
         IF ((dta_rec->dta[dta].post_time > dta_post_time))
          dta_post_time = dta_rec->dta[dta].post_time
         ENDIF
        ENDIF
      ENDFOR
      IF (dta_found_ind="Y")
       IF ((ord_rec->ord[d_o.seq].collected_time >= dta_pre_time)
        AND (ord_rec->ord[d_o.seq].collected_time <= dta_post_time))
        rslt_cnt += 1
        IF (mod(rslt_cnt,10)=1
         AND rslt_cnt != 1)
         stat = alterlist(rpt_ord_rec->ord[rpt_ord_cnt].results,(rslt_cnt+ 9))
        ENDIF
        rpt_ord_rec->ord[rpt_ord_cnt].rslt_cnt = rslt_cnt, n = "", c = "",
        r = "", d = "", rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].mnemonic = rslt_rec->rslt[d_r
        .seq].mnemonic,
        rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].event_dt_tm = cnvtdatetime(rslt_rec->rslt[d_r
         .seq].event_dt_tm), rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result_status_disp =
        rslt_rec->rslt[d_r.seq].result_status_disp
        IF (trim(rslt_rec->rslt[d_r.seq].result_value_alpha) > "")
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = rslt_rec->rslt[d_r.seq].
         result_value_alpha
        ELSEIF ((rslt_rec->rslt[d_r.seq].result_value_numeric != 0)
         AND (rslt_rec->rslt[d_r.seq].result_value_numeric != null))
         arg_min_digits = rslt_rec->rslt[d_r.seq].arg_min_digits, arg_max_digits = rslt_rec->rslt[d_r
         .seq].arg_max_digits, arg_min_dec_places = rslt_rec->rslt[d_r.seq].arg_min_dec_places,
         arg_less_great_flag = rslt_rec->rslt[d_r.seq].arg_less_great_flag, arg_raw_value = rslt_rec
         ->rslt[d_r.seq].result_value_numeric, result_value = fillstring(17," "),
         result_value = uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
          arg_less_great_flag,arg_raw_value), rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result
          = result_value
        ELSEIF (trim(rslt_rec->rslt[d_r.seq].ascii_text) > "")
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = rslt_rec->rslt[d_r.seq].ascii_text
        ELSEIF ((rslt_rec->rslt[d_r.seq].result_code_set_cd > 0)
         AND (rslt_rec->rslt[d_r.seq].result_code_set_cd != null))
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = rslt_rec->rslt[d_r.seq].
         result_code_set_disp
        ELSEIF ((rslt_rec->rslt[d_r.seq].long_text_id > 0)
         AND (rslt_rec->rslt[d_r.seq].long_text_id != null))
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = "<Text,check online>"
        ELSEIF ((rslt_rec->rslt[d_r.seq].nomenclature_id <= 0))
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = "<Blank>"
        ELSE
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = "<Unknown>"
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].normal_cd > 0))
         n = rslt_rec->rslt[d_r.seq].normal_disp
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].critical_cd > 0))
         c = rslt_rec->rslt[d_r.seq].critical_disp
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].review_cd > 0))
         r = rslt_rec->rslt[d_r.seq].review_disp
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].delta_cd > 0))
         d = rslt_rec->rslt[d_r.seq].delta_disp
        ENDIF
        rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result_flags = concat(n,c,r,d)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    foot_trans_time
    IF (last_trans_row > 0)
     call reportmove('ROW',(last_trans_row+ 1),0)
    ELSE
     row + 1
    ENDIF
    col 001, equal_line, foot_page,
    row 62, col 053, captions->end_of_report,
    report_complete_ind = "Y", select_ok_ind = 1
   WITH nocounter, outerjoin(d_r_r), maxrow = 9999,
    nullreport, nolandscape, compress
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "S"
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = "get product_event rows"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "ZERO:  No data found for specified date range"
   GO TO exit_script
  ENDIF
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "print transfusion committee report"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
  IF (report_complete_ind="Y")
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "SCRIPT ERROR:  Report ended abnormally"
  ENDIF
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  IF (select_ok_ind=1)
   SET reply->status_data.status = "S"
  ENDIF
  IF (ops_ind="Y")
   SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
  ENDIF
 ENDIF
 IF (report_type != "PRINT")
  RECORD xml_tags(
    1 begin_date = vc
    1 end_date = vc
    1 owner_area = vc
    1 inv_area = vc
    1 product_category = vc
    1 abo = vc
    1 rh = vc
    1 patient = vc
    1 physician_filter = vc
    1 name = vc
    1 dob = vc
    1 mrn = vc
    1 fin = vc
    1 location = vc
    1 medicalservice = vc
    1 pre_trans_accession = vc
    1 pre_trans_procedure = vc
    1 pre_trans_collecteddatetime = vc
    1 pre_trans_collected = vc
    1 pre_trans_orderassay = vc
    1 pre_trans_eventdatetime = vc
    1 pre_trans_resultstatus = vc
    1 pre_trans_result = vc
    1 pre_trans_flags = vc
    1 physician = vc
    1 product = vc
    1 aborh = vc
    1 productnumber = vc
    1 qty = vc
    1 iu = vc
    1 transdatetime = vc
    1 post_trans_accession = vc
    1 post_trans_procedure = vc
    1 post_trans_collecteddatetime = vc
    1 post_trans_collected = vc
    1 post_trans_orderassay = vc
    1 post_trans_eventdatetime = vc
    1 post_trans_resultstatus = vc
    1 post_trans_result = vc
    1 post_trans_flags = vc
    1 all = vc
    1 dispense_to = vc
    1 serialnumber = vc
  )
  SET xml_tags->begin_date = uar_i18ngetmessage(i18nhandle,"begin_date","BEGIN_DATE")
  SET xml_tags->end_date = uar_i18ngetmessage(i18nhandle,"end_date","END_DATE")
  SET xml_tags->owner_area = uar_i18ngetmessage(i18nhandle,"owner_area","OWNER_AREA")
  SET xml_tags->inv_area = uar_i18ngetmessage(i18nhandle,"inv_area","INV_AREA")
  SET xml_tags->product_category = uar_i18ngetmessage(i18nhandle,"product_category",
   "PRODUCT_CATEGORY")
  SET xml_tags->abo = uar_i18ngetmessage(i18nhandle,"abo","ABO")
  SET xml_tags->rh = uar_i18ngetmessage(i18nhandle,"rh","RH")
  SET xml_tags->patient = uar_i18ngetmessage(i18nhandle,"patient","PATIENT")
  SET xml_tags->physician_filter = uar_i18ngetmessage(i18nhandle,"physician_filter",
   "PHYSICIAN_FILTER")
  SET xml_tags->name = uar_i18ngetmessage(i18nhandle,"name","NAME")
  SET xml_tags->dob = uar_i18ngetmessage(i18nhandle,"dob","DOB")
  SET xml_tags->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN")
  SET xml_tags->fin = uar_i18ngetmessage(i18nhandle,"fin","FIN")
  SET xml_tags->location = uar_i18ngetmessage(i18nhandle,"location","LOCATION")
  SET xml_tags->medicalservice = uar_i18ngetmessage(i18nhandle,"medicalservice","MEDICALSERVICE")
  SET xml_tags->pre_trans_accession = uar_i18ngetmessage(i18nhandle,"pre_trans_accession",
   "PRE-TRANS-ACCESSION")
  SET xml_tags->pre_trans_procedure = uar_i18ngetmessage(i18nhandle,"pre_trans_procedure",
   "PRE-TRANS-PROCEDURE")
  SET xml_tags->pre_trans_collecteddatetime = uar_i18ngetmessage(i18nhandle,
   "pre_trans_collecteddatetime","PRE-TRANS-COLLECTEDDATETIME")
  SET xml_tags->pre_trans_collected = uar_i18ngetmessage(i18nhandle,"pre_trans_collected",
   "PRE-TRANS-COLLECTED")
  SET xml_tags->pre_trans_orderassay = uar_i18ngetmessage(i18nhandle,"pre_trans_orderassay",
   "PRE-TRANS-ORDERASSAY")
  SET xml_tags->pre_trans_eventdatetime = uar_i18ngetmessage(i18nhandle,"pre_trans_eventdatetime",
   "PRE-TRANS-EVENTDATETIME")
  SET xml_tags->pre_trans_resultstatus = uar_i18ngetmessage(i18nhandle,"pre_trans_resultstatus",
   "PRE-TRANS-RESULTSTATUS")
  SET xml_tags->pre_trans_result = uar_i18ngetmessage(i18nhandle,"pre_trans_result",
   "PRE-TRANS-RESULT")
  SET xml_tags->pre_trans_flags = uar_i18ngetmessage(i18nhandle,"pre_trans_flags","PRE-TRANS-FLAGS")
  SET xml_tags->physician = uar_i18ngetmessage(i18nhandle,"physician","PHYSICIAN")
  SET xml_tags->product = uar_i18ngetmessage(i18nhandle,"product","PRODUCT")
  SET xml_tags->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABORH")
  SET xml_tags->productnumber = uar_i18ngetmessage(i18nhandle,"productnumber","PRODUCTNUMBER")
  SET xml_tags->qty = uar_i18ngetmessage(i18nhandle,"qty","QTY")
  SET xml_tags->iu = uar_i18ngetmessage(i18nhandle,"iu","IU")
  SET xml_tags->transdatetime = uar_i18ngetmessage(i18nhandle,"transdatetime","TRANSDATETIME")
  SET xml_tags->post_trans_accession = uar_i18ngetmessage(i18nhandle,"post_trans_accession",
   "POST-TRANS-ACCESSION")
  SET xml_tags->post_trans_procedure = uar_i18ngetmessage(i18nhandle,"post_trans_procedure",
   "POST-TRANS-PROCEDURE")
  SET xml_tags->post_trans_collecteddatetime = uar_i18ngetmessage(i18nhandle,
   "post_trans_collecteddatetime","POST-TRANS-COLLECTEDDATETIME")
  SET xml_tags->post_trans_collected = uar_i18ngetmessage(i18nhandle,"post_trans_collected",
   "POST-TRANS-COLLECTED")
  SET xml_tags->post_trans_orderassay = uar_i18ngetmessage(i18nhandle,"post_trans_orderassay",
   "POST-TRANS-ORDERASSAY")
  SET xml_tags->post_trans_eventdatetime = uar_i18ngetmessage(i18nhandle,"post_trans_eventdatetime",
   "POST-TRANS-EVENTDATETIME")
  SET xml_tags->post_trans_resultstatus = uar_i18ngetmessage(i18nhandle,"post_trans_resultstatus",
   "POST-TRANS-RESULTSTATUS")
  SET xml_tags->post_trans_result = uar_i18ngetmessage(i18nhandle,"post_trans_result",
   "POST-TRANS-RESULT")
  SET xml_tags->post_trans_flags = uar_i18ngetmessage(i18nhandle,"post_trans_flags",
   "POST-TRANS-FLAGS")
  SET xml_tags->all = uar_i18ngetmessage(i18nhandle,"all","ALL")
  SET xml_tags->dispense_to = uar_i18ngetmessage(i18nhandle,"dispense_to","DISPENSED-LOC")
  SET xml_tags->serialnumber = uar_i18ngetmessage(i18nhandle,"serialnumber","SERIALNUMBER")
  DECLARE no_flag = c1
  DECLARE first_patient_flag = c1
  DECLARE physicianname = vc WITH noconstant(fillstring(80," "))
  DECLARE accessionnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE transprocedure = vc WITH noconstant(fillstring(80," "))
  DECLARE patientname = vc WITH noconstant(fillstring(80," "))
  DECLARE medical_servicenonull = vc WITH noconstant(fillstring(80," "))
  DECLARE fac_locationnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE mrnnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE finnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE flagsnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE assaynonull = vc WITH noconstant(fillstring(80," "))
  DECLARE resultstatusnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE resultnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE productnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE aborhnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE productnumbernonull = vc WITH noconstant(fillstring(80," "))
  DECLARE qtynonull = vc WITH noconstant(fillstring(80," "))
  DECLARE iunonull = vc WITH noconstant(fillstring(80," "))
  DECLARE temp_str = vc WITH noconstant(fillstring(1," "))
  DECLARE dispense_locationnonull = vc WITH noconstant(fillstring(80," "))
  DECLARE serialnumbernonull = vc WITH noconstant(fillstring(20," "))
  SET first_patient_flag = "Y"
  SET select_ok_ind = 0
  EXECUTE cpm_create_file_name_logical "bbt_trans_cmte_xml", "xml", "d"
  SELECT
   IF (by_patient_ind="Y")
    ORDER BY patient_name_sort, trans_time, table_ind,
     pe_trans_time, o_trans_time, collected_time,
     order_id_sort, dispense_prov_id_sort, ptr_sequence_sort,
     result_id_sort
   ELSEIF (by_physician_ind="Y")
    ORDER BY physician_name_sort, patient_name_sort, trans_time,
     table_ind, pe_trans_time, o_trans_time,
     collected_time, order_id_sort, dispense_prov_id_sort,
     result_id_sort
   ELSE
   ENDIF
   INTO cpm_cfn_info->file_name_logical
   table_ind = decode(d_o.seq,"2o ",d_pe.seq,"1pe","9xxx"), trans_time = decode(d_pe.seq,pe_rec->pe[
    d_pe.seq].trans_time,d_o.seq,ord_rec->ord[d_o.seq].trans_time,999999999999999.9), sort_time =
   decode(d_pe.seq,pe_rec->pe[d_pe.seq].trans_time,d_o.seq,ord_rec->ord[d_o.seq].collected_time,
    999999999999999.9),
   patient_name_sort = per_rec->per[d_per.seq].patient_name_sort, encntr_id = per_rec->per[d_per.seq]
   .encntr_id, person_id = per_rec->per[d_per.seq].person_id,
   dispense_prov_id = per_rec->per[d_per.seq].dispense_prov_id, dispense_prov_id_sort = decode(d_per
    .seq,format(per_rec->per[d_per.seq].dispense_prov_id,"##################;p0"),
    "000000000000000000"), physician_name_sort = per_rec->per[d_per.seq].physician_name_sort,
   product_event_id = pe_rec->pe[d_pe.seq].product_event_id, pe_trans_time = pe_rec->pe[d_pe.seq].
   trans_time, trans_dt_tm = pe_rec->pe[d_pe.seq].event_dt_tm,
   order_id = ord_rec->ord[d_o.seq].order_id, order_id_sort = decode(d_o.seq,format(ord_rec->ord[d_o
     .seq].order_id,"##################;p0"),"000000000000000000"), accession = ord_rec->ord[d_o.seq]
   .accession,
   o_trans_time = ord_rec->ord[d_o.seq].trans_time, collected_time = ord_rec->ord[d_o.seq].
   collected_time, collected_dt_tm = ord_rec->ord[d_o.seq].collected_dt_tm,
   ptr.sequence, ptr_sequence_sort = decode(ptr.sequence,format(ptr.sequence,"##########;p0"),
    "0000000000"), result_ind = decode(d_r.seq,"Y","N"),
   result_id = rslt_rec->rslt[d_r.seq].result_id, result_id_sort = decode(d_r.seq,format(rslt_rec->
     rslt[d_r.seq].result_id,"##################;p0"),"000000000000000000"), detail_mnemonic =
   rslt_rec->rslt[d_r.seq].mnemonic,
   minimize_order_by_for_physician = concat(format(ord_rec->ord[d_o.seq].order_id,
     "##################.##;p0;f")," ",format(per_rec->per[d_per.seq].dispense_prov_id,
     "##################.##;p0;f")," ",format(rslt_rec->rslt[d_r.seq].result_id,
     "##################.##;p0;f"))
   FROM (dummyt d_per  WITH seq = value(per_cnt)),
    (dummyt d1  WITH seq = 1),
    (dummyt d_pe  WITH seq = value(pe_cnt)),
    (dummyt d_tc  WITH seq = value(trans_cat_cnt)),
    (dummyt d_o  WITH seq = value(ord_cnt)),
    (dummyt d_r_r  WITH seq = 1),
    (dummyt d_r  WITH seq = value(rslt_cnt_g)),
    profile_task_r ptr
   PLAN (d_per)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (((d_pe
    WHERE (pe_rec->pe[d_pe.seq].encntr_id=per_rec->per[d_per.seq].encntr_id)
     AND (pe_rec->pe[d_pe.seq].dispense_prov_id=per_rec->per[d_per.seq].dispense_prov_id))
    ) ORJOIN ((d_tc
    WHERE (trans_cat_rec->trans_cat[d_tc.seq].encntr_id=per_rec->per[d_per.seq].encntr_id)
     AND (trans_cat_rec->trans_cat[d_tc.seq].dispense_prov_id=per_rec->per[d_per.seq].
    dispense_prov_id))
    JOIN (d_o
    WHERE (ord_rec->ord[d_o.seq].encntr_id=trans_cat_rec->trans_cat[d_tc.seq].encntr_id)
     AND (ord_rec->ord[d_o.seq].trans_time=trans_cat_rec->trans_cat[d_tc.seq].trans_time)
     AND (ord_rec->ord[d_o.seq].catalog_cd=trans_cat_rec->trans_cat[d_tc.seq].catalog_cd))
    JOIN (d_r_r
    WHERE d_r_r.seq=1)
    JOIN (d_r
    WHERE (rslt_rec->rslt[d_r.seq].order_id=ord_rec->ord[d_o.seq].order_id))
    JOIN (ptr
    WHERE (ptr.task_assay_cd=rslt_rec->rslt[d_r.seq].task_assay_cd)
     AND (ptr.catalog_cd=ord_rec->ord[d_o.seq].catalog_cd))
    ))
   HEAD REPORT
    dispense_prov_id_hd = 0.0, new_physician_ind = "N", print_physician_ind = "Y",
    person_id_hd = 0.0, new_person_ind = "N", print_person_ind = "N",
    encntr_id_hd = 0.0, new_encntr_ind = "N", patient_name = fillstring(40," "),
    birth_dt_tm = cnvtdatetime(null), birth_tz = 0, mrn_alias = fillstring(20," "),
    fin_alias = fillstring(20," "), fac_location = fillstring(20," "), medical_service = fillstring(
     20," "),
    first_trans_ind = "Y", trans_time_hd = 0.0, new_trans_time_ind = "N",
    trans_row_cnt = 0, rpt_pe_cnt = 0, dta = 0,
    tca = 0, order_id_hd = 0.0, new_order_ind = "N",
    rpt_ord_cnt = 0, pre_cnt = 0, post_cnt = 0,
    result_id_hd = 0.0, new_result_ind = "N", rslt_cnt = 0,
    rslt = 0, beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->
     end_dt_tm),
    last_trans_row = 0, select_ok_ind = 0, result_value = fillstring(17," "),
    tc_prod_idx = 0, tc_search_idx = 0, tc_with_assoc_assays_exists = 0,
    col 0, "<?xml version='1.0' encoding='UTF-8'?>", row + 1,
    col 001, "<report>", row + 1,
    col 005, "<filters>", row + 1,
    col 009, "<", xml_tags->begin_date,
    ">", "<![CDATA[", beg_dt_tm"@DATETIMECONDENSED;;d",
    "]]>", "</", xml_tags->begin_date,
    ">", row + 1, col 009,
    "<", xml_tags->end_date, ">",
    "<![CDATA[", end_dt_tm"@DATETIMECONDENSED;;d", "]]>",
    "</", xml_tags->end_date, ">",
    row + 1
    IF ((request->cur_owner_area_cd > 0))
     temp_str = concat("<",xml_tags->owner_area,">","<![CDATA[",owner_area_disp,
      "]]>","</",xml_tags->owner_area,">"), col 009, temp_str,
     row + 1
    ELSE
     temp_str = concat("<",xml_tags->owner_area,">",xml_tags->all,"</",
      xml_tags->owner_area,">"), col 009, temp_str,
     row + 1
    ENDIF
    IF ((request->cur_inv_area_cd > 0))
     temp_str = concat("<",xml_tags->inv_area,">","<![CDATA[",inv_area_disp,
      "]]>","</",xml_tags->inv_area,">"), col 009, temp_str,
     row + 1
    ELSE
     temp_str = concat("<",xml_tags->inv_area,">",xml_tags->all,"</",
      xml_tags->inv_area,">"), col 009, temp_str,
     row + 1
    ENDIF
    IF ((request->product_cat_cd > 0))
     temp_str = concat("<",xml_tags->product_category,">","<![CDATA[",product_cat_disp,
      "]]>","</",xml_tags->product_category,">"), col 009, temp_str,
     row + 1
    ELSE
     temp_str = concat("<",xml_tags->product_category,">",xml_tags->all,"</",
      xml_tags->product_category,">"), col 009, temp_str,
     row + 1
    ENDIF
    IF ((request->abo_cd > 0))
     temp_str = concat("<",xml_tags->abo,">","<![CDATA[",abo_disp,
      "]]>","</",xml_tags->abo,">"), col 009, temp_str,
     row + 1
    ELSE
     temp_str = concat("<",xml_tags->abo,">",xml_tags->all,"</",
      xml_tags->abo,">"), col 009, temp_str,
     row + 1
    ENDIF
    IF ((request->rh_cd > 0))
     temp_str = concat("<",xml_tags->rh,">","<![CDATA[",rh_disp,
      "]]>","</",xml_tags->rh,">"), col 009, temp_str,
     row + 1
    ELSE
     temp_str = concat("<",xml_tags->rh,">",xml_tags->all,"</",
      xml_tags->rh,">"), col 009, temp_str,
     row + 1
    ENDIF
    IF (individual_id > 0)
     temp_str = concat("<",xml_tags->patient,">","<![CDATA[",individual_name,
      "]]>","</",xml_tags->patient,">"), col 009, temp_str,
     row + 1
    ELSE
     temp_str = concat("<",xml_tags->patient,">",xml_tags->all,"</",
      xml_tags->patient,">"), col 009, temp_str,
     row + 1
    ENDIF
    IF (physician_id > 0)
     temp_str = concat("<",xml_tags->physician_filter,">","<![CDATA[",physician_name_filter,
      "]]>","</",xml_tags->physician_filter,">"), col 009, temp_str,
     row + 1
    ELSE
     temp_str = concat("<",xml_tags->physician_filter,">",xml_tags->all,"</",
      xml_tags->physician_filter,">"), col 009, temp_str,
     row + 1
    ENDIF
    col 005, "</filters>", row + 1,
    col 005, "<patients>",
    MACRO (foot_trans_time_xml)
     IF (rpt_pe_cnt > 0)
      IF (print_person_ind="Y")
       print_person_ind = "N"
       IF (by_physician_ind
        AND print_physician_ind="Y")
        print_physician_ind = "N"
       ENDIF
       IF (by_physician_ind="Y"
        AND print_physician_ind="Y")
        print_physician_ind = "N"
       ENDIF
       IF (first_patient_flag="Y")
        first_patient_flag = "N"
       ELSE
        col 009, "</encounters>", row + 1,
        col 009, "</patient>", row + 1
       ENDIF
       IF (curutc=1)
        birth_datetime = format(datetimezone(birth_dt_tm,birth_tz),"@DATETIMECONDENSED;4;q")
       ELSE
        birth_datetime = format(birth_dt_tm,"@DATETIMECONDENSED;;d")
       ENDIF
       col 009, "<patient>", row + 1,
       patientname = " ", patientname = concat("<![CDATA[",trim(patient_name),"]]>"), col 013,
       "<", xml_tags->name, ">",
       patientname, "</", xml_tags->name,
       ">", row + 1, col 013,
       "<", xml_tags->dob, ">",
       "<![CDATA[", birth_datetime, "]]>",
       "</", xml_tags->dob, ">",
       row + 1, col 013, "<encounters>",
       row + 1
      ENDIF
      col 0013, "<encounter>", row + 1,
      mrnnonull = concat("<![CDATA[",trim(mrn_alias),"]]>"), col 017, "<",
      xml_tags->mrn, ">", mrnnonull,
      "</", xml_tags->mrn, ">",
      row + 1, finnonull = concat("<![CDATA[",trim(fin_alias),"]]>"), col 017,
      "<", xml_tags->fin, ">",
      finnonull, "</", xml_tags->fin,
      ">", row + 1, fac_locationnonull = concat("<![CDATA[",trim(fac_location),"]]>"),
      col 017, "<", xml_tags->location,
      ">", fac_locationnonull, "</",
      xml_tags->location, ">", row + 1,
      medical_servicenonull = concat("<![CDATA[",trim(medical_service),"]]>"), col 017, "<",
      xml_tags->medicalservice, ">", medical_servicenonull,
      "</", xml_tags->medicalservice, ">",
      row + 1, new_encntr_ind = "N"
      FOR (pe = 1 TO rpt_pe_cnt)
        col 21, "<transaction>", row + 1
        IF (pre_cnt > 0)
         tc_with_assoc_assays_exists = 1, col 017, "<pretransfusiontests>",
         row + 1
         FOR (ord = 1 TO pre_cnt)
           col 021, "<pretransfusiontest>", row + 1,
           print_pre_order, col 021, "</pretransfusiontest>",
           row + 1
         ENDFOR
         col 017, "</pretransfusiontests>", row + 1
        ELSE
         ord = 1, col 017, "<pretransfusiontests>",
         row + 1, col 021, "<pretransfusiontest>",
         row + 1, print_pre_order, col 021,
         "</pretransfusiontest>", row + 1, col 017,
         "</pretransfusiontests>", row + 1
        ENDIF
        col 017, "<transfusions>", row + 1,
        col 021, "<transfusion>", row + 1,
        physicianname = trim(rpt_pe_rec->pe[pe].physician_name,1), col 025, "<",
        xml_tags->physician, ">", "<![CDATA[",
        physicianname, "]]>", "</",
        xml_tags->physician, ">", row + 1,
        productnonull = concat("<![CDATA[",trim(rpt_pe_rec->pe[pe].product_disp),"]]>"), col 025, "<",
        xml_tags->product, ">", productnonull,
        "</", xml_tags->product, ">",
        row + 1, aborhnonull = concat("<![CDATA[",trim(rpt_pe_rec->pe[pe].abo_rh_disp),"]]>"), col
        025,
        "<", xml_tags->aborh, ">",
        aborhnonull, "</", xml_tags->aborh,
        ">", row + 1, productnumbernonull = concat("<![CDATA[",trim(rpt_pe_rec->pe[pe].product_nbr),
         "]]>"),
        col 025, "<", xml_tags->productnumber,
        ">", productnumbernonull, "</",
        xml_tags->productnumber, ">", row + 1
        IF ((rpt_pe_rec->pe[pe].serial_number != null))
         serialnumbernonull = concat("<![CDATA[",trim(rpt_pe_rec->pe[pe].serial_number),"]]>"), col
         025, "<",
         xml_tags->serialnumber, ">", serialnumbernonull,
         "</", xml_tags->serialnumber, ">",
         row + 1
        ELSE
         col 025, "<", xml_tags->serialnumber,
         "></", xml_tags->serialnumber, ">",
         row + 1
        ENDIF
        IF ((rpt_pe_rec->pe[pe].quantity > 0))
         qtynonull = concat("<![CDATA[",trim(cnvtstring(rpt_pe_rec->pe[pe].quantity)),"]]>"), col 025,
         "<",
         xml_tags->qty, ">", qtynonull,
         "</", xml_tags->qty, ">",
         row + 1
        ELSE
         col 025, "<", xml_tags->qty,
         "></", xml_tags->qty, ">",
         row + 1
        ENDIF
        IF ((rpt_pe_rec->pe[pe].iu > 0))
         iunonull = concat("<![CDATA[",trim(cnvtstring(rpt_pe_rec->pe[pe].iu)),"]]>"), col 025, "<",
         xml_tags->iu, ">", iunonull,
         "</", xml_tags->iu, ">",
         row + 1
        ELSE
         col 025, "<", xml_tags->iu,
         "></", xml_tags->iu, ">",
         row + 1
        ENDIF
        dispense_locationnonull = concat("<![CDATA[",trim(rpt_pe_rec->pe[pe].dispense_to),"]]>"), col
         025, "<",
        xml_tags->dispense_to, ">", dispense_locationnonull,
        "</", xml_tags->dispense_to, ">",
        row + 1, col 025, "<",
        xml_tags->transdatetime, ">", "<![CDATA[",
        rpt_pe_rec->pe[pe].event_dt_tm"@DATETIMECONDENSED;;d", "]]>", "</",
        xml_tags->transdatetime, ">", row + 1,
        col 021, "</transfusion>", row + 1,
        col 017, "</transfusions>", row + 1
        IF (post_cnt > 0)
         row + 1, col 017, "<posttransfusiontests>",
         row + 1
         FOR (ord = (pre_cnt+ 1) TO rpt_ord_cnt)
           col 021, "<posttransfusiontest>", row + 1,
           print_post_order, col 021, "</posttransfusiontest>",
           row + 1
         ENDFOR
         col 017, "</posttransfusiontests>", row + 1
        ELSE
         ord = 1, col 017, "<posttransfusiontests>",
         row + 1, col 021, "<posttransfusiontest>",
         row + 1, print_post_order, col 021,
         "</posttransfusiontest>", row + 1, col 017,
         "</posttransfusiontests>", row + 1
        ENDIF
        col 21, "</transaction>", row + 1
      ENDFOR
      last_trans_row = row, col 017, "</encounter>",
      row + 1
     ENDIF
    ENDMACRO
    ,
    MACRO (print_pre_order)
     accessionnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].accession),"]]>"), col 025, "<",
     xml_tags->pre_trans_accession, ">", accessionnonull,
     "</", xml_tags->pre_trans_accession, ">",
     row + 1, transprocedure = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].order_mnemonic),"]]>"),
     col 025,
     "<", xml_tags->pre_trans_procedure, ">",
     transprocedure, "</", xml_tags->pre_trans_procedure,
     ">", row + 1, col 025,
     "<", xml_tags->pre_trans_collecteddatetime, ">",
     rpt_ord_rec->ord[ord].collected_dt_tm"@DATETIMECONDENSED;;d", "</", xml_tags->
     pre_trans_collecteddatetime,
     ">", row + 1, col 025,
     "<", xml_tags->pre_trans_collected, ">",
     captions->collected, "</", xml_tags->pre_trans_collected,
     ">", row + 1
     IF ((rpt_ord_rec->ord[ord].rslt_cnt > 0))
      rslt = 0, col 025, "<assays>",
      row + 1
      FOR (rslt = 1 TO rpt_ord_rec->ord[ord].rslt_cnt)
        col 029, "<assay>", row + 1,
        assaynonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].mnemonic),"]]>"),
        col 033, "<",
        xml_tags->pre_trans_orderassay, ">", assaynonull,
        "</", xml_tags->pre_trans_orderassay, ">",
        row + 1, col 033, "<",
        xml_tags->pre_trans_eventdatetime, ">", "<![CDATA[",
        rpt_ord_rec->ord[ord].results[rslt].event_dt_tm"@DATETIMECONDENSED;;d", "]]>", "</",
        xml_tags->pre_trans_eventdatetime, ">", row + 1,
        resultstatusnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].
          result_status_disp),"]]>"), col 033, "<",
        xml_tags->pre_trans_resultstatus, ">", resultstatusnonull,
        "</", xml_tags->pre_trans_resultstatus, ">",
        row + 1, resultnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].result),
         "]]>"), col 033,
        "<", xml_tags->pre_trans_result, ">",
        resultnonull, "</", xml_tags->pre_trans_result,
        ">", row + 1, flagsnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].
          result_flags),"]]>"),
        col 033, "<", xml_tags->pre_trans_flags,
        ">", flagsnonull, "</",
        xml_tags->pre_trans_flags, ">", row + 1,
        col 029, "</assay>", row + 1
      ENDFOR
     ELSE
      col 025, "<assays>", row + 1,
      col 029, "<assay>", row + 1,
      col 033, "<", xml_tags->pre_trans_orderassay,
      "></", xml_tags->pre_trans_orderassay, ">",
      row + 1, col 033, "<",
      xml_tags->pre_trans_eventdatetime, "></", xml_tags->pre_trans_eventdatetime,
      ">", row + 1, col 033,
      "<", xml_tags->pre_trans_resultstatus, "></",
      xml_tags->pre_trans_resultstatus, ">", row + 1,
      col 033, "<", xml_tags->pre_trans_result,
      "></", xml_tags->pre_trans_result, ">",
      row + 1, col 033, "<",
      xml_tags->pre_trans_flags, "></", xml_tags->pre_trans_flags,
      ">", row + 1, col 029,
      "</assay>", row + 1
     ENDIF
     col 025, "</assays>", row + 1
    ENDMACRO
    ,
    MACRO (print_post_order)
     accessionnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].accession),"]]>"), col 025, "<",
     xml_tags->post_trans_accession, ">", accessionnonull,
     "</", xml_tags->post_trans_accession, ">",
     row + 1, orderprocedure = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].order_mnemonic),"]]>"),
     col 025,
     "<", xml_tags->post_trans_procedure, ">",
     orderprocedure, "</", xml_tags->post_trans_procedure,
     ">", row + 1, col 025,
     "<", xml_tags->post_trans_collecteddatetime, ">",
     rpt_ord_rec->ord[ord].collected_dt_tm"@DATETIMECONDENSED;;d", "</", xml_tags->
     post_trans_collecteddatetime,
     ">", row + 1, col 025,
     "<", xml_tags->post_trans_collected, ">",
     captions->collected, "</", xml_tags->post_trans_collected,
     ">", row + 1
     IF ((rpt_ord_rec->ord[ord].rslt_cnt > 0))
      rslt = 0, col 025, "<assays>",
      row + 1
      FOR (rslt = 1 TO rpt_ord_rec->ord[ord].rslt_cnt)
        row + 1, col 029, "<assay>",
        row + 1, assaynonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].mnemonic),
         "]]>"), col 033,
        "<", xml_tags->post_trans_orderassay, ">",
        assaynonull, "</", xml_tags->post_trans_orderassay,
        ">", row + 1, col 033,
        "<", xml_tags->post_trans_eventdatetime, ">",
        "<![CDATA[", rpt_ord_rec->ord[ord].results[rslt].event_dt_tm"@DATETIMECONDENSED;;d", "]]>",
        "</", xml_tags->post_trans_eventdatetime, ">",
        row + 1, resultstatusnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].
          result_status_disp),"]]>"), col 033,
        "<", xml_tags->post_trans_resultstatus, ">",
        resultstatusnonull, "</", xml_tags->post_trans_resultstatus,
        ">", row + 1, resultnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].
          result),"]]>"),
        col 033, "<", xml_tags->post_trans_result,
        ">", resultnonull, "</",
        xml_tags->post_trans_result, ">", row + 1,
        flagsnonull = concat("<![CDATA[",trim(rpt_ord_rec->ord[ord].results[rslt].result_flags),"]]>"
         ), col 033, "<",
        xml_tags->post_trans_flags, ">", flagsnonull,
        "</", xml_tags->post_trans_flags, ">",
        row + 1, col 029, "</assay>",
        row + 1
      ENDFOR
     ELSE
      col 025, "<assays>", row + 1,
      col 029, "<assay>", row + 1,
      col 033, "<", xml_tags->post_trans_orderassay,
      "></", xml_tags->post_trans_orderassay, ">",
      row + 1, col 033, "<",
      xml_tags->post_trans_eventdatetime, "></", xml_tags->post_trans_eventdatetime,
      ">", row + 1, col 033,
      "<", xml_tags->post_trans_resultstatus, "></",
      xml_tags->post_trans_resultstatus, ">", row + 1,
      col 033, "<", xml_tags->post_trans_result,
      "></", xml_tags->post_trans_result, ">",
      row + 1, col 033, "<",
      xml_tags->post_trans_flags, "></", xml_tags->post_trans_flags,
      ">", row + 1, col 029,
      "</assay>", row + 1
     ENDIF
     col 025, "</assays>", row + 1
    ENDMACRO
   HEAD PAGE
    row + 1
   HEAD dispense_prov_id
    IF (dispense_prov_id != dispense_prov_id_hd
     AND by_physician_ind="Y")
     new_physician_ind = "Y", dispense_prov_id_hd = dispense_prov_id, person_id_hd = 0.0,
     encntr_id_hd = 0.0, trans_time_hd = 0.0, order_id_hd = 0.0,
     result_id_hd = 0.0
    ENDIF
   HEAD person_id
    IF (person_id != person_id_hd)
     new_person_ind = "Y", person_id_hd = person_id, encntr_id_hd = 0.0,
     trans_time_hd = 0.0, order_id_hd = 0.0, result_id_hd = 0.0
    ENDIF
   HEAD encntr_id
    IF (encntr_id != encntr_id_hd)
     new_encntr_ind = "Y", encntr_id_hd = encntr_id, trans_time_hd = 0.0,
     order_id_hd = 0.0, result_id_hd = 0.0
    ENDIF
   HEAD trans_time
    IF (trans_time != trans_time_hd)
     IF (first_trans_ind="Y")
      first_trans_ind = "N"
     ELSE
      foot_trans_time_xml
     ENDIF
     new_trans_time_ind = "Y", trans_time_hd = trans_time, rpt_ord_cnt = 0,
     valid_order_ind = "N", stat = alterlist(rpt_ord_rec->ord,0), stat = alterlist(rpt_ord_rec->ord,
      10),
     pre_cnt = 0, post_cnt = 0, rpt_pe_cnt = 0,
     stat = alterlist(rpt_pe_rec->pe,0), stat = alterlist(rpt_pe_rec->pe,10), rpt_pe_rec->trans_time
      = trans_time,
     dta_cnt = 0, dta = 0, stat = alterlist(dta_rec->dta,0),
     stat = alterlist(dta_rec->dta,10), tca = 0, order_id_hd = 0.0,
     result_id_hd = 0.0
    ENDIF
   HEAD order_id
    IF (trim(table_ind)="2o")
     IF (order_id != order_id_hd)
      new_order_ind = "Y", order_id_hd = order_id, result_id_hd = 0.0
     ENDIF
    ENDIF
   HEAD result_id
    IF (trim(table_ind)="2o")
     IF (result_id != result_id_hd)
      new_result_ind = "Y", result_id_hd = result_id
     ENDIF
    ENDIF
   DETAIL
    IF (new_physician_ind="Y")
     print_physician_ind = "Y", new_physician_ind = "N"
    ENDIF
    IF (new_person_ind="Y")
     new_person_ind = "N", print_person_ind = "Y"
    ENDIF
    patient_name = trim(per_rec->per[d_per.seq].patient_name,5), birth_dt_tm = cnvtdatetime(per_rec->
     per[d_per.seq].birth_dt_tm), birth_tz = validate(per_rec->per[d_per.seq].birth_tz,0),
    new_encntr_ind = "N", mrn_alias = trim(per_rec->per[d_per.seq].mrn_alias,1), fin_alias = trim(
     per_rec->per[d_per.seq].fin_alias,1),
    medical_service = trim(per_rec->per[d_per.seq].medicalservice), fac_location = trim(per_rec->per[
     d_per.seq].fac_location), new_trans_time_ind = "N"
    IF (trim(table_ind)="1pe")
     IF ((pe_rec->pe[d_pe.seq].product_event_id > 0)
      AND (pe_rec->pe[d_pe.seq].product_event_id != null))
      rpt_pe_cnt += 1
      IF (mod(rpt_pe_cnt,10)=1
       AND rpt_pe_cnt != 1)
       stat = alterlist(rpt_pe_rec->pe,(rpt_pe_cnt+ 9))
      ENDIF
      rpt_pe_rec->pe[rpt_pe_cnt].product_cd = pe_rec->pe[d_pe.seq].product_cd, rpt_pe_rec->pe[
      rpt_pe_cnt].product_disp = pe_rec->pe[d_pe.seq].product_disp, rpt_pe_rec->pe[rpt_pe_cnt].
      product_nbr = pe_rec->pe[d_pe.seq].product_nbr,
      rpt_pe_rec->pe[rpt_pe_cnt].serial_number = pe_rec->pe[d_pe.seq].serial_number, rpt_pe_rec->pe[
      rpt_pe_cnt].abo_rh_disp = concat(trim(pe_rec->pe[d_pe.seq].abo_disp)," ",trim(pe_rec->pe[d_pe
        .seq].rh_disp)), rpt_pe_rec->pe[rpt_pe_cnt].quantity = pe_rec->pe[d_pe.seq].quantity,
      rpt_pe_rec->pe[rpt_pe_cnt].iu = pe_rec->pe[d_pe.seq].iu, rpt_pe_rec->pe[rpt_pe_cnt].event_dt_tm
       = cnvtdatetime(pe_rec->pe[d_pe.seq].event_dt_tm), rpt_pe_rec->pe[rpt_pe_cnt].physician_name =
      pe_rec->pe[d_pe.seq].physician_name,
      rpt_pe_rec->pe[rpt_pe_cnt].dispense_to = pe_rec->pe[d_pe.seq].dispense_to
     ENDIF
     product_found_ind = "N", dta = 0
     FOR (dta = 1 TO dta_cnt)
       IF ((dta_rec->dta[dta].product_cd=pe_rec->pe[d_pe.seq].product_cd))
        product_found_ind = "Y", dta = dta_cnt
       ENDIF
     ENDFOR
     IF (product_found_ind="N")
      FOR (tca = 1 TO tca_cnt)
        IF ((tca_rec->tca[tca].product_cd=pe_rec->pe[d_pe.seq].product_cd))
         product_found_ind = "Y", dta_cnt += 1
         IF (mod(dta_cnt,10)=1
          AND dta_cnt != 1)
          stat = alterlist(dta_rec->dta,(dta_cnt+ 9))
         ENDIF
         dta_rec->dta[dta_cnt].product_cd = tca_rec->tca[tca].product_cd, dta_rec->dta[dta_cnt].
         task_assay_cd = tca_rec->tca[tca].task_assay_cd, dta_rec->dta[dta_cnt].mnemonic = tca_rec->
         tca[tca].detail_mnemonic,
         dta_rec->dta[dta_cnt].pre_time = (trans_time - (tca_rec->tca[tca].pre_hours * 60)), dta_rec
         ->dta[dta_cnt].post_time = (trans_time+ (tca_rec->tca[tca].post_hours * 60))
        ELSEIF (product_found_ind="Y")
         tca = tca_cnt
        ENDIF
      ENDFOR
     ENDIF
    ELSEIF (trim(table_ind)="2o")
     IF (new_order_ind="Y")
      valid_order_ind = "N", cat = 0, catalog_found_ind = "N"
      FOR (cat = 1 TO cat_task_cnt)
        IF ((cat_task_rec->cat_task[cat].catalog_cd=ord_rec->ord[d_o.seq].catalog_cd))
         catalog_found_ind = "Y", dta = 0
         FOR (dta = 1 TO dta_cnt)
           IF ((dta_rec->dta[dta].task_assay_cd=cat_task_rec->cat_task[cat].task_assay_cd))
            IF ((collected_time >= dta_rec->dta[dta].pre_time)
             AND (collected_time <= dta_rec->dta[dta].post_time))
             valid_order_ind = "Y", dta = dta_cnt
            ENDIF
           ENDIF
         ENDFOR
        ELSEIF (catalog_found_ind="Y")
         cat = cat_task_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (new_order_ind="Y"
      AND valid_order_ind="Y")
      new_order_ind = "N"
      IF (collected_time <= trans_time)
       pre_cnt += 1
      ELSE
       post_cnt += 1
      ENDIF
      rpt_ord_cnt += 1
      IF (mod(rpt_ord_cnt,10)=1
       AND rpt_ord_cnt != 1)
       stat = alterlist(rpt_ord_rec->ord,(rpt_ord_cnt+ 9))
      ENDIF
      rpt_ord_rec->ord[rpt_ord_cnt].accession = ord_rec->ord[d_o.seq].accession, rpt_ord_rec->ord[
      rpt_ord_cnt].order_mnemonic = ord_rec->ord[d_o.seq].order_mnemonic, rpt_ord_rec->ord[
      rpt_ord_cnt].collected_dt_tm = cnvtdatetime(ord_rec->ord[d_o.seq].collected_dt_tm),
      rpt_ord_rec->ord[rpt_ord_cnt].order_status_disp = ord_rec->ord[d_o.seq].order_status_disp,
      rslt_cnt = 0, stat = alterlist(rpt_ord_rec->ord[rpt_ord_cnt].results,10)
     ENDIF
     IF (new_result_ind="Y"
      AND result_ind="Y"
      AND valid_order_ind="Y")
      new_result_ind = "N", dta_found_ind = "N", dta_pre_time = 0.0,
      dta_post_time = 0.0
      FOR (dta = 1 TO dta_cnt)
        IF ((dta_rec->dta[dta].task_assay_cd=rslt_rec->rslt[d_r.seq].task_assay_cd))
         dta_found_ind = "Y"
         IF ((dta_rec->dta[dta].pre_time > dta_pre_time))
          dta_pre_time = dta_rec->dta[dta].pre_time
         ENDIF
         IF ((dta_rec->dta[dta].post_time > dta_post_time))
          dta_post_time = dta_rec->dta[dta].post_time
         ENDIF
        ENDIF
      ENDFOR
      IF (dta_found_ind="Y")
       IF ((ord_rec->ord[d_o.seq].collected_time >= dta_pre_time)
        AND (ord_rec->ord[d_o.seq].collected_time <= dta_post_time))
        rslt_cnt += 1
        IF (mod(rslt_cnt,10)=1
         AND rslt_cnt != 1)
         stat = alterlist(rpt_ord_rec->ord[rpt_ord_cnt].results,(rslt_cnt+ 9))
        ENDIF
        rpt_ord_rec->ord[rpt_ord_cnt].rslt_cnt = rslt_cnt, n = "", c = "",
        r = "", d = "", rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].mnemonic = rslt_rec->rslt[d_r
        .seq].mnemonic,
        rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].event_dt_tm = cnvtdatetime(rslt_rec->rslt[d_r
         .seq].event_dt_tm), rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result_status_disp =
        rslt_rec->rslt[d_r.seq].result_status_disp
        IF (trim(rslt_rec->rslt[d_r.seq].result_value_alpha) > "")
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = rslt_rec->rslt[d_r.seq].
         result_value_alpha
        ELSEIF ((rslt_rec->rslt[d_r.seq].result_value_numeric != 0)
         AND (rslt_rec->rslt[d_r.seq].result_value_numeric != null))
         arg_min_digits = rslt_rec->rslt[d_r.seq].arg_min_digits, arg_max_digits = rslt_rec->rslt[d_r
         .seq].arg_max_digits, arg_min_dec_places = rslt_rec->rslt[d_r.seq].arg_min_dec_places,
         arg_less_great_flag = rslt_rec->rslt[d_r.seq].arg_less_great_flag, arg_raw_value = rslt_rec
         ->rslt[d_r.seq].result_value_numeric, result_value = fillstring(17," "),
         result_value = uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
          arg_less_great_flag,arg_raw_value), rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result
          = result_value
        ELSEIF (trim(rslt_rec->rslt[d_r.seq].ascii_text) > "")
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = rslt_rec->rslt[d_r.seq].ascii_text
        ELSEIF ((rslt_rec->rslt[d_r.seq].result_code_set_cd > 0)
         AND (rslt_rec->rslt[d_r.seq].result_code_set_cd != null))
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = rslt_rec->rslt[d_r.seq].
         result_code_set_disp
        ELSEIF ((rslt_rec->rslt[d_r.seq].long_text_id > 0)
         AND (rslt_rec->rslt[d_r.seq].long_text_id != null))
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = "<Text,check online>"
        ELSEIF ((rslt_rec->rslt[d_r.seq].nomenclature_id <= 0))
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = "<Blank>"
        ELSE
         rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result = "<Unknown>"
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].normal_cd > 0))
         n = rslt_rec->rslt[d_r.seq].normal_disp
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].critical_cd > 0))
         c = rslt_rec->rslt[d_r.seq].critical_disp
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].review_cd > 0))
         r = rslt_rec->rslt[d_r.seq].review_disp
        ENDIF
        IF ((rslt_rec->rslt[d_r.seq].delta_cd > 0))
         d = rslt_rec->rslt[d_r.seq].delta_disp
        ENDIF
        rpt_ord_rec->ord[rpt_ord_cnt].results[rslt_cnt].result_flags = concat(n,c,r,d)
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT REPORT
    foot_trans_time_xml
    IF (last_trans_row > 0)
     call reportmove('ROW',(last_trans_row+ 1),0)
    ELSE
     row + 1
    ENDIF
    report_complete_ind = "Y", col 0013, "</encounters>",
    row + 1, col 009, "</patient>",
    row + 1, col 001, "</patients>",
    row + 1, col 001, "</report>",
    select_ok_ind = 1
   WITH nocounter, outerjoin(d_r_r), maxrow = 9999,
    formfeed = none, nullreport, nolandscape,
    compress
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.subeventstatus[count1].operationname = "get product_event rows"
   SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "ZERO:  No data found for specified date range"
   GO TO exit_script
  ENDIF
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "print transfusion committee report"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_trans_cmte"
  IF (report_complete_ind="Y")
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[count1].operationstatus = "S"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue = "SUCCESS"
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "SCRIPT ERROR:  Report ended abnormally"
  ENDIF
  SET rpt_cnt += 1
  SET stat = alterlist(reply->rpt_list,rpt_cnt)
  SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
  IF (select_ok_ind=1)
   SET reply->status_data.status = "S"
  ENDIF
  IF (size(trim(request->batch_selection))=0)
   FREE RECORD ekssourcerequest
   RECORD ekssourcerequest(
     1 module_dir = vc
     1 module_name = vc
     1 basblob = i2
   )
   FREE RECORD eksreply
   RECORD eksreply(
     1 info_line[*]
       2 new_line = vc
     1 data_blob = gvc
     1 data_blob_size = i4
     1 status_data
       2 status = c1
       2 subeventstatus[1]
         3 operationname = c25
         3 operationstatus = c1
         3 targetobjectname = c25
         3 targetobjectvalue = vc
   )
   SUBROUTINE (readexportfile(fullfilepath=vc) =null)
     SET stat = initrec(ekssourcerequest)
     SET stat = initrec(eksreply)
     DECLARE filename = vc WITH protect, noconstant
     DECLARE file_dir = vc WITH protect, noconstant
     DECLARE separator_pos = i2 WITH protect, noconstant(0)
     SET separator_pos = 0
     SET separator_pos = cnvtint(value(findstring(":",fullfilepath,1,1)))
     IF (separator_pos <= 0)
      SET separator_pos = cnvtint(value(findstring("/",fullfilepath,1,1)))
     ENDIF
     SET file_dir = concat(substring(1,(separator_pos - 1),fullfilepath),":")
     SET filename = substring((separator_pos+ 1),(size(fullfilepath) - separator_pos),fullfilepath)
     SET ekssourcerequest->module_dir = file_dir
     SET ekssourcerequest->module_name = filename
     SET ekssourcerequest->basblob = 1
     EXECUTE eks_get_source  WITH replace("REQUEST",ekssourcerequest), replace("REPLY",eksreply)
     RETURN
   END ;Subroutine
   FOR (j = 1 TO size(reply->rpt_list,5))
     CALL echo(reply->rpt_list[j].rpt_filename)
     CALL readexportfile(reply->rpt_list[j].rpt_filename)
     IF ((eksreply->status_data.status="S"))
      SET reply->rpt_list[j].data_blob = eksreply->data_blob
      SET reply->rpt_list[j].data_blob_size = eksreply->data_blob_size
     ELSE
      CALL addtostatusblock("F","SCRIPT","F","BBT_RPT_TRANS_CMTE_XML",concat("Error reading report",
        reply->rpt_list[j].rpt_filename))
     ENDIF
   ENDFOR
  ENDIF
  GO TO exit_script
 ENDIF
#exit_script
END GO
