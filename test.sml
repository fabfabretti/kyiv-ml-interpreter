printred(
    
    Par(
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
    )
 

    ,[("a",0),("b",10),("c",20)]  
);

