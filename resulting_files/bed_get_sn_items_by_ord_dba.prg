CREATE PROGRAM bed_get_sn_items_by_ord:dba
 FREE SET reply
 RECORD reply(
   1 slist[*]
     2 ilist[*]
       3 item_id = f8
       3 long_description = c255
       3 clinical_description = c255
       3 item_number = c255
       3 manufacturer_number = c255
       3 set_ind = i2
       3 open_qty = i4
       3 hold_qty = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET use_specialty_ind = 0
 IF (validate(request->use_specialty_ind))
  SET use_specialty_ind = request->use_specialty_ind
 ENDIF
 SET clin_desc_cd = 0.0
 SET long_desc_cd = 0.0
 SET item_nbr_cd = 0.0
 SET manu_nbr_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning IN ("DESC_CLINIC", "DESC", "ITEM_NBR", "MANF_ITM_NBR")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="DESC_CLINIC")
    clin_desc_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DESC")
    long_desc_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ITEM_NBR")
    item_nbr_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="MANF_ITM_NBR")
    manu_nbr_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET scnt = 0
 SET scnt = size(request->sa_list,5)
 SET stat = alterlist(reply->slist,scnt)
 IF (scnt > 0)
  IF (use_specialty_ind=0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = scnt),
     preference_card pc,
     pref_card_pick_list pl,
     item_definition id,
     object_identifier_index oii1,
     object_identifier_index oii2,
     object_identifier_index oii3,
     object_identifier_index oii4
    PLAN (d)
     JOIN (pc
     WHERE (pc.catalog_cd=request->catalog_code_value)
      AND (pc.surg_area_cd=request->sa_list[d.seq].surg_area_code_value)
      AND (pc.prsnl_id=request->surgeon_id))
     JOIN (pl
     WHERE pl.pref_card_id=pc.pref_card_id
      AND pl.active_ind=1)
     JOIN (id
     WHERE id.item_id=pl.item_id)
     JOIN (oii1
     WHERE oii1.parent_entity_id=pl.item_id
      AND oii1.parent_entity_name="ITEM_DEFINITION"
      AND ((oii1.identifier_type_cd+ 0)=long_desc_cd)
      AND oii1.generic_object=0
      AND oii1.relationship_type_cd=0.0
      AND oii1.active_ind=1)
     JOIN (oii2
     WHERE oii2.parent_entity_id=outerjoin(pl.item_id)
      AND oii2.parent_entity_name=outerjoin("ITEM_DEFINITION")
      AND ((oii2.identifier_type_cd+ 0)=outerjoin(clin_desc_cd))
      AND oii2.generic_object=outerjoin(0)
      AND oii2.relationship_type_cd=outerjoin(0.0)
      AND oii2.active_ind=outerjoin(1))
     JOIN (oii3
     WHERE oii3.parent_entity_id=outerjoin(pl.item_id)
      AND oii3.parent_entity_name=outerjoin("ITEM_DEFINITION")
      AND ((oii3.identifier_type_cd+ 0)=outerjoin(item_nbr_cd))
      AND oii3.generic_object=outerjoin(0)
      AND oii3.relationship_type_cd=outerjoin(0.0)
      AND oii3.active_ind=outerjoin(1))
     JOIN (oii4
     WHERE oii4.parent_entity_id=outerjoin(pl.item_id)
      AND oii4.parent_entity_name=outerjoin("ITEM_DEFINITION")
      AND ((oii4.identifier_type_cd+ 0)=outerjoin(manu_nbr_cd))
      AND oii4.generic_object=outerjoin(0)
      AND oii4.relationship_type_cd=outerjoin(0.0)
      AND oii4.active_ind=outerjoin(1))
    ORDER BY pc.surg_area_cd, id.item_id
    HEAD pc.surg_area_cd
     icnt = 0, alterlist_icnt = 0, stat = alterlist(reply->slist[d.seq].ilist,20)
    HEAD id.item_id
     icnt = (icnt+ 1), alterlist_icnt = (alterlist_icnt+ 1)
     IF (alterlist_icnt > 20)
      stat = alterlist(reply->slist[d.seq].ilist,(icnt+ 20)), alterlist_icnt = 1
     ENDIF
     reply->slist[d.seq].ilist[icnt].item_id = pl.item_id, reply->slist[d.seq].ilist[icnt].
     long_description = oii1.value, reply->slist[d.seq].ilist[icnt].clinical_description = oii2.value,
     reply->slist[d.seq].ilist[icnt].item_number = oii3.value, reply->slist[d.seq].ilist[icnt].
     manufacturer_number = oii4.value, reply->slist[d.seq].ilist[icnt].set_ind = id.component_ind,
     reply->slist[d.seq].ilist[icnt].open_qty = pl.request_open_qty, reply->slist[d.seq].ilist[icnt].
     hold_qty = pl.request_hold_qty
    FOOT  pc.surg_area_cd
     stat = alterlist(reply->slist[d.seq].ilist,icnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = scnt),
     preference_card pc,
     pref_card_pick_list pl,
     item_definition id,
     object_identifier_index oii1,
     object_identifier_index oii2,
     object_identifier_index oii3,
     object_identifier_index oii4
    PLAN (d)
     JOIN (pc
     WHERE (pc.catalog_cd=request->catalog_code_value)
      AND (pc.surg_area_cd=request->sa_list[d.seq].surg_area_code_value)
      AND (pc.prsnl_id=request->surgeon_id)
      AND (pc.surg_specialty_id=request->sa_list[d.seq].specialty_id))
     JOIN (pl
     WHERE pl.pref_card_id=pc.pref_card_id
      AND pl.active_ind=1)
     JOIN (id
     WHERE id.item_id=pl.item_id)
     JOIN (oii1
     WHERE oii1.parent_entity_id=pl.item_id
      AND oii1.parent_entity_name="ITEM_DEFINITION"
      AND ((oii1.identifier_type_cd+ 0)=long_desc_cd)
      AND oii1.generic_object=0
      AND oii1.relationship_type_cd=0.0
      AND oii1.active_ind=1)
     JOIN (oii2
     WHERE oii2.parent_entity_id=outerjoin(pl.item_id)
      AND oii2.parent_entity_name=outerjoin("ITEM_DEFINITION")
      AND ((oii2.identifier_type_cd+ 0)=outerjoin(clin_desc_cd))
      AND oii2.generic_object=outerjoin(0)
      AND oii2.relationship_type_cd=outerjoin(0.0)
      AND oii2.active_ind=outerjoin(1))
     JOIN (oii3
     WHERE oii3.parent_entity_id=outerjoin(pl.item_id)
      AND oii3.parent_entity_name=outerjoin("ITEM_DEFINITION")
      AND ((oii3.identifier_type_cd+ 0)=outerjoin(item_nbr_cd))
      AND oii3.generic_object=outerjoin(0)
      AND oii3.relationship_type_cd=outerjoin(0.0)
      AND oii3.active_ind=outerjoin(1))
     JOIN (oii4
     WHERE oii4.parent_entity_id=outerjoin(pl.item_id)
      AND oii4.parent_entity_name=outerjoin("ITEM_DEFINITION")
      AND ((oii4.identifier_type_cd+ 0)=outerjoin(manu_nbr_cd))
      AND oii4.generic_object=outerjoin(0)
      AND oii4.relationship_type_cd=outerjoin(0.0)
      AND oii4.active_ind=outerjoin(1))
    ORDER BY pc.surg_area_cd, id.item_id
    HEAD pc.surg_area_cd
     icnt = 0, alterlist_icnt = 0, stat = alterlist(reply->slist[d.seq].ilist,20)
    HEAD id.item_id
     icnt = (icnt+ 1), alterlist_icnt = (alterlist_icnt+ 1)
     IF (alterlist_icnt > 20)
      stat = alterlist(reply->slist[d.seq].ilist,(icnt+ 20)), alterlist_icnt = 1
     ENDIF
     reply->slist[d.seq].ilist[icnt].item_id = pl.item_id, reply->slist[d.seq].ilist[icnt].
     long_description = oii1.value, reply->slist[d.seq].ilist[icnt].clinical_description = oii2.value,
     reply->slist[d.seq].ilist[icnt].item_number = oii3.value, reply->slist[d.seq].ilist[icnt].
     manufacturer_number = oii4.value, reply->slist[d.seq].ilist[icnt].set_ind = id.component_ind,
     reply->slist[d.seq].ilist[icnt].open_qty = pl.request_open_qty, reply->slist[d.seq].ilist[icnt].
     hold_qty = pl.request_hold_qty
    FOOT  pc.surg_area_cd
     stat = alterlist(reply->slist[d.seq].ilist,icnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
