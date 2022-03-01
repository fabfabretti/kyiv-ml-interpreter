print("===========================================================\n|| TEST : [skip || skip]\n|| Mi aspetto concluda correttamente scegliendo uno skip.\nVV\n");
printred(
    Par(  
        Skip,
        Skip
    )
    ,[("a",1),("b",2),("c",3)]  
);
print("============================================================\n");

print("===========================================================\n|| TEST : [c:=!a || c:=!b]\n|| Mi aspetto concluda correttamente, facendo i passi in ordine interlacciato.\nVV\n");
printred(
    Par(  
        Assign(
            "c",
            Deref "a"
        ),
        Assign(
            "c",
            Deref "b"
        )
    )
    ,[("a",1),("b",2),("c",3)]  
);
print("============================================================\n");

print("===========================================================\n|| TEST : [c:=!a+10 || c:=!b+10]\n|| Mi aspetto concluda correttamente, facendo i passi in modo interlacciato.\nVV\n");
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
print("============================================================\n");


print("===========================================================\n|| TEST : [c:=!a || c:=!b]\n|| Mi aspetto concluda correttamente, facendo uno solo dei due rami.\nVV\n");
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
print("============================================================\n");

print("===========================================================\n|| TEST : [await false || await false]\n|| Per come ho implementato il  codice, mi aspetto che si blocchi immediatamente.\nVV\n");
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


print("===========================================================\n|| TEST : [await true (tanti passi) end ]\n|| Mi aspetto che tutti i passi interni alla await siano effettuati in un solo passo.\nVV\n");
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
    ,[("a",0),("b",10),("c",1)]  
);
print("============================================================\n");


print("===========================================================\n|| TEST : [await true a:=10 || await false]\n|| Per come ho implementato il  codice, mi aspetto che svolga tutto a sinistra e poi si blocchi.\nVV\n");
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


print("===========================================================\n|| TEST : [await false (+) await false]\n|| Mi aspetto rimanga bloccato subito.\nVV\n");
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
    ,[("a",1),("b",2),("c",3)]  
);
print("============================================================\n");

print("===========================================================\n|| TEST : [await true (+) await false]\n|| Mi aspetto svolga il ramo true.\nVV\n");
printred(
    Choice(  
        
        Await(
            Boolean false,
            Skip       
        ),
        
        Await(
            Boolean true,
            Skip       
        )
    )
    ,[("a",1),("b",2),("c",3)]  
);
print("============================================================\n");