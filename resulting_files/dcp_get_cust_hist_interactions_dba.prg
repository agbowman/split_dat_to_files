CREATE PROGRAM dcp_get_cust_hist_interactions:dba
 FREE SET reply
 RECORD reply(
   1 get_list[*]
     2 dcp_entity_reltn_id = f8
     2 entity1_id = f8
     2 entity1_display = vc
     2 entity1_name = vc
     2 entity2_id = f8
     2 entity2_display = vc
     2 rank_sequence = i4
     2 active_ind = i2
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH public, noconstant(0)
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
  d.dcp_entity_reltn_id, d.entity1_id, d.entity1_display,
  d.entity1_name, d.entity2_id, d.entity2_display,
  d.rank_sequence, d.active_ind, d.begin_effective_dt_tm,
  d.end_effective_dt_tm
  FROM dcp_entity_reltn d
  WHERE d.entity_reltn_mean=trim(request->entity_reltn_mean)
   AND d.entity1_id=entity1_id
   AND d.entity2_id=entity2_id
  ORDER BY cnvtdatetime(d.begin_effective_dt_tm) DESC
  HEAD REPORT
   stat = alterlist(reply->get_list,10)
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->get_list,(count1+ 9))
   ENDIF
   reply->get_list[count1].dcp_entity_reltn_id = d.dcp_entity_reltn_id, reply->get_list[count1].
   entity1_id = d.entity1_id, reply->get_list[count1].entity1_display = d.entity1_display,
   reply->get_list[count1].entity1_name = d.entity1_name, reply->get_list[count1].entity2_id = d
   .entity2_id, reply->get_list[count1].entity2_display = d.entity2_display,
   reply->get_list[count1].rank_sequence = d.rank_sequence, reply->get_list[count1].active_ind = d
   .active_ind, reply->get_list[count1].begin_effective_dt_tm = cnvtdatetime(d.begin_effective_dt_tm),
   reply->get_list[count1].end_effective_dt_tm = cnvtdatetime(d.end_effective_dt_tm)
  FOOT REPORT
   stat = alterlist(reply->get_list,count1)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
