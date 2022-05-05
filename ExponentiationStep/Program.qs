namespace ExponentiationStep.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;    
    open ModularMult.Testing;
    open ModularSquare.Testing;

    // given the quantum state |a>|b>|c>|curr>|0>, the operation returns
    // the quantum state |a>|b>|c>|curr>|curr^2 mod c> if b in state |0>
    // or                |a>|b>|c>|curr>|((curr^2 mod c) * a) mod c> if b in state |1>
    operation SingleStep(aQ: Qubit[], bQ: Qubit, cQ: Qubit[], currValueQ: Qubit[], newValueQ: Qubit[]) : Unit is Adj + Ctl {
        use temp = Qubit[Length(newValueQ)];
        // first square current value modulo c
        ModularSquare(currValueQ, cQ, temp);
        // depending on the value of b, multiply modulo c with a
        Controlled Multiply([bQ], (temp, aQ, cQ, newValueQ));
        X(bQ);
        // add the result to the new value
        Controlled AddI([bQ], (LittleEndian(temp), LittleEndian(newValueQ)));
        X(bQ);
        Adjoint ModularSquare(currValueQ, cQ, temp);
    }

    // operation used to numerically check the validity of the implementation
    // given a, b, c and curr the operation performs the square and multiplu step
    // return (curr^2 mod c) if b == 0 or ((curr^2 mod c) * a) mod c if b == 1
    operation testSingleStep(a: BigInt, b: Bool, c: BigInt, curr: BigInt): Int {
        
        // initialize the initial quantum registers in state |a>|b>|c>|curr>
        let aB = BigIntAsBoolArray(a);
        let cB = BigIntAsBoolArray(c);

        mutable asize = 0;
        for index in 0..Length(aB) - 1{
            if(aB[index]){
                set asize = index + 1;
            }
        }

        mutable csize = 0;
        for index in 0..Length(cB) - 1{
            if(cB[index]){
                set csize = index + 1;
            }
        }

        let size = Max([asize, csize]);

        use aQ = Qubit[size];
        
        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        
        use cQ = Qubit[size];
        
        for index in 0..Length(cB) - 1 {
            if(cB[index]) {
                X(cQ[index]);
            }
        }

        let currB = BigIntAsBoolArray(curr);
        
        use currQ = Qubit[size];
        for index in 0..Length(currB) - 1 {
            if(currB[index]) {
                X(currQ[index]);
            }
        }

        use bQ = Qubit();
        if(b) {
            X(bQ);
        }
        
        // initialise an quantum register to store the result
        use resQ = Qubit[size];
        SingleStep(aQ, bQ, cQ, currQ, resQ);
        // use another auxiliary register to find the numerical result
        use finalRes = Qubit[size];
        AddI(LittleEndian(resQ), LittleEndian(finalRes));
        let result = MeasureInteger(LittleEndian(finalRes));

        // reverse the operation
        Adjoint SingleStep(aQ, bQ, cQ, currQ, resQ);

        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        for index in 0..Length(cB) - 1 {
            if(cB[index]) {
                X(cQ[index]);
            }
        }

        for index in 0..Length(currB) - 1 {
            if(currB[index]) {
                X(currQ[index]);
            }
        }

        if(b) {
            X(bQ);
        }

        return result;
        
    }

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation testQubitCount(regSize: Int): Unit {
        use (aQ, b, cQ, currValueQ, newValueQ) = (Qubit[regSize], Qubit(), Qubit[regSize], Qubit[regSize], Qubit[regSize]);

        H(b);
        ApplyToEach(H, aQ);
        ApplyToEach(H, cQ);
        ApplyToEach(H, currValueQ);

        SingleStep(aQ, b, cQ, currValueQ, newValueQ);
        Adjoint SingleStep(aQ, b, cQ, currValueQ, newValueQ);
        
    }

}
