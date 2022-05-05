namespace UpdatedSignedSub.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    

    operation signedSub(aQ: Qubit[], bQ: Qubit[], signQubit: Qubit) : Unit is Adj + Ctl {
        // this puts aQ in state aQ - bQ
        GreaterThan(LittleEndian(aQ), LittleEndian(bQ), signQubit);
        // so this should happen if signQubit is 1 (aQ > bQ)
        Controlled Adjoint AddI([signQubit], (LittleEndian(bQ), LittleEndian(aQ)));
        X(signQubit);
        // this happens if signQubit is 0 initially, which is (aQ < bQ)
        Controlled Adjoint AddI([signQubit], (LittleEndian(aQ), LittleEndian(bQ)));
    }

    operation andGate(qubit1: Qubit, qubit2: Qubit, qubit3: Qubit): Unit is Adj + Ctl {
        Controlled X([qubit1], qubit3);
        Controlled X([qubit2], qubit3);
    }

    operation computeValue(arrQ: Qubit[]): Int {
        mutable result = 0;
        mutable power = 1;
        for index in 0..Length(arrQ) - 1{
            use temp = Qubit();
            Controlled X([arrQ[index]], temp);
            let res = MeasureInteger(LittleEndian([temp]));
            if(res == 1){
                set result = result + power;
            }
            set power = power * 2;
        }
        return result;
    }

    operation signedSubNew(aQ: Qubit[], bQ: Qubit[], areTheSame: Qubit, greater: Qubit) : Unit is Adj + Ctl {
        // areTheSame should always be 0
        // first make sure that modulo wise aQ will always be greater than bQ
        
        GreaterThan(LittleEndian(aQ[0..(Length(aQ) - 2)]), LittleEndian(bQ[0..(Length(bQ) - 2)]), greater);
        X(greater);
        for index in 0..Length(aQ) - 2{
            Controlled SWAP([greater], (aQ[index], bQ[index]));
        }

        
        // Message("Modular values of a and b (a > b) are " + IntAsString(computeValue(aQ[0..Length(aQ) - 2])) + 
        // " " + IntAsString(computeValue(bQ[0..Length(bQ) - 2])));

        // use greaterAux = Qubit();
        // GreaterThan(LittleEndian(aQ[0..(Length(aQ) - 2)]), LittleEndian(bQ[0..(Length(bQ) - 2)]), greaterAux);

        andGate(aQ[Length(aQ) - 1], bQ[Length(bQ) - 1], areTheSame);

        Controlled X([greater], bQ[Length(bQ) - 1]); // this is not correct

        Controlled SWAP([greater], (aQ[Length(aQ) - 1], bQ[Length(bQ) - 1]));

        // X(greaterAux);
        // Controlled X([greaterAux], greater);
        // X(greaterAux);

        // Adjoint GreaterThan(LittleEndian(aQ[0..(Length(aQ) - 2)]), LittleEndian(bQ[0..(Length(bQ) - 2)]), greaterAux);

        // we now know that reg aQ mod is always bigger than reg bQ so we are left only with the signs

        
        Controlled AddI([areTheSame], (LittleEndian(bQ[0..(Length(bQ) - 2)]), LittleEndian(aQ[0..Length(aQ) - 2])));
        
        X(areTheSame);
        // if they are not the same
        
        Controlled Adjoint AddI([areTheSame], (LittleEndian(bQ[0..(Length(bQ) - 2)]), LittleEndian(aQ[0..Length(aQ) - 2])));
        
        // it is enough to do this cus sign of result is same as a
        //Message("The value of greater is " + IntAsString(computeValue([greater])));
    }

    operation Subtract(a: BigInt, b: BigInt, aSign: Bool, bSign: Bool) : Int {
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);
        // should pad these to be same length
        use aQ = Qubit[Length(aB)];
        use bQ = Qubit[Length(bB)];

        use padA = Qubit[Max([Length(aQ), Length(bQ)]) - Length(aQ)];
        use padB = Qubit[Max([Length(aQ), Length(bQ)]) - Length(bQ)];

        use aS = Qubit();
        use bS = Qubit();

        if(not aSign){
            X(aS);
        }

        if(not bSign){
            X(bS);
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
        use areTheSame = Qubit();
        use greater = Qubit();
        mutable result = 0;
        
        signedSubNew(aQ + padA + [aS], bQ + padB + [bS], areTheSame, greater);

        set result = MeasureInteger(LittleEndian(aQ + padA));

        let resSign = MeasureInteger(LittleEndian([aS]));

        if(resSign == 1){
            set result = result * -1;
        }

        ResetAll(aQ + bQ + [aS] + padA + padB + [bS] + [areTheSame] + [greater]);

        return result;

    }

    operation Testing_in_Superposition(numQubits: Int) : Unit is Adj + Ctl {
        use aQ = Qubit[numQubits];
        use bQ = Qubit[numQubits];

        ApplyToEachCA(H, aQ);
        ApplyToEachCA(H, bQ);

        use sign = Qubit();
        use greater = Qubit();

        signedSubNew(aQ, bQ, sign, greater);

        //AddI(LittleEndian(aQ), LittleEndian(bQ));

    }

}
