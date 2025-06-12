CREATE PROGRAM dcp_mu_patient_list_driver:dba
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
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE provider_relation_error = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "provider_relation_error",
   "For the selected provider relation filter do not specify the provider name."))
 DECLARE demographics_error = vc WITH constant(uar_i18ngetmessage(i18nhandle,"demographics_error",
   "At least one of the demographics or other filters are required."))
 DECLARE lab_test_error = vc WITH constant(uar_i18ngetmessage(i18nhandle,"lab_test_error",
   "You must specify values for all fields associated with Lab Test / Result filter."))
 DECLARE no_data_error = vc WITH constant(uar_i18ngetmessage(i18nhandle,"no_data_error",
   "No data found."))
 RECORD pat_request(
   1 outdev = vc
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 loc_facility_cd = f8
   1 loc_nurse_unit_cd = f8
   1 demographics
     2 sex_cd = f8
     2 age_num = i4
     2 age_unit = vc
     2 language_cd = f8
     2 race_cd = f8
     2 ethnic_grp_cd = f8
     2 contact_method_cd = f8
     2 pcp_prsnl_list = vc
     2 cause_of_death_type = vc
     2 cause_of_death_id = f8
   1 prob_diag_nomen_id = f8
   1 prob_diag_nomen_id2 = f8
   1 prob_diag_nomen_id3 = f8
   1 catalog_cd = f8
   1 catalog_cd2 = f8
   1 catalog_cd3 = f8
   1 allergy_nomen_id = f8
   1 allergy_nomen_id2 = f8
   1 allergy_nomen_id3 = f8
   1 task_assay_cd = f8
   1 result_sign = i2
   1 result_value_numeric = f8
   1 primary_sort = vc
   1 primary_sort_desc = i2
   1 secondary_sort = vc
   1 secondary_sort_desc = i2
   1 reltn_option = i4
 )
 DECLARE code_set = vc WITH protect, constant("CODESET")
 DECLARE event_code = vc WITH protect, constant("EVENTCODE")
 DECLARE getpromptlist(which_prompt=i2) = vc
 DECLARE ispromptany(which_prompt=i2) = i2
 DECLARE ispromptlist(which_prompt=i2) = i2
 DECLARE ispromptsingle(which_prompt=i2) = i2
 DECLARE ispromptempty(which_prompt=i2) = i2
 DECLARE parsedateprompt(date_str=vc,default_date=vc,time=i4) = dq8
 DECLARE _evaluatedatestr(date_str=vc) = i4
 DECLARE _parsedate(date_str=vc) = i4
 SUBROUTINE getpromptlist(which_prompt)
   DECLARE prompt_reflect = vc WITH noconstant(reflect(parameter(which_prompt,0))), private
   DECLARE count = i4 WITH noconstant(0), private
   DECLARE item_num = i4 WITH noconstant(0), private
   DECLARE return_val = vc WITH noconstant(" "), private
   DECLARE enq = c1 WITH constant(char(5)), private
   IF (ispromptempty(which_prompt))
    SET return_val = " "
   ELSEIF (ispromptlist(which_prompt))
    SET count = cnvtint(substring(2,(textlen(prompt_reflect) - 1),prompt_reflect))
   ELSEIF (ispromptsingle(which_prompt))
    SET count = 1
   ENDIF
   IF (count > 0)
    FOR (item_num = 1 TO count)
      SET return_val = build(return_val,value(parameter(which_prompt,item_num)),enq)
    ENDFOR
    SET return_val = replace(trim(return_val,3),enq,",")
    IF (count=1)
     SET return_val = build("=",return_val)
    ELSE
     SET return_val = build("in (",return_val,")")
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptany(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (prompt_reflect="C1")
    IF (ichar(value(parameter(which_prompt,1)))=42)
     SET return_val = 1
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptlist(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (substring(1,1,prompt_reflect)="L")
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptsingle(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3)) > 0
    AND  NOT (ispromptany(which_prompt))
    AND  NOT (ispromptlist(which_prompt)))
    SET return_val = 1
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE ispromptempty(which_prompt)
   DECLARE prompt_reflect = vc WITH private, noconstant(reflect(parameter(which_prompt,0)))
   DECLARE return_val = i2 WITH private, noconstant(0)
   IF (textlen(trim(prompt_reflect,3))=0)
    SET return_val = 1
   ELSEIF (ispromptsingle(which_prompt))
    IF (substring(1,1,prompt_reflect)="C")
     IF (textlen(trim(value(parameter(which_prompt,0)),3))=0)
      SET return_val = 1
     ENDIF
    ELSE
     IF (cnvtreal(value(parameter(which_prompt,1)))=0)
      SET return_val = 1
     ENDIF
    ENDIF
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SUBROUTINE parsedateprompt(date_str,default_date,time)
   DECLARE _return_val = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE _time = i4 WITH constant(cnvtint(time)), private
   DECLARE _date = i4 WITH constant(_parsedate(date_str)), private
   IF (_date=0.0)
    CASE (substring(1,1,reflect(default_date)))
     OF "F":
      SET _return_val = cnvtdatetime(cnvtdate(default_date),_time)
     OF "C":
      SET _return_val = cnvtdatetime(_evaluatedatestr(default_date),_time)
     OF "I":
      SET _return_val = cnvtdatetime(default_date,_time)
     ELSE
      SET _return_val = 0
    ENDCASE
   ELSE
    SET _return_val = cnvtdatetime(_date,_time)
   ENDIF
   RETURN(_return_val)
 END ;Subroutine
 SUBROUTINE _parsedate(date_str)
   DECLARE _return_val = dq8 WITH private, noconstant(cnvtdatetime(curdate,curtime3))
   DECLARE _time = i4 WITH constant(0), private
   IF (isnumeric(date_str))
    DECLARE _date = vc WITH constant(trim(cnvtstring(date_str))), private
    SET _return_val = cnvtdatetime(cnvtdate(_date),_time)
    IF (_return_val=0.0)
     SET _return_val = cnvtdatetime(cnvtint(_date),_time)
    ENDIF
   ELSE
    DECLARE _date = vc WITH constant(trim(date_str)), private
    IF (textlen(trim(_date))=0)
     SET _return_val = 0
    ELSE
     IF (_date IN ("*CURDATE*"))
      SET _return_val = cnvtdatetime(_evaluatedatestr(_date),_time)
     ELSE
      SET _return_val = cnvtdatetime(cnvtdate2(_date,"DD-MMM-YYYY"),_time)
     ENDIF
    ENDIF
   ENDIF
   RETURN(cnvtdate(_return_val))
 END ;Subroutine
 SUBROUTINE _evaluatedatestr(date_str)
   DECLARE _dq8 = dq8 WITH noconstant, private
   DECLARE _parse = vc WITH constant(concat("set _dq8 = cnvtdatetime(",date_str,", 0) go")), private
   CALL parser(_parse)
   RETURN(cnvtdate(_dq8))
 END ;Subroutine
 RECORD pat_reply(
   1 qual_cnt = i4
   1 qual[*]
     2 person_id = f8
     2 mrn = vc
     2 name_full_formatted = vc
     2 sex_cd = f8
     2 sex = vc
     2 birth_dt_tm = dq8
     2 dob = vc
     2 age = vc
     2 language_cd = f8
     2 preferred_language = vc
     2 race_cd = f8
     2 race = vc
     2 ethnic_grp_cd = f8
     2 ethnicity = vc
     2 cause_of_death_id = f8
     2 preliminary_cause_of_death = vc
     2 contact_method_cd = f8
     2 patient_communication_preference = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 facility = vc
     2 loc_nurse_unit_cd = f8
     2 clinic = vc
     2 reg_dt_tm = dq8
     2 reg_date = vc
     2 pcp_prsnl_id = f8
     2 primary_care_physician = vc
     2 prob_diag_id = f8
     2 problem = vc
     2 prob_diag_id2 = f8
     2 problem2 = vc
     2 prob_diag_id3 = f8
     2 problem3 = vc
     2 problem_sort = vc
     2 medications = vc
     2 medications2 = vc
     2 medications3 = vc
     2 medications_sort = vc
     2 allergy_instance_id = f8
     2 medication_allergy = vc
     2 allergy_instance_id2 = f8
     2 medication_allergy2 = vc
     2 allergy_instance_id3 = f8
     2 medication_allergy3 = vc
     2 medication_allergy_sort = vc
     2 lab_results = vc
     2 lab_results_sort = f8
     2 physician_name = vc
     2 lifetime_physician = vc
     2 visit_physician = vc
 )
 RECORD pat_reply_temp(
   1 qual_cnt = i4
   1 qual[*]
     2 person_id = f8
     2 mrn = vc
     2 name_full_formatted = vc
     2 sex_cd = f8
     2 sex = vc
     2 birth_dt_tm = dq8
     2 dob = vc
     2 age = vc
     2 language_cd = f8
     2 preferred_language = vc
     2 race_cd = f8
     2 race = vc
     2 ethnic_grp_cd = f8
     2 ethnicity = vc
     2 cause_of_death_id = f8
     2 preliminary_cause_of_death = vc
     2 contact_method_cd = f8
     2 patient_communication_preference = vc
     2 encntr_id = f8
     2 loc_facility_cd = f8
     2 facility = vc
     2 loc_nurse_unit_cd = f8
     2 clinic = vc
     2 reg_dt_tm = dq8
     2 reg_date = vc
     2 pcp_prsnl_id = f8
     2 primary_care_physician = vc
     2 prob_diag_id = f8
     2 problem = vc
     2 prob_diag_id2 = f8
     2 problem2 = vc
     2 prob_diag_id3 = f8
     2 problem3 = vc
     2 problem_sort = vc
     2 medications = vc
     2 medications2 = vc
     2 medications3 = vc
     2 medications_sort = vc
     2 allergy_instance_id = f8
     2 medication_allergy = vc
     2 allergy_instance_id2 = f8
     2 medication_allergy2 = vc
     2 allergy_instance_id3 = f8
     2 medication_allergy3 = vc
     2 medication_allergy_sort = vc
     2 lab_results = vc
     2 lab_results_sort = f8
     2 physician_name = vc
     2 lifetime_physician = vc
     2 visit_physician = vc
 )
 RECORD child_request(
   1 beg_dt_tm = dq8
   1 end_dt_tm = dq8
   1 loc_facility_cd = f8
   1 loc_nurse_unit_cd = f8
   1 nomenclature_id = f8
   1 nomenclature_id2 = f8
   1 nomenclature_id3 = f8
   1 catalog_cd = f8
   1 catalog_cd2 = f8
   1 catalog_cd3 = f8
   1 task_assay_cd = f8
   1 result_sign = i2
   1 result_value_numeric = f8
   1 cnt = i4
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
 )
 RECORD child_reply(
   1 cnt = i4
   1 qual[*]
     2 person_id = f8
     2 encntr_id = f8
     2 item_id = f8
     2 item_display = vc
     2 item_id2 = f8
     2 item_display2 = vc
     2 item_id3 = f8
     2 item_display3 = vc
 )
 RECORD grid(
   1 col_cnt = i4
   1 cols[*]
     2 col_name = vc
   1 row_cnt = i4
   1 row[*]
     2 col[*]
       3 value = vc
 )
 DECLARE age_unit_days = vc WITH protect, constant("D")
 DECLARE age_unit_weeks = vc WITH protect, constant("W")
 DECLARE age_unit_months = vc WITH protect, constant("M")
 DECLARE age_unit_years = vc WITH protect, constant("Y")
 DECLARE child_type_prob = i2 WITH protect, constant(1)
 DECLARE child_type_med = i2 WITH protect, constant(2)
 DECLARE child_type_allergy = i2 WITH protect, constant(3)
 DECLARE child_type_lab = i2 WITH protect, constant(4)
 DECLARE ea_type_mrn_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!8021"))
 DECLARE prsnl_r_pcp_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!4593"))
 DECLARE auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE inpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17006"))
 DECLARE outpatient_class_cd = f8 WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!17007"))
 DECLARE query_person_ind = i2 WITH protect, noconstant(0)
 DECLARE query_race_ind = i2 WITH protect, noconstant(0)
 DECLARE query_person_pat_ind = i2 WITH protect, noconstant(0)
 DECLARE query_pcp_ind = i2 WITH protect, noconstant(0)
 DECLARE query_prob_diag_ind = i2 WITH protect, noconstant(0)
 DECLARE query_med_ind = i2 WITH protect, noconstant(0)
 DECLARE query_allergy_ind = i2 WITH protect, noconstant(0)
 DECLARE query_lab_ind = i2 WITH protect, noconstant(0)
 DECLARE query_ce_ind = i2 WITH protect, noconstant(0)
 DECLARE query_ind = i2 WITH protect, noconstant(0)
 DECLARE beg_birth_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE end_birth_dt_tm = dq8 WITH protect, noconstant(0.0)
 DECLARE parser_loc = vc WITH protect, noconstant("1=1")
 DECLARE parser_sex = vc WITH protect, noconstant("1=1")
 DECLARE parser_dob = vc WITH protect, noconstant("1=1")
 DECLARE parser_lang = vc WITH protect, noconstant("1=1")
 DECLARE parser_ethnic = vc WITH protect, noconstant("1=1")
 DECLARE parser_death = vc WITH protect, noconstant("1=1")
 DECLARE parser_pcp = vc WITH protect, noconstant("1=1")
 DECLARE parser_encntr_type = vc WITH protect, noconstant("1=1")
 DECLARE exp_idx = i4 WITH protect, noconstant(0)
 DECLARE loc_idx = i4 WITH protect, noconstant(0)
 DECLARE encntr_idx = i4 WITH protect, noconstant(0)
 DECLARE person_idx = i4 WITH protect, noconstant(0)
 DECLARE row_idx = i4 WITH protect, noconstant(0)
 DECLARE col_idx = i4 WITH protect, noconstant(0)
 DECLARE race_list = vc WITH protect, noconstant(" ")
 DECLARE pcp_list = vc WITH protect, noconstant(" ")
 DECLARE incomplete_lab_fields = i2 WITH protect, noconstant(0)
 DECLARE query_lab_result_count = i2 WITH protect, noconstant(0)
 DECLARE query_reltn_fields = i2 WITH protect, noconstant(0)
 DECLARE loadchildrequest(item_type=i2) = null
 SUBROUTINE loadchildrequest(item_type)
   SET stat = initrec(child_request)
   SET stat = initrec(child_reply)
   SET child_request->beg_dt_tm = pat_request->beg_dt_tm
   SET child_request->end_dt_tm = pat_request->end_dt_tm
   SET child_request->loc_facility_cd = pat_request->loc_facility_cd
   SET child_request->loc_nurse_unit_cd = pat_request->loc_nurse_unit_cd
   CASE (item_type)
    OF child_type_prob:
     SET child_request->nomenclature_id = pat_request->prob_diag_nomen_id
     SET child_request->nomenclature_id2 = pat_request->prob_diag_nomen_id2
     SET child_request->nomenclature_id3 = pat_request->prob_diag_nomen_id3
    OF child_type_med:
     SET child_request->catalog_cd = pat_request->catalog_cd
     SET child_request->catalog_cd2 = pat_request->catalog_cd2
     SET child_request->catalog_cd3 = pat_request->catalog_cd3
    OF child_type_allergy:
     SET child_request->nomenclature_id = pat_request->allergy_nomen_id
     SET child_request->nomenclature_id2 = pat_request->allergy_nomen_id2
     SET child_request->nomenclature_id3 = pat_request->allergy_nomen_id3
    OF child_type_lab:
     SET child_request->task_assay_cd = pat_request->task_assay_cd
     SET child_request->result_sign = pat_request->result_sign
     SET child_request->result_value_numeric = pat_request->result_value_numeric
   ENDCASE
   SET child_request->cnt = pat_reply->qual_cnt
   SET stat = alterlist(child_request->qual,child_request->cnt)
   FOR (encntr_idx = 1 TO pat_reply->qual_cnt)
    SET child_request->qual[encntr_idx].person_id = pat_reply->qual[encntr_idx].person_id
    SET child_request->qual[encntr_idx].encntr_id = pat_reply->qual[encntr_idx].encntr_id
   ENDFOR
   CALL echorecord(child_request)
 END ;Subroutine
 DECLARE reconcileencounters(item_type=i2) = null
 SUBROUTINE reconcileencounters(item_type)
   CALL echorecord(child_reply)
   FOR (encntr_idx = 1 TO child_reply->cnt)
    SET loc_idx = locateval(loc_idx,1,pat_reply->qual_cnt,child_reply->qual[encntr_idx].encntr_id,
     pat_reply->qual[loc_idx].encntr_id)
    IF (loc_idx=0)
     SET pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
     IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
      SET stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
     ENDIF
     SET pat_reply->qual[pat_reply->qual_cnt].person_id = child_reply->qual[encntr_idx].person_id
     SET pat_reply->qual[pat_reply->qual_cnt].encntr_id = child_reply->qual[encntr_idx].encntr_id
     CASE (item_type)
      OF child_type_prob:
       SET pat_reply->qual[pat_reply->qual_cnt].prob_diag_id = child_reply->qual[encntr_idx].item_id
       SET pat_reply->qual[pat_reply->qual_cnt].problem = child_reply->qual[encntr_idx].item_display
       SET pat_reply->qual[pat_reply->qual_cnt].prob_diag_id2 = child_reply->qual[encntr_idx].
       item_id2
       SET pat_reply->qual[pat_reply->qual_cnt].problem2 = child_reply->qual[encntr_idx].
       item_display2
       SET pat_reply->qual[pat_reply->qual_cnt].prob_diag_id3 = child_reply->qual[encntr_idx].
       item_id3
       SET pat_reply->qual[pat_reply->qual_cnt].problem3 = child_reply->qual[encntr_idx].
       item_display3
       IF ((pat_reply->qual[pat_reply->qual_cnt].prob_diag_id > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].prob_diag_id2 > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].prob_diag_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].problem_sort = "A"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].prob_diag_id > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].prob_diag_id2 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].problem_sort = "B"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].prob_diag_id2 > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].prob_diag_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].problem_sort = "C"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].prob_diag_id > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].prob_diag_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].problem_sort = "D"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].prob_diag_id > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].problem_sort = "E"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].prob_diag_id2 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].problem_sort = "F"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].prob_diag_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].problem_sort = "G"
       ENDIF
      OF child_type_med:
       SET pat_reply->qual[pat_reply->qual_cnt].medications = child_reply->qual[encntr_idx].
       item_display
       SET pat_reply->qual[pat_reply->qual_cnt].medications2 = child_reply->qual[encntr_idx].
       item_display2
       SET pat_reply->qual[pat_reply->qual_cnt].medications3 = child_reply->qual[encntr_idx].
       item_display3
       IF ((pat_reply->qual[pat_reply->qual_cnt].medications != "")
        AND (pat_reply->qual[pat_reply->qual_cnt].medications2 != "")
        AND (pat_reply->qual[pat_reply->qual_cnt].medications3 != ""))
        SET pat_reply->qual[pat_reply->qual_cnt].medications_sort = "A"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].medications != "")
        AND (pat_reply->qual[pat_reply->qual_cnt].medications2 != ""))
        SET pat_reply->qual[pat_reply->qual_cnt].medications_sort = "B"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].medications2 != "")
        AND (pat_reply->qual[pat_reply->qual_cnt].medications3 != ""))
        SET pat_reply->qual[pat_reply->qual_cnt].medications_sort = "C"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].medications != "")
        AND (pat_reply->qual[pat_reply->qual_cnt].medications3 != ""))
        SET pat_reply->qual[pat_reply->qual_cnt].medications_sort = "D"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].medications != ""))
        SET pat_reply->qual[pat_reply->qual_cnt].medications_sort = "E"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].medications2 != ""))
        SET pat_reply->qual[pat_reply->qual_cnt].medications_sort = "F"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].medications3 != ""))
        SET pat_reply->qual[pat_reply->qual_cnt].medications_sort = "G"
       ENDIF
      OF child_type_allergy:
       SET pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id = child_reply->qual[encntr_idx].
       item_id
       SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy = child_reply->qual[encntr_idx].
       item_display
       SET pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id2 = child_reply->qual[encntr_idx].
       item_id2
       SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy2 = child_reply->qual[encntr_idx].
       item_display2
       SET pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id3 = child_reply->qual[encntr_idx].
       item_id3
       SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy3 = child_reply->qual[encntr_idx].
       item_display3
       IF ((pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id2 > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy_sort = "A"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id2 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy_sort = "B"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id2 > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy_sort = "C"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id > 0)
        AND (pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy_sort = "D"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy_sort = "E"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id2 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy_sort = "F"
       ELSEIF ((pat_reply->qual[pat_reply->qual_cnt].allergy_instance_id3 > 0))
        SET pat_reply->qual[pat_reply->qual_cnt].medication_allergy_sort = "G"
       ENDIF
      OF child_type_lab:
       SET pat_reply->qual[pat_reply->qual_cnt].lab_results = child_reply->qual[encntr_idx].
       item_display
       SET pat_reply->qual[pat_reply->qual_cnt].lab_results_sort = child_reply->qual[encntr_idx].
       item_id2
     ENDCASE
    ELSE
     SET stat = movereclist(pat_reply->qual,pat_reply->qual,loc_idx,encntr_idx,1,
      0)
     CASE (item_type)
      OF child_type_prob:
       SET pat_reply->qual[encntr_idx].prob_diag_id = child_reply->qual[encntr_idx].item_id
       SET pat_reply->qual[encntr_idx].problem = child_reply->qual[encntr_idx].item_display
       SET pat_reply->qual[encntr_idx].prob_diag_id2 = child_reply->qual[encntr_idx].item_id2
       SET pat_reply->qual[encntr_idx].problem2 = child_reply->qual[encntr_idx].item_display2
       SET pat_reply->qual[encntr_idx].prob_diag_id3 = child_reply->qual[encntr_idx].item_id3
       SET pat_reply->qual[encntr_idx].problem3 = child_reply->qual[encntr_idx].item_display3
       IF ((pat_reply->qual[encntr_idx].prob_diag_id > 0)
        AND (pat_reply->qual[encntr_idx].prob_diag_id2 > 0)
        AND (pat_reply->qual[encntr_idx].prob_diag_id3 > 0))
        SET pat_reply->qual[encntr_idx].problem_sort = "A"
       ELSEIF ((pat_reply->qual[encntr_idx].prob_diag_id > 0)
        AND (pat_reply->qual[encntr_idx].prob_diag_id2 > 0))
        SET pat_reply->qual[encntr_idx].problem_sort = "B"
       ELSEIF ((pat_reply->qual[encntr_idx].prob_diag_id2 > 0)
        AND (pat_reply->qual[encntr_idx].prob_diag_id3 > 0))
        SET pat_reply->qual[encntr_idx].problem_sort = "C"
       ELSEIF ((pat_reply->qual[encntr_idx].prob_diag_id > 0)
        AND (pat_reply->qual[encntr_idx].prob_diag_id3 > 0))
        SET pat_reply->qual[encntr_idx].problem_sort = "D"
       ELSEIF ((pat_reply->qual[encntr_idx].prob_diag_id > 0))
        SET pat_reply->qual[encntr_idx].problem_sort = "E"
       ELSEIF ((pat_reply->qual[encntr_idx].prob_diag_id2 > 0))
        SET pat_reply->qual[encntr_idx].problem_sort = "F"
       ELSEIF ((pat_reply->qual[encntr_idx].prob_diag_id3 > 0))
        SET pat_reply->qual[encntr_idx].problem_sort = "G"
       ENDIF
      OF child_type_med:
       SET pat_reply->qual[encntr_idx].medications = child_reply->qual[encntr_idx].item_display
       SET pat_reply->qual[encntr_idx].medications2 = child_reply->qual[encntr_idx].item_display2
       SET pat_reply->qual[encntr_idx].medications3 = child_reply->qual[encntr_idx].item_display3
       IF ((pat_reply->qual[encntr_idx].medications != "")
        AND (pat_reply->qual[encntr_idx].medications2 != "")
        AND (pat_reply->qual[encntr_idx].medications3 != ""))
        SET pat_reply->qual[encntr_idx].medications_sort = "A"
       ELSEIF ((pat_reply->qual[encntr_idx].medications != "")
        AND (pat_reply->qual[encntr_idx].medications2 != ""))
        SET pat_reply->qual[encntr_idx].medications_sort = "B"
       ELSEIF ((pat_reply->qual[encntr_idx].medications2 != "")
        AND (pat_reply->qual[encntr_idx].medications3 != ""))
        SET pat_reply->qual[encntr_idx].medications_sort = "C"
       ELSEIF ((pat_reply->qual[encntr_idx].medications != "")
        AND (pat_reply->qual[encntr_idx].medications3 != ""))
        SET pat_reply->qual[encntr_idx].medications_sort = "D"
       ELSEIF ((pat_reply->qual[encntr_idx].medications != ""))
        SET pat_reply->qual[encntr_idx].medications_sort = "E"
       ELSEIF ((pat_reply->qual[encntr_idx].medications2 != ""))
        SET pat_reply->qual[encntr_idx].medications_sort = "F"
       ELSEIF ((pat_reply->qual[encntr_idx].medications3 != ""))
        SET pat_reply->qual[encntr_idx].medications_sort = "G"
       ENDIF
      OF child_type_allergy:
       SET pat_reply->qual[encntr_idx].allergy_instance_id = child_reply->qual[encntr_idx].item_id
       SET pat_reply->qual[encntr_idx].medication_allergy = child_reply->qual[encntr_idx].
       item_display
       SET pat_reply->qual[encntr_idx].allergy_instance_id2 = child_reply->qual[encntr_idx].item_id2
       SET pat_reply->qual[encntr_idx].medication_allergy2 = child_reply->qual[encntr_idx].
       item_display2
       SET pat_reply->qual[encntr_idx].allergy_instance_id3 = child_reply->qual[encntr_idx].item_id3
       SET pat_reply->qual[encntr_idx].medication_allergy3 = child_reply->qual[encntr_idx].
       item_display3
       IF ((pat_reply->qual[encntr_idx].allergy_instance_id > 0)
        AND (pat_reply->qual[encntr_idx].allergy_instance_id2 > 0)
        AND (pat_reply->qual[encntr_idx].allergy_instance_id3 > 0))
        SET pat_reply->qual[encntr_idx].medication_allergy_sort = "A"
       ELSEIF ((pat_reply->qual[encntr_idx].allergy_instance_id > 0)
        AND (pat_reply->qual[encntr_idx].allergy_instance_id2 > 0))
        SET pat_reply->qual[encntr_idx].medication_allergy_sort = "B"
       ELSEIF ((pat_reply->qual[encntr_idx].allergy_instance_id2 > 0)
        AND (pat_reply->qual[encntr_idx].allergy_instance_id3 > 0))
        SET pat_reply->qual[encntr_idx].medication_allergy_sort = "C"
       ELSEIF ((pat_reply->qual[encntr_idx].allergy_instance_id > 0)
        AND (pat_reply->qual[encntr_idx].allergy_instance_id3 > 0))
        SET pat_reply->qual[encntr_idx].medication_allergy_sort = "D"
       ELSEIF ((pat_reply->qual[encntr_idx].allergy_instance_id > 0))
        SET pat_reply->qual[encntr_idx].medication_allergy_sort = "E"
       ELSEIF ((pat_reply->qual[encntr_idx].allergy_instance_id2 > 0))
        SET pat_reply->qual[encntr_idx].medication_allergy_sort = "F"
       ELSEIF ((pat_reply->qual[encntr_idx].allergy_instance_id3 > 0))
        SET pat_reply->qual[encntr_idx].medication_allergy_sort = "G"
       ENDIF
      OF child_type_lab:
       SET pat_reply->qual[encntr_idx].lab_results = child_reply->qual[encntr_idx].item_display
       SET pat_reply->qual[encntr_idx].lab_results_sort = child_reply->qual[encntr_idx].item_id2
     ENDCASE
    ENDIF
   ENDFOR
   SET pat_reply->qual_cnt = child_reply->cnt
 END ;Subroutine
 DECLARE islogicaldomainsactive(null) = i2
 SUBROUTINE islogicaldomainsactive(null)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE b_logicaldomain = i4 WITH noconstant(column_exists("LOGICAL_DOMAIN","LOGICAL_DOMAIN_ID")),
   protect
   DECLARE ld_id = f8 WITH noconstant(0.0), protect
   DECLARE cnt = i4 WITH noconstant(0), protect
   IF (b_logicaldomain)
    SELECT INTO "nl:"
     FROM logical_domain ld
     PLAN (ld
      WHERE ld.logical_domain_id > 0.0
       AND ld.active_ind=1)
     ORDER BY ld.logical_domain_id
     HEAD ld.logical_domain_id
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 DECLARE column_exists(stable=vc,scolumn=vc) = i4
 SUBROUTINE column_exists(stable,scolumn)
   DECLARE return_val = i4 WITH noconstant(0), protect
   DECLARE ce_temp = vc WITH noconstant(""), protect
   SET stable = cnvtupper(stable)
   SET scolumn = cnvtupper(scolumn)
   IF (((currev=8
    AND currevminor=2
    AND currevminor2 >= 4) OR (((currev=8
    AND currevminor > 2) OR (currev > 8)) )) )
    SET ce_temp = build('"',stable,".",scolumn,'"')
    SET stat = checkdic(parser(ce_temp),"A",0)
    IF (stat > 0)
     SET return_val = 1
    ENDIF
   ELSE
    SELECT INTO "nl:"
     l.attr_name
     FROM dtableattr a,
      dtableattrl l
     WHERE a.table_name=stable
      AND l.attr_name=scolumn
      AND l.structtype="F"
      AND btest(l.stat,11)=0
     DETAIL
      return_val = 1
     WITH nocounter
    ;end select
   ENDIF
   RETURN(return_val)
 END ;Subroutine
 SET grid->col_cnt = 7
 SET stat = alterlist(grid->cols,grid->col_cnt)
 SET grid->cols[1].col_name = "name_full_formatted"
 SET grid->cols[2].col_name = "age"
 SET grid->cols[3].col_name = "dob"
 SET grid->cols[4].col_name = "sex"
 SET grid->cols[5].col_name = "mrn"
 IF (pat_request->loc_nurse_unit_cd)
  SET parser_loc = build("e.loc_nurse_unit_cd = ",pat_request->loc_nurse_unit_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",outpatient_class_cd)
  SET grid->cols[6].col_name = "clinic"
 ELSEIF (pat_request->loc_facility_cd)
  SET parser_loc = build("e.loc_facility_cd = ",pat_request->loc_facility_cd)
  SET parser_encntr_type = build("e.encntr_type_class_cd = ",inpatient_class_cd)
  SET grid->cols[6].col_name = "facility"
 ENDIF
 SET grid->cols[7].col_name = "reg_date"
 IF (pat_request->demographics.sex_cd)
  SET query_person_ind = 1
  SET query_ind = 1
  SET parser_sex = build("p.sex_cd = ",pat_request->demographics.sex_cd)
 ENDIF
 IF ((pat_request->demographics.age_num > 0)
  AND (pat_request->demographics.age_unit IN (age_unit_days, age_unit_weeks, age_unit_months,
 age_unit_years)))
  SET query_person_ind = 1
  SET query_ind = 1
  SET beg_birth_dt_tm = cnvtlookbehind(build(pat_request->demographics.age_num,",",pat_request->
    demographics.age_unit),pat_request->beg_dt_tm)
  SET end_birth_dt_tm = cnvtlookbehind(build(pat_request->demographics.age_num,",",pat_request->
    demographics.age_unit),pat_request->end_dt_tm)
  SET parser_dob =
  "p.birth_dt_tm between cnvtdatetime(beg_birth_dt_tm) and cnvtdatetime(end_birth_dt_tm)"
 ENDIF
 IF (pat_request->demographics.language_cd)
  SET query_person_ind = 1
  SET query_ind = 1
  SET parser_lang = build("p.language_cd = ",pat_request->demographics.language_cd)
 ENDIF
 SET grid->col_cnt = (grid->col_cnt+ 1)
 SET stat = alterlist(grid->cols,grid->col_cnt)
 SET grid->cols[grid->col_cnt].col_name = "preferred_language"
 IF (pat_request->demographics.race_cd)
  SET query_race_ind = 1
  SET query_ind = 1
 ENDIF
 SET grid->col_cnt = (grid->col_cnt+ 1)
 SET stat = alterlist(grid->cols,grid->col_cnt)
 SET grid->cols[grid->col_cnt].col_name = "race"
 IF (pat_request->demographics.ethnic_grp_cd)
  SET query_person_ind = 1
  SET query_ind = 1
  SET parser_ethnic = build("p.ethnic_grp_cd = ",pat_request->demographics.ethnic_grp_cd)
 ENDIF
 SET grid->col_cnt = (grid->col_cnt+ 1)
 SET stat = alterlist(grid->cols,grid->col_cnt)
 SET grid->cols[grid->col_cnt].col_name = "ethnicity"
 IF (pat_request->demographics.cause_of_death_id)
  SET query_ind = 1
  IF ((pat_request->demographics.cause_of_death_type=code_set))
   SET query_person_ind = 1
   SET parser_death = build("p.cause_of_death_cd = ",pat_request->demographics.cause_of_death_id)
  ELSE
   SET query_ce_ind = 1
  ENDIF
 ENDIF
 SET grid->col_cnt = (grid->col_cnt+ 1)
 SET stat = alterlist(grid->cols,grid->col_cnt)
 SET grid->cols[grid->col_cnt].col_name = "preliminary_cause_of_death"
 IF ((pat_request->demographics.contact_method_cd > - (1)))
  IF ((pat_request->demographics.contact_method_cd > 0))
   SET query_person_pat_ind = 1
   SET query_ind = 1
  ENDIF
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "patient_communication_preference"
 ENDIF
 IF ((pat_request->reltn_option=1))
  IF (textlen(trim(pat_request->demographics.pcp_prsnl_list,3)) > 0)
   SET query_pcp_ind = 1
   SET query_ind = 1
   SET parser_pcp = concat("ppr.prsnl_person_id ",pat_request->demographics.pcp_prsnl_list)
   SET grid->col_cnt = (grid->col_cnt+ 1)
   SET stat = alterlist(grid->cols,grid->col_cnt)
   SET grid->cols[grid->col_cnt].col_name = "primary_care_physician"
  ENDIF
 ENDIF
 IF ((((pat_request->reltn_option=2)) OR ((((pat_request->reltn_option=3)) OR ((pat_request->
 reltn_option=4))) )) )
  IF (textlen(trim(pat_request->demographics.pcp_prsnl_list,3)) > 0)
   SET query_pcp_ind = 1
   SET query_reltn_fields = 1
   SET query_ind = 1
   SET pat_reply->qual_cnt = 0
   GO TO get_data
  ENDIF
 ENDIF
 IF ((((pat_request->reltn_option=2)) OR ((((pat_request->reltn_option=3)) OR ((pat_request->
 reltn_option=4))) )) )
  SET query_pcp_ind = 1
  SET query_ind = 1
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  IF ((pat_request->reltn_option=2))
   SET grid->cols[grid->col_cnt].col_name = "lifetime_physician"
  ELSEIF ((pat_request->reltn_option=3))
   SET grid->cols[grid->col_cnt].col_name = "visit_physician"
  ELSEIF ((pat_request->reltn_option=4))
   SET grid->cols[grid->col_cnt].col_name = "physician_name"
  ENDIF
 ENDIF
 IF (pat_request->prob_diag_nomen_id)
  SET query_prob_diag_ind = 1
  SET query_ind = 1
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "problem"
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "problem2"
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "problem3"
 ENDIF
 IF (pat_request->catalog_cd)
  SET query_med_ind = 1
  SET query_ind = 1
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "medications"
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "medications2"
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "medications3"
 ENDIF
 IF (pat_request->allergy_nomen_id)
  SET query_allergy_ind = 1
  SET query_ind = 1
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "medication_allergy"
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "medication_allergy2"
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "medication_allergy3"
 ENDIF
 IF ((pat_request->task_assay_cd > 0))
  SET query_lab_result_count = (query_lab_result_count+ 1)
 ENDIF
 IF ((pat_request->result_sign > 0))
  SET query_lab_result_count = (query_lab_result_count+ 1)
 ENDIF
 IF ((pat_request->result_value_numeric != 1.36e36))
  SET query_lab_result_count = (query_lab_result_count+ 1)
 ENDIF
 IF (query_lab_result_count=3)
  SET incomplete_lab_fields = 0
  SET query_lab_ind = 1
  SET query_ind = 1
  SET grid->col_cnt = (grid->col_cnt+ 1)
  SET stat = alterlist(grid->cols,grid->col_cnt)
  SET grid->cols[grid->col_cnt].col_name = "lab_results"
 ELSEIF (query_lab_result_count > 0)
  SET incomplete_lab_fields = 1
  SET pat_reply->qual_cnt = 0
  GO TO get_data
 ENDIF
 IF (query_person_ind)
  SELECT INTO "nl:"
   FROM encounter e,
    person p
   PLAN (e
    WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
     end_dt_tm)
     AND parser(parser_loc)
     AND parser(parser_encntr_type)
     AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND e.active_ind=1)
    JOIN (p
    WHERE p.person_id=e.person_id
     AND parser(parser_sex)
     AND parser(parser_dob)
     AND parser(parser_lang)
     AND parser(parser_ethnic)
     AND parser(parser_death))
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
    IF (mod(pat_reply->qual_cnt,20)=1)
     stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
    ENDIF
    pat_reply->qual[pat_reply->qual_cnt].person_id = p.person_id, pat_reply->qual[pat_reply->qual_cnt
    ].encntr_id = e.encntr_id
   WITH nocounter
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF (query_race_ind)
  SELECT
   IF ((pat_reply->qual_cnt=0))
    PLAN (e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
      end_dt_tm)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (p
     WHERE p.person_id=outerjoin(e.person_id)
      AND p.race_cd=outerjoin(pat_request->demographics.race_cd))
     JOIN (pcv
     WHERE pcv.person_id=outerjoin(e.person_id)
      AND pcv.code_set=outerjoin(282)
      AND pcv.code_value=outerjoin(pat_request->demographics.race_cd)
      AND pcv.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
      AND pcv.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
      AND pcv.active_ind=outerjoin(1))
   ELSE
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
     JOIN (p
     WHERE p.person_id=outerjoin(e.person_id)
      AND p.race_cd=outerjoin(pat_request->demographics.race_cd))
     JOIN (pcv
     WHERE pcv.person_id=outerjoin(e.person_id)
      AND pcv.code_set=outerjoin(282)
      AND pcv.code_value=outerjoin(pat_request->demographics.race_cd)
      AND pcv.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
      AND pcv.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
      AND pcv.active_ind=outerjoin(1))
   ENDIF
   INTO "nl:"
   FROM encounter e,
    person p,
    person_code_value_r pcv
   ORDER BY e.encntr_id
   HEAD REPORT
    pat_reply->qual_cnt = 0
   HEAD e.encntr_id
    IF ((((p.race_cd=pat_request->demographics.race_cd)) OR (pcv.person_code_value_r_id > 0)) )
     pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
     IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
      stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
     ENDIF
     pat_reply->qual[pat_reply->qual_cnt].person_id = e.person_id, pat_reply->qual[pat_reply->
     qual_cnt].encntr_id = e.encntr_id
    ENDIF
   WITH nocounter, nullreport, expand = 1
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF (query_person_pat_ind)
  SELECT
   IF ((pat_reply->qual_cnt=0))
    PLAN (e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
      end_dt_tm)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (pp
     WHERE pp.person_id=e.person_id
      AND (pp.contact_method_cd=pat_request->demographics.contact_method_cd))
   ELSE
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
     JOIN (pp
     WHERE pp.person_id=e.person_id
      AND (pp.contact_method_cd=pat_request->demographics.contact_method_cd))
   ENDIF
   INTO "nl:"
   FROM encounter e,
    person_patient pp
   ORDER BY e.encntr_id
   HEAD REPORT
    pat_reply->qual_cnt = 0
   HEAD e.encntr_id
    pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
    IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
     stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
    ENDIF
    pat_reply->qual[pat_reply->qual_cnt].person_id = e.person_id, pat_reply->qual[pat_reply->qual_cnt
    ].encntr_id = e.encntr_id
   WITH nocounter, nullreport, expand = 1
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF ((pat_request->reltn_option=1)
  AND query_pcp_ind=1)
  SELECT
   IF ((pat_reply->qual_cnt=0))
    PLAN (e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
      end_dt_tm)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (ppr
     WHERE ppr.person_id=e.person_id
      AND parser(parser_pcp)
      AND ppr.person_prsnl_r_cd=prsnl_r_pcp_cd
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ppr.active_ind=1)
   ELSE
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
     JOIN (ppr
     WHERE ppr.person_id=e.person_id
      AND parser(parser_pcp)
      AND ppr.person_prsnl_r_cd=prsnl_r_pcp_cd
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ppr.active_ind=1)
   ENDIF
   INTO "nl:"
   FROM encounter e,
    person_prsnl_reltn ppr
   ORDER BY e.encntr_id
   HEAD REPORT
    pat_reply->qual_cnt = 0
   HEAD e.encntr_id
    pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
    IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
     stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
    ENDIF
    pat_reply->qual[pat_reply->qual_cnt].person_id = e.person_id, pat_reply->qual[pat_reply->qual_cnt
    ].encntr_id = e.encntr_id
   FOOT REPORT
    stat = alterlist(pat_reply->qual,pat_reply->qual_cnt)
   WITH nocounter, nullreport, expand = 1
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF ((pat_request->reltn_option=2)
  AND query_pcp_ind=1)
  SELECT
   IF ((pat_reply->qual_cnt=0))
    PLAN (e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
      end_dt_tm)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (ppr
     WHERE ppr.person_id=e.person_id
      AND ppr.person_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=331
       AND cv.active_ind=1))
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ppr.active_ind=1)
   ELSE
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
     JOIN (ppr
     WHERE ppr.person_id=e.person_id
      AND ppr.person_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=331
       AND cv.active_ind=1))
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ppr.active_ind=1)
   ENDIF
   INTO "nl:"
   FROM encounter e,
    person_prsnl_reltn ppr
   ORDER BY e.encntr_id
   HEAD REPORT
    pat_reply->qual_cnt = 0
   HEAD e.encntr_id
    IF (ppr.person_prsnl_r_cd != 0.0)
     pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
     IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
      stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
     ENDIF
     pat_reply->qual[pat_reply->qual_cnt].person_id = e.person_id, pat_reply->qual[pat_reply->
     qual_cnt].encntr_id = e.encntr_id
    ENDIF
   FOOT REPORT
    stat = alterlist(pat_reply->qual,pat_reply->qual_cnt)
   WITH nocounter, nullreport, expand = 1
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF ((pat_request->reltn_option=3)
  AND query_pcp_ind=1)
  SELECT
   IF ((pat_reply->qual_cnt=0))
    PLAN (e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
      end_dt_tm)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (epr
     WHERE epr.encntr_id=e.encntr_id
      AND epr.encntr_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=333
       AND cv.active_ind=1))
      AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND epr.active_ind=1)
   ELSE
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
     JOIN (epr
     WHERE epr.encntr_id=e.encntr_id
      AND epr.encntr_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=333
       AND cv.active_ind=1))
      AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND epr.active_ind=1)
   ENDIF
   INTO "nl:"
   FROM encounter e,
    encntr_prsnl_reltn epr
   ORDER BY e.encntr_id
   HEAD REPORT
    pat_reply->qual_cnt = 0
   HEAD e.encntr_id
    IF (epr.encntr_prsnl_r_cd != 0.0)
     pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
     IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
      stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
     ENDIF
     pat_reply->qual[pat_reply->qual_cnt].person_id = e.person_id, pat_reply->qual[pat_reply->
     qual_cnt].encntr_id = e.encntr_id
    ENDIF
   FOOT REPORT
    stat = alterlist(pat_reply->qual,pat_reply->qual_cnt)
   WITH nocounter, nullreport, expand = 1
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF ((pat_request->reltn_option=4)
  AND query_pcp_ind=1)
  SELECT
   IF ((pat_reply->qual_cnt=0))
    PLAN (e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
      end_dt_tm)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (ppr)
     JOIN (epr)
   ELSE
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (ppr)
     JOIN (epr)
   ENDIF
   INTO "nl:"
   FROM encounter e,
    (left JOIN person_prsnl_reltn ppr ON ppr.person_id=e.person_id
     AND ppr.person_prsnl_r_cd IN (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=331
      AND cv.active_ind=1))
     AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND ppr.active_ind=1),
    (left JOIN encntr_prsnl_reltn epr ON epr.encntr_id=e.encntr_id
     AND epr.encntr_prsnl_r_cd IN (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_set=333
      AND cv.active_ind=1))
     AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND epr.active_ind=1)
   ORDER BY e.encntr_id
   HEAD REPORT
    pat_reply->qual_cnt = 0
   HEAD e.encntr_id
    IF (((ppr.person_prsnl_r_cd != 0.0) OR (epr.encntr_prsnl_r_cd != 0.0)) )
     pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
     IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
      stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
     ENDIF
     pat_reply->qual[pat_reply->qual_cnt].person_id = e.person_id, pat_reply->qual[pat_reply->
     qual_cnt].encntr_id = e.encntr_id
    ENDIF
   FOOT REPORT
    stat = alterlist(pat_reply->qual,pat_reply->qual_cnt)
   WITH nocounter, nullreport, expand = 1
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF (query_ce_ind)
  SELECT
   IF ((pat_reply->qual_cnt=0))
    PLAN (e
     WHERE e.reg_dt_tm BETWEEN cnvtdatetime(pat_request->beg_dt_tm) AND cnvtdatetime(pat_request->
      end_dt_tm)
      AND parser(parser_loc)
      AND parser(parser_encntr_type)
      AND e.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND e.active_ind=1)
     JOIN (ce
     WHERE ce.person_id=e.person_id
      AND (ce.event_cd=pat_request->demographics.cause_of_death_id)
      AND ce.event_end_dt_tm BETWEEN e.create_dt_tm AND cnvtdatetime(curdate,curtime3)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ((ce.encntr_id+ 0)=e.encntr_id)
      AND ce.view_level=1
      AND ce.publish_flag=1
      AND ce.result_status_cd IN (auth_cd, altered_cd, modified_cd))
   ELSE
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
     JOIN (ce
     WHERE ce.person_id=e.person_id
      AND (ce.event_cd=pat_request->demographics.cause_of_death_id)
      AND ce.event_end_dt_tm BETWEEN e.create_dt_tm AND cnvtdatetime(curdate,curtime3)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ((ce.encntr_id+ 0)=e.encntr_id)
      AND ce.view_level=1
      AND ce.publish_flag=1
      AND ce.result_status_cd IN (auth_cd, altered_cd, modified_cd))
   ENDIF
   INTO "nl:"
   FROM encounter e,
    clinical_event ce
   ORDER BY e.encntr_id
   HEAD REPORT
    pat_reply->qual_cnt = 0
   HEAD e.encntr_id
    pat_reply->qual_cnt = (pat_reply->qual_cnt+ 1)
    IF ((pat_reply->qual_cnt > size(pat_reply->qual,5)))
     stat = alterlist(pat_reply->qual,(pat_reply->qual_cnt+ 19))
    ENDIF
    pat_reply->qual[pat_reply->qual_cnt].person_id = e.person_id, pat_reply->qual[pat_reply->qual_cnt
    ].encntr_id = e.encntr_id
   WITH nocounter, nullreport, expand = 1
  ;end select
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF (query_prob_diag_ind)
  CALL loadchildrequest(child_type_prob)
  EXECUTE dcp_mu_patient_list_prob_diag  WITH replace("REQUEST",child_request), replace("REPLY",
   child_reply)
  CALL reconcileencounters(child_type_prob)
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF (query_med_ind)
  CALL loadchildrequest(child_type_med)
  EXECUTE dcp_mu_patient_list_med  WITH replace("REQUEST",child_request), replace("REPLY",child_reply
   )
  CALL reconcileencounters(child_type_med)
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF (query_allergy_ind)
  CALL loadchildrequest(child_type_allergy)
  EXECUTE dcp_mu_patient_list_allergy  WITH replace("REQUEST",child_request), replace("REPLY",
   child_reply)
  CALL reconcileencounters(child_type_allergy)
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
 IF (query_lab_ind)
  CALL loadchildrequest(child_type_lab)
  EXECUTE dcp_mu_patient_list_lab  WITH replace("REQUEST",child_request), replace("REPLY",child_reply
   )
  CALL reconcileencounters(child_type_lab)
  IF ((pat_reply->qual_cnt=0))
   GO TO get_data
  ENDIF
 ENDIF
