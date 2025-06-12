CREATE PROGRAM bed_get_eces_code_dup_check:dba
 FREE SET reply
 RECORD reply(
   1 dups[*]
     2 event_code_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_dups
 RECORD temp_dups(
   1 temp_dups[*]
     2 name = vc
     2 dup_ind = i2
 )
 SET reply->status_data.status = "F"
 SET cnt = size(request->names,5)
 SET stat = alterlist(temp_dups->temp_dups,cnt)
 FOR (x = 1 TO cnt)
   SET temp_dups->temp_dups[x].name = request->names[x].event_code_name
 ENDFOR
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM code_value cv,
    (dummyt d  WITH seq = cnt)
   PLAN (d)
    JOIN (cv
    WHERE cv.code_set=72
     AND cv.display_key=trim(cnvtupper(cnvtalphanum(temp_dups->temp_dups[d.seq].name)))
     AND cnvtupper(cv.display)=trim(cnvtupper(temp_dups->temp_dups[d.seq].name)))
   ORDER BY d.seq
   DETAIL
    temp_dups->temp_dups[d.seq].dup_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM v500_event_code vec,
    (dummyt d  WITH seq = cnt)
   PLAN (d)
    JOIN (vec
    WHERE vec.event_cd_disp_key=trim(cnvtupper(cnvtalphanum(temp_dups->temp_dups[d.seq].name)))
     AND cnvtupper(vec.event_cd_disp)=trim(cnvtupper(temp_dups->temp_dups[d.seq].name)))
   ORDER BY d.seq
   DETAIL
    temp_dups->temp_dups[d.seq].dup_ind = 1
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = cnt)
   PLAN (d
    WHERE (temp_dups->temp_dups[d.seq].dup_ind=1))
   ORDER BY d.seq
   HEAD REPORT
    ncnt = 0, nlist_cnt = 0, stat = alterlist(reply->dups,10)
   DETAIL
    ncnt = (ncnt+ 1), nlist_cnt = (nlist_cnt+ 1)
    IF (nlist_cnt > 10)
     stat = alterlist(reply->dups,(ncnt+ 10)), nlist_cnt = 1
    ENDIF
    reply->dups[ncnt].event_code_name = temp_dups->temp_dups[d.seq].name
   FOOT REPORT
    stat = alterlist(reply->dups,ncnt)
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
