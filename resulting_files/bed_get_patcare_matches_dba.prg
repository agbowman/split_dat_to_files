CREATE PROGRAM bed_get_patcare_matches:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 facility = vc
     2 match
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 type_flag = i2
       3 value = vc
       3 autobuild_ind = i2
       3 catalog_type
         4 code_value = f8
         4 display = vc
         4 cdf_meaning = vc
       3 activity_type
         4 code_value = f8
         4 display = vc
         4 cdf_meaning = vc
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
 SET rcnt = 0
 SET dcnt = 0
 SET dcnt = size(request->departments,5)
 IF (dcnt=0)
  GO TO exit_script
 ENDIF
 SET lab_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="GENERAL LAB")
  DETAIL
   lab_cd = cv.code_value
  WITH nocounter
 ;end select
 SET rad_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="RADIOLOGY")
  DETAIL
   rad_cd = cv.code_value
  WITH nocounter
 ;end select
 SET surg_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="SURGERY")
  DETAIL
   surg_cd = cv.code_value
  WITH nocounter
 ;end select
 SET pharm_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=6000
    AND cv.cdf_meaning="PHARMACY")
  DETAIL
   pharm_cd = cv.code_value
  WITH nocounter
 ;end select
 SET dcp_cd = 0.0
 SET ancillary_cd = 0.0
 SET primary_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=6011
    AND c.cdf_meaning IN ("DCP", "ANCILLARY", "PRIMARY"))
  DETAIL
   CASE (c.cdf_meaning)
    OF "DCP":
     dcp_cd = c.code_value
    OF "ANCILLARY":
     ancillary_cd = c.code_value
    OF "PRIMARY":
     primary_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 RECORD temp(
   1 qual[*]
     2 id = f8
     2 mnemonic = vc
     2 desc = vc
     2 l_mnemonic = vc
     2 l_desc = vc
     2 match_ind = i2
     2 facility = vc
     2 match
       3 cd = f8
       3 mnemonic = vc
       3 desc = vc
       3 type = i2
       3 value = vc
       3 autobuild_ind = i2
       3 catalog_type_cd = f8
       3 catalog_type = vc
       3 activity_type_cd = f8
       3 activity_type = vc
 )
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(dcnt)),
   br_oc_work b
  PLAN (d)
   JOIN (b
   WHERE (b.catalog_type=request->departments[d.seq].name)
    AND b.status_ind=0)
  ORDER BY b.short_desc
  HEAD b.oc_id
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].id = b.oc_id,
   temp->qual[cnt].mnemonic = cnvtupper(b.short_desc), temp->qual[cnt].desc = cnvtupper(b.long_desc),
   temp->qual[cnt].l_mnemonic = b.short_desc,
   temp->qual[cnt].l_desc = b.long_desc, temp->qual[cnt].match_ind = 0, temp->qual[cnt].facility = b
   .facility
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 IF ((request->match_option_flag=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_catalog_synonym s,
    order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (s
    WHERE (((s.mnemonic_key_cap=temp->qual[d.seq].mnemonic)) OR ((s.mnemonic_key_cap=temp->qual[d.seq
    ].desc)))
     AND s.mnemonic_type_cd IN (dcp_cd, ancillary_cd, primary_cd))
    JOIN (c
    WHERE c.catalog_cd=s.catalog_cd
     AND  NOT (c.catalog_type_cd IN (lab_cd, rad_cd, surg_cd, pharm_cd)))
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    temp->qual[d.seq].match.cd = c.catalog_cd, temp->qual[d.seq].match.mnemonic = c.primary_mnemonic,
    temp->qual[d.seq].match.desc = c.description,
    temp->qual[d.seq].match.type = 1, temp->qual[d.seq].match.value = s.mnemonic, temp->qual[d.seq].
    match.catalog_type_cd = c.catalog_type_cd,
    temp->qual[d.seq].match.activity_type_cd = c.activity_type_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_auto_oc_synonym s,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (s
    WHERE (((s.mnemonic_key_cap=temp->qual[d.seq].mnemonic)) OR ((s.mnemonic_key_cap=temp->qual[d.seq
    ].desc)))
     AND s.mnemonic_type_cd IN (dcp_cd, ancillary_cd, primary_cd))
    JOIN (c
    WHERE c.catalog_cd=s.catalog_cd
     AND c.patient_care_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    temp->qual[d.seq].match.cd = c.catalog_cd, temp->qual[d.seq].match.mnemonic = c.primary_mnemonic,
    temp->qual[d.seq].match.desc = c.description,
    temp->qual[d.seq].match.type = 1, temp->qual[d.seq].match.value = s.mnemonic, temp->qual[d.seq].
    match.autobuild_ind = 1,
    temp->qual[d.seq].match.catalog_type_cd = c.catalog_type_cd, temp->qual[d.seq].match.catalog_type
     = c.catalog_type_display, temp->qual[d.seq].match.activity_type_cd = c.activity_type_cd,
    temp->qual[d.seq].match.activity_type = c.activity_type_display
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="BR_AUTO_ORDER_CATALOG"
     AND (((n.alias_name_key_cap=temp->qual[d.seq].mnemonic)) OR ((n.alias_name_key_cap=temp->qual[d
    .seq].desc))) )
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id
     AND  NOT (c.catalog_type_cd IN (lab_cd, rad_cd, surg_cd, pharm_cd)))
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    temp->qual[d.seq].match.cd = c.catalog_cd, temp->qual[d.seq].match.mnemonic = c.primary_mnemonic,
    temp->qual[d.seq].match.desc = c.description,
    temp->qual[d.seq].match.type = 1, temp->qual[d.seq].match.value = n.alias_name, temp->qual[d.seq]
    .match.catalog_type_cd = c.catalog_type_cd,
    temp->qual[d.seq].match.activity_type_cd = c.activity_type_cd
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="BR_AUTO_ORDER_CATALOG"
     AND (((n.alias_name_key_cap=temp->qual[d.seq].mnemonic)) OR ((n.alias_name_key_cap=temp->qual[d
    .seq].desc))) )
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id
     AND c.patient_care_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    temp->qual[d.seq].match.cd = c.catalog_cd, temp->qual[d.seq].match.mnemonic = c.primary_mnemonic,
    temp->qual[d.seq].match.desc = c.description,
    temp->qual[d.seq].match.type = 1, temp->qual[d.seq].match.value = n.alias_name, temp->qual[d.seq]
    .match.autobuild_ind = 1,
    temp->qual[d.seq].match.catalog_type_cd = c.catalog_type_cd, temp->qual[d.seq].match.catalog_type
     = c.catalog_type_display, temp->qual[d.seq].match.activity_type_cd = c.activity_type_cd,
    temp->qual[d.seq].match.activity_type = c.activity_type_display
   WITH nocounter, skipbedrock = 1
  ;end select
  SET rcnt = 0
  FOR (x = 1 TO cnt)
    IF ((temp->qual[x].match_ind=1))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->orderables,rcnt)
     SET reply->orderables[rcnt].id = temp->qual[x].id
     SET reply->orderables[rcnt].short_desc = temp->qual[x].l_mnemonic
     SET reply->orderables[rcnt].long_desc = temp->qual[x].l_desc
     SET reply->orderables[rcnt].facility = temp->qual[x].facility
     SET reply->orderables[rcnt].match.code_value = temp->qual[x].match.cd
     SET reply->orderables[rcnt].match.mnemonic = temp->qual[x].match.mnemonic
     SET reply->orderables[rcnt].match.description = temp->qual[x].match.desc
     SET reply->orderables[rcnt].match.type_flag = temp->qual[x].match.type
     SET reply->orderables[rcnt].match.value = temp->qual[x].match.value
     SET reply->orderables[rcnt].match.autobuild_ind = temp->qual[x].match.autobuild_ind
     SET reply->orderables[rcnt].match.catalog_type.code_value = temp->qual[x].match.catalog_type_cd
     SET reply->orderables[rcnt].match.catalog_type.display = temp->qual[x].match.catalog_type
     SET reply->orderables[rcnt].match.activity_type.code_value = temp->qual[x].match.
     activity_type_cd
     SET reply->orderables[rcnt].match.activity_type.display = temp->qual[x].match.activity_type
    ENDIF
  ENDFOR
  IF (rcnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     code_value cv
    PLAN (d
     WHERE (reply->orderables[d.seq].match.catalog_type.code_value > 0))
     JOIN (cv
     WHERE (cv.code_value=reply->orderables[d.seq].match.catalog_type.code_value))
    DETAIL
     reply->orderables[d.seq].match.catalog_type.display = cv.display, reply->orderables[d.seq].match
     .catalog_type.cdf_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     code_value cv
    PLAN (d
     WHERE (reply->orderables[d.seq].match.activity_type.code_value > 0))
     JOIN (cv
     WHERE (cv.code_value=reply->orderables[d.seq].match.activity_type.code_value))
    DETAIL
     reply->orderables[d.seq].match.activity_type.display = cv.display, reply->orderables[d.seq].
     match.activity_type.cdf_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->match_option_flag=2))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    br_other_names n,
    br_auto_order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=0))
    JOIN (n
    WHERE n.parent_entity_name="CODE_VALUE"
     AND (((n.alias_name_key_cap=temp->qual[d.seq].mnemonic)) OR ((n.alias_name_key_cap=temp->qual[d
    .seq].desc))) )
    JOIN (c
    WHERE c.catalog_cd=n.parent_entity_id
     AND c.patient_care_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    temp->qual[d.seq].match.cd = c.catalog_cd, temp->qual[d.seq].match.mnemonic = c.primary_mnemonic,
    temp->qual[d.seq].match.desc = c.description,
    temp->qual[d.seq].match.type = 2, temp->qual[d.seq].match.value = n.alias_name, temp->qual[d.seq]
    .match.autobuild_ind = 1,
    temp->qual[d.seq].match.catalog_type_cd = c.catalog_type_cd, temp->qual[d.seq].match.catalog_type
     = c.catalog_type_display, temp->qual[d.seq].match.activity_type_cd = c.activity_type_cd,
    temp->qual[d.seq].match.activity_type = c.activity_type_display
   WITH nocounter, skipbedrock = 1
  ;end select
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(cnt)),
    order_catalog c
   PLAN (d
    WHERE (temp->qual[d.seq].match_ind=1))
    JOIN (c
    WHERE c.active_ind=1
     AND cnvtupper(c.primary_mnemonic)=cnvtupper(temp->qual[d.seq].match.mnemonic))
   ORDER BY d.seq
   HEAD c.catalog_cd
    temp->qual[d.seq].match.cd = c.catalog_cd, temp->qual[d.seq].match.mnemonic = c.primary_mnemonic,
    temp->qual[d.seq].match.desc = c.description,
    temp->qual[d.seq].match.type = 2, temp->qual[d.seq].match.autobuild_ind = 0, temp->qual[d.seq].
    match.catalog_type_cd = c.catalog_type_cd,
    temp->qual[d.seq].match.activity_type_cd = c.activity_type_cd
   WITH nocounter
  ;end select
  SET rcnt = 0
  FOR (x = 1 TO cnt)
    IF ((temp->qual[x].match_ind=1))
     SET rcnt = (rcnt+ 1)
     SET stat = alterlist(reply->orderables,rcnt)
     SET reply->orderables[rcnt].id = temp->qual[x].id
     SET reply->orderables[rcnt].short_desc = temp->qual[x].l_mnemonic
     SET reply->orderables[rcnt].long_desc = temp->qual[x].l_desc
     SET reply->orderables[rcnt].facility = temp->qual[x].facility
     SET reply->orderables[rcnt].match.code_value = temp->qual[x].match.cd
     SET reply->orderables[rcnt].match.mnemonic = temp->qual[x].match.mnemonic
     SET reply->orderables[rcnt].match.description = temp->qual[x].match.desc
     SET reply->orderables[rcnt].match.type_flag = temp->qual[x].match.type
     SET reply->orderables[rcnt].match.value = temp->qual[x].match.value
     SET reply->orderables[rcnt].match.autobuild_ind = temp->qual[x].match.autobuild_ind
     SET reply->orderables[rcnt].match.catalog_type.code_value = temp->qual[x].match.catalog_type_cd
     SET reply->orderables[rcnt].match.catalog_type.display = temp->qual[x].match.catalog_type
     SET reply->orderables[rcnt].match.activity_type.code_value = temp->qual[x].match.
     activity_type_cd
     SET reply->orderables[rcnt].match.activity_type.display = temp->qual[x].match.activity_type
    ENDIF
  ENDFOR
  IF (rcnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     code_value cv
    PLAN (d
     WHERE (reply->orderables[d.seq].match.catalog_type.code_value > 0))
     JOIN (cv
     WHERE (cv.code_value=reply->orderables[d.seq].match.catalog_type.code_value))
    DETAIL
     reply->orderables[d.seq].match.catalog_type.display = cv.display, reply->orderables[d.seq].match
     .catalog_type.cdf_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = rcnt),
     code_value cv
    PLAN (d
     WHERE (reply->orderables[d.seq].match.activity_type.code_value > 0))
     JOIN (cv
     WHERE (cv.code_value=reply->orderables[d.seq].match.activity_type.code_value))
    DETAIL
     reply->orderables[d.seq].match.activity_type.display = cv.display, reply->orderables[d.seq].
     match.activity_type.cdf_meaning = cv.cdf_meaning
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
