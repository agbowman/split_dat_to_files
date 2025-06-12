CREATE PROGRAM bbd_get_procedures:dba
 RECORD reply(
   1 procedurelist[*]
     2 procedure_id = f8
     2 procedure_cd = f8
     2 procedure_disp = c40
     2 procedure_desc = c60
     2 procedure_mean = c12
     2 deferrals_allowed_cd = f8
     2 deferrals_allowed_disp = c40
     2 deferrals_allowed_desc = c60
     2 deferrals_allowed_mean = c12
     2 nbr_per_volume_level = i4
     2 schedule_ind = i2
     2 start_stop_ind = i2
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 outcomelist[*]
       3 procedure_outcome_id = f8
       3 procedure_id = f8
       3 outcome_cd = f8
       3 outcome_disp = c40
       3 outcome_desc = c60
       3 outcome_mean = c12
       3 count_as_donation_ind = i2
       3 synonym_id = f8
       3 add_product_ind = i2
       3 quar_reason_cd = f8
       3 quar_reason_disp = c40
       3 quar_reason_desc = c60
       3 quar_reason_mean = c12
       3 beg_effective_dt_tm = dq8
       3 end_effective_dt_tm = dq8
       3 active_ind = i2
       3 reasonlist[*]
         4 outcome_reason_id = f8
         4 procedure_outcome_id = f8
         4 reason_cd = f8
         4 reason_disp = c40
         4 reason_desc = c60
         4 reason_mean = c12
         4 days_ineligible = i4
         4 hours_ineligible = i4
         4 deferral_expire_cd = f8
         4 deferral_expire_disp = c40
         4 deferral_expire_desc = c60
         4 deferral_expire_mean = c12
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
       3 bagtypelist[*]
         4 outcome_bag_type_id = f8
         4 procedure_outcome_id = f8
         4 bag_type_cd = f8
         4 bag_type_disp = c40
         4 bag_type_desc = c60
         4 bag_type_mean = c12
         4 default_ind = i2
         4 beg_effective_dt_tm = dq8
         4 end_effective_dt_tm = dq8
         4 active_ind = i2
         4 productlist[*]
           5 bag_type_product_id = f8
           5 outcome_bag_type_id = f8
           5 product_cd = f8
           5 product_disp = c40
           5 product_desc = c60
           5 product_mean = c12
           5 default_ind = i2
           5 beg_effective_dt_tm = dq8
           5 end_effective_dt_tm = dq8
           5 active_ind = i2
     2 default_donation_type_cd = f8
     2 default_donation_type_disp = c40
     2 default_donation_type_mean = c12
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
 DECLARE script_name = c18 WITH constant("bbd_get_procedures")
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE p_cnt = i4 WITH noconstant(0)
 DECLARE o_cnt = i4 WITH noconstant(0)
 DECLARE r_cnt = i4 WITH noconstant(0)
 DECLARE b_cnt = i4 WITH noconstant(0)
 DECLARE pr_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  bdp.*, bpo.*, bor.*,
  bobt.*, bbtp.*, outcome_path = decode(bpo.seq,1,0),
  bag_reason_path = decode(bor.seq,1,bobt.seq,2,0), product_path = decode(bbtp.seq,1,0)
  FROM bbd_donation_procedure bdp,
   bbd_procedure_outcome bpo,
   bbd_outcome_reason bor,
   bbd_outcome_bag_type bobt,
   bbd_bag_type_product bbtp,
   dummyt d1,
   dummyt d2,
   dummyt d3,
   dummyt d4
  PLAN (bdp
   WHERE bdp.procedure_id > 0.0
    AND bdp.active_ind=1)
   JOIN (d1)
   JOIN (bpo
   WHERE bpo.procedure_id=bdp.procedure_id
    AND bpo.active_ind=1)
   JOIN (((d2)
   JOIN (bor
   WHERE bor.procedure_outcome_id=bpo.procedure_outcome_id
    AND bor.active_ind=1)
   ) ORJOIN ((d3)
   JOIN (bobt
   WHERE bobt.procedure_outcome_id=bpo.procedure_outcome_id
    AND bobt.active_ind=1)
   JOIN (d4)
   JOIN (bbtp
   WHERE bbtp.outcome_bag_type_id=bobt.outcome_bag_type_id
    AND bbtp.active_ind=1)
   ))
  ORDER BY bdp.procedure_id, bpo.procedure_outcome_id, bor.outcome_reason_id,
   bobt.outcome_bag_type_id, bbtp.bag_type_product_id
  HEAD REPORT
   p_cnt = 0
  HEAD bdp.procedure_id
   o_cnt = 0, p_cnt = (p_cnt+ 1)
   IF (mod(p_cnt,10)=1)
    stat = alterlist(reply->procedurelist,(p_cnt+ 9))
   ENDIF
   reply->procedurelist[p_cnt].procedure_id = bdp.procedure_id, reply->procedurelist[p_cnt].
   procedure_cd = bdp.procedure_cd, reply->procedurelist[p_cnt].deferrals_allowed_cd = bdp
   .deferrals_allowed_cd,
   reply->procedurelist[p_cnt].nbr_per_volume_level = bdp.nbr_per_volume_level, reply->procedurelist[
   p_cnt].schedule_ind = bdp.schedule_ind, reply->procedurelist[p_cnt].start_stop_ind = bdp
   .start_stop_ind,
   reply->procedurelist[p_cnt].beg_effective_dt_tm = bdp.beg_effective_dt_tm, reply->procedurelist[
   p_cnt].end_effective_dt_tm = bdp.end_effective_dt_tm, reply->procedurelist[p_cnt].active_ind = bdp
   .active_ind,
   reply->procedurelist[p_cnt].default_donation_type_cd = bdp.default_donation_type_cd
  HEAD bpo.procedure_outcome_id
   IF (outcome_path=1)
    r_cnt = 0, b_cnt = 0, o_cnt = (o_cnt+ 1)
    IF (mod(o_cnt,10)=1)
     stat = alterlist(reply->procedurelist[p_cnt].outcomelist,(o_cnt+ 9))
    ENDIF
    reply->procedurelist[p_cnt].outcomelist[o_cnt].procedure_outcome_id = bpo.procedure_outcome_id,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].procedure_id = bpo.procedure_id, reply->
    procedurelist[p_cnt].outcomelist[o_cnt].outcome_cd = bpo.outcome_cd,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].count_as_donation_ind = bpo.count_as_donation_ind,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].synonym_id = bpo.synonym_id, reply->procedurelist[
    p_cnt].outcomelist[o_cnt].add_product_ind = bpo.add_product_ind,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].quar_reason_cd = bpo.quar_reason_cd, reply->
    procedurelist[p_cnt].outcomelist[o_cnt].beg_effective_dt_tm = bpo.beg_effective_dt_tm, reply->
    procedurelist[p_cnt].outcomelist[o_cnt].end_effective_dt_tm = bpo.end_effective_dt_tm,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].active_ind = bpo.active_ind
   ENDIF
  HEAD bor.outcome_reason_id
   IF (bag_reason_path=1)
    r_cnt = (r_cnt+ 1)
    IF (mod(r_cnt,10)=1)
     stat = alterlist(reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist,(r_cnt+ 9))
    ENDIF
    reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist[r_cnt].outcome_reason_id = bor
    .outcome_reason_id, reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist[r_cnt].
    procedure_outcome_id = bor.procedure_outcome_id, reply->procedurelist[p_cnt].outcomelist[o_cnt].
    reasonlist[r_cnt].reason_cd = bor.reason_cd,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist[r_cnt].days_ineligible = bor
    .days_ineligible, reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist[r_cnt].
    hours_ineligible = bor.hours_ineligible, reply->procedurelist[p_cnt].outcomelist[o_cnt].
    reasonlist[r_cnt].deferral_expire_cd = bor.deferral_expire_cd,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist[r_cnt].beg_effective_dt_tm = bor
    .beg_effective_dt_tm, reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist[r_cnt].
    end_effective_dt_tm = bor.end_effective_dt_tm, reply->procedurelist[p_cnt].outcomelist[o_cnt].
    reasonlist[r_cnt].active_ind = bor.active_ind
   ENDIF
  HEAD bobt.outcome_bag_type_id
   IF (bag_reason_path=2)
    pr_cnt = 0, b_cnt = (b_cnt+ 1)
    IF (mod(b_cnt,10)=1)
     stat = alterlist(reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist,(b_cnt+ 9))
    ENDIF
    reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].outcome_bag_type_id = bobt
    .outcome_bag_type_id, reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].
    procedure_outcome_id = bobt.procedure_outcome_id, reply->procedurelist[p_cnt].outcomelist[o_cnt].
    bagtypelist[b_cnt].bag_type_cd = bobt.bag_type_cd,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].default_ind = bobt.default_ind,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].beg_effective_dt_tm = bobt
    .beg_effective_dt_tm, reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].
    end_effective_dt_tm = bobt.end_effective_dt_tm,
    reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].active_ind = bobt.active_ind
   ENDIF
  HEAD bbtp.bag_type_product_id
   IF (bag_reason_path=2)
    IF (product_path=1)
     pr_cnt = (pr_cnt+ 1)
     IF (mod(pr_cnt,10)=1)
      stat = alterlist(reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].productlist,
       (pr_cnt+ 9))
     ENDIF
     reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].productlist[pr_cnt].
     bag_type_product_id = bbtp.bag_type_product_id, reply->procedurelist[p_cnt].outcomelist[o_cnt].
     bagtypelist[b_cnt].productlist[pr_cnt].outcome_bag_type_id = bbtp.outcome_bag_type_id, reply->
     procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].productlist[pr_cnt].product_cd = bbtp
     .product_cd,
     reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].productlist[pr_cnt].
     default_ind = bbtp.default_ind, reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt
     ].productlist[pr_cnt].beg_effective_dt_tm = bbtp.beg_effective_dt_tm, reply->procedurelist[p_cnt
     ].outcomelist[o_cnt].bagtypelist[b_cnt].productlist[pr_cnt].end_effective_dt_tm = bbtp
     .end_effective_dt_tm,
     reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].productlist[pr_cnt].active_ind
      = bbtp.active_ind
    ENDIF
   ENDIF
  DETAIL
   row + 0
  FOOT  bbtp.bag_type_product_id
   IF (bag_reason_path=2)
    IF (product_path=1)
     row + 0
    ENDIF
   ENDIF
  FOOT  bobt.outcome_bag_type_id
   IF (bag_reason_path=2)
    stat = alterlist(reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist[b_cnt].productlist,
     pr_cnt)
   ENDIF
  FOOT  bor.outcome_reason_id
   IF (bag_reason_path=1)
    row + 0
   ENDIF
  FOOT  bpo.procedure_outcome_id
   IF (outcome_path=1)
    stat = alterlist(reply->procedurelist[p_cnt].outcomelist[o_cnt].reasonlist,r_cnt), stat =
    alterlist(reply->procedurelist[p_cnt].outcomelist[o_cnt].bagtypelist,b_cnt)
   ENDIF
  FOOT  bdp.procedure_id
   stat = alterlist(reply->procedurelist[p_cnt].outcomelist,o_cnt)
  FOOT REPORT
   stat = alterlist(reply->procedurelist,p_cnt)
  WITH nocounter, outerjoin(d1), outerjoin(d2),
   outerjoin(d3), outerjoin(d4)
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","Multiple tables",errmsg)
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
 IF (p_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
