CREATE PROGRAM bhs_rpt_medrec_home_meds:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 beg_date = dq8
   1 end_date = dq8
   1 action_dt_tm = dq8
   1 note_cnt = i4
   1 note_qual[*]
     2 encntr_id = f8
     2 author_id = f8
     2 patient_id = f8
     2 fin = vc
     2 note_dt_tm = dq8
     2 story_id = f8
     2 med_cnt = i4
     2 hx_cnt = i4
     2 home_med_cnt = i4
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (3))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"W","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"W","E","E")
  SET email_list = trim( $1)
 ENDIF
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE signed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",15750,"SIGNED"))
 DECLARE pharm_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY"))
 DECLARE fin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE t_line = vc
 DECLARE department = vc
 SELECT INTO "nl:"
  FROM scr_pattern sp,
   scd_story_pattern ssp,
   scd_story s,
   clinical_event ce,
   scd_term st,
   scd_term_data std,
   orders o,
   encntr_alias ea
  PLAN (sp
   WHERE sp.display_key="PHYSICIANDISCHARGESUMMARY")
   JOIN (ssp
   WHERE ssp.scr_pattern_id=sp.scr_pattern_id)
   JOIN (s
   WHERE s.scd_story_id=ssp.scd_story_id
    AND s.story_completion_status_cd=signed_cd
    AND s.active_status_dt_tm >= cnvtdatetime(t_record->beg_date))
   JOIN (ce
   WHERE ce.event_id=s.event_id
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.event_tag != "In Error"
    AND ce.event_end_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND ce.event_end_dt_tm < cnvtdatetime(t_record->end_date))
   JOIN (st
   WHERE st.scd_story_id=s.scd_story_id)
   JOIN (std
   WHERE std.scd_term_data_id=st.scd_term_data_id
    AND std.fkey_entity_name IN ("ORDER", "ORDERS"))
   JOIN (o
   WHERE o.order_id=std.fkey_id
    AND o.catalog_type_cd=pharm_cd)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.encntr_alias_type_cd=1077)
  ORDER BY s.scd_story_id, o.order_id
  HEAD s.scd_story_id
   t_record->note_cnt = (t_record->note_cnt+ 1)
   IF (mod(t_record->note_cnt,1000)=1)
    stat = alterlist(t_record->note_qual,(t_record->note_cnt+ 999))
   ENDIF
   t_record->note_qual[t_record->note_cnt].encntr_id = ce.encntr_id, t_record->note_qual[t_record->
   note_cnt].author_id = s.author_id, t_record->note_qual[t_record->note_cnt].note_dt_tm =
   cnvtdatetime(ce.event_end_dt_tm),
   t_record->note_qual[t_record->note_cnt].patient_id = ce.person_id, t_record->note_qual[t_record->
   note_cnt].fin = ea.alias, t_record->note_qual[t_record->note_cnt].story_id = s.scd_story_id
  HEAD o.order_id
   t_record->note_qual[t_record->note_cnt].med_cnt = (t_record->note_qual[t_record->note_cnt].med_cnt
   + 1)
   IF (((o.orig_ord_as_flag=1) OR (o.orig_ord_as_flag=2)) )
    t_record->note_qual[t_record->note_cnt].hx_cnt = (t_record->note_qual[t_record->note_cnt].hx_cnt
    + 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(t_record->note_qual,t_record->note_cnt)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(t_record->note_qual,5))),
   orders o
  PLAN (d)
   JOIN (o
   WHERE (o.person_id=t_record->note_qual[d.seq].patient_id)
    AND o.current_start_dt_tm <= cnvtdatetime(t_record->note_qual[d.seq].note_dt_tm)
    AND ((o.orig_ord_as_flag+ 0) IN (1, 2))
    AND o.catalog_type_cd=pharm_cd
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  ORDER BY o.person_id, o.order_id
  HEAD o.order_id
   t_record->note_qual[d.seq].home_med_cnt = (t_record->note_qual[d.seq].home_med_cnt+ 1)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "home_med_rec.xls"
  phys = p1.name_full_formatted, date = t_record->note_qual[d.seq].note_dt_tm, sid = t_record->
  note_qual[d.seq].story_id,
  fin = t_record->note_qual[d.seq].fin
  FROM (dummyt d  WITH seq = t_record->note_cnt),
   prsnl p1,
   person p2,
   encntr_loc_hist elh
  PLAN (d)
   JOIN (p1
   WHERE (p1.person_id=t_record->note_qual[d.seq].author_id)
    AND p1.physician_ind=1)
   JOIN (p2
   WHERE (p2.person_id=t_record->note_qual[d.seq].patient_id))
   JOIN (elh
   WHERE (elh.encntr_id=t_record->note_qual[d.seq].encntr_id))
  ORDER BY fin, date DESC, elh.end_effective_dt_tm DESC
  HEAD REPORT
   t_line = concat("Home Med Rec from Physician Discharge Summary Note - ",format(t_record->beg_date,
     "MM-DD-YYYY HH:MM;;q")," to ",format(t_record->end_date,"MM-DD-YYYY HH:MM;;q")), col 0, t_line,
   row + 1, t_line = concat("Author",char(9),"Department",char(9),"Note Date Time",
    char(9),"Unit",char(9),"Patient",char(9),
    "Acct #",char(9),"Number of Meds on Note",char(9),"Number of Home Meds from Note",
    char(9),"Number of Total Home Meds",char(9)), col 0,
   t_line, row + 1
  HEAD fin
   CASE (uar_get_code_display(p1.position_cd))
    OF "BHS Anesthesiology MD":
     department = "Anesthesiology"
    OF "BHS Cardiology MD":
     department = "Internal Medicine"
    OF "BHS Cardiac Surgery MD":
     department = "Surgery"
    OF "BHS Critical Care MD":
     department = "Internal Medicine"
    OF "BHS ER Medicine MD":
     department = "Emergency Medicine"
    OF "BHS Infectious Disease MD":
     department = "Internal Medicine"
    OF "BHS GI MD":
     department = "Internal Medicine"
    OF "BHS Urology MD":
     department = "Surgery"
    OF "BHS Thoracic MD":
     department = "Surgery"
    OF "BHS Trauma MD":
     department = "Surgery"
    OF "BHS Resident":
     department = "Resident"
    OF "BHS Oncology MD":
     department = "Internal Medicine"
    OF "BHS Neonatal MD":
     department = "Pediatrics"
    OF "BHS Neurology MD":
     department = "Internal Medicine"
    OF "BHS OB/GYN MD":
     department = "Ob/Gyn"
    OF "BHS Orthopedics MD":
     department = "Surgery"
    OF "BHS General Pediatrics MD":
     department = "Pediatrics"
    OF "BHS Psychiatry MD":
     department = "Psychiatry"
    OF "BHS Physiatry MD":
     department = "Internal Medicine"
    OF "BHS Pulmonary MD":
     department = "Internal Medicine"
    OF "BHS Radiology MD":
     department = "Radiology"
    OF "BHS Renal MD":
     department = "Internal Medicine"
    OF "BHS General Surgery MD":
     department = "Surgery"
    OF "BHS Midwife":
     department = "Ob/Gyn"
    OF "BHS Associate Professional":
     department = "Associate Provider"
    OF "BHS Physician (General Medicine)":
     department = "Internal Medicine"
    OF "BHS Medical Student":
     department = "Medical Student"
    ELSE
     department = "Other"
   ENDCASE
   t_line = concat(p1.name_full_formatted,char(9),department,char(9),format(t_record->note_qual[d.seq
     ].note_dt_tm,"mm-dd-yyyy hh:mm;;q"),
    char(9),uar_get_code_display(elh.loc_nurse_unit_cd),char(9),p2.name_full_formatted,char(9),
    t_record->note_qual[d.seq].fin,char(9),trim(cnvtstring(t_record->note_qual[d.seq].med_cnt)),char(
     9),trim(cnvtstring(t_record->note_qual[d.seq].hx_cnt)),
    char(9),trim(cnvtstring(t_record->note_qual[d.seq].home_med_cnt)),char(9)), col 0, t_line,
   row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("home_med_rec.xls")=1)
  SET subject_line = concat("Home Med Rec from Physician Discharge Summary Note - ",format(t_record->
    beg_date,"MM-DD-YYYY HH:MM;;q")," to ",format(t_record->end_date,"MM-DD-YYYY HH:MM;;q"))
  CALL emailfile("home_med_rec.xls","home_med_rec.xls",email_list,subject_line,1)
 ENDIF
#exit_script
 SET reply->status_data[1].status = "S"
END GO
