CREATE PROGRAM dcp_hc_percentile_calc:dba
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
 DECLARE calculatehcpercentile(null) = null
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE error_msg = vc
 DECLARE hc_sex_cd = f8 WITH noconstant(0.0)
 DECLARE hc_birth_dt_tm = dq8 WITH noconstant(0)
 DECLARE hc_event_end_dt_tm = dq8 WITH noconstant(0)
 DECLARE age_in_days = f8 WITH noconstant(0.0)
 DECLARE ref_datastats_age = f8 WITH noconstant(0.0)
 DECLARE hc_median = f8 WITH noconstant(0.0)
 DECLARE hc_coeff_of_var = f8 WITH noconstant(0.0)
 DECLARE hc_box_cox_power = f8 WITH noconstant(0.0)
 DECLARE hc = f8 WITH noconstant(0.0)
 DECLARE hc_percentile = f8 WITH noconstant(0.0)
 DECLARE chart_src = vc WITH noconstant("BESTFIT")
 DECLARE hc_chart_def_scale_pref = i2 WITH noconstant(2)
 DECLARE hc_chart_source_cd = f8 WITH noconstant(0.0)
 DECLARE hc_chart_source_disp = vc
 IF (((link_clineventid <= 0) OR (link_personid <= 0)) )
  SET failed = 1
  SET error_msg = "Error retrieving patient data from trigger."
  GO TO exit_script
 ENDIF
 CALL getpatientinfo(null)
 CALL getpreferenceinfo(null)
 CALL getstatsdata(null)
 CALL calculatehcpercentile(null)
 GO TO exit_script
 SUBROUTINE getpatientinfo(null)
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.clinical_event_id=link_clineventid
    DETAIL
     IF (cnvtreal(ce.result_val) <= 0.0)
      failed = 1, error_msg = "Error retrieving hc results"
     ELSE
      hc = cnvtreal(ce.result_val), hc_event_end_dt_tm = ce.event_end_dt_tm
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
      hc_sex_cd = p.sex_cd, hc_birth_dt_tm = p.birth_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (failed=1)
    GO TO exit_script
   ENDIF
   SET age_in_days = datetimediff(hc_event_end_dt_tm,hc_birth_dt_tm)
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
    SET hc_chart_def_scale_pref = cnvtint(substring(1,1,pref_rep->pref[1].entries[2].values[1].value)
     )
   ENDIF
   IF (chart_src="")
    SET chart_src = "BESTFIT"
   ENDIF
   IF (hc_chart_def_scale_pref=0)
    SET hc_chart_def_scale_pref = 2
   ENDIF
 END ;Subroutine
 SUBROUTINE getstatsdata(null)
   DECLARE hc_chart_type_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255551,"HCFORAGE"))
   DECLARE hc_chart_source_cdc_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,"CDC"))
   DECLARE hc_chart_source_who_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,"WHO"))
   DECLARE hc_chart_source_cdcwho_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,"CDCWHO"))
   DECLARE found_row = i2 WITH noconstant(0)
   DECLARE hc_chart_definition_id = f8 WITH noconstant(0)
   DECLARE min_age_range = f8 WITH noconstant(0)
   DECLARE chart_age_units = f8 WITH noconstant(0)
   DECLARE d_where = vc
   DECLARE hc_chart_axis_unit_cd = f8 WITH noconstant(0)
   IF (hc_chart_type_cd <= 0.0)
    SET hc_chart_type_cd = uar_get_code_by("DISPLAYKEY",255551,"HCFORAGE")
   ENDIF
   IF (hc_chart_source_cdc_cd <= 0.0)
    SET hc_chart_source_cdc_cd = uar_get_code_by("DISPLAYKEY",255550,"CDC")
   ENDIF
   IF (hc_chart_source_who_cd <= 0.0)
    SET hc_chart_source_who_cd = uar_get_code_by("DISPLAYKEY",255550,"WHO")
   ENDIF
   IF (hc_chart_source_cdcwho_cd <= 0.0)
    SET hc_chart_source_cdcwho_cd = uar_get_code_by("DISPLAYKEY",255550,"CDCWHO")
   ENDIF
   IF (((hc_chart_type_cd <= 0) OR (hc_chart_source_cdc_cd <= 0
    AND hc_chart_source_who_cd <= 0
    AND hc_chart_source_cdcwho_cd <= 0)) )
    SET failed = 1
    SET error_msg = "Error retrieving chart type or source from CDF meaning."
    GO TO exit_script
   ENDIF
   IF (chart_src="BESTFIT")
    SET d_where =
    "c.chart_source_cd in (hc_chart_source_CDC_cd, hc_chart_source_WHO_cd, hc_chart_source_CDCWHO_cd)"
   ELSEIF (chart_src="CDC")
    SET d_where = "c.chart_source_cd = hc_chart_source_CDC_cd"
   ELSEIF (chart_src="WHO")
    SET d_where = "c.chart_source_cd = hc_chart_source_WHO_cd"
   ELSEIF (chart_src="CDCWHO")
    SET d_where = "c.chart_source_cd = hc_chart_source_CDCWHO_cd"
   ENDIF
   SELECT
    result = min((c.max_age - c.min_age))
    FROM chart_definition c
    WHERE parser(d_where)
     AND c.chart_type_cd=hc_chart_type_cd
     AND c.sex_cd=hc_sex_cd
     AND c.min_age <= age_in_days
     AND c.max_age > age_in_days
    DETAIL
     min_age_range = result
    WITH nocounter
   ;end select
   IF (hc_chart_def_scale_pref=1)
    SET hc_chart_axis_unit_cd = uar_get_code_by("MEANING",54,"INCHES")
    IF (hc_chart_axis_unit_cd=0)
     SET hc_chart_axis_unit_cd = uar_get_code_by("DISPLAYKEY",54,"IN")
    ENDIF
   ELSEIF (hc_chart_def_scale_pref=2)
    SET hc_chart_axis_unit_cd = uar_get_code_by("MEANING",54,"CM")
    IF (hc_chart_axis_unit_cd=0)
     SET hc_chart_axis_unit_cd = uar_get_code_by("DISPLAYKEY",54,"CM")
    ENDIF
   ENDIF
   SELECT INTO "nl:"
    FROM chart_definition c
    WHERE parser(d_where)
     AND c.chart_type_cd=hc_chart_type_cd
     AND c.sex_cd=hc_sex_cd
     AND c.min_age <= age_in_days
     AND c.max_age > age_in_days
     AND c.y_axis_unit_cd=hc_chart_axis_unit_cd
    DETAIL
     IF (((c.max_age - c.min_age)=min_age_range))
      hc_chart_definition_id = c.chart_definition_id, chart_age_units = c.x_axis_section1_unit_cd
     ENDIF
     hc_chart_source_cd = c.chart_source_cd, hc_chart_source_disp = concat("^~:!",
      percentile_source_string,uar_get_code_display(c.chart_source_cd))
    WITH nocounter
   ;end select
   IF (hc_chart_definition_id=0)
    SET failed = 1
    SET error_msg = "No HC charts match the patient age range."
    GO TO exit_script
   ENDIF
   IF (chart_age_units=uar_get_code_by("MEANING",54,"YEARS"))
    SET ref_datastats_age = (age_in_days/ 365.25)
   ELSEIF (chart_age_units=uar_get_code_by("MEANING",54,"MONTHS"))
    SET ref_datastats_age = ((age_in_days/ 365.25) * 12)
   ELSEIF (chart_age_units=uar_get_code_by("MEANING",54,"WEEKS"))
    SET ref_datastats_age = datetimediff(hc_event_end_dt_tm,hc_birth_dt_tm,2)
   ELSE
    SET failed = 1
    SET error_msg = "Error converting age to correct units for ref_datastats table comparison."
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM ref_datastats r
    WHERE r.chart_definition_id=hc_chart_definition_id
     AND r.x_min_val <= ref_datastats_age
     AND r.x_max_val > ref_datastats_age
    DETAIL
     hc_median = r.median_value, hc_coeff_of_var = r.coeffnt_var_value, hc_box_cox_power = r
     .box_cox_power_value,
     found_row = 1
    WITH nocounter
   ;end select
   IF (found_row=0)
    SET failed = 1
    SET error_msg = "No row on table matches patient's age range."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE calculatehcpercentile(null)
   DECLARE pi = f8 WITH noconstant(3.14159265)
   IF (hc_box_cox_power != 0)
    SET hc_z_score = ((((hc/ hc_median)** hc_box_cox_power) - 1)/ (hc_box_cox_power * hc_coeff_of_var
    ))
   ELSE
    SET hc_z_score = (log((hc/ hc_median))/ hc_coeff_of_var)
   ENDIF
   SET hc_percentile = (1 - ((((1/ (2 * pi))** 0.5) * exp(- (((abs(hc_z_score)** 2)/ 2)))) * (((
   0.4361836 * (1/ (1+ (0.33267 * abs(hc_z_score))))) - (0.1201676 * ((1/ (1+ (0.33267 * abs(
    hc_z_score))))** 2)))+ (0.937298 * ((1/ (1+ (0.33267 * abs(hc_z_score))))** 3)))))
   IF (hc_z_score > 0)
    SET hc_percentile *= 100
   ELSE
    SET hc_percentile = (100 - (hc_percentile * 100))
   ENDIF
 END ;Subroutine
#exit_script
 SET log_misc1 = concat(trim(cnvtstringchk(hc_percentile,10,6)),"|",trim(cnvtstringchk(
    hc_chart_source_cd)),"|",hc_chart_source_disp)
 IF (failed=1)
  SET retval = 0
  SET log_message = error_msg
 ELSE
  SET retval = 100
  SET log_message = "HC percentile calculation finished."
 ENDIF
END GO
