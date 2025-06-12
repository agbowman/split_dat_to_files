CREATE PROGRAM bed_get_refrange_rules:dba
 FREE SET reply
 RECORD reply(
   1 rules[*]
     2 module_name = vc
     2 maint_validation = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET rcnt = 0
 SELECT INTO "nl:"
  FROM eks_module em,
   eks_modulestorage ems
  PLAN (em
   WHERE em.active_flag="A")
   JOIN (ems
   WHERE ems.module_name=em.module_name
    AND ems.version=em.version
    AND ems.data_type=7)
  ORDER BY em.module_name
  HEAD REPORT
   rcnt = 0
  HEAD em.module_name
   IF (substring(1,15,ems.ekm_info)="PNTFLEXREFRANGE")
    rcnt = (rcnt+ 1), stat = alterlist(reply->rules,rcnt), reply->rules[rcnt].module_name = em
    .module_name,
    reply->rules[rcnt].maint_validation = em.maint_validation
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 IF (error_flag="F")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 SET reply->error_msg = error_msg
 CALL echorecord(reply)
END GO
