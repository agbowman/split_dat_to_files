CREATE PROGRAM dm_post_cont_sys
 SELECT INTO update_contributor
  FROM contributor_system@loc_mrg_link css,
   dm_merge_translate dmt,
   dm_merge_translate dmt1,
   contributor_system cst
  WHERE cst.contributor_system_cd=dmt.to_value
   AND css.contributor_system_cd=dmt.from_value
   AND dmt.table_name="CODE_VALUE"
   AND dmt1.table_name="CODE_VALUE"
   AND css.loc_facility_cd=dmt1.from_value
  DETAIL
   "update into contributor_system", row + 1, "   set loc_facility_cd=",
   dmt1.to_value, row + 1, " where contributor_system_cd = ",
   cst.contributor_system_cd, row + 1, "go",
   row + 1, "commit go", row + 3
  WITH nocounter
 ;end select
 SELECT INTO update_contributor
  FROM contributor_system@loc_mrg_link css,
   dm_merge_translate dmt,
   dm_merge_translate dmt1,
   contributor_system cst
  WHERE cst.contributor_system_cd=dmt.to_value
   AND css.contributor_system_cd=dmt.from_value
   AND dmt.table_name="CODE_VALUE"
   AND dmt1.table_name="PERSON"
   AND css.prsnl_person_id=dmt1.from_value
  DETAIL
   "update into contributor_system", row + 1, "   set prsnl_person_id=",
   dmt1.to_value, row + 1, " where contributor_system_cd = ",
   cst.contributor_system_cd, row + 1, "go",
   row + 1, "commit go", row + 3
  WITH nocounter, append
 ;end select
 CALL compile("%i ccluserdir:update_contributor.dat")
END GO
