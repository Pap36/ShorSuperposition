namespace ModularSquare.Testing {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Arrays;


    // operation used to numerically check the validity of the implementation
    // given a and b the operation return (a * a) % b
    operation modularSquare(a: BigInt, b: BigInt) : Int {
        // begin by initialising two registers to be in states
        // |a> |b>
        let aB = BigIntAsBoolArray(a);
        let bB = BigIntAsBoolArray(b);

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

        let size = Max([asize, bsize]);

        use aQ = Qubit[size];
        use bQ = Qubit[size];
        for index in 0..Length(aB) - 1{
            if(aB[index]){
                X(aQ[index]);
            }
        }

        for index in 0..Length(bB) - 1{
            if(bB[index]){
                X(bQ[index]);
            }
        }

        // quantum register to store the result into
        use result = Qubit[size];
        ModularSquare(aQ, bQ, result);
        // use auxiliary result register so that the operation can be reversed
        use finalResQ = Qubit[size];
        AddI(LittleEndian(result), LittleEndian(finalResQ));

        let finalRes = MeasureInteger(LittleEndian(finalResQ));
        // reverse the operation to check the validity
        Adjoint ModularSquare(aQ, bQ, result);

        for index in 0..Length(aB) - 1{
            if(aB[index]){
                X(aQ[index]);
            }
        }

        for index in 0..Length(bB) - 1{
            if(bB[index]){
                X(bQ[index]);
            }
        }

        return finalRes;

    }

    // given the quantum state |a>|b>|0>, the operation returns
    // the quantum state |a>|b>|a ^ 2 mod b> 
    operation ModularSquare(aQ : Qubit[], bQ : Qubit[], result : Qubit[]) : Unit is Adj + Ctl{
        // quantum register to store the quotient of the division between a^2 and b
        use div = Qubit[2 * Length(aQ)];
        // padding registers due to MQDK operations requirements
        use padB = Qubit[Length(div) - Length(bQ)];
        use padA = Qubit[Length(div) - Length(result)];
        // compute a^2
        SquareI(LittleEndian(aQ), LittleEndian(result + padA));
        // compute the remainder mod b
        DivideI(LittleEndian(result + padA), LittleEndian(bQ + padB), LittleEndian(div));
        // now we are in |aQ> = |a>, |bQ> = |b>, |result> = |a^2 mod b>, |div = a^2 / b>

        use placeHolder = Qubit[Length(result)];
        AddI(LittleEndian(result), LittleEndian(placeHolder));
        // reverse division so that the registers initialised inside the operation are back in state |0>
        Adjoint DivideI(LittleEndian(placeHolder + padA), LittleEndian(bQ + padB), LittleEndian(div));
        Adjoint SquareI(LittleEndian(aQ), LittleEndian(placeHolder + padA));

        // pad, div and placeholder should all be 0
    }


    // operation used to set up a superposition of values using the Hadamard gat
    // so that the operation can be checked when running in superposition
    // also provides a good estimate for the number of qubits required when running
    // the resource estimator
    operation Testing_in_Superposition(numQubits : Int): Unit{
        
        use (a,m,t) = (Qubit[numQubits],Qubit[numQubits],Qubit[numQubits]);
        //Putting both a and m into superposition
        ApplyToEach(H,a);
        ApplyToEach(H,m);

        ModularSquare(a,m,t);
        Adjoint ModularSquare(a, m, t);

    }
}
