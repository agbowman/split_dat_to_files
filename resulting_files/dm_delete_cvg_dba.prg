CREATE PROGRAM dm_delete_cvg:dba
 CALL echo("start dm_delete_cvg")
 IF (dmrequest->delete_ind)
  FREE SET arr
  RECORD arr(
    1 new_p_code_value = f8
    1 new_c_code_value = f8
  )
  SET arr->new_p_code_value = 0
  SET arr->new_c_code_value = 0
  SELECT INTO "nl:"
   c.code_value
   FROM code_value c
   WHERE (((c.cki=dmrequest->p_cki)) OR ((c.cki=dmrequest->c_cki)))
   DETAIL
    IF ((c.cki=dmrequest->p_cki))
     arr->new_p_code_value = c.code_value
    ENDIF
    IF ((c.cki=dmrequest->c_cki))
     arr->new_c_code_value = c.code_value
    ENDIF
   WITH nocounter
  ;end select
  SET delcnt = 0
  IF ((arr->new_p_code_value > 0)
   AND (arr->new_c_code_value > 0))
   DELETE  FROM code_value_group cg
    WHERE (cg.parent_code_value=arr->new_p_code_value)
     AND (cg.child_code_value=arr->new_c_code_value)
     AND (cg.code_set=dmrequest->child_code_set)
    WITH nocounter
   ;end delete
  ELSE
   SET cs_reply->cs_fail = 1
   SET reply->status_data.status = "F"
  ENDIF
 ENDIF
END GO
