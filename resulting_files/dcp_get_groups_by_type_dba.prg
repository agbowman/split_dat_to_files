CREATE PROGRAM dcp_get_groups_by_type:dba
 RECORD reply(
   1 qual[*]
     2 log_grouping_cd = f8
     2 logical_group_desc = vc
     2 comp_type_cd = f8
     2 log_grouping_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE knt = i4
 DECLARE idx = i4
 DECLARE dcp_script_version = vc
 SELECT INTO "NL:"
  FROM (dummyt d  WITH seq = value(size(request->exception_type,5))),
   log_group_type lgt_1,
   log_group_type lgt_2,
   logical_grouping lg
  PLAN (d
   WHERE d.seq > 0)
   JOIN (lgt_1
   WHERE (lgt_1.exception_type_cd=request->exception_type[d.seq].exception_type_cd))
   JOIN (lgt_2
   WHERE lgt_2.log_grouping_cd=lgt_1.log_grouping_cd)
   JOIN (lg
   WHERE lg.log_grouping_cd=lgt_1.log_grouping_cd)
  ORDER BY lgt_1.log_grouping_cd
  HEAD REPORT
   knt = 0, stat = alterlist(reply->qual,10)
  HEAD lgt_1.log_grouping_cd
   add_group_cd = true, idx = 0
  DETAIL
   IF (add_group_cd=true)
    ipos = 0, num = 0, idx = (idx+ 1),
    ipos = locateval(num,1,size(request->exception_type,5),lgt_2.exception_type_cd,request->
     exception_type[num].exception_type_cd)
    IF (ipos < 1)
     add_group_cd = false
    ENDIF
   ENDIF
  FOOT  lgt_1.log_grouping_cd
   IF (add_group_cd=true
    AND (idx=(size(request->exception_type,5) * size(request->exception_type,5))))
    knt = (knt+ 1)
    IF (mod(knt,10)=1
     AND knt != 1)
     stat = alterlist(reply->qual,(knt+ 9))
    ENDIF
    reply->qual[knt].log_grouping_cd = lg.log_grouping_cd, reply->qual[knt].logical_group_desc = lg
    .logical_group_desc, reply->qual[knt].comp_type_cd = lg.comp_type_cd,
    reply->qual[knt].log_grouping_type_cd = lg.log_grouping_type_cd
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,knt)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET dcp_script_version = "000 01/02/07 JD5581"
END GO
