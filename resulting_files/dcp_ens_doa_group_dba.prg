CREATE PROGRAM dcp_ens_doa_group:dba
 RECORD requestdoa(
   1 person_id = f8
   1 prsnl_id = f8
   1 created_by_id = f8
   1 beg_effective_dt_tm = dq8
   1 end_effective_dt_tm = dq8
   1 reason_cd = f8
   1 comment_txt = c300
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE maxqualsize = i4 WITH public, noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE i = i4 WITH protect, noconstant(0)
 SET modify = predeclare
 SET reply->status_data.status = "S"
 SET maxqualsize = size(request->qual,5)
 IF (maxqualsize=0)
  SET stat = alterlist(request->qual,1)
  SET request->qual[1].person_id = 0
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO maxqualsize)
   SET stat = initrec(requestdoa)
   SET requestdoa->person_id = request->qual[i].person_id
   SET requestdoa->prsnl_id = request->qual[i].prsnl_id
   SET requestdoa->created_by_id = request->qual[i].created_by_id
   SET requestdoa->comment_txt = request->comment_txt
   SET requestdoa->beg_effective_dt_tm = cnvtdatetime(request->qual[i].beg_effective_dt_tm)
   SET requestdoa->reason_cd = validate(request->reason_cd,0)
   EXECUTE dcp_ens_doa  WITH replace("REQUEST",requestdoa)
 ENDFOR
#exit_script
END GO
