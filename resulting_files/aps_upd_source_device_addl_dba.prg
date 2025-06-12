CREATE PROGRAM aps_upd_source_device_addl:dba
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
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 RECORD unique_vals(
   1 qual[*]
     2 id = f8
 )
 DECLARE logcclerror(soperation=vc,stablename=vc) = i2 WITH protect
 DECLARE script_name = c19 WITH constant("bb_upd_label_params")
 DECLARE insert_ind = i2 WITH constant(1)
 DECLARE update_ind = i2 WITH constant(2)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE nidx = i4 WITH protect, noconstant(0)
 DECLARE nsourcedeviceidxhold = i4 WITH protect, noconstant(0)
 DECLARE nnbraddlparams = i2 WITH protect, noconstant(0)
 DECLARE naddcount = i2 WITH protect, noconstant(0)
 DECLARE nuniquevalsidx = i4 WITH protect, noconstant(0)
 DECLARE scclerror = vc WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SET nnbraddlparams = size(request->source_device_params,5)
 IF (nnbraddlparams > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = nnbraddlparams),
    ap_source_device_addl asda
   PLAN (d)
    JOIN (asda
    WHERE (asda.source_device_cd=request->source_device_params[d.seq].source_device_cd)
     AND asda.source_device_cd > 0)
   DETAIL
    IF ((request->source_device_params[d.seq].save_flag=insert_ind))
     request->source_device_params[d.seq].save_flag = update_ind, request->source_device_params[d.seq
     ].ap_source_device_addl_id = asda.ap_source_device_addl_id
    ENDIF
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","AP_SOURCE_DEVICE_ADDL")=0)
   GO TO exit_script
  ENDIF
  SET naddcount = 0
  FOR (nidx = 1 TO nnbraddlparams)
    IF ((request->source_device_params[nidx].save_flag=insert_ind))
     SET naddcount = (naddcount+ 1)
    ENDIF
  ENDFOR
  IF (naddcount > 0)
   SET stat = alterlist(unique_vals->qual,naddcount)
   EXECUTE dm2_dar_get_bulk_seq "unique_vals->qual", naddcount, "ID",
   1, "reference_seq"
   IF ((m_dm2_seq_stat->n_status != 1))
    CALL subevent_add(build("Bulk seq script call"),"F",build("dm2_dar_get_bulk_seq"),m_dm2_seq_stat
     ->s_error_msg)
    GO TO exit_script
   ENDIF
   SET nuniquevalsidx = 0
   FOR (nidx = 1 TO nnbraddlparams)
     IF ((request->source_device_params[nidx].save_flag=insert_ind))
      SET nuniquevalsidx = (nuniquevalsidx+ 1)
      SET request->source_device_params[nidx].ap_source_device_addl_id = unique_vals->qual[
      nuniquevalsidx].id
     ENDIF
   ENDFOR
   FREE SET unique_vals
   FREE SET m_dm2_seq_stat
   INSERT  FROM (dummyt d  WITH seq = nnbraddlparams),
     ap_source_device_addl asda
    SET asda.ap_source_device_addl_id = request->source_device_params[d.seq].ap_source_device_addl_id,
     asda.device_password = request->source_device_params[d.seq].device_password, asda
     .device_username = request->source_device_params[d.seq].device_username,
     asda.network_share_path = request->source_device_params[d.seq].network_share_path, asda
     .source_device_cd = request->source_device_params[d.seq].source_device_cd, asda
     .source_device_url = request->source_device_params[d.seq].source_device_url,
     asda.image_server_url = request->source_device_params[d.seq].image_server_url, asda.updt_applctx
      = reqinfo->updt_applctx, asda.updt_cnt = 0,
     asda.updt_dt_tm = cnvtdatetime(curdate,curtime), asda.updt_id = reqinfo->updt_id, asda.updt_task
      = reqinfo->updt_task
    PLAN (d
     WHERE (request->source_device_params[d.seq].save_flag=insert_ind))
     JOIN (asda)
    WITH nocounter
   ;end insert
   IF (logcclerror("INSERT","AP_SOURCE_DEVICE_ADDL")=0)
    GO TO exit_script
   ENDIF
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = nnbraddlparams),
    ap_source_device_addl asda
   PLAN (d)
    JOIN (asda
    WHERE (asda.ap_source_device_addl_id=request->source_device_params[d.seq].
    ap_source_device_addl_id)
     AND (update_ind=request->source_device_params[d.seq].save_flag))
   WITH nocounter, forupdate(asda)
  ;end select
  IF (logcclerror("LOCK","AP_SOURCE_DEVICE_ADDL")=0)
   GO TO exit_script
  ENDIF
  IF (curqual > 0)
   UPDATE  FROM (dummyt d  WITH seq = nnbraddlparams),
     ap_source_device_addl asda
    SET asda.ap_source_device_addl_id = request->source_device_params[d.seq].ap_source_device_addl_id,
     asda.device_password = request->source_device_params[d.seq].device_password, asda
     .device_username = request->source_device_params[d.seq].device_username,
     asda.network_share_path = request->source_device_params[d.seq].network_share_path, asda
     .source_device_cd = request->source_device_params[d.seq].source_device_cd, asda
     .source_device_url = request->source_device_params[d.seq].source_device_url,
     asda.image_server_url = request->source_device_params[d.seq].image_server_url, asda.updt_applctx
      = reqinfo->updt_applctx, asda.updt_cnt = (asda.updt_cnt+ 1),
     asda.updt_dt_tm = cnvtdatetime(curdate,curtime), asda.updt_id = reqinfo->updt_id, asda.updt_task
      = reqinfo->updt_task
    PLAN (d)
     JOIN (asda
     WHERE (asda.ap_source_device_addl_id=request->source_device_params[d.seq].
     ap_source_device_addl_id)
      AND (update_ind=request->source_device_params[d.seq].save_flag))
    WITH nocounter
   ;end update
   IF (logcclerror("UPDATE","AP_SOURCE_DEVICE_ADDL")=0)
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 GO TO set_status
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(scclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),scclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
