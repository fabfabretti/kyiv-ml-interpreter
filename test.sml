print("===========================================================\nTEST 1 : [await false || await false]\n[Per come ho implementato il  codice, mi aspetto che si blocchi immediatamente.]\n\n\n");
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
    ,[("a",0),("b",10),("c",1)]  
);
print("============================================================\n");

print("===========================================================\nTEST 1 : [await true a:=10 || await false]\n[Per come ho implementato il  codice, mi aspetto che svolga tutto a sinistra e poi si blocchi.]\n\n\n");
printred(
    Par(  
        Await(
            Boolean true,
            Assign(
                "a",
                Integer 10
            )
        ),
        Await(
            Boolean false,
            Skip       
        )
    )
    ,[("a",0),("b",10),("c",1)]  
);
print("============================================================\n");
