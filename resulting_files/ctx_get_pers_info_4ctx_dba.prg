CREATE PROGRAM ctx_get_pers_info_4ctx:dba
 RECORD reply(
   1 username = vc
   1 email = vc
   1 position_cd = f8
   1 position_disp = c40
   1 physician_ind = i2
   1 name_last = vc
   1 name_first = vc
   1 active_ind = i2
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  a.username, a.name_last, a.name_first,
  a.active_ind, a.physician_ind, a.position_cd,
  a.beg_effective_dt_tm, a.end_effective_dt_tm, a.email,
  nullind_a_beg_effective_dt_tm = nullind(a.beg_effective_dt_tm), nullind_a_end_effective_dt_tm =
  nullind(a.end_effective_dt_tm)
  FROM prsnl a
  WHERE (a.username=request->username)
  DETAIL
   reply->username = a.username, reply->name_last = a.name_last, reply->name_first = a.name_first,
   reply->active_ind = a.active_ind, reply->position_cd = a.position_cd, reply->physician_ind = a
   .physician_ind,
   reply->beg_effective_dt_tm =
   IF (nullind_a_beg_effective_dt_tm=0) cnvtdatetime(a.beg_effective_dt_tm)
   ENDIF
   , reply->end_effective_dt_tm =
   IF (nullind_a_end_effective_dt_tm=0) cnvtdatetime(a.end_effective_dt_tm)
   ENDIF
   , reply->email = a.email
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "application"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "none qualified"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
