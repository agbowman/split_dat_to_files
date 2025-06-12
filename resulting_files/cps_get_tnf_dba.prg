CREATE PROGRAM cps_get_tnf:dba
 EXECUTE cclseclogin
 RECORD reply(
   1 syn_cnt = i4
   1 qual[*]
     2 synonym_id = f8
     2 mnemonic = vc
     2 catalog_cd = f8
     2 catalog_type_cd = f8
     2 activity_type_cd = f8
     2 cnum_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE cpharmacy = f8 WITH protect, noconstant(0.0)
 DECLARE cprimary = f8 WITH protect, noconstant(0.0)
 DECLARE cactive = f8 WITH protect, noconstant(0.0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 SET stat = uar_get_meaning_by_codeset(6000,"PHARMACY",1,cpharmacy)
 SET stat = uar_get_meaning_by_codeset(6011,"PRIMARY",1,cprimary)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,cactive)
 IF (((cpharmacy=0) OR (((cprimary=0) OR (cactive=0)) )) )
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  *
  FROM order_catalog_synonym ocs,
   ocs_facility_r ocsfr
  WHERE ocs.orderable_type_flag=10
   AND ocs.rx_mask=4
   AND ocs.catalog_type_cd=cpharmacy
   AND ocs.mnemonic_type_cd=cprimary
   AND ocs.active_ind=1
   AND ocs.active_status_cd=cactive
   AND ocs.hide_flag IN (0, null)
   AND (((request->facility_cd=0)
   AND ocsfr.synonym_id=0
   AND ocsfr.facility_cd=0) OR (ocs.synonym_id=ocsfr.synonym_id
   AND ocsfr.facility_cd IN (request->facility_cd, 0)))
  ORDER BY ocs.catalog_cd
  HEAD REPORT
   lcnt = 0
  HEAD ocs.catalog_cd
   lcnt = (lcnt+ 1), stat = alterlist(reply->qual,lcnt), reply->qual[lcnt].synonym_id = ocs
   .synonym_id,
   reply->qual[lcnt].mnemonic = ocs.mnemonic, reply->qual[lcnt].catalog_cd = ocs.catalog_cd, reply->
   qual[lcnt].catalog_type_cd = ocs.catalog_type_cd,
   reply->qual[lcnt].activity_type_cd = ocs.activity_type_cd, reply->qual[lcnt].cnum_cki = trim(ocs
    .cki)
  WITH nocounter
 ;end select
 SET reply->syn_cnt = lcnt
 IF (lcnt=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ORDER_CATALOG_SYNONYM"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "No TNF orderable found"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "002  12/12/2008  SW015124"
END GO
