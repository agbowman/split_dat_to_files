CREATE PROGRAM bed_get_stndord_rev_matches:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 legacy
       3 id = f8
       3 short_desc = vc
       3 long_desc = vc
       3 facility = vc
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 catalog_type
         4 code_value = f8
         4 display = vc
         4 meaning = vc
       3 activity_type
         4 code_value = f8
         4 display = vc
         4 meaning = vc
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
 SET mcnt = 0
 SET ccnt = 0
 RECORD temp(
   1 qual[*]
     2 cd = f8
     2 legacy
       3 id = f8
       3 short_desc = vc
       3 long_desc = vc
       3 facility = vc
     2 millennium
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 concept_cki = vc
       3 catalog_type
         4 code_value = f8
         4 display = vc
         4 meaning = vc
       3 activity_type
         4 code_value = f8
         4 display = vc
         4 meaning = vc
 )
 SET ccnt = size(request->catalog_types,5)
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 DECLARE c_string = vc
 FOR (x = 1 TO ccnt)
   IF (x=1)
    SET c_string = build("o.catalog_type_cd in (",request->catalog_types[x].code_value)
   ELSE
    SET c_string = build(trim(c_string),",",request->catalog_types[x].code_value)
   ENDIF
 ENDFOR
 SET c_string = concat(trim(c_string),")")
 SELECT INTO "nl:"
  FROM br_oc_work b
  PLAN (b
   WHERE b.match_orderable_cd > 0
    AND (b.catalog_type=request->department_name))
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cd = b.match_orderable_cd,
   temp->qual[cnt].legacy.id = b.oc_id, temp->qual[cnt].legacy.short_desc = b.short_desc, temp->qual[
   cnt].legacy.long_desc = b.long_desc,
   temp->qual[cnt].legacy.facility = b.facility
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog o,
   code_value cv1,
   code_value cv2
  PLAN (d)
   JOIN (o
   WHERE (o.catalog_cd=temp->qual[d.seq].cd)
    AND parser(c_string))
   JOIN (cv1
   WHERE cv1.code_value=o.catalog_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_type_cd
    AND cv2.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].millennium.code_value = o.catalog_cd, temp->qual[d.seq].millennium.mnemonic = o
   .primary_mnemonic, temp->qual[d.seq].millennium.description = o.description,
   temp->qual[d.seq].millennium.concept_cki = o.concept_cki, temp->qual[d.seq].millennium.
   catalog_type.code_value = cv1.code_value, temp->qual[d.seq].millennium.catalog_type.display = cv1
   .display,
   temp->qual[d.seq].millennium.catalog_type.meaning = cv1.cdf_meaning, temp->qual[d.seq].millennium.
   activity_type.code_value = cv2.code_value, temp->qual[d.seq].millennium.activity_type.display =
   cv2.display,
   temp->qual[d.seq].millennium.activity_type.meaning = cv2.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_auto_order_catalog b
  PLAN (d)
   JOIN (b
   WHERE (b.catalog_cd=temp->qual[d.seq].cd)
    AND (temp->qual[d.seq].millennium.code_value=0))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].millennium.concept_cki = b.concept_cki
  WITH nocounter, skipbedrock = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog o,
   code_value cv1,
   code_value cv2
  PLAN (d)
   JOIN (o
   WHERE (o.concept_cki=temp->qual[d.seq].millennium.concept_cki)
    AND (temp->qual[d.seq].millennium.code_value=0)
    AND parser(c_string))
   JOIN (cv1
   WHERE cv1.code_value=o.catalog_type_cd
    AND cv1.active_ind=1)
   JOIN (cv2
   WHERE cv2.code_value=o.activity_type_cd
    AND cv2.active_ind=1)
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].millennium.code_value = o.catalog_cd, temp->qual[d.seq].millennium.mnemonic = o
   .primary_mnemonic, temp->qual[d.seq].millennium.description = o.description,
   temp->qual[d.seq].millennium.concept_cki = o.concept_cki, temp->qual[d.seq].millennium.
   catalog_type.code_value = cv1.code_value, temp->qual[d.seq].millennium.catalog_type.display = cv1
   .display,
   temp->qual[d.seq].millennium.catalog_type.meaning = cv1.cdf_meaning, temp->qual[d.seq].millennium.
   activity_type.code_value = cv2.code_value, temp->qual[d.seq].millennium.activity_type.display =
   cv2.display,
   temp->qual[d.seq].millennium.activity_type.meaning = cv2.cdf_meaning
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].millennium.code_value > 0))
    SET mcnt = (mcnt+ 1)
    SET stat = alterlist(reply->orderables,mcnt)
    SET reply->orderables[mcnt].legacy.id = temp->qual[x].legacy.id
    SET reply->orderables[mcnt].legacy.short_desc = temp->qual[x].legacy.short_desc
    SET reply->orderables[mcnt].legacy.long_desc = temp->qual[x].legacy.long_desc
    SET reply->orderables[mcnt].legacy.facility = temp->qual[x].legacy.facility
    SET reply->orderables[mcnt].millennium.code_value = temp->qual[x].millennium.code_value
    SET reply->orderables[mcnt].millennium.mnemonic = temp->qual[x].millennium.mnemonic
    SET reply->orderables[mcnt].millennium.description = temp->qual[x].millennium.description
    SET reply->orderables[mcnt].millennium.catalog_type.code_value = temp->qual[x].millennium.
    catalog_type.code_value
    SET reply->orderables[mcnt].millennium.catalog_type.display = temp->qual[x].millennium.
    catalog_type.display
    SET reply->orderables[mcnt].millennium.catalog_type.meaning = temp->qual[x].millennium.
    catalog_type.meaning
    SET reply->orderables[mcnt].millennium.activity_type.code_value = temp->qual[x].millennium.
    activity_type.code_value
    SET reply->orderables[mcnt].millennium.activity_type.display = temp->qual[x].millennium.
    activity_type.display
    SET reply->orderables[mcnt].millennium.activity_type.meaning = temp->qual[x].millennium.
    activity_type.meaning
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
