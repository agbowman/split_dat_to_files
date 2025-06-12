CREATE PROGRAM bhs_combine_audit_nperson_t
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "UserName" = "*",
  "Please enter start date" = "SYSDATE",
  "End Date" = "SYSDATE"
  WITH outdev, username, start_dt_tm,
  end_dt_tm
 SELECT DISTINCT INTO  $OUTDEV
  user = pr.username, user_name = pr.name_full_formatted, frommrn = pa.alias,
  toperson = pa1.alias, time = format(pcd.updt_dt_tm,"dd-mmm-yyyy hh:mm:ss ;;d")
  FROM person_combine pc,
   person_combine_det pcd,
   prsnl pr,
   person_alias pa,
   person_alias pa1,
   person p
  PLAN (pc
   WHERE pc.updt_dt_tm BETWEEN cnvtdatetime( $START_DT_TM) AND cnvtdatetime( $END_DT_TM)
    AND pc.active_ind=1)
   JOIN (pcd
   WHERE ((pcd.person_combine_id=pc.person_combine_id
    AND pcd.entity_name IN ("PERSON_ALIAS", "ENCNTR_ALIAS")
    AND pc.encntr_id=0) OR (pcd.person_combine_det_id=0)) )
   JOIN (pr
   WHERE pr.person_id=pc.updt_id
    AND pr.username=patstring( $2))
   JOIN (p
   WHERE pc.to_person_id=p.person_id)
   JOIN (pa
   WHERE ((((pc.encntr_id > 0
    AND pa.person_id=pc.from_person_id) OR (pc.encntr_id=0
    AND pa.person_alias_id=pcd.entity_id))
    AND ((pa.person_alias_type_cd+ 0)=2.0)) OR (pa.person_alias_id=0)) )
   JOIN (pa1
   WHERE pa1.person_id=pc.to_person_id
    AND ((pa1.person_alias_type_cd+ 0)=2.0)
    AND ((pa1.active_ind+ 0)=1))
  ORDER BY pr.username, pc.to_person_id
  WITH nocounter, separator = " ", format,
   time = 300
 ;end select
END GO
