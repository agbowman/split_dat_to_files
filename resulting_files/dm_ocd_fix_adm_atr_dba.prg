CREATE PROGRAM dm_ocd_fix_adm_atr:dba
 SET tmode = trim(cnvtupper( $1))
 EXECUTE FROM init_record_begin TO init_record_end
 IF (tmode="APP")
  CALL echo("***")
  CALL echo("*** Checking dm_ocd_application...")
  CALL echo("***")
  SELECT INTO "nl:"
   d.alpha_feature_nbr, d.application_number, count(*)
   FROM dm_ocd_application d
   GROUP BY d.alpha_feature_nbr, d.application_number
   HAVING count(*) > 1
   HEAD REPORT
    fix_atr->ocd_cnt = 0, stat = alterlist(fix_atr->ocd,0), o_cnt = 0,
    a_cnt = 0
   HEAD d.alpha_feature_nbr
    fix_atr->ocd_cnt = (fix_atr->ocd_cnt+ 1), o_cnt = fix_atr->ocd_cnt, stat = alterlist(fix_atr->ocd,
     o_cnt),
    fix_atr->ocd[o_cnt].o_number = d.alpha_feature_nbr, fix_atr->ocd[o_cnt].atr_cnt = 0, stat =
    alterlist(fix_atr->ocd[o_cnt].atr,0),
    a_cnt = 0, oi = 0, ai = 0
   DETAIL
    fix_atr->ocd[o_cnt].atr_cnt = (fix_atr->ocd[o_cnt].atr_cnt+ 1), a_cnt = fix_atr->ocd[o_cnt].
    atr_cnt, stat = alterlist(fix_atr->ocd[o_cnt].atr,a_cnt),
    fix_atr->ocd[o_cnt].atr[a_cnt].a_number = d.application_number, fix_atr->ocd[o_cnt].atr[a_cnt].
    b_number = 0, fix_atr->ocd[o_cnt].atr[a_cnt].row_id = "x",
    fix_atr->max_atr_cnt = greatest(fix_atr->max_atr_cnt,fix_atr->ocd[o_cnt].atr_cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("***")
   CALL echo("*** Fixing dups...")
   CALL echo("***")
   SELECT INTO "nl:"
    FROM dm_ocd_application d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.application_number=fix_atr->ocd[o.seq].atr[a.seq].a_number))
    ORDER BY d.alpha_feature_nbr, d.application_number, d.schema_date DESC,
     d.feature_number DESC
    DETAIL
     IF ((fix_atr->ocd[o.seq].atr[a.seq].row_id="x"))
      fix_atr->ocd[o.seq].atr[a.seq].row_id = d.rowid, fix_atr->ocd[o.seq].atr[a.seq].f_number = d
      .feature_number
     ENDIF
    WITH nocounter
   ;end select
   DELETE  FROM dm_ocd_application d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    SET d.seq = 1
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.application_number=fix_atr->ocd[o.seq].atr[a.seq].a_number)
      AND (d.rowid != fix_atr->ocd[o.seq].atr[a.seq].row_id))
    WITH nocounter
   ;end delete
  ENDIF
 ELSEIF (tmode="TASK")
  EXECUTE FROM init_record_begin TO init_record_end
  CALL echo("***")
  CALL echo("*** Checking dm_ocd_task ...")
  CALL echo("***")
  SELECT INTO "nl:"
   d.alpha_feature_nbr, d.task_number, count(*)
   FROM dm_ocd_task d
   GROUP BY d.alpha_feature_nbr, d.task_number
   HAVING count(*) > 1
   HEAD REPORT
    fix_atr->ocd_cnt = 0, stat = alterlist(fix_atr->ocd,0), o_cnt = 0,
    a_cnt = 0
   HEAD d.alpha_feature_nbr
    fix_atr->ocd_cnt = (fix_atr->ocd_cnt+ 1), o_cnt = fix_atr->ocd_cnt, stat = alterlist(fix_atr->ocd,
     o_cnt),
    fix_atr->ocd[o_cnt].o_number = d.alpha_feature_nbr, fix_atr->ocd[o_cnt].atr_cnt = 0, stat =
    alterlist(fix_atr->ocd[o_cnt].atr,0),
    a_cnt = 0, oi = 0, ai = 0
   DETAIL
    fix_atr->ocd[o_cnt].atr_cnt = (fix_atr->ocd[o_cnt].atr_cnt+ 1), a_cnt = fix_atr->ocd[o_cnt].
    atr_cnt, stat = alterlist(fix_atr->ocd[o_cnt].atr,a_cnt),
    fix_atr->ocd[o_cnt].atr[a_cnt].a_number = d.task_number, fix_atr->ocd[o_cnt].atr[a_cnt].b_number
     = 0, fix_atr->ocd[o_cnt].atr[a_cnt].row_id = "x",
    fix_atr->max_atr_cnt = greatest(fix_atr->max_atr_cnt,fix_atr->ocd[o_cnt].atr_cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("***")
   CALL echo("*** Fixing dups...")
   CALL echo("***")
   SELECT INTO "nl:"
    FROM dm_ocd_task d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.task_number=fix_atr->ocd[o.seq].atr[a.seq].a_number))
    ORDER BY d.alpha_feature_nbr, d.task_number, d.schema_date DESC,
     d.feature_number DESC
    DETAIL
     IF ((fix_atr->ocd[o.seq].atr[a.seq].row_id="x"))
      fix_atr->ocd[o.seq].atr[a.seq].row_id = d.rowid, fix_atr->ocd[o.seq].atr[a.seq].f_number = d
      .feature_number
     ENDIF
    WITH nocounter
   ;end select
   DELETE  FROM dm_ocd_task d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    SET d.seq = 1
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.task_number=fix_atr->ocd[o.seq].atr[a.seq].a_number)
      AND (d.rowid != fix_atr->ocd[o.seq].atr[a.seq].row_id))
    WITH nocounter
   ;end delete
  ENDIF
 ELSEIF (tmode="REQUEST")
  EXECUTE FROM init_record_begin TO init_record_end
  CALL echo("***")
  CALL echo("*** Checking dm_ocd_request ...")
  CALL echo("***")
  SELECT INTO "nl:"
   d.alpha_feature_nbr, d.request_number, count(*)
   FROM dm_ocd_request d
   GROUP BY d.alpha_feature_nbr, d.request_number
   HAVING count(*) > 1
   HEAD REPORT
    fix_atr->ocd_cnt = 0, stat = alterlist(fix_atr->ocd,0), o_cnt = 0,
    a_cnt = 0
   HEAD d.alpha_feature_nbr
    fix_atr->ocd_cnt = (fix_atr->ocd_cnt+ 1), o_cnt = fix_atr->ocd_cnt, stat = alterlist(fix_atr->ocd,
     o_cnt),
    fix_atr->ocd[o_cnt].o_number = d.alpha_feature_nbr, fix_atr->ocd[o_cnt].atr_cnt = 0, stat =
    alterlist(fix_atr->ocd[o_cnt].atr,0),
    a_cnt = 0, oi = 0, ai = 0
   DETAIL
    fix_atr->ocd[o_cnt].atr_cnt = (fix_atr->ocd[o_cnt].atr_cnt+ 1), a_cnt = fix_atr->ocd[o_cnt].
    atr_cnt, stat = alterlist(fix_atr->ocd[o_cnt].atr,a_cnt),
    fix_atr->ocd[o_cnt].atr[a_cnt].a_number = d.request_number, fix_atr->ocd[o_cnt].atr[a_cnt].
    b_number = 0, fix_atr->ocd[o_cnt].atr[a_cnt].row_id = "x",
    fix_atr->max_atr_cnt = greatest(fix_atr->max_atr_cnt,fix_atr->ocd[o_cnt].atr_cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("***")
   CALL echo("*** Fixing dups...")
   CALL echo("***")
   SELECT INTO "nl:"
    FROM dm_ocd_request d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.request_number=fix_atr->ocd[o.seq].atr[a.seq].a_number))
    ORDER BY d.alpha_feature_nbr, d.request_number, d.schema_date DESC,
     d.feature_number DESC
    DETAIL
     IF ((fix_atr->ocd[o.seq].atr[a.seq].row_id="x"))
      fix_atr->ocd[o.seq].atr[a.seq].row_id = d.rowid, fix_atr->ocd[o.seq].atr[a.seq].f_number = d
      .feature_number
     ENDIF
    WITH nocounter
   ;end select
   DELETE  FROM dm_ocd_request d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    SET d.seq = 1
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.request_number=fix_atr->ocd[o.seq].atr[a.seq].a_number)
      AND (d.rowid != fix_atr->ocd[o.seq].atr[a.seq].row_id))
    WITH nocounter
   ;end delete
  ENDIF
 ELSEIF (tmode="APP_TASK_R")
  EXECUTE FROM init_record_begin TO init_record_end
  CALL echo("***")
  CALL echo("*** Checking dm_ocd_app_task_r ...")
  CALL echo("***")
  SELECT INTO "nl:"
   d.alpha_feature_nbr, d.application_number, d.task_number,
   count(*)
   FROM dm_ocd_app_task_r d
   GROUP BY d.alpha_feature_nbr, d.application_number, d.task_number
   HAVING count(*) > 1
   HEAD REPORT
    fix_atr->ocd_cnt = 0, stat = alterlist(fix_atr->ocd,0), o_cnt = 0,
    a_cnt = 0
   HEAD d.alpha_feature_nbr
    fix_atr->ocd_cnt = (fix_atr->ocd_cnt+ 1), o_cnt = fix_atr->ocd_cnt, stat = alterlist(fix_atr->ocd,
     o_cnt),
    fix_atr->ocd[o_cnt].o_number = d.alpha_feature_nbr, fix_atr->ocd[o_cnt].atr_cnt = 0, stat =
    alterlist(fix_atr->ocd[o_cnt].atr,0),
    a_cnt = 0, oi = 0, ai = 0
   DETAIL
    fix_atr->ocd[o_cnt].atr_cnt = (fix_atr->ocd[o_cnt].atr_cnt+ 1), a_cnt = fix_atr->ocd[o_cnt].
    atr_cnt, stat = alterlist(fix_atr->ocd[o_cnt].atr,a_cnt),
    fix_atr->ocd[o_cnt].atr[a_cnt].a_number = d.application_number, fix_atr->ocd[o_cnt].atr[a_cnt].
    b_number = d.task_number, fix_atr->ocd[o_cnt].atr[a_cnt].row_id = "x",
    fix_atr->max_atr_cnt = greatest(fix_atr->max_atr_cnt,fix_atr->ocd[o_cnt].atr_cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("***")
   CALL echo("*** Fixing dups...")
   CALL echo("***")
   SELECT INTO "nl:"
    FROM dm_ocd_app_task_r d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.application_number=fix_atr->ocd[o.seq].atr[a.seq].a_number)
      AND (d.task_number=fix_atr->ocd[o.seq].atr[a.seq].b_number))
    ORDER BY d.alpha_feature_nbr, d.application_number, d.task_number,
     d.schema_date DESC, d.feature_number DESC
    DETAIL
     IF ((fix_atr->ocd[o.seq].atr[a.seq].row_id="x"))
      fix_atr->ocd[o.seq].atr[a.seq].row_id = d.rowid, fix_atr->ocd[o.seq].atr[a.seq].f_number = d
      .feature_number
     ENDIF
    WITH nocounter
   ;end select
   DELETE  FROM dm_ocd_app_task_r d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    SET d.seq = 1
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.application_number=fix_atr->ocd[o.seq].atr[a.seq].a_number)
      AND (d.task_number=fix_atr->ocd[o.seq].atr[a.seq].b_number)
      AND (d.rowid != fix_atr->ocd[o.seq].atr[a.seq].row_id))
    WITH nocounter
   ;end delete
  ENDIF
 ELSEIF (tmode="TASK_REQ_R")
  EXECUTE FROM init_record_begin TO init_record_end
  CALL echo("***")
  CALL echo("*** Checking dm_ocd_task_req_r ...")
  CALL echo("***")
  SELECT INTO "nl:"
   d.alpha_feature_nbr, d.task_number, d.request_number,
   count(*)
   FROM dm_ocd_task_req_r d
   GROUP BY d.alpha_feature_nbr, d.task_number, d.request_number
   HAVING count(*) > 1
   HEAD REPORT
    fix_atr->ocd_cnt = 0, stat = alterlist(fix_atr->ocd,0), o_cnt = 0,
    a_cnt = 0
   HEAD d.alpha_feature_nbr
    fix_atr->ocd_cnt = (fix_atr->ocd_cnt+ 1), o_cnt = fix_atr->ocd_cnt, stat = alterlist(fix_atr->ocd,
     o_cnt),
    fix_atr->ocd[o_cnt].o_number = d.alpha_feature_nbr, fix_atr->ocd[o_cnt].atr_cnt = 0, stat =
    alterlist(fix_atr->ocd[o_cnt].atr,0),
    a_cnt = 0, oi = 0, ai = 0
   DETAIL
    fix_atr->ocd[o_cnt].atr_cnt = (fix_atr->ocd[o_cnt].atr_cnt+ 1), a_cnt = fix_atr->ocd[o_cnt].
    atr_cnt, stat = alterlist(fix_atr->ocd[o_cnt].atr,a_cnt),
    fix_atr->ocd[o_cnt].atr[a_cnt].a_number = d.task_number, fix_atr->ocd[o_cnt].atr[a_cnt].b_number
     = d.request_number, fix_atr->ocd[o_cnt].atr[a_cnt].row_id = "x",
    fix_atr->max_atr_cnt = greatest(fix_atr->max_atr_cnt,fix_atr->ocd[o_cnt].atr_cnt)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   CALL echo("***")
   CALL echo("*** Fixing dups...")
   CALL echo("***")
   SELECT INTO "nl:"
    FROM dm_ocd_task_req_r d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.task_number=fix_atr->ocd[o.seq].atr[a.seq].a_number)
      AND (d.request_number=fix_atr->ocd[o.seq].atr[a.seq].b_number))
    ORDER BY d.alpha_feature_nbr, d.task_number, d.request_number,
     d.schema_date DESC, d.feature_number DESC
    DETAIL
     IF ((fix_atr->ocd[o.seq].atr[a.seq].row_id="x"))
      fix_atr->ocd[o.seq].atr[a.seq].row_id = d.rowid, fix_atr->ocd[o.seq].atr[a.seq].f_number = d
      .feature_number
     ENDIF
    WITH nocounter
   ;end select
   DELETE  FROM dm_ocd_task_req_r d,
     (dummyt o  WITH seq = value(fix_atr->ocd_cnt)),
     (dummyt a  WITH seq = value(fix_atr->max_atr_cnt))
    SET d.seq = 1
    PLAN (o)
     JOIN (a
     WHERE (a.seq <= fix_atr->ocd[o.seq].atr_cnt))
     JOIN (d
     WHERE (d.alpha_feature_nbr=fix_atr->ocd[o.seq].o_number)
      AND (d.task_number=fix_atr->ocd[o.seq].atr[a.seq].a_number)
      AND (d.request_number=fix_atr->ocd[o.seq].atr[a.seq].b_number)
      AND (d.rowid != fix_atr->ocd[o.seq].atr[a.seq].row_id))
    WITH nocounter
   ;end delete
  ENDIF
 ENDIF
#init_record_begin
 FREE RECORD fix_atr
 RECORD fix_atr(
   1 max_atr_cnt = i4
   1 ocd_cnt = i4
   1 ocd[*]
     2 o_number = i4
     2 atr_cnt = i4
     2 atr[*]
       3 a_number = i4
       3 b_number = i4
       3 s_date = dq8
       3 f_number = i4
       3 dup_ind = i2
       3 row_id = vc
 )
 SET fix_atr->ocd_cnt = 0
 SET stat = alterlist(fix_atr->ocd,0)
 SET fix_atr->max_atr_cnt = 0
#init_record_end
END GO
