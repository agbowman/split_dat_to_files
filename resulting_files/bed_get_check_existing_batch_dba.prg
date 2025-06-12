CREATE PROGRAM bed_get_check_existing_batch:dba
 FREE SET reply
 RECORD reply(
   1 batch_exists = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 batch_list[*]
     2 batch_exists = i2
     2 entity1_id = vc
     2 entity1_display = vc
     2 entity2_id = vc
     2 entity2_display = vc
     2 custom_type_flag = i2
 )
 DECLARE batchcnt = i4 WITH noconstant(0.0)
 DECLARE entity1_id = f8 WITH public, noconstant(0.0)
 DECLARE entity2_id = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF ((request->entity1_id < request->entity2_id))
  SET entity1_id = request->entity1_id
  SET entity2_id = request->entity2_id
 ELSE
  SET entity1_id = request->entity2_id
  SET entity2_id = request->entity1_id
 ENDIF
 SELECT INTO "nl:"
  FROM dcp_entity_reltn dcp,
   drug_class_int_cstm_entity_r dcer,
   drug_class_int_custom dcc
  PLAN (dcp
   WHERE dcp.entity1_id=entity1_id
    AND dcp.entity2_id=entity2_id
    AND (dcp.entity_reltn_mean=request->entity_reltn_mean))
   JOIN (dcer
   WHERE dcer.dcp_entity_reltn_id=dcp.dcp_entity_reltn_id)
   JOIN (dcc
   WHERE dcc.drug_class_int_custom_id=dcer.drug_class_int_custom_id
    AND (dcc.custom_interaction_flag=request->custom_interaction_flag))
  HEAD REPORT
   stat = alterlist(reply->batch_list,5), batchcnt = 0
  DETAIL
   batchcnt = (batchcnt+ 1), reply->batch_list[batchcnt].entity1_id = dcc.entity1_ident, reply->
   batch_list[batchcnt].entity1_display = dcc.entity1_display,
   reply->batch_list[batchcnt].entity2_id = dcc.entity2_ident, reply->batch_list[batchcnt].
   entity2_display = dcc.entity2_display, reply->batch_list[batchcnt].custom_type_flag = dcc
   .custom_type_flag
  FOOT REPORT
   stat = alterlist(reply->batch_list,1)
  WITH nocounter
 ;end select
 IF (batchcnt > 0)
  SET reply->batch_list[1].batch_exists = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->batch_list[1].batch_exists = 0
  SET reply->status_data.status = "Z"
 ENDIF
END GO
