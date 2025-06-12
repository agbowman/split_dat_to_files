CREATE PROGRAM dts_ins_updt_recipient_info:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 IF ( NOT (validate(errors,0)))
  FREE RECORD errors
  RECORD errors(
    1 err_cnt = i4
    1 err[*]
      2 err_code = i4
      2 err_msg = vc
  ) WITH protect
 ENDIF
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errcnt = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nsuccess = i2 WITH private, constant(0)
 DECLARE nfailed_ccl_error = i2 WITH private, constant(1)
 DECLARE prsnl_index = i4 WITH protect, noconstant(0)
 DECLARE address_index = i4 WITH protect, noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 DECLARE request_size = i4 WITH constant(size(request->personnel_list,5))
 DECLARE item_index = i4 WITH protect, noconstant(0)
 DECLARE event_prsnl_cnt = i4 WITH protect, noconstant(0)
 DECLARE icnt = i4 WITH protect, noconstant(0)
 DECLARE geteventprsnlids(reference_nbr=vc) = null WITH protect
 DECLARE checkoneventrepstatus(null) = i4 WITH protect
 DECLARE event_rep_status = i4 WITH protect, constant(checkoneventrepstatus(null))
 DECLARE insertrows(null) = null WITH protect
 DECLARE updaterows(null) = null WITH protect
 DECLARE populaterecordsforupdate(null) = null WITH protect
 DECLARE checkforvalidprsnlid(index=i4) = null WITH protect
 DECLARE action_followup = f8 WITH constant(uar_get_code_by("MEANING",21,"FOLLOWUP"))
 DECLARE action_review = f8 WITH constant(uar_get_code_by("MEANING",21,"REVIEW"))
 FREE RECORD address
 RECORD address(
   1 address_list[*]
     2 address_hist_id = f8
     2 address_id = f8
 )
 FREE RECORD total_list
 RECORD total_list(
   1 event_prsnl_list[*]
     2 event_prsnl_id = f8
     2 action_prsnl_id = f8
     2 action_type_cd = f8
     2 address_hist_id = f8
     2 primary_ind = i2
     2 update_ind = i2
 )
 FREE RECORD update_list
 RECORD update_list(
   1 event_prsnl_list[*]
     2 event_prsnl_id = f8
     2 action_prsnl_id = f8
     2 action_type_cd = f8
     2 address_hist_id = f8
     2 primary_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 SELECT INTO "nl:"
  FROM address_hist a
  PLAN (a
   WHERE expand(icnt,1,request_size,a.address_id,request->personnel_list[icnt].address_id)
    AND a.active_ind=1)
  ORDER BY a.address_id
  HEAD REPORT
   icnt = 0, stat = alterlist(address->address_list,10)
  HEAD a.address_id
   IF (a.address_id > 0)
    icnt = (icnt+ 1)
    IF (mod(icnt,10)=0)
     stat = alterlist(address->address_list,10)
    ENDIF
    address->address_list[icnt].address_id = a.address_id, address->address_list[icnt].
    address_hist_id = a.address_hist_id
   ENDIF
  DETAIL
   IF (a.address_id > 0)
    IF ((a.address_hist_id > address->address_list[icnt].address_hist_id))
     address->address_list[icnt].address_id = a.address_id, address->address_list[icnt].
     address_hist_id = a.address_hist_id
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(address->address_list,icnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  GO TO exit_script
 ENDIF
 CALL geteventprsnlids(request->reference_nbr)
 CALL populaterecordsforupdate(null)
 CALL insertrows(null)
 CALL updaterows(null)
 FREE RECORD temp_list
 FREE RECORD update_list
 FREE RECORD address
 SUBROUTINE geteventprsnlids(reference_nbr)
  IF (textlen(trim(reference_nbr))=0)
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "GetEventPrsnlIDs"
   SET reply->status_data.subeventstatus[1].targetobjectname = "Reference Number"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "Invalid reference_number from the request structure"
   GO TO exit_script
  ENDIF
  IF (event_rep_status=1)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(event_rep->rb_list[1].prsnl_list,5)))
    PLAN (d1
     WHERE (event_rep->rb_list[1].reference_nbr=reference_nbr))
    HEAD REPORT
     icnt = 0, stat = alterlist(total_list->event_prsnl_list,10)
    DETAIL
     icnt = (icnt+ 1)
     IF (mod(icnt,10)=0)
      stat = alterlist(total_list->event_prsnl_list,10)
     ENDIF
     IF ((((event_rep->rb_list[1].prsnl_list[icnt].action_type_cd=action_followup)) OR ((event_rep->
     rb_list[1].prsnl_list[icnt].action_type_cd=action_review))) )
      total_list->event_prsnl_list[icnt].event_prsnl_id = event_rep->rb_list[1].prsnl_list[icnt].
      event_prsnl_id, total_list->event_prsnl_list[icnt].action_prsnl_id = event_rep->rb_list[1].
      prsnl_list[icnt].action_prsnl_id, total_list->event_prsnl_list[icnt].action_type_cd = event_rep
      ->rb_list[1].prsnl_list[icnt].action_type_cd,
      prsnl_index = locateval(i,1,size(request->personnel_list,5),total_list->event_prsnl_list[icnt].
       action_prsnl_id,request->personnel_list[i].action_prsnl_id)
      IF (prsnl_index > 0)
       total_list->event_prsnl_list[icnt].primary_ind = request->personnel_list[prsnl_index].
       primary_ind
       IF ((request->personnel_list[prsnl_index].address_hist_id=0))
        address_index = locateval(i,1,size(address->address_list,5),request->personnel_list[
         prsnl_index].address_id,address->address_list[i].address_id)
        IF (address_index > 0)
         total_list->event_prsnl_list[icnt].address_hist_id = address->address_list[address_index].
         address_hist_id
        ENDIF
        request->personnel_list[prsnl_index].action_prsnl_id = 0
       ENDIF
       total_list->event_prsnl_list[icnt].update_ind = 0
      ENDIF
      CALL checkforvalidprsnlid(icnt)
     ENDIF
    FOOT REPORT
     stat = alterlist(total_list->event_prsnl_list,icnt)
    WITH nocounter
   ;end select
  ENDIF
 END ;Subroutine
 SUBROUTINE checkforvalidprsnlid(index)
   IF ((total_list->event_prsnl_list[index].event_prsnl_id <= 0))
    SET reply->status_data.subeventstatus[1].operationstatus = "EVENT PRSNL ID"
    SET reply->status_data.subeventstatus[1].operationname = "GetEventPrsnlIDS"
    SET reply->status_data.subeventstatus[1].targetobjectname = "Event_Prsnl_Id"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid event_prsnl_id value"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE checkoneventrepstatus(null)
   DECLARE event_cnt = i4 WITH private, noconstant(0)
   IF (validate(event_rep))
    IF ((event_rep->sb.severitycd > 2))
     SET reply->status_data.subeventstatus[1].operationstatus = "INVALID EVENT REPLY"
     SET reply->status_data.subeventstatus[1].operationname = "CheckOnEventRepStatus"
     SET reply->status_data.subeventstatus[1].targetobjectname = "CheckOnEventRepStatus"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "CheckOnEventRepStatus"
     RETURN(0)
    ENDIF
    SET event_cnt = size(event_rep->rb_list,5)
    IF (event_cnt=0)
     RETURN(0)
    ENDIF
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE populaterecordsforupdate(null)
   DECLARE updt_count = i4 WITH private, noconstant(0)
   DECLARE count2 = i4 WITH private, noconstant(0)
   SET icnt = size(total_list->event_prsnl_list,5)
   SELECT INTO "nl:"
    FROM dts_recipient dr
    PLAN (dr
     WHERE expand(i,1,icnt,dr.event_prsnl_id,total_list->event_prsnl_list[i].event_prsnl_id))
    HEAD REPORT
     stat = alterlist(update_list->event_prsnl_list,10), updt_count = 1
    DETAIL
     IF (mod(updt_count,10)=0)
      stat = alterlist(update_list->event_prsnl_list,10)
     ENDIF
     index = locateval(i,1,icnt,dr.event_prsnl_id,total_list->event_prsnl_list[i].event_prsnl_id)
     IF (index > 0)
      total_list->event_prsnl_list[index].update_ind = 1, update_list->event_prsnl_list[updt_count].
      event_prsnl_id = total_list->event_prsnl_list[index].event_prsnl_id, update_list->
      event_prsnl_list[updt_count].action_prsnl_id = total_list->event_prsnl_list[index].
      action_prsnl_id,
      update_list->event_prsnl_list[updt_count].action_type_cd = total_list->event_prsnl_list[index].
      action_type_cd, update_list->event_prsnl_list[updt_count].address_hist_id = total_list->
      event_prsnl_list[index].address_hist_id, update_list->event_prsnl_list[updt_count].primary_ind
       = total_list->event_prsnl_list[index].primary_ind,
      updt_count = (updt_count+ 1)
     ENDIF
    FOOT REPORT
     stat = alterlist(update_list->event_prsnl_list,updt_count)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE insertrows(null)
   DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
   DECLARE prsnl_index = i4 WITH protect, noconstant(0)
   DECLARE new_recipient_id = f8 WITH protect, noconstant(0)
   DECLARE new_event_prsnl_id = f8 WITH protect, noconstant(0)
   SET prsnl_cnt = size(total_list->event_prsnl_list,5)
   FOR (prsnl_index = 1 TO prsnl_cnt)
     IF ((total_list->event_prsnl_list[prsnl_index].event_prsnl_id > 0)
      AND (total_list->event_prsnl_list[prsnl_index].update_ind=0))
      INSERT  FROM dts_recipient d
       SET d.dts_recipient_id = seq(dts_seq,nextval), d.event_prsnl_id = total_list->
        event_prsnl_list[prsnl_index].event_prsnl_id, d.address_hist_id = total_list->
        event_prsnl_list[prsnl_index].address_hist_id,
        d.primary_ind = total_list->event_prsnl_list[prsnl_index].primary_ind, d.updt_dt_tm =
        cnvtdatetime(curdate,curtime3), d.updt_cnt = 1,
        d.updt_id = reqinfo->updt_id, d.updt_task = reqinfo->updt_task, d.updt_applctx = reqinfo->
        updt_applctx
       WITH nocounter
      ;end insert
     ENDIF
   ENDFOR
   IF (curqual=0)
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "INSERT RECIPIENT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DTS_RECIPIENT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to insert the recipient info in DTS_RECIPIENT table"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE updaterows(null)
   DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
   DECLARE prsnl_index = i4 WITH protect, noconstant(0)
   SET prsnl_cnt = size(update_list->event_prsnl_list,5)
   FOR (prsnl_index = 1 TO prsnl_cnt)
     UPDATE  FROM dts_recipient d
      SET d.event_prsnl_id = update_list->event_prsnl_list[prsnl_index].event_prsnl_id, d
       .address_hist_id = update_list->event_prsnl_list[prsnl_index].address_hist_id, d.primary_ind
        = update_list->event_prsnl_list[prsnl_index].primary_ind,
       d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = (d.updt_cnt+ 1)
      WHERE (d.event_prsnl_id=update_list->event_prsnl_list[prsnl_index].event_prsnl_id)
      WITH nocounter
     ;end update
   ENDFOR
   IF (curqual=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE RECIPIENT"
    SET reply->status_data.subeventstatus[1].targetobjectname = "DTS_RECIPIENT"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Failed to update the recipient info in DTS_RECIPIENT table"
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 CALL echo("***********************************")
 CALL echo("***   Start of error checking   ***")
 CALL echo("***********************************")
 SET errcode = error(errmsg,0)
 WHILE (errcode != 0
  AND errcnt < 6)
   SET errcnt = (errcnt+ 1)
   IF (errcnt > size(errors->err,5))
    SET stat = alterlist(errors->err,(errcnt+ 9))
   ENDIF
   SET errors->err[errcnt].err_code = errcode
   SET errors->err[errcnt].err_msg = errmsg
   SET errors->err_cnt = errcnt
   SET errcode = error(errmsg,0)
 ENDWHILE
 SET stat = alterlist(errors->err,errcnt)
 IF (errcnt > 0)
  SET nscriptstatus = nfailed_ccl_error
  CALL echorecord(errors)
 ELSE
  SET nscriptstatus = nsuccess
 ENDIF
 CALL echo("*************************************")
 CALL echo("***   Start of error processing   ***")
 CALL echo("*************************************")
 IF (nscriptstatus != nsuccess)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  CASE (nscriptstatus)
   OF nfailed_ccl_error:
    SET reply->status_data.subeventstatus[1].operationname = "CCL ERROR"
    SET reply->status_data.subeventstatus[1].targetobjectname = "dts_ins_updt_recipient_info"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = errors->err[1].err_msg
  ENDCASE
 ELSEIF ((reply->status_data.subeventstatus[1].operationname="EVENT PRSNL ID"))
  SET reply->status_data.status = "Z"
 ELSEIF ((reply->status_data.subeventstatus[1].operationname="INVALID EVENT REPLY"))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
