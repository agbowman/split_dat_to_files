CREATE PROGRAM dcp_get_cust_interactions:dba
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
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->entity_reltn_mean="TDC/SUPP"))
   WHERE (d.entity_reltn_mean=request->entity_reltn_mean)
    AND d.active_ind=1
    AND d.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
   ORDER BY display2
  ELSE
   WHERE (d.entity_reltn_mean=request->entity_reltn_mean)
    AND  NOT (d.dcp_entity_reltn_id IN (
   (SELECT
    dcp_entity_reltn_id
    FROM drug_class_int_cstm_entity_r)))
    AND d.active_ind=1
    AND d.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND d.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  ENDIF
  INTO "nl:"
  d.dcp_entity_reltn_id, d.entity1_id, d.entity1_display,
  d.entity1_name, d.entity2_id, display2 = cnvtlower(d.entity2_display),
  d.entity2_display, d.rank_sequence, d.begin_effective_dt_tm,
  d.end_effective_dt_tm
  FROM dcp_entity_reltn d
  HEAD REPORT
   stat = alterlist(reply->get_list,10), count1 = 0
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
   reply->get_list[count1].rank_sequence = d.rank_sequence, reply->get_list[count1].
   begin_effective_dt_tm = cnvtdatetime(d.begin_effective_dt_tm), reply->get_list[count1].
   end_effective_dt_tm = cnvtdatetime(d.end_effective_dt_tm)
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
