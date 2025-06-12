CREATE PROGRAM ch_get_dist:dba
 RECORD reply(
   1 qual[*]
     2 distribution_id = f8
     2 dist_descr = vc
     2 logical_domain_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE dist_cnt = i4
 DECLARE where_clause = vc
 DECLARE name = vc
 DECLARE nameupper = vc
 DECLARE getdistributions(null) = null
 DECLARE getdistributionsbyids(null) = null
 SET dist_cnt = size(request->distribution_ids,5)
 SET name = trim(request->dist_name,3)
 IF (size(name) > 0)
  SET nameupper = concat('"',trim(cnvtupper(name),3),'*"')
  SET where_clause = build2("cnvtupper(c.dist_descr) = patstring(",nameupper,
   ") and c.distribution_id > 0")
  CALL getdistributions(null)
 ELSEIF (dist_cnt=0)
  SET where_clause = "c.distribution_id >= request->start_name and c.active_ind = 1"
  CALL getdistributions(null)
 ELSE
  CALL getdistributionsbyids(null)
 ENDIF
 CALL echo(where_clause)
 SUBROUTINE getdistributions(null)
   SELECT DISTINCT INTO "nl:"
    FROM chart_distribution c
    WHERE parser(where_clause)
    ORDER BY cnvtupper(c.dist_descr), c.distribution_id
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].dist_descr = c.dist_descr, reply->qual[count1].distribution_id = c
     .distribution_id, reply->qual[count1].logical_domain_id = c.logical_domain_id
    FOOT REPORT
     stat = alterlist(reply->qual,count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE getdistributionsbyids(null)
   DECLARE bind_cnt = i4 WITH constant(20)
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH constant((ceil((cnvtreal(dist_cnt)/ bind_cnt)) * bind_cnt)),
   protect
   SET stat = alterlist(request->distribution_ids,noptimizedtotal)
   FOR (i = (dist_cnt+ 1) TO noptimizedtotal)
     SET request->distribution_ids[i].distribution_id = request->distribution_ids[dist_cnt].
     distribution_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     chart_distribution c
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (c
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),c.distribution_id,request->
      distribution_ids[idx].distribution_id,
      bind_cnt))
    ORDER BY cnvtupper(c.dist_descr), c.distribution_id
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 += 1
     IF (mod(count1,10)=1)
      stat = alterlist(reply->qual,(count1+ 9))
     ENDIF
     reply->qual[count1].dist_descr = c.dist_descr, reply->qual[count1].distribution_id = c
     .distribution_id, reply->qual[count1].logical_domain_id = c.logical_domain_id
    FOOT REPORT
     stat = alterlist(reply->qual,count1)
    WITH nocounter
   ;end select
 END ;Subroutine
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
