CREATE PROGRAM dcp_get_predefined_prefs:dba
 RECORD reply(
   1 name = c32
   1 active_ind = i2
   1 updt_cnt = i4
   1 nv_cnt = i4
   1 nv[100]
     2 name_value_prefs_id = f8
     2 pvc_name = c32
     2 pvc_value = vc
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SELECT INTO "nl:"
  pp.name, nvp.updt_cnt
  FROM predefined_prefs pp,
   (dummyt d1  WITH seq = 1),
   name_value_prefs nvp
  PLAN (pp
   WHERE (pp.predefined_prefs_id=request->predefined_prefs_id))
   JOIN (d1)
   JOIN (nvp
   WHERE nvp.parent_entity_name="PREDEFINED_PREFS"
    AND (nvp.parent_entity_id=request->predefined_prefs_id)
    AND nvp.active_ind=1)
  HEAD REPORT
   count1 = 0, reply->name = pp.name, reply->active_ind = pp.active_ind,
   reply->updt_cnt = pp.updt_cnt
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->nv,5))
    stat = alter(reply->nv,(count1+ 10))
   ENDIF
   reply->nv[count1].name_value_prefs_id = nvp.name_value_prefs_id, reply->nv[count1].pvc_name = nvp
   .pvc_name, reply->nv[count1].pvc_value = nvp.pvc_value,
   reply->nv[count1].updt_cnt = nvp.updt_cnt
  WITH nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->nv,count1)
 SET reply->nv_cnt = count1
END GO
