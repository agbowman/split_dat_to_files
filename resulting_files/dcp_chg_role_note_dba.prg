CREATE PROGRAM dcp_chg_role_note:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt[500] = 0
 SET failed = "F"
 SET count1 = 0
 SET number_to_chg = size(request->qual,5)
 SELECT INTO "nl:"
  n.*
  FROM note_type_list n,
   (dummyt d  WITH seq = value(number_to_chg))
  PLAN (d)
   JOIN (n
   WHERE (n.note_type_list_id=request->qual[d.seq].note_type_list_id))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1), cur_updt_cnt[count1] = n.updt_cnt
  WITH nocounter, forupdate(p)
 ;end select
 IF (count1 != number_to_chg)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 UPDATE  FROM note_type_list n,
   (dummyt d  WITH seq = value(number_to_chg))
  SET n.seq = 1, n.seq_num = request->qual[d.seq].seq_num, n.updt_cnt = (n.updt_cnt+ 1),
   n.updt_dt_tm = cnvtdatetime(curdate,curtime3), n.updt_id = reqinfo->updt_id, n.updt_task = reqinfo
   ->updt_task,
   n.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (n
   WHERE (n.note_type_list_id=request->qual[d.seq].note_type_list_id))
  WITH nocounter
 ;end update
 CALL echo(build("curqual ",curqual))
 IF (curqual != number_to_chg)
  SET failed = "T"
 ENDIF
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
  SET reply->status_data.status = "S"
 ENDIF
END GO
