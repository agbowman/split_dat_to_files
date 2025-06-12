CREATE PROGRAM bed_get_stndord_matches:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 id = f8
     2 short_desc = vc
     2 long_desc = vc
     2 facility = vc
     2 matches[*]
       3 code_value = f8
       3 mnemonic = vc
       3 description = vc
       3 type_flag = i2
       3 value = vc
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
 SET ccnt = 0
 SET ccnt = size(request->catalog_types,5)
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 DECLARE c_string = vc
 FOR (x = 1 TO ccnt)
   IF (x=1)
    SET c_string = build("c.catalog_type_cd in (",request->catalog_types[x].code_value)
   ELSE
    SET c_string = build(trim(c_string),",",request->catalog_types[x].code_value)
   ENDIF
 ENDFOR
 SET c_string = concat(trim(c_string),")")
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
 SET cpt_cd = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=14002
    AND c.cki="CKI.CODEVALUE!3600")
  DETAIL
   cpt_cd = c.code_value
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
     2 cpt = vc
     2 matches[*]
       3 cd = f8
       3 mnemonic = vc
       3 desc = vc
       3 type = i2
       3 value = vc
 )
 SELECT INTO "nl:"
  FROM br_oc_work b
  PLAN (b
   WHERE (b.catalog_type=request->department_name)
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
     AND parser(c_string))
   ORDER BY d.seq
   HEAD d.seq
    temp->qual[d.seq].match_ind = 1
   HEAD c.catalog_cd
    stat = alterlist(temp->qual[d.seq].matches,1), temp->qual[d.seq].matches[1].cd = c.catalog_cd,
    temp->qual[d.seq].matches[1].mnemonic = c.primary_mnemonic,
    temp->qual[d.seq].matches[1].desc = c.description, temp->qual[d.seq].matches[1].type = 1, temp->
    qual[d.seq].matches[1].value = s.mnemonic
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
     SET stat = alterlist(reply->orderables[rcnt].matches,1)
     SET reply->orderables[rcnt].matches[1].code_value = temp->qual[x].matches[1].cd
     SET reply->orderables[rcnt].matches[1].mnemonic = temp->qual[x].matches[1].mnemonic
     SET reply->orderables[rcnt].matches[1].description = temp->qual[x].matches[1].desc
     SET reply->orderables[rcnt].matches[1].type_flag = temp->qual[x].matches[1].type
     SET reply->orderables[rcnt].matches[1].value = temp->qual[x].matches[1].value
    ENDIF
  ENDFOR
 ENDIF
 CALL echorecord(reply)
#exit_script
 SET reply->status_data.status = "S"
END GO
