CREATE PROGRAM dcp_catsel_key_call:dba
 DECLARE cat_not_size = i4 WITH private, noconstant(0)
 DECLARE search_string = vc WITH protect, noconstant(
  "ocs.mnemonic_key_cap between startrange AND endrange")
 DECLARE result = i2 WITH protect, noconstant(- (1))
 DECLARE trim_upper_seed = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET s_cnt = 0
 SET upperseed = cnvtupper(request->seed)
 SET show_inactive_ind = request->show_inactive_ind
 SET exact_match_ind = request->exact_match_ind
 SET virtual_orc = 0
 SET exact_match_found = 0
 SET loc_size = size(loc_cd->qual,5)
 IF ((request->virtual_view_offset > 0)
  AND (request->virtual_view_offset < 101))
  SET virtual_orc = 1
 ELSE
  SET virtual_orc = 0
  SET request->virtual_view_offset = 99
 ENDIF
 SET startrange = upperseed
 SET endrange = "ZZZZZZZZZZ"
 CALL echo(build("request seed = ",request->seed))
 CALL echo(concat("start range = ",startrange))
 CALL echo(concat("end range = ",endrange))
 IF (validate(request->check_wildcard_ind)=1)
  IF ((request->check_wildcard_ind=1))
   SET trim_upper_seed = trim(upperseed,3)
   SET result = findstring("*",trim_upper_seed,1,0)
   IF (result=0)
    SET result = findstring("?",trim_upper_seed,1,0)
   ENDIF
   IF (result > 0)
    SET search_string = "ocs.mnemonic_key_cap = patstring(concat(trim_upper_seed, '*'))"
   ENDIF
  ENDIF
 ENDIF
 IF ((request->exact_match_ind=1))
  SELECT
   IF (logical_domain_flag > 0)
    ocs.mnemonic
    FROM order_catalog_synonym ocs,
     ocs_facility_r ofr,
     location l,
     organization o,
     surgical_procedure sp,
     surg_proc_detail spd,
     dummyt d1
    PLAN (ocs
     WHERE ocs.mnemonic_key_cap >= startrange
      AND ocs.mnemonic_key_cap <= endrange
      AND ocs.active_ind=1
      AND  $1
      AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
      AND ((virtual_orc=0) OR (virtual_orc=1
      AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id)
     JOIN (l
     WHERE l.location_cd=ofr.facility_cd)
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND ((o.logical_domain_id=m_logical_domain_id) OR (((o.organization_id+ 0)=0.0))) )
     JOIN (sp
     WHERE sp.catalog_cd=outerjoin(ocs.catalog_cd))
     JOIN (d1)
     JOIN (spd
     WHERE spd.catalog_cd=sp.catalog_cd
      AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
   ELSE
    ocs.mnemonic
    FROM order_catalog_synonym ocs,
     surgical_procedure sp,
     surg_proc_detail spd,
     dummyt d1
    PLAN (ocs
     WHERE ocs.mnemonic_key_cap >= startrange
      AND ocs.mnemonic_key_cap <= endrange
      AND ocs.active_ind=1
      AND  $1
      AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
      AND ((virtual_orc=0) OR (virtual_orc=1
      AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
     JOIN (sp
     WHERE sp.catalog_cd=outerjoin(ocs.catalog_cd))
     JOIN (d1)
     JOIN (spd
     WHERE spd.catalog_cd=sp.catalog_cd
      AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
   ENDIF
   INTO "NL:"
   ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, spd.surg_area_cd
   HEAD ocs.synonym_id
    IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
     AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
     AND cnvtupper(request->seed)=cnvtupper(ocs.mnemonic_key_cap)
     AND s_cnt < 50)
     s_cnt = (s_cnt+ 1)
     IF (mod(s_cnt,10)=1
      AND s_cnt != 1)
      stat = alter(reply->qual,(s_cnt+ 9))
     ENDIF
     reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
     reply->qual[s_cnt].code = ocs.synonym_id,
     reply->qual[s_cnt].type = ocs.orderable_type_flag, reply->qual[s_cnt].ref_text_mask = ocs
     .ref_text_mask, reply->qual[s_cnt].catalog_cd = ocs.catalog_cd,
     reply->qual[s_cnt].catalog_type_cd = ocs.catalog_type_cd, reply->qual[s_cnt].activity_type_cd =
     ocs.activity_type_cd, reply->qual[s_cnt].activity_subtype_cd = ocs.activity_subtype_cd,
     reply->qual[s_cnt].oe_format_id = ocs.oe_format_id
     IF (exact_match_found=0)
      IF (cnvtupper(request->seed)=cnvtupper(ocs.mnemonic_key_cap))
       reply->exact_match_ind = 1, exact_match_found = 1
      ELSE
       reply->exact_match_ind = 0
      ENDIF
     ENDIF
     reply->qual[s_cnt].cat_not_avail_ind = 1, reply->qual[s_cnt].cat_not_avail_msg = concat(
      "The procedure ",trim(reply->qual[s_cnt].display),
      " is not included within the following surgical location(s) and cannot be added at this time:"),
     stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,loc_size)
     FOR (x = 1 TO loc_size)
      reply->qual[s_cnt].cat_not_avail_qual[x].surg_area_cd = loc_cd->qual[x].surg_area_cd,reply->
      qual[s_cnt].cat_not_avail_qual[x].location_cd = loc_cd->qual[x].location_cd
     ENDFOR
    ENDIF
   HEAD spd.surg_area_cd
    IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
     AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
     AND s_cnt <= 50)
     IF (spd.surg_area_cd > 0.0)
      cat_not_size = size(reply->qual[s_cnt].cat_not_avail_qual,5), loc_idx = locateval(idx,1,
       cat_not_size,spd.surg_area_cd,reply->qual[s_cnt].cat_not_avail_qual[idx].surg_area_cd)
      IF (loc_idx > 0)
       stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,(cat_not_size - 1),(loc_idx - 1))
       IF (size(reply->qual[s_cnt].cat_not_avail_qual,5)=0)
        reply->qual[s_cnt].cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
       ENDIF
      ENDIF
     ENDIF
     IF (((sp.catalog_cd=0) OR ((loc_cd->qual[1].surg_area_cd=0))) )
      stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,0), reply->qual[s_cnt].cat_not_avail_ind
       = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
     ENDIF
    ENDIF
   WITH outerjoin = d1, nocounter
  ;end select
 ELSE
  SELECT
   IF (logical_domain_flag > 0)
    ocs.mnemonic
    FROM order_catalog_synonym ocs,
     ocs_facility_r ofr,
     location l,
     organization o,
     surgical_procedure sp,
     surg_proc_detail spd,
     dummyt d1
    PLAN (ocs
     WHERE parser(search_string)
      AND ocs.active_ind=1
      AND  $1
      AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
      AND ((virtual_orc=0) OR (virtual_orc=1
      AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
     JOIN (ofr
     WHERE ofr.synonym_id=ocs.synonym_id)
     JOIN (l
     WHERE l.location_cd=ofr.facility_cd)
     JOIN (o
     WHERE o.organization_id=l.organization_id
      AND ((o.logical_domain_id=m_logical_domain_id) OR (((o.organization_id+ 0)=0.0))) )
     JOIN (sp
     WHERE sp.catalog_cd=outerjoin(ocs.catalog_cd))
     JOIN (d1)
     JOIN (spd
     WHERE spd.catalog_cd=sp.catalog_cd
      AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
   ELSE
    ocs.mnemonic
    FROM order_catalog_synonym ocs,
     surgical_procedure sp,
     surg_proc_detail spd,
     dummyt d1
    PLAN (ocs
     WHERE parser(search_string)
      AND ocs.active_ind=1
      AND  $1
      AND ((ocs.hide_flag=null) OR (ocs.hide_flag=0))
      AND ((virtual_orc=0) OR (virtual_orc=1
      AND substring(request->virtual_view_offset,1,ocs.virtual_view)="1")) )
     JOIN (sp
     WHERE sp.catalog_cd=outerjoin(ocs.catalog_cd))
     JOIN (d1)
     JOIN (spd
     WHERE spd.catalog_cd=sp.catalog_cd
      AND expand(idx,1,size(loc_cd->qual,5),spd.surg_area_cd,loc_cd->qual[idx].surg_area_cd))
   ENDIF
   INTO "NL:"
   ORDER BY ocs.mnemonic_key_cap, ocs.synonym_id, spd.surg_area_cd
   HEAD ocs.synonym_id
    IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
     AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
     AND s_cnt < 50)
     s_cnt = (s_cnt+ 1)
     IF (mod(s_cnt,10)=1
      AND s_cnt != 1)
      stat = alter(reply->qual,(s_cnt+ 9))
     ENDIF
     reply->qual[s_cnt].display = ocs.mnemonic, reply->qual[s_cnt].keyval = ocs.mnemonic_key_cap,
     reply->qual[s_cnt].code = ocs.synonym_id,
     reply->qual[s_cnt].type = ocs.orderable_type_flag, reply->qual[s_cnt].ref_text_mask = ocs
     .ref_text_mask, reply->qual[s_cnt].catalog_cd = ocs.catalog_cd,
     reply->qual[s_cnt].catalog_type_cd = ocs.catalog_type_cd, reply->qual[s_cnt].activity_type_cd =
     ocs.activity_type_cd, reply->qual[s_cnt].activity_subtype_cd = ocs.activity_subtype_cd,
     reply->qual[s_cnt].oe_format_id = ocs.oe_format_id
     IF (exact_match_found=0)
      IF (cnvtupper(request->seed)=cnvtupper(ocs.mnemonic_key_cap))
       reply->exact_match_ind = 1, exact_match_found = 1
      ELSE
       reply->exact_match_ind = 0
      ENDIF
     ENDIF
     reply->qual[s_cnt].cat_not_avail_ind = 1, reply->qual[s_cnt].cat_not_avail_msg = concat(
      "The procedure ",trim(reply->qual[s_cnt].display),
      " is not included within the following surgical location(s) and cannot be added at this time:"),
     stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,loc_size)
     FOR (x = 1 TO loc_size)
      reply->qual[s_cnt].cat_not_avail_qual[x].surg_area_cd = loc_cd->qual[x].surg_area_cd,reply->
      qual[s_cnt].cat_not_avail_qual[x].location_cd = loc_cd->qual[x].location_cd
     ENDFOR
    ENDIF
   HEAD spd.surg_area_cd
    IF (((sp.catalog_cd=0) OR (((sp.catalog_cd > 0
     AND spd.catalog_cd > 0) OR ((loc_cd->qual[1].surg_area_cd=0))) ))
     AND s_cnt <= 50)
     IF (spd.surg_area_cd > 0.0)
      cat_not_size = size(reply->qual[s_cnt].cat_not_avail_qual,5), loc_idx = locateval(idx,1,
       cat_not_size,spd.surg_area_cd,reply->qual[s_cnt].cat_not_avail_qual[idx].surg_area_cd)
      IF (loc_idx > 0)
       stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,(cat_not_size - 1),(loc_idx - 1))
       IF (size(reply->qual[s_cnt].cat_not_avail_qual,5)=0)
        reply->qual[s_cnt].cat_not_avail_ind = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
       ENDIF
      ENDIF
     ENDIF
     IF (((sp.catalog_cd=0) OR ((loc_cd->qual[1].surg_area_cd=0))) )
      stat = alterlist(reply->qual[s_cnt].cat_not_avail_qual,0), reply->qual[s_cnt].cat_not_avail_ind
       = 0, reply->qual[s_cnt].cat_not_avail_msg = ""
     ENDIF
    ENDIF
   WITH outerjoin = d1, nocounter
  ;end select
 ENDIF
 IF (s_cnt != size(reply->qual,5))
  SET stat = alter(reply->qual,s_cnt)
 ENDIF
 IF (s_cnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "GET"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ORDER_CATALOG_SYNONYM"
  GO TO exit_script
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 SET reply->qual_cnt = s_cnt
 SET last_mod = "210921 06/12/09 dd018884"
END GO
