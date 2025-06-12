CREATE PROGRAM bhs_eks_get_death_info
 DECLARE expiredobv_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDOBV")), protect
 DECLARE expiredes_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDES")), protect
 DECLARE expireddaystay_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDDAYSTAY")),
 protect
 DECLARE expiredip_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",71,"EXPIREDIP")), protect
 SET eid = link_encntrid
 SET pid = trigger_personid
 SET deceased = uar_get_code_by("displaykey",268,"EXPIRED")
 DECLARE pat_name = vc
 DECLARE admit_date = vc
 DECLARE pat_loc = vc
 DECLARE att_md = vc
 DECLARE fin_nbr = vc
 SET retval = 0
 SELECT INTO "nl:"
  FROM encounter e
  WHERE e.encntr_id=eid
   AND e.encntr_type_cd IN (expiredobv_var, expiredes_var, expireddaystay_var, expiredip_var)
  WITH nocounter
 ;end select
 IF (curqual=1)
  SELECT INTO "nl:"
   FROM pm_transaction pm
   WHERE pm.n_encntr_id=eid
    AND pm.n_encntr_type_cd IN (expiredobv_var, expiredes_var, expireddaystay_var, expiredip_var)
   DETAIL
    pat_name = trim(pm.n_name_formatted), admit_date = trim(format(pm.n_reg_dt_tm,"mm/dd/yyyy;;q")),
    pat_loc = concat(trim(uar_get_code_display(pm.n_loc_facility_cd))," ",trim(uar_get_code_display(
       pm.n_loc_nurse_unit_cd))," ",trim(uar_get_code_display(pm.n_loc_room_cd))),
    att_md = trim(pm.n_attend_doc_name), fin_nbr = trim(pm.n_fin_nbr)
   WITH nocounter
  ;end select
  SET log_misc1 = concat(pat_name," was admitted to ",pat_loc," on ",admit_date,
   " and has expired. Doctor ",att_md," was this patient's attending physician. ",
   "You have received this notification because you ",
   "were listed in CIS as the patient's primary care physician.",
   "fin:",fin_nbr)
  SET retval = 100
 ELSE
  SET log_message = build("Encntrid:",eid)
 ENDIF
END GO
