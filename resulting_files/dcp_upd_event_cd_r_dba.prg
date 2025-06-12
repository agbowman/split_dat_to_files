CREATE PROGRAM dcp_upd_event_cd_r:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET x = 0
 SET reply->status_data.status = "F"
 SET qual_cnt = size(request->qual,5)
 SELECT INTO "nl:"
  cer.event_cd
  FROM (dummyt d1  WITH seq = value(qual_cnt)),
   code_value_event_r cer
  PLAN (d1)
   JOIN (cer
   WHERE (cer.parent_cd=request->qual[d1.seq].parent_cd)
    AND (cer.flex1_cd=request->qual[d1.seq].flex1_cd)
    AND (cer.flex2_cd=request->qual[d1.seq].flex2_cd)
    AND (cer.flex3_cd=request->qual[d1.seq].flex3_cd)
    AND (cer.flex4_cd=request->qual[d1.seq].flex4_cd)
    AND (cer.flex5_cd=request->qual[d1.seq].flex5_cd))
  DETAIL
   request->qual[d1.seq].flag = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO qual_cnt)
  IF ((request->qual[x].flag=1))
   DELETE  FROM code_value_event_r cer
    WHERE (cer.parent_cd=request->qual[x].parent_cd)
     AND (cer.flex1_cd=request->qual[x].flex1_cd)
     AND (cer.flex2_cd=request->qual[x].flex2_cd)
     AND (cer.flex3_cd=request->qual[x].flex3_cd)
     AND (cer.flex4_cd=request->qual[x].flex4_cd)
     AND (cer.flex5_cd=request->qual[x].flex5_cd)
    WITH nocounter
   ;end delete
  ENDIF
  INSERT  FROM code_value_event_r cer
   SET cer.event_cd = request->qual[x].event_cd, cer.parent_cd = request->qual[x].parent_cd, cer
    .flex1_cd = request->qual[x].flex1_cd,
    cer.flex2_cd = request->qual[x].flex2_cd, cer.flex3_cd = request->qual[x].flex3_cd, cer.flex4_cd
     = request->qual[x].flex4_cd,
    cer.flex5_cd = request->qual[x].flex5_cd, cer.updt_id = reqinfo->updt_id, cer.updt_task = reqinfo
    ->updt_task,
    cer.updt_applctx = reqinfo->updt_applctx, cer.updt_dt_tm = cnvtdatetime(curdate,curtime3)
   WITH nocounter
  ;end insert
 ENDFOR
 IF (curqual)
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
