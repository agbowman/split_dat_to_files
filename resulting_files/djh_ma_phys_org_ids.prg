CREATE PROGRAM djh_ma_phys_org_ids
 PROMPT
  "Output to File/Printer/MINE" = "David.Hounshell@bhs.org"
  WITH outdev
 IF (findstring("@", $1) > 0)
  SET output_dest = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"))
  SET email_ind = 1
 ELSE
  SET output_dest =  $1
  SET email_ind = 0
 ENDIF
 CALL echo(output_dest)
 CALL echo(format(date_qual,"YYYY/MM/DD;;D"))
 DECLARE output_string = vc
 SELECT DISTINCT INTO value(output_dest)
  p.name_full_formatted, p.physician_ind, p.username,
  pa.alias, p.active_ind, p.person_id,
  pa.person_id, pa_alias_pool_disp = uar_get_code_display(pa.alias_pool_cd), pa.alias_pool_cd
  FROM prsnl p,
   prsnl_alias pa
  PLAN (p
   WHERE p.physician_ind=1
    AND p.active_ind=1)
   JOIN (pa
   WHERE p.person_id=pa.person_id
    AND pa.alias_pool_cd=719676.00
    AND ((p.name_last_key="ABARE*"
    AND p.name_first_key="NATHAN*") OR (((p.name_last_key="AJELLO*"
    AND p.name_first_key="ROBERT*") OR (((p.name_last_key="ALBERT*"
    AND p.name_first_key="GRACE*") OR (((p.name_last_key="ALLEN*"
    AND p.name_first_key="HOLLEY*") OR (((p.name_last_key="ALLEN*"
    AND p.name_first_key="NANCY*") OR (((p.name_last_key="ALOUIDOR*"
    AND p.name_first_key="REGINALD*") OR (((p.name_last_key="ARENAS*"
    AND p.name_first_key="RICHARD*") OR (((p.name_last_key="ASIK*"
    AND p.name_first_key="ARMEN*") OR (((p.name_last_key="AULAKH*"
    AND p.name_first_key="SUDEEP*") OR (((p.name_last_key="BAHGAT*"
    AND p.name_first_key="CHRISTINA*") OR (((p.name_last_key="BALDER*"
    AND p.name_first_key="ANDREW*") OR (((p.name_last_key="BARRON*"
    AND p.name_first_key="ROBERTA*") OR (((p.name_last_key="BARTLEY*"
    AND p.name_first_key="MARY*") OR (((p.name_last_key="BEAULIEU*"
    AND p.name_first_key="DANIELLE*") OR (((p.name_last_key="BELLANTONIO*"
    AND p.name_first_key="SANDRA*") OR (((p.name_last_key="BENJAMIN*"
    AND p.name_first_key="EVAN*") OR (((p.name_last_key="BIGNELL*"
    AND p.name_first_key="CANDACE*") OR (((p.name_last_key="BISHOP*"
    AND p.name_first_key="TODD*") OR (((p.name_last_key="BORDEN*"
    AND p.name_first_key="SAMUEL*") OR (((p.name_last_key="BOURGEAULT*"
    AND p.name_first_key="BRIAN*") OR (((p.name_last_key="BOYLE*"
    AND p.name_first_key="ELIZABETH*") OR (((p.name_last_key="BRENNAN*"
    AND p.name_first_key="MAURA*") OR (((p.name_last_key="BROWN*"
    AND p.name_first_key="RICHARD*") OR (((p.name_last_key="CAMARANO*"
    AND p.name_first_key="GUSTAV*") OR (((p.name_last_key="CANTY*"
    AND p.name_first_key="LINDA*") OR (((p.name_last_key="CARLETON*"
    AND p.name_first_key="MARY*") OR (((p.name_last_key="CASH*"
    AND p.name_first_key="SUSAN*") OR (((p.name_last_key="CASSELLS*"
    AND p.name_first_key="LUCINDA*") OR (((p.name_last_key="CHESKY*"
    AND p.name_first_key="ALLA*") OR (((p.name_last_key="CHURCHILL*"
    AND p.name_first_key="ERIC*") OR (((p.name_last_key="COE*"
    AND p.name_first_key="NICHOLAS*") OR (((p.name_last_key="COLLINS*"
    AND p.name_first_key="MARK*") OR (((p.name_last_key="COLLINS*"
    AND p.name_first_key="SEAN*") OR (((p.name_last_key="DABAKIS*CHOQUETTE*"
    AND p.name_first_key="SUZANNE*") OR (((p.name_last_key="DEMETRI*"
    AND p.name_first_key="CHARALAMBOS*") OR (((p.name_last_key="DEMMER*"
    AND p.name_first_key="LAURIE*") OR (((p.name_last_key="DONOVAN*"
    AND p.name_first_key="JULIA*") OR (((p.name_last_key="DOUBLEDAY*"
    AND p.name_first_key="NANCY*") OR (((p.name_last_key="DUDA*"
    AND p.name_first_key="FRANCIS*") OR (((p.name_last_key="DUNBAR*"
    AND p.name_first_key="NANCY*") OR (((p.name_last_key="DUNCAN*"
    AND p.name_first_key="JOYCE*") OR (((p.name_last_key="EARLE*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="ENRIQUEZ*"
    AND p.name_first_key="CELESTE*") OR (((p.name_last_key="EZELL*"
    AND p.name_first_key="BERNICE*") OR (((p.name_last_key="FAY*"
    AND p.name_first_key="ANDREW*") OR (((p.name_last_key="FISHER*"
    AND p.name_first_key="DONNA*") OR (((p.name_last_key="FLINT*"
    AND p.name_first_key="LORING*") OR (((p.name_last_key="FLYNN*"
    AND p.name_first_key="GLENDA*") OR (((p.name_last_key="FOX*"
    AND p.name_first_key="STEPHEN*") OR (((p.name_last_key="FULFORD*"
    AND p.name_first_key="JEFFREY*") OR (((p.name_last_key="GABERMAN*"
    AND p.name_first_key="JONNA*") OR (((p.name_last_key="GANIM*"
    AND p.name_first_key="ROSE*") OR (((p.name_last_key="GARG*"
    AND p.name_first_key="ANUJA*") OR (((p.name_last_key="GARRETSON*"
    AND p.name_first_key="ADAM*") OR (((p.name_last_key="GERSTLE*"
    AND p.name_first_key="KATHERINE*") OR (((p.name_last_key="GERSTLE*"
    AND p.name_first_key="ROBERT*") OR (((p.name_last_key="GHAOUI*"
    AND p.name_first_key="RONY*") OR (((p.name_last_key="GILMORE*"
    AND p.name_first_key="HERBERT*") OR (((p.name_last_key="GOFF*"
    AND p.name_first_key="SARAH*") OR (((p.name_last_key="GOLDFIELD*"
    AND p.name_first_key="NORBERT*") OR (((p.name_last_key="GOLDSMITH*"
    AND p.name_first_key="IAN*") OR (((p.name_last_key="GONCERO*CRUZ*"
    AND p.name_first_key="GRACE*") OR (((p.name_last_key="GOODE*"
    AND p.name_first_key="SUSAN*") OR (((p.name_last_key="GORDNER*"
    AND p.name_first_key="CHELSEA*") OR (((p.name_last_key="GRAICHEN*"
    AND p.name_first_key="ALAN*") OR (((p.name_last_key="GRANOWITZ*"
    AND p.name_first_key="ERIC*") OR (((p.name_last_key="GREWAL*"
    AND p.name_first_key="SATKIRAN*") OR (((p.name_last_key="GROSSMAN*"
    AND p.name_first_key="LINDSEY*") OR (((p.name_last_key="GUHN*"
    AND p.name_first_key="AUDREY*") OR (((p.name_last_key="HADRO*"
    AND p.name_first_key="NEAL*") OR (((p.name_last_key="HAESSLER*"
    AND p.name_first_key="SARAH*") OR (((p.name_last_key="HANKS*"
    AND p.name_first_key="DEBORAH*") OR (((p.name_last_key="HARMON*"
    AND p.name_first_key="DONNA*") OR (((p.name_last_key="HIGBY*"
    AND p.name_first_key="DONALD*") OR (((p.name_last_key="HIRKO*"
    AND p.name_first_key="MARK*") OR (((p.name_last_key="ISLAM*"
    AND p.name_first_key="ASHEQUL*") OR (((p.name_last_key="IYER*"
    AND p.name_first_key="SMITHA*") OR (((p.name_last_key="JACKSON*"
    AND p.name_first_key="ANTHONY*") OR (((p.name_last_key="JAMES*"
    AND p.name_first_key="HELEN*") OR (((p.name_last_key="JEPSEN*"
    AND p.name_first_key="MARY ELLEN*") OR (((p.name_last_key="JOHNSTON*"
    AND p.name_first_key="ALICIA*") OR (((p.name_last_key="JONES*"
    AND p.name_first_key="EMLEN*") OR (((p.name_last_key="KAISER*"
    AND p.name_first_key="KRISTIN*") OR (((p.name_last_key="KASHEY*"
    AND p.name_first_key="NIKOLAUS*") OR (((p.name_last_key="KASLOVSKY*"
    AND p.name_first_key="ROBERT*") OR (((p.name_last_key="KASSIS*"
    AND p.name_first_key="PETER*") OR (((p.name_last_key="KATZ*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="KATZ*"
    AND p.name_first_key="DEBORAH*") OR (((p.name_last_key="KAUFMAN*"
    AND p.name_first_key="JEFFREY*") OR (((p.name_last_key="KIDDER*"
    AND p.name_first_key="LEILANI*") OR (((p.name_last_key="KILLIPS*"
    AND p.name_first_key="LISA*") OR (((p.name_last_key="KOENIGS*"
    AND p.name_first_key="LAURA*") OR (((p.name_last_key="KOLB*"
    AND p.name_first_key="ERIN*") OR (((p.name_last_key="KRULEWITZ*"
    AND p.name_first_key="ARTHUR*") OR (((p.name_last_key="KUGELMASS*"
    AND p.name_first_key="AARON*") OR (((p.name_last_key="KUHN*"
    AND p.name_first_key="JAY*") OR (((p.name_last_key="LAMOUREUX*"
    AND p.name_first_key="DEB*") OR (((p.name_last_key="LANGLOIS*"
    AND p.name_first_key="MARIANNE*") OR (((p.name_last_key="LAO*"
    AND p.name_first_key="ERIC*") OR (((p.name_last_key="LARIOZA*"
    AND p.name_first_key="JULIUS*") OR (((p.name_last_key="LEDERMAN*"
    AND p.name_first_key="HARVEY*") OR (((p.name_last_key="LEE*"
    AND p.name_first_key="PATRICK*") OR (((p.name_last_key="LIAUTAUD*"
    AND p.name_first_key="SYBILLE*") OR (((p.name_last_key="LICHTER*"
    AND p.name_first_key="DEREK*") OR (((p.name_last_key="LINCOLN*"
    AND p.name_first_key="THOMAS*") OR (((p.name_last_key="LONDON*"
    AND p.name_first_key="NAOMI*") OR (((p.name_last_key="LONG*"
    AND p.name_first_key="SALLY*") OR (((p.name_last_key="LUTY*"
    AND p.name_first_key="JOANNA*") OR (((p.name_last_key="MAKARI*JUDSON*"
    AND p.name_first_key="GRACE*") OR (((p.name_last_key="MARTAGON*VILLAMIL*"
    AND p.name_first_key="JOSE*") OR (((p.name_last_key="MASON*"
    AND p.name_first_key="HOLLY*") OR (((p.name_last_key="MCCANN*"
    AND p.name_first_key="JOHN*") OR (((p.name_last_key="MCCLELLAND*"
    AND p.name_first_key="ALAN*") OR (((p.name_last_key="MCQUADE*"
    AND p.name_first_key="KELLY*") OR (((p.name_last_key="MECKEL*"
    AND p.name_first_key="MARIE*") OR (((p.name_last_key="MERCADO*"
    AND p.name_first_key="DONNA*") OR (((p.name_last_key="MERCED*"
    AND p.name_first_key="MARIANGELA*") OR (((p.name_last_key="MERTENS*"
    AND p.name_first_key="WILSON*") OR (((p.name_last_key="MILLER*MACK*"
    AND p.name_first_key="ELLEN*") OR (((p.name_last_key="MUTHAVARAPU*"
    AND p.name_first_key="SATISH*") OR (((p.name_last_key="MYERS*"
    AND p.name_first_key="TASHANNA*") OR (((p.name_last_key="NATHAN*"
    AND p.name_first_key="MARTHA*") OR (((p.name_last_key="NESTEBY*"
    AND p.name_first_key="ALEAH*") OR (((p.name_last_key="NICASIO*"
    AND p.name_first_key="JOHN*") OR (((p.name_last_key="NORRIS*"
    AND p.name_first_key="MARC*") OR (((p.name_last_key="ODULIO*"
    AND p.name_first_key="ROSETTE*") OR (((p.name_last_key="O'REILLY*"
    AND p.name_first_key="JOHN*") OR (((p.name_last_key="OSAKWE*"
    AND p.name_first_key="IBITORO*") OR (((p.name_last_key="PAEZ*"
    AND p.name_first_key="ARMANDO*") OR (((p.name_last_key="PAGE*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="PALMER*"
    AND p.name_first_key="RACQUEL*") OR (((p.name_last_key="PAPPAS*"
    AND p.name_first_key="DALE*") OR (((p.name_last_key="PARIS*"
    AND p.name_first_key="YVONNE*") OR (((p.name_last_key="PATEL*"
    AND p.name_first_key="PIKESHKUMAR*") OR (((p.name_last_key="PATTERSON*"
    AND p.name_first_key="LISA*") OR (((p.name_last_key="PECK*"
    AND p.name_first_key="PAMELA*") OR (((p.name_last_key="PLAGER*"
    AND p.name_first_key="JANE*") OR (((p.name_last_key="PLUMMER*"
    AND p.name_first_key="PIXIE*") OR (((p.name_last_key="POPKIN*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="PRICE*"
    AND p.name_first_key="BERNARD*") OR (((p.name_last_key="RAGHUNATHAN*"
    AND p.name_first_key="UMA*") OR (((p.name_last_key="RANDHAWA*"
    AND p.name_first_key="SANJEEVAN*") OR (((p.name_last_key="RASMUSSEN*"
    AND p.name_first_key="YEKATHERINE*") OR (((p.name_last_key="REATIRAZA*"
    AND p.name_first_key="JOCELIN*") OR (((p.name_last_key="REDDY*"
    AND p.name_first_key="VASANTHA*") OR (((p.name_last_key="REFERMAT*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="REITER*"
    AND p.name_first_key="EDWARD*") OR (((p.name_last_key="RHEE*"
    AND p.name_first_key="SANG WON*") OR (((p.name_last_key="RICHARDSON*"
    AND p.name_first_key="MATT*") OR (((p.name_last_key="RIST*"
    AND p.name_first_key="ELIZABETH*") OR (((p.name_last_key="ROBATOR*"
    AND p.name_first_key="JAMES*") OR (((p.name_last_key="ROSE*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="ROSEN*"
    AND p.name_first_key="BETH*") OR (((p.name_last_key="ROSENBLUM*"
    AND p.name_first_key="MICHAEL*") OR (((p.name_last_key="ROTHBERG*"
    AND p.name_first_key="MICHAEL*") OR (((p.name_last_key="RYZEWICZ*"
    AND p.name_first_key="STEPHEN*") OR (((p.name_last_key="SAMALE*"
    AND p.name_first_key="JENNIFER*") OR (((p.name_last_key="SANTOS*"
    AND p.name_first_key="TONJA*") OR (((p.name_last_key="SCAVRON*"
    AND p.name_first_key="JEFFREY*") OR (((p.name_last_key="SEN*"
    AND p.name_first_key="SABYASACHI*") OR (((p.name_last_key="SEVIGNY*"
    AND p.name_first_key="CHRISTINE*") OR (((p.name_last_key="SHARRON*"
    AND p.name_first_key="MARGARET*") OR (((p.name_last_key="SHERCHAN*"
    AND p.name_first_key="POOJA*") OR (((p.name_last_key="SHIN*"
    AND p.name_first_key="JOSEPH*") OR (((p.name_last_key="SHOUKRI*"
    AND p.name_first_key="KAMAL*") OR (((p.name_last_key="SIEGE*"
    AND p.name_first_key="SCOTT*") OR (((p.name_last_key="SILVA*"
    AND p.name_first_key="ENRIQUE*") OR (((p.name_last_key="SILVERMAN*"
    AND p.name_first_key="STEPHANIE*") OR (((p.name_last_key="SKIEST*"
    AND p.name_first_key="DANIEL*") OR (((p.name_last_key="SOLON*"
    AND p.name_first_key="MICHAEL*") OR (((p.name_last_key="SOUCY*"
    AND p.name_first_key="DAVID*") OR (((p.name_last_key="STARLING*"
    AND p.name_first_key="CHRISTINE*") OR (((p.name_last_key="STARLING*"
    AND p.name_first_key="TARA*") OR (((p.name_last_key="STATZ*"
    AND p.name_first_key="INGRID*") OR (((p.name_last_key="STECHENBERG*"
    AND p.name_first_key="BARBARA*") OR (((p.name_last_key="STEINGART*"
    AND p.name_first_key="RICHARD*") OR (((p.name_last_key="STELMOKAS*"
    AND p.name_first_key="ANNE-MARIE*") OR (((p.name_last_key="STEWART*"
    AND p.name_first_key="JAMES*") OR (((p.name_last_key="STOENESCU*"
    AND p.name_first_key="MATHIAS*") OR (((p.name_last_key="STRAPP*"
    AND p.name_first_key="MICHAEL*") OR (((p.name_last_key="STRAUSS*"
    AND p.name_first_key="LOUIS*") OR (((p.name_last_key="TAYLOR*"
    AND p.name_first_key="SHERRY*") OR (((p.name_last_key="THOMAS*"
    AND p.name_first_key="ASHA*") OR (((p.name_last_key="TIWARI*"
    AND p.name_first_key="RISHITA*") OR (((p.name_last_key="TORRES*"
    AND p.name_first_key="ORLANDO*") OR (((p.name_last_key="TORRES*MUNIZ*"
    AND p.name_first_key="NORAYMAR*") OR (((p.name_last_key="TSIRKA*"
    AND p.name_first_key="ANNA*") OR (((p.name_last_key="TYLER*"
    AND p.name_first_key="KELLY*") OR (((p.name_last_key="VONGOELER*"
    AND p.name_first_key="DOROTHEA*") OR (((p.name_last_key="WAIT*"
    AND p.name_first_key="RICHARD*") OR (((p.name_last_key="WANG*"
    AND p.name_first_key="JAMES*") OR (((p.name_last_key="WILLERS*"
    AND p.name_first_key="MICHAEL*") OR (((p.name_last_key="WINSTON*"
    AND p.name_first_key="ELEANOR*") OR (((p.name_last_key="WITTCOPP*"
    AND p.name_first_key="CHRYSTAL*") OR (((p.name_last_key="WITTENBERG*"
    AND p.name_first_key="STEPHEN*") OR (((p.name_last_key="WOODS*"
    AND p.name_first_key="SHARON*") OR (((p.name_last_key="WU*"
    AND p.name_first_key="HAO MING*") OR (((p.name_last_key="YOSS*"
    AND p.name_first_key="MARCI*") OR (p.name_last_key="ZACHARIAH*"
    AND p.name_first_key="REENA*")) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
  ORDER BY p.name_last, p.name_first
  HEAD REPORT
   col 1, ",", "Last Name",
   ",", "First Name", ",",
   "Login", ",", "SMS ORG ID",
   ",", "Position", ",",
   row + 1
  HEAD p.name_last
   position = trim(uar_get_code_display(p.position_cd)), output_string = build(',"',p.name_last,'","',
    p.name_first,'","',
    p.username,'","',pa.alias,'","',position,
    '",'), col 1,
   output_string
   IF ( NOT (curendreport))
    row + 1
   ENDIF
  WITH format = variable, formfeed = none
 ;end select
 IF (email_ind=1)
  SET filename_in = trim(concat(output_dest,".dat"))
  SET filename_out = concat(format(curdate,"YYYY-MM-DD ;;D"),"x",".csv")
  DECLARE subject_line = vc
  SET subject_line = concat(curprog,"V5.1 - Baystate Health CIS Acnts inactive 1 days")
  EXECUTE bhs_ma_email_file
  CALL emailfile(filename_in,filename_out, $1,subject_line,1)
 ENDIF
#end_prog
END GO
