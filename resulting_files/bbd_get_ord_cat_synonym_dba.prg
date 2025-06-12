CREATE PROGRAM bbd_get_ord_cat_synonym:dba
 RECORD reply(
   1 oe_format_id = f8
   1 catalog_type_cd = f8
   1 catalog_cd = f8
   1 routine_cd = f8
   1 routine_disp = c40
   1 routine_mean = c12
   1 specimen_type_cd = f8
   1 specimen_type_disp = c40
   1 specimen_type_mean = c12
   1 qual[*]
     2 oe_format_id = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 synonym_id = f8
     2 mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET routine_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(1905,"2",1,routine_cd)
 SET reply->routine_cd = routine_cd
 SELECT INTO "nl:"
  o1.synonym_id
  FROM order_catalog_synonym o1,
   cs_component c,
   order_catalog_synonym o2,
   procedure_specimen_type p
  PLAN (o1
   WHERE (o1.synonym_id=request->synonym_id)
    AND o1.active_ind=1)
   JOIN (c
   WHERE c.catalog_cd=o1.catalog_cd)
   JOIN (o2
   WHERE o2.synonym_id=c.comp_id
    AND o2.active_ind=1)
   JOIN (p
   WHERE p.catalog_cd=o2.catalog_cd)
  ORDER BY o1.synonym_id
  HEAD o1.synonym_id
   reply->oe_format_id = o1.oe_format_id, reply->catalog_type_cd = o1.catalog_type_cd, reply->
   catalog_cd = o1.catalog_cd,
   reply->specimen_type_cd = p.specimen_type_cd
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].oe_format_id = o2
   .oe_format_id,
   reply->qual[count].catalog_type_cd = o2.catalog_type_cd, reply->qual[count].catalog_cd = o2
   .catalog_cd, reply->qual[count].synonym_id = o2.synonym_id,
   reply->qual[count].mnemonic = o2.mnemonic
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#end_script
END GO
