CREATE PROGRAM afc_get_org_from_billcodesched:dba
 DECLARE afc_get_bim_bill_item_vrsn = vc WITH constant("FT.74874.002")
 RECORD reply(
   1 bill_code_sched_list[*]
     2 cs_org_reltn_id = f8
     2 organization_id = f8
     2 org_name = c200
     2 key1_entity_name = c100
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 DECLARE bill_code_sched_cd = f8
 DECLARE cnt = i4
 SET code_set = 26078
 SET cdf_meaning = "BC_SCHED"
 SET cnt = 1
 SET iret = uar_get_meaning_by_codeset(code_set,cdf_meaning,cnt,bill_code_sched_cd)
 CALL echo(build("bill_code_sched_cd: ",bill_code_sched_cd))
 SET reply->status_data.status = "S"
 SET cnt = 0
 SELECT INTO "nl:"
  FROM cs_org_reltn cs,
   organization o
  PLAN (cs
   WHERE (request->cs_org_reltn_type_cd=bill_code_sched_cd)
    AND (request->key1_id=cs.key1_id)
    AND cs.active_ind=1)
   JOIN (o
   WHERE o.organization_id=cs.organization_id)
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(reply->bill_code_sched_list,cnt), reply->bill_code_sched_list[cnt
   ].cs_org_reltn_id = cs.cs_org_reltn_id,
   reply->bill_code_sched_list[cnt].organization_id = cs.organization_id, reply->
   bill_code_sched_list[cnt].org_name = o.org_name, reply->bill_code_sched_list[cnt].
   beg_effective_dt_tm = cs.beg_effective_dt_tm,
   reply->bill_code_sched_list[cnt].end_effective_dt_tm = cs.end_effective_dt_tm,
   CALL echo(build("organization_id: ",reply->bill_code_sched_list[cnt].organization_id))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "S"
 ENDIF
 FOR (i = 1 TO cnt)
  CALL echo(build("cnt: ",cnt))
  CALL echo(build("organization_id: ",reply->bill_code_sched_list[i].organization_id))
 ENDFOR
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CS_ORG_RELTN"
 ENDIF
 SET stat = alter(reply->bill_code_sched_list,cnt)
END GO
