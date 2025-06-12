CREATE PROGRAM bhs_eks_get_account:dba
 DECLARE mf_finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 SELECT INTO "nl:"
  FROM encntr_alias ea
  PLAN (ea
   WHERE ea.encntr_id=link_encntrid
    AND ea.encntr_alias_type_cd=mf_finnbr)
  HEAD ea.encntr_id
   cclprogram_message = trim(ea.alias,3), cclprogram_status = 1
  WITH nocounter
 ;end select
 IF (cclprogram_status != 1)
  SET cclprogram_message = "ACCOUNT not found"
  SET cclprogram_status = 1
 ENDIF
END GO
