CREATE PROGRAM dm_drop_ce_event_prsnl_fk:dba
 SET const_name = fillstring(30," ")
 SELECT INTO "nl:"
  ucc.*
  FROM user_constraints uc,
   user_cons_columns ucc
  WHERE uc.owner="V500"
   AND uc.table_name="CE_EVENT_PRSNL"
   AND uc.constraint_type="R"
   AND ucc.owner="V500"
   AND ucc.constraint_name=uc.constraint_name
   AND ucc.table_name=uc.table_name
   AND ucc.column_name="EVENT_PRSNL_ID"
  DETAIL
   const_name = uc.constraint_name
  WITH nocounter
 ;end select
 IF (curqual=1)
  CALL parser("rdb alter table CE_EVENT_PRSNL drop constraint ")
  CALL parser(const_name)
  CALL parser(" go ")
 ENDIF
END GO
