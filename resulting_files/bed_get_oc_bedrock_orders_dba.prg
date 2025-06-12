CREATE PROGRAM bed_get_oc_bedrock_orders:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 catalog_code_value = f8
     2 primary_mnemonic = vc
     2 description = vc
     2 catalog_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 activity_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 activity_subtype
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 clinical_category
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 procedure_type
       3 code_value = f8
       3 display = vc
       3 mean = vc
     2 dept_name = vc
     2 order_entry_format
       3 id = f8
       3 name = vc
     2 concept_cki = vc
     2 cki = vc
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
 SET wcard = "*"
 DECLARE ord_parse = vc
 DECLARE search_string = vc
 IF (trim(request->search_string) > " ")
  IF ((request->search_type_string="S"))
   SET search_string = concat(trim(cnvtupper(request->search_string)),wcard)
  ELSE
   SET search_string = concat(wcard,trim(cnvtupper(request->search_string)),wcard)
  ENDIF
  SET ord_parse = concat("cnvtupper(b.primary_mnemonic) = '",search_string,"'")
 ELSE
  SET search_string = wcard
  SET ord_parse = concat("cnvtupper(b.primary_mnemonic) = '",search_string,"'")
 ENDIF
 CASE (request->content_ind)
  OF 1:
   SET ord_parse = concat(trim(ord_parse)," and b.patient_care_ind = 1")
  OF 2:
   SET ord_parse = concat(trim(ord_parse)," and b.laboratory_ind = 1")
  OF 3:
   SET ord_parse = concat(trim(ord_parse)," and b.radiology_ind = 1")
  OF 4:
   SET ord_parse = concat(trim(ord_parse)," and b.surgery_ind = 1")
  OF 5:
   SET ord_parse = concat(trim(ord_parse)," and b.cardiology_ind = 1")
  ELSE
   SET ord_parse = concat(trim(ord_parse)," and b.catalog_cd > 0")
 ENDCASE
 RECORD ord(
   1 qual[*]
     2 cd = f8
     2 mnemonic = vc
     2 desc = vc
     2 concept_cki = vc
     2 cki = vc
     2 cat_type_cd = f8
     2 act_type_cd = f8
     2 act_subtype_cd = f8
     2 clin_cat_cd = f8
     2 proc_cd = f8
     2 dept = vc
     2 format_id = f8
     2 match_ind = i2
 )
 CALL echo(ord_parse)
 SELECT INTO "nl:"
  FROM br_auto_order_catalog b
  PLAN (b
   WHERE parser(ord_parse))
  ORDER BY b.primary_mnemonic
  HEAD b.primary_mnemonic
   cnt = (cnt+ 1), stat = alterlist(ord->qual,cnt), ord->qual[cnt].cd = b.catalog_cd,
   ord->qual[cnt].mnemonic = b.primary_mnemonic, ord->qual[cnt].desc = b.description, ord->qual[cnt].
   concept_cki = b.concept_cki,
   ord->qual[cnt].cki = b.cki, ord->qual[cnt].cat_type_cd = b.catalog_type_cd, ord->qual[cnt].
   act_type_cd = b.activity_type_cd,
   ord->qual[cnt].act_subtype_cd = b.activity_subtype_cd, ord->qual[cnt].clin_cat_cd = b
   .dcp_clin_cat_cd, ord->qual[cnt].proc_cd = b.bb_processing_cd,
   ord->qual[cnt].dept = b.dept_name, ord->qual[cnt].format_id = b.oe_format_id, ord->qual[cnt].
   match_ind = 0
  WITH nocounter, skipbedrock = 1
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog o
  PLAN (d)
   JOIN (o
   WHERE ((cnvtupper(o.primary_mnemonic)=cnvtupper(ord->qual[d.seq].mnemonic)) OR ((o.concept_cki=ord
   ->qual[d.seq].concept_cki))) )
  ORDER BY d.seq
  HEAD d.seq
   ord->qual[d.seq].match_ind = 1
  WITH nocounter
 ;end select
 SET rcnt = 0
 FOR (x = 1 TO cnt)
   IF ((ord->qual[x].match_ind=0))
    SET rcnt = (rcnt+ 1)
    SET stat = alterlist(reply->orderables,rcnt)
    SET reply->orderables[rcnt].catalog_code_value = ord->qual[x].cd
    SET reply->orderables[rcnt].primary_mnemonic = ord->qual[x].mnemonic
    SET reply->orderables[rcnt].description = ord->qual[x].desc
    SET reply->orderables[rcnt].catalog_type.code_value = ord->qual[x].cat_type_cd
    SET reply->orderables[rcnt].activity_type.code_value = ord->qual[x].act_type_cd
    SET reply->orderables[rcnt].activity_subtype.code_value = ord->qual[x].act_subtype_cd
    SET reply->orderables[rcnt].clinical_category.code_value = ord->qual[x].clin_cat_cd
    SET reply->orderables[rcnt].procedure_type.code_value = ord->qual[x].proc_cd
    SET reply->orderables[rcnt].dept_name = ord->qual[x].dept
    SET reply->orderables[rcnt].order_entry_format.id = ord->qual[x].format_id
    SET reply->orderables[rcnt].concept_cki = ord->qual[x].concept_cki
    SET reply->orderables[rcnt].cki = ord->qual[x].cki
   ENDIF
 ENDFOR
 IF (rcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=reply->orderables[d.seq].catalog_type.code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->orderables[d.seq].catalog_type.mean = c.cdf_meaning, reply->orderables[d.seq].catalog_type.
   display = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=reply->orderables[d.seq].activity_type.code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->orderables[d.seq].activity_type.mean = c.cdf_meaning, reply->orderables[d.seq].
   activity_type.display = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=reply->orderables[d.seq].activity_subtype.code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->orderables[d.seq].activity_subtype.mean = c.cdf_meaning, reply->orderables[d.seq].
   activity_subtype.display = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=reply->orderables[d.seq].clinical_category.code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->orderables[d.seq].clinical_category.mean = c.cdf_meaning, reply->orderables[d.seq].
   clinical_category.display = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   code_value c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=reply->orderables[d.seq].procedure_type.code_value))
  ORDER BY d.seq
  HEAD d.seq
   reply->orderables[d.seq].procedure_type.mean = c.cdf_meaning, reply->orderables[d.seq].
   procedure_type.display = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(rcnt)),
   order_entry_format o
  PLAN (d)
   JOIN (o
   WHERE (o.oe_format_id=reply->orderables[d.seq].order_entry_format.id))
  ORDER BY d.seq
  HEAD d.seq
   reply->orderables[d.seq].order_entry_format.name = o.oe_format_name
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
