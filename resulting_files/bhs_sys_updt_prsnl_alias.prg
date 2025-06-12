CREATE PROGRAM bhs_sys_updt_prsnl_alias
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Provider ID" = 0
  WITH outdev, prompt1
 DECLARE npitypecode_320 = f8 WITH constant(uar_get_code_by("MEANING",320,"NPI")), protect
 DECLARE npipoolcode_263 = f8 WITH constant(uar_get_code_by("displaykey",263,
   "NATIONALPROVIDERIDENTIFIER")), protect
 FREE RECORD temp
 RECORD temp(
   1 cnt = i2
   1 qual[*]
     2 prsnlaliasid = f8
 )
 SELECT INTO  $1
  pa.alias, pa.alias_pool_cd, display = uar_get_code_display(pa.prsnl_alias_type_cd)
  FROM prsnl_alias pa
  WHERE (((pa.person_id= $2)) OR (( $2=999)))
   AND pa.prsnl_alias_type_cd=npitypecode_320
   AND pa.active_ind=1
   AND pa.alias_pool_cd <= 0
  ORDER BY pa.person_id
  HEAD pa.person_id
   temp->cnt = (temp->cnt+ 1), stat = alterlist(temp->qual,temp->cnt), temp->qual[temp->cnt].
   prsnlaliasid = pa.prsnl_alias_id
  WITH nocounter, format
 ;end select
 CALL echorecord(temp)
 UPDATE  FROM prsnl_alias pa,
   (dummyt d  WITH seq = value(temp->cnt))
  SET pa.alias_pool_cd = npipoolcode_263
  PLAN (d)
   JOIN (pa
   WHERE (pa.prsnl_alias_id=temp->qual[d.seq].prsnlaliasid)
    AND pa.alias_pool_cd IN (0, - (1)))
  WITH nocounter
 ;end update
 COMMIT
END GO
