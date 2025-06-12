CREATE PROGRAM cps_get_orderables_by_syn_id:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 FREE SET reply
 RECORD reply(
   1 synonym_knt = i4
   1 synonym[*]
     2 synonym_id = f8
     2 order_sentence_id = f8
     2 catalog_cd = f8
     2 oe_format_id = f8
     2 activity_type_cd = f8
     2 activity_subtype_cd = f8
     2 catalog_type_cd = f8
     2 mnemonic = vc
     2 primary_mnemonic = vc
     2 mnemonic_key_cap = vc
     2 mnemonic_type_cd = f8
     2 ref_text_mask = i4
     2 prep_info_flag = i2
     2 cki = vc
     2 synonym_cki = vc
     2 dup_checking_ind = i2
     2 orderable_type_flag = i2
     2 comment_template_flag = i2
     2 rx_mask = i4
     2 dcp_clin_cat_cd = f8
     2 multiple_ord_sent_ind = i2
     2 virtual_view = vc
     2 health_plan_view = vc
     2 disable_order_comment_ind = i2
     2 event_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
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
 SET ierrcode = 0
 SELECT
  IF (ifacilityind=1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (ocs
    WHERE (ocs.synonym_id=request->qual[d.seq].synonym_id)
     AND ocs.active_ind=1
     AND  EXISTS (
    (SELECT
     ofr.synonym_id
     FROM ocs_facility_r ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->facility_cd))) )))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
    JOIN (cve
    WHERE cve.parent_cd=outerjoin(oc.catalog_cd)
     AND cve.flex1_cd=outerjoin(0.0)
     AND cve.flex2_cd=outerjoin(0.0)
     AND cve.flex3_cd=outerjoin(0.0)
     AND cve.flex4_cd=outerjoin(0.0)
     AND cve.flex5_cd=outerjoin(0.0))
  ELSE
   PLAN (d
    WHERE d.seq > 0)
    JOIN (ocs
    WHERE (ocs.synonym_id=request->qual[d.seq].synonym_id)
     AND ocs.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
    JOIN (cve
    WHERE cve.parent_cd=outerjoin(oc.catalog_cd)
     AND cve.flex1_cd=outerjoin(0.0)
     AND cve.flex2_cd=outerjoin(0.0)
     AND cve.flex3_cd=outerjoin(0.0)
     AND cve.flex4_cd=outerjoin(0.0)
     AND cve.flex5_cd=outerjoin(0.0))
  ENDIF
  INTO "nl:"
  FROM (dummyt d  WITH seq = value(request->qual_knt)),
   order_catalog_synonym ocs,
   order_catalog oc,
   code_value_event_r cve
  HEAD REPORT
   knt = 0, stat = alterlist(reply->synonym,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(reply->synonym,(knt+ 9))
   ENDIF
   reply->synonym[knt].synonym_id = ocs.synonym_id, reply->synonym[knt].order_sentence_id = ocs
   .order_sentence_id, reply->synonym[knt].catalog_cd = ocs.catalog_cd,
   reply->synonym[knt].oe_format_id = ocs.oe_format_id, reply->synonym[knt].activity_type_cd = ocs
   .activity_type_cd, reply->synonym[knt].activity_subtype_cd = ocs.activity_subtype_cd,
   reply->synonym[knt].catalog_type_cd = ocs.catalog_type_cd, reply->synonym[knt].mnemonic = ocs
   .mnemonic, reply->synonym[knt].primary_mnemonic = oc.description,
   reply->synonym[knt].mnemonic_key_cap = ocs.mnemonic_key_cap, reply->synonym[knt].mnemonic_type_cd
    = ocs.mnemonic_type_cd, reply->synonym[knt].ref_text_mask = oc.ref_text_mask,
   reply->synonym[knt].prep_info_flag = oc.prep_info_flag, reply->synonym[knt].cki = oc.cki, reply->
   synonym[knt].synonym_cki = ocs.cki,
   reply->synonym[knt].dup_checking_ind = oc.dup_checking_ind, reply->synonym[knt].
   orderable_type_flag = ocs.orderable_type_flag, reply->synonym[knt].comment_template_flag = oc
   .comment_template_flag,
   reply->synonym[knt].disable_order_comment_ind = oc.disable_order_comment_ind, reply->synonym[knt].
   rx_mask = ocs.rx_mask, reply->synonym[knt].dcp_clin_cat_cd = ocs.dcp_clin_cat_cd,
   reply->synonym[knt].multiple_ord_sent_ind = ocs.multiple_ord_sent_ind, reply->synonym[knt].
   virtual_view = ocs.virtual_view, reply->synonym[knt].health_plan_view = ocs.health_plan_view,
   reply->synonym[knt].event_cd = cve.event_cd
  FOOT REPORT
   reply->synonym_knt = knt, stat = alterlist(reply->synonym,knt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_CATALOG_SYNONYM"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET failed = true
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed=false)
  IF ((reply->synonym_knt > 0))
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ENDIF
 SET script_version = "004 10/04/04 mh2659"
END GO
