CREATE PROGRAM bhs_athn_get_prsnl_group_pool
 RECORD orequest(
   1 call_echo_ind = i2
   1 name = vc
   1 prsnl_group_type_cd = f8
   1 prsnl_group_class_cd = f8
   1 active_ind = i2
   1 active_ind_ind = i2
   1 spo_id = f8
   1 org_reltn_type_cd = f8
   1 unlimited_reply_size_ind = i2
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
     2 pool_group_desc = vc
 )
 DECLARE poolgroup_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",19189,"POOLGROUP"))
 DECLARE p_cnt = i4
 DECLARE search_string = vc
 SET orequest->prsnl_group_class_cd = poolgroup_cd
 SET orequest->active_ind = 1
 SET orequest->active_ind_ind = 1
 SET orequest->unlimited_reply_size_ind = 1
 SET stat = tdbexecute(600005,3202004,115417,"REC",orequest,
  "REC",oreply)
 SET prequest->load.prsnl_group_ind = 1
 SET stat = alterlist(prequest->entity_qual,size(oreply->prsnl_group_qual,5))
 FOR (i = 1 TO size(oreply->prsnl_group_qual,5))
   SET prequest->entity_qual[i].entity_id = oreply->prsnl_group_qual[i].prsnl_group_id
 ENDFOR
 SET stat = tdbexecute(600005,3202004,115411,"REC",prequest,
  "REC",preply)
 IF (( $2=""))
  SET stat = alterlist(out_rec->pool_groups,size(preply->entity_qual,5))
  FOR (i = 1 TO size(preply->entity_qual,5))
    SET out_rec->pool_groups[i].pool_group_id = trim(cnvtstring(preply->entity_qual[i].prsnl_group.
      prsnl_group_id))
    SET out_rec->pool_groups[i].pool_group_name = preply->entity_qual[i].prsnl_group.prsnl_group_name
    SET out_rec->pool_groups[i].pool_group_desc = preply->entity_qual[i].prsnl_group.prsnl_group_desc
  ENDFOR
 ELSE
  SET search_string = concat("*",cnvtupper( $2),"*")
  FOR (i = 1 TO size(preply->entity_qual,5))
    IF (cnvtupper(preply->entity_qual[i].prsnl_group.prsnl_group_name)=patstring(search_string))
     SET p_cnt = (p_cnt+ 1)
     SET stat = alterlist(out_rec->pool_groups,p_cnt)
     SET out_rec->pool_groups[p_cnt].pool_group_id = trim(cnvtstring(preply->entity_qual[i].
       prsnl_group.prsnl_group_id))
     SET out_rec->pool_groups[p_cnt].pool_group_name = preply->entity_qual[i].prsnl_group.
     prsnl_group_name
     SET out_rec->pool_groups[p_cnt].pool_group_desc = preply->entity_qual[i].prsnl_group.
     prsnl_group_desc
    ENDIF
  ENDFOR
 ENDIF
 CALL echojson(out_rec, $1)
END GO
