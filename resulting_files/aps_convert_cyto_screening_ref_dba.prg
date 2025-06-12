CREATE PROGRAM aps_convert_cyto_screening_ref:dba
 RECORD temp(
   1 qual[*]
     2 prsnl_group_reltn_id = f8
     2 person_id = f8
 )
 SET x = 0
 SET stat = alterlist(temp->qual,10)
 SELECT INTO "nl:"
  csl.prsnl_group_reltn_id, pgr.person_id
  FROM cyto_screening_limits csl,
   prsnl_group_reltn pgr
  PLAN (csl)
   JOIN (pgr
   WHERE pgr.prsnl_group_reltn_id=csl.prsnl_group_reltn_id)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alterlist(temp->qual,(x+ 9))
   ENDIF
   temp->qual[x].prsnl_group_reltn_id = csl.prsnl_group_reltn_id, temp->qual[x].person_id = pgr
   .person_id
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->qual,x)
 IF (x > 0)
  UPDATE  FROM cyto_screening_limits csl,
    (dummyt d  WITH seq = value(x))
   SET csl.prsnl_id = temp->qual[d.seq].person_id
   PLAN (d)
    JOIN (csl
    WHERE (csl.prsnl_group_reltn_id=temp->qual[d.seq].prsnl_group_reltn_id))
   WITH nocounter
  ;end update
  IF (curqual != 0)
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
 SET stat = alterlist(temp->qual,10)
 SELECT INTO "nl:"
  css.prsnl_group_reltn_id, pgr.person_id
  FROM cyto_screening_security css,
   prsnl_group_reltn pgr
  PLAN (css)
   JOIN (pgr
   WHERE pgr.prsnl_group_reltn_id=css.prsnl_group_reltn_id)
  HEAD REPORT
   x = 0
  DETAIL
   x = (x+ 1)
   IF (mod(x,10)=1
    AND x != 1)
    stat = alterlist(temp->qual,(x+ 9))
   ENDIF
   temp->qual[x].prsnl_group_reltn_id = css.prsnl_group_reltn_id, temp->qual[x].person_id = pgr
   .person_id
  WITH nocounter
 ;end select
 SET stat = alterlist(temp->qual,x)
 IF (x > 0)
  UPDATE  FROM cyto_screening_security css,
    (dummyt d  WITH seq = value(x))
   SET css.prsnl_id = temp->qual[d.seq].person_id
   PLAN (d)
    JOIN (css
    WHERE (css.prsnl_group_reltn_id=temp->qual[d.seq].prsnl_group_reltn_id))
   WITH nocounter
  ;end update
  IF (curqual != 0)
   COMMIT
  ELSE
   ROLLBACK
  ENDIF
 ENDIF
END GO
