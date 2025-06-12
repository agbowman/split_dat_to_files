CREATE PROGRAM clean_import:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH persistscript
 RECORD filter(
   1 list[*]
     2 filter_id = f8
 )
 RECORD default(
   1 list[*]
     2 default_id = f8
 )
 RECORD default_detail(
   1 list[*]
     2 detail_id = f8
 )
 RECORD rept(
   1 list[*]
     2 report_id = f8
 )
 RECORD report_default(
   1 list[*]
     2 default_id = f8
 )
 RECORD filter_detail(
   1 list[*]
     2 detail_id = f8
 )
 RECORD flex(
   1 list[*]
     2 flex_id = f8
 )
 RECORD reltn(
   1 list[*]
     2 reltn_id = f8
 )
 RECORD text(
   1 list[*]
     2 long_text_id = f8
 )
 DECLARE cat_id = f8
 SELECT INTO "nl:"
  FROM br_datamart_filter f,
   (dummyt d1  WITH seq = size(request->list,5))
  PLAN (d1)
   JOIN (f
   WHERE (f.br_datamart_category_id=request->list[d1.seq].category_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(filter->list,cnt), filter->list[cnt].filter_id = f
   .br_datamart_filter_id
  WITH nocounter
 ;end select
 IF (size(filter->list,5) > 0)
  SELECT INTO "nl:"
   FROM br_datamart_default d,
    (dummyt d1  WITH seq = size(filter->list,5))
   PLAN (d1)
    JOIN (d
    WHERE (d.br_datamart_filter_id=filter->list[d1.seq].filter_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(default->list,cnt), default->list[cnt].default_id = d
    .br_datamart_default_id
   WITH nocounter
  ;end select
 ENDIF
 IF (size(default->list,5) > 0)
  SELECT INTO "nl:"
   FROM br_datamart_default_detail d,
    (dummyt d1  WITH seq = size(default->list,5))
   PLAN (d1)
    JOIN (d
    WHERE (d.br_datamart_default_id=default->list[d1.seq].default_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(default_detail->list,cnt), default_detail->list[cnt].detail_id
     = d.br_datamart_default_detail_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM br_datamart_report r,
   (dummyt d1  WITH seq = size(request->list,5))
  PLAN (d1)
   JOIN (r
   WHERE (r.br_datamart_category_id=request->list[d1.seq].category_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(rept->list,cnt), rept->list[cnt].report_id = r
   .br_datamart_report_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_datamart_text t,
   (dummyt d1  WITH seq = size(request->list,5))
  PLAN (d1)
   JOIN (t
   WHERE (t.br_datamart_category_id=request->list[d1.seq].category_id))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(text->list,cnt), text->list[cnt].long_text_id = t.long_text_id
  WITH nocounter
 ;end select
 IF (size(rept->list,5) > 0)
  SELECT INTO "nl:"
   FROM br_datamart_report_default r,
    (dummyt d1  WITH seq = size(rept->list,5))
   PLAN (d1)
    JOIN (r
    WHERE (r.br_datamart_report_id=rept->list[d1.seq].report_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(report_default->list,cnt), report_default->list[cnt].default_id
     = r.br_datamart_report_default_id
   WITH nocounter
  ;end select
 ENDIF
 IF (size(filter->list,5) > 0)
  SELECT INTO "nl:"
   FROM br_datamart_filter_detail f,
    (dummyt d1  WITH seq = size(filter->list,5))
   PLAN (d1)
    JOIN (f
    WHERE (f.br_datamart_filter_id=filter->list[d1.seq].filter_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(filter_detail->list,cnt), filter_detail->list[cnt].detail_id = f
    .br_datamart_filter_detail_id
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM br_datamart_value v,
   (dummyt d1  WITH seq = size(request->list,5))
  PLAN (d1)
   JOIN (v
   WHERE (v.br_datamart_category_id=request->list[d1.seq].category_id)
    AND v.br_datamart_flex_id > 0)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(flex->list,cnt), flex->list[cnt].flex_id = v.br_datamart_flex_id
  WITH nocounter
 ;end select
 IF (size(request->vlist,5) > 0)
  SELECT INTO "nl:"
   FROM mp_viewpoint_reltn r,
    (dummyt d1  WITH seq = size(request->list,5))
   PLAN (d1)
    JOIN (r
    WHERE (r.br_datamart_category_id=request->list[d1.seq].category_id))
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1), stat = alterlist(reltn->list,cnt), reltn->list[cnt].reltn_id = r
    .mp_viewpoint_reltn_id
   WITH nocounter
  ;end select
 ENDIF
 IF (size(default_detail->list,5) > 0)
  FOR (i = 1 TO size(default_detail->list,5))
   DELETE  FROM br_datamart_default_detail d
    WHERE (d.br_datamart_default_detail_id=default_detail->list[i].detail_id)
   ;end delete
   CALL echo(build("default_id deleted:",d.br_datamart_default_detail_id,"-default_id:",d
     .br_datamart_default_id))
  ENDFOR
 ELSE
  CALL echo("default_detail list is empty")
 ENDIF
 IF (size(default->list,5) > 0)
  FOR (i = 1 TO size(default->list,5))
   SELECT INTO "nl"
    FROM br_datamart_default_detail d
    PLAN (d
     WHERE (d.br_datamart_default_id=default->list[i].default_id))
    DETAIL
     CALL echo(build("child found:",default->list[i].default_id))
    WITH nocounter
   ;end select
   DELETE  FROM br_datamart_default d
    WHERE (d.br_datamart_default_id=default->list[i].default_id)
   ;end delete
  ENDFOR
 ENDIF
 IF (size(report_default->list,5) > 0)
  FOR (i = 1 TO size(report_default->list,5))
    DELETE  FROM br_datamart_report_default d
     WHERE (d.br_datamart_report_default_id=report_default->list[i].default_id)
    ;end delete
  ENDFOR
 ENDIF
 IF (size(filter_detail->list,5) > 0)
  FOR (i = 1 TO size(filter_detail->list,5))
    DELETE  FROM br_datamart_filter_detail f
     WHERE (f.br_datamart_filter_detail_id=filter_detail->list[i].detail_id)
    ;end delete
  ENDFOR
 ENDIF
 IF (size(filter->list,5) > 0)
  FOR (i = 1 TO size(filter->list,5))
   DELETE  FROM br_datamart_report_filter_r f
    WHERE (f.br_datamart_filter_id=filter->list[i].filter_id)
   ;end delete
   DELETE  FROM br_datamart_text t
    WHERE (t.br_datamart_filter_id=filter->list[i].filter_id)
   ;end delete
  ENDFOR
 ENDIF
 IF (size(rept->list,5) > 0)
  FOR (i = 1 TO size(rept->list,5))
   DELETE  FROM br_datamart_report_filter_r f
    WHERE (f.br_datamart_report_id=rept->list[i].report_id)
   ;end delete
   DELETE  FROM br_datamart_report_default d
    WHERE (d.br_datamart_report_id=rept->list[i].report_id)
   ;end delete
  ENDFOR
 ENDIF
 FOR (i = 1 TO size(request->list,5))
   DELETE  FROM br_datamart_text t
    WHERE (t.br_datamart_category_id=request->list[i].category_id)
   ;end delete
 ENDFOR
 IF (size(text->list,5) > 0)
  FOR (i = 1 TO size(text->list,5))
    DELETE  FROM br_long_text l
     WHERE (l.parent_entity_id=text->list[i].long_text_id)
    ;end delete
  ENDFOR
 ENDIF
 IF (size(flex->list,5) > 0)
  FOR (i = 1 TO size(flex->list,5))
    DELETE  FROM br_datamart_flex x
     WHERE (x.br_datamart_flex_id=flex->list[i].flex_id)
    ;end delete
  ENDFOR
 ENDIF
 FOR (i = 1 TO size(request->list,5))
   DELETE  FROM br_datamart_value v
    WHERE (v.br_datamart_category_id=request->list[i].category_id)
   ;end delete
   DELETE  FROM br_datamart_filter f
    WHERE (f.br_datamart_category_id=request->list[i].category_id)
   ;end delete
   DELETE  FROM br_datamart_report r
    WHERE (r.br_datamart_category_id=request->list[i].category_id)
   ;end delete
 ENDFOR
 IF (size(request->vlist,5) > 0)
  IF (size(reltn->list,5) > 0)
   FOR (i = 1 TO size(reltn->list,5))
     DELETE  FROM mp_viewpoint_encntr e
      WHERE (e.mp_viewpoint_reltn_id=reltn->list[i].reltn_id)
     ;end delete
   ENDFOR
  ENDIF
  IF (size(reltn->list,5) > 0)
   FOR (i = 1 TO size(reltn->list,5))
     DELETE  FROM mp_viewpoint_reltn r
      WHERE (r.mp_viewpoint_reltn_id=reltn->list[i].reltn_id)
     ;end delete
   ENDFOR
  ENDIF
  FOR (i = 1 TO size(request->vlist,5))
    DELETE  FROM mp_viewpoint v
     WHERE (v.mp_viewpoint_id=request->vlist[i].mp_viewpoint_id)
    ;end delete
  ENDFOR
 ENDIF
 FOR (i = 1 TO size(request->list,5))
   DELETE  FROM br_datamart_category c
    WHERE (c.br_datamart_category_id=request->list[i].category_id)
   ;end delete
 ENDFOR
#exit_prg
END GO
