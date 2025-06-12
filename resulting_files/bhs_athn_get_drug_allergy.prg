CREATE PROGRAM bhs_athn_get_drug_allergy
 RECORD t_record(
   1 drug_cnt = i4
   1 drug_qual[*]
     2 cki = vc
     2 long_cki = vc
 )
 RECORD out_rec(
   1 allergies[*]
     2 allergy_id = vc
     2 cki = vc
     2 drug = vc
     2 severity = vc
     2 reaction_type = vc
     2 reactions[*]
       3 reaction = vc
     2 comments[*]
       3 comment = vc
     2 source_of_info_cd = vc
     2 source_of_info_disp = vc
 )
 DECLARE drug_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12020,"DRUG"))
 DECLARE active_cd = f8 WITH public, constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE"))
 DECLARE t_line = vc
 DECLARE t_line2 = vc
 DECLARE done = i2
 SET t_line =  $3
 WHILE (done=0)
   IF (findstring(",",t_line)=0)
    SET t_record->drug_cnt = (t_record->drug_cnt+ 1)
    SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
    SET t_record->drug_qual[t_record->drug_cnt].cki = replace(t_line,"MUL.ORD!","")
    SET t_record->drug_qual[t_record->drug_cnt].long_cki = t_line
    SET done = 1
   ELSE
    SET t_record->drug_cnt = (t_record->drug_cnt+ 1)
    SET t_line2 = substring(1,(findstring(",",t_line) - 1),t_line)
    SET stat = alterlist(t_record->drug_qual,t_record->drug_cnt)
    SET t_record->drug_qual[t_record->drug_cnt].cki = replace(t_line2,"MUL.ORD!","")
    SET t_record->drug_qual[t_record->drug_cnt].long_cki = t_line2
    SET t_line = substring((findstring(",",t_line)+ 1),textlen(t_line),t_line)
   ENDIF
 ENDWHILE
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->drug_cnt),
   mltm_drug_name_map mdnm,
   order_catalog oc,
   nomenclature n,
   allergy a,
   reaction r,
   nomenclature n1
  PLAN (d)
   JOIN (mdnm
   WHERE (mdnm.drug_identifier=t_record->drug_qual[d.seq].cki))
   JOIN (oc
   WHERE (oc.cki=t_record->drug_qual[d.seq].long_cki))
   JOIN (n
   WHERE n.source_identifier=mdnm.drug_identifier)
   JOIN (a
   WHERE a.substance_nom_id=n.nomenclature_id
    AND (a.person_id= $2)
    AND a.reaction_status_cd=active_cd
    AND a.active_ind=1)
   JOIN (r
   WHERE r.allergy_id=outerjoin(a.allergy_id)
    AND r.active_ind=outerjoin(1))
   JOIN (n1
   WHERE n1.nomenclature_id=outerjoin(r.reaction_nom_id))
  ORDER BY a.allergy_id, r.reaction_id
  HEAD REPORT
   cnt = 0
  HEAD a.allergy_id
   cnt = (cnt+ 1), r_cnt = 0, ac_cnt = 0,
   stat = alterlist(out_rec->allergies,cnt), out_rec->allergies[cnt].allergy_id = trim(cnvtstring(a
     .allergy_id)), out_rec->allergies[cnt].cki = concat("MUL.ORD!",mdnm.drug_identifier),
   out_rec->allergies[cnt].drug = n.source_string, out_rec->allergies[cnt].severity =
   uar_get_code_display(a.severity_cd), out_rec->allergies[cnt].reaction_type = uar_get_code_display(
    a.reaction_class_cd),
   out_rec->allergies[cnt].source_of_info_cd = cnvtstring(a.source_of_info_cd), out_rec->allergies[
   cnt].source_of_info_disp = uar_get_code_display(a.source_of_info_cd)
  HEAD r.reaction_id
   r_cnt = (r_cnt+ 1), stat = alterlist(out_rec->allergies[cnt].reactions,r_cnt)
   IF (r.reaction_nom_id=0)
    out_rec->allergies[cnt].reactions[r_cnt].reaction = r.reaction_ftdesc
   ELSE
    out_rec->allergies[cnt].reactions[r_cnt].reaction = n1.source_string
   ENDIF
  WITH nocounter, time = 30
 ;end select
 IF (size(out_rec->allergies,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = size(out_rec->allergies,5)),
    allergy_comment ac
   PLAN (d)
    JOIN (ac
    WHERE ac.allergy_id=cnvtreal(out_rec->allergies[d.seq].allergy_id)
     AND ac.active_ind=1)
   ORDER BY ac.allergy_id, ac.allergy_comment_id DESC
   HEAD ac.allergy_id
    null, ac_cnt = 0
   HEAD ac.allergy_comment_id
    ac_cnt = (ac_cnt+ 1), stat = alterlist(out_rec->allergies[d.seq].comments,ac_cnt), out_rec->
    allergies[d.seq].comments[ac_cnt].comment = ac.allergy_comment
   WITH nocounter, time = 30
  ;end select
 ENDIF
 CALL echojson(out_rec, $1)
END GO
