CREATE PROGRAM dcp_ens_doa:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ms_err_msg = vc WITH protect, noconstant("")
 DECLARE ms_operation_name = vc WITH protect, noconstant("")
 DECLARE ms_target_name = vc WITH protect, noconstant("")
 DECLARE mf_doa_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4002127,"DENIALACCESS"))
 DECLARE mf_doa_seal_id = f8 WITH protect, noconstant(0.0)
 DECLARE mf_doa_seal_part_id = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  FROM seal s,
   seal_participant sp
  PLAN (s
   WHERE (s.person_id=request->person_id)
    AND s.seal_type_cd=mf_doa_cd
    AND s.beg_effective_dt_tm=cnvtdatetime(request->beg_effective_dt_tm))
   JOIN (sp
   WHERE s.seal_id=sp.seal_id
    AND (sp.prsnl_id=request->prsnl_id))
  DETAIL
   mf_doa_seal_id = s.seal_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM seal s
  PLAN (s
   WHERE s.seal_id=mf_doa_seal_id)
  WITH nocounter, forupdate(s)
 ;end select
 IF (mf_doa_seal_id > 0)
  CALL updatedoa(1)
 ELSE
  CALL adddoa(1)
 ENDIF
 SUBROUTINE (updatedoa(x=i2) =null)
  UPDATE  FROM seal s
   SET s.active_ind = 0, s.end_effective_dt_tm = cnvtdatetime(sysdate), s.updt_cnt = (s.updt_cnt+ 1),
    s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_task = reqinfo->updt_task, s.updt_id = reqinfo->
    updt_id,
    s.updt_applctx = reqinfo->updt_applctx, s.comment_txt = request->comment_txt, s.reason_cd =
    request->reason_cd
   PLAN (s
    WHERE s.seal_id=mf_doa_seal_id)
   WITH nocounter
  ;end update
  IF (curqual != 1)
   SET reply->status_data.status = "F"
   SET ms_operation_name = "UPDATE"
   SET ms_err_msg = "Failed to update row to seal table."
   SET ms_target_name = "SEAL and SEAL_PARTICIPANT"
   GO TO exit_program
  ENDIF
 END ;Subroutine
 SUBROUTINE (adddoa(x=i2) =null)
   SELECT INTO "nl:"
    y = seq(pco_seq,nextval)
    FROM dual
    DETAIL
     mf_doa_seal_id = cnvtreal(y)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    y = seq(pco_seq,nextval)
    FROM dual
    DETAIL
     mf_doa_seal_part_id = cnvtreal(y)
    WITH nocounter
   ;end select
   IF (((mf_doa_seal_id=0) OR (mf_doa_seal_part_id=0)) )
    SET reply->status_data.status = "F"
    SET ms_operation_name = "SEQ"
    SET ms_err_msg = "Failed to retrieve sequence."
    SET ms_target_name = ""
    GO TO exit_program
   ENDIF
   INSERT  FROM seal s
    SET s.active_ind = 1, s.beg_effective_dt_tm = cnvtdatetime(request->beg_effective_dt_tm), s
     .created_by_id = request->created_by_id,
     s.person_id = request->person_id, s.seal_id = mf_doa_seal_id, s.seal_type_cd = mf_doa_cd,
     s.comment_txt = request->comment_txt, s.reason_cd = request->reason_cd, s.updt_cnt = 0,
     s.updt_dt_tm = cnvtdatetime(sysdate), s.updt_task = reqinfo->updt_task, s.updt_id = reqinfo->
     updt_id,
     s.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET reply->status_data.status = "F"
    SET ms_operation_name = "INSERT"
    SET ms_err_msg = "Failed to insert row to seal table."
    SET ms_target_name = "SEAL"
    GO TO exit_program
   ENDIF
   INSERT  FROM seal_participant sp
    SET sp.prsnl_id = request->prsnl_id, sp.seal_id = mf_doa_seal_id, sp.seal_participant_id =
     mf_doa_seal_part_id,
     sp.updt_cnt = 0, sp.updt_dt_tm = cnvtdatetime(sysdate), sp.updt_task = reqinfo->updt_task,
     sp.updt_id = reqinfo->updt_id, sp.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET reply->status_data.status = "F"
    SET ms_operation_name = "INSERT"
    SET ms_err_msg = "Failed to insert row to seal participant table."
    SET ms_target_name = "SEAL_PARTICIPANT"
    GO TO exit_program
   ENDIF
 END ;Subroutine
#exit_program
 IF ((reply->status_data.status="F"))
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ms_err_msg
  SET reply->status_data.subeventstatus[1].operationname = ms_operation_name
  SET reply->status_data.subeventstatus[1].targetobjectname = ms_target_name
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "001 05/15/07 MS5566"
END GO
