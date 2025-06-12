CREATE PROGRAM bhs_fix_phys_usigned_ords_v2
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
  FROM order_notification n
  WHERE (n.to_prsnl_id= $1)
   AND n.notification_status_flag=1
   AND n.notification_type_flag != 1
  HEAD REPORT
   cnt = 0, stat = alterlist(data->qual,10)
  HEAD n.order_id
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(data->qual,(cnt+ 10))
   ENDIF
   data->qual[cnt].order_id = n.order_id
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
   COMMIT
   SET data->qual[i].or_qual = curqual
   IF (curqual > 0)
    UPDATE  FROM order_notification orn
     SET orn.notification_status_flag = 2, orn.updt_dt_tm = cnvtdatetime(curdate,curtime3), orn
      .updt_id = 1,
      orn.updt_task = 0
     WHERE (orn.order_id=data->qual[i].order_id)
      AND (orn.to_prsnl_id= $1)
      AND  NOT (orn.caused_by_flag IN (1, 2))
     WITH counter
    ;end update
    COMMIT
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
