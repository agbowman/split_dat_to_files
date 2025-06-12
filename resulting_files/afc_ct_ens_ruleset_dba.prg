CREATE PROGRAM afc_ct_ens_ruleset:dba
 DECLARE afc_ct_ens_ruleset_version = vc WITH private, noconstant("121604.FT.000")
 RECORD reply(
   1 ruleset_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 ruleset_id = f8
   1 ruleset_name = vc
   1 process_ind = i2
   1 beg_effective_dt_tm = dq8
 )
 DECLARE dtempid = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET reqinfo->commit_ind = 0
 IF ((request->active_ind=1))
  IF ((request->ruleset_id=0))
   SELECT INTO "nl:"
    next_seq = seq(pft_ref_seq,nextval)"###############;rp0"
    FROM dual
    DETAIL
     dtempid = next_seq
    WITH nocounter
   ;end select
   INSERT  FROM cs_cpp_ruleset r
    SET r.cs_cpp_ruleset_id = dtempid, r.prev_cs_cpp_ruleset_id = dtempid, r.ruleset_name = request->
     ruleset_name,
     r.ruleset_name_key = cnvtupper(cnvtalphanum(request->ruleset_name)), r.process_ind = request->
     process_ind, r.active_ind = 1,
     r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), r.end_effective_dt_tm = cnvtdatetime(
      "31-DEC-2100 23:59:59"), r.updt_cnt = 1,
     r.updt_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual < 1)
    GO TO end_script
   ENDIF
   SET reply->ruleset_id = dtempid
  ELSE
   SELECT INTO "nl:"
    FROM cs_cpp_ruleset r
    WHERE (r.cs_cpp_ruleset_id=request->ruleset_id)
    DETAIL
     temp->ruleset_id = r.cs_cpp_ruleset_id, temp->ruleset_name = r.ruleset_name, temp->process_ind
      = r.process_ind,
     temp->beg_effective_dt_tm = r.beg_effective_dt_tm
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    next_seq = seq(pft_ref_seq,nextval)"###############;rp0"
    FROM dual
    DETAIL
     dtempid = next_seq
    WITH nocounter
   ;end select
   INSERT  FROM cs_cpp_ruleset r
    SET r.cs_cpp_ruleset_id = dtempid, r.prev_cs_cpp_ruleset_id = temp->ruleset_id, r.ruleset_name =
     temp->ruleset_name,
     r.ruleset_name_key = cnvtupper(cnvtalphanum(temp->ruleset_name)), r.process_ind = temp->
     process_ind, r.active_ind = 0,
     r.beg_effective_dt_tm = cnvtdatetime(temp->beg_effective_dt_tm), r.end_effective_dt_tm =
     cnvtdatetime(curdate,curtime3), r.updt_cnt = 1,
     r.updt_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   UPDATE  FROM cs_cpp_ruleset r
    SET r.ruleset_name = request->ruleset_name, r.ruleset_name_key = cnvtupper(cnvtalphanum(request->
       ruleset_name)), r.process_ind = request->process_ind,
     r.active_ind = 1, r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_cnt = (r
     .updt_cnt+ 1),
     r.updt_id = reqinfo->updt_id, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_task =
     reqinfo->updt_task,
     r.updt_applctx = reqinfo->updt_applctx
    WHERE (r.cs_cpp_ruleset_id=request->ruleset_id)
    WITH nocounter
   ;end update
   IF (curqual < 1)
    GO TO end_script
   ENDIF
  ENDIF
 ELSE
  UPDATE  FROM cs_cpp_ruleset r
   SET r.active_ind = 0
   WHERE (r.cs_cpp_ruleset_id=request->ruleset_id)
   WITH nocounter
  ;end update
  IF (curqual < 1)
   GO TO end_script
  ENDIF
  UPDATE  FROM cs_cpp_rule r
   SET r.active_ind = 0
   WHERE (r.cs_cpp_ruleset_id=request->ruleset_id)
   WITH nocounter
  ;end update
  UPDATE  FROM cs_cpp_tier t
   SET t.active_ind = 0
   WHERE (t.cs_cpp_ruleset_id=request->ruleset_id)
   WITH nocounter
  ;end update
 ENDIF
#end_script
 SET v_errmsg2 = fillstring(132," ")
 SET v_err_code2 = 0
 SET v_err_code2 = error(v_errmsg2,1)
 IF (v_err_code2=0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->ruleset_id = - (1)
  SET reply->status_data.subeventstatus[1].targetobjectname = cnvtstring(v_err_code2)
  SET reply->status_data.subeventstatus[1].targetobjectvalue = v_errmsg2
 ENDIF
END GO
