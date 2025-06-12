CREATE PROGRAM dm_omf_client_copy
 FREE SET clist
 RECORD clist(
   1 numclients = i4
   1 list[*]
     2 client_id = f8
     2 hospital_name = c80
 )
 SET clist->numclients = 0
 SELECT DISTINCT INTO "nl:"
  me.client_id_fl01
  FROM ub92_mon_encounter me
  WHERE  NOT (me.client_id_fl01 IN (
  (SELECT INTO "nl:"
   ooc.client_id
   FROM omf_outcome_client ooc
   WITH nocounter)))
  ORDER BY me.client_id_fl01
  DETAIL
   clist->numclients = (clist->numclients+ 1)
   IF (mod(clist->numclients,10)=1)
    stat = alterlist(clist->list,(clist->numclients+ 9))
   ENDIF
   clist->list[clist->numclients].client_id = me.client_id_fl01, clist->list[clist->numclients].
   hospital_name = me.client_name_fl01
  WITH nocounter, outerjoin = ooc
 ;end select
 IF (curqual != 0)
  INSERT  FROM omf_outcome_client ooc,
    (dummyt d  WITH seq = value(clist->numclients))
   SET ooc.client_id = clist->list[d.seq].client_id, ooc.hospital_name = clist->list[d.seq].
    hospital_name, ooc.health_system_name = clist->list[d.seq].hospital_name,
    ooc.health_plan_name = clist->list[d.seq].hospital_name
   PLAN (d)
    JOIN (ooc)
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
END GO
