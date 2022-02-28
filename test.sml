printred(
    Seq( 
        Assign("a",Integer 1),
        Par(
            Assign ("a",Integer 1),
            Choice(
                Assign ("a",Integer 1),
                Assign ("a",Integer 10)
            )
           )
    )
 

    ,[("a",0),("b",0),("res",0)]  
);
