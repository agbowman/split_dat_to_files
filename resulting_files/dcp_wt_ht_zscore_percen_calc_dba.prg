CREATE PROGRAM dcp_wt_ht_zscore_percen_calc:dba
 PROMPT
  "Height Clinical Event Id:" = 0.0,
  "Weight Clinical Event Id:" = 0.0
  WITH htclinicaleventid, wtclinicaleventid
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
 DECLARE zscore_source_string = vc WITH constant(uar_i18ngetmessage(i18nhandle,"zscore_source_string",
   "ZScore Source - "))
 DECLARE percentile_source_string = vc WITH constant(uar_i18ngetmessage(i18nhandle,
   "percentile_source_string","Percentile Source - "))
 DECLARE getpatientinfo(null) = null
 DECLARE getpreferenceinfo(null) = null
 DECLARE getstatsdata(null) = null
 DECLARE calculatewtforhtorlenzscore(null) = null
 DECLARE calculatewtforhtorlenpercentile(null) = null
 DECLARE failed = i2 WITH noconstant(0)
 DECLARE error_msg = vc WITH noconstant("")
 DECLARE wtforhtorlen_sex_cd = f8 WITH noconstant(0.0)
 DECLARE wtforhtorlen_birth_dt_tm = dq8 WITH noconstant(0)
 DECLARE wtorht_resultant_event_end_dt_tm = dq8 WITH noconstant(0)
 DECLARE wtorht_trigger_event_end_dt_tm = dq8 WITH noconstant(0)
 DECLARE wtorht_trigger_parent_event_id = f8 WITH noconstant(0.0)
 DECLARE wtorht_trigger_event_cd = f8 WITH noconstant(0.0)
 DECLARE wtorht_resultant_event_cd = f8 WITH noconstant(0.0)
 DECLARE age_in_days = f8 WITH noconstant(0.0)
 DECLARE ref_datastats_value = f8 WITH noconstant(0.0)
 DECLARE wtforhtorlen_median = f8 WITH noconstant(0.0)
 DECLARE wtforhtorlen_coeff_of_var = f8 WITH noconstant(0.0)
 DECLARE wtforhtorlen_box_cox_power = f8 WITH noconstant(0.0)
 DECLARE wtorht_trigger = f8 WITH noconstant(0.0)
 DECLARE wtorht_resultant = f8 WITH noconstant(0.0)
 DECLARE wtforhtorlen_zscore = f8 WITH noconstant(0.0)
 DECLARE wtforhtorlen_percentile = f8 WITH noconstant(0.0)
 DECLARE chart_src = vc WITH noconstant("BESTFIT")
 DECLARE wtforhtorlen_chart_def_scale_pref = i2 WITH noconstant(2)
 DECLARE wtforhtorlen_ht_wt_match_interval = i2 WITH noconstant(60)
 DECLARE wtforhtorlen_chart_source_cd = f8 WITH noconstant(0.0)
 DECLARE wtforhtorlen_chart_source_disp_zscore = vc WITH noconstant("")
 DECLARE wtforhtorlen_chart_source_disp_percentile = vc WITH noconstant("")
 DECLARE wtresultval = f8 WITH noconstant(0.0)
 DECLARE htresultval = f8 WITH noconstant(0.0)
 DECLARE wteventcd = f8 WITH noconstant(0.0)
 DECLARE hteventcd = f8 WITH noconstant(0.0)
 DECLARE inerroreventcd = f8 WITH noconstant(uar_get_code_by("MEANING",8,"INERROR"))
 IF (((link_clineventid <= 0) OR (link_personid <= 0)) )
  SET failed = 1
  SET error_msg = "Error retrieving patient data from trigger."
  GO TO exit_script
 ENDIF
 CALL getpreferenceinfo(null)
 CALL getpatientinfo(null)
 CALL getstatsdata(null)
 CALL calculatewtforhtorlenzscore(null)
 CALL calculatewtforhtorlenpercentile(null)
 GO TO exit_script
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
   SET stat = alterlist(pref_req->pref[1].entries,3)
   SET pref_req->pref[1].entries[1].entry = "def_src_for_percentile_calc"
   SET pref_req->pref[1].entries[2].entry = "default_scale_type"
   SET pref_req->pref[1].entries[3].entry = "height_weight_match_interval"
   EXECUTE ppr_preferences  WITH replace("REQUEST","PREF_REQ"), replace("REPLY","PREF_REP")
   IF ((pref_rep->status_data.status="S"))
    SET chart_src = cnvtupper(pref_rep->pref[1].entries[1].values[1].value)
    SET wtforhtorlen_chart_def_scale_pref = cnvtint(substring(1,1,pref_rep->pref[1].entries[2].
      values[1].value))
    SET wtforhtorlen_ht_wt_match_interval = cnvtint(pref_rep->pref[1].entries[3].values[1].value)
   ENDIF
   IF (chart_src="")
    SET chart_src = "BESTFIT"
   ENDIF
   IF (wtforhtorlen_chart_def_scale_pref=0)
    SET wtforhtorlen_chart_def_scale_pref = 2
   ENDIF
   IF (wtforhtorlen_ht_wt_match_interval=0)
    SET wtforhtorlen_ht_wt_match_interval = 60
   ENDIF
 END ;Subroutine
 SUBROUTINE getpatientinfo(null)
   DECLARE min_time_diff = f8 WITH noconstant(0)
   FREE RECORD wtorht_event_end_date_time_rec
   RECORD wtorht_event_end_date_time_rec(
     1 cnt = i4
     1 qual[*]
       2 value = dq8
   )
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE (ce.clinical_event_id= $HTCLINICALEVENTID)
    DETAIL
     hteventcd = ce.event_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE (ce.clinical_event_id= $WTCLINICALEVENTID)
    DETAIL
     wteventcd = ce.event_cd
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.clinical_event_id=link_clineventid
    DETAIL
     IF (cnvtreal(ce.result_val) <= 0.0)
      failed = 1, error_msg = "Error retrieving Weight or Height results"
     ELSE
      wtorht_trigger = cnvtreal(ce.result_val), wtorht_trigger_parent_event_id = ce.parent_event_id,
      wtorht_trigger_event_cd = ce.event_cd,
      wtorht_trigger_event_end_dt_tm = ce.event_end_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (failed=1)
    GO TO exit_script
   ENDIF
   IF (wtorht_trigger_event_cd=wteventcd)
    SET wtorht_resultant_event_cd = hteventcd
   ELSEIF (wtorht_trigger_event_cd=hteventcd)
    SET wtorht_resultant_event_cd = wteventcd
   ELSE
    SET failed = 1
    SET error_msg = "Error retrieving height or weight event code."
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    FROM clinical_event ce
    WHERE ce.parent_event_id=wtorht_trigger_parent_event_id
     AND ce.event_cd=wtorht_resultant_event_cd
     AND (ce.event_id !=
    (SELECT
     event_id
     FROM clinical_event
     WHERE event_cd=wtorht_resultant_event_cd
      AND person_id=link_personid
      AND result_status_cd=inerroreventcd))
    DETAIL
     wtorht_resultant = cnvtreal(ce.result_val), wtorht_resultant_event_end_dt_tm = ce
     .event_end_dt_tm
    WITH nocounter
   ;end select
   IF (wtorht_resultant <= 0)
    SELECT INTO "nl:"
     FROM clinical_event ce
     WHERE ce.event_end_dt_tm=cnvtdatetime(wtorht_trigger_event_end_dt_tm)
      AND ce.event_cd=wtorht_resultant_event_cd
      AND ce.person_id=link_personid
      AND (ce.event_id !=
     (SELECT
      event_id
      FROM clinical_event
      WHERE event_cd=wtorht_resultant_event_cd
       AND person_id=link_personid
       AND result_status_cd=inerroreventcd))
     ORDER BY ce.performed_dt_tm
     DETAIL
      wtorht_resultant = cnvtreal(ce.result_val), wtorht_resultant_event_end_dt_tm = ce
      .event_end_dt_tm
     WITH nocounter
    ;end select
   ENDIF
   IF (wtorht_resultant <= 0)
    SELECT INTO "nl:"
     FROM clinical_event ce
     WHERE ce.event_cd=wtorht_resultant_event_cd
      AND ce.person_id=link_personid
      AND (ce.event_id !=
     (SELECT
      event_id
      FROM clinical_event
      WHERE event_cd=wtorht_resultant_event_cd
       AND person_id=link_personid
       AND result_status_cd=inerroreventcd))
     HEAD REPORT
      count = 0, stat = alterlist(wtorht_event_end_date_time_rec->qual,5)
     DETAIL
      count += 1
      IF (mod(count,5)=1)
       stat = alterlist(wtorht_event_end_date_time_rec->qual,(count+ 4))
      ENDIF
      wtorht_event_end_date_time_rec->qual[count].value = ce.event_end_dt_tm
     FOOT REPORT
      wtorht_event_end_date_time_rec->cnt = count, stat = alterlist(wtorht_event_end_date_time_rec->
       qual,count)
     WITH nocounter
    ;end select
    SET min_time_diff = abs(datetimediff(wtorht_event_end_date_time_rec->qual[1].value,
      wtorht_trigger_event_end_dt_tm,4))
    FOR (index = 2 TO wtorht_event_end_date_time_rec->cnt)
      IF (abs(datetimediff(wtorht_event_end_date_time_rec->qual[index].value,
        wtorht_trigger_event_end_dt_tm,4)) < min_time_diff)
       SET min_time_diff = abs(datetimediff(wtorht_event_end_date_time_rec->qual[index].value,
         wtorht_trigger_event_end_dt_tm,4))
      ENDIF
    ENDFOR
    SELECT INTO "nl:"
     FROM clinical_event ce
     WHERE ce.event_cd=wtorht_resultant_event_cd
      AND ce.person_id=link_personid
      AND min_time_diff <= wtforhtorlen_ht_wt_match_interval
      AND (ce.event_id !=
     (SELECT
      event_id
      FROM clinical_event
      WHERE event_cd=wtorht_resultant_event_cd
       AND person_id=link_personid
       AND result_status_cd=inerroreventcd))
     DETAIL
      IF (abs(datetimediff(ce.event_end_dt_tm,wtorht_trigger_event_end_dt_tm,4))=min_time_diff)
       wtorht_resultant = cnvtreal(ce.result_val), wtorht_resultant_event_end_dt_tm = ce
       .event_end_dt_tm
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   IF (wtorht_resultant <= 0.0)
    SET failed = 1
    SET error_msg = "Error retrieving resultant Weight or Height results"
    GO TO exit_script
   ENDIF
   IF (wtorht_trigger_event_cd=wteventcd)
    SET wtresultval = wtorht_trigger
    SET htresultval = wtorht_resultant
   ELSE
    SET wtresultval = wtorht_resultant
    SET htresultval = wtorht_trigger
   ENDIF
   SELECT INTO "nl:"
    FROM person p
    WHERE p.person_id=link_personid
    DETAIL
     IF (((p.sex_cd <= 0) OR (p.birth_dt_tm <= 0)) )
      failed = 1, error_msg = "Error retrieving sex code / birthdate."
     ELSE
      wtforhtorlen_sex_cd = p.sex_cd, wtforhtorlen_birth_dt_tm = p.birth_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (failed=1)
    GO TO exit_script
   ENDIF
   SET age_in_days = datetimediff(wtorht_resultant_event_end_dt_tm,wtforhtorlen_birth_dt_tm)
 END ;Subroutine
 SUBROUTINE getstatsdata(null)
   DECLARE wtforhtorlen_chart_type_cd = f8
   DECLARE wtforhtorlen_chart_source_cdc_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,
     "CDC"))
   DECLARE wtforhtorlen_chart_source_who_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,
     "WHO"))
   DECLARE wtforhtorlen_chart_source_cdcwho_cd = f8 WITH noconstant(uar_get_code_by("MEANING",255550,
     "CDCWHO"))
   DECLARE found_row = i2 WITH noconstant(0)
   DECLARE wtforhtorlen_chart_definition_id = f8 WITH noconstant(0)
   DECLARE min_age_range = f8 WITH noconstant(0)
   DECLARE d_where = vc
   DECLARE wt_chart_axis_unit_cd = f8 WITH noconstant(0)
   DECLARE weight_from_cd = f8 WITH noconstant(uar_get_code_by("MEANING",54,"KG"))
   DECLARE weight_to_cd = f8 WITH noconstant(uar_get_code_by("MEANING",54,"LB"))
   DECLARE height_from_cd = f8 WITH noconstant(uar_get_code_by("MEANING",54,"CM"))
   DECLARE height_to_cd = f8 WITH noconstant(uar_get_code_by("MEANING",54,"INCHES"))
   DECLARE newval = f8 WITH protect, noconstant(0)
   IF (age_in_days <= 731.0)
    SET wtforhtorlen_chart_type_cd = uar_get_code_by("MEANING",255551,"WEIGHTLEN")
   ELSE
    SET wtforhtorlen_chart_type_cd = uar_get_code_by("MEANING",255551,"WEIGHTHEIGHT")
   ENDIF
   IF (wtforhtorlen_chart_type_cd <= 0.0)
    IF (age_in_days <= 731.0)
     SET wtforhtorlen_chart_type_cd = uar_get_code_by("DISPLAYKEY",255551,"WEIGHTFORLENGTH")
    ELSE
     SET wtforhtorlen_chart_type_cd = uar_get_code_by("DISPLAYKEY",255551,"WEIGHTFORHEIGHT")
    ENDIF
   ENDIF
   IF (wtforhtorlen_chart_source_cdc_cd <= 0.0)
    SET wtforhtorlen_chart_source_cdc_cd = uar_get_code_by("DISPLAYKEY",255550,"CDC")
   ENDIF
   IF (wtforhtorlen_chart_source_who_cd <= 0.0)
    SET wtforhtorlen_chart_source_who_cd = uar_get_code_by("DISPLAYKEY",255550,"WHO")
   ENDIF
   IF (wtforhtorlen_chart_source_cdcwho_cd <= 0.0)
    SET wtforhtorlen_chart_source_cdcwho_cd = uar_get_code_by("DISPLAYKEY",255550,"CDCWHO")
   ENDIF
   IF (((wtforhtorlen_chart_type_cd <= 0) OR (wtforhtorlen_chart_source_cdc_cd <= 0
    AND wtforhtorlen_chart_source_who_cd <= 0
    AND wtforhtorlen_chart_source_cdcwho_cd <= 0)) )
    SET failed = 1
    SET error_msg = "Error retrieving chart type or source from CDF meaning."
    GO TO exit_script
   ENDIF
   IF (chart_src="BESTFIT")
    SET d_where =
