CREATE PROGRAM dcp_add_encntr_event_set_io:dba
 SET modify = predeclare
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 event_set_cd = f8
     2 event_set_name = vc
     2 insert_flag = i4
 )
 DECLARE num = i4 WITH noconstant(0)
 DECLARE list_size = i4 WITH noconstant(size(request->qual,5))
 DECLARE stat = i4 WITH noconstant(alterlist(temp->qual,list_size))
 DECLARE counter = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM v500_event_set_code v
  WHERE expand(num,1,list_size,v.event_set_cd,request->qual[num].event_set_cd)
  HEAD REPORT
   counter = 0
  DETAIL
   counter = (counter+ 1), cnt = locateval(num,1,list_size,v.event_set_cd,request->qual[num].
    event_set_cd), temp->qual[counter].event_set_cd = request->qual[cnt].event_set_cd,
   temp->qual[counter].event_set_name = v.event_set_name
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM encntr_event_set_io e
  WHERE (e.person_id=request->person_id)
   AND (e.encntr_id=request->encntr_id)
   AND expand(num,1,list_size,e.event_set_name,temp->qual[num].event_set_name)
  DETAIL
   cnt = locateval(num,1,list_size,e.event_set_name,temp->qual[num].event_set_name), temp->qual[cnt].
   insert_flag = 1
  WITH counter
 ;end select
 INSERT  FROM encntr_event_set_io e,
   (dummyt d  WITH seq = value(list_size))
  SET e.encntr_event_set_io_id = seq(carenet_seq,nextval), e.person_id = request->person_id, e
   .encntr_id = request->encntr_id,
   e.event_set_name = temp->qual[d.seq].event_set_name, e.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   e.updt_id = reqinfo->updt_id,
   e.updt_applctx = reqinfo->updt_applctx, e.updt_cnt = 0, e.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (temp->qual[d.seq].insert_flag=0))
   JOIN (e)
  WITH nocounter
 ;end insert
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
