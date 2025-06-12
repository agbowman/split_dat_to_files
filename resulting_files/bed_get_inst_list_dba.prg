CREATE PROGRAM bed_get_inst_list:dba
 FREE SET reply
 RECORD reply(
   1 inst_list[*]
     2 inst_code_value = f8
     2 inst_display = vc
     2 inst_description = vc
     2 org_id = f8
     2 active_ind = i2
     2 dept_list[*]
       3 dept_code_value = f8
       3 dept_disc_code_value = f8
       3 dept_disc_display = vc
       3 dept_disc_meaning = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 RECORD disc_types(
   1 disc[*]
     2 disc_code_value = f8
     2 disc_meaning = vc
 )
 DECLARE error_msg = vc
 SET error_flag = "F"
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
 SET dept_code = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=223
    AND c.cdf_meaning="DEPARTMENT")
  DETAIL
   dept_code = c.code_value
  WITH nocounter
 ;end select
 IF (dept_code=0)
  SET error_flag = "T"
  SET error_msg = "Unable to read code_value for DEPARTMENT on code_set 223"
  GO TO exit_script
 ENDIF
 SET disccnt = 0
 SET dcnt = size(request->disc_list,5)
 IF (dcnt > 0)
  FOR (i = 1 TO dcnt)
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=6000
       AND (c.cdf_meaning=request->disc_list[i].disc_type_meaning))
     DETAIL
      disccnt = (disccnt+ 1), stat = alterlist(disc_types->disc,disccnt), disc_types->disc[disccnt].
      disc_code_value = c.code_value,
      disc_types->disc[disccnt].disc_meaning = c.cdf_meaning
     WITH nocounter
    ;end select
  ENDFOR
 ENDIF
 SET icnt = 0
 SET max_cnt = 0
 IF ((request->max_reply > 0))
  SET max_cnt = request->max_reply
 ELSE
  SET max_cnt = 1000
 ENDIF
 IF ((request->inc_inactive_ind=1))
  SELECT DISTINCT INTO "nl:"
   FROM code_value c,
    service_resource s
   PLAN (c
    WHERE c.code_set=221
     AND c.cdf_meaning="INSTITUTION")
    JOIN (s
    WHERE s.service_resource_cd=c.code_value)
   HEAD REPORT
    listcnt = 0, stat = alterlist(reply->inst_list,10)
   DETAIL
    icnt = (icnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->inst_list,(icnt+ 10))
    ENDIF
    reply->inst_list[icnt].inst_code_value = c.code_value, reply->inst_list[icnt].inst_display = c
    .display, reply->inst_list[icnt].inst_description = c.description,
    reply->inst_list[icnt].active_ind = c.active_ind, reply->inst_list[icnt].org_id = s
    .organization_id
   FOOT REPORT
    stat = alterlist(reply->inst_list,icnt)
   WITH maxqual(c,value((max_cnt+ 2))), nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   FROM code_value c,
    service_resource s
   PLAN (c
    WHERE c.code_set=221
     AND c.cdf_meaning="INSTITUTION"
     AND c.active_ind=1)
    JOIN (s
    WHERE s.service_resource_cd=c.code_value)
   HEAD REPORT
    listcnt = 0, stat = alterlist(reply->inst_list,10)
   DETAIL
    icnt = (icnt+ 1), listcnt = (listcnt+ 1)
    IF (listcnt > 10)
     listcnt = 1, stat = alterlist(reply->inst_list,(icnt+ 10))
    ENDIF
    reply->inst_list[icnt].inst_code_value = c.code_value, reply->inst_list[icnt].inst_display = c
    .display, reply->inst_list[icnt].inst_description = c.description,
    reply->inst_list[icnt].active_ind = c.active_ind, reply->inst_list[icnt].org_id = s
    .organization_id
   FOOT REPORT
    stat = alterlist(reply->inst_list,icnt)
   WITH maxqual(c,value((max_cnt+ 2))), nocounter
  ;end select
 ENDIF
 IF (icnt > max_cnt)
  SET stat = alterlist(reply->inst_list,max_cnt)
  GO TO exit_script
 ENDIF
 SET dd = 0
 IF (icnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = icnt),
    resource_group r,
    code_value c,
    service_resource s,
    code_value c2
   PLAN (d)
    JOIN (r
    WHERE (r.parent_service_resource_cd=reply->inst_list[d.seq].inst_code_value)
     AND r.active_ind=1)
    JOIN (c
    WHERE c.code_value=r.child_service_resource_cd
     AND c.active_ind=1)
    JOIN (s
    WHERE s.service_resource_cd=outerjoin(r.child_service_resource_cd)
     AND s.service_resource_type_cd=outerjoin(dept_code)
     AND s.active_ind=outerjoin(1))
    JOIN (c2
    WHERE c2.code_value=outerjoin(s.discipline_type_cd))
   HEAD d.seq
    dd = 0
   DETAIL
    dd = (dd+ 1), stat = alterlist(reply->inst_list[d.seq].dept_list,dd), reply->inst_list[d.seq].
    dept_list[dd].dept_code_value = c.code_value,
    reply->inst_list[d.seq].dept_list[dd].dept_disc_code_value = c2.code_value, reply->inst_list[d
    .seq].dept_list[dd].dept_disc_display = c2.display, reply->inst_list[d.seq].dept_list[dd].
    dept_disc_meaning = c2.cdf_meaning
   WITH nocounter
  ;end select
 ENDIF
 IF (dcnt > 0)
  SET loopcnt = icnt
  FOR (i = 1 TO loopcnt)
    IF (i <= icnt)
     SET remove_ind = "Y"
     SET dsize = size(reply->inst_list[i].dept_list,5)
     IF (dsize > 0)
      FOR (j = 1 TO dsize)
        FOR (k = 1 TO disccnt)
          IF ((disc_types->disc[k].disc_code_value=reply->inst_list[i].dept_list[j].
          dept_disc_code_value))
           SET remove_ind = "N"
          ENDIF
        ENDFOR
      ENDFOR
     ENDIF
     IF (remove_ind="Y")
      SET icnt = (icnt - 1)
      SET i = (i - 1)
      SET stat = alterlist(reply->inst_list,icnt,i)
     ENDIF
    ENDIF
  ENDFOR
 ELSE
  SET loopcnt = icnt
  FOR (i = 1 TO loopcnt)
    IF (i <= icnt)
     SET dsize = size(reply->inst_list[i].dept_list,5)
     IF (dsize=0)
      SET icnt = (icnt - 1)
      SET i = (i - 1)
      SET stat = alterlist(reply->inst_list,icnt,i)
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (dcnt > 0)
  FOR (i = 1 TO icnt)
    SET dsize = size(reply->inst_list[i].dept_list,5)
    SET loopcnt = dsize
    FOR (j = 1 TO loopcnt)
      IF (j <= dsize)
       SET remove_ind = "Y"
       FOR (k = 1 TO disccnt)
         IF ((disc_types->disc[k].disc_code_value=reply->inst_list[i].dept_list[j].
         dept_disc_code_value))
          SET remove_ind = "N"
         ENDIF
       ENDFOR
       IF (remove_ind="Y")
        SET dsize = (dsize - 1)
        SET j = (j - 1)
        SET stat = alterlist(reply->inst_list[i].dept_list,dsize,j)
       ENDIF
      ENDIF
    ENDFOR
  ENDFOR
 ENDIF
#exit_script
 IF (error_flag="T")
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_GET_INST_LIST  >> ERROR MESSAGE:  ",error_msg
   )
 ELSE
  IF (icnt > 0)
   IF (icnt > max_cnt)
    SET stat = alterlist(reply->inst_list,0)
    SET reply->too_many_results_ind = 1
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "S"
   ENDIF
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 CALL echorecord(reply)
END GO
