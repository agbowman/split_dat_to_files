CREATE PROGRAM bed_ens_docset_migrated:dba
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
 FREE SET treq
 RECORD treq(
   1 reltns[*]
     2 dcp_section_ref_id = vc
     2 doc_set_section_ref_id = vc
 )
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET cnt = size(request->reltns,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(treq->reltns,cnt)
 FOR (x = 1 TO cnt)
  SET treq->reltns[x].dcp_section_ref_id = idtostring(request->reltns[x].dcp_section_ref_id)
  SET treq->reltns[x].doc_set_section_ref_id = idtostring(request->reltns[x].doc_set_section_ref_id)
 ENDFOR
 SET ierrcode = 0
 INSERT  FROM br_name_value b,
   (dummyt d  WITH seq = value(cnt))
  SET b.br_name_value_id = seq(bedrock_seq,nextval), b.br_nv_key1 = "DOCSETMIGRATE", b.br_name = treq
   ->reltns[d.seq].dcp_section_ref_id,
   b.br_value = treq->reltns[d.seq].doc_set_section_ref_id, b.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_cnt = 0, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET error_flag = "Y"
  SET reply->status_data.subeventstatus[1].targetobjectname = concat("Error on insert")
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  GO TO exit_script
 ENDIF
 SUBROUTINE idtostring(p1)
   DECLARE string1 = vc
   DECLARE string2 = vc
   SET string1 = build(p1)
   SET y = findstring(".",string1,1,0)
   SET string2 = substring(1,(y - 1),string1)
   RETURN(string2)
 END ;Subroutine
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
