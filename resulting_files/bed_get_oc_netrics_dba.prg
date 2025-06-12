CREATE PROGRAM bed_get_oc_netrics:dba
 FREE SET reply
 RECORD reply(
   1 oclist[*]
     2 catalog_code_value = f8
     2 primary = vc
     2 ancillary = vc
     2 dcp = vc
     2 desc = vc
     2 other_list[*]
       3 name = vc
     2 already_matched_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET temp_oc
 RECORD temp_oc(
   1 oclist[*]
     2 catalog_code_value = f8
     2 primary = vc
     2 ancillary = vc
     2 dcp = vc
     2 desc = vc
     2 concept_cki = vc
     2 synonyms[*]
       3 mnemonic = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET tot_count = 0
 SET ocnt = 0
 SET tot_ocount = 0
 SET already_matched = 0
 SET dcp_code_value = 0.0
 SET ancillary_code_value = 0.0
 SET primary_code_value = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=6011
   AND cv.active_ind=1
   AND cv.cdf_meaning IN ("DCP", "ANCILLARY", "PRIMARY")
  DETAIL
   CASE (cv.cdf_meaning)
    OF "DCP":
     dcp_code_value = cv.code_value
    OF "ANCILLARY":
     ancillary_code_value = cv.code_value
    OF "PRIMARY":
     primary_code_value = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SET surg_cat_ind = 0
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE (cv.code_value=request->catalog_type_code_value)
  DETAIL
   IF (cv.cdf_meaning="SURGERY")
    surg_cat_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET cnt = 0
 SET tot_count = 0
 SET stat = alterlist(temp_oc->oclist,300)
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE (oc.catalog_type_cd=request->catalog_type_code_value)
    AND (oc.activity_type_cd=request->activity_type_code_value)
    AND oc.active_ind=1
    AND oc.primary_mnemonic != "zz*"
    AND oc.orderable_type_flag != 6
    AND oc.orderable_type_flag != 2)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.active_ind=1
    AND ocs.mnemonic_type_cd IN (primary_code_value, ancillary_code_value, dcp_code_value))
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), tot_count = (tot_count+ 1)
   IF (cnt > 300)
    stat = alterlist(temp_oc->oclist,(tot_count+ 300)), cnt = 1
   ENDIF
   temp_oc->oclist[tot_count].catalog_code_value = ocs.catalog_cd, temp_oc->oclist[tot_count].desc =
   oc.description, temp_oc->oclist[tot_count].concept_cki = oc.concept_cki,
   scnt = 0
  DETAIL
   CASE (ocs.mnemonic_type_cd)
    OF primary_code_value:
     temp_oc->oclist[tot_count].primary = ocs.mnemonic
    OF dcp_code_value:
     scnt = (scnt+ 1),stat = alterlist(temp_oc->oclist[tot_count].synonyms,scnt),temp_oc->oclist[
     tot_count].synonyms[scnt].mnemonic = ocs.mnemonic
    OF ancillary_code_value:
     scnt = (scnt+ 1),stat = alterlist(temp_oc->oclist[tot_count].synonyms,scnt),temp_oc->oclist[
     tot_count].synonyms[scnt].mnemonic = ocs.mnemonic
   ENDCASE
  WITH nocounter
 ;end select
 SET tot_start_count = tot_count
 DECLARE auto_parse = vc
 IF (surg_cat_ind=1)
  SET auto_parse = "oc.surgery_ind = 1"
 ELSE
  SET auto_parse = concat("oc.catalog_type_cd = request->catalog_type_code_value ",
   " and oc.activity_type_cd = request->activity_type_code_value")
 ENDIF
 SELECT INTO "nl:"
  FROM br_auto_order_catalog oc,
   br_auto_oc_synonym ocs
  PLAN (oc
   WHERE parser(auto_parse))
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd IN (primary_code_value, ancillary_code_value, dcp_code_value))
  HEAD oc.catalog_cd
   found = 0
   FOR (i = 1 TO tot_start_count)
     IF ((((temp_oc->oclist[i].concept_cki=oc.concept_cki)) OR (cnvtupper(temp_oc->oclist[i].primary)
     =cnvtupper(oc.primary_mnemonic))) )
      found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    cnt = (cnt+ 1), tot_count = (tot_count+ 1)
    IF (cnt > 300)
     stat = alterlist(temp_oc->oclist,(tot_count+ 300)), cnt = 1
    ENDIF
    temp_oc->oclist[tot_count].catalog_code_value = ocs.catalog_cd, temp_oc->oclist[tot_count].desc
     = oc.description, temp_oc->oclist[tot_count].concept_cki = oc.concept_cki,
    scnt = 0
   ENDIF
  DETAIL
   IF (found=0)
    CASE (ocs.mnemonic_type_cd)
     OF primary_code_value:
      temp_oc->oclist[tot_count].primary = ocs.mnemonic
     OF dcp_code_value:
      scnt = (scnt+ 1),stat = alterlist(temp_oc->oclist[tot_count].synonyms,scnt),temp_oc->oclist[
      tot_count].synonyms[scnt].mnemonic = ocs.mnemonic
     OF ancillary_code_value:
      scnt = (scnt+ 1),stat = alterlist(temp_oc->oclist[tot_count].synonyms,scnt),temp_oc->oclist[
      tot_count].synonyms[scnt].mnemonic = ocs.mnemonic
    ENDCASE
   ENDIF
  WITH nocounter, skipbedrock = 1
 ;end select
 SET stat = alterlist(temp_oc->oclist,tot_count)
 SET stat = alterlist(reply->oclist,tot_count)
 IF (tot_count > 0)
  FOR (x = 1 TO tot_count)
    SET reply->oclist[x].catalog_code_value = temp_oc->oclist[x].catalog_code_value
    SET reply->oclist[x].primary = temp_oc->oclist[x].primary
    SET reply->oclist[x].desc = temp_oc->oclist[x].desc
    SET reply->oclist[x].already_matched_ind = 0
    SET syn_cnt = size(temp_oc->oclist[x].synonyms,5)
    IF (syn_cnt > 0)
     SET stat = alterlist(reply->oclist[x].other_list,syn_cnt)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(syn_cnt))
      ORDER BY d.seq
      DETAIL
       reply->oclist[x].other_list[d.seq].name = temp_oc->oclist[x].synonyms[d.seq].mnemonic
      WITH nocounter
     ;end select
    ENDIF
  ENDFOR
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tot_count),
    br_other_names bon
   PLAN (d)
    JOIN (bon
    WHERE (bon.parent_entity_id=reply->oclist[d.seq].catalog_code_value)
     AND bon.parent_entity_name="CODE_VALUE")
   HEAD d.seq
    ocnt = 0, tot_ocount = size(reply->oclist[d.seq].other_list,5), stat = alterlist(reply->oclist[d
     .seq].other_list,(tot_ocount+ 5))
   DETAIL
    ocnt = (ocnt+ 1), tot_ocount = (tot_ocount+ 1)
    IF (ocnt > 5)
     stat = alterlist(reply->oclist[d.seq].other_list,(tot_ocount+ 5)), ocnt = 1
    ENDIF
    reply->oclist[d.seq].other_list[tot_ocount].name = bon.alias_name
   FOOT  d.seq
    stat = alterlist(reply->oclist[d.seq].other_list,tot_ocount)
   WITH nocounter
  ;end select
  SELECT INTO "nl"
   FROM br_oc_work b,
    (dummyt d  WITH seq = tot_count)
   PLAN (d)
    JOIN (b
    WHERE (b.match_orderable_cd=reply->oclist[d.seq].catalog_code_value))
   HEAD d.seq
    reply->oclist[d.seq].already_matched_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 IF (tot_count=0)
  SET reply->status_data.status = "Z"
 ELSEIF (tot_count > 0)
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
