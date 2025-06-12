CREATE PROGRAM bed_get_source_vocab_cds:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 source_vocab[*]
      2 source_vocab_cd = f8
      2 source_vocab_disp = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET source_cnt = 0
 SELECT DISTINCT INTO "nl:"
  n.source_vocabulary_cd
  FROM nomenclature n,
   code_value cv
  PLAN (n
   WHERE n.active_ind=1
    AND n.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cv
   WHERE cv.code_value=n.source_vocabulary_cd)
  DETAIL
   IF (n.source_vocabulary_cd > 0)
    source_cnt = (source_cnt+ 1), stat = alterlist(reply->source_vocab,source_cnt), reply->
    source_vocab[source_cnt].source_vocab_cd = n.source_vocabulary_cd,
    reply->source_vocab[source_cnt].source_vocab_disp = cv.display
   ENDIF
  WITH nocounter
 ;end select
 CALL bederrorcheck("Error selecting nomenclature table")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
