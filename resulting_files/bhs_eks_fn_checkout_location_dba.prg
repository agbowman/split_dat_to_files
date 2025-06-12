CREATE PROGRAM bhs_eks_fn_checkout_location:dba
 DECLARE mf_edhold_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"EDHOLD")), protect
 DECLARE mf_edhld_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"EDHLD")), protect
 DECLARE mf_eshp_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESHP")), protect
 DECLARE mf_eshld_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,"ESHLD")), protect
 DECLARE log_misc1 = vc WITH noconstant(" ")
 DECLARE retval = i4 WITH noconstant(0), public
 SELECT INTO "nl:"
  nunit = uar_get_code_display(tl.loc_nurse_unit_cd), room = uar_get_code_display(tl.loc_room_cd),
  bed = uar_get_code_display(tl.loc_bed_cd)
  FROM tracking_item ti,
   tracking_locator tl,
   code_value cv
  PLAN (ti
   WHERE ti.encntr_id=trigger_encntrid
    AND ti.active_ind=1)
   JOIN (tl
   WHERE ti.tracking_id=tl.tracking_id
    AND  NOT (tl.loc_nurse_unit_cd IN (mf_edhold_cd, mf_edhld_cd, mf_eshp_cd, mf_eshld_cd)))
   JOIN (cv
   WHERE cv.code_set=220
    AND cv.code_value=tl.loc_room_cd
    AND cv.display_key != "CHECKOUT")
  ORDER BY ti.encntr_id, tl.arrive_dt_tm DESC
  HEAD ti.encntr_id
   log_misc1 = build(nunit,", ",room,", ",bed),
   CALL echo(log_misc1)
 ;end select
 SET retval = 100 WITH nocounter, maxrec = 1
#exit_script
END GO
