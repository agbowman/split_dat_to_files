CREATE PROGRAM cp_add_fields_to_cdfv_table:dba
 SET nbr_selected = 0
 SET nbr_updated = 0
 SELECT INTO "nl:"
  cdfv.parent_entity_name
  FROM chart_dist_filter_value cdfv
  WHERE trim(cdfv.parent_entity_name)=null
   AND cdfv.distribution_id != 0
  WITH nocounter
 ;end select
 SET nbr_selected = curqual
 IF (nbr_selected > 0)
  UPDATE  FROM chart_dist_filter_value cdfv
   SET cdfv.parent_entity_name = evaluate(cdfv.type_flag,1,"ORGANIZATION",2,"PRSNL",
     "CODE_VALUE")
   WHERE cdfv.distribution_id != 0
  ;end update
  IF (curqual > 0)
   SET nbr_updated = curqual
  ENDIF
 ENDIF
 IF (nbr_selected=nbr_updated)
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
