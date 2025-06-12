CREATE PROGRAM acm_ens_service_cat_hist
 DECLARE insert_new_svc_cat_hist_row = i2 WITH noconstant(0)
 DECLARE service_category_hist_id = f8 WITH noconstant(0.0)
 DECLARE old_attend_prsnl_id = f8 WITH noconstant(0.0)
 DECLARE old_beg_eff_dt_tm = f8 WITH noconstant(0.0)
 DECLARE old_attend_prsnl_id = f8 WITH noconstant(0.0)
 DECLARE cur_service_category_cd = f8 WITH noconstant(0.0)
 DECLARE sservcathist = c1 WITH noconstant("")
 DECLARE dcodevalue = f8 WITH noconstant(0.0)
 DECLARE dactivecd = f8 WITH noconstant(0.0)
 SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET insert_new_svc_cat_hist_row = false
 SET old_attend_prsnl_id = 0
 SET stat = uar_get_meaning_by_codeset(20790,"SERVCATHIST",1,dcodevalue)
 SELECT INTO "nl:"
  cve.seq
  FROM code_value_extension cve
  WHERE cve.code_value=dcodevalue
  DETAIL
   sservcathist = cve.field_value
  WITH nocounter
 ;end select
 IF ((request->active_status_cd=0.0))
  SET dactivecd = reqdata->active_status_cd
 ENDIF
 CASE (request->action_type)
  OF 1:
   SET service_category_hist_id = 0.0
   SET insert_new_svc_cat_hist_row = true
  OF 2:
   SET service_category_hist_id = 0.0
   SELECT INTO "nl:"
    s.seq
    FROM service_category_hist s
    WHERE (s.encntr_id=request->encntr_id)
     AND ((s.active_ind+ 0)=1)
     AND ((s.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
     AND ((((s.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))) OR (((s
    .end_effective_dt_tm+ 0)=cnvtdatetime(request->disch_dt_tm))))
    DETAIL
     cur_service_category_cd = s.service_category_cd, service_category_hist_id = s.svc_cat_hist_id,
     old_attend_prsnl_id = s.attend_prsnl_id,
     old_beg_eff_dt_tm = s.beg_effective_dt_tm
    WITH nocounter
   ;end select
   IF (service_category_hist_id > 0.0)
    CALL echo(build("MY HIST ID",service_category_hist_id))
    IF ((cur_service_category_cd != request->service_category_cd)
     AND  NOT (cur_service_category_cd=0
     AND (request->service_category_cd=- (1)))
     AND (request->service_category_cd != 0))
     SET insert_new_svc_cat_hist_row = true
    ENDIF
    IF (sservcathist="1"
     AND (old_attend_prsnl_id != request->attend_prsnl_id)
     AND  NOT (old_attend_prsnl_id=0.0
     AND (request->attend_prsnl_id=- (1)))
     AND (request->attend_prsnl_id != 0.0))
     SET insert_new_svc_cat_hist_row = true
    ENDIF
    IF (insert_new_svc_cat_hist_row=false
     AND  NOT (((cnvtdatetime(request->disch_dt_tm) <= 0) OR (cnvtdatetime(request->disch_dt_tm)=
    blank_date)) ))
     UPDATE  FROM service_category_hist s
      SET s.end_effective_dt_tm = cnvtdatetime(request->disch_dt_tm), s.updt_cnt = (s.updt_cnt+ 1), s
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
       updt_applctx
      WHERE s.svc_cat_hist_id=service_category_hist_id
       AND ((s.active_ind+ 0)=1)
       AND ((s.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
       AND ((s.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
      WITH nocounter
     ;end update
     IF (curqual=0)
      CALL echo("ERROR 1")
      SET failed = update_error
      SET reply->postprocess_qual[request->process_idx].status = 0
      GO TO exit_script
     ELSE
      SET reply->postprocess_qual[request->process_idx].id_updated = service_category_hist_id
     ENDIF
    ENDIF
   ELSE
    SET insert_new_svc_cat_hist_row = true
   ENDIF
 ENDCASE
 IF (insert_new_svc_cat_hist_row=true)
  IF (service_category_hist_id > 0.0)
   UPDATE  FROM service_category_hist s
    SET s.end_effective_dt_tm =
     IF ((((request->transaction_dt_tm <= 0)) OR ((((request->transaction_dt_tm=blank_date)) OR ((
     request->transaction_dt_tm <= old_beg_eff_dt_tm))) )) ) cnvtdatetime(curdate,curtime3)
     ELSE cnvtdatetime(request->transaction_dt_tm)
     ENDIF
     , s.updt_cnt = (s.updt_cnt+ 1), s.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
     updt_applctx
    WHERE s.svc_cat_hist_id=service_category_hist_id
     AND ((s.active_ind+ 0)=1)
     AND ((s.beg_effective_dt_tm+ 0) <= cnvtdatetime(curdate,curtime3))
     AND ((s.end_effective_dt_tm+ 0) >= cnvtdatetime(curdate,curtime3))
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET failed = update_error
    SET reply->postprocess_qual[request->process_idx].status = 0
    GO TO exit_script
   ELSE
    SET reply->postprocess_qual[request->process_idx].id_updated = service_category_hist_id
   ENDIF
  ENDIF
  SET new_svc_cat_hist_id = 0.0
  SELECT INTO "nl:"
   y = seq(encounter_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_svc_cat_hist_id = cnvtreal(y)
   WITH format, counter
  ;end select
  IF (curqual=0)
   SET failed = gen_nbr_error
   SET reply->postprocess_qual[request->process_idx].status = 0
   GO TO exit_script
  ENDIF
  INSERT  FROM service_category_hist s
   SET s.svc_cat_hist_id = new_svc_cat_hist_id, s.med_service_cd =
    IF ((request->med_service_cd=- (1))) 0.0
    ELSEIF ((request->med_service_cd=0.0)) cur_service_category_cd
    ELSE request->med_service_cd
    ENDIF
    , s.service_category_cd =
    IF ((request->service_category_cd=- (1))) 0
    ELSEIF ((request->service_category_cd=0)) cur_service_category_cd
    ELSE request->service_category_cd
    ENDIF
    ,
    s.attend_prsnl_id = evaluate(request->attend_prsnl_id,0.0,old_attend_prsnl_id,- (1.0),0.0,
     request->attend_prsnl_id), s.encntr_id = request->encntr_id, s.updt_cnt = 0,
    s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_applctx = reqinfo->
    updt_applctx,
    s.updt_dt_tm = cnvtdatetime(curdate,curtime3), s.active_ind = 1, s.beg_effective_dt_tm =
    IF ((((request->transaction_dt_tm <= 0)) OR ((((request->transaction_dt_tm=blank_date)) OR ((
    request->transaction_dt_tm <= old_beg_eff_dt_tm))) )) ) cnvtdatetime(curdate,curtime3)
    ELSE cnvtdatetime(request->transaction_dt_tm)
    ENDIF
    ,
    s.end_effective_dt_tm =
    IF (((cnvtdatetime(request->disch_dt_tm) <= 0) OR (cnvtdatetime(request->disch_dt_tm)=blank_date
    )) ) cnvtdatetime("31-DEC-2100 00:00:00.00")
    ELSE cnvtdatetime(request->disch_dt_tm)
    ENDIF
    , s.active_status_cd =
    IF ((request->active_status_cd=0.0)) dactivecd
    ELSE request->active_status_cd
    ENDIF
    , s.active_status_prsnl_id = reqinfo->updt_id,
    s.active_status_dt_tm = cnvtdatetime(curdate,curtime3), s.transaction_dt_tm =
    IF ((((request->transaction_dt_tm <= 0)) OR ((request->transaction_dt_tm=blank_date))) )
     cnvtdatetime(curdate,curtime3)
    ELSE cnvtdatetime(request->transaction_dt_tm)
    ENDIF
   WITH nocounter
  ;end insert
  IF (curqual=0)
   SET failed = update_error
   SET reply->postprocess_qual[request->process_idx].status = 0
   GO TO exit_script
  ELSE
   SET reply->postprocess_qual[request->process_idx].id_updated = new_svc_cat_hist_id
  ENDIF
 ENDIF
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
