CREATE PROGRAM bed_ens_sets_by_contr_system:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET scnt = 0
 SET scnt = size(request->segments,5)
 FOR (s = 1 TO scnt)
   DELETE  FROM br_contr_cs_r b
    WHERE (b.contributor_system_cd=request->contributor_system_code_value)
     AND (b.segment_name=request->segments[s].segment)
    WITH nocounter
   ;end delete
   SET ccnt = 0
   SET ccnt = size(request->segments[s].code_sets,5)
   FOR (c = 1 TO ccnt)
     INSERT  FROM br_contr_cs_r b
      SET b.br_contr_cs_r_id = seq(bedrock_seq,nextval), b.contributor_system_cd = request->
       contributor_system_code_value, b.segment_name = request->segments[s].segment,
       b.codeset = request->segments[s].code_sets[c].code_set, b.updt_cnt = 0, b.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
       updt_applctx
      WITH nocounter
     ;end insert
   ENDFOR
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
