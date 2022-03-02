(*Potenzialmente avrei anche potuto fare che, se il lato non è derivabile, sto fermo (nel senso che ritorno 
l'espressione invariata): tuttavia in questo caso se avessi espressioni del tipo (await false... || await false...) 
mi troverei ad andare in loop infinito.
Eventualmente, l'implementazione di questo secondo scenario sarebbe la seguente:*)
  | red (Par(e1,e2),s) =
    (
      if ((Random.range(0,2) rgen) = 0) 
          then (
            case e1 of
              Skip => SOME(e2,s)
              |_ => (
                case red(e1,s) of
                  SOME (e1',s') => SOME(Par(e1',e2),s')
                  | NONE => SOME(Par(e1,e2),s)
                  )
              )
          else (
            case e2 of
              Skip => SOME(e1,s)
              |_ => (
                case red(e2,s) of
                  SOME (e2',s') => SOME(Par(e1,e2'),s')
                  | NONE => SOME(Par(e1,e2),s)
                  )
              )
    )
  