"c.chart_source_cd in (WtForHtOrLen_chart_source_CDC_cd, WtForHtOrLen_chart_source_WHO_cd, WtForHtOrLen_chart_source_CDCWHO\
_cd)\
"
   ELSEIF (chart_src="CDC")
    SET d_where = "c.chart_source_cd = WtForHtOrLen_chart_source_CDC_cd"
   ELSEIF (chart_src="WHO")
    SET d_where = "c.chart_source_cd = WtForHtOrLen_chart_source_WHO_cd"
   ELSEIF (chart_src="CDCWHO")
    SET d_where = "c.chart_source_cd = WtForHtOrLen_chart_source_CDCWHO_cd"
   ENDIF
   IF (wtforhtorlen_chart_def_scale_pref=1)
    SET wt_chart_axis_unit_cd = uar_get_code_by("MEANING",54,"LB")
    IF (wt_chart_axis_unit_cd=0)
     SET wt_chart_axis_unit_cd = uar_get_code_by("DISPLAYKEY",54,"LB")
    ENDIF
   ELSEIF (wtforhtorlen_chart_def_scale_pref=2)
    SET wt_chart_axis_unit_cd = uar_get_code_by("MEANING",54,"KG")
    IF (wt_chart_axis_unit_cd=0)
     SET wt_chart_axis_unit_cd = uar_get_code_by("DISPLAYKEY",54,"KG")
    ENDIF
   ENDIF
   SELECT
    result = min((c.max_age - c.min_age))
    FROM chart_definition c
    WHERE parser(d_where)
     AND c.chart_type_cd=wtforhtorlen_chart_type_cd
     AND c.sex_cd=wtforhtorlen_sex_cd
     AND c.min_age <= age_in_days
     AND c.max_age > age_in_days
     AND c.y_axis_unit_cd=wt_chart_axis_unit_cd
    DETAIL
     min_age_range = result
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM chart_definition c
    WHERE parser(d_where)
     AND c.chart_type_cd=wtforhtorlen_chart_type_cd
     AND c.sex_cd=wtforhtorlen_sex_cd
     AND c.min_age <= age_in_days
     AND c.max_age > age_in_days
     AND c.y_axis_unit_cd=wt_chart_axis_unit_cd
    DETAIL
     IF (((c.max_age - c.min_age)=min_age_range))
      wtforhtorlen_chart_definition_id = c.chart_definition_id
     ENDIF
     wtforhtorlen_chart_source_cd = c.chart_source_cd, wtforhtorlen_chart_source_disp_zscore = concat
     ("^~:!",zscore_source_string,uar_get_code_display(c.chart_source_cd)),
     wtforhtorlen_chart_source_disp_percentile = concat("^~:!",percentile_source_string,
      uar_get_code_display(c.chart_source_cd))
    WITH nocounter
   ;end select
   IF (wtforhtorlen_chart_definition_id=0)
    SET failed = 1
    SET error_msg = "No WtForHtOrLen charts match the patient age range."
    GO TO exit_script
   ENDIF
   IF (wtforhtorlen_chart_def_scale_pref=1)
    IF (convertunits(height_to_cd,height_from_cd,htresultval,newval)=1)
     SET ref_datastats_value = newval
    ELSE
     SET ref_datastats_value = ((htresultval * 1.0e-2) * 3.93700803e+1)
    ENDIF
    IF (convertunits(weight_to_cd,weight_from_cd,wtresultval,newval)=1)
     SET wtresultval = newval
    ELSE
     SET wtresultval *= 2.204623
    ENDIF
   ELSE
    SET ref_datastats_value = htresultval
    SET wtresultval = wtresultval
   ENDIF
   SELECT INTO "nl:"
    FROM ref_datastats r
    WHERE r.chart_definition_id=wtforhtorlen_chart_definition_id
     AND r.x_min_val <= ref_datastats_value
     AND r.x_max_val > ref_datastats_value
    DETAIL
     wtforhtorlen_median = r.median_value, wtforhtorlen_coeff_of_var = r.coeffnt_var_value,
     wtforhtorlen_box_cox_power = r.box_cox_power_value,
     found_row = 1
    WITH nocounter
   ;end select
   IF (found_row=0)
    SET failed = 1
    SET error_msg = "No row on table matches patient's age range."
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE calculatewtforhtorlenzscore(null)
  DECLARE pi = f8 WITH noconstant(3.14159265)
  IF (wtforhtorlen_box_cox_power != 0)
   SET wtforhtorlen_zscore = ((((wtresultval/ wtforhtorlen_median)** wtforhtorlen_box_cox_power) - 1)
   / (wtforhtorlen_box_cox_power * wtforhtorlen_coeff_of_var))
  ELSE
   SET wtforhtorlen_zscore = (log((wtresultval/ wtforhtorlen_median))/ wtforhtorlen_coeff_of_var)
  ENDIF
 END ;Subroutine
 SUBROUTINE calculatewtforhtorlenpercentile(null)
   DECLARE pi = f8 WITH noconstant(3.14159265)
   SET wtforhtorlen_percentile = (1 - ((((1/ (2 * pi))** 0.5) * exp(- (((abs(wtforhtorlen_zscore)** 2
    )/ 2)))) * (((0.4361836 * (1/ (1+ (0.33267 * abs(wtforhtorlen_zscore))))) - (0.1201676 * ((1/ (1
   + (0.33267 * abs(wtforhtorlen_zscore))))** 2)))+ (0.937298 * ((1/ (1+ (0.33267 * abs(
    wtforhtorlen_zscore))))** 3)))))
   IF (wtforhtorlen_zscore > 0)
    SET wtforhtorlen_percentile *= 100
   ELSE
    SET wtforhtorlen_percentile = (100 - (wtforhtorlen_percentile * 100))
   ENDIF
 END ;Subroutine
 SUBROUTINE (convertunits(tounitscd=f8,fromunitscd=f8,value=f8,result=f8(ref)) =i2 WITH protect)
   DECLARE happ = i4 WITH protect, noconstant(0)
   DECLARE htask = i4 WITH protect, noconstant(0)
   DECLARE hstep = i4 WITH protect, noconstant(0)
   DECLARE iret = i4 WITH protect, noconstant(0)
   DECLARE appid = i4 WITH protect, noconstant(1000300)
   DECLARE taskid = i4 WITH protect, noconstant(1000300)
   DECLARE requestid = i4 WITH protect, noconstant(1000300)
   DECLARE hreq = i4 WITH protect, noconstant(0)
   DECLARE hreply = i4 WITH protect, noconstant(0)
   DECLARE formula = vc WITH protect, noconstant("")
   DECLARE srvstat = i4 WITH protect, noconstant(0)
   SET iret = uar_crmbeginapp(appid,happ)
   IF (iret != 0)
    SET error_msg = "Failed to start App 10003000."
    RETURN(0)
   ENDIF
   SET iret = uar_crmbegintask(happ,taskid,htask)
   IF (iret != 0)
    SET error_msg = "Failed to start Task 1000300."
    GO TO exit_script
    RETURN(0)
   ENDIF
   SET iret = uar_crmbeginreq(htask,"",requestid,hstep)
   IF (iret != 0)
    SET error_msg = "Failed to start Req 1000300."
    GO TO exit_script
    RETURN(0)
   ENDIF
   SET hreq = uar_crmgetrequest(hstep)
   SET srvstat = uar_srvsetdouble(hreq,"to_unit_cd",tounitscd)
   SET srvstat = uar_srvsetdouble(hreq,"from_unit_cd",fromunitscd)
   SET iret = uar_crmperform(hstep)
   IF (iret != 0)
    SET error_msg = "Request Perform Failed."
    GO TO exit_script
   ENDIF
   SET hreply = uar_crmgetreply(hstep)
   IF (hreply > 0
    AND trim(uar_srvgetstringptr(hreply,"formula"),3) != "")
    SET formula = build2(uar_srvgetstringptr(hreply,"formula")," ",trim(format(value,
       "#################.#######"),3))
    SET result = parser(formula)
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
#exit_script
 SET log_misc1 = concat(trim(cnvtstringchk(wtforhtorlen_zscore,10,6)),"|",trim(cnvtstringchk(
    wtforhtorlen_chart_source_cd)),"|",wtforhtorlen_chart_source_disp_zscore,
  "|",trim(cnvtstringchk(wtforhtorlen_percentile,10,6)),"|",wtforhtorlen_chart_source_disp_percentile
  )
 IF (failed=1)
  SET retval = 0
  SET log_message = error_msg
 ELSE
  SET retval = 100
  SET log_message = "WtForHtOrLen Z-score and percentile calculation finished."
 ENDIF
END GO
