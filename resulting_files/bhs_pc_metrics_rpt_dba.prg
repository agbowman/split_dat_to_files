CREATE PROGRAM bhs_pc_metrics_rpt:dba
 FREE RECORD t_record
 RECORD t_record(
   1 action_dt_tm = dq8
   1 beg_date = dq8
   1 end_date = dq8
   1 phys_cnt = i4
   1 phys_qual[*]
     2 phys_id = f8
     2 position_cd = f8
     2 signed_pn_cnt = i4
     2 signed_cn_cnt = i4
     2 fwd_doc_cnt = i4
   1 ce_cnt = i4
   1 ce_qual[*]
     2 ce_id = f8
     2 author_id = f8
   1 pn_cnt = i4
   1 pn_qual[*]
     2 event_id = f8
 )
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE fin_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR"))
 DECLARE sign_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"SIGN"))
 DECLARE modify_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",21,"MODIFY"))
 DECLARE blob_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",25,"BLOB"))
 DECLARE doc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"DOC"))
 DECLARE mdoc_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",53,"MDOC"))
 DECLARE appt1_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION"))
 DECLARE appt2_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHOBV"))
 DECLARE appt3_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV"))
 DECLARE appt4_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE appt5_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHIP"))
 DECLARE appt6_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP"))
 DECLARE appt7_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE appt8_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"PREADMITDAYSTAY"))
 DECLARE appt9_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"DISCHDAYSTAY"))
 DECLARE appt10_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY"))
 DECLARE appt11_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EMERGENCY"))
 DECLARE completed_cd = f8 WITH constant(uar_get_code_by("MEANING",103,"COMPLETED"))
 DECLARE bhs_dba_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"BHSDBA"))
 DECLARE dba_bhs_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"DBABHS"))
 DECLARE dba_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",88,"DBA"))
 DECLARE powerchart_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",89,"POWERCHART"))
 DECLARE signed_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15750,"SIGNED"))
 DECLARE document_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15749,"DOCUMENT"))
 DECLARE mock_org_id = f8
 DECLARE indx = i4
 DECLARE department = vc
 DECLARE t_line = vc
 SELECT INTO "nl:"
  o.organization_id
  FROM organization o
  PLAN (o
   WHERE o.org_name_key="MOCKBAYSTATEHEALTHSYSTEM")
  DETAIL
   mock_org_id = o.organization_id
  WITH nocounter
 ;end select
 IF (validate(request->batch_selection))
  SET t_record->action_dt_tm = cnvtdatetime(request->ops_date)
  IF ((t_record->action_dt_tm <= 0))
   SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  ENDIF
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (15))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list =  $1
 ELSE
  SET t_record->action_dt_tm = cnvtdatetime(curdate,curtime3)
  SET t_record->action_dt_tm = datetimeadd(t_record->action_dt_tm,- (15))
  SET t_record->beg_date = datetimefind(t_record->action_dt_tm,"M","B","B")
  SET t_record->end_date = datetimefind(t_record->action_dt_tm,"M","E","E")
  SET email_list =  $1
 ENDIF
 SELECT INTO "nl:"
  FROM prsnl pr,
   omf_app_ctx_month_st omf
  PLAN (pr
   WHERE pr.physician_ind=1
    AND trim(pr.username,3) > " ")
   JOIN (omf
   WHERE omf.person_id=pr.person_id
    AND omf.start_month >= cnvtdatetime(t_record->beg_date)
    AND omf.start_month <= cnvtdatetime(t_record->end_date)
    AND omf.application_number IN (600005, 961000))
  ORDER BY pr.person_id
  HEAD pr.person_id
   IF (((pr.position_cd != bhs_dba_cd) OR (((pr.position_cd != dba_bhs_cd) OR (pr.position_cd !=
   dba_cd)) )) )
    t_record->phys_cnt = (t_record->phys_cnt+ 1)
    IF (mod(t_record->phys_cnt,1000)=1)
     stat = alterlist(t_record->phys_qual,(t_record->phys_cnt+ 999))
    ENDIF
    t_record->phys_qual[t_record->phys_cnt].phys_id = pr.person_id, t_record->phys_qual[t_record->
    phys_cnt].position_cd = pr.position_cd
   ENDIF
  FOOT REPORT
   stat = alterlist(t_record->phys_qual,t_record->phys_cnt)
  WITH orahint("index(pr XIE3PRSNL)")
 ;end select
 SELECT INTO TABLE pc_temp
  phys_id = t_record->phys_qual[d.seq].phys_id
  FROM (dummyt d  WITH seq = t_record->phys_cnt)
  WITH nocounter
 ;end select
 FOR (i = 1 TO t_record->phys_cnt)
   CALL echo(t_record->phys_cnt)
   CALL echo(i)
   SELECT INTO "nl:"
    FROM scd_story s,
     clinical_event ce,
     person p,
     encounter e
    PLAN (s
     WHERE (s.author_id=t_record->phys_qual[i].phys_id)
      AND s.story_type_cd=document_cd
      AND s.story_completion_status_cd=signed_cd)
     JOIN (ce
     WHERE ce.event_id=s.event_id
      AND ce.event_end_dt_tm >= cnvtdatetime(t_record->beg_date)
      AND ce.event_end_dt_tm <= cnvtdatetime(t_record->end_date)
      AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
     JOIN (p
     WHERE p.person_id=ce.person_id)
     JOIN (e
     WHERE e.encntr_id=ce.encntr_id
      AND e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
     appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd,
     appt11_cd))
    ORDER BY ce.event_id, s.scd_story_id
    HEAD ce.event_id
     IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
      t_record->phys_qual[i].signed_pn_cnt = (t_record->phys_qual[i].signed_pn_cnt+ 1)
     ENDIF
    HEAD s.scd_story_id
     t_record->pn_cnt = (t_record->pn_cnt+ 1)
     IF (mod(t_record->pn_cnt,1000)=1)
      stat = alterlist(t_record->pn_qual,(t_record->pn_cnt+ 999))
     ENDIF
     t_record->pn_qual[t_record->pn_cnt].event_id = ce.event_id
    WITH maxcol = 1000
   ;end select
 ENDFOR
 SET stat = alterlist(t_record->pn_qual,t_record->pn_cnt)
 SELECT INTO "nl:"
  FROM pc_temp pt,
   ce_event_prsnl cep,
   clinical_event ce,
   clinical_event ce1,
   ce_blob_result ceb,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=sign_cd)
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ((ce.performed_prsnl_id+ 0)=cep.action_prsnl_id)
    AND ce.event_class_cd=mdoc_cd
    AND ce.contributor_system_cd=powerchart_cd
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.accession_nbr=" "
    AND  NOT ( EXISTS (
   (SELECT
    s.scd_story_id
    FROM scd_story s
    WHERE s.event_id=ce.event_id))))
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.event_class_cd=doc_cd
    AND  NOT ( EXISTS (
   (SELECT
    s.scd_story_id
    FROM scd_story s
    WHERE s.event_id=ce1.event_id))))
   JOIN (ceb
   WHERE ceb.event_id=ce1.event_id
    AND ceb.storage_cd=blob_cd)
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd,
   appt11_cd))
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].signed_cn_cnt = (t_record->phys_qual[idx].signed_cn_cnt+ 1)
   ENDIF
  WITH orahint("index(cep XIE3CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "nl:"
  FROM pc_temp pt,
   ce_event_prsnl cep,
   ce_event_prsnl cep1,
   clinical_event ce,
   person p,
   encounter e
  PLAN (pt)
   JOIN (cep
   WHERE cep.action_prsnl_id=pt.phys_id
    AND cep.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep.action_status_cd=completed_cd
    AND cep.action_type_cd=modify_cd)
   JOIN (cep1
   WHERE cep1.event_id=cep.event_id
    AND cep1.action_prsnl_id=cep.action_prsnl_id
    AND cep1.action_dt_tm >= cnvtdatetime(t_record->beg_date)
    AND cep1.action_dt_tm <= cnvtdatetime(t_record->end_date)
    AND cep1.action_status_cd=completed_cd
    AND cep1.action_type_cd=sign_cd)
   JOIN (ce
   WHERE ce.event_id=cep.event_id
    AND ((ce.performed_prsnl_id+ 0) != cep.action_prsnl_id))
   JOIN (p
   WHERE p.person_id=cep.person_id)
   JOIN (e
   WHERE e.encntr_id=ce.encntr_id
    AND e.encntr_type_cd IN (appt1_cd, appt2_cd, appt3_cd, appt4_cd, appt5_cd,
   appt6_cd, appt7_cd, appt8_cd, appt9_cd, appt10_cd,
   appt11_cd))
  ORDER BY pt.phys_id, cep.event_id
  HEAD pt.phys_id
   idx = locateval(indx,1,t_record->phys_cnt,pt.phys_id,t_record->phys_qual[indx].phys_id)
  HEAD cep.event_id
   IF (((e.organization_id != mock_org_id) OR (p.name_last_key != "ZZZ*")) )
    t_record->phys_qual[idx].fwd_doc_cnt = (t_record->phys_qual[idx].fwd_doc_cnt+ 1)
   ENDIF
  WITH orahint("index(cep XIE3CE_EVENT_PRSNL), index(cep1 XIE1CE_EVENT_PRSNL)")
 ;end select
 SELECT INTO "pn_usage.xls"
  total_docs = ((t_record->phys_qual[d.seq].signed_pn_cnt+ t_record->phys_qual[d.seq].signed_cn_cnt)
  + t_record->phys_qual[d.seq].fwd_doc_cnt), phys_id = t_record->phys_qual[d.seq].phys_id
  FROM (dummyt d  WITH seq = t_record->phys_cnt),
   person pr
  PLAN (d)
   JOIN (pr
   WHERE (pr.person_id=t_record->phys_qual[d.seq].phys_id)
    AND pr.active_ind=1)
  ORDER BY pr.name_full_formatted, phys_id
  HEAD REPORT
   t_line = "PN Usage Report", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), col 0,
   t_line, row + 1, t_line = concat("Physcian Name",char(9),"Position",char(9),"Department",
    char(9),"Powernotes Signed",char(9),"Clinical Notes Signed",char(9),
    "Forwarded Notes Modified and Signed",char(9),"Total Documents Signed",char(9)),
   col 0, t_line, row + 1
  HEAD pr.name_full_formatted
   null
  HEAD phys_id
   CASE (uar_get_code_display(t_record->phys_qual[d.seq].position_cd))
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
   t_line = concat(trim(pr.name_full_formatted),char(9),trim(uar_get_code_display(t_record->
      phys_qual[d.seq].position_cd)),char(9),trim(department),
    char(9),trim(cnvtstring(t_record->phys_qual[d.seq].signed_pn_cnt)),char(9),trim(cnvtstring(
      t_record->phys_qual[d.seq].signed_cn_cnt)),char(9),
    trim(cnvtstring(t_record->phys_qual[d.seq].fwd_doc_cnt)),char(9),trim(cnvtstring(total_docs)),
    char(9)), col 0, t_line,
   row + 1
  WITH maxcol = 3500, formfeed = none
 ;end select
 SELECT INTO "phys_pn_details.xls"
  FROM (dummyt d  WITH seq = t_record->pn_cnt),
   scd_story s,
   scd_story_pattern ssp,
   scr_pattern sp,
   clinical_event ce,
   person p,
   prsnl pr,
   encntr_alias ea
  PLAN (d)
   JOIN (s
   WHERE (s.event_id=t_record->pn_qual[d.seq].event_id)
    AND s.story_completion_status_cd=signed_cd)
   JOIN (ssp
   WHERE ssp.scd_story_id=s.scd_story_id)
   JOIN (sp
   WHERE sp.scr_pattern_id=ssp.scr_pattern_id)
   JOIN (ce
   WHERE ce.event_id=s.event_id
    AND ce.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00")
    AND ce.event_tag != "In Error")
   JOIN (p
   WHERE p.person_id=ce.person_id
    AND p.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=s.author_id
    AND pr.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.encntr_alias_type_cd=fin_cd)
  ORDER BY pr.name_full_formatted, pr.person_id, sp.display,
   ce.event_end_dt_tm, p.person_id
  HEAD REPORT
   t_line = "PN Type Count Report", col 0, t_line,
   row + 1, t_line = concat(format(t_record->beg_date,"DD-MMM-YYYY;;Q")," to ",format(t_record->
     end_date,"DD-MMM-YYYY;;Q"),char(9)), col 0,
   t_line, row + 1, t_line = concat("Physcian Name",char(9),"Position",char(9),"Department",
    char(9),"Note Title",char(9),"Note Type",char(9),
    "Note Date/Time",char(9),"Patient Name",char(9),"Acct #"),
   col 0, t_line, row + 1
  HEAD pr.person_id
   CASE (uar_get_code_display(pr.position_cd))
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
  HEAD p.person_id
   null
  DETAIL
   t_line = concat(pr.name_full_formatted,char(9),uar_get_code_display(pr.position_cd),char(9),
    department,
    char(9),sp.display,char(9),ce.event_tag,char(9),
    format(ce.event_end_dt_tm,"mm-dd-yyyy hh:mm;;q"),char(9),p.name_full_formatted,char(9),ea.alias),
   col 0, t_line,
   row + 1
  WITH maxcol = 1000, formfeed = none
 ;end select
 DECLARE dclcom = vc
 IF (findfile("pn_usage.xls")=1
  AND findfile("phys_pn_details.xls")=1)
  SET dclcom = "gzip pn_usage.xls"
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET dclcom = "gzip phys_pn_details.xls"
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET subject_line = concat("Power Chart PN Usage Reports ",format(t_record->beg_date,
    "DD-MMM-YYYY;;Q")," to ",format(t_record->end_date,"DD-MMM-YYYY;;Q"))
  SET dclcom = concat('echo " " | mailx -s "',subject_line,'" ','-a "pn_usage.xls.gz" ',
   '-a "phys_pn_details.xls.gz" ',
   email_list)
  SET len = size(trim(dclcom))
  SET status = 0
  SET stat = dcl(dclcom,len,status)
  SET stat = remove("pn_usage.xls")
  SET stat = remove("phys_pn_details.xls")
  SET stat = remove("pn_usage.xls.gz")
  SET stat = remove("phys_pn_details.xls.gz")
 ENDIF
 DROP TABLE pc_temp
 SET dclcom = "rm -f pc_temp*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
#exit_script
 SET reply->status_data[1].status = "S"
END GO
