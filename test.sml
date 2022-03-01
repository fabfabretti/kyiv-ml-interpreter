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

Par(
        
        
        Await(
            (*Op(
                Deref "c",
                mu,
                Integer 1
            )*)
            Boolean false,
            Assign(
                "a",
                Integer 10
            )
        ),
        Await(
            (*Op(
                Deref "c",
                mu,
                Integer 1
            )*)
            Boolean false,
            Assign(
                "a",
                Integer 10
            )
        )
        
    )
    ,[("a",0),("b",10),("c",1)]  
);
