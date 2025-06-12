CREATE PROGRAM bed_get_alias_pool_types:dba
 IF ( NOT (validate(reply)))
  RECORD reply(
    1 alias_classes[*]
      2 name = vc
      2 code_set = i4
      2 alias_types[*]
        3 code_value = f8
        3 display = vc
        3 mean = vc
    1 error_msg = vc
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
 DECLARE getaliaspoolinfo(codeset=i4,aliasname=vc) = null
 DECLARE typecnt = i4 WITH protect, noconstant(0)
 DECLARE classcnt = i4 WITH protect, noconstant(0)
 CALL getaliaspoolinfo(4,"Person Alias")
 CALL getaliaspoolinfo(319,"Encounter Alias")
 CALL getaliaspoolinfo(320,"Personnel Alias")
 CALL getaliaspoolinfo(334,"Organization Alias")
 CALL getaliaspoolinfo(754,"Order Alias")
 CALL getaliaspoolinfo(25711,"Media Alias")
 CALL getaliaspoolinfo(26881,"Sch Event Alias")
 CALL getaliaspoolinfo(27121,"Health Plan Alias")
 CALL getaliaspoolinfo(27520,"ProfFit Encounter Alias")
 CALL getaliaspoolinfo(28200,"ProFit Bill Alias")
 CALL getaliaspoolinfo(4002262,"ProFit Receipt Alias")
 CALL getaliaspoolinfo(4001913,"Medication Claim Alias")
 CALL getaliaspoolinfo(4070,"PHM_ID Alias")
 CALL getaliaspoolinfo(4002035,"Claim Visit Alias")
 CALL getaliaspoolinfo(12801,"PowerTrials Alias")
 SUBROUTINE getaliaspoolinfo(codeset,aliasname)
   SET classcnt = (classcnt+ 1)
   SET stat = alterlist(reply->alias_classes,classcnt)
   SET reply->alias_classes[classcnt].code_set = codeset
   SET reply->alias_classes[classcnt].name = aliasname
   SET typecnt = 0
   SELECT INTO "nl:"
    FROM code_value cv
    PLAN (cv
     WHERE cv.code_set=codeset
      AND cv.active_ind=1
      AND cv.display > " ")
    DETAIL
     typecnt = (typecnt+ 1), stat = alterlist(reply->alias_classes[classcnt].alias_types,typecnt),
     reply->alias_classes[classcnt].alias_types[typecnt].code_value = cv.code_value,
     reply->alias_classes[classcnt].alias_types[typecnt].display = cv.display, reply->alias_classes[
     classcnt].alias_types[typecnt].mean = cv.cdf_meaning
    WITH nocounter
   ;end select
   CALL bederrorcheck(build("Error CS:",codeset))
 END ;Subroutine
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
