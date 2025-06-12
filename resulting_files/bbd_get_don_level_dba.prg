CREATE PROGRAM bbd_get_don_level:dba
 RECORD reply(
   1 qual[*]
     2 person_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE script_name = c17 WITH constant("bbd_get_don_level")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE donor_count = i4 WITH protect, noconstant(0)
 DECLARE beg_donation_level = f8 WITH protect, noconstant(0.0)
 DECLARE end_donation_level = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 IF ((request->donation_level=- (1)))
  SET request->donation_level = 0
  SET request->end_donation_level = 999
 ENDIF
 SET beg_donation_level = (request->donation_level - 0.0005)
 SET end_donation_level = ((request->end_donation_level+ 1) - 0.0005)
 SELECT
  IF ((request->organization_id > 0.0))
   FROM person_org_reltn por,
    person_donor pd
   PLAN (por
    WHERE (por.organization_id=request->organization_id))
    JOIN (pd
    WHERE pd.person_id=por.person_id
     AND ((((pd.last_donation_dt_tm+ 0.0) BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime
    (cnvtlookahead("1,D",cnvtdatetime(request->end_dt_tm))))) OR ((request->begin_dt_tm=0)))
     AND ((((pd.donation_level+ 0.0) >= request->donation_level)
     AND ((((pd.donation_level+ 0.0) < end_donation_level)) OR ((request->end_donation_level >= 999)
    )) ) OR ((request->donation_level=- (1)))) )
  ELSEIF ((request->begin_dt_tm != 0)
   AND (request->end_donation_level < 999.0))
   FROM person_donor pd
   PLAN (pd
    WHERE pd.last_donation_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(
     cnvtlookahead("1,D",cnvtdatetime(request->end_dt_tm)))
     AND ((pd.donation_level+ 0.0) >= beg_donation_level)
     AND ((pd.donation_level+ 0.0) < end_donation_level))
  ELSEIF ((request->begin_dt_tm != 0))
   FROM person_donor pd
   PLAN (pd
    WHERE pd.last_donation_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(
     cnvtlookahead("1,D",cnvtdatetime(request->end_dt_tm)))
     AND ((pd.donation_level+ 0.0) >= beg_donation_level))
  ELSEIF ((request->end_donation_level < 999))
   FROM person_donor pd
   PLAN (pd
    WHERE pd.donation_level >= beg_donation_level
     AND pd.donation_level < end_donation_level)
  ELSE
   FROM person_donor pd
   PLAN (pd
    WHERE ((pd.donation_level+ 0.0) >= beg_donation_level))
  ENDIF
  INTO "nl:"
  pd.person_id
  ORDER BY pd.person_id
  HEAD REPORT
   donor_count = 0
  HEAD pd.person_id
   IF (pd.person_id > 0.0)
    donor_count = (donor_count+ 1)
    IF (mod(donor_count,10)=1)
     stat = alterlist(reply->qual,(donor_count+ 9))
    ENDIF
    reply->qual[donor_count].person_id = pd.person_id
   ENDIF
  DETAIL
   row + 0
  FOOT  pd.person_id
   row + 0
  FOOT REPORT
   stat = alterlist(reply->qual,donor_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select donors",errmsg)
 ENDIF
 GO TO set_status
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (donor_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
