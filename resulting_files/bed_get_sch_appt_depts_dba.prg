CREATE PROGRAM bed_get_sch_appt_depts:dba
 FREE SET reply
 RECORD reply(
   1 dept_types[*]
     2 id = f8
     2 display = vc
     2 prefix = vc
     2 depts[*]
       3 code_value = f8
       3 display = vc
       3 mean = vc
       3 order_based_appt_ind = i2
       3 nonorder_based_appt_ind = i2
       3 orders_ind = i2
       3 prefix = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET dcnt = 0
 SELECT INTO "nl:"
  FROM br_sched_dept_type t,
   br_sched_dept d,
   code_value c
  PLAN (t)
   JOIN (d
   WHERE d.dept_type_id=t.dept_type_id)
   JOIN (c
   WHERE c.code_value=d.location_cd
    AND c.active_ind=1)
  ORDER BY t.dept_type_display, c.display
  HEAD t.dept_type_display
   dcnt = 0, tcnt = (tcnt+ 1), stat = alterlist(reply->dept_types,tcnt),
   reply->dept_types[tcnt].id = t.dept_type_id, reply->dept_types[tcnt].display = t.dept_type_display,
   reply->dept_types[tcnt].prefix = t.dept_type_prefix
  DETAIL
   dcnt = (dcnt+ 1), stat = alterlist(reply->dept_types[tcnt].depts,dcnt), reply->dept_types[tcnt].
   depts[dcnt].code_value = d.location_cd,
   reply->dept_types[tcnt].depts[dcnt].display = c.display, reply->dept_types[tcnt].depts[dcnt].mean
    = c.cdf_meaning, reply->dept_types[tcnt].depts[dcnt].prefix = d.dept_prefix
  WITH nocounter
 ;end select
 FOR (x = 1 TO tcnt)
   SET dcnt = size(reply->dept_types[x].depts,5)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dcnt)),
     sch_appt_loc s,
     sch_order_appt o
    PLAN (d)
     JOIN (s
     WHERE (s.location_cd=reply->dept_types[x].depts[d.seq].code_value)
      AND s.active_ind=1)
     JOIN (o
     WHERE o.appt_type_cd=s.appt_type_cd)
    HEAD d.seq
     reply->dept_types[x].depts[d.seq].order_based_appt_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dcnt)),
     sch_appt_loc s
    PLAN (d)
     JOIN (s
     WHERE (s.location_cd=reply->dept_types[x].depts[d.seq].code_value)
      AND s.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      o.appt_type_cd
      FROM sch_order_appt o
      WHERE o.appt_type_cd=s.appt_type_cd))))
    HEAD d.seq
     reply->dept_types[x].depts[d.seq].nonorder_based_appt_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(dcnt)),
     sch_order_loc s
    PLAN (d)
     JOIN (s
     WHERE (s.location_cd=reply->dept_types[x].depts[d.seq].code_value)
      AND s.active_ind=1)
    HEAD d.seq
     reply->dept_types[x].depts[d.seq].orders_ind = 1
    WITH nocounter
   ;end select
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
