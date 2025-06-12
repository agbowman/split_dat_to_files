CREATE PROGRAM bed_get_res_resource_list:dba
 FREE SET reply
 RECORD reply(
   1 resource_lists[*]
     2 res_list_id = f8
     2 mnemonic = vc
     2 resource_sets[*]
       3 res_set_id = f8
       3 description = vc
       3 group_id = f8
       3 meaning = vc
       3 sequence = i4
     2 selected_ind = i2
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
 SELECT INTO "nl:"
  FROM sch_resource_list srl,
   sch_list_role slr,
   sch_appt_loc sal,
   br_name_value b
  PLAN (srl
   WHERE srl.res_list_id > 0
    AND srl.active_ind=1)
   JOIN (slr
   WHERE slr.res_list_id=srl.res_list_id
    AND slr.active_ind=1)
   JOIN (sal
   WHERE sal.res_list_id=srl.res_list_id
    AND (sal.location_cd=request->dept_code_value)
    AND sal.active_ind=1)
   JOIN (b
   WHERE b.br_nv_key1=outerjoin("SCHRESGROUPROLE")
    AND b.br_name=outerjoin(cnvtstring(slr.list_role_id)))
  ORDER BY srl.res_list_id, slr.list_role_id
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(reply->resource_lists,100)
  HEAD srl.res_list_id
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(reply->resource_lists,(tot_cnt+ 100)), cnt = 1
   ENDIF
   reply->resource_lists[tot_cnt].res_list_id = srl.res_list_id, reply->resource_lists[tot_cnt].
   mnemonic = srl.mnemonic, scnt = 0,
   stot_cnt = 0, stat = alterlist(reply->resource_lists[tot_cnt].resource_sets,100)
  HEAD slr.list_role_id
   IF (slr.role_meaning != "PATIENT")
    scnt = (scnt+ 1), stot_cnt = (stot_cnt+ 1)
    IF (scnt > 100)
     stat = alterlist(reply->resource_lists[tot_cnt].resource_sets,(stot_cnt+ 100)), scnt = 1
    ENDIF
    reply->resource_lists[tot_cnt].resource_sets[stot_cnt].res_set_id = slr.list_role_id, reply->
    resource_lists[tot_cnt].resource_sets[stot_cnt].description = slr.description, reply->
    resource_lists[tot_cnt].resource_sets[stot_cnt].group_id = cnvtint(b.br_value),
    reply->resource_lists[tot_cnt].resource_sets[stot_cnt].meaning = slr.role_meaning, reply->
    resource_lists[tot_cnt].resource_sets[stot_cnt].sequence = slr.role_seq
   ENDIF
  DETAIL
   IF ((sal.appt_type_cd=request->appt_type_code_value))
    reply->resource_lists[tot_cnt].selected_ind = 1
   ENDIF
  FOOT  srl.res_list_id
   stat = alterlist(reply->resource_lists[tot_cnt].resource_sets,stot_cnt)
  FOOT REPORT
   stat = alterlist(reply->resource_lists,tot_cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
