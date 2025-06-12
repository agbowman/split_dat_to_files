CREATE PROGRAM dcp_get_ordering_prsnl:dba
 SET modify = predeclare
 RECORD reply(
   1 order_list[*]
     2 order_id = f8
     2 action_list[*]
       3 action_seq = i4
       3 prsnl_id = f8
       3 position_cd = f8
       3 verify_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE failed = c1 WITH noconstant("F")
 DECLARE stat = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE comp_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_idx = i4 WITH protect, noconstant(0)
 DECLARE expand_start = i4 WITH protect, noconstant(1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE oaidx = i4 WITH protect, noconstant(0)
 DECLARE find_idx = i4 WITH protect, noconstant(0)
 DECLARE verify_ind = i2 WITH protect, noconstant(0)
 DECLARE expand_size = i4 WITH public, constant(100)
 DECLARE total_ids = i4 WITH protect, constant(size(request->order_list,5))
 IF (total_ids=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 DECLARE expand_blocks = i4 WITH protect, constant(ceil((total_ids/ (1.0 * expand_size))))
 DECLARE total_items = i4 WITH protect, constant((expand_blocks * expand_size))
 SET stat = alterlist(request->order_list,total_items)
 SET stat = alterlist(reply->order_list,total_ids)
 FOR (comp_idx = (total_ids+ 1) TO total_items)
   SET request->order_list[comp_idx].order_id = request->order_list[total_ids].order_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(expand_blocks)),
   order_action oa,
   prsnl p
  PLAN (d
   WHERE assign(expand_start,evaluate(d.seq,1,1,(expand_start+ expand_size))))
   JOIN (oa
   WHERE expand(expand_idx,expand_start,(expand_start+ (expand_size - 1)),oa.order_id,request->
    order_list[expand_idx].order_id))
   JOIN (p
   WHERE p.person_id=oa.action_personnel_id)
  ORDER BY oa.order_id, oa.action_sequence DESC
  HEAD REPORT
   idx = 0
  HEAD oa.order_id
   idx = (idx+ 1), oaidx = 0, stat = alterlist(reply->order_list[idx].action_list,10),
   verify_ind = 0
  HEAD oa.action_sequence
   oaidx = (oaidx+ 1)
   IF (mod(oaidx,10)=1)
    stat = alterlist(reply->order_list[idx].action_list,(oaidx+ 9))
   ENDIF
  DETAIL
   CASE (oa.needs_verify_ind)
    OF 0:
     verify_ind = 0
    OF 3:
     verify_ind = 0
    OF 5:
     verify_ind = 0
    OF 1:
     verify_ind = 1
    OF 4:
     verify_ind = 2
   ENDCASE
   reply->order_list[idx].order_id = oa.order_id, reply->order_list[idx].action_list[oaidx].
   action_seq = oa.action_sequence, reply->order_list[idx].action_list[oaidx].prsnl_id = oa
   .action_personnel_id,
   reply->order_list[idx].action_list[oaidx].position_cd = p.position_cd, reply->order_list[idx].
   action_list[oaidx].verify_ind = verify_ind
  FOOT  oa.order_id
   stat = alterlist(reply->order_list[idx].action_list,oaidx)
  FOOT REPORT
   stat = alterlist(reply->order_list,idx)
  WITH nocounter
 ;end select
 IF (idx=0)
  SET failed = "T"
 ENDIF
 GO TO exit_script
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_ACTION"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO ORDER_ACTIONS SELECTED"
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
