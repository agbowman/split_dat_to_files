CREATE PROGRAM bhs_fix_copy_to:dba
 DECLARE ml_bfct_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_bfct_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_bfct_rc_size = i4 WITH protect, noconstant(0)
 DECLARE ml_bfct_id_nbr = vc WITH protect, noconstant("")
 DECLARE ml_bfct_last_name = vc WITH protect, noconstant("")
 DECLARE ml_bfct_middle_name = vc WITH protect, noconstant("")
 DECLARE ml_bfct_first_name = vc WITH protect, noconstant("")
 DECLARE ml_bfct_id_type = vc WITH protect, noconstant("")
 SET ml_bfct_rc_size = size(oen_reply->order_group[1].obr_group[1].obr.result_copies,5)
 IF (ml_bfct_rc_size > 0)
  SET ml_bfct_loc = locateval(ml_bfct_loop,1,ml_bfct_rc_size,"ORGANIZATION DOCTOR",oen_reply->
   order_group[1].obr_group[1].obr.result_copies[ml_bfct_loop].id_type)
  IF (ml_bfct_loc != 0)
   SET ml_bfct_id_nbr = format(oen_reply->order_group[1].obr_group[1].obr.result_copies[ml_bfct_loc].
    id_nbr,"#####;P0;I")
   SET ml_bfct_last_name = oen_reply->order_group[1].obr_group[1].obr.result_copies[ml_bfct_loc].
   last_name
   SET ml_bfct_middle_name = oen_reply->order_group[1].obr_group[1].obr.result_copies[ml_bfct_loc].
   middle_name
   SET ml_bfct_first_name = oen_reply->order_group[1].obr_group[1].obr.result_copies[ml_bfct_loc].
   first_name
   SET ml_bfct_id_type = oen_reply->order_group[1].obr_group[1].obr.result_copies[ml_bfct_loc].
   id_type
   SET stat = alterlist(oen_reply->order_group[1].obr_group[1].obr.result_copies,0)
   SET stat = alterlist(oen_reply->order_group[1].obr_group[1].obr.result_copies,1)
   SET oen_reply->order_group[1].obr_group[1].obr.result_copies[1].id_nbr = ml_bfct_id_nbr
   SET oen_reply->order_group[1].obr_group[1].obr.result_copies[1].last_name = ml_bfct_last_name
   SET oen_reply->order_group[1].obr_group[1].obr.result_copies[1].middle_name = ml_bfct_middle_name
   SET oen_reply->order_group[1].obr_group[1].obr.result_copies[1].first_name = ml_bfct_first_name
   SET oen_reply->order_group[1].obr_group[1].obr.result_copies[1].id_type = ml_bfct_id_type
  ENDIF
 ENDIF
END GO
