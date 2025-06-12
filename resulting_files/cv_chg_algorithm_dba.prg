CREATE PROGRAM cv_chg_algorithm:dba
 DECLARE action_none = i4 WITH protect, constant(0)
 DECLARE action_add = i4 WITH protect, constant(1)
 DECLARE action_chg = i4 WITH protect, constant(2)
 DECLARE action_del = i4 WITH protect, constant(3)
 DECLARE action_get = i4 WITH protect, constant(4)
 DECLARE action_ina = i4 WITH protect, constant(5)
 DECLARE action_act = i4 WITH protect, constant(6)
 DECLARE action_temp = i4 WITH protect, constant(999)
 DECLARE gen_nbr_error = i4 WITH protect, constant(3)
 DECLARE insert_error = i4 WITH protect, constant(4)
 DECLARE update_error = i4 WITH protect, constant(5)
 DECLARE replace_error = i4 WITH protect, constant(6)
 DECLARE delete_error = i4 WITH protect, constant(7)
 DECLARE undelete_error = i4 WITH protect, constant(8)
 DECLARE remove_error = i4 WITH protect, constant(9)
 DECLARE attribute_error = i4 WITH protect, constant(10)
 DECLARE lock_error = i4 WITH protect, constant(11)
 DECLARE none_found = i4 WITH protect, constant(12)
 DECLARE select_error = i4 WITH protect, constant(13)
 DECLARE update_cnt_error = i4 WITH protect, constant(14)
 DECLARE not_found = i4 WITH protect, constant(15)
 DECLARE version_insert_error = i4 WITH protect, constant(16)
 DECLARE inactivate_error = i4 WITH protect, constant(17)
 DECLARE activate_error = i4 WITH protect, constant(18)
 DECLARE version_delete_error = i4 WITH protect, constant(19)
 DECLARE uar_error = i4 WITH protect, constant(20)
 DECLARE failed = i4 WITH protect
 DECLARE table_name = vc WITH protect
 DECLARE call_echo_ind = i2 WITH protect
 DECLARE i_version = i4 WITH protect
 DECLARE program_name = vc WITH protect
 DECLARE sch_security_id = f8 WITH protect
 IF (validate(chg_algorithm_request,0))
  SET called_by_script_server = false
 ELSE
  SET called_by_script_server = true
 ENDIF
 IF (called_by_script_server=true)
  IF ( NOT (validate(chg_algorithm_request,0)))
   RECORD chg_algorithm_request(
     1 call_echo_ind = i2
     1 qual[*]
       2 algorithm_id = f8
       2 dataset_id = f8
       2 description = vc
       2 updt_cnt = i4
       2 result_dta_cd = f8
       2 validation_alg_id = f8
       2 allow_partial_ind = i2
       2 version_ind = i2
       2 force_updt_ind = i2
   )
  ENDIF
  IF ( NOT (validate(chg_algorithm_reply,0)))
   RECORD chg_algorithm_reply(
     1 qual_cnt = i4
     1 qual[*]
       2 status = i4
   )
  ENDIF
  SET nbr1 = size(request->qual,5)
  SET stat = alterlist(chg_algorithm_request->qual,nbr1)
  SET chg_algorithm_request->call_echo_ind = request->call_echo_ind
  FOR (i = 1 TO nbr1)
    SET chg_algorithm_request->qual[i].algorithm_id = request->qual[i].algorithm_id
    SET chg_algorithm_request->qual[i].dataset_id = request->qual[i].dataset_id
    SET chg_algorithm_request->qual[i].description = request->qual[i].description
    SET chg_algorithm_request->qual[i].updt_cnt = request->qual[i].updt_cnt
    SET chg_algorithm_request->qual[i].result_dta_cd = request->qual[i].result_dta_cd
    SET chg_algorithm_request->qual[i].validation_alg_id = request->qual[i].validation_alg_id
    SET chg_algorithm_request->qual[i].allow_partial_ind = request->qual[i].allow_partial_ind
    SET chg_algorithm_request->qual[i].version_ind = request->qual[i].version_ind
    SET chg_algorithm_request->qual[i].force_updt_ind = request->qual[i].force_updt_ind
  ENDFOR
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 status = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET nbr_correct = 0
 SET reply->status_data.status = "F"
 SET table_name = "CV_ALGORITHM"
 SET chg_algorithm_reply->qual_cnt = size(chg_algorithm_request->qual,5)
 SET stat = alterlist(chg_algorithm_reply->qual,chg_algorithm_reply->qual_cnt)
 IF ((chg_algorithm_reply->qual_cnt=0))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  t.updt_cnt, d.seq
  FROM cv_algorithm t,
   (dummyt d  WITH seq = value(chg_algorithm_reply->qual_cnt))
  PLAN (d)
   JOIN (t
   WHERE (t.algorithm_id=chg_algorithm_request->qual[d.seq].algorithm_id))
  HEAD REPORT
   i_version = 0
  DETAIL
   IF ((((t.updt_cnt=chg_algorithm_request->qual[d.seq].updt_cnt)) OR ((chg_algorithm_request->qual[d
   .seq].force_updt_ind=1))) )
    chg_algorithm_reply->qual[d.seq].status = 1
   ELSE
    chg_algorithm_reply->qual[d.seq].status = update_cnt_error
   ENDIF
  WITH nocounter, forupdate(t)
 ;end select
 SET nbr_correct = 0
 FOR (i = 1 TO chg_algorithm_reply->qual_cnt)
   IF ((chg_algorithm_reply->qual[i].status=1))
    SET nbr_correct = (nbr_correct+ 1)
   ELSE
    IF ((chg_algorithm_request->qual[i].allow_partial_ind != 1))
     SET failed = select_error
     SET nbr_correct = 0
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_correct=0)
  GO TO exit_script
 ENDIF
 UPDATE  FROM cv_algorithm t,
   (dummyt d  WITH seq = value(chg_algorithm_reply->qual_cnt))
  SET t.dataset_id = chg_algorithm_request->qual[d.seq].dataset_id, t.description = trim(
    chg_algorithm_request->qual[d.seq].description), t.updt_id = reqinfo->updt_id,
   t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo->updt_task, t.updt_applctx =
   reqinfo->updt_applctx,
   t.updt_cnt = (t.updt_cnt+ 1), t.result_dta_cd = chg_algorithm_request->qual[d.seq].result_dta_cd,
   t.validation_alg_id = chg_algorithm_request->qual[d.seq].validation_alg_id
  PLAN (d
   WHERE (chg_algorithm_reply->qual[d.seq].status=1))
   JOIN (t
   WHERE (t.algorithm_id=chg_algorithm_request->qual[d.seq].algorithm_id))
  WITH nocounter, status(chg_algorithm_reply->qual[d.seq].status)
 ;end update
 SET nbr_correct = 0
 FOR (i = 1 TO chg_algorithm_reply->qual_cnt)
   IF ((chg_algorithm_reply->qual[i].status=1))
    SET nbr_correct = (nbr_correct+ 1)
   ELSE
    IF ((chg_algorithm_reply->qual[i].status=0))
     SET chg_algorithm_reply->qual[i].status = update_error
     IF ((chg_algorithm_request->qual[i].allow_partial_ind != 1))
      SET failed = update_error
      SET nbr_correct = 0
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_correct=0)
  GO TO exit_script
 ENDIF
#exit_script
 IF (called_by_script_server=true)
  SET reply->qual_cnt = chg_algorithm_reply->qual_cnt
  SET stat = alterlist(reply->qual,reply->qual_cnt)
  FOR (i = 1 TO reply->qual_cnt)
    SET reply->qual[i].status = chg_algorithm_reply->qual[i].status
  ENDFOR
 ENDIF
#check_failed
 IF (failed=false)
  CASE (nbr_correct)
   OF 0:
    SET reqinfo->commit_ind = false
    SET reply->status_data.status = "Z"
   OF chg_algorithm_reply->qual_cnt:
    SET reqinfo->commit_ind = true
    SET reply->status_data.status = "S"
   ELSE
    SET reqinfo->commit_ind = true
    SET reply->status_data.status = "P"
  ENDCASE
 ELSE
  CALL echorecord(chg_algorithm_request)
  CALL echorecord(chg_algorithm_reply)
  SET reqinfo->commit_ind = false
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
    OF version_insert_error:
     CALL s_add_subeventstatus("VERSION_INSERT","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF version_delete_error:
     CALL s_add_subeventstatus("VERSION_DELETE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCL_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   CALL s_log_subeventstatus(1)
  ENDIF
 ENDIF
END GO
