CREATE PROGRAM bhs_rpt_ppu_infusion_react:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, start_date, end_date
 FREE RECORD drec
 RECORD drec(
   1 line_cnt = i4
   1 display_line = vc
   1 line_qual[*]
     2 disp_line = vc
 )
 FREE RECORD blob
 RECORD blob(
   1 person_id = f8
   1 cntblob = i4
   1 list[*]
     2 encntr_id = f8
     2 fin = vc
     2 mrn = vc
     2 person_id = f8
     2 event_cd = f8
     2 display_event_cd = vc
     2 result_status_cd = f8
     2 result_dt = vc
     2 unit = vc
     2 discharge_dt = vc
     2 dob = vc
     2 parent_event_id = f8
     2 event_id = f8
     2 title = vc
 )
 DECLARE mf_cs72_progressnotehospital = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "PROGRESSNOTEHOSPITAL")), protect
 DECLARE mf_cs29520_powernote = f8 WITH constant(uar_get_code_by("DISPLAYKEY",29520,"POWERNOTE")),
 protect
 DECLARE mf_cs220_ppu = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"MEDICALSTAYPPU")), protect
 DECLARE mf_cs48_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 SELECT INTO "NL:"
  FROM encounter e,
   clinical_event ce,
   encntr_alias mrn,
   encntr_alias fin
  PLAN (e
   WHERE e.loc_nurse_unit_cd=mf_cs220_ppu
    AND e.active_status_cd=188
    AND e.active_ind=1
    AND e.disch_dt_tm BETWEEN cnvtdatetime( $START_DATE) AND cnvtdatetime( $END_DATE))
   JOIN (ce
   WHERE ce.event_cd IN (mf_cs72_progressnotehospital)
    AND ce.encntr_id=e.encntr_id
    AND ce.person_id=e.person_id
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND ce.entry_mode_cd=mf_cs29520_powernote
    AND cnvtupper(ce.event_title_text)="*INFUSION REACTION - DOCUMENTATION*")
   JOIN (mrn
   WHERE mrn.encntr_id=e.encntr_id
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND mrn.end_effective_dt_tm > sysdate
    AND mrn.active_status_cd=mf_cs48_active_cd
    AND mrn.active_ind=1)
   JOIN (fin
   WHERE fin.encntr_id=e.encntr_id
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND fin.end_effective_dt_tm > sysdate
    AND fin.active_status_cd=mf_cs48_active_cd
    AND fin.active_ind=1)
  ORDER BY e.encntr_id, ce.event_id
  HEAD REPORT
   stat = alterlist(blob->list,10)
  HEAD e.encntr_id
   blob->cntblob += 1
   IF (mod(blob->cntblob,10)=1
    AND (blob->cntblob > 1))
    stat = alterlist(blob->list,(blob->cntblob+ 9))
   ENDIF
   blob->list[blob->cntblob].encntr_id = e.encntr_id, blob->list[blob->cntblob].unit = trim(
    uar_get_code_display(e.loc_nurse_unit_cd),3), blob->list[blob->cntblob].mrn = trim(mrn.alias,3),
   blob->list[blob->cntblob].fin = trim(fin.alias,3), blob->list[blob->cntblob].discharge_dt = format
   (e.disch_dt_tm,"@SHORTDATETIMENOSEC"), blob->list[blob->cntblob].title = trim(ce.event_title_text,
    3)
  HEAD ce.event_id
   blob->list[blob->cntblob].event_id = ce.event_id, blob->list[blob->cntblob].display_event_cd =
   trim(uar_get_code_display(ce.event_cd),3)
  FOOT REPORT
   stat = alterlist(blob->list,blob->cntblob)
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  fin = substring(1,30,blob->list[d1.seq].fin), mrn = substring(1,30,blob->list[d1.seq].mrn), unit =
  substring(1,30,blob->list[d1.seq].unit),
  discharge_dt = substring(1,30,blob->list[d1.seq].discharge_dt), note_name = substring(1,200,blob->
   list[d1.seq].display_event_cd), note_title = substring(1,200,blob->list[d1.seq].title)
  FROM (dummyt d1  WITH seq = size(blob->list,5))
  PLAN (d1)
  WITH nocounter, separator = " ", format
 ;end select
END GO
