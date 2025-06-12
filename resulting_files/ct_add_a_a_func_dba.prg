CREATE PROGRAM ct_add_a_a_func:dba
 CALL echo(build("-----Pt_Amd_Assignment->reg_id =",pt_amd_assignment->reg_id))
 CALL echo(build("-----Pt_Amd_Assignment->prot_amendment_id =",pt_amd_assignment->prot_amendment_id))
 CALL echo(build("-----Pt_Amd_Assignment->transfer_checked_amendment_id =",pt_amd_assignment->
   transfer_checked_amendment_id))
 CALL echo(build("-----Pt_Amd_Assignment->assign_start_dt_tm =",pt_amd_assignment->assign_start_dt_tm
   ))
 CALL echo(build("-----Pt_Amd_Assignment->assign_end_dt_tm =",pt_amd_assignment->assign_end_dt_tm))
 DECLARE caaa_ct_pt_amd_assignment_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET caaa_status = "F"
 SELECT INTO "nl:"
  nextseqnum = seq(protocol_def_seq,nextval)
  FROM dual
  DETAIL
   caaa_ct_pt_amd_assignment_id = nextseqnum
  WITH format, nocounter
 ;end select
 INSERT  FROM ct_pt_amd_assignment cpaa
  SET cpaa.ct_pt_amd_assignment_id = caaa_ct_pt_amd_assignment_id, cpaa.prot_amendment_id =
   pt_amd_assignment->prot_amendment_id, cpaa.reg_id = pt_amd_assignment->reg_id,
   cpaa.transfer_checked_amendment_id = pt_amd_assignment->transfer_checked_amendment_id, cpaa
   .assign_start_dt_tm = cnvtdatetime(pt_amd_assignment->assign_start_dt_tm), cpaa.assign_end_dt_tm
    = cnvtdatetime(pt_amd_assignment->assign_end_dt_tm),
   cpaa.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), cpaa.end_effective_dt_tm = cnvtdatetime
   ("31-dec-2100 00:00:00.00"), cpaa.updt_cnt = 0,
   cpaa.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpaa.updt_id = reqinfo->updt_id, cpaa.updt_task
    = reqinfo->updt_task,
   cpaa.updt_applctx = reqinfo->updt_applctx
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET caaa_status = "F"
 ELSE
  SET caaa_status = "S"
 ENDIF
 SET last_mod = "001"
 SET mod_date = "Aug 27, 2007"
END GO
