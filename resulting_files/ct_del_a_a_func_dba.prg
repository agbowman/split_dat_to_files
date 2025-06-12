CREATE PROGRAM ct_del_a_a_func:dba
 IF (cdaa_ct_pt_amd_assignment_id != 0.0)
  CALL echo(build("----cdaa_ct_pt_amd_assignment_id != 0.0"))
  SELECT INTO "nl:"
   cpaa.ct_pt_amd_assignment_id
   FROM ct_pt_amd_assignment cpaa
   WHERE cpaa.ct_pt_amd_assignment_id=cdaa_ct_pt_amd_assignment_id
   WITH nocounter, forupdate(cpaa)
  ;end select
  CALL echo(build("-----curqual =",curqual))
  IF (curqual=0)
   CALL echo(build("----curqual = 0"))
   SET cdaa_status = "L"
   GO TO exit_cdaa
  ENDIF
  CALL echo(build("----ONE"))
  UPDATE  FROM ct_pt_amd_assignment cpaa
   SET cpaa.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cpaa.updt_cnt = (cpaa.updt_cnt+ 1),
    cpaa.updt_task = reqinfo->updt_task,
    cpaa.updt_id = reqinfo->updt_id, cpaa.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpaa
    .updt_applctx = reqinfo->updt_applctx
   WHERE cpaa.ct_pt_amd_assignment_id=cdaa_ct_pt_amd_assignment_id
   WITH nocounter
  ;end update
  CALL echo(build("-----curqual =",curqual))
  IF (curqual=0)
   CALL echo(build("----curqual = 0"))
   SET cdaa_status = "F"
   GO TO exit_cdaa
  ENDIF
 ELSEIF (cdaa_reg_id != 0.0)
  CALL echo(build("----cdaa_reg_id != 0.0"))
  SELECT INTO "nl:"
   cpaa.ct_pt_amd_assignment_id
   FROM ct_pt_amd_assignment cpaa
   WHERE cpaa.reg_id=cdaa_reg_id
    AND cpaa.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
   WITH nocounter, forupdate(cpaa)
  ;end select
  CALL echo(build("-----curqual =",curqual))
  IF (curqual=0)
   CALL echo(build("----curqual = 0"))
   SET cdaa_status = "L"
   GO TO exit_cdaa
  ENDIF
  CALL echo(build("----TWO"))
  UPDATE  FROM ct_pt_amd_assignment cpaa
   SET cpaa.end_effective_dt_tm = cnvtdatetime(curdate,curtime3), cpaa.updt_cnt = (cpaa.updt_cnt+ 1),
    cpaa.updt_task = reqinfo->updt_task,
    cpaa.updt_id = reqinfo->updt_id, cpaa.updt_dt_tm = cnvtdatetime(curdate,curtime3), cpaa
    .updt_applctx = reqinfo->updt_applctx
   WHERE cpaa.reg_id=cdaa_reg_id
    AND cpaa.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00.00")
   WITH nocounter
  ;end update
  CALL echo(build("-----curqual =",curqual))
  IF (curqual=0)
   CALL echo(build("----curqual = 0"))
   SET cdaa_status = "F"
   GO TO exit_cdaa
  ENDIF
 ENDIF
 CALL echo("-----end of ct_del_a_a_func is success")
 SET cdaa_status = "S"
#exit_cdaa
END GO
