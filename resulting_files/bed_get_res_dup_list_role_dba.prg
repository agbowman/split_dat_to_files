CREATE PROGRAM bed_get_res_dup_list_role:dba
 FREE SET reply
 RECORD reply(
   1 dups[*]
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_dup
 RECORD temp_dup(
   1 check_list[*]
     2 mnemonic = vc
     2 dup_ind = i2
 )
 SET reply->status_data.status = "F"
 SET tot_cnt = 0
 SET req_cnt = size(request->check_list,5)
 SET stat = alterlist(temp_dup->check_list,req_cnt)
 FOR (x = 1 TO req_cnt)
   SET temp_dup->check_list[x].mnemonic = request->check_list[x].mnemonic
 ENDFOR
 IF (req_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = req_cnt),
    sch_role s
   PLAN (d)
    JOIN (s
    WHERE s.mnemonic_key=trim(cnvtupper(temp_dup->check_list[d.seq].mnemonic)))
   ORDER BY d.seq
   HEAD d.seq
    temp_dup->check_list[d.seq].dup_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = req_cnt),
    code_value cv
   PLAN (d
    WHERE (temp_dup->check_list[d.seq].dup_ind=0))
    JOIN (cv
    WHERE cv.code_set=14250
     AND cv.display_key=trim(cnvtupper(cnvtalphanum(temp_dup->check_list[d.seq].mnemonic))))
   ORDER BY d.seq
   HEAD d.seq
    temp_dup->check_list[d.seq].dup_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 SET rep_cnt = 0
 SET stat = alterlist(reply->dups,req_cnt)
 FOR (x = 1 TO req_cnt)
   IF ((temp_dup->check_list[x].dup_ind=1))
    SET rep_cnt = (rep_cnt+ 1)
    SET reply->dups[rep_cnt].mnemonic = temp_dup->check_list[x].mnemonic
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->dups,rep_cnt)
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
