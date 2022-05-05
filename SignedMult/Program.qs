namespace SignedMult.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;

    operation SMult(aQ: Qubit[], bQ: Qubit[], res: Qubit[]) : Unit is Adj + Ctl {
        // note that aQ is size L, bQ is size L but this is with sign as well
        // res is size 2L - 2 normal result + 1 for sign so we have
        MultiplyI(LittleEndian(aQ[0..(Length(aQ) - 2)]), 
                    LittleEndian(bQ[0..(Length(bQ) - 2)]), 
                    LittleEndian(res[0..(Length(res) - 2)]));
        Controlled X([aQ[Length(aQ) - 1]], res[Length(res) - 1]);
        Controlled X([bQ[Length(bQ) - 1]], res[Length(res) - 1]);
    }

    operation Mult(a: BigInt, b: BigInt, aSign: Bool, bSign: Bool) : Int {
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);
        use aQ = Qubit[Length(aB)];
        use bQ = Qubit[Length(bB)];
        use aSQ = Qubit();
        use bSQ = Qubit();
        if(aSign) {
            X(aSQ);
        }
        if(bSign) {
            X(bSQ);
        }

        //Message(IntAsString(Length(aB)) + " " + IntAsString(Length(bB)));

        for index in 0..Length(aB) - 1 {
            if(aB[index] == true) {
                X(aQ[index]);
            }
        }

        for index in 0..Length(bB) - 1 {
            if(bB[index] == true) {
                X(bQ[index]);
            }
        }

        use padA = Qubit[Max([Length(aQ) + 1, Length(bQ) + 1]) - Length(aQ) - 1];
        use padB = Qubit[Max([Length(aQ) + 1, Length(bQ) + 1]) - Length(bQ) - 1];
        
        use res = Qubit[Length(aQ + bQ)];
        use resSign = Qubit();
        use padRes = Qubit[2 * Max([Length(aQ), Length(bQ)]) - Length(res)];

        SMult(aQ + padA + [aSQ], bQ + padB + [bSQ] , res + padRes + [resSign]);
        
        mutable result = 0;
        set result = MeasureInteger(LittleEndian(res));
        let resS = MeasureInteger(LittleEndian([resSign]));

        if(resS == 1) {
            set result *= -1;
        }
        //let result = MeasureInteger(LittleEndian([signRes]));

        ResetAll(aQ + bQ + res + padA + padB + padRes + [resSign] + [aSQ] + [bSQ]);

        return result;
        
    }
    
    operation SignedMult(a: BigInt, b: BigInt) : BigInt {
        let c = a * b;
        return c;
    }

    operation Testing_in_Superposition(numQubits: Int): Unit{
        //let numQubits = 6;
        use a = Qubit[numQubits];
        use b = Qubit[numQubits];
        use res = Qubit[2*numQubits - 1];
        //Putting both a and b into superposition
        ApplyToEach(H,a);
        ApplyToEach(H,b);

        SMult(a,b,res);

        //MultiplyI(LittleEndian(a), LittleEndian(b), LittleEndian(res));

        //Print out Result
        //DumpMachine("TestingInSuperpositionResults.txt");
        ResetAll(a+b+res);
        
    }

}
