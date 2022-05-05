namespace ModularMult.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;
    
    // given the quantum state |a>|b>|c>|0>, the operation returns
    // the quantum state |a>|b>|c>||ab mod c> 
    operation Multiply(aQ: Qubit[], bQ: Qubit[], modulo: Qubit[], result: Qubit[]): Unit is Adj + Ctl {
        // quantum register to store |ab> with padding treated separately
        use multPad = Qubit[Length(aQ) + Length(bQ) - Length(modulo)];
        use mult = Qubit[Length(modulo)];
        // padding of first two registers so they are the same size
        use extraPadA = Qubit[Max([Length(aQ), Length(bQ)]) - Length(aQ)];
        use extraPadB = Qubit[Max([Length(aQ), Length(bQ)]) - Length(bQ)];
        // final padding for multiplication register
        use extraPadM = Qubit[2 * Max([Length(aQ), Length(bQ)]) - Length(mult) - Length(multPad)];
        // quantum register to store the quotient of the division so it can be reversed
        use aux = Qubit[Length(modulo)];
        // padding for the division operation
        use padM1 = Qubit[Length(multPad + extraPadM)]; // applied to |modulo>
        use padM2 = Qubit[Length(multPad + extraPadM)]; // applied to |aux>

        // compute |ab>
        MultiplyI(LittleEndian(aQ + extraPadA), LittleEndian(bQ + extraPadB), LittleEndian(mult + multPad + extraPadM));
        // compute |ab mod c>
        DivideI(LittleEndian(mult + multPad + extraPadM), LittleEndian(modulo + padM1), LittleEndian(aux + padM2));
        // add to the target result register
        AddI(LittleEndian(mult), LittleEndian(result));
        // reverse so that all paddings and auxiliart registers are back to state |0>
        Adjoint DivideI(LittleEndian(mult + multPad + extraPadM), LittleEndian(modulo + padM1), LittleEndian(aux + padM2));
        Adjoint MultiplyI(LittleEndian(aQ + extraPadA), LittleEndian(bQ + extraPadB), LittleEndian(mult + multPad + extraPadM));
    }

    // operation used to numerically check the validity of the implementation
    // given a, b and modulo the operation return (a * b) % modulo
    operation Mult(a: BigInt, b: BigInt, modulo: BigInt) : Int {

        // first initialise the three quantum registers in state |a>|b>|modulo>
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);
        let mB = BigIntAsBoolArray(modulo);

        mutable asize = 0;
        for index in 0..Length(aB) - 1{
            if(aB[index]){
                set asize = index + 1;
            }
        }

        mutable bsize = 0;
        for index in 0..Length(bB) - 1{
            if(bB[index]){
                set bsize = index + 1;
            }
        }

        mutable msize = 0;
        for index in 0..Length(mB) - 1{
            if(mB[index]){
                set msize = index + 1;
            }
        }

        let size = Max([asize, bsize, msize]);

        use aQ = Qubit[size];
        use bQ = Qubit[size];
        use mQ = Qubit[size];

        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        for index in 0..Length(bB) - 1 {
            if(bB[index]) {
                X(bQ[index]);
            }
        }

        for index in 0..Length(mB) - 1 {
            if(mB[index]) {
                X(mQ[index]);
            }
        }

        // initialise quantum register in state |0> to store result
        use result = Qubit[size];

        Multiply(aQ, bQ, mQ, result);
        // prepare auxiliary register to store the numerical result
        use finalRes = Qubit[size];
        AddI(LittleEndian(result), LittleEndian(finalRes));

        let res = MeasureInteger(LittleEndian(finalRes));

        // reverse the operation to check that the qubits are still in state |0>
        Adjoint Multiply(aQ, bQ, mQ, result);

        for index in 0..Length(aB) - 1 {
            if(aB[index]) {
                X(aQ[index]);
            }
        }

        for index in 0..Length(bB) - 1 {
            if(bB[index]) {
                X(bQ[index]);
            }
        }

        for index in 0..Length(mB) - 1 {
            if(mB[index]) {
                X(mQ[index]);
            }
        }

        return res;

    }

    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation Testing_in_Superposition(numQubits:Int): Unit{
        use a = Qubit[numQubits];
        use b = Qubit[numQubits];
        use m = Qubit[numQubits];
        use res = Qubit[numQubits];

        //Putting both a and m into superposition
        ApplyToEach(H,a);
        ApplyToEach(H,b);
        ApplyToEach(H,m);

        Multiply(a,b,m,res);
        Adjoint Multiply(a, b, m ,res);
    }

    



}
