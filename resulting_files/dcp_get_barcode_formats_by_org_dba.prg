CREATE PROGRAM dcp_get_barcode_formats_by_org:dba
 RECORD reply(
   1 barcodeformats[*]
     2 alias_type_cd = f8
     2 alias_type_disp = vc
     2 alias_pool_cd = f8
     2 alias_mask = vc
     2 barcode_type_cd = f8
     2 barcode_type_disp = vc
     2 check_digit_ind = i2
     2 label_organization_id = f8
     2 org_barcode_format_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 prefix = vc
     2 z_data = vc
     2 scanningorganizations[*]
       3 org_barcode_org_id = f8
       3 scanning_organization_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nbcformatcnt = i4 WITH noconstant(0)
 DECLARE nscanorgcnt = i4 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE norgidx1 = i4 WITH noconstant(0)
 DECLARE norgidx2 = i4 WITH noconstant(0)
 DECLARE nbcidx = i4 WITH noconstant(0)
 SET reply->status_data.status = "F"
 IF (size(request->organizations,5) > 0)
  SET stat = alterlist(request->organizations,(size(request->organizations,5)+ 1))
  SET request->organizations[size(request->organizations,5)].organization_id = 0.0
 ENDIF
 SELECT
  IF (size(request->organizations,5) > 0
   AND size(request->barcode_types,5) > 0)
   PLAN (obo
    WHERE expand(norgidx1,1,size(request->organizations,5),obo.scan_organization_id,request->
     organizations[norgidx1].organization_id))
    JOIN (obf
    WHERE expand(nbcidx,1,size(request->barcode_types,5),obf.barcode_type_cd,request->barcode_types[
     nbcidx].barcode_type_cd)
     AND ((obf.organization_id=obo.label_organization_id
     AND obf.barcode_type_cd=obo.barcode_type_cd
     AND obo.scan_organization_id > 0) OR (expand(norgidx2,1,(size(request->organizations,5) - 1),obf
     .organization_id,request->organizations[norgidx2].organization_id)
     AND obo.scan_organization_id=0)) )
  ELSEIF (size(request->organizations,5) > 0)
   PLAN (obo
    WHERE expand(norgidx1,1,size(request->organizations,5),obo.scan_organization_id,request->
     organizations[norgidx1].organization_id))
    JOIN (obf
    WHERE ((obf.organization_id=obo.label_organization_id
     AND obf.barcode_type_cd=obo.barcode_type_cd
     AND obo.scan_organization_id > 0) OR (expand(norgidx2,1,(size(request->organizations,5) - 1),obf
     .organization_id,request->organizations[norgidx2].organization_id)
     AND obo.scan_organization_id=0)) )
  ELSEIF (size(request->barcode_types,5) > 0)
   PLAN (obf
    WHERE obf.organization_id > 0.0
     AND expand(nbcidx,1,size(request->barcode_types,5),obf.barcode_type_cd,request->barcode_types[
     nbcidx].barcode_type_cd))
    JOIN (obo
    WHERE (obo.label_organization_id= Outerjoin(obf.organization_id))
     AND (obo.barcode_type_cd= Outerjoin(obf.barcode_type_cd)) )
  ELSE
   PLAN (obf
    WHERE obf.organization_id > 0.0)
    JOIN (obo
    WHERE (obo.label_organization_id= Outerjoin(obf.organization_id))
     AND (obo.barcode_type_cd= Outerjoin(obf.barcode_type_cd)) )
  ENDIF
  INTO "nl:"
  FROM org_barcode_org obo,
   org_barcode_format obf
  ORDER BY obf.org_barcode_format_id, obo.org_barcode_seq_id
  HEAD obf.org_barcode_format_id
   nbcformatcnt += 1
   IF (nbcformatcnt > size(reply->barcodeformats,5))
    stat = alterlist(reply->barcodeformats,(nbcformatcnt+ 9))
   ENDIF
   reply->barcodeformats[nbcformatcnt].alias_type_cd = obf.alias_type_cd, reply->barcodeformats[
   nbcformatcnt].barcode_type_cd = obf.barcode_type_cd, reply->barcodeformats[nbcformatcnt].
   check_digit_ind = obf.check_digit_ind,
   reply->barcodeformats[nbcformatcnt].label_organization_id = obf.organization_id, reply->
   barcodeformats[nbcformatcnt].org_barcode_format_id = obf.org_barcode_format_id, reply->
   barcodeformats[nbcformatcnt].parent_entity_id = obf.parent_entity_id,
   reply->barcodeformats[nbcformatcnt].parent_entity_name = obf.parent_entity_name, reply->
   barcodeformats[nbcformatcnt].prefix = obf.prefix, reply->barcodeformats[nbcformatcnt].z_data = obf
   .z_data,
   nscanorgcnt = 0
  DETAIL
   IF (obo.scan_organization_id > 0.0)
    nscanorgcnt += 1
    IF (nscanorgcnt > size(reply->barcodeformats[nbcformatcnt].scanningorganizations,5))
     stat = alterlist(reply->barcodeformats[nbcformatcnt].scanningorganizations,(nscanorgcnt+ 3))
    ENDIF
    reply->barcodeformats[nbcformatcnt].scanningorganizations[nscanorgcnt].scanning_organization_id
     = obo.scan_organization_id, reply->barcodeformats[nbcformatcnt].scanningorganizations[
    nscanorgcnt].org_barcode_org_id = obo.org_barcode_seq_id
   ENDIF
  FOOT  obf.org_barcode_format_id
   stat = alterlist(reply->barcodeformats[nbcformatcnt].scanningorganizations,nscanorgcnt)
  FOOT REPORT
   stat = alterlist(reply->barcodeformats,nbcformatcnt)
  WITH nocounter, expand = 1
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(nbcformatcnt)),
   org_alias_pool_reltn oapr,
   alias_pool ap
  PLAN (d1)
   JOIN (oapr
   WHERE (oapr.organization_id=reply->barcodeformats[d1.seq].label_organization_id)
    AND (oapr.alias_entity_alias_type_cd=reply->barcodeformats[d1.seq].alias_type_cd))
   JOIN (ap
   WHERE ap.alias_pool_cd=oapr.alias_pool_cd)
  DETAIL
   reply->barcodeformats[d1.seq].alias_pool_cd = ap.alias_pool_cd, reply->barcodeformats[d1.seq].
   alias_mask = ap.format_mask
  WITH nocounter
 ;end select
#exit_script
END GO
