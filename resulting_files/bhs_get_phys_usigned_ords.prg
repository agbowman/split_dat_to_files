CREATE PROGRAM bhs_get_phys_usigned_ords
 PROMPT
  "OUTPUT DEVICE" = "mine",
  "Phy ID:" = 0
  WITH prompt1, prompt2
 SET p_phys_id =  $2
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
 SELECT INTO  $1
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
  WITH nocounter, format
 ;end select
#exit_script
END GO
