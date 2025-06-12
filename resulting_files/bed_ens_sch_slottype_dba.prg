CREATE PROGRAM bed_ens_sch_slottype:dba
 FREE SET reply
 RECORD reply(
   1 slot_type_id = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "Y"
 DECLARE error_msg = vc
 SET active_cd = get_code_value(48,"ACTIVE")
 SELECT INTO "nl:"
  FROM sch_slot_type sst
  WHERE sst.mnemonic_key=cnvtupper(request->mnemonic)
   AND sst.active_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET error_flag = "Y"
  SET reply->error_msg = "Slot Type already exists"
  GO TO exit_script
 ENDIF
 SET reply->slot_type_id = 0.0
 SELECT INTO "NL:"
  nextseqnum = seq(sched_reference_seq,nextval)"##################;RP0"
  FROM dual
  DETAIL
   reply->slot_type_id = cnvtreal(nextseqnum)
  WITH nocounter, format
 ;end select
 IF ((request->priority_cd > 0.0))
  INSERT  FROM sch_slot_type sst
   SET sst.slot_type_id = reply->slot_type_id, sst.version_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sst.mnemonic = request->mnemonic,
    sst.def_duration = request->def_duration, sst.mnemonic_key = cnvtupper(request->mnemonic), sst
    .description = request->description,
    sst.interval = request->interval, sst.disp_scheme_id = request->disp_scheme_id, sst
    .contiguous_ind = request->contiguous_ind,
    sst.sch_flex_id = request->sch_flex_id, sst.priority_cd = request->priority_cd, sst.null_dt_tm =
    cnvtdatetime("31-dec-2100 00:00:00"),
    sst.candidate_id = seq(sch_candidate_seq,nextval), sst.beg_effective_dt_tm = cnvtdatetime(curdate,
     curtime3), sst.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
    sst.active_ind = 1, sst.active_status_cd = active_cd, sst.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    sst.active_status_prsnl_id = reqinfo->updt_id, sst.updt_dt_tm = cnvtdatetime(curdate,curtime3),
    sst.updt_id = reqinfo->updt_id,
    sst.updt_task = reqinfo->updt_task, sst.updt_applctx = reqinfo->updt_applctx, sst.updt_cnt = 0
   WITH nocounter
  ;end insert
 ELSE
  INSERT  FROM sch_slot_type sst
   SET sst.slot_type_id = reply->slot_type_id, sst.version_dt_tm = cnvtdatetime(
     "31-dec-2100 00:00:00"), sst.mnemonic = request->mnemonic,
    sst.def_duration = request->def_duration, sst.mnemonic_key = cnvtupper(request->mnemonic), sst
    .description = request->description,
    sst.interval = request->interval, sst.disp_scheme_id = request->disp_scheme_id, sst
    .contiguous_ind = request->contiguous_ind,
    sst.sch_flex_id = request->sch_flex_id, sst.null_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
    sst.candidate_id = seq(sch_candidate_seq,nextval),
    sst.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), sst.active_status_prsnl_id = reqinfo->
    updt_id, sst.end_effective_dt_tm = cnvtdatetime("31-dec-2100 00:00:00"),
    sst.active_ind = 1, sst.active_status_cd = active_cd, sst.active_status_dt_tm = cnvtdatetime(
     curdate,curtime3),
    sst.updt_dt_tm = cnvtdatetime(curdate,curtime3), sst.updt_id = reqinfo->updt_id, sst.updt_task =
    reqinfo->updt_task,
    sst.updt_applctx = reqinfo->updt_applctx, sst.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 SET error_flag = "N"
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET stat = alterlist(reply->status_data.subeventstatus,1)
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = error_msg
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
 RETURN
 SUBROUTINE get_code_value(xcodeset,xcdf)
   SET to_return = 0.0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=xcodeset
      AND c.cdf_meaning=xcdf)
    DETAIL
     to_return = c.code_value
    WITH nocounter
   ;end select
   RETURN(to_return)
 END ;Subroutine
END GO
