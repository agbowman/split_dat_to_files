CREATE PROGRAM acm_get_ld_user_by_org:dba
 IF (validate(reply)=0)
  RECORD reply(
    1 user_name = vc
    1 user_id = f8
    1 status_block
      2 status_ind = i2
      2 status_code = i4
  ) WITH persistscript
 ENDIF
 DECLARE success = i4 WITH protect, constant(1)
 DECLARE failure = i4 WITH protect, constant(0)
 DECLARE unknown_status = i4 WITH protect, constant(- (1))
 DECLARE invalid_arg = i4 WITH protect, constant(- (2))
 DECLARE invalid_state = i4 WITH protect, constant(- (3))
 DECLARE default_user = i4 WITH protect, constant(2)
 DECLARE cur_datetime = q8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 SET reply->status_block.status_ind = failure
 SET reply->status_block.status_code = unknown_status
 SELECT INTO "nl:"
  ldnullind = nullind(ld.logical_domain_id), pnullind = nullind(p.person_id)
  FROM organization o,
   logical_domain ld,
   prsnl p
  PLAN (o
   WHERE (o.organization_id=request->organization_id)
    AND o.organization_id != 0
    AND o.active_ind=1)
   JOIN (ld
   WHERE ld.logical_domain_id=outerjoin(o.logical_domain_id))
   JOIN (p
   WHERE p.person_id=outerjoin(ld.system_user_id))
  DETAIL
   IF (((ldnullind=1) OR (pnullind=1)) )
    reply->status_block.status_code = invalid_state
   ELSEIF (ld.active_ind != 1)
    reply->status_block.status_code = invalid_state
   ELSEIF (p.person_id=0)
    reply->status_block.status_ind = success, reply->status_block.status_code = default_user, reply->
    user_id = 0
   ELSEIF (((p.active_ind != 1) OR ( NOT (cnvtdatetime(cur_datetime) BETWEEN p.beg_effective_dt_tm
    AND p.end_effective_dt_tm))) )
    reply->status_block.status_code = invalid_state
   ELSEIF (p.logical_domain_id != ld.logical_domain_id)
    reply->status_block.status_code = invalid_state
   ELSE
    reply->status_block.status_ind = success, reply->status_block.status_code = success, reply->
    user_id = p.person_id,
    reply->user_name = p.username
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual != 1)
  SET reply->status_block.status_ind = failure
  SET reply->status_block.status_code = invalid_arg
 ENDIF
END GO
