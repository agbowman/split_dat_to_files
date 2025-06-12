CREATE PROGRAM codecache_add_future_values:dba
 DECLARE node_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  FROM code_value_node cvn
  WHERE trim(cnvtlower(cvn.node_name),3)=trim(cnvtlower(curnode),3)
  DETAIL
   node_id = cvn.code_value_node_id
  WITH nocounter
 ;end select
 IF (node_id=0.0)
  SELECT INTO "nl:"
   nextseqnum = seq(reference_seq,nextval)"#################;rp0"
   FROM dual
   DETAIL
    node_id = cnvtreal(nextseqnum)
   WITH format
  ;end select
  INSERT  FROM code_value_node cvn
   SET cvn.code_value_node_id = node_id, cvn.node_name = trim(cnvtlower(curnode),3), cvn.updt_id = 0,
    cvn.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvn.updt_task = 0, cvn.updt_applctx = 0,
    cvn.updt_cnt = 0
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual=0)
  CALL echo("error occurred")
  GO TO exit_script
 ENDIF
 RECORD to_insert(
   1 values[*]
     2 code_value = f8
 )
 DECLARE value_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM code_value cv,
   dummyt d,
   code_value_changes cvc
  PLAN (cv
   WHERE ((cv.begin_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (cv.begin_effective_dt_tm
    <= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm < cnvtdatetime("31-DEC-2100")
    AND cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND cv.end_effective_dt_tm < cnvtlookahead("2,Y",cnvtdatetime(curdate,curtime3))
    AND cv.active_ind=1)) )
   JOIN (d)
   JOIN (cvc
   WHERE cvc.code_value=cv.code_value)
  HEAD REPORT
   value_cnt = 0
  DETAIL
   value_cnt = (value_cnt+ 1), stat = alterlist(to_insert->values,value_cnt), to_insert->values[
   value_cnt].code_value = cv.code_value
  WITH outerjoin = d, dontexist
 ;end select
 CALL echo(build("future values:",value_cnt))
 IF (value_cnt > 0)
  CALL echorecord(to_insert)
  INSERT  FROM code_value_changes cvc,
    (dummyt d  WITH seq = value(value_cnt))
   SET cvc.code_value_changes_id = seq(reference_seq,nextval), cvc.code_value = to_insert->values[d
    .seq].code_value, cvc.code_value_node_id = node_id,
    cvc.updt_id = 0, cvc.updt_dt_tm = cnvtdatetimeutc(cnvtdatetime(curdate,curtime3),4), cvc
    .updt_task = 0,
    cvc.updt_applctx = 0, cvc.updt_cnt = 0
   PLAN (d)
    JOIN (cvc)
   WITH nocounter
  ;end insert
 ENDIF
 IF (curqual > 0)
  COMMIT
 ENDIF
#exit_script
END GO
