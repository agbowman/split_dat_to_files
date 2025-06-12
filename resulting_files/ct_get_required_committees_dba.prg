CREATE PROGRAM ct_get_required_committees:dba
 RECORD reply(
   1 committees[*]
     2 committee_id = f8
     2 committee_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE com_cnt = i2 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET last_mod = "001"
 SET mod_date = "Jan 10, 2006"
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 SELECT INTO "nl:"
  FROM prot_amd_committee_reltn pacr,
   committee cm
  PLAN (pacr
   WHERE (pacr.prot_amendment_id=request->prot_amendment_id)
    AND pacr.validate_ind=1
    AND pacr.active_ind=1)
   JOIN (cm
   WHERE cm.committee_id=pacr.committee_id
    AND cm.end_effective_dt_tm >= cnvtdatetime("31-dec-2100 00:00:00.00"))
  HEAD REPORT
   com_cnt = 0
  DETAIL
   com_cnt = (com_cnt+ 1)
   IF (com_cnt > size(reply->committees,5))
    stat = alterlist(reply->committees,(com_cnt+ 5))
   ENDIF
   reply->committees[com_cnt].committee_id = pacr.committee_id, reply->committees[com_cnt].
   committee_name = cm.committee_name
  FOOT REPORT
   stat = alterlist(reply->committees,com_cnt)
  WITH counter
 ;end select
 CALL echo(build("curqual",curqual))
 IF (curqual=0
  AND com_cnt > 0)
  CALL report_failure("SELECT","F","CT_GET_REQUIRED_COMMITTEES",
   "Failed to retrieve required committees.")
  GO TO exit_script
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   IF (opstatus="F")
    SET failed = "T"
   ENDIF
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
