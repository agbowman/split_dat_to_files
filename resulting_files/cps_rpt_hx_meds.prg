CREATE PROGRAM cps_rpt_hx_meds
 DECLARE utcdatetime(ddatetime=vc,lindex=i4,bshowtz=i2,sformat=vc) = vc
 DECLARE utcshorttz(lindex=i4) = vc
 DECLARE sutcdatetime = vc WITH protect, noconstant(" ")
 DECLARE dutcdatetime = f8 WITH protect, noconstant(0.0)
 DECLARE cutc = i2 WITH protect, constant(curutc)
 SUBROUTINE utcdatetime(sdatetime,lindex,bshowtz,sformat)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewdatetime = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = vc WITH protect, constant("ZZZ")
   IF (lindex > 0)
    SET lnewindex = lindex
   ENDIF
   SET snewdatetime = datetimezoneformat(sdatetime,lnewindex,sformat)
   IF (cutc=1
    AND bshowtz=1)
    IF (size(trim(snewdatetime)) > 0)
     SET snewdatetime = concat(snewdatetime," ",datetimezoneformat(sdatetime,lnewindex,
       ctime_zone_format))
    ENDIF
   ENDIF
   SET snewdatetime = trim(snewdatetime)
   RETURN(snewdatetime)
 END ;Subroutine
 SUBROUTINE utcshorttz(lindex)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE daylight = i2 WITH protect, noconstant(0)
   DECLARE lnewindex = i4 WITH protect, noconstant(curtimezoneapp)
   DECLARE snewshorttz = vc WITH protect, noconstant(" ")
   DECLARE ctime_zone_format = i2 WITH protect, constant(7)
   IF (cutc=1)
    IF (lindex > 0)
     SET lnewindex = lindex
    ENDIF
    SET snewshorttz = datetimezonebyindex(lnewindex,offset,daylight,ctime_zone_format)
   ENDIF
   SET snewshorttz = trim(snewshorttz)
   RETURN(snewshorttz)
 END ;Subroutine
 SET modify = predeclare
 RECORD reply(
   1 num_lines = f8
   1 qual[*]
     2 line = c255
   1 output_file = vc
   1 log_info[*]
     2 log_level = i2
     2 log_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET internal
 RECORD internal(
   1 pat_name = vc
   1 pat_sex = vc
   1 pat_dob = vc
   1 pat_age = vc
   1 pat_addr = vc
   1 pat_city = vc
   1 address_line1 = vc
   1 address_line2 = vc
   1 address_line3 = vc
   1 address_line4 = vc
   1 printed_by = vc
   1 orders[*]
     2 top_level_order_id = f8
     2 top_level_core_action_seq = i2
     2 top_level_order_type = f8
     2 top_level_freq_type = i2
     2 top_level_prn_ind = i2
     2 top_level_order_mnemonic = vc
     2 top_level_ordered_as_mnemonic = vc
     2 top_level_facility_name = vc
     2 top_level_mrn = vc
     2 top_level_fin = vc
     2 top_level_encntr_id = f8
     2 top_level_discharge_dttm = vc
     2 top_level_admit_dttm = vc
     2 top_level_hx_ind = i2
     2 top_level_clinical_display_line = vc
     2 unable_to_obtain_info = vc
     2 order_actions[*]
       3 action_type_cd = f8
       3 action_dt_tm = f8
       3 action_tz = i4
       3 effective_dt_tm = f8
       3 effective_tz = i4
       3 action_sequence = i2
       3 action_personnel_id = f8
       3 action_person = vc
       3 clinical_display_line = vc
       3 core_ind = i2
       3 prn_ind = i2
       3 order_id = f8
       3 verify_ind = i2
       3 schedule[*]
         4 time_of_day = i4
       3 order_ingredients[*]
         4 action_sequence = i2
         4 comp_sequence = i2
         4 order_mnemonic = vc
         4 ordered_as_mnemonic = vc
         4 strength = f8
         4 strength_unit = f8
         4 volume = f8
         4 volume_unit = f8
         4 volume_flag = f8
         4 total_volume = f8
         4 bag_freq = f8
         4 volume_display = vc
         4 strength_display = vc
     2 notes[*]
       3 action_sequence = i2
       3 max_sequence = i2
       3 order_comment_text = vc
       3 product_note_text = vc
     2 order_review[*]
       3 review_dt_tm = f8
       3 review_tz = i4
       3 review_personnel_id = f8
       3 reviewed_status_flag = i2
       3 action_sequence = i4
       3 review_sequence = i2
       3 reviewed_person_name = vc
       3 review_type_flag = i2
     2 order_compliance[1]
       3 compliance_status = vc
       3 information_src = vc
       3 compliance_comments = vc
       3 last_occured_dt_tm = f8
       3 last_occured_tz = i4
 )
 FREE SET act_fltr_lst
 RECORD act_fltr_lst(
   1 count = i4
   1 qual[*]
     2 act_type_cd = f8
 )
 FREE SET cat_fltr_lst
 RECORD cat_fltr_lst(
   1 count = i4
   1 qual[*]
     2 cat_type_cd = f8
 )
 FREE SET order_fltr_lst
 RECORD order_fltr_lst(
   1 count = i4
   1 qual[*]
     2 catalog_cd = f8
 )
 DECLARE script_version = c50 WITH private, noconstant(fillstring(50," "))
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE action_count = i4 WITH protect, noconstant(0)
 DECLARE note_count = i4 WITH protect, noconstant(0)
 DECLARE review_count = i4 WITH protect, noconstant(0)
 DECLARE rpt_header = vc WITH protect, noconstant(" ")
 DECLARE orderable_sort = vc WITH protect, noconstant(" ")
 DECLARE ordered_as = vc WITH protect, noconstant(" ")
 DECLARE long_line = vc WITH protect, noconstant(" ")
 DECLARE ordered_by = vc WITH protect, noconstant(" ")
 DECLARE modified_by = vc WITH protect, noconstant(" ")
 DECLARE time = c4 WITH protect, noconstant(" ")
 DECLARE time2 = i2 WITH protect, noconstant(0)
 DECLARE tod = f8 WITH protect, noconstant(0.0)
 DECLARE reviewed_print = vc WITH protect, noconstant(" ")
 DECLARE order_action_dt_tm = vc WITH protect, noconstant(" ")
 DECLARE dose_print = vc WITH protect, noconstant(" ")
 DECLARE ord_mnem = vc WITH protect, noconstant(" ")
 DECLARE review_action_type = vc WITH protect, noconstant(" ")
 DECLARE prsnl_type = vc WITH protect, noconstant(" ")
 DECLARE prsnl_id = vc WITH protect, noconstant(" ")
 DECLARE order_id = vc WITH protect, noconstant(" ")
 DECLARE action_performed_by = vc WITH protect, noconstant(" ")
 DECLARE print_action = vc WITH protect, noconstant(" ")
 DECLARE strength_dose = f8 WITH protect, noconstant(0.0)
 DECLARE strength_display = vc WITH protect, noconstant(" ")
 DECLARE strength_dose_unit = f8 WITH protect, noconstant(0.0)
 DECLARE volume_dose = f8 WITH protect, noconstant(0.0)
 DECLARE volume_display = vc WITH protect, noconstant(" ")
 DECLARE volume_dose_unit = f8 WITH protect, noconstant(0.0)
 DECLARE print_bag_freq = vc WITH protect, noconstant(" ")
 DECLARE granted_ind = i2 WITH protect, noconstant(1)
 DECLARE activity_filter_ind = i2 WITH protect, noconstant(0)
 DECLARE catalog_filter_ind = i2 WITH protect, noconstant(0)
 DECLARE order_filter_ind = i2 WITH protect, noconstant(0)
 DECLARE filtered_list_count = i4 WITH protect, noconstant(0)
 DECLARE position = i4 WITH protect, noconstant(0)
 DECLARE temp_id = f8 WITH protect, noconstant(0.0)
 DECLARE loc_num = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE unabletoobtainind = i4 WITH protect, noconstant(0)
 DECLARE _hi18nhandle = i4 WITH protect, noconstant(0)
 DECLARE _lretval = i4 WITH protect, noconstant(0)
 DECLARE unableind = i2 WITH protect, noconstant(0)
 DECLARE noknownind = i2 WITH protect, noconstant(0)
 DECLARE no_known_home_meds = vc WITH protect, noconstant(" ")
 DECLARE unable_to_obtain = vc WITH protect, noconstant(" ")
 DECLARE compliance_info = vc WITH protect, noconstant(" ")
 DECLARE ct = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE line = c100 WITH protect, constant(fillstring(100,"_"))
 DECLARE line2 = c66 WITH protect, constant(fillstring(80,"_"))
 DECLARE line3 = c32 WITH protect, constant(fillstring(32,"_"))
 DECLARE line4 = c130 WITH protect, constant(fillstring(130,"_"))
 DECLARE pharmacy_cd = f8 WITH constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE order_comment_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT"))
 DECLARE product_note_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"MARNOTE"))
 DECLARE cmed = f8 WITH constant(uar_get_code_by("MEANING",18309,"MED"))
 DECLARE civ = f8 WITH constant(uar_get_code_by("MEANING",18309,"IV"))
 DECLARE cmodify = f8 WITH constant(uar_get_code_by("MEANING",6003,"MODIFY"))
 DECLARE corder = f8 WITH constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE cactivatecd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ACTIVATE"))
 DECLARE crefill = f8 WITH constant(uar_get_code_by("MEANING",6003,"REFILL"))
 DECLARE crenew = f8 WITH constant(uar_get_code_by("MEANING",6003,"RENEW"))
 DECLARE cstatuschg = f8 WITH constant(uar_get_code_by("MEANING",6003,"STATUSCHANGE"))
 DECLARE caccepted = i2 WITH protect, constant(1)
 DECLARE crejected = i2 WITH protect, constant(2)
 DECLARE csuperseded = i2 WITH protect, constant(4)
 DECLARE creviewed = i2 WITH protect, constant(5)
 DECLARE cnurse = i2 WITH protect, constant(1)
 DECLARE cdoctor = i2 WITH protect, constant(2)
 DECLARE crx = i2 WITH protect, constant(3)
 DECLARE cactivate = i2 WITH protect, constant(1)
 DECLARE cfin = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE cmrn = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE home_add_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE found_address = i2 WITH protect, noconstant(false)
 DECLARE strwhere = vc WITH protect, noconstant("")
 DECLARE cactivity_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6015,"ACTIVITYTYPE"))
 DECLARE ccatalog_type_cd = f8 WITH constant(uar_get_code_by("MEANING",6015,"CATALOGTYPE"))
 DECLARE corderables_cd = f8 WITH constant(uar_get_code_by("MEANING",6015,"ORDERABLES"))
 DECLARE cstrength_id = f8 WITH protect, constant(2056.00)
 DECLARE cvolume_id = f8 WITH protect, constant(2058.00)
 CALL echo(build("cSTATUSCHG = ",cstatuschg))
 SET reply->status_data.status = "F"
 SET act_fltr_lst->count = 0
 SET cat_fltr_lst->count = 0
 SET order_fltr_lst->count = 0
 SET count1 = 0
 IF (size(request->privileges,5)=1)
  SET granted_ind = request->privileges[0].default[0].granted_ind
  FOR (count1 = 1 TO size(request->privileges[0].default[0].exceptions,5))
    IF ((request->privileges[0].default[0].exceptions[count1].type_cd=cactivity_type_cd))
     SET activity_filter_ind = 1
     SET act_fltr_lst->count = (act_fltr_lst->count+ 1)
     IF ((act_fltr_lst->count >= size(act_fltr_lst->qual,5)))
      SET stat = alterlist(act_fltr_lst->qual,(act_fltr_lst->count+ 10))
     ENDIF
     SET temp_id = request->privileges[0].default[0].exceptions[count1].id
     SET act_fltr_lst->qual[act_fltr_lst->count].act_type_cd = temp_id
    ELSEIF ((request->privileges[0].default[0].exceptions[count1].type_cd=ccatalog_type_cd))
     SET catalog_filter_ind = 1
     SET cat_fltr_lst->count = (cat_fltr_lst->count+ 1)
     IF ((cat_fltr_lst->count >= size(cat_fltr_lst->qual,5)))
      SET stat = alterlist(cat_fltr_lst->qual,(cat_fltr_lst->count+ 10))
     ENDIF
     SET temp_id = request->privileges[0].default[0].exceptions[count1].id
     SET cat_fltr_lst->qual[cat_fltr_lst->count].cat_type_cd = temp_id
    ELSEIF ((request->privileges[0].default[0].exceptions[count1].type_cd=corderables_cd))
     SET order_filter_ind = 1
     SET order_fltr_lst->count = (order_fltr_lst->count+ 1)
     IF ((order_fltr_lst->count >= size(order_fltr_lst->qual,5)))
      SET stat = alterlist(order_fltr_lst->qual,(order_fltr_lst->count+ 10))
     ENDIF
     SET temp_id = request->privileges[0].default[0].exceptions[count1].id
     SET order_fltr_lst->qual[order_fltr_lst->count].catalog_cd = temp_id
    ENDIF
  ENDFOR
  SET stat = alterlist(act_fltr_lst->qual,act_fltr_lst->count)
  SET stat = alterlist(cat_fltr_lst->qual,cat_fltr_lst->count)
  SET stat = alterlist(order_fltr_lst->qual,order_fltr_lst->count)
 ENDIF
 EXECUTE cpm_create_file_name "hx_meds", "ps"
 CALL echo(build("Output Filename: ",cpm_cfn_info->file_name_full_path))
 SET reply->output_file = trim(cpm_cfn_info->file_name_full_path)
 IF ((request->start_dt_tm <= 0))
  SET request->start_dt_tm = cnvtdatetime("01-JAN-2003 00:00:00")
 ENDIF
 IF ((request->end_dt_tm <= 0))
  SET request->end_dt_tm = cnvtdatetime(curdate,curtime3)
 ENDIF
 CALL echo(concat("End Date: ",concat(trim(format(cnvtdatetime(curdate,curtime3),"@MEDIUMDATE4YR")),
    " ",trim(format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS")))))
 IF ((request->chart_request_id > 0.0))
  SELECT INTO "nl:"
   FROM chart_request cr,
    person p
   PLAN (cr
    WHERE (cr.chart_request_id=request->chart_request_id))
    JOIN (p
    WHERE p.person_id=cr.request_prsnl_id)
   DETAIL
    internal->printed_by = p.name_full_formatted
   WITH nocounter
  ;end select
 ELSEIF ((reqinfo->updt_id > 0.0))
  SELECT INTO "nl:"
   FROM person p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    internal->printed_by = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("============== Getting patient info ==============",1)
 SELECT INTO "nl:"
  FROM person p,
   address a
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND (request->person_id > 0.0))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON")
    AND a.address_type_cd=outerjoin(home_add_cd)
    AND a.active_ind=outerjoin(1)
    AND a.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  ORDER BY a.address_id
  HEAD REPORT
   internal->pat_name = trim(p.name_full_formatted), internal->pat_sex = trim(uar_get_code_display(p
     .sex_cd)), internal->pat_dob = trim(format(cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz
       ),1),"@SHORTDATE4YR")),
   internal->pat_age = cnvtage(p.birth_dt_tm), found_address = false
  HEAD a.address_id
   IF (a.address_id > 0
    AND found_address=false)
    found_address = true, internal->address_line1 = trim(substring(1,33,a.street_addr)), internal->
    address_line2 = trim(substring(1,33,a.street_addr2)),
    internal->address_line3 = trim(substring(1,33,a.street_addr3)), internal->address_line4 = trim(
     substring(1,33,a.street_addr4)), internal->pat_city = trim(a.city)
    IF (a.state_cd > 0)
     internal->pat_city = concat(trim(internal->pat_city),", ",trim(uar_get_code_display(a.state_cd))
      )
    ELSEIF (a.state > " ")
     internal->pat_city = concat(trim(internal->pat_city),", ",trim(a.state))
    ENDIF
    IF (a.zipcode > " ")
     internal->pat_city = concat(trim(internal->pat_city)," ",trim(a.zipcode))
    ENDIF
    internal->pat_city = trim(substring(1,33,internal->pat_city))
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->scope_flag=5))
  SET strwhere = concat("e.person_id = request->person_id ",
   "and expand(num,1,size(request->encntr_list,5),e.encntr_id,request->encntr_list[num].encntr_id)")
 ELSEIF ((request->scope_flag=1))
  SET strwhere = "e.person_id = request->person_id"
 ELSE
  SET strwhere = "e.person_id = request->person_id and e.encntr_id = request->encntr_id"
 ENDIF
 CALL echo(build("strWhere = '",strwhere,"'"))
 SELECT INTO "nl:"
  o.order_id
  FROM orders o,
   encounter e,
   encntr_alias ea
  PLAN (e
   WHERE (e.person_id=request->person_id))
   JOIN (o
   WHERE o.encntr_id=e.encntr_id
    AND o.catalog_type_cd=pharmacy_cd
    AND ((o.orig_ord_as_flag=2) OR (o.orig_ord_as_flag=1))
    AND o.orig_order_dt_tm >= cnvtdatetime(request->start_dt_tm)
    AND o.orig_order_dt_tm <= cnvtdatetime(request->end_dt_tm)
    AND  EXISTS (
   (SELECT
    oa.order_id
    FROM order_action oa
    WHERE oa.order_id=o.order_id
     AND oa.action_sequence=o.last_action_sequence
     AND ((o.orig_ord_as_flag=2
     AND oa.action_type_cd IN (corder, cmodify, cstatuschg)) OR (o.orig_ord_as_flag=1
     AND oa.action_type_cd IN (corder, cmodify, crefill, cactivatecd, crenew,
    cstatuschg))) )))
   JOIN (ea
   WHERE ea.encntr_id=o.encntr_id
    AND ea.encntr_alias_type_cd IN (cfin, cmrn)
    AND ea.active_ind=true
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY o.order_mnemonic, o.order_id
  HEAD REPORT
   count1 = 0, filtered_list_count = 0
  HEAD o.order_id
   position = 0
   IF (catalog_filter_ind=1)
    position = locateval(loc_num,1,cat_fltr_lst->count,o.catalog_type_cd,cat_fltr_lst->qual[loc_num].
     cat_type_cd)
   ENDIF
   IF (position=0
    AND activity_filter_ind=1)
    position = locateval(loc_num,1,act_fltr_lst->count,o.activity_type_cd,act_fltr_lst->qual[loc_num]
     .act_type_cd)
   ENDIF
   IF (position=0
    AND order_filter_ind=1)
    position = locateval(loc_num,1,order_fltr_lst->count,o.catalog_cd,order_fltr_lst->qual[loc_num].
     catalog_cd)
   ENDIF
   IF (((position > 0
    AND granted_ind=1) OR (position=0
    AND granted_ind=0)) )
    filtered_list_count = (filtered_list_count+ 1)
    IF (mod(filtered_list_count,10)=1)
     stat = alterlist(reply->log_info,(filtered_list_count+ 9))
    ENDIF
    reply->log_info[filtered_list_count].log_message = cnvtstring(o.order_id,3)
   ENDIF
   IF (((granted_ind=1
    AND position=0) OR (granted_ind=0
    AND position > 0)) )
    count1 = (count1+ 1)
    IF (mod(count1,10)=1)
     stat = alterlist(internal->orders,(count1+ 9))
    ENDIF
    internal->orders[count1].top_level_order_id = o.order_id, internal->orders[count1].
    top_level_core_action_seq = o.last_core_action_sequence, internal->orders[count1].
    top_level_order_type = o.med_order_type_cd,
    internal->orders[count1].top_level_order_mnemonic = o.order_mnemonic, internal->orders[count1].
    top_level_ordered_as_mnemonic = o.ordered_as_mnemonic, internal->orders[count1].top_level_prn_ind
     = o.prn_ind,
    internal->orders[count1].top_level_freq_type = o.freq_type_flag, internal->orders[count1].
    top_level_facility_name = uar_get_code_display(e.location_cd), internal->orders[count1].
    top_level_encntr_id = o.encntr_id,
    internal->orders[count1].top_level_discharge_dttm = trim(format(cnvtdatetime(e.disch_dt_tm),
      "@SHORTDATE4YR")), internal->orders[count1].top_level_admit_dttm = trim(format(cnvtdatetime(e
       .inpatient_admit_dt_tm),"@SHORTDATE4YR")), internal->orders[count1].
    top_level_clinical_display_line = o.clinical_display_line
    IF (o.orig_ord_as_flag=2)
     internal->orders[count1].top_level_hx_ind = 1
    ENDIF
   ENDIF
  DETAIL
   IF (((granted_ind=1
    AND position=0) OR (granted_ind=0
    AND position > 0)) )
    CALL echo(build("ALIAS: ",ea.alias))
    IF (ea.encntr_alias_type_cd=cfin)
     internal->orders[count1].top_level_fin = trim(ea.alias)
    ELSE
     IF (ea.alias_pool_cd > 0)
      internal->orders[count1].top_level_mrn = trim(cnvtalias(ea.alias,ea.alias_pool_cd))
     ELSE
      internal->orders[count1].top_level_mrn = trim(ea.alias)
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(internal->orders,count1), stat = alterlist(reply->log_info,filtered_list_count)
  WITH nocounter
 ;end select
 SET _lretval = uar_i18nlocalizationinit(_hi18nhandle,curprog,"",curcclrev)
 IF (curqual=0)
  SELECT INTO value(reply->output_file)
   FROM order_compliance oc
   WHERE (oc.encntr_id=request->encntr_id)
   ORDER BY oc.performed_dt_tm
   HEAD REPORT
    "{f/0/1}{cpi/14^}{lpi/8}", row + 1, "{color/31/1}",
    "{pos/065/20}{box/093/2/1}", row + 1, "{color/30/1}",
    "{pos/095/47}{box/080/5/1}", row + 1, "{color/31/1}",
    "{pos/095/47}{box/080/5/1}", row + 1, "{f/5/1}{cpi/5^}{lpi/3}",
    "{pos/000/10}", row + 1, col 15,
    "Medication Profile - Historical Meds", "{f/0/1}{cpi/16^}{lpi/6}", "{f/0/1}{cpi/16^}{lpi/6}",
    row + 1, "{pos/000/043}", row + 1,
    col 20, "Patient :", col 30,
    internal->pat_name, col 70, "DOB / Sex :",
    col 82, internal->pat_dob, " ",
    internal->pat_sex, row + 1, col 20,
    "Address :", col 30, internal->address_line1,
    row + 1
    IF ((internal->address_line2 > " "))
     col 30, internal->address_line2, row + 1
    ENDIF
    IF ((internal->address_line3 > " "))
     col 30, internal->address_line3, row + 1
    ENDIF
    IF ((internal->address_line4 > " "))
     col 30, internal->address_line4, row + 1
    ENDIF
    curdate_disp = concat(trim(format(cnvtdatetime(curdate,curtime3),"@SHORTDATE4YR"))," ",trim(
      format(cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS"))), col 20, "Print by:  ",
    col 30, internal->printed_by, col 70,
    "Printed   :  ", col 82, curdate_disp,
    row + 1, col 20, "Date range: ",
    startdate_disp = concat(trim(format(cnvtdatetime(request->start_dt_tm),"@SHORTDATE4YR"))," ",trim
     (format(cnvtdatetime(request->start_dt_tm),"@TIMENOSECONDS"))), enddate_disp = concat(trim(
      format(cnvtdatetime(request->end_dt_tm),"@SHORTDATE4YR"))," ",trim(format(cnvtdatetime(request
        ->end_dt_tm),"@TIMENOSECONDS"))), col 32,
    startdate_disp, col 49, "-> ",
    enddate_disp
   HEAD oc.performed_dt_tm
    IF (oc.unable_to_obtain_ind=1)
     unableind = 1
    ELSE
     unableind = 0
    ENDIF
    IF (oc.no_known_home_meds_ind=1)
     noknownind = 1
    ELSE
     noknownind = 0
    ENDIF
   FOOT  oc.performed_dt_tm
    row + 0
   FOOT REPORT
    row + 2, compliance_info = uar_i18ngetmessage(_hi18nhandle,"compliance_info","Compliance Info:")
    IF (noknownind=1)
     reply->status_data.status = "S", no_known_home_meds = uar_i18ngetmessage(_hi18nhandle,
      "no_known_home_meds","No known home medications."), col 20,
     compliance_info, col 40, no_known_home_meds
    ELSEIF (unableind=1)
     reply->status_data.status = "S", unable_to_obtain = uar_i18ngetmessage(_hi18nhandle,
      "unable_to_obtain","Unable to obtain information."), col 20,
     compliance_info, col 40, unable_to_obtain
    ELSE
     reply->status_data.status = "Z"
    ENDIF
   WITH nocounter, maxcol = 500, maxrow = 80,
    dio = postscript
  ;end select
  IF (curqual=0)
   SET reply->status_data.status = "Z"
  ENDIF
  GO TO exit_program
 ENDIF
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(internal->orders,5))),
   order_action oa,
   (left JOIN order_ingredient oi ON oi.order_id=oa.order_id
    AND oi.action_sequence <= oa.action_sequence),
   (left JOIN order_detail od ON od.order_id=oi.order_id
    AND od.action_sequence=oi.action_sequence
    AND od.oe_field_meaning_id IN (cstrength_id, cvolume_id)),
   prsnl p
  PLAN (d)
   JOIN (oa
   WHERE (oa.order_id=internal->orders[d.seq].top_level_order_id))
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
   JOIN (oi)
   JOIN (od)
  ORDER BY oa.order_id, oa.action_sequence, oi.action_sequence,
   oi.comp_sequence, od.oe_field_meaning_id
  HEAD REPORT
   x = 0
  HEAD oa.order_id
   action_count = 0
  HEAD oa.action_sequence
   action_count = (action_count+ 1)
   IF (action_count > size(internal->orders[d.seq].order_actions,5))
    stat = alterlist(internal->orders[d.seq].order_actions,(action_count+ 9))
   ENDIF
   internal->orders[d.seq].order_actions[action_count].action_type_cd = oa.action_type_cd, internal->
   orders[d.seq].order_actions[action_count].action_sequence = oa.action_sequence, internal->orders[d
   .seq].order_actions[action_count].action_personnel_id = oa.action_personnel_id,
   internal->orders[d.seq].order_actions[action_count].action_person = p.name_full_formatted,
   internal->orders[d.seq].order_actions[action_count].clinical_display_line = oa
   .clinical_display_line, internal->orders[d.seq].order_actions[action_count].core_ind = oa.core_ind,
   internal->orders[d.seq].order_actions[action_count].prn_ind = oa.prn_ind, internal->orders[d.seq].
   order_actions[action_count].order_id = oa.order_id, internal->orders[d.seq].order_actions[
   action_count].action_dt_tm = oa.action_dt_tm,
   internal->orders[d.seq].order_actions[action_count].action_tz = oa.action_tz, internal->orders[d
   .seq].order_actions[action_count].effective_dt_tm = oa.effective_dt_tm, internal->orders[d.seq].
   order_actions[action_count].effective_tz = oa.effective_tz,
   internal->orders[d.seq].order_actions[action_count].verify_ind = oa.needs_verify_ind
  HEAD oi.action_sequence
   ingredient_action_count = 0
  HEAD oi.comp_sequence
   ingredient_action_count = (ingredient_action_count+ 1)
   IF (ingredient_action_count > size(internal->orders[d.seq].order_actions[action_count].
    order_ingredients,5))
    stat = alterlist(internal->orders[d.seq].order_actions[action_count].order_ingredients,(
     ingredient_action_count+ 9))
   ENDIF
   internal->orders[d.seq].order_actions[action_count].order_ingredients[ingredient_action_count].
   action_sequence = oi.action_sequence, internal->orders[d.seq].order_actions[action_count].
   order_ingredients[ingredient_action_count].comp_sequence = oi.comp_sequence, internal->orders[d
   .seq].order_actions[action_count].order_ingredients[ingredient_action_count].order_mnemonic = oi
   .order_mnemonic,
   internal->orders[d.seq].order_actions[action_count].order_ingredients[ingredient_action_count].
   ordered_as_mnemonic = oi.ordered_as_mnemonic, internal->orders[d.seq].order_actions[action_count].
   order_ingredients[ingredient_action_count].strength = oi.strength, internal->orders[d.seq].
   order_actions[action_count].order_ingredients[ingredient_action_count].strength_unit = oi
   .strength_unit,
   internal->orders[d.seq].order_actions[action_count].order_ingredients[ingredient_action_count].
   volume = oi.volume, internal->orders[d.seq].order_actions[action_count].order_ingredients[
   ingredient_action_count].volume_unit = oi.volume_unit, internal->orders[d.seq].order_actions[
   action_count].order_ingredients[ingredient_action_count].volume_flag = oi
   .include_in_total_volume_flag,
   internal->orders[d.seq].order_actions[action_count].order_ingredients[ingredient_action_count].
   bag_freq = oi.freq_cd
  HEAD od.oe_field_meaning_id
   IF (od.oe_field_meaning_id=cstrength_id)
    internal->orders[d.seq].order_actions[action_count].order_ingredients[ingredient_action_count].
    strength_display = od.oe_field_display_value
   ENDIF
   IF (od.oe_field_meaning_id=cvolume_id)
    internal->orders[d.seq].order_actions[action_count].order_ingredients[ingredient_action_count].
    volume_display = od.oe_field_display_value
   ENDIF
  FOOT  od.oe_field_meaning_id
   row + 0
  FOOT  oi.comp_sequence
   stat = alterlist(internal->orders[d.seq].order_actions[action_count].order_ingredients,
    ingredient_action_count)
  FOOT  oa.order_id
   stat = alterlist(internal->orders[d.seq].order_actions,action_count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(internal->orders,5))),
   order_comment oc,
   long_text lt
  PLAN (d)
   JOIN (oc
   WHERE (oc.order_id=internal->orders[d.seq].top_level_order_id)
    AND oc.comment_type_cd IN (order_comment_cd, product_note_cd))
   JOIN (lt
   WHERE lt.long_text_id=oc.long_text_id)
  ORDER BY oc.order_id, oc.action_sequence, oc.comment_type_cd
  HEAD oc.order_id
   note_count = 0
  HEAD oc.action_sequence
   note_count = (note_count+ 1)
   IF (note_count > size(internal->orders[d.seq].notes,5))
    stat = alterlist(internal->orders[d.seq].notes,(note_count+ 9))
   ENDIF
   internal->orders[d.seq].notes[note_count].action_sequence = oc.action_sequence
  HEAD oc.comment_type_cd
   IF (oc.comment_type_cd=order_comment_cd)
    internal->orders[d.seq].notes[note_count].order_comment_text = lt.long_text
   ELSEIF (oc.comment_type_cd=product_note_cd)
    internal->orders[d.seq].notes[note_count].product_note_text = lt.long_text
   ENDIF
  FOOT  oc.order_id
   stat = alterlist(internal->orders[d.seq].notes,note_count)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = value(size(internal->orders,5))),
   order_review ordr,
   prsnl p
  PLAN (d)
   JOIN (ordr
   WHERE (ordr.order_id=internal->orders[d.seq].top_level_order_id)
    AND ordr.review_personnel_id > 0)
   JOIN (p
   WHERE p.person_id=ordr.review_personnel_id)
  ORDER BY ordr.order_id, ordr.action_sequence, ordr.review_sequence
  HEAD ordr.order_id
   review_count = 0
  HEAD ordr.action_sequence
   x = 0
  HEAD ordr.review_sequence
   review_count = (review_count+ 1)
   IF (review_count > size(internal->orders[d.seq].order_review,5))
    stat = alterlist(internal->orders[d.seq].order_review,(review_count+ 9))
   ENDIF
   internal->orders[d.seq].order_review[review_count].review_sequence = ordr.review_sequence,
   internal->orders[d.seq].order_review[review_count].action_sequence = ordr.action_sequence,
   internal->orders[d.seq].order_review[review_count].review_dt_tm = ordr.review_dt_tm,
   internal->orders[d.seq].order_review[review_count].review_tz = ordr.review_tz, internal->orders[d
   .seq].order_review[review_count].review_personnel_id = ordr.review_personnel_id, internal->orders[
   d.seq].order_review[review_count].reviewed_status_flag = ordr.reviewed_status_flag,
   internal->orders[d.seq].order_review[review_count].reviewed_person_name = p.name_full_formatted,
   internal->orders[d.seq].order_review[review_count].review_type_flag = ordr.review_type_flag
  FOOT  ordr.order_id
   stat = alterlist(internal->orders[d.seq].order_review,review_count)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM order_compliance oc
  PLAN (oc
   WHERE (oc.encntr_id=request->encntr_id)
    AND oc.order_compliance_id > 0.0)
  ORDER BY oc.performed_dt_tm
  HEAD oc.performed_dt_tm
   unableind = oc.unable_to_obtain_ind
  WITH nocounter
 ;end select
 IF (unableind=0)
  SELECT INTO "NL:"
   FROM order_compliance oc,
    order_compliance_detail ocd,
    long_text lt
   PLAN (oc
    WHERE (oc.encntr_id=request->encntr_id))
    JOIN (ocd
    WHERE expand(num,1,size(internal->orders,5),ocd.order_nbr,internal->orders[num].
     top_level_order_id)
     AND oc.order_compliance_id=ocd.order_compliance_id)
    JOIN (lt
    WHERE outerjoin(ocd.long_text_id)=lt.long_text_id)
   ORDER BY ocd.order_nbr, ocd.compliance_capture_dt_tm
   HEAD REPORT
    ct = 0
   HEAD ocd.order_nbr
    index = locateval(ct,1,size(internal->orders,5),ocd.order_nbr,internal->orders[ct].
     top_level_order_id)
   HEAD ocd.compliance_capture_dt_tm
    IF (index > 0)
     internal->orders[index].order_compliance[1].compliance_status = uar_get_code_display(ocd
      .compliance_status_cd), internal->orders[index].order_compliance[1].information_src =
     uar_get_code_display(ocd.information_source_cd), internal->orders[index].order_compliance[1].
     last_occured_dt_tm = ocd.last_occurred_dt_tm,
     internal->orders[index].order_compliance[1].last_occured_tz = ocd.last_occurred_tz, internal->
     orders[index].order_compliance[1].compliance_comments = lt.long_text
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 CALL echo("=================== Reporting Begins =================",1)
 SELECT INTO value(reply->output_file)
  med_sort =
  IF ((internal->orders[d.seq].top_level_freq_type=5)) 2
  ELSEIF ((internal->orders[d.seq].top_level_order_type=civ)) 4
  ELSEIF ((internal->orders[d.seq].top_level_prn_ind=1)) 3
  ELSE 1
  ENDIF
  , heading_sort = concat(internal->orders[d.seq].top_level_facility_name," ",internal->orders[d.seq]
   .top_level_mrn," ",internal->orders[d.seq].top_level_fin,
   " ",trim(cnvtstring(internal->orders[d.seq].top_level_encntr_id))), orderable_sort = internal->
  orders[d.seq].top_level_order_mnemonic
  FROM (dummyt d  WITH seq = value(size(internal->orders,5)))
  PLAN (d
   WHERE (internal->orders[d.seq].top_level_order_id > 0))
  ORDER BY heading_sort, orderable_sort
  HEAD REPORT
   "{f/0/1}{cpi/14^}{lpi/8}", row + 1, "{color/31/1}",
   "{pos/065/20}{box/093/2/1}", row + 1, "{color/30/1}",
   "{pos/095/47}{box/080/5/1}", row + 1, "{color/31/1}",
   "{pos/095/47}{box/080/5/1}", row + 1, "{f/5/1}{cpi/5^}{lpi/3}",
   "{pos/000/10}", row + 1, col 15,
   "Medication Profile - Historical Meds", "{f/0/1}{cpi/16^}{lpi/6}", "{f/0/1}{cpi/16^}{lpi/6}",
   row + 1, "{pos/000/043}", row + 1,
   col 20, "Patient :", col 30,
   internal->pat_name, col 70, "DOB / Sex :",
   col 82, internal->pat_dob, " ",
   internal->pat_sex, row + 1, col 20,
   "Address :", col 30, internal->address_line1,
   row + 1
   IF ((internal->address_line2 > " "))
    col 30, internal->address_line2, row + 1
   ENDIF
   IF ((internal->address_line3 > " "))
    col 30, internal->address_line3, row + 1
   ENDIF
   IF ((internal->address_line4 > " "))
    col 30, internal->address_line4, row + 1
   ENDIF
   curdate_disp = concat(trim(format(cnvtdatetime(curdate,curtime3),"@SHORTDATE4YR"))," ",trim(format
     (cnvtdatetime(curdate,curtime3),"@TIMENOSECONDS"))), col 20, "Print by:  ",
   col 30, internal->printed_by, col 70,
   "Printed   :  ", col 82, curdate_disp,
   row + 1, col 20, "Date range: ",
   startdate_disp = concat(trim(format(cnvtdatetime(request->start_dt_tm),"@SHORTDATE4YR"))," ",trim(
     format(cnvtdatetime(request->start_dt_tm),"@TIMENOSECONDS"))), enddate_disp = concat(trim(format
     (cnvtdatetime(request->end_dt_tm),"@SHORTDATE4YR"))," ",trim(format(cnvtdatetime(request->
       end_dt_tm),"@TIMENOSECONDS"))), col 32,
   startdate_disp, col 49, "-> ",
   enddate_disp,
   MACRO (parse_zeroes)
    dsvalue = fillstring(16," "), move_fld = fillstring(16," "), strfld = fillstring(16," "),
    sig_dig = 0, sig_dec = 0, strfld = cnvtstring(pass_field_in,16,4,r),
    str_cnt = 1, len = 0
    WHILE (str_cnt < 12
     AND substring(str_cnt,1,strfld) IN ("0", " "))
      str_cnt = (str_cnt+ 1)
    ENDWHILE
    sig_dig = (str_cnt - 1), str_cnt = 16
    WHILE (str_cnt > 12
     AND substring(str_cnt,1,strfld) IN ("0", " "))
      str_cnt = (str_cnt - 1)
    ENDWHILE
    IF (str_cnt=12
     AND substring(str_cnt,1,strfld)=".")
     str_cnt = (str_cnt - 1)
    ENDIF
    sig_dec = str_cnt
    IF (sig_dig=11
     AND sig_dec=11)
     dsvalue = "n/a"
    ELSE
     len = movestring(strfld,(sig_dig+ 1),move_fld,1,(sig_dec - sig_dig)), dsvalue = trim(move_fld)
     IF (substring(1,1,dsvalue)=".")
      dsvalue = concat("0",trim(move_fld))
     ENDIF
    ENDIF
   ENDMACRO
   ,
   MACRO (prnt_note)
    ln_width_in = chars_per_line, stuck = 0, count_no_spaces = 0,
    counter = 0, time_to_loop = 0, time_to_loop = ((size(trim(note_text_in,1))/ chars_per_line)+ 1)
    FOR (note_length = 1 TO time_to_loop)
      FOR (time2 = 1 TO chars_per_line)
       counter = (counter+ 1),
       IF (substring(counter,1,note_text_in) != " ")
        count_no_spaces = (count_no_spaces+ 1)
        IF (count_no_spaces >= chars_per_line)
         stuck = 1, note_length = time_to_loop, time2 = chars_per_line
        ENDIF
       ELSE
        count_no_spaces = 0
       ENDIF
      ENDFOR
    ENDFOR
    IF (stuck=0)
     start_pos = 1, big_string_len = 0, count = 0,
     note_string = fillstring(90," "), hold_string = fillstring(90," "), return_found = 0,
     big_string_len = size(trim(note_text_in)), cr = fillstring(1," "), cr = char(13)
     WHILE (((big_string_len - start_pos) > 0))
       space_loc = 0, return_found = 0, count = 0,
       cr_count = 0, end_pos = 0, end_pos = (ln_width_in+ start_pos),
       len = movestring(note_text_in,start_pos,hold_string,0,end_pos), hold_string = hold_string,
       cr_count = findstring(cr,hold_string)
       IF (cr_count > 0
        AND size(trim(substring(0,(cr_count - 1),hold_string))) <= chars_per_line)
        return_found = 1, note_string = substring(0,(cr_count - 1),hold_string), note_string = trim(
         note_string,1),
        call reportmove('COL',(00+ col_start),0), "{ENDB}", note_string,
        row + 1, ord_row = row, cr_count = (cr_count+ 1),
        start_pos = (start_pos+ cr_count)
       ENDIF
       WHILE (count < ln_width_in
        AND return_found=0)
        count = (count+ 1),
        IF (substring(count,1,hold_string)=" "
         AND return_found=0)
         space_loc = count
        ENDIF
       ENDWHILE
       IF (space_loc > 0
        AND return_found=0)
        note_string = substring(0,(space_loc - 1),hold_string), note_string = trim(note_string),
        call reportmove('COL',(00+ col_start),0),
        "{ENDB}", note_string, row + 1,
        ord_row = row, start_pos = (start_pos+ space_loc)
       ENDIF
     ENDWHILE
    ELSE
     call reportmove('COL',(00+ col_start),0), "See chart for notes", row + 1,
     ord_row = row
    ENDIF
   ENDMACRO
  HEAD heading_sort
   print_line = 0, "{f/0/1}{cpi/16^}{lpi/6}",
   CALL echo(concat("heading_sort = '",heading_sort,"'")),
   row + 2, col 02, "{B}Med Rec # : ",
   internal->orders[d.seq].top_level_mrn, col 50, "{B}FIN # : ",
   internal->orders[d.seq].top_level_fin, row + 1, col 02,
   "{B}Facility : ", internal->orders[d.seq].top_level_facility_name
   IF ((internal->orders[d.seq].top_level_admit_dttm > " "))
    col 50, "{B}Admit Date: ", internal->orders[d.seq].top_level_admit_dttm
   ENDIF
   IF ((internal->orders[d.seq].top_level_discharge_dttm > " "))
    col 100, "{B}Discharge Date: ", internal->orders[d.seq].top_level_discharge_dttm
   ENDIF
   row + 2
   IF ((internal->orders[d.seq].top_level_freq_type=5))
    rpt_header = "UNSCHEDULED MEDS"
   ELSEIF ((internal->orders[d.seq].top_level_prn_ind=1))
    rpt_header = "PRN"
   ELSEIF ((internal->orders[d.seq].top_level_order_type=civ))
    rpt_header = "CONTINUOUS INFUSIONS"
   ELSE
    rpt_header = "SCHEDULED MEDS"
   ENDIF
   col 2, "{B}", rpt_header,
   row + 1, line4
  HEAD d.seq
   IF (print_line=1)
    line
   ENDIF
   print_line = 1, row + 1
  HEAD orderable_sort
   x = 0, y = size(internal->orders[d.seq].order_actions,5)
   FOR (action = 1 TO y)
     ingredients = 0, volume_dose = 0.0, volume_dose_unit = 0.0,
     strength_dose = 0.0, strength_dose_unit = 0.0, dose_print = " ",
     ordered_as = " ", ordered_by = " ", modified_by = " ",
     activated_by = " ", refilled_by = " ", renewed_by = " ",
     order_action_dt_tm = " ", long_line = " ", strength_display = " ",
     volume_display = " "
     IF ((internal->orders[d.seq].order_actions[action].action_type_cd=corder))
      row + 1
      FOR (ingredients = 1 TO size(internal->orders[d.seq].order_actions[action].order_ingredients,5)
       )
        print_bag_freq = " ", "{f/4/1}{lpi/8}{cpi/14}", ord_mnem = " "
        IF ((internal->orders[d.seq].top_level_hx_ind=1))
         ord_mnem = concat("Hx--",internal->orders[d.seq].order_actions[action].order_ingredients[
          ingredients].order_mnemonic)
        ELSE
         ord_mnem = internal->orders[d.seq].order_actions[action].order_ingredients[ingredients].
         order_mnemonic
        ENDIF
        "{B}", ord_mnem
        IF ((internal->orders[d.seq].order_actions[action].order_ingredients[ingredients].
        ordered_as_mnemonic != internal->orders[d.seq].order_actions[action].order_ingredients[
        ingredients].order_mnemonic))
         ordered_as = concat("(",trim(internal->orders[d.seq].order_actions[action].
           order_ingredients[ingredients].ordered_as_mnemonic),")")
        ENDIF
        IF ((internal->orders[d.seq].order_actions[action].order_ingredients[ingredients].volume > 0)
         AND (internal->orders[d.seq].order_actions[action].order_ingredients[ingredients].strength
         > 0))
         volume_display = internal->orders[d.seq].order_actions[action].order_ingredients[ingredients
         ].volume_display, volume_dose_unit = internal->orders[d.seq].order_actions[action].
         order_ingredients[ingredients].volume_unit, dose_print = concat(trim(volume_display)," ",
          trim(uar_get_code_display(volume_dose_unit))),
         strength_display = internal->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].strength_display, strength_dose_unit = internal->orders[d.seq].order_actions[
         action].order_ingredients[ingredients].strength_unit, dose_print = concat(trim(dose_print),
          " = ",concat(trim(strength_display)," ",trim(uar_get_code_display(strength_dose_unit))))
        ELSEIF ((internal->orders[d.seq].order_actions[action].order_ingredients[ingredients].
        strength > 0))
         strength_display = internal->orders[d.seq].order_actions[action].order_ingredients[
         ingredients].strength_display, strength_dose_unit = internal->orders[d.seq].order_actions[
         action].order_ingredients[ingredients].strength_unit, dose_print = concat(trim(
           strength_display)," ",trim(uar_get_code_display(strength_dose_unit)))
        ELSEIF ((internal->orders[d.seq].order_actions[action].order_ingredients[ingredients].volume
         > 0))
         volume_display = internal->orders[d.seq].order_actions[action].order_ingredients[ingredients
         ].volume_display, volume_dose_unit = internal->orders[d.seq].order_actions[action].
         order_ingredients[ingredients].volume_unit, dose_print = concat(trim(volume_display)," ",
          trim(uar_get_code_display(volume_dose_unit)))
        ELSE
         dose_print = "NO STRENGTH OR VOLUME"
        ENDIF
        IF ((internal->orders[d.seq].top_level_order_type=civ))
         bag_freq = internal->orders[d.seq].order_actions[action].order_ingredients[ingredients].
         bag_freq, print_bag_freq = uar_get_code_description(bag_freq)
        ENDIF
        long_line = concat(trim(ordered_as),"      ",trim(dose_print))
        IF ((internal->orders[d.seq].top_level_order_type=civ))
         long_line = concat(long_line," ",trim(print_bag_freq))
        ENDIF
        IF (ingredients=1)
         order_id = "", order_id = concat("(Order Id = ",trim(cnvtstring(internal->orders[d.seq].
            top_level_order_id)),")"), long_line = concat(long_line,"     ",trim(order_id))
        ENDIF
        long_line, row + 1
      ENDFOR
      col 2, internal->orders[d.seq].top_level_clinical_display_line, row + 1
      IF (size(internal->orders[d.seq].notes,5) > 0)
       FOR (note = 1 TO size(internal->orders[d.seq].notes,5))
        IF (size(internal->orders[d.seq].notes[note].order_comment_text) > 0
         AND (internal->orders[d.seq].notes[note].action_sequence <= internal->orders[d.seq].
        order_actions[action].action_sequence))
         col 4, "{B}", "Order Comment: ",
         "{ENDB}", note_text_in = fillstring(1000," "), note_text_in = internal->orders[d.seq].notes[
         note].order_comment_text,
         chars_per_line = 90, note_string = fillstring(90," "), col_start = 22,
         prnt_note
        ENDIF
        ,
        IF (size(internal->orders[d.seq].notes[note].product_note_text) > 0
         AND (internal->orders[d.seq].notes[note].action_sequence <= internal->orders[d.seq].
        order_actions[action].action_sequence))
         col 4, "{B}", "Product Note: ",
         note_text_in = fillstring(1000," "), note_text_in = internal->orders[d.seq].notes[note].
         product_note_text, chars_per_line = 90,
         note_string = fillstring(90," "), col_start = 22, prnt_note
        ENDIF
       ENDFOR
      ENDIF
      reviewed_print = " "
      IF ((internal->orders[d.seq].order_actions[action].action_type_cd=corder))
       ordered_by = trim(internal->orders[d.seq].order_actions[action].action_person), col 6, "{B}",
       "Order Entered By: ", "{ENDB}", ordered_by,
       row + 1
      ENDIF
      review_action_type = "", prsnl_type = "", prsnl_id = ""
      FOR (review = 1 TO size(internal->orders[d.seq].order_review,5))
        IF ((internal->orders[d.seq].order_actions[action].action_sequence=internal->orders[d.seq].
        order_review[review].action_sequence))
         sdisplay = "", sutcdatetime = utcdatetime(internal->orders[d.seq].order_review[review].
          review_dt_tm,internal->orders[d.seq].order_review[review].review_tz,1,"@SHORTDATETIMENOSEC"
          ), reviewed_print = sutcdatetime
         CASE (internal->orders[d.seq].order_review[review].reviewed_status_flag)
          OF csuperseded:
           review_action_type = " superceded on "
          OF crejected:
           review_action_type = " rejected on "
          OF caccepted:
           review_action_type = " accepted on "
          OF creviewed:
           review_action_type = " reviewed on "
          ELSE
           review_action_type = ""
         ENDCASE
         CASE (internal->orders[d.seq].order_review[review].review_type_flag)
          OF cnurse:
           prsnl_type = "Nurse : "
          OF cdoctor:
           prsnl_type = "Dr. "
          OF crx:
           prsnl_type = "Pharmacist: "
          OF cactivate:
           prsnl_type = "Physician Activated: "
          ELSE
           prsnl_type = ""
         ENDCASE
         prsnl_id = trim(cnvtstring(internal->orders[d.seq].order_review[review].review_personnel_id)
          ), col 6, prsnl_type,
         " ", "{B}", prsnl_id,
         "{ENDB}", review_action_type, " ",
         reviewed_print, row + 1
        ENDIF
      ENDFOR
      row + 1
      IF (y > 1)
       col 2, "ACTION(S)", col 25,
       "ACTION TIME(S)", "{f/4/1}{lpi/18}{cpi/14}", row + 1,
       col 2, line3, "{f/4/1}{lpi/8}{cpi/14}",
       row + 1
      ENDIF
     ELSE
      print_action = uar_get_code_display(internal->orders[d.seq].order_actions[action].
       action_type_cd), col 2, "{B}",
      print_action, sutcdatetime = utcdatetime(internal->orders[d.seq].order_actions[action].
       effective_dt_tm,internal->orders[d.seq].order_actions[action].effective_tz,1,
       "@SHORTDATETIMENOSEC"), order_action_dt_tm = sutcdatetime,
      col 27, "{B}", order_action_dt_tm,
      row + 1, action_performed_by = trim(internal->orders[d.seq].order_actions[action].action_person
       ), col 130,
      "{ENDB}", "Performed By: ", action_performed_by,
      row + 1
     ENDIF
   ENDFOR
   row + 1
   IF (unableind=1)
    internal->orders[d.seq].unable_to_obtain_info = uar_i18ngetmessage(_hi18nhandle,
     "unable_to_obtain","Unable to obtain information."), col 8, "{B}",
    "Compliance: ", note_text_in = fillstring(1000," "), note_text_in = internal->orders[d.seq].
    unable_to_obtain_info,
    chars_per_line = 90, note_string = fillstring(90," "), col_start = 22,
    prnt_note
   ELSE
    IF (size(internal->orders[d.seq].order_compliance[1].compliance_status,1) > 0)
     col 8, "{B}", "Compliance status: ",
     note_text_in = fillstring(1000," "), note_text_in = internal->orders[d.seq].order_compliance[1].
     compliance_status, chars_per_line = 90,
     note_string = fillstring(90," "), col_start = 31, prnt_note
    ENDIF
    IF (size(internal->orders[d.seq].order_compliance[1].information_src,1) > 0)
     col 8, "{B}", "Compliance Information Source: ",
     note_text_in = fillstring(1000," "), note_text_in = internal->orders[d.seq].order_compliance[1].
     information_src, chars_per_line = 90,
     note_string = fillstring(90," "), col_start = 43, prnt_note
    ENDIF
    sutcdatetime = utcdatetime(internal->orders[d.seq].order_compliance[1].last_occured_dt_tm,
     internal->orders[d.seq].order_compliance[1].last_occured_tz,1,"@SHORTDATETIMENOSEC")
    IF (size(trim(sutcdatetime,3),1) > 0)
     col 8, "{B}", "Last Dose Dt Tm: ",
     note_text_in = fillstring(1000," "), note_text_in = sutcdatetime, chars_per_line = 90,
     note_string = fillstring(90," "), col_start = 29, prnt_note
    ENDIF
    IF (size(trim(internal->orders[d.seq].order_compliance[1].compliance_comments,3),1) > 0)
     col 8, "{B}", "Compliance Comments: ",
     note_text_in = fillstring(1000," "), note_text_in = internal->orders[d.seq].order_compliance[1].
     compliance_comments, chars_per_line = 90,
     note_string = fillstring(90," "), col_start = 33, prnt_note
    ENDIF
   ENDIF
  WITH nocounter, maxcol = 500, maxrow = 80,
   dio = postscript
 ;end select
#exit_program
 SET script_version = "MOD 014  01/19/15  AV028265"
END GO
