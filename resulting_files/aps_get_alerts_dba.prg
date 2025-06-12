CREATE PROGRAM aps_get_alerts:dba
 IF ((request->called_ind != "Y"))
  RECORD reply(
    1 ft_ind = i2
    1 path_history_ind = i2
    1 open_cases_ind = i2
    1 prev_abnormal_ind = i2
    1 prev_atypical_ind = i2
    1 prev_normal_ind = i2
    1 prev_unsat_ind = i2
    1 clin_high_risk_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
  SET reply->status_data.status = "F"
 ENDIF
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE prev_abnormal_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prev_atypical_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prev_normal_cd = f8 WITH protect, noconstant(0.0)
 DECLARE prev_unsat_cd = f8 WITH protect, noconstant(0.0)
 DECLARE verified_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cancelled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE corrected_cd = f8 WITH protect, noconstant(0.0)
 DECLARE signinproc_cd = f8 WITH protect, noconstant(0.0)
 DECLARE csigninproc_cd = f8 WITH protect, noconstant(0.0)
 SET cnt = 0
 SET nbr_cases = 0
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 case_id = f8
 )
 SET stat = uar_get_meaning_by_codeset(1305,"VERIFIED",1,verified_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"CANCEL",1,cancelled_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"CORRECTED",1,corrected_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"SIGNINPROC",1,signinproc_cd)
 SET stat = uar_get_meaning_by_codeset(1305,"CSIGNINPROC",1,csigninproc_cd)
 IF (((verified_cd=0.0) OR (((cancelled_cd=0.0) OR (((corrected_cd=0.0) OR (((signinproc_cd=0.0) OR (
 csigninproc_cd=0.0)) )) )) )) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 ENDIF
 IF (verified_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - VERIFIED"
  GO TO exit_script
 ELSEIF (cancelled_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - CANCEL"
  GO TO exit_script
 ELSEIF (corrected_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - CORRECTED"
  GO TO exit_script
 ELSEIF (signinproc_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - SIGNINPROC"
  GO TO exit_script
 ELSEIF (csigninproc_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - CSIGNINPROC"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(1316,"ABNORMAL",1,prev_abnormal_cd)
 SET stat = uar_get_meaning_by_codeset(1316,"ATYPICAL",1,prev_atypical_cd)
 SET stat = uar_get_meaning_by_codeset(1316,"NORMAL",1,prev_normal_cd)
 SET stat = uar_get_meaning_by_codeset(1316,"UNSAT",1,prev_unsat_cd)
 IF (((prev_abnormal_cd=0.0) OR (((prev_atypical_cd=0.0) OR (((prev_normal_cd=0.0) OR (prev_unsat_cd=
 0.0)) )) )) )
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 ENDIF
 IF (prev_abnormal_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - ABNORMAL"
  GO TO exit_script
 ELSEIF (prev_atypical_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - ATYPICAL"
  GO TO exit_script
 ELSEIF (prev_normal_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - NORMAL"
  GO TO exit_script
 ELSEIF (prev_unsat_cd=0.0)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE - UNSAT"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  pc.case_id, main_report_complete_dt_tm_indc = evaluate(nullind(pc.main_report_cmplete_dt_tm),0,1,0)
  FROM pathology_case pc
  PLAN (pc
   WHERE (request->person_id=pc.person_id)
    AND pc.cancel_cd IN (null, 0)
    AND pc.reserved_ind != 1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt > size(temp->qual,5))
    stat = alterlist(temp->qual,(cnt+ 49))
   ENDIF
   temp->qual[cnt].case_id = pc.case_id
   IF (pc.chr_ind=1
    AND main_report_complete_dt_tm_indc=1)
    reply->clin_high_risk_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->qual,cnt)
  WITH nocounter
 ;end select
 SET nbr_cases = cnvtint(size(temp->qual,5))
 SELECT INTO "nl:"
  cr.report_id
  FROM case_report cr
  PLAN (cr
   WHERE expand(idx,1,nbr_cases,cr.case_id,temp->qual[idx].case_id)
    AND (request->report_id != cr.report_id)
    AND  NOT (cr.status_cd IN (verified_cd, cancelled_cd, corrected_cd, signinproc_cd, csigninproc_cd
   )))
  WITH nocounter, maxrec = 1
 ;end select
 IF (curqual > 0)
  SET reply->open_cases_ind = 1
 ENDIF
 SELECT INTO "nl:"
  cr.case_id
  FROM case_report cr
  PLAN (cr
   WHERE expand(idx,1,nbr_cases,cr.case_id,temp->qual[idx].case_id)
    AND (request->report_id != cr.report_id)
    AND cr.event_id > 0)
  WITH nocounter, maxrec = 1
 ;end select
 IF (curqual > 0)
  SET reply->path_history_ind = 1
 ENDIF
 SELECT INTO "nl:"
  ft.person_id
  FROM ap_ft_event ft
  PLAN (ft
   WHERE (request->person_id=ft.person_id)
    AND ft.term_id IN (0, null))
  WITH nocounter, maxrec = 1
 ;end select
 IF (curqual > 0)
  SET reply->ft_ind = 1
 ENDIF
 SELECT INTO "nl:"
  qa.flag_type_cd
  FROM ap_qa_info qa
  PLAN (qa
   WHERE (request->person_id=qa.person_id)
    AND qa.active_ind=1
    AND qa.flag_type_cd IN (prev_abnormal_cd, prev_atypical_cd, prev_normal_cd, prev_unsat_cd))
  DETAIL
   CASE (qa.flag_type_cd)
    OF prev_abnormal_cd:
     reply->prev_abnormal_ind = 1
    OF prev_atypical_cd:
     reply->prev_atypical_ind = 1
    OF prev_normal_cd:
     reply->prev_normal_ind = 1
    OF prev_unsat_cd:
     reply->prev_unsat_ind = 1
   ENDCASE
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
END GO
