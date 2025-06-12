CREATE PROGRAM dep_role_cat_restriction_reltn:dba
 SET readme_data->status = "F"
 SET readme_data->message = "Beginning readme to update dep_role_cat_restriction_reltn"
 SELECT INTO "nl:"
  FROM dep_role_cat_restriction_reltn rcr,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d1)
   JOIN (rcr
   WHERE rcr.role_id=cnvtreal(requestin->list_0[d1.seq].role_id)
    AND rcr.category_id=cnvtreal(requestin->list_0[d1.seq].category_id)
    AND rcr.dep_env_id=dep_env_id)
  DETAIL
   requestin->list_0[d1.seq].exists_ind = "1"
  WITH nocounter
 ;end select
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_cat_restriction_reltn SELECT:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 INSERT  FROM dep_role_cat_restriction_reltn rcr,
   (dummyt d1  WITH seq = value(size(requestin->list_0,5)))
  SET rcr.role_id = cnvtreal(requestin->list_0[d1.seq].role_id), rcr.category_id = cnvtreal(requestin
    ->list_0[d1.seq].category_id), rcr.dep_env_id = dep_env_id
  PLAN (d1
   WHERE (requestin->list_0[d1.seq].exists_ind != "1"))
   JOIN (rcr)
  WITH nocounter
 ;end insert
 IF (error(string_struct_c->ms_err_msg,0) != 0)
  SET readme_data->message = concat("Failure during dep_role_cat_restriction_reltn INSERT:",
   string_struct_c->ms_err_msg)
  GO TO enditnow
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "EUC role/category relationship list inserted successfully"
#enditnow
 IF ((readme_data->status="S"))
  COMMIT
 ELSE
  ROLLBACK
 ENDIF
END GO
