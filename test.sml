printred(
    
    (*Par(
        Assign(
            "a",
            Op(
                Deref "a",
                piu,
                Deref "b"
            )
        ),
        Assign(
            "a" ,
            Op(
                Deref "a",
                piu,
                Deref "c"
            )
        )
    )*)

    Await(
        Op(
            Deref "c",
            mu,
            Integer 1
        ),
        Assign(
            "a",
            Integer 10
        )
    )
 
    ,[("a",0),("b",10),("c",1)]  
);
