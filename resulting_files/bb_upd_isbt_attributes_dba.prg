CREATE PROGRAM bb_upd_isbt_attributes:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE attribute_cnt = i4 WITH noconstant(0)
 DECLARE attribute_idx = i4 WITH noconstant(0)
 DECLARE attribute_pos = i4 WITH noconstant(0)
 DECLARE error_check = i4 WITH noconstant(0)
 DECLARE error_message = c132 WITH noconstant(fillstring(132," "))
 DECLARE inserted_flag = i2 WITH noconstant(0)
 DECLARE inserted_idx = i4 WITH noconstant(0)
 DECLARE new_pathnet_seq = f8 WITH noconstant(0.0)
 SET reply->status_data.status = "Z"
 SET attribute_cnt = size(request->attribute_list,5)
 IF (attribute_cnt > 0)
  SELECT INTO "nl:"
   attr.standard_display
   FROM bb_isbt_attribute attr
   PLAN (attr
    WHERE expand(attribute_idx,1,attribute_cnt,attr.standard_display,request->attribute_list[
     attribute_idx].standard_display))
   DETAIL
    attribute_pos = locateval(attribute_idx,1,attribute_cnt,attr.standard_display,request->
     attribute_list[attribute_idx].standard_display), request->attribute_list[attribute_idx].
    exists_flag = 1
   WITH nocounter
  ;end select
  FOR (attribute_idx = 1 TO attribute_cnt)
    IF ((request->attribute_list[attribute_idx].exists_flag=0))
     SET attribute_pos = locateval(inserted_idx,1,attribute_cnt,request->attribute_list[attribute_idx
      ].standard_display,request->attribute_list[inserted_idx].standard_display)
     IF ((request->attribute_list[attribute_pos].exists_flag=0))
      SELECT INTO "nl:"
       seqn = seq(pathnet_seq,nextval)
       FROM dual
       DETAIL
        new_pathnet_seq = seqn
       WITH format, nocounter
      ;end select
      INSERT  FROM bb_isbt_attribute attr
       SET attr.attribute_group = request->attribute_list[attribute_idx].attribute_group, attr
        .standard_display = request->attribute_list[attribute_idx].standard_display, attr
        .label_display = request->attribute_list[attribute_idx].label_display,
        attr.bb_isbt_attribute_id = new_pathnet_seq, attr.active_ind = 1, attr.updt_id = reqinfo->
        updt_id,
        attr.updt_applctx = reqinfo->updt_applctx, attr.updt_task = reqinfo->updt_task, attr
        .active_status_prsnl_id = reqinfo->updt_id,
        attr.active_status_dt_tm = cnvtdatetime(curdate,curtime)
       WITH nocounter
      ;end insert
      SET error_check = error(error_message,0)
      IF (error_check > 0)
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus.operationname = "Insert bb_isbt_attribute"
       SET reply->status_data.subeventstatus.operationstatus = cnvtstring(error_check)
       SET reply->status_data.subeventstatus.targetobjectname = "bb_upd_isbt_attribute"
       SET reply->status_data.subeventstatus.targetobjectvalue = error_message
       GO TO exit_script
      ENDIF
      SET request->attribute_list[attribute_idx].exists_flag = 1
      SET inserted_flag = 1
     ENDIF
    ENDIF
  ENDFOR
  IF (inserted_flag=1)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
#exit_script
 IF ((reply->status_data.status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
