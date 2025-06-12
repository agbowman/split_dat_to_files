CREATE PROGRAM ccl_add_prompt_help:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD seqrec(
   1 oracleseq[*]
     2 nextseq = i4
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET cnt = 0
 SET stat = 0
 DELETE  FROM ccl_prompt_help c
  WHERE (c.program_name=request->program_name)
 ;end delete
 SET cnt = size(request->prompt_list,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET i = 0
 FOR (i = 1 TO cnt)
  IF (mod(i,10)=1)
   SET stat = alterlist(seqrec->oracleseq,(i+ 9))
  ENDIF
  SELECT INTO "nl:"
   oracleseq = seq(ccl_prompt_help_seq,nextval)
   FROM dual
   DETAIL
    seqrec->oracleseq[i].nextseq = oracleseq
   WITH nocounter
  ;end select
 ENDFOR
 SET stat = alterlist(seqrec->oracleseq,cnt)
 INSERT  FROM ccl_prompt_help p,
   (dummyt d  WITH seq = value(cnt))
  SET p.prompt_id = seqrec->oracleseq[d.seq].nextseq, p.program_name = request->program_name, p
   .prompt_num = request->prompt_list[d.seq].prompt_num,
   p.control_ind = request->prompt_list[d.seq].control_ind, p.help_codeset = request->prompt_list[d
   .seq].help_codeset, p.help_lookup = request->prompt_list[d.seq].help_lookup,
   p.active_ind = 1, p.context_ind = request->prompt_list[d.seq].context_ind, p.context_startval =
   request->prompt_list[d.seq].context_startval,
   p.context_varname = request->prompt_list[d.seq].context_varname, p.updt_dt_tm = cnvtdatetime(
    curdate,curtime), p.updt_task = reqinfo->updt_task,
   p.updt_id = reqinfo->updt_id, p.updt_cnt = 1, p.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (p
   WHERE 1=1)
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  SET reply->status_data.status = "S"
  SET failed = "F"
 ELSE
  SET errcode = error(errmsg,1)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.subeventstatus[1].operationname = "add record"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_upd_prompt_help"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
END GO
