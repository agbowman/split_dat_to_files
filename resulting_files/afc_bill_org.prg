CREATE PROGRAM afc_bill_org
 CALL echo(build("Executing afc_bill_org UPDATE...    Count1 is :",count1))
 CALL echo(build("TG String : ",tg_string))
 UPDATE  FROM bill_org_payor b,
   (dummyt d1  WITH seq = value(parent_entity->pe_qual))
  SET b.parent_entity_name =
   IF ((parent_entity->pe[d1.seq].bill_org_type_cd=wl_group_cv)) "WORKLOAD_STANDARD"
   ELSEIF ( $1) "CODE_VALUE"
   ELSE " "
   ENDIF
  PLAN (d1)
   JOIN (b
   WHERE (b.org_payor_id=parent_entity->pe[d1.seq].org_payor_id))
  WITH nocounter
 ;end update
 COMMIT
 FREE SET parent_entity
END GO
