CREATE PROGRAM aps_upd_diagnostic_summary:dba
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE logcclerror(soperation=vc(value),stable=vc(value)) = i2 WITH protect
 DECLARE dprefixdiagsmryid = f8
 DECLARE nrequestcounter = i4 WITH noconstant(0)
 DECLARE niterator = i4 WITH noconstant(0)
 DECLARE ccclerror = vc WITH protect, noconstant(" ")
 SET nrequestcounter = size(request->qual,5)
 SET lstat = error(ccclerror,1)
 SET dprefixdiagsmryid = 0.0
 FOR (niterator = 1 TO nrequestcounter)
  IF ((request->qual[niterator].task_assay_cd=0))
   SELECT INTO "nl:"
    apds.prefix_id
    FROM ap_prefix_diag_smry apds
    WHERE (apds.prefix_id=request->qual[niterator].prefix_id)
    WITH nocounter, forupdate(apds)
   ;end select
   IF (logcclerror("SELECT","AP_PREFIX_DIAG_SMRY")=0)
    GO TO exit_script
   ENDIF
   IF (curqual > 0)
    DELETE  FROM ap_prefix_diag_smry apds
     WHERE (apds.prefix_id=request->qual[niterator].prefix_id)
     WITH nocounter
    ;end delete
    IF (logcclerror("DELETE","AP_PREFIX_DIAG_SMRY")=0)
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
  IF ((request->qual[niterator].task_assay_cd > 0))
   SELECT INTO "nl:"
    apds.prefix_id
    FROM ap_prefix_diag_smry apds
    WHERE (apds.prefix_id=request->qual[niterator].prefix_id)
    WITH nocounter, forupdate(apds)
   ;end select
   IF (logcclerror("SELECT","AP_PREFIX_DIAG_SMRY")=0)
    GO TO exit_script
   ENDIF
   IF (curqual > 0)
    UPDATE  FROM ap_prefix_diag_smry apds
     SET apds.required_ind = request->qual[niterator].required_ind, apds.task_assay_cd = request->
      qual[niterator].task_assay_cd, apds.comment_ind = request->qual[niterator].comment_ind,
      apds.comment_length_qty = request->qual[niterator].comment_length, apds.updt_cnt = (apds
      .updt_cnt+ 1), apds.updt_id = reqinfo->updt_id,
      apds.updt_task = reqinfo->updt_task, apds.updt_applctx = reqinfo->updt_applctx, apds.updt_dt_tm
       = cnvtdatetime(curdate,curtime)
     WHERE (apds.prefix_id=request->qual[niterator].prefix_id)
     WITH nocounter
    ;end update
    IF (logcclerror("UPDATE","AP_PREFIX_DIAG_SMRY")=0)
     GO TO exit_script
    ENDIF
   ENDIF
   IF (curqual=0)
    SELECT INTO "nl:"
     seq_nbr = seq(reference_seq,nextval)
     FROM dual
     DETAIL
      dprefixdiagsmryid = seq_nbr
     WITH nocounter, format
    ;end select
    INSERT  FROM ap_prefix_diag_smry apds
     SET apds.prefix_diag_smry_id = dprefixdiagsmryid, apds.prefix_id = request->qual[niterator].
      prefix_id, apds.task_assay_cd = request->qual[niterator].task_assay_cd,
      apds.required_ind = request->qual[niterator].required_ind, apds.comment_ind = request->qual[
      niterator].comment_ind, apds.comment_length_qty = request->qual[niterator].comment_length,
      apds.updt_id = reqinfo->updt_id, apds.updt_task = reqinfo->updt_task, apds.updt_applctx =
      reqinfo->updt_applctx,
      apds.updt_dt_tm = cnvtdatetime(curdate,curtime)
     WITH nocounter
    ;end insert
    IF (logcclerror("INSERT","AP_PREFIX_DIAG_SMRY")=0)
     GO TO exit_script
    ENDIF
   ENDIF
  ENDIF
 ENDFOR
 IF (nrequestcounter=0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 GO TO exit_script
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(ccclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),ccclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
END GO
