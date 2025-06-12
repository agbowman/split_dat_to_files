CREATE PROGRAM afc_get_parent_inst:dba
 RECORD tempreply(
   1 current_service_resource_cd = f8
   1 current_display = c40
   1 current_meaning = c12
   1 parent_service_resource_cd = f8
 )
 RECORD reply(
   1 current_service_resource_cd = f8
   1 current_display = c40
   1 current_meaning = c12
   1 parent_service_resource_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 EXECUTE cpmsrsrtl
 DECLARE m_nressecuarstatus = i2 WITH protect, noconstant(0)
 DECLARE nres_sec_failed = i2 WITH protect, constant(0)
 DECLARE nres_sec_passed = i2 WITH protect, constant(1)
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT DISTINCT INTO "nl:"
  FROM resource_group r,
   code_value c
  WHERE (r.child_service_resource_cd=request->child_service_resource_cd)
   AND c.code_set=221
   AND c.code_value=r.child_service_resource_cd
  ORDER BY c.code_value
  DETAIL
   tempreply->current_service_resource_cd = c.code_value, tempreply->current_display = c.display,
   tempreply->current_meaning = c.cdf_meaning,
   tempreply->parent_service_resource_cd = r.parent_service_resource_cd
  WITH nocounter
 ;end select
 SET m_nressecuarstatus = uar_srsprsnlhasaccess(reqinfo->updt_id,reqinfo->position_cd,tempreply->
  current_service_resource_cd)
 IF (m_nressecuarstatus=nres_sec_passed)
  SET reply->current_service_resource_cd = tempreply->current_service_resource_cd
  SET reply->current_display = tempreply->current_display
  SET reply->current_meaning = tempreply->current_meaning
  SET reply->parent_service_resource_cd = tempreply->parent_service_resource_cd
 ENDIF
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
