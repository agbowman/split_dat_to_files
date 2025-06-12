CREATE PROGRAM afc_load_caresets:dba
 EXECUTE cclseclogin
 SET message = nowindow
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE cstype_cd = f8
 SET codeset = 6030
 SET cdf_meaning = "ORDERABLE"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,cstype_cd)
 CALL echo(build("the orderable code is : ",cstype_cd))
 IF ((validate(gl_cont_cd,- (1))=- (1)))
  DECLARE gl_cont_cd = f8
  SET codeset = 13016
  SET cdf_meaning = "ORD CAT"
  SET cnt = 1
  SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,gl_cont_cd)
  CALL echo(build("the ord cat code is : ",gl_cont_cd))
 ENDIF
 SELECT
  IF (( $1=0))
   PLAN (o
    WHERE ((o.orderable_type_flag=2) OR (o.orderable_type_flag=6))
     AND o.active_ind=1)
    JOIN (d1)
    JOIN (cc
    WHERE cc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE cc.comp_type_cd=cstype_cd
     AND ocs.synonym_id=cc.comp_id
     AND ocs.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.active_ind=1)
  ELSE
   PLAN (o
    WHERE ((o.orderable_type_flag=2) OR (o.orderable_type_flag=6))
     AND o.active_ind=1
     AND (o.activity_type_cd= $1))
    JOIN (d1)
    JOIN (cc
    WHERE cc.catalog_cd=o.catalog_cd)
    JOIN (ocs
    WHERE cc.comp_type_cd=cstype_cd
     AND ocs.synonym_id=cc.comp_id
     AND ocs.active_ind=1)
    JOIN (oc
    WHERE oc.catalog_cd=ocs.catalog_cd
     AND oc.active_ind=1)
  ENDIF
  INTO "nl:"
  desc = trim(o.description), short_desc = trim(o.primary_mnemonic), taskdesc = trim(oc.description),
  mnem = trim(oc.primary_mnemonic), o.*, oc.*
  FROM dummyt d1,
   order_catalog o,
   cs_component cc,
   order_catalog_synonym ocs,
   order_catalog oc
  HEAD o.catalog_cd
   child_ndx = 0, parent_ndx += 1, stat = alterlist(request->qual,parent_ndx),
   request->qual[parent_ndx].child_qual = child_ndx, hold_parent_cd = o.catalog_cd, request->qual[
   parent_ndx].action = 1,
   request->qual[parent_ndx].ext_id = o.catalog_cd, request->qual[parent_ndx].ext_owner_cd = o
   .activity_type_cd, stat = assign(validate(request->qual[parent_ndx].ext_sub_owner_cd),o
    .activity_subtype_cd),
   request->qual[parent_ndx].ext_contributor_cd = gl_cont_cd, request->qual[parent_ndx].
   ext_description = desc, request->qual[parent_ndx].ext_short_desc = short_desc,
   request->qual[parent_ndx].parent_qual_ind = 1
  DETAIL
   IF (oc.catalog_cd != 0)
    child_ndx += 1, stat = alterlist(request->qual[parent_ndx].children,child_ndx), request->qual[
    parent_ndx].children[child_ndx].ext_id = oc.catalog_cd,
    request->qual[parent_ndx].children[child_ndx].ext_contributor_cd = gl_cont_cd, request->qual[
    parent_ndx].children[child_ndx].ext_description = taskdesc, request->qual[parent_ndx].children[
    child_ndx].ext_short_desc = mnem,
    request->qual[parent_ndx].children[child_ndx].ext_owner_cd = oc.activity_type_cd, stat = assign(
     validate(request->qual[parent_ndx].children[child_ndx].ext_sub_owner_cd),oc.activity_subtype_cd),
    request->qual[parent_ndx].child_qual = child_ndx
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
END GO
