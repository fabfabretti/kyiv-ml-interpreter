load "Random";
val rgen = Random.newgen();

type loc = string

datatype oper = piu | mu

datatype exp =
        Boolean of bool
    |   Integer of int
    |   Op of exp * oper * exp
    |   If of exp * exp * exp
    |   Assign of loc * exp
    |   Skip 
    |   Seq of exp * exp
    |   While of exp * exp
    |   Deref of loc 
    |   Par of exp * exp
    |   Choice of exp * exp
    |   Await of exp * exp

fun valore (Integer n) = true
  | valore (Boolean b) = true
  | valore (Skip) = true
  | valore _ = false


type store = (loc * int) list

(*e1 -> e2*)

(*(exp * store) -> (exp * store) option*)
(*(''a * b) list *''a ->ib option*)

fun lookup ( [], l ) = NONE
  | lookup ( (l',n')::pairs, l) = 
    if l=l' then SOME n' else lookup (pairs,l)


(* fn:store * (loc*int)->store option *)

(* fn: (''a * 'b) list -> (''a * 'b) list -> ''a * 'b -> (''a * 'b) list option *)

fun update'  front [] (l,n) = NONE
 |  update'  front ((l',n')::pairs) (l,n) = 
    if l=l' then 
        SOME(front @ ((l,n)::pairs) )
    else 
        update' ((l',n')::front) pairs (l,n)

fun update (s, (l,n)) = update' [] s (l,n)

