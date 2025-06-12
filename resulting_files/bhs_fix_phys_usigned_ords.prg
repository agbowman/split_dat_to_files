CREATE PROGRAM bhs_fix_phys_usigned_ords
 PROMPT
  "Physician ID:"
 SET p_phys_id =  $1
 SET cnt = 0
 SET cnt_comment = 0
 SET disch_cd = uar_get_code_by("DISPLAYKEY",261,"DISCHARGED")
 FREE RECORD data
 RECORD data(
   1 qual[*]
     2 order_id = f8
     2 action_sequence = i4
     2 review_sequence = i4
     2 or_qual = f8
     2 on_qual = f8
     2 o_qual = f8
 )
 SET v_oa_order_cd = uar_get_code_by("MEANING",6003,"ORDER")
 SET v_canceled_cd = uar_get_code_by("MEANING",6004,"CANCELED")
 SET v_deleted_cd = uar_get_code_by("MEANING",6004,"DELETED")
 SET v_discontinued_cd = uar_get_code_by("MEANING",6004,"DISCONTINUED")
 SET rpt_name = "UNSIGNED ORDERS BY PHYSICIAN"
 SELECT INTO "nl:"
  orv.order_id, order_status = uar_get_code_display(o.order_status_cd), encntr_type =
  uar_get_code_display(e.encntr_type_cd),
  days_since_disch = datetimecmp(cnvtdatetime(curdate,curtime3),e.disch_dt_tm)
  FROM order_review orv,
   encounter e,
   person p,
   orders o
  PLAN (orv
   WHERE orv.provider_id=p_phys_id
    AND orv.review_type_flag=2
    AND orv.reviewed_status_flag=0
    AND  NOT (orv.order_id IN (
   (SELECT
    orn.order_id
    FROM order_notification orn
    WHERE orv.order_id=orn.order_id
     AND orv.provider_id=orn.from_prsnl_id
     AND orn.caused_by_flag IN (1, 2)))))
   JOIN (o
   WHERE o.order_id=orv.order_id
    AND o.active_ind=1
    AND  NOT (o.order_status_cd IN (v_canceled_cd, v_deleted_cd, v_discontinued_cd)))
   JOIN (e
   WHERE e.encntr_id=o.encntr_id
    AND e.active_ind=1
    AND e.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    AND e.encntr_status_cd=disch_cd)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1
    AND p.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY orv.order_id
  HEAD REPORT
   cnt = 0, stat = alterlist(data->qual,10)
  HEAD orv.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(data->qual,(cnt+ 10))
   ENDIF
   data->qual[cnt].order_id = orv.order_id
  FOOT REPORT
   IF (cnt > 0)
    stat = alterlist(data->qual,cnt)
   ENDIF
  WITH nocounter
 ;end select
 FOR (i = 1 TO cnt)
   UPDATE  FROM order_review orr
    SET orr.reviewed_status_flag = 1, orr.updt_dt_tm = cnvtdatetime(curdate,curtime3), orr.updt_id =
     1,
     orr.updt_task = 0
    WHERE (orr.order_id=data->qual[i].order_id)
     AND (orr.provider_id= $1)
    WITH counter
   ;end update
   SET data->qual[i].or_qual = curqual
   IF (curqual > 0)
    UPDATE  FROM order_notification orn
     SET orn.notification_status_flag = 2, orn.updt_dt_tm = cnvtdatetime(curdate,curtime3), orn
      .updt_id = 1,
      orn.updt_task = 0
     WHERE (orn.order_id=data->qual[i].order_id)
      AND ((orn.to_prsnl_id+ 0)= $1)
      AND  NOT (orn.caused_by_flag IN (1, 2))
     WITH counter
    ;end update
    SET data->qual[i].on_qual = curqual
    IF (curqual > 0)
     UPDATE  FROM orders o
      SET o.need_doctor_cosign_ind = 0
      WHERE (o.order_id=data->qual[i].order_id)
       AND o.updt_dt_tm=cnvtdatetime(curdate,curtime3)
       AND o.updt_id=1
       AND o.updt_task=0
      WITH counter
     ;end update
     SET data->qual[i].o_qual = curqual
     IF (curqual > 0)
      COMMIT
     ELSE
      ROLLBACK
     ENDIF
    ELSE
     ROLLBACK
    ENDIF
   ELSE
    ROLLBACK
   ENDIF
 ENDFOR
 SELECT
  FROM (dummyt d  WITH seq = value(cnt))
  PLAN (d
   WHERE (((data->qual[d.seq].o_qual <= 0)) OR ((((data->qual[d.seq].or_qual <= 0)) OR ((data->qual[d
   .seq].on_qual <= 0))) )) )
  DETAIL
   col 1, data->qual[d.seq].order_id, col 20,
   data->qual[d.seq].o_qual, col 40, data->qual[d.seq].on_qual,
   col 60, data->qual[d.seq].or_qual, row + 1
 ;end select
#exit_script
END GO
