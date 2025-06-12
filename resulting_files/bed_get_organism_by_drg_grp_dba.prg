CREATE PROGRAM bed_get_organism_by_drg_grp:dba
 FREE SET reply
 RECORD reply(
   1 drug_groups[*]
     2 drg_grp_id = f8
     2 name = vc
     2 organism[*]
       3 category_type_ind = i2
       3 organism_cd = f8
       3 display = vc
       3 description = vc
       3 category_id = f8
       3 category_name = vc
       3 br_mdro_cat_organism_id = f8
       3 name_id = f8
       3 name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = 0
 SET cnt = size(request->drug_groups,5)
 FOR (i = 1 TO cnt)
   SELECT INTO "NL:"
    FROM br_drug_group dg,
     br_drug_group_organism dgo,
     br_mdro_cat_organism cato,
     br_mdro_cat cat,
     br_mdro nm,
     code_value cv
    PLAN (dg
     WHERE (dg.br_drug_group_id=request->drug_groups[i].drg_grp_id)
      AND (dg.drug_group_name=request->drug_groups[i].name))
     JOIN (dgo
     WHERE dgo.br_drug_group_id=dg.br_drug_group_id)
     JOIN (cato
     WHERE cato.br_mdro_cat_organism_id=dgo.br_mdro_cat_organism_id)
     JOIN (cat
     WHERE cat.br_mdro_cat_id=cato.br_mdro_cat_id)
     JOIN (nm
     WHERE nm.br_mdro_id=cato.br_mdro_id)
     JOIN (cv
     WHERE cv.code_value=cato.organism_cd
      AND cv.active_ind=1)
    ORDER BY dg.br_drug_group_id, cato.br_mdro_cat_organism_id
    HEAD dg.br_drug_group_id
     tcnt = (tcnt+ 1), acnt = 0, stat = alterlist(reply->drug_groups,tcnt),
     reply->drug_groups[tcnt].drg_grp_id = dg.br_drug_group_id, reply->drug_groups[tcnt].name = dg
     .drug_group_name
    HEAD cato.br_mdro_cat_organism_id
     acnt = (acnt+ 1), stat = alterlist(reply->drug_groups[tcnt].organism,acnt), reply->drug_groups[
     tcnt].organism[acnt].br_mdro_cat_organism_id = cato.br_mdro_cat_organism_id,
     reply->drug_groups[tcnt].organism[acnt].organism_cd = cato.organism_cd, reply->drug_groups[tcnt]
     .organism[acnt].category_type_ind = cat.cat_type_flag, reply->drug_groups[tcnt].organism[acnt].
     display = cv.display,
     reply->drug_groups[tcnt].organism[acnt].description = cv.description, reply->drug_groups[tcnt].
     organism[acnt].category_id = cat.br_mdro_cat_id, reply->drug_groups[tcnt].organism[acnt].
     category_name = cat.mdro_cat_name,
     reply->drug_groups[tcnt].organism[acnt].name_id = cato.br_mdro_id, reply->drug_groups[tcnt].
     organism[acnt].name = nm.mdro_name
    WITH nocounter
   ;end select
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
