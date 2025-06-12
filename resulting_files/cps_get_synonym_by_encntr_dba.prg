CREATE PROGRAM cps_get_synonym_by_encntr:dba
 RECORD reply(
   1 qual[*]
     2 source_synonym_id = f8
     2 syn_cnt = i4
     2 direct_cnvt_ind = i2
     2 tclass_desc = vc
     2 syn_qual[*]
       3 synonym_id = f8
       3 mnemonic = vc
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 activity_type_cd = f8
       3 dnum_cki = vc
       3 cnum_cki = vc
       3 tclass_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE lsize = i4 WITH protect, noconstant(0)
 DECLARE errcode = i2 WITH protect, noconstant(0)
 DECLARE cfacility = f8 WITH protect, noconstant(0.0)
 DECLARE cprimary = f8 WITH protect, noconstant(0.0)
 DECLARE cbrandname = f8 WITH protect, noconstant(0.0)
 DECLARE cdispdrug_c = f8 WITH protect, noconstant(0.0)
 DECLARE cgenerictop_m = f8 WITH protect, noconstant(0.0)
 DECLARE ctradetop_n = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",1,cprimary)
 SET stat = uar_get_meaning_by_codeset(6011,"BRANDNAME",1,cbrandname)
 SET stat = uar_get_meaning_by_codeset(6011,"DISPDRUG",1,cdispdrug_c)
 SET stat = uar_get_meaning_by_codeset(6011,"GENERICTOP",1,cgenerictop_m)
 SET stat = uar_get_meaning_by_codeset(6011,"TRADETOP",1,ctradetop_n)
 SELECT INTO "nl:"
  e.loc_facility_cd
  FROM (dummyt d  WITH seq = value(size(request->qual,5))),
   encounter e
  PLAN (d)
   JOIN (e
   WHERE (e.encntr_id=request->encntr_id))
  DETAIL
   request->qual[d.seq].facility_cd = e.loc_facility_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ENCOUNTER"
  GO TO exit_script
 ENDIF
 SET lsize = value(size(request->qual,5))
 SET stat = alterlist(reply->qual,lsize)
 FOR (x = 1 TO lsize)
   SET reply->qual[x].source_synonym_id = request->qual[x].synonym_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = lsize),
   order_catalog_synonym ocs,
   order_catalog oc,
   mltm_combination_drug mcd
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ocs
   WHERE (ocs.synonym_id=request->qual[d.seq].synonym_id))
   JOIN (oc
   WHERE oc.catalog_cd=ocs.catalog_cd)
   JOIN (mcd
   WHERE findstring("MUL.ORD!",oc.cki) > 0
    AND substring(9,6,oc.cki)=mcd.drug_identifier)
  DETAIL
   request->qual[d.seq].multi_ingred_ind = 1
  WITH nocounter
 ;end select
 IF ((request->auto_verify_ind=0))
  SELECT INTO "nl:"
   *
   FROM (dummyt d  WITH seq = lsize),
    order_catalog oc,
    order_catalog_synonym ocs
   PLAN (d)
    JOIN (ocs
    WHERE (request->qual[d.seq].multi_ingred_ind=0)
     AND (ocs.synonym_id=request->qual[d.seq].synonym_id)
     AND ocs.mnemonic_type_cd IN (cprimary, cbrandname, cdispdrug_c, cgenerictop_m, ctradetop_n)
     AND ocs.active_ind=1
     AND ocs.hide_flag=0
     AND  EXISTS (
    (SELECT
     ofr.synonym_id
     FROM ocs_facility_r ofr
     WHERE ofr.synonym_id=ocs.synonym_id
      AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->qual[d.seq].facility_cd))) )))
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd)
   DETAIL
    reply->qual[d.seq].direct_cnvt_ind = 1, stat = alterlist(reply->qual[d.seq].syn_qual,1), reply->
    qual[d.seq].syn_qual[1].synonym_id = ocs.synonym_id,
    reply->qual[d.seq].syn_qual[1].mnemonic = ocs.mnemonic, reply->qual[d.seq].syn_qual[1].catalog_cd
     = ocs.catalog_cd, reply->qual[d.seq].syn_qual[1].catalog_type_cd = ocs.catalog_type_cd,
    reply->qual[d.seq].syn_qual[1].activity_type_cd = ocs.activity_type_cd, reply->qual[d.seq].
    syn_qual[1].cnum_cki = ocs.cki, reply->qual[d.seq].syn_qual[1].dnum_cki = oc.cki
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  ocs2.*
  FROM (dummyt d  WITH seq = lsize),
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   order_catalog oc
  PLAN (d
   WHERE (reply->qual[d.seq].direct_cnvt_ind=0))
   JOIN (ocs
   WHERE (ocs.synonym_id=request->qual[d.seq].synonym_id))
   JOIN (ocs2
   WHERE ocs2.catalog_cd=ocs.catalog_cd
    AND ocs2.mnemonic_type_cd IN (cprimary, cbrandname, cdispdrug_c, cgenerictop_m, ctradetop_n)
    AND ocs2.active_ind=1
    AND ocs2.hide_flag=0
    AND  EXISTS (
   (SELECT
    ofr.synonym_id
    FROM ocs_facility_r ofr
    WHERE ofr.synonym_id=ocs2.synonym_id
     AND ((ofr.facility_cd=0) OR ((ofr.facility_cd=request->qual[d.seq].facility_cd))) )))
   JOIN (oc
   WHERE oc.catalog_cd=ocs2.catalog_cd)
  ORDER BY ocs2.mnemonic_key_cap
  DETAIL
   lsyncnt = (reply->qual[d.seq].syn_cnt+ 1), reply->qual[d.seq].syn_cnt = lsyncnt, stat = alterlist(
    reply->qual[d.seq].syn_qual,lsyncnt),
   reply->qual[d.seq].syn_qual[lsyncnt].synonym_id = ocs2.synonym_id, reply->qual[d.seq].syn_qual[
   lsyncnt].mnemonic = ocs2.mnemonic, reply->qual[d.seq].syn_qual[lsyncnt].catalog_cd = ocs2
   .catalog_cd,
   reply->qual[d.seq].syn_qual[lsyncnt].catalog_type_cd = ocs.catalog_type_cd, reply->qual[d.seq].
   syn_qual[lsyncnt].activity_type_cd = ocs.activity_type_cd, reply->qual[d.seq].syn_qual[lsyncnt].
   cnum_cki = ocs2.cki,
   reply->qual[d.seq].syn_qual[lsyncnt].dnum_cki = oc.cki
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  *
  FROM (dummyt d  WITH seq = lsize),
   order_catalog_synonym ocs,
   order_catalog_synonym ocs2,
   order_catalog_synonym ocs3,
   order_catalog_synonym ocs4,
   alt_sel_list al,
   alt_sel_list al2,
   alt_sel_cat ac,
   order_catalog oc
  PLAN (d
   WHERE (reply->qual[d.seq].direct_cnvt_ind=0))
   JOIN (ocs
   WHERE (ocs.synonym_id=request->qual[d.seq].synonym_id))
   JOIN (ocs2
   WHERE ocs2.catalog_cd=ocs.catalog_cd
    AND ocs2.mnemonic_type_cd=cprimary)
   JOIN (al
   WHERE al.synonym_id=ocs2.synonym_id)
   JOIN (ac
   WHERE ac.alt_sel_category_id=al.alt_sel_category_id
    AND ((ac.owner_id+ 0)=0)
    AND ((ac.security_flag+ 0)=2)
    AND ((ac.ahfs_ind+ 0)=1))
   JOIN (al2
   WHERE al2.alt_sel_category_id=ac.alt_sel_category_id
    AND ((al2.synonym_id+ 0) != al.synonym_id))
   JOIN (ocs3
   WHERE ocs3.synonym_id=al2.synonym_id)
   JOIN (oc
   WHERE oc.catalog_cd=ocs3.catalog_cd)
   JOIN (ocs4
   WHERE ocs4.catalog_cd=oc.catalog_cd
    AND ocs4.mnemonic_type_cd IN (cprimary, cbrandname, cdispdrug_c, cgenerictop_m, ctradetop_n)
    AND ocs4.active_ind=1
    AND ocs4.hide_flag=0
    AND  EXISTS (
   (SELECT
    ofr.synonym_id
    FROM ocs_facility_r ofr
    WHERE ofr.synonym_id=ocs4.synonym_id
     AND ofr.facility_cd IN (0, request->qual[d.seq].facility_cd))))
  ORDER BY d.seq, ocs4.mnemonic_key_cap, ocs4.synonym_id
  HEAD d.seq
   reply->qual[d.seq].tclass_desc = ac.long_description
  HEAD ocs4.synonym_id
   lsyncnt = (reply->qual[d.seq].syn_cnt+ 1), reply->qual[d.seq].syn_cnt = lsyncnt, stat = alterlist(
    reply->qual[d.seq].syn_qual,lsyncnt),
   reply->qual[d.seq].syn_qual[lsyncnt].synonym_id = ocs4.synonym_id, reply->qual[d.seq].syn_qual[
   lsyncnt].mnemonic = ocs4.mnemonic, reply->qual[d.seq].syn_qual[lsyncnt].catalog_cd = ocs4
   .catalog_cd,
   reply->qual[d.seq].syn_qual[lsyncnt].catalog_type_cd = ocs4.catalog_type_cd, reply->qual[d.seq].
   syn_qual[lsyncnt].activity_type_cd = ocs.activity_type_cd, reply->qual[d.seq].syn_qual[lsyncnt].
   cnum_cki = ocs4.cki,
   reply->qual[d.seq].syn_qual[lsyncnt].dnum_cki = oc.cki, reply->qual[d.seq].syn_qual[lsyncnt].
   tclass_ind = 1
  WITH nocounter
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 SET last_mod = "004 04/10/2008 AC013650"
END GO
