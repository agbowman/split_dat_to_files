CREATE PROGRAM br_set_nv_def_sel_ind:dba
 RECORD temp(
   1 nlist[*]
     2 br_client_id = f8
     2 br_nv_key1 = vc
     2 br_name = vc
 )
 SET ncnt = 0
 SELECT INTO "nl:"
  FROM br_name_value_temp bt
  PLAN (bt
   WHERE bt.br_name_value_id > 0)
  DETAIL
   ncnt = (ncnt+ 1), stat = alterlist(temp->nlist,ncnt), temp->nlist[ncnt].br_client_id = bt
   .br_client_id,
   temp->nlist[ncnt].br_nv_key1 = bt.br_nv_key1, temp->nlist[ncnt].br_name = bt.br_name
  WITH nocounter, skipbedrock = 1
 ;end select
 FOR (x = 1 TO ncnt)
   UPDATE  FROM br_name_value b
    SET b.default_selected_ind = 1
    WHERE (b.br_client_id=temp->nlist[x].br_client_id)
     AND (b.br_nv_key1=temp->nlist[x].br_nv_key1)
     AND (b.br_name=temp->nlist[x].br_name)
    WITH nocounter, skipbedrock = 1
   ;end update
 ENDFOR
END GO
