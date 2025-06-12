CREATE PROGRAM cps_norm_str_load:dba
 RECORD reply(
   1 qual = i4
   1 nomen[*]
     2 nomen_id = f8
 )
 RECORD reqinfo(
   1 commit_ind = i2
   1 updt_id = f8
   1 position_cd = f8
   1 updt_app = i4
   1 updt_task = i4
   1 updt_req = i4
   1 updt_applctx = i4
 )
 SET reqinfo->updt_id = 0
 SET reqinfo->updt_app = 0
 SET reqinfo->updt_task = 0
 SET reqinfo->updt_req = 0
 SET reqinfo->updt_applctx = 0
 SET count1 = 0
 SET nom_id = 0
 SET count1 = 0
 SET stat = alterlist(reply->nomen,1000)
 SELECT INTO "nl:"
  n.nomenclature_id, n.source_string
  FROM nomenclature n
  PLAN (n
   WHERE n.nomenclature_id > nom_id
    AND n.source_string > " ")
  DETAIL
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 != 1)
    stat = alterlist(reply->nomen,(count1+ 1000))
   ENDIF
   reply->nomen[count1].nomen_id = n.nomenclature_id
  FOOT REPORT
   stat = alterlist(reply->nomen,count1), reply->qual = count1, nom_id = n.nomenclature_id
  WITH check, nocounter
 ;end select
 SET index = 0
 WHILE ((index <= reply->qual))
   SET nom_id = reply->nomen[index].nomen_id
   EXECUTE cps_ens_normalized_index nom_id
   COMMIT
   SET index = (index+ 1)
 ENDWHILE
 CALL echo(build("Nbr Nomenclature ids = ",count1),1)
END GO
