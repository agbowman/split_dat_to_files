CREATE PROGRAM bhs_mod_gendoc_fldr:dba
 DECLARE ml_idx = i4 WITH protect, noconstant(0)
 DECLARE ml_epicnt = i4 WITH protect, noconstant(0)
 DECLARE ml_ecnt = i4 WITH protect, noconstant(0)
 DECLARE ml_obr32pos = i4 WITH protect, noconstant(0)
 DECLARE mf_prsnl_id = f8 WITH protect, noconstant(0.0)
 DECLARE ml_phys_ind = i2 WITH protect, noconstant(0)
 DECLARE ml_pos1 = i4 WITH protect, noconstant(0)
 DECLARE ms_slice_1 = vc WITH protect, noconstant("")
 DECLARE ms_slice_2 = vc WITH protect, noconstant("")
 SET ml_epicnt = size(oen_reply->cerner[1].encntr_prsnl_info,5)
 IF (ml_epicnt > 0)
  SET ml_ecnt = size(oen_reply->cerner[1].encntr_prsnl_info[1].encntr,5)
  IF (ml_ecnt > 0)
   SET ml_obr32pos = locateval(ml_idx,1,ml_ecnt,"OBR_32_1",oen_reply->cerner[1].encntr_prsnl_info[1].
    encntr[ml_idx].reln_type_cdf)
   IF (ml_obr32pos != 0)
    SET mf_prsnl_id = cnvtreal(oen_reply->cerner[1].encntr_prsnl_info[1].encntr[ml_obr32pos].prsnl_r[
     1].prsnl_person_id)
   ENDIF
   IF (mf_prsnl_id != 0.0)
    IF ((oen_reply->res_oru_group[1].obr.result_status IN ("F", "C")))
     SELECT INTO "nl:"
      FROM prsnl p
      WHERE p.person_id=mf_prsnl_id
       AND p.active_ind=1
       AND p.beg_effective_dt_tm < sysdate
       AND p.end_effective_dt_tm > sysdate
      DETAIL
       ml_phys_ind = p.physician_ind
      WITH nocounter
     ;end select
     IF (ml_phys_ind != 0)
      SET ml_pos1 = findstring("^",oen_reply->res_oru_group[1].obr[1].univ_service_id[1].identifier,1,
       0)
      IF (ml_pos1 > 0)
       SET ms_slice_1 = substring(1,(ml_pos1 - 1),oen_reply->res_oru_group[1].obr[1].univ_service_id[
        1].identifier)
       SET ms_slice_2 = substring(ml_pos1,size(oen_reply->res_oru_group[1].obr[1].univ_service_id[1].
         identifier),oen_reply->res_oru_group[1].obr[1].univ_service_id[1].identifier)
       SET oen_reply->res_oru_group[1].obr[1].univ_service_id[1].identifier = concat(ms_slice_1," P",
        trim(ms_slice_2))
      ELSE
       SET oen_reply->res_oru_group[1].obr[1].univ_service_id[1].identifier = concat(oen_reply->
        res_oru_group[1].obr[1].univ_service_id[1].identifier," P")
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ENDIF
#end_mod_gendoc
END GO
