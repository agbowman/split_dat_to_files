CREATE PROGRAM cpmcachemanager_purgevalues:dba
 RECORD reply(
   1 rows_purged = i4
   1 rows_remaining = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD to_delete(
   1 code_values[*]
     2 code_value_changes_id = f8
 )
 DECLARE delete_cnt = i4 WITH noconstant(0)
 DECLARE node_id = f8 WITH noconstant(0.0)
 DECLARE i = i4 WITH noconstant(0)
 CALL echorecord(request)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM code_value_node cvn
  WHERE trim(cnvtlower(request->node_name),3)=trim(cnvtlower(cvn.node_name),3)
  DETAIL
   node_id = cvn.code_value_node_id
  WITH nocounter
 ;end select
 CALL echo(build("node_id:",node_id))
 CALL echo(build("code_value:",request->cvlistarray[1].cvlist[1].code_value))
 IF (node_id=0)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO size(request->cvlistarray,5))
  SELECT INTO "nl:"
   cvc.code_value
   FROM code_value_changes cvc,
    (dummyt d  WITH seq = value(size(request->cvlistarray[i].cvlist,5))),
    code_value cv
   PLAN (d)
    JOIN (cvc
    WHERE cvc.code_value_node_id=node_id
     AND (cvc.code_value=request->cvlistarray[i].cvlist[d.seq].code_value)
     AND cvc.updt_dt_tm <= cnvtdatetime(request->cvlistarray[i].cvlist[d.seq].updt_dt_tm))
    JOIN (cv
    WHERE cvc.code_value=cv.code_value)
   ORDER BY cvc.code_value
   DETAIL
    IF (((cv.end_effective_dt_tm <= cnvtdatetime(curdate,curtime3)) OR (((cv.end_effective_dt_tm >
    cnvtlookahead("2,Y",cnvtdatetime(curdate,curtime3))
     AND cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)) OR (cv.active_ind=0)) )) )
     delete_cnt = (delete_cnt+ 1)
     IF (mod(delete_cnt,500)=1)
      stat = alterlist(to_delete->code_values,(delete_cnt+ 499))
     ENDIF
     to_delete->code_values[delete_cnt].code_value_changes_id = cvc.code_value_changes_id
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   cvc.code_value
   FROM code_value_changes cvc,
    (dummyt d  WITH seq = value(size(request->cvlistarray[i].cvlist,5)))
   PLAN (d)
    JOIN (cvc
    WHERE cvc.code_value_node_id=node_id
     AND (cvc.code_value=request->cvlistarray[i].cvlist[d.seq].code_value)
     AND cvc.updt_dt_tm <= cnvtdatetime(request->cvlistarray[i].cvlist[d.seq].updt_dt_tm)
     AND  NOT ( EXISTS (
    (SELECT
     cv.code_value
     FROM code_value cv
     WHERE cv.code_value=cvc.code_value))))
   ORDER BY cvc.code_value
   DETAIL
    delete_cnt = (delete_cnt+ 1)
    IF (mod(delete_cnt,500)=1)
     stat = alterlist(to_delete->code_values,(delete_cnt+ 499))
    ENDIF
    to_delete->code_values[delete_cnt].code_value_changes_id = cvc.code_value_changes_id
   WITH nocounter
  ;end select
 ENDFOR
 IF (delete_cnt=0)
  SET reply->status_data.status = "S"
  GO TO exit_script
 ELSE
  SET stat = alterlist(to_delete->code_values,delete_cnt)
 ENDIF
 CALL echorecord(to_delete)
 DELETE  FROM code_value_changes cvc,
   (dummyt d  WITH seq = value(size(to_delete->code_values,5)))
  SET cvc.seq = 1
  PLAN (d)
   JOIN (cvc
   WHERE (to_delete->code_values[d.seq].code_value_changes_id=cvc.code_value_changes_id))
  WITH nocounter
 ;end delete
 IF (curqual=0)
  SET reply->rows_purged = 0
  GO TO exit_script
 ELSE
  COMMIT
  SET reply->status_data.status = "S"
  SET reply->rows_purged = size(to_delete->code_values,5)
 ENDIF
#exit_script
 SELECT INTO "nl:"
  cnt = count(*)
  FROM code_value_changes cvc
  WHERE cvc.code_value_node_id=node_id
  DETAIL
   reply->rows_remaining = cnt
  WITH nocounter
 ;end select
 CALL echorecord(reply)
END GO
