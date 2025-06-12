CREATE PROGRAM cv_da_add_device_location:dba
 IF (validate(reply) != 1)
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 RECORD ref_id_list(
   1 item[*]
     2 id = f8
 ) WITH protect
 RECORD r_id_list(
   1 item[*]
     2 id = f8
 ) WITH protect
 SET stat = alterlist(ref_id_list->item,size(size(request->objarray,5)))
 EXECUTE dm2_dar_get_bulk_seq "ref_id_list->item", size(request->objarray,5), "id",
 1, "CARD_VAS_SEQ"
 IF ((m_dm2_seq_stat->n_status != 1))
  GO TO exit_script
  RETURN
 ENDIF
 SET stat = alterlist(r_id_list->item,size(size(request->objarray,5)))
 EXECUTE dm2_dar_get_bulk_seq "r_id_list->item", size(request->objarray,5), "id",
 1, "CARD_VAS_SEQ"
 IF ((m_dm2_seq_stat->n_status != 1))
  GO TO exit_script
  RETURN
 ENDIF
 DECLARE ref_id = f8 WITH noconstant(0.0), protect
 DECLARE r_id = f8 WITH noconstant(0.0), protect
 DECLARE n_row_idx = i4 WITH noconstant(0), protect
 SET n_row_idx = 1
 WHILE (n_row_idx <= size(request->objarray,5))
   SET ref_id = 0.0
   SET r_id = 0.0
   SELECT INTO "nl:"
    FROM cv_device_location_ref ref
    WHERE (ref.device_name=request->objarray[n_row_idx].device_name)
    DETAIL
     ref_id = ref.cv_device_location_ref_id
    WITH format, nocounter
   ;end select
   IF (curqual=0)
    IF (validate(request->objarray[n_row_idx].cv_device_location_ref_id,- (0.00001)) <= 0.0)
     SET ref_id = ref_id_list->item[n_row_idx].id
     SET request->objarray[n_row_idx].cv_device_location_ref_id = ref_id
    ELSE
     SET ref_id = request->objarray[i].cv_device_location_ref_id
    ENDIF
    INSERT  FROM cv_device_location_ref ref
     SET ref.cv_device_location_ref_id = ref_id, ref.device_name = request->objarray[n_row_idx].
      device_name, ref.active_ind = 1,
      ref.updt_id = reqinfo->updt_id, ref.updt_applctx = reqinfo->updt_applctx, ref.updt_dt_tm =
      cnvtdatetime(sysdate),
      ref.updt_task = reqinfo->updt_task, ref.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET reply->status_data.status = "F"
     GO TO exit_script
    ELSE
     SET reply->status_data.status = "S"
    ENDIF
   ENDIF
   IF (validate(request->objarray[n_row_idx].cv_device_location_r_id,- (0.00001)) <= 0.0)
    SET r_id = r_id_list->item[n_row_idx].id
    SET request->objarray[n_row_idx].cv_device_location_r_id = r_id
   ELSE
    SET r_id = request->objarray[n_row_idx].cv_device_location_r_id
   ENDIF
   INSERT  FROM cv_device_location_r r
    SET r.cv_device_location_r_id = r_id, r.cv_device_location_ref_id = ref_id, r
     .performing_location_cd = request->objarray[n_row_idx].performing_location,
     r.default_ind = request->objarray[n_row_idx].default_ind, r.updt_id = reqinfo->updt_id, r
     .updt_applctx = reqinfo->updt_applctx,
     r.updt_dt_tm = cnvtdatetime(sysdate), r.updt_task = reqinfo->updt_task, r.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
   SET n_row_idx += 1
 ENDWHILE
 SET reply->status_data.status = "S"
#exit_script
END GO
