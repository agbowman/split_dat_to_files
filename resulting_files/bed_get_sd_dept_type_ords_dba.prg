CREATE PROGRAM bed_get_sd_dept_type_ords:dba
 FREE SET reply
 RECORD reply(
   1 dept_types[*]
     2 dept_type_id = f8
     2 catalog_types[*]
       3 code_value = f8
       3 display = vc
       3 activity_types[*]
         4 code_value = f8
         4 display = vc
         4 sub_activity_types[*]
           5 code_value = f8
           5 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET len = size(request->dept_types,5)
 IF (len > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = len),
    br_sched_dept_type bsdt,
    br_sched_dept_type_r bsdtr
   PLAN (d)
    JOIN (bsdt
    WHERE (bsdt.dept_type_id=request->dept_types[d.seq].dept_type_id))
    JOIN (bsdtr
    WHERE bsdtr.dept_type_id=outerjoin(bsdt.dept_type_id))
   ORDER BY bsdt.dept_type_id, bsdtr.catalog_type_cd, bsdtr.activity_type_cd
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(reply->dept_types,100)
   HEAD bsdt.dept_type_id
    cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
    IF (cnt > 100)
     stat = alterlist(reply->dept_types,(tot_cnt+ 100)), cnt = 1
    ENDIF
    reply->dept_types[tot_cnt].dept_type_id = bsdt.dept_type_id, cat_cnt = 0, cat_tot_cnt = 0,
    stat = alterlist(reply->dept_types[tot_cnt].catalog_types,10)
   HEAD bsdtr.catalog_type_cd
    IF (bsdtr.catalog_type_cd > 0)
     cat_cnt = (cat_cnt+ 1), cat_tot_cnt = (cat_tot_cnt+ 1)
     IF (cat_cnt > 10)
      stat = alterlist(reply->dept_types[tot_cnt].catalog_types,(cat_tot_cnt+ 10)), cat_cnt = (
      cat_cnt+ 1)
     ENDIF
     reply->dept_types[tot_cnt].catalog_types[cat_tot_cnt].code_value = bsdtr.catalog_type_cd
    ENDIF
    act_cnt = 0, act_tot_cnt = 0, stat = alterlist(reply->dept_types[tot_cnt].catalog_types[
     cat_tot_cnt].activity_types,10)
   HEAD bsdtr.activity_type_cd
    IF (bsdtr.activity_type_cd > 0)
     act_cnt = (act_cnt+ 1), act_tot_cnt = (act_tot_cnt+ 1)
     IF (act_cnt > 10)
      stat = alterlist(reply->dept_types[tot_cnt].catalog_types[cat_tot_cnt].activity_types,(
       act_tot_cnt+ 10)), act_cnt = (act_cnt+ 1)
     ENDIF
     reply->dept_types[tot_cnt].catalog_types[cat_tot_cnt].activity_types[act_tot_cnt].code_value =
     bsdtr.activity_type_cd
    ENDIF
    sact_cnt = 0, sact_tot_cnt = 0, stat = alterlist(reply->dept_types[tot_cnt].catalog_types[
     cat_tot_cnt].activity_types[act_tot_cnt].sub_activity_types,10)
   HEAD bsdtr.activity_subtype_cd
    IF (bsdtr.activity_subtype_cd > 0)
     sact_cnt = (sact_cnt+ 1), sact_tot_cnt = (sact_tot_cnt+ 1)
     IF (sact_cnt > 10)
      stat = alterlist(reply->dept_types[tot_cnt].catalog_types[cat_tot_cnt].activity_types[
       act_tot_cnt].sub_activity_types,(sact_tot_cnt+ 10)), sact_cnt = (sact_cnt+ 1)
     ENDIF
     reply->dept_types[tot_cnt].catalog_types[cat_tot_cnt].activity_types[act_tot_cnt].
     sub_activity_types[sact_tot_cnt].code_value = bsdtr.activity_subtype_cd
    ENDIF
   FOOT  bsdtr.activity_type_cd
    IF (cat_tot_cnt > 0
     AND act_tot_cnt > 0)
     stat = alterlist(reply->dept_types[tot_cnt].catalog_types[cat_tot_cnt].activity_types[
      act_tot_cnt].sub_activity_types,sact_tot_cnt)
    ENDIF
   FOOT  bsdtr.catalog_type_cd
    IF (cat_tot_cnt > 0)
     stat = alterlist(reply->dept_types[tot_cnt].catalog_types[cat_tot_cnt].activity_types,
      act_tot_cnt)
    ENDIF
   FOOT  bsdtr.dept_type_id
    stat = alterlist(reply->dept_types[tot_cnt].catalog_types,cat_tot_cnt)
   FOOT REPORT
    stat = alterlist(reply->dept_types,tot_cnt)
   WITH nocounter
  ;end select
 ENDIF
 FOR (x = 1 TO size(reply->dept_types,5))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(reply->dept_types[x].catalog_types,5)),
    code_value cv
   PLAN (d
    WHERE (reply->dept_types[x].catalog_types[d.seq].code_value > 0))
    JOIN (cv
    WHERE (cv.code_value=reply->dept_types[x].catalog_types[d.seq].code_value))
   ORDER BY d.seq
   DETAIL
    reply->dept_types[x].catalog_types[d.seq].display = cv.display
   WITH nocounter
  ;end select
  FOR (y = 1 TO size(reply->dept_types[x].catalog_types,5))
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = size(reply->dept_types[x].catalog_types[y].activity_types,5)),
     code_value cv
    PLAN (d
     WHERE (reply->dept_types[x].catalog_types[y].activity_types[d.seq].code_value > 0))
     JOIN (cv
     WHERE (cv.code_value=reply->dept_types[x].catalog_types[y].activity_types[d.seq].code_value))
    ORDER BY d.seq
    DETAIL
     reply->dept_types[x].catalog_types[y].activity_types[d.seq].display = cv.display
    WITH nocounter
   ;end select
   FOR (z = 1 TO size(reply->dept_types[x].catalog_types[y].activity_types,5))
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = size(reply->dept_types[x].catalog_types[y].activity_types[z].
        sub_activity_types,5)),
       code_value cv
      PLAN (d
       WHERE (reply->dept_types[x].catalog_types[y].activity_types[z].sub_activity_types[d.seq].
       code_value > 0))
       JOIN (cv
       WHERE (cv.code_value=reply->dept_types[x].catalog_types[y].activity_types[z].
       sub_activity_types[d.seq].code_value))
      ORDER BY d.seq
      DETAIL
       reply->dept_types[x].catalog_types[y].activity_types[z].sub_activity_types[d.seq].display = cv
       .display
      WITH nocounter
     ;end select
   ENDFOR
  ENDFOR
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
