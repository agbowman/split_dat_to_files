CREATE PROGRAM bbd_get_don_eligibility:dba
 RECORD reply(
   1 success_ind = i2
   1 eligibility_type = vc
   1 eligible_dt = dq8
   1 procedure_type = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET nbr_days = 0
 SET reply->success_ind = 0
 SET reply->procedure_type = ""
 SELECT INTO "nl:"
  pd.eligibility_type_cd, pd.defer_until_dt_tm
  FROM person_donor pd
  WHERE (pd.person_id=request->person_id)
  DETAIL
   reply->eligibility_type = uar_get_code_meaning(pd.eligibility_type_cd), reply->eligible_dt =
   cnvtdatetime(pd.defer_until_dt_tm)
   IF (pd.defer_until_dt_tm=0.000000)
    nbr_days = 0
   ELSE
    nbr_days = datetimediff(cnvtdatetime(request->scheduled_dt),reply->eligible_dt)
   ENDIF
  WITH nocounter
 ;end select
 IF ((reply->eligibility_type="PERMNENT"))
  SET reply->success_ind = 0
  SET reply->eligible_dt = cnvtdatetime(0,0)
 ELSEIF ((reply->eligibility_type="TEMP"))
  IF (nbr_days < 0)
   SET reply->success_ind = 0
  ELSE
   SET reply->success_ind = 1
  ENDIF
 ELSEIF ((reply->eligibility_type="GOOD"))
  SELECT INTO "nl:"
   p.days_until_eligible, d.drawn_dt_tm
   FROM bbd_donation_results d,
    procedure_eligibility_r p
   PLAN (d
    WHERE (d.person_id=request->person_id)
     AND d.active_ind=1)
    JOIN (p
    WHERE (p.procedure_cd=request->procedure_cd)
     AND p.prev_procedure_cd=d.procedure_cd)
   DETAIL
    reply->eligible_dt = datetimeadd(d.drawn_dt_tm,p.days_until_eligible), "mm/dd/yyyy;;d", reply->
    procedure_type = uar_get_code_meaning(request->procedure_cd),
    nbr_days = datetimediff(cnvtdatetime(request->scheduled_dt),reply->eligible_dt)
    IF (nbr_days < 0)
     reply->success_ind = 0, reply->eligible_dt = datetimeadd(d.drawn_dt_tm,p.days_until_eligible),
     "mm/dd/yyyy;;d"
    ELSE
     reply->success_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#end_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
