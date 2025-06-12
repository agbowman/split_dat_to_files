CREATE PROGRAM cdi_get_cm_logins:dba
 RECORD reply(
   1 logins[*]
     2 cdi_cm_login_id = f8
     2 username = vc
     2 password = vc
     2 organization_id = f8
     2 org_default_ind = i2
     2 updt_cnt = i4
     2 positions[*]
       3 cdi_cm_login_position_id = f8
       3 position_cd = f8
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count1 = i4 WITH noconstant(0), protect
 DECLARE count2 = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SELECT INTO "NL:"
  FROM cdi_cm_login cl,
   cdi_cm_login_position cp
  PLAN (cl
   WHERE cl.cdi_cm_login_id != 0)
   JOIN (cp
   WHERE outerjoin(cl.cdi_cm_login_id)=cp.cdi_cm_login_id)
  ORDER BY cl.cm_username, cl.organization_id
  HEAD REPORT
   stat = alterlist(reply->logins,10), count1 = 0
  HEAD cl.cm_username
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->logins,(count1+ 9))
   ENDIF
   reply->logins[count1].cdi_cm_login_id = cl.cdi_cm_login_id, reply->logins[count1].username = cl
   .cm_username, reply->logins[count1].password = cl.cm_password,
   reply->logins[count1].organization_id = cl.organization_id, reply->logins[count1].org_default_ind
    = cl.org_default_ind, reply->logins[count1].updt_cnt = cl.updt_cnt,
   count2 = 0, stat = alterlist(reply->logins[count1].positions,10)
  DETAIL
   IF (cp.cdi_cm_login_position_id > 0.0)
    count2 = (count2+ 1)
    IF (mod(count2,10)=1
     AND count2 != 1)
     stat = alterlist(reply->logins[count1].positions,(count2+ 9))
    ENDIF
    reply->logins[count1].positions[count2].cdi_cm_login_position_id = cp.cdi_cm_login_position_id,
    reply->logins[count1].positions[count2].position_cd = cp.position_cd, reply->logins[count1].
    positions[count2].updt_cnt = cp.updt_cnt
   ENDIF
  FOOT  cl.cm_username
   stat = alterlist(reply->logins[count1].positions,count2)
  FOOT REPORT
   stat = alterlist(reply->logins,count1)
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
