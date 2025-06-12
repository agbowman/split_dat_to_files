CREATE PROGRAM cv_add_operator:dba
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
 DECLARE called_by_script_server = i2 WITH protect
 DECLARE nbr1 = i4 WITH protect
 DECLARE stat = i4 WITH protect
 DECLARE nbr_correct = i4 WITH protect
 DECLARE generic_ind = i2 WITH protect
 IF (validate(add_operator_request,0))
  SET called_by_script_server = false
 ELSE
  SET called_by_script_server = true
 ENDIF
 IF (called_by_script_server=true)
  IF ( NOT (validate(add_operator_request,0)))
   RECORD add_operator_request(
     1 call_echo_ind = i2
     1 qual[*]
       2 long_text_id = f8
       2 operator = c20
       2 nbr_operands = i4
       2 description_2 = c20
       2 data_status_cd = f8
       2 active_ind = i2
       2 active_status_cd = f8
       2 operator_id = f8
       2 allow_partial_ind = i2
   )
  ENDIF
  IF ( NOT (validate(add_operator_reply,0)))
   RECORD add_operator_reply(
     1 qual_cnt = i4
     1 qual[*]
       2 operator_id = f8
       2 status = i4
   )
  ENDIF
  SET nbr1 = size(request->qual,5)
  SET stat = alterlist(add_operator_request->qual,nbr1)
  SET add_operator_request->call_echo_ind = request->call_echo_ind
  FOR (i = 1 TO nbr1)
    SET add_operator_request->qual[i].operator = request->qual[i].operator
    SET add_operator_request->qual[i].active_ind = request->qual[i].active_ind
    SET add_operator_request->qual[i].operator_id = request->qual[i].operator_id
    SET add_operator_request->qual[i].long_text_id = request->qual[i].long_text_id
    SET add_operator_request->qual[i].nbr_operands = request->qual[i].nbr_operands
    SET add_operator_request->qual[i].description_2 = request->qual[i].description_2
    SET add_operator_request->qual[i].data_status_cd = request->qual[i].data_status_cd
    SET add_operator_request->qual[i].active_status_cd = request->qual[i].active_status_cd
    SET add_operator_request->qual[i].allow_partial_ind = request->qual[i].allow_partial_ind
  ENDFOR
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 operator_id = f8
      2 status = i4
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
 SET add_operator_reply->qual_cnt = size(add_operator_request->qual,5)
 SET stat = alterlist(add_operator_reply->qual,add_operator_reply->qual_cnt)
 IF ((add_operator_reply->qual_cnt=0))
  GO TO exit_script
 ENDIF
 SET nbr_correct = 0
 SET table_name = "CV_OPERATOR"
 FOR (i = 1 TO add_operator_reply->qual_cnt)
   SET generic_ind = true
   IF (generic_ind)
    IF ((add_operator_request->qual[i].operator_id=0.0))
     SELECT INTO "nl:"
      nextseqnum = seq(card_vas_seq,nextval)
      FROM dual
      DETAIL
       add_operator_reply->qual[i].operator_id = nextseqnum, add_operator_request->qual[i].
       operator_id = nextseqnum
      WITH nocounter, format
     ;end select
     IF (curqual=0)
      SET generic_ind = false
     ENDIF
    ELSE
     SET add_operator_reply->qual[i].operator_id = add_operator_request->qual[i].operator_id
    ENDIF
   ENDIF
   IF (generic_ind)
    SET add_operator_reply->qual[i].status = 1
    SET nbr_correct = (nbr_correct+ 1)
   ELSE
    SET add_operator_reply->qual[i].status = gen_nbr_error
    IF ((add_operator_request->qual[i].allow_partial_ind != 1))
     SET failed = gen_nbr_error
     SET nbr_correct = 0
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 IF (nbr_correct=0)
  GO TO exit_script
 ENDIF
 INSERT  FROM cv_operator t,
   (dummyt d  WITH seq = value(add_operator_reply->qual_cnt))
  SET t.long_text_id = add_operator_request->qual[d.seq].long_text_id, t.operator = trim(
    add_operator_request->qual[d.seq].operator), t.nbr_operands = add_operator_request->qual[d.seq].
   nbr_operands,
   t.description_2 = trim(add_operator_request->qual[d.seq].description_2), t.beg_effective_dt_tm =
   cnvtdatetime(curdate,curtime3), t.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
   t.data_status_cd =
   IF ((add_operator_request->qual[d.seq].data_status_cd > 0.0)) add_operator_request->qual[d.seq].
    data_status_cd
   ELSE reqdata->data_status_cd
   ENDIF
   , t.data_status_dt_tm = cnvtdatetime(curdate,curtime3), t.data_status_prsnl_id = reqinfo->updt_id,
   t.updt_id = reqinfo->updt_id, t.updt_dt_tm = cnvtdatetime(curdate,curtime3), t.updt_task = reqinfo
   ->updt_task,
   t.updt_applctx = reqinfo->updt_applctx, t.updt_cnt = 0, t.active_ind = add_operator_request->qual[
   d.seq].active_ind,
   t.active_status_cd =
   IF ((add_operator_request->qual[d.seq].active_status_cd > 0.0)) add_operator_request->qual[d.seq].
    active_status_cd
   ELSEIF ((add_operator_request->qual[d.seq].active_ind=true)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   , t.active_status_dt_tm = cnvtdatetime(curdate,curtime3), t.active_status_prsnl_id = reqinfo->
   updt_id,
   t.operator_id = add_operator_request->qual[d.seq].operator_id
  PLAN (d
   WHERE (add_operator_reply->qual[d.seq].status=1))
   JOIN (t)
  WITH nocounter, status(add_operator_reply->qual[d.seq].status)
 ;end insert
 SET nbr_correct = 0
 FOR (i = 1 TO add_operator_reply->qual_cnt)
   IF ((add_operator_reply->qual[i].status=1))
    SET nbr_correct = (nbr_correct+ 1)
   ELSE
    IF ((add_operator_reply->qual[i].status=0))
     IF ((add_operator_request->qual[i].allow_partial_ind != 1))
      SET failed = insert_error
      SET nbr_correct = 0
      GO TO exit_script
     ELSE
      SET add_operator_reply->qual[i].status = insert_error
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (called_by_script_server=true)
  SET reply->qual_cnt = add_operator_reply->qual_cnt
  SET stat = alterlist(reply->qual,reply->qual_cnt)
  FOR (i = 1 TO reply->qual_cnt)
   SET reply->qual[i].operator_id = add_operator_reply->qual[i].operator_id
   SET reply->qual[i].status = add_operator_reply->qual[i].status
  ENDFOR
 ENDIF
#check_failed
 IF (failed=false)
  CASE (nbr_correct)
   OF 0:
    SET reqinfo->commit_ind = false
    SET reply->status_data.status = "Z"
   OF add_operator_reply->qual_cnt:
    SET reqinfo->commit_ind = true
    SET reply->status_data.status = "S"
   ELSE
    SET reqinfo->commit_ind = true
    SET reply->status_data.status = "P"
  ENDCASE
 ELSE
  CALL echorecord(add_operator_request)
  CALL echorecord(add_operator_reply)
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
 DECLARE cv_add_operator_vrsn = vc WITH private, constant("MOD 001 BM9013 06/02/06")
END GO
