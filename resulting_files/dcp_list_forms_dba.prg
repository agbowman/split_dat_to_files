CREATE PROGRAM dcp_list_forms:dba
 SELECT
  r.*
  FROM dcp_forms_ref r
  WHERE r.active_ind=1
  ORDER BY r.description
  HEAD REPORT
   CALL print("DCP_FORMS_REF_ID"), col 20,
   CALL print("DESCRIPTION"),
   col 65,
   CALL print("DEFINITION"), row + 1
  DETAIL
   CALL print(trim(cnvtstring(r.dcp_forms_ref_id,20,2),3)), col 20,
   CALL print(trim(r.description)),
   col 65,
   CALL print(trim(r.definition)), row + 1
 ;end select
END GO