fun red (Integer n,s) = NONE (*int*)
  | red (Boolean b,s) = NONE (*bool*)
  | red (Op (e1,opr,e2),s) = 
    (case (e1,opr,e2) of
         (Integer x1, piu, Integer x2) => SOME(Integer (x1+x2), s)   (*op+*)
       | (Integer x1, mu, Integer x2) => SOME(Boolean (x1 >= x2), s)(*op>=*)
       | (e1,opr,e2) => (                                               
         if (valore e1) then (                                        
             case red (e2,s) of 
                 SOME (e2',s') => SOME (Op(e1,opr,e2'),s')     (*op2*)
               | NONE => NONE )                           
         else (                                                 
             case red (e1,s) of 
                 SOME (e1',s') => SOME(Op(e1',opr,e2),s')      (*op1*)
               | NONE => NONE ) ) )
  | red (If (e1,e2,e3),s) =
    (case e1 of
         Boolean(true) => SOME(e2,s)                           
       | Boolean(false) => SOME(e3,s)                          
       | _ => (case red (e1,s) of
                   SOME(e1',s') => SOME(If(e1',e2,e3),s')      (*if*)
                 | NONE => NONE ))
  | red (Deref l,s) = 
    (case lookup  (s,l) of                
          SOME n => SOME(Integer n,s)      (*deref*)                    
        | NONE => NONE )                  
  | red (Assign (l,e),s) =                                  
    (case e of                                                 
         Integer n => (case update (s,(l,n)) of  (*assign1*)
                           SOME s' => SOME(Skip, s')           
                         | NONE => NONE)                                   
       | _ => (case red (e,s) of                           
                   SOME (e',s') => SOME(Assign (l,e'), s')   (*assign2*) 
                 | NONE => NONE  ) )                          
  | red (While (e1,e2),s) = SOME( If(e1,Seq(e2,While(e1,e2)),Skip),s) (* (while) *)
  | red (Skip,s) = NONE   (*skip*)                                  
  | red (Seq (e1,e2),s) =                                   
    (case e1 of                                                 
        Skip => SOME(e2,s)      (*seq.skip*)                               
      | _ => ( case red (e1,s) of                           
                 SOME (e1',s') => SOME(Seq (e1',e2), s') (*seq*)      
               | NONE => NONE ) 
    )  
(*
Decido di implementare la par nel seguente modo: se il lato che ho estratto con la monetina non ?? derivabile,
provo a derivare l'altro lato. 
Il modo in cui implemento lo scenario che ho scelto ?? spiegato dal seguente schema:
  (ho provato a spiegarlo a parole come ho fatto per choice e await, ma essendo innestato su molti
  livelli mi sembra pi?? chiaro il grafo...)

                random estrae che            random estree che
                          va a sx ?????????????????????????????? va a dx
                              ???????????????e1 || e2???????????????
                              ???   ??????????????????????????????   ???
                             ?????????             ????????????
      ??????????????????   e1=skip       ??? ???             ???  ???  e2=skip   ??????????????????
      ??? e2 ????????????????????????????????????????????????????????? ???             ???  ?????????????????????????????????????????? e1 ???
      ??????????????????                   ???             ???               ??????????????????
                               ???             ???
                    e1 not skip???             ??? e2 not skip
                   ???????????????????????????????????????             ???????????????????????????????????????
                   ???                                     ???
                  ????????????????????????                          ??????????????????????????????e2'
              e1' ???      ???e1'                    e2'???        ???esiste
  ??????????????????????????? esiste???      ???non                    non???        ???      ?????????????????????????????????
  ???e1'||e2???????????????????????????      ???esiste              esiste???        ????????????????????????e1 || e2'???
  ???????????????????????????              ???                          ???               ?????????????????????????????????
                Non posso svolgere            Non posso svolgere
                 a sinistra; vado              a destra; vado
                     a destra                     a sinistra
                         ???                          ???
    ????????????   e2=skip   ?????????????????????                      ?????????????????????   e1=skip   ????????????
    ???e1?????????????????????????????????????????????     ???e2 not          e1 not???     ?????????????????????????????????????????????e2???
    ????????????                   ??? skip             skip???                   ????????????
                   ???????????????????????????                      ??????????????????????????????
                   ???                                       ???
   e2'???????????????????????????????????????????????? e2' non esiste      e1' non esiste???????????????????????????????????????e1'
esiste???              ??? e non ?? skip          e non ?? skip???           ???esiste
      ???              ???                                   ???           ???
  ?????????????????????????????????    ???????????????????????????                           ???????????????????????????    ????????????????????????????????????
  ???e1 || e2'???    ???bottom ??? -> (es. await false) <-   ???bottom ???    ???e1' || e2 ???
  ?????????????????????????????????    ???????????????????????????                           ???????????????????????????    ????????????????????????????????????*)
  | red (Par(e1,e2),s) =
    (
      if ((Random.range(0,2) rgen) = 0) 
          then (
            case e1 of
              Skip => SOME(e2,s)
              |_ => (
                case red(e1,s) of
                  SOME (e1',s') => SOME(Par(e1',e2),s')
                  | NONE => 
                    case e2 of 
                      Skip => SOME(e1,s)
                      |_ => (
                        case red(e2,s) of
                          SOME(e2',s) => SOME(Par(e1,e2'),s)
                          | NONE => NONE
                      )
                  )
              )
         
          else (
            case e2 of
              Skip => SOME(e1,s)
              |_ => (
                case red(e2,s) of
                  SOME (e2',s') => SOME(Par(e1,e2'),s')
                  | NONE => (
                    case red(e1,s) of
                      SOME(e1',s') => SOME(Par(e1',e2),s')
                      | _ => (
                        case e1 of
                        Skip => SOME(e2,s)
                        |_ => (case red(e1,s) of
                                SOME(e1',s) => SOME(Par(e1',e2),s)
                                | NONE => NONE
                        )
                      )
                  )
              )
          )
    )
    | red(Choice(e1,e2),s) = (
      if ((Random.range(0,2) rgen) = 0)
        then ( (* Se estraggo 0 provo ad andare a sinistra *)
          case red(e1,s) of
            SOME(e1',s') => SOME (e1',s') (*Se a sinistra ?? derivabile, allora butto via il lato destro e svolgo un passo del lato sinistro*)
            | NONE => (
              case red(e2,s) of (*Se a sinistra NON ?? derivabile, allora provo a derivare a destra*)
                SOME (e2',s') => SOME (e2',s') (* Se a destra ?? derivabile butto via il lato sinistro e faccio un passo a destra*)
                | NONE => NONE (*Altrimenti ?? bloccato. *)
            )
        )
        else ( (*Se estraggo 1 provo ad andare a destra*)
          case red(e2,s) of
            SOME (e2',s') => SOME(e2',s') (*Se a destra ?? derivabile, allora butto via il lato sinistro e svolgo un passo del lato destro*)
            | NONE =>(
              case red(e1,s) of (*Se a destra NON ?? derivabile, allora provo a derivare a sinistra*)
                SOME(e1',s') => SOME (e1',s') (*Se a sinistra ?? derivabile, butto via il lato destro e faccio un passo a sinistra*)
                | NONE => NONE (*Altrimenti ?? bloccato. *)
            )
        )
    )
    | red(Await(e1,e2),s) = (
      let
        fun evaluate (e,s) = case red(e,s) of (*Mi servirebbe la big step per ottenere il risultato in un passo, ma ?? definita in seguito 
        (e usa la red, quindi non posso dichiararla prima). Dunque me la ridefinisco qui.*)
                                SOME(e',s') => evaluate(e',s')
                                | NONE => (e,s)
      in
        (
          case evaluate(e1,s) of (*Svolgo in un passo tutta la condizione per vedere se ?? vera o falsa.*)
             (Boolean true,s') => ( (* Se ?? vera, allora svolgo tutto il corpo e ritorno Skip *)
               case evaluate (e2,s') of
                (Skip,s'') => SOME(Skip,s'')
                | _ => NONE
             )
            | (Boolean false,s') => NONE (*Se ?? falsa sto fermo: non ho alcuna derivazione possibile. (?? ridondante, ma per chiarezza lo lascio)*)
            | _ => NONE 
        )
      end
    )




fun evaluate (e,s) = case red (e,s) of 
                         NONE => (e,s)
                       | SOME (e',s') => evaluate (e',s')


(*   e,s -> e2,s2 ---..... *)


datatype type_L =  int  | unit  | bool | proc; (*aggiungo proc per gestire il tipo della PAR*)


datatype type_loc = intref

type typeE = (loc*type_loc) list 


fun infertype gamma (Integer n) = SOME int
  | infertype gamma (Boolean b) = SOME bool
  | infertype gamma (Op (e1,opr,e2)) 
    = (case (infertype gamma e1, opr, infertype gamma e2) of
          (SOME int, piu, SOME int) => SOME int
        | (SOME int, mu, SOME int) => SOME bool
        | _ => NONE)
  | infertype gamma (If (e1,e2,e3)) 
    = (case (infertype gamma e1, infertype gamma e2, infertype gamma e3) of
           (SOME bool, SOME t2, SOME t3) => 
           (if t2=t3 then SOME t2 else NONE)
         | _ => NONE)
  | infertype gamma (Deref l) 
    = (case lookup (gamma,l) of
           SOME intref => SOME int
         | NONE => NONE)
  | infertype gamma (Assign (l,e)) 
    = (case (lookup (gamma,l), infertype gamma e) of
           (SOME intref,SOME int) => SOME unit
         | _ => NONE)
  | infertype gamma (Skip) = SOME unit
  | infertype gamma (Seq (e1,e2))  
    = (case (infertype gamma e1, infertype gamma e2) of
           (SOME unit, SOME t2) => SOME t2
         | _ => NONE )
  | infertype gamma (While (e1,e2)) 
    = (case (infertype gamma e1, infertype gamma e2) of
           (SOME bool, SOME unit) => SOME unit 
         | _ => NONE )
  | infertype gamma (Par(e1,e2))
    = (
      case (infertype gamma e1, infertype gamma e2) of
        (SOME unit, SOME unit) => SOME proc
        | (SOME unit, SOME proc) => SOME proc
        | (SOME proc, SOME unit) => SOME proc
        | (SOME proc, SOME proc) => SOME proc (*Dalle regole, e1 ed e2 possono essere qualunque combinazione di unit e proc*)
        | _ => NONE
    )
  | infertype gamma (Choice(e1,e2))
  = (
    case (infertype gamma e1, infertype gamma e2) of
      (SOME unit, SOME unit) => SOME unit
      | _ => NONE
  )
  | infertype gamma (Await(e1,e2)) = (
    case(infertype gamma e1, infertype gamma e2) of
    (SOME bool, SOME unit) => SOME unit
    | _ => NONE
  );


load "Listsort";
load "Int";
load "Bool";


fun printop piu = "+"
  | printop mu = ">="
                         
fun printexp (Integer n) = Int.toString n
  | printexp (Boolean b) = Bool.toString b
  | printexp (Op (e1,opr,e2)) 
    = "(" ^ (printexp e1) ^ (printop opr) 
      ^ (printexp e2) ^ ")"
  | printexp (If (e1,e2,e3)) 
    = "if " ^ (printexp e1 ) ^ " then " ^ (printexp e2)
      ^ " else " ^ (printexp e3)
  | printexp (Deref l) = "!" ^ l
  | printexp (Assign (l,e)) =  l ^ ":=" ^ (printexp e )
  | printexp (Skip) = "skip"
  | printexp (Seq (e1,e2)) =  (printexp e1 ) ^ ";" 
                                     ^ (printexp e2)
  | printexp (While (e1,e2)) =  "while " ^ (printexp e1 ) 
                                       ^ " do " ^ (printexp e2)
  | printexp (Par(e1,e2)) = "(" ^(printexp e1) ^ " || " ^ (printexp e2)^ ")"
  | printexp (Choice(e1,e2)) = "( " ^ (printexp e1) ^ " (+) " ^ (printexp e2) ^ ")"
  | printexp (Await(e1,e2)) = "await ("^(printexp e1)^") protect ("^(printexp e2)^") end"

fun printstore' [] = ""
  | printstore' ((l,n)::pairs) = l ^ "=" ^ (Int.toString n) 
                                   ^ " " ^ (printstore' pairs)

fun printstore pairs = 
    let val pairs' = Listsort.sort 
                         (fn ((l,n),(l',n')) => String.compare (l,l'))
                         pairs
    in
        "{" ^ printstore' pairs' ^ "}" end


fun printconf (e,s) = "< " ^ (printexp e) 
                             ^ " , " ^ (printstore s) ^ " >"


fun printred' (e,s) = 
    case red (e,s) of 
        SOME (e',s') => 
        ( TextIO.print ("\n -->  " ^ printconf (e',s') ) ;
          printred' (e',s'))
      | NONE => (TextIO.print "\n -/->  " ; 
                 if valore e then 
                     TextIO.print "(a value)\n" 
                 else 
                     TextIO.print "(stuck - not a value)" )

fun printred (e,s) = (TextIO.print ("      "^(printconf (e,s))) ;
                          printred' (e,s))


