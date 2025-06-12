CREATE PROGRAM doc_ens_dqr:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 cps_error
      2 cnt = i4
      2 data[*]
        3 code = i4
        3 severity_level = i4
        3 supp_err_txt = c32
        3 def_msg = vc
        3 row_data
          4 lvl_1_idx = i4
          4 lvl_2_idx = i4
          4 lvl_3_idx = i4
  )
 ENDIF
 DECLARE cps_lock = i4 WITH public, constant(100)
 DECLARE cps_no_seq = i4 WITH public, constant(101)
 DECLARE cps_updt_cnt = i4 WITH public, constant(102)
 DECLARE cps_insuf_data = i4 WITH public, constant(103)
 DECLARE cps_update = i4 WITH public, constant(104)
 DECLARE cps_insert = i4 WITH public, constant(105)
 DECLARE cps_delete = i4 WITH public, constant(106)
 DECLARE cps_select = i4 WITH public, constant(107)
 DECLARE cps_auth = i4 WITH public, constant(108)
 DECLARE cps_inval_data = i4 WITH public, constant(109)
 DECLARE cps_ens_note_story_not_locked = i4 WITH public, constant(110)
 DECLARE cps_lock_msg = c33 WITH public, constant("Failed to lock all requested rows")
 DECLARE cps_no_seq_msg = c34 WITH public, constant("Failed to get next sequence number")
 DECLARE cps_updt_cnt_msg = c28 WITH public, constant("Failed to match update count")
 DECLARE cps_insuf_data_msg = c38 WITH public, constant("Request did not supply sufficient data")
 DECLARE cps_update_msg = c24 WITH public, constant("Failed on update request")
 DECLARE cps_insert_msg = c24 WITH public, constant("Failed on insert request")
 DECLARE cps_delete_msg = c24 WITH public, constant("Failed on delete request")
 DECLARE cps_select_msg = c24 WITH public, constant("Failed on select request")
 DECLARE cps_auth_msg = c34 WITH public, constant("Failed on authorization of request")
 DECLARE cps_inval_data_msg = c35 WITH public, constant("Request contained some invalid data")
 DECLARE cps_success = i4 WITH public, constant(0)
 DECLARE cps_success_info = i4 WITH public, constant(1)
 DECLARE cps_success_warn = i4 WITH public, constant(2)
 DECLARE cps_deadlock = i4 WITH public, constant(3)
 DECLARE cps_script_fail = i4 WITH public, constant(4)
 DECLARE cps_sys_fail = i4 WITH public, constant(5)
 SUBROUTINE cps_add_error(cps_errcode,severity_level,supp_err_txt,def_msg,idx1,idx2,idx3)
   SET reply->cps_error.cnt += 1
   SET errcnt = reply->cps_error.cnt
   SET stat = alterlist(reply->cps_error.data,errcnt)
   SET reply->cps_error.data[errcnt].code = cps_errcode
   SET reply->cps_error.data[errcnt].severity_level = severity_level
   SET reply->cps_error.data[errcnt].supp_err_txt = supp_err_txt
   SET reply->cps_error.data[errcnt].def_msg = def_msg
   SET reply->cps_error.data[errcnt].row_data.lvl_1_idx = idx1
   SET reply->cps_error.data[errcnt].row_data.lvl_2_idx = idx2
   SET reply->cps_error.data[errcnt].row_data.lvl_3_idx = idx3
 END ;Subroutine
 IF (validate(reply->status_data.status)=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"reply doesn't contain status block",
   cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 FREE RECORD updatedqrrequest
 RECORD updatedqrrequest(
   1 event_id = f8
   1 temp_ref_ident = vc
 )
 FREE RECORD updatedqrreply
 RECORD updatedqrreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (geteventids(reference_nbr=vc) =f8 WITH protect)
   DECLARE event_id = f8 WITH protect, noconstant(0.0)
   IF (textlen(trim(reference_nbr))=0)
    RETURN(event_id)
   ENDIF
   IF (event_rep_status=1)
    SELECT INTO "nl:"
     FROM (dummyt d1  WITH seq = value(size(event_rep->rb_list,5)))
     PLAN (d1
      WHERE (event_rep->rb_list[d1.seq].reference_nbr=reference_nbr))
     DETAIL
      event_id = event_rep->rb_list[d1.seq].event_id
     WITH nocounter
    ;end select
   ENDIF
   RETURN(event_id)
 END ;Subroutine
 DECLARE g_failure = c1 WITH public, noconstant("F")
 DECLARE request_note_count = i4 WITH protect, constant(size(request->notes,5))
 DECLARE event_rep_status = i2 WITH protect, constant(1)
 CALL echo("====================== Starting doc_ens_dqr.prg =================")
 IF (request_note_count=0)
  SET g_failure = "T"
  CALL cps_add_error(cps_inval_data,cps_script_fail,"REQUEST_NOTE_COUNT 0",cps_inval_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 DECLARE isessionidx = i4 WITH private, noconstant(0)
 FOR (isessionidx = 1 TO request_note_count)
  CALL associateref(isessionidx)
  IF (g_failure="T")
   GO TO exit_script
  ENDIF
 ENDFOR
 SUBROUTINE associateref(isessionidx)
   DECLARE r_event_id = f8 WITH private, noconstant(0.0)
   SET r_event_id = geteventids(request->notes[isessionidx].reference_nbr)
   SET updatedqrrequest->event_id = r_event_id
   SET updatedqrrequest->temp_ref_ident = request->notes[isessionidx].reference_dqr
   EXECUTE eso_update_dqr_document_ids  WITH replace("REQUEST",updatedqrrequest), replace("REPLY",
    updatedqrreply)
   IF ((updatedqrreply->status_data.status != "S"))
    CALL cps_add_error(cps_update,cps_script_fail,"AssociateRef",cps_update_msg,isessionidx,
     0,0)
    RETURN
   ENDIF
 END ;Subroutine
#exit_script
 IF (g_failure="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
  CALL echorecord(request,"doc_ens_dqr_failure_log",1)
  IF (validate(event_rep) != 0)
   CALL echorecord(event_rep,"doc_ens_dqr_failure_log",1)
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
