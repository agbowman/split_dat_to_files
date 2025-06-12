CREATE PROGRAM bed_get_sch_avail_appt_orders:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 code_value = f8
     2 display = vc
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET max_cnt = 0
 IF ((request->max_reply_limit > 0))
  SET max_cnt = request->max_reply_limit
 ELSE
  SET max_cnt = 1000000
 ENDIF
 SET wcard = "*"
 DECLARE sched_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_string="S"))
   SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
  ENDIF
  SET sched_parse = concat("cnvtupper(o.primary_mnemonic) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET sched_parse = concat("cnvtupper(o.primary_mnemonic) = '",search_string,"'")
 ENDIF
 IF ((request->dept_type_id > 0))
  SELECT INTO "nl:"
   FROM br_sched_dept d,
    br_sched_dept_ord_r r,
    order_catalog o
   PLAN (d
    WHERE (d.dept_type_id=request->dept_type_id))
    JOIN (r
    WHERE r.location_cd=d.location_cd)
    JOIN (o
    WHERE o.catalog_type_cd=r.catalog_type_cd
     AND ((o.activity_type_cd=r.activity_type_cd) OR (r.activity_type_cd=0))
     AND ((o.activity_subtype_cd=r.activity_subtype_cd) OR (r.activity_subtype_cd=0))
     AND parser(sched_parse)
     AND o.active_ind=1)
   ORDER BY o.primary_mnemonic
   HEAD o.primary_mnemonic
    cnt = (cnt+ 1), stat = alterlist(reply->orders,cnt), reply->orders[cnt].code_value = o.catalog_cd,
    reply->orders[cnt].display = o.primary_mnemonic
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM order_catalog o
   PLAN (o
    WHERE parser(sched_parse)
     AND o.active_ind=1)
   ORDER BY o.primary_mnemonic
   HEAD o.primary_mnemonic
    cnt = (cnt+ 1), stat = alterlist(reply->orders,cnt), reply->orders[cnt].code_value = o.catalog_cd,
    reply->orders[cnt].display = o.primary_mnemonic
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (cnt > max_cnt)
  SET stat = alterlist(reply->orders,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
