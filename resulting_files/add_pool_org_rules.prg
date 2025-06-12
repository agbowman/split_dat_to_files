CREATE PROGRAM add_pool_org_rules
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
 SET prsnl_group_pool_id = 0
 IF ((request->prsnl_group_id < 0))
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET failed = "F"
 SELECT INTO "nl:"
  nextseqnum = seq(prsnl_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   prsnl_group_pool_id = cnvtreal(nextseqnum)
  WITH format, nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 INSERT  FROM prsnl_group_pool pap
  SET pap.prsnl_group_pool_id = prsnl_group_pool_id, pap.prsnl_group_id = request->prsnl_group_id,
   pap.outside_add_ind = request->outside_add_ind,
   pap.outside_forward_ind = request->outside_forward_ind, pap.self_assign_leader_ind = request->
   self_assign_leader_ind, pap.self_enroll_ind = request->self_enroll_ind,
   pap.sch_flex_id = 0, pap.active_ind = 1, pap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   pap.updt_cnt = 0, pap.updt_id = reqinfo->updt_id, pap.updt_task = reqinfo->updt_task,
   pap.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
