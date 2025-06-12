CREATE PROGRAM dxr_add_xreference:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET number_to_add = size(request->qual,5)
 INSERT  FROM dept_xreference dx,
   (dummyt d  WITH seq = value(number_to_add))
  SET dx.dept_cat_xref_id = seq(mednet_seq,nextval), dx.department_cd = request->qual[d.seq].
   department_cd, dx.section_cd = request->qual[d.seq].section_cd,
   dx.task_type_cd = request->qual[d.seq].task_type_cd, dx.dept_sect_ind =
   IF ((request->qual[d.seq].section_cd > 0)) 1
   ELSE 0
   ENDIF
   , dx.updt_id = reqinfo->updt_id,
   dx.updt_cnt = 0, dx.updt_task = reqinfo->updt_task, dx.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   dx.updt_applctx = reqinfo->updt_applctx, dx.active_ind = 1, dx.active_status_prsnl_id = reqinfo->
   updt_id,
   dx.active_status_dt_tm = cnvtdatetime(curdate,curtime3), dx.begin_effective_dt_tm = cnvtdatetime(
    curdate,curtime3), dx.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00.00")
  PLAN (d)
   JOIN (dx)
  WITH nocounter
 ;end insert
 IF (curqual != number_to_add)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
