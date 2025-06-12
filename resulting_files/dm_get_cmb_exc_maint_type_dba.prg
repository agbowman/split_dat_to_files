CREATE PROGRAM dm_get_cmb_exc_maint_type:dba
 IF (validate(dgcemt_request->parent_entity,"X")="X")
  RECORD dgcemt_request(
    1 parent_entity = c30
    1 child_entity = c30
    1 op_type = c10
  )
 ENDIF
 IF ((validate(dgcemt_reply->cust_script_ind,- (1))=- (1)))
  RECORD dgcemt_reply(
    1 cust_script_ind = i2
    1 status = c1
    1 err_msg = c255
  )
 ENDIF
 SET dgcemt_reply->cust_script_ind = 0
 SET dgcemt_reply->status = "F"
 SET dgcemt_reply->err_msg = " "
 SELECT INTO "nl:"
  d.info_domain
  FROM dm_info d
  WHERE d.info_domain=concat(dgcemt_request->op_type,"_EXCEPTION:",cnvtupper(dgcemt_request->
    parent_entity))
   AND (d.info_name=dgcemt_request->child_entity)
  DETAIL
   dgcemt_reply->cust_script_ind = 1, dgcemt_reply->status = "S"
  WITH nocounter
 ;end select
 IF ((dgcemt_reply->cust_script_ind=0))
  IF (error(dgcemt_reply->err_msg,1) != 0)
   SET dgcemt_reply->status = "F"
  ELSE
   SET dgcemt_reply->status = "S"
  ENDIF
 ENDIF
END GO
