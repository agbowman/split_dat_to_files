CREATE PROGRAM acm_add_person_rx_plan_reltn:dba
 IF (validate(false,0)=0
  AND validate(false,1)=1)
  DECLARE false = i2 WITH public, constant(0)
 ENDIF
 IF (validate(true,0)=0
  AND validate(true,1)=1)
  DECLARE true = i2 WITH public, constant(1)
 ENDIF
 IF (validate(gen_nbr_error,0)=0
  AND validate(gen_nbr_error,1)=1)
  DECLARE gen_nbr_error = i2 WITH public, constant(3)
 ENDIF
 IF (validate(insert_error,0)=0
  AND validate(insert_error,1)=1)
  DECLARE insert_error = i2 WITH public, constant(4)
 ENDIF
 IF (validate(update_error,0)=0
  AND validate(update_error,1)=1)
  DECLARE update_error = i2 WITH public, constant(5)
 ENDIF
 IF (validate(replace_error,0)=0
  AND validate(replace_error,1)=1)
  DECLARE replace_error = i2 WITH public, constant(6)
 ENDIF
 IF (validate(delete_error,0)=0
  AND validate(delete_error,1)=1)
  DECLARE delete_error = i2 WITH public, constant(7)
 ENDIF
 IF (validate(undelete_error,0)=0
  AND validate(undelete_error,1)=1)
  DECLARE undelete_error = i2 WITH public, constant(8)
 ENDIF
 IF (validate(remove_error,0)=0
  AND validate(remove_error,1)=1)
  DECLARE remove_error = i2 WITH public, constant(9)
 ENDIF
 IF (validate(attribute_error,0)=0
  AND validate(attribute_error,1)=1)
  DECLARE attribute_error = i2 WITH public, constant(10)
 ENDIF
 IF (validate(lock_error,0)=0
  AND validate(lock_error,1)=1)
  DECLARE lock_error = i2 WITH public, constant(11)
 ENDIF
 IF (validate(none_found,0)=0
  AND validate(none_found,1)=1)
  DECLARE none_found = i2 WITH public, constant(12)
 ENDIF
 IF (validate(select_error,0)=0
  AND validate(select_error,1)=1)
  DECLARE select_error = i2 WITH public, constant(13)
 ENDIF
 IF (validate(update_cnt_error,0)=0
  AND validate(update_cnt_error,1)=1)
  DECLARE update_cnt_error = i2 WITH public, constant(14)
 ENDIF
 IF (validate(not_found,0)=0
  AND validate(not_found,1)=1)
  DECLARE not_found = i2 WITH public, constant(15)
 ENDIF
 IF (validate(inactivate_error,0)=0
  AND validate(inactivate_error,1)=1)
  DECLARE inactivate_error = i2 WITH public, constant(17)
 ENDIF
 IF (validate(activate_error,0)=0
  AND validate(activate_error,1)=1)
  DECLARE activate_error = i2 WITH public, constant(18)
 ENDIF
 IF (validate(uar_error,0)=0
  AND validate(uar_error,1)=1)
  DECLARE uar_error = i2 WITH public, constant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 DECLARE failed = i2 WITH protect, noconstant(false)
 DECLARE table_name = vc WITH protect, noconstant(" ")
 DECLARE call_echo_ind = i2 WITH protect, noconstant(0)
 DECLARE pmhc_contributory_system_cd = f8 WITH protect, noconstant(0.0)
 DECLARE index = i4 WITH protect, noconstant(0)
 FOR (index = 1 TO xref->add_cnt)
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[index].idx].person_rx_plan_reltn_id <= 0.0))
    SELECT INTO "nl:"
     nextseqnum = seq(person_seq,nextval)
     FROM dual
     DETAIL
      acm_request->person_rx_plan_reltn_qual[xref->add[index].idx].person_rx_plan_reltn_id = cnvtreal
      (nextseqnum), reply->person_rx_plan_reltn_qual[xref->add[index].idx].person_rx_plan_reltn_id =
      cnvtreal(nextseqnum)
     WITH nocounter, format
    ;end select
    IF (curqual=0)
     SET reply->person_rx_plan_reltn_qual[xref->add[index].idx].status = gen_nbr_error
     SET failed = gen_nbr_error
     GO TO exit_script
    ENDIF
   ELSE
    SET reply->person_rx_plan_reltn_qual[xref->add[index].idx].person_rx_plan_reltn_id = acm_request
    ->person_rx_plan_reltn_qual[xref->add[index].idx].person_rx_plan_reltn_id
   ENDIF
   SET reply->person_rx_plan_reltn_qual[xref->add[index].idx].status = 0
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[index].idx].beg_effective_dt_tm <= 0))
    SET acm_request->person_rx_plan_reltn_qual[xref->add[index].idx].beg_effective_dt_tm =
    cnvtdatetime(curdate,curtime3)
   ENDIF
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[index].idx].end_effective_dt_tm <= 0))
    SET acm_request->person_rx_plan_reltn_qual[xref->add[index].idx].end_effective_dt_tm =
    cnvtdatetime("31-DEC-2100 00:00:00.00")
   ENDIF
 ENDFOR
 INSERT  FROM (dummyt d  WITH seq = value(xref->add_cnt)),
   person_rx_plan_reltn p
  SET p.person_rx_plan_reltn_id = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].
   person_rx_plan_reltn_id, p.beg_effective_dt_tm = cnvtdatetime(acm_request->
    person_rx_plan_reltn_qual[xref->add[d.seq].idx].beg_effective_dt_tm), p.cardholder_first_name =
   acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].cardholder_first_name,
   p.cardholder_ident = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].cardholder_ident,
   p.cardholder_last_name = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].
   cardholder_last_name, p.contributor_system_cd =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].contributor_system_cd > 0.0))
    acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].contributor_system_cd
   ELSE pmhc_contributory_system_cd
   ENDIF
   ,
   p.data_build_flag = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].data_build_flag,
   p.end_effective_dt_tm = cnvtdatetime(acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].
    end_effective_dt_tm), p.health_plan_id =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].health_plan_id > 0)) acm_request
    ->person_rx_plan_reltn_qual[xref->add[d.seq].idx].health_plan_id
   ELSE reply->health_plan_qual[acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].
    health_plan_idx].health_plan_id
   ENDIF
   ,
   p.interchange_id = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].interchange_id, p
   .interchange_seq = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].interchange_seq, p
   .patient_unit_number = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].
   patient_unit_number,
   p.person_id =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].person_id > 0)) acm_request->
    person_rx_plan_reltn_qual[xref->add[d.seq].idx].person_id
   ELSE reply->person_qual[acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].person_idx].
    person_id
   ENDIF
   , p.priority_seq = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].priority_seq, p
   .rx_plan_beg_dt_tm =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].rx_plan_beg_dt_tm > 0))
    cnvtdatetime(acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].rx_plan_beg_dt_tm)
   ELSE null
   ENDIF
   ,
   p.rx_plan_end_dt_tm =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].rx_plan_end_dt_tm > 0))
    cnvtdatetime(acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].rx_plan_end_dt_tm)
   ELSE null
   ENDIF
   , p.trans_dt_tm =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].trans_dt_tm > 0)) cnvtdatetime(
     acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].trans_dt_tm)
   ELSE null
   ENDIF
   , p.verified_by_id = acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].verified_by_id,
   p.verified_dt_tm =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].verified_dt_tm > 0))
    cnvtdatetime(acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].verified_dt_tm)
   ELSE null
   ENDIF
   , p.active_ind =
   IF ((((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].active_status_cd=0.0)) OR ((
   acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].active_status_cd=reqdata->
   active_status_cd))) ) 1
   ELSE 0
   ENDIF
   , p.active_status_cd =
   IF ((acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].active_status_cd > 0.0))
    acm_request->person_rx_plan_reltn_qual[xref->add[d.seq].idx].active_status_cd
   ELSE reqdata->active_status_cd
   ENDIF
   ,
   p.active_status_prsnl_id = reqinfo->updt_id, p.active_status_dt_tm = cnvtdatetime(curdate,curtime3
    ), p.updt_cnt = 0,
   p.updt_dt_tm = cnvtdatetime(curdate,curtime3), p.updt_id = reqinfo->updt_id, p.updt_applctx =
   reqinfo->updt_applctx,
   p.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (p)
  WITH nocounter, status(reply->person_rx_plan_reltn_qual[xref->add[d.seq].idx].status)
 ;end insert
 FOR (index = 1 TO xref->add_cnt)
   IF ((reply->person_rx_plan_reltn_qual[xref->add[index].idx].status=0))
    SET failed = insert_error
    SET table_name = "PERSON_RX_PLAN_RELTN"
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (failed)
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
