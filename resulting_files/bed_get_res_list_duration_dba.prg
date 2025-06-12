CREATE PROGRAM bed_get_res_list_duration:dba
 FREE SET reply
 RECORD reply(
   1 resource_lists[*]
     2 res_list_id = f8
     2 resource_sets[*]
       3 res_set_id = f8
       3 description = vc
       3 group_id = f8
       3 meaning = vc
       3 sequence = i4
       3 resources[*]
         4 sch_resource_code_value = f8
         4 mnemonic = vc
         4 display_seq = i4
         4 slot_types[*]
           5 slot_type_id = f8
           5 slot_type_mnemonic = vc
           5 slot_type_seq = i4
           5 contiguous_ind = i2
           5 inherit_duration_from_id = f8
           5 duration = i4
           5 duration_unit_code_value = f8
           5 setup_duration = i4
           5 setup_unit_code_value = f8
           5 cleanup_duration = i4
           5 cleanup_unit_code_value = f8
           5 arrival_duration = i4
           5 arrival_unit_code_value = f8
           5 recovery_duration = i4
           5 recovery_unit_code_value = f8
           5 offset = i4
           5 offset_unit_code_value = f8
           5 offset_from_id = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_res_list
 RECORD temp_res_list(
   1 resource_lists[*]
     2 res_list_id = f8
     2 mnemonic = vc
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM sch_appt_loc sal,
   sch_resource_list srl
  PLAN (sal
   WHERE (sal.appt_type_cd=request->appt_type_code_value)
    AND (sal.location_cd=request->dept_code_value)
    AND sal.res_list_id > 0
    AND sal.active_ind=1)
   JOIN (srl
   WHERE srl.res_list_id=sal.res_list_id
    AND srl.active_ind=1)
  ORDER BY sal.res_list_id
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_res_list->resource_lists,100)
  HEAD sal.res_list_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_res_list->resource_lists,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_res_list->resource_lists[tot_cnt].res_list_id = sal.res_list_id, temp_res_list->
   resource_lists[tot_cnt].mnemonic = srl.mnemonic
  FOOT REPORT
   stat = alterlist(temp_res_list->resource_lists,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt > 0)
  SET stat = alterlist(reply->resource_lists,tot_cnt)
  FOR (x = 1 TO tot_cnt)
    SET reply->resource_lists[x].res_list_id = temp_res_list->resource_lists[x].res_list_id
    SET reply->resource_lists[x].mnemonic = temp_res_list->resource_lists[x].mnemonic
    SET rtot_cnt = 0
    SET tot_cnt = 0
    SELECT INTO "nl:"
     FROM sch_list_role role,
      sch_list_res res,
      sch_list_slot slot,
      sch_resource s,
      sch_slot_type sst
     PLAN (role
      WHERE (role.res_list_id=temp_res_list->resource_lists[x].res_list_id)
       AND role.active_ind=1)
      JOIN (res
      WHERE res.list_role_id=role.list_role_id
       AND res.active_ind=1)
      JOIN (slot
      WHERE slot.resource_cd=res.resource_cd
       AND slot.list_role_id=res.list_role_id
       AND slot.active_ind=1)
      JOIN (s
      WHERE s.resource_cd=outerjoin(res.resource_cd)
       AND s.active_ind=outerjoin(1))
      JOIN (sst
      WHERE sst.slot_type_id=outerjoin(slot.slot_type_id))
     ORDER BY role.res_list_id, res.list_role_id, res.resource_cd
     HEAD role.res_list_id
      cnt = 0, tot_cnt = 0, stat = alterlist(reply->resource_lists[x].resource_sets,10)
     HEAD res.list_role_id
      cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
      IF (cnt > 10)
       stat = alterlist(reply->resource_lists[x].resource_sets,(tot_cnt+ 10)), cnt = 1
      ENDIF
      reply->resource_lists[x].resource_sets[tot_cnt].res_set_id = role.list_role_id, reply->
      resource_lists[x].resource_sets[tot_cnt].description = role.description, reply->resource_lists[
      x].resource_sets[tot_cnt].meaning = role.role_meaning,
      reply->resource_lists[x].resource_sets[tot_cnt].sequence = role.role_seq, rcnt = 0, rtot_cnt =
      0,
      stat = alterlist(reply->resource_lists[x].resource_sets[tot_cnt].resources,10)
     HEAD res.resource_cd
      rcnt = (rcnt+ 1), rtot_cnt = (rtot_cnt+ 1)
      IF (rcnt > 10)
       stat = alterlist(reply->resource_lists[x].resource_sets[tot_cnt].resources,(rtot_cnt+ 10)),
       rcnt = 1
      ENDIF
      reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].sch_resource_code_value =
      res.resource_cd, reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].mnemonic
       = s.mnemonic, reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].display_seq
       = res.display_seq,
      scnt = 0, stot_cnt = 0, stat = alterlist(reply->resource_lists[x].resource_sets[tot_cnt].
       resources[rtot_cnt].slot_types,10)
     DETAIL
      scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
      IF (scnt > 10)
       stat = alterlist(reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].
        slot_types,(stot_cnt+ 10)), scnt = 1
      ENDIF
      reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
      slot_type_id = sst.slot_type_id, reply->resource_lists[x].resource_sets[tot_cnt].resources[
      rtot_cnt].slot_types[stot_cnt].slot_type_mnemonic = sst.mnemonic, reply->resource_lists[x].
      resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].slot_type_seq = slot
      .display_seq,
      reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
      contiguous_ind = sst.contiguous_ind, reply->resource_lists[x].resource_sets[tot_cnt].resources[
      rtot_cnt].slot_types[stot_cnt].inherit_duration_from_id = slot.duration_role_id, reply->
      resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].duration =
      slot.duration_units,
      reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
      duration_unit_code_value = slot.duration_units_cd
      IF (role.role_meaning="PATIENT")
       reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
       arrival_duration = slot.setup_units, reply->resource_lists[x].resource_sets[tot_cnt].
       resources[rtot_cnt].slot_types[stot_cnt].arrival_unit_code_value = slot.setup_units_cd, reply
       ->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
       recovery_duration = slot.cleanup_units,
       reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
       recovery_unit_code_value = slot.cleanup_units_cd
      ELSE
       reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
       setup_duration = slot.setup_units, reply->resource_lists[x].resource_sets[tot_cnt].resources[
       rtot_cnt].slot_types[stot_cnt].setup_unit_code_value = slot.setup_units_cd, reply->
       resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
       cleanup_duration = slot.cleanup_units,
       reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].
       cleanup_unit_code_value = slot.cleanup_units_cd
      ENDIF
      reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].offset
       = slot.offset_beg_units, reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].
      slot_types[stot_cnt].offset_unit_code_value = slot.offset_beg_units_cd, reply->resource_lists[x
      ].resource_sets[tot_cnt].resources[rtot_cnt].slot_types[stot_cnt].offset_from_id = slot
      .offset_role_id
     FOOT  res.resource_cd
      stat = alterlist(reply->resource_lists[x].resource_sets[tot_cnt].resources[rtot_cnt].slot_types,
       stot_cnt)
     FOOT  res.list_role_id
      stat = alterlist(reply->resource_lists[x].resource_sets[tot_cnt].resources,rtot_cnt)
     FOOT  role.res_list_id
      stat = alterlist(reply->resource_lists[x].resource_sets,tot_cnt)
     WITH nocounter
    ;end select
    IF (tot_cnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = tot_cnt),
       br_name_value b,
       dummyt d2
      PLAN (d)
       JOIN (b
       WHERE b.br_nv_key1="SCHRESGROUPROLE")
       JOIN (d2
       WHERE (cnvtint(trim(b.br_name))=reply->resource_lists[x].resource_sets[d.seq].res_set_id))
      ORDER BY d.seq
      DETAIL
       reply->resource_lists[x].resource_sets[d.seq].group_id = cnvtint(trim(b.br_value))
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
