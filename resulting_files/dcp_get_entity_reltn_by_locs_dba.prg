CREATE PROGRAM dcp_get_entity_reltn_by_locs:dba
 RECORD reply(
   1 entities[*]
     2 entity1_id = f8
     2 entity2_id = f8
     2 entity1_name = vc
     2 entity2_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 locationcds[*]
     2 location_cd = f8
 )
 DECLARE list_size = i4 WITH noconstant(0), protect
 SET reply->status_data.status = "F"
 SET list_size = size(request->location_cds,5)
 IF (list_size=0)
  GO TO exit_script
 ENDIF
 DECLARE entity_reltn_mean = c8 WITH constant("TASK/LOC"), protect
 DECLARE cnt = i4 WITH noconstant(0), protect
 DECLARE idx = i4 WITH noconstant(0), protect
 DECLARE num = i4 WITH noconstant(0), protect
 DECLARE loop_cnt = i4 WITH noconstant(0), protect
 DECLARE ntotal = i4 WITH noconstant(0), protect
 DECLARE nstart = i4 WITH noconstant(1), protect
 DECLARE nsize = i4 WITH noconstant(30), protect
 DECLARE stat = i2 WITH noconstant(0), protect
 SET loop_cnt = ceil((cnvtreal(list_size)/ nsize))
 SET ntotal = (loop_cnt * nsize)
 SET stat = alterlist(temp->locationcds,ntotal)
 FOR (idx = 1 TO list_size)
   SET temp->locationcds[idx].location_cd = request->location_cds[idx].location_cd
 ENDFOR
 FOR (idx = (list_size+ 1) TO ntotal)
   SET temp->locationcds[idx].location_cd = request->location_cds[list_size].location_cd
 ENDFOR
 SELECT DISTINCT INTO "nl:"
  FROM (dummyt d1  WITH seq = value(loop_cnt)),
   dcp_entity_reltn der
  PLAN (d1
   WHERE assign(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (der
   WHERE expand(num,nstart,(nstart+ (nsize - 1)),der.entity2_id,temp->locationcds[num].location_cd)
    AND der.entity_reltn_mean=trim(entity_reltn_mean,3)
    AND der.active_ind=1)
  ORDER BY der.entity2_id, der.entity1_id
  HEAD REPORT
   stat = alterlist(reply->entities,list_size)
  DETAIL
   cnt = (cnt+ 1)
   IF (cnt >= size(reply->entities,5))
    stat = alterlist(reply->entities,(cnt+ 10))
   ENDIF
   reply->entities[cnt].entity1_id = der.entity1_id, reply->entities[cnt].entity2_id = der.entity2_id,
   reply->entities[cnt].entity1_name = der.entity1_name,
   reply->entities[cnt].entity2_name = der.entity2_name
  FOOT REPORT
   stat = alterlist(reply->entities,cnt)
  WITH nocounter
 ;end select
 IF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE SET temp
END GO
