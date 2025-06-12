CREATE PROGRAM cps_get_schevent:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 schevent_qual = i4
   1 schevent[*]
     2 sch_event_id = f8
     2 version_dt_tm = dq8
     2 appt_type_cd = f8
     2 appt_synonym_cd = f8
     2 oe_format_id = f8
     2 order_sentence_id = f8
     2 sch_state_cd = f8
     2 sch_meaning = c12
     2 contributor_system_cd = f8
     2 appt_synonym_free = vc
     2 candidate_id = f8
     2 null_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 active_status_cd = f8
     2 active_status_dt_tm = dq8
     2 appt_reason_free = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->schevent,5)
 SET reply->status_data.status = "F"
 SET failed = false
 SET kount = 0
 SELECT INTO "NL:"
  se.sch_event_id, sep.encntr_id
  FROM sch_event se,
   sch_event_patient sep,
   encounter e
  PLAN (e
   WHERE (e.encntr_id=request->encntr_id))
   JOIN (sep
   WHERE sep.encntr_id=e.encntr_id)
   JOIN (se
   WHERE se.sch_event_id=sep.sch_event_id
    AND se.version_dt_tm > cnvtdatetime(sysdate)
    AND se.active_ind=1)
  HEAD REPORT
   kount = 0, stat = alterlist(reply->schevent,10)
  DETAIL
   kount += 1
   IF (mod(kount,10)=1
    AND kount != 1)
    stat = alterlist(reply->schevent,(kount+ 9))
   ENDIF
   reply->schevent[kount].sch_event_id = se.sch_event_id, reply->schevent[kount].version_dt_tm = se
   .version_dt_tm, reply->schevent[kount].appt_type_cd = se.appt_type_cd,
   reply->schevent[kount].oe_format_id = se.oe_format_id, reply->schevent[kount].order_sentence_id =
   se.order_sentence_id, reply->schevent[kount].sch_state_cd = se.sch_state_cd,
   reply->schevent[kount].sch_meaning = se.sch_meaning, reply->schevent[kount].contributor_system_cd
    = se.contributor_system_cd, reply->schevent[kount].appt_synonym_free = se.appt_synonym_free,
   reply->schevent[kount].candidate_id = se.candidate_id, reply->schevent[kount].null_dt_tm = se
   .null_dt_tm, reply->schevent[kount].beg_effective_dt_tm = se.beg_effective_dt_tm,
   reply->schevent[kount].end_effective_dt_tm = se.end_effective_dt_tm, reply->schevent[kount].
   active_ind = se.active_ind, reply->schevent[kount].active_status_cd = se.active_status_cd,
   reply->schevent[kount].active_status_dt_tm = se.active_status_dt_tm, reply->schevent[kount].
   appt_reason_free = e.reason_for_visit
  FOOT REPORT
   reply->schevent_qual = kount, stat = alterlist(reply->schevent,kount)
  WITH nocounter
 ;end select
 IF (kount <= 0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
