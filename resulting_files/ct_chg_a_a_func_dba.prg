CREATE PROGRAM ct_chg_a_a_func:dba
 SET ccaa_status = "F"
 SET ccaa_updt_cnt_old = 0
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET last_mod = "003"
 SET mod_date = "Aug 8, 2006"
 IF (ccaa_ct_pt_amd_assignment_id > 0)
  CALL echo(build("----CCAA_ct_pt_amd_assignment_id > 0"))
  SELECT INTO "nl:"
   cpaa.ct_pt_amd_assignment_id
   FROM ct_pt_amd_assignment cpaa
   WHERE cpaa.ct_pt_amd_assignment_id=ccaa_ct_pt_amd_assignment_id
   DETAIL
    ccaa_updt_cnt_old = cpaa.updt_cnt
    IF ((pt_amd_assignment->transfer_checked_amendment_id=0))
     pt_amd_assignment->transfer_checked_amendment_id = cpaa.transfer_checked_amendment_id
    ENDIF
    IF ((pt_amd_assignment->assign_start_dt_tm=0))
     pt_amd_assignment->assign_start_dt_tm = cpaa.assign_start_dt_tm
    ENDIF
    IF ((pt_amd_assignment->assign_end_dt_tm=0))
     pt_amd_assignment->assign_end_dt_tm = cpaa.assign_end_dt_tm
    ENDIF
    IF ((pt_amd_assignment->reg_id=0))
     pt_amd_assignment->reg_id = cpaa.reg_id
    ENDIF
    IF ((pt_amd_assignment->prot_amendment_id=0))
     pt_amd_assignment->prot_amendment_id = cpaa.prot_amendment_id
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   CALL echo(build("----curqual = 0"))
   GO TO exit_script
  ENDIF
 ELSEIF ((pt_amd_assignment->reg_id > 0))
  CALL echo(build("----Pt_Amd_Assignment->reg_id > 0"))
  CALL echo(build("== Reg_id = ",pt_amd_assignment->reg_id))
  CALL echo(build("-- prot Amendment Id = ",pt_amd_assignment->prot_amendment_id))
  IF ((pt_amd_assignment->prot_amendment_id > 0))
   CALL echo(build("----Pt_Amd_Assignment->prot_amendment_id > 0"))
   SELECT INTO "nl:"
    cpaa.ct_pt_amd_assignment_id
    FROM ct_pt_amd_assignment cpaa
    WHERE (cpaa.reg_id=pt_amd_assignment->reg_id)
     AND cpaa.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
     AND (cpaa.prot_amendment_id=pt_amd_assignment->prot_amendment_id)
    DETAIL
     ccaa_ct_pt_amd_assignment_id = cpaa.ct_pt_amd_assignment_id, ccaa_updt_cnt_old = cpaa.updt_cnt
     IF ((pt_amd_assignment->transfer_checked_amendment_id=0))
      pt_amd_assignment->transfer_checked_amendment_id = cpaa.transfer_checked_amendment_id
     ENDIF
     IF ((pt_amd_assignment->assign_start_dt_tm=0))
      pt_amd_assignment->assign_start_dt_tm = cpaa.assign_start_dt_tm
     ENDIF
     IF ((pt_amd_assignment->assign_end_dt_tm=0))
      pt_amd_assignment->assign_end_dt_tm = cpaa.assign_end_dt_tm
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(build("----curqual = 0"))
    GO TO exit_script
   ENDIF
  ELSE
   CALL echo(build("----!(Pt_Amd_Assignment->prot_amendment_id > 0"))
   SELECT INTO "nl:"
    cpaa.ct_pt_amd_assignment_id, cpaa.prot_amendment_id, cpaa.updt_cnt
    FROM ct_pt_amd_assignment cpaa,
     prot_amendment pa
    PLAN (cpaa
     WHERE (cpaa.reg_id=pt_amd_assignment->reg_id)
      AND cpaa.end_effective_dt_tm >= cnvtdatetime("31-DEC-2100 00:00:00.00"))
     JOIN (pa
     WHERE pa.prot_amendment_id=cpaa.prot_amendment_id)
    ORDER BY pa.amendment_nbr DESC, pa.revision_seq DESC
    HEAD REPORT
     ccaa_ct_pt_amd_assignment_id = cpaa.ct_pt_amd_assignment_id, ccaa_updt_cnt_old = cpaa.updt_cnt,
     CALL echo(build("----(CCAA_updt_cnt_old is: ",ccaa_updt_cnt_old)),
     pt_amd_assignment->prot_amendment_id = cpaa.prot_amendment_id
     IF ((pt_amd_assignment->transfer_checked_amendment_id=0))
      pt_amd_assignment->transfer_checked_amendment_id = cpaa.transfer_checked_amendment_id
     ENDIF
     IF ((pt_amd_assignment->assign_start_dt_tm=0))
      pt_amd_assignment->assign_start_dt_tm = cpaa.assign_start_dt_tm
     ENDIF
     IF ((pt_amd_assignment->assign_end_dt_tm=0))
      pt_amd_assignment->assign_end_dt_tm = cpaa.assign_end_dt_tm
     ENDIF
     IF ((pt_amd_assignment->reg_id=0))
      pt_amd_assignment->reg_id = cpaa.reg_id
     ENDIF
    DETAIL
     CALL echo("reg_id = pt_amd_assignment->reg_id")
    WITH nocounter
   ;end select
   IF (curqual=0)
    CALL echo(build("----curqual = 0"))
    GO TO exit_script
   ENDIF
  ENDIF
 ELSE
  CALL echo(build("----not enough information to find row to update"))
  GO TO exit_script
 ENDIF
 CALL echo(build("----CCAA_updt_cnt is: ",ccaa_updt_cnt))
 IF ((ccaa_updt_cnt > - (1)))
  CALL echo(build("----CCAA_updt_cnt > -1"))
  IF (ccaa_updt_cnt != ccaa_updt_cnt_old)
   CALL echo(build("----CCAA_updt_cnt != CCAA_updt_cnt_old"))
   SET ccaa_status = "C"
   GO TO exit_script
  ENDIF
 ENDIF
 SET cdaa_status = "F"
 SET cdaa_reg_id = 0
 SET cdaa_ct_pt_amd_assignment_id = ccaa_ct_pt_amd_assignment_id
 CALL echo(build("----PRE - execute ct_del_amd_assignment"))
 EXECUTE ct_del_a_a_func
 CALL echo(build("----POST - execute ct_del_amd_assignment"))
 IF (cdaa_status="L")
  CALL echo(build("----CDAA_STATUS = L"))
  SET ccaa_status = "L"
  GO TO exit_script
 ELSEIF (cdaa_status="F")
  CALL echo(build("----CDAA_STATUS = F"))
  SET ccaa_status = "F"
  GO TO exit_script
 ENDIF
 SET caaa_status = "F"
 CALL echo(build("----PRE - execute ct_add_amd_assignment"))
 EXECUTE ct_add_a_a_func
 CALL echo(build("----PRE - execute ct_add_amd_assignment"))
 IF (caaa_status="L")
  CALL echo(build("----CAAA_STATUS = L"))
  SET ccaa_status = "L"
  GO TO exit_script
 ELSEIF (caaa_status="F")
  CALL echo(build("----CAAA_STATUS = F"))
  SET ccaa_status = "F"
  GO TO exit_script
 ENDIF
 SET ccaa_status = "S"
#exit_script
END GO
