CREATE PROGRAM cv_get_step_ref:dba
 RECORD reply(
   1 cv_step_ref_list[*]
     2 task_assay_cd = f8
     2 doc_type_cd = f8
     2 doc_id_str = vc
     2 activity_subtype_cd = f8
     2 schedule_ind = i2
     2 proc_status_cd = f8
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE num = i4 WITH public, noconstant(0)
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE size = i4 WITH pulbic, noconstant(0)
 DECLARE stat = i2 WITH public, noconstant(0)
 DECLARE failed = i2 WITH protect, noconstant(0)
 SET size = size(request->task_assay_cd_list,5)
 SET stat = alterlist(reply->cv_step_ref_list,10)
 IF (size > 0)
  SELECT INTO "nl:"
   *
   FROM cv_step_ref csr
   WHERE expand(num,1,size,csr.task_assay_cd,request->task_assay_cd_list[num].task_assay_cd)
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1
     AND count > 1)
     stat = alterlist(reply->cv_step_ref_list,(count+ 9))
    ENDIF
    reply->cv_step_ref_list[count].task_assay_cd = csr.task_assay_cd, reply->cv_step_ref_list[count].
    doc_type_cd = csr.doc_type_cd, reply->cv_step_ref_list[count].doc_id_str = csr.doc_id_str,
    reply->cv_step_ref_list[count].activity_subtype_cd = csr.activity_subtype_cd, reply->
    cv_step_ref_list[count].schedule_ind = csr.schedule_ind, reply->cv_step_ref_list[count].
    proc_status_cd = csr.proc_status_cd,
    reply->cv_step_ref_list[count].updt_cnt = csr.updt_cnt
   WITH nocounter
  ;end select
  SET failed = 1
 ELSE
  SET failed = 0
  GO TO exit_script
 ENDIF
#exit_script
 SET stat = alterlist(reply->cv_step_ref_list,count)
 IF (failed=0)
  SET reply->status_data.status = "F"
 ELSE
  IF (count=0)
   SET reply->status_data.status = "Z"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
END GO
