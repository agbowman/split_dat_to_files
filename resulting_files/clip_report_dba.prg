CREATE PROGRAM clip_report:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Appointment Start Date" = "",
  "Appointment End Date" = "",
  "Facility" = 0,
  "Ambulatory Location" = 0,
  "Provider" = 0
  WITH outdev, beg_date, end_date,
  facility, nu_amb, provider
 FREE RECORD locations
 RECORD locations(
   1 child_locations[*]
     2 location_cd = f8
 )
 FREE RECORD report_data
 RECORD report_data(
   1 appointments[*]
     2 sch_event_id = f8
     2 date = dq8
     2 location = vc
     2 location_cd = f8
     2 time = vc
     2 name = vc
     2 sex = vc
     2 dob = vc
     2 mrn = vc
     2 appt_type = vc
     2 resources = vc
     2 portal = vc
     2 eclipboard_created = vc
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
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
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE fac_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE bldg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE nu_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE amb_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"AMBULATORY"))
 DECLARE room_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"ROOM"))
 DECLARE bed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BED"))
 DECLARE messaging_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MESSAGING"))
 DECLARE encounter_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE person_alias_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE sch_appt_patient_role_meaning = vc WITH protect, constant("PATIENT")
 DECLARE g_failure = c1 WITH public, noconstant("F")
 DECLARE validate_code_values(null) = i2
 DECLARE get_fac_to_nu_hierarchy(null) = null
 DECLARE get_nu_to_bed_hierarchy(null) = null
 DECLARE populate_report_data(null) = null
 IF (validate_code_values(null)=false)
  GO TO exit_script
 ENDIF
 SUBROUTINE validate_code_values(null)
   IF (fac_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for fac_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (bldg_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for bldg_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (nu_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for nu_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (amb_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for amb_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (room_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for room_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (bed_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for bed_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (messaging_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for messaging_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (encounter_mrn_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for encounter_mrn_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (person_alias_mrn_cd <= 0.0)
    SET g_failure = "T"
    IF (validate(debug_ind,0)=1)
     CALL echo("Code value lookup for person_alias_mrn_cd failed.")
    ENDIF
    RETURN(false)
   ENDIF
   IF (validate(debug_ind,0)=1)
    CALL echo("Code values were successfuly.")
   ENDIF
   RETURN(true)
 END ;Subroutine
 SUBROUTINE get_fac_to_nu_hierarchy(null)
   DECLARE child_cnt = i4 WITH protect, noconstant(size(locations->child_locations,5))
   DECLARE loop_cnt = i4 WITH protect, noconstant(0)
   SET child_cnt += 1
   SET stat = alterlist(locations->child_locations,child_cnt)
   SET locations->child_locations[1].location_cd = cnvtreal( $FACILITY)
   SELECT INTO "nl:"
    FROM location_group lg,
     location l
    PLAN (lg
     WHERE expand(loop_cnt,1,child_cnt,lg.parent_loc_cd,locations->child_locations[loop_cnt].
      location_cd)
      AND lg.location_group_type_cd=fac_cd)
     JOIN (l
     WHERE lg.child_loc_cd=l.location_cd
      AND l.location_type_cd=bldg_cd)
    ORDER BY lg.child_loc_cd
    HEAD lg.child_loc_cd
     child_cnt += 1, stat = alterlist(locations->child_locations,child_cnt), locations->
     child_locations[child_cnt].location_cd = lg.child_loc_cd
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "nl:"
    FROM location_group lg,
     location l
    PLAN (lg
     WHERE expand(loop_cnt,1,child_cnt,lg.parent_loc_cd,locations->child_locations[loop_cnt].
      location_cd)
      AND lg.location_group_type_cd=bldg_cd)
     JOIN (l
     WHERE lg.child_loc_cd=l.location_cd
      AND l.location_type_cd IN (nu_cd, amb_cd))
    ORDER BY lg.child_loc_cd
    HEAD lg.child_loc_cd
     child_cnt += 1, stat = alterlist(locations->child_locations,child_cnt), locations->
     child_locations[child_cnt].location_cd = lg.child_loc_cd
    WITH nocounter, expand = 1
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(locations)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_nu_to_bed_hierarchy(null)
   DECLARE child_cnt = i4 WITH protect, noconstant(size(locations->child_locations,5))
   DECLARE loop_cnt = i4 WITH protect, noconstant(0)
   IF (cnvtreal( $NU_AMB) > 0.0)
    SET child_cnt += 1
    SET stat = alterlist(locations->child_locations,child_cnt)
    SET locations->child_locations[child_cnt].location_cd = cnvtreal( $NU_AMB)
   ENDIF
   SELECT INTO "nl:"
    FROM location_group lg,
     location l
    PLAN (lg
     WHERE expand(loop_cnt,1,child_cnt,lg.parent_loc_cd,locations->child_locations[loop_cnt].
      location_cd)
      AND lg.location_group_type_cd=nu_cd)
     JOIN (l
     WHERE lg.child_loc_cd=l.location_cd
      AND l.location_type_cd=room_cd)
    ORDER BY lg.child_loc_cd
    HEAD lg.child_loc_cd
     child_cnt += 1, stat = alterlist(locations->child_locations,child_cnt), locations->
     child_locations[child_cnt].location_cd = lg.child_loc_cd
    WITH nocounter, expand = 1
   ;end select
   SELECT INTO "nl:"
    FROM location_group lg,
     location l
    PLAN (lg
     WHERE expand(loop_cnt,1,child_cnt,lg.parent_loc_cd,locations->child_locations[loop_cnt].
      location_cd)
      AND lg.location_group_type_cd=room_cd)
     JOIN (l
     WHERE lg.child_loc_cd=l.location_cd
      AND l.location_type_cd=bed_cd)
    ORDER BY lg.child_loc_cd
    HEAD lg.child_loc_cd
     child_cnt += 1, stat = alterlist(locations->child_locations,child_cnt), locations->
     child_locations[child_cnt].location_cd = lg.child_loc_cd
    WITH nocounter, expand = 1
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(locations)
   ENDIF
 END ;Subroutine
 SUBROUTINE populate_report_data(null)
   DECLARE expand_index = i4 WITH protect, noconstant(0)
   DECLARE report_loop_index = i4 WITH protect, noconstant(0)
   SET snoclipcreated = uar_i18ngetmessage(i18nhandle,"no","No")
   SET sactive = uar_i18ngetmessage(i18nhandle,"active","Active")
   SET snone = uar_i18ngetmessage(i18nhandle,"none","None")
   SELECT INTO "nl:"
    nullind_ea_alias = nullind(ea.alias)
    FROM sch_appt sa_patient,
     sch_appt sa_resource,
     sch_event se,
     encntr_alias ea,
     person p,
     prsnl pl,
     person_alias pa_mrn,
     person_alias pa_messaging,
     dms_media_xref dmx
    PLAN (sa_patient
     WHERE sa_patient.active_ind=1
      AND sa_patient.beg_dt_tm BETWEEN cnvtdatetime( $BEG_DATE) AND cnvtdatetime(concat( $END_DATE,
       " 23:59:59"))
      AND expand(expand_index,1,size(locations->child_locations,5),sa_patient.appt_location_cd,
      locations->child_locations[expand_index].location_cd)
      AND sa_patient.role_meaning=sch_appt_patient_role_meaning
      AND sa_patient.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
      AND sa_patient.state_meaning IN ("CONFIRMED", "SCHEDULED", "CHECKED IN"))
     JOIN (sa_resource
     WHERE sa_resource.sch_event_id=sa_patient.sch_event_id
      AND sa_resource.role_meaning != sch_appt_patient_role_meaning
      AND sa_resource.person_id > 0.0
      AND sa_resource.active_ind=1)
     JOIN (se
     WHERE se.sch_event_id=sa_patient.sch_event_id
      AND (se.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (se.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
      AND se.active_ind=1
      AND se.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (p
     WHERE p.person_id=sa_patient.person_id
      AND p.active_ind=1)
     JOIN (pl
     WHERE pl.person_id=sa_resource.person_id
      AND trim(pl.name_full_formatted) != ""
      AND pl.active_ind=1)
     JOIN (pa_messaging
     WHERE (pa_messaging.person_id= Outerjoin(sa_patient.person_id))
      AND (pa_messaging.person_alias_type_cd= Outerjoin(messaging_cd))
      AND (pa_messaging.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (pa_messaging.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
      AND (pa_messaging.active_ind= Outerjoin(1)) )
     JOIN (ea
     WHERE (ea.encntr_id= Outerjoin(sa_patient.encntr_id))
      AND (ea.encntr_alias_type_cd= Outerjoin(encounter_mrn_cd))
      AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (ea.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
      AND (ea.active_ind= Outerjoin(1)) )
     JOIN (pa_mrn
     WHERE (pa_mrn.person_id= Outerjoin(sa_patient.person_id))
      AND (pa_mrn.person_alias_type_cd= Outerjoin(person_alias_mrn_cd))
      AND (pa_mrn.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (pa_mrn.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
      AND (pa_mrn.active_ind= Outerjoin(1)) )
     JOIN (dmx
     WHERE (dmx.parent_entity_id= Outerjoin(sa_patient.sch_event_id))
      AND (dmx.parent_entity_name= Outerjoin("SCH_EVENT")) )
    ORDER BY sa_patient.beg_dt_tm, dmx.updt_dt_tm DESC, ea.updt_dt_tm DESC
    HEAD REPORT
     report_loop_index = 0
    HEAD sa_patient.sch_appt_id
     report_loop_index += 1
     IF (mod(report_loop_index,5)=1)
      stat = alterlist(report_data->appointments,(report_loop_index+ 4))
     ENDIF
     report_data->appointments[report_loop_index].sch_event_id = sa_patient.sch_event_id, report_data
     ->appointments[report_loop_index].date = sa_patient.beg_dt_tm, report_data->appointments[
     report_loop_index].location = uar_get_code_display(sa_patient.appt_location_cd),
     report_data->appointments[report_loop_index].location_cd = sa_patient.appt_location_cd,
     report_data->appointments[report_loop_index].time = format(sa_patient.beg_dt_tm,"HH:MM;;S"),
     report_data->appointments[report_loop_index].appt_type = uar_get_code_display(se.appt_type_cd),
     report_data->appointments[report_loop_index].name = p.name_full_formatted, report_data->
     appointments[report_loop_index].sex = uar_get_code_display(p.sex_cd), report_data->appointments[
     report_loop_index].dob = datebirthformat(p.birth_dt_tm,p.birth_tz,p.birth_prec_flag,"MM/DD/YYYY"
      )
     IF (nullind_ea_alias=1)
      report_data->appointments[report_loop_index].mrn = pa_mrn.alias
     ELSE
      report_data->appointments[report_loop_index].mrn = ea.alias
     ENDIF
     IF (pa_messaging.person_alias_type_cd > 0)
      report_data->appointments[report_loop_index].portal = sactive
     ELSE
      report_data->appointments[report_loop_index].portal = snone
     ENDIF
     IF (dmx.parent_entity_id > 0)
      report_data->appointments[report_loop_index].eclipboard_created = format(dmx.updt_dt_tm,
       "MM/DD/YYYY;;D")
     ELSE
      report_data->appointments[report_loop_index].eclipboard_created = snoclipcreated
     ENDIF
     IF (size(trim(report_data->appointments[report_loop_index].resources),5) > 0)
      report_data->appointments[report_loop_index].resources = concat(report_data->appointments[
       report_loop_index].resources,"; ",pl.name_full_formatted)
     ELSE
      report_data->appointments[report_loop_index].resources = pl.name_full_formatted
     ENDIF
    FOOT REPORT
     CALL alterlist(report_data->appointments,report_loop_index)
    WITH nocounter, separator = " ", format,
     expand = 1
   ;end select
   IF (validate(debug_ind,0)=1)
    CALL echorecord(report_data)
   ENDIF
 END ;Subroutine
 IF (cnvtreal( $FACILITY)
  AND cnvtreal( $NU_AMB)=0.0)
  CALL get_fac_to_nu_hierarchy(null)
 ENDIF
 CALL get_nu_to_bed_hierarchy(null)
 CALL populate_report_data(null)
 SELECT
  IF (( $PROVIDER > 0.0))
   FROM (dummyt d1  WITH seq = value(size(report_data->appointments,5))),
    sch_appt sa_prsnl
   PLAN (d1)
    JOIN (sa_prsnl
    WHERE (report_data->appointments[d1.seq].sch_event_id=sa_prsnl.sch_event_id)
     AND sa_prsnl.role_meaning != sch_appt_patient_role_meaning
     AND (sa_prsnl.person_id= $PROVIDER)
     AND sa_prsnl.state_meaning IN ("CONFIRMED", "SCHEDULED", "CHECKED IN"))
  ELSE
   FROM (dummyt d1  WITH seq = value(size(report_data->appointments,5)))
  ENDIF
  INTO  $OUTDEV
  appt_date = format(report_data->appointments[d1.seq].date,"MM/DD/YYYY;;D"), appt_time = substring(1,
   999,report_data->appointments[d1.seq].time), location = substring(1,999,report_data->appointments[
   d1.seq].location),
  name = substring(1,999,report_data->appointments[d1.seq].name), sex = substring(1,999,report_data->
   appointments[d1.seq].sex), dob = substring(1,999,report_data->appointments[d1.seq].dob),
  mrn = substring(1,999,report_data->appointments[d1.seq].mrn), appt_type = substring(1,999,
   report_data->appointments[d1.seq].appt_type), resources = substring(1,999,report_data->
   appointments[d1.seq].resources),
  portal = substring(1,999,report_data->appointments[d1.seq].portal), eclipboard_submitted =
  substring(1,999,report_data->appointments[d1.seq].eclipboard_created)
  WITH nocounter, separator = " ", format
 ;end select
#exit_script
 IF (g_failure="T")
  SET reply->status_data.status = "F"
 ELSEIF (g_failure="Z")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
