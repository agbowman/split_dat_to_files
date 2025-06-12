CREATE PROGRAM cps_ens_xdoc_note:dba
 IF (validate(reply,"0")="0")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
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
   SET reply->cps_error.cnt = (reply->cps_error.cnt+ 1)
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
 IF (size(request->notes,5)=0)
  CALL cps_add_error(cps_insuf_data,cps_script_fail,"No notes specified",cps_insuf_data_msg,0,
   0,0)
  GO TO exit_script
 ENDIF
 RECORD updt_meta_req(
   1 xdocs[*]
     2 si_xdoc_metadata_id = f8
     2 mdoc_event_id = f8
     2 doc_event_id = f8
 )
 RECORD updt_meta_rep(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
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
 DECLARE checkoneventrepstatus(null) = i2 WITH protect
 DECLARE geteventid(contributor_cd=f8,reference_nbr=vc) = f8 WITH protect
 DECLARE number_notes = i4 WITH protect, constant(size(request->notes,5))
 DECLARE event_rep_status = i2 WITH protect, constant(checkoneventrepstatus(null))
 DECLARE failed = i2 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = vc WITH public, noconstant(fillstring(150," "))
 DECLARE stablename = vc WITH public, noconstant(fillstring(50," "))
 DECLARE suid = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF (event_rep_status=0)
  SET failed = 1
  GO TO exit_script
 ENDIF
 SET stat = alterlist(updt_meta_req->xdocs,number_notes)
 FOR (note_index = 1 TO number_notes)
   SET updt_meta_req->xdocs[note_index].si_xdoc_metadata_id = request->notes[note_index].
   si_xdoc_metadata_id
   SET updt_meta_req->xdocs[note_index].mdoc_event_id = geteventid(request->notes[note_index].
    contributor_cd,request->notes[note_index].mdoc_reference_nbr)
   IF (failed=1)
    GO TO exit_script
   ENDIF
   SET updt_meta_req->xdocs[note_index].doc_event_id = geteventid(request->notes[note_index].
    contributor_cd,request->notes[note_index].doc_reference_nbr)
   IF (failed=1)
    GO TO exit_script
   ENDIF
 ENDFOR
 SET imetadatacnt = size(updt_meta_req->xdocs,5)
 IF (imetadatacnt=0)
  SET failed = 1
  GO TO exit_script
 ENDIF
 EXECUTE si_upt_xdoc_metadata_event  WITH replace("REQUEST","UPDT_META_REQ"), replace("REPLY",
  "UPDT_META_REP")
 IF ((updt_meta_rep->status_data.status="F"))
  SET failed = 1
  FOR (x = 1 TO updt_meta_rep->cps_error.cnt)
    CALL cps_add_error(updt_meta_rep->cps_error.data[x].code,updt_meta_rep->cps_error.data[x].
     severity_level,updt_meta_rep->cps_error.data[x].supp_err_txt,updt_meta_rep->cps_error.data[x].
     def_msg,updt_meta_rep->cps_error.data[x].row_data.lvl_1_idx,
     updt_meta_rep->cps_error.data[x].row_data.lvl_2_idx,updt_meta_rep->cps_error.data[x].row_data.
     lvl_3_idx)
  ENDFOR
  SET serrmsg = updt_meta_rep->status_data.subeventstatus[1].targetobjectvalue
 ENDIF
#exit_script
 IF (failed=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  IF (textlen(trim(serrmsg)) > 0)
   SET reply->status_data.subeventstatus[1].operationstatus = updt_meta_rep->status_data.
   subeventstatus[1].operationstatus
   SET reply->status_data.subeventstatus[1].operationname = updt_meta_rep->status_data.
   subeventstatus[1].operationname
   SET reply->status_data.subeventstatus[1].targetobjectname = updt_meta_rep->status_data.
   subeventstatus[1].targetobjectname
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  ENDIF
  CALL echorecord(request)
 ENDIF
 FREE RECORD updt_meta_req
 FREE RECORD updt_meta_rep
 SUBROUTINE checkoneventrepstatus(null)
   DECLARE event_cnt = i4 WITH private, noconstant(0)
   IF (validate(event_rep))
    IF ((event_rep->sb.severitycd > 0))
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"Event Server Failed on ensure",cps_insert_msg,0,
      0,0)
     RETURN(0)
    ENDIF
    SET event_cnt = size(event_rep->rb_list,5)
    IF (event_cnt=0)
     SET failed = 1
     CALL cps_add_error(cps_insert,cps_script_fail,"No events in the reply",cps_insert_msg,0,
      0,0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE geteventid(contributor_cd,reference_nbr)
   DECLARE event_id = f8 WITH protect, noconstant(0.0)
   IF (textlen(trim(reference_nbr))=0)
    RETURN(event_id)
   ENDIF
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(event_rep->rb_list,5)))
    PLAN (d1
     WHERE (event_rep->rb_list[d1.seq].contributor_system_cd=contributor_cd)
      AND (event_rep->rb_list[d1.seq].reference_nbr=reference_nbr))
    DETAIL
     event_id = event_rep->rb_list[d1.seq].event_id
    WITH nocounter
   ;end select
   RETURN(event_id)
 END ;Subroutine
END GO
