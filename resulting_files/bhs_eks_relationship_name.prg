CREATE PROGRAM bhs_eks_relationship_name
 PROMPT
  "Relationship Type: " = "ATTENDINGPHYSICIAN"
 SELECT INTO "relat_test"
  FROM dummyt d
  DETAIL
   col 1,  $1, row + 1,
   enc_disp = cnvtstring(link_encntrid), col 1, enc_disp,
   row + 1
  WITH nocounter
 ;end select
 DECLARE relationship_type_cd = f8
 SET relationship_type_cd = uar_get_code_by("DISPLAYKEY",333, $1)
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl pr
  PLAN (epr
   WHERE epr.encntr_id=link_encntrid
    AND epr.encntr_prsnl_r_cd=relationship_type_cd
    AND cnvtdatetime(curdate,curtime3) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm
    AND epr.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=epr.prsnl_person_id)
  ORDER BY epr.beg_effective_dt_tm
  HEAD epr.encntr_id
   cclprogram_message = pr.name_full_formatted, cclprogram_status = 1
  WITH nocounter
 ;end select
 IF (cclprogram_status != 1)
  SET cclprogram_message = "Unknown Provider"
  SET cclprogram_status = 1
 ENDIF
END GO
