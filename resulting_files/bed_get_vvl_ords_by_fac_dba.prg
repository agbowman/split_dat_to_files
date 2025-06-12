CREATE PROGRAM bed_get_vvl_ords_by_fac:dba
 FREE SET reply
 RECORD reply(
   1 orders[*]
     2 catalog_code_value = f8
     2 description = vc
     2 primary_mnemonic = vc
     2 power_ord_ind = i2
     2 prod_syn_link_ind = i2
     2 virtual_view_ind = i2
   1 too_many_results_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_cat
 RECORD temp_cat(
   1 cats[*]
     2 catalog_code_value = f8
 )
 SET reply->status_data.status = "F"
 SET pharm_ct = 0.0
 SET pharm_ct = uar_get_code_by("MEANING",6000,"PHARMACY")
 SET pharm_at = 0.0
 SET pharm_at = uar_get_code_by("MEANING",106,"PHARMACY")
 SET primary_code_value = 0.0
 SET primary_code_value = uar_get_code_by("MEANING",6011,"PRIMARY")
 SET brand_code_value = 0.0
 SET brand_code_value = uar_get_code_by("MEANING",6011,"BRANDNAME")
 SET dcp_code_value = 0.0
 SET dcp_code_value = uar_get_code_by("MEANING",6011,"DCP")
 SET c_code_value = 0.0
 SET c_code_value = uar_get_code_by("MEANING",6011,"DISPDRUG")
 SET e_code_value = 0.0
 SET e_code_value = uar_get_code_by("MEANING",6011,"IVNAME")
 SET m_code_value = 0.0
 SET m_code_value = uar_get_code_by("MEANING",6011,"GENERICTOP")
 SET n_code_value = 0.0
 SET n_code_value = uar_get_code_by("MEANING",6011,"TRADETOP")
 SET orderable_code_value = 0.0
 SET orderable_code_value = uar_get_code_by("MEANING",4063,"ORDERABLE")
 SET inpatient_code_value = 0.0
 SET inpatient_code_value = uar_get_code_by("MEANING",4500,"INPATIENT")
 SET sys_pkg_code_value = 0.0
 SET sys_pkg_code_value = uar_get_code_by("MEANING",4062,"SYSPKGTYP")
 SET system_code_value = 0.0
 SET system_code_value = uar_get_code_by("MEANING",4062,"SYSTEM")
 SET desc_code_value = 0.0
 SET desc_code_value = uar_get_code_by("MEANING",11000,"DESC")
 DECLARE search_txt = vc
 DECLARE oc_parse = vc
 SET oc_parse = "o.catalog_cd = ocir.catalog_cd and o.active_ind = 1"
 IF ((request->search_string > " "))
  IF ((request->search_type_flag="S"))
   SET search_string = concat('"',cnvtupper(trim(request->search_string)),'*"')
  ELSE
   SET search_string = concat('"*',cnvtupper(trim(request->search_string)),'*"')
  ENDIF
  SET oc_parse = concat(oc_parse," and cnvtupper(o.primary_mnemonic) = ",search_string)
 ENDIF
 SET tot_cnt = 0
 SELECT INTO "nl:"
  FROM order_catalog_item_r ocir,
   order_catalog o,
   medication_definition md,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   item_definition id,
   med_identifier mi
  PLAN (ocir
   WHERE ocir.catalog_cd > 0)
   JOIN (o
   WHERE parser(oc_parse))
   JOIN (md
   WHERE ocir.item_id=md.item_id)
   JOIN (mdf
   WHERE md.item_id=mdf.item_id
    AND mdf.pharmacy_type_cd=inpatient_code_value
    AND mdf.flex_type_cd=sys_pkg_code_value)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND ((mfoi.flex_object_type_cd+ 0)=orderable_code_value)
    AND ((((mfoi.parent_entity_id+ 0) IN (0, request->facility_code_value))) OR ((request->
   ignore_facility_ind=1)))
    AND mfoi.active_ind=1)
   JOIN (id
   WHERE md.item_id=id.item_id
    AND ((id.active_ind+ 0)=1))
   JOIN (mi
   WHERE mi.item_id=id.item_id
    AND mi.pharmacy_type_cd=inpatient_code_value
    AND mi.med_identifier_type_cd=desc_code_value
    AND ((mi.flex_type_cd+ 0)=system_code_value)
    AND mi.primary_ind=1
    AND ((mi.med_product_id+ 0)=0)
    AND ((mi.active_ind+ 0)=1))
  ORDER BY ocir.catalog_cd, md.item_id
  HEAD REPORT
   cnt = 0, tot_cnt = 0, stat = alterlist(temp_cat->cats,100)
  HEAD ocir.catalog_cd
   cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_cat->cats,(tot_cnt+ 100)), cnt = 1
   ENDIF
   temp_cat->cats[tot_cnt].catalog_code_value = ocir.catalog_cd
  FOOT REPORT
   stat = alterlist(temp_cat->cats,tot_cnt)
  WITH nocounter
 ;end select
 IF (tot_cnt=0)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SET stat = alterlist(reply->orders,tot_cnt)
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(tot_cnt)),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.catalog_cd=temp_cat->cats[d.seq].catalog_code_value)
    AND ((oc.catalog_type_cd+ 0)=pharm_ct)
    AND ((oc.activity_type_cd+ 0)=pharm_at)
    AND oc.active_ind=1)
  ORDER BY d.seq
  HEAD REPORT
   cnt = 0
  HEAD d.seq
   cnt = (cnt+ 1), reply->orders[cnt].catalog_code_value = oc.catalog_cd, reply->orders[cnt].
   description = oc.description,
   reply->orders[cnt].primary_mnemonic = oc.primary_mnemonic
  FOOT REPORT
   stat = alterlist(reply->orders,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog_synonym ocs,
   synonym_item_r s
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.catalog_cd=reply->orders[d.seq].catalog_code_value)
    AND ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value, c_code_value,
   e_code_value,
   m_code_value, n_code_value)
    AND ocs.active_ind=1
    AND  EXISTS (
   (SELECT
    ocsf.synonym_id
    FROM ocs_facility_r ocsf
    WHERE ocsf.synonym_id=ocs.synonym_id)))
   JOIN (s
   WHERE s.synonym_id=outerjoin(ocs.synonym_id))
  ORDER BY d.seq
  DETAIL
   IF (ocs.hide_flag IN (0, null))
    reply->orders[d.seq].power_ord_ind = 1
   ENDIF
   reply->orders[d.seq].virtual_view_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(cnt)),
   order_catalog_synonym ocs,
   synonym_item_r s
  PLAN (d)
   JOIN (ocs
   WHERE (ocs.catalog_cd=reply->orders[d.seq].catalog_code_value)
    AND ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value, c_code_value,
   e_code_value,
   m_code_value, n_code_value)
    AND ocs.active_ind=1)
   JOIN (s
   WHERE s.synonym_id=ocs.synonym_id)
  ORDER BY d.seq
  DETAIL
   reply->orders[d.seq].prod_syn_link_ind = 1
  WITH nocounter
 ;end select
 IF ((cnt > request->max_reply)
  AND (request->max_reply > 0))
  SET stat = initrec(reply)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
