(* --- Elenco tests ---
(* Test PAR FRA VALORI - skip || skip*)
(* Test PAR FRA DUE EXP SEMPLICI - c:=10|| c:=10*)
(* Test PAR FRA DUE EXP COMPLESSE - c:=!a+10 || c:=!b+10*)
(* Test PAR FRA DUE AWAIT FALSE -  await false || await false*)
(* Test CHOICE FRA DUE VALORI skip (+) skip*)
(* Test CHOICE FRA DUE EXP SEMPLICI - c:=10 (+) c:=10*)
(* Test CHOICE FRA DUE EXP COMPLESSE - c:=!a+10 (+) c:=!a+10*)
(* Test AWAIT CON EXP COMPLESSA - await true protect (tanti passi) end*)
(* Test CHOICE FRA DUE AWAIT FALSE - await false protect skip end (+) await false protect skip end *)
*)


(* Test PAR FRA VALORI - skip || skip*)

print("===========================================================\n||"^
      " ===[skip || skip]===\n||\n"^
      "|| Test PAR FRA VALORI\n||   Mi aspetto che scelga uno skip e termini correttamente.\n"^
      "||   Mi aspetto che il tipo sia proc.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [] (
        Par(  
            Skip,
            Skip
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Par(  
            Skip,
            Skip
        )
    ,[]  
);


(* Test PAR FRA DUE EXP SEMPLICI - - c:=10|| c:=10*)

print("===========================================================\n||"^
      " ===[c:=10 || c:=10]===\n||\n"^
      "|| Test PAR FRA DUE EXP SEMPLICI\n||   Mi aspetto che svolga alternando e termini correttamente.\n"^
      "||   Mi aspetto che il tipo sia proc.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [("a",intref),("b",intref),("c",intref)] (
        Par(
            Assign(
                "c",
                Integer 10
            ),
            Assign(
                "c",
                Integer 10
            )
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Par(
        Assign(
            "c",
            Integer 10
        ),
        Assign(
            "c",
            Integer 10
        )
    )
    ,[("a",1),("b",2),("c",3)]  
);



(* Test PAR FRA DUE EXP COMPLESSE - c:=!a+10 || c:=!b+10*)

print("===========================================================\n||"^
      " ===[c:=!a+10 || c:=!b+10]===\n||\n"^
      "|| Test PAR FRA DUE EXP COMPLESSE\n||   Mi aspetto che svolga interlacciato e termini in un valore (skip).\n"^
      "||   Mi aspetto che il tipo sia proc.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [("a",intref),("b",intref),("c",intref)] (
        Par(  
            Assign(
                "c",
                Op(
                    Deref "a",
                    piu,
                    Integer 10
                )
            ),
            Assign(
                "c",
                Op(
                    Deref "b",
                    piu,
                    Integer 10
                )
            )
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
        Par(  
            Assign(
                "c",
                Op(
                    Deref "a",
                    piu,
                    Integer 10
                )
            ),
            Assign(
                "c",
                Op(
                    Deref "b",
                    piu,
                    Integer 10
                )
            )
        )
    ,[("a",1),("b",2),("c",3)]  
);



(* Test PAR FRA DUE AWAIT FALSE -  await false || await false*)

print("===========================================================\n||"^
      " ===[await false || await false]===\n||\n"^
      "|| Test PAR FRA DUE AWAIT FALSE\n||   Per come ho implementato la await, mi aspetto si blocchi subito senza fare passi.\n"^
      "||   Mi aspetto che il tipo sia proc.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [] (
        Par(  
            Await(
                Boolean false,
                Skip
            ),
            Await(
                Boolean false,
                Skip       
            )
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Par(  
        Await(
            Boolean false,
            Skip
        ),
        Await(
            Boolean false,
            Skip       
        )
    )
    ,[]  
);


(* Test CHOICE FRA DUE VALORI skip (+) skip*)

print("===========================================================\n||"^
      " ===[skip (+) skip]===\n||\n"^
      "|| Test CHOICE FRA DUE VALORI\n||   Mi aspetto che rimanga bloccato senza poter fare passi.\n"^
      "||   Mi aspetto che il tipo sia unit.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [] (
        Choice(
            Skip,
            Skip
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Choice(
        Skip,
        Skip
    )
    ,[]  
);


(* Test CHOICE FRA DUE EXP SEMPLICI - c:=10 (+) c:=10*)

print("===========================================================\n||"^
      " ===[c:=10 (+) c:=10]===\n||\n"^
      "|| Test CHOICE FRA DUE EXP SEMPLICI \n||   Mi aspetto che in un passo scelga un lato e svolga la prima operazione (deref).\n"^
      "||   Mi aspetto che il tipo sia unit.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [("a",intref),("b",intref),("c",intref)] (
        Choice(  
            Assign(
                "c",
                Integer 10
            ),
            Assign(
                "c",
                Integer 10
            )
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Choice(  
        Assign(
            "c",
            Integer 10
        ),
        Assign(
            "c",
            Integer 10
        )
    )
    ,[("a",1),("b",2),("c",3)]  
);



(* Test CHOICE FRA DUE EXP COMPLESSE - c:=!a+10 (+) c:=!a+10*)

print("===========================================================\n||"^
      " ===[c:=!a+10 (+) c:=!a+10]===\n||\n"^
      "|| Test CHOICE FRA DUE EXP COMPLESSE\n||   Mi aspetto che svolga solo uno dei rami.\n"^
      "||   Mi aspetto che il tipo sia skip.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [("a",intref),("b",intref),("c",intref)] (
        Choice(  
            Assign(
                "c",
                Op(
                    Deref "a",
                    piu,
                    Integer 10
                )
            ),
            Assign(
                "c",
                Op(
                    Deref "b",
                    piu,
                    Integer 10
                )
            )
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Choice(  
        Assign(
            "c",
            Op(
                Deref "a",
                piu,
                Integer 10
            )
        ),
        Assign(
            "c",
            Op(
                Deref "b",
                piu,
                Integer 10
            )
        )
    )
    ,[("a",1),("b",2),("c",3)]  
);


(* Test CHOICE FRA DUE AWAIT FALSE - await false protect skip end (+) await false protect skip end *)

print("===========================================================\n||"^
      " ===[await false protect skip end (+) await false protect skip end]===\n||\n"^
      "|| Test CHOICE FRA DUE AWAIT FALSE\n||   Mi aspetto che rimanga bloccato.\n"^
      "||   Mi aspetto che il tipo sia unit.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [] (
        Choice(  
            Await(
                Boolean false,
                Skip
            ),
            Await(
                Boolean false,
                Skip       
            )
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Choice(  
        Await(
            Boolean false,
            Skip
        ),
        Await(
            Boolean false,
            Skip       
        )
    )
    ,[]  
);


(* Test AWAIT CON EXP COMPLESSA - await true protect (tanti passi) end*)

print("===========================================================\n||"^
      " ===[await true protect a:=!b+!c end]===\n||\n"^
      "|| Test AWAIT CON EXP COMPLESSA\n||   Mi aspetto che i tanti passi della Await siano svolti in un passo solo.\n"^
      "||   Mi aspetto che il tipo sia unit.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [("a",intref),("b",intref),("c",intref)] (
        Await(  
            Boolean true,
            Assign(
                "a",
                Op(
                    Deref "b",
                    piu,
                    Deref "c"
                )
            )
        )
    )
);

print( "||--- REDUCE ---                        ");

printred(
    Await(  
        Boolean true,
        Assign(
            "a",
            Op(
                Deref "b",
                piu,
                Deref "c"
            )
        )
    )
    ,[("a",1),("b",2),("c",3)]  
);



(*
-- TEMPLATE DEI TEST --

(* Test A*)

print("===========================================================\n||"^
      " ===[skip || skip]===\n||\n"^
      "||   A.\n"^
      "||   A.                        ");
print("||\n||--- TYPE CHECKER ---                                                ");

valOf(
    infertype [("a",intref),("b",intref),("c",intref)] (
        A
    )
);

print( "||--- REDUCE ---                        ");

printred(
    A
    ,[("a",1),("b",2),("c",3)]  
);


*)