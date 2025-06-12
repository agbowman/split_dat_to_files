CREATE PROGRAM bhs_athn_get_pools_by_prsnl_id
 RECORD orequest(
   1 call_echo_ind = i2
   1 entity_qual[*]
     2 entity_id = f8
     2 entity_name = vc
   1 inactive_ineffective_ind = i2
 )
 RECORD prequest(
   1 call_echo_ind = i2
   1 load
     2 prsnl_group_ind = i2
     2 prsnl_group_reltn_ind = i2
     2 prsnl_group_org_reltn_ind = i2
   1 entity_qual[*]
     2 entity_id = f8
   1 inactive_ineffective_ind = i2
 )
 RECORD out_rec(
   1 pool_groups[*]
     2 pool_group_id = vc
     2 pool_group_name = vc
 )
 DECLARE poolgroup_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"POOLGROUP"))
 DECLARE cnt = i4
 SET stat = alterlist(orequest->entity_qual,1)
 SET orequest->entity_qual[1].entity_id =  $2
 SET stat = tdbexecute(600005,3202004,115418,"REC",orequest,
  "REC",oreply)
 SET prequest->load.prsnl_group_ind = 1
 SET stat = alterlist(prequest->entity_qual,size(oreply->entity_qual[1].prsnl_group_reltn_qual,5))
 FOR (j = 1 TO size(oreply->entity_qual[1].prsnl_group_reltn_qual,5))
   SET prequest->entity_qual[j].entity_id = oreply->entity_qual[1].prsnl_group_reltn_qual[j].
   prsnl_group_id
 ENDFOR
 SET stat = tdbexecute(600005,3202004,115411,"REC",prequest,
  "REC",preply)
 FOR (i = 1 TO size(preply->entity_qual,5))
   IF ((preply->entity_qual[i].prsnl_group_class_cd=poolgroup_cd))
    SET cnt = (cnt+ 1)
    SET stat = alterlist(out_rec->pool_groups,cnt)
    SET out_rec->pool_groups[cnt].pool_group_id = trim(cnvtstring(preply->entity_qual[i].prsnl_group.
      prsnl_group_id))
    SET out_rec->pool_groups[cnt].pool_group_name = preply->entity_qual[i].prsnl_group.
    prsnl_group_name
   ENDIF
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
