CREATE PROGRAM bed_get_res_role_resources:dba
 FREE SET reply
 RECORD reply(
   1 ord_roles[*]
     2 ord_role_id = f8
     2 resources[*]
       3 sch_resource_code_value = f8
       3 person_id = f8
       3 service_resource_code_value = f8
       3 mnemonic = vc
       3 display_seq = i4
       3 slot_types[*]
         4 slot_type_id = f8
         4 slot_type_mnemonic = vc
         4 slot_type_seq = i4
       3 position
         4 code_value = f8
         4 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET req_size = size(request->ord_roles,5)
 IF (req_size > 0)
  SET stat = alterlist(reply->ord_roles,req_size)
 ELSE
  GO TO exit_script
 ENDIF
 FOR (x = 1 TO req_size)
   SET reply->ord_roles[x].ord_role_id = request->ord_roles[x].ord_role_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = req_size),
   sch_list_role role,
   sch_list_res res,
   sch_list_slot slot,
   sch_resource r,
   sch_slot_type sst
  PLAN (d)
   JOIN (role
   WHERE (role.list_role_id=request->ord_roles[d.seq].ord_role_id)
    AND role.active_ind=1)
   JOIN (res
   WHERE res.list_role_id=role.list_role_id
    AND res.active_ind=1)
   JOIN (slot
   WHERE slot.list_role_id=res.list_role_id
    AND slot.resource_cd=res.resource_cd
    AND slot.active_ind=1)
   JOIN (r
   WHERE r.resource_cd=slot.resource_cd
    AND r.active_ind=1)
   JOIN (sst
   WHERE sst.slot_type_id=slot.slot_type_id)
  ORDER BY d.seq, role.list_role_id, res.resource_cd,
   slot.slot_type_id
  HEAD d.seq
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->ord_roles[d.seq].resources,100)
  HEAD res.resource_cd
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->ord_roles[d.seq].resources,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->ord_roles[d.seq].resources[tot_cnt].mnemonic = r.mnemonic, reply->ord_roles[d.seq].
   resources[tot_cnt].person_id = r.person_id, reply->ord_roles[d.seq].resources[tot_cnt].
   sch_resource_code_value = r.resource_cd,
   reply->ord_roles[d.seq].resources[tot_cnt].service_resource_code_value = r.service_resource_cd,
   reply->ord_roles[d.seq].resources[tot_cnt].display_seq = res.display_seq, scnt = 0,
   stot_cnt = 0, stat = alterlist(reply->ord_roles[d.seq].resources[tot_cnt].slot_types,10)
  HEAD slot.slot_type_id
   scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
   IF (scnt > 10)
    stat = alterlist(reply->ord_roles[d.seq].resources[tot_cnt].slot_types,(stot_cnt+ 10)), scnt = 1
   ENDIF
   reply->ord_roles[d.seq].resources[tot_cnt].slot_types[stot_cnt].slot_type_id = slot.slot_type_id,
   reply->ord_roles[d.seq].resources[tot_cnt].slot_types[stot_cnt].slot_type_mnemonic = sst.mnemonic,
   reply->ord_roles[d.seq].resources[tot_cnt].slot_types[stot_cnt].slot_type_seq = slot.display_seq
  FOOT  res.resource_cd
   stat = alterlist(reply->ord_roles[d.seq].resources[tot_cnt].slot_types,stot_cnt)
  FOOT  d.seq
   stat = alterlist(reply->ord_roles[d.seq].resources,tot_cnt)
  WITH nocounter
 ;end select
 FOR (x = 1 TO req_size)
  SET res_size = size(reply->ord_roles[x].resources,5)
  IF (res_size > 0)
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(size(reply->ord_roles[x].resources,5))),
     prsnl p,
     code_value cv
    PLAN (d1
     WHERE (reply->ord_roles[x].resources[d1.seq].person_id > 0))
     JOIN (p
     WHERE (p.person_id=reply->ord_roles[x].resources[d1.seq].person_id)
      AND p.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=p.position_cd
      AND cv.active_ind=1)
    ORDER BY d1.seq
    DETAIL
     reply->ord_roles[x].resources[d1.seq].position.code_value = cv.code_value, reply->ord_roles[x].
     resources[d1.seq].position.display = cv.display
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
