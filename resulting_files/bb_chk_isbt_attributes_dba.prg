CREATE PROGRAM bb_chk_isbt_attributes:dba
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 SET row_count = 0
 SELECT INTO "nl:"
  *
  FROM bb_isbt_attribute bia
  WHERE bia.bb_isbt_attribute_id > 0
  DETAIL
   row_count = (row_count+ 1)
  WITH nocounter
 ;end select
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus=0)
  IF (row_count=255)
   SELECT INTO "nl:"
    *
    FROM common_data_foundation cdf
    WHERE code_set=1612
     AND cdf_meaning="SPTYP"
     AND display="Modifier/Attribute"
    WITH nocounter
   ;end select
   SET nerrorstatus = error(serrormsg,0)
   IF (nerrorstatus=0)
    IF (curqual > 0)
     SET request->setup_proc[1].success_ind = 1
    ELSE
     SET request->setup_proc[1].success_ind = 0
    ENDIF
   ELSE
    SET request->setup_proc[1].success_ind = 0
   ENDIF
  ELSE
   SET request->setup_proc[1].success_ind = 0
  ENDIF
 ELSE
  SET request->setup_proc[1].success_ind = 0
 ENDIF
 EXECUTE dm_add_upt_setup_proc_log
END GO
