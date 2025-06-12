CREATE PROGRAM bbt_get_info_mask:dba
 RECORD reply(
   1 formatted_ssn = vc
   1 mrnlist[*]
     2 formatted_mrn = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET alias_ssn = fillstring(30," ")
 SET alias_mrn = fillstring(50," ")
 SET ssn_format_cd = 0.0
 SET mrn_format_cd = 0.0
 SET count1 = 0
 SET reply->status_data.status = "I"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=4
   AND c.cdf_meaning="SSN"
  DETAIL
   ssn_format_cd = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=4
   AND c.cdf_meaning="MRN"
  DETAIL
   mrn_format_cd = c.code_value
  WITH nocounter
 ;end select
 SET meaning_cd = 0
 SELECT INTO "nl:"
  c.seq, p.seq
  FROM code_value c,
   person_alias p
  PLAN (c
   WHERE c.code_set=4
    AND c.cdf_meaning="SSN")
   JOIN (p
   WHERE (p.person_id=request->person_id)
    AND p.person_alias_type_cd=c.code_value
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   alias_ssn = p.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  new_alias = trim(cnvtalias(p.alias,p.alias_pool_cd))
  FROM person_alias p
  WHERE (p.person_id=request->person_id)
   AND p.alias=alias_ssn
   AND p.person_alias_type_cd=ssn_format_cd
  DETAIL
   reply->formatted_ssn = new_alias
  WITH nocounter
 ;end select
 SET meaning_cd = 0
 SELECT INTO "nl:"
  c.seq, p.seq
  FROM code_value c,
   person_alias p
  PLAN (c
   WHERE c.code_set=4
    AND c.cdf_meaning="MRN")
   JOIN (p
   WHERE (p.person_id=request->person_id)
    AND p.person_alias_type_cd=c.code_value
    AND p.active_ind=1
    AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND p.end_effective_dt_tm >= cnvtdatetime(sysdate))
  DETAIL
   count1 += 1
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->mrnlist,(count1+ 9))
   ENDIF
   alias_mrn = p.alias
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  new_alias = trim(cnvtalias(p.alias,p.alias_pool_cd))
  FROM person_alias p
  WHERE (p.person_id=request->person_id)
   AND p.alias=alias_mrn
   AND p.person_alias_type_cd=mrn_format_cd
  DETAIL
   reply->mrnlist[count1].formatted_mrn = new_alias
  WITH nocounter
 ;end select
 SET count1 += 1
 IF (count1 != 1)
  SET stat = alter(reply->status_data.subeventstatus,count1)
 ENDIF
#exit_program
 IF ((reply->status_data.status="I"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
