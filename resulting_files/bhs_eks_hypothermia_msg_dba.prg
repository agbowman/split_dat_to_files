CREATE PROGRAM bhs_eks_hypothermia_msg:dba
 SET eid = trigger_encntrid
 DECLARE name = vc
 DECLARE mrn = vc
 DECLARE loc = vc
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   encounter e,
   person p
  PLAN (ea
   WHERE ea.encntr_id=eid
    AND ea.encntr_alias_type_cd=1079
    AND ea.end_effective_dt_tm > sysdate
    AND ea.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (p
   WHERE p.person_id=e.person_id)
  DETAIL
   name = trim(p.name_full_formatted), mrn = trim(ea.alias), loc = trim(concat(uar_get_code_display(e
      .loc_nurse_unit_cd)," ",uar_get_code_display(e.loc_room_cd)," ",uar_get_code_display(e
      .loc_bed_cd)))
  WITH nocounter
 ;end select
 SET log_message = build2("Name: ",name," ","MRN: ",mrn,
  " ","Loc: ",loc)
 SET log_misc1 = build2("Name: ",name," ","MRN: ",mrn,
  "    ","Loc: ",loc)
 SET retval = 100
END GO
