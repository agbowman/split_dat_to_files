CREATE PROGRAM bed_get_rad_seg_orders:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 subtypes[*]
      2 code_value = f8
      2 orderables[*]
        3 code_value = f8
        3 primary_mnemonic = vc
        3 multi_segment_ind = i2
        3 segment_cnt_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) WITH protect
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE cnt = i2 WITH protect, noconstant(0)
 DECLARE scnt = i2 WITH protect, noconstant(0)
 DECLARE ocnt = i2 WITH protect, noconstant(0)
 DECLARE rcnt = i2 WITH protect, noconstant(0)
 DECLARE rad_cd = f8 WITH protect
 DECLARE date_cd = f8 WITH protect
 SET cnt = 0
 SET scnt = 0
 SET ocnt = 0
 SET cnt = size(request->subtypes,5)
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 RECORD temp(
   1 subtypes[*]
     2 code_value = f8
     2 orderables[*]
       3 use_ind = i2
       3 code_value = f8
       3 primary_mnemonic = vc
       3 multi_segment_ind = i2
       3 segment_cnt_ind = i2
 )
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=106
    AND cv.cdf_meaning="RADIOLOGY"
    AND cv.active_ind=1)
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET date_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=289
    AND cv.display_key="DATEANDTIME"
    AND cv.active_ind=1)
  DETAIL
   date_cd = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE oc.activity_type_cd=rad_cd
    AND (oc.activity_subtype_cd=request->subtypes[d.seq].code_value)
    AND  NOT (oc.orderable_type_flag IN (2, 6))
    AND oc.active_ind=1)
  ORDER BY oc.activity_subtype_cd, oc.primary_mnemonic
  HEAD oc.activity_subtype_cd
   ocnt = 0, scnt = (scnt+ 1), stat = alterlist(temp->subtypes,scnt),
   temp->subtypes[scnt].code_value = oc.activity_subtype_cd
  HEAD oc.primary_mnemonic
   ocnt = (ocnt+ 1), stat = alterlist(temp->subtypes[scnt].orderables,ocnt), temp->subtypes[scnt].
   orderables[ocnt].code_value = oc.catalog_cd,
   temp->subtypes[scnt].orderables[ocnt].primary_mnemonic = oc.primary_mnemonic, temp->subtypes[scnt]
   .orderables[ocnt].use_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO scnt)
  SET ocnt = size(temp->subtypes[x].orderables,5)
  IF (ocnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(ocnt)),
     br_exam_segment_info b,
     order_catalog oc
    PLAN (d)
     JOIN (b
     WHERE (b.catalog_cd=temp->subtypes[x].orderables[d.seq].code_value))
     JOIN (oc
     WHERE oc.catalog_cd=b.catalog_cd
      AND oc.active_ind=1)
    ORDER BY d.seq
    HEAD d.seq
     temp->subtypes[x].orderables[d.seq].multi_segment_ind = 1, temp->subtypes[x].orderables[d.seq].
     use_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 FOR (x = 1 TO scnt)
  SET ocnt = size(temp->subtypes[x].orderables,5)
  SELECT INTO "nl:"
   p.catalog_cd, d.seq
   FROM (dummyt d  WITH seq = value(ocnt)),
    profile_task_r p,
    discrete_task_assay t
   PLAN (d
    WHERE (temp->subtypes[x].orderables[d.seq].multi_segment_ind=0))
    JOIN (p
    WHERE (p.catalog_cd=temp->subtypes[x].orderables[d.seq].code_value)
     AND p.active_ind=1)
    JOIN (t
    WHERE t.task_assay_cd=p.task_assay_cd
     AND t.default_result_type_cd=date_cd)
   GROUP BY p.catalog_cd
   HAVING count(*)=1
   ORDER BY d.seq
   HEAD d.seq
    temp->subtypes[x].orderables[d.seq].use_ind = 0
   WITH nocounter
  ;end select
 ENDFOR
 FOR (x = 1 TO scnt)
  SET ocnt = size(temp->subtypes[x].orderables,5)
  IF (ocnt > 0)
   SELECT INTO "nl:"
    p.catalog_cd, d.seq
    FROM (dummyt d  WITH seq = value(ocnt)),
     profile_task_r p,
     discrete_task_assay t
    PLAN (d
     WHERE (temp->subtypes[x].orderables[d.seq].use_ind=1))
     JOIN (p
     WHERE (p.catalog_cd=temp->subtypes[x].orderables[d.seq].code_value)
      AND p.active_ind=1)
     JOIN (t
     WHERE t.task_assay_cd=p.task_assay_cd
      AND t.default_result_type_cd=date_cd)
    GROUP BY p.catalog_cd
    HAVING count(*) > 1
    ORDER BY d.seq
    HEAD d.seq
     temp->subtypes[x].orderables[d.seq].segment_cnt_ind = 1
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
 FOR (x = 1 TO scnt)
   SET stat = alterlist(reply->subtypes,scnt)
   SET reply->subtypes[x].code_value = temp->subtypes[x].code_value
   SET rcnt = 0
   SET ocnt = size(temp->subtypes[x].orderables,5)
   FOR (y = 1 TO ocnt)
     IF ((temp->subtypes[x].orderables[y].use_ind=1))
      SET rcnt = (rcnt+ 1)
      SET stat = alterlist(reply->subtypes[x].orderables,rcnt)
      SET reply->subtypes[x].orderables[rcnt].code_value = temp->subtypes[x].orderables[y].code_value
      SET reply->subtypes[x].orderables[rcnt].primary_mnemonic = temp->subtypes[x].orderables[y].
      primary_mnemonic
      SET reply->subtypes[x].orderables[rcnt].multi_segment_ind = temp->subtypes[x].orderables[y].
      multi_segment_ind
      SET reply->subtypes[x].orderables[rcnt].segment_cnt_ind = temp->subtypes[x].orderables[y].
      segment_cnt_ind
     ENDIF
   ENDFOR
 ENDFOR
#exit_script
 IF (size(reply->subtypes,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
