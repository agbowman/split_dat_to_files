CREATE PROGRAM dcp_chg_expire_rule:dba
 RECORD reply(
   1 expire_rule[*]
     2 rule_id = f8
     2 rule_name = vc
     2 prsnl_id = f8
     2 rule_dt_tm = dq8
     2 active_ind = i2
     2 authentic_flag_ind = i2
     2 rule_definition[*]
       3 rule_definition_id = f8
       3 rule_type_cd = f8
       3 param_name = vc
       3 param_value = vc
       3 merge_name = vc
       3 merge_id = f8
       3 location_cd = f8
       3 loc_facility_cd = f8
       3 seq_num = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "S"
 SET rulecnt = cnvtint(size(request->expire_rule,5))
 UPDATE  FROM expire_rule er,
   (dummyt d  WITH seq = value(rulecnt))
  SET er.obsolete_ind = 1, er.updt_dt_tm = cnvtdatetime(curdate,curtime3), er.updt_id = reqinfo->
   updt_id,
   er.updt_task = reqinfo->updt_task, er.updt_applctx = reqinfo->updt_applctx, er.updt_cnt = (er
   .updt_cnt+ 1)
  PLAN (d)
   JOIN (er
   WHERE (er.expire_rule_id=request->expire_rule[d.seq].expire_rule_id))
  WITH nocounter
 ;end update
 FOR (x = 1 TO rulecnt)
  DELETE  FROM rule_definition rd
   WHERE (rd.parent_entity_id=request->expire_rule[x].expire_rule_id)
    AND rd.parent_entity_name="EXPIRE_RULE"
   WITH nocounter
  ;end delete
  IF (curqual=0)
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
 ENDFOR
 EXECUTE dcp_add_expire_rule
 IF ((reply->status_data.status="F"))
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
