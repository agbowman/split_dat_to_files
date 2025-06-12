CREATE PROGRAM bsv_get_children_by_event_set:dba
 RECORD reply(
   1 children[*]
     2 child_type_flag = i2
     2 child_ind = i2
     2 child_cd = f8
     2 child_desc = c60
     2 child_disp = c40
     2 child_name = c40
     2 auth_ind = i2
     2 all_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE check_all_results(event_set_cd=f8) = i2
 DECLARE event_set = i2 WITH public, constant(0)
 DECLARE prim_event_set = i2 WITH public, constant(1)
 DECLARE event_code = i2 WITH public, constant(2)
 DECLARE nochild = i2 WITH public, constant(0)
 DECLARE child = i2 WITH public, constant(1)
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE active = f8 WITH public, noconstant(0.0)
 DECLARE child_cnt = i4 WITH public, noconstant(0)
 DECLARE all_results_cd = f8 WITH public, noconstant(0.0)
 SET reply->status_data.status = "F"
 IF ((reqdata->active_status_cd <= 0.0))
  SET active = uar_get_code_by("MEANING",48,"ACTIVE")
 ELSE
  SET active = reqdata->active_status_cd
 ENDIF
 IF ((request->check_all_results_ind=1))
  SELECT INTO "nl:"
   vesc.event_set_name
   FROM v500_event_set_code vesc
   WHERE vesc.event_set_name="ALL RESULT SECTIONS"
   DETAIL
    all_results_cd = vesc.event_set_cd
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->primitive_ind=1))
  SELECT
   IF ((request->snapshot_ind=1))
    FROM kia_event_set_explode_snp vese,
     kia_event_code_snp vec,
     code_value cv
   ELSE
    FROM v500_event_set_explode vese,
     v500_event_code vec,
     code_value cv
   ENDIF
   INTO "nl:"
   vese.event_cd
   PLAN (vese
    WHERE (vese.event_set_cd=request->event_set_cd))
    JOIN (vec
    WHERE vec.event_cd=vese.event_cd)
    JOIN (cv
    WHERE cv.code_value=vec.event_cd)
   ORDER BY vese.event_cd
   HEAD REPORT
    child_cnt = 0
   HEAD vese.event_cd
    child_cnt = (child_cnt+ 1)
    IF (mod(child_cnt,10)=1)
     stat = alterlist(reply->children,(child_cnt+ 9))
    ENDIF
    reply->children[child_cnt].child_type_flag = event_code, reply->children[child_cnt].child_cd =
    vese.event_cd, reply->children[child_cnt].child_disp = vec.event_cd_disp,
    reply->children[child_cnt].child_desc = vec.event_cd_descr
    IF ((cv.data_status_cd != reqdata->data_status_cd))
     reply->children[child_cnt].auth_ind = 1
    ENDIF
   FOOT REPORT
    stat = alterlist(reply->children,child_cnt)
   WITH nocounter
  ;end select
  IF (curqual < 1)
   SET failed = "T"
   GO TO exit_script
  ELSE
   SELECT INTO "nl:"
    cver.parent_cd
    FROM (dummyt d  WITH seq = value(child_cnt)),
     code_value_event_r cver
    PLAN (d
     WHERE (reply->children[d.seq].child_cd > 0.0))
     JOIN (cver
     WHERE (cver.event_cd=reply->children[d.seq].child_cd))
    DETAIL
     reply->children[d.seq].child_ind = child
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    dta.task_assay_cd
    FROM (dummyt d  WITH seq = value(child_cnt)),
     discrete_task_assay dta
    PLAN (d
     WHERE (reply->children[d.seq].child_cd > 0.0)
      AND (reply->children[d.seq].child_ind=nochild))
     JOIN (dta
     WHERE (dta.event_cd=reply->children[d.seq].child_cd)
      AND dta.active_ind=1
      AND dta.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
      AND dta.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
    DETAIL
     reply->children[d.seq].child_ind = child
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  IF ((request->event_set_cd <= 0.0))
   SELECT
    IF ((request->snapshot_ind=1))
     FROM kia_event_set_code_snp ves,
      kia_event_set_canon_snp vesc
    ELSE
     FROM v500_event_set_code ves,
      v500_event_set_canon vesc
    ENDIF
    INTO "nl:"
    ves.event_set_cd, vesc.event_set_cd, vesc.parent_event_set_cd,
    vesc_ind = nullind(vesc.event_set_cd)
    PLAN (ves
     WHERE ves.event_set_name_key IN ("ALLOCFEVENTSETS", patstring("CUSTOM*"))
      AND ves.code_status_cd=active)
     JOIN (vesc
     WHERE vesc.parent_event_set_cd=outerjoin(ves.event_set_cd)
      AND vesc.event_set_status_cd=outerjoin(active))
    ORDER BY ves.event_set_cd
    HEAD REPORT
     child_cnt = 0
    HEAD ves.event_set_cd
     child_cnt = (child_cnt+ 1)
     IF (mod(child_cnt,10)=1)
      stat = alterlist(reply->children,(child_cnt+ 9))
     ENDIF
     IF (vesc_ind=1)
      reply->children[child_cnt].child_type_flag = prim_event_set
     ELSE
      reply->children[child_cnt].child_type_flag = event_set, reply->children[child_cnt].child_ind =
      child
     ENDIF
     reply->children[child_cnt].child_cd = ves.event_set_cd, reply->children[child_cnt].child_disp =
     ves.event_set_cd_disp, reply->children[child_cnt].child_desc = ves.event_set_cd_descr
    FOOT REPORT
     stat = alterlist(reply->children,child_cnt)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET failed = "T"
    GO TO exit_script
   ELSE
    SELECT
     IF ((request->snapshot_ind=1))
      FROM (dummyt d  WITH seq = value(child_cnt)),
       kia_event_set_explode_snp vese
     ELSE
      FROM (dummyt d  WITH seq = value(child_cnt)),
       v500_event_set_explode vese
     ENDIF
     INTO "nl:"
     vese.event_cd
     PLAN (d
      WHERE (reply->children[d.seq].child_cd > 0.0)
       AND (reply->children[d.seq].child_type_flag=prim_event_set)
       AND (reply->children[d.seq].child_ind=nochild))
      JOIN (vese
      WHERE (vese.event_set_cd=reply->children[d.seq].child_cd))
     ORDER BY d.seq
     HEAD d.seq
      reply->children[d.seq].child_ind = child
     WITH nocounter
    ;end select
   ENDIF
  ELSE
   SELECT
    IF ((request->snapshot_ind=1))
     FROM kia_event_set_canon_snp vesc1,
      kia_event_set_code_snp vesc,
      kia_event_set_canon_snp vesc2
    ELSE
     FROM v500_event_set_canon vesc1,
      v500_event_set_code vesc,
      v500_event_set_canon vesc2
    ENDIF
    INTO "nl:"
    vesc1.event_set_cd, vesc1.parent_event_set_cd, vesc2.event_set_cd,
    vesc2.parent_event_set_cd, vesc2_ind = nullind(vesc2.event_set_cd)
    PLAN (vesc1
     WHERE (vesc1.parent_event_set_cd=request->event_set_cd)
      AND vesc1.event_set_status_cd=active)
     JOIN (vesc
     WHERE vesc.event_set_cd=vesc1.event_set_cd)
     JOIN (vesc2
     WHERE vesc2.parent_event_set_cd=outerjoin(vesc.event_set_cd)
      AND vesc2.event_set_status_cd=outerjoin(active))
    ORDER BY vesc1.event_set_collating_seq, vesc1.event_set_cd
    HEAD REPORT
     child_cnt = 0
    HEAD vesc1.event_set_collating_seq
     row + 0
    HEAD vesc1.event_set_cd
     child_cnt = (child_cnt+ 1)
     IF (mod(child_cnt,10)=1)
      stat = alterlist(reply->children,(child_cnt+ 9))
     ENDIF
     IF (vesc2_ind=1)
      reply->children[child_cnt].child_type_flag = prim_event_set
     ELSE
      reply->children[child_cnt].child_type_flag = event_set, reply->children[child_cnt].child_ind =
      child
     ENDIF
     reply->children[child_cnt].child_cd = vesc1.event_set_cd, reply->children[child_cnt].child_disp
      = vesc.event_set_cd_disp, reply->children[child_cnt].child_desc = vesc.event_set_cd_descr
    FOOT REPORT
     stat = alterlist(reply->children,child_cnt)
    WITH nocounter
   ;end select
   IF (curqual < 1)
    SET failed = "T"
    GO TO exit_script
   ELSE
    SELECT
     IF ((request->snapshot_ind=1))
      FROM (dummyt d  WITH seq = value(child_cnt)),
       kia_event_set_explode_snp vese
     ELSE
      FROM (dummyt d  WITH seq = value(child_cnt)),
       v500_event_set_explode vese
     ENDIF
     INTO "nl:"
     vese.event_cd
     PLAN (d
      WHERE (reply->children[d.seq].child_cd > 0.0)
       AND (reply->children[d.seq].child_type_flag=prim_event_set)
       AND (reply->children[d.seq].child_ind=nochild))
      JOIN (vese
      WHERE (vese.event_set_cd=reply->children[d.seq].child_cd))
     ORDER BY d.seq
     HEAD d.seq
      reply->children[d.seq].child_ind = child
     WITH nocounter
    ;end select
   ENDIF
  ENDIF
  SELECT
   IF ((request->snapshot_ind=1))
    FROM kia_event_set_code_snp vesc,
     (dummyt d  WITH seq = value(size(reply->children,5)))
   ELSE
    FROM v500_event_set_code vesc,
     (dummyt d  WITH seq = value(size(reply->children,5)))
   ENDIF
   INTO "nl:"
   PLAN (d)
    JOIN (vesc
    WHERE (vesc.event_set_cd=reply->children[d.seq].child_cd))
   DETAIL
    reply->children[d.seq].child_name = vesc.event_set_name
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->check_all_results_ind=1)
  AND all_results_cd > 0.0)
  FOR (x = 1 TO size(reply->children,5))
    SET reply->children[x].all_results_ind = check_all_results(reply->children[x].child_cd)
  ENDFOR
 ENDIF
 SUBROUTINE check_all_results(event_set_cd)
   FREE RECORD es
   RECORD es(
     1 es_cnt = i4
     1 qual[*]
       2 event_set_cd = f8
       2 event_set_disp = c40
   )
   SET es->es_cnt = (es->es_cnt+ 1)
   SET stat = alterlist(es->qual,es->es_cnt)
   SET es->qual[es->es_cnt].event_set_cd = event_set_cd
   SET continue_ind = true
   SET found_ind = false
   WHILE (continue_ind
    AND  NOT (found_ind))
     SET num = 0
     SELECT INTO "nl:"
      vesn.event_set_cd, parent = uar_get_code_display(vesn.parent_event_set_cd)
      FROM v500_event_set_canon vesn
      PLAN (vesn
       WHERE expand(num,1,es->es_cnt,vesn.event_set_cd,es->qual[num].event_set_cd))
      ORDER BY vesn.parent_event_set_cd
      HEAD REPORT
       es_cnt = 0
      HEAD vesn.parent_event_set_cd
       IF (vesn.parent_event_set_cd=all_results_cd)
        found_ind = true
       ENDIF
       es_cnt = (es_cnt+ 1)
       IF (mod(es_cnt,10)=1)
        stat = alterlist(es->qual,(es_cnt+ 9))
       ENDIF
       es->qual[es_cnt].event_set_cd = vesn.parent_event_set_cd, es->qual[es_cnt].event_set_disp =
       parent
      FOOT REPORT
       stat = alterlist(es->qual,es_cnt), es->es_cnt = es_cnt
      WITH nocounter
     ;end select
     IF (curqual < 1)
      SET continue_ind = false
     ENDIF
   ENDWHILE
   RETURN(found_ind)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET script_version = "001 03/14/03 AA017659"
END GO
