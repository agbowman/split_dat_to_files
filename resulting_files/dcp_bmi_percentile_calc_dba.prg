CREATE PROGRAM dcp_bmi_percentile_calc:dba
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
 DECLARE percentile_source_string = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "percentile_source_string","Percentile Source - "))
 DECLARE getpatientinfo(null) = null
 DECLARE getpreferenceinfo(null) = null
 DECLARE getstatsdata(null) = null
 DECLARE calculatebmipercentile(null) = null
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE ispatientobesecdc = i2 WITH noconstant(0)
 DECLARE error_msg = vc
 DECLARE bmi_sex_cd = f8 WITH noconstant(0.0)
 DECLARE bmi_birth_dt_tm = dq8 WITH noconstant(0)
 DECLARE bmi_event_end_dt_tm = dq8 WITH noconstant(0)
 DECLARE age_in_days = f8 WITH noconstant(0.0)
 DECLARE ref_datastats_age = f8 WITH noconstant(0.0)
 DECLARE bmi_median = f8 WITH noconstant(0.0)
 DECLARE bmi_coeff_of_var = f8 WITH noconstant(0.0)
 DECLARE bmi_box_cox_power = f8 WITH noconstant(0.0)
 DECLARE bmi = f8 WITH noconstant(0.0)
 DECLARE bmi_percentile = f8 WITH noconstant(0.0)
 DECLARE bmi_z_score = f8 WITH noconstant(0.0)
 DECLARE chart_src = vc WITH noconstant("BESTFIT")
 DECLARE bmi_chart_source_cd = f8 WITH noconstant(0.0)
 DECLARE bmi_chart_source_disp = vc
 DECLARE extendedbmi_chart_source_cd = f8 WITH noconstant(0.0)
 DECLARE extendedbmi_chart_source_disp = vc
 DECLARE bmi_p95 = f8 WITH noconstant(0.0)
 DECLARE sigma_age = f8 WITH noconstant(0.0)
 IF (((link_clineventid <= 0) OR (link_personid <= 0)) )
  SET failed = 1
  SET error_msg = "Error retrieving patient data from trigger."
  GO TO exit_script
 ENDIF
 CALL getpatientinfo(null)
 CALL getpreferenceinfo(null)
 CALL getstatsdata(null)
 CALL calculatebmipercentile(null)
 GO TO exit_script
 SUBROUTINE getpatientinfo(null)
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.clinical_event_id=link_clineventid
    DETAIL
     IF (cnvtreal(ce.result_val) <= 0.0)
      failed = 1, error_msg = "Error retrieving BMI results"
     ELSE
      bmi = cnvtreal(ce.result_val), bmi_event_end_dt_tm = ce.event_end_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (failed=1)
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM person p
    WHERE p.person_id=link_personid
    DETAIL
     IF (((p.sex_cd <= 0) OR (p.birth_dt_tm <= 0)) )
      failed = 1, error_msg = "Error retrieving sex code / birthdate."
     ELSE
      bmi_sex_cd = p.sex_cd, bmi_birth_dt_tm = p.birth_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (failed=1)
    GO TO exit_script
   ENDIF
   SET age_in_days = datetimediff(bmi_event_end_dt_tm,bmi_birth_dt_tm)
 END ;Subroutine
 SUBROUTINE getpreferenceinfo(null)
   IF ( NOT (validate(pref_req,0)))
    RECORD pref_req(
      1 write_ind = i2
      1 delete_ind = i2
      1 pref[*]
        2 contexts[*]
          3 context = vc
          3 context_id = vc
        2 section = vc
        2 section_id = vc
        2 subgroup = vc
        2 entries[*]
          3 entry = vc
          3 values[*]
            4 value = vc
    )
   ENDIF
   IF ( NOT (validate(pref_rep,0)))
    RECORD pref_rep(
      1 pref[*]
        2 section = vc
        2 section_id = vc
        2 subgroup = vc
        2 entries[*]
          3 pref_exists_ind = i2
          3 entry = vc
          3 values[*]
            4 value = vc
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    )
   ENDIF
   SET pref_req->write_ind = 0
   SET stat = alterlist(pref_req->pref,1)
   SET stat = alterlist(pref_req->pref[1].contexts,1)
   SET pref_req->pref[1].contexts[1].context = "default"
   SET pref_req->pref[1].contexts[1].context_id = "system"
   SET pref_req->pref[1].section = "component"
   SET pref_req->pref[1].section_id = "advancedgrowthchart"
   SET stat = alterlist(pref_req->pref[1].entries,2)
   SET pref_req->pref[1].entries[1].entry = "def_src_for_percentile_calc"
   SET pref_req->pref[1].entries[2].entry = "default_scale_type"
   EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
   IF ((pref_rep->status_data.status="S"))
    SET chart_src = cnvtupper(pref_rep->pref[1].entries[1].values[1].value)
   ENDIF
   IF (chart_src="")
    SET chart_src = "BESTFIT"
   ENDIF
 END ;Subroutine
 SUBROUTINE getstatsdata(null)
   DECLARE bmi_chart_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255551,"BMIFORAGE"))
   DECLARE bmi_chart_source_cdc_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,"CDC"))
   DECLARE bmi_chart_source_cdcbmi_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,"CDCBMI")
    )
   DECLARE bmi_chart_source_who_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,"WHO"))
   DECLARE bmi_chart_source_cdcwho_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,"CDCWHO")
    )
   DECLARE found_row = i2 WITH noconstant(0)
   DECLARE found_p95_row = i2 WITH noconstant(0)
   DECLARE bmi_chart_definition_id = f8 WITH noconstant(0.0)
   DECLARE extendedbmi_chart_definition_id = f8 WITH noconstant(0.0)
   DECLARE min_age_range = f8 WITH noconstant(0.0)
   DECLARE chart_age_units = f8 WITH noconstant(0.0)
   DECLARE d_where = vc
   IF (bmi_chart_type_cd <= 0.0)
    SET bmi_chart_type_cd = uar_get_code_by("DISPLAYKEY",255551,"BMIFORAGE")
   ENDIF
   IF (bmi_chart_source_cdc_cd <= 0.0)
    SET bmi_chart_source_cdc_cd = uar_get_code_by("DISPLAYKEY",255550,"CDC")
   ENDIF
   IF (bmi_chart_source_cdcbmi_cd <= 0.0)
    SET bmi_chart_source_cdcbmi_cd = uar_get_code_by("DISPLAYKEY",255550,"CDCBMI")
   ENDIF
   IF (bmi_chart_source_who_cd <= 0.0)
    SET bmi_chart_source_who_cd = uar_get_code_by("DISPLAYKEY",255550,"WHO")
   ENDIF
   IF (bmi_chart_source_cdcwho_cd <= 0.0)
    SET bmi_chart_source_cdcwho_cd = uar_get_code_by("DISPLAYKEY",255550,"CDCWHO")
   ENDIF
   IF (((bmi_chart_type_cd <= 0) OR (bmi_chart_source_cdc_cd <= 0
    AND bmi_chart_source_who_cd <= 0
    AND bmi_chart_source_cdcwho_cd <= 0
    AND bmi_chart_source_cdcbmi_cd <= 0)) )
    SET failed = 1
    SET error_msg = "Error retrieving chart type or source from CDF meaning."
    GO TO exit_script
   ENDIF
   IF (chart_src="BESTFIT")
    SET d_where =
    "c.chart_source_cd in (BMI_chart_source_CDC_cd,BMI_chart_source_WHO_cd,BMI_chart_source_CDCWHO_cd)"
   ELSEIF (chart_src="CDC")
    SET d_where = "c.chart_source_cd = BMI_chart_source_CDC_cd"
   ELSEIF (chart_src="WHO")
    SET d_where = "c.chart_source_cd = BMI_chart_source_WHO_cd"
   ELSEIF (chart_src="CDCWHO")
    SET d_where = "c.chart_source_cd = BMI_chart_source_CDCWHO_cd"
   ENDIF
   SELECT
    result = min((c.max_age - c.min_age))
    FROM chart_definition c
    WHERE parser(d_where)
     AND c.chart_type_cd=bmi_chart_type_cd
     AND c.sex_cd=bmi_sex_cd
     AND c.min_age <= age_in_days
     AND c.max_age > age_in_days
    DETAIL
     min_age_range = result
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM chart_definition c
    WHERE parser(d_where)
     AND c.chart_type_cd=bmi_chart_type_cd
     AND c.sex_cd=bmi_sex_cd
     AND c.min_age <= age_in_days
     AND c.max_age > age_in_days
    DETAIL
     IF (((c.max_age - c.min_age)=min_age_range))
      bmi_chart_definition_id = c.chart_definition_id, chart_age_units = c.x_axis_section1_unit_cd
     ENDIF
     bmi_chart_source_cd = c.chart_source_cd, bmi_chart_source_disp = concat("^~:!",
      percentile_source_string," ",uar_get_code_display(bmi_chart_source_cd))
    WITH nocounter
   ;end select
   IF (bmi_chart_source_cd=bmi_chart_source_cdc_cd
    AND bmi_chart_source_cdcbmi_cd > 0)
    SELECT INTO "nl:"
     FROM chart_definition c
     WHERE c.chart_source_cd=bmi_chart_source_cdcbmi_cd
      AND c.chart_type_cd=bmi_chart_type_cd
      AND c.sex_cd=bmi_sex_cd
      AND c.min_age <= age_in_days
      AND c.max_age > age_in_days
     DETAIL
      IF (((c.max_age - c.min_age)=min_age_range))
       extendedbmi_chart_definition_id = c.chart_definition_id, chart_age_units = c
       .x_axis_section1_unit_cd
      ENDIF
      extendedbmi_chart_source_cd = bmi_chart_source_cdcbmi_cd, extendedbmi_chart_source_disp =
      concat("^~:!",percentile_source_string," ",uar_get_code_display(extendedbmi_chart_source_cd))
     WITH nocounter
    ;end select
   ENDIF
   IF (bmi_chart_definition_id=0)
    SET failed = 1
    SET error_msg = "No bmi charts match the patient age range."
    GO TO exit_script
   ENDIF
   IF (bmi_chart_source_cd=bmi_chart_source_cdc_cd
    AND bmi_chart_source_cdcbmi_cd > 0
    AND extendedbmi_chart_definition_id=0)
    SET failed = 1
    SET error_msg = "No extended bmi charts match the patient age range."
    GO TO exit_script
   ENDIF
   IF (chart_age_units=uar_get_code_by("MEANING",54,"YEARS"))
    SET ref_datastats_age = (age_in_days/ 365.25)
   ELSEIF (chart_age_units=uar_get_code_by("MEANING",54,"MONTHS"))
    SET ref_datastats_age = ((age_in_days/ 365.25) * 12)
   ELSEIF (chart_age_units=uar_get_code_by("MEANING",54,"WEEKS"))
    SET ref_datastats_age = datetimediff(bmi_event_end_dt_tm,bmi_birth_dt_tm,2)
   ELSE
    SET failed = 1
    SET error_msg = "Error converting age to correct units for ref_datastats table comparison."
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM ref_datastats r
    WHERE r.chart_definition_id=bmi_chart_definition_id
     AND r.x_min_val <= ref_datastats_age
     AND r.x_max_val > ref_datastats_age
    DETAIL
     bmi_median = r.median_value, bmi_coeff_of_var = r.coeffnt_var_value, bmi_box_cox_power = r
     .box_cox_power_value,
     found_row = 1
    WITH nocounter
   ;end select
   IF (extendedbmi_chart_definition_id > 0)
    SELECT INTO "nl:"
     FROM ref_datapoint r,
      ref_datastats rd,
      ref_dataset rde
     WHERE rd.chart_definition_id=extendedbmi_chart_definition_id
      AND rde.chart_definition_id=rd.chart_definition_id
      AND r.ref_dataset_id=rde.ref_dataset_id
      AND rde.display_name="120% of 95"
      AND ref_datastats_age >= rd.x_min_val
      AND ref_datastats_age < rd.x_max_val
      AND r.x_val >= rd.x_min_val
      AND r.x_val < rd.x_max_val
     ORDER BY r.x_val DESC
     DETAIL
      bmi_p95 = r.y_val
      IF (bmi_p95 > 0)
       bmi_p95 /= 1.2
       IF (bmi > bmi_p95)
        sigma_age = r.x_val, ispatientobesecdc = 1, bmi_chart_source_cd = extendedbmi_chart_source_cd,
        bmi_chart_source_disp = extendedbmi_chart_source_disp
       ELSE
        bmi_median = rd.median_value, bmi_coeff_of_var = rd.coeffnt_var_value, bmi_box_cox_power = rd
        .box_cox_power_value
       ENDIF
      ENDIF
      found_p95_row = 1
     WITH nocounter
    ;end select
   ENDIF
   IF (found_row=0)
    SET failed = 1
    SET error_msg = "No row on table matches patient's age range."
    GO TO exit_script
   ENDIF
   IF (extendedbmi_chart_definition_id > 0
    AND found_p95_row=0)
    SET failed = 1
    SET error_msg = "No row found on table for 120% of 95 BMI value."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE calculatebmipercentile(null)
   DECLARE pi = f8 WITH noconstant(3.14159265)
   IF (bmi_box_cox_power != 0)
    SET bmi_z_score = ((((bmi/ bmi_median)** bmi_box_cox_power) - 1)/ (bmi_box_cox_power *
    bmi_coeff_of_var))
   ELSE
    SET bmi_z_score = (log((bmi/ bmi_median))/ bmi_coeff_of_var)
   ENDIF
   SET bmi_percentile = (1 - ((((1/ (2 * pi))** 0.5) * exp(- (((abs(bmi_z_score)** 2)/ 2)))) * (((
   0.4361836 * (1/ (1+ (0.33267 * abs(bmi_z_score))))) - (0.1201676 * ((1/ (1+ (0.33267 * abs(
    bmi_z_score))))** 2)))+ (0.937298 * ((1/ (1+ (0.33267 * abs(bmi_z_score))))** 3)))))
   IF (bmi_z_score > 0)
    SET bmi_percentile *= 100
   ELSE
    SET bmi_percentile = (100 - (bmi_percentile * 100))
   ENDIF
   IF (ispatientobesecdc=1)
    DECLARE male_codevalue = f8 WITH noconstant(uar_get_code_by("MEANING",57,"MALE"))
    DECLARE female_codevalue = f8 WITH noconstant(uar_get_code_by("MEANING",57,"FEMALE"))
    DECLARE sigma = f8 WITH noconstant(0.0)
    IF (bmi_sex_cd=female_codevalue)
     SET sigma = ((0.8334+ (0.3712 * sigma_age)) - (0.0011 * (sigma_age** 2)))
    ELSEIF (bmi_sex_cd=male_codevalue)
     SET sigma = ((0.3728+ (0.5196 * sigma_age)) - (0.0091 * (sigma_age** 2)))
    ENDIF
    SET bmi_percentile = (90+ (10 * (1 - ((((1/ (2 * pi))** 0.5) * exp(- (((abs(((bmi - bmi_p95)/
      sigma))** 2)/ 2)))) * (((0.4361836 * (1/ (1+ (0.33267 * abs(((bmi - bmi_p95)/ sigma)))))) - (
    0.1201676 * ((1/ (1+ (0.33267 * abs(((bmi - bmi_p95)/ sigma)))))** 2)))+ (0.937298 * ((1/ (1+ (
    0.33267 * abs(((bmi - bmi_p95)/ sigma)))))** 3)))))))
   ENDIF
 END ;Subroutine
#exit_script
 SET log_misc1 = concat(trim(cnvtstringchk(bmi_percentile,10,6)),"|",trim(cnvtstringchk(
    bmi_chart_source_cd)),"|",bmi_chart_source_disp)
 IF (failed=1)
  SET retval = 0
  SET log_message = error_msg
 ELSE
  SET retval = 100
  SET log_message = "BMI percentile calculation finished."
 ENDIF
END GO
