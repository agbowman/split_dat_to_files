CREATE PROGRAM bed_get_sn_itemset_comps:dba
 FREE SET reply
 RECORD reply(
   1 ilist[*]
     2 item_id = f8
     2 item_number = c255
     2 long_description = c255
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET item_nbr_cd = 0.0
 SET long_desc_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11000
   AND cv.cdf_meaning IN ("ITEM_NBR", "DESC")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="ITEM_NBR")
    item_nbr_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="DESC")
    long_desc_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET icnt = 0
 SET alterlist_icnt = 0
 SET stat = alterlist(reply->ilist,20)
 SELECT INTO "NL"
  FROM item_component ic,
   object_identifier_index oii1,
   object_identifier_index oii2
  PLAN (ic
   WHERE (ic.item_id=request->item_id))
   JOIN (oii2
   WHERE oii2.parent_entity_id=ic.component_id
    AND oii2.parent_entity_name="ITEM_DEFINITION"
    AND ((oii2.identifier_type_cd+ 0)=long_desc_cd)
    AND oii2.generic_object=0
    AND oii2.relationship_type_cd=0.0
    AND oii2.active_ind=1)
   JOIN (oii1
   WHERE oii1.parent_entity_id=outerjoin(ic.component_id)
    AND oii1.parent_entity_name=outerjoin("ITEM_DEFINITION")
    AND ((oii1.identifier_type_cd+ 0)=outerjoin(item_nbr_cd))
    AND oii1.generic_object=outerjoin(0)
    AND oii1.relationship_type_cd=outerjoin(0.0)
    AND oii1.active_ind=outerjoin(1))
  DETAIL
   icnt = (icnt+ 1), alterlist_icnt = (alterlist_icnt+ 1)
   IF (alterlist_icnt > 20)
    stat = alterlist(reply->ilist,(icnt+ 20)), alterlist_icnt = 1
   ENDIF
   reply->ilist[icnt].item_id = ic.component_id, reply->ilist[icnt].item_number = oii1.value, reply->
   ilist[icnt].long_description = oii2.value
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->ilist,icnt)
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
