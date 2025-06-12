CREATE PROGRAM cps_get_attending_doc:dba
 FREE SET reply
 RECORD reply(
   1 encounter_qual = i4
   1 encounter[*]
     2 encntr_id = f8
     2 provider_id = f8
     2 provider_full_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET true = 1
 SET false = 0
 SET reply->status_data.status = "F"
 SET attending_cd = 0.0
 SET code_set = 333
 SET code_value = 0.0
 SET cdf_meaning = "ATTENDDOC"
 SET errmsg = fillstring(132," ")
 SET errcode = 0
 EXECUTE cpm_get_cd_for_cdf
 SET attending_cd = code_value
 IF (code_value < 1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
  ELSE
   SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
    "Failed to find valid code_value for cdf_meaning ",trim(cdf_meaning)," in code_set ",trim(
     cnvtstring(code_set)))
  ENDIF
  GO TO end_program
 ENDIF
 SELECT DISTINCT INTO "nl:"
  epr.encntr_id, p.person_id
  FROM encntr_prsnl_reltn epr,
   prsnl p,
   (dummyt d  WITH seq = value(request->encounter_qual))
  PLAN (d
   WHERE d.seq > 0)
   JOIN (epr
   WHERE (epr.encntr_id=request->encounter[d.seq].encntr_id)
    AND epr.encntr_prsnl_r_cd=attending_cd
    AND epr.active_ind > 0
    AND epr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND epr.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id
    AND p.physician_ind=1)
  HEAD REPORT
   knt = 0, stat = alterlist(reply->encounter,10)
  DETAIL
   knt += 1
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->encounter,(knt+ 9))
   ENDIF
   reply->encounter[knt].encntr_id = request->encounter[d.seq].encntr_id, reply->encounter[knt].
   provider_id = p.person_id, reply->encounter[knt].provider_full_name = p.name_full_formatted
  FOOT REPORT
   reply->encounter_qual = knt, stat = alterlist(reply->encounter,knt)
  WITH nocounter, outerjoin = d, orahint("index(epr XIE2ENCNTR_PRSNL_RELTN) ")
 ;end select
 IF (curqual < 1)
  SET errcode = error(errmsg,1)
  IF (errcode > 0)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "ENCNTR_PRSNL_RELTN"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
   GO TO end_program
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#end_program
END GO
