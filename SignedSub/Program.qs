namespace SignedSub.Testing {

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

    operation Subtract(a: BigInt, b: BigInt, aSign: Bool, bSign: Bool) : Int {
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);
        // should pad these to be same length
        use aQ = Qubit[Length(aB)];
        use bQ = Qubit[Length(bB)];

        use padA = Qubit[Max([Length(aQ), Length(bQ)]) - Length(aQ)];
        use padB = Qubit[Max([Length(aQ), Length(bQ)]) - Length(bQ)];

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
        use sign = Qubit();
        mutable result = 0;
        if(aSign == true and bSign == true) {
            // need to do a - b
            signedSub(aQ + padA, bQ + padB, sign);
            let signRes = MeasureInteger(LittleEndian([sign]));
            // if sign is 0, then result is in bQ and is positive
            // if sign is 1, then result is in aQ and is negative
            if(signRes == 0) {
                set result = MeasureInteger(LittleEndian(aQ));
            } else {
                set result = -MeasureInteger(LittleEndian(bQ));
            }
        } elif(aSign == true and bSign == false) {
            // need to do a + b
            AddI(LittleEndian(aQ + padA), LittleEndian(bQ + padB));
            set result = MeasureInteger(LittleEndian(bQ + padB));

        } elif(aSign == false and bSign == true) {
            // need to do -(a + b)
            AddI(LittleEndian(aQ + padA), LittleEndian(bQ + padB));
            set result = -MeasureInteger(LittleEndian(bQ + padB));
            
        } else {
            // need to do b - a
            // same as doing a - b but then add a - to the result
            signedSub(aQ + padA, bQ + padB, sign);
            let signRes = MeasureInteger(LittleEndian([sign]));
            // if sign is 0, then result is in bQ and is negative
            // if sign is 1, then result is in aQ and is positive
            if(signRes == 0) {
                set result = -MeasureInteger(LittleEndian(aQ));
            } else {
                set result = MeasureInteger(LittleEndian(bQ));
            }
        }

        ResetAll(aQ + bQ + [sign] + padA + padB);

        return result;

    }

    operation Testing_in_Superposition(numQubits: Int) : Unit is Adj + Ctl {
        use aQ = Qubit[numQubits];
        use bQ = Qubit[numQubits];

        ApplyToEachCA(H, aQ);
        ApplyToEachCA(H, bQ);

        use sign = Qubit();

        //signedSub(aQ, bQ, sign);

        AddI(LittleEndian(aQ), LittleEndian(bQ));

    }

}
