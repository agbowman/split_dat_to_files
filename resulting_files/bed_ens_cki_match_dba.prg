CREATE PROGRAM bed_ens_cki_match:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 client_id = f8
     2 data_type_id = f8
     2 data_item_id = vc
     2 data_item_name = vc
     2 concept_cki = vc
     2 millennium_value = f8
     2 millennium_name = vc
     2 cki_found = i2
 )
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 SET mcnt = size(request->mlist,5)
 SET stat = alterlist(temp->qual,mcnt)
 FOR (x = 1 TO mcnt)
   SET temp->qual[x].client_id = request->client_id
   SET temp->qual[x].data_type_id = request->data_type_id
   SET temp->qual[x].data_item_id = request->mlist[x].data_item_id
   SET temp->qual[x].concept_cki = request->mlist[x].cki
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   br_cki_client_data b
  PLAN (d)
   JOIN (b
   WHERE (b.field_10=temp->qual[d.seq].data_item_id))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].data_item_name = b.field_2
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   order_catalog oc
  PLAN (d)
   JOIN (oc
   WHERE (oc.concept_cki=temp->qual[d.seq].concept_cki))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].millennium_value = oc.catalog_cd, temp->qual[d.seq].millennium_name = oc
   .primary_mnemonic, temp->qual[d.seq].cki_found = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(temp->qual,5))),
   br_auto_order_catalog oc
  PLAN (d
   WHERE (temp->qual[d.seq].cki_found=0))
   JOIN (oc
   WHERE (oc.concept_cki=temp->qual[d.seq].concept_cki))
  ORDER BY d.seq
  HEAD d.seq
   temp->qual[d.seq].millennium_value = oc.catalog_cd, temp->qual[d.seq].millennium_name = oc
   .primary_mnemonic, temp->qual[d.seq].cki_found = 1
  WITH nocounter
 ;end select
 SET ierrcode = 0
 INSERT  FROM br_cki_match b,
   (dummyt d  WITH seq = value(size(temp->qual,5)))
  SET b.seq = 1, b.br_cki_match_id = seq(bedrock_seq,nextval), b.client_id = temp->qual[d.seq].
   client_id,
   b.data_type_id = temp->qual[d.seq].data_type_id, b.data_item_name = temp->qual[d.seq].
   data_item_name, b.data_item_id = temp->qual[d.seq].data_item_id,
   b.concept_cki = temp->qual[d.seq].concept_cki, b.millennium_value = temp->qual[d.seq].
   millennium_value, b.millennium_name = temp->qual[d.seq].millennium_name,
   b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,curtime), b.updt_id = reqinfo->updt_id,
   b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->updt_applctx
  PLAN (d)
   JOIN (b)
  WITH nocounter
 ;end insert
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = "Y"
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="Y")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
