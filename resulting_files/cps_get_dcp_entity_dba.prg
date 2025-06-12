CREATE PROGRAM cps_get_dcp_entity:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE RECORD reply
 RECORD reply(
   1 orders_qual = i4
   1 orders[*]
     2 order_id = f8
     2 reltn_qual = i4
     2 reltn_info[*]
       3 dcp_entity_reltn_id = f8
       3 entity_reltn_mean = vc
       3 entity1_id = f8
       3 entity1_display = vc
       3 entity2_id = f8
       3 entity2_display = vc
       3 rank_sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "NL:"
  dc.entity1_id
  FROM dcp_entity_reltn dc,
   (dummyt d  WITH seq = value(size(request->orders,5)))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (dc
   WHERE (dc.entity1_id=request->orders[d.seq].order_id)
    AND dc.entity_reltn_mean="ORDERS/DIAGN"
    AND dc.active_ind=1)
  HEAD REPORT
   count1 = 0, stat = alterlist(reply->orders,10)
  HEAD dc.entity1_id
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->orders,(count1+ 9))
   ENDIF
   reply->orders[count1].order_id = dc.entity1_id, count2 = 0, stat = alterlist(reply->orders[count1]
    .reltn_info,10)
  DETAIL
   count2 += 1
   IF (mod(count2,10)=1
    AND count2 != 1)
    stat = alterlist(reply->orders[count1].reltn_info,(count2+ 9))
   ENDIF
   reply->orders[count1].reltn_info[count2].dcp_entity_reltn_id = dc.dcp_entity_reltn_id, reply->
   orders[count1].reltn_info[count2].entity_reltn_mean = dc.entity_reltn_mean, reply->orders[count1].
   reltn_info[count2].entity1_id = dc.entity1_id,
   reply->orders[count1].reltn_info[count2].entity1_display = dc.entity1_display, reply->orders[
   count1].reltn_info[count2].entity2_id = dc.entity2_id, reply->orders[count1].reltn_info[count2].
   entity2_display = dc.entity2_display,
   reply->orders[count1].reltn_info[count2].rank_sequence = dc.rank_sequence
  FOOT  dc.entity1_id
   stat = alterlist(reply->orders[count1].reltn_info,count2), reply->orders[count1].reltn_qual =
   count2
  FOOT REPORT
   stat = alterlist(reply->orders,count1), reply->orders_qual = count1
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "DCP_ENTITY_RELTN"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSEIF ((reply->orders_qual > 0))
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET script_version = "001 02/05/01 SF3151"
END GO
