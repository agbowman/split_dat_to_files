CREATE PROGRAM aps_get_printers:dba
 RECORD reply(
   1 sts = i4
   1 count = i4
   1 qual[60]
     2 name = c31
     2 node = c6
     2 dev_name = c31
     2 desc = c255
     2 status = i4
   1 qcontext
     2 name = c31
     2 node = c6
     2 dev_name = c21
     2 desc = c76
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD context(
   1 name = c31
   1 node = c6
   1 dev_name = c31
   1 desc = c255
 )
 SET qcount = 0
 SET tcount = 0
 SET sts = 0
 IF (validate(request->qcontext.name,"false") != "false")
  IF (trim(request->qcontext.name) != "")
   SET context->name = request->qcontext.name
  ENDIF
  IF (trim(request->qcontext.node) != "")
   SET context->node = request->qcontext.node
  ENDIF
  IF (trim(request->qcontext.dev_name) != "")
   SET context->dev_name = request->qcontext.dev_name
  ENDIF
 ENDIF
 SET context->name = nullterm(trim(context->name))
 SET context->dev_name = nullterm(trim(context->dev_name))
 SET context->node = nullterm(trim(context->node))
 SET sts = 2
 WHILE (sts=2)
   SET sts = 94
   CALL uar_get_queues(sts,qcount,reply->qual[tcount],context)
   IF (sts=1)
    SET reply->status_data.status = "S"
    FREE SET context
   ELSEIF (sts=2)
    SET tcount = (tcount+ qcount)
    SET stat = alter(reply->qual,(tcount+ 60))
    SET reply->status_data.status = "S"
    SET context->name = nullterm(trim(context->name))
    SET context->dev_name = nullterm(trim(context->dev_name))
    SET context->node = nullterm(trim(context->node))
   ELSEIF (sts=3)
    SET reply->status_data.status = "Z"
    FREE SET context
   ELSE
    SET reply->status_data.status = "F"
    FREE SET context
   ENDIF
 ENDWHILE
 SET reply->sts = sts
 SET reply->count = (tcount+ qcount)
 SET stat = alter(reply->qual,reply->count)
END GO
