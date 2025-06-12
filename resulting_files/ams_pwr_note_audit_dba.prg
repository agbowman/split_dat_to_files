CREATE PROGRAM ams_pwr_note_audit:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, sdate, edate
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET exe_error = 10
 SET failed = false
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 DECLARE cnt = i4 WITH protect
 DECLARE powernoteed_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,"POWERNOTEED")),
 protect
 DECLARE powernote_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,"POWERNOTE")), protect
 DECLARE powernotemodifiers_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,
   "POWERNOTEMODIFIERS")), protect
 DECLARE finnbr_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 FREE RECORD power_list
 RECORD power_list(
   1 qual[*]
     2 note_title = vc
     2 note_type = vc
     2 save_forward = vc
     2 date_time = vc
     2 patient_name = vc
     2 fin = vc
     2 mrn = vc
     2 personel_name = vc
     2 signed_name = vc
     2 scd_id = f8
 )
 SELECT
  ce.event_tag, ce_event_disp = uar_get_code_display(ce.event_cd)
  FROM scd_story ss,
   clinical_event ce,
   person p,
   prsnl pr,
   prsnl pr1,
   encntr_alias ea
  PLAN (ss
   WHERE ss.active_status_dt_tm BETWEEN cnvtdatetime(cnvtdate( $SDATE),0) AND cnvtdatetime(cnvtdate(
      $EDATE),235959)
    AND ss.entry_mode_cd IN (powernoteed_var, powernote_var, powernotemodifiers_var)
    AND ss.active_ind=1)
   JOIN (ce
   WHERE ce.event_id=outerjoin(ss.event_id)
    AND ce.valid_until_dt_tm=outerjoin(cnvtdatetime("31-DEC-2100 000000")))
   JOIN (p
   WHERE p.person_id=ss.person_id)
   JOIN (pr
   WHERE pr.person_id=outerjoin(ce.verified_prsnl_id))
   JOIN (pr1
   WHERE pr1.person_id=outerjoin(ss.author_id))
   JOIN (ea
   WHERE ea.encntr_id=ss.encounter_id
    AND ea.encntr_alias_type_cd IN (mrn_var, finnbr_var))
  ORDER BY ss.scd_story_id, p.person_id
  HEAD ss.scd_story_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(power_list->qual,(cnt+ 9))
   ENDIF
   power_list->qual[cnt].scd_id = ss.scd_story_id, power_list->qual[cnt].note_title = ss.title,
   power_list->qual[cnt].note_type = ce_event_disp
   IF (ss.update_lock_dt_tm != null)
    power_list->qual[cnt].save_forward = "Auto Saved"
   ELSEIF (ce.verified_dt_tm != null)
    power_list->qual[cnt].save_forward = "Signed"
   ELSE
    power_list->qual[cnt].save_forward = "Saved"
   ENDIF
   power_list->qual[cnt].date_time = format(ss.active_status_dt_tm,";;q"), power_list->qual[cnt].
   patient_name = trim(p.name_full_formatted), power_list->qual[cnt].personel_name = trim(pr1
    .name_full_formatted),
   power_list->qual[cnt].signed_name = trim(pr.name_full_formatted)
  DETAIL
   CALL echo(ea.encntr_alias_type_cd)
   IF (ea.encntr_alias_type_cd=477.00)
    CALL echo("Fin"), power_list->qual[cnt].fin = ea.alias
   ELSEIF (ea.encntr_alias_type_cd=122479)
    power_list->qual[cnt].mrn = ea.alias
   ENDIF
  FOOT REPORT
   stat = alterlist(power_list->qual,cnt)
  WITH nocounter, format = " "
 ;end select
 CALL echorecord(power_list)
 SELECT INTO  $1
  patient_name = substring(1,30,power_list->qual[d1.seq].patient_name), mrn = substring(1,30,
   power_list->qual[d1.seq].mrn), fin = substring(1,30,power_list->qual[d1.seq].fin),
  note_title = substring(1,30,power_list->qual[d1.seq].note_title), note_type = substring(1,30,
   power_list->qual[d1.seq].note_type), date_time = substring(1,30,power_list->qual[d1.seq].date_time
   ),
  save_forward = substring(1,30,power_list->qual[d1.seq].save_forward), creater_name = substring(1,30,
   power_list->qual[d1.seq].personel_name), signed_name = substring(1,30,power_list->qual[d1.seq].
   signed_name)
  FROM (dummyt d1  WITH seq = value(size(power_list->qual,5)))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
 CALL updtdminfo(trim(cnvtupper(curprog),3))
#exit_script
 IF (failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 SET last_mode = " 29/03/2015 kk032244 Initial Release"
END GO
