CREATE PROGRAM ccl_ord_reports
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "ORD Report:" = "DEACMTREQ06",
  "Person:" = 299887.0,
  "Orders:" = value(9182098.0,343594.0,0.0)
  WITH outdev, ordreports, person,
  ords
 FREE RECORD request
 RECORD request(
   1 person_id = f8
   1 print_prsnl_id = f8
   1 order_qual[*]
     2 order_id = f8
     2 encntr_id = f8
     2 conversation_id = f8
   1 printer_name = vc
 )
 DECLARE finddot = i4 WITH noconstant(findstring(".", $OUTDEV,1,1)), protect
 DECLARE ordfilename = vc WITH noconstant( $OUTDEV), protect
 DECLARE hrtf = i4 WITH noconstant(0), protect
 DECLARE stat = i4 WITH noconstant(0), protect
 DECLARE pg = i4 WITH noconstant(0), protect
 DECLARE cont = i4 WITH noconstant(0), protect
 DECLARE nstop = i4 WITH noconstant(0), protect
 DECLARE par = f8 WITH noconstant(1.0), protect
 DECLARE parnum = i4 WITH noconstant(0), protect
 DECLARE ctype = c20 WITH protect
 DECLARE cnt = i4 WITH noconstant(1), protect
 SET request->print_prsnl_id = reqinfo->updt_id
 SET request->person_id =  $PERSON
 SET ctype = reflect(parameter(4,0))
 IF (substring(1,1,ctype)="L")
  SET nstop = cnvtint(substring(2,19,ctype))
 ELSE
  SET nstop = 1
 ENDIF
 WHILE (parnum < nstop)
   SET parnum += 1
   SET par = parameter(4,parnum)
   CALL echo(par)
   IF (par > 0.0)
    SET stat = alterlist(request->order_qual,cnt)
    SET request->order_qual[cnt].order_id = par
    SET par = parameter(4,(parnum+ 1))
    SET request->order_qual[cnt].encntr_id = par
    SET par = parameter(4,(parnum+ 2))
    SET request->order_qual[cnt].conversation_id = par
    SET parnum += 2
    SET cnt += 1
   ENDIF
   CALL echo(reflect( $4))
 ENDWHILE
 SET request->printer_name = ordfilename
 EXECUTE value(cnvtupper( $ORDREPORTS))
 SET modify = nopredeclare
END GO
