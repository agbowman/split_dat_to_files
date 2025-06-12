CREATE PROGRAM aps_event_codes_audit
 RECORD oc(
   1 qual[*]
     2 catalog_cd = f8
     2 mnemonic = vc
     2 err_ind = i2
     2 es_err_ind = i2
     2 event_cd = f8
     2 event_set_name = c40
 )
 RECORD dta(
   1 qual[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 err_ind = i2
     2 es_err_ind = i2
     2 event_cd = f8
     2 event_set_name = c40
 )
 RECORD event(
   1 qual[*]
     2 parent_cd = f8
     2 event_cd = f8
 )
 SET x = 0
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM code_value cv,
   order_catalog oc
  PLAN (cv
   WHERE 5801=cv.code_set
    AND "APREPORT"=cv.cdf_meaning
    AND 1=cv.active_ind)
   JOIN (oc
   WHERE cv.code_value=oc.activity_subtype_cd
    AND 1=oc.active_ind)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1)
    stat = alterlist(oc->qual,(cnt+ 4))
   ENDIF
   oc->qual[cnt].catalog_cd = oc.catalog_cd, oc->qual[cnt].mnemonic = oc.primary_mnemonic, oc->qual[
   cnt].err_ind = 0
  FOOT REPORT
   stat = alterlist(oc->qual,cnt)
  WITH nocounter
 ;end select
 IF (size(oc->qual,5) > 0)
  SET stat = alterlist(event->qual,size(oc->qual,5))
  FOR (x = 1 TO size(oc->qual,5))
   SET event->qual[x].parent_cd = oc->qual[x].catalog_cd
   SET event->qual[x].event_cd = 0.0
  ENDFOR
  EXECUTE aps_get_event_codes
  FOR (x = 1 TO size(oc->qual,5))
    IF ((event->qual[x].event_cd=0.0))
     SET oc->qual[x].err_ind = 1
    ENDIF
  ENDFOR
 ENDIF
 IF (size(oc->qual,5) > 0)
  SELECT INTO "nl:"
   d1.seq
   FROM (dummyt d1  WITH seq = value(size(oc->qual,5))),
    code_value_event_r cv,
    v500_event_code ec,
    (dummyt d2  WITH seq = 1),
    v500_event_set_explode es
   PLAN (d1)
    JOIN (cv
    WHERE (oc->qual[d1.seq].catalog_cd=cv.parent_cd))
    JOIN (ec
    WHERE cv.event_cd=ec.event_cd)
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (es
    WHERE ec.event_cd=es.event_cd)
   DETAIL
    oc->qual[d1.seq].es_err_ind = 1, oc->qual[d1.seq].event_cd = ec.event_cd, oc->qual[d1.seq].
    event_set_name = ec.event_set_name
   WITH nocounter, outerjoin = d2, dontexist
  ;end select
 ENDIF
 SELECT DISTINCT INTO "nl:"
  d1.seq, dta.task_assay_cd
  FROM (dummyt d1  WITH seq = value(size(oc->qual,5))),
   profile_task_r ptr,
   discrete_task_assay dta
  PLAN (d1)
   JOIN (ptr
   WHERE (oc->qual[d1.seq].catalog_cd=ptr.catalog_cd)
    AND ptr.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN ptr.beg_effective_dt_tm AND ptr.end_effective_dt_tm)
   JOIN (dta
   WHERE ptr.task_assay_cd=dta.task_assay_cd
    AND 1=dta.active_ind)
  ORDER BY dta.task_assay_cd, 0
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,5)=1)
    stat = alterlist(dta->qual,(cnt+ 4))
   ENDIF
   dta->qual[cnt].task_assay_cd = dta.task_assay_cd, dta->qual[cnt].mnemonic = dta.mnemonic, dta->
   qual[cnt].err_ind = 0
  FOOT REPORT
   stat = alterlist(dta->qual,cnt)
  WITH nocounter
 ;end select
 IF (size(dta->qual,5) > 0)
  SET stat = alterlist(event->qual,size(dta->qual,5))
  FOR (x = 1 TO size(dta->qual,5))
   SET event->qual[x].parent_cd = dta->qual[x].task_assay_cd
   SET event->qual[x].event_cd = 0.0
  ENDFOR
  EXECUTE aps_get_event_codes
  FOR (x = 1 TO size(dta->qual,5))
    IF ((event->qual[x].event_cd=0.0))
     SET dta->qual[x].err_ind = 1
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   d1.seq
   FROM (dummyt d1  WITH seq = value(size(dta->qual,5))),
    code_value_event_r cv,
    v500_event_code ec,
    (dummyt d2  WITH seq = 1),
    v500_event_set_explode es
   PLAN (d1)
    JOIN (cv
    WHERE (dta->qual[d1.seq].task_assay_cd=cv.parent_cd))
    JOIN (ec
    WHERE cv.event_cd=ec.event_cd)
    JOIN (d2
    WHERE 1=d2.seq)
    JOIN (es
    WHERE ec.event_cd=es.event_cd)
   DETAIL
    dta->qual[d1.seq].es_err_ind = 1, dta->qual[d1.seq].event_cd = ec.event_cd, dta->qual[d1.seq].
    event_set_name = ec.event_set_name
   WITH nocounter, outerjoin = d2, dontexist
  ;end select
 ENDIF
 SELECT
  xyz = 0
  DETAIL
   col 0, "Reports without event codes", row + 1
   FOR (x = 1 TO size(oc->qual,5))
     IF ((oc->qual[x].err_ind=1))
      col 0, oc->qual[x].catalog_cd, col 20,
      oc->qual[x].mnemonic, row + 1
     ENDIF
   ENDFOR
   row + 1, col 0, "Discrete task assays without event codes",
   row + 1
   FOR (x = 1 TO size(dta->qual,5))
     IF ((dta->qual[x].err_ind=1))
      col 0, dta->qual[x].task_assay_cd, col 20,
      dta->qual[x].mnemonic, row + 1
     ENDIF
   ENDFOR
   row + 4, col 0, "Report event codes without a primitive event set",
   row + 1
   FOR (x = 1 TO size(oc->qual,5))
     IF ((oc->qual[x].es_err_ind=1))
      col 0, oc->qual[x].event_cd, col 20,
      oc->qual[x].event_set_name, col 55, oc->qual[x].mnemonic,
      row + 1
     ENDIF
   ENDFOR
   row + 1, col 0, "Report Section event codes without a primitive event set",
   row + 1
   FOR (x = 1 TO size(dta->qual,5))
     IF ((dta->qual[x].es_err_ind=1))
      col 0, dta->qual[x].event_cd, col 20,
      dta->qual[x].event_set_name, col 55, dta->qual[x].mnemonic,
      row + 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
END GO
