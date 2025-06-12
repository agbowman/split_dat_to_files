CREATE PROGRAM bed_ens_coll_class:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET ccnt = size(request->collection_classes,5)
 FOR (c = 1 TO ccnt)
   IF ((request->collection_classes[c].action_flag=1))
    SET request_cv->cd_value_list[1].action_flag = 1
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].display = request->collection_classes[c].display
    SET request_cv->cd_value_list[1].description = request->collection_classes[c].description
    SET request_cv->cd_value_list[1].definition = request->collection_classes[c].description
    SET request_cv->cd_value_list[1].concept_cki = " "
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((reply_cv->status_data.status="S")
     AND (reply_cv->qual[1].code_value > 0))
     IF ((request->collection_classes[c].storage_tracking_ind=1))
      SET cont_id_print = "B"
     ELSE
      SET cont_id_print = "N"
     ENDIF
     INSERT  FROM collection_class cc
      SET cc.coll_class_cd = reply_cv->qual[1].code_value, cc.max_class_volume = 10.0, cc
       .max_class_vol_units = null,
       cc.updt_applctx = reqinfo->updt_applctx, cc.updt_dt_tm = cnvtdatetime(curdate,curtime), cc
       .updt_id = reqinfo->updt_id,
       cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task, cc.max_accession_size = 12,
       cc.max_class_vol_units_cd = 0.0, cc.def_storage_minutes = 0, cc.symbology = "A",
       cc.smg_barcode_adjust = 0, cc.smg_format = "L", cc.container_id_print = cont_id_print,
       cc.transfer_temp_cd = 0.0, cc.storage_temp_cd = 0.0, cc.sequence = 0
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF ((request->collection_classes[c].action_flag=2))
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_set = 231
    SET request_cv->cd_value_list[1].code_value = request->collection_classes[c].code_value
    SET request_cv->cd_value_list[1].display = request->collection_classes[c].display
    SET request_cv->cd_value_list[1].description = request->collection_classes[c].description
    SET request_cv->cd_value_list[1].definition = request->collection_classes[c].description
    SET request_cv->cd_value_list[1].display_key = " "
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
    IF ((request->collection_classes[c].storage_tracking_ind=1))
     SET cont_id_print = "B"
    ELSE
     SET cont_id_print = "N"
    ENDIF
    UPDATE  FROM collection_class cc
     SET cc.container_id_print = cont_id_print, cc.updt_applctx = reqinfo->updt_applctx, cc
      .updt_dt_tm = cnvtdatetime(curdate,curtime),
      cc.updt_id = reqinfo->updt_id, cc.updt_cnt = 0, cc.updt_task = reqinfo->updt_task
     WHERE (cc.coll_class_cd=request->collection_classes[c].code_value)
     WITH nocounter
    ;end update
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
 CALL echorecord(reply)
END GO
