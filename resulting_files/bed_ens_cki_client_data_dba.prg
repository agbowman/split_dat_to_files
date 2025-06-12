CREATE PROGRAM bed_ens_cki_client_data:dba
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
 SET reply->status_data.status = "F"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET failed = "N"
 RECORD temp(
   1 qual[*]
     2 client_id = f8
     2 data_type_id = f8
     2 field_1 = vc
     2 field_2 = vc
     2 field_3 = vc
     2 field_4 = vc
     2 field_5 = vc
     2 field_6 = vc
     2 field_7 = vc
     2 field_8 = vc
     2 field_9 = vc
     2 field_10 = vc
     2 field_11 = vc
     2 field_12 = vc
     2 field_13 = vc
     2 field_14 = vc
     2 field_15 = vc
 )
 SET rcnt = size(request->rlist,5)
 SET stat = alterlist(temp->qual,rcnt)
 FOR (x = 1 TO rcnt)
   SET temp->qual[x].client_id = request->client_id
   SET temp->qual[x].data_type_id = request->data_type_id
   FOR (y = 1 TO size(request->rlist[x].flist,5))
     IF (y=1)
      SET temp->qual[x].field_1 = request->rlist[x].flist[y].field
     ELSEIF (y=2)
      SET temp->qual[x].field_2 = cnvtupper(request->rlist[x].flist[y].field)
     ELSEIF (y=3)
      SET temp->qual[x].field_3 = cnvtupper(request->rlist[x].flist[y].field)
     ELSEIF (y=4)
      SET temp->qual[x].field_4 = request->rlist[x].flist[y].field
     ELSEIF (y=5)
      SET temp->qual[x].field_5 = request->rlist[x].flist[y].field
     ELSEIF (y=6)
      SET temp->qual[x].field_6 = request->rlist[x].flist[y].field
     ELSEIF (y=7)
      SET temp->qual[x].field_7 = request->rlist[x].flist[y].field
     ELSEIF (y=8)
      SET temp->qual[x].field_8 = request->rlist[x].flist[y].field
     ELSEIF (y=9)
      SET temp->qual[x].field_9 = request->rlist[x].flist[y].field
     ELSEIF (y=10)
      SET temp->qual[x].field_10 = request->rlist[x].flist[y].field
     ELSEIF (y=11)
      SET temp->qual[x].field_11 = request->rlist[x].flist[y].field
     ELSEIF (y=12)
      SET temp->qual[x].field_12 = request->rlist[x].flist[y].field
     ELSEIF (y=13)
      SET temp->qual[x].field_13 = request->rlist[x].flist[y].field
     ELSEIF (y=14)
      SET temp->qual[x].field_14 = request->rlist[x].flist[y].field
     ELSEIF (y=15)
      SET temp->qual[x].field_15 = request->rlist[x].flist[y].field
     ENDIF
   ENDFOR
 ENDFOR
 SET ierrcode = 0
 INSERT  FROM br_cki_client_data b,
   (dummyt d  WITH seq = value(size(temp->qual,5)))
  SET b.seq = 1, b.br_cki_client_data_id = seq(bedrock_seq,nextval), b.client_id = temp->qual[d.seq].
   client_id,
   b.data_type_id = temp->qual[d.seq].data_type_id, b.field_1 = temp->qual[d.seq].field_1, b.field_2
    = temp->qual[d.seq].field_2,
   b.field_3 = temp->qual[d.seq].field_3, b.field_4 = temp->qual[d.seq].field_4, b.field_5 = temp->
   qual[d.seq].field_5,
   b.field_6 = temp->qual[d.seq].field_6, b.field_7 = temp->qual[d.seq].field_7, b.field_8 = temp->
   qual[d.seq].field_8,
   b.field_9 = temp->qual[d.seq].field_9, b.field_10 = temp->qual[d.seq].field_10, b.field_11 = temp
   ->qual[d.seq].field_11,
   b.field_12 = temp->qual[d.seq].field_12, b.field_13 = temp->qual[d.seq].field_13, b.field_14 =
   temp->qual[d.seq].field_14,
   b.field_15 = temp->qual[d.seq].field_15, b.updt_cnt = 0, b.updt_dt_tm = cnvtdatetime(curdate,
    curtime),
   b.updt_id = reqinfo->updt_id, b.updt_task = reqinfo->updt_task, b.updt_applctx = reqinfo->
   updt_applctx
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
