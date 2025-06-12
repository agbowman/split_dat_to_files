CREATE PROGRAM bhs_rpt_hemorrage_report
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Start Date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, s_start_date, s_end_date
 DECLARE mf_cs72_attendingprovider_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ATTENDINGPROVIDER")), protect
 DECLARE mf_cs72_deliverycnm_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"DELIVERYCNM")),
 protect
 DECLARE mf_cs72_deliverycomplications_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DELIVERYCOMPLICATIONS")), protect
 DECLARE mf_cs72_bloodlossquantitative_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODLOSSQUANTITATIVE")), protect
 DECLARE mf_cs72_bloodloss_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BLOODLOSS")),
 protect
 DECLARE mf_cs72_deliveryphysician_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DELIVERYPHYSICIAN")), protect
 DECLARE mf_cs48_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mc_date_time_of_birth = vc WITH constant("CERNER!ASYr9AEYvUr1YoPTCqIGfQ"), protect
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE mf_date_time_of_birth_cd = f8 WITH noconstant(0.0), protect
 DECLARE ml_diagcnt = i4 WITH noconstant(0), protect
 DECLARE ml_attloc = i4 WITH noconstant(0), protect
 DECLARE ml_num = i4 WITH noconstant(0), protect
 DECLARE ml_loc = i4 WITH noconstant(0), protect
 DECLARE ml_idx1 = i4 WITH noconstant(0), protect
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD pat
 RECORD pat(
   1 cnt_preg = i4
   1 hem[*]
     2 pat_name = vc
     2 mrn = vc
     2 dob = vc
     2 del_type = vc
     2 qual_factor = vc
     2 attending = vc
     2 delivery_physician = vc
     2 delivery_cnm = vc
     2 delivery_comp = vc
     2 personid = f8
     2 encntr_id = f8
     2 momperson_id = f8
     2 momencntr_id = f8
     2 child_encntr = f8
     2 child_person_id = f8
     2 total_blood_loss = f8
     2 total_quan_blood = f8
     2 total_blood_combined = f8
     2 preg_instance = f8
     2 diagnosis = vc
 )
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=72
    AND cv.concept_cki IN (mc_date_time_of_birth))
  ORDER BY cv.code_value
  DETAIL
   CASE (cv.concept_cki)
    OF mc_date_time_of_birth:
     mf_date_time_of_birth_cd = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF (( $OUTDEV="OPS"))
  SET ms_start_date = format(datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,0)),"M","B","B"),
   "DD-MMM-YYYY 00:00:00;;Q")
  SET ms_end_date = format(datetimefind(cnvtdatetime(curdate,0),"M","B","B"),
   "DD-MMM-YYYY 00:00:00;;Q")
 ENDIF
 CALL echo(build("end = ",ms_end_date,"Start = ",ms_start_date))
 SELECT INTO "nl:"
  FROM pregnancy_instance pi,
   pregnancy_child pc,
   clinical_event ce,
   ce_date_result cdr,
   clinical_event cebl,
   encntr_alias mommrn,
   person mom,
   diagnosis d
  PLAN (pc
   WHERE pc.active_ind=1
    AND pc.delivery_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date)
    AND pc.delivery_dt_tm != null)
   JOIN (pi
   WHERE pi.pregnancy_id=pc.pregnancy_id
    AND pi.pregnancy_id != 0
    AND pi.pregnancy_instance_id=pc.pregnancy_instance_id
    AND pi.historical_ind=0
    AND pi.active_ind=1
    AND pi.end_effective_dt_tm > sysdate)
   JOIN (ce
   WHERE ce.person_id=pi.person_id
    AND ce.event_cd=mf_date_time_of_birth_cd
    AND ce.valid_until_dt_tm > sysdate
    AND ce.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd))
   JOIN (cdr
   WHERE cdr.event_id=ce.event_id
    AND cdr.result_dt_tm BETWEEN cnvtdatetime(ms_start_date) AND cnvtdatetime(ms_end_date))
   JOIN (cebl
   WHERE cebl.person_id=ce.person_id
    AND cebl.encntr_id=ce.encntr_id
    AND cebl.result_status_cd IN (mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_auth_cd,
   mf_cs8_active_cd)
    AND cebl.valid_until_dt_tm > sysdate
    AND cebl.view_level=1
    AND cebl.event_cd IN (mf_cs72_bloodlossquantitative_cd, mf_cs72_deliveryphysician_cd,
   mf_cs72_attendingprovider_cd, mf_cs72_bloodloss_cd, mf_cs72_deliverycomplications_cd,
   mf_cs72_deliverycnm_cd))
   JOIN (mommrn
   WHERE mommrn.encntr_id=cebl.encntr_id
    AND mommrn.active_status_cd=mf_cs48_active_cd
    AND mommrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND mommrn.end_effective_dt_tm >= cnvtdatetime(sysdate)
    AND mommrn.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND mommrn.active_ind=1)
   JOIN (mom
   WHERE mom.person_id=cebl.person_id
    AND mom.active_status_cd=mf_cs48_active_cd
    AND mom.active_ind=1)
   JOIN (d
   WHERE (d.active_ind= Outerjoin(1))
    AND (d.encntr_id= Outerjoin(ce.encntr_id))
    AND (cnvtupper(d.diagnosis_display)= Outerjoin("POSTPARTUM HEMORRHAGE*")) )
  ORDER BY pi.pregnancy_instance_id, cebl.encntr_id, cebl.event_cd,
   cebl.event_id, d.diagnosis_id
  HEAD REPORT
   null, stat = alterlist(pat->hem,10)
  HEAD pi.pregnancy_instance_id
   pat->cnt_preg += 1
   IF (mod(pat->cnt_preg,10)=1
    AND (pat->cnt_preg > 1))
    stat = alterlist(pat->hem,(pat->cnt_preg+ 9))
   ENDIF
   pat->hem[pat->cnt_preg].pat_name = trim(mom.name_full_formatted,3), pat->hem[pat->cnt_preg].mrn =
   trim(mommrn.alias,3), pat->hem[pat->cnt_preg].dob = trim(format(cdr.result_dt_tm,
     "mm/dd/yyyy hh:mm;;d"),3),
   pat->hem[pat->cnt_preg].del_type = trim(uar_get_code_display(pc.delivery_method_cd),3), pat->hem[
   pat->cnt_preg].encntr_id = ce.encntr_id, pat->hem[pat->cnt_preg].preg_instance = pi
   .pregnancy_instance_id,
   pat->hem[pat->cnt_preg].personid = ce.person_id, ml_diagcnt = 0
  HEAD cebl.encntr_id
   null
  HEAD cebl.event_cd
   CASE (cebl.event_cd)
    OF mf_cs72_attendingprovider_cd:
     IF ((pat->hem[pat->cnt_preg].attending=null))
      pat->hem[pat->cnt_preg].attending = trim(cebl.result_val,3)
     ENDIF
    OF mf_cs72_deliveryphysician_cd:
     IF ((pat->hem[pat->cnt_preg].delivery_physician=null))
      pat->hem[pat->cnt_preg].delivery_physician = trim(cebl.result_val,3)
     ENDIF
    OF mf_cs72_deliverycnm_cd:
     pat->hem[pat->cnt_preg].delivery_cnm = trim(cebl.result_val,3)
   ENDCASE
  HEAD cebl.event_id
   CASE (cebl.event_cd)
    OF mf_cs72_bloodloss_cd:
     pat->hem[pat->cnt_preg].total_blood_loss = (cnvtreal(cebl.result_val)+ pat->hem[pat->cnt_preg].
     total_blood_loss),pat->hem[pat->cnt_preg].total_blood_combined = (cnvtreal(cebl.result_val)+ pat
     ->hem[pat->cnt_preg].total_blood_combined)
    OF mf_cs72_bloodlossquantitative_cd:
     pat->hem[pat->cnt_preg].total_quan_blood = (cnvtreal(cebl.result_val)+ pat->hem[pat->cnt_preg].
     total_quan_blood),pat->hem[pat->cnt_preg].total_blood_combined = (cnvtreal(cebl.result_val)+ pat
     ->hem[pat->cnt_preg].total_blood_combined)
    OF mf_cs72_attendingprovider_cd:
     pat->hem[pat->cnt_preg].attending = trim(cebl.result_val,3)
    OF mf_cs72_deliverycomplications_cd:
     pat->hem[pat->cnt_preg].delivery_comp = trim(cebl.result_val,3)
   ENDCASE
  HEAD d.diagnosis_id
   pat->hem[pat->cnt_preg].diagnosis = trim(d.diagnosis_display,3)
  FOOT  cebl.encntr_id
   ml_diagcnt = 0
  FOOT  pi.pregnancy_instance_id
   null
  FOOT REPORT
   stat = alterlist(pat->hem,pat->cnt_preg)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM surgical_case sc,
   surg_case_procedure scp,
   prsnl delprov
  PLAN (sc
   WHERE expand(ml_num,1,size(pat->hem,5),sc.encntr_id,pat->hem[ml_num].encntr_id)
    AND sc.active_ind=1
    AND sc.cancel_dt_tm=null)
   JOIN (scp
   WHERE scp.surg_case_id=sc.surg_case_id
    AND scp.active_ind=1
    AND scp.primary_proc_ind=1)
   JOIN (delprov
   WHERE delprov.person_id=scp.primary_surgeon_id)
  ORDER BY sc.encntr_id
  HEAD sc.encntr_id
   ml_alloc = 0, ml_alloc = locateval(ml_loc,1,size(pat->hem,5),sc.encntr_id,pat->hem[ml_loc].
    encntr_id)
   IF (ml_alloc != 0
    AND (pat->hem[ml_alloc].delivery_physician=null))
    pat->hem[ml_alloc].delivery_physician = trim(delprov.name_full_formatted,3)
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 IF (( $OUTDEV="OPS"))
  SET frec->file_name = concat("bhs_postpartum_hemorrhage_",format(sysdate,"MMDDYYYY;;q"),".csv")
  SET frec->file_buf = "w"
  SET stat = cclio("OPEN",frec)
  SET frec->file_buf = build('"Patient Name",','"MRN",','"D0B",','"Delivery Type",','"Attending",',
   '"Delivery Physician",','"Delivery CNM",','"Blood Loss",','"Quantitative Blood",',
   '"Blood_loss Combined",',
   '"Diagnosis",','"Delivery Complication",',char(13))
  SELECT INTO "NL:"
   FROM (dummyt d1  WITH seq = size(pat->hem,5))
   PLAN (d1
    WHERE (((pat->hem[d1.seq].total_blood_loss > 1000)) OR ((((pat->hem[d1.seq].total_quan_blood >
    1000)) OR ((((pat->hem[d1.seq].total_blood_combined > 1000)) OR (((cnvtupper(pat->hem[d1.seq].
     delivery_comp)="*HEMORRHAGE*") OR (cnvtupper(pat->hem[d1.seq].diagnosis)=
    "*POSTPARTUM HEMORRHAGE*")) )) )) )) )
   HEAD d1.seq
    frec->file_buf = build(frec->file_buf,'"',pat->hem[d1.seq].pat_name,'","',pat->hem[d1.seq].mrn,
     '","',pat->hem[d1.seq].dob,'","',pat->hem[d1.seq].del_type,'","',
     pat->hem[d1.seq].attending,'","',pat->hem[d1.seq].delivery_physician,'","',pat->hem[d1.seq].
     delivery_cnm,
     '","',pat->hem[d1.seq].total_blood_loss,'","',pat->hem[d1.seq].total_quan_blood,'","',
     pat->hem[d1.seq].total_blood_combined,'","',pat->hem[d1.seq].diagnosis,'","',pat->hem[d1.seq].
     delivery_comp,
     '"',char(13))
   WITH nocounter
  ;end select
  SET stat = cclio("WRITE",frec)
  SET stat = cclio("CLOSE",frec)
  DECLARE ms_tmp = vc WITH protect, noconstant("")
  DECLARE ms_email = vc WITH protect, constant("obqualityandsafetyleadership@bhs.org")
  EXECUTE bhs_ma_email_file
  SET ms_tmp = concat("Postpartum Hemorrhage Report: ",format(cnvtdatetime(sysdate),
    "YYYYMMDDHHMMSS;;q"))
  CALL emailfile(value(frec->file_name),frec->file_name,ms_email,ms_tmp,1)
 ELSE
  SELECT INTO  $OUTDEV
   pat_name = substring(1,60,pat->hem[d1.seq].pat_name), mrn = substring(1,20,pat->hem[d1.seq].mrn),
   dob = substring(1,20,pat->hem[d1.seq].dob),
   delivery_type = substring(1,30,pat->hem[d1.seq].del_type), attending = substring(1,100,pat->hem[d1
    .seq].attending), delivery_physician = substring(1,60,pat->hem[d1.seq].delivery_physician),
   delivery_cnm = substring(1,60,pat->hem[d1.seq].delivery_cnm), blood_loss = pat->hem[d1.seq].
   total_blood_loss, quantitative_blood = pat->hem[d1.seq].total_quan_blood,
   blood_loss_combined = pat->hem[d1.seq].total_blood_combined, diagnosis = substring(1,100,pat->hem[
    d1.seq].diagnosis), delivery_complication = substring(1,200,pat->hem[d1.seq].delivery_comp)
   FROM (dummyt d1  WITH seq = size(pat->hem,5))
   PLAN (d1
    WHERE (((pat->hem[d1.seq].total_blood_loss > 1000)) OR ((((pat->hem[d1.seq].total_quan_blood >
    1000)) OR ((((pat->hem[d1.seq].total_blood_combined > 1000)) OR (((cnvtupper(pat->hem[d1.seq].
     delivery_comp)="*HEMORRHAGE*") OR (cnvtupper(pat->hem[d1.seq].diagnosis)=
    "*POSTPARTUM HEMORRHAGE*")) )) )) )) )
   WITH nocounter, separator = " ", format
  ;end select
 ENDIF
END GO
