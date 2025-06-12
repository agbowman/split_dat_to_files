CREATE PROGRAM bhs_athn_get_position_by_id
 RECORD orequest(
   1 all_pos_ind = i2
   1 positions[*]
     2 position_cd = f8
   1 prsnl_id = f8
   1 position_cd = f8
 )
 RECORD out_rec(
   1 position_disp = vc
   1 position_mean = vc
   1 position_value = vc
   1 relationships[*]
     2 relationship_type_disp = vc
     2 relationship_type_mean = vc
     2 relationship_type_value = vc
 )
 SET orequest->prsnl_id =  $2
 SET stat = tdbexecute(3200000,3200001,3200002,"REC",orequest,
  "REC",oreply)
 SET out_rec->position_disp = uar_get_code_display(oreply->positions[1].position_cd)
 SET out_rec->position_mean = uar_get_code_meaning(oreply->positions[1].position_cd)
 SET out_rec->position_value = trim(cnvtstring(oreply->positions[1].position_cd))
 SET stat = alterlist(out_rec->relationships,size(oreply->positions[1].types,5))
 FOR (i = 1 TO size(oreply->positions[1].types,5))
   SET out_rec->relationships[i].relationship_type_disp = uar_get_code_display(oreply->positions[1].
    types[i].ppr_cd)
   SET out_rec->relationships[i].relationship_type_mean = uar_get_code_meaning(oreply->positions[1].
    types[i].ppr_cd)
   SET out_rec->relationships[i].relationship_type_value = trim(cnvtstring(oreply->positions[1].
     types[i].ppr_cd))
 ENDFOR
 CALL echojson(out_rec, $1)
END GO
