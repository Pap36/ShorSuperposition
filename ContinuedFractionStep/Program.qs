namespace ContinuedFractionStep.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    
    open Microsoft.Quantum.Logical;
    
    // operation performs the continued fractions step on the passed quantum registers
    operation CFStep(nQ: Qubit[], dQ: Qubit[], approxDenom1: Qubit[], approxDenom2: Qubit[], auxDiv: Qubit[],
         auxMult: Qubit[], pad: Qubit[], pad1: Qubit[], convergenceIndex: Int): Unit is Adj + Ctl{
        
        DivideI(LittleEndian(nQ), LittleEndian(dQ), LittleEndian(auxDiv + pad1));
        
        for index in 0..Length(nQ) - 1{
                SWAP(nQ[index], dQ[index]);
        }
        // nQ now holds d and dQ now holds remainder

        if(convergenceIndex == 0) {
            //use one = Qubit();
            // X(one);
            // AddI(LittleEndian([one]), LittleEndian(approxDenom1));
            // AddI(LittleEndian([one]), LittleEndian(approxDenom2));
            // X(one);
            IncrementByInteger(1, LittleEndian(approxDenom1));
            IncrementByInteger(1, LittleEndian(approxDenom2));
            
        } elif(convergenceIndex == 1){

            AddI(LittleEndian(auxDiv), LittleEndian(approxDenom1));
            
            // use one = Qubit();
            // X(one);
            // Adjoint AddI(LittleEndian([one]), LittleEndian(approxDenom1));
            // X(one);
            Adjoint IncrementByInteger(1, LittleEndian(approxDenom1));

        }else {
            MultiplyI(LittleEndian(approxDenom1), LittleEndian(auxDiv), LittleEndian(auxMult + pad));
            
            AddI(LittleEndian(approxDenom2), LittleEndian(auxMult + pad));

            for index in 0..Length(approxDenom1) - 1{
                SWAP(approxDenom1[index], approxDenom2[index]);
            }

            for index in 0..Length(approxDenom1) - 1{
                SWAP(approxDenom1[index], auxMult[index]);
            }
            

        }
    }

    // operation used to numerically check the validity of the implementation
    // given the values characterizing a step of the continuous fraction algorithm, the operation
    // returns the next values in the sequence of steps
    operation testCFStep(n: BigInt, d: BigInt, approxDenom1: BigInt, approxDenom2: BigInt, convergenceIndex: Int, size: Int) : Int[] {
        
        let nB = BigIntAsBoolArray(n);
        let dB = BigIntAsBoolArray(d);
        let a1B = BigIntAsBoolArray(approxDenom1);
        let a2B = BigIntAsBoolArray(approxDenom2);

        // initialise the registers
        use nQ = Qubit[size];
        
        for index in 0..Length(nB) - 1 {
            if(nB[index] == true) {
                X(nQ[index]);
            }
        }

        use dQ = Qubit[size];
        
        for index in 0..Length(dB) - 1 {
            if(dB[index] == true) {
                X(dQ[index]);
            }
        }

        // remember the different bit-length of the numerator, denominator
        // compared with the bound and bit-length of the result
        use a1Q = Qubit[(size - 1) / 2];
        
        for index in 0..Length(a1B) - 1 {
            if(a1B[index] == true) {
                X(a1Q[index]);
            }
        }

        use a2Q = Qubit[(size - 1) / 2];
        
        for index in 0..Length(a2B) - 1 {
            if(a2B[index] == true) {
                X(a2Q[index]);
            }
        }

        use auxDiv = Qubit[(size - 1) / 2];
        use auxMult = Qubit[(size - 1) / 2];
        use pad = Qubit[(size - 1) / 2];
        use pad1 = Qubit[(size - 1) / 2 + 1];
        CFStep(nQ, dQ, a1Q, a2Q, auxDiv, auxMult, pad, pad1, convergenceIndex);

        // we need the values of nQ, dQ, a1Q, a2Q - everything else is garbage
        
        let nRes = MeasureInteger(LittleEndian(nQ));
        let dRes = MeasureInteger(LittleEndian(dQ));
        let denom1Res = MeasureInteger(LittleEndian(a1Q + pad));
        let denom2Res = MeasureInteger(LittleEndian(a2Q));

        return [nRes, dRes, denom1Res, denom2Res];

    }

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation testCFSQubitCount(registerSize: Int): Unit {
        use aQ = Qubit[2 * registerSize + 1];
        use bQ = Qubit[2 * registerSize + 1];
        use aD1 = Qubit[registerSize];
        use aD2 = Qubit[registerSize];
        use auD = Qubit[registerSize];
        use auM = Qubit[registerSize];
        use pad = Qubit[registerSize];
        use pad1 = Qubit[registerSize + 1];

        ApplyToEach(H, aQ);
        ApplyToEach(H, bQ);
        ApplyToEach(H, aD1);
        ApplyToEach(H, aD2);

        CFStep(aQ, bQ, aD1, aD2, auD, auM, pad, pad1, 3);
        Adjoint CFStep(aQ, bQ, aD1, aD2, auD, auM, pad, pad1, 3);
        
    }

}
