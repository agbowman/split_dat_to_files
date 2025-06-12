CREATE PROGRAM aps_get_enctr_personnel:dba
 RECORD reply(
   1 qual[*]
     2 name_full_formatted = vc
     2 person_id = f8
     2 roll_cd = f8
     2 roll_disp = c40
     2 roll_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE consultphys = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"CONSULTDOC"))
 DECLARE orderphys = f8 WITH protect, constant(uar_get_code_by("MEANING",333,"ORDERDOC"))
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE (epr.encntr_id=request->encounter_id)
    AND epr.active_ind=1
    AND ((epr.manual_create_ind IN (0, null)) OR (epr.manual_create_ind=1
    AND epr.encntr_prsnl_r_cd IN (consultphys, orderphys)))
    AND epr.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE p.person_id=epr.prsnl_person_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(reply->qual,(cnt+ 9))
   ENDIF
   reply->qual[cnt].name_full_formatted = p.name_full_formatted, reply->qual[cnt].person_id = p
   .person_id, reply->qual[cnt].roll_cd = epr.encntr_prsnl_r_cd,
   CALL echo(build("name = ",reply->qual[cnt].name_full_formatted))
  FOOT REPORT
   stat = alterlist(reply->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PRSNL"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
