CREATE PROGRAM bed_get_provider_taxonomy:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 taxonomyterm[*]
      2 code = vc
      2 providertype = vc
      2 classification = vc
      2 specialization = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
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
 SET reply->status_data.status = "F"
 DECLARE counter = i4 WITH noconstant(0.0)
 DECLARE provider_code_set = f8 WITH constant(29220.0)
 DECLARE classification_code_set = f8 WITH constant(29221.0)
 DECLARE specialization_code_set = f8 WITH constant(29222.0)
 DECLARE no_code_value = f8 WITH constant(689501.0)
 SELECT INTO "nl:"
  FROM provider_taxonomy p,
   code_value cvp,
   code_value cvc,
   code_value cvs
  PLAN (p
   WHERE p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cvp
   WHERE p.provider_type_cd=cvp.code_value
    AND cvp.code_set=provider_code_set
    AND cvp.active_ind=1
    AND cvp.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cvp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cvc
   WHERE p.classification_cd=cvc.code_value
    AND cvc.code_set=classification_code_set
    AND cvc.active_ind=1
    AND cvc.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cvc.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (cvs
   WHERE p.specialization_cd=cvs.code_value
    AND cvs.code_set=specialization_code_set
    AND cvs.active_ind=1
    AND cvs.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND cvs.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY cvp.display, cvc.display, cvs.display
  DETAIL
   counter = (counter+ 1), stat = alterlist(reply->taxonomyterm,counter), reply->taxonomyterm[counter
   ].code = p.taxonomy,
   reply->taxonomyterm[counter].providertype = cvp.display, reply->taxonomyterm[counter].
   classification = cvc.display, reply->taxonomyterm[counter].specialization = evaluate(cvs
    .code_value,no_code_value,trim(""),cvs.display)
  WITH nocounter
 ;end select
 CALL bederrorcheck("Invalid Taxonomy Codes")
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
 CALL bederrorcheck("Descriptive error message not provided.")
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
