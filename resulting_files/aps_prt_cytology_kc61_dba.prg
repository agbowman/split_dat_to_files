CREATE PROGRAM aps_prt_cytology_kc61:dba
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
 RECORD temp(
   1 quarter_qual[8]
     2 from_date = dq8
     2 to_date = dq8
     2 case_qual[*]
       3 case_id = f8
       3 main_report_cmplete_dt_tm = dq8
       3 case_received_dt_tm = dq8
       3 case_collect_dt_tm = dq8
       3 source_of_smear_cd = f8
       3 received_smear_ind = i2
       3 birth_dt_tm = dq8
       3 age_in_years = i4
       3 turnaround_weeks = i4
       3 send_out_specimen_ind = i2
       3 event_sequence = i4
       3 diagnostic_category_cd = f8
       3 kc61_multiple_specimens_ind = i2
       3 kc61_outcome_of_referral_cd = f8
       3 kc61_result_of_test_cd = f8
       3 kc61_source_of_smear_cd = f8
       3 org_name = vc
       3 specimen_qual[*]
         4 specimen_cd = f8
       3 followup_tracking_qual[*]
         4 term_reason_cd = f8
   1 multi_source_specimens_qual[1]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 outcome_of_referral_qual[14]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 result_of_test_qual[8]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 source_of_smear_qual[7]
     2 code_value = f8
     2 display = vc
     2 description = vc
   1 weeks_range_qual[6]
     2 display = vc
     2 lower_limit = i2
     2 upper_limit = i2
   1 age_range_qual[13]
     2 display = vc
     2 lower_limit = i2
     2 upper_limit = i2
 )
 RECORD tempkc61(
   1 part[6]
     2 row[*]
       3 max_lines = i2
       3 col[*]
         4 total = i4
         4 lines_cnt = i2
         4 lines[*]
           5 text = vc
   1 c1_pos_pred_value = f8
   1 c1_lost_to_followup = f8
   1 c2_pos_pred_value = f8
   1 c2_lost_to_followup = f8
   1 a3_received[*]
     2 org_name = vc
 )
 RECORD reqkc61assignedcv(
   1 debug_ind = i2
   1 max_results = i4
   1 inactives_ind = i2
   1 code_sets[*]
     2 code_set = i4
 )
 RECORD reqkc61cs(
   1 debug_ind = i2
   1 inactives_ind = i2
   1 qual[*]
     2 code_set = i4
     2 cdf_meaning = c12
 )
 RECORD tempkc61assignedcv(
   1 parents[*]
     2 code_value = f8
     2 display = vc
     2 display_key = vc
     2 description = vc
     2 definition = vc
     2 code_set = i4
     2 cdf_meaning = c12
     2 collation_seq = i4
     2 active_ind = i2
     2 children[*]
       3 code_value = f8
       3 display = vc
       3 display_key = vc
       3 description = vc
       3 definition = vc
       3 code_set = i4
       3 cdf_meaning = c12
       3 collation_seq = i4
       3 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD flatkc61assignedcv(
   1 code_qual[*]
     2 parent_code_value = f8
     2 child_code_value = f8
 )
 RECORD tempkc61cs(
   1 qual[*]
     2 code_value = f8
     2 display = vc
     2 display_key = vc
     2 description = vc
     2 definition = vc
     2 code_set = i4
     2 cdf_meaning = c12
     2 collation_seq = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD reply(
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
 DECLARE n_multi_source_cs = i4 WITH protect, constant(29461)
 DECLARE n_outcome_of_referral_cs = i4 WITH protect, constant(29462)
 DECLARE n_result_of_test_cs = i4 WITH protect, constant(29463)
 DECLARE n_source_of_smear_cs = i4 WITH protect, constant(29464)
 DECLARE n_quarter_cnt = i2 WITH protect, constant(4)
 DECLARE n_multi_source_cnt = i2 WITH protect, constant(1)
 DECLARE n_outcome_referral_cnt = i2 WITH protect, constant(14)
 DECLARE n_result_test_cnt = i2 WITH protect, constant(8)
 DECLARE n_source_smear_cnt = i2 WITH protect, constant(7)
 DECLARE n_age_range_cnt = i2 WITH protect, constant(13)
 DECLARE n_weeks_range_cnt = i2 WITH protect, constant(6)
 DECLARE n_kc61_part_a1 = i2 WITH protect, constant(1)
 DECLARE n_kc61_part_a2 = i2 WITH protect, constant(2)
 DECLARE n_kc61_part_a3 = i2 WITH protect, constant(3)
 DECLARE n_kc61_part_b = i2 WITH protect, constant(4)
 DECLARE n_kc61_part_c1 = i2 WITH protect, constant(5)
 DECLARE n_kc61_part_c2 = i2 WITH protect, constant(6)
 DECLARE n_part_a1_rows = i2 WITH protect, constant(10)
 DECLARE n_part_a1_cols = i2 WITH protect, constant(11)
 DECLARE n_part_a2_rows = i2 WITH protect, constant(7)
 DECLARE n_part_a2_cols = i2 WITH protect, constant(9)
 DECLARE n_part_a3_cols = i2 WITH protect, constant(5)
 DECLARE n_part_b_rows = i2 WITH protect, constant(16)
 DECLARE n_part_b_cols = i2 WITH protect, constant(11)
 DECLARE n_part_c_rows = i2 WITH protect, constant(16)
 DECLARE n_part_c_cols = i2 WITH protect, constant(10)
 DECLARE n_part_a1_row_offset = i2 WITH protect, constant(1)
 DECLARE n_part_a1_col_offset = i2 WITH protect, constant(2)
 DECLARE n_part_a2_row_offset = i2 WITH protect, constant(2)
 DECLARE n_part_a2_col_offset = i2 WITH protect, constant(3)
 DECLARE n_part_a3_row_offset = i2 WITH protect, constant(1)
 DECLARE n_part_a3_col_offset = i2 WITH protect, constant(1)
 DECLARE n_part_b_row_offset = i2 WITH protect, constant(1)
 DECLARE n_part_b_col_offset = i2 WITH protect, constant(2)
 DECLARE n_part_c_row_offset = i2 WITH protect, constant(1)
 DECLARE n_part_c_col_offset = i2 WITH protect, constant(2)
 DECLARE n_part_a1_line_col = i2 WITH protect, constant(1)
 DECLARE n_part_a1_source_col = i2 WITH protect, constant(2)
 DECLARE n_part_a1_total_col = i2 WITH protect, constant(11)
 DECLARE n_part_a1_result_row = i2 WITH protect, constant(1)
 DECLARE n_part_a1_subtotal_row = i2 WITH protect, constant(9)
 DECLARE n_part_a1_total_row = i2 WITH protect, constant(10)
 DECLARE n_part_a2_header_row = i2 WITH protect, constant(1)
 DECLARE n_part_a2_weeks_row = i2 WITH protect, constant(2)
 DECLARE n_part_a2_linenum_col = i2 WITH protect, constant(1)
 DECLARE n_part_a2_quarter_col = i2 WITH protect, constant(2)
 DECLARE n_part_a2_total_col = i2 WITH protect, constant(3)
 DECLARE n_part_a2_nbr_within_col = i2 WITH protect, constant(4)
 DECLARE n_part_a3_header_row = i2 WITH protect, constant(1)
 DECLARE n_part_a3_linenum_col = i2 WITH protect, constant(1)
 DECLARE n_part_a3_header_col = i2 WITH protect, constant(2)
 DECLARE n_part_a3_total_col = i2 WITH protect, constant(3)
 DECLARE n_part_a3_sent_col = i2 WITH protect, constant(4)
 DECLARE n_part_a3_primary_col = i2 WITH protect, constant(5)
 DECLARE n_part_b_line_col = i2 WITH protect, constant(1)
 DECLARE n_part_b_age_col = i2 WITH protect, constant(2)
 DECLARE n_part_b_total_col = i2 WITH protect, constant(11)
 DECLARE n_part_b_result_row = i2 WITH protect, constant(1)
 DECLARE n_part_b_subtotal_row = i2 WITH protect, constant(15)
 DECLARE n_part_b_total_row = i2 WITH protect, constant(16)
 DECLARE n_part_c_line_col = i2 WITH protect, constant(1)
 DECLARE n_part_c_outcome_col = i2 WITH protect, constant(2)
 DECLARE n_part_c_total_col = i2 WITH protect, constant(10)
 DECLARE n_part_c_result_row = i2 WITH protect, constant(1)
 DECLARE n_part_a1_line_col_size = i2 WITH protect, constant(4)
 DECLARE n_part_a1_source_col_size = i2 WITH protect, constant(10)
 DECLARE n_part_a1_result_col_size = i2 WITH protect, constant(11)
 DECLARE n_part_a1_total_col_size = i2 WITH protect, constant(10)
 DECLARE n_part_a2_line_col_size = i2 WITH protect, constant(7)
 DECLARE n_part_a2_qrtr_col_size = i2 WITH protect, constant(11)
 DECLARE n_part_a2_weeks_col_size = i2 WITH protect, constant(14)
 DECLARE n_part_a2_total_col_size = i2 WITH protect, constant(13)
 DECLARE n_part_a3_line_col_size = i2 WITH protect, constant(7)
 DECLARE n_part_a3_header_col_size = i2 WITH protect, constant(47)
 DECLARE n_part_a3_total_col_size = i2 WITH protect, constant(7)
 DECLARE n_part_a3_sent_col_size = i2 WITH protect, constant(45)
 DECLARE n_part_a3_primary_size = i2 WITH protect, constant(15)
 DECLARE n_part_b_line_col_size = i2 WITH protect, constant(4)
 DECLARE n_part_b_age_col_size = i2 WITH protect, constant(7)
 DECLARE n_part_b_result_col_size = i2 WITH protect, constant(11)
 DECLARE n_part_b_total_col_size = i2 WITH protect, constant(10)
 DECLARE n_part_c_line_col_size = i2 WITH protect, constant(6)
 DECLARE n_part_c_outcome_col_size = i2 WITH protect, constant(21)
 DECLARE n_part_c_total_col_size = i2 WITH protect, constant(9)
 DECLARE n_part_c_result_col_size = i2 WITH protect, constant(11)
 DECLARE n_part_a1_maxlines = i2 WITH protect, constant(9)
 DECLARE n_part_a2_maxlines = i2 WITH protect, constant(5)
 DECLARE n_part_a3_maxlines = i2 WITH protect, constant(5)
 DECLARE n_part_b_maxlines = i2 WITH protect, constant(8)
 DECLARE n_part_c_maxlines = i2 WITH protect, constant(8)
 DECLARE gyn_case_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE parent_cnt = i2 WITH protect, noconstant(0)
 DECLARE child_cnt = i2 WITH protect, noconstant(0)
 DECLARE error_cnt = i2 WITH protect, noconstant(0)
 DECLARE prefix_cnt = i2 WITH protect, noconstant(0)
 DECLARE array_cnt = i2 WITH protect, noconstant(0)
 DECLARE array_pos = i2 WITH protect, noconstant(0)
 DECLARE code_cnt = i2 WITH protect, noconstant(0)
 DECLARE code_idx = i2 WITH protect, noconstant(0)
 DECLARE lines_cnt = i2 WITH protect, noconstant(0)
 DECLARE lines_idx = i2 WITH protect, noconstant(0)
 DECLARE lines_offset = i2 WITH protect, noconstant(0)
 DECLARE q1_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE q2_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE q3_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE q4_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE q5_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE q6_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE q7_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE q8_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE max_specimen_cnt = i2 WITH protect, noconstant(0)
 DECLARE max_followup_cnt = i2 WITH protect, noconstant(0)
 DECLARE a2_cell_value = i2 WITH protect, noconstant(0)
 DECLARE a2_cell_lines = i2 WITH protect, noconstant(0)
 DECLARE a3_cell_value = i2 WITH protect, noconstant(0)
 DECLARE a3_cell_lines = i2 WITH protect, noconstant(0)
 DECLARE assigned_cnt = i2 WITH protect, noconstant(0)
 DECLARE temp_age_str = vc WITH protect, noconstant("")
 DECLARE temp_pos_int = i2 WITH protect, noconstant(0)
 DECLARE temp_year = i2 WITH protect, noconstant(0)
 DECLARE temp_report_date = vc WITH protect, noconstant("")
 DECLARE c2_report_date = vc WITH protect, noconstant("")
 DECLARE cell_text = vc WITH protect, noconstant("")
 DECLARE cell_value = i4 WITH protect, noconstant(0)
 DECLARE part_row = i2 WITH protect, noconstant(0)
 DECLARE part_col = i2 WITH protect, noconstant(0)
 DECLARE last_row = i2 WITH protect, noconstant(0)
 DECLARE received_cnt = i2 WITH protect, noconstant(0)
 DECLARE text_addon = vc WITH protect, noconstant("")
 DECLARE part_c_cnt = i2 WITH protect, noconstant(0)
 DECLARE cur_quarter = i2 WITH protect, noconstant(0)
 DECLARE cur_case_cnt = i4 WITH protect, noconstant(0)
 DECLARE beg_year = i2 WITH protect, noconstant(0)
 DECLARE end_year = i2 WITH protect, noconstant(0)
 DECLARE n_part_a3_rows = i2 WITH protect, noconstant(5)
 DECLARE n_part_a3_smear_sent_row = i2 WITH protect, noconstant(2)
 DECLARE n_part_a3_smear_recd_row = i2 WITH protect, noconstant(3)
 DECLARE n_part_a3_subheader_row = i2 WITH protect, noconstant(4)
 DECLARE n_part_a3_multi_row = i2 WITH protect, noconstant(5)
 SET reply->status_data.status = "F"
 SET prefix_cnt = cnvtint(size(request->prefix_qual,5))
 SET beg_year = year(request->beg_dt_tm)
 SET end_year = year(request->end_dt_tm)
 SET temp_year = beg_year
 IF (beg_year=end_year
  AND month(request->beg_dt_tm) < 4)
  SET temp_year -= 1
 ENDIF
 SET temp->quarter_qual[1].from_date = cnvtdatetime(build("01-APR-",temp_year,",00:00:00"))
 SET temp->quarter_qual[1].to_date = cnvtdatetime(build("30-JUN-",temp_year,",23:59:59"))
 SET temp->quarter_qual[2].from_date = cnvtdatetime(build("01-JUL-",temp_year,",00:00:00"))
 SET temp->quarter_qual[2].to_date = cnvtdatetime(build("30-SEP-",temp_year,",23:59:59"))
 SET temp->quarter_qual[3].from_date = cnvtdatetime(build("01-OCT-",temp_year,",00:00:00"))
 SET temp->quarter_qual[3].to_date = cnvtdatetime(build("31-DEC-",temp_year,",23:59:59"))
 SET temp->quarter_qual[4].from_date = cnvtdatetime(build("01-JAN-",(temp_year+ 1),",00:00:00"))
 SET temp->quarter_qual[4].to_date = cnvtdatetime(build("31-MAR-",(temp_year+ 1),",23:59:59"))
 SET temp->quarter_qual[5].from_date = cnvtdatetime(build("01-APR-",(temp_year - 1),",00:00:00"))
 SET temp->quarter_qual[5].to_date = cnvtdatetime(build("30-JUN-",(temp_year - 1),",23:59:59"))
 SET temp->quarter_qual[6].from_date = cnvtdatetime(build("01-JUL-",(temp_year - 1),",00:00:00"))
 SET temp->quarter_qual[6].to_date = cnvtdatetime(build("30-SEP-",(temp_year - 1),",23:59:59"))
 SET temp->quarter_qual[7].from_date = cnvtdatetime(build("01-OCT-",(temp_year - 1),",00:00:00"))
 SET temp->quarter_qual[7].to_date = cnvtdatetime(build("31-DEC-",(temp_year - 1),",23:59:59"))
 SET temp->quarter_qual[8].from_date = cnvtdatetime(build("01-JAN-",temp_year,",00:00:00"))
 SET temp->quarter_qual[8].to_date = cnvtdatetime(build("31-MAR-",temp_year,",23:59:59"))
 SET temp->weeks_range_qual[1].display = "0-2 weeks (0-14 days)"
 SET temp->weeks_range_qual[1].lower_limit = 0
 SET temp->weeks_range_qual[1].upper_limit = 2
 SET temp->weeks_range_qual[2].display = "3-4 weeks (15-28 days)"
 SET temp->weeks_range_qual[2].lower_limit = 3
 SET temp->weeks_range_qual[2].upper_limit = 4
 SET temp->weeks_range_qual[3].display = "5-6 weeks (29-42 days)"
 SET temp->weeks_range_qual[3].lower_limit = 5
 SET temp->weeks_range_qual[3].upper_limit = 6
 SET temp->weeks_range_qual[4].display = "7-8 weeks (43-56 days)"
 SET temp->weeks_range_qual[4].lower_limit = 7
 SET temp->weeks_range_qual[4].upper_limit = 8
 SET temp->weeks_range_qual[5].display = "9-10 weeks (57-70 days)"
 SET temp->weeks_range_qual[5].lower_limit = 9
 SET temp->weeks_range_qual[5].upper_limit = 10
 SET temp->weeks_range_qual[6].display = "over 10 weeks (over 70 days)"
 SET temp->weeks_range_qual[6].lower_limit = 11
 SET temp->weeks_range_qual[6].upper_limit = 9999
 SET temp->age_range_qual[1].display = "Under 20"
 SET temp->age_range_qual[1].lower_limit = 0
 SET temp->age_range_qual[1].upper_limit = 19
 SET temp->age_range_qual[2].display = "20-24"
 SET temp->age_range_qual[2].lower_limit = 20
 SET temp->age_range_qual[2].upper_limit = 24
 SET temp->age_range_qual[3].display = "25-29"
 SET temp->age_range_qual[3].lower_limit = 25
 SET temp->age_range_qual[3].upper_limit = 29
 SET temp->age_range_qual[4].display = "30-34"
 SET temp->age_range_qual[4].lower_limit = 30
 SET temp->age_range_qual[4].upper_limit = 34
 SET temp->age_range_qual[5].display = "35-39"
 SET temp->age_range_qual[5].lower_limit = 35
 SET temp->age_range_qual[5].upper_limit = 39
 SET temp->age_range_qual[6].display = "40-44"
 SET temp->age_range_qual[6].lower_limit = 40
 SET temp->age_range_qual[6].upper_limit = 44
 SET temp->age_range_qual[7].display = "45-49"
 SET temp->age_range_qual[7].lower_limit = 45
 SET temp->age_range_qual[7].upper_limit = 49
 SET temp->age_range_qual[8].display = "50-54"
 SET temp->age_range_qual[8].lower_limit = 50
 SET temp->age_range_qual[8].upper_limit = 54
 SET temp->age_range_qual[9].display = "55-59"
 SET temp->age_range_qual[9].lower_limit = 55
 SET temp->age_range_qual[9].upper_limit = 59
 SET temp->age_range_qual[10].display = "60-64"
 SET temp->age_range_qual[10].lower_limit = 60
 SET temp->age_range_qual[10].upper_limit = 64
 SET temp->age_range_qual[11].display = "65-69"
 SET temp->age_range_qual[11].lower_limit = 65
 SET temp->age_range_qual[11].upper_limit = 69
 SET temp->age_range_qual[12].display = "70-74"
 SET temp->age_range_qual[12].lower_limit = 70
 SET temp->age_range_qual[12].upper_limit = 74
 SET temp->age_range_qual[13].display = "75 and over"
 SET temp->age_range_qual[13].lower_limit = 75
 SET temp->age_range_qual[13].upper_limit = 9999
 IF ((request->end_dt_tm > temp->quarter_qual[4].to_date))
  CALL handle_errors("REQUEST","F","INVALID DATE RANGE","DATE RANGE EXCEEDS 1 YEAR")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF ((request->send_out_resource_cd=0.0))
  CALL handle_errors("REQUEST","F","INVALID SERVICE RESOURCE","SERVICE RESOURCE NOT SPECIFIED")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 IF (prefix_cnt=0)
  CALL handle_errors("REQUEST","F","INVALID PREFIXES","PREFIXES NOT SPECIFIED")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET temp_report_date = format(temp->quarter_qual[4].to_date,"@LONGDATE")
 SET c2_report_date = format(temp->quarter_qual[8].to_date,"@LONGDATE")
 SET stat = uar_get_meaning_by_codeset(1301,"GYN",1,gyn_case_type_cd)
 IF (gyn_case_type_cd=0.0)
  CALL handle_errors("UAR","F","1301","CANNOT GET GYN CASE TYPE CODE VALUE")
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reqkc61cs->qual,1)
 SET reqkc61cs->qual[1].code_set = n_multi_source_cs
 SET stat = alterlist(tempkc61cs->qual,0)
 EXECUTE pcs_get_code_values  WITH replace("REQUEST","REQKC61CS"), replace("REPLY","TEMPKC61CS")
 IF ((tempkc61cs->status_data.status != "S"))
  CALL handle_errors("EXECUTE","F","PCS_GET_CODE_VALUES","KC61 MULTI SOURCE CS")
  SET reply->status_data.status = tempkc61cs->status_data.status
  GO TO exit_script
 ENDIF
 SET array_cnt = 0
 SET code_cnt = size(tempkc61cs->qual,5)
 FOR (code_idx = 1 TO code_cnt)
   SET array_pos = 0
   CASE (trim(tempkc61cs->qual[code_idx].cdf_meaning))
    OF "MULTISOURCE":
     SET array_pos = 1
   ENDCASE
   IF (array_pos != 0)
    SET array_cnt += 1
    SET temp->multi_source_specimens_qual[array_pos].code_value = tempkc61cs->qual[code_idx].
    code_value
    SET temp->multi_source_specimens_qual[array_pos].display = tempkc61cs->qual[code_idx].display
    SET temp->multi_source_specimens_qual[array_pos].description = tempkc61cs->qual[code_idx].
    description
   ENDIF
 ENDFOR
 IF (array_cnt != n_multi_source_cnt)
  CALL handle_errors("SELECT","Z","CODE_SET","KC61 MULTI SOURCE CNT")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reqkc61cs->qual,1)
 SET reqkc61cs->qual[1].code_set = n_outcome_of_referral_cs
 SET stat = alterlist(tempkc61cs->qual,0)
 EXECUTE pcs_get_code_values  WITH replace("REQUEST","REQKC61CS"), replace("REPLY","TEMPKC61CS")
 IF ((tempkc61cs->status_data.status != "S"))
  CALL handle_errors("EXECUTE","F","PCS_GET_CODE_VALUES","KC61 OUTCOME OF REFERRAL CS")
  SET reply->status_data.status = tempkc61cs->status_data.status
  GO TO exit_script
 ENDIF
 SET array_cnt = 0
 SET code_cnt = size(tempkc61cs->qual,5)
 FOR (code_idx = 1 TO code_cnt)
   SET array_pos = 0
   SET text_addon = ""
   CASE (trim(tempkc61cs->qual[code_idx].cdf_meaning))
    OF "CERVCANCER1B":
     SET array_pos = 1
    OF "CERV CANCER":
     SET array_pos = 2
    OF "CARCINOMA":
     SET array_pos = 3
    OF "CIN3":
     SET array_pos = 4
    OF "CIN2":
     SET array_pos = 5
    OF "CIN1":
     SET array_pos = 6
    OF "HPV":
     SET array_pos = 7
    OF "NO CIN OR HP":
     SET array_pos = 8
    OF "NO BIOPSY":
     SET array_pos = 9
     SET text_addon = "(2)"
    OF "NONEOFABOVE":
     SET array_pos = 10
     SET text_addon = "(3)"
    OF "UNKNOWN":
     SET array_pos = 11
     SET text_addon = "(4)"
    OF "NONE AVAIL":
     SET array_pos = 12
     SET text_addon = "(5)"
    OF "INADEQUATE":
     SET array_pos = 13
    OF "NON CANCERS":
     SET array_pos = 14
   ENDCASE
   IF (array_pos != 0)
    SET array_cnt += 1
    SET temp->outcome_of_referral_qual[array_pos].code_value = tempkc61cs->qual[code_idx].code_value
    SET temp->outcome_of_referral_qual[array_pos].display = tempkc61cs->qual[code_idx].display
    SET temp->outcome_of_referral_qual[array_pos].description = concat(tempkc61cs->qual[code_idx].
     description,text_addon)
   ENDIF
 ENDFOR
 IF (array_cnt != n_outcome_referral_cnt)
  CALL handle_errors("SELECT","Z","CODE_SET","KC61 OUTCOME REFERRAL CNT")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reqkc61cs->qual,1)
 SET reqkc61cs->qual[1].code_set = n_result_of_test_cs
 SET stat = alterlist(tempkc61cs->qual,0)
 EXECUTE pcs_get_code_values  WITH replace("REQUEST","REQKC61CS"), replace("REPLY","TEMPKC61CS")
 IF ((tempkc61cs->status_data.status != "S"))
  CALL handle_errors("EXECUTE","F","PCS_GET_CODE_VALUES","KC61 RESULT OF TEST CS")
  SET reply->status_data.status = tempkc61cs->status_data.status
  GO TO exit_script
 ENDIF
 SET array_cnt = 0
 SET code_cnt = size(tempkc61cs->qual,5)
 FOR (code_idx = 1 TO code_cnt)
   SET array_pos = 0
   CASE (trim(tempkc61cs->qual[code_idx].cdf_meaning))
    OF "CAT1":
     SET array_pos = 1
    OF "CAT2":
     SET array_pos = 2
    OF "CAT8":
     SET array_pos = 3
    OF "CAT3":
     SET array_pos = 4
    OF "CAT7":
     SET array_pos = 5
    OF "CAT4":
     SET array_pos = 6
    OF "CAT5":
     SET array_pos = 7
    OF "CAT6":
     SET array_pos = 8
   ENDCASE
   IF (array_pos != 0)
    SET array_cnt += 1
    SET temp->result_of_test_qual[array_pos].code_value = tempkc61cs->qual[code_idx].code_value
    SET temp->result_of_test_qual[array_pos].display = tempkc61cs->qual[code_idx].display
    SET temp->result_of_test_qual[array_pos].description = tempkc61cs->qual[code_idx].description
   ENDIF
 ENDFOR
 IF (array_cnt != n_result_test_cnt)
  CALL handle_errors("SELECT","Z","CODE_SET","KC61 RESULT TEST CNT")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reqkc61cs->qual,1)
 SET reqkc61cs->qual[1].code_set = n_source_of_smear_cs
 SET stat = alterlist(tempkc61cs->qual,0)
 EXECUTE pcs_get_code_values  WITH replace("REQUEST","REQKC61CS"), replace("REPLY","TEMPKC61CS")
 IF ((tempkc61cs->status_data.status != "S"))
  CALL handle_errors("EXECUTE","F","PCS_GET_CODE_VALUES","KC61 SOURCE OF SMEAR CS")
  SET reply->status_data.status = tempkc61cs->status_data.status
  GO TO exit_script
 ENDIF
 SET array_cnt = 0
 SET code_cnt = size(tempkc61cs->qual,5)
 FOR (code_idx = 1 TO code_cnt)
   SET array_pos = 0
   CASE (trim(tempkc61cs->qual[code_idx].cdf_meaning))
    OF "GP":
     SET array_pos = 1
    OF "NHS CLINIC":
     SET array_pos = 2
    OF "GUM":
     SET array_pos = 3
    OF "NHS HOSPITAL":
     SET array_pos = 4
    OF "COLPOSCOPY":
     SET array_pos = 5
    OF "PRIVATE":
     SET array_pos = 6
    OF "OTHER":
     SET array_pos = 7
   ENDCASE
   IF (array_pos != 0)
    SET array_cnt += 1
    SET temp->source_of_smear_qual[array_pos].code_value = tempkc61cs->qual[code_idx].code_value
    SET temp->source_of_smear_qual[array_pos].display = tempkc61cs->qual[code_idx].display
    SET temp->source_of_smear_qual[array_pos].description = tempkc61cs->qual[code_idx].description
   ENDIF
 ENDFOR
 IF (array_cnt != n_source_smear_cnt)
  CALL handle_errors("SELECT","Z","CODE_SET","KC61 SOURCE SMEAR CNT")
  SET reply->status_data.status = "F"
  GO TO exit_script
 ENDIF
 FREE SET reqkc61cs
 FREE SET tempkc61cs
 SET reqkc61assignedcv->max_results = 0
 SET reqkc61assignedcv->inactives_ind = 1
 SET stat = alterlist(reqkc61assignedcv->code_sets,4)
 SET reqkc61assignedcv->code_sets[1].code_set = n_multi_source_cs
 SET reqkc61assignedcv->code_sets[2].code_set = n_outcome_of_referral_cs
 SET reqkc61assignedcv->code_sets[3].code_set = n_result_of_test_cs
 SET reqkc61assignedcv->code_sets[4].code_set = n_source_of_smear_cs
 EXECUTE aps_get_code_value_group  WITH replace("REQUEST","REQKC61ASSIGNEDCV"), replace("REPLY",
  "TEMPKC61ASSIGNEDCV")
 IF ((tempkc61assignedcv->status_data.status != "S"))
  CALL handle_errors("EXECUTE","F","APS_GET_CODE_VALUE_GROUP","SCRIPT FAILURE")
  SET reply->status_data.status = tempkc61assignedcv->status_data.status
  GO TO exit_script
 ENDIF
 FREE SET reqkc61assignedcv
 SET assigned_cnt = 0
 FOR (parent_cnt = 1 TO size(tempkc61assignedcv->parents,5))
   FOR (child_cnt = 1 TO size(tempkc61assignedcv->parents[parent_cnt].children,5))
     SET assigned_cnt += 1
     IF (assigned_cnt > size(flatkc61assignedcv->code_qual,5))
      SET stat = alterlist(flatkc61assignedcv->code_qual,(assigned_cnt+ 9))
     ENDIF
     SET flatkc61assignedcv->code_qual[assigned_cnt].parent_code_value = tempkc61assignedcv->parents[
     parent_cnt].code_value
     SET flatkc61assignedcv->code_qual[assigned_cnt].child_code_value = tempkc61assignedcv->parents[
     parent_cnt].children[child_cnt].code_value
   ENDFOR
 ENDFOR
 SET stat = alterlist(flatkc61assignedcv->code_qual,assigned_cnt)
 FREE SET tempkc61assignedcv
 IF (assigned_cnt=0)
  CALL handle_errors("EXECUTE","Z","APS_GET_CODE_VALUE_GROUP","NO ASSIGNED PARAMS")
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pc.case_id, join_path = decode(cs.seq,"S",cse.seq,"E",cr.seq,
   "R"," ")
  FROM (dummyt d1  WITH seq = value(prefix_cnt)),
   pathology_case pc,
   person p,
   encounter e,
   organization o,
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1),
   case_specimen cs,
   cyto_screening_event cse,
   case_report cr,
   report_task rt
  PLAN (d1)
   JOIN (pc
   WHERE ((pc.case_type_cd+ 0)=gyn_case_type_cd)
    AND (pc.prefix_id=request->prefix_qual[d1.seq].prefix_id)
    AND pc.case_year IN (temp_year, (temp_year+ 1))
    AND ((pc.case_received_dt_tm+ 0) BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(
    cnvtdate(request->end_dt_tm),235959))
    AND ((pc.main_report_cmplete_dt_tm+ 0) != null))
   JOIN (e
   WHERE e.encntr_id=pc.encntr_id)
   JOIN (o
   WHERE o.organization_id=e.organization_id)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (((d2
   WHERE 1=d2.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id
    AND cs.cancel_cd IN (null, 0))
   ) ORJOIN ((((d3
   WHERE 1=d3.seq)
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND cse.active_ind=1)
   ) ORJOIN ((d4
   WHERE 1=d4.seq)
   JOIN (cr
   WHERE pc.case_id=cr.case_id
    AND cr.cancel_cd IN (null, 0))
   JOIN (rt
   WHERE cr.report_id=rt.report_id
    AND ((rt.service_resource_cd+ 0)=request->send_out_resource_cd))
   )) ))
  ORDER BY pc.case_id
  HEAD REPORT
   quarter_idx = 0, case_idx = 0, specimen_cnt = 0
  HEAD pc.case_id
   IF ((pc.case_received_dt_tm <= temp->quarter_qual[1].to_date))
    quarter_idx = 1, q1_case_cnt += 1
    IF (mod(q1_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q1_case_cnt+ 99))
    ENDIF
    case_idx = q1_case_cnt
   ELSEIF ((pc.case_received_dt_tm <= temp->quarter_qual[2].to_date))
    quarter_idx = 2, q2_case_cnt += 1
    IF (mod(q2_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q2_case_cnt+ 99))
    ENDIF
    case_idx = q2_case_cnt
   ELSEIF ((pc.case_received_dt_tm <= temp->quarter_qual[3].to_date))
    quarter_idx = 3, q3_case_cnt += 1
    IF (mod(q3_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q3_case_cnt+ 99))
    ENDIF
    case_idx = q3_case_cnt
   ELSEIF ((pc.case_received_dt_tm <= temp->quarter_qual[4].to_date))
    quarter_idx = 4, q4_case_cnt += 1
    IF (mod(q4_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q4_case_cnt+ 99))
    ENDIF
    case_idx = q4_case_cnt
   ENDIF
   temp->quarter_qual[quarter_idx].case_qual[case_idx].case_id = pc.case_id, temp->quarter_qual[
   quarter_idx].case_qual[case_idx].main_report_cmplete_dt_tm = pc.main_report_cmplete_dt_tm, temp->
   quarter_qual[quarter_idx].case_qual[case_idx].case_received_dt_tm = pc.case_received_dt_tm,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].case_collect_dt_tm = pc.case_collect_dt_tm,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].source_of_smear_cd = pc.source_of_smear_cd,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].received_smear_ind = pc.received_smear_ind,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].birth_dt_tm = p.birth_dt_tm, temp->
   quarter_qual[quarter_idx].case_qual[case_idx].turnaround_weeks = ceil(datetimediff(cnvtdatetime(
      cnvtdate(pc.main_report_cmplete_dt_tm),0),cnvtdatetime(cnvtdate(pc.case_received_dt_tm),0),2)),
   temp->quarter_qual[quarter_idx].case_qual[case_idx].org_name = o.org_name,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].age_in_years = 0, temp_age_str = cnvtage(p
    .birth_dt_tm,pc.case_collect_dt_tm,0), temp_pos_int = findstring("Years",temp_age_str,1,0)
   IF (temp_pos_int > 0)
    temp->quarter_qual[quarter_idx].case_qual[case_idx].age_in_years = cnvtint(substring(1,(
      temp_pos_int - 1),temp_age_str))
   ENDIF
   temp->quarter_qual[quarter_idx].case_qual[case_idx].send_out_specimen_ind = 0, temp->quarter_qual[
   quarter_idx].case_qual[case_idx].event_sequence = 0, temp->quarter_qual[quarter_idx].case_qual[
   case_idx].diagnostic_category_cd = 0.0,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].kc61_multiple_specimens_ind = 0, temp->
   quarter_qual[quarter_idx].case_qual[case_idx].kc61_outcome_of_referral_cd = 0.0, temp->
   quarter_qual[quarter_idx].case_qual[case_idx].kc61_result_of_test_cd = temp->result_of_test_qual[1
   ].code_value,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].kc61_source_of_smear_cd = temp->
   source_of_smear_qual[7].code_value, stat = alterlist(temp->quarter_qual[quarter_idx].case_qual[
    case_idx].specimen_qual,0), stat = alterlist(temp->quarter_qual[quarter_idx].case_qual[case_idx].
    followup_tracking_qual,0),
   specimen_cnt = 0
  DETAIL
   CASE (join_path)
    OF "S":
     specimen_cnt += 1,stat = alterlist(temp->quarter_qual[quarter_idx].case_qual[case_idx].
      specimen_qual,specimen_cnt),temp->quarter_qual[quarter_idx].case_qual[case_idx].specimen_qual[
     specimen_cnt].specimen_cd = cs.specimen_cd,
     IF (specimen_cnt > 1)
      temp->quarter_qual[quarter_idx].case_qual[case_idx].kc61_multiple_specimens_ind = 1
     ENDIF
    OF "E":
     IF ((temp->quarter_qual[quarter_idx].case_qual[case_idx].event_sequence < cse.sequence))
      temp->quarter_qual[quarter_idx].case_qual[case_idx].event_sequence = cse.sequence, temp->
      quarter_qual[quarter_idx].case_qual[case_idx].diagnostic_category_cd = cse
      .diagnostic_category_cd
     ENDIF
    OF "R":
     temp->quarter_qual[quarter_idx].case_qual[case_idx].send_out_specimen_ind = 1
   ENDCASE
  FOOT  pc.case_id
   stat = alterlist(temp->quarter_qual[quarter_idx].case_qual[case_idx].specimen_qual,specimen_cnt)
   IF (specimen_cnt > max_specimen_cnt)
    max_specimen_cnt = specimen_cnt
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->quarter_qual[1].case_qual,q1_case_cnt), stat = alterlist(temp->
    quarter_qual[2].case_qual,q2_case_cnt), stat = alterlist(temp->quarter_qual[3].case_qual,
    q3_case_cnt),
   stat = alterlist(temp->quarter_qual[4].case_qual,q4_case_cnt)
   IF (max_case_cnt < q1_case_cnt)
    max_case_cnt = q1_case_cnt
   ENDIF
   IF (max_case_cnt < q2_case_cnt)
    max_case_cnt = q2_case_cnt
   ENDIF
   IF (max_case_cnt < q3_case_cnt)
    max_case_cnt = q3_case_cnt
   ENDIF
   IF (max_case_cnt < q4_case_cnt)
    max_case_cnt = q4_case_cnt
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pc.case_id
  FROM (dummyt d1  WITH seq = value(prefix_cnt)),
   pathology_case pc,
   cyto_screening_event cse
  PLAN (d1)
   JOIN (pc
   WHERE ((pc.case_type_cd+ 0)=gyn_case_type_cd)
    AND (pc.prefix_id=request->prefix_qual[d1.seq].prefix_id)
    AND pc.case_year IN (temp_year, (temp_year - 1))
    AND ((pc.case_received_dt_tm+ 0) BETWEEN cnvtdatetime(temp->quarter_qual[5].from_date) AND
   cnvtdatetime(temp->quarter_qual[8].to_date))
    AND ((pc.main_report_cmplete_dt_tm+ 0) != null))
   JOIN (cse
   WHERE pc.case_id=cse.case_id
    AND cse.active_ind=1)
  ORDER BY pc.case_id
  HEAD REPORT
   quarter_idx = 0, case_idx = 0, specimen_cnt = 0
  HEAD pc.case_id
   IF ((pc.case_received_dt_tm <= temp->quarter_qual[5].to_date))
    quarter_idx = 5, q5_case_cnt += 1
    IF (mod(q5_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q5_case_cnt+ 99))
    ENDIF
    case_idx = q5_case_cnt
   ELSEIF ((pc.case_received_dt_tm <= temp->quarter_qual[6].to_date))
    quarter_idx = 6, q6_case_cnt += 1
    IF (mod(q6_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q6_case_cnt+ 99))
    ENDIF
    case_idx = q6_case_cnt
   ELSEIF ((pc.case_received_dt_tm <= temp->quarter_qual[7].to_date))
    quarter_idx = 7, q7_case_cnt += 1
    IF (mod(q7_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q7_case_cnt+ 99))
    ENDIF
    case_idx = q7_case_cnt
   ELSEIF ((pc.case_received_dt_tm <= temp->quarter_qual[8].to_date))
    quarter_idx = 8, q8_case_cnt += 1
    IF (mod(q8_case_cnt,100)=1)
     stat = alterlist(temp->quarter_qual[quarter_idx].case_qual,(q8_case_cnt+ 99))
    ENDIF
    case_idx = q8_case_cnt
   ENDIF
   temp->quarter_qual[quarter_idx].case_qual[case_idx].case_id = pc.case_id, temp->quarter_qual[
   quarter_idx].case_qual[case_idx].main_report_cmplete_dt_tm = pc.main_report_cmplete_dt_tm, temp->
   quarter_qual[quarter_idx].case_qual[case_idx].case_received_dt_tm = pc.case_received_dt_tm,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].case_collect_dt_tm = pc.case_collect_dt_tm,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].source_of_smear_cd = pc.source_of_smear_cd,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].received_smear_ind = pc.received_smear_ind,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].turnaround_weeks = ceil(datetimediff(
     cnvtdatetime(cnvtdate(pc.main_report_cmplete_dt_tm),0),cnvtdatetime(cnvtdate(pc
       .case_received_dt_tm),0),2)), temp->quarter_qual[quarter_idx].case_qual[case_idx].age_in_years
    = 0, temp->quarter_qual[quarter_idx].case_qual[case_idx].send_out_specimen_ind = 0,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].event_sequence = 0, temp->quarter_qual[
   quarter_idx].case_qual[case_idx].diagnostic_category_cd = 0.0, temp->quarter_qual[quarter_idx].
   case_qual[case_idx].kc61_multiple_specimens_ind = 0,
   temp->quarter_qual[quarter_idx].case_qual[case_idx].kc61_outcome_of_referral_cd = 0.0, temp->
   quarter_qual[quarter_idx].case_qual[case_idx].kc61_result_of_test_cd = temp->result_of_test_qual[1
   ].code_value, temp->quarter_qual[quarter_idx].case_qual[case_idx].kc61_source_of_smear_cd = temp->
   source_of_smear_qual[7].code_value,
   stat = alterlist(temp->quarter_qual[quarter_idx].case_qual[case_idx].specimen_qual,0), stat =
   alterlist(temp->quarter_qual[quarter_idx].case_qual[case_idx].followup_tracking_qual,0),
   specimen_cnt = 0
  DETAIL
   IF ((temp->quarter_qual[quarter_idx].case_qual[case_idx].event_sequence < cse.sequence))
    temp->quarter_qual[quarter_idx].case_qual[case_idx].event_sequence = cse.sequence, temp->
    quarter_qual[quarter_idx].case_qual[case_idx].diagnostic_category_cd = cse.diagnostic_category_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->quarter_qual[5].case_qual,q5_case_cnt), stat = alterlist(temp->
    quarter_qual[6].case_qual,q6_case_cnt), stat = alterlist(temp->quarter_qual[7].case_qual,
    q7_case_cnt),
   stat = alterlist(temp->quarter_qual[8].case_qual,q8_case_cnt)
   IF (max_case_cnt < q5_case_cnt)
    max_case_cnt = q5_case_cnt
   ENDIF
   IF (max_case_cnt < q6_case_cnt)
    max_case_cnt = q6_case_cnt
   ENDIF
   IF (max_case_cnt < q7_case_cnt)
    max_case_cnt = q7_case_cnt
   ENDIF
   IF (max_case_cnt < q8_case_cnt)
    max_case_cnt = q8_case_cnt
   ENDIF
  WITH nocounter
 ;end select
 IF (q1_case_cnt > 0)
  SELECT INTO "nl:"
   afe.followup_event_id, terminated = evaluate(nullind(afe.term_dt_tm),0,1,0)
   FROM (dummyt d  WITH seq = value(q1_case_cnt)),
    ap_ft_event afe
   PLAN (d)
    JOIN (afe
    WHERE (temp->quarter_qual[1].case_qual[d.seq].case_id=afe.case_id)
     AND ((afe.term_dt_tm <= cnvtdatetime(temp->quarter_qual[4].to_date)) OR (afe.term_reason_cd IN (
    null, 0))) )
   ORDER BY afe.case_id, afe.term_dt_tm DESC
   HEAD REPORT
    term_reason_cnt = 0
   HEAD afe.case_id
    term_reason_cnt = 0
    IF (terminated=1)
     temp->quarter_qual[1].case_qual[d.seq].kc61_outcome_of_referral_cd = temp->
     outcome_of_referral_qual[10].code_value
    ELSE
     temp->quarter_qual[1].case_qual[d.seq].kc61_outcome_of_referral_cd = temp->
     outcome_of_referral_qual[12].code_value
    ENDIF
   DETAIL
    IF (terminated=1)
     term_reason_cnt += 1, stat = alterlist(temp->quarter_qual[1].case_qual[d.seq].
      followup_tracking_qual,term_reason_cnt), temp->quarter_qual[1].case_qual[d.seq].
     followup_tracking_qual[term_reason_cnt].term_reason_cd = afe.term_reason_cd
    ENDIF
   FOOT  afe.case_id
    IF (term_reason_cnt > max_followup_cnt)
     max_followup_cnt = term_reason_cnt
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (((((q5_case_cnt+ q6_case_cnt)+ q7_case_cnt)+ q8_case_cnt) > 0))
  SELECT INTO "nl:"
   afe.followup_event_id, terminated = evaluate(nullind(afe.term_dt_tm),0,1,0)
   FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
    (dummyt d2  WITH seq = value(max_case_cnt)),
    ap_ft_event afe
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(temp->quarter_qual[(d1.seq+ 4)].case_qual,5))
    JOIN (afe
    WHERE (temp->quarter_qual[(d1.seq+ 4)].case_qual[d2.seq].case_id=afe.case_id))
   ORDER BY afe.case_id, afe.term_dt_tm DESC
   HEAD REPORT
    term_reason_cnt = 0
   HEAD afe.case_id
    term_reason_cnt = 0
    IF (terminated=1)
     temp->quarter_qual[(d1.seq+ 4)].case_qual[d2.seq].kc61_outcome_of_referral_cd = temp->
     outcome_of_referral_qual[10].code_value
    ELSE
     temp->quarter_qual[(d1.seq+ 4)].case_qual[d2.seq].kc61_outcome_of_referral_cd = temp->
     outcome_of_referral_qual[12].code_value
    ENDIF
   DETAIL
    IF (terminated=1)
     term_reason_cnt += 1, stat = alterlist(temp->quarter_qual[(d1.seq+ 4)].case_qual[d2.seq].
      followup_tracking_qual,term_reason_cnt), temp->quarter_qual[(d1.seq+ 4)].case_qual[d2.seq].
     followup_tracking_qual[term_reason_cnt].term_reason_cd = afe.term_reason_cd
    ENDIF
   FOOT  afe.case_id
    IF (term_reason_cnt > max_followup_cnt)
     max_followup_cnt = term_reason_cnt
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((n_quarter_cnt * 2))),
   (dummyt d2  WITH seq = value(max_case_cnt)),
   (dummyt d3  WITH seq = value(assigned_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE (temp->quarter_qual[d1.seq].case_qual[d2.seq].diagnostic_category_cd=flatkc61assignedcv->
   code_qual[d3.seq].child_code_value))
  DETAIL
   temp->quarter_qual[d1.seq].case_qual[d2.seq].kc61_result_of_test_cd = flatkc61assignedcv->
   code_qual[d3.seq].parent_code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
   (dummyt d2  WITH seq = value(max_case_cnt)),
   (dummyt d3  WITH seq = value(assigned_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE (temp->quarter_qual[d1.seq].case_qual[d2.seq].source_of_smear_cd=flatkc61assignedcv->
   code_qual[d3.seq].child_code_value))
  DETAIL
   temp->quarter_qual[d1.seq].case_qual[d2.seq].kc61_source_of_smear_cd = flatkc61assignedcv->
   code_qual[d3.seq].parent_code_value
  WITH nocounter
 ;end select
 IF (max_specimen_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
    (dummyt d2  WITH seq = value(max_case_cnt)),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = value(assigned_cnt))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
    JOIN (d3
    WHERE d3.seq <= size(temp->quarter_qual[d1.seq].case_qual[d2.seq].specimen_qual,5)
     AND (temp->quarter_qual[d1.seq].case_qual[d2.seq].kc61_multiple_specimens_ind=0))
    JOIN (d4
    WHERE (temp->quarter_qual[d1.seq].case_qual[d2.seq].specimen_qual[d3.seq].specimen_cd=
    flatkc61assignedcv->code_qual[d4.seq].child_code_value))
   DETAIL
    temp->quarter_qual[d1.seq].case_qual[d2.seq].kc61_multiple_specimens_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (max_followup_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((n_quarter_cnt * 2))),
    (dummyt d2  WITH seq = value(max_case_cnt)),
    (dummyt d3  WITH seq = value(max_followup_cnt)),
    (dummyt d4  WITH seq = value(assigned_cnt)),
    (dummyt d5  WITH seq = value(n_outcome_referral_cnt))
   PLAN (d1)
    JOIN (d2
    WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
    JOIN (d3
    WHERE d3.seq <= size(temp->quarter_qual[d1.seq].case_qual[d2.seq].followup_tracking_qual,5))
    JOIN (d4
    WHERE (temp->quarter_qual[d1.seq].case_qual[d2.seq].followup_tracking_qual[d3.seq].term_reason_cd
    =flatkc61assignedcv->code_qual[d4.seq].child_code_value))
    JOIN (d5
    WHERE (temp->outcome_of_referral_qual[d5.seq].code_value=flatkc61assignedcv->code_qual[d4.seq].
    parent_code_value))
   ORDER BY d2.seq, d5.seq DESC
   DETAIL
    temp->quarter_qual[d1.seq].case_qual[d2.seq].kc61_outcome_of_referral_cd = flatkc61assignedcv->
    code_qual[d4.seq].parent_code_value
   WITH nocounter
  ;end select
 ENDIF
 FREE SET flatkc61assignedcv
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
 SET stat = alterlist(tempkc61->part[n_kc61_part_a1].row,n_part_a1_rows)
 FOR (part_row = 1 TO n_part_a1_rows)
   SET tempkc61->part[n_kc61_part_a1].row[part_row].max_lines = 1
   SET stat = alterlist(tempkc61->part[n_kc61_part_a1].row[part_row].col,n_part_a1_cols)
   FOR (part_col = 1 TO n_part_a1_cols)
    IF (part_row=n_part_a1_result_row)
     IF (part_col=n_part_a1_line_col)
      SET cell_text = "Line No."
      CALL rtf_to_text(cell_text,1,n_part_a1_line_col_size)
     ELSEIF (part_col=n_part_a1_source_col)
      SET cell_text = "Source of smear (Box 9 of form HMR 101/5)"
      CALL rtf_to_text(cell_text,1,n_part_a1_source_col_size)
     ELSEIF (part_col=n_part_a1_total_col)
      SET cell_text = "Total number examined"
      CALL rtf_to_text(cell_text,1,n_part_a1_total_col_size)
     ELSE
      SET cell_text = temp->result_of_test_qual[(part_col - n_part_a1_col_offset)].description
      CALL rtf_to_text(cell_text,1,n_part_a1_result_col_size)
     ENDIF
    ELSEIF (part_row=n_part_a1_subtotal_row)
     IF (part_col=n_part_a1_line_col)
      SET cell_text = format((part_row - n_part_a1_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_a1_line_col_size)
     ELSEIF (part_col=n_part_a1_source_col)
      SET cell_text = "Total of GP and NHS Community Clinics Line 0001 + 0002"
      CALL rtf_to_text(cell_text,1,n_part_a1_source_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ELSEIF (part_row=n_part_a1_total_row)
     IF (part_col=n_part_a1_line_col)
      SET cell_text = format((part_row - n_part_a1_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_a1_line_col_size)
     ELSEIF (part_col=n_part_a1_source_col)
      SET cell_text = "Grand Total"
      CALL rtf_to_text(cell_text,1,n_part_a1_source_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ELSE
     IF (part_col=n_part_a1_line_col)
      SET cell_text = format((part_row - n_part_a1_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_a1_line_col_size)
     ELSEIF (part_col=n_part_a1_source_col)
      SET cell_text = temp->source_of_smear_qual[(part_row - n_part_a1_row_offset)].description
      CALL rtf_to_text(cell_text,1,n_part_a1_source_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ENDIF
    IF (((part_row=n_part_a1_result_row) OR (((part_col=n_part_a1_source_col) OR (part_col=
    n_part_a1_line_col)) ))
     AND cell_text != ""
     AND cell_text != "0")
     SET lines_cnt = cnvtint(size(tmptext->qual,5))
     SET tempkc61->part[n_kc61_part_a1].row[part_row].col[part_col].lines_cnt = lines_cnt
     SET stat = alterlist(tempkc61->part[n_kc61_part_a1].row[part_row].col[part_col].lines,lines_cnt)
     FOR (lines_idx = 1 TO lines_cnt)
       SET tempkc61->part[n_kc61_part_a1].row[part_row].col[part_col].lines[lines_idx].text = tmptext
       ->qual[lines_idx].text
     ENDFOR
     IF ((tempkc61->part[n_kc61_part_a1].row[part_row].max_lines < lines_cnt))
      SET tempkc61->part[n_kc61_part_a1].row[part_row].max_lines = lines_cnt
     ENDIF
    ELSE
     SET tempkc61->part[n_kc61_part_a1].row[part_row].col[part_col].total = 0
     SET tempkc61->part[n_kc61_part_a1].row[part_row].col[part_col].lines_cnt = 0
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
   (dummyt d2  WITH seq = value(max_case_cnt)),
   (dummyt d3  WITH seq = value(n_source_smear_cnt)),
   (dummyt d4  WITH seq = value(n_result_test_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE (temp->source_of_smear_qual[d3.seq].code_value=temp->quarter_qual[d1.seq].case_qual[d2.seq].
   kc61_source_of_smear_cd))
   JOIN (d4
   WHERE (temp->result_of_test_qual[d4.seq].code_value=temp->quarter_qual[d1.seq].case_qual[d2.seq].
   kc61_result_of_test_cd))
  DETAIL
   part_row = (d3.seq+ n_part_a1_row_offset), part_col = (d4.seq+ n_part_a1_col_offset), cell_value
    = tempkc61->part[n_kc61_part_a1].row[part_row].col[part_col].total,
   tempkc61->part[n_kc61_part_a1].row[part_row].col[part_col].total = (cell_value+ 1), cell_value =
   tempkc61->part[n_kc61_part_a1].row[part_row].col[n_part_a1_total_col].total, tempkc61->part[
   n_kc61_part_a1].row[part_row].col[n_part_a1_total_col].total = (cell_value+ 1)
   IF ((((temp->source_of_smear_qual[d3.seq].code_value=temp->source_of_smear_qual[1].code_value))
    OR ((temp->source_of_smear_qual[d3.seq].code_value=temp->source_of_smear_qual[2].code_value))) )
    cell_value = tempkc61->part[n_kc61_part_a1].row[n_part_a1_subtotal_row].col[part_col].total,
    tempkc61->part[n_kc61_part_a1].row[n_part_a1_subtotal_row].col[part_col].total = (cell_value+ 1),
    cell_value = tempkc61->part[n_kc61_part_a1].row[n_part_a1_subtotal_row].col[n_part_a1_total_col].
    total,
    tempkc61->part[n_kc61_part_a1].row[n_part_a1_subtotal_row].col[n_part_a1_total_col].total = (
    cell_value+ 1)
   ENDIF
   cell_value = tempkc61->part[n_kc61_part_a1].row[n_part_a1_total_row].col[part_col].total, tempkc61
   ->part[n_kc61_part_a1].row[n_part_a1_total_row].col[part_col].total = (cell_value+ 1), cell_value
    = tempkc61->part[n_kc61_part_a1].row[n_part_a1_total_row].col[n_part_a1_total_col].total,
   tempkc61->part[n_kc61_part_a1].row[n_part_a1_total_row].col[n_part_a1_total_col].total = (
   cell_value+ 1)
  WITH nocounter
 ;end select
 SET stat = alterlist(tempkc61->part[n_kc61_part_a2].row,n_part_a2_rows)
 FOR (part_row = 1 TO n_part_a2_rows)
   SET tempkc61->part[n_kc61_part_a2].row[part_row].max_lines = 1
   SET stat = alterlist(tempkc61->part[n_kc61_part_a2].row[part_row].col,n_part_a2_cols)
   FOR (part_col = 1 TO n_part_a2_cols)
    IF (part_row=n_part_a2_header_row)
     IF (part_col=n_part_a2_nbr_within_col)
      SET cell_text = "Number within (1)"
      CALL rtf_to_text(cell_text,1,((n_part_a2_weeks_col_size * 5)+ 4))
     ELSEIF (part_col=n_part_a2_linenum_col)
      SET cell_text = "Line No."
      CALL rtf_to_text(cell_text,1,n_part_a2_line_col_size)
     ELSE
      SET cell_text = ""
      CALL rtf_to_text(cell_text,1,n_part_a2_qrtr_col_size)
     ENDIF
    ELSEIF (part_row=n_part_a2_weeks_row)
     IF (part_col=n_part_a2_linenum_col)
      SET cell_text = ""
      CALL rtf_to_text(cell_text,1,n_part_a2_line_col_size)
     ELSEIF (part_col=n_part_a2_quarter_col)
      SET cell_text = "QUARTER"
      CALL rtf_to_text(cell_text,1,n_part_a2_qrtr_col_size)
     ELSEIF (part_col=n_part_a2_total_col)
      SET cell_text = "Total number of smears registered"
      CALL rtf_to_text(cell_text,1,n_part_a2_total_col_size)
     ELSE
      SET cell_text = temp->weeks_range_qual[(part_col - n_part_a2_col_offset)].display
      CALL rtf_to_text(cell_text,1,n_part_a2_weeks_col_size)
     ENDIF
    ELSE
     IF (part_col=n_part_a2_quarter_col)
      IF (part_row=n_part_a2_rows)
       SET cell_text = "TOTAL"
      ELSE
       SET cell_text = concat("QUARTER ",build((part_row - n_part_a2_row_offset))," ",trim(format(
          temp->quarter_qual[(part_row - n_part_a2_row_offset)].to_date,"DD-MMM-YY;;D")))
      ENDIF
      CALL rtf_to_text(cell_text,1,n_part_a2_qrtr_col_size)
     ELSEIF (part_col=n_part_a2_linenum_col)
      SET cell_text = format((part_row - n_part_a2_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_a2_line_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ENDIF
    IF (((part_row=n_part_a2_weeks_row) OR (((part_row=n_part_a2_header_row) OR (((part_col=
    n_part_a2_quarter_col) OR (((part_col=n_part_a2_total_col) OR (part_col=n_part_a2_linenum_col))
    )) )) ))
     AND cell_text != ""
     AND cell_text != "0")
     SET lines_cnt = cnvtint(size(tmptext->qual,5))
     SET tempkc61->part[n_kc61_part_a2].row[part_row].col[part_col].lines_cnt = lines_cnt
     SET stat = alterlist(tempkc61->part[n_kc61_part_a2].row[part_row].col[part_col].lines,lines_cnt)
     FOR (lines_idx = 1 TO lines_cnt)
       SET tempkc61->part[n_kc61_part_a2].row[part_row].col[part_col].lines[lines_idx].text = tmptext
       ->qual[lines_idx].text
     ENDFOR
     IF ((tempkc61->part[n_kc61_part_a2].row[part_row].max_lines < lines_cnt))
      SET tempkc61->part[n_kc61_part_a2].row[part_row].max_lines = lines_cnt
     ENDIF
    ELSE
     SET tempkc61->part[n_kc61_part_a2].row[part_row].col[part_col].total = 0
     SET tempkc61->part[n_kc61_part_a2].row[part_row].col[part_col].lines_cnt = 0
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
   (dummyt d2  WITH seq = value(max_case_cnt)),
   (dummyt d3  WITH seq = value(n_weeks_range_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE (temp->weeks_range_qual[d3.seq].lower_limit <= temp->quarter_qual[d1.seq].case_qual[d2.seq].
   turnaround_weeks)
    AND (temp->weeks_range_qual[d3.seq].upper_limit >= temp->quarter_qual[d1.seq].case_qual[d2.seq].
   turnaround_weeks))
  DETAIL
   part_row = (d1.seq+ n_part_a2_row_offset), part_col = (d3.seq+ n_part_a2_col_offset), cell_value
    = tempkc61->part[n_kc61_part_a2].row[part_row].col[part_col].total,
   tempkc61->part[n_kc61_part_a2].row[part_row].col[part_col].total = (cell_value+ 1), cell_value =
   tempkc61->part[n_kc61_part_a2].row[part_row].col[n_part_a2_total_col].total, tempkc61->part[
   n_kc61_part_a2].row[part_row].col[n_part_a2_total_col].total = (cell_value+ 1),
   cell_value = tempkc61->part[n_kc61_part_a2].row[n_part_a2_rows].col[part_col].total, tempkc61->
   part[n_kc61_part_a2].row[n_part_a2_rows].col[part_col].total = (cell_value+ 1), cell_value =
   tempkc61->part[n_kc61_part_a2].row[n_part_a2_rows].col[n_part_a2_total_col].total,
   tempkc61->part[n_kc61_part_a2].row[n_part_a2_rows].col[n_part_a2_total_col].total = (cell_value+ 1
   )
  WITH nocounter
 ;end select
 SET n_part_a3_rows = 4
 SELECT INTO "nl:"
  org_name = temp->quarter_qual[d1.seq].case_qual[d2.seq].org_name
  FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
   (dummyt d2  WITH seq = value(max_case_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5)
    AND (temp->quarter_qual[d1.seq].case_qual[d2.seq].received_smear_ind=1))
  ORDER BY org_name
  HEAD REPORT
   received_cnt = 0
  HEAD org_name
   n_part_a3_rows += 1, received_cnt += 1
   IF (received_cnt > size(tempkc61->a3_received,5))
    stat = alterlist(tempkc61->a3_received,(received_cnt+ 9))
   ENDIF
   tempkc61->a3_received[received_cnt].org_name = temp->quarter_qual[d1.seq].case_qual[d2.seq].
   org_name
  WITH nocounter
 ;end select
 IF (received_cnt=0)
  SET stat = alterlist(tempkc61->a3_received,1)
  SET n_part_a3_rows += 1
 ELSE
  SET stat = alterlist(tempkc61->a3_received,received_cnt)
 ENDIF
 SET n_part_a3_smear_sent_row = 2
 SET n_part_a3_smear_recd_row = (n_part_a3_smear_sent_row+ 1)
 SET n_part_a3_subheader_row = (n_part_a3_rows - 1)
 SET n_part_a3_multi_row = n_part_a3_rows
 SET stat = alterlist(tempkc61->part[n_kc61_part_a3].row,n_part_a3_rows)
 FOR (part_row = 1 TO n_part_a3_rows)
   SET tempkc61->part[n_kc61_part_a3].row[part_row].max_lines = 1
   SET stat = alterlist(tempkc61->part[n_kc61_part_a3].row[part_row].col,n_part_a3_cols)
   FOR (part_col = 1 TO n_part_a3_cols)
    IF (part_row=n_part_a3_header_row)
     IF (part_col=n_part_a3_total_col)
      SET cell_text = "NUMBER"
      CALL rtf_to_text(cell_text,1,n_part_a3_total_col_size)
     ELSEIF (part_col=n_part_a3_sent_col)
      SET cell_text = "SENT TO/RECEIVED FROM (please give details)"
      CALL rtf_to_text(cell_text,1,n_part_a3_sent_col_size)
     ELSEIF (part_col=n_part_a3_primary_col)
      SET cell_text = "PRIMARY SCREENING OR OTHER (please specify)(2)"
      CALL rtf_to_text(cell_text,1,n_part_a3_primary_size)
     ELSE
      SET cell_text = ""
     ENDIF
    ELSEIF (part_row=n_part_a3_smear_sent_row)
     IF (part_col=n_part_a3_header_col)
      SET cell_text = "REQUESTS SENT TO ANOTHER LABORATORY FOR SCREENING"
      CALL rtf_to_text(cell_text,1,n_part_a3_header_col_size)
     ELSEIF (part_col=n_part_a3_linenum_col)
      SET cell_text = "0001"
      CALL rtf_to_text(cell_text,1,n_part_a3_line_col_size)
     ELSEIF (part_col=n_part_a3_sent_col)
      SET cell_text = uar_get_code_display(request->send_out_resource_cd)
      CALL rtf_to_text(cell_text,1,n_part_a3_sent_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ELSEIF (part_row >= n_part_a3_smear_recd_row
     AND part_row < n_part_a3_subheader_row)
     IF (part_col=n_part_a3_header_col
      AND part_row=n_part_a3_smear_recd_row)
      SET cell_text = "REQUESTS RECEIVED FROM ANOTHER LABORATORY FOR SCREENING"
      CALL rtf_to_text(cell_text,1,n_part_a3_header_col_size)
     ELSEIF (part_col=n_part_a3_linenum_col
      AND part_row=n_part_a3_smear_recd_row)
      SET cell_text = "0002"
      CALL rtf_to_text(cell_text,1,n_part_a3_line_col_size)
     ELSEIF (part_col=n_part_a3_sent_col)
      SET cell_text = tempkc61->a3_received[((part_row - n_part_a3_smear_recd_row)+ 1)].org_name
      CALL rtf_to_text(cell_text,1,n_part_a3_sent_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ELSEIF (part_row=n_part_a3_subheader_row)
     IF (part_col=n_part_a3_header_col)
      SET cell_text = "WHERE MORE THAN ONE SMEAR IS TAKEN"
      CALL rtf_to_text(cell_text,1,n_part_a3_header_col_size)
     ELSE
      SET cell_text = ""
     ENDIF
    ELSEIF (part_row=n_part_a3_multi_row)
     IF (part_col=n_part_a3_header_col)
      SET cell_text =
      "NUMBER OF INSTANCES WHERE A SINGLE REPORT IS DERIVED FROM MORE THAN ONE SAMPLE(3)"
      CALL rtf_to_text(cell_text,1,n_part_a3_header_col_size)
     ELSEIF (part_col=n_part_a3_linenum_col)
      SET cell_text = "0003"
      CALL rtf_to_text(cell_text,1,n_part_a3_line_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ELSE
     SET cell_text = ""
    ENDIF
    IF (cell_text != ""
     AND cell_text != "0")
     SET lines_cnt = cnvtint(size(tmptext->qual,5))
     SET tempkc61->part[n_kc61_part_a3].row[part_row].col[part_col].lines_cnt = lines_cnt
     SET stat = alterlist(tempkc61->part[n_kc61_part_a3].row[part_row].col[part_col].lines,lines_cnt)
     FOR (lines_idx = 1 TO lines_cnt)
       SET tempkc61->part[n_kc61_part_a3].row[part_row].col[part_col].lines[lines_idx].text = tmptext
       ->qual[lines_idx].text
     ENDFOR
     IF ((tempkc61->part[n_kc61_part_a3].row[part_row].max_lines < lines_cnt))
      SET tempkc61->part[n_kc61_part_a3].row[part_row].max_lines = lines_cnt
     ENDIF
    ELSE
     SET tempkc61->part[n_kc61_part_a3].row[part_row].col[part_col].total = 0
     SET tempkc61->part[n_kc61_part_a3].row[part_row].col[part_col].lines_cnt = 0
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  org_name = temp->quarter_qual[d1.seq].case_qual[d2.seq].org_name
  FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
   (dummyt d2  WITH seq = value(max_case_cnt)),
   dummyt d3,
   (dummyt d4  WITH seq = value(received_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
   JOIN (d3)
   JOIN (d4
   WHERE (tempkc61->a3_received[d3.seq].org_name=temp->quarter_qual[d1.seq].case_qual[d2.seq].
   org_name))
  ORDER BY org_name
  DETAIL
   IF ((temp->quarter_qual[d1.seq].case_qual[d2.seq].send_out_specimen_ind=1))
    cell_value = tempkc61->part[n_kc61_part_a3].row[n_part_a3_smear_sent_row].col[n_part_a3_total_col
    ].total, tempkc61->part[n_kc61_part_a3].row[n_part_a3_smear_sent_row].col[n_part_a3_total_col].
    total = (cell_value+ 1)
   ENDIF
   IF ((temp->quarter_qual[d1.seq].case_qual[d2.seq].received_smear_ind=1)
    AND received_cnt > 0)
    cell_value = tempkc61->part[n_kc61_part_a3].row[((n_part_a3_smear_recd_row+ d4.seq) - 1)].col[
    n_part_a3_total_col].total, tempkc61->part[n_kc61_part_a3].row[((n_part_a3_smear_recd_row+ d4.seq
    ) - 1)].col[n_part_a3_total_col].total = (cell_value+ 1)
   ENDIF
   IF ((temp->quarter_qual[d1.seq].case_qual[d2.seq].kc61_multiple_specimens_ind=1))
    cell_value = tempkc61->part[n_kc61_part_a3].row[n_part_a3_multi_row].col[n_part_a3_total_col].
    total, tempkc61->part[n_kc61_part_a3].row[n_part_a3_multi_row].col[n_part_a3_total_col].total = (
    cell_value+ 1)
   ENDIF
  WITH nocounter, outerjoin = d3
 ;end select
 SET stat = alterlist(tempkc61->part[n_kc61_part_b].row,n_part_b_rows)
 FOR (part_row = 1 TO n_part_b_rows)
   SET tempkc61->part[n_kc61_part_b].row[part_row].max_lines = 1
   SET stat = alterlist(tempkc61->part[n_kc61_part_b].row[part_row].col,n_part_b_cols)
   FOR (part_col = 1 TO n_part_b_cols)
    IF (part_row=n_part_b_result_row)
     IF (part_col=n_part_b_line_col)
      SET cell_text = "Line No."
      CALL rtf_to_text(cell_text,1,n_part_b_line_col_size)
     ELSEIF (part_col=n_part_b_age_col)
      SET cell_text = "Age"
      CALL rtf_to_text(cell_text,1,n_part_b_age_col_size)
     ELSEIF (part_col=n_part_b_total_col)
      SET cell_text = "Total number examined"
      CALL rtf_to_text(cell_text,1,n_part_b_total_col_size)
     ELSE
      SET cell_text = temp->result_of_test_qual[(part_col - n_part_b_col_offset)].description
      CALL rtf_to_text(cell_text,1,n_part_b_result_col_size)
     ENDIF
    ELSEIF (part_row=n_part_b_subtotal_row)
     IF (part_col=n_part_b_line_col)
      SET cell_text = format((part_row - n_part_b_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_b_line_col_size)
     ELSEIF (part_col=n_part_b_age_col)
      SET cell_text = "Total 20-64 Lines 0002 - 0010"
      CALL rtf_to_text(cell_text,1,n_part_b_age_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ELSEIF (part_row=n_part_b_total_row)
     IF (part_col=n_part_b_line_col)
      SET cell_text = format((part_row - n_part_b_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_b_line_col_size)
     ELSEIF (part_col=n_part_b_age_col)
      SET cell_text = "Grand Total"
      CALL rtf_to_text(cell_text,1,n_part_b_age_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ELSE
     IF (part_col=n_part_b_line_col)
      SET cell_text = format((part_row - n_part_b_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_b_line_col_size)
     ELSEIF (part_col=n_part_b_age_col)
      SET cell_text = temp->age_range_qual[(part_row - n_part_b_row_offset)].display
      CALL rtf_to_text(cell_text,1,n_part_b_age_col_size)
     ELSE
      SET cell_text = "0"
     ENDIF
    ENDIF
    IF (((part_row=n_part_b_result_row) OR (((part_col=n_part_b_age_col) OR (((part_col=
    n_part_b_line_col) OR (part_col=n_part_b_total_col)) )) ))
     AND cell_text != ""
     AND cell_text != "0")
     SET lines_cnt = cnvtint(size(tmptext->qual,5))
     SET tempkc61->part[n_kc61_part_b].row[part_row].col[part_col].lines_cnt = lines_cnt
     SET stat = alterlist(tempkc61->part[n_kc61_part_b].row[part_row].col[part_col].lines,lines_cnt)
     FOR (lines_idx = 1 TO lines_cnt)
       SET tempkc61->part[n_kc61_part_b].row[part_row].col[part_col].lines[lines_idx].text = tmptext
       ->qual[lines_idx].text
     ENDFOR
     IF ((tempkc61->part[n_kc61_part_b].row[part_row].max_lines < lines_cnt))
      SET tempkc61->part[n_kc61_part_b].row[part_row].max_lines = lines_cnt
     ENDIF
    ELSE
     SET tempkc61->part[n_kc61_part_b].row[part_row].col[part_col].total = 0
     SET tempkc61->part[n_kc61_part_b].row[part_row].col[part_col].lines_cnt = 0
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
   (dummyt d2  WITH seq = value(max_case_cnt)),
   (dummyt d3  WITH seq = value(2)),
   (dummyt d4  WITH seq = value(n_result_test_cnt)),
   (dummyt d5  WITH seq = value(n_age_range_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[d1.seq].case_qual,5))
   JOIN (d3
   WHERE (temp->source_of_smear_qual[d3.seq].code_value=temp->quarter_qual[d1.seq].case_qual[d2.seq].
   kc61_source_of_smear_cd))
   JOIN (d4
   WHERE (temp->result_of_test_qual[d4.seq].code_value=temp->quarter_qual[d1.seq].case_qual[d2.seq].
   kc61_result_of_test_cd))
   JOIN (d5
   WHERE (temp->age_range_qual[d5.seq].lower_limit <= temp->quarter_qual[d1.seq].case_qual[d2.seq].
   age_in_years)
    AND (temp->age_range_qual[d5.seq].upper_limit >= temp->quarter_qual[d1.seq].case_qual[d2.seq].
   age_in_years))
  DETAIL
   part_row = (d5.seq+ n_part_b_row_offset), part_col = (d4.seq+ n_part_b_col_offset), cell_value =
   tempkc61->part[n_kc61_part_b].row[part_row].col[part_col].total,
   tempkc61->part[n_kc61_part_b].row[part_row].col[part_col].total = (cell_value+ 1), cell_value =
   tempkc61->part[n_kc61_part_b].row[part_row].col[n_part_b_total_col].total, tempkc61->part[
   n_kc61_part_b].row[part_row].col[n_part_b_total_col].total = (cell_value+ 1)
   IF ((temp->age_range_qual[d5.seq].lower_limit >= temp->age_range_qual[2].lower_limit)
    AND (temp->age_range_qual[d5.seq].lower_limit <= temp->age_range_qual[10].upper_limit))
    cell_value = tempkc61->part[n_kc61_part_b].row[n_part_b_subtotal_row].col[part_col].total,
    tempkc61->part[n_kc61_part_b].row[n_part_b_subtotal_row].col[part_col].total = (cell_value+ 1),
    cell_value = tempkc61->part[n_kc61_part_b].row[n_part_b_subtotal_row].col[n_part_b_total_col].
    total,
    tempkc61->part[n_kc61_part_b].row[n_part_b_subtotal_row].col[n_part_b_total_col].total = (
    cell_value+ 1)
   ENDIF
   cell_value = tempkc61->part[n_kc61_part_b].row[n_part_b_total_row].col[part_col].total, tempkc61->
   part[n_kc61_part_b].row[n_part_b_total_row].col[part_col].total = (cell_value+ 1), cell_value =
   tempkc61->part[n_kc61_part_b].row[n_part_b_total_row].col[n_part_b_total_col].total,
   tempkc61->part[n_kc61_part_b].row[n_part_b_total_row].col[n_part_b_total_col].total = (cell_value
   + 1)
  WITH nocounter
 ;end select
 SET stat = alterlist(tempkc61->part[n_kc61_part_c1].row,n_part_c_rows)
 FOR (part_row = 1 TO n_part_c_rows)
   SET tempkc61->part[n_kc61_part_c1].row[part_row].max_lines = 1
   SET stat = alterlist(tempkc61->part[n_kc61_part_c1].row[part_row].col,n_part_c_cols)
   FOR (part_col = 1 TO n_part_c_cols)
    IF (part_row=n_part_c_result_row)
     IF (part_col=n_part_c_line_col)
      SET cell_text = "Line No."
      CALL rtf_to_text(cell_text,1,n_part_c_line_col_size)
     ELSEIF (part_col=n_part_c_outcome_col)
      SET cell_text = "Outcome of referral(1)"
      CALL rtf_to_text(cell_text,1,n_part_c_outcome_col_size)
     ELSEIF (part_col=3)
      SET cell_text = temp->result_of_test_qual[1].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=4)
      SET cell_text = temp->result_of_test_qual[3].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=5)
      SET cell_text = temp->result_of_test_qual[4].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=6)
      SET cell_text = temp->result_of_test_qual[5].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=7)
      SET cell_text = temp->result_of_test_qual[6].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=8)
      SET cell_text = temp->result_of_test_qual[7].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=9)
      SET cell_text = temp->result_of_test_qual[8].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=n_part_c_total_col)
      SET cell_text = "Total"
      CALL rtf_to_text(cell_text,1,n_part_c_total_col_size)
     ELSE
      SET cell_text = ""
     ENDIF
    ELSE
     IF (part_col=n_part_c_line_col)
      SET cell_text = format((part_row - n_part_c_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_c_line_col_size)
     ELSEIF (part_col=n_part_c_outcome_col)
      IF (part_row=n_part_c_rows)
       SET cell_text = "Total"
       CALL rtf_to_text(cell_text,1,n_part_c_outcome_col_size)
      ELSE
       SET cell_text = temp->outcome_of_referral_qual[(part_row - n_part_c_row_offset)].description
       CALL rtf_to_text(cell_text,1,n_part_c_outcome_col_size)
      ENDIF
     ELSE
      SET cell_text = "0"
     ENDIF
    ENDIF
    IF (((part_row=n_part_c_result_row) OR (((part_col=n_part_c_outcome_col) OR (((part_col=
    n_part_c_line_col) OR (part_col=n_part_c_total_col)) )) ))
     AND cell_text != ""
     AND cell_text != "0")
     SET lines_cnt = cnvtint(size(tmptext->qual,5))
     SET tempkc61->part[n_kc61_part_c1].row[part_row].col[part_col].lines_cnt = lines_cnt
     SET stat = alterlist(tempkc61->part[n_kc61_part_c1].row[part_row].col[part_col].lines,lines_cnt)
     FOR (lines_idx = 1 TO lines_cnt)
       SET tempkc61->part[n_kc61_part_c1].row[part_row].col[part_col].lines[lines_idx].text = tmptext
       ->qual[lines_idx].text
     ENDFOR
     IF ((tempkc61->part[n_kc61_part_c1].row[part_row].max_lines < lines_cnt))
      SET tempkc61->part[n_kc61_part_c1].row[part_row].max_lines = lines_cnt
     ENDIF
    ELSE
     SET tempkc61->part[n_kc61_part_c1].row[part_row].col[part_col].total = 0
     SET tempkc61->part[n_kc61_part_c1].row[part_row].col[part_col].lines_cnt = 0
    ENDIF
   ENDFOR
 ENDFOR
 IF (q1_case_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(q1_case_cnt)),
    (dummyt d2  WITH seq = value(n_outcome_referral_cnt)),
    (dummyt d3  WITH seq = value(n_result_test_cnt))
   PLAN (d1)
    JOIN (d2
    WHERE (temp->outcome_of_referral_qual[d2.seq].code_value=temp->quarter_qual[1].case_qual[d1.seq].
    kc61_outcome_of_referral_cd))
    JOIN (d3
    WHERE (temp->result_of_test_qual[d3.seq].code_value=temp->quarter_qual[1].case_qual[d1.seq].
    kc61_result_of_test_cd))
   HEAD REPORT
    total_x = 0.0, total_y = 0.0, total_a = 0.0,
    total_b = 0.0, tempkc61->c1_pos_pred_value = 0.0, tempkc61->c1_lost_to_followup = 0.0
   DETAIL
    total_x_ind = 0, total_y_ind = 0, part_row = (d2.seq+ n_part_c_row_offset)
    IF (d3.seq=1)
     part_col = (d3.seq+ n_part_c_col_offset)
    ELSEIF (d3.seq=2)
     part_col = 0
    ELSE
     part_col = ((d3.seq+ n_part_c_col_offset) - 1)
    ENDIF
    IF (d3.seq IN (5, 6, 7, 8))
     IF (d2.seq IN (1, 2, 3, 4, 5))
      total_x += 1
     ELSEIF (d2.seq IN (6, 7, 8, 9))
      total_y += 1
     ENDIF
    ENDIF
    IF (part_col > 0)
     IF (d2.seq IN (11, 12))
      total_a += 1
     ENDIF
     cell_value = tempkc61->part[n_kc61_part_c1].row[part_row].col[part_col].total, tempkc61->part[
     n_kc61_part_c1].row[part_row].col[part_col].total = (cell_value+ 1), cell_value = tempkc61->
     part[n_kc61_part_c1].row[part_row].col[n_part_c_total_col].total,
     tempkc61->part[n_kc61_part_c1].row[part_row].col[n_part_c_total_col].total = (cell_value+ 1),
     cell_value = tempkc61->part[n_kc61_part_c1].row[n_part_c_rows].col[part_col].total, tempkc61->
     part[n_kc61_part_c1].row[n_part_c_rows].col[part_col].total = (cell_value+ 1),
     cell_value = tempkc61->part[n_kc61_part_c1].row[n_part_c_rows].col[n_part_c_total_col].total,
     tempkc61->part[n_kc61_part_c1].row[n_part_c_rows].col[n_part_c_total_col].total = (cell_value+ 1
     )
    ENDIF
   FOOT REPORT
    IF (((total_x+ total_y) > 0))
     tempkc61->c1_pos_pred_value = ((total_x * 100)/ (total_x+ total_y))
    ENDIF
    total_b = tempkc61->part[n_kc61_part_c1].row[n_part_c_rows].col[n_part_c_total_col].total
    IF (total_b > 0)
     tempkc61->c1_lost_to_followup = ((total_a * 100)/ total_b)
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(tempkc61->part[n_kc61_part_c2].row,n_part_c_rows)
 FOR (part_row = 1 TO n_part_c_rows)
   SET tempkc61->part[n_kc61_part_c2].row[part_row].max_lines = 1
   SET stat = alterlist(tempkc61->part[n_kc61_part_c2].row[part_row].col,n_part_c_cols)
   FOR (part_col = 1 TO n_part_c_cols)
    IF (part_row=n_part_c_result_row)
     IF (part_col=n_part_c_line_col)
      SET cell_text = "Line No."
      CALL rtf_to_text(cell_text,1,n_part_c_line_col_size)
     ELSEIF (part_col=n_part_c_outcome_col)
      SET cell_text = "Outcome of referral(1)"
      CALL rtf_to_text(cell_text,1,n_part_c_outcome_col_size)
     ELSEIF (part_col=3)
      SET cell_text = temp->result_of_test_qual[1].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=4)
      SET cell_text = temp->result_of_test_qual[3].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=5)
      SET cell_text = temp->result_of_test_qual[4].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=6)
      SET cell_text = temp->result_of_test_qual[5].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=7)
      SET cell_text = temp->result_of_test_qual[6].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=8)
      SET cell_text = temp->result_of_test_qual[7].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=9)
      SET cell_text = temp->result_of_test_qual[8].description
      CALL rtf_to_text(cell_text,1,n_part_c_result_col_size)
     ELSEIF (part_col=n_part_c_total_col)
      SET cell_text = "Total"
      CALL rtf_to_text(cell_text,1,n_part_c_total_col_size)
     ELSE
      SET cell_text = ""
     ENDIF
    ELSE
     IF (part_col=n_part_c_line_col)
      SET cell_text = format((part_row - n_part_c_row_offset),"####;P0")
      CALL rtf_to_text(cell_text,1,n_part_c_line_col_size)
     ELSEIF (part_col=n_part_c_outcome_col)
      IF (part_row=n_part_c_rows)
       SET cell_text = "Total"
       CALL rtf_to_text(cell_text,1,n_part_c_outcome_col_size)
      ELSE
       SET cell_text = temp->outcome_of_referral_qual[(part_row - n_part_c_row_offset)].description
       CALL rtf_to_text(cell_text,1,n_part_c_outcome_col_size)
      ENDIF
     ELSE
      SET cell_text = "0"
     ENDIF
    ENDIF
    IF (((part_row=n_part_c_result_row) OR (((part_col=n_part_c_outcome_col) OR (((part_col=
    n_part_c_line_col) OR (part_col=n_part_c_total_col)) )) ))
     AND cell_text != ""
     AND cell_text != "0")
     SET lines_cnt = cnvtint(size(tmptext->qual,5))
     SET tempkc61->part[n_kc61_part_c2].row[part_row].col[part_col].lines_cnt = lines_cnt
     SET stat = alterlist(tempkc61->part[n_kc61_part_c2].row[part_row].col[part_col].lines,lines_cnt)
     FOR (lines_idx = 1 TO lines_cnt)
       SET tempkc61->part[n_kc61_part_c2].row[part_row].col[part_col].lines[lines_idx].text = tmptext
       ->qual[lines_idx].text
     ENDFOR
     IF ((tempkc61->part[n_kc61_part_c2].row[part_row].max_lines < lines_cnt))
      SET tempkc61->part[n_kc61_part_c2].row[part_row].max_lines = lines_cnt
     ENDIF
    ELSE
     SET tempkc61->part[n_kc61_part_c2].row[part_row].col[part_col].total = 0
     SET tempkc61->part[n_kc61_part_c2].row[part_row].col[part_col].lines_cnt = 0
    ENDIF
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(n_quarter_cnt)),
   (dummyt d2  WITH seq = value(max_case_cnt)),
   (dummyt d3  WITH seq = value(n_outcome_referral_cnt)),
   (dummyt d4  WITH seq = value(n_result_test_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->quarter_qual[(d1.seq+ 4)].case_qual,5))
   JOIN (d3
   WHERE (temp->outcome_of_referral_qual[d3.seq].code_value=temp->quarter_qual[(d1.seq+ 4)].
   case_qual[d2.seq].kc61_outcome_of_referral_cd))
   JOIN (d4
   WHERE (temp->result_of_test_qual[d4.seq].code_value=temp->quarter_qual[(d1.seq+ 4)].case_qual[d2
   .seq].kc61_result_of_test_cd))
  HEAD REPORT
   total_x = 0.0, total_y = 0.0, total_a = 0.0,
   total_b = 0.0, tempkc61->c2_pos_pred_value = 0.0, tempkc61->c2_lost_to_followup = 0.0
  DETAIL
   cur_quarter = (d1.seq+ 4), part_row = (d3.seq+ n_part_c_row_offset)
   IF (d4.seq=1)
    part_col = (d4.seq+ n_part_c_col_offset)
   ELSEIF (d4.seq=2)
    part_col = 0
   ELSE
    part_col = ((d4.seq+ n_part_c_col_offset) - 1)
   ENDIF
   IF (d4.seq IN (4, 5, 6, 7))
    IF (d3.seq IN (1, 2, 3, 4, 5))
     total_x += 1
    ELSEIF (d3.seq IN (6, 7, 8, 9))
     total_y += 1
    ENDIF
   ENDIF
   IF (part_col > 0)
    IF (d3.seq IN (11, 12))
     total_a += 1
    ENDIF
    cell_value = tempkc61->part[n_kc61_part_c2].row[part_row].col[part_col].total, tempkc61->part[
    n_kc61_part_c2].row[part_row].col[part_col].total = (cell_value+ 1), cell_value = tempkc61->part[
    n_kc61_part_c2].row[part_row].col[n_part_c_total_col].total,
    tempkc61->part[n_kc61_part_c2].row[part_row].col[n_part_c_total_col].total = (cell_value+ 1),
    cell_value = tempkc61->part[n_kc61_part_c2].row[n_part_c_rows].col[part_col].total, tempkc61->
    part[n_kc61_part_c2].row[n_part_c_rows].col[part_col].total = (cell_value+ 1),
    cell_value = tempkc61->part[n_kc61_part_c2].row[n_part_c_rows].col[n_part_c_total_col].total,
    tempkc61->part[n_kc61_part_c2].row[n_part_c_rows].col[n_part_c_total_col].total = (cell_value+ 1)
   ENDIF
  FOOT REPORT
   IF (((total_x+ total_y) > 0))
    tempkc61->c2_pos_pred_value = ((total_x * 100)/ (total_x+ total_y))
   ENDIF
   total_b = tempkc61->part[n_kc61_part_c2].row[n_part_c_rows].col[n_part_c_total_col].total
   IF (total_b > 0)
    tempkc61->c2_lost_to_followup = ((total_a * 100)/ total_b)
   ENDIF
  WITH nocounter
 ;end select
 FREE SET temp
#report_maker
 EXECUTE cpm_create_file_name_logical "aps_cyto_kc61", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  FROM (dummyt d1  WITH seq = value(1))
  PLAN (d1)
  HEAD REPORT
   line1 = fillstring(125,"_"), line2 = fillstring(44,"_"), line3 = fillstring(67,"_"),
   line4 = fillstring(36,"_"), line5 = fillstring(43,"_"), line6 = fillstring(123,"_"),
   line_cnt = 0
  HEAD PAGE
   row + 0
  DETAIL
   col 1, "DH FORM",
   CALL center("PATHOLOGY LABORATORIES - CERVICAL CYTOLOGY",1,125),
   col 122, "KC61", row + 1,
   CALL center("AND OUTCOME OF GYNAECOLOGICAL REFERRALS.",1,125), row + 1, col 1,
   line1, row + 1,
   CALL center("This return has been approved by the Review of Central Returns Steering",1,125),
   row + 1,
   CALL center("Committee - ROCR.  Reference ROCR/OR/0076/001",1,125), row + 2,
   col 90, "Year ending", col 104,
   temp_report_date, col 123, "(1)",
   row + 2, col 34, "Trust Name",
   col + 1, line5, col + 8,
   "Trust Code", col + 2, "__ __ __",
   col 123, "(2)", row + 2,
   col 43, line2, row + 1,
   col 42, "|",
   CALL center("A separate return is required for",42,87),
   col 87, "|", row + 1,
   col 42, "|",
   CALL center("each pathology laboratory that",42,87),
   col 87, "|", row + 1,
   col 42, "|",
   CALL center("carries out gynaecological cytology",42,87),
   col 87, "|", row + 1,
   col 42, "|", line2,
   "|", row + 2, col 81,
   "Pathology Laboratory Code", col + 2, "__ __ __ __ __ (3)",
   row + 2, col 29, "Pathology Laboratory Name",
   col + 1, line3, row + 2,
   col 70, "Name of contact", col + 1,
   line4, row + 2, col 76,
   "Telephone", col + 1, line4,
   row + 3, col 34, "If you have any queries regarding completion of this form, please contact SD3G",
   row + 2, col 70, "Telephone:",
   col 86, "020 7972 5697", row + 2,
   col 70, "Fax:", col 86,
   "020 7972 5662", row + 2, col 70,
   "Return to:", col 86, "Department of Health",
   row + 1, col 86, "Statistics Division 3G",
   row + 1, col 86, "Room 430B",
   row + 1, col 86, "Skipton House",
   row + 1, col 86, "Elephant and Castle",
   row + 1, col 86, "London",
   row + 1, col 86, "SE1 6LH",
   row + 2, col 2, line6,
   row + 1, col 1,
   "| For NHS use.  Please use this space to record anything relevant to the quality or consistency of the data.",
   col 125, "|", row + 1
   FOR (line_cnt = 1 TO 12)
     col 1, "|", col 125,
     "|", row + 1
   ENDFOR
   col 1, "|", col 2,
   line6, col 125, "|",
   row + 2, col 1,
   "I confirm that these data are, to the best of my knowledge, an accurate representation",
   row + 1, col 1,
   "of the results obtained from the cervical screening carried out at this laboratory.",
   row + 3, col 1, "Signed",
   col 10, line3, col + 4,
   "Date", col + 1, line4,
   row + 1, col 10, "Consultant Pathologist",
   row + 1
  FOOT PAGE
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter, maxcol = 132, maxrow = 65,
   compress
 ;end select
 SELECT INTO value(reply->print_status_data.print_filename)
  row_lines = tempkc61->part[n_kc61_part_a1].row[d1.seq].max_lines, cell_lines = tempkc61->part[
  n_kc61_part_a1].row[d1.seq].col[d3.seq].lines_cnt
  FROM (dummyt d1  WITH seq = value(n_part_a1_rows)),
   (dummyt d2  WITH seq = value(n_part_a1_maxlines)),
   (dummyt d3  WITH seq = value(n_part_a1_cols))
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= tempkc61->part[n_kc61_part_a1].row[d1.seq].max_lines))
   JOIN (d3)
  ORDER BY d1.seq, d2.seq, d3.seq
  HEAD REPORT
   line1 = fillstring(125,"_"), line2 = fillstring(93,"_"), header_ind = 1,
   BREAK, header_ind = 0
  HEAD PAGE
   IF (header_ind=0)
    col 1, "DH FORM",
    CALL center("PART A1     NUMBER OF SMEARS EXAMINED BY SOURCE OF SMEAR",1,125),
    col 123, "KC61", row + 2,
    col 1, line1, row + 1,
    call reportmove('COL',((4+ n_part_a1_line_col_size)+ n_part_a1_source_col_size),0), line2, row +
    1,
    col 17, "|", col 37,
    "Results of test (See categories in box 22 of form HMR 101/5)", col 112, "|",
    row + 1, col 1, line1
   ENDIF
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   row + 1, col 0
  DETAIL
   IF (d3.seq=n_part_a1_line_col)
    col 1
   ELSEIF (d3.seq=n_part_a1_source_col)
    call reportmove('COL',(2+ n_part_a1_line_col_size),0), "|"
   ELSEIF (d3.seq=n_part_a1_total_col)
    col 112, "|"
   ELSE
    call reportmove('COL',(((3+ n_part_a1_line_col_size)+ n_part_a1_source_col_size)+ ((d3.seq - 3)
     * (n_part_a1_result_col_size+ 1))),0), "|"
   ENDIF
   IF (cell_lines=0)
    IF ((d2.seq=((row_lines+ 1)/ 2)))
     col + 2, cell_value = cnvtint(tempkc61->part[n_kc61_part_a1].row[d1.seq].col[d3.seq].total),
     cell_value"#######"
    ENDIF
   ELSE
    line_offset = ((row_lines - cell_lines)/ 2)
    IF (d2.seq > line_offset
     AND (d2.seq <= (line_offset+ cell_lines)))
     tempkc61->part[n_kc61_part_a1].row[d1.seq].col[d3.seq].lines[(d2.seq - line_offset)].text
    ENDIF
   ENDIF
  FOOT  d2.seq
   row + 0
  FOOT  d1.seq
   row + 1, col 1, line1
  FOOT PAGE
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter, maxcol = 132, maxrow = 65,
   append, compress
 ;end select
 SELECT INTO value(reply->print_status_data.print_filename)
  row_lines = tempkc61->part[n_kc61_part_a2].row[d1.seq].max_lines
  FROM (dummyt d1  WITH seq = value(n_part_a2_rows)),
   (dummyt d2  WITH seq = value(n_part_a2_maxlines)),
   (dummyt d3  WITH seq = value(n_part_a2_cols))
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= tempkc61->part[n_kc61_part_a2].row[d1.seq].max_lines))
   JOIN (d3)
  ORDER BY d1.seq, d2.seq, d3.seq
  HEAD REPORT
   line1 = fillstring(124,"_"), line2 = fillstring(90,"_"), line3 = fillstring(125,"_"),
   header_ind = 1, BREAK, header_ind = 0
  HEAD PAGE
   IF (header_ind=0)
    col 1, "DH FORM",
    CALL center("PART A2     LABORATORY PROCESSING: FROM RECEIPT OF SMEAR TO AUTHORIZATION OF REPORT",
    1,125),
    col 122, "KC61", row + 2,
    col 1, line3, row + 2,
    col 1, line1
   ENDIF
  HEAD d1.seq
   IF (((d1.seq=n_part_a3_smear_sent_row) OR (d1.seq=n_part_a3_multi_row)) )
    col 71
   ENDIF
  HEAD d2.seq
   row + 1
  DETAIL
   col 0, "|"
   IF (d3.seq=n_part_a2_linenum_col)
    col 1
   ELSEIF (d3.seq=n_part_a2_quarter_col)
    col n_part_a2_line_col_size, "|"
   ELSEIF (d3.seq=n_part_a2_total_col)
    call reportmove('COL',(n_part_a2_line_col_size+ n_part_a2_qrtr_col_size),0), "|"
   ELSEIF (d1.seq != n_part_a2_header_row)
    call reportmove('COL',((((3+ n_part_a2_line_col_size)+ n_part_a2_qrtr_col_size)+
    n_part_a2_total_col_size)+ ((d3.seq - (n_part_a2_col_offset+ 1)) * (n_part_a2_weeks_col_size+ 1))
    ),0), "|"
   ELSEIF ((d3.seq=(n_part_a2_total_col+ 1)))
    call reportmove('COL',(((3+ n_part_a2_line_col_size)+ n_part_a2_qrtr_col_size)+
    n_part_a2_total_col_size),0), "|"
   ENDIF
   a2_cell_lines = tempkc61->part[n_kc61_part_a2].row[d1.seq].col[d3.seq].lines_cnt
   IF (a2_cell_lines=0
    AND d1.seq != n_part_a2_header_row
    AND d1.seq != n_part_a2_weeks_row)
    IF ((d2.seq=((row_lines+ 1)/ 2)))
     IF (d3.seq=n_part_a2_total_col)
      col + 1
     ENDIF
     col + 1, a2_cell_value = cnvtint(tempkc61->part[n_kc61_part_a2].row[d1.seq].col[d3.seq].total),
     a2_cell_value"######"
    ENDIF
   ELSEIF (a2_cell_lines != 0)
    line_offset = ((row_lines - a2_cell_lines)/ 2)
    IF (d2.seq > line_offset
     AND (d2.seq <= (line_offset+ a2_cell_lines)))
     tempkc61->part[n_kc61_part_a2].row[d1.seq].col[d3.seq].lines[(d2.seq - line_offset)].text
    ENDIF
   ENDIF
  FOOT  d2.seq
   row + 0, col 125, "|"
  FOOT  d1.seq
   row + 1
   IF (d1.seq=n_part_a2_header_row)
    col 0, "|", col n_part_a2_line_col_size,
    "|", call reportmove('COL',(n_part_a2_line_col_size+ n_part_a2_qrtr_col_size),0), "|",
    call reportmove('COL',(((4+ n_part_a2_line_col_size)+ n_part_a2_qrtr_col_size)+
    n_part_a2_total_col_size),0), line2
   ELSE
    col 1, line1
   ENDIF
  FOOT PAGE
   row + 0
  FOOT REPORT
   last_row = row
  WITH nocounter, maxcol = 132, maxrow = 65,
   append, compress
 ;end select
 SELECT INTO value(reply->print_status_data.print_filename)
  row_lines = tempkc61->part[n_kc61_part_a3].row[d1.seq].max_lines
  FROM (dummyt d1  WITH seq = value(n_part_a3_rows)),
   (dummyt d2  WITH seq = value(n_part_a3_maxlines)),
   (dummyt d3  WITH seq = value(n_part_a3_cols))
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= tempkc61->part[n_kc61_part_a3].row[d1.seq].max_lines))
   JOIN (d3)
  ORDER BY d1.seq, d2.seq, d3.seq
  HEAD REPORT
   line1 = fillstring(124,"_"), line2 = fillstring(69,"_"), line3 = fillstring(62,"_")
  HEAD PAGE
   row + 2, call reportmove('COL',(n_part_a3_line_col_size+ 1),0), "PART A3",
   row + 2, call reportmove('COL',(n_part_a3_line_col_size+ 1),0),
   "REQUESTS SCREENED FOR/BY ANOTHER LABORATORY",
   call reportmove('COL',(((3+ n_part_a3_line_col_size)+ n_part_a3_header_col_size)+
   n_part_a3_total_col_size),0), "SENT TO/RECEIVED FROM (please give details)", row + 1
   IF (curpage=1)
    call reportmove('COL',((2+ n_part_a3_line_col_size)+ n_part_a3_header_col_size),0), line2
   ELSE
    col 1, line1, row + 1
   ENDIF
  HEAD d1.seq
   IF (curpage=1
    AND (row > ((64 - last_row) - n_part_a2_maxlines)))
    BREAK
   ENDIF
   IF (((d1.seq=n_part_a3_smear_sent_row) OR (d1.seq=n_part_a3_multi_row)) )
    col 71
   ENDIF
   IF (d1.seq=n_part_a3_subheader_row)
    row + 1, col 1,
    "Note: The laboratory which receives the original request should issue the report and include the information",
    row + 1, col 1, "within this return.",
    row + 2
   ENDIF
  HEAD d2.seq
   row + 1
   IF (d1.seq != n_part_a3_header_row
    AND d1.seq != n_part_a3_subheader_row)
    col 0, "|"
   ENDIF
  DETAIL
   IF (d3.seq=n_part_a3_linenum_col)
    col 1
   ELSEIF (d3.seq=n_part_a3_header_col)
    col n_part_a3_line_col_size
    IF (d1.seq != n_part_a3_header_row
     AND d1.seq != n_part_a3_subheader_row)
     "|"
    ENDIF
   ELSEIF (d3.seq=n_part_a3_total_col)
    call reportmove('COL',((1+ n_part_a3_line_col_size)+ n_part_a3_header_col_size),0)
    IF (d1.seq != n_part_a3_subheader_row)
     "|"
    ENDIF
   ELSEIF (d3.seq=n_part_a3_sent_col)
    call reportmove('COL',(((2+ n_part_a3_line_col_size)+ n_part_a3_header_col_size)+
    n_part_a3_total_col_size),0)
    IF (d1.seq != n_part_a3_subheader_row)
     "|"
    ENDIF
   ELSEIF (d3.seq=n_part_a3_primary_col)
    call reportmove('COL',((((3+ n_part_a3_line_col_size)+ n_part_a3_header_col_size)+
    n_part_a3_total_col_size)+ n_part_a3_sent_col_size),0)
    IF (d1.seq < n_part_a3_subheader_row)
     "|"
    ENDIF
   ENDIF
   a3_cell_lines = tempkc61->part[n_kc61_part_a3].row[d1.seq].col[d3.seq].lines_cnt
   IF (d3.seq=n_part_a3_primary_col
    AND d2.seq=1
    AND a3_cell_value > 0
    AND d1.seq >= n_part_a3_smear_sent_row
    AND d1.seq < n_part_a3_subheader_row)
    "PRIMARY"
   ENDIF
   IF (a3_cell_lines != 0)
    IF (d1.seq=n_part_a3_subheader_row)
     col + 1
    ENDIF
    line_offset = ((row_lines - a3_cell_lines)/ 2)
    IF (d2.seq > line_offset
     AND (d2.seq <= (line_offset+ a3_cell_lines)))
     tempkc61->part[n_kc61_part_a3].row[d1.seq].col[d3.seq].lines[(d2.seq - line_offset)].text
    ENDIF
   ELSEIF (d3.seq=n_part_a3_total_col
    AND d1.seq >= n_part_a3_smear_sent_row
    AND d1.seq != n_part_a3_subheader_row)
    IF ((d2.seq=((row_lines+ 1)/ 2)))
     a3_cell_value = cnvtint(tempkc61->part[n_kc61_part_a3].row[d1.seq].col[n_part_a3_total_col].
      total), a3_cell_value"######"
    ENDIF
   ENDIF
  FOOT  d2.seq
   row + 0
   IF (d1.seq < n_part_a3_subheader_row)
    col 125, "|"
   ENDIF
  FOOT  d1.seq
   row + 1
   IF (d1.seq >= n_part_a3_subheader_row)
    col 1, line3
   ELSEIF (d1.seq >= n_part_a3_smear_recd_row
    AND (d1.seq < (n_part_a3_subheader_row - 1)))
    col 0, "|", col n_part_a3_line_col_size,
    "|", call reportmove('COL',((1+ n_part_a3_line_col_size)+ n_part_a3_header_col_size),0), "|",
    call reportmove('COL',((2+ n_part_a3_line_col_size)+ n_part_a3_header_col_size),0), line2
   ELSE
    col 1, line1
   ENDIF
  FOOT PAGE
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter, maxcol = 132, maxrow = 64,
   append, compress
 ;end select
 SELECT INTO value(reply->print_status_data.print_filename)
  row_lines = tempkc61->part[n_kc61_part_b].row[d1.seq].max_lines, cell_lines = tempkc61->part[
  n_kc61_part_b].row[d1.seq].col[d3.seq].lines_cnt
  FROM (dummyt d1  WITH seq = value(n_part_b_rows)),
   (dummyt d2  WITH seq = value(n_part_b_maxlines)),
   (dummyt d3  WITH seq = value(n_part_b_cols))
  PLAN (d1)
   JOIN (d2
   WHERE (d2.seq <= tempkc61->part[n_kc61_part_b].row[d1.seq].max_lines))
   JOIN (d3)
  ORDER BY d1.seq, d2.seq, d3.seq
  HEAD REPORT
   line1 = fillstring(125,"_"), line2 = fillstring(94,"_"), header_ind = 1,
   BREAK, header_ind = 0
  HEAD PAGE
   IF (header_ind=0)
    col 1, "DH FORM",
    CALL center("PART B     RESULTS OF SMEARS FROM GP AND NHS COMMUNITY",1,125),
    col 122, "KC61", row + 1,
    CALL center("CLINICS ONLY BY AGE GROUP OF WOMEN",1,125), row + 1, col 1,
    line1, row + 1, call reportmove('COL',((7+ n_part_b_line_col_size)+ n_part_b_age_col_size),0),
    line2, row + 1, call reportmove('COL',((6+ n_part_b_line_col_size)+ n_part_b_age_col_size),0),
    "|", col 37, "Results of test (See categories in box 22 of form HMR 101/5)",
    col 112, "|", row + 1,
    col 1, line1
   ENDIF
  HEAD d1.seq
   row + 0
  HEAD d2.seq
   row + 1, col 0
  DETAIL
   IF (d3.seq=n_part_b_line_col)
    col 1
   ELSEIF (d3.seq=n_part_b_age_col)
    call reportmove('COL',(2+ n_part_b_line_col_size),0), "|"
   ELSEIF (d3.seq=n_part_b_total_col)
    col 112, "|"
   ELSE
    call reportmove('COL',(((6+ n_part_b_line_col_size)+ n_part_b_age_col_size)+ ((d3.seq - 3) * (
    n_part_b_result_col_size+ 1))),0), "|"
   ENDIF
   IF (cell_lines=0)
    IF ((d2.seq=((row_lines+ 1)/ 2)))
     col + 2, cell_value = cnvtint(tempkc61->part[n_kc61_part_b].row[d1.seq].col[d3.seq].total),
     cell_value"#######"
    ENDIF
   ELSE
    line_offset = ((row_lines - cell_lines)/ 2)
    IF (d2.seq > line_offset
     AND (d2.seq <= (line_offset+ cell_lines)))
     tempkc61->part[n_kc61_part_b].row[d1.seq].col[d3.seq].lines[(d2.seq - line_offset)].text
    ENDIF
   ENDIF
  FOOT  d2.seq
   row + 0
  FOOT  d1.seq
   row + 1, col 1, line1
  FOOT PAGE
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter, maxcol = 132, maxrow = 65,
   append, compress
 ;end select
 FOR (part_c_cnt = 1 TO 2)
   SELECT INTO value(reply->print_status_data.print_filename)
    row_lines = tempkc61->part[((n_kc61_part_c1+ part_c_cnt) - 1)].row[d1.seq].max_lines, cell_lines
     = tempkc61->part[((n_kc61_part_c1+ part_c_cnt) - 1)].row[d1.seq].col[d3.seq].lines_cnt
    FROM (dummyt d1  WITH seq = value(n_part_c_rows)),
     (dummyt d2  WITH seq = value(n_part_c_maxlines)),
     (dummyt d3  WITH seq = value(n_part_c_cols))
    PLAN (d1)
     JOIN (d2
     WHERE (d2.seq <= tempkc61->part[((n_kc61_part_c1+ part_c_cnt) - 1)].row[d1.seq].max_lines))
     JOIN (d3)
    ORDER BY d1.seq, d2.seq, d3.seq
    HEAD REPORT
     line1 = fillstring(125,"_"), line2 = fillstring(83,"_"), line3 = fillstring(105,"_"),
     line_cnt = 0, pos_pred_value = 0.0, lost_to_followup = 0.0,
     header_ind = 1, BREAK, header_ind = 0
    HEAD PAGE
     IF (header_ind=0)
      col 1, "DH FORM"
      IF (part_c_cnt=1)
       CALL center(concat("PART C1     OUTCOME BY ",trim(cnvtupper(temp_report_date),3),
        " FOR WOMEN RECOMMENDED FOR GYNAECOLOGICAL REFERRAL"),1,125)
      ELSE
       CALL center(concat("PART C2     OUTCOME BY ",trim(cnvtupper(c2_report_date),3),
        " FOR WOMEN RECOMMENDED FOR GYNAECOLOGICAL REFERRAL"),1,125)
      ENDIF
      col 122, "KC61", row + 1
      IF (part_c_cnt=1)
       CALL center(concat("WHERE THE SMEAR WAS REGISTERED DURING APRIL - JUNE ",build(temp_year)),1,
       125)
      ELSE
       CALL center(concat("WHERE THE SMEAR WAS REGISTERED DURING APRIL ",build((temp_year - 1)),
        " - MARCH ",build(temp_year)),1,125)
      ENDIF
      row + 1, col 1, line1,
      row + 1, call reportmove('COL',((2+ n_part_c_line_col_size)+ n_part_c_outcome_col_size),0),
      line2,
      row + 1, call reportmove('COL',((1+ n_part_c_line_col_size)+ n_part_c_outcome_col_size),0),
      "|Most significant result (See categories in box 22 of form HMR 101/5)",
      call reportmove('COL',(((1+ n_part_c_line_col_size)+ n_part_c_outcome_col_size)+ (7 * (
      n_part_c_result_col_size+ 1))),0), "|", row + 1,
      col 1, line1
     ENDIF
    HEAD d1.seq
     row + 0
    HEAD d2.seq
     row + 1, col 0
    DETAIL
     IF (d3.seq=n_part_c_line_col)
      col 1
     ELSEIF (d3.seq=n_part_c_outcome_col)
      col n_part_c_line_col_size, "|"
     ELSEIF (d3.seq=n_part_c_total_col)
      call reportmove('COL',(((1+ n_part_c_line_col_size)+ n_part_c_outcome_col_size)+ (7 * (
      n_part_c_result_col_size+ 1))),0), "|"
     ELSE
      call reportmove('COL',(((1+ n_part_c_line_col_size)+ n_part_c_outcome_col_size)+ ((d3.seq - 3)
       * (n_part_c_result_col_size+ 1))),0), "|"
     ENDIF
     IF (cell_lines=0)
      IF ((d2.seq=((row_lines+ 1)/ 2)))
       col + 2, cell_value = cnvtint(tempkc61->part[((n_kc61_part_c1+ part_c_cnt) - 1)].row[d1.seq].
        col[d3.seq].total), cell_value"#######"
      ENDIF
     ELSE
      line_offset = ((row_lines - cell_lines)/ 2)
      IF (d2.seq > line_offset
       AND (d2.seq <= (line_offset+ cell_lines)))
       tempkc61->part[((n_kc61_part_c1+ part_c_cnt) - 1)].row[d1.seq].col[d3.seq].lines[(d2.seq -
       line_offset)].text
      ENDIF
     ENDIF
    FOOT  d2.seq
     row + 0
    FOOT  d1.seq
     row + 1, col 1, line1
    FOOT PAGE
     row + 0
    FOOT REPORT
     IF (part_c_cnt=1)
      pos_pred_value = tempkc61->c1_pos_pred_value, lost_to_followup = tempkc61->c1_lost_to_followup
     ELSE
      pos_pred_value = tempkc61->c2_pos_pred_value, lost_to_followup = tempkc61->c2_lost_to_followup
     ENDIF
     row + 1, call reportmove('COL',(1+ n_part_c_line_col_size),0), "Positive Predictive Value (PPV)",
     col 70, "Lost to follow-up", row + 1,
     call reportmove('COL',(1+ n_part_c_line_col_size),0), "Total x", col 70,
     "Total a", row + 1, call reportmove('COL',(1+ n_part_c_line_col_size),0),
     "-------", cell_text = concat("X 100 = ",format(pos_pred_value,"###.##")," %"), col + 8,
     cell_text, col 70, "-------",
     cell_text = concat("X 100 = ",format(lost_to_followup,"###.##")," %"), col + 8, cell_text,
     row + 1, call reportmove('COL',(1+ n_part_c_line_col_size),0), "Total x + y",
     col 70, "Total b", row + 2,
     call reportmove('COL',(1+ n_part_c_line_col_size),0),
     "PPV should be regarded as a guide for the audit of histology", col 70,
     "(This figure should be less than 5%)", row + 1, call reportmove('COL',(1+
     n_part_c_line_col_size),0),
     "and cytology and is not a precise measure of accuracy", row + 2, call reportmove('COL',(1+
     n_part_c_line_col_size),0),
     "Details of non cervical cancers (row 0014)", row + 1, call reportmove('COL',(1+
     n_part_c_line_col_size),0),
     line3
     FOR (line_cnt = 1 TO 3)
       row + 1, col n_part_c_line_col_size, "|",
       call reportmove('COL',(((1+ n_part_c_line_col_size)+ n_part_c_outcome_col_size)+ (7 * (
       n_part_c_result_col_size+ 1))),0), "|"
     ENDFOR
     call reportmove('COL',(1+ n_part_c_line_col_size),0), line3
    WITH nocounter, maxcol = 132, maxrow = 65,
     append, compress
   ;end select
 ENDFOR
 SELECT INTO value(reply->print_status_data.print_filename)
  FROM (dummyt d1  WITH seq = value(1))
  PLAN (d1)
  HEAD REPORT
   line1 = fillstring(125,"_"), BREAK
  HEAD PAGE
   row + 0
  DETAIL
   col 1, "DH FORM",
   CALL center("ROCR/OR/0076/001 COMMENTS",1,130),
   col 122, "KC61", row + 1,
   col 1, line1, row + 2,
   col 1, "PART A1:", row + 1,
   col 5,
   "More detailed instructions on the completion of this return can be found in the NHS Data Dictionary & Manual",
   row + 2,
   col 1, "PART A2:", row + 1,
   col 5, "(1) Days - relate to calendar days", row + 2,
   col 1, "PART A3:", row + 1,
   col 5, "(2) Other may include rapid review, checking, abnormal, or clinical reporting etc.", row
    + 1,
   col 5, "(3) Full details should be available on request", row + 1,
   col 5,
   "More detailed instructions on the completion of this return can be found in the NHS Data Dictionary & Manual",
   row + 2,
   col 1, "PART B:", row + 1,
   col 5,
   "More detailed instructions on the completion of this return can be found in the NHS Data Dictionary & Manual",
   row + 1,
   col 5, "NB: Total number examined as recorded in Part B should equal row 0008 in Part A1", row + 2,
   col 1, "PART C1, C2:", row + 1,
   col 5,
   "(1) Where more than one specimen is taken from the same women, the most severe result only should be recorded",
   row + 1,
   col 5,
   "(2) Include colposcopy assessment only, smear taken only, cytological surveillance in colposcopy, ablation",
   row + 1,
   col 5, "(see guidance notes)", row + 1,
   col 5,
   "(3) Include deceased, community smear surveillance, colposcopy delayed for known reason eg pregnancy, currently",
   row + 1,
   col 5,
   "in failsafe system following non attendance at colposcopy, patient refusal, referral to other specialty for",
   row + 1,
   col 5, "non-cervical disease, patient moved away (notification through 'Exeter system')", row + 1,
   col 5, "(4) Include biopsy taken but result not yet known", row + 1,
   col 5,
   "(5) Include outcome unknown to laboratory, no record of referral and/or patient, patient moved away (no information)",
   row + 1,
   col 5,
   "(private/other NHS hospital referral (if outcome unknown), incorrect patient details, patient lost to system",
   row + 2
  FOOT PAGE
   row + 0
  FOOT REPORT
   row + 0
  WITH nocounter, maxcol = 132, maxrow = 65,
   append, compress
 ;end select
 SET reply->status_data.status = "S"
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#exit_script
END GO
