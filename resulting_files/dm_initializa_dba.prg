CREATE PROGRAM dm_initializa:dba
 RECORD reply(
   1 auth_cd = f8
   1 auth_display = c100
   1 unauth_cd = f8
   1 inactive_cd = f8
   1 inactive_display = c100
   1 active_cd = f8
   1 active_display = c100
   1 esi_trans_id = f8
   1 current_user_name = c100
   1 current_user_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET new_nbr = 0
 SELECT INTO "nl:"
  d.seq
  FROM dm_transactions d
  WHERE d.description="ESI SERVER"
  DETAIL
   reply->esi_trans_id = d.transaction_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   y = seq(reference_seq,nextval)"##################;rp0"
   FROM dual
   DETAIL
    new_nbr = cnvtreal(y), reply->esi_trans_id = new_nbr
   WITH format, counter
  ;end select
  INSERT  FROM dm_transactions d
   SET d.transaction_id = new_nbr, d.description = "ESI SERVER", d.updt_applctx = 12218,
    d.updt_dt_tm = cnvtdatetime(curdate,curtime3), d.updt_cnt = 0, d.updt_id = 12218,
    d.updt_task = 12218, d.transaction_cat_cd = 0
   WITH nocounter
  ;end insert
 ENDIF
 SELECT INTO "nl:"
  p.person_id, p.name_full_formatted
  FROM prsnl p
  WHERE (p.username=request->username)
   AND p.active_ind=1
   AND p.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->current_user_id = p.person_id, reply->current_user_name = substring(1,30,p
    .name_full_formatted)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value, c.display
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="AUTH"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->auth_cd = c.code_value, reply->auth_display = c.display
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=8
   AND c.cdf_meaning="UNAUTH"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->unauth_cd = c.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="INACTIVE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->inactive_cd = c.code_value, reply->inactive_display = substring(1,12,c.display)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.seq
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
   AND c.active_ind=1
   AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
  DETAIL
   reply->active_cd = c.code_value, reply->active_display = substring(1,12,c.display)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
 COMMIT
#end_script
END GO