#get_data
 SET stat = alterlist(pat_reply->qual,pat_reply->qual_cnt)
 IF (pat_reply->qual_cnt)
  SELECT INTO "nl:"
   FROM encounter e,
    person p,
    person_patient pp,
    encntr_alias ea
   PLAN (e
    WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
    JOIN (p
    WHERE p.person_id=e.person_id)
    JOIN (pp
    WHERE pp.person_id=outerjoin(p.person_id))
    JOIN (ea
    WHERE ea.encntr_id=outerjoin(e.encntr_id)
     AND ea.encntr_alias_type_cd=outerjoin(ea_type_mrn_cd)
     AND ea.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3))
     AND ea.active_ind=outerjoin(1))
   ORDER BY e.encntr_id
   HEAD e.encntr_id
    encntr_idx = locateval(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].
     encntr_id)
    IF (encntr_idx)
     pat_reply->qual[encntr_idx].name_full_formatted = trim(p.name_full_formatted,3), pat_reply->
     qual[encntr_idx].sex_cd = p.sex_cd, pat_reply->qual[encntr_idx].sex = trim(uar_get_code_display(
       p.sex_cd),3),
     pat_reply->qual[encntr_idx].birth_dt_tm = p.birth_dt_tm, pat_reply->qual[encntr_idx].age = trim(
      cnvtage(p.birth_dt_tm),3), pat_reply->qual[encntr_idx].dob = trim(datetimezoneformat(p
       .birth_dt_tm,p.birth_tz,"@SHORTDATE")),
     pat_reply->qual[encntr_idx].language_cd = p.language_cd, pat_reply->qual[encntr_idx].
     preferred_language = uar_get_code_display(p.language_cd), pat_reply->qual[encntr_idx].
     ethnic_grp_cd = p.ethnic_grp_cd,
     pat_reply->qual[encntr_idx].ethnicity = uar_get_code_display(p.ethnic_grp_cd)
     IF ((pat_request->demographics.cause_of_death_type=code_set))
      pat_reply->qual[encntr_idx].cause_of_death_id = p.cause_of_death_cd, pat_reply->qual[encntr_idx
      ].preliminary_cause_of_death = uar_get_code_display(p.cause_of_death_cd)
     ENDIF
     pat_reply->qual[encntr_idx].contact_method_cd = pp.contact_method_cd, pat_reply->qual[encntr_idx
     ].patient_communication_preference = uar_get_code_display(pp.contact_method_cd), pat_reply->
     qual[encntr_idx].loc_facility_cd = e.loc_facility_cd,
     pat_reply->qual[encntr_idx].facility = uar_get_code_display(e.loc_facility_cd), pat_reply->qual[
     encntr_idx].loc_nurse_unit_cd = e.loc_nurse_unit_cd, pat_reply->qual[encntr_idx].clinic =
     uar_get_code_display(e.loc_nurse_unit_cd),
     pat_reply->qual[encntr_idx].reg_dt_tm = e.reg_dt_tm, pat_reply->qual[encntr_idx].reg_date =
     format(e.reg_dt_tm,"@SHORTDATETIME"), pat_reply->qual[encntr_idx].mrn = trim(cnvtalias(ea.alias,
       ea.alias_pool_cd),3)
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SELECT INTO "nl:"
   race_disp =
   IF (pcv.person_code_value_r_id=0) trim(uar_get_code_display(p.race_cd),3)
   ELSE trim(uar_get_code_display(pcv.code_value),3)
   ENDIF
   FROM person p,
    person_code_value_r pcv
   PLAN (p
    WHERE expand(exp_idx,1,pat_reply->qual_cnt,p.person_id,pat_reply->qual[exp_idx].person_id))
    JOIN (pcv
    WHERE pcv.person_id=p.person_id
     AND pcv.code_set=282
     AND pcv.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND pcv.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
     AND pcv.active_ind=1)
   ORDER BY p.person_id, race_disp
   HEAD p.person_id
    person_idx = 0, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,p.person_id,
     pat_reply->qual[exp_idx].person_id), race_list = " "
   DETAIL
    IF (textlen(trim(race_list,3)) > 0)
     race_list = notrim(concat(race_list,", "))
    ENDIF
    race_list = concat(race_list,trim(race_disp))
   FOOT  p.person_id
    WHILE (person_idx)
      pat_reply->qual[person_idx].race_cd = p.race_cd, pat_reply->qual[person_idx].race = race_list,
      person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,p.person_id,pat_reply->qual[
       exp_idx].person_id)
    ENDWHILE
   WITH nocounter, expand = 1
  ;end select
  IF ((pat_request->reltn_option=1)
   AND query_pcp_ind=1)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     prsnl pr
    PLAN (ppr
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,ppr.person_id,pat_reply->qual[exp_idx].person_id)
      AND ppr.person_prsnl_r_cd=prsnl_r_pcp_cd
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ppr.active_ind=1)
     JOIN (pr
     WHERE pr.person_id=ppr.prsnl_person_id)
    ORDER BY ppr.person_id
    HEAD ppr.person_id
     person_idx = 0, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,ppr.person_id,
      pat_reply->qual[exp_idx].person_id), pcp_list = " "
    DETAIL
     IF (textlen(trim(pcp_list,3)) > 0)
      pcp_list = notrim(concat(pcp_list,"; "))
     ENDIF
     pcp_list = concat(pcp_list,trim(pr.name_full_formatted))
    FOOT  ppr.person_id
     WHILE (person_idx)
       pat_reply->qual[person_idx].pcp_prsnl_id = ppr.prsnl_person_id, pat_reply->qual[person_idx].
       primary_care_physician = pcp_list, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->
        qual_cnt,ppr.person_id,pat_reply->qual[exp_idx].person_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
  ENDIF
  IF ((pat_request->reltn_option=2)
   AND query_pcp_ind=1)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     prsnl pr
    PLAN (ppr
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,ppr.person_id,pat_reply->qual[exp_idx].person_id)
      AND ppr.person_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=331
       AND cv.active_ind=1))
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ppr.active_ind=1)
     JOIN (pr
     WHERE pr.person_id=ppr.prsnl_person_id)
    ORDER BY ppr.person_id
    HEAD ppr.person_id
     person_idx = 0, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,ppr.person_id,
      pat_reply->qual[exp_idx].person_id), pcp_list = " "
    DETAIL
     IF (textlen(trim(pcp_list,3)) > 0)
      pcp_list = notrim(concat(pcp_list,"; "))
     ENDIF
     pcp_list = concat(pcp_list,trim(pr.name_full_formatted))
    FOOT  ppr.person_id
     WHILE (person_idx)
       pat_reply->qual[person_idx].pcp_prsnl_id = ppr.prsnl_person_id, pat_reply->qual[person_idx].
       lifetime_physician = pcp_list, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->
        qual_cnt,ppr.person_id,pat_reply->qual[exp_idx].person_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
  ENDIF
  IF ((pat_request->reltn_option=3)
   AND query_pcp_ind=1)
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr,
     prsnl pr
    PLAN (epr
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,epr.encntr_id,pat_reply->qual[exp_idx].encntr_id)
      AND epr.encntr_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=333
       AND cv.active_ind=1))
      AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND epr.active_ind=1)
     JOIN (pr
     WHERE pr.person_id=epr.prsnl_person_id)
    ORDER BY epr.encntr_id
    HEAD epr.encntr_id
     person_idx = 0, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,epr.encntr_id,
      pat_reply->qual[exp_idx].encntr_id), pcp_list = " "
    DETAIL
     IF (textlen(trim(pcp_list,3)) > 0)
      pcp_list = notrim(concat(pcp_list,"; "))
     ENDIF
     pcp_list = concat(pcp_list,trim(pr.name_full_formatted))
    FOOT  epr.encntr_id
     WHILE (person_idx)
       pat_reply->qual[person_idx].pcp_prsnl_id = epr.prsnl_person_id, pat_reply->qual[person_idx].
       visit_physician = pcp_list, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,
        epr.encntr_id,pat_reply->qual[exp_idx].encntr_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
  ENDIF
  IF ((pat_request->reltn_option=4)
   AND query_pcp_ind=1)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     prsnl pr
    PLAN (ppr
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,ppr.person_id,pat_reply->qual[exp_idx].person_id)
      AND ppr.person_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=331
       AND cv.active_ind=1))
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND ppr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND ppr.active_ind=1)
     JOIN (pr
     WHERE pr.person_id=ppr.prsnl_person_id)
    ORDER BY ppr.person_id
    HEAD ppr.person_id
     person_idx = 0, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,ppr.person_id,
      pat_reply->qual[exp_idx].person_id), pcp_list = " "
    DETAIL
     IF (textlen(trim(pcp_list,3)) > 0)
      pcp_list = notrim(concat(pcp_list,"; "))
     ENDIF
     pcp_list = concat(pcp_list,trim(pr.name_full_formatted))
    FOOT  ppr.person_id
     WHILE (person_idx)
       pat_reply->qual[person_idx].pcp_prsnl_id = ppr.prsnl_person_id
       IF (trim(pat_reply->qual[person_idx].physician_name) > "")
        pat_reply->qual[person_idx].physician_name = notrim(concat(pat_reply->qual[person_idx].
          physician_name,"; ")), pat_reply->qual[person_idx].physician_name = concat(pcp_list,trim(
          pat_reply->qual[person_idx].physician_name))
       ELSE
        pat_reply->qual[person_idx].physician_name = pcp_list
       ENDIF
       person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,ppr.person_id,pat_reply->
        qual[exp_idx].person_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "nl:"
    FROM encntr_prsnl_reltn epr,
     prsnl pr
    PLAN (epr
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,epr.encntr_id,pat_reply->qual[exp_idx].encntr_id)
      AND epr.encntr_prsnl_r_cd IN (
     (SELECT
      cv.code_value
      FROM code_value cv
      WHERE cv.code_set=333
       AND cv.active_ind=1))
      AND epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND epr.active_ind=1)
     JOIN (pr
     WHERE pr.person_id=epr.prsnl_person_id)
    HEAD epr.encntr_id
     person_idx = 0, person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,epr.encntr_id,
      pat_reply->qual[exp_idx].encntr_id), pcp_list = " "
    DETAIL
     IF (textlen(trim(pcp_list,3)) > 0)
      pcp_list = notrim(concat(pcp_list,"; "))
     ENDIF
     pcp_list = concat(pcp_list,trim(pr.name_full_formatted))
    FOOT  epr.encntr_id
     WHILE (person_idx)
       pat_reply->qual[person_idx].pcp_prsnl_id = epr.prsnl_person_id
       IF (trim(pat_reply->qual[person_idx].physician_name) > "")
        pat_reply->qual[person_idx].physician_name = notrim(concat(pat_reply->qual[person_idx].
          physician_name,"; ")), pat_reply->qual[person_idx].physician_name = concat(pcp_list,trim(
          pat_reply->qual[person_idx].physician_name))
       ELSE
        pat_reply->qual[person_idx].physician_name = pcp_list
       ENDIF
       person_idx = locateval(exp_idx,(person_idx+ 1),pat_reply->qual_cnt,epr.encntr_id,pat_reply->
        qual[exp_idx].encntr_id)
     ENDWHILE
    WITH nocounter, expand = 1
   ;end select
  ENDIF
  IF ((pat_request->demographics.cause_of_death_type=event_code))
   RECORD cod_cds(
     1 cod_cds[*]
       2 cod_cds = f8
   )
   DECLARE codcnt = i4 WITH noconstant(0), protected
   DECLARE exp_idx2 = i4 WITH noconstant(0), protected
   DECLARE logical_domain_id = f8 WITH noconstant(0.0), protected
   IF (islogicaldomainsactive(null))
    SELECT INTO "nl:"
     FROM prsnl p
     PLAN (p
      WHERE (p.person_id=reqinfo->updt_id))
     HEAD REPORT
      logical_domain_id = p.logical_domain_id
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_category bdc,
     br_datamart_filter bdf,
     br_datamart_value bdv
    PLAN (bdc
     WHERE bdc.category_mean="MUSE_FUNCTIONAL_2")
     JOIN (bdf
     WHERE bdf.br_datamart_category_id=bdc.br_datamart_category_id
      AND bdf.filter_mean="MUSE_DEATH_CAUSE_EVENT")
     JOIN (bdv
     WHERE bdv.br_datamart_category_id=bdf.br_datamart_category_id
      AND bdv.br_datamart_filter_id=bdf.br_datamart_filter_id
      AND bdv.logical_domain_id=logical_domain_id)
    DETAIL
     codcnt = (codcnt+ 1), stat = alterlist(cod_cds->cod_cds,codcnt), cod_cds->cod_cds[codcnt].
     cod_cds = bdv.parent_entity_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM encounter e,
     clinical_event ce
    PLAN (e
     WHERE expand(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->qual[exp_idx].encntr_id))
     JOIN (ce
     WHERE ce.person_id=e.person_id
      AND expand(exp_idx2,1,codcnt,ce.event_cd,cod_cds->cod_cds[exp_idx2].cod_cds)
      AND ce.event_end_dt_tm BETWEEN e.create_dt_tm AND cnvtdatetime(curdate,curtime3)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND ((ce.encntr_id+ 0)=e.encntr_id)
      AND ce.view_level=1
      AND ce.publish_flag=1
      AND ce.result_status_cd IN (auth_cd, altered_cd, modified_cd))
    ORDER BY e.encntr_id
    HEAD e.encntr_id
     encntr_idx = 0, encntr_idx = locateval(exp_idx,1,pat_reply->qual_cnt,e.encntr_id,pat_reply->
      qual[exp_idx].encntr_id)
     IF (encntr_idx)
      pat_reply->qual[encntr_idx].cause_of_death_id = ce.event_cd, pat_reply->qual[encntr_idx].
      preliminary_cause_of_death = ce.result_val
     ENDIF
    WITH nocounter, expand = 1
   ;end select
  ENDIF
  IF ((pat_request->primary_sort != ""))
   DECLARE primarysort = vc WITH private, noconstant("")
   DECLARE secondarysort = vc WITH private, noconstant("")
   DECLARE sortparsestr = vc WITH private, noconstant("")
   DECLARE primaryparsestring = vc WITH private, noconstant(
    "pat_reply_temp->qual[d.seq].name_full_formatted")
   DECLARE secondaryparsestring = vc WITH private, noconstant(
    "pat_reply_temp->qual[d.seq].name_full_formatted")
   SET stat = initrec(pat_reply_temp)
   SET stat = moverec(pat_reply,pat_reply_temp)
   SET stat = initrec(pat_reply)
   SET pat_reply->qual_cnt = pat_reply_temp->qual_cnt
   CALL echorecord(pat_reply_temp)
   IF ((pat_request->primary_sort != "LAB"))
    SET sortparsestr = "select into 'nl:' primarySort = trim(cnvtupper(substring(1, 40, "
   ELSE
    SET sortparsestr = "select into 'nl:' primarySort = "
   ENDIF
   IF ((pat_request->primary_sort="SEX"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].sex"
   ELSEIF ((((pat_request->primary_sort="AGE")) OR ((pat_request->primary_sort="DOB"))) )
    SET primaryparsestring = " cnvtstring(cnvtdatetime(pat_reply_temp->qual[d.seq].birth_dt_tm), 17)"
   ELSEIF ((pat_request->primary_sort="PREFERRED_LANGUAGE"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].preferred_language"
   ELSEIF ((pat_request->primary_sort="RACE"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].race"
   ELSEIF ((pat_request->primary_sort="ETHNICITY"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].ethnicity"
   ELSEIF ((pat_request->primary_sort="PRELIMINARY_CAUSE_OF_DEATH"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].preliminary_cause_of_death"
   ELSEIF ((pat_request->primary_sort="PROBLEM"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].problem_sort"
   ELSEIF ((pat_request->primary_sort="MEDICATION"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].medications_sort"
   ELSEIF ((pat_request->primary_sort="MED_ALLERGY"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].medication_allergy_sort"
   ELSEIF ((pat_request->primary_sort="LAB"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].lab_results_sort"
   ELSEIF ((pat_request->primary_sort="PCP"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].primary_care_physician"
   ELSEIF ((pat_request->primary_sort="REG_DT"))
    SET primaryparsestring = " cnvtstring(cnvtdatetime(pat_reply_temp->qual[d.seq].reg_dt_tm), 17)"
   ELSEIF ((pat_request->primary_sort="COMM_PREF"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].patient_communication_preference"
   ELSEIF ((pat_request->primary_sort="MRN"))
    SET primaryparsestring = " pat_reply_temp->qual[d.seq].mrn"
   ENDIF
   IF ((pat_request->primary_sort != "LAB")
    AND (pat_request->secondary_sort != "LAB"))
    SET sortparsestr = build2(sortparsestr,primaryparsestring,
     ")), 3), secondarySort = trim(cnvtupper(substring(1, 40, ")
   ELSEIF ((pat_request->primary_sort != "LAB"))
    SET sortparsestr = build2(sortparsestr,primaryparsestring,")), 3), secondarySort = ")
   ELSEIF ((pat_request->secondary_sort != "LAB"))
    SET sortparsestr = build2(sortparsestr,primaryparsestring,
     ", secondarySort = trim(cnvtupper(substring(1, 40, ")
   ELSE
    SET sortparsestr = build2(sortparsestr,primaryparsestring,", secondarySort = ")
   ENDIF
   IF ((pat_request->secondary_sort="SEX"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].sex"
   ELSEIF ((((pat_request->secondary_sort="AGE")) OR ((pat_request->secondary_sort="DOB"))) )
    SET secondaryparsestring =
    " cnvtstring(cnvtdatetime(pat_reply_temp->qual[d.seq].birth_dt_tm), 17)"
   ELSEIF ((pat_request->secondary_sort="PREFERRED_LANGUAGE"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].preferred_language"
   ELSEIF ((pat_request->secondary_sort="RACE"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].race"
   ELSEIF ((pat_request->secondary_sort="ETHNICITY"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].ethnicity"
   ELSEIF ((pat_request->secondary_sort="PRELIMINARY_CAUSE_OF_DEATH"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].preliminary_cause_of_death"
   ELSEIF ((pat_request->secondary_sort="PROBLEM"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].problem_sort"
   ELSEIF ((pat_request->secondary_sort="MEDICATION"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].medications_sort"
   ELSEIF ((pat_request->secondary_sort="MED_ALLERGY"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].medication_allergy_sort"
   ELSEIF ((pat_request->secondary_sort="LAB"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].lab_results_sort"
   ELSEIF ((pat_request->secondary_sort="PCP"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].primary_care_physician"
   ELSEIF ((pat_request->secondary_sort="REG_DT"))
    SET secondaryparsestring = " cnvtstring(cnvtdatetime(pat_reply_temp->qual[d.seq].reg_dt_tm), 17)"
   ELSEIF ((pat_request->secondary_sort="COMM_PREF"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].patient_communication_preference"
   ELSEIF ((pat_request->secondary_sort="MRN"))
    SET secondaryparsestring = " pat_reply_temp->qual[d.seq].mrn"
   ENDIF
   IF ((pat_request->secondary_sort != "LAB"))
    SET sortparsestr = build2(sortparsestr,secondaryparsestring,")), 3)")
   ELSE
    SET sortparsestr = build2(sortparsestr,secondaryparsestring)
   ENDIF
   CALL parser(sortparsestr)
   CALL echo(sortparsestr)
   SET sortparsestr = build2("from (dummyt d with seq = value(size(pat_reply_temp->qual, 5)))")
   CALL parser(sortparsestr)
   CALL echo(sortparsestr)
   SET sortparsestr = build2(" order by primarySort ")
   IF ((pat_request->primary_sort_desc=1))
    IF ((pat_request->primary_sort != "AGE"))
     SET sortparsestr = build2(sortparsestr,", ")
    ELSE
     SET sortparsestr = build2(sortparsestr," desc, ")
    ENDIF
   ELSE
    IF ((pat_request->primary_sort != "AGE"))
     SET sortparsestr = build2(sortparsestr," desc, ")
    ELSE
     SET sortparsestr = build2(sortparsestr,", ")
    ENDIF
   ENDIF
   SET sortparsestr = build2(sortparsestr," secondarySort ")
   IF ((pat_request->secondary_sort_desc=0))
    IF ((pat_request->secondary_sort != "AGE"))
     SET sortparsestr = build2(sortparsestr," desc ")
    ENDIF
   ELSE
    IF ((pat_request->secondary_sort="AGE"))
     SET sortparsestr = build2(sortparsestr," desc ")
    ENDIF
   ENDIF
   CALL parser(sortparsestr)
   CALL echo(sortparsestr)
   SET sortparsestr = build2(" detail ")
   CALL parser(sortparsestr)
   CALL echo(sortparsestr)
   SET sortparsestr = build2(
    " stat = movereclist(pat_reply_temp->qual, pat_reply->qual, d.seq, 0, 1, true) ")
   CALL parser(sortparsestr)
   CALL echo(sortparsestr)
   SET sortparsestr = build2(" with nocounter go")
   CALL parser(sortparsestr)
   CALL echo(sortparsestr)
   CALL echorecord(pat_reply)
  ENDIF
  SET grid->row_cnt = pat_reply->qual_cnt
  SET stat = alterlist(grid->row,grid->row_cnt)
  FOR (row_idx = 1 TO grid->row_cnt)
   SET stat = alterlist(grid->row[row_idx].col,grid->col_cnt)
   FOR (col_idx = 1 TO grid->col_cnt)
     CALL parser(concat("set grid->row[row_idx].col[col_idx].value = build(pat_reply->qual[row_idx].",
       grid->cols[col_idx].col_name,") go"))
   ENDFOR
  ENDFOR
  DECLARE parser_str = vc WITH protect, noconstant("")
  CALL echo(notrim(concat("select into '",pat_request->outdev,"' ")))
  CALL parser(notrim(concat("select into '",pat_request->outdev,"' ")))
  CALL echo(concat(grid->cols[1].col_name,
    " = trim(substring(1, 200, grid->row[d.seq].col[1].value), 3)"))
  CALL parser(concat(grid->cols[1].col_name,
    " = trim(substring(1, 200, grid->row[d.seq].col[1].value), 3)"))
  FOR (col_idx = 2 TO grid->col_cnt)
    SET parser_str = build(",",grid->cols[col_idx].col_name,
     " = trim(substring(1, 200, grid->row[d.seq].col[",col_idx,"].value), 3)")
    CALL echo(parser_str)
    CALL parser(parser_str)
  ENDFOR
  CALL parser("    from (dummyt d with seq = value(grid->row_cnt)) ")
  CALL parser("    with nocounter, format, separator = ' ' go")
 ELSEIF (query_ind=false)
  SELECT INTO pat_request->outdev
   FROM dummyt d
   DETAIL
    demographics_error
   WITH nocounter
  ;end select
 ELSEIF (query_lab_result_count > 0
  AND incomplete_lab_fields > 0)
  SELECT INTO pat_request->outdev
   FROM dummyt d
   DETAIL
    lab_test_error
   WITH nocounter
  ;end select
 ELSEIF (query_reltn_fields > 0)
  SELECT INTO pat_request->outdev
   FROM dummyt d
   DETAIL
    provider_relation_error
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO pat_request->outdev
   FROM dummyt d
   DETAIL
    no_data_error
   WITH nocounter
  ;end select
 ENDIF
 CALL echorecord(pat_request)
 CALL echorecord(pat_reply)
 CALL echo("last mod: 10/21/2013  Mark Smith")
END GO
