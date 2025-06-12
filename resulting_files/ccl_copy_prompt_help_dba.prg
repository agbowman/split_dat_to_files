CREATE PROGRAM ccl_copy_prompt_help:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD promptrec(
   1 qual[*]
     2 prompt_id = i4
     2 program_name = c30
     2 prompt_num = i4
     2 control_ind = i2
     2 active_ind = i2
     2 help_codeset = i4
     2 help_lookup = vc
     2 context_startval = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET errmsg = fillstring(255," ")
 SET cnt = 0
 SET promptfilter = fillstring(40," ")
 DECLARE newcnt = i2
 IF ((request->prompt_num=0))
  SET promptfilter = "c.prompt_num > 0"
 ELSE
  SET promptfilter = "c.prompt_num = request->prompt_num"
 ENDIF
 SELECT INTO "NL:"
  c.*
  FROM ccl_prompt_help c
  WHERE (c.program_name=request->program_name)
   AND parser(promptfilter)
  DETAIL
   cnt += 1
   IF (mod(cnt,10)=1)
    stat = alterlist(promptrec->qual,(cnt+ 9))
   ENDIF
   promptrec->qual[cnt].prompt_id = 0, promptrec->qual[cnt].program_name = request->new_program_name,
   promptrec->qual[cnt].prompt_num = c.prompt_num,
   promptrec->qual[cnt].control_ind = c.control_ind, promptrec->qual[cnt].help_codeset = c
   .help_codeset, promptrec->qual[cnt].help_lookup = c.help_lookup,
   promptrec->qual[cnt].active_ind = c.active_ind, promptrec->qual[cnt].context_startval = c
   .context_startval
  WITH nocounter
 ;end select
 SET stat = alterlist(promptrec->qual,cnt)
 SELECT INTO "NL:"
  nrecs = count(c.prompt_num)
  FROM ccl_prompt_help c
  WHERE (c.program_name=request->new_program_name)
  DETAIL
   newcnt = nrecs
  WITH nocounter
 ;end select
 IF (newcnt > 0)
  DELETE  FROM ccl_prompt_help c
   WHERE (c.program_name=request->new_program_name)
  ;end delete
  IF (cnt=0)
   GO TO exit_script
  ENDIF
 ENDIF
 SET i = 0
 FOR (i = 1 TO cnt)
   SELECT INTO "nl:"
    oracleseq = seq(ccl_prompt_help_seq,nextval)
    FROM dual
    DETAIL
     promptrec->qual[i].prompt_id = oracleseq
    WITH nocounter
   ;end select
 ENDFOR
 INSERT  FROM ccl_prompt_help c,
   (dummyt d  WITH seq = value(cnt))
  SET c.program_name = promptrec->qual[d.seq].program_name, c.prompt_id = promptrec->qual[d.seq].
   prompt_id, c.prompt_num = promptrec->qual[d.seq].prompt_num,
   c.control_ind = promptrec->qual[d.seq].control_ind, c.help_codeset = promptrec->qual[d.seq].
   help_codeset, c.help_lookup = promptrec->qual[d.seq].help_lookup,
   c.active_ind = promptrec->qual[d.seq].active_ind, c.context_startval = promptrec->qual[d.seq].
   context_startval, c.updt_dt_tm = cnvtdatetime(sysdate),
   c.updt_id = 0, c.updt_task = 0, c.updt_cnt = 0,
   c.updt_applctx = 0
  PLAN (d)
   JOIN (c
   WHERE 1=1)
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
  SET reply->status_data.subeventstatus[1].operationname = "get"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ccl_prompt_help"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  SET reqinfo->commit_ind = 0
  GO TO endit
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  GO TO endit
 ENDIF
#endit
END GO
