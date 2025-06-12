CREATE PROGRAM cps_get_cs_component:dba
 RECORD reply(
   1 catalog_cd = f8
   1 description = vc
   1 oe_format_id = f8
   1 dcp_clin_cat_cd = f8
   1 modifiable_flag = i2
   1 cs_comp_cnt = i4
   1 cs_comp_qual[5]
     2 comp_seq = i4
     2 comp_type_cd = f8
     2 comp_id = f8
     2 comp_label = vc
     2 comment_text = vc
     2 required_ind = i2
     2 include_exclude_ind = i2
     2 orderable_ind = i2
     2 catalog_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
     2 primary_mnemonic = vc
     2 order_sentence_id = f8
     2 oe_format_id = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 orderable_type_flag = i2
     2 mnemonic_type_cd = f8
     2 order_display = vc
     2 ord_com_template_long_text_id = f8
     2 linked_date_comp_seq = i4
     2 comp_mask = i4
     2 rx_mask = i4
     2 dcp_clin_cat_cd = f8
     2 ref_text_mask = i4
     2 prep_info_flag = i2
     2 cki = vc
     2 disable_order_comment_ind = i2
     2 synonym_cki = vc
     2 requisition_format_cd = f8
     2 requisition_object_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET count1 = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cstype_cd = 0.0
 SET code_set = 6030
 SET cdf_meaning = "ORDERABLE"
 EXECUTE cpm_get_cd_for_cdf
 SET cstype_cd = code_value
 SET count1 = 0
 DECLARE ifacilitytableexists = i2 WITH protect, noconstant(0)
 DECLARE ifacilityind = i2 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM dba_tables dt
  WHERE dt.table_name="OCS_FACILITY_R"
  DETAIL
   ifacilitytableexists = 1
  WITH nocounter
 ;end select
 IF ((request->facility_cd > 0)
  AND ifacilitytableexists=1)
  SET ifacilityind = 1
 ENDIF
 SELECT
  IF (ifacilityind=1)
   PLAN (c
    WHERE (c.catalog_cd=request->catalog_cd))
    JOIN (cc
    WHERE cc.catalog_cd=c.catalog_cd
     AND ((cc.comp_type_cd=cstype_cd
     AND  EXISTS (
    (SELECT
     ofr.synonym_id
     FROM ocs_facility_r ofr
     WHERE ofr.synonym_id=cc.comp_id
      AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_cd))) ))) OR (cc.comp_type_cd
     != cstype_cd)) )
    JOIN (d1)
    JOIN (((lt
    WHERE cc.long_text_id > 0
     AND lt.long_text_id=cc.long_text_id
     AND lt.active_ind=1)
    ) ORJOIN ((ocs
    WHERE cc.comp_type_cd=cstype_cd
     AND ocs.synonym_id=cc.comp_id)
    JOIN (c2
    WHERE ocs.catalog_cd=c2.catalog_cd)
    JOIN (d2)
    JOIN (os
    WHERE cc.order_sentence_id > 0
     AND os.order_sentence_id=cc.order_sentence_id)
    ))
  ELSE
   PLAN (c
    WHERE (c.catalog_cd=request->catalog_cd))
    JOIN (cc
    WHERE cc.catalog_cd=c.catalog_cd)
    JOIN (d1)
    JOIN (((lt
    WHERE cc.long_text_id > 0
     AND lt.long_text_id=cc.long_text_id
     AND lt.active_ind=1)
    ) ORJOIN ((ocs
    WHERE cc.comp_type_cd=cstype_cd
     AND ocs.synonym_id=cc.comp_id)
    JOIN (c2
    WHERE ocs.catalog_cd=c2.catalog_cd)
    JOIN (d2)
    JOIN (os
    WHERE cc.order_sentence_id > 0
     AND os.order_sentence_id=cc.order_sentence_id)
    ))
  ENDIF
  INTO "nl:"
  c.catalog_cd, cc.catalog_cd, lt.long_text_id,
  ocs.synonym_id, os.order_sentence_id
  FROM order_catalog c,
   order_catalog c2,
   cs_component cc,
   order_catalog_synonym ocs,
   long_text lt,
   order_sentence os,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  HEAD REPORT
   reply->catalog_cd = cc.catalog_cd, reply->description = c.description, reply->oe_format_id = c
   .oe_format_id,
   reply->dcp_clin_cat_cd = c.dcp_clin_cat_cd, reply->modifiable_flag = c.modifiable_flag
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->cs_comp_qual,5))
    stat = alter(reply->cs_comp_qual,(count1+ 10))
   ENDIF
   reply->cs_comp_qual[count1].comp_seq = count1, reply->cs_comp_qual[count1].comp_type_cd = cc
   .comp_type_cd, reply->cs_comp_qual[count1].comp_id = cc.comp_id
   IF (cc.long_text_id > 0)
    reply->cs_comp_qual[count1].comment_text = lt.long_text
   ENDIF
   reply->cs_comp_qual[count1].comp_label = cc.comp_label, reply->cs_comp_qual[count1].required_ind
    = cc.required_ind, reply->cs_comp_qual[count1].include_exclude_ind = cc.include_exclude_ind
   IF (cc.comp_type_cd=cstype_cd)
    reply->cs_comp_qual[count1].orderable_ind = 1, reply->cs_comp_qual[count1].catalog_cd = ocs
    .catalog_cd, reply->cs_comp_qual[count1].synonym_id = ocs.synonym_id,
    reply->cs_comp_qual[count1].mnemonic = ocs.mnemonic, reply->cs_comp_qual[count1].
    order_sentence_id = cc.order_sentence_id, reply->cs_comp_qual[count1].oe_format_id = ocs
    .oe_format_id,
    reply->cs_comp_qual[count1].catalog_type_cd = ocs.catalog_type_cd, reply->cs_comp_qual[count1].
    activity_type_cd = ocs.activity_type_cd, reply->cs_comp_qual[count1].activity_subtype_cd = ocs
    .activity_subtype_cd,
    reply->cs_comp_qual[count1].orderable_type_flag = ocs.orderable_type_flag, reply->cs_comp_qual[
    count1].mnemonic_type_cd = ocs.mnemonic_type_cd, reply->cs_comp_qual[count1].rx_mask = ocs
    .rx_mask,
    reply->cs_comp_qual[count1].dcp_clin_cat_cd = ocs.dcp_clin_cat_cd, reply->cs_comp_qual[count1].
    ord_com_template_long_text_id = cc.ord_com_template_long_text_id, reply->cs_comp_qual[count1].
    ref_text_mask = ocs.ref_text_mask,
    reply->cs_comp_qual[count1].primary_mnemonic = c2.primary_mnemonic, reply->cs_comp_qual[count1].
    prep_info_flag = c2.prep_info_flag, reply->cs_comp_qual[count1].cki = c2.cki,
    reply->cs_comp_qual[count1].disable_order_comment_ind = c2.disable_order_comment_ind, reply->
    cs_comp_qual[count1].synonym_cki = ocs.cki, reply->cs_comp_qual[count1].requisition_format_cd =
    c2.requisition_format_cd,
    reply->cs_comp_qual[count1].requisition_object_name = uar_get_code_meaning(c2
     .requisition_format_cd)
   ELSE
    reply->cs_comp_qual[count1].orderable_ind = 0
   ENDIF
   IF (((cc.order_sentence_id > 0) OR (ocs.order_sentence_id > 0)) )
    reply->cs_comp_qual[count1].order_display = os.order_sentence_display_line
   ENDIF
   reply->cs_comp_qual[count1].linked_date_comp_seq = cc.linked_date_comp_seq, reply->cs_comp_qual[
   count1].comp_mask = cc.comp_mask
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->cs_comp_cnt = 0
 ELSE
  SET reply->status_data.status = "S"
  SET stat = alter(reply->cs_comp_qual,count1)
  SET reply->cs_comp_cnt = count1
 ENDIF
 SET script_version = "013 12/03/04 BP9613"
END GO
