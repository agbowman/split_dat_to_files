CREATE PROGRAM bed_get_mos_ords_wo_sent:dba
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 orders[*]
      2 catalog_code_value = f8
      2 description = vc
      2 primary_mnemonic = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET temp_qual
 RECORD temp_qual(
   1 ords[*]
     2 catalog_code = f8
     2 primary_m = vc
     2 desc = vc
     2 load_ind = i2
     2 syn_cnt = i4
     2 product_ind = i2
     2 syns[*]
       3 syn_id = f8
 )
 SET reply->status_data.status = "F"
 DECLARE pharm_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE primary_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"PRIMARY"))
 DECLARE brand_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"BRANDNAME"))
 DECLARE dcp_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"DCP"))
 DECLARE c_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"DISPDRUG"))
 DECLARE e_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"IVNAME"))
 DECLARE m_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"GENERICTOP"))
 DECLARE n_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6011,"TRADETOP"))
 DECLARE orderable_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",4063,"ORDERABLE")
  )
 DECLARE inpatient_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",4500,"INPATIENT")
  )
 DECLARE sys_pkg_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSPKGTYP"))
 DECLARE system_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",4062,"SYSTEM"))
 DECLARE desc_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",11000,"DESC"))
 DECLARE oe_order_code_value = f8 WITH protect, constant(uar_get_code_by("MEANING",6003,"ORDER"))
 DECLARE activity_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",106,"PHARMACY"))
 DECLARE tcnt = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE scnt = i4 WITH protect, noconstant(0)
 DECLARE stcnt = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE index1 = i4 WITH protect, noconstant(0)
 DECLARE index2 = i4 WITH protect, noconstant(0)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE lcnt = i4 WITH protect, noconstant(0)
 DECLARE pharm_at = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=106
   AND cv.cdf_meaning="PHARMACY"
  HEAD REPORT
   pharm_at = "(oc.activity_type_cd = "
  DETAIL
   count = (count+ 1)
   IF (count=1)
    pharm_at = concat(pharm_at,cnvtstring(cv.code_value))
   ELSE
    pharm_at = concat(pharm_at," or oc.activity_type_cd = ",cnvtstring(cv.code_value))
   ENDIF
  FOOT REPORT
   pharm_at = concat(pharm_at,")")
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM order_catalog oc,
   order_catalog_synonym ocs
  PLAN (oc
   WHERE oc.catalog_type_cd=pharm_cd
    AND parser(pharm_at)
    AND oc.orderable_type_flag IN (0, 1)
    AND oc.active_ind=1)
   JOIN (ocs
   WHERE ocs.catalog_cd=oc.catalog_cd
    AND ocs.mnemonic_type_cd IN (primary_code_value, brand_code_value, dcp_code_value, c_code_value,
   e_code_value,
   m_code_value, n_code_value)
    AND ocs.active_ind=1
    AND ocs.hide_flag IN (0, null))
  ORDER BY oc.catalog_cd, ocs.synonym_id
  HEAD REPORT
   cnt = 0, tcnt = 0, stat = alterlist(temp_qual->ords,100)
  HEAD oc.catalog_cd
   cnt = (cnt+ 1), tcnt = (tcnt+ 1)
   IF (cnt > 100)
    stat = alterlist(temp_qual->ords,(tcnt+ 100)), cnt = 1
   ENDIF
   temp_qual->ords[tcnt].catalog_code = oc.catalog_cd, temp_qual->ords[tcnt].desc = oc.description,
   temp_qual->ords[tcnt].primary_m = oc.primary_mnemonic,
   scnt = 0, stcnt = 0, stat = alterlist(temp_qual->ords[tcnt].syns,10)
  HEAD ocs.synonym_id
   scnt = (scnt+ 1), stcnt = (stcnt+ 1)
   IF (scnt > 10)
    stat = alterlist(temp_qual->ords[tcnt].syns,(stcnt+ 10)), scnt = 1
   ENDIF
   temp_qual->ords[tcnt].syns[stcnt].syn_id = ocs.synonym_id
  FOOT  oc.catalog_cd
   stat = alterlist(temp_qual->ords[tcnt].syns,stcnt), temp_qual->ords[tcnt].syn_cnt = stcnt
  FOOT REPORT
   stat = alterlist(temp_qual->ords,tcnt)
  WITH nocounter
 ;end select
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog_item_r ocir,
   medication_definition md,
   med_def_flex mdf,
   med_flex_object_idx mfoi,
   item_definition id,
   med_identifier mi
  PLAN (ocir
   WHERE expand(index,1,value(tcnt),ocir.catalog_cd,temp_qual->ords[index].catalog_code))
   JOIN (md
   WHERE ocir.item_id=md.item_id)
   JOIN (mdf
   WHERE md.item_id=mdf.item_id
    AND mdf.pharmacy_type_cd=inpatient_code_value
    AND mdf.flex_type_cd=sys_pkg_code_value)
   JOIN (mfoi
   WHERE mfoi.med_def_flex_id=mdf.med_def_flex_id
    AND mfoi.flex_object_type_cd=orderable_code_value
    AND mfoi.parent_entity_id IN (0, request->facility_code_value)
    AND mfoi.active_ind=1)
   JOIN (id
   WHERE md.item_id=id.item_id
    AND id.active_ind=1)
   JOIN (mi
   WHERE mi.item_id=id.item_id
    AND mi.pharmacy_type_cd=inpatient_code_value
    AND mi.med_identifier_type_cd=desc_code_value
    AND mi.flex_type_cd=system_code_value
    AND mi.primary_ind=1
    AND mi.med_product_id=0
    AND mi.active_ind=1)
  ORDER BY md.item_id
  HEAD md.item_id
   lcnt = locateval(idx,1,value(tcnt),ocir.catalog_cd,temp_qual->ords[idx].catalog_code)
   IF (lcnt > 0)
    temp_qual->ords[lcnt].product_ind = 1
   ENDIF
  WITH nocounter, expand = 1
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(tcnt)),
   (dummyt d2  WITH seq = 1),
   ocs_facility_r ofr
  PLAN (d1
   WHERE (temp_qual->ords[d1.seq].syn_cnt > 0)
    AND maxrec(d2,size(temp_qual->ords[d1.seq].syns,5)))
   JOIN (d2)
   JOIN (ofr
   WHERE (ofr.synonym_id=temp_qual->ords[d1.seq].syns[d2.seq].syn_id)
    AND (ofr.facility_cd=request->facility_code_value))
  ORDER BY ofr.synonym_id
  HEAD ofr.synonym_id
   temp_qual->ords[d1.seq].load_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(tcnt)),
   (dummyt d2  WITH seq = 1),
   ord_cat_sent_r ocsr,
   filter_entity_reltn f,
   order_sentence os
  PLAN (d1
   WHERE (temp_qual->ords[d1.seq].load_ind=1)
    AND (temp_qual->ords[d1.seq].syn_cnt > 0)
    AND maxrec(d2,size(temp_qual->ords[d1.seq].syns,5)))
   JOIN (d2)
   JOIN (ocsr
   WHERE (ocsr.synonym_id=temp_qual->ords[d1.seq].syns[d2.seq].syn_id))
   JOIN (f
   WHERE f.parent_entity_id=ocsr.order_sentence_id
    AND f.parent_entity_name="ORDER_SENTENCE"
    AND (((f.filter_entity1_id=request->facility_code_value)) OR (f.filter_entity1_id=0))
    AND f.filter_entity1_name="LOCATION")
   JOIN (os
   WHERE os.order_sentence_id=f.parent_entity_id
    AND (os.order_encntr_group_cd=request->encntr_grp_code_value)
    AND (os.usage_flag=request->usage_flag))
  ORDER BY ocsr.synonym_id
  HEAD ocsr.synonym_id
   temp_qual->ords[d1.seq].load_ind = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(tcnt))
  PLAN (d1
   WHERE (temp_qual->ords[d1.seq].load_ind=1)
    AND (temp_qual->ords[d1.seq].product_ind=1))
  ORDER BY d1.seq
  HEAD REPORT
   cnt = 0, stat = alterlist(reply->orders,tcnt)
  HEAD d1.seq
   cnt = (cnt+ 1), reply->orders[cnt].catalog_code_value = temp_qual->ords[d1.seq].catalog_code,
   reply->orders[cnt].description = temp_qual->ords[d1.seq].desc,
   reply->orders[cnt].primary_mnemonic = temp_qual->ords[d1.seq].primary_m
  FOOT REPORT
   stat = alterlist(reply->orders,cnt)
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
