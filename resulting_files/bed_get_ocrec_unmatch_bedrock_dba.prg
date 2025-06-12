CREATE PROGRAM bed_get_ocrec_unmatch_bedrock:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 mnemonic = vc
     2 description = vc
     2 activity_subtype
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 oe_format_id = f8
     2 dept_name = vc
     2 concept_cki = vc
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
 DECLARE b_string = vc
 SET b_string = "b.match_orderable_cd = temp->qual[d.seq].cd"
 IF ((request->facility > " "))
  SET b_string = concat(b_string," and b.facility = request->facility")
 ENDIF
 RECORD temp(
   1 qual[*]
     2 cd = f8
     2 mnemonic = vc
     2 description = vc
     2 sub_cd = f8
     2 sub_disp = vc
     2 sub_mean = vc
     2 format_id = f8
     2 dept = vc
     2 cki = vc
     2 match_ind = i2
 )
 SELECT INTO "nl:"
  FROM br_auto_order_catalog b
  PLAN (b
   WHERE (b.catalog_type_cd=request->catalog_type_code_value)
    AND (b.activity_type_cd=request->activity_type_code_value))
  ORDER BY b.primary_mnemonic
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cd = b.catalog_cd,
   temp->qual[cnt].mnemonic = b.primary_mnemonic, temp->qual[cnt].description = b.description, temp->
   qual[cnt].sub_cd = b.activity_subtype_cd,
   temp->qual[cnt].format_id = b.oe_format_id, temp->qual[cnt].dept = b.dept_name, temp->qual[cnt].
   cki = b.concept_cki
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=temp->qual[d.seq].sub_cd))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].sub_disp = c.display, temp->qual[d.seq].sub_mean = c.cdf_meaning
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   br_oc_work b
  PLAN (d
   WHERE (temp->qual[d.seq].match_ind=0))
   JOIN (b
   WHERE parser(b_string))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].match_ind = 1
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].match_ind=0))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->orderables,rcnt)
    SET reply->orderables[rcnt].code_value = temp->qual[x].cd
    SET reply->orderables[rcnt].mnemonic = temp->qual[x].mnemonic
    SET reply->orderables[rcnt].description = temp->qual[x].description
    SET reply->orderables[rcnt].activity_subtype.code_value = temp->qual[x].sub_cd
    SET reply->orderables[rcnt].activity_subtype.display = temp->qual[x].sub_disp
    SET reply->orderables[rcnt].activity_subtype.mean = temp->qual[x].sub_mean
    SET reply->orderables[rcnt].oe_format_id = temp->qual[x].format_id
    SET reply->orderables[rcnt].dept_name = temp->qual[x].dept
    SET reply->orderables[rcnt].concept_cki = temp->qual[x].cki
   ENDIF
 ENDFOR
 CALL echorecord(reply)
#exit_script
 IF (rcnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
