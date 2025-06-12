CREATE PROGRAM ct_get_rule_detail:dba
 RECORD reply(
   1 ct_rule_qual = i4
   1 qual[*]
     2 ct_rule_id = i4
     2 ct_rule_detail_id = i4
     2 description = vc
     2 action_cd_display = c40
     2 operator_cd = f8
     2 operator_disp = c40
     2 operator_mean = c20
     2 operator_desc = c40
     2 cpt4_cd = vc
     2 rule_entity_id = i4
     2 rule_entity_name = vc
     2 precedence = i4
     2 sequence = i4
     2 rule_display = vc
     2 duration_display = c40
     2 vocab_display = c40
     2 operator_cd = f8
     2 operator_disp = c40
     2 operator_mean = c20
     2 operator_desc = c40
     2 detail_type_cd = f8
     2 detail_type_disp = c40
     2 detail_type_mean = c20
     2 detail_type_desc = c40
     2 detail_name = vc
     2 count_beg = i4
     2 count_end = i4
     2 result_factor = f8
     2 bill_item_name = vc
     2 action_name = f8
     2 action_cd = f8
     2 action_type = vc
     2 source_string = vc
     2 bill_item_id = i4
     2 rule_entity_name = vc
     2 source_string_result = vc
   1 status_data = c1
     2 status = c15
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD cv(
   1 precursor = f8
   1 result = f8
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 SELECT INTO "nl:"
  cv.*
  FROM code_value cv
  WHERE cv.code_set=15729
  DETAIL
   IF (cv.cdf_meaning="PRECURSOR")
    cv->precursor = cv.code_value
   ELSEIF (cv.cdf_meaning="RESULT")
    cv->result = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET count1 = 0
 SELECT
  rd.*, cv.*, r.*
  FROM ct_rule_detail rd,
   code_value cv,
   ct_rule r
  WHERE (rd.ct_rule_id=request->ct_rule_id)
   AND rd.active_ind=1
   AND cv.code_value=rd.detail_type_cd
   AND r.ct_rule_id=rd.ct_rule_id
  ORDER BY rd.detail_type_cd
  DETAIL
   count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].ct_rule_id = rd.ct_rule_id,
   reply->qual[count1].ct_rule_detail_id = rd.ct_rule_detail_id, reply->qual[count1].operator_cd = rd
   .operator_cd, reply->qual[count1].rule_entity_id = rd.rule_entity_id,
   reply->qual[count1].rule_entity_name = rd.rule_entity_name, reply->qual[count1].precedence = rd
   .precedence, reply->qual[count1].sequence = rd.sequence,
   reply->qual[count1].count_beg = rd.count_beg, reply->qual[count1].count_end = rd.count_end, reply
   ->qual[count1].result_factor = rd.result_factor,
   reply->qual[count1].detail_type_cd = rd.detail_type_cd, reply->qual[count1].detail_name = cv
   .display, reply->qual[count1].action_cd = r.action_cd,
   reply->qual[count1].rule_entity_name = rd.rule_entity_name
  WITH nocounter
 ;end select
 IF (count1 > 0)
  SELECT INTO "nl:"
   c.cdf_meaning
   FROM code_value c,
    (dummyt d1  WITH seq = value(size(reply->qual,5)))
   PLAN (d1)
    JOIN (c
    WHERE (reply->qual[d1.seq].action_cd=c.code_value))
   DETAIL
    reply->qual[d1.seq].action_type = c.display
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   n.source_identifier
   FROM nomenclature n,
    (dummyt d1  WITH seq = value(size(reply->qual,5)))
   PLAN (d1
    WHERE (reply->qual[d1.seq].detail_name="PRECURSOR"))
    JOIN (n
    WHERE (n.nomenclature_id=reply->qual[d1.seq].rule_entity_id)
     AND n.active_ind=1)
   DETAIL
    reply->qual[d1.seq].source_string = n.source_string
   WITH nocounter
  ;end select
  CALL echo(build("Action_Type is  ",reply->qual.action_type))
  IF ((reply->qual.action_type="REPLACELIST"))
   CALL echo(build("Replacelist",reply->qual.action_type))
   SELECT INTO "nl:"
    n.source_identifier
    FROM nomenclature n,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1
     WHERE (reply->qual[d1.seq].detail_name="PRECURSOR"))
     JOIN (n
     WHERE (n.nomenclature_id=reply->qual[d1.seq].rule_entity_id)
      AND n.active_ind=1)
    DETAIL
     reply->qual[d1.seq].cpt4_cd = n.source_identifier
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    b.ext_short_desc
    FROM bill_item b,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1
     WHERE (reply->qual[d1.seq].detail_name="RESULT"))
     JOIN (b
     WHERE (b.bill_item_id=reply->qual[d1.seq].rule_entity_id))
    DETAIL
     reply->qual[d1.seq].bill_item_name = b.ext_short_desc
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    b.ext_short_desc
    FROM bill_item b,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1
     WHERE (reply->qual[d1.seq].detail_name="RESULT"))
     JOIN (b
     WHERE (b.bill_item_id=reply->qual[d1.seq].rule_entity_id))
    DETAIL
     reply->qual[d1.seq].bill_item_id = b.bill_item_id
    WITH nocounter
   ;end select
  ELSEIF ((((reply->qual.action_type="MODIFYLIST")) OR ((((reply->qual.action_type="REPLACEPRICE"))
   OR ((reply->qual.action_type="REPLACEADJUST"))) )) )
   CALL echo(build("Rule Type is   ",reply->qual.action_type))
   CALL echo(build("detail name  ",reply->qual.detail_name))
   CALL echo(build("rule entity id ",reply->qual.rule_entity_id))
   SELECT INTO "nl:"
    n.source_identifier
    FROM nomenclature n,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1
     WHERE (reply->qual[d1.seq].detail_name="RESULT"))
     JOIN (n
     WHERE (n.nomenclature_id=reply->qual[d1.seq].rule_entity_id)
      AND n.active_ind=1)
    DETAIL
     reply->qual[d1.seq].source_string_result = n.source_string
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    n.source_identifier
    FROM nomenclature n,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1)
     JOIN (n
     WHERE (n.nomenclature_id=reply->qual[d1.seq].rule_entity_id))
    DETAIL
     reply->qual[d1.seq].cpt4_cd = n.source_identifier
    WITH nocounter
   ;end select
  ELSEIF ((reply->qual.action_type="COUNT"))
   CALL echo(build("action_type   ",reply->qual.action_type))
   CALL echo(build("detail_name   ",reply->qual.detail_name))
   SELECT INTO "nl:"
    n.source_identifier
    FROM nomenclature n,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1
     WHERE (reply->qual[d1.seq].rule_entity_name="NOMENCLATURE"))
     JOIN (n
     WHERE (n.nomenclature_id=reply->qual[d1.seq].rule_entity_id))
    DETAIL
     reply->qual[d1.seq].cpt4_cd = n.source_identifier
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    b.ext_short_desc
    FROM bill_item b,
     (dummyt d1  WITH seq = value(size(reply->qual,5)))
    PLAN (d1
     WHERE (reply->qual[d1.seq].rule_entity_name="BILL_ITEM"))
     JOIN (b
     WHERE (b.bill_item_id=reply->qual[d1.seq].rule_entity_id))
    DETAIL
     reply->qual[d1.seq].bill_item_name = b.ext_short_desc
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->ct_rule_qual = count1
 IF (curqual=0
  AND count1=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CT_RULE_DETAIL"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
