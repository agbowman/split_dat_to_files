CREATE PROGRAM bhs_rpt_ss_sacrament_of_sick:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE",
  "Email Operations" = 0,
  "Enter Emails" = ""
  WITH outdev, start_date, end_date,
  email_ops, emails
 DECLARE mf_cs_72_endtimespiritualservice = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ENDTIMESPIRITUALSERVICE")), protect
 DECLARE mf_cs_72_starttimespiritualservice = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "STARTTIMESPIRITUALSERVICE")), protect
 DECLARE mf_cs319_mrn = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE mf_cs8_authverified = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_modified = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_altered = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs72_spiritualsacramentalres = f8 WITH constant(uar_get_code_by("DISPLAY",72,
   "Spiritual/Sacramental Resources")), protect
 DECLARE mf_cs72_religiousspiritualpref = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "RELIGIOUSSPIRITUALPREFERENCE")), protect
 DECLARE mf_cs220_bmc_fac = f8 WITH constant(uar_get_code_by("DESCRIPTION",220,
   "BAYSTATE MEDICAL CENTER")), protect
 DECLARE ms_filename = vc WITH noconstant(concat("bhs_sos_rpt_")), protect
 DECLARE ms_output_file = vc WITH noconstant( $OUTDEV), protect
 DECLARE ms_start_date = vc WITH noconstant( $START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $END_DATE), protect
 FREE RECORD frec
 RECORD frec(
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
   1 file_name = vc
   1 file_buf = vc
 )
 IF (( $EMAIL_OPS=0))
  SELECT INTO value(ms_output_file)
   patient_name = substring(1,100,trim(p.name_full_formatted,3)), dob = datebirthformat(p.birth_dt_tm,
    p.birth_tz,p.birth_prec_flag,"mm/dd/yyyy;;Q"), mrn = trim(mrn.alias,3),
   unit = substring(1,100,trim(uar_get_code_display(e.loc_nurse_unit_cd),3)), room_bed = substring(1,
    10,concat(trim(uar_get_code_display(e.loc_room_cd),3),"-",trim(uar_get_code_display(e.loc_bed_cd),
      3))), religious_spiritual_preference = substring(1,50,trim(ce.result_val,3)),
   spiritual_sacramental_resources = substring(1,50,trim(ce1.result_val,3)), start_time = format(
    cnvtdatetime(cnvtdate2(substring(3,8,cest.result_val),"yyyymmdd"),cnvttime2(substring(11,6,cest
       .result_val),"HHMMSS")),"mm/dd/yy hh:mm;;d"), end_time = format(cnvtdatetime(cnvtdate2(
      substring(3,8,ceet.result_val),"yyyymmdd"),cnvttime2(substring(11,6,ceet.result_val),"HHMMSS")),
    "mm/dd/yy hh:mm;;d")
   FROM person p,
    encounter e,
    clinical_event ce,
    clinical_event ce1,
    clinical_event cest,
    clinical_event ceet,
    encntr_alias mrn
   PLAN (ce
    WHERE ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
     AND ce.event_cd=mf_cs72_religiousspiritualpref
     AND ce.view_level=1
     AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
     AND ce.result_status_cd IN (mf_cs8_modified, mf_cs8_altered, mf_cs8_authverified)
     AND trim(cnvtupper(ce.result_val),3) IN ("ROMAN CATHOLIC", "NAT CATHOLIC"))
    JOIN (ce1
    WHERE ce1.encntr_id=ce.encntr_id
     AND ce1.person_id=ce.person_id
     AND ce1.event_cd=mf_cs72_spiritualsacramentalres
     AND ce1.result_status_cd IN (mf_cs8_modified, mf_cs8_altered, mf_cs8_authverified)
     AND ce1.view_level=1
     AND ce1.valid_until_dt_tm >= cnvtdatetime(sysdate)
     AND trim(cnvtupper(ce1.result_val),3)="SACRAMENT OF THE SICK")
    JOIN (cest
    WHERE (cest.encntr_id= Outerjoin(ce.encntr_id))
     AND (cest.person_id= Outerjoin(ce.person_id))
     AND (cest.parent_event_id= Outerjoin(ce.parent_event_id))
     AND cest.event_cd=mf_cs_72_starttimespiritualservice
     AND (((cest.result_status_cd= Outerjoin(mf_cs8_modified)) ) OR ((((cest.result_status_cd=
     Outerjoin(mf_cs8_altered)) ) OR ((cest.result_status_cd= Outerjoin(mf_cs8_authverified)) )) ))
     AND (cest.view_level= Outerjoin(1))
     AND (cest.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (ceet
    WHERE (ceet.encntr_id= Outerjoin(ce.encntr_id))
     AND (ceet.person_id= Outerjoin(ce.person_id))
     AND (ceet.parent_event_id= Outerjoin(ce.parent_event_id))
     AND ceet.event_cd=mf_cs_72_endtimespiritualservice
     AND (((ceet.result_status_cd= Outerjoin(mf_cs8_modified)) ) OR ((((ceet.result_status_cd=
     Outerjoin(mf_cs8_altered)) ) OR ((ceet.result_status_cd= Outerjoin(mf_cs8_authverified)) )) ))
     AND (ceet.view_level= Outerjoin(1))
     AND (ceet.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.person_id=ce.person_id
     AND e.active_status_cd=mf_cs48_active
     AND e.loc_facility_cd=mf_cs220_bmc_fac
     AND e.active_ind=1)
    JOIN (mrn
    WHERE mrn.encntr_id=e.encntr_id
     AND mrn.encntr_alias_type_cd=mf_cs319_mrn
     AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND mrn.active_ind=1
     AND mrn.active_status_cd=mf_cs48_active)
    JOIN (p
    WHERE p.active_ind=1
     AND p.person_id=ce.person_id
     AND p.active_status_cd=mf_cs48_active)
   WITH nocounter, format, separator = " ",
    format(date,";;Q")
  ;end select
 ELSE
  EXECUTE bhs_sys_stand_subroutine
  SET ms_output_file = build(trim(ms_filename,3),format(sysdate,"MMDDYYYY;;q"),".csv")
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "MM/DD/YYYY;;D")
  SET ms_start_date = format(cnvtdatetime(cnvtdate2(ms_start_date,"MM/DD/YYYY"),0),";;Q")
  SET ms_end_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","E","E"),
   "MM/DD/YYYY;;D")
  SET ms_end_date = format(cnvtdatetime(cnvtdate2(ms_end_date,"MM/DD/YYYY"),235959),";;Q")
  SET frec->file_name = ms_output_file
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Patient Name",','"DOB",','"MRN",','"Unit",','"Room-Bed",',
   '"Religious/Spiritual Preference",','"Spiritual/Sacramental Resources",','"Start Time",',
   '"End Time"',char(13))
  SELECT INTO "NL:"
   FROM person p,
    encounter e,
    clinical_event ce,
    clinical_event ce1,
    clinical_event cest,
    clinical_event ceet,
    encntr_alias mrn
   PLAN (ce
    WHERE ce.event_end_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
     AND ce.event_cd=mf_cs72_religiousspiritualpref
     AND ce.view_level=1
     AND ce.valid_until_dt_tm >= cnvtdatetime(sysdate)
     AND ce.result_status_cd IN (mf_cs8_modified, mf_cs8_altered, mf_cs8_authverified)
     AND trim(cnvtupper(ce.result_val),3) IN ("ROMAN CATHOLIC", "NAT CATHOLIC"))
    JOIN (ce1
    WHERE ce1.encntr_id=ce.encntr_id
     AND ce1.person_id=ce.person_id
     AND ce1.event_cd=mf_cs72_spiritualsacramentalres
     AND ce1.result_status_cd IN (mf_cs8_modified, mf_cs8_altered, mf_cs8_authverified)
     AND ce1.view_level=1
     AND ce1.valid_until_dt_tm >= cnvtdatetime(sysdate)
     AND trim(cnvtupper(ce1.result_val),3)="SACRAMENT OF THE SICK")
    JOIN (cest
    WHERE (cest.encntr_id= Outerjoin(ce.encntr_id))
     AND (cest.person_id= Outerjoin(ce.person_id))
     AND (cest.parent_event_id= Outerjoin(ce.parent_event_id))
     AND cest.event_cd=mf_cs_72_starttimespiritualservice
     AND (((cest.result_status_cd= Outerjoin(mf_cs8_modified)) ) OR ((((cest.result_status_cd=
     Outerjoin(mf_cs8_altered)) ) OR ((cest.result_status_cd= Outerjoin(mf_cs8_authverified)) )) ))
     AND (cest.view_level= Outerjoin(1))
     AND (cest.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (ceet
    WHERE (ceet.encntr_id= Outerjoin(ce.encntr_id))
     AND (ceet.person_id= Outerjoin(ce.person_id))
     AND (ceet.parent_event_id= Outerjoin(ce.parent_event_id))
     AND ceet.event_cd=mf_cs_72_endtimespiritualservice
     AND (((ceet.result_status_cd= Outerjoin(mf_cs8_modified)) ) OR ((((ceet.result_status_cd=
     Outerjoin(mf_cs8_altered)) ) OR ((ceet.result_status_cd= Outerjoin(mf_cs8_authverified)) )) ))
     AND (ceet.view_level= Outerjoin(1))
     AND (ceet.valid_until_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
    JOIN (e
    WHERE e.encntr_id=ce.encntr_id
     AND e.person_id=ce.person_id
     AND e.active_status_cd=mf_cs48_active
     AND e.loc_facility_cd=mf_cs220_bmc_fac
     AND e.active_ind=1)
    JOIN (mrn
    WHERE mrn.encntr_id=e.encntr_id
     AND mrn.encntr_alias_type_cd=mf_cs319_mrn
     AND mrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND mrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
     AND mrn.active_ind=1
     AND mrn.active_status_cd=mf_cs48_active)
    JOIN (p
    WHERE p.active_ind=1
     AND p.person_id=ce.person_id
     AND p.active_status_cd=mf_cs48_active)
   HEAD REPORT
    null
   DETAIL
    frec->file_buf = build(frec->file_buf,'"',trim(p.name_full_formatted,3),'","',datebirthformat(p
      .birth_dt_tm,p.birth_tz,p.birth_prec_flag,"mm/dd/yyyy;;Q"),
     '","',trim(mrn.alias,3),'","',trim(uar_get_code_display(e.loc_nurse_unit_cd),3),'","',
     concat(trim(uar_get_code_display(e.loc_room_cd),3),"-",trim(uar_get_code_display(e.loc_bed_cd),3
       )),'","',trim(ce.result_val,3),'","',trim(ce1.result_val,3),
     '","',format(cnvtdatetime(cnvtdate2(substring(3,8,cest.result_val),"yyyymmdd"),cnvttime2(
        substring(11,6,cest.result_val),"HHMMSS")),"mm/dd/yy hh:mm;;d"),'","',format(cnvtdatetime(
       cnvtdate2(substring(3,8,ceet.result_val),"yyyymmdd"),cnvttime2(substring(11,6,ceet.result_val),
        "HHMMSS")),"mm/dd/yy hh:mm;;d"),'"',
     char(13))
   WITH nocounter
  ;end select
  SET stat = cclio("WRITE",frec)
  SET stat = cclio("CLOSE",frec)
  IF (curqual > 0)
   CALL emailfile(ms_output_file,ms_output_file, $EMAILS,concat("Sacrament of the Sick Report ",trim(
      format(sysdate,"mm-dd-yy hh:mm;;d"))),1)
  ELSE
   CALL emailfile(ms_output_file,ms_output_file, $EMAILS,"Sacrament of the Sick Report No Data Found",
    1)
  ENDIF
 ENDIF
END GO
