CREATE PROGRAM ct_get_pt_settings:dba
 RECORD reply(
   1 not_interested_ind = i2
   1 interest_cd = f8
   1 not_interested_dt_tm = dq8
   1 not_interested_prsnl_name = vc
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
 DECLARE bfound = i2 WITH protect, noconstant(0)
 DECLARE interested_cd = f8 WITH protect, noconstant(0.0)
 DECLARE notinterested_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET bstat = uar_get_meaning_by_codeset(17910,"INTERESTED",1,interested_cd)
 SET bstat = uar_get_meaning_by_codeset(17910,"NOTINTEREST",1,notinterested_cd)
 SELECT INTO "NL:"
  FROM ct_pt_settings cts,
   prsnl p
  PLAN (cts
   WHERE (cts.person_id=request->person_id)
    AND cts.active_ind=1)
   JOIN (p
   WHERE p.person_id=cts.not_interested_prsnl_id)
  DETAIL
   bfound = 1, reply->not_interested_ind = cts.not_interested_ind
   IF (cts.not_interested_ind=1)
    reply->interest_cd = notinterested_cd
   ELSEIF (cts.not_interested_ind=0)
    reply->interest_cd = interested_cd
   ENDIF
   reply->not_interested_dt_tm = cts.not_interested_dt_tm, reply->not_interested_prsnl_name = p
   .name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual=0
  AND bfound=1)
  SET failed = "T"
  CALL echo("Failed to find row in ct_pt_settings table.")
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
  COMMIT
 ENDIF
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "001"
 SET mod_date = "August 20, 2008"
END GO
