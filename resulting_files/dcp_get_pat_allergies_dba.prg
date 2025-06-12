CREATE PROGRAM dcp_get_pat_allergies:dba
 RECORD reply(
   1 alqual_cnt = i4
   1 alqual[*]
     2 allergy_id = f8
     2 person_id = f8
     2 encntr_id = f8
     2 allergy_instance_id = f8
     2 substance_nom_id = f8
     2 substance_display = vc
     2 onset_dt_tm = dq8
     2 severity_cd = f8
     2 severity_disp = vc
     2 source_info_cd = f8
     2 source_info_ft = vc
     2 mul_ind = i2
     2 reaction_status_cd = f8
     2 reaction_status_disp = c40
     2 reaction_cnt = i4
     2 reaction_qual[*]
       3 reaction_display = vc
       3 reaction_id = f8
       3 reaction_nom_id = f8
     2 created_prsnl_name = vc
     2 comment_ind = i2
     2 comment_cnt = i4
     2 allergy_comment[*]
       3 comment_display = vc
       3 comment_prsnl_id = f8
       3 comment_dt_tm = dq8
       3 allergy_comment_id = f8
   1 lookup_status = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET al_cnt = 0
 SET reaction_cnt = 0
 SET comment_cnt = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET active_status_cd = 0.0
 SET mulcat_cd = 0.0
 SET muldrug_cd = 0.0
 SET code_set = 12025
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_status_cd = code_value
 SET code_set = 400
 SET cdf_meaning = "MUL.ALGCAT"
 EXECUTE cpm_get_cd_for_cdf
 SET mulcat_cd = code_value
 SET code_set = 400
 SET cdf_meaning = "MUL.DRUG"
 EXECUTE cpm_get_cd_for_cdf
 SET muldrug_cd = code_value
 SELECT INTO "nl:"
  a.allergy_id, a.allergy_instance_id, r.allergy_instance_id,
  ac.allergy_comment_id, check = decode(ac.seq,"ac",r.seq,"r",a.seq,
   "a","z")
  FROM allergy a,
   (dummyt d1  WITH seq = 1),
   prsnl p,
   (dummyt d2  WITH seq = 1),
   nomenclature n,
   (dummyt d3  WITH seq = 1),
   reaction r,
   (dummyt d4  WITH seq = 1),
   allergy_comment ac,
   (dummyt d5  WITH seq = 1),
   nomenclature n2
  PLAN (a
   WHERE (a.person_id=request->person_id)
    AND a.active_ind=1
    AND a.reaction_status_cd=active_status_cd)
   JOIN (d1)
   JOIN (p
   WHERE p.person_id=a.created_prsnl_id)
   JOIN (d2)
   JOIN (n
   WHERE n.nomenclature_id=a.substance_nom_id)
   JOIN (d3)
   JOIN (((ac
   WHERE ac.allergy_id=a.allergy_id
    AND ac.allergy_instance_id=a.allergy_instance_id
    AND ac.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ac.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ) ORJOIN ((d4)
   JOIN (r
   WHERE a.allergy_id=r.allergy_id
    AND a.allergy_instance_id=r.allergy_instance_id
    AND r.active_ind=1)
   JOIN (d5)
   JOIN (n2
   WHERE n2.nomenclature_id=r.reaction_nom_id)
   ))
  HEAD REPORT
   al_cnt = 0
  HEAD a.allergy_instance_id
   reaction_cnt = 0, comment_cnt = 0, al_cnt = (al_cnt+ 1)
   IF (al_cnt > size(reply->alqual,5))
    stat = alterlist(reply->alqual,(al_cnt+ 5))
   ENDIF
   reply->alqual[al_cnt].allergy_id = a.allergy_id, reply->alqual[al_cnt].person_id = a.person_id,
   reply->alqual[al_cnt].encntr_id = a.encntr_id,
   reply->alqual[al_cnt].allergy_instance_id = a.allergy_instance_id, reply->alqual[al_cnt].
   substance_nom_id = a.substance_nom_id, reply->alqual[al_cnt].substance_display = a
   .substance_ftdesc,
   reply->alqual[al_cnt].reaction_status_cd = a.reaction_status_cd, reply->alqual[al_cnt].severity_cd
    = a.severity_cd, reply->alqual[al_cnt].source_info_cd = a.source_of_info_cd,
   reply->alqual[al_cnt].source_info_ft = a.source_of_info_ft
   IF (n.nomenclature_id > 0
    AND n.source_string > " ")
    reply->alqual[al_cnt].substance_display = n.source_string
   ENDIF
   IF (((n.source_vocabulary_cd=mulcat_cd) OR (n.source_vocabulary_cd=muldrug_cd)) )
    reply->alqual[al_cnt].mul_ind = 1
   ELSE
    reply->alqual[al_cnt].mul_ind = 0
   ENDIF
   reply->alqual[al_cnt].onset_dt_tm = a.onset_dt_tm, reply->alqual[al_cnt].severity_cd = a
   .severity_cd
   IF (p.person_id > 0)
    reply->alqual[al_cnt].created_prsnl_name = p.name_full_formatted
   ENDIF
  DETAIL
   CASE (check)
    OF "ac":
     IF (ac.allergy_comment_id > 0)
      reply->alqual[al_cnt].comment_ind = 1, comment_cnt = (comment_cnt+ 1)
      IF (comment_cnt > size(reply->alqual[al_cnt].allergy_comment,5))
       stat = alterlist(reply->alqual[al_cnt].allergy_comment,(comment_cnt+ 5))
      ENDIF
      reply->alqual[al_cnt].allergy_comment[comment_cnt].comment_display = ac.allergy_comment, reply
      ->alqual[al_cnt].allergy_comment[comment_cnt].comment_dt_tm = ac.comment_dt_tm, reply->alqual[
      al_cnt].allergy_comment[comment_cnt].comment_prsnl_id = ac.comment_prsnl_id,
      reply->alqual[al_cnt].allergy_comment[comment_cnt].allergy_comment_id = ac.allergy_comment_id
     ELSE
      reply->alqual[al_cnt].comment_ind = 0
     ENDIF
    OF "r":
     IF (r.reaction_id > 0.0)
      reaction_cnt = (reaction_cnt+ 1)
      IF (reaction_cnt > size(reply->alqual[al_cnt].reaction_qual,5))
       stat = alterlist(reply->alqual[al_cnt].reaction_qual,(reaction_cnt+ 5))
      ENDIF
      reply->alqual[al_cnt].reaction_qual[reaction_cnt].reaction_id = r.reaction_id, reply->alqual[
      al_cnt].reaction_qual[reaction_cnt].reaction_nom_id = r.reaction_nom_id
      IF (((r.reaction_ftdesc > " ") OR (n2.source_string > " ")) )
       reply->alqual[al_cnt].reaction_qual[reaction_cnt].reaction_display = r.reaction_ftdesc
       IF (n2.source_string > " ")
        reply->alqual[al_cnt].reaction_qual[reaction_cnt].reaction_display = n2.source_string
       ENDIF
      ENDIF
     ENDIF
    OF "z":
     CALL echo(build("returnted z: that means I got combined join"))
   ENDCASE
  FOOT  a.allergy_instance_id
   reply->alqual[al_cnt].reaction_cnt = reaction_cnt, stat = alterlist(reply->alqual[al_cnt].
    reaction_qual,reaction_cnt), reply->alqual[al_cnt].comment_cnt = comment_cnt,
   stat = alterlist(reply->alqual[al_cnt].allergy_comment,comment_cnt)
  FOOT REPORT
   reply->alqual_cnt = al_cnt, stat = alterlist(reply->alqual,al_cnt)
  WITH nocounter, outerjoin = d1, outerjoin = d2,
   dontcare = n, outerjoin = d3, dontcare = ac,
   outerjoin = d4, dontcare = r, outerjoin = d5,
   dontcare = n2
 ;end select
 IF (al_cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
