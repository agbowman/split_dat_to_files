CREATE PROGRAM dcp_updt_disch_pat_asgnmnts:dba
 RECORD temp(
   1 assignments[*]
     2 assignment_id = f8
     2 end_effective_dt_tm = dq8
 )
 DECLARE selectdischasgnmnts(null) = null
 DECLARE updatedischasgnmnts(null) = null
 DECLARE status = vc WITH protect, noconstant("F")
 CALL selectdischasgnmnts(null)
 IF (size(temp->assignments,5) > 0)
  CALL updatedischasgnmnts(null)
 ENDIF
 GO TO exit_script
 SUBROUTINE selectdischasgnmnts(null)
   SELECT INTO "NL:"
    FROM (dummyt d1  WITH seq = 1),
     encounter e,
     dcp_shift_assignment dsa
    PLAN (d1)
     JOIN (dsa
     WHERE dsa.active_ind=1
      AND dsa.encntr_id > 0.0)
     JOIN (e
     WHERE e.encntr_id=dsa.encntr_id
      AND e.disch_dt_tm != null
      AND e.disch_dt_tm <= cnvtdatetime(curdate,curtime))
    HEAD REPORT
     stat = alterlist(temp->assignments,100), cnt = 0
    DETAIL
     cnt = (cnt+ 1)
     IF (mod(cnt,100)=1)
      stat = alterlist(temp->assignments,(cnt+ 99))
     ENDIF
     temp->assignments[cnt].assignment_id = dsa.assignment_id, temp->assignments[cnt].
     end_effective_dt_tm = e.disch_dt_tm
    FOOT REPORT
     stat = alterlist(temp->assignments,cnt)
    WITH nocounter
   ;end select
 END ;Subroutine
 SUBROUTINE updatedischasgnmnts(null)
   DECLARE expand_sz = i4 WITH protect, constant(50)
   DECLARE expand_strt = i4 WITH protect, noconstant(1)
   DECLARE expand_stp = i4 WITH protect, noconstant(50)
   DECLARE expand_total = i4 WITH protect, noconstant(0)
   DECLARE assignment_size = i4 WITH protect, constant(size(temp->assignments,5))
   DECLARE index = i4 WITH protect, noconstant
   DECLARE num = i4 WITH noconstant(0)
   SET expand_total = (ceil((cnvtreal(assignment_size)/ expand_sz)) * expand_sz)
   SET stat = alterlist(temp->assignments,expand_total)
   FOR (index = 1 TO expand_total)
     IF (index > assignment_size)
      SET temp->assignments[index].assignment_id = temp->assignments[assignment_size].assignment_id
      SET temp->assignments[index].end_effective_dt_tm = temp->assignments[assignment_size].
      end_effective_dt_tm
     ENDIF
   ENDFOR
   UPDATE  FROM dcp_shift_assignment dsa,
     (dummyt d2  WITH seq = value((expand_total/ expand_sz)))
    SET dsa.active_ind = 0.0, dsa.updt_cnt = (dsa.updt_cnt+ 1), dsa.updt_applctx = reqinfo->
     updt_applctx,
     dsa.updt_dt_tm = cnvtdatetime(curdate,curtime), dsa.updt_task = reqinfo->updt_task, dsa.updt_id
      = reqinfo->updt_id,
     dsa.end_effective_dt_tm = cnvtdatetime(temp->assignments[d2.seq].end_effective_dt_tm)
    PLAN (d2
     WHERE assign(expand_strt,evaluate(d2.seq,1,1,(expand_strt+ expand_sz)))
      AND assign(expand_stp,(expand_strt+ (expand_sz - 1))))
     JOIN (dsa
     WHERE expand(num,expand_strt,expand_stp,dsa.assignment_id,temp->assignments[num].assignment_id))
    WITH nocounter
   ;end update
   IF (curqual > 0)
    SET status = "S"
   ELSEIF (curqual=0)
    SET status = "Z"
   ENDIF
 END ;Subroutine
#exit_script
 IF (status="S")
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
 FREE RECORD temp
END GO
