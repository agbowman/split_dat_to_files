CREATE PROGRAM bb_upd_worklist:dba
 RECORD reply(
   1 worklist_list[*]
     2 worklist_id = f8
     2 worklist_object_key = i4
     2 worklist_detail_list[*]
       3 worklist_detail_id = f8
       3 worklist_detail_object_key = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET modify = predeclare
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lwidx = i4 WITH public, noconstant(0)
 DECLARE lwdidx = i4 WITH public, noconstant(0)
 DECLARE dnextseqn = f8 WITH public, noconstant(0.0)
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE select_ok_ind = i2 WITH protect, noconstant(0)
 IF (size(request->worklist_list,5) > 0)
  FOR (lwidx = 1 TO size(request->worklist_list,5))
    IF ((request->worklist_list[lwidx].save_flag=2))
     SELECT INTO "nl:"
      FROM bb_worklist w
      WHERE (w.worklist_id=request->worklist_list[lwidx].worklist_id)
       AND (w.updt_cnt=request->worklist_list[lwidx].updt_cnt)
      WITH nocounter, forupdate(w)
     ;end select
     IF (curqual > 0)
      UPDATE  FROM bb_worklist w
       SET w.worklist_name = request->worklist_list[lwidx].worklist_name, w.worklist_name_key =
        request->worklist_list[lwidx].worklist_name_key, w.worklist_name_key_nls = request->
        worklist_list[lwidx].worklist_name_key,
        w.create_dt_tm = cnvtdatetime(request->worklist_list[lwidx].create_dt_tm), w.create_prsnl_id
         = request->worklist_list[lwidx].create_prsnl_id, w.qc_group_id = request->worklist_list[
        lwidx].qc_group_id,
        w.test_group_id = request->worklist_list[lwidx].test_group_id, w.download_ind = request->
        worklist_list[lwidx].download_ind, w.last_download_dt_tm = cnvtdatetime(request->
         worklist_list[lwidx].last_download_dt_tm),
        w.updt_applctx = reqinfo->updt_applctx, w.updt_cnt = (request->worklist_list[lwidx].updt_cnt
        + 1), w.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        w.updt_id = reqinfo->updt_id, w.updt_task = reqinfo->updt_task
       WHERE (w.worklist_id=request->worklist_list[lwidx].worklist_id)
       WITH nocounter
      ;end update
     ELSE
      CALL subevent_add("UPDATE","F","BB_UPD_WORKLIST",
       "Rows to update have not been locked - BB_WORKLIST.")
      GO TO exit_script
     ENDIF
     SET lstat = alterlist(reply->worklist_list,lwidx)
     SET reply->worklist_list[lwidx].worklist_id = request->worklist_list[lwidx].worklist_id
     SET reply->worklist_list[lwidx].worklist_object_key = request->worklist_list[lwidx].
     worklist_object_key
     CALL check_worklist_details(0)
    ELSEIF ((request->worklist_list[lwidx].save_flag=1))
     SET dnextseqn = 0.0
     CALL getnextpathnetseqn(0)
     CALL echo(build("dNextSeqn ::",dnextseqn))
     INSERT  FROM bb_worklist w
      SET w.create_dt_tm = cnvtdatetime(request->worklist_list[lwidx].create_dt_tm), w
       .create_prsnl_id = request->worklist_list[lwidx].create_prsnl_id, w.download_ind = request->
       worklist_list[lwidx].download_ind,
       w.last_download_dt_tm = cnvtdatetime(request->worklist_list[lwidx].last_download_dt_tm), w
       .qc_group_id = request->worklist_list[lwidx].qc_group_id, w.test_group_id = request->
       worklist_list[lwidx].test_group_id,
       w.worklist_id = dnextseqn, w.worklist_name = request->worklist_list[lwidx].worklist_name, w
       .worklist_name_key = request->worklist_list[lwidx].worklist_name_key,
       w.worklist_name_key_nls = request->worklist_list[lwidx].worklist_name_key, w.updt_applctx =
       reqinfo->updt_applctx, w.updt_cnt = request->worklist_list[lwidx].updt_cnt,
       w.updt_dt_tm = cnvtdatetime(curdate,curtime3), w.updt_id = reqinfo->updt_id, w.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     SET lerrorcode = error(serrormsg,1)
     IF (lerrorcode=0)
      SET lstat = alterlist(reply->worklist_list,lwidx)
      SET reply->worklist_list[lwidx].worklist_id = dnextseqn
      SET reply->worklist_list[lwidx].worklist_object_key = request->worklist_list[lwidx].
      worklist_object_key
     ELSE
      CALL subevent_add("INSERT","F","BB_UPD_WORKLIST","Failure to insert into BB_WORKLIST table.")
      GO TO exit_script
     ENDIF
     CALL check_worklist_details(0)
    ELSEIF ((request->worklist_list[lwidx].save_flag=3))
     SET lstat = alterlist(reply->worklist_list,lwidx)
     CALL check_worklist_details(0)
     DELETE  FROM bb_worklist w
      WHERE (w.worklist_id=request->worklist_list[lwidx].worklist_id)
      WITH nocounter
     ;end delete
     IF (curqual > 0)
      SET lstat = alterlist(reply->worklist_list,lwidx)
      SET reply->worklist_list[lwidx].worklist_id = request->worklist_list[lwidx].worklist_id
      SET reply->worklist_list[lwidx].worklist_object_key = request->worklist_list[lwidx].
      worklist_object_key
     ELSE
      CALL subevent_add("INSERT","F","BB_UPD_WORKLIST","Failure to DELETE from BB_WORKLIST table.")
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  SET select_ok_ind = 1
 ENDIF
 DECLARE getnextpathnetseqn() = f8
 SUBROUTINE getnextpathnetseqn(null)
  SELECT INTO "nl:"
   seq = seq(pathnet_seq,nextval)
   FROM dual
   HEAD REPORT
    dnextseqn = 0.0
   DETAIL
    dnextseqn = seq
   WITH format, nocounter
  ;end select
  IF (dnextseqn > 0)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 DECLARE insert_worklist_details() = i2
 SUBROUTINE insert_worklist_details(null)
   SET dnextseqn = 0.0
   CALL getnextpathnetseqn(0)
   CALL echo(build("dNextSeqn ::",dnextseqn))
   IF (dnextseqn=0.0)
    CALL subevent_add("SELECT","F","BB_UPD_WORKLIST","Failure to retrieve next PATHNET_SEQ.")
    RETURN(0)
   ELSE
    INSERT  FROM bb_worklist_detail wd
     SET wd.worklist_detail_id = dnextseqn, wd.worklist_id = reply->worklist_list[lwidx].worklist_id,
      wd.order_id = request->worklist_list[lwidx].worklist_detail_list[lwdidx].order_id,
      wd.updt_applctx = reqinfo->updt_applctx, wd.updt_cnt = request->worklist_list[lwidx].
      worklist_detail_list[lwdidx].updt_cnt, wd.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      wd.updt_id = request->worklist_list[lwidx].create_prsnl_id, wd.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    IF (curqual > 0)
     SET lstat = alterlist(reply->worklist_list[lwidx].worklist_detail_list,size(request->
       worklist_list[lwidx].worklist_detail_list,5))
     SET reply->worklist_list[lwidx].worklist_detail_list[lwdidx].worklist_detail_id = dnextseqn
     SET reply->worklist_list[lwidx].worklist_detail_list[lwdidx].worklist_detail_object_key =
     request->worklist_list[lwidx].worklist_detail_list[lwdidx].worklist_detail_object_key
    ELSE
     CALL subevent_add("INSERT","F","BB_UPD_WORKLIST",
      "Failure to insert into BB_WORKLIST_DETAIL table.")
     RETURN(0)
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE delete_worklist_details() = i2
 SUBROUTINE delete_worklist_details(null)
   DELETE  FROM bb_worklist_detail wd
    WHERE (wd.worklist_detail_id=request->worklist_list[lwidx].worklist_detail_list[lwdidx].
    worklist_detail_id)
    WITH nocounter
   ;end delete
   IF (curqual > 0)
    SET lstat = alterlist(reply->worklist_list[lwidx].worklist_detail_list,size(request->
      worklist_list[lwidx].worklist_detail_list,5))
    SET reply->worklist_list[lwidx].worklist_detail_list[lwdidx].worklist_detail_id = request->
    worklist_list[lwidx].worklist_detail_list[lwdidx].worklist_detail_id
    SET reply->worklist_list[lwidx].worklist_detail_list[lwdidx].worklist_detail_object_key = request
    ->worklist_list[lwidx].worklist_detail_list[lwdidx].worklist_detail_object_key
   ELSE
    CALL subevent_add("DELETE","F","BB_UPD_WORKLIST",
     "Failure to DELETE from BB_WORKLIST_DETAIL table.")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE check_worklist_details() = i2
 SUBROUTINE check_worklist_details(null)
  IF (size(request->worklist_list[lwidx].worklist_detail_list,5) > 0)
   FOR (lwdidx = 1 TO size(request->worklist_list[lwidx].worklist_detail_list,5))
     IF ((request->worklist_list[lwidx].worklist_detail_list[lwdidx].save_flag=1))
      CALL insert_worklist_details(0)
     ELSEIF ((request->worklist_list[lwidx].worklist_detail_list[lwdidx].save_flag=3))
      CALL delete_worklist_details(0)
     ENDIF
   ENDFOR
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 IF (select_ok_ind=1)
  COMMIT
  SET reply->status_data.status = "S"
  CALL subevent_add("SCRIPT","S","BB_UPD_WORKLIST","Successful.")
 ELSE
  ROLLBACK
  SET reply->status_data.status = "F"
 ENDIF
END GO
