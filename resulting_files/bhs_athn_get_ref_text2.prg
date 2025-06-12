CREATE PROGRAM bhs_athn_get_ref_text2
 RECORD orequest(
   1 parent_entity_id = f8
   1 parent_entity_name = vc
   1 facility_cd = f8
   1 text_type_cd = f8
 )
 SET orequest->parent_entity_id =  $2
 SET orequest->parent_entity_name = "ORDER_CATALOG"
 SET orequest->facility_cd =  $3
 SET stat = tdbexecute(961000,968400,500670,"REC",orequest,
  "REC",oreply)
 CALL echojson(oreply, $1)
END GO
