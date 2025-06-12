CREATE PROGRAM bhs_athn_get_sch_resources
 RECORD out_rec(
   1 res_qual[*]
     2 resource_cd = vc
     2 resource = vc
     2 prsnl_id = vc
     2 prsnl_name = vc
     2 resource_type = vc
 )
 DECLARE r_cnt = i4
 DECLARE search_ind = i2
 DECLARE search_string = vc
 IF (( $2 > ""))
  SET search_string = concat("*",cnvtupper( $2),"*")
  SET search_ind = 1
 ENDIF
 SELECT INTO "nl:"
  FROM sch_resource sr,
   prsnl p,
   sch_res_role srr
  PLAN (sr
   WHERE sr.active_ind=1
    AND ((search_ind=0) OR (sr.mnemonic_key=patstring(search_string)))
    AND sr.res_type_flag IN (1, 2))
   JOIN (p
   WHERE (p.person_id= Outerjoin(sr.person_id)) )
   JOIN (srr
   WHERE (srr.resource_cd= Outerjoin(sr.resource_cd))
    AND (srr.active_ind= Outerjoin(1)) )
  ORDER BY sr.mnemonic
  DETAIL
   r_cnt += 1
   IF (mod(r_cnt,1000)=1)
    stat = alterlist(out_rec->res_qual,(r_cnt+ 999))
   ENDIF
   out_rec->res_qual[r_cnt].resource_cd = trim(cnvtstring(sr.resource_cd)), out_rec->res_qual[r_cnt].
   resource = sr.mnemonic, out_rec->res_qual[r_cnt].prsnl_id = trim(cnvtstring(sr.person_id)),
   out_rec->res_qual[r_cnt].prsnl_name = p.name_full_formatted
   IF (sr.res_type_flag=1)
    out_rec->res_qual[r_cnt].resource_type = "General Resource"
   ELSEIF (sr.res_type_flag=2)
    out_rec->res_qual[r_cnt].resource_type = "Personnel Resource"
   ELSEIF (sr.res_type_flag=3)
    out_rec->res_qual[r_cnt].resource_type = "Service Resource"
   ELSEIF (sr.res_type_flag=4)
    out_rec->res_qual[r_cnt].resource_type = "Item Resource"
   ENDIF
  FOOT REPORT
   stat = alterlist(out_rec->res_qual,r_cnt)
  WITH nocounter, time = 30
 ;end select
 SET _memory_reply_string = cnvtrectojson(out_rec)
END GO
