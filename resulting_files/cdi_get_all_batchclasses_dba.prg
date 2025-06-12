CREATE PROGRAM cdi_get_all_batchclasses:dba
 RECORD reply(
   1 batchclasses[*]
     2 cdi_ac_batchclass_id = f8
     2 batchclass_name = vc
     2 single_encntr = i2
     2 auto_comp_notify = i2
     2 auto_close = i2
     2 auditing_ind = i2
     2 organization_id = f8
     2 updt_cnt = i4
     2 alias_contrib_src_cd = f8
     2 cpdi_batch_class_ind = i2
     2 parent_types[*]
       3 cdi_ac_batchclass_parent_r_id = f8
       3 parent_level_cd = f8
     2 active_ind = i2
     2 batch_profile_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH noconstant(0), protect
 DECLARE parentcount = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM cdi_ac_batchclass bc,
   cdi_ac_batchclass_parent_r bcr
  PLAN (bc
   WHERE bc.cdi_ac_batchclass_id != 0)
   JOIN (bcr
   WHERE (bcr.cdi_ac_batchclass_id= Outerjoin(bc.cdi_ac_batchclass_id)) )
  ORDER BY bc.batchclass_name
  HEAD bc.batchclass_name
   count += 1
   IF (mod(count,50)=1)
    stat = alterlist(reply->batchclasses,(count+ 50))
   ENDIF
   reply->batchclasses[count].cdi_ac_batchclass_id = bc.cdi_ac_batchclass_id, reply->batchclasses[
   count].batchclass_name = bc.batchclass_name, reply->batchclasses[count].single_encntr = bc
   .single_encntr,
   reply->batchclasses[count].auto_comp_notify = bc.auto_comp_notify, reply->batchclasses[count].
   auto_close = bc.auto_close, reply->batchclasses[count].auditing_ind = bc.auditing_ind,
   reply->batchclasses[count].organization_id = bc.organization_id, reply->batchclasses[count].
   updt_cnt = bc.updt_cnt, reply->batchclasses[count].alias_contrib_src_cd = bc.alias_contrib_src_cd,
   reply->batchclasses[count].cpdi_batch_class_ind = bc.cpdi_batch_class_ind, reply->batchclasses[
   count].active_ind = bc.active_ind, reply->batchclasses[count].batch_profile_ind = bc
   .batch_profile_ind,
   parentcount = 0
  DETAIL
   IF (bcr.parent_level_cd > 0)
    parentcount += 1
    IF (mod(parentcount,5)=1)
     stat = alterlist(reply->batchclasses[count].parent_types,(parentcount+ 5))
    ENDIF
    reply->batchclasses[count].parent_types[parentcount].parent_level_cd = bcr.parent_level_cd, reply
    ->batchclasses[count].parent_types[parentcount].cdi_ac_batchclass_parent_r_id = bcr
    .cdi_ac_batchclass_parent_r_id
   ENDIF
  FOOT  bc.batchclass_name
   IF (parentcount > 0)
    stat = alterlist(reply->batchclasses[count].parent_types,parentcount)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->batchclasses,count)
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status != "S"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CDI_AC_BATCHCLASS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = " "
 ENDIF
END GO
