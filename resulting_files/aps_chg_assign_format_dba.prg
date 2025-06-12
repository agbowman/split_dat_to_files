CREATE PROGRAM aps_chg_assign_format:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ep_cnt = i4 WITH noconstant(0), protect
 DECLARE lf_cnt = i4 WITH noconstant(0), protect
#script
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET number_to_del = size(request->del_task_qual,5)
 SET number_to_add = size(request->add_task_qual,5)
 SET ep_cnt = size(request->ep_qual,5)
 SET lf_cnt = size(request->layout_field_qual,5)
 SET reqinfo->commit_ind = 0
 IF (number_to_del > 0)
  DELETE  FROM sign_line_dta_r sldr,
    (dummyt d  WITH seq = value(number_to_del))
   SET sldr.seq = 1
   PLAN (d)
    JOIN (sldr
    WHERE (sldr.activity_subtype_cd=request->activity_subtype_cd)
     AND (sldr.status_flag=request->status_flag)
     AND (sldr.task_assay_cd=request->del_task_qual[d.seq].task_assay_cd))
   WITH nocounter
  ;end delete
  IF (curqual != number_to_del)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Delete"
   SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_dta_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
    format_id)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (number_to_add > 0)
  INSERT  FROM sign_line_dta_r sldr,
    (dummyt d  WITH seq = value(number_to_add))
   SET sldr.activity_subtype_cd = request->activity_subtype_cd, sldr.status_flag = request->
    status_flag, sldr.format_id = request->format_id,
    sldr.task_assay_cd = request->add_task_qual[d.seq].task_assay_cd, sldr.updt_cnt = 0, sldr
    .updt_dt_tm = cnvtdatetime(curdate,curtime3),
    sldr.updt_id = reqinfo->updt_id, sldr.updt_task = reqinfo->updt_task, sldr.updt_applctx = reqinfo
    ->updt_applctx
   PLAN (d)
    JOIN (sldr)
   WITH nocounter
  ;end insert
  IF (curqual != number_to_add)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_dta_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
    format_id)
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM sign_line_ep_r sler
  PLAN (sler
   WHERE (sler.format_id=request->format_id))
  WITH nocounter
 ;end delete
 IF (ep_cnt > 0)
  INSERT  FROM sign_line_ep_r sler,
    (dummyt d  WITH seq = ep_cnt)
   SET sler.sign_line_ep_r_id = seq(reference_seq,nextval), sler.cki_source = request->ep_qual[d.seq]
    .cki_source, sler.cki_identifier = request->ep_qual[d.seq].cki_identifier,
    sler.format_id = request->format_id, sler.status_flag = request->status_flag, sler.active_ind = 1
   PLAN (d)
    JOIN (sler)
   WITH nocounter
  ;end insert
  IF (curqual != ep_cnt)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "sign_line_ep_r"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
    format_id)
   GO TO exit_script
  ENDIF
 ENDIF
 DELETE  FROM sign_line_layout_field_r slfr
  PLAN (slfr
   WHERE (slfr.format_id=request->format_id)
    AND (slfr.status_flag=request->status_flag))
  WITH nocounter
 ;end delete
 IF (lf_cnt > 0)
  INSERT  FROM sign_line_layout_field_r slfr,
    (dummyt d  WITH seq = lf_cnt)
   SET slfr.sign_line_layout_field_r_id = seq(reference_seq,nextval), slfr.format_id = request->
    format_id, slfr.ucmr_layout_field_id = request->layout_field_qual[d.seq].ucmr_layout_field_id,
    slfr.status_flag = request->status_flag, slfr.active_ind = 1
   PLAN (d)
    JOIN (slfr)
   WITH nocounter
  ;end insert
  IF (curqual != lf_cnt)
   SET stat = alter(reply->status_data.subeventstatus,1)
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Insert"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SIGN_LINE_LAYOUT_FIELD_R "
   SET reply->status_data.subeventstatus[1].targetobjectvalue = build("format_id: ",request->
    format_id)
   GO TO exit_script
  ENDIF
 ENDIF
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
#exit_script
END GO
