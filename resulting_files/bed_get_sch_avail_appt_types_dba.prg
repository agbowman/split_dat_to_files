CREATE PROGRAM bed_get_sch_avail_appt_types:dba
 FREE SET reply
 RECORD reply(
   1 appt_types[*]
     2 appt_type_id = f8
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
 DECLARE code_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_string="S"))
   SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
  ENDIF
  SET sched_parse = concat("cnvtupper(a.appt_type_display) = '",search_string,"'")
  SET code_parse = concat("cnvtupper(c.display) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET sched_parse = concat("cnvtupper(a.appt_type_display) = '",search_string,"'")
  SET code_parse = concat("cnvtupper(c.display) = '",search_string,"'")
 ENDIF
 RECORD o_appt(
   1 qual[*]
     2 cd = f8
     2 display = vc
 )
 SET ocnt = 0
 SELECT INTO "nl:"
  FROM code_value c,
   sch_order_appt a
  PLAN (c
   WHERE c.code_set=14230
    AND c.active_ind=1)
   JOIN (a
   WHERE a.appt_type_cd=c.code_value)
  ORDER BY c.display
  HEAD c.display
   ocnt = (ocnt+ 1), stat = alterlist(o_appt->qual,ocnt), o_appt->qual[ocnt].cd = c.code_value,
   o_appt->qual[ocnt].display = c.display
  WITH nocounter
 ;end select
 RECORD n_appt(
   1 qual[*]
     2 cd = f8
     2 display = vc
 )
 SET ncnt = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14230
    AND c.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    a.appt_type_cd
    FROM sch_order_appt a
    WHERE a.appt_type_cd=c.code_value))))
  ORDER BY c.display
  HEAD c.display
   ncnt = (ncnt+ 1), stat = alterlist(n_appt->qual,ncnt), n_appt->qual[ncnt].cd = c.code_value,
   n_appt->qual[ncnt].display = c.display
  WITH nocounter
 ;end select
 IF ((request->dept_type_id > 0))
  IF ((request->orders_based_ind=1))
   SELECT INTO "nl:"
    FROM br_sched_dept d,
     br_sched_dept_ord_r r,
     br_sched_appt_type a,
     br_sched_appt_type_ord o,
     order_catalog c
    PLAN (d
     WHERE (d.dept_type_id=request->dept_type_id))
     JOIN (r
     WHERE r.location_cd=d.location_cd)
     JOIN (a
     WHERE a.catalog_type_cd=r.catalog_type_cd
      AND parser(sched_parse))
     JOIN (o
     WHERE o.appt_type_id=a.appt_type_id
      AND o.catalog_type_cd=r.catalog_type_cd
      AND ((o.activity_type_cd=r.activity_type_cd) OR (r.activity_type_cd=0))
      AND ((o.activity_subtype_cd=r.activity_subtype_cd) OR (r.activity_subtype_cd=0)) )
     JOIN (c
     WHERE c.concept_cki=o.concept_cki
      AND c.active_ind=1)
    ORDER BY a.appt_type_id
    HEAD a.appt_type_id
     nfound = 0
     FOR (x = 1 TO ncnt)
       IF ((a.appt_type_display=n_appt->qual[x].display))
        nfound = 1
       ENDIF
     ENDFOR
     IF (nfound=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].appt_type_id =
      a.appt_type_id,
      reply->appt_types[cnt].display = a.appt_type_display
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM br_sched_appt_type a
    PLAN (a
     WHERE (a.dept_type_id=request->dept_type_id)
      AND parser(sched_parse))
    ORDER BY a.appt_type_id
    HEAD a.appt_type_id
     ofound = 0
     FOR (x = 1 TO ocnt)
       IF ((a.appt_type_display=o_appt->qual[x].display))
        ofound = 1
       ENDIF
     ENDFOR
     IF (ofound=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].appt_type_id =
      a.appt_type_id,
      reply->appt_types[cnt].display = a.appt_type_display
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  IF ((request->orders_based_ind=1))
   SELECT INTO "nl:"
    FROM br_sched_appt_type a,
     br_sched_appt_type_ord o,
     order_catalog c
    PLAN (a
     WHERE a.orders_based_ind=1
      AND parser(sched_parse))
     JOIN (o
     WHERE o.appt_type_id=a.appt_type_id)
     JOIN (c
     WHERE c.concept_cki=o.concept_cki
      AND c.active_ind=1)
    ORDER BY a.appt_type_id
    HEAD a.appt_type_id
     nfound = 0
     FOR (x = 1 TO ncnt)
       IF ((a.appt_type_display=n_appt->qual[x].display))
        nfound = 1
       ENDIF
     ENDFOR
     IF (nfound=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].appt_type_id =
      a.appt_type_id,
      reply->appt_types[cnt].display = a.appt_type_display
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM br_sched_appt_type a
    PLAN (a
     WHERE a.orders_based_ind=0
      AND parser(sched_parse))
    ORDER BY a.appt_type_id
    HEAD a.appt_type_id
     ofound = 0
     FOR (x = 1 TO ocnt)
       IF ((a.appt_type_display=o_appt->qual[x].display))
        ofound = 1
       ENDIF
     ENDFOR
     IF (ofound=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].appt_type_id =
      a.appt_type_id,
      reply->appt_types[cnt].display = a.appt_type_display
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF (cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    code_value c
   PLAN (d)
    JOIN (c
    WHERE c.code_set=14230
     AND cnvtupper(c.display)=cnvtupper(reply->appt_types[d.seq].display)
     AND c.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    reply->appt_types[d.seq].code_value = c.code_value
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->orders_based_ind=1))
  IF ((request->dept_type_id > 0))
   SELECT INTO "nl:"
    FROM br_sched_dept b,
     sch_appt_loc s,
     code_value c,
     sch_order_appt a
    PLAN (b
     WHERE (b.dept_type_id=request->dept_type_id))
     JOIN (s
     WHERE s.location_cd=b.location_cd
      AND s.active_ind=1)
     JOIN (c
     WHERE c.code_value=s.appt_type_cd
      AND parser(code_parse)
      AND c.active_ind=1)
     JOIN (a
     WHERE a.appt_type_cd=c.code_value
      AND a.active_ind=1)
    ORDER BY c.display
    HEAD c.display
     found = 0
     FOR (x = 1 TO size(reply->appt_types,5))
       IF ((reply->appt_types[x].display=c.display))
        found = 1
       ENDIF
     ENDFOR
     IF (found=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].code_value = c
      .code_value,
      reply->appt_types[cnt].display = c.display
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM code_value c,
     sch_order_appt a
    PLAN (c
     WHERE c.code_set=14230
      AND parser(code_parse)
      AND c.active_ind=1)
     JOIN (a
     WHERE a.appt_type_cd=c.code_value
      AND a.active_ind=1)
    ORDER BY c.display
    HEAD c.display
     found = 0
     FOR (x = 1 TO size(reply->appt_types,5))
       IF ((reply->appt_types[x].display=c.display))
        found = 1
       ENDIF
     ENDFOR
     IF (found=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].code_value = c
      .code_value,
      reply->appt_types[cnt].display = c.display
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  IF ((request->dept_type_id > 0))
   SELECT INTO "nl:"
    FROM br_sched_dept b,
     sch_appt_loc s,
     code_value c
    PLAN (b
     WHERE (b.dept_type_id=request->dept_type_id))
     JOIN (s
     WHERE s.location_cd=b.location_cd
      AND s.active_ind=1)
     JOIN (c
     WHERE c.code_value=s.appt_type_cd
      AND parser(code_parse)
      AND c.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      a.appt_type_cd
      FROM sch_order_appt a
      WHERE a.appt_type_cd=c.code_value))))
    ORDER BY c.display
    HEAD c.display
     found = 0
     FOR (x = 1 TO size(reply->appt_types,5))
       IF ((reply->appt_types[x].display=c.display))
        found = 1
       ENDIF
     ENDFOR
     IF (found=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].code_value = c
      .code_value,
      reply->appt_types[cnt].display = c.display
     ENDIF
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=14230
      AND parser(code_parse)
      AND c.active_ind=1
      AND  NOT ( EXISTS (
     (SELECT
      a.appt_type_cd
      FROM sch_order_appt a
      WHERE a.appt_type_cd=c.code_value))))
    ORDER BY c.display
    HEAD c.display
     found = 0
     FOR (x = 1 TO size(reply->appt_types,5))
       IF ((reply->appt_types[x].display=c.display))
        found = 1
       ENDIF
     ENDFOR
     IF (found=0)
      cnt = (cnt+ 1), stat = alterlist(reply->appt_types,cnt), reply->appt_types[cnt].code_value = c
      .code_value,
      reply->appt_types[cnt].display = c.display
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 IF (cnt > max_cnt)
  SET stat = alterlist(reply->appt_types,0)
  SET reply->too_many_results_ind = 1
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
