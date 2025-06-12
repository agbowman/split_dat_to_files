CREATE PROGRAM bed_get_sn_items_list:dba
 FREE SET reply
 RECORD reply(
   1 ilist[*]
     2 item_id = f8
     2 clinical_description = c255
     2 long_description = c255
     2 item_number = c255
     2 manufacturer_number = c255
     2 set_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
   1 too_many_results_ind = i2
 )
 SET reply->status_data.status = "F"
 SET reply->too_many_results_ind = 0
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
 SET item_master_cd = 0.0
 SET item_equip_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11001
   AND cv.cdf_meaning IN ("ITEM_MASTER", "ITEM_EQP")
   AND cv.active_ind=1
  DETAIL
   IF (cv.cdf_meaning="ITEM_MASTER")
    item_master_cd = cv.code_value
   ELSEIF (cv.cdf_meaning="ITEM_EQP")
    item_equip_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SET class_instance_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=11027
   AND cv.cdf_meaning="ITEM_CLASS"
   AND cv.active_ind=1
  DETAIL
   class_instance_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE maxitem = i4
 IF ((request->item_class_id > 0.0))
  SET maxitem = 10002
 ELSE
  SET maxitem = 1002
 ENDIF
 CALL echo(build("***** maxitem = ",maxitem))
 DECLARE search_string = vc
 SET search_string = "*"
 IF ((request->search_type_flag="S"))
  SET search_string = concat('"',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
 ELSE
  SET search_string = concat('"*',trim(cnvtupper(cnvtalphanum(request->search_string))),'*"')
 ENDIF
 SET search_string = cnvtupper(search_string)
 DECLARE clin_desc_parse = vc
 DECLARE long_desc_parse = vc
 DECLARE item_nbr_parse = vc
 DECLARE manu_nbr_parse = vc
 IF ((request->search_by_ind=2)
  AND (request->search_string > " ")
  AND (request->search_type_flag > " "))
  SET long_desc_parse = build("oii1.parent_entity_id+0		    = id.item_id",
   " and oii1.parent_entity_name	    = 'ITEM_DEFINITION'"," and oii1.identifier_type_cd	    = ",
   long_desc_cd," and oii1.generic_object+0		    = 0",
   " and oii1.relationship_type_cd+0	= 0.0"," and oii1.active_ind			    = 1",
   " and oii1.value_key		        = ",search_string)
 ELSE
  SET long_desc_parse = build("oii1.parent_entity_id		    	= id.item_id",
   " and oii1.parent_entity_name	    = 'ITEM_DEFINITION'"," and oii1.identifier_type_cd+0	    = ",
   long_desc_cd," and oii1.generic_object+0		    = 0",
   " and oii1.relationship_type_cd+0	= 0.0"," and oii1.active_ind			    = 1")
 ENDIF
 IF ((request->search_by_ind=3)
  AND (request->search_string > " ")
  AND (request->search_type_flag > " "))
  SET item_nbr_parse = build("oii2.parent_entity_id+0			= id.item_id",
   " and oii2.parent_entity_name	    = 'ITEM_DEFINITION'"," and oii2.identifier_type_cd	    = ",
   item_nbr_cd," and oii2.generic_object+0		    = 0",
   " and oii2.relationship_type_cd+0	= 0.0"," and oii2.active_ind			    = 1",
   " and oii2.value_key		        = ",search_string)
 ELSE
  SET item_nbr_parse = build("oii2.parent_entity_id			    = outerjoin(id.item_id)",
   " and oii2.parent_entity_name	    = outerjoin('ITEM_DEFINITION')",
   " and oii2.identifier_type_cd+0	    = outerjoin(",item_nbr_cd,")",
   " and oii2.generic_object+0		    = outerjoin(0)",
   " and oii2.relationship_type_cd+0	= outerjoin(0.0)"," and oii2.active_ind			    = outerjoin(1)")
 ENDIF
 IF ((request->search_by_ind=1)
  AND (request->search_string > " ")
  AND (request->search_type_flag > " "))
  SET clin_desc_parse = build("oii3.parent_entity_id+0			= id.item_id",
   " and oii3.identifier_type_cd    	= ",clin_desc_cd," and oii3.generic_object+0		    = 0",
   " and oii3.relationship_type_cd+0	= 0.0",
   " and oii3.active_ind			    = 1"," and oii3.value_key		        = ",search_string)
 ELSE
  SET clin_desc_parse = build("oii3.parent_entity_id			    = outerjoin(id.item_id)",
   " and oii3.identifier_type_cd+0  	= outerjoin(",clin_desc_cd,")",
   " and oii3.generic_object+0		    = outerjoin(0)",
   " and oii3.relationship_type_cd+0	= outerjoin(0.0)"," and oii3.active_ind			    = outerjoin(1)")
 ENDIF
 IF ((request->search_by_ind=4)
  AND (request->search_string > " ")
  AND (request->search_type_flag > " "))
  SET manu_nbr_parse = build("oii4.parent_entity_id+0			= id.item_id",
   " and oii4.parent_entity_name	    = 'ITEM_DEFINITION'"," and oii4.identifier_type_cd	    = ",
   manu_nbr_cd," and oii4.generic_object+0		    = 0",
   " and oii4.relationship_type_cd+0 	= 0.0"," and oii4.active_ind			    = 1",
   " and oii4.value_key		        = ",search_string)
 ELSE
  SET manu_nbr_parse = build("oii4.parent_entity_id			    = outerjoin(id.item_id)",
   " and oii4.parent_entity_name	    = outerjoin('ITEM_DEFINITION')",
   " and oii4.identifier_type_cd+0	    = outerjoin(",manu_nbr_cd,")",
   " and oii4.generic_object+0		    = outerjoin(0)",
   " and oii4.relationship_type_cd+0	= outerjoin(0.0)"," and oii4.active_ind			    = outerjoin(1)")
 ENDIF
 SET icnt = 0
 SET alterlist_icnt = 0
 SET stat = alterlist(reply->ilist,100)
 IF ((request->item_class_id > 0))
  SELECT INTO "NL:"
   FROM item_definition id,
    item_class_node_r icnr,
    object_identifier_index oii1,
    object_identifier_index oii2,
    object_identifier_index oii3,
    object_identifier_index oii4
   PLAN (id
    WHERE id.item_type_cd IN (item_master_cd, item_equip_cd))
    JOIN (icnr
    WHERE icnr.item_id=id.item_id
     AND (icnr.class_node_id=request->item_class_id)
     AND icnr.class_instance_cd=class_instance_cd)
    JOIN (oii1
    WHERE parser(long_desc_parse))
    JOIN (oii2
    WHERE parser(item_nbr_parse))
    JOIN (oii3
    WHERE parser(clin_desc_parse))
    JOIN (oii4
    WHERE parser(manu_nbr_parse))
   DETAIL
    icnt = (icnt+ 1), alterlist_icnt = (alterlist_icnt+ 1)
    IF (alterlist_icnt > 100)
     stat = alterlist(reply->ilist,(icnt+ 100)), alterlist_icnt = 1
    ENDIF
    reply->ilist[icnt].item_id = id.item_id, reply->ilist[icnt].set_ind = id.component_ind, reply->
    ilist[icnt].long_description = oii1.value,
    reply->ilist[icnt].item_number = oii2.value, reply->ilist[icnt].clinical_description = oii3.value,
    reply->ilist[icnt].manufacturer_number = oii4.value
   WITH nocounter, maxqual(id,value(maxitem))
  ;end select
 ELSE
  SELECT INTO "NL:"
   FROM item_definition id,
    object_identifier_index oii1,
    object_identifier_index oii2,
    object_identifier_index oii3,
    object_identifier_index oii4
   PLAN (id
    WHERE id.item_type_cd IN (item_master_cd, item_equip_cd))
    JOIN (oii1
    WHERE parser(long_desc_parse))
    JOIN (oii2
    WHERE parser(item_nbr_parse))
    JOIN (oii3
    WHERE parser(clin_desc_parse))
    JOIN (oii4
    WHERE parser(manu_nbr_parse))
   DETAIL
    icnt = (icnt+ 1), alterlist_icnt = (alterlist_icnt+ 1)
    IF (alterlist_icnt > 100)
     stat = alterlist(reply->ilist,(icnt+ 100)), alterlist_icnt = 1
    ENDIF
    reply->ilist[icnt].item_id = id.item_id, reply->ilist[icnt].set_ind = id.component_ind, reply->
    ilist[icnt].long_description = oii1.value,
    reply->ilist[icnt].item_number = oii2.value, reply->ilist[icnt].clinical_description = oii3.value,
    reply->ilist[icnt].manufacturer_number = oii4.value
   WITH nocounter, maxqual(id,value(maxitem))
  ;end select
 ENDIF
 SET stat = alterlist(reply->ilist,icnt)
 CALL echo(build("***** icnt = ",icnt))
 IF ((icnt > (maxitem - 2)))
  SET stat = alterlist(reply->ilist,0)
  SET reply->too_many_results_ind = 1
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
