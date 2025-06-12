CREATE PROGRAM afc_get_him_codes_for_encntr:dba
 RECORD reply(
   1 qual[*]
     2 nomenclature_id = f8
     2 source_string = vc
     2 source_identifier = vc
     2 priority = i4
 )
 DECLARE count1 = i4
 SELECT INTO "nl:"
  FROM coding c,
   diagnosis d,
   nomenclature n
  PLAN (c
   WHERE (c.encntr_id=request->encntr_id)
    AND c.active_ind=1)
   JOIN (d
   WHERE d.encntr_id=c.encntr_id
    AND d.contributor_system_cd=c.contributor_system_cd
    AND d.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  ORDER BY d.diag_priority, d.beg_effective_dt_tm
  DETAIL
   count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].nomenclature_id =
   n.nomenclature_id,
   reply->qual[count1].source_string = n.source_string, reply->qual[count1].source_identifier = n
   .source_identifier, reply->qual[count1].priority = d.diag_priority
  WITH nocounter
 ;end select
END GO
