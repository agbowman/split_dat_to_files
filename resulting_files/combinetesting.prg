CREATE PROGRAM combinetesting
 SET cnt_fin = 0
 SET cnt_person = 0
 RECORD personcombine(
   1 qual[*]
     2 username = vc
     2 fullname = vc
     2 time = vc
       3 fromperson = vc
       3 fromfin = vc
       3 toperson = vc
       3 tofin = vc
       3 encounter = vc
         4 person_combine_id = vc
         4 en_entity_name = vc
         4 encounter_entity_id = vc
         4 person_entity_name = vc
         4 person_entity_id = vc
 )
 SELECT DISTINCT INTO "NL:"
  username = pr.username, fullname = pr.name_full_formatted, toalias = ea.alias,
  fromperson = p.name_full_formatted, toperson = p1.name_full_formatted, fromfin = pa.alias,
  tofin = pa1.alias, time = format(pc.updt_dt_tm,"dd-mmm-yyyy hh:mm:ss ;;d")
  FROM person_combine pc,
   prsnl pr,
   person p,
   person p1,
   encntr_alias ea,
   person_alias pa1,
   person_alias pa,
   person_combine_det pcd
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND pc.active_ind=1)
   JOIN (p
   WHERE p.person_id=pc.from_person_id)
   JOIN (p1
   WHERE p1.person_id=pc.to_person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(p.person_id)
    AND pa.person_alias_type_cd=outerjoin(2.0))
   JOIN (pa1
   WHERE pa1.person_id=p1.person_id
    AND pa1.person_alias_type_cd=2.0
    AND pa1.active_ind=1)
   JOIN (ea
   WHERE ea.encntr_id=outerjoin(pc.encntr_id)
    AND ea.encntr_alias_type_cd=outerjoin(1077.00))
   JOIN (pcd
   WHERE pcd.person_combine_id=pc.person_combine_id
    AND pcd.entity_name IN ("ENCNTR_ALIAS", "PERSON_ALIAS"))
   JOIN (pr
   WHERE pr.person_id=pc.updt_id
    AND pr.username=patstring( $2))
  ORDER BY pc.to_person_id, pc.from_person_id
 ;end select
END GO
